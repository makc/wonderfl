// forked from buccchi's 猫にも届け！元気玉！

package {
    import flash.events.*;
    import flash.display.*;
    
    [SWF(width="465", height="465", backgroundColor="#000000", frameRate="30")] 
    
    public class Main extends Sprite {
        private var _rokuS3D:RokuS3D;
        
        public function Main():void {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            _rokuS3D = new RokuS3D();
            addChild(_rokuS3D);
            var controller:S3DController = new S3DController( _rokuS3D );
            _rokuS3D.addChild( controller );
            
            stage.addEventListener(Event.RESIZE, onResize);
            onResize(null);
        }
        
        private function onResize(e:Event):void {
            _rokuS3D.x = Math.floor((stage.stageWidth-465)/2);
            _rokuS3D.y = Math.floor((stage.stageHeight-465)/2);
        }
    }
}



import flash.geom.Matrix;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.geom.Point;
import flash.geom.ColorTransform;
import org.papervision3d.objects.*;
import org.papervision3d.objects.parsers.DAE;
import org.papervision3d.materials.*;
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.view.Viewport3D;
import org.papervision3d.scenes.Scene3D;
import org.papervision3d.objects.primitives.Plane;
import org.papervision3d.render.BasicRenderEngine;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.proto.CameraObject3D;  
import org.papervision3d.core.math.Matrix3D; 

class RokuS3D extends Sprite {
    private var _bgSpr:Sprite;
    private var _bgMask:Sprite;
    private var _container:Sprite;
    private var _cameraA:Camera3D;
    private var _cameraB:Camera3D;
    private var _targetObj:DisplayObject3D
    private var _viewportA:Viewport3D;
    private var _viewportB:Viewport3D;
    private var _scene:Scene3D;
    private var _renderer:BasicRenderEngine;
    private var _wrapA:DisplayObject3D;                 //縦回転用
    private var _wrapB:DisplayObject3D;                 //横回転用
    private var _genkiDama:Plane;
    private var _genkis:Vector.<Genki>;
    private var _genkiMats:Vector.<BitmapMaterial>;     //フェード用テクスチャを保持
    private const STAGE_W:Number = 465;
    private const STAGE_H:Number = 465;
    private const CAMERA_RANGE:Number = 80;             //左右カメラの最大ズレ幅(/2)
    private const BG_DEPTH_RANGE:Number = 35;           //背景の最大ズレ幅
    private const GENKIDAMA_H:Number = 350;             //元気玉の高さ（座標算出用）
    private const DIFF_X:Number = Math.floor(STAGE_W/2);//左右の絵の距離
    private const BG_W:Number = STAGE_W+DIFF_X;         //背景の基本幅
    private const GENKI_STEP:Number = 200;              //中心へ移動するまでのフレーム数
    
