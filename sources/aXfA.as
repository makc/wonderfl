package {
    import com.bit101.components.RadioButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filters.BevelFilter;
    import flash.filters.BlurFilter;
    import flash.filters.GlowFilter;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.ui.Keyboard;
    
    [SWF(width=465, height=465, backgroundColor=0xFFFFFF, frameRate=60)]

    public class FlashTest extends Sprite {
        private var bmp:Bitmap;
        
        private var txt:TextField;
        private var goBtn:SimpleButton;
        private var btns:Sprite;
        private var dir0:DirSprite;
        private var dir1:DirSprite;
        private var dirNum:int;
        private var lastStr:String;
                
        public function FlashTest() {
            // write as3 code here..
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.addEventListener(Event.RESIZE, onResize);
            
            bmp = new Bitmap();
            addChild(bmp);
            dirNum = 0;
            lastStr = null;
            var str:String = "Wonderfl!";
            setText(str, bmp , dirNum);
            
            
            ////入力部///////
            btns = new Sprite();
            addChild(btns);
            btns.x = 5;
            btns.y = 5;
            txt = new TextField();
            txt.border = true;
            txt.width = 100;
            txt.height = 20;
            txt.background = true;
            txt.backgroundColor = 0xFFFFFF;
            txt.type = "input";
            txt.maxChars = 12;
            txt.text = str;
            btns.addChild(txt);
            
            var up:BtnState = new BtnState(0xFAFAFA);
            var over:BtnState = new BtnState(0xD0A000);
            var down:BtnState = new BtnState(0xD04000);
            goBtn = new SimpleButton(up, over, down, over);
            goBtn.x = 110; 
            goBtn.addEventListener(MouseEvent.CLICK, goBtnClick);
            btns.addChild(goBtn);
            
            dir0 = new DirSprite(0);
            dir0.x = 195;
            btns.addChild(dir0);
            dir1 = new DirSprite(1);
            dir1.x = 275;
            dir1.changeColor(0);
            btns.addChild(dir1);
            var radioBtn0:RadioButton = new RadioButton(btns, 180, 5, "           ", true, checkRadioBtn);
            radioBtn0.name = "r0";
            radioBtn0.filters = [new ColorMatrixFilter([1, 0, 0, 0, 20,  0, 1, 0, 0, 20,  0, 0, 1, 0, 20,  0, 0, 0, 1, 0])];
            var radioBtn1:RadioButton = new RadioButton(btns, 260, 5, "           ", false, checkRadioBtn);
            radioBtn1.name = "r1";
            radioBtn1.filters = [new ColorMatrixFilter([1, 0, 0, 0, 20,  0, 1, 0, 0, 20,  0, 0, 1, 0, 20,  0, 0, 0, 1, 0])];
            
            
            //enter Key
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            
            
            
            
            
            
        }
        
        private function onKeyDown(event:KeyboardEvent):void
        {
            if (event.keyCode == Keyboard.ENTER) {
                var str:String = txt.text;
                if (lastStr != str) {
                    lastStr = str;
                    setText(str, bmp, dirNum);
                }
            }
        }
        
        private function goBtnClick(e:MouseEvent):void
        {
                
            var str:String = txt.text;
            if (lastStr != str) {
                lastStr = str;
                setText(str, bmp, dirNum);
            }
        }
        
        private function setText(str:String, bmp:Bitmap, num:int):void
        {
            if (!str || str == "") return;
            var i:int;
            
            var sp:Shape = new Shape();
            var s_w:Number = stage.stageWidth;
            var s_h:Number = stage.stageWidth;
            var rot_m:Matrix = new Matrix();
            rot_m.createGradientBox(s_w, s_h/3, Math.PI / 2);
            with (sp) {
                graphics.clear();
                graphics.beginGradientFill("linear", [0xB0B0AA, 0xFFFFFF], [1, 0], [0, 255], rot_m);
                graphics.drawRect(0, 0, s_w, s_h/3);
                graphics.endFill();
            }
            
            var canvas:BitmapData =  new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
            canvas.draw(sp);
            
            var tf:TextField = new TextField();
            //addChild(tf);
            var fontSize:uint = stage.stageWidth / 5;
            var fmt:TextFormat = new TextFormat("_sans", fontSize, 0xffffff, true);// 7F7FFF, true); 
            tf.defaultTextFormat = fmt;
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.text = str;
            var w:Number = tf.width;
            var h:Number = tf.height;
            var len:Number = (w > h)?w:h;
            
            //tf.filters = [new GlowFilter(0x7f0000,1,2,2,3)];
            var txt0:BitmapData = new BitmapData(w, h, true, 0);// false, 0x0);
            txt0.draw(tf);
            var degree:Number = 45;
            var rad:Number = Math.PI * degree / 180;
            var dx:Number =    h * .8;// 回転した文字列を範囲内に収める
            var dy:Number = 0;// ((stage.stageHeight - h) / 2);
            if (num == 1) {
                degree = -45;
                rad = Math.PI * degree / 180;
                dx = 0;
                dy = w * .4;
            }
            var ipMatrix:Matrix = new Matrix();
            ipMatrix.rotate(rad);
            ipMatrix.scale(1, .5);
            ipMatrix.translate(dx, dy);
            //
            var txtSource:BitmapData =  new BitmapData(len + h, len + h, true, 0);
            txtSource.draw(txt0, ipMatrix, null, null, null, true);
            
            //
            var txtDataColumn:BitmapData = txtSource.clone();
            txtDataColumn.applyFilter(txtDataColumn, txtDataColumn.rect, new Point(0, 0), new BevelFilter(4,10, 0xFFFFFF,1,0xE0E0E0,1,1,1,1,1,"inner"));
            //txtDataColumn.applyFilter(txtDataColumn, txtDataColumn.rect, new Point(0, 0), new BlurFilter(2, 1, 1));
            
            //Shadow
            var txtDataShadow:BitmapData = txtSource.clone();
            var ctfShadow:ColorTransform = new ColorTransform(0, 0, 0);
            txtDataShadow.colorTransform(txtDataShadow.rect, ctfShadow);
            txtDataShadow.applyFilter(txtDataShadow, txtDataShadow.rect, new Point(0, 0), new BlurFilter(12,12,1));
            
            var m:Matrix = new Matrix();
            //stageの中央に描画する。(映りこみから描くので、やや下から描く)
            m.tx = (stage.stageWidth - w) / 2 +10;
            m.ty = ((stage.stageHeight - h) / 2) + 62;
            
            var s:int = 0;
            //reflection
            var maxRef:int = 30;
            var cftRef:ColorTransform = new ColorTransform();
            cftRef.alphaMultiplier = 0;
            cftRef.redOffset = -30;
            cftRef.blueOffset = -30;
            cftRef.greenOffset = -30;
            for (i = 0; i < 30; i++) {
                
                canvas.draw(txtDataColumn, m, cftRef);// , null, null, true);
                
                cftRef.alphaMultiplier += .01;
                m.ty--;
            }
            //shadow
            canvas.draw(txtDataShadow, m);// , cft);// , null, null, true);
            
            m.ty -= 2;
            
            
            //shade
            s = 0;
            var max:int = 30;
            var colorOffsets:Array = [-20,0,0,-20];
            var ratios:Array = [0, .6, .8, 1];
            var ctfShade:ColorTransform = new ColorTransform();
            var color_d:Number = 0;
            for (i = 0; i < 30; i++) {
                if (i >= ratios[s] * max) {
                    var p_from:int = ratios[s] * max;
                    var colorOffset_from:Number = colorOffsets[s];
                    s++;
                    var p_to:int = ratios[s] * max;
                    var colorOffset_to:Number = colorOffsets[s];
                    color_d = (colorOffset_to - colorOffset_from) / ( p_to - p_from);
                    
                    ctfShade.redOffset = colorOffset_from;
                    ctfShade.blueOffset = colorOffset_from;
                    ctfShade.greenOffset = colorOffset_from;
                    
                    
                }
                canvas.draw(txtDataColumn, m, ctfShade);// , null, null, true);
                
                ctfShade.redOffset += color_d;
                ctfShade.blueOffset += color_d;
                ctfShade.greenOffset += color_d;
                m.ty--;
            }
            //
            
            //face
            var cf:ColorTransform = new ColorTransform(1, .6, .2);
            txtSource.colorTransform(txtSource.rect, cf);
            txtSource.applyFilter(txtSource, txtSource.rect, new Point(0, 0), new GlowFilter(0x202020, 1, 2, 2, 2, 1));
            canvas.draw(txtSource, m,null,null,null,true);
                

            bmp.bitmapData = canvas;
            
        }
        
        private function onResize(event:Event):void
        {
            
            var str:String = txt.text;
            setText(str, bmp, dirNum);
        }
        
        private function checkRadioBtn(e:MouseEvent):void
        {
            var n:int = 0;
            if (e.currentTarget.name == "r0") {
                n = 0;
                dir0.changeColor(1);
                dir1.changeColor(0);
            }
            if (e.currentTarget.name == "r1") {
                n = 1;
                dir0.changeColor(0);
                dir1.changeColor(1);
            }
            
            dirNum = n;
            
            var str:String = txt.text;
            setText(str, bmp, dirNum);
            
            
            
        }
        
    }
}

