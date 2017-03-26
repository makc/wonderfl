// < Rainbow beetle >
// Alternativa3Dでの習作。  テクスチャにモデルの法線を焼きこんでPixelBenderでシェーディング。
// Per pixel shading ならぬ Per Texel shading.原理的にはdrawTrianglesでもPaperVision3Dでも可能なはず
// おもったより複雑で重くなってしまった。せっかく法線マップを使っているのだからもう少しポリゴン数をおさえるべき。
//
// 本当はボーンを入れて歩かせたかったけど断念。(Colladaを介さないjointの追加方法がまだわかっていない)

package {
    import alternativ7.engine3d.containers.ConflictContainer;
    import alternativ7.engine3d.core.Camera3D;
    import alternativ7.engine3d.core.Clipping;
    import alternativ7.engine3d.core.MipMapping;
    import alternativ7.engine3d.core.MouseEvent3D;
    import alternativ7.engine3d.core.Object3D;
    import alternativ7.engine3d.core.Sorting;
    import alternativ7.engine3d.core.View;
    import alternativ7.engine3d.loaders.Parser3DS;
    import alternativ7.engine3d.materials.FillMaterial;
    import alternativ7.engine3d.materials.TextureMaterial;
    import alternativ7.engine3d.objects.Mesh;
    import alternativ7.engine3d.objects.Sprite3D;
    import alternativ7.engine3d.primitives.Plane;
    import com.bit101.components.CheckBox;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.BlurFilter;
    import flash.filters.ShaderFilter;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.system.Security;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    

    [SWF(backgroundColor="#e0e0e0", frameRate="60", width="465", height="465")]
    public class Gata extends Sprite {
        
        private var camera : Camera3D;
        
        private var gataShader : GataShader = new GataShader();
        private var gataShaderFilter : ShaderFilter = new ShaderFilter(gataShader);
        private var gataTexSrc : BitmapData;
        private var gataTex : BitmapData;
        private var gataModel : Parser3DS = new Parser3DS();
        private var debugBmp : Bitmap;

        private var zeroPoint : Point = new Point(0, 0);
        private var eye : Vector3D = new Vector3D();
        private var light : Vector3D = new Vector3D();
        private var halfv : Vector3D = new Vector3D();
        private var kuwagata : Mesh;
        private var shadow : Mesh;
        
        private var wire : FillMaterial = new FillMaterial(0xffffff, 1, 1, 0);
        private var morpho : TextureMaterial = new TextureMaterial();
        
        private var shadowBitmapData : BitmapData = new BitmapData(475, 475, false, 0xffc0c0c0);
        private var shadowBlur : BlurFilter = new BlurFilter(4, 4, 1);

        private const plane_size : Number = 1000;
        
        private var downPoint : Point = new Point();
        private var camPos : Polar = new Polar();
        private var camDistance : Number = 900;
        private var mouseIsDown : Boolean = false;
        
        private var lightPos : Polar = new Polar();
        private var light_camera:Camera3D;
        private var light_dummy : Sprite3D;
        
        private var stopCameraAnime : Boolean = false;
        private var startAnimeTimer : Timer = new Timer(5000);
        
        private var lightPath : MotionPath = new MotionPath(400, 400, 0, 300, 500, 500);
        private var cameraPath : MotionPath = new MotionPath(400, 400, 0, 200, 1000, 500);
        
        private var morphoShader : Number = 0.0;
        private    var mtx_stack : MatrixStack = new MatrixStack();
        
        // UI
        private var uirect : Sprite = new Sprite();
        private var cbxMorpho : CheckBox;
        private var cbxQuality : CheckBox;
        private var cbxDebug : CheckBox;
        private var cbxDebugTex : CheckBox;
        private var info : TextInfo;

        // temporary
        private var temp0 : Vector3D = new Vector3D();
        private var temp1 : Vector3D = new Vector3D();
        private var temp2 : Vector3D = new Vector3D();
        
        private var loaders : Array;
        private const url:Array = [
//            "b", "http://escargot.la.coocan.jp/jsdoit/Nijiiro.3ds",//"./Nijiiro.3ds",
            "b", "http://escargot.la.coocan.jp/jsdoit/Nijiiro_low.3ds",//"./Nijiiro_low.3ds",
            "b", "http://escargot.la.coocan.jp/jsdoit/Nijiiro_shadow.3ds",//"./Nijiiro_shadow.3ds",
            "c", "http://assets.wonderfl.net/images/related_images/c/c1/c131/c13116ea291321da1e2ca090edccd38fd0be9f35"// "./map_gata_low.png"
//            "c", "./map_gata_low196.png"
            ];
        
        public function Gata() {
            Security.loadPolicyFile("http://escargot.la.coocan.jp/jsdoit/crossdomain.xml");
            loaders = new Array();
            for (var i : int = 0; i < url.length>>1; i++) {
                if (url[i*2] == "b") {
                    loaders[i] = new URLLoader();
                    loaders[i].addEventListener(Event.COMPLETE, loaded);
                    loaders[i].dataFormat = URLLoaderDataFormat.BINARY;
                    loaders[i].load(new URLRequest(url[i * 2 + 1]));
                } else {
                    loaders[i] = new Loader();
                    loaders[i].contentLoaderInfo.addEventListener(Event.COMPLETE, loaded);
                    loaders[i].load(new URLRequest(url[i * 2 + 1]), new LoaderContext(true));
                }
            }
        }
        
        private var loaded_count : int = 0;
        private function loaded(e : Event = null) : void
        {
            loaded_count++;
            if (loaded_count < (url.length>>1)) return;
            gataModel.parse(ByteArray(loaders[0].data), "./", 5);

            gataTexSrc = Bitmap(loaders[2].content).bitmapData;
            gataTex = gataTexSrc.clone();
            morpho.texture = gataTex;

            kuwagata = gataModel.objects[0] as Mesh;
            kuwagata.setMaterialToAllFaces(morpho);
            
            var shadow_parse : Parser3DS = new Parser3DS();
            shadow_parse.parse(ByteArray(loaders[1].data), "./", 5);
            
            shadow = shadow_parse.objects[0] as Mesh;
            //kuwagata.sorting = Sorting.AVERAGE_Z;

            uirect.graphics.clear();
            uirect.graphics.beginFill(0x000000, 0.8);
            uirect.graphics.drawRoundRect(0, 0, 200, 100, 16, 16);
            uirect.graphics.endFill();
            cbxMorpho = new CheckBox( uirect, 16, 16, "MORPHO SHADER", cbxMorphoChecked);
            cbxMorpho.selected = true;
            cbxQuality = new CheckBox( uirect, 16, 32, "HIGH QUALITY", cbxQualityChecked);
            cbxQuality.selected = true;
            cbxDebug = new CheckBox( uirect, 16, 64, "NO SHADER", cbxDebugChecked);
            cbxDebug.selected = false;
            cbxDebugTex = new CheckBox( uirect, 16, 80, "DEBUG");
            cbxDebugTex.selected = false;
            
            //kuwagata = (gataModel.objects[0] as Mesh);
            var mat : Matrix3D = new Matrix3D();
            mat.appendTranslation(0, 0, 5);
            kuwagata.matrix = mat;
            shadow.matrix = mat;
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.HIGH;
            
            light_camera = new Camera3D();
            light_camera.view = new View(465, 465);
            
            var shadow_container : ConflictContainer = new ConflictContainer();
            shadow_container.addChild(light_camera);
            shadow_container.addChild(shadow);
            light_camera.view.filters = [ shadowBlur ];

            // 可視化ライト
            var lightspr : Sprite = new Sprite();
            lightspr.graphics.clear();
            lightspr.graphics.beginFill(0xf0f000, 0.5);
            lightspr.graphics.drawCircle(16, 16, 16);
            lightspr.graphics.endFill();
            lightspr.graphics.beginFill(0xffffff, 1);
            lightspr.graphics.drawCircle(16, 16, 8);
            lightspr.graphics.endFill();
            
            var bmpd : BitmapData = new BitmapData(32, 32, true, 0);
            bmpd.draw( lightspr );
            var light_material : TextureMaterial = new TextureMaterial(bmpd);
            light_dummy = new Sprite3D(32,32, light_material);

            // floor
            var material2:TextureMaterial = new TextureMaterial(shadowBitmapData);
            material2.mipMapping = MipMapping.PER_PIXEL;
            var plane:Plane = new Plane(plane_size, plane_size, 20, 20);
            plane.setMaterialToAllFaces(material2);
            plane.sorting = Sorting.NONE;
            plane.clipping = Clipping.FACE_CULLING;
            plane.z = 0;

            // camera
            camera = new Camera3D();
            camera.view = new View(465, 465);
            addChild(camera.view);

            camera.fov = 60 * Math.PI / 180;            
            camPos.r = camDistance;
            camPos.thi = 50;
            camPos.phi = 120;
            camPos.applyPosition( camera );
            
            // ライトとカメラの動作パス。鷹匠からの流用なのでいまいちの出来
            lightPath  = new MotionPath(400, 400, 0, 300, 500, 500);
            cameraPath = new MotionPath(camera.x, camera.y, camera.z, 300, 1000, 500);
            computeCameraPos();

            // Root object
            var container : ConflictContainer = new ConflictContainer();
            container.resolveByAABB = true;
            container.resolveByOOBB = true;
            
            // Adding
            container.addChild(camera);
            container.addChild(plane);
            container.addChild(kuwagata);
            container.addChild(light_dummy);
            camera.view.interactive = true;
            
            //camera.debug = false;
        
            onResize();
            debugBmp = new Bitmap(gataTex)
            addChild( debugBmp );
            debugBmp.scaleX = 0.5;
            debugBmp.scaleY = 0.5;
            debugBmp.scaleZ = 0.5;
            debugBmp.visible = cbxDebugTex.selected;

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            stage.addEventListener(Event.RESIZE, onResize);
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            
            uirect.x = stage.stageWidth - uirect.width;
            addChild(uirect);
            addChild(camera.diagram);
            
            stopCameraAnime = true;
            startAnimeTimer.addEventListener(TimerEvent.TIMER, onTimer);
            startAnimeTimer.start();
            
        }
        
        private function onTimer(e:TimerEvent) : void
        {
            startAnimeTimer.stop();
            startAnimeTimer.removeEventListener(TimerEvent.TIMER, onTimer);
            stopCameraAnime = false;
        }
        
        private function computeCameraPos() : void
        {
            cameraPath.computeD();
            cameraPath.getPositionAsAlt3D( temp1 );
            camPos.r = temp1.length;
            camPos.thi = Math.atan2(temp1.z, temp1.length) * 180 / Math.PI;;
            camPos.phi = Math.atan2(temp1.y, temp1.x) * 180 / Math.PI;
            camPos.applyPosition( camera );
        }
        
        public function onEnterFrame(e:Event = null):void
        {
            lightPath.computeD();
            lightPath.getPositionAsAlt3D( temp0 );
            light_dummy.x = temp0.x;
            light_dummy.y = temp0.y;
            light_dummy.z = temp0.z;
            var light_thi : Number = Math.atan2(light_dummy.z, temp0.length) * 180 / Math.PI;
            if (light_thi < 30) light_thi = 30;

            if (!stopCameraAnime) {
                computeCameraPos();
            }
            
            

            // 影をレンダリング。かなり無理やりなので汎用性なし ------------------------------------------------------------------------
            // 影レンダリング用カメラの位置設定
            // 任意座標から、オブジェクト中心にカメラを向けるようにしたかったが、fovを小さくしてcameraのrotationYを変えるとアスペクトが狂うので
            // 極座標形式にして、rotationYをさわらないようにした。
            light_camera.fov = 0.1 * Math.PI / 180;//平行投影がなさそうなのでfovを小さくして代用
            var len : Number = (plane_size + plane_size * 0.4) / (2 * Math.tan(light_camera.fov / 2.0)); // magic number=0.4?
            
            lightPos.r = len;
            lightPos.thi = light_thi;
            lightPos.phi = Math.atan2(light_dummy.y, light_dummy.x)*180/Math.PI;
            lightPos.applyPosition(light_camera);
            lightPos.r = 400;
            //lightPos.changePosition(light_dummy); // ライト可視化

            shadow.matrix = kuwagata.matrix;            
            
            light_camera.render();
            shadowBitmapData.fillRect(shadowBitmapData.rect, 0xffe0e0e0);

            mtx_stack.push();
            mtx_stack.translate( 4, 4 ) ; // なぜか影が原点方向に4画素ほどずれるので補正            
            mtx_stack.translate( light_camera.view.width / 2, light_camera.view.height /2) ;
            mtx_stack.rotate( (-lightPos.phi-90 ) * Math.PI / 180 );
            mtx_stack.translate( -light_camera.view.width / 2, -light_camera.view.height / 2 + light_camera.view.height / 2 * (1-Math.abs(1 / (Math.cos((90 - lightPos.thi) * Math.PI / 180)))) ) ;
            //matstk.translate(0, -light_camera.view.height/2*(Math.abs(1 / (Math.cos((90-lightPos.thi)*Math.PI/180)))));
            mtx_stack.scale(1, 1 / (Math.cos((90-lightPos.thi)*Math.PI/180)));
            
            var shadowMatrix : Matrix = mtx_stack.raw.clone();
            mtx_stack.pop();
            

            shadowBitmapData.draw( light_camera.view, shadowMatrix );

            // ニジイロクワガタレンダリング -------------------------------------------------------
            
            gataShader.SetModelMatrix( kuwagata.matrix);
            
            eye.x = camera.x;
            eye.y = camera.y;
            eye.z = camera.z;
            eye.normalize();

            light.x = light_camera.x;
            light.y = light_camera.y;
            light.z = light_camera.z;
            light.normalize();
            
            halfv.x = light.x + eye.x;
            halfv.y = light.y + eye.y;
            halfv.z = light.z + eye.z;
            halfv.normalize();
            
            if (!cbxDebug.selected) {
                gataShader.data.shader.value = [morphoShader];
                gataShader.data.eye.value = [ eye.x, eye.y, eye.z ];
                gataShader.data.light.value = [ light.x, light.y, light.z ];
                gataShader.data.halfv.value = [ halfv.x, halfv.y, halfv.z ];
                gataTex.applyFilter(gataTexSrc, gataTex.rect, zeroPoint, gataShaderFilter);
            } else {
            //    gataTex.copyPixels(gataTexSrc, gataTex.rect, zeroPoint);
            }
            
            debugBmp.visible = cbxDebugTex.selected;
            
            if (shader_on) {
                morphoShader += (1.0 - morphoShader) / 8;
            } else {
                morphoShader += (0.0 - morphoShader) / 8;
            }
            
            camera.render();
            
        }
        private function onMouseDown(e:MouseEvent) : void
        {
            stopCameraAnime = true;
            downPoint.x = e.stageX;
            downPoint.y = e.stageY;
            mouseIsDown = true;
        }

        private function onMouseUp(e:MouseEvent) : void
        {
            mouseIsDown = false;
            startAnimeTimer.addEventListener(TimerEvent.TIMER, onTimer);
            startAnimeTimer.start();
        }

        private function onMouseMove(e:MouseEvent) : void
        {
            if (mouseIsDown) {
                camPos.phi += 1 * (downPoint.x - e.stageX) ;// * Math.PI / 180;            
                camPos.thi -= 1 * (downPoint.y - e.stageY) ;// * Math.PI / 180;
                if (camPos.thi < 10) camPos.thi = 10;
                if (camPos.thi > 90) camPos.thi = 90;
                camPos.applyPosition( camera );
            }
            downPoint.x = e.stageX;
            downPoint.y = e.stageY;
        }
        
        private function onMouseWheel(e:MouseEvent3D):void {
            if (e.target is Sprite3D) {
                (e.target as Sprite3D).rotation += e.delta/20;
            } else {
                (e.target as Object3D).rotationZ += e.delta/20;
            }
        }
        private var shader_on : int = 1;
        private function cbxMorphoChecked(e:Event):void
        {
            shader_on = cbxMorpho.selected ? 1 : 0;
            e.stopImmediatePropagation();
        }

        private function cbxQualityChecked(e:Event):void
        {
            if (!cbxQuality.selected) {
                stage.quality = StageQuality.LOW;
            } else {
                stage.quality = StageQuality.HIGH;
            } 
        }

        private function cbxDebugChecked(e:Event):void
        {
            if (!cbxDebug.selected) {
            //    kuwagata.setMaterialToAllFaces(morpho);
            } else {
                gataTex.copyPixels(gataTexSrc, gataTex.rect, zeroPoint);
            //    kuwagata.setMaterialToAllFaces(wire);
            } 
            
        }

        public function onResize(e:Event = null) : void
        {
            camera.view.width = stage.stageWidth;
            camera.view.height = stage.stageHeight;
            camera.view.x = 0;
            camera.view.y = 0;
        }
    }
}

