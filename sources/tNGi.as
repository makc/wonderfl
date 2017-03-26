//コードはめっちゃ汚いよ！
//ブロックの数465*100
//がんばってクリアしてください
package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import net.hires.debug.Stats;
	
	[SWF(width = "465", height = "465", frameRate = "30")]
	public class BlockBreaker extends Sprite 
	{
		private static const HEIGHT:Number = 465;
		private static const WIDTH:Number = 465;
		private var _canvas:BitmapData;
		private var _blocks:Blocks;
		private var _fallBlocks:Vector.<Particle>;
		private var _balls:Vector.<Particle>;
		private var _bar:Bitmap;
		
		public function BlockBreaker()
		{
			_canvas = new BitmapData(WIDTH, HEIGHT,false,0x000000);
			addChild(new Bitmap(_canvas));
			
			_blocks = new Blocks(WIDTH, 100);
			
			_fallBlocks = new Vector.<Particle>();
			
			var b:BitmapData = new BitmapData(50, 10, false, 0x00FF00);
			addChild(_bar = new Bitmap(b));
			_bar.y = WIDTH -b.width;
			var _ball:Particle = new Particle(WIDTH / 2, HEIGHT / 2);
			_ball.vx = Math.random() *10;
			_ball.vy = -Math.random() *9 -1;
			_ball.color = 0xFFFFFF;
			
			_balls = new Vector.<Particle>();
			_balls.push(_ball);
			
			//var stats:Stats = new Stats();
			//stats.y = 200;
			//addChild(stats);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		private function update(e:Event):void
		{
			_canvas.lock();
			_canvas.colorTransform(_canvas.rect, new ColorTransform (0.9, 0.5, 0.9));
			
			for each(var block:Particle in _blocks.values)
			{
				if (block)
				{
					_canvas.setPixel(block.x, block.y, block.color);
				}
			}
			var removeBalls:Vector.<Particle> = new Vector.<Particle>();
			 for each(var ball:Particle in _balls)
			 {
				var bvx:Number = ball.vx;
				var bvy:Number = ball.vy;
				var bspeed:Number = Math.sqrt(bvx * bvx + bvy * bvy);
				var bradius:Number = Math.atan2(bvy, bvx);
				for (var i:int = 0; i < bspeed;i++)
				{
					ball.x += ball.vx/bspeed;
					ball.y += ball.vy/bspeed;
					var hitParticle:Particle = _blocks.getParticle(ball.x, ball.y);
					if(hitParticle)
					{
						var removedP:Particle = _blocks.removeParticle(ball.x, ball.y);
						removedP.vx = Math.cos(bradius+Math.PI*2/(30*Math.random())-15)*3;
						removedP.vy = 1;
						removedP.color = hitParticle.color;
						_fallBlocks.push(removedP);
						ball.vy = -ball.vy;
					}
					
					if ((ball.x < 0 && ball.vx < 0) || (ball.x > WIDTH && ball.vx > 0))
					{
						ball.vx = -ball.vx;
					}
					if (ball.y < 0 && ball.vy < 0)
					{
						ball.vy = -ball.vy;
					}
					if (ball.y > HEIGHT)
					{
						removeBalls.push(ball);
					}
					if (_bar.hitTestPoint(ball.x, ball.y))
					{
						ball.vy = -Math.abs(ball.vy);
					}
					_canvas.setPixel(ball.x, ball.y, ball.color);
				}
			}
			removeBalls.forEach(function(b:Particle, ...args):void {
				var index:int = _balls.indexOf(b);
				if (index != -1)
				{
					_balls.splice(index, 1);
				}
			});
			
			var removeFallBs:Vector.<Particle> = new Vector.<Particle>();
			_fallBlocks.forEach(function(fallP:Particle, ...args):void {
				fallP.vy += 0.1;
				fallP.x += fallP.vx;
				fallP.y += fallP.vy;
				_canvas.setPixel(fallP.x, fallP.y, fallP.color);
				if (_bar.hitTestPoint(fallP.x,fallP.y))
				{
					var newball:Particle = new Particle(fallP.x,fallP.y);
					newball.vx = Math.random() * 10;
					newball.vy = Math.random() * 9 + 1;
					newball.color = fallP.color;
					_balls.push(newball);
					removeFallBs.push(fallP);
				}else if (fallP.y > HEIGHT)
				{
					removeFallBs.push(fallP);
				}
			});
			
			removeFallBs.forEach(function(b:Particle,...args):void{
				var index:int = _fallBlocks.indexOf(b);
				if (index != -1)
				{
					_fallBlocks.splice(index, 1);
				}
			});
			_bar.x = stage.mouseX;
			_canvas.unlock();
			
			if (_blocks.count == 0)
			{
				removeEventListener(Event.ENTER_FRAME, update);
				var clearTF:TextField = new TextField();
				clearTF.text = "CLEAR!\nおめでと";
				clearTF.textColor = 0xFFFFFF;
				clearTF.autoSize = TextFieldAutoSize.LEFT;
				_canvas.draw(clearTF,new Matrix(5,0,0,5,WIDTH/2-clearTF.width*5/2,HEIGHT/2-clearTF.height*5/2));
			}
			
		}
	}
}
import frocessing.color.ColorHSV;
class Blocks
{
	public function get count():int { return _count;}
	private var _count:int;
	public function get width():Number { return _width; }
	private var _width:Number;
	public function get height():Number { return _height; }
	private var _height:Number;
	public var values:Vector.<Particle>;
	function Blocks(width:Number,height:Number)
	{
		_width = width;
		_height = height;
		_count = width * height;
		values = new Vector.<Particle>(width * height, false);
		var c:ColorHSV = new ColorHSV();
		for (var i:int = 0; i < _width; i++)
		{
			c.h = 360 * i / _width;
			for (var j:int = 0 ; j < _height; j++ )
			{
				var p:Particle = new Particle(i, j);
				p.color = c.value;
				values[i + j * _width] = p;
			}
		}
	}
	public function getParticle(x:int, y:int):Particle
	{
		var index:int = x + y * _width;
		if (index >= values.length || index < 0)
		{
			return null;
		}
		return values[x + y * _width];
	}
	public function removeParticle(x:int, y:int):Particle
	{
		var p:Particle = values[x + y * _width];
		if (p)
		{
			_count--;
			values[x + y * _width] = undefined;
		}
		return p;
	}
}
class Particle
{
	public var x:Number;
	public var y:Number;
	public var vx:Number = 0;
	public var vy:Number = 0;
	public var color:uint;
	public function Particle(x:Number=0,y:Number=0 )
	{
		this.x = x;
		this.y = y;
	}
}