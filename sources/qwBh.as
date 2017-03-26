package {
    
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.media.*;
    import flash.net.*;
    import flash.text.*;
    import flash.ui.*
    import flash.utils.*;
    
    /* @author dubfrog aka 'dubflash' /* 
    
    /* project [ MathGraphics SoundVisualizer ] 
     * 
     * サウンドビジュアライザーをPV風にしてみました。
     * 音の強弱を数字で視覚可し、0に近づくほど音が弱くなり、数字表記が小さくなります。
     * 
     * // forked from gaina's soundtest6
     * サウンドはgainaさんのところからお借りしてます
     * 
     * */ 
    [SWF(backgroundColor='0xffffff', width='465', height='465')]
    
    public class Main extends MovieClip
    {
        
        public function Main():void
        {
            details();
            
            if (stage) initialize();
            else addEventListener(Event.ADDED_TO_STAGE, initialize);
        }
        
        private function details():void 
        {
            zword     = "MathGraphics SoundVisualizer";
            bword     = "DFG";
            sdstr     = "http://www.takasumi-nagai.com/soundfiles/sound001.mp3";
            bitmax    = 255;
            spectrum  = new Vector.< Number >();
            cnt       = { a:0, b:0 };
        }
        private function initialize(e:Event = null):void
        {    
            setSound();
        }
        private function start():void
        {
            tyle = new Sprite();
            addChild(tyle);
            
            haul = new Sprite();
            haul.x = -50;
            haul.scaleX = haul.scaleY = 1.1;
            addChild(haul);
            
            dtSp = new Sprite();
            dtSp.x = 9999;
            addChild(dtSp);
            
            var ft:TextFormat = new TextFormat();
            ft.size = 36;
            ft.color = 0xffffff;
            dt = new TextField();
            dt.selectable = false;
            dt.autoSize = TextFieldAutoSize.LEFT;
            dt.wordWrap = false;
            dtSp.addChild(dt);
            
            title = new Sprite();
            title.graphics.beginFill(0x000000, 1);
            title.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            title.graphics.endFill();
            addChild(title);
            zdt = new TextField();
            zdt.defaultTextFormat = ft;
            zdt.selectable = false;
            zdt.autoSize = TextFieldAutoSize.LEFT;
            zdt.text = zword;
            zdt.x = stage.stageWidth / 2 - zdt.width / 2;
            zdt.y = stage.stageHeight / 2 - zdt.height / 2;
            title.addChild(zdt);
            title.visible = false;
            
            var _temp:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false);
            _temp.draw(tyle);
            overhaul = new BitmapRgbOverhaul(_temp);
            
            Wonderfl.capture_delay(30);
            callTimer();
        }
        private function callTimer():void
        {
            timer = new Timer(Math.random() * 500, 1);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, addLine);
            timer.start();
        }
        private function removeTimer():void
        {
            if (timer)
            {
                timer.stop();
                timer.removeEventListener(TimerEvent.TIMER_COMPLETE, addLine);
                timer = null;
            }
        }
        private function addLine(e:TimerEvent):void
        {
            var mc:line = new line();
            mc.x = -100;
            addChild(mc);
            
            moveLine(mc);
            
            removeTimer();
            callTimer();
        }
        private function moveLine(target:Sprite):void
        {
            var gx:Number = Math.random() * stage.stageWidth;
            var spd:Number = .2;
            var cnt:Number = 0;
            target.addEventListener(Event.ENTER_FRAME, function(e:Event):void
            {
                e.target.x += (gx - e.target.x ) * spd;
                e.target.alpha += (0 - e.target.alpha ) * spd;
                cnt++;
                if (cnt >= 50)
                {
                    e.target.removeEventListener(Event.ENTER_FRAME, arguments.callee);
                    e.target.parent.removeChild(e.target);
                }
            });
        }
        private function setSound():void
        {
            var context:SoundLoaderContext = new SoundLoaderContext(10, true);
            var req:URLRequest = new URLRequest(sdstr);
            track = new Sound(req, context);
            track.addEventListener(Event.COMPLETE, function(e:Event):void
            {
                start();
                channel = track.play(0, 9999);
                addEventListener(Event.ENTER_FRAME, update);
            });
        }
        private function titleMotion():void
        {
            title.visible = true;
            
            var blur:BlurFilter = new BlurFilter(Math.random() * 10 + 1, Math.random() * 10 + 1, 1);
            title.x = Math.random() * 1 + ( stage.stageWidth / 2 - title.width / 2);
            title.scaleX = title.scaleY = Math.random() * .01 + 1;
            title.filters = [blur];
            
            var bmp:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false);
            var grad:Sprite = new Sprite();
            grad.graphics.beginGradientFill(GradientType.LINEAR,
                                            [0x000000, 0xffffff], 
                                            [1, 1],
                                            [55, 255],
                                            null, 
                                            SpreadMethod.PAD,
                                            InterpolationMethod.RGB, 0);
            grad.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            grad.graphics.endFill();
            bmp.draw(grad);
            var r:Number = Math.floor(Math.random() * 2);
            var plus:Number = Math.floor(Math.random() * 100) - 25;
            if (r == 0)
            {
                cnt.a += plus;
                cnt.b = 0;
            }else if (r == 1) {
                cnt.b += plus;
                cnt.a = 0;
            }
            var dmf:DisplacementMapFilter = new DisplacementMapFilter(bmp, 
                                                                      new Point(), 
                                                                      BitmapDataChannel.BLUE, 
                                                                      BitmapDataChannel.BLUE, 
                                                                      cnt.a, 
                                                                      cnt.b, 
                                                                      DisplacementMapFilterMode.WRAP);
            title.filters = [dmf, blur];
            
            if (r == 0) cnt.b = cnt.a;
            else if (r == 1) cnt.a = cnt.b;
        }
        private function update(e:Event):void
        {
            var bytes:ByteArray = new ByteArray();
            SoundMixer.computeSpectrum(bytes, true, 0);
            
            var total:Number = 0;
            for (var i:uint = 0; i <= bitmax - 1; i++) 
            {
                spectrum[i] = bytes.readFloat();
                total += Math.floor(spectrum[i] * 10);
            }
            
            var p:Number, bw:Number, bh:Number;
            
            p = Math.floor(total);
            dt.scaleX = dt.scaleY = p / 10;
            
            title.visible = false;
            if (p > 50 && p < 200) dt.text = String(p);
            else if (p == 0) titleMotion();
            else dt.text = bword;
            
            if (dt.width >= 1) bw = dt.width;
            else bw = dt.width = 1;
            if (dt.height >= 1) bh = dt.height;
            else bh = dt.height = 1;
            
            var matrix:Matrix = new Matrix();
            if (p % 2 == 0) matrix.rotate(Math.PI / 180 * p);
            var bmp:BitmapData = new BitmapData(bw, bh, true, 0x808080);
            bmp.draw(dtSp);
            
            tyle.visible = false;
            tyle.graphics.clear();
            tyle.graphics.beginBitmapFill(bmp, matrix, true, false);
            tyle.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            tyle.graphics.endFill();
            
            
            var _temp:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false);
            _temp.draw(tyle);
            overhaul.reDraw(_temp);
            
            if (haul.numChildren > 0) 
            {
                for (var n:Number; n <= haul.numChildren - 1; n++)
                {
                    haul.removeChildAt(n);
                }
            }
            
            haul.addChild(overhaul.blackObj);
            haul.addChild(overhaul.rbmpObj);
            haul.addChild(overhaul.gbmpObj);
            haul.addChild(overhaul.bbmpObj);
            
            overhaul.rbmpObj.x = 0;
            overhaul.gbmpObj.x = Math.random() * 5;
            overhaul.bbmpObj.x = Math.random() * 10;
        }
        private function stageDetail():void
        {
            var context:ContextMenu = new ContextMenu();
            context.hideBuiltInItems();
            MovieClip(this.root).contextMenu      = context;
            stage.frameRate                       = 60;
            stage.quality                         = StageQuality.MEDIUM;
            stage.align                           = StageAlign.TOP_LEFT;
            stage.scaleMode                       = StageScaleMode.NO_SCALE;
        }
        
        
        /*_Vars______________________________________________________________________________________*/
        
        private var track:Sound;
        private var channel:SoundChannel;
        private var spectrum:Vector.<Number>;
        private var bitmax:Number;
        private var dt:TextField, zdt:TextField;
        private var sdstr:String, bword:String, zword:String;
        private var tyle:Sprite, dtSp:Sprite, haul:Sprite, title:Sprite;
        private var overhaul:BitmapRgbOverhaul;
        private var cnt:Object;
        private var timer:Timer;
    }
}


