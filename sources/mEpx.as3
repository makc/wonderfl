package 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.geom.*;
	import flash.text.*;
	
	public class Main extends Sprite 
	{
		private var frameBuffer:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false);
		
		private var p0:ControlPoint;
		private var p1:ControlPoint;
		private var p2:ControlPoint;
		
		private var status:TextField;
		
		private var shape:Shape = new Shape();
		private var g:Graphics = shape.graphics;
		private var caption:TextField = new TextField();
		
		public function Main():void 
		{
			addChild(new Bitmap(frameBuffer));
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xAAFFAA, 0.2);
			shape.graphics.drawRect(0, 0, 140, 160);
			shape.graphics.endFill();
			addChild(shape);
			
			status = new TextField();
			status.defaultTextFormat = new TextFormat("_sana", 9, 0x000000);
			status.autoSize = TextFieldAutoSize.LEFT;
			status.selectable = false;
			status.x = 5;
			status.y = 5;
			addChild(status);
			
			p0 = new ControlPoint(this, 60, 340, 0xFF4444);
			p1 = new ControlPoint(this, 210, 140, 0x44FF44);
			p2 = new ControlPoint(this, 300, 280, 0x4444FF);
			
			caption.defaultTextFormat = new TextFormat("_sans", 14, 0x000000);
			caption.width = 0;
			caption.autoSize = TextFieldAutoSize.CENTER;
			caption.filters = [ new GlowFilter(0xFFFFFF, 1, 6, 6, 30) ];
			
			repaint();
		}
		
		public function repaint():void 
		{
			var v1:Point = sub(p1, p0);
			var v2:Point = sub(p2, p0);
			
			var p3:Point = add(p1, v2);
			
			var v1Length:Number = norm(v1);
			var v2Length:Number = norm(v2);
			
			var dotProduct:Number = dot(v1, v2);
			var crossProduct:Number = cross(v1, v2);
			
			var v1cost:Number = dotProduct / v2Length;
			var v1sint:Number = crossProduct / v2Length;
			
			var angle:Number = Math.acos(dotProduct / (v1Length * v2Length));
			var angle2:Number = Math.asin(crossProduct / (v1Length * v2Length));
			
			var vproj:Point = cut(v2, v1cost);
			var vperp:Point = sub(v1, vproj);
			
			function format(value:Number, digits:Number):Number
			{
				var n:Number = Math.pow(10, digits);
				return Math.round(value * n) / n;
			}
			
			status.text = 
				"v1 = [ " + v1.x + ", " + v1.y + " ]\n" +
				"v2 = [ " + v2.x + ", " + v2.y + " ]\n" +
				"|v1| = " + format(v1Length, 1) + "\n" + 
				"|v2| = " + format(v2Length, 1) + "\n" + 
				"v1 / |v1| = ( " + format(v1.x / v1Length, 2) + ", " + format(v1.y / v1Length, 2) + " )\n" +
				"v2 / |v2| = ( " + format(v2.x / v2Length, 2) + ", " + format(v2.y / v2Length, 2) + " )\n" +
				"v1.v2 = |v1||v2|cosθ = " + dotProduct + "\n" +
				"v1xv2 = |v1||v2|sinθ = " + crossProduct + "\n" + 
				"|v1|cosθ = v1.v2 / |v2| = " + format(v1cost, 1) + "\n" + 
				"|v1|sinθ = v1xv2 / |v2| = " + format(v1sint, 1) + "\n" + 
				"θ = cos-1(v1.v2 / |v1||v2|) = " + format(toDegree(angle), 0) + "°\n" +
				"θ = sin-1(v1xv2 / |v1||v2|) = " + format(toDegree(angle2), 0) + "°\n";
			
			// rendering
			frameBuffer.fillRect(frameBuffer.rect, 0xFFFFFF);
			
			g.clear();
			{
				g.beginFill(0x000044, 0.05);
				moveTo(p0);
				lineTo(p1);
				lineTo(p3);
				lineTo(p2);
				lineTo(p0);
				g.endFill();
			}
			frameBuffer.draw(shape);
			
			if (v1Length > 0 && v2Length > 0) {
				g.clear();
				var n1:Point = minus(mul(normalize(vperp), 60));
				
				g.lineStyle(0, 0xAAAAAA);
				drawLine(p1, add(add(p0, vproj), n1));
				drawLine(p0, add(p0, vproj));
				drawLine(p0, add(p0, n1));
				
				const RECT_SIZE:Number = 10;
				if (Math.abs(v1cost) > RECT_SIZE && Math.abs(v1sint) > RECT_SIZE) {
					var t:Point = add(p0, vproj); moveTo(t);
					addto(t, cut(vperp, RECT_SIZE)); lineTo(t);
					addto(t, cut(vproj, -RECT_SIZE)); lineTo(t);
					addto(t, cut(vperp, -RECT_SIZE)); lineTo(t);
				}
				
				var a0:Point = lerp(p0, add(p0, n1), 0.8);
				var a1:Point = add(a0, vproj);
				g.lineStyle(0, 0xDDDDDD);
				drawLine(a0, a1);
				frameBuffer.draw(shape);
				drawCaption("|v1|cosθ", midpoint(a0, a1));
			}
			
			drawArrow(p0, p1, 0x333333);
			drawArrow(p0, p2, 0x333333);
			
			drawCaption("v1xv2", lerp(p0, p3, 0.55));
			
			var sign:Number = (crossProduct > 0) ? 1 : -1;
			const OFFSET:Number = 16;
			drawCaption("v1", add(midpoint(p0, p1), cut(normal(sub(p1, p0)), sign * OFFSET)));
			drawCaption("v2", add(midpoint(p0, p2), cut(normal(sub(p2, p0)), sign * -OFFSET)));
			
			var radius:Number = Math.min(80, Math.min(v1Length, v2Length)) / 4;
				
			var startAngle:Number = getAngle(v1);
			var endAngle:Number = getAngle(v2);
			if (endAngle - startAngle > Math.PI) {
				startAngle += Math.PI * 2;
			}
			if (startAngle - endAngle > Math.PI) {
				endAngle += Math.PI * 2;
			}
			drawArc(p0, radius, 0x333333, startAngle, endAngle);
			drawArc(p0, radius * 0.8, 0x333333, startAngle, endAngle);
			
			drawCaption("|v1|sinθ", midpoint(add(p0, vproj), p1));
		}
		
		private function moveTo(p:Point):void
		{
			g.moveTo(p.x, p.y);
		}
		
		private function lineTo(p:Point):void
		{
			g.lineTo(p.x, p.y);
		}
		
		private function drawLine(start:Point, end:Point):void
		{
			moveTo(start);
			lineTo(end);
		}
		
		private function drawArrow(start:Point, end:Point, color:uint):void
		{
			g.clear();
			{
				g.lineStyle(2, color, 1, false, "normal", null, JointStyle.MITER);
				g.moveTo(start.x, start.y);
				g.lineTo(end.x, end.y);
				
				var len:Number = distance(start, end);
				var arrowLen:Number = Math.min(len, 30) / 3;
				var arrowWidth:Number = arrowLen / 3;
				
				if (arrowLen > 0) {
					var v:Point = sub(end, start);
					var c:Point = sub(end, cut(v, arrowLen));
					var l:Point = add(c, cut(normal(v), arrowWidth));
					var r:Point = add(c, cut(normal(v), -arrowWidth));
				
					g.beginFill(color);
					moveTo(end);
					lineTo(l);
					lineTo(r);
					lineTo(end);
					g.endFill();
				}
			}
			frameBuffer.draw(shape);
		}
		
		private function drawCaption(text:String, pos:Point):void
		{
			caption.text = text;
			var m:Matrix = new Matrix();
			m.translate(pos.x, pos.y - 12);
			frameBuffer.draw(caption, m);
		}
		
		private function drawArc(center:Point, radius:Number, color:uint, start:Number, end:Number):void
		{
			g.clear();
			{
				const SEGMENT:int = 32;
				
				g.lineStyle(2, color);
				
				for (var i:int = 0; i <= SEGMENT; i++) {
					var angle:Number = start + (end - start) * (i / SEGMENT);
					var x:Number = center.x + Math.cos(angle) * radius;
					var y:Number = center.y + Math.sin(angle) * radius;
					if (i == 0) {
						g.moveTo(x, y);
					} else {
						g.lineTo(x, y);
					}
				}
			}
			frameBuffer.draw(shape);
		}
	}
	
}