import flash.display.Sprite;
import flash.text.TextField;
import flash.filters.GlowFilter;
import flash.text.TextFieldAutoSize;
class BtnState extends Sprite
{
    public function BtnState(color:uint)
    {
        //graphics.lineStyle(0, 0);
        graphics.clear();
        graphics.beginFill(0xFAFAFA);
        graphics.drawRoundRect(0, 0, 28, 20, 8, 8);
        graphics.endFill();
        
        this.filters = [new GlowFilter(color, 1,6,6,1,1,true), new GlowFilter(0, 1, 4, 4, 1)];
 
        var txt:TextField = new TextField();
        txt.text = "GO";
        txt.width = 28 - 1;
        txt.autoSize = TextFieldAutoSize.CENTER;
        txt.selectable = false;
        addChild(txt);
    }
}
import flash.text.TextFormat;
import flash.geom.Matrix;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.filters.BevelFilter;
class DirSprite extends Sprite
{
    public function DirSprite(dirType:int):void
    {
        var w:Number = 50;
        var h:Number = 25;
        graphics.clear();
        graphics.lineStyle(0, 0x808080);
        graphics.beginFill(0xFFFFFF);
        graphics.moveTo(0, h / 2);
        graphics.lineTo(w / 2, h);
        graphics.lineTo(w, h / 2);
        graphics.lineTo(w / 2, 0);
        graphics.lineTo(0, h / 2);
        graphics.endFill();
        this.filters = [new BevelFilter(1, 90, 0xFFFFFF, 0, 0, 1, 4, 4)];
        
        //'A'を向きにあわせて描く
        var tf:TextField = new TextField();
        tf.defaultTextFormat = new TextFormat("_sans", 24, 0x303030);
        tf.text = "A";
        var txt0:BitmapData = new BitmapData(w, h, true, 0);// false, 0x0);
        txt0.draw(tf);
        //右下へ
        var degree:Number = 45;
        var rad:Number = Math.PI * degree / 180;
        var dx:Number =   28;
        var dy:Number = 3;
        if (dirType == 1) {
            degree = -45;
            rad = Math.PI * degree / 180;
            dx = 7;
            dy = 9;
        }
        var ipMatrix:Matrix = new Matrix();
        ipMatrix.rotate(rad);
        ipMatrix.scale(1, .5);
        ipMatrix.translate(dx, dy);
        var txtSource:BitmapData =  new BitmapData(w, h, true, 0);
        txtSource.draw(txt0, ipMatrix, null, null, null, true);
        var bmp:Bitmap = new Bitmap(txtSource);
        addChild(bmp);
        
        
    }
    
    public function changeColor(n:int):void
    {
        if (n == 0) this.alpha = .5;
        if (n == 1) this.alpha = 1;
    }
}