import alternativ7.engine3d.core.Object3D;
import flash.display.Shader;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import mx.utils.Base64Decoder;

class TextInfo extends TextField {

    public function TextInfo() {
        autoSize = TextFieldAutoSize.LEFT;
        selectable = false;
        defaultTextFormat = new TextFormat("Tahoma", 10, 0x7F7F7F);
    }
    
    public function write(value:String):void {
        appendText(value + "\n");
    }
    
    public function clear():void {
        text = "";
    }
}

class Polar
{
    public var thi : Number;
    public var phi : Number;
    public var r   : Number;
    
    public function Polar(thi : Number = 0, phi : Number = 0, r : Number = 1)
    {
        this.thi = thi;
        this.phi = phi;
        this.r   = r;
    }
    
    public function applyPosition( obj3D : Object3D) : void
    {
        obj3D.x = r * Math.cos(phi* Math.PI / 180) * Math.cos(thi* Math.PI / 180);
        obj3D.y = r * Math.sin(phi* Math.PI / 180) * Math.cos(thi* Math.PI / 180);
        obj3D.z = r * Math.sin(thi* Math.PI / 180);
                
        obj3D.rotationX = (-thi- 90) * Math.PI / 180;
//        obj3D.rotationY = 90 * Math.PI / 180;
        obj3D.rotationZ =  (phi + 90) * Math.PI / 180;
    }
    