    public function RokuS3D():void {
        var loopW:Number = DIFF_X;    //背景の繰り返し幅
        
        _bgMask = new Sprite();
        _bgMask.graphics.beginFill(0xFF0000, 1);
        _bgMask.graphics.drawRect(-Math.floor(BG_W/2), 0, BG_W, STAGE_H-S3DController.HEIGHT);
        _bgMask.x = Math.floor(STAGE_W/2);
        addChild(_bgMask);
        
        _bgSpr = new Sprite();
        _bgSpr.graphics.beginFill(0xFFA915, 1);
        _bgSpr.graphics.drawRect(-Math.floor(BG_W/2), 0, BG_W, STAGE_H-S3DController.HEIGHT);
        _bgSpr.x = _bgMask.x;
        _bgSpr.mask = _bgMask;
        addChild(_bgSpr);
        
        //ノイズ生成
        var noiseBmd:BitmapData = new BitmapData(loopW, _bgSpr.height, false, 0x0);
        var seed:int = int(Math.random() * int.MAX_VALUE);
        noiseBmd.noise(seed, 0, 0xFF, BitmapDataChannel.RED, true);
        //ノイズをループ描画
        var bmd:BitmapData = new BitmapData(_bgSpr.width, _bgSpr.height, false, 0x0);
        var i:int=0;
        while(i*loopW < bmd.width){
            bmd.draw(noiseBmd, new Matrix(1, 0, 0, 1, loopW*i, 0));
            i++;
        }
        //ノイズを表示
        var bm:Bitmap = new Bitmap(bmd);
        bm.alpha = .2;
        bm.blendMode = "add";
        bm.x = -Math.floor(bm.width/2);
        _bgSpr.addChild( bm );
        
        _renderer = new BasicRenderEngine();
        //ビューポート生成
        var padding:Number = DIFF_X;
        _viewportA = new Viewport3D(STAGE_W/2+padding, STAGE_H-S3DController.HEIGHT, false, false);
        _viewportB = new Viewport3D(STAGE_W/2+padding, STAGE_H-S3DController.HEIGHT, false, false);
        _viewportA.x = Math.floor(-padding/2);
        _viewportB.x = Math.floor(DIFF_X -padding/2);
        //カメラ生成
        _cameraA = new Camera3D();
        _cameraB = new Camera3D();
        _cameraA.x = -CAMERA_RANGE;
        _cameraB.x = CAMERA_RANGE;
        //カメラの向きを調整
        _targetObj = new DisplayObject3D();
        _targetObj.y = -20;
        _targetObj.z = 200;
        _cameraA.lookAt(_targetObj);
        _cameraB.lookAt(_targetObj);
        
        _container = new Sprite();
        addChild(_container);
        _container.addChild(_viewportA);
        _container.addChild(_viewportB);
        
        _scene = new Scene3D();
        _wrapA = new DisplayObject3D();
        _scene.addChild(_wrapA);
        _wrapB = new DisplayObject3D();
        _wrapA.addChild(_wrapB);
        
        //ロク生成
        var roku:DAE = new DAE();
        roku.load("http://buccchi.jp/wonderfl/201104/roku.dae");
        roku.scale = 50;
        _wrapB.addChild(roku);
        
        //元気玉生成（Plane）
        var genkiDamaShape:Shape = new Shape();
        var genkiDamaMatr:Matrix = new Matrix();
        genkiDamaMatr.createGradientBox(100, 100, 0, 0, 0);
        genkiDamaShape.graphics.beginGradientFill(
            GradientType.RADIAL,
            [0xFFFFFF, 0xFFFFFF, 0x90F2F6, 0x90F2F6],
            [1, 1, 1, 0],
            [0x00, 0x66, 0xAA, 0xFF],
            genkiDamaMatr,
            SpreadMethod.PAD,
            InterpolationMethod.LINEAR_RGB
        );
        genkiDamaShape.graphics.drawCircle(50, 50, 50);
        var genkiDamaBmd:BitmapData = new BitmapData(100, 100, true, 0);
        genkiDamaBmd.draw(genkiDamaShape);
        _genkiDama = new Plane(new BitmapMaterial(genkiDamaBmd), 220, 220, 1, 1);
        //頂点座標を移動
        var max:int = _genkiDama.geometry.vertices.length;
        var vertex:Vertex3D;
        for(var j:int=0; j<max; j++){
            vertex = _genkiDama.geometry.vertices[j];
            vertex.x = -vertex.x;
        }
        _scene.addChild(_genkiDama);
        
        //Genkiテクスチャ生成
        //フェード用のテクスチャをBitmapData化して格納
        var genkiShape:Shape = new Shape();
        var particleMatr:Matrix = new Matrix();
        particleMatr.createGradientBox(100, 100, 0, 0, 0);
        genkiShape.graphics.beginGradientFill(
            GradientType.RADIAL,
            [0xFFFFFF, 0xFFFFFF, 0xFFFFFF],
            [1, 1, 0],
            [0x00, 0x88, 0xFF],
            particleMatr,
            SpreadMethod.PAD,
            InterpolationMethod.LINEAR_RGB
        );
        genkiShape.graphics.drawCircle(50, 50, 50);
        _genkis = new Vector.<Genki>();
        _genkiMats = new Vector.<BitmapMaterial>();
        for(var k:int=0; k<30; k++){
            var genkiBmd:BitmapData = new BitmapData(100, 100, true, 0);
            var myAlpha:Number = 1/30*k;
            genkiBmd.draw(genkiShape, null, new ColorTransform(1, 1, 1, myAlpha));
            _genkiMats.push( new BitmapMaterial(genkiBmd) );
        }
        
        //Genki生成
        var genki:Genki;
        var genkiNum:Number = 15;
        for(var l:int; l<genkiNum; l++){
            genki = new Genki(_genkiMats[0]);
            genki.ratio = l/genkiNum;
            _genkis.push(genki);
            _scene.addChild(genki);
        }
        
        //地面テクスチャ読み込み
        var texLoader:Loader = new Loader();
        var req:URLRequest = new URLRequest("http://buccchi.jp/wonderfl/201104/texture/ground_tex.png");
        texLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onTexLoadComplete);
        texLoader.load(req, new LoaderContext(true));
    }
    
    private function onTexLoadComplete(e:Event):void {
        e.target.removeEventListener(Event.COMPLETE, onTexLoadComplete);
        //地面生成
        var ground:Plane = new Plane(new BitmapMaterial(e.target.content.bitmapData), 450, 450, 2, 2);
        ground.rotationX = 90;
        ground.y = -400;
        _wrapB.addChild(ground);
    }
    
    
    
    // isAnimation:    自動再生
    // depthRatio:    立体感の強さ（0:2D表示〜 1:3D表示）
    public function update(obj:Object):void {
        _cameraA.x = -CAMERA_RANGE *obj.depthRatio;
        _cameraB.x = CAMERA_RANGE *obj.depthRatio;
        _cameraA.lookAt(_targetObj);
        _cameraB.lookAt(_targetObj);
        _bgSpr.width = Math.floor( BG_W+(BG_DEPTH_RANGE*obj.depthRatio) );
            
        if(obj.isAnimation){
            _wrapB.rotationY += .5;
        }
        _wrapA.rotationX = obj.rotationX;
        _wrapB.rotationY = obj.rotationY;
        
        var radX:Number = (obj.rotationX) * Math.PI / 180;
        var radY:Number = (obj.rotationY) * Math.PI / 180;
        var sinX:Number = Math.sin(radX);
        var cosX:Number = Math.cos(radX);
        var sinY:Number = Math.sin(radY);
        var cosY:Number = Math.cos(radY);
        
        //元気玉の座標を算出
        var genkiDamaY:Number = cosX*GENKIDAMA_H;
        var genkiDamaZ:Number = sinX*GENKIDAMA_H;
        _genkiDama.y = genkiDamaY;
        _genkiDama.z = genkiDamaZ;
        
        //Genkiの座標を変更
        var genki:Genki;
        var nowX:Number;
        var nowY:Number;
        var nowZ:Number;
        var tempZ:Number;
        var outX:Number = 75;        //消えはじめる距離
        var outDist:Number = 50;    //完全に消えるまでの距離
        var fadeInRatio:Number;        //フェードイン率
        
        for(var i:int=0; i<_genkis.length; i++){
            genki = _genkis[i];
            
            var myRatio:Number = Math.sin(Math.PI/2*genki.ratio);
            nowX = genki.myX * myRatio;
            nowY = genki.myY * myRatio + GENKIDAMA_H;
            nowZ = genki.myZ * myRatio;
            //回転角に応じた座標に移動
            genki.x = nowX*cosY - nowZ*sinY;
            tempZ = nowX*sinY + nowZ*cosY;
            genki.z = -( tempZ*cosX - nowY*sinX );
            genki.y = tempZ*sinX + nowY*cosX;
            
            //フェードイン率
            var fadeLimen:Number = .9;    
            if(genki.ratio > fadeLimen){
                fadeInRatio = (1-genki.ratio) /(1-fadeLimen);
            }else{
                fadeInRatio = 1;
            }
            //中心に近づける
            if(obj.isAnimation){
                genki.ratio -= 1/GENKI_STEP;
                if(genki.ratio <= 0){
                    genki.init();
                }
            }
            
            // 隣の絵と被るパーティクルを非表示に
            // 3D座標→2D座標変換（1フレーム前の座標？）
            var pt:Point = getObj2DCords(genki, _cameraA);
            var disRatio:int;
            if(pt.x > outX || pt.x < -outX ){
                var dist:Number = Math.abs(pt.x)-outX;
                if(dist>outDist) dist = outDist;
                disRatio = (1-dist/outDist) * (_genkiMats.length-1);
            }else{
                disRatio = _genkiMats.length-1;
            }
            var matIndex:int = disRatio * fadeInRatio;
            
            genki.material = _genkiMats[matIndex];
        }
        
        //レンダリング
        _genkiDama.lookAt(_cameraA);
        _renderer.renderScene(_scene, _cameraA, _viewportA);
        _genkiDama.lookAt(_cameraB);
        _renderer.renderScene(_scene, _cameraB, _viewportB);
    }
    
    // 3D座標→2D座標変換
    // http://wonderfl.net/c/2Nad
    private function getObj2DCords(o:DisplayObject3D, camera:CameraObject3D, offsetX:Number=0, offsetY:Number=0):Point {  
        var view:Matrix3D = o.view;  
        var persp:Number = (camera.focus * camera.zoom) / (camera.focus + view.n34);  
        return new Point ( (view.n14 * persp) + offsetX, (view.n24 * persp) + offsetY );  
    }  
}



