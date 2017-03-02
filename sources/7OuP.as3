// forked from hacker_9vjnvtdz's GYAOS_sample
/**
 * Copyright hacker_9vjnvtdz ( http://wonderfl.net/user/hacker_9vjnvtdz )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/f6f2
 */

/*
    attak
*/
package
{
    import flash.display.*;
    import flash.events.*;
    
    [SWF(width="465", height="465", backgroundColor="#579741", frameRate="30")]

    public class FlashTest extends MovieClip
    {
        private var _battleController:BattleController;
        private var _monsters:Vector.<Monster>;
        private var _monsterIndex:uint = 0;
        private var _loadedCount:Number = 0;
        
        public function FlashTest():void {
            _monsters = new Vector.<Monster>();
            
            var monsterA:Monster = new Monster({
                                        url:"http://assets.wonderfl.net/images/related_images/5/57/5728/5728bb5057da70c62a2bff824fac59cf139bcb44",    //画像のパス
                                        scale:1.6,                  //スケール
                                        diffX:5,                    //影のずれ補正
                                        diffY:-5,                   //影のずれ補正
                                        cameraDistBase:400,         //カメラの距離
                                        zRange:500,                 //吹っ飛ぶ量
                                        speed:1,                    //ジャンプスピード
                                        jumpIntervalMin:.1,         //ジャンプの間隔（秒）
                                        jumpIntervalMax:1,          //ジャンプの間隔（秒）
                                        attackPt:.1,                //モンスター攻撃力（0~1）
                                        defensePt:.6,               //モンスター防御力（0~1）
                                        hitRangeMin:.4,             //攻撃ゲージの最小割合（0~1）
                                        hitRangeMax:.7              //攻撃ゲージの最大割合（0~1）
                                        });
            var monsterB:Monster = new Monster({
                                        url:"http://assets.wonderfl.net/images/related_images/6/6d/6d2a/6d2aac9165308e05d07f52232f99bfe9d52a06fb",    //画像のパス
                                        scale:2.5,                  //スケール
                                        diffX:1,                    //影のずれ補正
                                        diffY:-40,                  //影のずれ補正
                                        cameraDistBase:700,         //カメラの距離
                                        zRange:1000,                //吹っ飛ぶ量
                                        speed:1.8,                  //ジャンプスピード
                                        jumpIntervalMin:.8,         //ジャンプの間隔（秒）
                                        jumpIntervalMax:1.8,        //ジャンプの間隔（秒）
                                        attackPt:.18,               //モンスター攻撃力（0~1）
                                        defensePt:.65,              //モンスター防御力（0~1）
                                        hitRangeMin:.1,             //攻撃ゲージの最小割合（0~1）
                                        hitRangeMax:.4              //攻撃ゲージの最大割合（0~1）
                                        });
            var monsterC:Monster = new Monster({
                                        url:"http://assets.wonderfl.net/images/related_images/9/9a/9a67/9a674310835d956620db269594b14241d8c079ba",    //画像のパス
                                        scale:7,                    //スケール
                                        diffX:0,                    //影のずれ補正
                                        diffY:-10,                  //影のずれ補正
                                        cameraDistBase:1100,        //カメラの距離
                                        zRange:1500,                //吹っ飛ぶ量
                                        speed:1.1,                  //ジャンプスピード
                                        jumpIntervalMin:.1,         //ジャンプの間隔（秒）
                                        jumpIntervalMax:1.2,        //ジャンプの間隔（秒）
                                        attackPt:.25,               //モンスター攻撃力（0~1）
                                        defensePt:.87,              //モンスター防御力（0~1）
                                        hitRangeMin:.04,            //攻撃ゲージの最小割合（0~1）
                                        hitRangeMax:.25             //攻撃ゲージの最大割合（0~1）
                                        });
            _monsters.push( monsterA );
            _monsters.push( monsterB );
            _monsters.push( monsterC );
            loadMonsters();
        }
        
        public function loadMonsters():void {
            for(var i:uint=0; i<_monsters.length; i++){
                _monsters[i].addEventListener(MonsterEvent.LOAD_COMPLETE, onLoaded);
                _monsters[i].load();
            }
        }
        
        private function onLoaded(e:MonsterEvent):void {
            _loadedCount++;
            if(_loadedCount >= _monsters.length){
                onMonstersLoaded();
            }
        }
        
        //すべてのモンスター読み込み完了
        private function onMonstersLoaded():void {
            var gaugeView:GaugeView = new GaugeView();
            var battle3DView:Battle3DView = new Battle3DView();
            
            _battleController = new BattleController(gaugeView, battle3DView);
            _battleController.addEventListener(BattleEvent.WIN, winHandler);
            _battleController.addEventListener(BattleEvent.LOSE, loseHandler);
            addChild(_battleController);
            
            _battleController.setMonster(_monsters[_monsterIndex]);
        }
        
        //勝利
        private function winHandler(e:BattleEvent):void {
            var messagePanel:MessagePanel = new MessagePanel();
            messagePanel.addEventListener(Event.COMPLETE, onClickHandler);
            addChild(messagePanel);
            if(_monsterIndex < _monsters.length-1){
                messagePanel.setWinMessage();
            }else{
                messagePanel.setClearMessage();
            }
        }
        private function onClickHandler(e:Event):void {
            removeChild( e.target as MessagePanel);
            //次のバトルをセット
            _monsterIndex++;
            if(_monsterIndex > _monsters.length-1) _monsterIndex = 0;
            _battleController.setMonster(_monsters[_monsterIndex]);
        }
        
        //敗北
        private function loseHandler(e:BattleEvent):void {
            var messagePanel:MessagePanel = new MessagePanel();
            addChild(messagePanel);
            messagePanel.setLoseMessage();
        }
    }
}



