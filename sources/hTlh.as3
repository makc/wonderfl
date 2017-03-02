/**
 * Spriral Particles
 * @author Yasu
 * @see http://clockmaker.jp/
 *
 * refered from
 * http://www.ayatoweb.com/ae_lab/lab22.html
 * http://wonderfl.net/c/qTwn
 */
package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.BlurFilter;
    import flash.geom.*;
    import flash.net.URLRequest;
    import flash.utils.getTimer;
    import idv.cjcat.stardust.common.clocks.SteadyClock;
    import org.papervision3d.core.effects.utils.BitmapClearMode;
    import org.papervision3d.core.geom.Pixels;
    import org.papervision3d.core.geom.renderables.Pixel3D;
    import org.papervision3d.core.math.Number3D;
    import org.papervision3d.materials.WireframeMaterial;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.view.layer.BitmapEffectLayer;
    
    /**
     * スターダストを使った、3Dパーティクルデモ
     * @author yasu
     */
    [SWF(width=465, height=465, frameRate=60, backgroundColor=0)]
    public class Main extends BasicView {
        // コンストラクタ
        public function Main() {
            super(465, 465, false);
            // 背景
            stage.quality = StageQuality.LOW; //画質を低に
            var loader:Loader = new Loader();
            loader.load(new URLRequest("http://clockmaker.jp/labs/091021_checkmate/assets/bg.png"));
            addChildAt(loader, 0);
            cerateFullScreenBtn();
            // Pixels用
            _bel = new BitmapEffectLayer(viewport, 465, 465, true, 0, BitmapClearMode.CLEAR_PRE, true, true);
            viewport.containerSprite.addLayer(_bel);
            // Pixelsの作成
            _pixels = new Pixels(_bel);
            scene.addChild(_pixels);
            // 3Dのパーツを配置
            earth.y = -1000;
            earth.rotationX = 90;
            earth.rotationY = 45;
            scene.addChild(earth);
            // 演出用のパーティクルを生成(彗星)
            var star:Array = [ 0xFF666666, 0xFFFFCCCC, 0xFFFFCC66 ]
            for (var i:int = 0; i < 100; i++) {
                _pixels.addPixel3D(new Pixel3D(star[ star.length * Math.random() | 0 ],
                    10000 * (Math.random() - 0.5),
                    10000 * (Math.random()) - 1000,
                    10000 * (Math.random() - 0.5)));
            }
            // パーティクルシステムの構築
            _emitter = new PV3DPixelsEmitter3D(new SteadyClock(5)); // エミッターに1フレームに発生させたい数値を指定
            _particleRenderer = new PV3DPixelsRenderer(_pixels);
            _particleRenderer.addEmitter(_emitter);
            // エンターフレームイベントの登録
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            // キラキラロジック
            _bmd = new BitmapData(465 / 4, 465 / 4, false, 0x000000);
            var bmp:Bitmap = new Bitmap(_bmd, PixelSnapping.NEVER, false);
            bmp.scaleX = bmp.scaleY = 4;
            bmp.blendMode = BlendMode.ADD;
            addChild(bmp);
            _matrix = new Matrix();
            _matrix.translate(-viewport.width / 2, -viewport.height / 2);
            _matrix.scale(0.25, 0.25);
            _matrix.translate(viewport.width / 4, viewport.height / 4);
            // ぶらー
            _bmdForBlur = new BitmapData(465, 465, false, 0x000000);
            var bmp2:Bitmap = new Bitmap(_bmdForBlur);
            bmp2.blendMode = BlendMode.ADD;
            addChild(bmp2);
            _matrixForBlur = new Matrix();
            _matrixForBlur.translate(viewport.width / 2, viewport.height / 2);
        }
        private const BLUR:BlurFilter = new BlurFilter(4,4, 3);
        private const ZERO_POINT:Point = new Point(0, 0);
        private var _bel:BitmapEffectLayer;
        private var _bmd:BitmapData;
        private var _bmdForBlur:BitmapData;
        private var _emitter:PV3DPixelsEmitter3D;
        private var _matrix:Matrix;
        private var _matrixForBlur:Matrix;
        private var _particleRenderer:PV3DPixelsRenderer;
        private var _pixels:Pixels;
        private var earth:Plane = new Plane(new WireframeMaterial(0xFFFFFF, 0.1), 5000, 5000, 6, 6);
        
        // エンターフレームイベント
        private function enterFrameHandler(e:Event):void {
            var time:Number = getTimer();
            var rot:Number = time / 3.5;
            var distance:Number = (time * 0.5) % 4000 - 2000;
            // 円周上を動いているかのようにみせる
            _emitter.point.x = 400 * Math.cos(-rot * Number3D.toRADIANS);
            _emitter.point.y = 400 * Math.sin(-rot * Number3D.toRADIANS);
            _emitter.point.z = distance;
            // パーティクルの方向を変える
            _emitter.sphereCap.rotationX = 90;
            _emitter.sphereCap.rotationZ = -rot - 90;
            // カメラが演習を回っているように設定しています
            camera.x = 2000 * Math.sin(time / 3000);
            camera.y = 800 * Math.sin(time / 2000);
            camera.z = 2000 * Math.cos(time / 3000);
            // カメラが近づいたり離れたりする演出
            camera.zoom = 15 * Math.sin(time / 4000) + 40;
            // エミッター更新
            _emitter.step();
            // キラキラ
            _bmd.lock();
            _bmd.fillRect(_bmd.rect, 0x0);
            _bmd.draw(_bel, _matrix);
            _bmd.unlock();
            // ぶらー
            _bmdForBlur.lock();
            _bmdForBlur.draw(_bel, _matrixForBlur,null,BlendMode.ADD);
            _bmdForBlur.applyFilter(_bmdForBlur, _bmdForBlur.rect, ZERO_POINT, BLUR);
            _bmdForBlur.unlock();
            // Papervision3Dのレンダリング
            singleRender();
        }
        
        private function cerateFullScreenBtn():void {
            var btn:Sprite = new Sprite();
            btn.buttonMode = true;
            btn.graphics.beginFill(0x808080, 0);
            btn.graphics.drawRect(0, 0, 50, 30);
            btn.graphics.endFill();
            btn.graphics.beginFill(0x808080, 0.5);
            btn.graphics.drawRect(6, 6, 39, 19);
            btn.graphics.endFill();
            btn.graphics.lineStyle(1, 0x808080, 0.5);
            btn.graphics.drawRect(0.5, 0.5, 50, 30);
            btn.x = 3;
            btn.y = 430;
            btn.addEventListener(MouseEvent.CLICK, btn_clickHandler);
            addChild(btn);
            stage.fullScreenSourceRect = new Rectangle(0, 0, 465, 465);
        }
        
        private function btn_clickHandler(event:MouseEvent):void {
            stage.displayState = stage.displayState == StageDisplayState.FULL_SCREEN
                ? StageDisplayState.NORMAL
                : stage.displayState = StageDisplayState.FULL_SCREEN;
        }
    }
}
import frocessing.color.ColorHSV;
import idv.cjcat.stardust.common.actions.*;
import idv.cjcat.stardust.common.clocks.Clock;
import idv.cjcat.stardust.common.events.EmitterEvent;
import idv.cjcat.stardust.common.initializers.Life;
import idv.cjcat.stardust.common.math.UniformRandom;
import idv.cjcat.stardust.common.particles.ParticleIterator;
import idv.cjcat.stardust.common.renderers.Renderer;
import idv.cjcat.stardust.threeD.actions.*;
import idv.cjcat.stardust.threeD.emitters.Emitter3D;
import idv.cjcat.stardust.threeD.initializers.*;
import idv.cjcat.stardust.threeD.particles.Particle3D;
import idv.cjcat.stardust.threeD.zones.*;
import org.papervision3d.core.geom.Pixels;
import org.papervision3d.core.geom.renderables.Pixel3D;

