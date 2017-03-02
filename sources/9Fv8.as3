package {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;
    import flash.geom.*;
    import flash.filters.*;
    import flash.text.*;
    import flash.system.*;
    import flash.media.*;
    [SWF(width=465,height=465,backgroundColor=0x000000,frameRate=60)]
    public class electrixion extends Sprite {
        private var STAGE_W:Number = stage.stageWidth;
        private var STAGE_H:Number = stage.stageHeight;
        private var bmpd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true,0xFFCC00);
        private var bmp:Bitmap = new Bitmap(bmpd);
        private var byteArray:ByteArray = new ByteArray();
        private var sound:Sound = new Sound();
        private var channel:SoundChannel;
        private var line:MovieClip = new MovieClip();
        private var blurEffect:BlurFilter = new BlurFilter(2,2,1);
        private var txt:TextField = new TextField(); 
        private var txtMatrix:Matrix;
        private var bmpdMatrix:Matrix = new Matrix();
        private var bmpdColor:ColorTransform = new ColorTransform(0.9,0.7,1,0.99);
        private var stable:Boolean = false;
        public function electrixion() {
            addChild(new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x0)));
            bmpd = new BitmapData(STAGE_W,STAGE_H,true,0xFFCC00);
            bmp = new Bitmap(bmpd);
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(STAGE_W,STAGE_H,0,0,0);
            var oval:Sprite = new MovieClip();
            oval.graphics.beginGradientFill(GradientType.RADIAL,[0x0,0x0],[1,0],[0,255],matrix);
            oval.graphics.drawEllipse(0,0,STAGE_W,STAGE_H);
            oval.graphics.endFill();
            oval.cacheAsBitmap = bmp.cacheAsBitmap = true;
            bmp.mask = oval;
            addChild(bmp);
            addChild(oval);
            line.filters = [new GlowFilter(0xFF0000,0.5,10,10,3,3)];
            sound.addEventListener(Event.ID3, id3Handler);
            sound.load(new URLRequest("http://level0.kayac.com/images/murai/Digi_GAlessio_-_06_-_darix_togni.mp3"), new SoundLoaderContext(10, true));
            channel = sound.play(0, 9999);
            stage.addEventListener(MouseEvent.CLICK, change);
            stage.addEventListener(Event.ENTER_FRAME, processing);
        }
        private function processing(e:Event):void {
            var i:int;
            line.graphics.clear();
            SoundMixer.computeSpectrum(byteArray, false, 0);
            var detectSound:int = 512;
            var w:Number = STAGE_W/detectSound;
            var t:Number;
            var n:Number;
            var byteTotal:Number = 0;
            var ratio:Number;
            var offset:Number;
            t = byteArray.readFloat();
            byteTotal += t;
            line.graphics.moveTo(0, STAGE_H/2);
            for(i=1; i<detectSound; i++) {
                t = byteArray.readFloat();
                byteTotal += t;
                if(i%8==0) {
                    ratio = (i<detectSound/2)?(i/(detectSound/2)):((detectSound-(i+16))/(detectSound/2));
                    n = (t * 30 * ratio);
                    line.graphics.lineStyle(ratio*1.5,0xFFFFFF);
                    line.graphics.lineTo(i*w,STAGE_H/2+n);
                }
            }
            line.graphics.endFill();
            var per:Number = byteTotal/detectSound;
            byteTotal*=0.8/detectSound;
            if(stable) byteTotal=0.1+byteTotal*0.3/detectSound;
            offset = -STAGE_W*(byteTotal)/2
            bmpdMatrix.identity();
            bmpdMatrix.scale(1+byteTotal,1+byteTotal);
            if(stable)
                bmpdMatrix.tx = bmpdMatrix.ty = offset;
            else {
                bmpdMatrix.tx = Math.cos((per+Math.random())*Math.PI*2)*offset;
                bmpdMatrix.ty = Math.sin((per+Math.random())*Math.PI*2)*offset;
            }
            var bmpdClone:BitmapData = bmpd.clone();
            bmpd.fillRect(bmpd.rect,0xFFFFFF);
            bmpd.draw(bmpdClone,bmpdMatrix,bmpdColor);
            bmpd.draw(line);
            if(!stable) bmpd.draw(txt, txtMatrix);
            bmpd.applyFilter(bmpd, bmpd.rect, new Point, blurEffect);
        }
        private function id3Handler(e:Event):void {
            txt.autoSize = "left"; var tf:TextFormat = new TextFormat(null,18,0xFFFF99); tf.align = "center";
            txt.defaultTextFormat = tf; txt.text = sound.id3.songName+"\n"+sound.id3.artist;
            txtMatrix = new Matrix(); txtMatrix.translate((STAGE_W-txt.width)/2, (STAGE_H-txt.height)/2);
        }
        private function change(e:MouseEvent):void { stable = !stable;}
    }
}