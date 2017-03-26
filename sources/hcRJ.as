/**
 * 【 BetweenAS3 を使ってタイムリマップ 】
 *
 * トゥイーンの一部分の微少時間を拡大し、動きに緩急をつける
 * コードも 60 行と短くしているので、参考になれば幸いです。
 *
 * 技術的な解説は次の記事で
 * http://clockmaker.jp/blog/2009/07/betweenas3/
 */
package {
    import flash.events.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.special.CompositeMaterial;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.view.BasicView;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    import org.libspark.betweenas3.easing.*;
    
    public class Main extends BasicView { 
    
        static private const OBJ_NUM :int = 20; // オブジェクトの個数
        public var rot:Number = 0; // カメラの円運動用
        
        public function Main() {
            // ベースのトゥイーン生成
            var baseTween:ITween;
            
            // カメラの動きをTweenで作る
            baseTween = BetweenAS3.parallel(
                BetweenAS3.tween(this, { rot:0 }, { rot:135 }, 7, Cubic.easeInOut),
                BetweenAS3.tween(camera, { y:400, zoom:4 }, { y:-100, zoom:1 }, 6, Cubic.easeInOut)
            );
            
            for (var i:int = 0; i < OBJ_NUM; i++) {
                // 立方体を作る
                var mt:CompositeMaterial = new CompositeMaterial();
                mt.addMaterial( new ColorMaterial(0x0, 0.6) );
                mt.addMaterial( new WireframeMaterial(0xFF0000) );
                var cube:Cube = scene.addChild(new Cube(new MaterialsList( { all:mt } ), 100, 100, 100)) as Cube;
                
                // ランダムに立方体を配置
                cube.x = 1500 * Math.random() - 750;
                cube.z = 1500 * Math.random() - 750;
                
                // 秒数
                var sec:Number = 2 * Math.random() + 3;
                
                // 立方体の落下する動き
                baseTween = BetweenAS3.parallel(
                    BetweenAS3.tween(cube, { y:50 }, { y:2000 }, sec, Bounce.easeOut),
                    baseTween
                );
            }
            
            // お待ちかね！　BetweenAS3によるタイムリマップ
            // [Step.1] まずはTweenを切り出す
            var tw1:ITween = BetweenAS3.slice(baseTween, 0.0, 0.45, true); // 0%から45%までを切り出し
            var tw2:ITween = BetweenAS3.slice(baseTween, 0.45, 0.5, true); // 45%から50%までを切り出し
            var tw3:ITween = BetweenAS3.slice(baseTween, 0.5, 1.0, true); // 50%から100%までを切り出し
            
            // [Step.2] Tweenの時間を加工する
            tw1 = BetweenAS3.scale(tw1, 0.5); // 0.5倍
            tw2 = BetweenAS3.scale(tw2, 15); // 15倍
            tw3 = BetweenAS3.scale(tw3, 0.5); // 0.5倍
            
            // [Step.3] 切り出したTweenをがちゃんこする
            var totalTween:ITween = BetweenAS3.serial(tw1, tw2, tw3);
            
            // 再生
            totalTween.play();
            totalTween.stopOnComplete = false; // ループ設定
            
            // -- 以下、初期化関連
            // Flashの初期設定
            stage.quality = "medium";
            stage.frameRate = 60;
            
            // pv3dの初期設定
            viewport.opaqueBackground = 0x0;
            camera.focus = 200;
            
            // レンダリング関係
            startRendering();
            
            // ついでに地面
            var earth:Plane = scene.addChild(new Plane(new WireframeMaterial(0x666666), 5000, 5000, 15, 15)) as Plane;
            earth.rotationX = 90;
        }
        
        override protected function onRenderTick(event:Event = null):void {
            // カメラの回転(BetweenAS3で制御するため)
            camera.x = 1000 * Math.cos(rot * Math.PI / 180);
            camera.z = 1000 * Math.sin(rot * Math.PI / 180);
            
            super.onRenderTick(event);
        }
    }
}