import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.filters.*;

/* project : [ RGB分解 ] */

class BitmapRgbOverhaul 
{
    
    private var rbmd:BitmapData;
    private var gbmd:BitmapData;
    private var bbmd:BitmapData;
    
    public var rbmpObj:Bitmap;
    public var gbmpObj:Bitmap;
    public var bbmpObj:Bitmap;
    public var blackObj:Bitmap;
    
    public function BitmapRgbOverhaul(sourceBmp:BitmapData) {
        
        rbmd = new BitmapData(sourceBmp.width, sourceBmp.height, true, 0x808080);
        gbmd = new BitmapData(sourceBmp.width, sourceBmp.height, true, 0x808080);
        bbmd = new BitmapData(sourceBmp.width, sourceBmp.height, true, 0x808080);
        rbmd.fillRect( sourceBmp.rect, 0xFF000000 );
        gbmd.fillRect( sourceBmp.rect, 0xFF000000 );
        bbmd.fillRect( sourceBmp.rect, 0xFF000000 );
        rbmd.copyChannel(sourceBmp, sourceBmp.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.RED);
        gbmd.copyChannel(sourceBmp, sourceBmp.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
        bbmd.copyChannel(sourceBmp, sourceBmp.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
        rbmpObj = new Bitmap(rbmd);
        gbmpObj = new Bitmap(gbmd);
        bbmpObj = new Bitmap(bbmd);
        rbmpObj.blendMode = BlendMode.ADD;
        gbmpObj.blendMode = BlendMode.ADD;
        bbmpObj.blendMode = BlendMode.ADD;
        
        var blackbmp:BitmapData = new BitmapData(sourceBmp.width, sourceBmp.height, false, 0x000000);
        blackObj = new Bitmap(blackbmp);
    }
    public function reDraw(sourceBmp:BitmapData):void
    {
        rbmd = new BitmapData(sourceBmp.width, sourceBmp.height, true, 0x808080);
        gbmd = new BitmapData(sourceBmp.width, sourceBmp.height, true, 0x808080);
        bbmd = new BitmapData(sourceBmp.width, sourceBmp.height, true, 0x808080);
        rbmd.fillRect( sourceBmp.rect, 0xFF000000 );
        gbmd.fillRect( sourceBmp.rect, 0xFF000000 );
        bbmd.fillRect( sourceBmp.rect, 0xFF000000 );
        rbmd.copyChannel(sourceBmp, sourceBmp.rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.RED);
        gbmd.copyChannel(sourceBmp, sourceBmp.rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
        bbmd.copyChannel(sourceBmp, sourceBmp.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
        
        rbmpObj.bitmapData = rbmd;
        gbmpObj.bitmapData = gbmd;
        bbmpObj.bitmapData = bbmd;
    }
}

class line extends Sprite
{
    public function line():void
    {
        graphics.lineStyle(Math.floor(Math.random() * 3), 0x000000, 1);
        graphics.moveTo(0, 0)
        graphics.lineTo(0, 500);
        var blur:BlurFilter = new BlurFilter(Math.random() * 10, Math.random() * 10, 1);
        //filters = [blur];
        alpha = Math.random() * .9 + .1;
    }
}