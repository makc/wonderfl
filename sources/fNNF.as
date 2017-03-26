package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import frocessing.color.ColorHSV;
	import frocessing.core.F5Graphics;
	
	[SWF(frameRate = '60', backgroundColor='0x000000')]
	public class FlashTest extends Sprite {
		
		protected var _nodes:Vector.<Node> = new Vector.<Node>;
		private var iterationCounter:int = 0;
		private var CENTER:Point;
		private var v:Vector3D;
		public var _view:F5Graphics;
		
		public function FlashTest() 
		{
			this.addEventListener(Event.ADDED_TO_STAGE, initCirclePacking)
			_view = new F5Graphics(graphics);
		}
		
		public function initCirclePacking(e:Event):void
		{
			CENTER = new Point(stage.stageWidth/2, stage.stageHeight/2);
			_view.clear();
			
			var maxSize:Number = 40
			var color:ColorHSV = new ColorHSV(0, 0.8, 1.0);
			
			var currentX:int = 10;
			var max:Number = 70;
			for(var i:int = 0; i < max; i++)
			{
				
				var node:Node = new Node();
				addChild(node);
				node.addEventListener(MouseEvent.MOUSE_DOWN, startDragging);

				
				var size:Number;
				
				if(i< 30) size = Math.random()* maxSize/10 + 5;
				else size = Math.random()* maxSize + 5;
				
				color.h = size/maxSize * 180 + 120;
				
				node.draw(size, color.value);
				node.setPosition(i*8, 200 + Math.random())
				_nodes.push(node);
			}
			
			addEventListener(Event.ENTER_FRAME, packCircles)
		}
		
		private function startDragging(e:MouseEvent):void
		{
			dragCircle = e.target as Node;
			dragCircle._radius = dragCircle._originalRadius * 1.5;
			
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		private function stopDragging(e:MouseEvent):void
		{
			dragCircle._radius = dragCircle._originalRadius;
			
			dragCircle = null;
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		private var dragCircle:Node;
		private function packCircles(e:Event):void
		{
			_nodes = _nodes.sort(sortOnDistanceToCenter);
			v = new Vector3D();
			
			
			// Push them away from each other
			for(var i:int = 0; i < _nodes.length; i++)
			{
				var ci:Node = _nodes[i];
				
				for (var j:int = i + 1; j<_nodes.length; j++)
				{
					var cj:Node = _nodes[j];
					if(i == j) continue;
					//cj.alpha = Math.random()
					var dx:Number = cj.x - ci.x;
					var dy:Number = cj.y - ci.y;
					var r:Number = ci._radius + cj._radius;
					var d:Number = (dx*dx) + (dy*dy);
					if (d < (r * r) - 0.01 )
					{
						v.x = dx;
						v.y = dy;
						v.normalize();
						v.scaleBy((r - Math.sqrt(d)) * 0.5);
						
						if(cj != dragCircle) {
							cj.x += v.x;
							cj.y += v.y;
						}
						
						if(ci != dragCircle) {
							ci.x -= v.x;
							ci.y -= v.y;
						}
					}
				}
			}
			
			
			//return;
			// push toward center
			var damping:Number = 0.01;///Number(iterationCounter);
			//trace(damping)
			for(i = 0; i < _nodes.length; i++) 
			{
				var c:Node = _nodes[i];
				
				if(c == dragCircle) continue;
				
				v.x = c.x - CENTER.x;
				v.y = c.y - CENTER.y;
				v.scaleBy(damping);
				c.x -= v.x;
				c.y -= v.y;
			}
			
			if(dragCircle) {
				dragCircle.x = stage.mouseX
				dragCircle.y = stage.mouseY
			}
		}
		
		private function sortOnRandom(a:Node, b:Node):int
		{
			return Math.random() < 0.5 ? -1 : 1;
		}
		
		private function sortOnDistanceToCenter(a:Node, b:Node):int
		{
			var valueA:int = a.distanceToCenter(CENTER);
			var valueB:int = b.distanceToCenter(CENTER);
			var comparisonValue:int = 0;
			
			if(valueA > valueB) comparisonValue = -1;
			else if(valueA < valueB) comparisonValue = 1;
			
			return comparisonValue;
		}    
		
	}
}

import frocessing.core.F5Graphics2D;
import flash.display.Sprite;
import flash.geom.Point;

//import gs.TweenMax;
//import gs.easing.*;

class Node extends Sprite
{ 
	private var _view:F5Graphics2D;
	public var _originalRadius:Number, _radius:Number, _radiusSquared:Number;
	public var _color:uint;
	public var _relative:Node;
	
	public function Node()
	{
	}
	
	public function draw(nodeSize:Number, color:uint = 0xff0000):void
	{
		size = nodeSize
		
		_color = color;
		
		_view = new F5Graphics2D(this.graphics);
		_view.noStroke();
		_view.beginDraw();
		_view.fillColor = color
		_view.fillAlpha = 0.75;
		_view.circle(0,0, _radius*0.8);
		_view.circle(0,0, _radius * 0.9);
		_view.fillAlpha = 0.3;
		_view.circle(0,0, _radius);
		_view.endDraw();
		
		
	}
	
	public function setPosition(xpos:Number, ypos:Number, animationTime:Number = 0.0, delay:Number = 0.0):void
	{
		x = xpos;
		y = ypos;
	}
	
	
	/**
	 * A few circle helper mathematical functions
	 */
	public function containsPoint(xpos:Number, ypos:Number):Boolean
	{
		var dx:Number = x - ypos;
		var dy:Number = y - ypos;
		var distance:Number = Math.sqrt(dx*dx + dy * dy);
		
		// if it's shorter than either radi, we intersect
		return distance <= _radius;
	}
	
	public function distanceToCenter(centerPoint:Point):Number
	{
		var dx:Number = x - centerPoint.x;
		var dy:Number = y - centerPoint.y;
		var distance:Number = dx*dx + dy*dy;
		
		return distance;
	}
	
	
	public function intersects(otherNode:Node):Boolean
	{
		var dx:Number = otherNode.x - x;
		var dy:Number = otherNode.y - y;
		var distance:Number = dx*dx + dy * dy;
		
		// if it's shorter than either radi, we intersect
		return (distance < _radiusSquared || distance < otherNode._radiusSquared);
	}
	
	public function dealloc():void
	{
		_relative = null;
		_view = null;
	}
	
	public function set size(value:Number):void
	{
		_radius = value;
		_originalRadius = value;
		
		_radiusSquared = _radius * _radius;
	}
}

