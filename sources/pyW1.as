// forked from Ctrl's forked from: forked from: forked from: forked from: forked from: forked from: forked from: forked from: Dancing Dobuemon
// forked from Ctrl's forked from: forked from: forked from: forked from: forked from: forked from: forked from: Dancing Dobuemon
// forked from Ctrl's forked from: forked from: forked from: forked from: forked from: forked from: Dancing Dobuemon
// forked from Ctrl's forked from: forked from: forked from: forked from: forked from: Dancing Dobuemon
// forked from Ctrl's forked from: forked from: forked from: forked from: Dancing Dobuemon
// forked from Ctrl's forked from: forked from: forked from: Dancing Dobuemon
// forked from Ctrl's forked from: forked from: Dancing Dobuemon
// forked from Ctrl's forked from: Dancing Dobuemon
// forked from daijimachine's Dancing Dobuemon
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
    import away3dlite.events.*;
    import away3dlite.loaders.Loader3D;
    import away3dlite.loaders.MD2;
    import away3dlite.materials.BitmapMaterial;
    import away3dlite.templates.FastTemplate;
    import com.bit101.components.ProgressBar;
    import flash.display.*;
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
        private const BMP_PATH:String = "http://ctrlcodes.com.ar/wonderfl/assets/65465/stelarc2.jpg";
        //private const BMP_PATH:String = "http://www.daijima.jp/materials/wonderfl/dobuemon/modeldata/dobuemon.png";
        private const MD2_PATH:String = "http://ctrlcodes.com.ar/wonderfl/assets/65465/dobuemon2.md2";
        private const MP3_PATH:String = "http://ctrlcodes.com.ar/wonderfl/assets/65465/435.mp3";
                                
        private var _loader:Loader3D;
        private var _snd:Sound;
        private var _model:MovieMesh;
        
        private var _cameraX:Number;
        private var _cameraY:Number;
        
        private var _texure_loader:Loader;
        
        private var _p_bar:ProgressBar;
        private var _loadPercent:Number = 0;
        private var _tw:ITween;
        
        private var md2:MD2;
        private var num:Number = 0;
        private var act:String = "fuck";
        private var actCount:Number = 0;
        
        private var doc:Document2;
        
        override protected function onInit():void
        {
            //stage.quality = StageQuality.LOW;
            debug = false;
            Security.loadPolicyFile("http://www.daijima.jp/crossdomain.xml");
            Security.loadPolicyFile("http://ctrlcodes.com.ar/crossdomain.xml");
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
            
            md2 = new MD2();
            md2.material = material;
            md2.scaling = 20;
            scene.rotationX = 30;
            scene.rotationY = 90;
            scene.rotationZ = -60;
            _loader = new Loader3D(); 
            _loader.loadGeometry(MD2_PATH, md2);
            _loader.addEventListener(Loader3DEvent.LOAD_PROGRESS, onLoadProgress);
            _loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onLoadSuccess);
            view.scene.addChild(_loader);
            
            doc = new Document2();
            addChildAt(doc, 0);
            
            doc.visible = false;
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
            
            var varA:Number;
            var varB:Number;
                        
            num -= 30;     
            ++ actCount;
            
            if(actCount == 300)
            {
               act = "one";
            }     
            else if(actCount == 480)
            {
               act = "two";
            } 
            else if(actCount == 590)
            {
               act = "three";
            }
            else if(actCount == 990)
            {
               act = "four";
            }    
            
            switch(act)
            {
                 case "one":
                 
                   if(num > -600)
                    {
                        this.x = num;
                        varA = 1.9;
                        varB = .3;                       
                    }
                    else
                    {
                        num = 600;
                    }
                    break;
                    
                  case "two":  
                    varA = .3;
                    varB = 2;
                    scene.z = -800;         
                    this.x = 0;
                    doc.visible = true;
                    break;
                    
                  case "three":  
                    varA = 1.9;
                    varB = 1.4;
                    scene.z = 300;
                    break;
                    
                  case "four":  
                    varA = .7;
                    varB = 1.8;
                    scene.z = -500;
                    break;
            }
            
            camera.x += (_cameraX - camera.x) * varA;
            camera.y += (_cameraY - camera.y) * varB;
            camera.lookAt(scene.position);
        }
        
        private function dancing():void
        {
            express();
            _cameraX = Math.random() * 2100 - 666;
            _cameraY = Math.random() * 200 - 200;
        }
        
        private function express():void 
        {
            var rand:int = Math.floor(Math.random() * 3);
            if (rand == 0) _model.play("ononoki");
            else if (rand == 1) _model.play("shitari");
            else if (rand == 2) _model.play("inoki");
            else _model.play("hokusoemi");
            
            //_model.play("inoki");
        }
        
        override protected function onPreRender():void
        {
            view.render();
        }
    }
}


