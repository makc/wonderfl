// forked from buccchi's オッス、おらロク！
/**
 * 画面クリックで輪郭線表示+ズーム+スロー再生
 * 再度クリックで元に戻ります
 *
 * ロク（猫）の写真はこちら
 * http://www.flickr.com/photos/40441900@N08/
 * Blenderでモデリング
 */
package {
    import flash.events.Event;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.render.BasicRenderEngine;
    import org.papervision3d.objects.parsers.DAE;
    import org.papervision3d.core.render.filter.FogFilter;
    import org.papervision3d.materials.BitmapFileMaterial;
    import org.papervision3d.materials.special.FogMaterial;
    import org.papervision3d.materials.special.ParticleMaterial;
    import org.papervision3d.objects.special.ParticleField;
    import net.hires.debug.Stats;
    import flash.events.MouseEvent;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.events.TweenEvent;
    
    public class FlashTest extends BasicView {
        private var _camR:Number = 0;
        private var _camY:Number = 0;
        private var _camD:Number = 0;
        private var _rokuLine:DAE;
        private var _mountains:Array;
        private var _it:ITween;
        public var _speed:Number = 4;
        public var _ratio:Number = 1;
        public var _k:Number = 0;
        private var _inks:Vector.<ParticleField>;
        
        public function FlashTest():void {
            addChild( new Stats() );
            
            _inks = new Vector.<ParticleField>();
            //useOwnContainerを有効にすると最前面に表示されてしまう？
            
            //ロク生成
            var roku:DAE = new DAE();
            roku.load("http://buccchi.jp/wonderfl/201002/roku.dae");
            scene.addChild(roku);
            roku.scale = 100;
            roku.y = -200;
            
            //輪郭線表示用オブジェクト生成
            _rokuLine = new DAE();
            _rokuLine.load("http://buccchi.jp/wonderfl/201002/roku_line.dae");
            _rokuLine.scale = 100;
            _rokuLine.y = -200;
            _rokuLine.name = "line";
            
            //山生成
            _mountains = new Array();
            for(var i:uint=0; i<10; i++){
                var mountain:DAE = new DAE();
                mountain.load("http://buccchi.jp/wonderfl/201002/mountain.dae");
                scene.addChild(mountain);
                mountain.x = i*2300;
                mountain.y = 200;
                resetMountain(mountain);
                _mountains.push(mountain);
            }
            
            // レンダリング
            var fg:FogMaterial = new FogMaterial(0xFFFFFF);
            renderer.filter = new FogFilter(fg, 50, 5000, 20000);
            startRendering();
            stage.addEventListener(MouseEvent.CLICK, onClickHandler);
        }
        
        private function onClickHandler(e:MouseEvent):void {
            if(_it != null) _it.stop();
            if(scene.getChildByName("line") == null){
                //ズームイン
                scene.addChild(_rokuLine);
                //墨エフェクト用パーティクル削除
                removeInks();
                //墨エフェクト用パーティクル生成
                var particleMat:ParticleMaterial = new ParticleMaterial(0x0, 1, 1);
                var ink1:ParticleField = new ParticleField(particleMat, 2, 50, 600, 600, 600);
                var ink2:ParticleField = new ParticleField(particleMat, 6, 35, 600, 600, 600);
                var ink3:ParticleField = new ParticleField(particleMat, 25, 15, 800, 800, 800);
                _inks.push(ink1);
                _inks.push(ink2);
                _inks.push(ink3);
                //
                _it = BetweenAS3.parallel(
                            BetweenAS3.tween(this, { _speed:.5, _k:0 }, { _k:18 }, .3, Sine.easeOut),
                            BetweenAS3.tween(this, { _ratio:.4 }, null, .3, Cubic.easeOut));
                for(var j:uint=0; j<_inks.length; j++){
                    scene.addChild(_inks[j]);
                    _inks[j].rotationX = Math.random()*360;
                    _inks[j].rotationY = Math.random()*360;
                    _it = BetweenAS3.parallel(
                            _it,
                            BetweenAS3.tween(_inks[j], { scale:1 }, { scale:.5 }, .3, Cubic.easeOut));
                }
                _it.play();
            }else{
                //スームアウト
                scene.removeChild(_rokuLine);
                _it = BetweenAS3.parallel(
                            BetweenAS3.tween(this, { _speed:4, _k:0 }, { _k:5 }, .5, Sine.easeOut),
                            BetweenAS3.tween(this, { _ratio:1 }, null, .5, Cubic.easeOut));
                for(var i:uint=0; i<_inks.length; i++){
                    _it = BetweenAS3.parallel(
                            _it,
                            BetweenAS3.tween(_inks[i], { scale:_inks[i].scale+15, alpha:0 }, null, .5, Sine.easeOut));
                }
                _it.addEventListener(TweenEvent.COMPLETE, completeZoomOut);
                _it.play();
            }
        }
        
        private function completeZoomOut(e:TweenEvent):void {
            _it.removeEventListener(TweenEvent.COMPLETE, completeZoomOut);
            removeInks();
        }
        
        private function removeInks():void {
            while(_inks.length){
                scene.removeChild(_inks[0]);
                _inks.shift();
            }
        }
        
        private function resetMountain(dae:DAE):void {
            dae.y = -Math.random()*400-1800;
            dae.z = (Math.random()<.5)? Math.random()*5000+1000 : Math.random()*-5000-1000;
            dae.scale = Math.random()*40+150;
            dae.scaleY = Math.random()*120+80;
            dae.rotationY = Math.random()*360;
        }
        
        override protected function onRenderTick(event:Event = null):void {
            for(var i:uint=0; i<_inks.length; i++){
                _inks[i].scale += .001;
            }
            
            //カメラを移動
            _camR -= .3 * _speed +_k;
            _camY += .01 * _speed;
            _camD += .007 * _speed;
            var h:Number =  Math.sin(_camD)*100+2500*_ratio;
            camera.x = h * Math.sin(_camR * Math.PI / 180);
            camera.z = h * Math.cos(_camR * Math.PI / 180);
            camera.y = Math.cos(_camY)*600*_ratio;
            //山を移動
            for(var j:uint=0; j<_mountains.length; j++){
                if(_mountains[j].x > 12000){
                    _mountains[j].x -= 24000;
                    resetMountain(_mountains[j]);
                }else{
                    _mountains[j].x += 50 * _speed;
                }
            }
            
            super.onRenderTick(event);
        }
    }
}