class Genki extends Plane {
    public var ratio:Number;
    public var myX:Number;
    public var myY:Number;
    public var myZ:Number;
    public function Genki(mat:BitmapMaterial):void {
        super(mat, 20, 20, 1, 1);
        init();
    }
    
    public function init():void {
        ratio = 1;
        var h:Number = Math.random()*200+250;
        var rad:Number = Math.random()*360 * Math.PI/180;
        myX = Math.cos(rad)*h;
        myY = Math.random()*950-700;
        myZ = Math.sin(rad)*h;
    }
}



import flash.events.*;
import flash.display.*;
import com.bit101.components.*;
import flash.text.TextFormat;

class S3DController extends Sprite {
    public static const HEIGHT:Number = 16;
    private var _animationCheckBox:CheckBox;
    private var _3DSlider:HSlider;
    private var MY_FONT_LEFT:String = "0000000001000001000001111111010000000100000000000";    // ←
    private var MY_FONT_UP:String = "0001000001110001010100001000000100000010000001000";      // ↑
    private var MY_FONT_RIGHT:String = "0000000000010000000101111111000001000001000000000";   // →
    private var MY_FONT_DOWN:String = "0001000000100000010000001000010101000111000001000";    // ↓
    //
    private var _roku3D:RokuS3D;
    private var _keyFlags:Array;
    private var _autoFlg:Boolean = true;
    private var _depthRatio:Number = .5;
    private var _rotationX:Number = -20;
    private var _rotationY:Number = 30;
    
    
    public function S3DController( roku3D:RokuS3D ):void {
        addEventListener(Event.ADDED_TO_STAGE, onAdded);
        _roku3D = roku3D;
    }
    