import flash.display.*;
import flash.events.*;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.Timer;
import org.papervision3d.core.utils.*;
import org.papervision3d.view.BasicView;
import org.papervision3d.objects.primitives.*;
import org.papervision3d.objects.parsers.DAE;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.materials.*;
import org.papervision3d.view.layer.util.*;
import org.papervision3d.events.FileLoadEvent;
import org.papervision3d.core.clipping.*;
import org.papervision3d.cameras.*;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.scenes.Scene3D;
import org.papervision3d.view.Viewport3D;
import org.papervision3d.objects.special.ParticleField;
import org.papervision3d.materials.special.ParticleMaterial;
import com.bit101.components.*;
import flash.geom.ColorTransform;
import flash.filters.GlowFilter;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.tweens.ITween;
import org.libspark.betweenas3.easing.*;
import org.libspark.betweenas3.events.TweenEvent;



/* */
class MessagePanel extends Sprite {
    private var _message:Label;
    private var _button:PushButton;
    private var _timer:Timer;
    private var _baseSpr:Sprite;
    
    public function MessagePanel():void {
        addEventListener(Event.ADDED, onAddedHandler);
    }
    
    private function setTimer(d:Number, f:Function):void {
        _timer = new Timer(d, 1);
        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, f);
        _timer.start();
    }
    
    public function setWinMessage():void {
        setTimer(1500, fadeWinMessage);
    }
    private function fadeWinMessage(e:TimerEvent):void {
        _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, fadeWinMessage);
        _message = new Label(this, 0, 0, "YOU WIN!");
        _message.scaleX = _message.scaleY = 2;
        changeLabelColor(_message);
        _message.alpha = 0;
        _message.x = -Math.floor(_message.width);
        _message.y = -60;
        _button = new PushButton(this, 0, 0, "NEXT BATTLE!", onNextBattle);
        _button.x = -Math.floor(_button.width/2);
        _button.y = -15;
        _button.alpha = 0;
        BetweenAS3.serial(
            BetweenAS3.tween(_message, { alpha:1 }, null, 1, Sine.easeOut),
            BetweenAS3.tween(_button, { alpha:1 }, null, 1, Cubic.easeOut)
        ).play();
    }
    
    //
    public function setClearMessage():void {
        setTimer(2000, fadeClearMessage);
    }
    private function fadeClearMessage(e:TimerEvent):void {
        _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, fadeClearMessage);
        _message = new Label(this, 0, 0, "CONGRATULATIONS!!");
        _message.scaleX = _message.scaleY = 2;
        changeLabelColor(_message);
        _message.alpha = 0;
        _message.x = -Math.floor(_message.width);
        _message.y = -20;
        BetweenAS3.tween(_message, { alpha:1 }, null, 1, Sine.easeOut).play();
    }
    
    //
    public function setLoseMessage():void {
        _baseSpr = new Sprite();
        _baseSpr.graphics.beginFill (0xFF3300, 1);
        _baseSpr.graphics.drawRect(-50, -50, 100, 100);
        _baseSpr.blendMode = "multiply";
        onResizeHandler(null);
        addChild(_baseSpr);
        setTimer(1500, fadeLoseMessage);
    }
    private function fadeLoseMessage(e:TimerEvent):void {
        _timer.removeEventListener(TimerEvent.TIMER_COMPLETE, fadeLoseMessage);
        _message = new Label(this, 0, 0, "YOU LOSE...");
        _message.scaleX = _message.scaleY = 2;
        changeLabelColor(_message);
        _message.alpha = 0;
        _message.x = -Math.floor(_message.width);
        _message.y = -20;
        BetweenAS3.tween(_message, { alpha:1 }, null, 1, Sine.easeOut).play();
    }
    
    
    private function changeLabelColor(obj:Label):void {
        var colorTransform:ColorTransform = obj.textField.transform.colorTransform;
        colorTransform.color = 0xFFFFFF;
        obj.textField.transform.colorTransform = colorTransform;
        obj.filters = [new GlowFilter(0x000000, 1, 4, 4, 255, 1)];
    }
    
    private function onNextBattle(e:Event):void {
        dispatchEvent(new Event(Event.COMPLETE));
    }
    
    private function onResizeHandler(e:Event):void {
        x = Math.floor(stage.stageWidth/2);
        y = Math.floor(stage.stageHeight/2);
        if(_baseSpr != null){
            _baseSpr.width = stage.stageWidth+1;
            _baseSpr.height = stage.stageHeight+1;
        }
    }
    
    private function onAddedHandler(e:Event):void {
        removeEventListener(Event.ADDED, onAddedHandler);
        addEventListener(Event.REMOVED, onRemovedHandler);
        stage.addEventListener(Event.RESIZE, onResizeHandler);
        onResizeHandler(null);
    }
    
    private function onRemovedHandler(e:Event):void {
        removeEventListener(Event.REMOVED, onRemovedHandler);
        stage.removeEventListener(Event.RESIZE, onResizeHandler);
    }
}


/* バトル制御 */
class BattleController extends Sprite {
    private var _gaugeView:GaugeView;
    private var _battle3DView:Battle3DView;
    private var _isMouseDown:Boolean;    //interactiveプロパティをtrueにするとマウスイベントが2回呼ばれるみたいなので回避用
    private var _attackRad:Number = 0;
    private var _isAttackWait:Boolean;    //攻撃待機
    private var _isBattleWait:Boolean;    //戦闘待機
    private var _waitCount:Number = 0;
    
    //attackBar
    private var _pow:Number = 0;    //威力（0~1）
    private var _attackPtRatio:Number;
    private var _hitRangeX:Number;    //hitRangeの位置（0~1）
    private var _hitRangeW:Number;    //hitRangeの幅（0~1）
    private var _rokuHP:Number = 1;    //（0~1）
    private var _monsterHP:Number = 1;//（0~1）
    private var _attackPt:Number = .2;    //モンスター攻撃力（0~1）
    private var _defensePt:Number = .8;    //モンスター防御力（0~1）
    private var _hitRangeMax:Number = .4;    //バーの何パーセントをあたり判定にするか（モンスターごとに異なる）
    private var _hitRangeMin:Number = .04; /*.01*/;    //最小値
    