import flash.geom.Point;
import flash.display.*;
import flash.events.MouseEvent;

class ControlPoint extends Point
{
	private var main:Main;
	
	private var sprite:Sprite = new Sprite();
	private var g:Graphics = sprite.graphics;
	
	function ControlPoint(main:Main, x:Number, y:Number, color:uint)
	{
		this.main = main;
		this.x = x;
		this.y = y;
		
		g.beginFill(color, 0.5);
		g.drawCircle(0, 0, 16);
		g.endFill();
		
		sprite.x = x;
		sprite.y = y;
		sprite.buttonMode = true;
		
		sprite.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		sprite.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		
		main.addChild(sprite);
	}
	
	private function mouseDownHandler(e:MouseEvent):void 
	{
		sprite.startDrag();
		main.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}
	
	private function mouseUpHandler(e:MouseEvent):void 
	{
		sprite.stopDrag();
		main.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}
	
	private function mouseMoveHandler(e:MouseEvent):void 
	{
		x = sprite.x;
		y = sprite.y;
		
		main.repaint();
		e.updateAfterEvent();
	}
	
}


function toDegree(radian:Number):Number
{
	return radian * 180 / Math.PI;
}

function toRadian(degree:Number):Number
{
	return degree * Math.PI / 180;
}

function minus(v:Point):Point
{
	return new Point( -v.x, -v.y);
}

