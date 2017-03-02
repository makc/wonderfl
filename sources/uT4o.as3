package  {
	import caurina.transitions.*;
	import caurina.transitions.properties.CurveModifiers;
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
	 * Tween capture: proof-of-concept.
	 * Just drag the square the way you want :)
	 * @see http://lists.caurinauebi.com/pipermail/tweener-caurinauebi.com/2010-July/001474.html
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
			CurveModifiers.init();
		}
		public function onPlay (e:*):void {
			pb.visible = false;
			sq.x = axy [0].x; sq.y = axy [0].y;
			Tweener.addTween (sq, { x: axy [axy.length -1].x, y:axy [axy.length -1].y,
				_bezier:bzr, time:1e-3 * (t1 - t0), transition:"linear",
				onComplete:function ():void { pb.visible = true; } } );
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
				"Tweener.addTween (obj, { x: " + int (axy [axy.length -1].x) +
				", y: " + int (axy [axy.length -1].y) + ",\n\t_bezier:[";
			for (var i:int = 0; i < bzr.length; i++) {
				s += " { x: " + int (bzr [i].x) + ", y: " + int (bzr [i].y) + " }";
				s += (i < bzr.length -1) ? ("," + ((i % 3 == 2) ? "\n\t" : "")) : " ],\n\t";
			}
			s += "time: " + (1e-3 * (t1 - t0)).toFixed (3) + ", transition: \"linear\" });";
			ta.text = s;
		}
		/**
		 * Converts path checkpoints to bezier anchors.
		 * @see http://makc.coverthesky.com/FlashFX/ffx.php?id=15
		 */
		public function makeBesierArray (p:Array):Array {
			var bezier:Array = [];
			// convert all points between p[0] and p[last]
			for (var i:int = 1; i < p.length -2; i++)
			{
				var b1:Object = {}, b2:Object = {};
				// use p[0] properties to fill bezier array
				for (var prop:String in p[0])
				{
					b1[prop] = -p[i -1][prop]/6 +p[i][prop] +p[i +1][prop]/6;
					b2[prop] = +p[i][prop]/6 +p[i +1][prop] -p[i +2][prop]/6;
				}
				bezier.push (b1); bezier.push (b2);
			}
			return bezier;
		}
	}
}