    //ゲージの色変化
    private var _colorCount:Number = 0;
    private var _isColorRed:Boolean;
    
    //モンスター制御
    private var _monsterController:MonsterController;
    
    public function get pow():Number {
        return _pow;
    }
    
    // モンスターセット
    public function setMonster(v:Monster):void {
        //数値リセット
        _monsterHP = 1;
        _gaugeView.changeMonsterHP( _monsterHP );
        //
        _battle3DView.monster = v;
        var s:Object = v.statusObj;
        _attackPt = s.attackPt;
        _defensePt = s.defensePt;
        _hitRangeMax = s.hitRangeMax;
        _hitRangeMin = s.hitRangeMin;
        //（影のずれ補正, スケール, 吹っ飛ぶ量, スピード）
        _monsterController.setMonsterData(s.diffX, s.diffY, s.scale, s.zRange, s.speed, s.jumpIntervalMin, s.jumpIntervalMax);
        _isBattleWait = false;
    }
    
    public function BattleController(gaugeView:GaugeView, battle3DView:Battle3DView):void {
        _battle3DView = battle3DView;
        addChild(_battle3DView);
        _gaugeView = gaugeView;
        addChild(_gaugeView);
        
        _monsterController = new MonsterController();
        _monsterController.addEventListener(MonsterEvent.ATTACK, monsterAttack);
        
        addEventListener(Event.ADDED, onAddedHandler);
    }
    
    //monsterの攻撃
    private function monsterAttack(e:MonsterEvent):void {
        rokuDamage();
        //カメラを揺らす
        _battle3DView.shakeCamera();
    }
    
    private function rokuDamage():void {
        if(_isBattleWait) return;
        _rokuHP -= _attackPt*_pow;
        _gaugeView.changeRokuHP( _rokuHP );
        if(_rokuHP <= 0){
            _gaugeView.shake(1);
            //攻撃待機
            _isBattleWait = true;
            _gaugeView.changeAttackColor(0x666666);
            _gaugeView.loseGauge();
            _pow = 0;
            onMUpHandler(null);
            //敗北を通知
            dispatchEvent(new BattleEvent(BattleEvent.LOSE));
        }else{
            _gaugeView.shake(_pow);
        }
        if(_pow > 0 ) {
            _gaugeView.changeHitRangeColor(GaugeView.DAMAGE);
            _isColorRed = true;
            _colorCount = 10;
        }
        _battle3DView.monsterAttack(_pow);
    }
        
        
    public function onMDownHandler(e:MouseEvent):void {
        if(!_isMouseDown){
            _isMouseDown = true;
        }
    }
    public function onMUpHandler(e:MouseEvent):void {
        if(_isMouseDown){
            _isMouseDown = false;
            if(!_isAttackWait){
                //攻撃判定
                var margin:Number = .02;
                var hitX:Number =_hitRangeX*(1-_hitRangeW);
                if(_attackPtRatio > hitX-margin &&
                   _attackPtRatio < hitX+_hitRangeW+margin){
                    //攻撃成功
                    rokuAttack();
                }else{
                    //攻撃失敗
                    rokuDamage();
                }
            }
            //攻撃待機
            _isAttackWait = true;
            _gaugeView.changeAttackColor(0x666666);
            _waitCount = 35*_pow-5;
            //
            _pow = 0;
        }
    }
    
    //ロクの攻撃
    private function rokuAttack():void {
        _monsterHP -= (1-_defensePt)*_pow;
        _gaugeView.changeMonsterHP( _monsterHP );
        if(_monsterHP <= 0){
            //モンスター死亡
            _battle3DView.monsterDeath(1, _monsterController.x, _monsterController.y, _monsterController.z);
            _monsterController.death(_pow);
            //攻撃待機
            _isBattleWait = true;
            _gaugeView.changeAttackColor(0x666666);
            //勝利を通知
            dispatchEvent(new BattleEvent(BattleEvent.WIN));
        }else{
            _battle3DView.rokuAttack(_pow, _monsterController.x, _monsterController.y, _monsterController.z);
            //モンスターのけぞる
            _monsterController.damage(_pow);
        }
    }
    
    
    private function onResizeHandler(e:Event):void {
        _gaugeView.resize(stage.stageWidth, stage.stageHeight);
    }
    
    public function loop(e:Event):void {
        _hitRangeX = _monsterController.xRatio;
        if(_isAttackWait && !_isBattleWait){
            _waitCount--;
            if(_waitCount<=0){
                //攻撃待機解除
                _isAttackWait = false;
                _gaugeView.changeAttackColor(0xFFCC00);
            }
        }
        if(_isMouseDown && !_isAttackWait &&  !_isBattleWait){
            //マウスを押している間、力を貯める
            _pow = (_pow<1)? _pow+.02 : 1;
        }
        
        //attackPtを移動（0~1）
        _attackRad += .05;
        if( _attackRad > 360*Math.PI/180 ) _attackRad = _attackRad-(360*Math.PI/180);
        _attackPtRatio = (Math.sin(_attackRad)+1)/2 ;
        _gaugeView.changeAttackPt( _attackPtRatio );
        //hitRangeを移動（0~1）
        _hitRangeW = (1-_pow)*(_hitRangeMax-_hitRangeMin) +_hitRangeMin;
        _gaugeView.changeHitRange( _hitRangeW, _hitRangeX );
        
        //ゲージの色制御
        if(_isColorRed){
            _colorCount--;
            if(_colorCount <= 0){
                _gaugeView.changeHitRangeColor(GaugeView.NORMAL);
                _isColorRed = false;
            }
        }
        //
        _battle3DView.pow = _pow;
        _gaugeView.loop();
        _battle3DView.monsterUpdate(_monsterController);
    }
    
