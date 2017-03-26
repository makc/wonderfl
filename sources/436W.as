// forked from paq's forked from: 重力マウス（ちょっぴり軽量化してみた）
// forked from fumix's 重力マウス（リンクリストにしてみた）
// forked from undo's 重力マウス
//　リンクリストにしてみたけどそんなに速くない？？
//_bmd.fillRect()を_bmd.setPixel()に変更。
//sin(),cos(),atan2(),sqrt()を排除。
package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import net.hires.debug.Stats;

	[SWF(frameRate='60', backgroundColor='0x0')]

	public class ParticleTest1 extends Sprite
	{
		private var _bmp:Bitmap;
		private var _bmd:BitmapData;
		private var _bmdRect:Rectangle;
		private var _colorTransform:ColorTransform = new ColorTransform(0.9, 0.0, 0.9, 1.0);

		private var _nodeArray:Array = [];
		private var _first:Node;
		private var _maxNum:int = 30000;
		
		//private var _rect:Rectangle = new Rectangle(0, 0, 1, 1);

		public function ParticleTest1()
		{
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			var old:Node;

			_bmd = new BitmapData(465, 465, false, 0x000000);
			_bmp = new Bitmap(_bmd);
			addChild(_bmp);
			this._bmdRect = new Rectangle(0, 0, 465, 465);

			for (var i:int = 0; i < this._maxNum; i++)
			{
				var n:Node = new Node();
				n.pos_x = Math.random() * 465;
				n.pos_y = Math.random() * 465;
				this._nodeArray.push(n);
				//リンクリスト
				if (_first == null) {
					old = _first = n;
				} else {
					old.next = n;
					old = n;
				}
			}
			
			addChild(new Stats());
			addEventListener(Event.ENTER_FRAME, onEnter);
		}

		private function onEnter(evt:Event):void
		{
			//var gravPoint:Point = new Point(mouseX, mouseY);
			var gravPoint_x:Number = mouseX;
			var gravPoint_y:Number = mouseY;
			var n:Node = _first;
			this._bmd.lock();
			do
			{
				var diff_x:Number = gravPoint_x - n.pos_x;
				var diff_y:Number = gravPoint_y - n.pos_y;
				var acc:Number = 50/(diff_x * diff_x + diff_y * diff_y);
				var acc_x:Number = acc * diff_x;
				var acc_y:Number = acc * diff_y;
				n.v_x += acc_x;
				n.v_y += acc_y;
				n.pos_x += n.v_x;
				n.pos_y += n.v_y;
				//n.acc_x *= 0.98;
				//n.acc_y *= 0.98;
				n.v_x *= 0.96;
				n.v_y *= 0.96;
				
				if (n.pos_x > 465)
					n.pos_x = 0;
				else if (n.pos_x < 0)
					n.pos_x = 465;
				if (n.pos_y > 465)
					n.pos_y = 0;
				else if (n.pos_y < 0)
					n.pos_y = 465;
				
				//_rect.x = n.pos_x;
				//_rect.y = n.pos_y;
				//this._bmd.fillRect(_rect, 0xffffff);
				this._bmd.setPixel(n.pos_x,n.pos_y,0xffffff);
			}
			while (n = n.next);
			this._bmd.colorTransform(this._bmdRect, this._colorTransform);
			this._bmd.unlock();
		}
	}
}

import flash.geom.Point;

class Node
{
//	public var acc_x:Number;
//	public var acc_y:Number;
	public var v_x:Number = 0;
	public var v_y:Number = 0;
	public var pos_x:Number = 0;
	public var pos_y:Number = 0;
	public var next:Node;
}
