package {
    import flash.events.*;
    import flash.display.*;
    import flash.text.TextField;
    import flash.net.*;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.events.TweenEvent;
    
    [SWF(width="465", height="465", backgroundColor="#000000", frameRate="30")] 
    
    public class MainLocal extends MovieClip {
        private var _it:ITween;
        public var _gienkin:Number = 0;
        private var _gienkinDisp:Gienkin;
        private var _gienkinTotal:Number;
        private var _gienkinDate:String;
        private var _backContainer:Sprite;
        private var _roku:Roku3D;
        private var _isIntroComp:Boolean;
        private var _intro:Intro;
        private var _bgRect:Sprite;
        
        public function MainLocal():void {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            Wonderfl.capture_delay(22);
            
            _backContainer = new Sprite();
            addChild(_backContainer);
            
            // 外部フォントの読み込み
            TfFactory.getInstance().loadFont();
            TfFactory.getInstance().addEventListener(Event.COMPLETE, onFontLoaded);
        }
        
        // フォント読み込み完了
        private function onFontLoaded(e:Event):void {
            _bgRect = new Sprite();
            _bgRect.graphics.beginFill(0xFFCC33, 1);
            _bgRect.graphics.drawRect(0, 0, 100, 100);
            _backContainer.addChild(_bgRect);
            
            _intro = new Intro();
            _intro.addEventListener(Event.COMPLETE, onIntroComp);
            addChild(_intro);
            
            //xmlの読み込み
            var url:URLRequest = new URLRequest("http://buccchi.jp/wonderfl/201104/gienkin.xml"+"?noCache="+new Date().getTime());
            var urlLoader:URLLoader = new URLLoader(url);
            urlLoader.addEventListener(Event.COMPLETE, onXmlLoaded);
            
            stage.addEventListener(Event.RESIZE, onResize);
            onResize(null);
        }
        
        private function onIntroComp(e:Event):void {
            _intro.removeEventListener(Event.COMPLETE, onIntroComp);
            checkIntroComp();
        }
        
        // xml読み込み完了
        private function onXmlLoaded(e:Event):void {
            e.target.removeEventListener(Event.COMPLETE, onXmlLoaded);
            var xml:XML = new XML(e.target.data);
            _gienkinTotal = xml.gienkin;
            _gienkinDate = xml.date;
            
            _roku = new Roku3D();
            _roku.addEventListener(Event.COMPLETE, onRokuLoaded);
            _backContainer.addChild(_roku);
            
            //addChild( new Stats() );
        }
        
        // DAEファイル読み込み完了
        private function onRokuLoaded(e:Event):void {
            _roku.removeEventListener(Event.COMPLETE, onRokuLoaded);
            _gienkinDisp = new Gienkin(_gienkinDate);
            _gienkinDisp.addEventListener(Event.COMPLETE, onGienkinLoaded);
            _gienkinDisp.loadBanner();
        }
        
        // 義援金表示（バナー）読み込み完了
        private function onGienkinLoaded(e:Event):void {
            _gienkinDisp.removeEventListener(Event.COMPLETE, onGienkinLoaded);
            addChild(_gienkinDisp);
            checkIntroComp();
        }
        
        private function checkIntroComp():void {
            if(_isIntroComp){
                startGenkidama();
            }else{
                _isIntroComp = true;
            }
        }
        
        private function startGenkidama():void {
            _intro.fadeOut();
            var delaySec:Number = 5;    //元気玉開始までの待ち時間
            var gatherSec:Number = 5;    //集める時間
            // 義援金表示開始
            _gienkinDisp.startDisp(delaySec, gatherSec);
            // レンダリング開始
            _roku.startRender(delaySec, gatherSec);
            // 義援金を増加
            _it = BetweenAS3.delay(BetweenAS3.tween(this, {_gienkin:_gienkinTotal}, null, gatherSec, Linear.linear), delaySec)
            _it.addEventListener(TweenEvent.UPDATE, onGienkinUpdate);
            _it.play();
        }
        
        private function onGienkinUpdate(e:TweenEvent):void {
            _roku.changeGenki(_gienkin, _gienkin/_gienkinTotal);
            _gienkinDisp.changeGenki(_gienkin);
        }
        
        private function onResize(e:Event):void {
            _bgRect.width = stage.stageWidth;
            _bgRect.height = stage.stageHeight;
        }
    }
}



