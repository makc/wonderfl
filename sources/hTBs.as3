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

	[SWF(frameRate='60', width='465', height='465', backgroundColor='0x0')]

	public class ParticleTest1 extends Sprite
	{
		private var _bmp:Bitmap;
		private var _bmd:BitmapData;
		private var _bmdRect:Rectangle;
		private var _colorTransform:ColorTransform = new ColorTransform(0, 0.9, 0, 0.9);

		private var _nodeArray:Array = [];
		private var _maxNum:int = 10000;

		public function ParticleTest1()
		{
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;

			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			_bmd = new BitmapData(465, 465, false, 0x000000);
			_bmp = new Bitmap(_bmd);
			addChild(_bmp);
			this._bmdRect = new Rectangle(0, 0, 465, 465);

			for (var i:int = 0; i < this._maxNum; i++)
			{
				var n:Node = new Node();
				n.pos.x = Math.random() * 465;
				n.pos.y = Math.random() * 465;
				this._nodeArray.push(n);
			}

			addEventListener(Event.ENTER_FRAME, onEnter);
		}

		private function onEnter(evt:Event):void
		{
			var gravPoint:Point = new Point(mouseX, mouseY);
			for (var i:int = 0; i < this._maxNum; i++)
			{
				var n:Node = this._nodeArray[i] as Node;
				var diff:Point = new Point(gravPoint.x - n.pos.x, gravPoint.y - n.pos.y);
				var rad:Number = Math.atan2(diff.y, diff.x);
				var grav:Number = 10 / Math.sqrt(diff.x * diff.x + diff.y * diff.y);
				n.acc.x = (Math.cos(rad) * grav);
				n.acc.y = (Math.sin(rad) * grav);
				n.v.x += n.acc.x;
				n.v.y += n.acc.y;
				n.pos.x += n.v.x;
				n.pos.y += n.v.y;

				n.acc.x *= 0.98;
				n.acc.y *= 0.98;
				n.v.x *= 0.96;
				n.v.y *= 0.96;

				if (n.pos.x > 465)
					n.pos.x = 0;
				else if (n.pos.x < 0)
					n.pos.x = 465;
				if (n.pos.y > 465)
					n.pos.y = 0;
				else if (n.pos.y < 0)
					n.pos.y = 465;

				this._bmd.fillRect(new Rectangle(n.pos.x, n.pos.y, 1, 1), 0xffffff);
			}

			this._bmd.colorTransform(this._bmdRect, this._colorTransform);
		}
	}
}

import flash.geom.Point;

class Node
{
	public var acc:Point;
	public var v:Point;
	public var pos:Point;

	public function Node()
	{
		this.acc = new Point();
		this.v = new Point();
		this.pos = new Point();
	}
}
