/**
 * Ginny Effect 3D
 * 
 * Photo by 
 * http://www.flickr.com/photos/88403964@N00/2662752839/ (by clockmaker)
 */
package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.utils.*;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.ITween;
    import org.papervision3d.core.geom.renderables.Vertex3D;
    import org.papervision3d.core.utils.Mouse3D;
    import org.papervision3d.events.InteractiveScene3DEvent;
    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.objects.primitives.Plane;
    import org.papervision3d.render.QuadrantRenderEngine;
    import org.papervision3d.view.BasicView;
    import com.bit101.components.*;
    
    [SWF(frameRate = 30)]
    public class Main extends BasicView {
            
        private const IMAGE_URL:String = "http://farm4.static.flickr.com/3190/2662752839_249c6642b1.jpg";
        private const IMG_W:Number = 500 * 2;
        private const IMG_H:Number = 375 * 2;
        private const SEGMENT:int = 12;
        private const PLANE_Y:int = 500;
        private const FLOOR_LENGTH:int = 3000;
        private var loader:Loader;
        private var isHide:Boolean = false;
        private var isShift:Boolean = false;
        private var plane:Plane;
        private var floorPlane:Plane;
        private var tween:ITween;
        private var vertexs:Array = [];
          
        public function Main():void {
            // init
            super(0, 0, true, true);
            stage.quality = StageQuality.LOW;
            
            // 3dの初期化
            Mouse3D.enabled = true;
            renderer = new QuadrantRenderEngine(QuadrantRenderEngine.ALL_FILTERS);
            viewport.opaqueBackground = 0x0;
                    
            // load
            var context:LoaderContext = new LoaderContext(true);
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, compHandler);
            loader.load(new URLRequest(IMAGE_URL), context);
            
            // とりあえず説明
            new Label(this, 360, 440, "PLEASE CLICK STAGE");
        }
        
        private function compHandler(e:Event):void {
            // 写真のマテリアル
            var material:BitmapMaterial = new BitmapMaterial(Bitmap(loader.content).bitmapData);
            plane = new Plane(material, IMG_W, IMG_H, SEGMENT - 1, SEGMENT - 1);
            scene.addChild(plane);
            
            // 各頂点の座標を配列に格納しておく
            var i:int = 0, xx:int, yy:int;
            for (xx = 0; xx < SEGMENT; xx++) {
                vertexs[xx] = [];
                for (yy = 0; yy < SEGMENT; yy++) {
                    var v:Vertex3D = plane.geometry.vertices[i++];
                    vertexs[xx][yy] = { x : v.x, y : v.y, z : v.z };
                }
            }
            
            // 地面を作る: タイルの作り方はrectさんのを参考
            var bmd:BitmapData = new BitmapData(2, 2, false);
            bmd.setPixel(0, 0, 0xDDDDDD);
            bmd.setPixel(0, 1, 0xFFFFFF);
            bmd.setPixel(1, 0, 0xFFFFFF);
            bmd.setPixel(1, 1, 0xDDDDDD);
            
            var floorMat:BitmapMaterial = new BitmapMaterial(bmd, true);
            floorMat.tiled = true;
            floorMat.maxU = 20, floorMat.maxV = 20;
            floorMat.interactive = true;
            
            floorPlane = new Plane(floorMat, FLOOR_LENGTH, FLOOR_LENGTH, 5, 5);
            scene.addChild(floorPlane);
            floorPlane.rotationX = 90;
            floorPlane.y = - PLANE_Y;
            floorPlane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, clickHandler);
            
            // いろいろイベントを登録
            addEventListener(Event.ENTER_FRAME, loop);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            startRendering();
        }
        
        private function clickHandler(e:InteractiveScene3DEvent):void {
            // トゥイーン実行中なら終了
            if (tween) if (tween.isPlaying) return;
               
            // クリックした点のワールド座標を取得
            var vx:Number = viewport.interactiveSceneManager.mouse3D.x;
            var vy:Number = viewport.interactiveSceneManager.mouse3D.y;
            var vz:Number = viewport.interactiveSceneManager.mouse3D.z;
            
            // いろいろ変数
            var tweens:Array = [];
            var i:int = 0, xx:int, yy:int, delay:Number, distance:Number;
            
            // 各頂点ごとにトゥイーンを設定
            for (xx = 0; xx < SEGMENT; xx++) {
                for (yy = 0; yy < SEGMENT; yy++) {
                    // 各頂点のオリジナルの位置
                    var bx:Number = vertexs[xx][yy].x;
                    var by:Number = vertexs[xx][yy].y;
                    var bz:Number = vertexs[xx][yy].z;
                     
                    // クリックした点までの距離を測定
                    distance = Math.sqrt((bx - vx) * (bx - vx) + (by - vy) * (by - vy) + (bz - vz) * (bz - vz));
                         
                    // 遅延を設定
                    delay = distance / 1500;
                    
                    // 頂点制御 PV3Dだと楽チン
                    var v:Vertex3D = plane.geometry.vertices[i++];
                    
                    // BetweenAS3
                    tweens.push(
                        BetweenAS3.delay(
                            BetweenAS3.tween(v,
                                { x : vx, y : vy, z : vz },
                                { x : bx, y : by, z : bz },
                                delay, Cubic.easeIn),
                            delay / 2)
                        );
                }
            }
            
            // ごにょごにょ
            tween = BetweenAS3.parallelTweens(tweens);
            if (isHide) tween = BetweenAS3.reverse(tween);
            if (isShift) tween = BetweenAS3.scale(tween, 5);
            tween.play();
            
            isHide = !isHide;
        }
        
        private function loop(e:Event = null):void {
            // 角度に応じてカメラの位置を設定
            camera.x = 1000 * Math.sin(getTimer() / 3000);
            camera.y = 500 * Math.sin(getTimer() / 2500) + 800;
            camera.z = -750;
        }
        
        /**
         * Shiftキーを押してるとスローモーションになる
         * macの挙動と同じように
         */
        private function keyUpHandler(e:KeyboardEvent):void {
            if(e.keyCode == 16) isShift = false;
        }
        
        private function keyDownHandler(e:KeyboardEvent):void {
            if(e.keyCode == 16) isShift = true;
        }
    }
}
