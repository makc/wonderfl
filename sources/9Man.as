package
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	[SWF(width = "465", height = "465", backgroundColor = "0x000000", frameRate = "24")]
	/**
	 * 彗星を衛星軌道に乗せましょう。
	 * マウスをドラッグです。
	 * @author naoto koshikawa
	 */
	public class SatelliteGame extends Sprite
	{
		/** 地球の大きさ */
		private static const EARTH_RADIUS:Number = 24;
		/** 彗星の大きさ　*/
		private static const STAR_SIZE:Number = 1.5;
		/** マウス動作の加速度調整値 */
		private static const MOUSE_FORCE:Number = 0.7;
		/** 引力補正 */
		private static const GRAVITY_FORCE:Number = 0.0001;
		/** 距離補正　*/
		private static const DISTANCE_FORCE:Number = 2.0;
		
		private var i:int;
		private var _container:Sprite;
		private var _earth:Earth;
		private var _moon:Moon;
		private var _stars:Sprite;
		
		private var _old:Point;
		//private var _prevTime:Number;
		
		public function SatelliteGame() 
		{
			//_prevTime = getTimer();

			// create container
			_container = new Sprite();
			_container.x = stage.stageWidth / 2;
			_container.y = stage.stageHeight / 2;
			addChild(_container);
			
			// create earth
			_earth = new Earth({size:EARTH_RADIUS});
			_container.addChild(_earth);
			
			// create moon
			_moon = new Moon({size:EARTH_RADIUS/4,radius:EARTH_RADIUS*6});
			_container.addChild(_moon);
			
			// create shooting star
			_stars = new Sprite();
			_stars.x = stage.stageWidth / 2;
			_stars.y = stage.stageHeight / 2;
			addChild(_stars);
			
			// draw dot shape like a filter
			var bitmapData:BitmapData = new BitmapData(3, 3, true, 0x00FFFFFF);
			bitmapData.setPixel32(0, 0, 0x22FFFFFF);
			var dot:Shape = new Shape();
			dot.graphics.beginBitmapFill(bitmapData);
			dot.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			addChild(dot);
			
			// add event listener
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
			addEventListener(Event.ENTER_FRAME, enterFrameListener);
		}
		
		private function mouseDownListener(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
			_old = new Point(_stars.mouseX, _stars.mouseY);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
			_stars.graphics.clear();
		}
		
		private function mouseUpListener(event:MouseEvent):void
		{
			if (!_old) return;
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
			// check mouse angle
			var dx:Number = _stars.mouseX - _old.x;
			var dy:Number = _stars.mouseY - _old.y;
			var dist:Number = Math.sqrt(dx * dx + dy * dy);
			
			_stars.addChild(new Star( { x:_stars.mouseX, y:_stars.mouseY, vx:dx * MOUSE_FORCE, vy:dy * MOUSE_FORCE, size:STAR_SIZE, visible:true, mass:0.01 } ));
			
			_stars.graphics.lineStyle(1, 0xFFFFFF, 0.1);
			_stars.graphics.moveTo(_old.x, _old.y);
			_stars.graphics.lineTo(_stars.mouseX, _stars.mouseY);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
		}
		
		private function enterFrameListener(event:Event):void
		{
			//var t:Number = (getTimer() - _prevTime) / 1000;
			var star:Star;
			var isOut:Boolean;
			for (i = 0; i < _stars.numChildren; i++)
			{
				isOut = false;
				star = _stars.getChildAt(i) as Star;
				// gravity
				var dx:Number = _earth.x - star.x;
				var dy:Number = _earth.y - star.y;
				var dist:Number = Math.sqrt(dx * dx + dy * dy);
				var force:Number;
				force = _earth.mass * star.mass / dist * dist * GRAVITY_FORCE * DISTANCE_FORCE * DISTANCE_FORCE;
				var ax:Number = force * dx / dist;
				var ay:Number = force * dy / dist;
				star.vx += ax / star.mass;
				star.vy += ay / star.mass;		
				
				// update position
				star.x += star.vx;
				star.y += star.vy;

				/*
				star.vx += star.ax * t;
				star.vy += star.ay * t;
				star.ax = 0;
				star.ay = 0;
				*/
				var moonDist:Number = Math.sqrt((_moon.x - star.x) * (_moon.x - star.x) + (_moon.y - star.y) * (_moon.y - star.y));
				
				if (dist <= star.size + _earth.size + 4) 
				{
					var spark:Spark = new Spark( { angle:Math.atan2(dy, dx) + Math.PI, offset:_earth.size} );
					_container.addChild(spark);
					isOut = true;
				}
				else if (moonDist <= star.size + _moon.size) 
				{
					isOut = true;
				}
				else {
					// boundary horizontally
					if (stage.stageWidth/2 < star.x  - star.width / 2) isOut = true;
					else if (star.x  + star.width / 2 < -stage.stageWidth/2) isOut = true;
					
					// boundary vertically
					if (stage.stageHeight/2 < star.y  -star.height / 2) isOut = true;
					else if (star.y  + star.height / 2 < -stage.stageHeight/2) isOut = true;
				}
				if (isOut) star.visible = false;
			}
			
			for (i = _stars.numChildren-1; i >= 0 ; i--)
			{
				star = _stars.getChildAt(i) as Star;
				if (!star.visible) _stars.removeChild(star);
				
			}
			//_prevTime = getTimer();
		}
	}	
}