/**
 * PV3DPixelsRenderer は Pixels を Stardust でレンダリングするためのクラスです。
 */
internal final class PV3DPixelsRenderer extends Renderer {
    public function PV3DPixelsRenderer(container:Pixels = null) {
        this._container = container;
    }
    private var _container:Pixels;
    
    override protected function particlesAdded(e:EmitterEvent):void {
        if (!_container)
            return;
        var particle:Particle3D;
        var iter:ParticleIterator = e.particles.getIterator();
        while (particle = iter.particle as Particle3D) {
            var pixel:Pixel3D = particle.target as Pixel3D;
            _container.addPixel3D(particle.target);
            particle.dictionary[ PV3DPixelsRenderer ] = _container;
            iter.next();
        }
    }
    
    override protected function particlesRemoved(e:EmitterEvent):void {
        var particle:Particle3D;
        var iter:ParticleIterator = e.particles.getIterator();
        while (particle = iter.particle as Particle3D) {
            var pixel:Pixel3D = particle.target as Pixel3D;
            var container:Pixels = particle.dictionary[ PV3DPixelsRenderer ] as Pixels;
            container.removePixel3D(pixel);
            iter.next();
        }
    }
    
    override protected function render(e:EmitterEvent):void {
        var particle:Particle3D;
        var iter:ParticleIterator = e.particles.getIterator();
        while (particle = iter.particle as Particle3D) {
            var pixel:Pixel3D = particle.target as Pixel3D;
            pixel.x = particle.x;
            pixel.y = particle.y;
            pixel.z = particle.z;
            iter.next();
        }
    }
}
/**
 * PV3DPixelsEmitter3D は 3D パーティクルを発生させるためのエミッターです。
 */
internal final class PV3DPixelsEmitter3D extends Emitter3D {
    public var point:SinglePoint3D = new SinglePoint3D(); // パーティクルの発生位置
    public var sphereCap:SphereCap = new SphereCap(0, 0, 0, 1, 2, 50); // パーティクルの拡散
    public function PV3DPixelsEmitter3D(clock:Clock = null) {
        super(clock);
        // パーティクルの属性を定義
        addInitializer(new Position3D(point));　// 発生位置
        addInitializer(new DisplayObjectClass3D(MyPixel3D));
        addInitializer(new Life(new UniformRandom(100, 60)));
        addInitializer(new Velocity3D(sphereCap));
        
        // パーティクルのアクションを定義
        addAction(new Age()); // 寿命を有効化
        addAction(new DeathLife()); // 消えるを有効化
        addAction(new Accelerate3D(0.04)); // 加速を有効化
        addAction(new Move3D()); // 移動を有効化
    }
}
/**
 * MyPixel3D は Pixel3D の拡張クラスです。
 * Stardust のイニシャライザで初期化できるようにコンストラクタの引数をなしにしています。
 */
internal final class MyPixel3D extends Pixel3D {
    private static var hsv:ColorHSV = new ColorHSV(0, 1, 1);
    
    public function MyPixel3D() {
        hsv.h += 0.5;
        var col:ColorHSV = hsv.clone();
        col.h += 10 * Math.random();
        var rand:Number = Math.random();
        col.s -= 0.9 * (rand * rand);
        super(col.value32);
    }
}