function normal(v:Point):Point
{
	return new Point(v.y, -v.x);
}

function norm(v:Point):Number
{
	return Math.sqrt(v.x * v.x + v.y * v.y);
}

function normalize(v:Point):Point
{
	return div(v, norm(v));
}

function add(n:Point, m:Point):Point
{
	return new Point(n.x + m.x, n.y + m.y);
}

function addto(n:Point, m:Point):void
{
	n.x += m.x;
	n.y += m.y;
}

function sub(n:Point, m:Point):Point
{
	return new Point(n.x - m.x, n.y - m.y);
}

function mul(v:Point, f:Number):Point
{
	return new Point(v.x * f, v.y * f);
}

function div(v:Point, f:Number):Point
{
	return new Point(v.x / f, v.y / f);
}

function dot(a:Point, b:Point):Number
{
	return a.x * b.x + a.y * b.y;
}

function cross(a:Point, b:Point):Number
{
	return a.x * b.y - a.y * b.x;
}

function distanceSquared(a:Point, b:Point):Number
{
	var dx:Number = b.x - a.x;
	var dy:Number = b.y - a.y;
	return dx * dx + dy * dy;
}

function distance(a:Point, b:Point):Number
{
	return Math.sqrt(distanceSquared(a, b));
}

function lerp(n:Point, m:Point, p:Number):Point
{
	return add(mul(n, 1 - p), mul(m, p));
}

function midpoint(n:Point, m:Point):Point
{
	return new Point((n.x + m.x) * 0.5, (n.y + m.y) * 0.5);
}

function cut(v:Point, len:Number):Point
{
	// create a vector of the specified length
	return mul(normalize(v), len);
}

function getAngle(v:Point):Number
{
	return Math.atan2(v.y, v.x);
}