    public function getMatrix(/*out*/matrix : Matrix3D) : void
    {
        var cp : Number = Math.cos(phi);
        var ct : Number = Math.cos(thi);
        var sp : Number = Math.sin(phi);
        var st : Number = Math.sin(phi);
        
        matrix.identity();
        matrix.appendRotation( -thi, new Vector3D(1, 0, 0));
        matrix.appendRotation(  phi, new Vector3D(0, 0, 1));
        matrix.appendTranslation(r, 0.0, 0.0);
        /*
                camera.x = camDistance * Math.cos(camPos.x) * Math.cos(camPos.y);
                camera.y = camDistance * Math.sin(camPos.x) * Math.cos(camPos.y);
                camera.z = camDistance * Math.sin(camPos.y);
                
                camera.rotationX = -camPos.y - 90 * Math.PI / 180;
//                camera.rotationY = 90 * Math.PI / 180;
                camera.rotationZ = camPos.x + 90 * Math.PI / 180;
        */
    }
}

class GataShader extends Shader
{
    //[Embed(source = 'GataShader.pbj', mimeType = 'application/octet-stream')]
    //private var pbj : Class;
    private var bcode : String = 
        "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" +
        "EQDiEAAYAAMRAOIEAPwAHQ0A4hEAGAA1AAAAAAAAADIFABA9zMzNHRAAgAUAwAAyBQAQPzMzMx0I" +
        "ACAKAIAAAwgAIAUAwAAdEABACACAADIFABA+TMzNHRAAIAUAwAAdEQDiEAAYAAMRAOICAPwAHRAA" +
        "4hEAGAADEADiCgCoAB0OAOIQABgAMgUAED5MzM0dEACABQDAADIFABA+TMzNHQgAIAoAgAADCAAg" +
        "BQDAAB0QAEAIAIAAMgUAEAAAAAAdEAAgBQDAAB0RAOIQABgAAxEA4gIA/AAyBQAQP4AAAB0IACAF" +
        "AMAAAggAIAoAgAAdEADiEQAYAAMQAOIIAKgAHQ8A4hAAGAAyEACAP4AAADIQAEA/gAAAMhAAID+A" +
        "AAAdEQDiEAAYAAMRAOIEAPwAHQ0A4hEAGAA2AAAAAAAAADYAAAAAAAAANgAAAAAAAAA2AAAAAAAA" +
        "ADIFABA/gAAAKgAAIAUAwAAdAYAgAIAAADQAAAABgIAAMhAAgD+AAAAyEABAP4AAADIQACA/gAAA" +
        "HREA4hAAGAADEQDiAQD8ADIFABA/gAAAHQgAIAUAwAACCAAgAACAAB0QAOIRABgAAxAA4ggAqAAd" +
        "EQDiDgAYAAMRAOIAAKgAHRIA4hAAGAABEgDiEQAYAB0OAOISABgAMhAAgAAAAAAyEABAAAAAADIQ" +
        "ACAAAAAAMgUAED+AAAAdCAAgBQDAAAIIACAAAIAAHREA4hAAGAADEQDiCACoAB0QAOIPABgAAxAA" +
        "4gAAqAAdEgDiEQAYAAESAOIQABgAHQ8A4hIAGAAyEACAP4AAADIQAEA/gAAAMhAAID+AAAAdEQDi" +
        "BAD8AAMRAOIQABgAMgUAED+AAAAdCAAgBQDAAAIIACAAAIAAHRAA4hEAGAADEADiCACoAB0RAOIN" +
        "ABgAAxEA4gAAqAAdEgDiEAAYAAESAOIRABgAHQ0A4hIAGAA2AAAAAAAAADUAAAAAAAAAMhAAgD+A" +
        "AAAyEABAP4AAADIQACA/gAAAHREA4hAAGAADEQDiAQD8AB0OAOIRABgAMg8AgAAAAAAyDwBAAAAA" +
        "ADIPACAAAAAAMhAAgD+AAAAyEABAP4AAADIQACA/gAAAHREA4gQA/AADEQDiEAAYAB0NAOIRABgA" +
        "NgAAAAAAAAAdEADiDgAYAAEQAOIPABgAHREA4hAAGAAdEADiDAAYAAMQAOIRABgAHRIA4hAAGAAB" +
        "EgDiDQAYAB0HAOISABgA";
    /*
        "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" ;
        */

