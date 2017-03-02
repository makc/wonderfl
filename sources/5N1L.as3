// forked from otherone's StarDustテスト
package {
    import flash.display.*;
    import flash.events.Event;
    import flash.filters.GlowFilter;
    import flash.geom.Rectangle;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.filters.BlurFilter;
    import net.hires.debug.Stats;
    import idv.cjcat.stardust.common.clocks.SteadyClock;
    import idv.cjcat.stardust.common.emitters.Emitter;
    import idv.cjcat.stardust.common.renderers.Renderer;
    import idv.cjcat.stardust.twoD.renderers.BitmapRenderer;
    import frocessing.color.ColorHSV;

    [SWF(width = 465,height = 465,frameRate = 60,backgroundColor = 0)]
    
    public class Main extends Sprite {
        protected var emitter:Emitter;// エミッター
        protected var renderer:Renderer;// レンダラー
        private const stw:uint = stage.stageWidth,sth:uint = stage.stageHeight;
        private var _hsv:ColorHSV;
        private var _bmd:BitmapData;
        private var _blurBmd:BitmapData;
        private var _ctf:ColorTransform;
        
        public function Main() {
            _hsv = new ColorHSV(0, .8, .95);
            _bmd = new BitmapData(465, 465, false, 0);
            _ctf = new ColorTransform(.95, .9, .7);
            //
            var bm:Bitmap = new Bitmap(_bmd);
            var bbm:Bitmap = new Bitmap(_blurBmd = _bmd.clone());
            bbm.blendMode = "add"
            addChild(bm)
            addChild(bbm)
            addChild(new Stats());
            //
            // パーティクルシステムの構築
            //
            // [1]clockを作成 [2]エミッターを作成
            emitter = new MyEmitter(new SteadyClock(6)); // エミッターに1フレームに発生させたい数値を指定
            // [3]レンダラーを作成 (MCを指定)
            renderer = new BitmapRenderer(_bmd);
            // [4]レンダラーにエミッターを追加
            renderer.addEmitter(emitter);
            //
            addEventListener(Event.ENTER_FRAME, loop);
        }
            
        private function loop(e:Event):void {
            _ctf.redMultiplier = (_hsv.value >> 16 & 0xff) / 255;
            _ctf.greenMultiplier = (_hsv.value >> 8 & 0xff) / 255;
            _ctf.blueMultiplier = (_hsv.value & 0xff) / 255
            //
            _bmd.colorTransform(_bmd.rect, _ctf)
            _bmd.applyFilter(_bmd, _bmd.rect, new Point(), new BlurFilter(8, 8, 3))
            _blurBmd.copyPixels(_bmd, _bmd.rect, new Point())
            //
            MyEmitter(emitter).point.x += (mouseX - MyEmitter(emitter).point.x) * .1;
            MyEmitter(emitter).point.y += (mouseY - MyEmitter(emitter).point.y) * .1;
            //
            _hsv.h++;
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

class MyEmitter extends Emitter2D {
    public var point:SinglePoint = new SinglePoint(); // パーティクルの発生位置
    
    public function MyEmitter(clock:Clock = null) {
        //-- パーティクルシステムの構築
        super(clock);
        // [5]イニシャライザーを登録;
        // パーティクルのアイテムを指定
        addInitializer(new DisplayObjectClass(MyCircle));
        // パーティクルにかかる力を指定;
        addInitializer(new Velocity(new LazySectorZone(0.1, 0)));
        // パーティクルのライフ(生存)を指定;
        addInitializer(new Life(new UniformRandom(40, 20)));
        addInitializer(new Position(point));        

        // [6]アクションを登録
        addAction(new AlphaCurve(20,40));
        
        addAction(new Age());
        // 寿命を有効化;
        addAction(new DeathLife());
        // 消えるを有効化;
        addAction(new Accelerate(0.05));
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
        gravity.addField(new UniformField( 0, 0.01)); // x , y
        addAction(gravity);
    }
}

import flash.display.Shape;
class MyCircle extends Shape {
    public function MyCircle() {
        graphics.beginFill (0xFFFFFF,1.0);
        graphics.drawCircle(0, 0, Math.random()*5 | 0);
        graphics.endFill()
    }
}