/**
* Dobuemon Tunnel
* 
* AAway3D4.0の開発が絶賛進んでるけど、
* FlashPlayer10対応のAway3D3.6を一足遅れていじってみた。
* 
* 日本有数の心霊スポット、その名はドブえもんトンネル。
* ずーーーっと見てると気分を悪くする場合がありますので
* くれぐれもご注意ください。
* 当方では責任を負いかねます。
* 
* @author Masayuki Daijima (ARCHETYP Inc.)
* http://www.daijima.jp/
* http://twitter.com/daijimachine
*/

    import away3d.cameras.Camera3D;
    import away3d.containers.Scene3D;
    import away3d.containers.View3D;
    import away3d.core.base.Vertex;
    import away3d.core.filter.FogFilter;
    import away3d.core.render.BasicRenderer;
    import away3d.materials.ColorMaterial;
    import away3d.materials.TransformBitmapMaterial;
    import away3d.primitives.Cylinder;
    import com.bit101.components.ProgressBar;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.system.Security;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.net.URLRequest;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Quad;
    import org.libspark.betweenas3.tweens.ITween;
    
    class Document2 extends Sprite 
    {
        private const IMG_URL:String = "http://ctrlcodes.com.ar/r.jpg";
        
        private const D2R:Number = Math.PI / 180;
        
        private var _loadPercent:Number = 0;
        private var _dobuemon:Loader;
                
        private var _scene:Scene3D;
        private var _camera:Camera3D;
        private var _view:View3D;
        private var _cylinder:*;
        private var _cylinder2:*;
        private var _bitmapMaterial:TransformBitmapMaterial;
        
        private var _weights:Array;
        private var _angle:int;
        private var _mtx1:Matrix3D;
        private var _mtx2:Matrix3D;
        private var _vec:Vector3D;
        
        public function Document2() 
        { 
            Security.loadPolicyFile("http://www.daijima.jp/crossdomain.xml");
            
            loadDobuemon();
        }
        
        private function loadDobuemon():void
        {
            _dobuemon = new Loader();
            var req:URLRequest = new URLRequest(IMG_URL);
            _dobuemon.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
            _dobuemon.load(req);
            
            setProgressBar();

        }
        private function loadProgress(event:ProgressEvent):void
        {
            _loadPercent = event.target.bytesLoaded / event.target.bytesTotal;
        }        
        
        private function setProgressBar():void
        {
            var p_bar:ProgressBar = new ProgressBar(this, 182, 232);
            addEventListener(Event.ENTER_FRAME, function(event:Event):void 
            {
                p_bar.value += (_loadPercent - p_bar.value) * .5;
                
                if (p_bar.value > .99) {
                    p_bar.value = 1;
                    event.target.removeEventListener(event.type, arguments.callee);
                    
                    var _tw:ITween = BetweenAS3.serial(
                        BetweenAS3.to(p_bar, { alpha:0 }, .3, Quad.easeOut), 
                        BetweenAS3.removeFromParent(p_bar)
                    );
                    _tw.onComplete = setWorld;
                    _tw.play();
                }
            });
        }
        
        private function setWorld():void
        {
            _dobuemon.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
            
            _mtx1 = new Matrix3D();
            _mtx2 = new Matrix3D();
            _vec = new Vector3D();
            _weights = [];
            _angle = 0;
            
            _scene = new Scene3D();
            _camera = new Camera3D();
            _camera.y = -500;
            _camera.x = 0;
            _camera.z = 0;
            _camera.focus = 25;
            _camera.zoom = 25;
            _camera.rotationX = 90;
            
            var filter:* = new FogFilter( { material:new ColorMaterial(0), minZ:100, maxZ:1500 } );
            
            _view = new View3D( { camera: _camera, scene: _scene, stats: false, x: 460 >> 1, y: 460 >> 1 } );
            _view.renderer = new BasicRenderer(filter);
            addChild(_view);
            
            var bmpd:BitmapData = Bitmap(_dobuemon.content).bitmapData;
            _bitmapMaterial = new TransformBitmapMaterial(bmpd, { repeat:true, scaleX:.1, scaleY:.1 } );
            
            var radius:int = 300;
            var segment:int = 20;
            var h:int = 1000;
            
            _cylinder = new Cylinder( { material:_bitmapMaterial, radius:radius, segmentsW:segment, segmentsH:segment, height:h, openEnded:true } );
            _cylinder2 = new Cylinder( { material:_bitmapMaterial, radius:radius, segmentsW:segment, segmentsH:segment, height:h, openEnded:true } );
            _cylinder.bothsides = true;
            _scene.addChild(_cylinder);
            
            var weight:Number, i:int;
            for each(var v:Vertex in _cylinder.vertices) {
                var row:int = i / segment;
                weight = row * 0.000625;
                _weights.push(weight);
                i++;
            }
            
            onStageResize();
            stage.addEventListener(Event.RESIZE, onStageResize);
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        private function update(event:Event):void 
        {
            _bitmapMaterial.offsetY++;
            _cylinder.rotationY += 0.8;
            _angle += 2;
            
            var rad:Number = _angle * D2R;
            var updateNum:Number = Math.cos(rad) * 0.00045;
            
            var i:int = 0;
            while(i < _cylinder2.vertices.length) {
                var v1:Vertex = _cylinder.vertices[i];
                var v2:Vertex = _cylinder2.vertices[i];
                
                _mtx1.identity();
                _mtx1.prependRotation(updateNum, new Vector3D(0, 0, 1));
                _mtx2.prependTranslation(updateNum, 0, 0);
                _mtx1.prepend(_mtx2);
                _vec = _mtx1.transformVector(v2.position);
                
                v2.x = _vec.x;
                v2.y = _vec.y;
                v2.z = _vec.z;
                
                var weightedV:Vertex = Vertex.weighted(v1, v2, 1 - _weights[i], _weights[i]);
                
                v1.x = weightedV.x;
                v1.y = weightedV.y;
                v1.z = weightedV.z;
                
                i++;
            }
            
            _view.render();
        }
        
        private function onStageResize(event:Event = null):void 
        {
            _view.x = 460>> 1;
            _view.y = 460 >> 1;
        }
    }