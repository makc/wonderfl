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
     * 前から気になってた事があって、Wonderfl は色んな作品があるけど作品同士のつながりがないのが気になっていた。
     * 例えば、パーツだけ作って読み込んでロードするだけで使える[素材]を作るとか。
     * あと Fork することで何かに参加できるようにすればもっと面白い事になって行きそうなきがする。
     * チェックメイトやJAMのような方法ではなく、Forkされたもの全てが一つの作品を作るというか。
     * これからもチェックメイトやJAM以外にも[企画]タグや[素材]タグが増えていくといいなぁ。
     * @mxmlc -o bin/loaderchild.swf -load-config+=obj\wondeflqConfig.xml
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
            if(stage) demo(null)
            else addEventListener(Event.ADDED_TO_STAGE, demo);
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
            disp = new Butterfly3D();
            addChild(disp);
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
            start(1);
        }
    }
}

import flash.display.*;
import flash.events.*;
import flash.utils.*;
import flash.net.*;
import flash.system.*;

import org.papervision3d.core.effects.view.ReflectionView;
import org.papervision3d.cameras.*;
import org.papervision3d.materials.*;
import org.papervision3d.objects.*;
import org.papervision3d.objects.primitives.*

/**
 * Butterfly3Dクラス(ReflectionViewを継承することで反射面が表現できます)
 */
internal class Butterfly3D extends ReflectionView
{    
    private var butterfly:DisplayObject3D;
    /**
     * Constructor
     */
    public function Butterfly3D()
    {
        super(440,440,false);
        opaqueBackground = 0x0;
                
        Security.loadPolicyFile("http://assets.wonderfl.net/crossdomain.xml");

        //　オブジェクトを作成します
        var earth:Plane = new Plane(new WireframeMaterial(0xFFFFFF, .5), 1000, 1000, 5, 5);
        
        // オブジェクトの角度を調整します
        
        earth.rotationX = 90;
        
        // 3D表示リストに追加します
        scene.addChild(earth);
        
        // 反射面の高さを設定します
        surfaceHeight = 0;
        
        // 毎フレームの演出を設定します(匿名関数で楽して書いてます)
        addEventListener(Event.ENTER_FRAME, function(event:Event):void
        {   
            // カメラが演習を回っているように設定しています
            camera.x = 500 * Math.sin(getTimer() / 2000);
            camera.y = 600;
            camera.z = 500 * Math.cos(getTimer() / 2000);
            
            // カメラが近づいたり離れたりする演出
            camera.zoom = 10 * Math.sin(getTimer() / 2000) + 40;
            
            // ReflectionViewのレンダリング
            singleRender(); 
        });
    }
    
    /**
     * 蝶を作成します
     * @return 蝶(DisplayObject3D型)
     */
    private function createButterfly():DisplayObject3D
    {
        // 蝶のコンテナーを作成
        var butterfly :DisplayObject3D = new DisplayObject3D();
        
        // 蝶の羽を作成
        var leftWing  :DisplayObject3D = new DisplayObject3D();
        var rightWing :DisplayObject3D = new DisplayObject3D();
        
        // 蝶の羽の素材を作成(PNGファイルを読み込み)
        var mat:BitmapFileMaterial = new BitmapFileMaterial("http://assets.wonderfl.net/images/related_images/a/ac/ac09/ac09a2ffd00b54f2779ab5cc3ebfd1114e204ec1");
        mat.doubleSided = true;
        
        // 蝶の羽を貼り付ける平面を作成
        var leftWingPlane  :Plane = new Plane(mat, 200, 200, 1, 1);
        var rightWingPlane :Plane = new Plane(mat, 200, 200, 1, 1);
        
        // 蝶の羽平面の座標や角度を調整
        leftWingPlane.scaleX = -1;
        leftWingPlane.x  = -100;
        rightWingPlane.x = 100;
        
        // 蝶の羽をコンテナーの表示リストに追加
        leftWing.addChild(leftWingPlane);
        rightWing.addChild(rightWingPlane);
        butterfly.addChild(leftWing);
        butterfly.addChild(rightWing);
        
        // アニメーションの設定
        addEventListener(Event.ENTER_FRAME, function(event:Event):void
        {
            // 蝶の揺らぎを設定しています
            butterfly.y = Math.sin(getTimer() / 200) * -25 + 240;
            
            // 羽が羽ばたく演出
            leftWing.rotationY  = Math.sin(getTimer() / 200) * 60;
            rightWing.rotationY = Math.sin(getTimer() / 200) * -60;
        });
        
        butterfly.rotationX = 90;
        
        // 蝶のインスタンスを返却
        return butterfly;
    }
    
    public function start(level:int):void{
        butterfly = createButterfly();
        scene.addChild(butterfly);
        butterfly.scale = (2 - level/2);
    }
    public function end():void{
        scene.removeChild(butterfly);
    }

}