    public function GataShader()
    {
        /*
        var code : ByteArray = (new pbj()) as ByteArray;
        super( code );
        */
        var dec : Base64Decoder = new Base64Decoder();
        dec.decode( bcode );
        super(dec.toByteArray());
        
        
    }
    
    public function SetModelMatrix(mat : Matrix3D) : void
    {
        var x0 : Number = mat.rawData[0], y0 : Number = mat.rawData[4], z0 : Number = mat.rawData[8];
        var x1 : Number = mat.rawData[1], y1 : Number = mat.rawData[5], z1 : Number = mat.rawData[9];
        var x2 : Number = mat.rawData[2], y2 : Number = mat.rawData[6], z2 : Number = mat.rawData[10];
        
//        data.matrix.value = [ x0, x1, x2,  y0, y1, y2,  z0, z1, z2 ];
        data.matrix.value = [ x0, y0, z0,  x1, y1, z1,  x2, y2, z2 ];
    }
}

class MatrixWrap
{
    public var matrix : Matrix;
    public var index : int;
    public var used : Boolean;
}

class MatrixPool
{
    // matrixは頻繁に作成されるので、そのたびにnewするのは精神衛生上悪いからPoolする。でもまあ殆ど影響ないと思う
    private var mats : Vector.<MatrixWrap> = new Vector.<MatrixWrap>;
    private var freep : int = -1;
    private const itemlimit : int = 5000;
    
