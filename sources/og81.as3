package  {
	import gs.*;
	import gs.easing.*;
	import gs.plugins.*;
	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	/**
	 * Tween capture for TweenLite attempt.
	 * Unfortunately its bezier plugin doesn't seem to tolerate duplicate values :(
	 * @author makc
	 */
	[SWF(width=465,height=465)]
	public class Capture extends Sprite {
		public var pb:PushButton;
		public var ta:TextArea;
		public var cr:ComboBox;
		public var sq:Sprite;
		public var drag:Boolean;
		public var axy:Array = [];
		public var bzr:Array = [];
		public var t0:int;
		public var t1:int;
		public function Capture () {
			super ();
			pb = new PushButton (this, 20, 425, "play", onPlay); pb.visible = false;
			ta = new TextArea (this, 0, 0, "Drag square to generate tween code");
			ta.width = 465; ta.height = 100;
			cr = new ComboBox (this, 410, 120, "10", ["1", "2", "3", "4", "5", "10", "15", "20", "30"]);
			cr.width = 40; new Label (this, 340, 120, "Capture rate:");
			sq = new Sprite; sq.x = 50; sq.y = 150; addChild (sq);
			sq.graphics.beginFill (0x7f7f7f); sq.graphics.drawRect ( -10, -10, 20, 20);
			sq.addEventListener (MouseEvent.MOUSE_DOWN, onDrag);
			sq.addEventListener (MouseEvent.MOUSE_UP, onDrag);
			addEventListener (Event.ENTER_FRAME, onLoop);
			stage.addEventListener (MouseEvent.MOUSE_MOVE, onMove);
			TweenPlugin.activate([BezierThroughPlugin]);
		}
		public function onPlay (e:*):void {
			pb.visible = false;
			sq.x = axy [0].x; sq.y = axy [0].y;
			TweenLite.to (sq, 1e-3 * (t1 - t0), {bezierThrough:bzr,
				ease: Linear.easeNone,
				onComplete:function ():void { pb.visible = true; } });
		}
		public function onDrag (e:MouseEvent):void {
			if (drag = (e.type == MouseEvent.MOUSE_DOWN)) {
				stage.frameRate = parseInt (cr.selectedItem ? String (cr.selectedItem) : cr.defaultLabel);
				trace (stage.frameRate);
				sq.startDrag ();
				pb.visible = false;
				t0 = getTimer ();
				axy.length = 0;
			} else {
				stage.frameRate = 30;
				sq.stopDrag ();
				pb.visible = true;
				t1 = getTimer ();
				axy.unshift (axy [0]);
				axy.push (axy [axy.length -1]);
				bzr = makeBesierArray (axy);
				outputCodeSample ();
			}
		}
		public function onLoop (e:*):void {
			if (drag) {
				axy.push ({x: sq.x, y: sq.y});
			}
		}
		public function onMove (e:MouseEvent):void {
			if (drag) {
				e.updateAfterEvent ();
			}
		}
		public function outputCodeSample ():void {
			var s:String =
				"obj.x = " + int (axy [0].x) + "; obj.y = " + int (axy [0].y) + ";\n" +
				"TweenLite.to (obj, " + (1e-3 * (t1 - t0)).toFixed (3) + ", {bezierThrough:[";
			for (var i:int = 0; i < bzr.length; i++) {
				s += " { x: " + int (bzr [i].x) + ", y: " + int (bzr [i].y) + " }";
				s += (i < bzr.length -1) ? ("," + ((i % 3 == 2) ? "\n\t" : "")) : " ], ease: Linear.easeNone});";
			}
			ta.text = s;
		}
		public function makeBesierArray (p:Array):Array {
			var bezier:Array = axy.concat (); bezier.shift (); return bezier;
		}
	}
}