import flash.events.*;
import flash.display.*;
import flash.text.TextField;
import flash.utils.Timer;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.net.*;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.text.*;
import flash.system.ApplicationDomain;
import flash.system.SecurityDomain;
import flash.system.Security;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.tweens.ITween;
import org.libspark.betweenas3.easing.*;
import org.libspark.betweenas3.events.TweenEvent;



/* フォント読み込み、TextField生成 */
class TfFactory extends Sprite {
    static private var instance:TfFactory;
    public function TfFactory(singletonEnforcer:SingletonEnforcer) {}
    private var _loader:Loader;
    
    public static function getInstance():TfFactory {
        if(TfFactory.instance == null) {
            TfFactory.instance = new TfFactory(new SingletonEnforcer());
        }
        return TfFactory.instance;    
    }
    
    public function loadFont():void {
        _loader = new Loader();
        var req:URLRequest = new URLRequest("http://buccchi.jp/wonderfl/201104/font.swf");
        // 参考：Loaderの設定に関する注意点 - LoaderContext
        // http://level0.kayac.com/2009/10/loader_-_loadercontext.php
        var context :LoaderContext = new LoaderContext();
        context.checkPolicyFile = true;
        context.securityDomain = SecurityDomain.currentDomain;
        context.applicationDomain = ApplicationDomain.currentDomain;
        _loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoadComplete );
        _loader.load( req, context );
    }
        
    private function onLoadComplete(e:Event):void {
        _loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoadComplete );
        var KozukaB:Class = _loader.contentLoaderInfo.applicationDomain.getDefinition( "KozukaGothicB" ) as Class;
        Font.registerFont( KozukaB );
        var KozukaM:Class = _loader.contentLoaderInfo.applicationDomain.getDefinition( "KozukaGothicM" ) as Class;
        Font.registerFont( KozukaM );
        dispatchEvent(new Event(Event.COMPLETE));
    }
    
    public function createKozukaBTF(size:Number=12):TextField {
        return getTF( new TextFormat("Kozuka Gothic Pro B", size) );
    }
    public function createKozukaMTF(size:Number=12):TextField {
        return getTF( new TextFormat("Kozuka Gothic Pro M", size) );
    }
    private function getTF(fmt:TextFormat):TextField {
        var tf:TextField = new TextField();
        tf.defaultTextFormat = fmt;
        tf.embedFonts = true;
        tf.selectable = false;
        tf.autoSize = "left";
        return tf;
    }
}
class SingletonEnforcer {}



/* イントロ */
class Intro extends Sprite {
    private var _it:ITween;
    private var _rect:Sprite;
    private var _tfSpr:Sprite
    
    public function Intro():void {
        addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }
    
    private function onAdded(e:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAdded);
        
        _rect = new Sprite();
        _rect.graphics.beginFill(0x00000, 1);
        _rect.graphics.drawRect (0, 0, stage.stageWidth, stage.stageHeight);
        addChild(_rect);
        
        _tfSpr = new Sprite();
        var tf:TextField = TfFactory.getInstance().createKozukaMTF(16);
        tf.text = "被災地の動物たちに、みんなの元気をわけてくれ！";
        tf.textColor = 0xFFCC33;
        tf.x = -tf.textWidth/2;
        tf.y = -8;
        _tfSpr.y = -10;
        
        addChild(_tfSpr);
        _tfSpr.addChild(tf);
        
        var it:ITween = BetweenAS3.serial(
                    BetweenAS3.delay(BetweenAS3.tween(_tfSpr, {alpha:1, scaleX:1, scaleY:1}, {alpha:0, scaleX:2, scaleY:2}, .3, Quad.easeOut), 1),
                    BetweenAS3.tween(_tfSpr, {scaleX:1.2, scaleY:1.2}, null, 5, Quad.easeOut)
                  );
        it.play();
        
        var timer:Timer = new Timer(2500, 1);
        timer.addEventListener(TimerEvent.TIMER_COMPLETE, onIntroComplete);
        timer.start();
        
        stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);
    }
    
    private function onIntroComplete(e:TimerEvent):void {
        e.target.removeEventListener(TimerEvent.TIMER_COMPLETE, onIntroComplete);
        dispatchEvent(new Event(Event.COMPLETE));
    }
    
    public function fadeOut():void {
        var it:ITween = BetweenAS3.tween(this, {alpha:0}, null, 2, Quad.easeIn);
        it.addEventListener(TweenEvent.COMPLETE, onFadeOutComplete);
        it.play();
    }
    
    private function onFadeOutComplete(e:TweenEvent):void {
        e.target.removeEventListener(TweenEvent.COMPLETE, onFadeOutComplete);
        stage.removeEventListener(Event.RESIZE, onResize);
        // 自身を削除
        parent.removeChild(this);
    }
    
    private function onResize(e:Event):void {
        var w:int = stage.stageWidth;
        var h:int = stage.stageHeight;
        x = w/2;
        y = h/2;
        _rect.x = -x;
        _rect.y = -y;
        _rect.width = w;
        _rect.height = h;
    }
}



/* 義援金表示 */
class Gienkin extends Sprite {
    private var _date:String;    //日付
    private var _gienkinSpr:Sprite;        //義援金総額表示
    private var _gienkinTf:TextField;
    private var _gienkinBaseTf:TextField;
    private var _messageSpr:Sprite;
    private var _gienkinBtn:MovieClip;    
    private var _banner:Sprite;    //バナー
    private var _btnIt:ITween;
    private var _it:ITween;
    private const GIENKIN_BASE_STR:String = "000,000,000,000";
    
    public function Gienkin(gienkinDate:String):void {
        _date = gienkinDate;
        addEventListener(Event.ADDED_TO_STAGE, onAdded);
    }
    
    public function loadBanner():void {
        var myLoader:Loader = new Loader();
        myLoader.load(new URLRequest("http://buccchi.jp/wonderfl/201104/saigai_banner.png"));
        myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
    }
    
    private function onLoaded(e:Event):void {
        _banner = new Sprite();
        _banner.addChild( Bitmap(e.target.content) );
        dispatchEvent(new Event(Event.COMPLETE));
    }
    
    private function onAdded(e:Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, onAdded);
        stage.addEventListener(Event.RESIZE, onResize);
        onResize(null);
        
        // テキスト生成（緊急災害時動物救護本部への義援金総額）
        _messageSpr = new Sprite();
        var m:TextField = TfFactory.getInstance().createKozukaMTF(14);
        m.text = "動物救援活動のために集まった義援金";
        _messageSpr.addChild(m);
        _messageSpr.x = -Math.floor(_messageSpr.width/2);
        _messageSpr.y = 87;
        
        // テキスト生成（義援金総額）
        _gienkinSpr = new Sprite();
        _gienkinTf = TfFactory.getInstance().createKozukaBTF(36);
        _gienkinTf.autoSize = "right";
        _gienkinTf.text = GIENKIN_BASE_STR;
        _gienkinTf.x = 0;    //最終文字数を入れた状態で位置調整
        _gienkinBaseTf = TfFactory.getInstance().createKozukaBTF(36);
        _gienkinBaseTf.text = GIENKIN_BASE_STR;
        _gienkinBaseTf.alpha = .2;
        
        var yen:TextField = TfFactory.getInstance().createKozukaBTF(16);
        yen.text = "円";
        yen.x = _gienkinTf.textWidth +4;
        yen.y = 16;
        _gienkinSpr.addChild(_gienkinTf);
        _gienkinSpr.addChild(_gienkinBaseTf);
        _gienkinSpr.addChild(yen);
        _gienkinSpr.x = -Math.floor(_gienkinSpr.width/2);
        _gienkinSpr.y = 105;
        
        _gienkinTf.text = "";
        
        // 集計日
        var date:TextField = TfFactory.getInstance().createKozukaMTF(9);
        date.autoSize = "left";
        date.text = getDate(_date);
        date.x = _gienkinSpr.width - date.textWidth - 4;
        date.y = 37;
        date.alpha = .7;
        _gienkinSpr.addChild(date);
        
        // ボタン生成
        _gienkinBtn = new MovieClip();
        _gienkinBtn.addChild(_banner);
        _gienkinBtn.x = Math.floor(-_gienkinBtn.width/2);
        _gienkinBtn.y = 160;
        addChild(_gienkinBtn);
        _gienkinBtn.visible = false;
        
