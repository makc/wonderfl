//
// scatterd letters
// http://www.openprocessing.org/visuals/?visualID=1811
//

package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	
	[SWF(width=465, height=465, frameRate=15, backgroundColor=0xeeeeee)]
	public class ScatterLetters extends Sprite
	{
		private var kana:TextField = new TextField();
		private var format:TextFormat = new TextFormat();
		private var base:BitmapData = new BitmapData(Util.Wid+100, Util.Hei+100, true, 0x00ffffff);
		private var holder:Bitmap = new Bitmap(base);
		private var count:int = 0;
		
		private var timer:Timer = new Timer(15);
		public function ScatterLetters()
		{
			
			super();
			if(stage){
				stage.addEventListener(MouseEvent.CLICK, onClick);
				stage.quality = StageQuality.BEST;
			}
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			addChild(holder);
			holder.x = -50;
			holder.y = -50;
			format.color = 0x000000;
			format.size = 220;
			
			
			drawEdge();
				
		}
		private function drawEdge():void
		{
			var sp:Sprite = new Sprite();
			sp.graphics.lineStyle(80,0xeeeeee);
			
			sp.graphics.drawRect(25,25,Util.Wid+50, Util.Hei+50);
			//stage.addChild(sp);
			base.draw(sp);
		}
		private function onClick(e:MouseEvent):void
		{
			base.fillRect(base.rect, 0xffffff);
			drawEdge();
			count = 0;
		}
		private function onTimer(e:TimerEvent):void
		{
			count += 1;
			
			if(count < Util.CharNum){
				
			
				var sca:Number = (Util.CharNum - count) / Util.CharNum;
				var sc:Number;
				if(count < 3){
					sc = sca + (4 - count)*0.45 + 0.1;
				}else if(count < 15){ 
					sc = (15 - count) *0.015 + 0.7;
				}else if(count < 35){
					
					sc = (35-count)*0.001 + 0.35;
				}else{
					sc = (Util.CharNum-count)*0.0004 + 0.09;
					
				}
				
				var bm:Bitmap = createTextBitmap(sc);
				
				var off:int = 0;
				
				
				for(var j:int = 0; j < Util.TryNum; j++)
				{
					bm.x = Math.random() * (Util.Wid + 50) - off;
					bm.y = Math.random() * (Util.Hei + 50) - off;
					if(!fitTest(bm))
					{
						var mat:Matrix = new Matrix(1,0,0,1,bm.x, bm.y);
						base.draw(bm,mat);
						break;
					}
				}
				
			}
				
				
			
		}
		private function fitTest(bm:Bitmap):Boolean
		{
			var bd1:BitmapData = bm.bitmapData;
			var bd2:BitmapData = holder.bitmapData;
			var result:Boolean = bd1.hitTest(new Point(bm.x, bm.y), 255, bd2, new Point(0,0), 255);
			
			return result;
		}
		private function createTextBitmap(sc:Number):Bitmap
		{
			var str:String = Util.getChar();
			var text:TextField = new TextField();
			
			text.text = str;
			text.setTextFormat(format);
			text.sharpness= 0; 
			text.thickness= 2;
			
			var bm:Bitmap = new Bitmap( textToBmd( text,sc) ,"auto", true);
			var shadow:DropShadowFilter = new DropShadowFilter(1,45,0,0.9);
			var be:BevelFilter = new BevelFilter(4,45,0xffffff);
			var gl:GlowFilter = new GlowFilter(0x000000,0.9,2,2,1,2);
			//bm.filters = [gl];
			return bm;
		}
		private function textToBmd(text:TextField, sc:Number):BitmapData
		{
			text.width = text.textWidth;
			text.height = text.textHeight;			
			
			var size:int;
			if(text.width > text.height){
				size = text.width;
			}else{
				size = text.height;
			}
			
				size = size * sc
			
                        var anti:int;
                        if(sc > 1){
                            anti = 10;
                         }else{
                             anti = 10;    
                         }
			var mat2:Matrix = new Matrix();
			mat2.scale(anti,anti);
			
			
			var mat:Matrix = new Matrix();
			mat.scale(sc/anti,sc/anti);
			mat.translate(-size/2, -size/2);
			mat.rotate(Math.random() * Math.PI * 2);
			mat.translate(size/2, size/2);

			var bmd:BitmapData = new BitmapData(1500,1500,true,0x00ffffff);
			bmd.draw(text,mat2);
			var bmm:Bitmap = new Bitmap(bmd);
			var gl:GlowFilter = new GlowFilter(0x000000,1,2,2,2,1);
			//bmm.filters = [gl]
			var newbmd:BitmapData = new BitmapData(400,400,true,0x00ffffff);
			newbmd.draw(bmm,mat);
			bmd.dispose();
			return newbmd;
		}
	}
}

class Util
{
		public static const Wid:int = 465;
		public static const Hei:int = 465;
		
		public static const CharNum:int = 400;
		public static const TryNum:int = 400;
	   
	      
	      public static function getChar():String
	      {
		          //var chars:Array = [getHiragana()];
				  var chars:String;
				  chars = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよわをん"
		          return chars.charAt( Math.floor(Math.random() * chars.length) );
	      }
	
}