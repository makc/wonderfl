// いろんなところがいいかげん。
package {
	import flash.display.StageQuality;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.events.Event;
	
	[SWF(backgroundColor="0")]
	public class Grass extends Sprite {
		private var container:Sprite; // 草の入れ物
		
		// 草の設定。
		private var leng:uint = 135;
		private var thickness:Number = .07;
		private var color_array:Array = [];
		private var rand_array:Array = [];
		
		private var fieldWidth:uint = 350;
		private var fieldHeight:uint = 300;
		private var centerX:Number = fieldWidth / 2;
		private var centerY:Number = fieldHeight / 2;
		
		private var space:uint = 15;// 草の間隔
		private var w:uint = fieldWidth / space;;
		private var h:uint= fieldHeight / space;;
		
		// 風用のperlinNoise
		private var perlin_bmd:BitmapData;
		private var seed:int = Math.round(Math.random() * 100);
		private var speed:int = 1; // 風の早さ
		private var offsetPoint:Point = new Point(speed, 0);
		private var damping:Number = -0.000005; // 風の強さ調整用
		
		//
		private var focusLength:uint = 500;
		private var angX:Number = 0;
		private var angY:Number = 0;
		
		public function Grass() {
			stage.quality = StageQuality.MEDIUM;
			
			perlin_bmd = new BitmapData(w, h);
			
			for (var r:uint = 0; r < h; r++) {
				color_array[r] = [];
				rand_array[r] = [];
				for (var c:uint = 0; c < w; c++) {
					color_array[r][c] = RGBtoHEX(Math.round(Math.random() * 34), Math.round(Math.random() * 128) + 102, Math.round(Math.random() * 68));
					var randX:Number = Math.random() * (space / 1.5) - (space / 1.5);
					var randZ:Number = Math.random() * (space / 1.5) - (space / 1.5);
					rand_array[r][c] = {x:randX, z:randZ};
				}
			}

			container = new Sprite();
			container.x = stage.stageWidth / 2;
			container.y = stage.stageHeight / 2 + leng / 2;
			container.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addChild(container);
		}
		
		private function enterFrameHandler(eventObject:Event):void {
			// perlinNoiseのスクロール
			offsetPoint.offset(speed, 0);
			perlin_bmd.perlinNoise(w / 2, h / 2, 1, seed, false, false, 1, true, [offsetPoint]);

			container.graphics.clear();
			angX = (mouseX - 200) / 5 * -1;
			angY = (mouseY - 200) / 5;
			// ↑回りすぎないように適当に調整
			
			for (var r:uint = 0; r < h; r++) {
				for (var c:uint = 0; c < w; c++) {
					drawGrass(c, 0, r);
				}
			}
		}
		
		// 草の描画
		private function drawGrass(xp:uint, yp:uint, zp:int):void {
			var power:Number = perlin_bmd.getPixel(xp, zp) * damping;
		
			var controlX:Number = Math.sin(DegToRad(power / 4)) * leng / 4;
			var controlY:Number = Math.cos(DegToRad(power / 4)) * leng / 1.4 * -1;
			var topX:Number = Math.sin(DegToRad(power)) * leng + xp * space;
			var topY:Number = Math.cos(DegToRad(power)) * leng * -1;
			var posZ:int = zp * space - centerY;
			
			var point1:Object = perspective(rotationXY(angX, angY, {x:xp * space - centerX, y:yp, z:posZ}));
			var point2:Object = perspective(rotationXY(angX, angY, {x:controlX + xp * space - centerX, y:controlY - power / 10, z:posZ}));
			var point3:Object = perspective(rotationXY(angX, angY, {x:topX - centerX, y:topY, z:posZ}));
			var point4:Object = perspective(rotationXY(angX, angY, {x:controlX / 2 + xp * space - centerX, y:controlY, z:posZ}));
			var point5:Object = perspective(rotationXY(angX, angY, {x:leng * thickness + xp * space - centerX, y:yp, z:posZ}));
		
			container.graphics.beginFill(color_array[zp][xp], 100);
			container.graphics.moveTo(point1["x"] + rand_array[zp][xp]["x"], point1["y"] + rand_array[zp][xp]["z"]);
			container.graphics.curveTo(point2["x"] + rand_array[zp][xp]["x"], point2["y"] + rand_array[zp][xp]["z"], point3["x"] + rand_array[zp][xp]["x"], point3["y"] + rand_array[zp][xp]["z"]);
			container.graphics.curveTo(point4["x"] + rand_array[zp][xp]["x"], point4["y"] + rand_array[zp][xp]["z"], point5["x"] + rand_array[zp][xp]["x"], point5["y"] + rand_array[zp][xp]["z"]);
			container.graphics.lineTo(point1["x"] + rand_array[zp][xp]["x"], point1["y"] + rand_array[zp][xp]["z"]);
			container.graphics.endFill();
		}
		
		private function RGBtoHEX(r:uint, g:uint, b:uint):int { return (r << 16 | g << 8 | b); }
		private function DegToRad(nDegree:Number):Number { return (nDegree * Math.PI / 180); }
		
		private function perspective(points:Object):Object {
			var temp:Object = {x:0, y:0};
			var nZ:Number = focusLength / (focusLength - points.z);
			temp.x = points.x * nZ;
			temp.y = points.y * nZ;
			return temp;
		}
	
		private function rotationXY(x:Number, y:Number, points:Object):Object {
			var temp:Object = points;
			
			var rX:Number = DegToRad(x);
			var rY:Number = DegToRad(y);
			var nY:Number, nX:Number, nZ:Number;
		
			nZ = temp.z;
			nY = temp.y;
			temp.z = nZ * Math.cos(rY) - nY * Math.sin(rY);
			temp.y = nY * Math.cos(rY) + nZ * Math.sin(rY);
		
			nX = temp.x;
			nZ = temp.z;
			temp.x = nX * Math.cos(rX) - nZ * Math.sin(rX);
			temp.z = nZ * Math.cos(rX) + nX * Math.sin(rX);
			
			return temp;
		}
	}
}