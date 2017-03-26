// http://en.wikipedia.org/wiki/Iterated_function_system

package  
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.ui.Mouse;
	import __AS3__.vec.Vector;
        import gs.TweenMax;
        import gs.easing.*;
	import net.hires.debug.Stats;

	[SWF(backgroundColor = "0x000000", frameRate = "30")]
	public class Main extends Sprite
	{
		public function Main():void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			init(stage.stageWidth, stage.stageHeight);
			addChild(view);
			//addChild(new Stats());
			stage.quality = "low";
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			Mouse.cursor = flash.ui.MouseCursor.BUTTON;
			stage.addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(Event.ENTER_FRAME, onEnter);

		}

		private function onClick(e:MouseEvent):void 
		{
			change();
		}

		private function onEnter(e:Event):void 
		{
			transforms[0].rotation += 0.002;
			transforms[1].rotation -= 0.003;
			transforms[2].rotation += 0.005;
			transforms[3].rotation -= 0.007;
			draw();
		}

		private var w: int;
		private var h: int;
		private var mw: int;
		private var mh: int;
		public var view: Bitmap;
		private var bmpData: BitmapData;
		private var buffer: Vector.<uint>;
		private var randomSeed: int;
		private var num: int;
		private var count: int = 0;

		private static const NUM_PARTICLES:uint = 175000;	
		private static const NUM_TRANSFORMS:uint = 4;	
		private var transforms:Vector.<Transform>;

		private var tonedown:ColorTransform;
		private var filter:BlurFilter;

		public function init(w: int, h: int):void
		{
			this.w = w;
			mw = w >> 1;
			this.h = h;
			mh = h >> 1;
			bmpData = new BitmapData(w, h, false, 0x00000000);
			buffer = bmpData.getVector(bmpData.rect);
			buffer = new Vector.<uint>(w * h, true);
			view = new Bitmap(bmpData);
			tonedown = new ColorTransform(
			    .95,.95,.95,.95,
			    -5,-5,-5,-5);
			filter = new BlurFilter(1.5, 1.5, 1);

			// init matrix and color arrays
			transforms = new Vector.<Transform>;
			for( var i:uint = 0; i < NUM_TRANSFORMS; i++ ) {
				transforms.push( new Transform );
			}

			change();
		}
		
		protected var point:Point = new Point;
		protected var color:uint = 0xFFFFFF;

		public function draw(): void
		{
			var b: Vector.<uint> = buffer;

			var bi: uint;
			var ti: uint;
			
			var rnd: Number
			var tmp:uint;
			
			bmpData.lock();
			b = bmpData.getVector(bmpData.rect);

			var x:int, y:int;
			var newx:Number;
                        var xform:Transform;

			for( var i:uint = 0; i < NUM_PARTICLES; i++ ) {
                                xform = transforms[int(Math.random() * NUM_TRANSFORMS)];
                                // It's too bad that Matrix.transformPoint creates a new Point object
                                newx    = point.x * xform.a + point.y * xform.b + xform.tx;
                                point.y = point.x * xform.c + point.y * xform.d + xform.ty;
                                point.x = newx;

				x = point.x * 150 + mw;
				y = point.y * 150 + mh;

				color = ((color & 0xFEFEFE) + (xform.color & 0xFEFEFE)) >>> 1;
				if( x >= 0 && x < w && y >= 0 && y < h )
				{
					bi = y * w + x;
					b[bi] = ((color & 0xFEFEFE) + (b[bi] & 0xFEFEFE)) >>> 1;
				}
			}
			
			bmpData.setVector(bmpData.rect, b);
			bmpData.applyFilter(bmpData, bmpData.rect, new Point(0,0), filter);
			bmpData.colorTransform(bmpData.rect, tonedown);
			bmpData.unlock();
		}
		
		public function change(): void
		{
			for( var i:uint = 0; i < NUM_TRANSFORMS; i++ ) {
				TweenMax.to( transforms[i], 3.5, {
						delay: i/6,
						ease: Bounce.easeOut,
						tx: Math.random() * 2 - 1,
						ty: Math.random() * 2 - 1,
						scaleX: Math.random() * 0.5 + 0.25,
						scaleY: Math.random() * 0.5 + 0.25,
						rotation: transforms[i].rotation + (Math.random() - 0.5) * 2 * Math.PI,
                                                hexColors:{color:Math.random()*0xFFFFFF | 0x202020} } );
			}
		}
	}
}

import flash.geom.*;
// ugly tween wrapper
class Transform extends Matrix {
	private var _x:Number = 0;
	private var _y:Number = 0;
	private var _scaleX:Number = 1;
	private var _scaleY:Number = 1;
	private var _rotation:Number = 0;
	public var color:uint = 0xFFFFFF;

	public function set rotation( angle:Number ):void {
		_rotation = angle;
		update();
	}

	public function set scaleX( value:Number ):void {
		_scaleX = value;
		update();
	}

	public function set scaleY( value:Number ):void {
		_scaleY = value;
		update();
	}

	public function get rotation():Number {
		return _rotation;
	}

	public function get scaleX():Number {
		return _scaleX;
	}

	public function get scaleY():Number {
		return _scaleY;
	}

	private function update():void {
		var tmpty:Number = ty;
		var tmptx:Number = tx;
		identity();
		scale( _scaleX, _scaleY );
		rotate( _rotation );
		ty = tmpty;
		tx = tmptx;
	}
}
