// forked from yonatan's static ifs fractals (click to cycle)
// forked from masuda's forked from: 250000 particle flow shimulation
// forked from fladdict's 250000 particle flow shimulation
// forked from fladdict's 20万個ぱーてぃくる 途中で飽きたけど 25万個は狙えるはず
// forked from beinteractive's forked from: 10万個ぱーてぃくる - 軽く高速化
// forked from bkzen's 10万個ぱーてぃくる

/*
http://www.be-interactive.org/index.php?itemid=458
↓
http://blog.joa-ebert.com/2009/04/03/massive-amounts-of-3d-particles-without-alchemy-and-pixelbender/
↓
http://www.joa-ebert.com/files/swf/pure/Main.as

の流れでBitmapData.setVector
*/
package  
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import __AS3__.vec.Vector;
	
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
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(Event.ENTER_FRAME, onEnter);
			
		}
		
		private function onClick(e:MouseEvent):void 
		{
			change();
		}
		
		private function onEnter(e:Event):void 
		{
			matrices[0].rotation += 0.002;
			matrices[1].rotation -= 0.003;
			matrices[2].rotation += 0.005;
			matrices[3].rotation -= 0.007;
			draw();
		}

		private var w: int;
		private var h: int;
		private var mw: int;
		private var mh: int;
		public var view: Bitmap;
		private var bmpData: BitmapData;
		private var buffer: Vector.<uint>;
		private var forceMap: BitmapData;
		private var randomSeed: int;
		private var num: int;
		private var color: uint = 0x100804;
		private var count: int = 0;
		private var colorTr: ColorTransform;

		private static const NUM_PARTICLES:uint = 50000;	
		private static const numMatrices:uint = 4;	
		private var matrices:Array;

		public function init(w: int, h: int):void
		{
			this.w = w;
			mw = w >> 1;
			this.h = h;
			mh = h >> 1;
			bmpData = new BitmapData(w, h, false, 0x00000000);
			buffer = new Vector.<uint>(w * h, true);
			view = new Bitmap(bmpData);
			
			change();
		}
		
		// 描画、マウスの判定を後で追加予定
		public function draw(): void
		{
			var b: Vector.<uint> = buffer;

			var bi: uint;
			var mi: uint;
			
			var rnd: Number
                        var tmp:uint;
			
			var n: int = b.length;
			while (--n > -1) 
                            if(b[n])
                                b[n] = ((b[n] & 0xF0F0F0) >>> 3)*7;
			//while (--n > -1) b[n] = 0;

			var point:Point = new Point;
			
			for( var i:uint = 0; i < NUM_PARTICLES; i++ ) {
				mi = Math.random() * numMatrices;
				point = matrices[mi].transformPoint(point);
        		point.x += mw;
				point.y += mh;
				if( point.x >= 0 
					&& point.y >= 0 
					&& point.x < w 
					&& point.y < h )
				{
					bi = (point.y >> 0) * w + (point.x >> 0);
    				
                                        tmp = b[bi] + color;
					if( tmp < 0xFFFFFF ) {
                                            b[bi] = tmp;
                                        }
				}
			}
			
			bmpData.lock();
			bmpData.setVector(bmpData.rect, b);
			bmpData.unlock();
		}
		
		public function change(): void
		{
			function rndMatrix():EZMatrix {
				var ret:EZMatrix = new EZMatrix;
				ret.rotation = ( Math.random() * Math.PI*2 );
				ret.scaleX = (Math.random() + 0.5)/2;
				ret.scaleY = (Math.random() + 0.5)/2;
				
				ret.tx = Math.random()*4-2;
				ret.ty = Math.random()*4-2;
				return ret;
			}
			color = (Math.random() * 0xFFFFFF) & 0x0F0F0F | 0x100000;;
			matrices = new Array;
			for( var i:uint = 0; i < numMatrices; i++ ) {
				matrices.push( rndMatrix() );
			}
		}
	}
}

import flash.geom.*;
// ugly tween wrapper
class EZMatrix extends Matrix {
	private var _x:Number = 0;
	private var _y:Number = 0;
	private var _scaleX:Number = 1;
	private var _scaleY:Number = 1;
	private var _rotation:Number = 0;

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