    private function onAdded(e:Event):void {
        removeEventListener(Event.ADDED, onAdded);
        //
        _keyFlags = new Array();
        
        graphics.beginFill(0x000000, 1);
        graphics.drawRect(0, 0, 465, 16);
        y = 465-16;
        
        var formatWhite:TextFormat = new TextFormat();
        formatWhite.color = 0xFFFFFF;
        var formatGray:TextFormat = new TextFormat();
        formatGray.color = 0x666666;
        //
        _animationCheckBox = new CheckBox(this, 3, 3, "");
        _animationCheckBox.selected = true;
        _animationCheckBox.addEventListener(MouseEvent.CLICK, onAutoCheckBox);
        var labelAuto:Label = new Label(this, _animationCheckBox.x+13, -1, "animation");
        labelAuto.textField.defaultTextFormat = formatWhite;
        var labelAuto2:Label = new Label(this, labelAuto.x+labelAuto.width, -1, "[Z]");
        labelAuto2.textField.defaultTextFormat = formatGray;
        //
        var label2D:Label = new Label(this, 140, -1, "2D");
        label2D.textField.defaultTextFormat = formatWhite;
        var label2D2:Label = new Label(this, label2D.x+label2D.width, -1, "[X]");
        label2D2.textField.defaultTextFormat = formatGray;
        _3DSlider = new HSlider(this, label2D2.x+label2D2.width+2, 3);
        _3DSlider.value = _depthRatio*100;
        var label3D:Label = new Label(this, _3DSlider.x+_3DSlider.width+2, -1, "3D");
        label3D.textField.defaultTextFormat = formatWhite;
        var label3D2:Label = new Label(this, label3D.x+label3D.width, -1, "[C]");
        label3D2.textField.defaultTextFormat = formatGray;
        //
        var labelRotate:Label = new Label(this, 364, -1, "rotate");
        labelRotate.textField.defaultTextFormat = formatWhite;
        var labelRotate2:Label = new Label(this, labelRotate.x+labelRotate.width, -1, "[  ] [  ] [  ] [  ]");
        labelRotate2.textField.defaultTextFormat = formatGray;
        var labelRotateLeft:Shape = drawMyFont(this, labelRotate.x+labelRotate.width+5, 0, MY_FONT_LEFT);
        var labelRotateUp:Shape = drawMyFont(this, labelRotate.x+labelRotate.width+22, 0, MY_FONT_UP);
        var labelRotateRight:Shape = drawMyFont(this, labelRotate.x+labelRotate.width+39, 0, MY_FONT_RIGHT);
        var labelRotateDown:Shape = drawMyFont(this, labelRotate.x+labelRotate.width+56, 0, MY_FONT_DOWN);
        
        stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDownHandler);
        stage.addEventListener(KeyboardEvent.KEY_UP, KeyUpHandler);
        addEventListener(Event.ENTER_FRAME, loop);
    }
    
    private function KeyDownHandler(e:KeyboardEvent):void {
        if(e.keyCode == 90){
            if(!_keyFlags[e.keyCode]){
                _animationCheckBox.selected = !_animationCheckBox.selected;
                _autoFlg = _animationCheckBox.selected;
            }
        }
        _keyFlags[e.keyCode] = true;
        
    }
    private function KeyUpHandler(e:KeyboardEvent):void {
        _keyFlags[e.keyCode] = false;
    }
    
    private function loop(e:Event):void {
        var _isUpdate:Boolean;
        if(_autoFlg){
            _rotationY += .5;
            _isUpdate = true;
        }
        if(_keyFlags[88]){    //[X]
            _3DSlider.value -= 2;
        }
        if(_keyFlags[67]){    //[C]
            _3DSlider.value += 2;
        }
        if(_keyFlags[37]){    //[left]
            _rotationY += (_autoFlg)? 3-.5: 3;
            _isUpdate = true;
        }
        if(_keyFlags[39]){    //[right]
            _rotationY -= (_autoFlg)? 3: 3-.5;
            _isUpdate = true;
        }
        if(_keyFlags[38]){    //[up]
            _rotationX += 2;
            _isUpdate = true;
        }
        if(_keyFlags[40]){    //[down]
            _rotationX -= 2;
            _isUpdate = true;
        }
        if(_depthRatio != _3DSlider.value){
            _isUpdate = true;
            _depthRatio = _3DSlider.value;
        }
        if(_isUpdate){
            update();
        }
    }
    
    private function onAutoCheckBox(e:MouseEvent):void {
        _autoFlg = e.target.selected;
    }
    
    private function update():void {
        _roku3D.update({isAnimation:_animationCheckBox.selected, depthRatio:_3DSlider.value/100, rotationX:_rotationX, rotationY:_rotationY});
    }
    
    //矢印を描画
    private function drawMyFont(parent:DisplayObjectContainer, xpos:Number, ypos:Number, data:String):Shape {
        var length:int = data.length;
        var xx:int = 0, yy:int = 5;
        var posX:int, posY:int;
        var s:Shape = new Shape();
        s.graphics.beginFill(0x666666, 1);
        for( var i:int=0; i<length; i++ ){
            if(data.charAt(i) == "1"){
                posX = xx;
                posY = yy;
                s.graphics.drawRect(posX, posY, 1, 1);
            }
            xx++;
            if(xx >= 7){
                xx = 0;
                yy++;
            }
        }
        s.x = xpos;
        s.y = ypos;
        parent.addChild(s);
        return s;
    }
}