package {
	import com.bit101.components.HSlider;
	import com.bit101.components.TextArea;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setInterval;
	
	/** Genetic programming experiment. */
	[SWF (height=465, width=465)]
	public class GeneticProgramming extends Sprite {
		
		public var anchors:Vector.<Anchor> = new Vector.<Anchor>;
		public var pool:Vector.<NodeRoot> = new Vector.<NodeRoot>;
		
		public function GeneticProgramming () {
			pool.push (new NodeRoot);
			addEventListener (Event.ENTER_FRAME, loop);
			
			text = new TextArea (this, 50, 400, "");
			text.width = 400; text.height = 50;
			setInterval (updateText, 2345);
			
			rate = new HSlider (this, 50, 380, changeRate);
			rate.width = 400; rate.value = Node.MUTATION_RATE;
			rate.minimum = 0.05; rate.maximum = 0.5; rate.tick = 0.01;
			
			for (var i:int = 0; i <= 10; i++) {
				var anchor:Anchor = new Anchor (46.5 * i);
				anchors.push (anchor); addChild (anchor);
			}
		}
		
		public function updateText ():void {
			text.text = pool [0].toAS3 ();
		}
		
		public function changeRate (e:Event):void {
			Node.MUTATION_RATE = HSlider (e.target).value;
		}
		
		public function targetFunction (t:Number):Number {
			var i:int = t * (anchors.length - 1);
			var k:Number = (t * 465.0 - anchors [i].x) / (anchors [i + 1].x - anchors [i].x);
			return (k * anchors [i + 1].y + (1 - k) * anchors [i].y) / 465.0;
		}
		
		public function loop (e:Event):void {
			// step 1: programs reproduction
			for (var i:int = 0, n:int = pool.length; i < n; i++) {
				var offspring:NodeRoot = pool [i].clone () as NodeRoot;
				offspring.mutate ();
				pool.push (offspring);
			}
			
			// step 2: evaluation
			for (i = 0, n = pool.length; i < n; i++) {
				var program:NodeRoot = pool [i];
				program.metric = 0;
				
				// how closely do we follow target function?
				for (var j:int = 0, m:int = 20; j < m; j++) {
					var t:Number = j / m;
					var d:Number = program.evaluate (t) - targetFunction (t);
					program.metric += d * d;
				}

				// short programs are boring and inaccurate, long are expensive
				var L:int = program.depth ();
				program.metric *= Math.exp (L * 0.008) + 4 * Math.exp ( -0.2 * L );
			}
			
			// step 3: selection
			pool.sort (comparePrograms);
			while (pool.length > 50) pool.pop ().dispose ();
			
			// draw best function found so far
			graphics.clear ();
			graphics.lineStyle (4, 0x9f9f9f);
			for (j = 0; j <= 30; j++) {
				graphics [(j == 0) ? "moveTo" : "lineTo"] (465 * j / 30.0, 465 * pool [0].evaluate (j / 30.0));
			}

			// draw worse function at the moment
			graphics.lineStyle (0, 0x9f9f9f);
			for (j = 0; j <= 30; j++) {
				graphics [(j == 0) ? "moveTo" : "lineTo"] (465 * j / 30.0, 465 * pool [pool.length -1].evaluate (j / 30.0));
			}
		}
		
		public function comparePrograms (a:NodeRoot, b:NodeRoot):int {
			if (isFinite (a.metric) && isFinite (b.metric)) {
				if (a.metric > b.metric) {
					return 1;
				}
				if (a.metric < b.metric) {
					return -1;
				}
				return 0;
			}
			
			if (isFinite (b.metric) /* a > b */) {
				return 1;
			}
			if (isFinite (a.metric) /* a < b */) {
				return -1;
			}
			// both NaN
			return 0;
		}
		
		public var text:TextArea;
		public var rate:HSlider;
	}
}