        //イベント設定
        _banner.buttonMode = true;
        _banner.mouseChildren = false;
        _banner.addEventListener(MouseEvent.CLICK, onMClick);
        _banner.addEventListener(MouseEvent.MOUSE_OVER, onMOver);
    }
    
    private function onMClick(e:MouseEvent):void {
        var url:URLRequest = new URLRequest( "http://www.jpc.or.jp/saigai/pc_gienkin.html" );
        navigateToURL( url );
    }
    
    private function onMOver(e:MouseEvent):void {
        if(_btnIt != null) _btnIt.stop();
        _btnIt = BetweenAS3.tween(_banner, {transform:{ colorTransform:{ redOffset:0,greenOffset:0,blueOffset:0} }}, {transform:{ colorTransform:{ redOffset:255,greenOffset:255,blueOffset:255} }}, 1, Quint.easeOut);
        _btnIt.play();
    }
    
    public function startDisp(delaySec:Number, gatherSec:Number):void {
        _it = BetweenAS3.parallel(
                BetweenAS3.delay(BetweenAS3.tween(_messageSpr, {alpha:1}, {alpha:0}, 1, Quad.easeIn), delaySec-1.3),
                BetweenAS3.delay(BetweenAS3.tween(_gienkinSpr, {alpha:1}, {alpha:0}, 1, Quad.easeIn), delaySec-.3),
                BetweenAS3.delay(BetweenAS3.tween(_gienkinBtn, {alpha:1, visible:1}, {alpha:0}, 1, Quad.easeIn), delaySec+gatherSec+.5)
              );
        _it.play();
        
        addChild(_messageSpr);
        addChild(_gienkinSpr);
        addChild(_gienkinBtn);
    }
    
    private function onResize(e:Event):void {
        var w:int = stage.stageWidth;
        var h:int = stage.stageHeight;
        x = w/2;
        y = h/2;
    }
    
    private function getDate(date:String):String {
        var list:Array = date.split(".");
        return list[0]+"年"+list[1]+"月"+list[2]+"日現在";
    }
    
    // 3桁毎にカンマで区切る
    // http://www.wadadanet.jp/flash/2-tips/16-as33.html
    private function displayNumber(n:Number):String {
        var str:String = String( Math.floor(n).toString() );
        var rst:String = str.replace( /([0-9]+?)(?=(?:[0-9]{3})+$)/g , '$1,' );
        return rst;
    }
    
    public function changeGenki(gienkin:Number):void {
        if(gienkin < 1) return;
        var str:String = displayNumber(gienkin);
        _gienkinTf.text = str;
        _gienkinBaseTf.text = GIENKIN_BASE_STR.substring(0, GIENKIN_BASE_STR.length-str.length);
    }
}



import org.papervision3d.view.BasicView;
import org.papervision3d.objects.*;
import org.papervision3d.objects.special.*;
import org.papervision3d.objects.parsers.DAE;
import org.papervision3d.materials.*;
import org.papervision3d.materials.special.*;
import org.papervision3d.events.*;
import flash.filters.*;

/* ロク、元気玉 */
class Roku3D extends BasicView {
    private var _camR:Number = 0;
    private var _camY:Number = 1;
    private var _camH:Number = 0;
    public var _camHBase:Number = 400;
    public var _camYBase:Number = 1000;
    public var _speed:Number = 2;
    private var _genkisNormal:Vector.<MyParticle>;    //はやい版
    private var _genkisSlow:Vector.<MyParticle>;    //ゆっくり版
    private var _genkidama:DAE;
    private var _genkiWrap:DisplayObject3D;
    private var _loadedStep:Number = 2;
    private const PARTICLE_COUNT:Number = 25;    //生成するパーティクル数
    private const REDUCTION_SEC:Number = 3;    //パーティクル集合スピード
    private const REDUCTION_SLOW_SEC:Number = 15;
    
    public function Roku3D():void {
        super(0, 0, true, false);
        
        _genkiWrap = new DisplayObject3D();
        scene.addChild(_genkiWrap);
        
        //パーティクル生成
        _genkisNormal = new Vector.<MyParticle>();
        _genkisSlow = new Vector.<MyParticle>();
        var myParticle:MyParticle;
        for(var i:uint=0; i<PARTICLE_COUNT; i++){
            myParticle = new MyParticle();
            _genkiWrap.addChild(myParticle);
            _genkisNormal.push(myParticle);
            //
            myParticle = new MyParticle();
            _genkiWrap.addChild(myParticle);
            _genkisSlow.push(myParticle);
        }
        
        //元気玉生成
        _genkidama = new DAE();
        _genkidama.load("http://buccchi.jp/wonderfl/201104/genkidama.dae");
        _genkidama.name = "genkidama";
        _genkidama.addEventListener(FileLoadEvent.LOAD_COMPLETE, onLoadDaeComplete);
        _genkiWrap.addChild(_genkidama);
        
        //ロク生成
        var roku:DAE = new DAE();
        roku.load("http://buccchi.jp/wonderfl/201104/roku.dae");
        roku.name = "roku";
        roku.rotationY = 30;
        roku.z = -100;
        roku.addEventListener(FileLoadEvent.LOAD_COMPLETE, onLoadDaeComplete);
        scene.addChild(roku);
        roku.scale = 100;
        
        changeGenki(0, 0);
    }
    
