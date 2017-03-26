// forked from bkzen's MoviePuzzleTest
package  
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    
    /**
     * [企画]皆で動くパズル作ろうぜ
     * http://wonderfl.net/c/yb0z
     * 前から気になってた事があって、Wonderfl は色んな作品があるけど作品同士のつながりがないのが気になっていた。
     * 例えば、パーツだけ作って読み込んでロードするだけで使える[素材]を作るとか。
     * あと Fork することで何かに参加できるようにすればもっと面白い事になって行きそうなきがする。
     * チェックメイトやJAMのような方法ではなく、Forkされたもの全てが一つの作品を作るというか。
     * これからもチェックメイトやJAM以外にも[企画]タグや[素材]タグが増えていくといいなぁ。
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0x000000", frameRate = "60", width = "465", height = "465")]
    public class MoviePuzzle extends Sprite 
    {
        private static const BG_COLOR: uint = 0x000000;
        private static const FRAME_RATE: uint = 30;
        
        public function MoviePuzzle() 
        {
            // ローダーで読み込まれなかった時の為のデモ用
            addEventListener(Event.ADDED_TO_STAGE, demo);
        }
        
        /**
         * 
         * MoviePuzzle -> MovieJigsawPuzzle
         *         obj["disp"]      : DisplayObject : 描画対象このオブジェクトの440x440の範囲で切り取られて描画されます。
         *         obj["color"]     : uint : 背景色(省略時は0x000000)
         *         obj["frameRate"] : uint : フレームレート(省略時は60)
         *         obj["level"]     : uint : 上限レベル(省略時は1)
         * @param    obj : <Object>
         */
        public function initialize(obj: Object): void
        {
            disp = new Alternativa3DTest();
            obj["disp"]  = disp;
            obj["color"] = BG_COLOR;
            obj["frameRate"]  = FRAME_RATE;
        }
        
        /**
         * スタートする時に呼ばれます。
         * @param    level : uint : 指定レベル : 変える必要があれば。
         */
        public function start(level: uint): void
        {
            Object(disp).start(level);
        }
        
        /**
         * 終了した時に呼ばれます。
         */
        public function end(): void
        {
            Object(disp).end();
        }
        
        private var disp: DisplayObject;
        
        /**
         * デモ用
         * @param    e
         */
        private function demo(e: Event): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, demo);
            //
            var obj: Object = {};
            initialize(obj);
            disp = obj["disp"];
            var col: uint = obj["color"];
            var bmd: BitmapData = new BitmapData(440, 440, false, col);
            var bmp: Bitmap = new Bitmap(bmd, "auto", true);
            start(1);
            addChild(bmp);
            addEventListener(Event.ENTER_FRAME, function(e: Event): void {
                bmd.lock();
                bmd.fillRect(bmd.rect, col);
                bmd.draw(disp);
                bmd.unlock();
            } );
        }
    }
}
import alternativ7.engine3d.containers.BSPContainer;
import alternativ7.engine3d.controllers.SimpleObjectController;
import alternativ7.engine3d.core.Camera3D;
import alternativ7.engine3d.core.Object3D;
import alternativ7.engine3d.core.Sorting;
import alternativ7.engine3d.core.View;
import alternativ7.engine3d.loaders.events.LoaderErrorEvent;
import alternativ7.engine3d.loaders.MaterialLoader;
import alternativ7.engine3d.loaders.ParserCollada;
import alternativ7.engine3d.materials.TextureMaterial;
import alternativ7.engine3d.objects.Mesh;
import com.bit101.components.Label;
import com.bit101.components.Style;
import flash.display.*;
import flash.display.Sprite;
import flash.events.*;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.Quad;
import org.libspark.betweenas3.tweens.ITween;
import org.libspark.betweenas3.tweens.ITweenGroup;
class Alternativa3DTest extends Sprite {
    private var _autoCamera:Object3D = new Object3D();
    private var _cameraMode:int = 0;
    private var _camera:Camera3D;
    private var _controller:SimpleObjectController;
    private var _scene:BSPContainer;
    
    private var _bg:Sprite;
    private var _loadingTxt:Label;
    
    private var _loader:URLLoader;
    private var _parser:ParserCollada;
    private var _mloader:MaterialLoader;
    private var _isInitError:Boolean = false;
    
    private const _PATH_DIR:String = "http://shelter.s377.xrea.com/assets/wonderfl/puzzle/";
    private const _PATH_DAE:String = "model_puzzle.DAE";
    