    protected function onAddedHandler(e:Event):void {
        removeEventListener(Event.ADDED, onAddedHandler);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMDownHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, onMUpHandler);
        stage.addEventListener(Event.RESIZE, onResizeHandler);
        onResizeHandler(null);
        addEventListener(Event.ENTER_FRAME, loop);
    }
}


/* 影を描く */
class ShadowBitmapData extends BitmapData {
    public function ShadowBitmapData():void {
        super(100, 100, true, 0x00000000);
        
        var s:Shape = new Shape();
        s.graphics.beginFill(0x000000, .2);
        s.graphics.drawCircle (50, 50, 49);
        draw(s);
    }
}



/*  */
class Monster extends Sprite {
    private var _loader:Loader;
    private var _url:String;
    private var _monster:Plane;
    private var _shadow:Plane;
    private var _w:Number;
    private var _h:Number;
    private var _scale:Number;
    public var statusObj:Object;
    
    public function get obj():Plane {
        return _monster;
    }
    public function get shadow():Plane {
        return _shadow;
    }
    public function get scale():Number {
        return _scale;
    }
    public function get h():Number {
        return _h;
    }
    
    //（画像のパス, スケール, カメラの距離, 影のずれ補正, 吹っ飛ぶ量, スピード）
    public function Monster( v:Object ):void {
        _url = v.url;
        _scale = v.scale;
        statusObj = v;
    }
    
    public function load():void {
        _loader = new Loader();
        _loader.load(new URLRequest(_url), new LoaderContext(true));
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
    }
    
    private function loadComplete(e:Event):void {
        _loader.removeEventListener(Event.COMPLETE, loadComplete);
        var bmd:BitmapData = new BitmapData(_loader.width, _loader.height, true, 0x00000000);
        bmd.draw( _loader );
        var monsterBmd:BitmapData = trimming( bmd );
        bmd.dispose();
        _w = monsterBmd.width*_scale;
        _h = monsterBmd.height*_scale;
        
        var monsterMaterial:BitmapMaterial = new BitmapMaterial( monsterBmd );
        monsterMaterial.smooth = true;
        _monster = new Plane(monsterMaterial, monsterBmd.width*_scale, monsterBmd.height*_scale, 4, 4);
        var max:int = _monster.geometry.vertices.length;
        for(var i:int=0; i<max; i++){
            var vertex:Vertex3D = _monster.geometry.vertices[i];
            vertex.y += monsterBmd.height*_scale/2;
        }
        
        //影を生成
        var shadowMaterial:BitmapMaterial = new BitmapMaterial( new ShadowBitmapData() );
        shadowMaterial.smooth = true;
        _shadow = new Plane(shadowMaterial, monsterBmd.width*_scale*.8, monsterBmd.width*_scale*.8, 4, 4);
        _shadow.rotationX = 90;
        
        dispatchEvent( new MonsterEvent(MonsterEvent.LOAD_COMPLETE) );
    }
    
    private function trimming(source:BitmapData):BitmapData {
        //半透明部分を完全な透明に置き換えて影を削除（影以外もちょっと消えちゃう）
        source.threshold(source, source.rect, new Point(0,0), "<", 0x50FFFFFF);
        //画像の余白をトリミング http://level0.kayac.com/2010/03/trim_transparent_pixels.php
        var rect:Rectangle = source.getColorBoundsRect(0xff000000, 0, false);
        var bmdResult:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
        bmdResult.copyPixels(source, rect, new Point(0, 0));
        return bmdResult;
    }
}

/* */
class MonsterEvent extends Event {
    public static const LOAD_COMPLETE:String = "monster_load_complete";
    public static const MONSTERS_LOAD_COMPLETE:String = "monsters_load_complete";
    public static const ATTACK:String = "monster_attack";
    
    public function MonsterEvent(type:String) {
        super(type);
    }
    public override function clone():Event {
        return new MonsterEvent(type);
    }
}



/* 3D表示 */
class Battle3DView extends BasicView {
    private var _pow:Number = 0;
    //ロク
    private var _rokus:Vector.<DAE>;
    private var _rokuIndex:Number;    //表示中のロク
    //モンスター
    private var _monster:Monster;
    //空
    private var _sky:DAE;
    //カメラ動作用
    private var _targetObj:DisplayObject3D;        //カメラターゲット
    private var _tempCameraDist:Number = 250;    //カメラまでの距離イージング用
    private var _cameraDist:Number = 250;        //カメラまでの距離
    private var _cameraDistBase:Number = 200;    //カメラまでの基本距離（モンスターごとに変更）
    private var _vd:Number = 0;                    //カメラまでの距離びよよよーん用
    private var _spring:Number = 1.5;
    private var _fliction:Number = 0.5;
    private var _tarRatioX:Number = 0;            //マウスの位置に応じたカメラ角度のイージング用
    private var _tarRatioY:Number = 0;
    private var _tarCameraDistBase:Number = 0;    //カメラの距離変更時イージング用
    private var _tarTargetObjY:Number = 0;        //カメラターゲットの高さイージング用
    private var _cameraYRatio:Number = 1;        //カメラの高さイージング用
    private var _tarCameraYRatio:Number = 1;
    private var _tarMonsterScale:Number = 0;    //スケールイージング用
    private var _monsterScale:Number = 1;        //
    private var _easeSpeed:Number = .05;        //イージング速度（モンスターが吹っ飛ぶ時に速める）
    //ヒットエフェクト
    private var _hitEffect:HitEffect;
    
    
    public function set monster(v:Monster):void {
        if(_monster != null){
            //モンスター表示済みの場合は削除
            scene.removeChild(_monster.obj);
            scene.removeChild(_monster.shadow);
        }
        _monster = v;
        _tarMonsterScale = v.scale;
        _tarCameraDistBase = v.statusObj.cameraDistBase;    //カメラまでの距離を設定
        _tarTargetObjY = _monster.h/3 - 50;    //カメラターゲットの高さを設定
        scene.addChild(_monster.obj);
        scene.addChild(_monster.shadow);
        viewport.getChildLayer(_monster.obj).layerIndex = 6;
        viewport.getChildLayer(_monster.shadow).layerIndex = 4;
        //数値リセット
        _tarCameraYRatio = 1;
        _easeSpeed = .02;
    }
    