    public function newItem(a : Number = 1, b : Number = 0, c : Number = 0, d : Number = 1, tx : Number = 0, ty : Number = 0 ) : MatrixWrap
    {
        var cnt : int = mats.length;
        if (((itemlimit > 0) && cnt >= itemlimit) && (freep >= cnt - 1)) 
        {
            trace("MatrixPool overflow!"+cnt.toString());
            return null;
        }
        
        freep++;

        if (freep == cnt) {
            mats[cnt] = new MatrixWrap();
            mats[cnt].matrix = new Matrix(a, b, c, d, tx, ty);
        } else {
            var m : Matrix = mats[freep].matrix;
            m.a = a;
            m.b = b;
            m.c = c;
            m.d = d;
            m.tx = tx;
            m.ty = ty;
        }
        mats[freep].index = freep;
        mats[freep].used = true;
    
        return mats[freep];
    }
    
    public function remove(item : MatrixWrap) : void
    {
        var cnt : int = mats.length;
        var lastp : int = freep;

        item.used = false;
        if (lastp != item.index) {
            mats[item.index] = mats[lastp];
            mats[item.index].index = item.index;
            mats[lastp] = item;
        }
        freep = lastp - 1;
        
    }
    
    private static var pool : MatrixPool = null;
    public static function get instance() : MatrixPool
    {
        if (!MatrixPool.pool) MatrixPool.pool = new MatrixPool();
        
        return MatrixPool.pool;
    }
    
}

// matrixの適用順をfrocessing互換にするためのMatrixStackクラス。
// 互換性うんぬんよりも、個人的にこちらのほうが使いやすいためという理由のほうが大きい
class MatrixStack
{
    private var stack : Vector.<MatrixWrap> = new Vector.<MatrixWrap>;
    private var current : MatrixWrap = new MatrixWrap();

    public function MatrixStack()
    {
    }
    