    /**
     * コンストラクタ
     */
    public function Alternativa3DTest() {
    }
    public function start(level:int):void {
        _camera = new Camera3D();
        _camera.view = new View(465, 465);
        _controller = new SimpleObjectController(this, _camera, 1);
                    
        _scene = new BSPContainer();
        _scene.addChild(_camera);
        
        //画面に配置するもの色々
        _bg = Painter.createColorRect(465, 465, 0x000000);
        Style.LABEL_TEXT = 0xffffff;
        _loadingTxt = new Label(null, 220, 220, "LOADING ");
        
        addChild(_bg);
        addChild(_loadingTxt);
        addChild(_camera.view);
        
        startLoad();
    }
    /**
     * BSPソートとZソートを切り替える
     * @param    enabled
     */
    private function setBSPEnabled(enabled:Boolean):void{
        for (var i:int = 0; i < _scene.numChildren; i++) {
            var m:Mesh = _scene.getChildAt(i) as Mesh;
            if (!m) continue;
            if (["sunlight", "containerbox", "truss"].indexOf(m.name) != -1) {
                m.sorting = (enabled)? Sorting.DYNAMIC_BSP : Sorting.AVERAGE_Z;
            }
        }
    }
    /**
     * Collada読み込み開始
     */
    private function startLoad():void {
        _loader = new URLLoader();
        _loader.addEventListener(Event.COMPLETE, onLoadCollada);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorAsset);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorAsset);
        _loader.load(new URLRequest(_PATH_DIR + _PATH_DAE));
    }
    private function onErrorAsset(e:ErrorEvent):void {
        _loadingTxt.text = "ERROR!";
        _loadingTxt.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 0xFF, 0, 0);
        _isInitError = true;
    }        
    /**
     * Colladaモデル読み込み完了時
     * @param    e
     */
    private function onLoadCollada(e:Event):void {
        //Colladaファイルをパース
        _parser = new ParserCollada();
        _parser.parse(new XML(_loader.data), _PATH_DIR);
        _loadingTxt.visible = false;
        var cameras:Vector.<Object3D> = new Vector.<Object3D>();
        
        for each(var o:Object3D in _parser.objects) {
            if (!o.name) continue;
            _scene.addChild(o);
            if (o is Mesh) {
            } else if (o.name.indexOf("Camera") != -1) {
                //カメラリストに追加
                cameras.push(o);
            }
        }
        setBSPEnabled(true);
        //カメラリストを名前順にソート
        cameras.sort(function(a:Object3D, b:Object3D):int { return int(a.name > b.name) - int(a.name < b.name) } );
        
        //自動カメラの動きをBetweenAS3で設定する
        var list:Array = [];
        var leng:int = cameras.length;
        for (var i:int = 0; i < leng; i++) {
            var cf:Object3D = cameras[i];
            var ct:Object3D = cameras[(i + 1) % leng];
            var it:ITween = BetweenAS3.tween(
                _autoCamera,
                { x:ct.x, y:ct.y, z:ct.z, rotationX:ct.rotationX, rotationY:ct.rotationY, rotationZ:ct.rotationZ },
                { x:cf.x, y:cf.y, z:cf.z, 
                    rotationX:Angle.toNearRadian(cf.rotationX, ct.rotationX),
                    rotationY:Angle.toNearRadian(cf.rotationY, ct.rotationY),
                    rotationZ:Angle.toNearRadian(cf.rotationZ, ct.rotationZ)
                },
                2.5,
                Quad.easeInOut
            );
            it = BetweenAS3.delay(it, 5, 0);
            list.push(it);
        }
        if (leng) {
            var itg:ITweenGroup = BetweenAS3.serialTweens(list);
            itg.stopOnComplete = false;
            itg.play();
            addEventListener(Event.ENTER_FRAME, onTick);
        }
        //全テクスチャのリピートをOFFにする
        for each(var tm:TextureMaterial in _parser.textureMaterials) {
            tm.smooth = false;
            tm.repeat = false;
        }
        //テクスチャ読み込み
        _mloader = new MaterialLoader();
        _mloader.addEventListener(LoaderErrorEvent.LOADER_ERROR, onErrorMaterial);
        _mloader.load(_parser.textureMaterials, new LoaderContext(true));
    }
    private function onErrorMaterial(e:LoaderErrorEvent):void {
    }
    /**
     * 毎フレーム処理
     * @param    e
     */
    private function onTick(e:Event):void {
        //自動カメラモード
        _controller.setObjectPosXYZ(_autoCamera.x, _autoCamera.y, _autoCamera.z);
        _controller.lookAtXYZ(0, 0, 0);
        _camera.rotationX = _autoCamera.rotationX;
        _camera.rotationY = _autoCamera.rotationY;
        _camera.rotationZ = _autoCamera.rotationZ;
        _camera.render();
    }
	public function end():void {
	}
}
class Angle {
    static public const PI2:Number = Math.PI * 2;
    /**
     * baseのラジアン度をnearに一番近くなるよう再設定(+Math.PI*2/-Math.PI*2)する
     */
    static public function toNearRadian(base:Number, near:Number):Number {
        var rad:Number = base - near;
        rad = (rad % PI2 + PI2) % PI2;
        if (rad > Math.PI) rad -= PI2;
        return rad + near;
    }
}
class Painter {
    /**
     * べた塗りスプライト生成
     */
    static public function createColorRect(width:Number, height:Number, color:uint = 0x000000, alpha:Number = 1, x:Number = 0, y:Number = 0):Sprite {
        var sp:Sprite = new Sprite();
        sp.graphics.beginFill(color, alpha);
        sp.graphics.drawRect(0, 0, width, height);
        sp.graphics.endFill();
        sp.x = x;
        sp.y = y;
        return sp;
    }
}