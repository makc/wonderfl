package {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.ColorTransform;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundLoaderContext;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;

    [SWF(backgroundColor="#FFFFFF", frameRate="60", width="465", height="465")]
    
     /**
     * @author Takashi Murai (KAYAC)
     */
     
     /*
     * Free Music Archive: Digi G'Alessio - ekiti son feat valeska - april deegee rmx 
     * http://creativecommons.org/licenses/by-nc-nd/3.0/
     */

    public class TrippyAtractor extends Sprite {


        private const N:uint = 10000;
        
        private var _a:Number;
        private var _b:Number;
        private var _c:Number;
        private var _d:Number;
        
        private var _va:Number = 1.0;
        private var _vb:Number = 1.0;
        private var _vc:Number = 1.0;
        private var _vd:Number = 1.0;
        
        private var _head:Particle;
        
        private var _canvas:BitmapData;
        private var _w:uint;
        private var _h:uint;
        
        private var snd:Sound;
        private var FFTswitch:Boolean = true;
        private var count:int;
        private var vol:Number;
        private var bmp:Bitmap;
        private var hex:uint=0x0;
        
        private var _trans:ColorTransform = new ColorTransform(1, 1, 1, 1, 0x4F, 0x4F, 0x4F);
        private var bytes:ByteArray;
        
        function TrippyAtractor() {
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.LOW;
            
            _w = 600;
            _h = 600;
                
            
            play("http://level0.kayac.com/images/murai/Digi_GAlessio_-_08_-_ekiti_son_feat_valeska_-_april_deegee_rmx.mp3");
            
            
            count = 0;
            
            /////
            
            var o:Particle = _head = new Particle();
            for (var i:uint = 0; i < N; ++i) {
                o = o.next = new Particle();
            }
            
            _canvas = new BitmapData(_w, _h, false, 0xffffff);
            bytes = new ByteArray();
            
            addChild(bmp = new Bitmap(_canvas));
            
            addEventListener(Event.ENTER_FRAME, _update);
            addEventListener(Event.ENTER_FRAME, render);
            stage.addEventListener(Event.RESIZE, resize);
            
            resize();
        }
        
        private function resize(e:Event = null) : void {
            bmp.x = stage.stageWidth / 2 - bmp.width / 2;
            bmp.y = stage.stageHeight / 2 - bmp.height / 2;
        }
        
        private function _reset():void {
            
            _a = (Math.random() - 0.5) * 3;
            _b = (Math.random() - 0.5) * 3;
            _c = (Math.random() - 0.5) * 6;
            _d = (Math.random() - 0.5) * 6;
            if (Math.abs(_a) < 0.8) _a += 0.8 * _a / Math.abs(_a);
            if (Math.abs(_b) < 0.8) _b += 0.8 * _b / Math.abs(_b);
            if (Math.abs(_c) < 1.0) _c += 1.0 * _c / Math.abs(_c);
            if (Math.abs(_d) < 1.0) _d += 1.0 * _d / Math.abs(_d);
            
            var p:Particle = _head;
            do {
                p.x0 = (Math.random() - 0.5) * 2;
                p.y0 = (Math.random() - 0.5) * 2;
            }
            while (p = p.next);
        }
        
        private function _update(e:Event):void {
            _canvas.lock();
            
            _canvas.colorTransform(_canvas.rect, _trans);
            var p:Particle = _head;
            do {
                p.x1 = Math.sin(_a * p.y0) + _c * Math.cos(_a * p.x0) + Math.random() * 0.001;
                p.y1 = Math.sin(_b * p.x0) + _d * Math.cos(_b * p.y0) + Math.random() * 0.001;
                p.x0 = p.x1;
                p.y0 = p.y1;

                _canvas.setPixel(_w / 2 + p.x1 * 70, _h / 2 + p.y1 * 70, hex);
            }
            while (p = p.next);

            _canvas.unlock();
            
            if (_a < -3.0) _va = 1.0; else if (_a > 3.0) _va = -1.0;
            if (_b < -3.0) _vb = 1.0; else if (_b > 3.0) _vb = -1.0;
            if (_c < -3.0) _vc = 1.0; else if (_c > 3.0) _vc = -1.0;
            if (_d < -3.0) _vd = 1.0; else if (_d > 3.0) _vd = -1.0;
            _a += _va * 0.002;
            _b += _vb * 0.004;
            _c += _vc * 0.008;
            _d += _vd * 0.010;
        }

        private function change():void {
            hex = [0x000000,0x333333,0xff358b,0x01b0f0,0xaeee00][count++ % 5];//A
            _reset();
        }

        private function play(sndUrl:String):void {
            snd = new Sound();
            var context:SoundLoaderContext = new SoundLoaderContext(10, true);
            var req:URLRequest = new URLRequest(sndUrl);
            snd.load(req, context);
            var sndChannel:SoundChannel = new SoundChannel();
            sndChannel = snd.play(0, 0);
        }

        private function render(e:Event):void {
            bytes.clear();
            SoundMixer.computeSpectrum(bytes, FFTswitch, 0);
            vol = bytes.readFloat();
            if(vol > 1)change();//A

            for (var i:int = 0; i < 100; i++) {
                vol = bytes.readFloat();
            }
        }

    }
}


internal class Particle {
    public var x1:Number;
    public var y1:Number;
    public var x0:Number;
    public var y0:Number;
    public var next:Particle;
}