import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
class Anchor extends Sprite {
	public var bounds:Rectangle;
	public function Anchor (x0:Number) {
		bounds = new Rectangle (x0, 0, 0, 465);
		x = x0;
		
		// just some initial function
		var t:Number = x0 / 465;
		y = 465 * (0.5 - (t - 0.5) * (t - 0.5));
		
		graphics.beginFill (123456);
		graphics.drawRect ( -8, -8, 16, 16);
		useHandCursor = buttonMode = true;
		addEventListener (Event.ADDED_TO_STAGE, onStage);
	}
	public function onStage (e:Event):void {
		addEventListener (MouseEvent.MOUSE_DOWN, startDragMe);
		stage.addEventListener (MouseEvent.MOUSE_UP, stopDragMe);
	}
	public function startDragMe (e:MouseEvent):void { startDrag (false, bounds); }
	public function stopDragMe (e:MouseEvent):void { stopDrag (); }
}






/** Program node base class. */
class Node {
	
	/** Defines how much the offspring is different; 0..1. */
	static public var MUTATION_RATE:Number = 0.2;
	
	protected var children:Vector.<Node> = new Vector.<Node>;
	
	final public function dispose ():void {
		for each (var child:Node in children) child.dispose ();
		children.length = 0; children = null;
	}
	
	/** Override. */
	public function evaluate (arg:Number):Number {
		return NaN;
	}
	
	/** Override. */
	public function toAS3 ():String {
		return null;
	}
	
	/** Override for terminal nodes. */
	protected function mutateSelf ():void {
		var n:int = children.length;
		n = int (n * Math.random ()) % n; // n = 0..n-1
		children.splice (n, 1, NodeFactory.randomNode ()) [0].dispose ();
	}
	
	final public function mutate ():void {
		for each (var child:Node in children) child.mutate ();
		if (Math.random () < MUTATION_RATE) mutateSelf ();
	}
	
	final public function cloneChildrenOf (template:Node):void {
		// get rid of whatever we have (default children, for example)
		while (children.length > 0) children.pop ().dispose ();
		
		for (var i:int = 0, n:int = template.children.length; i < n; i++) {
			children.push (template.children [i].clone ());
		}
	}

	/** Override. */
	public function clone ():Node {
		return null;
	}
	
	final public function depth ():int {
		var d:int = 0;
		for each (var child:Node in children) d = Math.max (d, child.depth () + 1);
		return d;
	}
}

class NodeRoot extends Node {
	public var metric:Number = 0;

	public function NodeRoot () {
		children.push (NodeFactory.randomNode ());
	}
	override public function evaluate (arg:Number):Number {
		return children [0].evaluate (arg);
	}
	override public function toAS3():String {
		return "function f(t:Number):Number {\n\treturn " + children [0].toAS3 () + ";\n}";
	}
	override public function clone():Node {
		var node:Node = new NodeRoot; node.cloneChildrenOf (this); return node;
	}
}

class NodeArgument extends Node {
	override public function evaluate(arg:Number):Number { return arg; }
	override public function toAS3():String { return "t"; }
	override protected function mutateSelf():void { /* do nothing */ }
	override public function clone():Node { return new NodeArgument; }
}

class NodeConstant extends Node {
	private var value:Number = Math.random ();
	override public function evaluate(arg:Number):Number { return value; }
	override public function toAS3():String { return value.toPrecision (5); }
	override protected function mutateSelf():void { value = Math.random (); }
	override public function clone():Node {
		var c:NodeConstant = new NodeConstant; c.value = value; return c;
	}
}

class NodeAddition extends Node {
	public function NodeAddition () {
		children.push (NodeFactory.randomTerminalNode (), NodeFactory.randomTerminalNode ());
	}
	override public function evaluate(arg:Number):Number {
		return children [0].evaluate (arg) + children [1].evaluate (arg);
	}
	override public function toAS3():String {
		return "(" + children [0].toAS3 () + " + " + children [1].toAS3 () + ")";
	}
	override public function clone():Node {
		var node:Node = new NodeAddition; node.cloneChildrenOf (this); return node;
	}
}

