/*
   Sakura Particle with Stardust - FlaMi -

   Flashで花見気分を味わう
   年度末で忙しく桜を見に行けない人たちへ…

   inspired by Stardust Demo
   http://code.google.com/p/stardust-particle-engine/

    updated:
    2011/03/17 - update for Stardust 1.3.186
 */
package {
    import flash.display.*;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    import idv.cjcat.stardust.common.clocks.SteadyClock;
    import idv.cjcat.stardust.threeD.handlers.DisplayObjectHandler3D;
    import idv.cjcat.stardust.threeD.initializers.DisplayObjectClass3D;
    
    import jp.progression.commands.lists.SerialList;
    import jp.progression.commands.net.LoadBitmapData;
    
    [SWF(width="465", height="465", frameRate="60")]
    public class Main extends Sprite {
        public static var petelBmd:BitmapData;
        private static const CONTEXT:LoaderContext = new LoaderContext(true);
        
        public function Main() {
            addChild(_container);
            addChild(new Bitmap(_bmd));
            stage.quality = StageQuality.LOW;
            // パーティクルハンドラーの作成
            var handler:DisplayObjectHandler3D = new DisplayObjectHandler3D(_container);
            handler.camera.position.x = 500;
            handler.camera.position.y = -200;
            handler.camera.position.z = -500;
            handler.camera.direction.set(-500, 0, 0);
            // エミッターの作成
            _emitter = new SakuraEmitter(new SteadyClock(1));
            _emitter.particleHandler = handler
            // 外部ファイル読み込み
            new SerialList(null, new LoadBitmapData(new URLRequest("http://assets.wonderfl.net/images/related_images/3/33/331b/331bb452e206976414f4577fb6709f48ac822ef3"), { context: CONTEXT }), 
                function():void {
                    addChildAt(new Bitmap(this.latestData as BitmapData), 0);
                }, 
                new LoadBitmapData(new URLRequest("http://assets.wonderfl.net/images/related_images/b/bd/bdae/bdaee24a0702bb49aeef880cbdc56729d78dc22b"), { context: CONTEXT }),
                function():void {
                    petelBmd = this.latestData as BitmapData;
                    addEventListener(Event.ENTER_FRAME, _onEnterFrame);
                    stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
                    stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
                }
            ).execute();
        }
        private var _bmd:BitmapData = new BitmapData(465, 465, true, 0x00000000);
        private var _container:Sprite = new Sprite();
        private var _emitter:SakuraEmitter;
        private var _stepTimeInterval:Number = 1;
        
        private function _onEnterFrame(event:Event):void {
            _emitter.step(_stepTimeInterval);
            _bmd.colorTransform(_bmd.rect, new ColorTransform(1, 1, 1, 0.3));
            _bmd.draw(_container);
        }
        
        private function _onMouseDown(e:Event):void {
            _stepTimeInterval = 0.04;
            stage.quality = StageQuality.MEDIUM;
        }
        
        private function _onMouseUp(e:Event):void {
            _stepTimeInterval = 1;
            stage.quality = StageQuality.LOW;
        }
    }
}
import flash.display.*;

import idv.cjcat.stardust.common.actions.Age;
import idv.cjcat.stardust.common.actions.AlphaCurve;
import idv.cjcat.stardust.common.actions.DeathLife;
import idv.cjcat.stardust.common.clocks.Clock;
import idv.cjcat.stardust.common.emitters.Emitter;
import idv.cjcat.stardust.common.initializers.Life;
import idv.cjcat.stardust.common.initializers.Scale;
import idv.cjcat.stardust.common.math.UniformRandom;
import idv.cjcat.stardust.common.particles.Particle;
import idv.cjcat.stardust.threeD.actions.Move3D;
import idv.cjcat.stardust.threeD.actions.StardustSpriteUpdate3D;
import idv.cjcat.stardust.threeD.emitters.Emitter3D;
import idv.cjcat.stardust.threeD.initializers.DisplayObjectClass3D;
import idv.cjcat.stardust.threeD.initializers.Position3D;
import idv.cjcat.stardust.threeD.initializers.Velocity3D;
import idv.cjcat.stardust.threeD.zones.CubeZone;
import idv.cjcat.stardust.twoD.display.StardustSprite;

class SakuraEmitter extends Emitter3D {
    public function SakuraEmitter(clock:Clock) {
        super(clock);
        //initializers
        addInitializer(new DisplayObjectClass3D(SakuraPetalWrapper));
        addInitializer(new Life(new UniformRandom(100, 40)));
        addInitializer(new Position3D(new CubeZone(-200, -900, -200, 1600, 300, 1600)));
        addInitializer(new Velocity3D(new CubeZone(-30, 10, -30, 30, 10, 30)));
        addInitializer(new Scale(new UniformRandom(1, 0.3)));
        //actions
        addAction(new Age());
        addAction(new Move3D());
        addAction(new DeathLife());
        addAction(new StardustSpriteUpdate3D());
        addAction(new AlphaCurve(15, 15));
    }
}

class SakuraPetalWrapper extends StardustSprite {
    public function SakuraPetalWrapper() {
        phase = 0;
        petel = new Bitmap(Main.petelBmd);
        innerWrapper = new Sprite();
        innerWrapper.addChild(petel);
        petel.rotation = Math.random() * 360;
        rotation *= Math.random() * 360;
        selfOmega = Math.random() * 10;
        petalOmega = Math.random() * 10;
        scaleXRate = Math.random() * 0.03 + 0.07;
        addChild(innerWrapper);
    }
    private var innerWrapper:Sprite;
    private var petalOmega:Number;
    private var petel:Bitmap;
    private var phase:Number;
    private var scaleXRate:Number;
    private var selfOmega:Number;
    
    override public function update(emitter:Emitter, particle:Particle, time:Number):void {
        petel.rotation += petalOmega * time;
        rotation += selfOmega * time;
        phase += time;
        innerWrapper.scaleX = Math.sin(scaleXRate * phase);
    }
}