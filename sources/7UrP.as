package {
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    import org.libspark.betweenas3.*;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.utils.*;
    import org.papervision3d.objects.*;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.view.*;
   
    /**
     * パーティクルデモ
     */
    public class ParticleDemo extends BasicView {
        // パーティクル形状を配列として格納
        static private const IMAGE_LIST:Array = [
            [
                [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0], 
                [0,0,0,0,0,1,1,1,1,1,0,0,0,1,1,1,1,1,0,0,0,0], 
                [0,0,0,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0], 
                [0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0], 
                [0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0], 
                [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0], 
                [0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            ],
            [
                [0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0], 
                [0,0,0,1,1,1,0,0,0,1,1,1,1,0,0,0,1,1,1,0,0,0], 
                [0,1,1,1,1,1,1,1,0,0,1,1,0,0,1,1,1,1,1,1,1,0], 
                [0,1,1,1,1,1,1,1,1,0,1,1,0,1,1,1,1,1,1,1,1,0], 
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], 
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], 
                [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1], 
                [0,1,1,1,1,1,1,1,1,0,1,1,0,1,1,1,1,1,1,1,1,0], 
                [0,1,1,1,1,1,1,1,0,0,1,1,0,0,1,1,1,1,1,1,1,0], 
                [0,0,0,1,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1,0,0,0], 
                [0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0], 
                [0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0]
            ]
        ];
        
        private const PIXEL_NUM     :int    = 22;     // 縦・横のピクセル数
        private const MAX_RADIUS    :int    = 20000;  // 空間の大きさ
        private const PLANE_SIZE    :int    = 300;    // パーティクルのサイズ
        private const PLANE_MARGIN  :int    = 50;     // パーティクルの余白
        private var pixelArr        :Array  = [];     // パーティクルを格納する配列
        private var dmyObjs         :Array  = [];     // ダミーの3Dオブジェクト
        private var dmyPixels       :Array  = [];     // ダミーの3Dピクセル
        private var index           :int    = 0;      // 形状のインデックス番号
        
        public function ParticleDemo() {
            // 背景を黒
            viewport.opaqueBackground = 0x0;
            
            // カメラの位置
            camera.z = -MAX_RADIUS;
            
            // 7秒ごとに形状が変化するようにタイマーをセット
            var timer:Timer = new Timer(7000);
            timer.addEventListener(TimerEvent.TIMER, loop);
            timer.start()
            
            // 初期化
            init()
            
            // モーションを100ミリ秒遅らせて開始(直後だとPV3Dの仕様で座標取得ができたないため)
            setTimeout(loop, 100);
            
            // レンダリング
            startRendering()
        }
        
        // 初期化
        private function init():void {
            // 外枠の立方体
            var wireMaterial:WireframeMaterial = new WireframeMaterial(0xFF0000);
            wireMaterial.opposite = true;
            var cube:Cube = new Cube(
                new MaterialsList( { all:wireMaterial } ),
                MAX_RADIUS, MAX_RADIUS, MAX_RADIUS,
                5, 5, 5);
            scene.addChild(cube);
            
            // パーティクルを生成
            var material:ColorMaterial = new ColorMaterial(0xFFFFFF);
            material.doubleSided = true;
            
            pixelArr = [];
            for (var i:int = 0; i < PIXEL_NUM; i++) {
                pixelArr[i] = [];
                for (var j:int = 0; j < PIXEL_NUM; j++ ) {
                    // Planeインスタンスを作成
                    var o:Plane = new Plane(material, PLANE_SIZE, PLANE_SIZE);
                    scene.addChild(o);
                    pixelArr[i][j] = o;
                    
                    // 座標
                    o.x = (+i - PIXEL_NUM / 2) * (PLANE_SIZE + PLANE_MARGIN);
                    o.y = (-j + PIXEL_NUM / 2) * (PLANE_SIZE + PLANE_MARGIN);
                }
            }
            
            // ダミーのピクセルを生成
            dmyPixels = [];
            for (var k:int = 0; k < IMAGE_LIST.length; k++) {
                dmyObjs[k] = new DisplayObject3D();
                dmyObjs[k].x = MAX_RADIUS * (Math.random() - 0.5);
                dmyObjs[k].y = MAX_RADIUS * (Math.random() - 0.5);
                dmyObjs[k].z = MAX_RADIUS * (Math.random() - 0.5);
                scene.addChild(dmyObjs[k]);
                
                dmyPixels[k] = [];
                
                for (i = 0; i < PIXEL_NUM; i++) {
                    dmyPixels[k][i] = [];
                    
                    for (j = 0; j < PIXEL_NUM; j++ ) {
                        dmyPixels[k][i][j] = new DisplayObject3D();
                        //dmyPixels[k][i][j] = new Plane(new WireframeMaterial(), PLANE_SIZE, PLANE_SIZE);
                        dmyPixels[k][i][j].x = (+i - PIXEL_NUM / 2) * (PLANE_SIZE + PLANE_MARGIN);
                        dmyPixels[k][i][j].y = (-j + PIXEL_NUM / 2) * (PLANE_SIZE + PLANE_MARGIN);
                        dmyObjs[k].addChild(dmyPixels[k][i][j]);
                    }
                }
            }
        }
        
        // 7秒ごとに呼び出されるタイマーイベント
        private function loop(e:TimerEvent = null):void {
            // 形状のインデックス番号を更新
            index ++;
            if (index == IMAGE_LIST.length ) index = 0;
            
            // 各パーティクルに対してトゥイーンを設定
            for (var i:int = 0; i < PIXEL_NUM; i++) {
                for (var j:int = 0; j < PIXEL_NUM; j++ ) {
                    // パーティクル
                    var p:DisplayObject3D = pixelArr[i][j];
                    // ダミーオブジェクト
                    var d:DisplayObject3D = dmyPixels[index][j][i];
                    // パーティクルのスケール値
                    var s:Object = IMAGE_LIST[index][i][j];
                    
                    // BetweenAS3でトゥイーン
                    BetweenAS3.delay(
                        BetweenAS3.bezier(p,
                            {
                                x : d.sceneX,
                                y : d.sceneY,
                                z : d.sceneZ,
                                scale : s
                            },
                            null, 
                            {
                                x : MAX_RADIUS * (Math.random() - 0.5),
                                y : MAX_RADIUS * (Math.random() - 0.5),
                                z : MAX_RADIUS * (Math.random() - 0.5)
                            }, 
                            5 + Math.random(), 
                            Quart.easeInOut),
                        Math.random() * 1
                    ).play();
                }
            }
        }
    }
}
