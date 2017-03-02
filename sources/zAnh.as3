package  
{
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.DropShadowFilter;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    /**
     * 思わずイラッとしてしまう作品募集
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0xFFFFFF", frameRate = "30", width = "465", height = "465")]
    public class Test83 extends Sprite 
    {
        private const sizeW: int = 200, sizeH: int = 50;
        private var percent: int;
        private var sp: Sprite;
        private var txt: TextField;
        
        public function Test83() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null ): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            //
            var g: Graphics = graphics;
            g.beginFill(0x333333);
            g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            
            mouseChildren = false;
            addChild(sp = new Sprite());
            sp.addChild(txt = new TextField());
            txt.autoSize = "left";
            txt.defaultTextFormat = new TextFormat("Verdana", 10);
            txt.y = 5;
            setPercent(0);
            sp.filters = [new DropShadowFilter(0, 45, 0, 1, 16, 16, 2, BitmapFilterQuality.HIGH)];
            addEventListener(Event.ENTER_FRAME, loop);
        }
        
        private function setPercent(p: uint): void 
        {
            txt.text = "Now Loading... " + p + " %";
            txt.x = sizeW - txt.width >> 1;
        }
        
        private function loop(e: Event): void 
        {
            var g: Graphics = sp.graphics, ty: int = txt.y + txt.height + 2;
            g.clear();
            g.beginFill(0xE0E0E0);
            g.drawRect(0, 0, sizeW, sizeH);
            sp.x = stage.stageWidth  - sp.width  >> 1;
            sp.y = stage.stageHeight - sp.height >> 1;
            percent += Math.random() * 9 >> 3;
            var s: int = (sizeW - 10) * percent / 100;
            g.drawRect(sizeW - s >> 1, ty, s, 20);
            if (s > 11) 
            {
                g.beginFill(0xFFFFFF);
                g.drawRect(sizeW - s + 10 >> 1, ty + 5, s - 10, 10);
            }
            
            setPercent(percent);
            if (percent >= 99) 
            {
                setPercent(99);
                removeEventListener(Event.ENTER_FRAME, loop);
            }
        }
    }
}
