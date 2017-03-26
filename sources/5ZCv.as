/**
* Dancing Dobuemon
* 
* 以前作った ↓ にメッシュアニメーションをつけてみた。
* http://wonderfl.net/c/dTAt
* せっかくなので音に合わせてダンスさせてみた。（ダンスというよりただの顔芸。）
* 
* 音は以下より拝借
* http://mutast.heteml.jp/works/music/music.mp3
* 
* ビート検知は以下を参考に、てかそのまま使わせていただきました。あたーす。
* http://wonderfl.net/c/dttt
* 
* @author Masayuki Daijima (ARCHETYP Inc.)
* http://www.daijima.jp/
* http://twitter.com/daijimachine
*/

package
{
    import away3dlite.animators.MovieMesh;
    import away3dlite.events.Loader3DEvent;
    import away3dlite.loaders.Loader3D;
    import away3dlite.loaders.MD2;
    import away3dlite.materials.BitmapMaterial;
    import away3dlite.templates.FastTemplate;
    import com.bit101.components.ProgressBar;
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
    import flash.system.Security;
    import flash.utils.ByteArray;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Quad;
    import org.libspark.betweenas3.tweens.ITween;
    
    [SWF(backgroundColor = "#000000", frameRate = "30", width = "465", height = "465")]
    
    public class Document extends FastTemplate
    {
        private const BMP_PATH:String = "http://www.daijima.jp/materials/wonderfl/dobuemon/modeldata/dobuemon.png";
        private const MD2_PATH:String = "http://www.daijima.jp/materials/wonderfl/dobuemon/modeldata/dobuemon2.md2";
        private const MP3_PATH:String = "http://www.daijima.jp/materials/sound/music.mp3";
        
        private var _loader:Loader3D;
        private var _snd:Sound;
        private var _model:MovieMesh;
        
        private var _cameraX:Number;
        private var _cameraY:Number;
        
        private var _texure_loader:Loader;
        
        private var _p_bar:ProgressBar;
        private var _loadPercent:Number = 0;
        private var _tw:ITween;
        
        override protected function onInit():void
        {
            debug = false;
            
            Security.loadPolicyFile("http://www.daijima.jp/crossdomain.xml");
            setProgressBar();
            
            _texure_loader = new Loader();
            _texure_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadTexture);
            _texure_loader.load(new URLRequest(BMP_PATH));
        }
        
        private function setProgressBar():void
        {
            _p_bar = new ProgressBar(this, 182, 232);
            addEventListener(Event.ENTER_FRAME, function(event:Event):void 
            {
                _p_bar.value += (_loadPercent - _p_bar.value) * .5;
                
                if (_p_bar.value > .99) {
                    _p_bar.value = 1;
                    event.target.removeEventListener(event.type, arguments.callee);
                    
                    _tw = BetweenAS3.serial(
                        BetweenAS3.to(_p_bar, { alpha:0 }, .3, Quad.easeOut), 
                        BetweenAS3.removeFromParent(_p_bar)
                    );
                    _tw.play();
                }
            });
        }
        
        private function onLoadTexture(event:Event):void 
        {
            event.target.removeEventListener(event.type, arguments.callee);
            
            var bmp:Bitmap = _texure_loader.content as Bitmap;
            var material:BitmapMaterial = new BitmapMaterial(bmp.bitmapData);
            
            var md2:MD2 = new MD2();
            md2.material = material;
            md2.scaling = 30;
            scene.rotationX = 30;
            scene.rotationY = 90;
            scene.rotationZ = -60;
            _loader = new Loader3D(); 
            _loader.loadGeometry(MD2_PATH, md2);
            _loader.addEventListener(Loader3DEvent.LOAD_PROGRESS, onLoadProgress);
            _loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onLoadSuccess);
            view.scene.addChild(_loader);
        }
        
        private function onLoadProgress(event:Loader3DEvent):void 
        {
            _loadPercent = event.target.bytesLoaded / event.target.bytesTotal * .5;
        }
        
        private function onLoadSuccess(event:Loader3DEvent):void
        {
            event.target.removeEventListener(event.type, arguments.callee);
            
            _model = event.loader.handle as MovieMesh;
            setSound();
        }
        
        private function setSound():void
        {
            _snd = new Sound();
            _snd.load(new URLRequest(MP3_PATH));
            _snd.addEventListener(ProgressEvent.PROGRESS, onProgressSound);
            _snd.addEventListener(Event.COMPLETE, onLoadSound);
        }
        
        private function onProgressSound(event:ProgressEvent):void 
        {
            _loadPercent = .5 + (event.bytesLoaded / event.bytesTotal * .5);
        }
        
        private function onLoadSound(event:Event):void 
        {
            event.target.removeEventListener(event.type, arguments.callee);
            startDance();
        }
        
        private function startDance():void
        {
            var channel:SoundChannel = new SoundChannel();
            channel = _snd.play(0, 65535);
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        private function update(event:Event):void 
        {
            var bytes:ByteArray = new ByteArray();
            SoundMixer.computeSpectrum(bytes, false, 0);
            bytes.position = 0;
            var rf:Number;
            var count:int = 0;
            for (var q:int = 0; bytes.bytesAvailable >= 4; q++) {
                rf = bytes.readFloat();
                var t:Number = Math.abs(rf);
                if (t >= 0.4 && q >256) count ++;
                if (count >= 120) dancing();
            }
            
            camera.x += (_cameraX - camera.x) * .3;
            camera.y += (_cameraY - camera.y) * .3;
            camera.lookAt(scene.position);
        }
        
        private function dancing():void
        {
            express();
            _cameraX = Math.random() * 1200 - 600;
            _cameraY = Math.random() * 1200 - 600;
        }
        
        private function express():void 
        {
            var rand:int = Math.floor(Math.random() * 4);
            if (rand == 0) _model.play("ononoki");
            else if (rand == 1) _model.play("shitari");
            else if (rand == 2) _model.play("inoki");
            else _model.play("hokusoemi");
        }
        
        override protected function onPreRender():void
        {
            view.render();
        }
    }
}