    public function push() : MatrixStack
    {
        stack.push(current);
        current = MatrixPool.instance.newItem(1,0,0,1,0,0);
        
        return this;
    }
    
    public function pop() : MatrixStack
    {
        MatrixPool.instance.remove(current);
        current = stack.pop();
        
        return this;
    }
    
    public function translate(x : Number, y : Number) : MatrixStack
    {
        var mat : MatrixWrap = MatrixPool.instance.newItem(1, 0, 0, 1, x, y);
        mat.matrix.concat(current.matrix);
        MatrixPool.instance.remove(current);
        current = mat;
        return this;
    }
    
    public function rotate(rad : Number) : MatrixStack
    {
        var mat : MatrixWrap = MatrixPool.instance.newItem(Math.cos(rad), Math.sin(rad), -Math.sin(rad), Math.cos(rad), 0, 0);
        mat.matrix.concat(current.matrix);
        MatrixPool.instance.remove(current);
        current = mat;
        return this;
    }
    
    public function scale(x : Number, y : Number) : MatrixStack
    {
        var mat : MatrixWrap = MatrixPool.instance.newItem(x, 0, 0, y, 0, 0);
        mat.matrix.concat(current.matrix);
        MatrixPool.instance.remove(current);
        current = mat;
        return this;
    }
    
    public function identity() : MatrixStack
    {
        var m : Matrix = current.matrix;
        m.a = 1.0;
        m.b = 0.0;
        m.c = 0.0;
        m.d = 1.0;
        m.tx = 0.0;
        m.ty = 0.0;
        
        return this;
    }
    
    public function transform(/*inout*/ pos : Point) : void
    {
        var m : Matrix = current.matrix;
        var tmpx : Number = m.a * pos.x + m.c * pos.y + m.tx * 1;
        var tmpy : Number = m.b * pos.x + m.d * pos.y + m.ty * 1;
        
        pos.x = tmpx;
        pos.y = tmpy;
    }
    
    public function copyTo(/* out */dest : Matrix) : void
    {
        var m : Matrix = current.matrix;
        dest.a = m.a;
        dest.b = m.b;
        dest.c = m.c;
        dest.d = m.d;
        dest.tx = m.tx;
        dest.ty = m.ty;
    }
    /*
    public function copyFromFMatrix2D( src : FMatrix2D ) : void
    {
        var mat : Matrix = current.matrix;
        mat.a = src.a;
        mat.b = src.b;
        mat.c = src.c;
        mat.d = src.d;
        mat.tx = src.tx;
        mat.ty = src.ty;
    }
    */
    public function get raw() : Matrix { return current.matrix; } // このプロパティで取り出されるmatrixの寿命は短いので要注意
}

// 鷹匠のソースから抜出。汎用化しないと...
function crossProduct(v0 : Vector3D, v1 : Vector3D, vo : Vector3D) : void
{
    var x : Number = v0.y * v1.z - v0.z * v1.y;
    var y : Number = v0.z * v1.x - v0.x * v1.z;
    var z : Number = v0.x * v1.y - v0.y * v1.x;
    
    vo.x = x;
    vo.y = y;
    vo.z = z;
}

class MotionPath
{
    private var speed : Number;
    private var half : Number;
    private var t : Number;
    private var start : Vector3D = new Vector3D();
    private var position : Vector3D = new Vector3D();
    private var prim_seg : Vector3D = new Vector3D();
    private var second_seg : Vector3D = new Vector3D();
    
    private var temp0 : Vector3D = new Vector3D();
    private var temp1 : Vector3D = new Vector3D();
    private var temp2 : Vector3D = new Vector3D();
    private var temp3 : Vector3D = new Vector3D();
    private var d : Vector3D = new Vector3D();
    
    private var limit_dist : Number;
    private var limit_height : Number;
    
    private var dir_h : Number;
    private var dir_v : Number;
    
    private var descent : Boolean;
    
    public function MotionPath(x : Number, y : Number, z :  Number, speed : Number = 10, limit_dist : Number = 100, limit_height : Number = 500)
    {
        t = -1.0;
        start.x = x;
        start.y = y;
        start.z = z;
        
        this.limit_dist = limit_dist;
        this.limit_height = limit_height;
        this.speed = speed;
        this.half = speed / 2;

        dir_h = -45*Math.PI/180;
        dir_v = 0.2;
        
        prim_seg.x = Math.sin( dir_h) * 1;
        prim_seg.z = Math.cos( dir_h) * 1;
        prim_seg.y = Math.sin( dir_v) * 1;
        second_seg.x = Math.sin( dir_h) * 1;
        second_seg.z = Math.cos( dir_h) * 1;
        second_seg.y = Math.sin( dir_v-0.2) * 1;
        
        position.x = start.x;
        position.y = start.y;
        position.z = start.z;
        
    }