    public function set pow(v:Number):void {
        _pow = v;
    }
    
    public function set cameraDistBase(v:Number):void {
        _cameraDistBase = v;
    }
    public function monsterUpdate(v:MonsterController):void {
        if(_monster.obj == null) return;
        _monster.obj.x = v.x;
        _monster.obj.y = v.y;
        _monster.obj.z = v.z;
        _monster.obj.scaleX = v.scaleX;
        _monster.obj.scaleY = v.scaleY;
        _monster.shadow.x = v.shadowX;
        _monster.shadow.z = v.shadowZ;
        _monster.shadow.scaleX = v.scaleX;
        _monster.shadow.scaleY = v.scaleX;
    }
    
    public function Battle3DView():void {
        super(0, 0, true, false, CameraType.FREE);
        //インデックスソートを使用
        viewport.containerSprite.sortMode = ViewportLayerSortMode.INDEX_SORT;
        //近距離クリッピング（地面のポリゴン欠け防止）
        renderer.clipping = new FrustumClipping(FrustumClipping.NEAR);
        
        // ロク生成
        _rokus = new Vector.<DAE>();
        var rokuA:DAE = new DAE();
        rokuA.load("http://buccchi.jp/wonderfl/201101/roku_a.dae");
        rokuA.addEventListener(FileLoadEvent.LOAD_COMPLETE, onRokuLoaded);
        _rokus.push(rokuA);
        var rokuB:DAE = new DAE();
        rokuB.load("http://buccchi.jp/wonderfl/201101/roku_b.dae");
        rokuB.addEventListener(FileLoadEvent.LOAD_COMPLETE, onRokuLoaded);
        _rokus.push(rokuB);
        var rokuC:DAE = new DAE();
        rokuC.load("http://buccchi.jp/wonderfl/201101/roku_c.dae");
        rokuC.addEventListener(FileLoadEvent.LOAD_COMPLETE, onRokuLoaded);
        _rokus.push(rokuC);
        var rokuD:DAE = new DAE();
        rokuD.load("http://buccchi.jp/wonderfl/201101/roku_d.dae");
        rokuD.addEventListener(FileLoadEvent.LOAD_COMPLETE, onRokuLoaded);
        _rokus.push(rokuD);
        for(var i:uint=0; i<_rokus.length; i++){
            _rokus[i].scale = 25;
            _rokus[i].rotationY = 90;
            _rokus[i].z = -150;
            _rokus[i].y = 60;
        }
        _rokuIndex = 3;
        scene.addChild( _rokus[_rokuIndex] );
        
        //ロク影生成
        var shadowMaterial:BitmapMaterial = new BitmapMaterial( new ShadowBitmapData() );
        shadowMaterial.smooth = true;
        var rokuShadow:Plane = new Plane(shadowMaterial, 150, 150, 4, 4);
        rokuShadow.rotationX = 90;
        rokuShadow.z = _rokus[0].z;
        scene.addChild(rokuShadow);
        viewport.getChildLayer(rokuShadow).layerIndex = 5;
        
        //背景生成
        var field:DAE = new DAE();
        field.load("http://buccchi.jp/wonderfl/201101/field.dae");
        field.scale = 60;
        field.addEventListener(FileLoadEvent.LOAD_COMPLETE, onFieldLoaded);
        
        //空生成
        _sky = new DAE();
        _sky.load("http://buccchi.jp/wonderfl/201101/sky.dae");
        _sky.scale = 120;
        _sky.addEventListener(FileLoadEvent.LOAD_COMPLETE, onSkyLoaded);
        
        //ヒットエフェクト
        _hitEffect = new HitEffect(scene, viewport);
        
        // カメラターゲット
        _targetObj = new DisplayObject3D();
        _targetObj.y = 0;
        
        startRendering();
    }
    
    public function shakeCamera():void {
        _cameraDist = _tempCameraDist - 50*_monsterScale;
    }
    
    private function onFieldLoaded(e:FileLoadEvent):void {
        scene.addChild(e.target as DAE);
        viewport.getChildLayer(e.target as DAE).layerIndex = 2;
    }
    private function onSkyLoaded(e:FileLoadEvent):void {
        scene.addChild(e.target as DAE);
        viewport.getChildLayer(e.target as DAE).layerIndex = 1;
    }
    
    private function onRokuLoaded(e:FileLoadEvent):void {
        viewport.getChildLayer(e.target as DAE).layerIndex = 7;
    }
    
    
    
    //ロクの攻撃
    public function rokuAttack(pow:Number, myX:Number, myY:Number, myZ:Number):void {
        //ヒットエフェクト生成
        _hitEffect.addAttackEffect(pow, myX, myY+_monster.h/2, myZ);
        //ロクのポーズ切り替え
        scene.removeChild( _rokus[_rokuIndex] );
        _rokuIndex = (_rokuIndex >= _rokus.length-1)? 0 : _rokuIndex+1;
        scene.addChild( _rokus[_rokuIndex] );
    }
    //モンスター死亡
    public function monsterDeath(pow:Number, myX:Number, myY:Number, myZ:Number):void {
        rokuAttack(pow, myX, myY, myZ);
        //カメラを移動
        _easeSpeed = .3;
        _tarCameraDistBase = 350;
        _tarTargetObjY = 200;
        _tarCameraYRatio = .2;
    }
    //モンスターの攻撃
    public function monsterAttack(pow:Number):void {
        if(pow==0){
            //ガードエフェクト生成
            _hitEffect.addGuardEffect(0, Math.random()*100+40, -80);
        }else{
            //ダメージエフェクト
        }
    }
    
