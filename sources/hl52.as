package  
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    /**
     * spiral
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0x000000", frameRate = "30", width = "465", height = "465")]
    public class Test54 extends Sprite 
    {
        private var bmd: BitmapData;
        private var colorTf: ColorTransform;
        private var drawMtarix: Matrix;
        private var texts: Array = [];
        private var textField: TextField;
        private var cnt: int;
        
        public function Test54() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(event: Event = null): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            //
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            addChild(new Bitmap(bmd = new BitmapData(465, 465, true, 0), "auto", true));
            textField = new TextField();
            textField.autoSize = TextFieldAutoSize.LEFT;
            textField.defaultTextFormat = new TextFormat("_sans", 40, 0xFFFFFF);
            colorTf = new ColorTransform(0.98, 0.98, 1, 1, -1, -1, -1);
            drawMtarix = new Matrix();
            
            var i: uint, n: uint = 10;
            for (i = 0; i < n; i++) 
            {
                texts[i] = new Text();
                textField.text = String.fromCharCode(Math.random() * 26 + 65 + (Math.random() < 0.5 ? 0 : 32));
                texts[i].init(textField,  i / n * 400 + 32, Math.random() * 232 + 232, (Math.random() - 0.5) * 0.05 );
            }
            texts.sortOn("y", Array.NUMERIC);
            addEventListener(Event.ENTER_FRAME, loop);
            
        }
        
        private function loop(event:Event):void 
        {
            bmd.lock();
            var i: uint, n: uint = texts.length;
            for (i = 0; i < n; i++) 
            {
                drawMtarix.a = drawMtarix.d = 1;
                drawMtarix.b = drawMtarix.c = drawMtarix.tx = drawMtarix.ty = 0;
                var t: Text = texts[i];
                drawMtarix.translate(- t.w / 2, - t.h / 2);
                drawMtarix.rotate(t.rad);
                drawMtarix.scale(1, 0.7);
                drawMtarix.translate(t.x, t.y);
                t.y -= 0.5, t.rad += t.vr;
                bmd.draw(t.bmd, drawMtarix, null, null, null, true);
                if (t.y < -20)
                {
                    textField.text = String.fromCharCode(Math.random() * 26 + 65 + (Math.random() < 0.5 ? 0 : 32));
                    t.init(textField, Math.random() * 465, Math.random() * 100 + 365, (Math.random() - 0.5) * 0.05 );
                }
            }
            bmd.colorTransform(bmd.rect, colorTf);
            bmd.unlock();
        }
        
    }
}
import flash.display.BitmapData;
import flash.filters.DropShadowFilter;
import flash.geom.Matrix;
import flash.text.TextField;
class Text
{
    public var x: Number = 0, y: Number = 0;
    public var w: Number = 0, h: Number = 0;
    public var rad: Number = 0, vr: Number = 0;
    public var bmd: BitmapData;
    private static const effect: DropShadowFilter = new DropShadowFilter(0, 45, 0x00FFFF, 1, 2, 2, 100);
    function Text() { }
    
    public function init(textField: TextField, x: Number, y: Number, vr: Number): void 
    {
        this.x = x, this.y = y, this.vr = vr;
        w = textField.width * 1.5, h = textField.height * 1.5;
        if (bmd) bmd.dispose();
        bmd = new BitmapData(w, h, true, 0);
        bmd.lock();
        bmd.draw(textField, new Matrix(1, 0, 0, 1, (w - textField.width) / 2, (h - textField.height) / 2));
        bmd.applyFilter(bmd, bmd.rect, bmd.rect.topLeft, effect);
    }
}