    private function nextPath() : void
    {
        var ah : Number = (Math.random()*10 - 5)*Math.PI/180;
        var av : Number = (Math.random()*40 - 10 )*Math.PI / 180;
        
        temp1.x = position.x - 0;
        temp1.y = position.y - 0;
        temp1.z = position.z - (-limit_dist);
        
        var dist : Number = Math.sqrt(temp1.x * temp1.x + temp1.z * temp1.z);
        if (dist > limit_dist) { // 0,0,-1000から水平方向に2000以上離れたら0,0,-1000方向に軌道修正
            
            temp0.x = d.x;
            temp0.y = d.y;
            temp0.z = d.z;
            
            temp0.normalize();
            temp1.normalize();
            
            crossProduct(temp0, temp1, temp0);            
            
            ah = (temp0.y > 0 ? -1:1) * (Math.random()+0.5) * Math.PI / 2;
        }
        
        if (position.y > limit_height) {
            av = -dir_v -Math.PI / 2;
        }
        second_seg.x = Math.sin(dir_h + ah);
        second_seg.z = Math.cos(dir_h + ah);
        second_seg.y = Math.sin(dir_v + av);
        
    }
    
    // モーションパスから移動量算出。
    public function computeD() : void
    {
        // tが1になったら次のパスを生成
        if (t >= 1.0) {
            t -= 1.0;
            // パス決定用セグメントをシフト
            start.x = start.x + prim_seg.x * speed;
            start.y = start.y + prim_seg.y * speed;
            start.z = start.z + prim_seg.z * speed;
            prim_seg.x = second_seg.x;
            prim_seg.y = second_seg.y;
            prim_seg.z = second_seg.z;

            // 新しいパスを生成
            nextPath();
        trace( t, dir_v, position , limit_height );
            
            // 水面につっこみそうになる場合は向きを↑に反転
            if (second_seg.y * speed + position.y < 0) {
                descent = false;
                second_seg.y *= -1;
            }
            
        }
        // 2直線で指定されるモーションパス上の位置を計算。tは0から1.0まで。ただし初期は-1から始まる。(制御点は各直線の真ん中と、ジョイント部の3点。2次ベジェ)
        if (t < 0) {
            temp3.x = start.x + (prim_seg.x * half)*(1+t);
            temp3.y = start.y + (prim_seg.y * half)*(1+t);
            temp3.z = start.z + (prim_seg.z * half)*(1+t);
        } else {
            temp0.x = start.x + prim_seg.x * half;
            temp0.y = start.y + prim_seg.y * half;
            temp0.z = start.z + prim_seg.z * half;
            
            temp1.x = start.x + prim_seg.x * speed;
            temp1.y = start.y + prim_seg.y * speed;
            temp1.z = start.z + prim_seg.z * speed;
            
            temp2.x = temp1.x + second_seg.x * half;
            temp2.y = temp1.y + second_seg.y * half;
            temp2.z = temp1.z + second_seg.z * half;
            
            
            temp3.x = (1 - t) * (1 - t) * temp0.x + 2 * t * (1 - t) * temp1.x + t * t * temp2.x;
            temp3.y = (1 - t) * (1 - t) * temp0.y + 2 * t * (1 - t) * temp1.y + t * t * temp2.y;
            temp3.z = (1 - t) * (1 - t) * temp0.z + 2 * t * (1 - t) * temp1.z + t * t * temp2.z;
        }
        if (temp3.y < 0) temp3.y = 0;
        
        d.x = temp3.x - position.x;
        d.y = temp3.y - position.y;
        d.z = temp3.z - position.z;

        dir_h = Math.atan2(d.x, d.z);
        var a : Number = Math.sqrt(d.x * d.x + d.z * d.z);
        dir_v = Math.atan2(d.y, a);
        
        position.x = temp3.x;
        position.y = temp3.y;
        position.z = temp3.z;

        t += 0.05
    }
    
    public function getPositionAsAlt3D(/*out*/ p : Vector3D) : void
    {
        p.x = position.x;
        p.y = position.z;
        p.z = position.y;
    }
    
}

