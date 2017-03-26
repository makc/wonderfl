package  
{

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;

	/**
	　* @Original code Info
	　* 
	　* from Proce55ing
	　* Metaball Demo Effect
	　* by luis2048. 
	 * 
	 * @update  onmyownlife.com transplanted to flash.
	 */
	public class Metaball extends Sprite
	{
		public static const STAGE_W:uint = 470;
		public static const STAGE_H:uint = 470;
		public static var stage:Stage;
                
		public static const TOTAL_BALL_COUNT:uint=6;
		public static const BT_WIDTH:uint=80;
		public static const BT_HEIGHT:uint=80;
		
		private var bitmapData:BitmapData;
		private var bitmap:Bitmap;
		private var balls_ary:Array;
		private var count:uint;

		public function Metaball(){init();}
		
		private function init():void {
                        Metaball.stage=this.stage;
			balls_ary = [];
			for (var i:uint = 0; i < TOTAL_BALL_COUNT; i++ ) {
			    var ball:Ball = new Ball(new Point(random1(), random1()),
                            new Point(int(random(1,BT_WIDTH)) , int(random(1,BT_HEIGHT))));					
			    balls_ary.push(ball);
			}
			
			bitmapData = new BitmapData(BT_WIDTH, BT_HEIGHT, false, 0x000000);
			bitmap = new Bitmap(bitmapData, "auto", true);
			addChild(bitmap);

			width = STAGE_W;
			height = STAGE_H;

			addEventListener(Event.ENTER_FRAME , update);
			stage.addEventListener(MouseEvent.MOUSE_UP , onMouseUp);
                        count=uint(Math.random()*10);
			bomb();
		}
		
		private function onMouseUp(evt:MouseEvent):void {
                        count++;
			bomb();
		}
		
		private function bomb():void {
			for (var i:uint  = 0; i < TOTAL_BALL_COUNT; i++ ) balls_ary[i].bomb();
		}
		
		private function update(evt:Event):void {
			for (var i:uint = 0; i < TOTAL_BALL_COUNT ; i++ ) balls_ary[i].update();
			
			render();
		}
		
		private function render():void {
			bitmapData.lock();
			for (var y:uint = 0; y < BT_HEIGHT; y++ ) {
				for (var x:uint = 0; x < BT_WIDTH; x++ ) {
					var pixelsValue:int = 0;
					for (var i:uint = 0; i < TOTAL_BALL_COUNT; i++ ) {
						var ball:Ball = balls_ary[i];
						pixelsValue += ball.currentRadius / (1 + ball.getPixelValue(x, y));
					}
					
					bitmapData.setPixel(x, y, convertRGBColor(pixelsValue));
				}
			}
			bitmapData.unlock();
		}
		
		private function convertRGBColor(pixelsValue:int):Number {
			var rgb:int;
			switch(count% 6) {
				case 0:    rgb = getRGB(0, pixelsValue/2 , pixelsValue);                    break;
				case 1:    rgb = getRGB( pixelsValue, pixelsValue / 2, 0);     	            break;
				case 2:    rgb = getRGB( pixelsValue, pixelsValue/3, pixelsValue/2);        break;	
				case 3:    rgb = getRGB( pixelsValue/2, pixelsValue*0.8, pixelsValue/5);    break;
				case 4:    rgb = getRGB( pixelsValue*0.8, pixelsValue/4, pixelsValue/7);    break;
				case 5:    rgb = getRGB(pixelsValue/6, pixelsValue/3 , pixelsValue*0.8);    break;
			}
			return rgb;
		}
                
		public static function shuffle(ary:Array):Array {
			var i :uint= ary.length;
			while (i--) {
				var j :uint= Math.floor(Math.random()*(i+1));
				var t :*= ary[i];
				ary[i] = ary[j];
				ary[j] = t;
			}
			return ary;
		}
		
		public static function getRGB(red : uint , green : uint , blue :uint):uint {
			return (Math.min(red, 255)<<16 | Math.min(green, 255)<< 8 | Math.min(blue, 255));
		}
		
		public static function random(min:Number , max:Number):Number {
			if (max == min) {
				return max;
			}else if (max < min) {
				var _temp: Number = max;
				max = min;
				min = _temp;
			}
			return Math.random() * (max - min) + min;
		}
		
		public static function random1(pct:Number = .5):int {
			return Math.random() < pct?1: -1;
		}
		
		public static function getPoint():Point {			
			return new Point(Metaball.BT_WIDTH * ( Metaball.stage.mouseX / Metaball.STAGE_W), Metaball.BT_HEIGHT * Metaball.stage.mouseY / Metaball.STAGE_H);
		}
	}
}

import flash.geom.Point;
	
class Ball {
	public var pixelX_ary:Array;
	public var pixelY_ary:Array;
	public var velocity:Point;
	public var position:Point;
        public var friction:Point;
	public var maxRadius:uint;
	public var currentRadius:uint;
	
	public function Ball(vel:Point , pos:Point) {
		velocity = vel;
		position = pos;
		reset();		
	}
	
	public function update():void {
                currentRadius += (maxRadius - currentRadius) / 10;
                position=position.add(velocity);
                velocity=velocity.subtract(friction);
		checkBorderline();
		setPixels();
	}
	
	private function checkBorderline():void {
		if (position.y > (Metaball.BT_HEIGHT + 10)) {
			reset();
			velocity.y = 1;
			position.y = -10;	
		}else if (position.y < -10) {
			reset();
			velocity.y = -1;
			position.y = Metaball.BT_HEIGHT + 10;		
		}
		
		if (position.x > (Metaball.BT_WIDTH+ 10)) {
			reset();
			position.x = -10;
			velocity.x = 1;
		}else if (position.x < -10) {
			reset();
			position.x = Metaball.BT_WIDTH + 10;	
			velocity.x = -1;			
		}
	}
	
	private function reset():void {
                friction=new Point(Metaball.random1() * Math.random() / 50 , Metaball.random1() * Math.random() / 50);
		currentRadius = Metaball.random( 5, 100);
		maxRadius = uint(Metaball.random(30000, 60000));
	}
	
	public function bomb():void {
		reset();
		position = Metaball.getPoint();
	}

	private function setPixels():void {
		pixelX_ary = [];
		pixelY_ary = [];
		for (var y:uint = 0; y < Metaball.BT_HEIGHT; y++ ) pixelY_ary[y] =  int((position.y - y)*(position.y - y));
		for (var x:uint = 0; x <  Metaball.BT_WIDTH; x++ ) pixelX_ary[x] = int((position.x - x)*(position.x - x));
	}
	
	public function getPixelValue(x:uint , y:uint):Number {return pixelX_ary[x] + pixelY_ary[y];}
	
}