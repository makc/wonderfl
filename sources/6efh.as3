package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.net.*;
    import flash.system.*;
    import jp.progression.casts.*;
    import jp.progression.commands.display.*;
    import jp.progression.commands.lists.*;
    import jp.progression.commands.net.*;
    import jp.progression.data.*;
    
    public class Main extends CastDocument {
        
        private var window:Sprite = new Sprite();
        private var windowMask:Sprite = new Sprite();
        private var bg:Sprite = new Sprite();
        private var flost:Sprite = new Sprite();
        static public const URL:String = "http://farm3.static.flickr.com/2599/3989465047_d24f577563_b.jpg";
        /**
         * 初期化
         */
        override protected function atReady():void {
            new SerialList(null,
                new LoadBitmapData(new URLRequest(URL), {context:new LoaderContext(true)}),
                initWindow
                ).execute();
        }
        /**
         * ウィンドウの生成
         */
        private function initWindow():void {
            addChild(bg);
            addChild(flost);
            addChild(windowMask);
            addChild(window);
            
            var res:Resource = getResourceById(URL);
            
            bg.addChild(new Bitmap(res.toBitmapData()));
            flost.addChild(new Bitmap(res.toBitmapData()));
            
            window.blendMode = BlendMode.LAYER;
            
            var f:Sprite = new WindowRect();
            var r:Sprite = new WindowRect();
            var o:Sprite = new Window();
            
            f.filters = [new GlowFilter(0x0, 1, 12, 12, 2.5, 3)];
            r.blendMode = BlendMode.ERASE;
            
            window.addChild(f);
            window.addChild(r);
            window.addChild(o);
            
            windowMask.addChild(new WindowRect);
            
            flost.mask = windowMask;
            flost.filters = [new BlurFilter(8, 8, 4)];
            
            window.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
            
            //　位置あわせ
            bg.x = flost.x = -100;
            bg.y = flost.y = -170;
            window.x = windowMask.x = 120;
            window.y = windowMask.y = 120;
        }
        
        /**
         * ドラッグ開始
         */
        private function downHandler(e:MouseEvent):void {
            window.startDrag();
            stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
        }
        
        /**
         * ドラッグしている際中
         */
        private function moveHandler(e:MouseEvent):void {
            windowMask.x = window.x;
            windowMask.y = window.y;
            e.updateAfterEvent();
        }
        /**
         * ドラッグ終わり
         */
        private function upHandler(e:MouseEvent):void {
            window.stopDrag();
            stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
        }
    }
}

import flash.display.Sprite;
import flash.text.TextField;
/**
 * ウィンドウの形状
 */
class WindowRect extends Sprite {
    public function WindowRect() {
        graphics.beginFill(0xFFFFFF);
        graphics.drawRoundRect(0, 0, 200, 200, 10);
    }
}

/**
 * ウィンドウの中身
 */
class Window extends Sprite {
    public function Window() {
        graphics.lineStyle(1, 0xFFFFFF);
        graphics.drawRoundRect(0, 0, 200, 200, 10);
        
        graphics.lineStyle(1, 0xFFFFFF, 0.5);
        graphics.drawRoundRect(4, 24, 192, 172, 0);
        
        graphics.lineStyle(1, 0x000000);
        graphics.beginFill(0xFFFFFF);
        graphics.drawRoundRect(5, 25, 190, 170, 0);
    }
}