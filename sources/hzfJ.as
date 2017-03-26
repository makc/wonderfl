package  {
	import gs.*;
	import gs.easing.*;
	import gs.plugins.TweenPlugin;
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
	 * Tween capture for TweenLite, fixed.
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

/*
 * Fixed version of BezierThroughPlugin.
 * Jack Doyle doesn't seem to be responsive, so let's just fix his stuff for him.
 */

import gs.*;
import gs.plugins.TweenPlugin;
import gs.utils.tween.*;

class BezierThroughPlugin extends TweenPlugin {
	public static const VERSION:Number = 1.01;
	public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
	
	protected static const _RAD2DEG:Number = 180 / Math.PI; //precalculate for speed
	
	protected var _target:Object;
	protected var _orientData:Array;
	protected var _orient:Boolean;
	protected var _future:Object = {}; //used for orientToBezier projections
	protected var _beziers:Object;
	
	public function BezierThroughPlugin() {
		super();
		this.propName = "bezierThrough"; //name of the special property that the plugin should intercept/manage
		this.overwriteProps = []; //will be populated in init()
	}
	
	override public function onInitTween($target:Object, $value:*, $tween:TweenLite):Boolean {
		if (!($value is Array)) {
			return false;
		}
		init($tween, $value as Array);
		return true;
	}
	
	protected function init($tween:TweenLite, $beziers:Array):void {
		_target = $tween.target;
		if ($tween.exposedVars.orientToBezier == true) {
			_orientData = [["x", "y", "rotation", 0]];
			_orient = true;
		} else if ($tween.exposedVars.orientToBezier is Array) {
			_orientData = $tween.exposedVars.orientToBezier;
			_orient = true;
		}
		var props:Object = {}, i:int, p:String;
		for (i = 0; i < $beziers.length; i++) {
			for (p in $beziers[i]) {
				if (props[p] == undefined) {
					props[p] = [$tween.target[p]];
				}
				if (typeof($beziers[i][p]) == "number") {
					props[p].push($beziers[i][p]);
				} else {
					props[p].push($tween.target[p] + Number($beziers[i][p])); //relative value
				}
			}
		}
		for (p in props) {
			this.overwriteProps[this.overwriteProps.length] = p;
			if ($tween.exposedVars[p] != undefined) {
				if (typeof($tween.exposedVars[p]) == "number") {
					props[p].push($tween.exposedVars[p]);
				} else {
					props[p].push($tween.target[p] + Number($tween.exposedVars[p])); //relative value
				}
				delete $tween.exposedVars[p]; //prevent TweenLite from creating normal tweens of the bezier properties.
				for (i = $tween.tweens.length - 1; i > -1; i--) {
					if ($tween.tweens[i].name == p) {
						$tween.tweens.splice(i, 1); //delete any normal tweens of the bezier properties. 
					}
				}
			}
		}
		_beziers = parseBeziers(props);
	}

	/**
	 * Converts path checkpoints to bezier anchors.
	 * @see http://makc.coverthesky.com/FlashFX/ffx.php?id=15
	 */
	public static function makeBesierArray (p0:Array):Array {
		// make a copy you can mess with 1st
		var p:Array = p0.concat ();
		// extrapolate in some way
		if (p.length < 2) {
			p.unshift (p [0]);
			p.push (p [p.length -1]);
		} else {
			p.unshift (p [0] - 0.5 * (p [1] - p [0]));
			p.push (p [p.length -1] - 0.5 * (p [p.length -2] - p [p.length -1]));
		}

		var bezier:Array = [];
		// convert all points between p[0] and p[last]
		for (var i:int = 1; i < p.length -2; i++)
		{
			var b1:Number = -p[i -1]/6 +p[i] +p[i +1]/6;
			var b2:Number = +p[i]/6 +p[i +1] -p[i +2]/6;
			bezier.push (b1); bezier.push (b2);
		}
		return bezier;
	}
	public static function parseBeziers($props:Object):Object { //$props object should contain a property for each one you'd like bezier paths for. Each property should contain a single Array with the numeric point values (i.e. props.x = [12,50,80] and props.y = [50,97,158]). It'll return a new object with an array of values for each property. The first element in the array  is the start value, the second is the control point, and the 3rd is the end value. (i.e. returnObject.x = [[12, 32, 50}, [50, 65, 80]])
		var i:int, a:Array, b:Object, p:String;
		var all:Object = {};
		for (p in $props) {
			// And here's the fix
			// I'm not quite sure it handles a [0] correctly, but... whatever
			a = makeBesierArray ($props[p]);
			all[p] = b = [];
			if (a.length > 3) {
				b[b.length] = [a[0], a[1], (a[1] + a[2]) / 2];
				for (i = 2; i < a.length - 2; i++) {
					b[b.length] = [b[i - 2][2], a[i], (a[i] + a[i + 1]) / 2];
				}
				b[b.length] = [b[b.length - 1][2], a[a.length - 2], a[a.length - 1]];
			} else if (a.length == 3) {
				b[b.length] = [a[0], a[1], a[2]];
			} else if (a.length == 2) {
				b[b.length] = [a[0], (a[0] + a[1]) / 2, a[1]];
			}
		}
		return all;
	}
	
	override public function killProps($lookup:Object):void {
		for (var p:String in _beziers) {
			if (p in $lookup) {
				delete _beziers[p];
			}
		}
		super.killProps($lookup);
	}	
	
	override public function set changeFactor($n:Number):void {
		var i:int, p:String, b:Object, t:Number, segments:uint, val:Number, neg:int;
		if ($n == 1) { //to make sure the end values are EXACTLY what they need to be.
			for (p in _beziers) {
				i = _beziers[p].length - 1;
				_target[p] = _beziers[p][i][2];
			}
		} else {
			for (p in _beziers) {
				segments = _beziers[p].length;
				if ($n < 0) {
					i = 0;
				} else if ($n >= 1) {
					i = segments - 1;
				} else {
					i = int(segments * $n);
				}
				t = ($n - (i * (1 / segments))) * segments;
				b = _beziers[p][i];
				if (this.round) {
					val = b[0] + t * (2 * (1 - t) * (b[1] - b[0]) + t * (b[2] - b[0]));
					neg = (val < 0) ? -1 : 1;
					_target[p] = ((val % 1) * neg > 0.5) ? int(val) + neg : int(val); //twice as fast as Math.round()
				} else {
					_target[p] = b[0] + t * (2 * (1 - t) * (b[1] - b[0]) + t * (b[2] - b[0]));
				}
			}
		}
		
		if (_orient) {
			var oldTarget:Object = _target, oldRound:Boolean = this.round;
			_target = _future;
			this.round = false;
			_orient = false;
			this.changeFactor = $n + 0.01;
			_target = oldTarget;
			this.round = oldRound;
			_orient = true;
			var dx:Number, dy:Number, cotb:Array, toAdd:Number;
			for (i = 0; i < _orientData.length; i++) {
				cotb = _orientData[i]; //current orientToBezier Array
				toAdd = cotb[3] || 0;
				dx = _future[cotb[0]] - _target[cotb[0]];
				dy = _future[cotb[1]] - _target[cotb[1]];
				_target[cotb[2]] = Math.atan2(dy, dx) * _RAD2DEG + toAdd;
			}
		}
		
	}
	
}
