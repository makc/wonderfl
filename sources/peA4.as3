package
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	
	// カーソルキーで操作できます。
	[SWF(width="465", height="465", frameRate="60")]
	public class Darius extends Sprite
	{
		public static const WIDTH:int = 233;
		public static const HEIGHT:int = 233;
		
		private var buffer:BitmapData;
		private var screen:Bitmap;
		
		private var loader:Loader;
		private var fish:Fish;
		private var bg:BG;
		
		function Darius()
		{
			Wonderfl.capture_delay(3);
			loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/2/2c/2c65/2c65f2686591075d582ac89a915d8819975e8155"), new LoaderContext(true));
		}
		
		private function onLoadComplete(e:Event):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			
			buffer = new BitmapData(WIDTH, HEIGHT, false, 0);
			screen = new Bitmap(buffer);
			screen.scaleX = screen.scaleY = 2;
			addChild(screen);
			
			fish = new Fish(Bitmap(loader.content).bitmapData);
			bg = new BG();
			
			Key.setListener(stage);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void
		{
			buffer.fillRect(buffer.rect, 0x181818);
			bg.draw(buffer);
			
			if(Key.isDown(40)) {fish.speed -= 0.05; fish.wait = 60*3;}
			if(Key.isDown(38)) {fish.speed += 0.05; fish.wait = 60*3;}
			if(Key.isDown(37)) {fish.head.dir += 4; fish.wait = 60*3;}
			if(Key.isDown(39)) {fish.head.dir -= 4; fish.wait = 60*3;}
			
			fish.main();
			fish.draw(buffer);
		}
	}
}

	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	
	class Fish
	{
		private var parts:Vector.<Segment> = new Vector.<Segment>(7, true);
		private var dirlog:Vector.<int> = new Vector.<int>();
		
		public var head:Segment;
		public var speed:Number = 4;
		public var dest:Number = 128;
		public var wait:int = 90;
		
		function Fish(bmp:BitmapData)
		{
			//反転画像の生成
			var temp:BitmapData = new BitmapData(Segment.WIDTH*16, Segment.HEIGHT*7, true, 0);
			var matrix:Matrix = new Matrix();
			temp.copyPixels(bmp, bmp.rect, new Point(0, 0));
			matrix.scale(-1, 1);
			matrix.translate(Segment.WIDTH*17, 0);
			temp.draw(bmp, matrix, null, null, new Rectangle(Segment.WIDTH*9, 0, Segment.WIDTH*7, Segment.HEIGHT*7));
			
			for(var i:int = 0; i < 7; i++)
			{
				var segment:Segment = new Segment(temp, i);
				parts[i] = segment;
			}
			
			//パーツ毎の距離
			parts[0].size = 44;
			parts[1].size = 32;
			parts[2].size = 28;
			parts[3].size = 22;
			parts[4].size = 24;
			parts[5].size = 24;
			
			//初期位置
			head = parts[0];
			head.x = Darius.WIDTH/2 + 80;
			head.y = 8;
			head.z = Segment.D;
			head.dir = 128;
			
			for(i = 0; i < 7*3+5; i++) {
				dirlog.unshift(head.dir);
			}
		}
		
		public function main():void
		{
			head.x += MathEx.getVectorX(head.dir, speed);
			head.z += MathEx.getVectorY(head.dir, speed);
			
			head.x = MathEx.limit(-Darius.WIDTH+80, head.x, Darius.WIDTH-80);
			head.z = MathEx.limit(Segment.D, head.z, Segment.D+600);
			
			if(wait > 0) {
				wait--;
			}
			else {
				if(Math.random() < 0.03) {dest = Math.floor(Math.random() * 16) * 16;}
				
				if(MathEx.getBearing(head.dir, dest) < -2) {
					head.dir += 4;
				}
				else if(MathEx.getBearing(head.dir, dest) > 2) {
					head.dir -= 4;
				}
			}
			
			if(head.dir >= 256) {head.dir -= 256;}
			if(head.dir < 0) {head.dir += 256;}
			
			dirlog.pop();
			dirlog.unshift(head.dir);
			
			//体節の処理
			for(var i:int = 1; i < parts.length; i++)
			{
				var segment:Segment = parts[i];
				var front:Segment = parts[i-1];
				
				segment.x = front.x + MathEx.getVectorX(front.dir, -front.size);
				segment.z = front.z + MathEx.getVectorY(front.dir, -front.size)+0.1;
				segment.y = front.y;
				segment.dir = dirlog[i*3+5];
			}
		}
		
		public function draw(screen:BitmapData):void
		{
			var temp:Vector.<Segment> = parts.slice();	//配列のコピー
			temp.sort(function(x:Segment, y:Segment):Number {return x.z <= y.z ? 1 : -1;});	//Zソート
			
			for(var i:int = 0; i < temp.length; i++) {
				temp[i].draw(screen);
			}
		}
	}
	
	class Segment
	{
		private var frames:Vector.<BitmapData> = new Vector.<BitmapData>(16, true);
		private var matrix:Matrix = new Matrix();
		
		public static const WIDTH:int = 128;
		public static const HEIGHT:int = 160;
		public static const D:int = 400;
		
		private var cx:int = WIDTH/2;
		private var cy:int = HEIGHT/2 + 4;
		
		public var x:Number = 0;
		public var y:Number = 0;
		public var z:Number = 0;
		public var dir:int = 0;
		public var size:int = 30;
		
		function Segment(bmp:BitmapData, num:int)
		{
			for(var i:int = 0; i < 16; i++)
			{
				var frame:BitmapData = new BitmapData(WIDTH, HEIGHT, true, 0);
				frame.copyPixels(bmp, new Rectangle(i * WIDTH, num * HEIGHT, WIDTH, HEIGHT), new Point(0, 0));
				frames[i] = frame;
			}
		}
		
		public function draw(screen:BitmapData):void
		{
			matrix.identity();
			matrix.translate(-cx, -cy);
			matrix.scale(D / z, D / z);
			matrix.translate((D * x / z) + Darius.WIDTH/2, (D * y / z) + Darius.HEIGHT/2);
			screen.draw(frames[Math.floor((dir+8) / 16+12) % 16], matrix);
		}
	}
	
	class BG
	{
		private var list:Vector.<Star> = new Vector.<Star>(400, true)
		
		function BG()
		{
			for(var i:int = 0; i < list.length; i++) {
				list[i] = new Star();
			}
		}
		
		public function draw(screen:BitmapData):void
		{
			for each(var star:Star in list) {
				star.draw(screen);
			}
		}
	}
	
	class Star
	{
		public var x:Number;
		public var y:Number;
		public var speed:Number;
		public var color:uint;
		
		function Star()
		{
			x = Math.random()*Darius.WIDTH;
			shuffle();
		}
		
		public function shuffle():void
		{
			y = Math.random()*Darius.HEIGHT;
			speed = Math.random()+0.1;
			color = MathEx.rand_int(0, 0xC0)*0x10000 + MathEx.rand_int(0, 0xC0)*0x100 + MathEx.rand_int(0, 0xC0);
		}
		
		public function draw(screen:BitmapData):void
		{
			x -= speed;
			if(x < 0) {
				x = Darius.WIDTH;
				shuffle();
			}
			screen.setPixel(x, y, color);
		}
	}
	
	class MathEx
	{
		public static function limit(min:Number, target:Number, max:Number):Number {return Math.max(min, Math.min(target, max));}
		public static function rand_int(min:int, max:int):int {return Math.floor(Math.random()*(max-min+1)+min);}
		public static function getVectorX(dir:Number, speed:Number):Number {return Math.cos(Math.PI/128*dir)*speed;}
		public static function getVectorY(dir:Number, speed:Number):Number {return Math.sin(Math.PI/128*dir)*speed;}
		
		public static function getBearing(dir1:Number, dir2:Number):Number
		{
			var d1:Number = normalizeAngle(dir1);
			var d2:Number = normalizeAngle(dir2);
			
			if(d2-128 > d1) {d1 += 256;}
			if(d2+128 < d1) {d1 -= 256;}
			
			return d1-d2;
		}
		
		public static function normalizeAngle(dir:Number):Number
		{
			if (dir < -128) {
				dir = 256 - (-dir % 256);
		    }
			dir = (dir + 128) % 256 - 128;
			return dir;
		}
	}
	
	class Key
	{
		private static var down:Vector.<Boolean> = new Vector.<Boolean>(256, true);
		
		public static function setListener(target:InteractiveObject):void
		{
			target.stage.focus = target;
			
			target.addEventListener(KeyboardEvent.KEY_DOWN, function (event:KeyboardEvent):void {down[event.keyCode] = true;});
			target.addEventListener(KeyboardEvent.KEY_UP, function (event:KeyboardEvent):void {down[event.keyCode] = false;});
			target.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
		}
		
		private static function onFocusOut(event:FocusEvent):void
		{
			event.currentTarget.stage.focus = event.currentTarget;
			
			//キーを押しながらフォーカスが外れると押しっぱなしになる現象の対策
			for(var i:int = 0; i < down.length; i++) {down[i] = false;}
		}
		
		public static function isDown(keycode:int):Boolean {
			return down[keycode];
		}
	}
