package
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.filters.BlurFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	
	import net.hires.debug.Stats;
	
        [SWF(frameRate=60, width=465, height=465, backgroundColor=0x000000)]

	public class Main extends MovieClip
	{
		private var _menu1:MovieClip;
		private var _menu2:MovieClip;
		private var _menu3:MovieClip;
		private var _textField:TextField;
		private var _film:BitmapData;
		private var _canvas:Shape;
		private var _particles:Array;
		private var _targetName:String;
		
		public function Main()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			addEventListener(Event.ENTER_FRAME, watchStage);
		}
		
		private function watchStage(event:Event):void
		{
			if (stage.stageWidth && stage.stageHeight)
			{
				removeEventListener(Event.ENTER_FRAME, watchStage);
				
				start();
			}
		}
		
		private function start():void
		{
			_targetName = 'none';
			
			_film = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0xffffff);
			addChild(new Bitmap(this._film));
			
			var textFormat:TextFormat = new TextFormat(null, 80, 0x000000, true);
			_textField = new TextField();
			_textField.autoSize = TextFieldAutoSize.LEFT;
			_textField.selectable = false;
			_textField.defaultTextFormat = textFormat;
			_textField.text = 'Menu';
			
			var bitmapData:BitmapData = new BitmapData(_textField.width, _textField.height, true, 0x00000000);
			bitmapData.draw(_textField);
			var bitmap1:Bitmap = new Bitmap(bitmapData);
			bitmap1.alpha = 0.1;
			_menu1 = new MovieClip();
			_menu1.name = 'menu1';
			_menu1.x = 30;
			_menu1.y = 30;
			_menu1.addChild(bitmap1);
			addChild(_menu1);
			
			var bitmap2:Bitmap = new Bitmap(bitmapData);
			bitmap2.alpha = 0.1;
			_menu2 = new MovieClip();
			_menu2.name = 'menu2';
			_menu2.x = 30;
			_menu2.y = _menu1.y + _menu1.height + 5 + 30;
			_menu2.addChild(bitmap2);
			addChild(_menu2);
			
			var bitmap3:Bitmap = new Bitmap(bitmapData);
			bitmap3.alpha = 0.1;
			_menu3 = new MovieClip();
			_menu3.name = 'menu3';
			_menu3.x = 30;
			_menu3.y = _menu2.y + _menu2.height + 5 + 30;
			_menu3.addChild(bitmap3);
			addChild(_menu3);
			
			_canvas = new Shape();
			
			createParticle();
			
			drawCanvas();
			
			var timer:Timer = new Timer(300, 1);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();
		}
		
		private function timerHandler(event:TimerEvent):void
		{
			event.target.removeEventListener(TimerEvent.TIMER, timerHandler);
			
			_targetName = '';
			addEventListener(Event.ENTER_FRAME, step);
			
			_menu1.buttonMode = true;
			_menu2.buttonMode = true;
			_menu3.buttonMode = true;
			_menu1.addEventListener(MouseEvent.ROLL_OVER, offReverse);
			_menu1.addEventListener(MouseEvent.ROLL_OUT, onReverse);
			_menu2.addEventListener(MouseEvent.ROLL_OVER, offReverse);
			_menu2.addEventListener(MouseEvent.ROLL_OUT, onReverse);
			_menu3.addEventListener(MouseEvent.ROLL_OVER, offReverse);
			_menu3.addEventListener(MouseEvent.ROLL_OUT, onReverse);
		}
		
		private function createParticle():void
		{
			var bmpData:BitmapData = new BitmapData(_textField.width, _textField.height, false, 0xffffff);
			bmpData.draw(_textField);
			
			_particles = [];
			var particleCount:uint = _textField.width * _textField.height;
			var w:uint = 0;
			var h:uint = 0;
			var baseX:Number = 0;
			var baseY:Number = 0;
			var targetName:String;
			var angle:Number;
			for (var k:uint = 0;k < 3;k++)
			{
				targetName = 'menu' + String(k + 1);
				
				baseX = 30;
				baseY = k * (_textField.height + 5 + 30) + 30;
				for (var i:uint = 0;i < bmpData.width;i++)
				{
					if (i % 4 != 0) continue;
					
					for (var j:uint = 0;j < bmpData.height;j++)
					{
						if (j % 4 != 0) continue;
						
						w = i;
						h = j;
						
						if (bmpData.getPixel(w, h) != 0x000000) continue;
						
						var particle:Particle = new Particle();
						particle.mcName = targetName;
						particle.color = bmpData.getPixel(w, h);
						
						particle.x = w + baseX;
						particle.y = h + baseY;
						particle.end = new Point(particle.x, particle.y);
						angle = Math.random() * Math.PI * 2;
						particle.start = new Point(Math.cos(angle) * 600 + baseX, Math.sin(angle) * 600 + baseY);
						
						_particles.push(particle);
					}
				}
			}
			bmpData.dispose();
		}
		
		private function step(event:Event):void
		{
			drawCanvas();
		}
		
		private function drawCanvas():void
		{
			var i:uint, 
				l:uint, 
				p:Particle, 
				g:Graphics;
			
			l = _particles.length;
			g = _canvas.graphics;
			
			g.clear();
			for (i = 0;i < l;i++)
			{
				p = _particles[i];
				
				if (_targetName == 'none')
				{
					// 何もしない
				}
				else if (_targetName == '' || _targetName != p.mcName)
				{
					if (!p.reverse) p.reverse = true;
					p.update();
				}
				else if (_targetName == p.mcName)
				{
					if (p.reverse) p.reverse = false;
					p.update();
				}
				
				if (p.isAlive)
				{
					g.beginFill(p.color, 0.5);
					g.drawCircle(p.x, p.y, 1);
					g.endFill();
				}
			}
			
			_film.lock();
			_film.fillRect(_film.rect, 0xffffff);
			_film.draw(_canvas);
			//_film.applyFilter(_film, _film.rect, new Point(0, 0), new BlurFilter(8, 8, BitmapFilterQuality.MEDIUM));
			_film.unlock();
		}
		
		private function onReverse(event:MouseEvent):void
		{
trace("rollOut");
			_targetName = '';
		}
		
		private function offReverse(event:MouseEvent):void
		{
trace("rollOver");
			_targetName = event.target.name;
		}
	}
}

