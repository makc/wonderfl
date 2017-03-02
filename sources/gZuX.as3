package  {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	[SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#000000")]
	/**
	 * サインカーブによる RGB カラーの循環変化
	 * 座標とスケールもあるよ
	 * 67WS の GEEKs in OSAKA イベントレポートの城戸さんのセッションムービーを見てショックを受けました
	 * @author Aquioux
	 */
	public class Main extends Sprite{
		
		private const NUM_OF_DOT:uint = 120;
		private const RADIUS:uint = 70;
		private const RADIAN:Number = Math.PI * 2 / NUM_OF_DOT;

		private var CX:Number = stage.stageWidth / 2;
		private var CY:Number = stage.stageHeight / 2;
		
		private var dots:Array = [];
		private var radian1:Number = 0;
		private var radian2:Number = 0;
		private const ADD:Number = Math.PI / 180 * 3;	// degree 1度分の radian 値 * 3 （NUM_OF_DOT が 120 だから 3倍）
		
		private var dotCanvas:Sprite;
		private var drawCanvas:BitmapData;
		private var viewCanvas:BitmapData;

		private const FADE:ColorTransform = new ColorTransform(1, 1, 1, 0.97, 0, 0, 0, 0);
		private const BLUR:BlurFilter = new BlurFilter(2, 2, BitmapFilterQuality.LOW);
		private const RECT:Rectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		private const ZERO_POINT:Point = new Point();
		
		private var flg:Boolean;
		

		public function Main() {
			setup();
			addEventListener(Event.ENTER_FRAME, loop);
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function setup():void {
			dotCanvas = new Sprite();
			drawCanvas = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000);
			viewCanvas = drawCanvas.clone();
			addChild(new Bitmap(viewCanvas));
			
			for (var i:int = 0; i < NUM_OF_DOT; i++) {
				var dot:Dot = new Dot();
				var p:Point = Point.polar(RADIUS, RADIAN * i);
				dot.x = p.x + CX;
				dot.y = p.y + CY;
				dot.radian = RADIAN * i + Math.PI / 2;
				dotCanvas.addChild(dot);
				dot.update();
				dots[i] = dot;
			}
		}
		
		private function loop(e:Event):void {
			radian2 = 0;
			for (var i:int = 0; i < NUM_OF_DOT; i++) {
				var dot:Dot = dots[i];
				var offset:Number = (Math.sin(radian1 + radian2) + 2);
				var p:Point = Point.polar(RADIUS * offset, RADIAN * i);
				dot.x = p.x + CX;
				dot.y = p.y + CY;
				dot.scaleX = dot.scaleY = offset * 1.5;
				dot.update();
				radian2 += ADD * 6;
			}
			radian1 += ADD;
			
			drawCanvas.draw(dotCanvas);
			viewCanvas.draw(drawCanvas);
			if (flg) {
				drawCanvas.applyFilter(drawCanvas, RECT, ZERO_POINT, BLUR);
			} else {
				drawCanvas.colorTransform(RECT, FADE);
			}
		}
		
		private function clickHandler(e:MouseEvent):void {
			flg = !flg;
		}
	}
}


	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	/**
	 * Dot
	 * @author Aquioux(Yoshida, Akio)
	 */
	class Dot extends Sprite {
		
		public function set radian(value:Number):void { _radian = value; }
		private var _radian:Number = Math.PI / 2;
		
		private const ADD:Number = Math.PI / 180;	// degree 1度分の radian 値
		private const OFFSET1:Number = Math.PI / 2;	// 90度
		private const OFFSET2:Number = Math.PI;		// 180度
		
		public function Dot():void {
			var g:Graphics = graphics;
			g.beginFill(0xFFFFFF);
			g.drawCircle(0, 0, 1);
			g.endFill();
		}
		
		public function update():void {
			_radian += ADD;
			var valR:Number = (Math.sin(_radian) + 1) / 2;
			var valG:Number = (Math.sin(_radian + OFFSET1) + 1) / 2;
			var valB:Number = (Math.sin(_radian + OFFSET2) + 1) / 2;
			var ct:ColorTransform = new ColorTransform(valR, valG, valB);
			transform.colorTransform = ct;
		}
	}