import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.GlowFilter;
class Star extends Shape
{
	public var color:uint;
	public var size:Number = 1;
	public var mass:Number = 1;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var vz:Number = 0;
	public var ax:Number = 0;
	public var ay:Number = 0;
	public var az:Number = 0;
	
	public function Star(initObject:Object = null)
	{
		color = 0xFFFFCC;
		init(initObject);
		graphics.beginFill(color);
		graphics.drawCircle(0, 0, size);
	}
	protected function init(initObject:Object):void
	{
		if (!initObject) return;
		for (var property:String in initObject)
		{
			if (this.hasOwnProperty(property)) this[property] = initObject[property];
		}
	}
}

import flash.display.GradientType;
import flash.display.Shape;
import flash.filters.BlurFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class Earth extends Star
{
	public function Earth(initObject:Object = null)
	{
		size = 25;
		mass = 1000;
		init(initObject);
		var bitmapData:BitmapData = new BitmapData(size*2, size*2, true, 0xFFFFFFFF);
		bitmapData.perlinNoise(size/3, size/4, 5, Math.random()*256, true, true, 0, true);
		bitmapData.colorTransform(new Rectangle(0, 0, size * 2, size * 2), new ColorTransform(1, 1, 1, 1, 0 , 45, 222, 0));
		graphics.beginBitmapFill(bitmapData);
		graphics.drawCircle(0, 0, size);
		filters = [new GlowFilter(0xFFFFCC,0.5, 7, 7)];
	}
}

import flash.display.Shape;
import flash.events.Event;
class Moon extends Star
{
	public var angle:Number;
	public var radius:Number;

	public function Moon(initObject:Object = null)
	{
		size = 3;
		init(initObject);
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(size*2, size*2, 0, -size/4, -size);
		graphics.beginGradientFill(GradientType.RADIAL, [0xFFFF00, 0x666666], [1.0, 1.0], [0, 255], matrix);
		//graphics.beginFill(0xFFFF66);
		graphics.drawCircle(0, 0, size);
		if (!angle) angle = Math.random() * Math.PI * 2;
		x = radius * Math.cos(angle);
		y = radius * Math.sin(angle);
		addEventListener(Event.ENTER_FRAME, enterFrameListener);
	}
	
	private function enterFrameListener(event:Event):void
	{
		angle += 0.001;
		x = radius * Math.cos(angle);
		y = radius * Math.sin(angle);
	}
}

class Spark extends Sprite
{
	public var angle:Number;
	public var offset:Number;
	private var i:uint;
	private var _trashs:Array = [];
	private var _count:uint;
	
	public function Spark(initObject:Object = null)
	{
		angle = 0;
		offset = 0;
		init(initObject);
		x += Math.cos(angle) * offset;
		y += Math.sin(angle) * offset;
		for (i = 0; i < 20; i++)
		{
			var eachAngle:Number = Math.random() * Math.PI/8 - Math.PI/16 + angle;
			var dist:Number = Math.random()*2;
			var star:Star = new Star( { color:0x999999, ax:dist * Math.cos(eachAngle), ay:dist * Math.sin(eachAngle) } );
			addChild(star);
		}
		addEventListener(Event.ENTER_FRAME, enterFrameListener);
	}
	
	private function enterFrameListener(event:Event):void
	{
		var star:Star;
		for (i = 0; i < numChildren; i++)
		{
			star = getChildAt(i) as Star;
			star.x += star.vx;
			star.y += star.vy;
			star.vx += star.ax;
			star.vy += star.ay;
			star.alpha += (0 - star.alpha) * 0.3;
		}
		if (++_count > 240)
		{
			removeEventListener(event.type, arguments.callee);
			for (i = 0; i < numChildren; i++)
			{
				removeChildAt(0);
			}
		}
	}
	protected function init(initObject:Object):void
	{
		if (!initObject) return;
		for (var property:String in initObject)
		{
			if (this.hasOwnProperty(property)) this[property] = initObject[property];
		}
	}
}