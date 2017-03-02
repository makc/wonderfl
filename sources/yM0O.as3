// ドキュメントクラス Main.as
package 
{
    import flash.display.*;
    import flash.events.*;
    import net.hires.debug.Stats;
    import idv.cjcat.stardust.common.clocks.SteadyClock;
    import idv.cjcat.stardust.common.emitters.Emitter;
    import idv.cjcat.stardust.common.renderers.Renderer;
    import idv.cjcat.stardust.twoD.renderers.DisplayObjectRenderer;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;

    [SWF(width = 465,height = 465,frameRate = 48,backgroundColor = 0)]
    public class StarDust_test1 extends Sprite
    {
        protected var emitter:Emitter;// エミッター
        protected var renderer:Renderer;// レンダラー
//        private var canvasBMP:Bitmap;
        private var mc:MovieClip;
        private const stw:uint = stage.stageWidth,sth:uint = stage.stageHeight;

        public function StarDust_test1()
        {
            var myBitmapData:BitmapData = new BitmapData(465, 465, false, 0x0000FF00);            
            var rect:Rectangle = new Rectangle(0,0,465,465);
            myBitmapData.fillRect(rect, 0x000000);
            var bm:Bitmap = new Bitmap(myBitmapData);
            addChild(bm);
            
            addChild( new Stats());
            
            // パーティクルを格納するムービークリップを作成
            mc = new MovieClip();
            mc.x = mc.y = 0;
            addChild(mc);
            
            // パーティクルシステムの構築
            
            // [1]clockを作成        // [2]エミッターを作成
            emitter = new MyEmitter(new SteadyClock(5));// エミッターに1フレームに発生させたい数値を指定
            // [3]レンダラーを作成 (MCを指定)
            renderer = new DisplayObjectRenderer(mc);
            // [4]レンダラーにエミッターを追加
            renderer.addEmitter(emitter);
            
            //
            addEventListener(Event.ENTER_FRAME, loop);
            
            //GlowFilter(color:uint = 0xFF0000, alpha:Number = 1.0, blurX:Number = 6.0, blurY:Number = 6.0, strength:Number = 2, quality:int = 1, inner:Boolean = false, knockout:Boolean = false)
            var param:GlowFilter=new GlowFilter(0xFF0000,1,6,6,2);
            mc.filters=[param];
            
        }
            
        private function loop(e:Event):void
        {
            
            //trace(MyEmitter(emitter).point.x)
            // パーティクルの発生位置をマウス座標にする
            MyEmitter(emitter).point.x += (mouseX - MyEmitter(emitter).point.x) * 0.1;
            MyEmitter(emitter).point.y += (mouseY - MyEmitter(emitter).point.y) * 0.1;
            emitter.step();
        }

    }
}

//エミッター
import idv.cjcat.stardust.common.actions.*;
import idv.cjcat.stardust.common.clocks.*;
import idv.cjcat.stardust.common.initializers.*;
import idv.cjcat.stardust.common.math.*;
import idv.cjcat.stardust.twoD.actions.*;
import idv.cjcat.stardust.twoD.emitters.*;
import idv.cjcat.stardust.twoD.initializers.*;
import idv.cjcat.stardust.twoD.zones.*;
import idv.cjcat.stardust.twoD.renderers.*;
import idv.cjcat.stardust.twoD.fields.BitmapField;
import idv.cjcat.stardust.twoD.fields.UniformField;
/*import org.flintparticles.common.actions.*;
import org.flintparticles.common.counters.*;
import org.flintparticles.common.initializers.*;
import org.flintparticles.common.events.EmitterEvent;
import org.flintparticles.common.energyEasing.*;*/

class MyEmitter extends Emitter2D
{
    public var point:SinglePoint = new SinglePoint();; // パーティクルの発生位置
    public function MyEmitter(clock:Clock = null)
    {
        //-- パーティクルシステムの構築
        super(clock);
        //renderer.addEmitter(emitter);
        // [5]イニシャライザーを登録;
        // パーティクルのアイテムを指定
        addInitializer(new DisplayObjectClass(MyCircle));
        // パーティクルにかかる力を指定;
        addInitializer(new Velocity(new LazySectorZone(0.1, 0)));
        // パーティクルのライフ(生存)を指定;
        addInitializer(new Life(new UniformRandom(40, 0)));
        //addInitializer(new Position(new Line( 200, 200, 200, 200 )));
        addInitializer(new Position(point));        
        //addInitializer(new Alpha( new UniformRandom( 0.5, 0.5)));

        // [6]アクションを登録
        addAction(new AlphaCurve(20,40));
        
        addAction(new Age());
        // 寿命を有効化;
        addAction(new DeathLife());
        // 消えるを有効化;
        addAction(new Accelerate(0.2));
        // 加速を有効化;
        addAction(new Move());
        // 移動を有効化;
        
        var bmpField:BitmapField = new BitmapField();
        bmpField.max = 0.1;
        bmpField.massless = false;
        bmpField.scaleX = bmpField.scaleY = 0;
        
        // 重力;
        var gravity:Gravity = new Gravity();
        gravity.addField(bmpField);
        gravity.addField(new UniformField( 0, 0.05));// x , y
        addAction(gravity);
        /*
            * Age : 寿命を有効化
            * DeathLife : 死滅を有効化
            * AlphaCurve : 透明度変化を有効化
            * ScaleCurve : スケール変化を有効化
            * Move : 移動を有効化
            * Accelerate : 加速を有効化
            * Damping : 減速を有効化
            * Gravity : 重力の速度を有効化
            * DeathZone : パーティクルが死滅する領域を指定
            * AbsoluteDrift : 動きのランダム方向を指定(雨粒のように左右にぶれるような動き)
            * Oriented : Velocityに関係する回転運動を指定
        */
    }

}


//円
import flash.display.*;
class MyCircle extends Sprite {;
public function MyCircle()
{
    //graphics.lineStyle (1, 0xFFFFFF, 1.0);    // 線のスタイル指定
    graphics.beginFill (0xFFFFFF,1.0);    // 面のスタイル設定
    graphics.drawCircle(0,0,Math.random()*4+1);
}
}// 円を描く