    override protected function onRenderTick(e:Event=null):void {
        _cameraDistBase += (_tarCameraDistBase - _cameraDistBase)*_easeSpeed;
        _targetObj.y += (_tarTargetObjY - _targetObj.y)*_easeSpeed;
        _cameraYRatio += (_tarCameraYRatio - _cameraYRatio)*_easeSpeed;
        _monsterScale += (_tarMonsterScale - _monsterScale)*_easeSpeed;
        
        _tempCameraDist = 300*Math.sin(_pow*90*Math.PI/180)*_monsterScale + _cameraDistBase;
        _vd += (_tempCameraDist - _cameraDist) * _spring;  
        _vd *= _fliction;  
        _cameraDist += _vd; 
        
        var ratioX:Number = stage.mouseX /stage.stageWidth;
        var ratioY:Number = (stage.stageWidth-stage.mouseY) /stage.stageHeight;
        if(ratioX < 0) ratioX=0;
        if(ratioX > 1) ratioX=1;
        if(ratioY < 0) ratioY=0;
        if(ratioY > 1) ratioY=1;
        
        _tarRatioX += (ratioX-_tarRatioX)*.05;
        _tarRatioY += (ratioY-_tarRatioY)*.05;
        var rotX:Number = 120 * _tarRatioX - 60;
        var rotY:Number = 40 * _tarRatioY * 5/_monsterScale;
        
        camera.x = _cameraDist * Math.sin(rotX * Math.PI / 180);
        camera.z = -_cameraDist * Math.cos(rotX * Math.PI / 180);
        camera.y = (_cameraDist * Math.sin(rotY * Math.PI / 180) * (1-_pow)*.8 + 50) * _cameraYRatio;
        
        _sky.rotationY -= .04;
        
        camera.lookAt(_targetObj);
        super.onRenderTick(e);
    }
}



/* ゲージ表示 */
class GaugeView extends Sprite {
    public static const NORMAL:Number = 0x50B9DA;
    public static const DAMAGE:Number = 0xFF3300;
    //ゲージを揺らす用
    private var _spring:Number = 1.5;
    private var _fliction:Number = 0.6;
    private var _vx:Number = 0;
    private var _vy:Number = 0;
    //attackGauge
    private var _attackGauge:Sprite;
    private var _attackPtBar:Sprite;
    private var _hitRangeBar:Sprite;
    private const ATTACK_W:Number = 440;
    //rokuGauge
    private var _rokuGauge:Sprite;
    private var _rokuHpBar:Sprite;
    //monsterGauge
    private var _monsterGauge:Sprite;
    private var _monsterHpBar:Sprite;
    //
    private const HP_W:Number = 195;
    
    public function GaugeView():void {
        //attackGauge生成
        _attackGauge = new Sprite();
        _attackGauge.graphics.beginFill(0x333333, 1);
        _attackGauge.graphics.drawRect(-1, -1, ATTACK_W+2, 28);
        _hitRangeBar = new Sprite();
        _hitRangeBar.graphics.beginFill(NORMAL, 1);
        _hitRangeBar.graphics.drawRect(0, 0, 100, 26);
        _attackGauge.addChild(_hitRangeBar);
        _attackPtBar = new Sprite();
        _attackPtBar.graphics.beginFill(0xFFCC00, 1);
        //_attackPtBar.graphics.beginFill(0x666666, 1);
        _attackPtBar.graphics.drawRect(2, 0, 4, 26);
        _attackGauge.addChild(_attackPtBar);
        var hl:Shape = new Shape();
        hl.graphics.beginFill(0xFFFFFF, .25);
        hl.graphics.drawRect(0, 0, ATTACK_W, 13);
        _attackGauge.addChild(hl);
        addChild(_attackGauge);
        //rokuGauge生成
        _rokuGauge = new Sprite();
        _rokuHpBar = createHpBar( _rokuGauge, true );
        _rokuGauge.y = 22;
        addChild(_rokuGauge);
        changeLabelColor( new Label(_rokuGauge, -2, -17, "ROKU") );
        //monsterGauge生成
        _monsterGauge = new Sprite();
        _monsterHpBar = createHpBar( _monsterGauge, false );
        _monsterGauge.y = 22;
        addChild(_monsterGauge);
        changeLabelColor( new Label(_monsterGauge, HP_W-45, -17, "MONSTER") );
    }
    
    //ゲージ全体を揺らす
    public function shake( v:Number ):void {
        var rad:Number = Math.random()*360 * Math.PI/180;
        x = Math.sin(rad)*v*300;
        y = Math.cos(rad)*v*300;
        if(v == 0) return;
    }
    
    //ゲージを赤く（ロク敗北時）
    public function loseGauge():void {
        changeHitRangeColor(0xFF3300);
    }
    
    private function createHpBar(spr:Sprite, isRight:Boolean):Sprite {
        spr.graphics.beginFill(0x333333, 1);
        spr.graphics.drawRect(-1, -1, HP_W+2, 8);
        var bar:Sprite = new Sprite();
        bar.graphics.beginFill(0xFF9900, 1);
        if(isRight){
            bar.graphics.drawRect(-HP_W, 0, HP_W, 6);
            bar.x = HP_W;
        }else{
            bar.graphics.drawRect(0, 0, HP_W, 6);
        }
        spr.addChild(bar);
        var hl:Shape = new Shape();
        hl.graphics.beginFill(0xFFFFFF, .25);
        hl.graphics.drawRect(0, 0, HP_W, 3);
        spr.addChild(hl);
        return bar;
    }
    
    public function resize(w:Number, h:Number):void {
        _attackGauge.x = Math.floor( w/2-_attackGauge.width/2 ) +1;
        _attackGauge.y = Math.floor( h -_attackGauge.height -15 ) +1;
        //
        _rokuGauge.x = _attackGauge.x;
        _monsterGauge.x = _attackGauge.x+_attackGauge.width - _rokuGauge.width;
    }
    
    public function changeAttackPt(v:Number):void {
        _attackPtBar.x = (ATTACK_W-4)*v-2;
    }
    