class NodeSubtraction extends Node {
	public function NodeSubtraction () {
		children.push (NodeFactory.randomTerminalNode (), NodeFactory.randomTerminalNode ());
	}
	override public function evaluate(arg:Number):Number {
		return children [0].evaluate (arg) - children [1].evaluate (arg);
	}
	override public function toAS3():String {
		return "(" + children [0].toAS3 () + " - " + children [1].toAS3 () + ")";
	}
	override public function clone():Node {
		var node:Node = new NodeSubtraction; node.cloneChildrenOf (this); return node;
	}
}

class NodeMultiplication extends Node {
	public function NodeMultiplication () {
		children.push (NodeFactory.randomTerminalNode (), NodeFactory.randomTerminalNode ());
	}
	override public function evaluate(arg:Number):Number {
		return children [0].evaluate (arg) * children [1].evaluate (arg);
	}
	override public function toAS3():String {
		return "(" + children [0].toAS3 () + " * " + children [1].toAS3 () + ")";
	}
	override public function clone():Node {
		var node:Node = new NodeMultiplication; node.cloneChildrenOf (this); return node;
	}
}

class NodeDivision extends Node {
	public function NodeDivision () {
		children.push (NodeFactory.randomTerminalNode (), NodeFactory.randomTerminalNode ());
	}
	override public function evaluate(arg:Number):Number {
		return children [0].evaluate (arg) / children [1].evaluate (arg);
	}
	override public function toAS3():String {
		return "(" + children [0].toAS3 () + " / " + children [1].toAS3 () + ")";
	}
	override public function clone():Node {
		var node:Node = new NodeDivision; node.cloneChildrenOf (this); return node;
	}
}

class NodeSine extends Node {
	public function NodeSine () {
		children.push (NodeFactory.randomTerminalNode ());
	}
	override public function evaluate(arg:Number):Number {
		return Math.sin (children [0].evaluate (arg));
	}
	override public function toAS3():String {
		return "Math.sin (" + children [0].toAS3 () + ")";
	}
	override public function clone():Node {
		var node:Node = new NodeSine; node.cloneChildrenOf (this); return node;
	}
}

class NodeSqrt extends Node {
	public function NodeSqrt () {
		children.push (NodeFactory.randomTerminalNode ());
	}
	override public function evaluate(arg:Number):Number {
		return Math.sqrt (children [0].evaluate (arg));
	}
	override public function toAS3():String {
		return "Math.sqrt (" + children [0].toAS3 () + ")";
	}
	override public function clone():Node {
		var node:Node = new NodeSqrt; node.cloneChildrenOf (this); return node;
	}
}

class NodeExp extends Node {
	public function NodeExp () {
		children.push (NodeFactory.randomTerminalNode ());
	}
	override public function evaluate(arg:Number):Number {
		return Math.exp (children [0].evaluate (arg));
	}
	override public function toAS3():String {
		return "Math.exp (" + children [0].toAS3 () + ")";
	}
	override public function clone():Node {
		var node:Node = new NodeExp; node.cloneChildrenOf (this); return node;
	}
}

class NodeFactory {
	static public function randomTerminalNode ():Node {
		return (Math.random () < 0.5) ? new NodeArgument : new NodeConstant;
	}
	static public function randomNode ():Node {
		var n:int = 3;//7;
		switch (int (n * Math.random ()) % n) {
			case 0: return new NodeAddition; break;
			case 1: return new NodeSubtraction; break;
			case 2: return new NodeMultiplication; break;
			case 3: return new NodeDivision; break;
			case 4: return new NodeSine; break;
			case 5: return new NodeSqrt; break;
			case 6: return new NodeExp; break;
		}
		// never
		return null;
	}
}