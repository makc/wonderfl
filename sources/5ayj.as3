package {
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.filters.BlurFilter;
	
	[SWF(width = "465", height = "465", backgroundColor = "0x000000", frameRate = "30")]
	
	public class etudeNative3D extends Sprite {
        private const STAGE_WIDTH:uint = 465;
        private const STAGE_HEIGHT:uint = 465;
        private const STAGE_CENTER_X:Number = STAGE_WIDTH * 0.5;
        private const STAGE_CENTER_Y:Number = STAGE_HEIGHT * 0.5;
		private var _canvas:BitmapData;
		private var _glow:BitmapData;
		private var _rect:Rectangle;
		private var _cTra:ColorTransform;
		private var mapList:Array = [];
		private var totalParticle:uint = 3600;
		private var particles:Array = [];
		private var mtx3D:Matrix3D = new Matrix3D();
		private var projection:PerspectiveProjection;
		private var projectionMatrix3D:Matrix3D;
		public function etudeNative3D() {
			init();
		}
		private function init():void {
			addChild( new Bitmap( _canvas = new BitmapData ( STAGE_WIDTH, STAGE_HEIGHT, true, 0x00FFFFFF ) ) );
			
			_glow = new BitmapData( STAGE_WIDTH/4, STAGE_HEIGHT/4, false, 0x0 );
			var bm:Bitmap = addChild( new Bitmap( _glow, PixelSnapping.NEVER, true ) ) as Bitmap;
			bm.scaleX = bm.scaleY = 4;
			bm.blendMode = BlendMode.ADD;
			
			_rect = new Rectangle( 0, 0, STAGE_WIDTH, STAGE_HEIGHT );
			_cTra = new ColorTransform( 0.95, 0.95, 0.95, 1.0 );
			
			projection = new PerspectiveProjection();
			projection.fieldOfView = 90;
			projectionMatrix3D = projection.toMatrix3D();
			
			mapList = textToBit();
			for ( var i:uint = 0; i < totalParticle; i++ ) {
				var particle:Particle = new Particle();
				particles.push( particle );
				var tmpPoint:Point = purposeMaker()
				particle.dx = tmpPoint.x;
				particle.dy = tmpPoint.y;
			}
			addEventListener( Event.ENTER_FRAME, onEnterFrameHandler );
		}
		private function textToBit():Array {
			var tmpList:Array = [];
			var accuracy:Number = 2;
			var threshold:uint = 0x00FFFFFF;
			for ( var i:uint = 0; i < 11; i++ ) {
				var txt:TextField = new TextField();
				txt.x = 0;
				txt.y = 0;
				txt.width = 90;
				txt.height = 90;
				txt.type = TextFieldType.DYNAMIC;
				txt.selectable = false;
				var tf:TextFormat = new TextFormat();
				
				tf.font = "Font Bold";
				tf.size = 80;
				tf.align = TextFormatAlign.CENTER;
				txt.textColor = 0xFFFFFF;
				txt.defaultTextFormat = tf;
				if ( i < 10 ) {
					txt.text = String( i );
				} else {
					txt.text = ":";
				}
				
				var tw:uint = txt.width / accuracy;
				var th:uint = txt.height / accuracy;
				var mapData:BitmapData = new BitmapData( tw, th, true, 0x00000000 );
				var matrix:Matrix = new Matrix();
				matrix.scale( 1 / accuracy, 1 / accuracy );
				mapData.draw(txt, matrix);

				var byteArray:ByteArray = mapData.getPixels( new Rectangle( 0, 0, mapData.width, mapData.height ) );
				byteArray.position = 0;
				tmpList[ i ] = [];
				for (var n:uint = 0; n < tw * th; n++) {
					var color:uint = byteArray.readInt();
					if ( color > threshold ) {
						var pos:uint = n;
						var px:Number = ( pos % tw ) * accuracy + txt.x;
						var py:Number = Math.floor(pos / tw) * accuracy + txt.y;
						tmpList[ i ].push( { dx:px, dy:py, dz:0 } );
					}
				}
			}
			return tmpList;
		}
		private function purposeMaker():Point {
			var destination:Point = new Point();
			var totalType:uint = 8;
			var rndtxt:int = int( Math.random() * totalType );
			
			var nDate:Date = new Date();
			var Hour:String = String(nDate.hours + 100);
			Hour = Hour.substring( 1, 3)
			var Minute:String = String(nDate.minutes + 100);
			Minute = Minute.substring( 1, 3)
			var Second:String = String(nDate.seconds + 100);
			Second = Second.substring(1, 3)
			var str:String = Hour + ":" + Minute + ":" + Second;
			
			str = str.substring( rndtxt, rndtxt + 1 );
			
			if( rndtxt == 2 || rndtxt == 5 ) {
				var dispTxt:uint = 10;
			} else {
				dispTxt = int( str );
			}
			var rndpoint:int = int( Math.random() * mapList[ dispTxt ].length );
			destination.x = mapList[ dispTxt ][ rndpoint ].dx + rndtxt * 50 - ( totalType * 50 * 0.5 );
			destination.y = mapList[ dispTxt ][ rndpoint ].dy - 45;
			return destination;
		}
		private function onEnterFrameHandler( eventObject:Event ):void {
			var vertices3D:Vector.<Number> = new Vector.<Number>();
			var projectedVerts:Vector.<Number> = new Vector.<Number>();
			var uvts:Vector.<Number> = new Vector.<Number>();
			var offsetZ:Number = 300;
			
			for ( var i:uint = 0; i < totalParticle; i++ ) {
				particles[ i ].update();
				vertices3D.push( particles[ i ].px, particles[ i ].py, particles[ i ].pz );
			}
			mtx3D.identity();
			mtx3D.appendRotation( -20, Vector3D.Y_AXIS);
			mtx3D.appendRotation( 20, Vector3D.X_AXIS);
			mtx3D.appendTranslation( 0, 0, offsetZ );
			mtx3D.append( projectionMatrix3D );
			bugfix( mtx3D );
			
			Utils3D.projectVectors( mtx3D, vertices3D, projectedVerts, uvts );
			
			var variation:Number = 0.04;
			var ctx:Number =  mouseX / 465;
			var cty:Number = mouseY / 465;
			if ( ctx > 0.95 ) {
				ctx = 0.95;
			} else if ( ctx < 0.05 ) {
				ctx = 0.05;
			}
			if ( cty > 0.95 ) {
				cty = 0.95;
			} else if ( cty < 0.05 ) {
				cty = 0.05;
			}
			if ( ctx > _cTra.redMultiplier ) {
				_cTra.redMultiplier += variation;
			} else {
				_cTra.redMultiplier -= variation;
			}
			if ( cty > _cTra.blueMultiplier ) {
				_cTra.blueMultiplier += variation;
			} else {
				_cTra.blueMultiplier -= variation;
			}
			
			_canvas.lock();
			_canvas.applyFilter( _canvas, _rect, new Point(), new BlurFilter( 1.6, 1.6 ) );
			_canvas.colorTransform( _rect, _cTra );
			var pvLength:uint = projectedVerts.length * 0.5;
			for ( var j:uint = 0; j < pvLength; j++ ) {
				if ( particles[ j ].arrivalFlag ) {
					particles[ j ].renew();
					var tmpPoint:Point = purposeMaker();
					particles[ j ].dx = tmpPoint.x;
					particles[ j ].dy = tmpPoint.y;
				}
				if( uvts[ j * 3 + 2 ] > 0 ) {
					_canvas.setPixel32( projectedVerts[ j * 2 ] + STAGE_CENTER_X, projectedVerts[ j * 2 + 1 ] + STAGE_CENTER_Y, 0xFF999999 );
				}
			}
			_canvas.unlock();
			_glow.fillRect( _glow.rect, 0x00000000 );
			_glow.draw( _canvas, new Matrix( 0.25, 0, 0, 0.25 ) );
		}
		private function bugfix( matrix:Matrix3D ):void {
			var m1:Matrix3D = new Matrix3D(Vector.<Number>( [ 0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 1, 0 ] ) );
			var m2:Matrix3D = new Matrix3D(Vector.<Number>( [ 0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 1,  0, 0, 0, 0 ] ) );
			m1.append( m2 );
			if ( m1.rawData[15] == 20 ) {
				var rawData:Vector.<Number> = matrix.rawData;
				rawData[15] /= 20;
				matrix.rawData = rawData;
			}
		}
	}
}
class Particle {
	public var px:Number;
	public var py:Number;
	public var pz:Number;
	public var dx:Number = 0;
	public var dy:Number = 0;
	public var dz:Number = 0;
	public var easingX:Number = Math.random() * 0.08 + 0.16;
	public var easingY:Number = Math.random() * 0.08 + 0.16;
	public var easingZ:Number = Math.random() * 0.08 + 0.16;
	
	private const range:Number = 0.1;
	public var distance:Number;
	public var arrivalFlag:Boolean = false;
	
	public function Particle() {
		renew();
	}
	public function update():void {
		px += ( dx - px ) * easingX;
		py += ( dy - py ) * easingY;
		pz += ( dz - pz ) * easingZ;
		
		distance = Math.sqrt( ( dx - px ) * (dx - px ) + ( dy - py ) * ( dy - py ) + ( dz - pz ) * ( dz - pz ) );
		
		if ( distance < range ) {
			arrivalFlag = true;
		}
	}
	public function renew():void {
		px = Math.random() * 800 - 400;
		py = dy;
		pz = Math.random() * 4000 - 2000;
		
		arrivalFlag = false;
	}
}