    public function changeHitRange(hitRangeW:Number, v:Number):void {
        _hitRangeBar.width = ATTACK_W*hitRangeW;
        _hitRangeBar.x = (ATTACK_W-ATTACK_W*hitRangeW)*v;
    }
    
    public function changeAttackColor(v:Number):void {
        var colorTransform:ColorTransform = _attackPtBar.transform.colorTransform;
        colorTransform.color = v;
        _attackPtBar.transform.colorTransform = colorTransform;
    }
    
    public function changeRokuHP(v:Number):void {
        _rokuHpBar.scaleX = (v<0)? 0 : v;
    }
    public function changeMonsterHP(v:Number):void {
        _monsterHpBar.scaleX = (v<0)? 0 : v;
    }
    
    private function changeLabelColor(obj:Label):void {
        var colorTransform:ColorTransform = obj.textField.transform.colorTransform;
        colorTransform.color = 0xFFFFFF;
        obj.textField.transform.colorTransform = colorTransform;
        obj.filters = [new GlowFilter(0x000000, 1, 2, 2, 8, 1)];
    }
    
    public function changeHitRangeColor(c:Number):void {
        var colorTransform:ColorTransform = _hitRangeBar.transform.colorTransform;
        colorTransform.color = c;
        _hitRangeBar.transform.colorTransform = colorTransform;
    }
    
    public function loop():void {
        _vx += (0 - x) * _spring;  
        _vx *= _fliction;  
        x += _vx;  
        _vy += (0 - y) * _spring;  
        _vy *= _fliction;  
        y += _vy;
    }
}


/* モンスターの動作制御 */
class MonsterController extends EventDispatcher {
    public var x:Number = 0;
    public var y:Number = 0;
    public var z:Number = 0;
    public var scaleX:Number = 1;
    public var scaleY:Number = 1;
    public var shadowX:Number = 0;
    public var shadowZ:Number = 0;
    private var _baseScale:Number;
    private var _diffX:Number;    //影のずれ補正
    private var _diffY:Number;    //影のずれ補正
    private var _baseZ:Number;    //初期位置
    private var _speed:Number;
    private var _zRange:Number; //後ろに吹っ飛ぶ距離
    private var _xRange:Number;    //左右に移動する距離
    private var _jumpIntervalMin:Number;    //ジャンプの間隔
    private var _jumpIntervalMax:Number;    //ジャンプの間隔
    private var _it:ITween;
    private var _timer:Timer;
    
    public function setMonsterData( diffX:Number, diffY:Number, scale:Number, zRange:Number, speed:Number, jumpIntervalMin:Number, jumpIntervalMax:Number ):void {
        //数値リセット
        scaleY = scaleX = 1;
        x = 0;
        shadowX = 0;
        //
        _baseScale = scale;
        _diffX = diffX * scale;
        _diffY = diffY * scale;
        _baseZ = 20*_baseScale + 20;
        _speed = speed;
        _zRange = zRange;
        _xRange = 150*_baseScale;
        x = _diffX;
        y = _diffY;
        z = shadowZ = _baseZ;
        _jumpIntervalMin = jumpIntervalMin;
        _jumpIntervalMax = jumpIntervalMax;
        
        jumpWait(null);
    }
    
    //x軸の位置（0~1）
    public function get xRatio():Number {
        return (x-_diffX+_xRange/2)/_xRange;
    }
    public function get scale():Number {
        return _baseScale;
    }
    public function get h():Number {
        return _baseScale*320;
    }
    
    public function death(pow:Number=0):void {
        stopIt();
        _it = BetweenAS3.parallel(
                    //吹っ飛ぶ
                    BetweenAS3.tween(this, { scaleX:0, scaleY:0, y:5000, z:10000 }, null, 2, Cubic.easeOut),
                    BetweenAS3.tween(this, { shadowZ:10000 }, null, 2, Cubic.easeOut)
                );
        _it.play();
    }
    
    public function damage(pow:Number=0):void {
        stopIt();
        var tarZ:Number = Math.min(z + _zRange*pow, _zRange);
        _it = BetweenAS3.serial(
                    BetweenAS3.parallel(
                        //下降
                        BetweenAS3.tween(this, { y:_diffY }, null, .5, Cubic.easeOut),
                        BetweenAS3.tween(this, { scaleY:1-.7*pow, z:tarZ }, null, .5, Cubic.easeOut),
                        BetweenAS3.tween(this, { shadowZ:tarZ }, null, .5, Cubic.easeOut)
                    ),
                    BetweenAS3.tween(this, { scaleY:1 }, null, .5/_speed, Cubic.easeOut),
                    //ため
                    BetweenAS3.tween(this, { scaleY:.7 }, null, .4/_speed, Sine.easeOut)
                );
        _it.addEventListener(TweenEvent.COMPLETE, jump);
        _it.play();
    }
    
    public function MonsterController():void {
    }
    
    //次のジャンプまで待機
    private function jumpWait(e:TweenEvent):void {
        var sec:Number = Math.random()*(_jumpIntervalMax-_jumpIntervalMin) + _jumpIntervalMin;
        _timer = new Timer(sec*1000, 1);
        _timer.addEventListener(TimerEvent.TIMER_COMPLETE, startJump);
        _timer.start();
    }
    
    private function startJump(e:TimerEvent):void {
        stopIt();
        //ため
        _it = BetweenAS3.tween(this, { scaleY:.7 }, null, .4/_speed, Sine.easeOut);
        _it.addEventListener(TweenEvent.COMPLETE, jump);
        _it.play();
    }
    