/*<languageVersion : 1.0;>

kernel MetaNV
<   namespace : "jp.limacon";
    vendor : "ESV";
    version : 1;
    description : "GataShader"; >
{
   parameter float3x3 matrix
   <
        defaultValue : float3x3(1.0, 0.0, 0.0,  0.0, 1.0, 0.0,  0.0, 0.0, 1.0);
   >;
   parameter float3 light
   <
        defaultValue : float3(0.2, -1.0, 1.0);
   >;
   parameter float3 eye
   <
        defaultValue : float3(0.0, -1.0, 0.0);
   >;
#if AIF_FLASH_TARGET
   parameter float3 halfv;
#endif
   parameter float shader
   <
        defaultValue : float(1.0);
   >;
   input image4 tex;
   
   output pixel4 dest;
   
   
    void evaluatePixel()
   {
#if !AIF_FLASH_TARGET
        float3 halfv = normalize( light+eye );
#endif
        //float3 light2 = normalize( halfv-eye );
        //float3 light3 = normalize( halfv+eye );
        
        float2 curPos = outCoord();
        pixel4 f0 = sampleNearest(tex, curPos);
        //pixel4 f1 = sampleNearest(tex, curPos+float2(1.0, 0.0));
        //pixel4 f2 = sampleNearest(tex, curPos+float2(0.0, 1.0));
        //pixel4 f3 = sampleNearest(tex, curPos+float2(1.0, 1.0));
        pixel4 orig = f0;
        int    flg = int(f0.x*255.0);
        float3 color_a, color_b, color_c, color_d;
        //f0 = (f0 + f1 + f2 + f3) / 4.0;
        
        dest.a = 1.0;//f0.a;

        f0.yz = (f0.zy-1.0/2.0)*2.00;
        f0.y = -f0.y;
        if (1.0-f0.y*f0.y <= 0.0) f0.z = 0.0;
        
        float a = 1.0 - f0.y*f0.y - f0.z*f0.z;
        f0.x = sqrt(a);
        if ((f0.x >= -1.0) && (f0.x <= 1.0)) {
          if (flg >= 128) { f0.x = -f0.x; };
//          if (orig.x >= 128.0/255.0) { f0.x = -f0.x; };
          //f0.x = f0.x;
        } else {
          f0.x = 0.0;
        }
        
        if (flg >= 128) flg -= 128;

        //orig.x = f0.x/2.0+0.5;

        float3 v;
        v.x = dot(matrix[0], f0.xyz);
        v.y = dot(matrix[1], f0.xyz);
        v.z = dot(matrix[2], f0.xyz);       

        float3 sky;
        sky = float3(1.0, 1.0,  1.1);//*(v.z/2.0+0.5);
        

        float doth = dot( halfv.xyz, v.xyz );
        float dotdi = clamp(dot( light, v ), 1.0, 0.0);
        float dota = dot( eye.xyz, v.xyz );
        
        float dotspec = 0.0; 
        //float dotspec2 = 0.0;

        //dotspec2 = max(pow(dota,40.0), 0.0);
        dotspec = max(pow(doth,80.0), 0.0);
 
        if (shader > 0.0) {
            if ( flg == 1 ) {
              color_a.rgb = float3(0.0, 0.0, 0.0)*dotdi*f0.z;
              color_b.rgb = float3(0.0, 0.0, 0.0)*(1.0-dotdi)*f0.z;;
              dotspec = max(pow(doth,50.0), 0.0);
              //color_c.rgb = float3(0.0, 0.0, 0.0);//float3(1.0, 1.0, 1.0)*dotspec2;
              color_d.rgb = float3(1.0, 1.0, 1.0)*dotspec;
            } else if ( flg == 2 ) {
              color_a.rgb = float3(0.1, 0.7, 0.2)*dotdi*f0.z;
              color_b.rgb = float3(0.1, 0.7, 0.2)*(1.0-dotdi)*f0.z;;
              //color_c.rgb = float3(0.5, 0.0, -0.2)*dotspec2;
              color_d.rgb = dotspec*float3(1.0, 1.0, 1.0);
            } else if ( flg == 3 ) {
              float dot_green = sin(dota*8.0*dot( f0.xyz, float3(0.0, 0.0, 1.0))*3.141592);
              color_a.rgb = float3(0.9, 0.1, 0.2)*dotdi*dot_green;// + float3(0.2, 0.2, 0.0)*(1.0-dotr);
              color_b.rgb = float3(0.1, 0.7, 0.2)*(1.0-dota)*(1.0-dot_green);
              //color_c.rgb = float3(0.1, 0.7, 0.3)*dotspec2;
              color_d.rgb = dotspec*float3(2.0, 2.0, 2.0);
    //          orig.x = 1.0;
            } else if ( flg == 4 ) {
              color_a.rgb = float3(0.1, f0.z*0.8, 0.2)*dotdi*(1.0-f0.z);
              color_b.rgb = float3(0.2, f0.z*0.2, 0.0)*dotdi*(f0.z);
              //color_c.rgb = float3(f0.z*-0.5, 0.0, -0.2)*dotspec2;
              color_d.rgb = float3(1.0, 1.0, 1.0)*dotspec;
            } else {
              color_a.rgb = float3(0.1, f0.z*0.7, 0.2)*dotdi*f0.z;
              color_b.rgb = float3(0.2, f0.z*0.2, 0.0)*dotdi*(1.0-f0.z);
              //color_c.rgb = float3(f0.z*-0.5, 0.0, -0.2)*dotspec2;
              color_d.rgb = float3(1.0, 1.0, 1.0)*dotspec;
    //          orig.x = 0.0;
            }
            
            if (shader < 1.0) {
                color_a.rgb = float3(1.0, 1.0, 1.0)*doth*(1.0-shader)+color_a.rgb*shader ;
                color_b.rgb = float3(0.0, 0.0, 0.0)*(1.0-shader)+color_b.rgb*shader ;
                //color_c.rgb = float3(0.0, 0.0, 0.0)*(1.0-shader)+color_c.rgb*shader ;
                color_d.rgb = dotspec*float3(1.0, 1.0, 1.0)*(1.0-shader)+color_d.rgb*shader ;
            }
        } else {
            color_a.rgb = float3(1.0, 1.0, 1.0)*doth;
            color_b.rgb = float3(0.0, 0.0, 0.0);
            //color_c.rgb = float3(0.0, 0.0, 0.0);
            color_d.rgb = dotspec*float3(1.0, 1.0, 1.0);
        }

        
        float3 diffuse = color_a + color_b;

        dest.rgb = sky*(diffuse)+color_d;//+color_c;
    
//        f0.z = sqrt( 1.0 - f0.x*f0.x - f0.y*f0.y);
//        dest.rgb = float3(v.x/2.0+0.5, v.y/2.0+0.5, v.z/2.0+0.5);//float3(density,density,density);// density);

   }
}
*/