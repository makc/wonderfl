package {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.*;

	[SWF(width="465", height="465", frameRate="40")]
	public class Firework extends Sprite
	{
		// 火花
		private var position:Vector.<Number> = new Vector.<Number>();
		private var velocity:Vector.<Number> = new Vector.<Number>();
		private var diameters:Vector.<Number> = new Vector.<Number>();
		private var sparkNumber:Number = 0;
		
		private var projectedPosition:Vector.<Number> = new Vector.<Number>();
		private var uvts:Vector.<Number> = new Vector.<Number>();
		
		private var sparkBitmapDatas:Vector.<BitmapData> = new Vector.<BitmapData>();
		private var sparkBitmapDataRectangles:Vector.<Rectangle> = new Vector.<Rectangle>();
		private const SPARK_COLOR:uint = 0x664020;
		
		private const GRAVITY:Number = 0.02;
		private const AIR_RESISTANCE:Number = 0.999;
		
		// 1フレームに放出する火花の数
		private const EMIT_SPARK_NUMBER:int = 3;
		
		// 照り返し
		private var reflectionBitmapData:BitmapData;
		private const REFLECTION_COLOR:uint = 0xFF1800;
		private const REFLECTION_RADIUS:Number = 16;
		
		// フレームバッファ
		private var displayBuffer:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false);
		private var splitBuffer:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false);
		private const NUMBER_OF_SPLIT_FRAME:int = 10;
		
		private var perspective:PerspectiveProjection = new PerspectiveProjection();
		private var projectionMatrix:Matrix3D = new Matrix3D();
		
		private var viewRotationY:Number = 0;
		private var viewRotationX:Number = 25;
		
		private const CENTER_X:Number = stage.stageWidth / 2;
		private const CENTER_Y:Number = stage.stageHeight * 0.65;
		
		private var stats:TextField = new TextField();
		
		public function Firework()
		{
			addChild(new Bitmap(displayBuffer));

			stats.x = 5;
			stats.y = 5;
			stats.autoSize = TextFieldAutoSize.LEFT;
			stats.textColor = 0xFFFFFF;
			addChild(stats);
			
			var shape:Shape = new Shape();
			var g:Graphics = shape.graphics;
			
			// 火花のプリレンダリング
			var bitmapData:BitmapData = new BitmapData(1, 1, true, SPARK_COLOR);
			sparkBitmapDatas.push(bitmapData);
			sparkBitmapDataRectangles.push(bitmapData.rect);
			
			for (var diameter:int = 1; diameter <= 32; diameter++) {
				bitmapData = new BitmapData(diameter, diameter, true, 0);
				
				g.clear();
				g.beginFill(SPARK_COLOR);
				var radius:Number = diameter / 2;
				g.drawCircle(radius, radius, radius);
				g.endFill();
				bitmapData.draw(shape);
				
				sparkBitmapDatas.push(bitmapData);
				sparkBitmapDataRectangles.push(bitmapData.rect);
				// bitmapData.rectはアクセサで重いのでキャッシュしておく。これにより30%ほど高速化
			}
			
			// 照り返しのプリレンダリング
			reflectionBitmapData = new BitmapData(REFLECTION_RADIUS * 2, REFLECTION_RADIUS * 2, true, 0);
			g.clear();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(REFLECTION_RADIUS * 2, REFLECTION_RADIUS * 2, 0, 0, 0);
			g.beginGradientFill(GradientType.RADIAL, [ REFLECTION_COLOR, REFLECTION_COLOR ], [ 1, 0 ], [ 0, 255 ], matrix);
			g.drawCircle(REFLECTION_RADIUS, REFLECTION_RADIUS, REFLECTION_RADIUS);
			g.endFill();
			reflectionBitmapData.draw(shape);
			
			createFireworkModel();
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
//			stage.addEventListener(MouseEvent.CLICK, function (e:Event):void {
//				emitSpark();
//			});
		}
		
		private function enterFrameHandler(e:Event):void
		{
			displayBuffer.fillRect(displayBuffer.rect, 0);
			
			setupProjectionMatrix();
			
			var startTime:uint = getTimer();
			renderFloor();
			var floorRenderingTime:uint = getTimer() - startTime;
			
			startTime = getTimer();
			for (var i:int = 0; i < NUMBER_OF_SPLIT_FRAME; i++) {
				const FACTOR:Number = 0.06;
				viewRotationY += (getTimer() * 0.01 + (-(CENTER_X - mouseX) * 0.4) - viewRotationY) * FACTOR;
				viewRotationX += ((27 + (CENTER_Y - mouseY) * 0.15) - viewRotationX) * FACTOR;
				
				setupProjectionMatrix();
				
				for (var j:int = 0; j < EMIT_SPARK_NUMBER; j++) {
					emitSpark();
				}
				updateSparks();
				renderSparks();
			}
			var sparksRenderingTime:uint = getTimer() - startTime;
			
			stats.text = 
				"Number of Sparks : " + sparkNumber + "\n" + 
				"Floor Rendering Time : " + floorRenderingTime + " ms\n" + 
				"Sparks Rendering Time : " + sparksRenderingTime + " ms \n";
		}
		
		private function setupProjectionMatrix():void
		{
			perspective.fieldOfView = 60;
			
			projectionMatrix.identity();
			projectionMatrix.appendRotation(viewRotationY, Vector3D.Y_AXIS);
			projectionMatrix.appendRotation(viewRotationX, Vector3D.X_AXIS);
			projectionMatrix.appendTranslation(0, 0, perspective.focalLength);
			projectionMatrix.append(perspective.toMatrix3D());
			
			correctMatrix3DMultiplyBug(projectionMatrix);
		}
		
		private function correctMatrix3DMultiplyBug(matrix:Matrix3D):void
		{
			// see http://bugs.adobe.com/jira/browse/FP-670
			var m1:Matrix3D = new Matrix3D(Vector.<Number>([ 0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 1, 0 ]));
			var m2:Matrix3D = new Matrix3D(Vector.<Number>([ 0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 1,  0, 0, 0, 0 ]));
			m1.append(m2);
			if (m1.rawData[15] == 20) {
				// バグ持ち！
				var rawData:Vector.<Number> = matrix.rawData;
				rawData[15] /= 20;
				matrix.rawData = rawData;
			}
		}
		
		private function createSpark(x:Number, y:Number, z:Number, vx:Number, vy:Number, vz:Number, diameter:Number):void
		{
			position.push(x, y, z);
			velocity.push(vx, vy, vz);
			diameters.push(diameter);
			sparkNumber++;
		}
		
		private function emitSpark():void
		{
			var azimuth:Number = Math.random() * 2 * Math.PI;
			var vy:Number = -(Math.random() * 0.06 + 0.94);
			var vx:Number = Math.sqrt(1 - vy * vy) * Math.cos(azimuth);
			var vz:Number = Math.sqrt(1 - vy * vy) * Math.sin(azimuth);
			
			var speed:Number = Math.random() * 2.3 + 0.7;
			vx *= speed;
			vy *= speed;
			vz *= speed;
			
			var diameter:Number = 3 + Math.random() * 3;
			createSpark(0, -FIREWORK_HEIGHT, 0, vx, vy, vz, diameter);
		}
		
		private function updateSparks():void
		{
			for (var i:int = 0; i < sparkNumber; ) {
				var xIndex:int = i * 3;
				var yIndex:int = xIndex + 1;
				var zIndex:int = xIndex + 2;
				
				velocity[yIndex] += GRAVITY;
				
				velocity[xIndex] *= AIR_RESISTANCE;
				velocity[yIndex] *= AIR_RESISTANCE;
				velocity[zIndex] *= AIR_RESISTANCE;
				
				if (position[yIndex] + velocity[yIndex] > 0) {
					velocity[yIndex] = -velocity[yIndex] * 0.2;
					
					position[xIndex] += velocity[xIndex];
					position[yIndex] += velocity[yIndex];
					position[zIndex] += velocity[zIndex];
					
					// 小さい火花に分割
					const DIAMETER_MIN:Number = 2;
					if (diameters[i] > DIAMETER_MIN) {
						var diameterLimit:Number = diameters[i];
						
						while (1) {
							var diameter:Number = Math.random() * (4 - DIAMETER_MIN) + DIAMETER_MIN;
							diameterLimit -= diameter;
							if (diameterLimit < 0) {
								break;
							}
							var azimuth:Number = Math.random() * 2 * Math.PI;
							var r:Number = Math.random() * 2;
							
							createSpark(position[xIndex], position[yIndex], position[zIndex], 
								(velocity[xIndex] + Math.cos(azimuth) * r) * 0.5, 
								velocity[yIndex], 
								(velocity[zIndex] + Math.sin(azimuth) * r) * 0.5, 
								diameter);
						}
					}
					
					// spliceは重い！
//					position.splice(xIndex, 3);
//					velocity.splice(xIndex, 3); 
//					diameters.splice(i, 1);

					position[xIndex] = position[sparkNumber * 3 - 3];
					position[yIndex] = position[sparkNumber * 3 - 2];
					position[zIndex] = position[sparkNumber * 3 - 1];

					velocity[xIndex] = velocity[sparkNumber * 3 - 3];
					velocity[yIndex] = velocity[sparkNumber * 3 - 2];
					velocity[zIndex] = velocity[sparkNumber * 3 - 1];
					
					diameters[i] = diameters[sparkNumber - 1];
					
					position.pop();
					position.pop();
					position.pop();

					velocity.pop();
					velocity.pop();
					velocity.pop();
					
					diameters.pop();
					
					sparkNumber--;
					continue;
				}
				position[xIndex] += velocity[xIndex];
				position[yIndex] += velocity[yIndex];
				position[zIndex] += velocity[zIndex];
				
				i++;
			}
		}
		
		private function renderSparks():void
		{
			splitBuffer.fillRect(splitBuffer.rect, 0x000000);
			
			Utils3D.projectVectors(projectionMatrix, position, projectedPosition, uvts);
			
			// ループ外に追い出したら30%以上高速化
			var p:Point = new Point();
			var focalLength:Number = perspective.focalLength;
			
			for (var i:int = 0; i < sparkNumber; i++) {
				// パーティクルの大きさ = 1/z * focalLength * pixel
				var diameter:int = uvts[i * 3 + 2] * focalLength * diameters[i] + 0.5;
				// (i * 2) => (i << 1)で10%ほど高速化
				p.x = CENTER_X + projectedPosition[(i << 1)    ] - diameter / 2;
				p.y = CENTER_Y + projectedPosition[(i << 1) + 1] - diameter / 2;
				splitBuffer.copyPixels(sparkBitmapDatas[diameter], sparkBitmapDataRectangles[diameter], p);
			}
			
			displayBuffer.draw(splitBuffer, null, null, BlendMode.ADD);
		}
		
		private const FLOOR_SIZE:Number = 300;
		private const FLOOR_HALFSIZE:Number = FLOOR_SIZE / 2;
		private const FLOOR_VERTICES:Vector.<Number> = Vector.<Number>([
			 FLOOR_HALFSIZE, 0,  FLOOR_HALFSIZE, 
			-FLOOR_HALFSIZE, 0,  FLOOR_HALFSIZE, 
			-FLOOR_HALFSIZE, 0, -FLOOR_HALFSIZE, 
			 FLOOR_HALFSIZE, 0, -FLOOR_HALFSIZE, 
			 
			 FLOOR_HALFSIZE, 0,               0, 
			-FLOOR_HALFSIZE, 0,               0, 
			              0, 0,  FLOOR_HALFSIZE, 
			              0, 0, -FLOOR_HALFSIZE, 
		]);
		private const FLOOR_VERTEX_NUMBER:int = FLOOR_VERTICES.length / 3;
		
		private var floorProjectedVertices:Vector.<Number> = new Vector.<Number>();
		private var floorIndices:Vector.<int> = Vector.<int>([
			0, 1, 2,  2, 3, 0
		]);
		private var floorUvts:Vector.<Number> = Vector.<Number>([
			1, 0, 0,  0, 0, 0,  0, 1, 0,  1, 1, 0,  
			0, 0, 0,  0, 0, 0,  0, 0, 0,  0, 0, 0
		]);
		
		private const TEXTURE_SIZE:int = 150;
		private var floorTexture:BitmapData = new BitmapData(TEXTURE_SIZE, TEXTURE_SIZE, false);
		
		private const WIREFRAME_COLOR:uint = 0x555566;
		
		private var sprite:Sprite = new Sprite();
		
		private function renderFloor():void
		{
			// 照り返しを描画する閾値
			const THRESHOLD_Y:Number = 50;
			
			var matrix:Matrix = new Matrix();
			var colorTransform:ColorTransform = new ColorTransform();
			
			floorTexture.fillRect(floorTexture.rect, 0x180C00);
			
			for (var i:int = 0; i < sparkNumber; i++) {
				var yIndex:int = i * 3 + 1;
				
				if (position[yIndex] > -THRESHOLD_Y) {
					var xIndex:int = i * 3;
					var zIndex:int = i * 3 + 2;
					
					matrix.identity();
					var scale:Number = (0.2 - (position[yIndex] / THRESHOLD_Y) * 0.8) * diameters[i];
					matrix.scale(scale, scale);
					matrix.translate(FLOOR_HALFSIZE + position[xIndex] - REFLECTION_RADIUS * scale, FLOOR_HALFSIZE - position[zIndex] - REFLECTION_RADIUS * scale);
					matrix.scale(TEXTURE_SIZE / FLOOR_SIZE, TEXTURE_SIZE / FLOOR_SIZE);
					
					colorTransform.alphaMultiplier = 1 + position[yIndex] / THRESHOLD_Y;
					floorTexture.draw(reflectionBitmapData, matrix, colorTransform, BlendMode.ADD);
				}
			}
			
			Utils3D.projectVectors(projectionMatrix, FLOOR_VERTICES, floorProjectedVertices, floorUvts);
			for (i = 0; i < FLOOR_VERTEX_NUMBER; i++) {
				floorProjectedVertices[(i << 1)    ] += CENTER_X;
				floorProjectedVertices[(i << 1) + 1] += CENTER_Y;
			}
			
			Utils3D.projectVectors(projectionMatrix, fireworkVertices, fireworkProjectedVertices, fireworkUvts);
			for (i = 0; i < fireworkProjectedVertices.length / 2; i++) {
				fireworkProjectedVertices[(i << 1)    ] += CENTER_X;
				fireworkProjectedVertices[(i << 1) + 1] += CENTER_Y;
			}
			
			var g:Graphics = sprite.graphics;
			g.clear();
			g.beginBitmapFill(floorTexture);
			g.drawTriangles(floorProjectedVertices, floorIndices, floorUvts);
			g.endFill();
			displayBuffer.draw(sprite);
			
			g.clear();
			g.lineStyle(1, WIREFRAME_COLOR);
			g.moveTo(floorProjectedVertices[0], floorProjectedVertices[1]);
			g.lineTo(floorProjectedVertices[2], floorProjectedVertices[3]);
			g.lineTo(floorProjectedVertices[4], floorProjectedVertices[5]);
			g.lineTo(floorProjectedVertices[6], floorProjectedVertices[7]);
			g.lineTo(floorProjectedVertices[0], floorProjectedVertices[1]);
			
			g.moveTo(floorProjectedVertices[8], floorProjectedVertices[9]);
			g.lineTo(floorProjectedVertices[10], floorProjectedVertices[11]);
			g.moveTo(floorProjectedVertices[12], floorProjectedVertices[13]);
			g.lineTo(floorProjectedVertices[14], floorProjectedVertices[15]);
			displayBuffer.draw(sprite, null, null, BlendMode.ADD);
			
			g.clear();
			g.beginFill(FIREWORK_COLOR);
			g.drawTriangles(fireworkProjectedVertices, fireworkIndices);
			g.endFill();
			displayBuffer.draw(sprite);
		}
		
		private const FIREWORK_RADIUS:Number = 8;
		private const FIREWORK_HEIGHT:Number = 40;
		private const FIREWORK_COLOR:uint = 0xAACCFF;
		
		private var fireworkVertices:Vector.<Number> = new Vector.<Number>();
		private var fireworkIndices:Vector.<int> = new Vector.<int>();
		private var fireworkProjectedVertices:Vector.<Number> = new Vector.<Number>();
		private var fireworkUvts:Vector.<Number> = new Vector.<Number>();
		
		private function createFireworkModel():void
		{
			const SEGMENT:int = 8;
			for (var i:int = 0; i < SEGMENT; i++) {
				var x:Number = Math.cos(2 * Math.PI * i / SEGMENT) * FIREWORK_RADIUS;
				var z:Number = Math.sin(2 * Math.PI * i / SEGMENT) * FIREWORK_RADIUS;
				fireworkVertices.push(x, -FIREWORK_HEIGHT, z);
				fireworkVertices.push(x, 0, z);
				
				var i0:int = (i * 2    ) % (SEGMENT * 2);
				var i1:int = (i * 2 + 1) % (SEGMENT * 2);
				var i2:int = (i * 2 + 2) % (SEGMENT * 2);
				var i3:int = (i * 2 + 3) % (SEGMENT * 2);
				fireworkIndices.push(i2, i0, i1);
				fireworkIndices.push(i1, i3, i2);
			}
		}
	}
}