    private function jump(e:TweenEvent):void {
        stopIt();
        var tarX:Number = (Math.random()-.5)*_xRange;
        //ジャンプ
        _it = BetweenAS3.parallel(
                    BetweenAS3.tween(this, { x:tarX+_diffX, z:_baseZ }, null, .8/_speed, Sine.easeOut),
                    BetweenAS3.tween(this, { shadowX:tarX, shadowZ:_baseZ }, null, .8/_speed, Sine.easeOut),
                    BetweenAS3.serial(
                        //上昇
                        BetweenAS3.parallel(
                            BetweenAS3.tween(this, { scaleY:1 }, null, .4/_speed, Sine.easeOut),
                            BetweenAS3.tween(this, { y:100*_baseScale+_diffY }, null, .4/_speed, Sine.easeOut)
                        ),
                        //下降
                        BetweenAS3.tween(this, { y:_diffY }, null, .4/_speed, Sine.easeIn)
                    )
                );
        _it.addEventListener(TweenEvent.COMPLETE, touchdown);
        _it.play();
    }
    private function touchdown(e:TweenEvent):void {
        stopIt();
        dispatchEvent( new MonsterEvent(MonsterEvent.ATTACK) );
        //着地
        _it = BetweenAS3.serial(
                    //ため
                    BetweenAS3.tween(this, { scaleY:.8 }, null, .2/_speed, Sine.easeOut),
                    BetweenAS3.tween(this, { scaleY:1 }, null, .4/_speed, Sine.easeIn)
                );
        _it.addEventListener(TweenEvent.COMPLETE, jumpWait);
        _it.play();
    }
    
    private function stopIt():void {
        if(_it != null) {
            _it.stop();
            _it.removeEventListener(TweenEvent.COMPLETE, jump);
            _it.removeEventListener(TweenEvent.COMPLETE, touchdown);
            _it.removeEventListener(TweenEvent.COMPLETE, jumpWait);
        }
        if(_timer != null) {
            _timer.reset();
        }
    }
}

/* */
class BattleEvent extends Event {
    public static const WIN:String = "roku_win";
    public static const LOSE:String = "roku_lose";
    
    public function BattleEvent(type:String) {
        super(type);
    }
    public override function clone():Event {
        return new BattleEvent(type);
    }
}

/* 攻撃エフェクト */
class HitEffect extends Sprite {
    private const LOW_ATTACK_POW:Number = .20;    //弱攻撃のしきい値
    private var _lowAttackList:Vector.<Object>;
    private var _lowAttackIndex:uint = 0;
    private var _attackList:Vector.<Object>;
    private var _guardObj:Object;
    private var _scene:Scene3D;
    private var _viewport:Viewport3D;
    
    public function HitEffect(scene:Scene3D, viewport:Viewport3D):void {
        _scene = scene;
        _viewport = viewport;
        
        var attackMat:ParticleMaterial = new ParticleMaterial(0xFFFF00, 1, 1);
        var particle:ParticleField;
        //弱攻撃エフェクト用パーティクル作成
        _lowAttackList = new Vector.<Object>();
        for(var i:uint=0; i<5; i++){
            particle = new ParticleField(attackMat, 3, 15, 10, 10, 10);    //（マテリアル, 数, サイズ）
            _viewport.getChildLayer(particle).layerIndex = 8;
            _lowAttackList.push( {p:particle} );
        }
        
        //通常攻撃エフェクト用パーティクル作成
        _attackList = new Vector.<Object>();
        for(var j:uint=0; j<10; j++){
            particle = new ParticleField(attackMat, 5*j+4, 5*j+16, 10, 10, 10);    //（マテリアル, 数, サイズ）
            _viewport.getChildLayer(particle).layerIndex = 8;
            _attackList.push( {p:particle} );
        }
        
        //ガードエフェクト生成
        var guardMat:ParticleMaterial = new ParticleMaterial(0xBCF7FD, 1, 1);
        var guardParticle:ParticleField = new ParticleField(guardMat, 5, 15, 10, 10, 10);
        _viewport.getChildLayer(guardParticle).layerIndex = 9;
        _guardObj = new Object();
        _guardObj.p = guardParticle;
    }
    
    public function addAttackEffect(pow:Number, x:Number, y:Number, z:Number):void {
        var obj:Object;
        if(pow < LOW_ATTACK_POW){
            //弱攻撃エフェクトを使用
            obj = _lowAttackList[_lowAttackIndex];
            if(_lowAttackIndex < _lowAttackList.length-1){
                _lowAttackIndex++;
            }else{
                _lowAttackIndex = 0;
            }
        }else{
            //通常攻撃エフェクトを使用
            var i:uint = Math.floor( (pow-LOW_ATTACK_POW) / (1-LOW_ATTACK_POW) * (_attackList.length-1) );
            obj = _attackList[i];
        }
        
        if(obj.it != null){
            _scene.removeChild( obj.p );
            obj.it.stop();
        }
        obj.p.rotationX = Math.random()*360;
        obj.p.rotationY = Math.random()*360;
        obj.p.x = x;
        obj.p.y = y;
        obj.p.z = z;
        obj.it = BetweenAS3.tween(obj.p, { scale:300*pow }, { scale:0 }, .5, Linear.linear);
        obj.it.addEventListener(TweenEvent.COMPLETE, onCompleteHandler);
        obj.it.play();
        _scene.addChild( obj.p );
    }
    
    public function addGuardEffect(x:Number, y:Number, z:Number):void {
        if(_guardObj.it != null){
            _scene.removeChild( _guardObj.p );
            _guardObj.it.stop();
        }
        _guardObj.p.rotationX = Math.random()*360;
        _guardObj.p.rotationY = Math.random()*360;
        _guardObj.p.x = x;
        _guardObj.p.y = y;
        _guardObj.p.z = z;
        _guardObj.it = BetweenAS3.tween(_guardObj.p, { scale:50 }, { scale:0 }, .5, Linear.linear);
        _guardObj.it.addEventListener(TweenEvent.COMPLETE, onCompleteHandler);
        _guardObj.it.play();
        _scene.addChild( _guardObj.p );
    }
        
    private function onCompleteHandler(e:TweenEvent):void {
        e.target.removeEventListener(TweenEvent.COMPLETE, onCompleteHandler);
        _scene.removeChild( e.target.target );
    }
}