    private function startGenkidama():void {
        for(var i:uint=0; i<PARTICLE_COUNT; i++){
            _genkisNormal[i].startReduction(REDUCTION_SEC, i/PARTICLE_COUNT);
            _genkisSlow[i].startReduction(REDUCTION_SLOW_SEC, i/PARTICLE_COUNT);
        }
    }
    
    // 元気玉サイズ変更
    public function changeGenki(n:Number, myRatio:Number):void {
        var genki:Number = n/4000000;
        _genkidama.scale = genki;
        _genkiWrap.y = (genki*12) + 800;
        _camH = genki*2;
    }
    
    // 元気玉完成
    private function compGenki():void {
        for(var i:uint=0; i<PARTICLE_COUNT; i++){
            _genkisNormal[i].stopLoop();
        }
    }
    
    private function onLoadDaeComplete(e:FileLoadEvent):void {
        var obj:DisplayObject3D = e.target as DisplayObject3D;
        obj.useOwnContainer = true;
        switch(obj.name){
            case "roku":
                obj.filters = [new BlurFilter(0, 0, 0)];
                break;
            case "genkidama":
                obj.filters = [new BlurFilter(16, 16, 2)];
                break;
        }
        _loadedStep--;
        if(_loadedStep <= 0){
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
    
    public function startRender(delaySec:Number, gatherSec:Number):void {
        var it:ITween = BetweenAS3.parallel(
                            BetweenAS3.tween(this, {_camHBase:0, _camYBase:0}, null, 7, Quart.easeInOut),
                            BetweenAS3.delay(BetweenAS3.func(function():void { startGenkidama(); }), -REDUCTION_SEC-.5+delaySec),
                            BetweenAS3.delay(BetweenAS3.func(function():void { compGenki(); }), gatherSec-REDUCTION_SEC+delaySec)
                        );
        it.play();
        startRendering();
    }
    
    override protected function onRenderTick(event:Event = null):void {
        //カメラを移動
        _camR -= .23 * _speed;
        _camY += .0025 * _speed;
        var h:Number = _camH-_camHBase;
        camera.x = (h+1500) * Math.sin(_camR * Math.PI / 180);
        camera.z = (h+1500) * Math.cos(_camR * Math.PI / 180);
        camera.y = Math.cos(_camY)*600 -500 -(h*1.5) +_camYBase;
        //
        super.onRenderTick(event);
    }
}



import org.papervision3d.objects.special.ParticleField;
import org.papervision3d.materials.special.*;

/* パーティクル */
class MyParticle extends ParticleField {
    private const INIT_SCALE:Number = 25;
    private var _sec:Number;
    private var _it:ITween;
    private var _isLoop:Boolean = true;
    
    public function MyParticle():void {
        var particleMat:ParticleMaterial = new ParticleMaterial(0xFFFFFF, 1, 1);
        super(particleMat, 1, 70, 600, 600, 600);
        useOwnContainer = true;
        filters = [new BlurFilter(2, 2, 2)];
        visible = false;
    }
    
    public function startReduction(sec:Number, delayRatio:Number):void {
        _sec = sec;
        _it = BetweenAS3.delay(
                BetweenAS3.func(function():void {
                    visible = true;
                    reduction();
                }), _sec*delayRatio
              )
        _it.play();
    }
    
    public function stopLoop():void {
        _isLoop = false;
    }
    
    private function reduction():void {
        if(_it != null) _it.stop();
        _it = BetweenAS3.serial(
                BetweenAS3.tween(this, {scale:0}, {scale:INIT_SCALE}, _sec, Sine.easeIn),
                BetweenAS3.func(function():void {
                    if(_isLoop){
                        rotationX = Math.random()*360;
                        rotationY = Math.random()*360;
                        reduction();
                    }else{
                        visible = false;
                    }
                })
              );
        _it.play();
    }
}