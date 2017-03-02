/*
 * テキストをアウトライン化してVector.<Point>に保存し
 * テキストの外周から線を引いて光を表現する
 */
package {
    import flash.display.*;
    import flash.geom.*;
    import flash.events.*;
    
    public class Main extends Sprite {
    	
		public const SW:Number = stage.stageWidth;
		public const SH:Number = stage.stageHeight;
		public const CX:Number = SW/2;
		public const CY:Number = SH/2;
		public var vOutline:Vector.<Point> = new Vector.<Point>();
		public var lx:Number = 0;
		public var myStage:Sprite = new Sprite();

		public function Main() {
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0);
			sprite.graphics.drawRect(0,0,SW,SH);
			sprite.graphics.endFill();
			addChild(sprite);
			addChild(myStage);
			
        		var myText:SimpleText = new SimpleText('wonderFl','Arial',32,0xffff99);
        		
			var vTemp:Vector.<Boolean> = new Vector.<Boolean>();
			const TW:Number = myText.width;
			const TH:Number = myText.height;

			// Text -> BitmapData
			var bmd:BitmapData = new BitmapData(TW,TH,true,0x00000000);
			bmd.draw(myText);
			var bitmap:Bitmap = new Bitmap(bmd);
			addChild(myText);
			myText.x = (SW - TW) / 2;
			myText.y = (SW - TH) / 2;
			
			// getColor
			for (var h:uint = 0; h < TH; h++) {
				for (var w:uint = 0; w < TW; w++) {
					vTemp[h*TW + w] = bmd.getPixel(w,h);
				}
			}
	
			// Gain inner Picels
			for (h = 0; h < TH; h++) {
				for (w = 0; w < TW; w++) {
					var flg:Boolean = false;
					var pos:uint = h*TW + w;
					if (h == 0 || h == TH-1 || w == 0 || w == TW-1) {
						flg = vTemp[pos];
					} else {
						flg = false;
						if (vTemp[pos] == true) {
							if (vTemp[pos+TW]+vTemp[pos-TW]+vTemp[pos-1]+vTemp[pos+1] < 4) {
								flg = true;
							}
						}
					}
					if (flg) {
						vOutline.push(new Point(w-TW/2,h-TH/2));
					}
				}
			}
			addEventListener(Event.ENTER_FRAME, xAnimation);
        }
        
        public function xAnimation(e:Event):void {
        		lx+=2;
        		if (lx > SW) {
        			lx = 0;
        		}
			// Drow
			myStage.graphics.clear();
			myStage.graphics.lineStyle(1,0xcccc33,0.3);
			for (var i:uint = 0; i < vOutline.length; i++) {
				var r:Number = Math.atan2(vOutline[i].y,vOutline[i].x+(CX-lx));
				var dp:Point = Point.polar(CX*2,r);	// このCXは長さ
				myStage.graphics.moveTo(vOutline[i].x+CX,vOutline[i].y+CY);
				myStage.graphics.lineTo(vOutline[i].x+lx+dp.x,vOutline[i].y+CY+dp.y);
			}
        		
        		
        }
    }
}

import flash.display.*;
import flash.text.*;
class SimpleText extends Sprite {
	public function SimpleText(message:String, fontName:String, fontSize:Number, fontColor:uint) {
		var tf:TextFormat = new TextFormat();
		tf.color = fontColor;
		tf.size = fontSize;
		tf.font = fontName;
		
		var txt:TextField = new TextField();
		txt.autoSize = TextFieldAutoSize.LEFT;
		txt.text = message;
		txt.selectable = false;
		txt.setTextFormat(tf);
		
		addChild(txt);
	}
}