import flash.geom.Point;
class Particle
{
	public var mcName:String;
	public var isAlive:Boolean = true;
	public var x:Number = 0;
	public var y:Number = 0;
	public var color:uint = 0;
	public var start:Point;
	public var end:Point;
	
	private var _reverse:Boolean = true;
	private var _vx:Number = 0;
	private var _vy:Number = 0;
	private var _tick:uint = 0;
	
	public function get reverse():Boolean
	{
		return _reverse;
	}
	
	public function set reverse(reverse:Boolean):void
	{
		_reverse = reverse;
		isAlive = true;
	}
	
	public function Particle()
	{
		var strength:Number = Math.random() * 4;
		var angle:Number = Math.random() * Math.PI * 2;
		_vx = strength * Math.cos(angle);
		_vy = strength * Math.sin(angle);
	}
	
	public function update():void
	{
		if (!isAlive) return;
		
		var speed:Number, 
			target:Point, 
			delta:Point;
		
		target = _reverse ? start : end;
		if (_reverse)
		{
			_tick++;
			var t:Number = _tick / 60;
			
			x += 9 * t + _vx;
			y += -3 * t + _vy;
		}
		else
		{
			_tick = 0;
			
			delta = target.subtract(new Point(x, y));
			
			x += delta.x * .5;
			y += delta.y * .5;
		}
		
		if (reverse && Math.abs(target.x - x) < .5 && Math.abs(target.y - y) < .5)
		{
			x = target.x;
			y = target.y;
			
			isAlive = false;
		}
	}
}