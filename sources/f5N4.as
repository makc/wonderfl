// forked from Kay's Shining Text
/*
 * テキストをアウトライン化してVector.<Point>に保存し
 * テキストの外周から線を引いて光を表現する
 */
package
{
    import caurina.transitions.Tweener;
    
    import flash.display.*;
    import flash.events.*;
    import flash.filters.BlurFilter;
    import flash.filters.GlowFilter;
    import flash.geom.*;
    import flash.text.TextField;

    public class LightBurst extends MovieClip
    {
        
        public const SW:Number = stage.stageWidth;
        public const SH:Number = stage.stageHeight;
        public const CX:Number = SW/2;
        public const CY:Number = SH/2;
        public var vOutline:Vector.<Point> = new Vector.<Point>();
        public var lx:Number = 0;
        private var canvas:Shape;
        
        private var container:Sprite;
        private var glowContainer:Sprite;
        
        private var myText:SimpleText;
        private var glowText:SimpleText;
        
        private var screen:Bitmap;
        private var buffer:BitmapData;
        
        private var lightBuffer:BitmapData;
        
        private var glowTextMask:Shape;
        
        private var blurFilter:BlurFilter = new BlurFilter(12, 35);
        
        
        public function LightBurst()
        {
            canvas = new Shape();
            
            glowContainer = new Sprite();
            addChild(glowContainer);
            
            var overlayRect:Shape = createOverlayRect();
            var trimRect:Shape = createTrimRect();
            
            lightBuffer = new BitmapData(SW, SH, true, 0);
            
            myText = new SimpleText('Light Burst', 'Georgia', 46, 0x98833D);
            glowText = new SimpleText('Light Burst', 'Georgia', 46, 0xF5DC8D);
            glowText.filters = [new GlowFilter(0xFFE8AB, 1, 10, 10, 4, 2), new BlurFilter(7, 7, 1)];
            
            var vTemp:Vector.<Boolean> = new Vector.<Boolean>();
            const TW:Number = myText.width;
            const TH:Number = myText.height;
            
            myText.x = (SW - TW) / 2;
            myText.y = (SH - TH) / 2;
            
            // Text -> BitmapData
            var bmd:BitmapData = new BitmapData(TW,TH,true,0x00000000);
            bmd.draw(myText);
            
            // getPixelColor
            for (var h:uint = 0; h < TH; h++) {
                for (var w:uint = 0; w < TW; w++) {
                    vTemp[h*TW + w] = bmd.getPixel(w,h);
                }
            }
            
            // Gain inner Pixels
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
            
            
            glowText.x = myText.x;
            glowText.y = myText.y;
            glowText.cacheAsBitmap = true;
            
            glowTextMask = createGlowTextMask();
            glowTextMask.cacheAsBitmap = true;
            glowText.mask = glowTextMask;
            glowTextMask.scaleX = 1.35;
            
            glowContainer.addChild(glowText);
            glowContainer.addChild(glowTextMask);
            glowContainer.blendMode = BlendMode.LAYER;
            
            
            container = new Sprite();
            addChild(container);
            container.addChild(myText);
            container.addChild(glowContainer);
            container.addChild(new Bitmap(lightBuffer));
            container.addChild(overlayRect);
            container.addChild(trimRect);
            container.visible = false;
            
            
            buffer = new BitmapData(SW, SH, false, 0);
            screen = new Bitmap(buffer);
            addChild(screen);
            screen.smoothing = true;
            
            
            addEventListener(Event.ENTER_FRAME, xAnimation);
            zoomOutScreen();
        }
        
        
        private function xAnimation(e:Event):void {
            
            lx+=5;
            if (lx > SW) {
                lx = 0;
                zoomOutScreen();
            }
            glowTextMask.x = lx;
            
            // Drow
            var g:Graphics = canvas.graphics;
            g.clear();
            g.lineStyle(1,0xFFEB79,0.3);
            const RANGE:Number = 17;
            var len:int = vOutline.length;
            for (var i:uint = 0; i < len; i++) {
                var tx:Number = vOutline[i].x+CX;
                if(tx > lx-RANGE && tx < lx+RANGE || (i%10 == 1 && tx > lx-RANGE*5 && tx < lx+RANGE*5)){
                    var r:Number = Math.atan2(vOutline[i].y,vOutline[i].x+(CX-lx));
                    var dp:Point = Point.polar(CX*3,r);    // このCXは長さ
                    g.moveTo(vOutline[i].x+CX,vOutline[i].y+CY);
                    g.lineTo(vOutline[i].x+lx+dp.x, vOutline[i].y+CY+dp.y);
                }
            }
            lightBuffer.fillRect(lightBuffer.rect, 0);
            lightBuffer.draw(canvas);
            lightBuffer.applyFilter(lightBuffer, lightBuffer.rect, new Point(), blurFilter);
            lightBuffer.applyFilter(lightBuffer, lightBuffer.rect, new Point(), blurFilter);
            
            buffer.fillRect(buffer.rect, 0);
            buffer.draw(container, null, null, null, null, true);
        }
        
        private function zoomOutScreen():void{
            const s:Number = 1.2;
            
            screen.scaleX = screen.scaleY = s;
            screen.x = -SW*(s-1)/2;
            screen.y = -SH*(s-1)/2;
            Tweener.addTween(screen, {scaleX:1, scaleY:1, x:0, y:0, time:2, delay:0.9, transition:"easeOutQuad"});
        }
        
        private function createGlowTextMask():Shape{
            const G_PADDING:Number = 20;
            const GW:Number = glowText.width + G_PADDING*2;
            const GH:Number = glowText.height + G_PADDING*2;
            
            var shape:Shape = new Shape();
            var g:Graphics = shape.graphics;
            var mat:Matrix = new Matrix();
            var r:Number = GH/2;
            mat.createGradientBox(2*r, 2*r, 0, -r, -r);
            g.beginGradientFill(GradientType.RADIAL, [0xFFFFFF, 0xFFFFFF], [1, 0], [0, 255], mat); 
            g.drawCircle(0, 0, r);
            g.endFill();
            
            shape.x = (SW - GW) / 2 +r;
            shape.y = (SH - GH) / 2 +r;
            
            return shape;
        }
        
        private function createOverlayRect():Shape{
            const SCALE_W:Number = 2;
            const SCALE_H:Number = 1.2;
            const RW:Number = SCALE_W*SW/2;
            const RH:Number = SCALE_H*SH/2;
            
            var shape:Shape = new Shape();
            var g:Graphics = shape.graphics;
            var mat:Matrix = new Matrix();
            mat.createGradientBox(2*RW, 2*RH, 0, 0, 0);
            g.beginGradientFill(GradientType.RADIAL, [0xFFFFFF, 0x000000], [1, 1], [0, 255], mat); 
            g.drawEllipse(0, 0, RW*2, RH*2);
            g.endFill();
            
            shape.x = (SW - shape.width) / 2;
            shape.y = (SH - shape.height) / 2;
            shape.blendMode = BlendMode.OVERLAY;
            shape.cacheAsBitmap = true;
            
            return shape;
        }
        
        private function createTrimRect():Shape{
            const TY:Number = 35;
            
            var shape:Shape = new Shape();
            var g:Graphics = shape.graphics;
            var mat:Matrix = new Matrix();
            mat.createGradientBox(SW, SH-TY*2, Math.PI/2, 0, TY);
            g.beginGradientFill(GradientType.LINEAR, [0, 0, 0, 0], [1, 0, 0, 1], [0, 51, 204, 255], mat); 
            g.drawRect(0, 0, SW, SH);
            g.endFill();
            
            shape.cacheAsBitmap = true;
            
            return shape;
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