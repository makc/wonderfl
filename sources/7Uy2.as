// forked from Event's SPEC vol.5 投稿用コード
//////////////////////////////////////////////////////
//  forked from Takema.Terai's flash on 2012-7-4  ////
//////////////////////////////////////////////////////
/**
 * copyright (c) 2012 
 * @author itoz
 * @since 2012/09/17 3:42:21
 * 
 * [SPEC 5 投稿]　※音が出ます。
 * Wonderflで最近利用できるようになった「Tween24」と「Away3D Gold」をメインで作ってみた。
 * soundもオリジナルだよ。
 */
package
{
    import a24.tween.Ease24;
    import a24.tween.Tween24;

    import away3d.cameras.Camera3D;
    import away3d.core.managers.Stage3DManager;
    import away3d.core.managers.Stage3DProxy;
    import away3d.events.Stage3DEvent;
    import away3d.filters.BloomFilter3D;
    import away3d.lights.PointLight;
    import away3d.materials.lightpickers.StaticLightPicker;

    import frocessing.color.ColorHSV;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.DataEvent;
    import flash.events.Event;
    import flash.geom.Vector3D;
    import flash.utils.getTimer;

    [SWF(backgroundColor="#000000", frameRate="60", width="465", height="465")]
    /**
     * Spec5
     */
    public class Spec5 extends Sprite
    {
        private static const ZERO : Vector3D = new Vector3D(0, 32, 0);
        private var stage3DManager : Stage3DManager;
        private var stage3DProxy : Stage3DProxy;
        private var background3d : BackGroundView3D;
        private var front3d : FrontView3D;
        private var _capture : Bitmap;
        private var _assetsLoader : AssetsLoader;
        private var _createFlag : Boolean;
        private var camera : Camera3D;
        private var cameraR : int = 100000;
        private var _lightColor0HSV : ColorHSV;
        private var _lightColor0 : PointLight;
        private var _lightPicker : StaticLightPicker;
        private var _colorChangeFlag : Boolean;
        private var _levelUpSprite : LevelUpSprite;
        private var _loadingArea : LoadingArea;
        
        public function Spec5()
        {
            if (stage) _initialize(null);
            else addEventListener(Event.ADDED_TO_STAGE, _initialize);
        }

        private function _initialize(event : Event) : void
        {
            removeEventListener(flash.events.Event.ADDED_TO_STAGE, _initialize);
           
            // ★wonderfl capture
            Wonderfl.disable_capture();
            // _capture = addChild(new Bitmap(new BitmapData(465, 465, false, 0x000000))) as Bitmap ;
            
            _loadingArea = addChild(new LoadingArea()) as LoadingArea;
            
            // ----------------------------------
            //  Assets Load Start
            //----------------------------------
            _assetsLoader = AssetsLoader.getInstance();
            _assetsLoader.addEventListener(DataEvent.DATA, onTexturesLoadLoadedData_Handler);
            _assetsLoader.addEventListener(Event.COMPLETE, onTexturesLoadComplete_Handler);
            _assetsLoader.loadStart();
        }

        private function onTexturesLoadLoadedData_Handler(event : DataEvent) : void
        {
            _loadingArea.setParcent(int(Number(event.data) * 100));
        }

        private function onTexturesLoadComplete_Handler(event : Event) : void
        {
            _loadingArea.addEventListener("FADE_OUT_COMPLETE", onLoadingAreaFadeoutComplete, false, 0, true);
            _loadingArea.fadeOut();
        }

        private function onLoadingAreaFadeoutComplete(event : Event) : void
        {
            if (_loadingArea && _loadingArea.parent) _loadingArea.parent.removeChild(_loadingArea);
            _loadingArea.dispose();
            _loadingArea = null;
            setup();
        }

        private function setup() : void
        {
            soundStart();
            initProxies();
        }

        private function soundStart() : void
        {
            AssetsLoader.soundMain.play(0, int.MAX_VALUE);
        }

        private function initProxies() : void
        {
            stage3DManager = Stage3DManager.getInstance(stage);
            stage3DProxy = stage3DManager.getFreeStage3DProxy();
            stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
        }

        private function onContextCreated(event : Stage3DEvent) : void
        {
            if (_createFlag) return;
            _createFlag = true;
            stage3DProxy.width = stage.stageWidth;
            stage3DProxy.height = stage.stageHeight;
            // ----------------------------------
            // init away3d
            // ----------------------------------
            initAway3D();
        }

        private function initAway3D() : void
        {
            // ----------------------------------
            // lights
            // ----------------------------------
            _lightColor0HSV = new ColorHSV(0x493a08);//0x493a08
            _lightColor0 = new PointLight();
            _lightColor0.ambientColor = _lightColor0HSV.value;
            _lightColor0.ambient = 1;
            _lightColor0.y = -5;
            _lightPicker = new StaticLightPicker([_lightColor0]);
            
            //----------------------------------
            //  background 
            //----------------------------------
            background3d = new BackGroundView3D(_lightPicker);
            background3d.stage3DProxy = stage3DProxy;
            background3d.shareContext = true;
            addChild(background3d);
            // filter3d
            background3d.filters3d = [new BloomFilter3D(0, 0,0,0)];
            
            // ----------------------------------
            // front
            // ----------------------------------
            front3d = new FrontView3D(_lightPicker);
            front3d.camera = background3d.camera;
            front3d.stage3DProxy = stage3DProxy;
            front3d.shareContext = true;
            addChild(front3d);
            
            // common camera
            camera = background3d.camera;
            
            // ----------------------------------
            // startRender
            // ----------------------------------
            startRender();
        }

        private function startRender() : void
        {
            Tween24.serial(
                  Tween24.prop(camera,{"x":0,"y" : 512, "z":-1})
                , Tween24.wait(1)
                //----------------------------------
                // 聖杯点火
                , Tween24.func(background3d.doEffect_Fire)
                , Tween24.wait(0.3)
                //----------------------------------
                // カメラ下降
                , Tween24.tween(camera,2.5,Ease24._3_CubicInOut).x(0).y(100).z(-280)
                , Tween24.wait(0.3)
                //----------------------------------
                // カラーチェンジ
                , Tween24.func(colorLight)
                , Tween24.wait(0.5)
                //----------------------------------
                // 複数カード 登場　中央に集まる
                , Tween24.func(front3d.doEffect_SilverCard)
                , Tween24.wait(2)
                //----------------------------------
                // 魔法陣エフェクト
                ,Tween24.func(background3d.doEffect_Light)
                //----------------------------------
                // 複数カード フェードアウト
                , Tween24.func(front3d.fadeOutEffect_SilverCard)
                , Tween24.wait(1)
                //----------------------------------
                // 合成中央光
                , Tween24.func(front3d.doEffect_SyntheticLight)
                , Tween24.wait(1.5)
                //----------------------------------
                // 背景Bloomフィルター
                , Tween24.func(setFilterLight)
                , Tween24.wait(1.5)
                //----------------------------------
                // 合成光フェードアウト
                , Tween24.func(front3d.fadeOutEffect_SyntheticLight)
                , Tween24.wait(0.7)
                //----------------------------------
                // 波紋
                ,Tween24.func(background3d.doEffect_Explosion)
                //----------------------------------
                // メインカードフェードイン
                , Tween24.func(front3d.doEffect_GoldCard)
                //----------------------------------
                // キラキラ
                , Tween24.func(front3d.doEffect_Twinkle)
                , Tween24.wait(1.5)
                //----------------------------------
                // LEVEL UP
                , Tween24.func(levelUp)
            ).play();
            
            // ----------------------------------
            // render start
            // ----------------------------------
            stage3DProxy.addEventListener(Event.ENTER_FRAME, update);
        }
        
        /**
         * color change start
         */
        private function colorLight() : void
        {
            cameraR = 190;
            _colorChangeFlag = true;
        }

        /**
         * background filter3d
         */
        private function setFilterLight() : void
        {
            background3d.filters3d = [new BloomFilter3D(32, 32, 0.2, 7, 15)];
        }
        
        /**
         * level up text
         */
        private function levelUp() : void
        {
            _levelUpSprite = addChild(new LevelUpSprite()) as LevelUpSprite;
            _levelUpSprite.x = int(465 * 0.5);
            _levelUpSprite.y = int(465* 0.5)+75;
            Tween24.serial(
                 Tween24.prop(_levelUpSprite,{"scaleX":0,"scaleY":0})
                ,Tween24.tween(_levelUpSprite,2,Ease24._BackOut).scaleX(1).scaleY(1).$y(50)
            ).play();
            AssetsLoader.soundLevelUp.play();
        }
        
       /**
        * update
        */
        private function update(event : Event) : void
        {
            var t : Number = getTimer();
            // ----------------------------------
            //  light
            //----------------------------------
            if (_lightColor0) {
                if (_colorChangeFlag) {
                _lightColor0.x = Math.cos(t / 256) * cameraR;
                _lightColor0.y = 128;
                _lightColor0.z = Math.sin(t /256) * cameraR -cameraR * 0.5;
                    if (_lightColor0HSV) {
                        _lightColor0HSV.h += 4;
                        _lightColor0.ambientColor = _lightColor0HSV.value;
                    }
                }
            }
            // ----------------------------------
            // camera
            // ----------------------------------
            camera.lookAt(ZERO);
            // ----------------------------------
            // 3D update
            // ----------------------------------
            if (background3d) background3d.update();
            if (front3d) front3d.update();
            //　★ wonderfl capture
            if (_capture) stage3DProxy.context3D.drawToBitmapData(_capture.bitmapData);
        }
    }
}
import a24.tween.Ease24;
import a24.tween.Tween24;

import away3d.containers.ObjectContainer3D;
import away3d.containers.View3D;
import away3d.core.base.Geometry;
import away3d.entities.Mesh;
import away3d.entities.Sprite3D;
import away3d.events.AssetEvent;
import away3d.library.assets.AssetType;
import away3d.lights.PointLight;
import away3d.loaders.Loader3D;
import away3d.loaders.parsers.Parsers;
import away3d.materials.ColorMaterial;
import away3d.materials.TextureMaterial;
import away3d.materials.lightpickers.LightPickerBase;
import away3d.materials.lightpickers.StaticLightPicker;
import away3d.materials.methods.EnvMapMethod;
import away3d.primitives.ConeGeometry;
import away3d.primitives.CylinderGeometry;
import away3d.primitives.PlaneGeometry;
import away3d.textures.BitmapCubeTexture;
import away3d.textures.BitmapTexture;
import away3d.textures.CubeTextureBase;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.DataEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix3D;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.getTimer;
// --------------------------------------------------------------------------
//
// assets loader
//
// --------------------------------------------------------------------------
class AssetsLoader extends EventDispatcher
{
    private  var allLoadItemNum : int = 0;
    private var _loadCount : int = 0;
    private var _startFlag : Boolean;
    private static const DOMAIN_PATH : String = "http://www.romatica.com/dev/wonderfl/spec5/";
    private static const SOUNDS_URL : String = DOMAIN_PATH + "sound.swf?v=1";
    private static const IMAGE_URL_GROUND : String = DOMAIN_PATH + "bg02.png";
    public static var groundBitmapData : BitmapData;
    private static const IMAGE_URL_MAGIC : String = DOMAIN_PATH + "magic.png";
    public static var  magicBigmapData : BitmapData;
    private static const IMAGE_URL_EFFECTLIGHT : String = DOMAIN_PATH + "effectLight.png";
    public static var  effectLightBitmapData : BitmapData;
    private static const IMAGE_URL_CARD_SILVER : String = DOMAIN_PATH + "card02.png";
    public static var  cardSilverBitmapData : BitmapData;
    private static const IMAGE_URL_CARD_GOLD : String = DOMAIN_PATH + "card01.png";
    public static var  cardGoldBitmapData : BitmapData;
    private static const IMAGE_URL_SYNTHETICLIGHT : String = DOMAIN_PATH + "SyntheticLight.png";
    public static var  syntheticLightBitmapData : BitmapData;
    private static const IMAGE_URL_LEVELUP : String = DOMAIN_PATH + "lvup.png";
    public static var  levelUpBitmapData : BitmapData;
    private static const IMAGE_URL_CHALICE : String = DOMAIN_PATH + "chalices.png";
    public static var  chalicesBitmapData : BitmapData;
    private static const DAE_CHALICE_URL : String = DOMAIN_PATH + "chalice.dae";
    private static const IMAGE_URL_FIRE : String = DOMAIN_PATH + "fire.png";
    public static var  fireBitmapData : BitmapData;
    private static const IMAGE_URL_TWINKLE : String = DOMAIN_PATH + "kira.png";
    public static var  twinkleBitmapData : BitmapData;
    private static const IMAGE_URL_EXPLOSION : String = DOMAIN_PATH + "explosion.png";
    public static var  explosionBitmapData : BitmapData;
    // env
    private static const IMAGE_URL_ENV_TOP : String = DOMAIN_PATH + "environment/top.jpg";
    public static var  envTopBitmapData : BitmapData;
    private static const IMAGE_URL_ENV_BOTTOM : String = DOMAIN_PATH + "environment/bottom.jpg";
    public static var  envBottomBitmapData : BitmapData;
    private static const IMAGE_URL_ENV_LEFT : String = DOMAIN_PATH + "environment/left.jpg";
    public static var  envLeftBitmapData : BitmapData;
    private static const IMAGE_URL_ENV_RIGHT : String = DOMAIN_PATH + "environment/right.jpg";
    public static var  envRightBitmapData : BitmapData;
    private static const IMAGE_URL_ENV_FRONT : String = DOMAIN_PATH + "environment/front.jpg";
    public static var  envFrontBitmapData : BitmapData;
    private static const IMAGE_URL_ENV_BACK : String = DOMAIN_PATH + "environment/back.jpg";
    public static var  envBackBitmapData : BitmapData;
    
    public static var chaliceMesh : Mesh;
    public static var chaliceGeo : Geometry;
    public static var instance : AssetsLoader;
    public static var soundMain : Sound;
    public static var soundLevelUp : Sound;
    public static var soundFinishSynthesis : Sound;
    public static var soundPopupCard : Sound;
    public static var soundFire : Sound;
    public static var soundMagic : Sound;
    public static var soundSynthesis : Sound;
    private var _loaderGround : Loader;
    private var _loaderMagic : Loader;
    private var _loaderEffectLight : Loader;
    private var _loaderCardSilver : Loader;
    private var _loaderSyntheticLight : Loader;
    private var _loaderCardGold : Loader;
    private var _loaderLevelUp : Loader;
    private var _loaderChaliceImage : Loader;
    private var _loader3d : Loader3D;
    private var _loaderFire : Loader;
    private var _loaderTwinkle : Loader;
    private var _loaderExplosion : Loader;
    private var _loaderSound : Loader;
    private var _loaderEnvTop : Loader;
    private var _loaderEnvBottom : Loader;
    private var _loaderEnvLeft : Loader;
    private var _loaderEnvRight : Loader;
    private var _loaderEnvFront : Loader;
    private var _loaderEnvBack : Loader;

    public static function getInstance() : AssetsLoader
    {
        if ( instance == null ) instance = new  AssetsLoader(new SingletonEnforcer());
        return instance;
    }

    public function AssetsLoader(pvt : SingletonEnforcer)
    {
        if (pvt == null) throw new Error("TextureLoader is a singleton class, use getInstance() instead");
    }

    public function loadStart() : void
    {
        if (_startFlag) return;
        _startFlag = true;

        _loaderSound = new Loader();
        allLoadItemNum++;
        _loaderSound.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteSound_Handler);
        _loaderSound.load(new URLRequest(SOUNDS_URL), new LoaderContext(true));

        _loaderGround = new Loader();
        allLoadItemNum++;
        _loaderGround.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteImageGround_Handler);
        _loaderGround.load(new URLRequest(IMAGE_URL_GROUND), new LoaderContext(true));

        _loaderMagic = new Loader();
        allLoadItemNum++;
        _loaderMagic.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteImageMagic_Handler);
        _loaderMagic.load(new URLRequest(IMAGE_URL_MAGIC), new LoaderContext(true));

        _loaderEffectLight = new Loader();
        allLoadItemNum++;
        _loaderEffectLight.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteImageEffectLight_Handler);
        _loaderEffectLight.load(new URLRequest(IMAGE_URL_EFFECTLIGHT), new LoaderContext(true));

        _loaderCardSilver = new Loader();
        allLoadItemNum++;
        _loaderCardSilver.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteCardSilver_Handler);
        _loaderCardSilver.load(new URLRequest(IMAGE_URL_CARD_SILVER), new LoaderContext(true));

        _loaderCardGold = new Loader();
        allLoadItemNum++;
        _loaderCardGold.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteCardGold_Handler);
        _loaderCardGold.load(new URLRequest(IMAGE_URL_CARD_GOLD), new LoaderContext(true));

        _loaderSyntheticLight = new Loader();
        allLoadItemNum++;
        _loaderSyntheticLight.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteSyntheticLight_Handler);
        _loaderSyntheticLight.load(new URLRequest(IMAGE_URL_SYNTHETICLIGHT), new LoaderContext(true));

        _loaderLevelUp = new Loader();
        allLoadItemNum++;
        _loaderLevelUp.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteLevelUp_Handler);
        _loaderLevelUp.load(new URLRequest(IMAGE_URL_LEVELUP), new LoaderContext(true));

        _loaderFire = new Loader();
        allLoadItemNum++;
        _loaderFire.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteFire_Handler);
        _loaderFire.load(new URLRequest(IMAGE_URL_FIRE), new LoaderContext(true));

        _loaderTwinkle = new Loader();
        allLoadItemNum++;
        _loaderTwinkle.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteTwinkle_Handler);
        _loaderTwinkle.load(new URLRequest(IMAGE_URL_TWINKLE), new LoaderContext(true));
        
         _loaderExplosion = new Loader();
        allLoadItemNum++;
        _loaderExplosion.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteExplosion_Handler);
        _loaderExplosion.load(new URLRequest(IMAGE_URL_EXPLOSION), new LoaderContext(true));

        Parsers.enableAllBundled();
        _loader3d = new Loader3D(true, null);
        allLoadItemNum++;
        _loader3d.addEventListener(AssetEvent.ASSET_COMPLETE, onChaliceDAELoadComplete_Handler);
        _loader3d.load(new URLRequest(DAE_CHALICE_URL));

        _loaderChaliceImage = new Loader();
        allLoadItemNum++;
        _loaderChaliceImage.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompChaliceImage_Handler);
        _loaderChaliceImage.load(new URLRequest(IMAGE_URL_CHALICE), new LoaderContext(true));

        _loaderEnvTop = new Loader();
        allLoadItemNum++;
        _loaderEnvTop.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompEnvTop_Handler);
        _loaderEnvTop.load(new URLRequest(IMAGE_URL_ENV_TOP), new LoaderContext(true));

        _loaderEnvBottom = new Loader();
        allLoadItemNum++;
        _loaderEnvBottom.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompEnvBottom_Handler);
        _loaderEnvBottom.load(new URLRequest(IMAGE_URL_ENV_BOTTOM), new LoaderContext(true));

        _loaderEnvLeft = new Loader();
        allLoadItemNum++;
        _loaderEnvLeft.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompEnvLeft_Handler);
        _loaderEnvLeft.load(new URLRequest(IMAGE_URL_ENV_LEFT), new LoaderContext(true));
        
        _loaderEnvRight = new Loader();
        allLoadItemNum++;
        _loaderEnvRight.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompEnvRight_Handler);
        _loaderEnvRight.load(new URLRequest(IMAGE_URL_ENV_RIGHT), new LoaderContext(true));

        _loaderEnvFront = new Loader();
        allLoadItemNum++;
        _loaderEnvFront.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompEnvFront_Handler);
        _loaderEnvFront.load(new URLRequest(IMAGE_URL_ENV_FRONT), new LoaderContext(true));

        _loaderEnvBack = new Loader();
        allLoadItemNum++;
        _loaderEnvBack.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompEnvBack_Handler);
        _loaderEnvBack.load(new URLRequest(IMAGE_URL_ENV_BACK), new LoaderContext(true));
    }

    private function loadCompEnvBack_Handler(event : Event) : void
    {
        envBackBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompEnvFront_Handler(event : Event) : void
    {
        envFrontBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompEnvRight_Handler(event : Event) : void
    {
        envRightBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompEnvLeft_Handler(event : Event) : void
    {
        envLeftBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompEnvBottom_Handler(event : Event) : void
    {
        envBottomBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompEnvTop_Handler(event : Event) : void
    {
        envTopBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompleteExplosion_Handler(event : Event) : void
    {
        explosionBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompleteSound_Handler(event : Event) : void
    {
        var soundMainClass : Class = _loaderSound.contentLoaderInfo.applicationDomain.getDefinition("Sound_Main") as Class;
        soundMain = new soundMainClass() as Sound;
        var soundLevelUpClass : Class = _loaderSound.contentLoaderInfo.applicationDomain.getDefinition("Sound_LevelUp") as Class;
        soundLevelUp = new soundLevelUpClass() as Sound;
        var soundFinishSynthesisClass : Class = _loaderSound.contentLoaderInfo.applicationDomain.getDefinition("Sound_finishSynthesis") as Class;
        soundFinishSynthesis = new soundFinishSynthesisClass() as Sound;
        var soundPopupCardClass : Class = _loaderSound.contentLoaderInfo.applicationDomain.getDefinition("Sound_popupcard") as Class;
        soundPopupCard = new soundPopupCardClass() as Sound;
        var soundFireClass : Class = _loaderSound.contentLoaderInfo.applicationDomain.getDefinition("Sound_fire") as Class;
        soundFire = new soundFireClass() as Sound;
        var soundMagicClass : Class = _loaderSound.contentLoaderInfo.applicationDomain.getDefinition("Sound_Magic") as Class;
        soundMagic = new soundMagicClass() as Sound;
        var soundSynthesisClass : Class = _loaderSound.contentLoaderInfo.applicationDomain.getDefinition("Sound_Synthesis") as Class;
        soundSynthesis = new soundSynthesisClass() as Sound;
        checkLoadImages();
    }

    private function loadCompleteTwinkle_Handler(event : Event) : void
    {
        twinkleBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompleteFire_Handler(event : Event) : void
    {
        fireBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function onChaliceDAELoadComplete_Handler(event : AssetEvent) : void
    {
        if (event.asset.assetType == AssetType.MESH) {
            chaliceMesh = event.asset as Mesh;
            chaliceGeo = chaliceMesh.geometry;
            checkLoadImages();
        }
    }

    private function loadCompChaliceImage_Handler(event : Event) : void
    {
        chalicesBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompleteLevelUp_Handler(event : Event) : void
    {
        levelUpBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompleteCardGold_Handler(event : Event) : void
    {
        cardGoldBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompleteSyntheticLight_Handler(event : Event) : void
    {
        syntheticLightBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompleteCardSilver_Handler(event : Event) : void
    {
        cardSilverBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompleteImageEffectLight_Handler(event : Event) : void
    {
        effectLightBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompleteImageGround_Handler(event : Event) : void
    {
        groundBitmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function loadCompleteImageMagic_Handler(event : Event) : void
    {
        magicBigmapData = ((event.target as LoaderInfo).content as Bitmap).bitmapData;
        checkLoadImages();
    }

    private function checkLoadImages() : void
    {
        _loadCount++;
        dispatchEvent(new DataEvent(DataEvent.DATA, false, false, String(_loadCount / allLoadItemNum)));
        if (_loadCount >= allLoadItemNum) loaComplete();
    }

    private function loaComplete() : void
    {
        dispatchEvent(new Event(Event.COMPLETE));
    }
}
internal class SingletonEnforcer
{
}

// --------------------------------------------------------------------------
//
// view3d background
//
// --------------------------------------------------------------------------
class BackGroundView3D extends View3D
{
    private var inited : Boolean;
    private var _lightPicker : LightPickerBase;
    private var _magicTop : Mesh;
    private var _container : ObjectContainer3D;
    private var _rotYSpeed : Number = 1;
    private var _ground : Mesh;
    private var _magicSide : Mesh;
    private var _chalices : Chalices;
    private var _explosionRing : ExplosionLing;
    private var _explosionRing2 : ExplosionLing;
    private var _explosionRing3 : ExplosionLing;
    private var _effectLights : EffectLights;

    public function BackGroundView3D(lightPicker : LightPickerBase)
    {
        super();
        _lightPicker = lightPicker;
        if (stage) _initialize(null);
        else addEventListener(Event.ADDED_TO_STAGE, _initialize);
    }

    private function _initialize(event : Event) : void
    {
        removeEventListener(Event.ADDED_TO_STAGE, _initialize);
        antiAlias = 4;
        backgroundColor = 0x0;
        createObjects();
        inited = true;
    }

    /**
     * オブジェクト生成
     */
    private function createObjects() : void
    {
        _container = scene.addChild(new ObjectContainer3D()) as ObjectContainer3D;
        // ----------------------------------
        // 地面
        // ----------------------------------
        var groundMaterial : TextureMaterial = new TextureMaterial(new BitmapTexture(AssetsLoader.groundBitmapData));
        groundMaterial.alphaBlending = true;
        _ground = _container.addChild(new Mesh(new PlaneGeometry(1024, 1024, 16, 16), groundMaterial)) as Mesh;
        _ground.rotationY = 180;

        // ----------------------------------
        // 魔法陣
        // ----------------------------------
        // 土台
        var sideMaterial : ColorMaterial = new ColorMaterial(0x192b3a);
        sideMaterial.ambientColor = 0x4a5694;
        sideMaterial.specular = 0.1;
        if (_lightPicker) sideMaterial.lightPicker = _lightPicker;
        _magicSide = _container.addChild(new Mesh(new CylinderGeometry(132, 140, 8, 32, 32), sideMaterial)) as Mesh;
        // 天面
        var magicTopMaterial : TextureMaterial = new TextureMaterial(new BitmapTexture(AssetsLoader.magicBigmapData));
        magicTopMaterial.alphaBlending = true;
        magicTopMaterial.specular = 2;
        if (_lightPicker) magicTopMaterial.lightPicker = _lightPicker;
        _magicTop = _container.addChild(new Mesh(new PlaneGeometry(256, 256, 16, 16), magicTopMaterial)) as Mesh;
        _magicTop.y = 5;

 // ----------------------------------
        // effect light
        // ----------------------------------
        _effectLights = _container.addChild(new EffectLights(_lightPicker)) as EffectLights;
        
        // ----------------------------------
        // 聖杯
        // ----------------------------------
        _chalices = _container.addChild(new Chalices(_lightPicker)) as Chalices;
        
        //----------------------------------
        //  波紋
        //----------------------------------
        _explosionRing = _container.addChild(new ExplosionLing(360)) as ExplosionLing;
        _explosionRing.y = 70;
        _explosionRing.rotationX =10;
        _explosionRing2 = _container.addChild(new ExplosionLing(256)) as ExplosionLing;
        _explosionRing2.y = 70;
        _explosionRing2.rotationZ =-10;
        _explosionRing3 = _container.addChild(new ExplosionLing(480)) as ExplosionLing;
        _explosionRing3.y = 70;
        _explosionRing3.rotationX =10;
        _explosionRing3.rotationZ =-10;
    }


    public function doEffect_Light() : void{if (_effectLights) _effectLights.doEffect();}
    public function doEffect_Fire() : void
    {
        if (_chalices) _chalices.doEffect();
    }
    
    public function doEffect_Explosion():void{
        
        if(_explosionRing&& _explosionRing2&& _explosionRing3){
            Tween24.serial(
                Tween24.parallel(
                     Tween24.func(_explosionRing3.doEffect)
                    ,Tween24.tween(_explosionRing3,3).rotationY(180)
                    ,Tween24.skip(0)
                )
                ,Tween24.wait(0.3)
                ,Tween24.parallel(
                      Tween24.func(_explosionRing.doEffect)
                     ,Tween24.tween(_explosionRing,3).rotationY(180)
                     ,Tween24.skip(0)
                )
                ,Tween24.wait(0.3)
                ,Tween24.parallel(
                     Tween24.func(_explosionRing2.doEffect)
                    ,Tween24.tween(_explosionRing2,3).rotationY(180)
                )
            ).play();
        }
    }

    public function update() : void
    {
        if (!inited) return ;
        _container.rotationY += (_container.rotationY + _rotYSpeed >= 360 ) ? _rotYSpeed - 360 : _rotYSpeed;
        if (_chalices) _chalices.update();
        render();
    }
}

// --------------------------------------------------------------------------
//
// main card
//
// --------------------------------------------------------------------------
class CardMain extends ObjectContainer3D
{
    private static const DEF_Y : Number = 80 * 0.5;
    private var _lightPicker : LightPickerBase;
    private var _container : ObjectContainer3D;
    private var _card : Mesh;

    public function CardMain(lightPicker : LightPickerBase = null)
    {
        super();
        visible = false;
        _lightPicker = lightPicker;
        _container = addChild(new ObjectContainer3D());
        var planeGeo : PlaneGeometry = new PlaneGeometry(80, 160, 4, 4);
        // enviroment
        var ct : CubeTextureBase = new BitmapCubeTexture(AssetsLoader.envLeftBitmapData, AssetsLoader.envRightBitmapData, AssetsLoader.envTopBitmapData, AssetsLoader.envBottomBitmapData, AssetsLoader.envBackBitmapData, AssetsLoader.envFrontBitmapData);
        var  material : TextureMaterial = new TextureMaterial(new BitmapTexture(AssetsLoader.cardGoldBitmapData));
        material.addMethod(new EnvMapMethod(ct, 0.4));
        material.alphaBlending = true;
        material.bothSides = true;
        if (_lightPicker) material.lightPicker = _lightPicker;
        _card = _container.addChild(new Mesh(planeGeo, material)) as Mesh;
        _card.y = DEF_Y;
        _card.rotationX = 90;
    }

    public function doEffect() : void
    {
        var material : TextureMaterial = _card.material as TextureMaterial;
        material.alpha = 0.3;
        visible = true;
        Tween24.parallel(
            Tween24.prop(_card,{"rotationX":0,"rotationY":180,"rotationZ":180})
           ,Tween24.tween(material, 1.5).alpha(1)
           ,Tween24.tween(_card, 5,Ease24._BackOut).rotationX(90).rotationY(90).rotationZ(0)
           ,Tween24.func(function():void{
                AssetsLoader.soundSynthesis.play();
            })
        ).play();
    }

    public function update() : void
    {
        if (!visible) return ;
        var t : Number = getTimer();
        _container.y = Math.cos(t / 256) * 16 + DEF_Y;
        _container.rotationX = Math.cos(t / 768) * 12 ;
        _container.rotationZ = Math.cos(t / 1024) * 12 ;
    }
}
// --------------------------------------------------------------------------
//
// normal cards
//
// --------------------------------------------------------------------------
class CardsNormal extends ObjectContainer3D
{
    private var _lightPicker : LightPickerBase;
    private var _container : ObjectContainer3D;
    private var R : int = 100;
    private var _planes : Array;

    public function CardsNormal(lightPicker : LightPickerBase)
    {
        super();
        _lightPicker = lightPicker;
        _container = addChild(new ObjectContainer3D());
        // ----------------------------------
        // geometory
        // ----------------------------------
        var planeGeo : PlaneGeometry = new PlaneGeometry(50, 100, 4, 4);
        _planes = [];
        var max : int = 8;
        for (var i : int = 0; i < max; i++) {
            // ----------------------------------
            // material
            // ----------------------------------
            var  material : TextureMaterial = new TextureMaterial(new BitmapTexture(AssetsLoader.cardSilverBitmapData));
            material.alphaBlending = true;
            material.bothSides = true;
            if (_lightPicker) material.lightPicker = _lightPicker;

            var  parts : Mesh = _container.addChild(new Mesh(planeGeo, material)) as Mesh;
            parts.x = Math.cos((360 / max * i) * (Math.PI / 180)) * (R) ;
            parts.y = 128 * 0.5;
            parts.z = Math.sin((360 / max * i) * (Math.PI / 180)) * (R);
            parts.rotationX = -90;
            parts.rotationY = 90 - (360 / max * i) ;
            parts.visible = false;
            _planes.push(parts);
        }
    }

    public function doEffect() : void
    {
        var max : uint = _planes.length;
        for (var i : int = 0; i < max; i++) {
            var  parts : Mesh = _planes[i] as Mesh;
            if (parts) {
                var rnd:int = (Math.random()>0.5) ? 1 : -1;
                Tween24.serial(
                     Tween24.wait(Math.random()*0.25+0.1*i)
                    ,Tween24.func(playSound)
                    //----------------------------------
                    //  カード登場
                    //----------------------------------
                    ,Tween24.parallel(
                         Tween24.prop(parts.material,{"alpha":0})
                        ,Tween24.prop(parts,{"visible":true,"y":-50})
                        ,Tween24.tween(parts.material,0.3*Math.random()+0.3,Ease24._2_QuadIn).alpha(1)
                        ,Tween24.tween(parts,0.5*Math.random()+2,Ease24._ElasticOut).y(64 + (Math.random()*32-16))
                    )
                    ,Tween24.wait(Math.random()*0.5+0.2)
                    //----------------------------------
                    //  中央に集まる
                    //----------------------------------
                    ,Tween24.parallel(
                         Tween24.tween(parts,0.5*Math.random()+2.0,Ease24._7_CircOut).rotationY(parts.rotationY*int(2*Math.random()+2))
                        ,Tween24.tween(parts,1*Math.random()+2,Ease24._7_CircOut).rotationX(180*rnd*int(Math.random()*3+1))
                        ,Tween24.tween(parts,.75*Math.random()+1.25,Ease24._BackIn).x(0).y(64).z(0)
                    )
                ).play();
            }
        }
        //ぐるぐる
        Tween24.tween(_container, 5, Ease24._3_CubicIn).delay(1.2).rotationY(360 * 4).play();
    }

    public function playSound() : void
    {
        AssetsLoader.soundPopupCard.play();
    }

    public function fadeOutEffect() : void
    {
        var max : uint = _planes.length;
        for (var i : int = 0; i < max; i++) {
            var  material : TextureMaterial = (_planes[i] as Mesh).material as TextureMaterial;
            if (material) {
                Tween24.tween(material, 0.75 * Math.random() + 1.5).delay(Math.random() + 1).alpha(0).play();
            }
        }
    }
}

// --------------------------------------------------------------------------
//
// Chalices
//
// --------------------------------------------------------------------------
class Chalices extends ObjectContainer3D
{
    private var _lightPicker : LightPickerBase;
    private var _container : ObjectContainer3D;
    private var _fires : Array;

    public function Chalices(lightPicker : LightPickerBase)
    {
        super();
        _lightPicker = lightPicker;
        _container = addChild(new ObjectContainer3D()) as ObjectContainer3D;
        _fires = [];
        // ----------------------------------
        // material
        // ----------------------------------
        var chaliceMaterial : TextureMaterial = new TextureMaterial(new BitmapTexture(AssetsLoader.chalicesBitmapData));
        chaliceMaterial.specular = 0;
        if (_lightPicker) chaliceMaterial.lightPicker = _lightPicker;
        // fire material color
        var fireColor : Array = [0xff0c00, 0x61ff00, 0x00bfff, 0xb686ff];
        
        var max : int = 4;
        for (var i : int = 0; i < max; i++) {
            // ----------------------------------
            // chalices
            // ----------------------------------
            var _chalice : Mesh = new Mesh(AssetsLoader.chaliceGeo, chaliceMaterial);
            _container.addChild(_chalice);
            _chalice.scale(20);
            _chalice.x = Math.cos((360 / max * i) * (Math.PI / 180)) * 160;
            _chalice.z = Math.sin((360 / max * i) * (Math.PI / 180)) * 160;
            // ----------------------------------
            // fire
            // ----------------------------------
            var _light : PointLight = new PointLight();
            _light.specular = 1;
            _light.ambient = 2;
            _light.ambientColor = fireColor[i];
            _light.x = _chalice.x;
            _light.y = 70;
            _light.z = _chalice.z;
            var lightPic : StaticLightPicker = new StaticLightPicker([_light]);
            
            var _fire : Fire = addChild(new Fire(lightPic)) as Fire;
            _fire.x = _chalice.x;
            _fire.y = 40;
            _fire.z = _chalice.z;
            _fires.push(_fire);
        }
        _container.y = 20;
    }

    public function update() : void
    {
        for (var i : int = 0; i < _fires.length; i++) {
            var _fire : Fire = _fires[i] as Fire;
            _fire.update();
        }
    }

    public function doEffect() : void
    {
        for (var i : int = 0; i < _fires.length; i++) {
            var _fire : Fire = _fires[i] as Fire;
            Tween24.serial(
                 Tween24.wait(0.75*i)
                ,Tween24.func(_fire.doEffect)
            ).play();
        }
    }

   
}
//--------------------------------------------------------------------------
//
//  effect lights 魔法陣の光
//
//--------------------------------------------------------------------------
class EffectLights extends ObjectContainer3D
{
    private var _lightPicker : LightPickerBase;
    private var _container : ObjectContainer3D;
    private var _planes : Array;
    private var R : int = 128;

    public function EffectLights(lightPicker : LightPickerBase)
    {
        super();
        _lightPicker = lightPicker;
        _container = addChild(new ObjectContainer3D());
        // ----------------------------------
        // geometory
        // ----------------------------------
        var planeGeo : PlaneGeometry = new PlaneGeometry(32, 256, 16, 16);
        _planes = [];
        var max : int = 24;
        for (var i : int = 0; i < max; i++) {
            // material
            var  material : TextureMaterial = new TextureMaterial(new BitmapTexture(AssetsLoader.effectLightBitmapData));
            material.alphaBlending = true;
            material.bothSides = true;
            if (_lightPicker) material.lightPicker = _lightPicker;

            var  parts : Mesh = _container.addChild(new Mesh(planeGeo, material)) as Mesh;
            parts.movePivot(0, 0, -256 * 0.5);
            parts.x = Math.cos((360 / max * i) * (Math.PI / 180)) * (R) ;
            parts.z = Math.sin((360 / max * i) * (Math.PI / 180)) * (R) + 128;
            parts.rotationX = -90;
            parts.rotationY = 90 - (360 / max * i) ;
            parts.scaleZ = 0;
            parts.visible = false;
            _planes.push(parts);
        }
    }

    public function doEffect() : void
    {
        var max : uint = _planes.length;
        for (var i : int = 0; i < max; i++) {
            var  parts : Mesh = _planes[i] as Mesh;
            if (parts) {
                parts.visible = true;
                Tween24.serial(
                     Tween24.wait(Math.random()*0.5)
                    ,Tween24.prop(parts,{"visible":true})
                    ,Tween24.tween(parts,1*Math.random()+0.5,Ease24._7_CircOut).scaleZ(0.3+Math.random()*0.6)
                    ,Tween24.parallel(
                         Tween24.tween(parts.material,0.75*Math.random()+0.75,Ease24._2_QuadIn).alpha(0)
                        ,Tween24.tween(parts,0.75*Math.random()+0.75,Ease24._2_QuadIn).scaleZ(0)
                    )
                ).play();
            }
        }
        AssetsLoader.soundMagic.play();
    }
}
//--------------------------------------------------------------------------
//
//  fire
//
//--------------------------------------------------------------------------
class Fire extends ObjectContainer3D
{
    private var _fires : Array;
    private var _light : PointLight;
    private var _lightPicker : LightPickerBase;

    public function Fire(lightPicker:LightPickerBase = null)
    {
        super();
        this.visible = false;
        if (!lightPicker) {
            _light = new PointLight();
            _light.specular = 2;
            _light.ambient = 1;
            _light.ambientColor = 0xfba900;
            _lightPicker = new StaticLightPicker([_light]);
        } else {
            _lightPicker = lightPicker;
        }
        _fires = [];
        var max : int = 16;
        for (var i : int = 0; i < max; i++) {
            var fireMaterial : TextureMaterial = new TextureMaterial(new BitmapTexture(AssetsLoader.fireBitmapData));
            fireMaterial.alphaBlending = true;
            fireMaterial.specular=2;
            fireMaterial.ambient  = 1;
            fireMaterial.lightPicker = _lightPicker;
            var _fire : Sprite3D = addChild(new Sprite3D(fireMaterial, 64, 64)) as Sprite3D;
            _fires.push(_fire);
            reset(_fire);
        }
    }

    public function doEffect() : void
    {
        visible = true;
        AssetsLoader.soundFire.play();
    }

    public function update() : void
    {
        if (!visible) return;
        var i : int = 0;
        var max : int = _fires.length;
        for ( i = 0; i < max; i++) {
            var _fire : Sprite3D = _fires[i] as Sprite3D;
            _fire.y += 1;
            _fire.scaleX *= 0.99;
            _fire.scaleY = _fire.scaleX;
            var mat : TextureMaterial = (_fire.material as TextureMaterial);
            mat.alpha *= 0.97;
            mat.alpha -= 0.01;
            if (mat.alpha <= 0.05) reset(_fire);
        }
    }

    private function reset(fire : Sprite3D) : void
    {
        fire.x = Math.random() * 12 - 6;
        fire.y = 0;
        fire.z = Math.random() * 12 - 6;
        fire.scaleX = Math.random() * 0.5 + 0.05;
        fire.scaleY = fire.scaleX;
        var mat : TextureMaterial = (fire.material as TextureMaterial);
        mat.alpha = Math.random();
    }
}

//--------------------------------------------------------------------------
//
//  view3d front
//
//--------------------------------------------------------------------------
class FrontView3D extends View3D
{
    private var inited : Boolean;
    private var _lightPicker : LightPickerBase;
    private var _container : ObjectContainer3D;
    private var _rotYSpeed : Number = 1;
    private var _normalCards : CardsNormal;
    private var _goldCard : CardMain;
    private var _synthticLight : SyntheticLight;
    private var _twinkle : Twinkle;

    public function FrontView3D(lightPicker : LightPickerBase)
    {
        super();
        _lightPicker = lightPicker;
        if (stage) _initialize(null);
        else addEventListener(Event.ADDED_TO_STAGE, _initialize);
    }

    private function _initialize(event : Event) : void
    {
        removeEventListener(Event.ADDED_TO_STAGE, _initialize);

        _container = scene.addChild(new ObjectContainer3D()) as ObjectContainer3D;
       
        // ----------------------------------
        // normal cards
        // ----------------------------------
        _normalCards = _container.addChild(new CardsNormal(_lightPicker)) as CardsNormal;
        // ----------------------------------
        // synthetic light
        // ----------------------------------
        _synthticLight = _container.addChild(new SyntheticLight()) as  SyntheticLight;
        // ----------------------------------
        // main cards
        // ----------------------------------
        _goldCard = _container.addChild(new CardMain()) as CardMain;
        // ----------------------------------
        // twinkle
        // ----------------------------------
        _twinkle = scene.addChild(new Twinkle()) as Twinkle;
        _twinkle.y = 100;
        inited = true;
    }


    public function doEffect_SilverCard() : void{if (_normalCards) _normalCards.doEffect();}

    public function fadeOutEffect_SilverCard() : void{ if (_normalCards) _normalCards.fadeOutEffect();}

    public function doEffect_SyntheticLight() : void { if (_synthticLight) _synthticLight.doEffect();}

    public function fadeOutEffect_SyntheticLight() : void {if (_synthticLight) _synthticLight.fadeOutEffect();}
    
    public function doEffect_GoldCard() : void{if (_goldCard) _goldCard.doEffect();}

    public function doEffect_Twinkle() : void{if (_twinkle) _twinkle.doEffect();}

    /**
     * update
     */
    public function update() : void
    {
        if (!inited) return ;
        _container.rotationY += (_container.rotationY + _rotYSpeed >= 360 ) ? _rotYSpeed - 360 : _rotYSpeed;
        if (_synthticLight) _synthticLight.update();
        if (_goldCard) _goldCard.update();
        if (_twinkle) _twinkle.update();
        render();
    }
}

//--------------------------------------------------------------------------
//
//  level up
//
//--------------------------------------------------------------------------
class LevelUpSprite extends Sprite
{
    private var _levelUpBitmap : Bitmap;

    public function LevelUpSprite()
    {
        _levelUpBitmap = addChild(new Bitmap(AssetsLoader.levelUpBitmapData)) as Bitmap;
        _levelUpBitmap.x = -_levelUpBitmap.width * 0.5;
        _levelUpBitmap.y = -_levelUpBitmap.height * 0.5;
    }
}

//--------------------------------------------------------------------------
//
//  synthsis light
//
//--------------------------------------------------------------------------
class SyntheticLight extends ObjectContainer3D
{
    private var _lightPicker : LightPickerBase;
    private var _container : ObjectContainer3D;
    private var _objects : Array;
    private var doEffectFlag : Boolean;

    public function SyntheticLight(lightPicker : LightPickerBase = null)
    {
        super();
        _lightPicker = lightPicker;
        _container = addChild(new ObjectContainer3D());
        _objects = [];
        var h : int = 96;
        var max : int = 3;
        for (var i : int = 0; i < max; i++) {
            var myH : int = h / max * i;
            // Cornの中心点を頂上にするマトリクス
            var mat3d : Matrix3D = new Matrix3D();
            mat3d.appendTranslation(0, -myH * 0.5, 0);
            // Corn
            var geo : ConeGeometry = new ConeGeometry(128 - myH, myH, 24, 4, false, true);
            geo.applyTransformation(mat3d);
            // material
            var  material : TextureMaterial = new TextureMaterial(new BitmapTexture(AssetsLoader.syntheticLightBitmapData));
            material.alphaBlending = true;
            material.bothSides = true;
            if (_lightPicker) material.lightPicker = _lightPicker;
            // bottom
            var cone_bottom : Mesh = _container.addChild(new Mesh(geo, material)) as Mesh;
            cone_bottom.rotationY = 360 / max * i;
            _objects.push(cone_bottom);
            // top
            var cone_upper : Mesh = _container.addChild(new Mesh(geo, material)) as Mesh;
            cone_upper.rotationY = (360 / max * i) + 180;
            cone_upper.rotationZ = 180;
            _objects.push(cone_upper);
            // right
            var cone_right : Mesh = _container.addChild(new Mesh(geo, material)) as Mesh;
            cone_right.rotationY = (360 / max * i) + 90;
            cone_right.rotationZ = 90;
            _objects.push(cone_right);
        }
        _container.y = 64;
        Tween24.prop(_container, {"scaleX":0, "scaleY":0, "scaleZ":0}).play();
    }

    public function doEffect() : void
    {
        Tween24.tween(_container, 2, Ease24._3_CubicOut).scaleX(1).scaleY(1).scaleZ(1).play();
        doEffectFlag = true;
        AssetsLoader.soundFinishSynthesis.play();
    }

    public function update() : void
    {
        if (!doEffectFlag) return;
        _container.rotationX += 0.1;
        _container.rotationY += 0.2;
        _container.rotationZ += 0.15;
        for (var i : int = 0; i < _objects.length; i++) {
            var light : Mesh = _objects[i] as Mesh;
            light.rotationY += 0.2 * i;
            (light.material as TextureMaterial).alpha = Math.random() * 0.5 + 0.5;
        }
    }

    public function fadeOutEffect() : void
    {
        Tween24.tween(_container, 2, Ease24._3_CubicIn).scaleX(0).scaleY(0).scaleZ(0).onComplete(fadeOutComplete).play();
    }

    private function fadeOutComplete() : void
    {
        doEffectFlag = false;
    }
}
// --------------------------------------------------------------------------
//
// キラキラ
//
// --------------------------------------------------------------------------
class Twinkle extends ObjectContainer3D
{
    private var _effectFlag : Boolean;
    private var _stars : Array;

    public function Twinkle()
    {
        this.visible = false;
        _stars = [];
        var max : int = 16;
        for (var i : int = 0; i < max; i++) {
            var mat : TextureMaterial = new TextureMaterial(new BitmapTexture(AssetsLoader.twinkleBitmapData));
            mat.alphaBlending = true;
            var star : Sprite3D = addChild(new Sprite3D(mat, 64, 64)) as Sprite3D;
            _stars.push(star);
            reset(star);
        }
    }

    public function doEffect() : void
    {
        _effectFlag = true;
        this.visible = true;
    }

    public function update() : void
    {
        if (!_effectFlag ) return ;
        var i : int = 0;
        var max : int = _stars.length;
        for ( i = 0; i < max; i++) {
            var star : Sprite3D = _stars[i] as Sprite3D;
            star.scaleX *= 1.09;
            star.scaleY = star.scaleX;
            var mat : TextureMaterial = (star.material as TextureMaterial);
            mat.alpha *= 0.95;
            mat.alpha -= 0.02;
            if (mat.alpha <= 0.05) reset(star);
        }
    }

    private function reset(star : Sprite3D) : void
    {
        star.x = Math.random() * 160 - 80;
        star.y = Math.random() * 128 - 64;
        star.z = Math.random() * 160 - 80;
        star.scaleX = Math.random() * 0.3 + 0.01;
        star.scaleY = star.scaleX;
        var mat : TextureMaterial = (star.material as TextureMaterial);
        mat.alpha = Math.random() + 0.5;
    }
}
//--------------------------------------------------------------------------
//
//  波紋
//
//--------------------------------------------------------------------------
class ExplosionLing extends ObjectContainer3D
{
    private var _picker : StaticLightPicker;
    private var _plane : Mesh;
    private var _size : int;

    public function ExplosionLing(size : int = 512)
    {
        _size = size || 512;
        visible = false;
        createObject();
    }

    private function createObject() : void
    {
        // ----------------------------------
        // create objects
        // ----------------------------------
        var  light : PointLight = new PointLight();
        light.ambientColor = 0xffffff;
        light.ambient = 1;
        light.specular = 1;
        light.z = 50;
        _picker = new StaticLightPicker([light]);

        var material : TextureMaterial = new TextureMaterial(new BitmapTexture(AssetsLoader.explosionBitmapData));
        material.alphaBlending = true;
        material.bothSides = true;
        material.lightPicker = _picker;
        var planeGeo : PlaneGeometry = new PlaneGeometry(_size, _size, 16, 16);
        _plane = addChild(new Mesh(planeGeo, material)) as Mesh;
        _plane.scaleX = _plane.scaleY = _plane.scaleZ = 0;
    }

    public function doEffect() : void
    {
        if (!_plane) return ;
        if(visible) return;
        visible = true;
        var speed0:Number = 1.25;
        var speed1:Number = 0.25;
        _plane.scaleX = _plane.scaleY = _plane.scaleZ = 0;
        var mat : TextureMaterial = _plane.material as TextureMaterial;
        mat.alpha = 0.4;
        Tween24.serial(
            Tween24.parallel(
                 Tween24.tween(_plane, speed0, Ease24._1_SineOut).scaleX(1).scaleY(1).scaleZ(1)
                ,Tween24.tween(mat, speed0).alpha(0.7))
                ,Tween24.parallel(
                     Tween24.tween(_plane, speed1, Ease24._2_QuadIn).scaleX(1.1).scaleY(1.1).scaleZ(1.1)
                    ,Tween24.tween(mat, speed1, Ease24._2_QuadIn).alpha(0)
                 )
                 ,Tween24.func(function() : void{visible = false;})
        ).play();
    }
}
// --------------------------------------------------------------------------
//
// loadingArea
//
// --------------------------------------------------------------------------
class LoadingArea extends Sprite
{
    private static const COLOR : Number = 0x553387;
    private var _progressTF : TextField;
    private var _bar : Shape;

    public function LoadingArea()
    {
        if (stage) _initialize(null);
        else addEventListener(Event.ADDED_TO_STAGE, _initialize);
    }

    private function _initialize(event : Event) : void
    {
        removeEventListener(Event.ADDED_TO_STAGE, _initialize);
        _progressTF = addChild(new TextField()) as TextField;
        _progressTF.defaultTextFormat = new TextFormat("＿ゴシック", 12, COLOR, null, null, null, null, null, TextFormatAlign.CENTER);
        _progressTF.width = stage.stageWidth;
        _progressTF.height = 24;
        _progressTF.text = "";
        _progressTF.x = 0;
        _progressTF.y = stage.stageHeight * 0.5 - (_progressTF.height * 2);

        _bar = addChild(new Shape()) as Shape;
        _bar.graphics.beginFill(COLOR);
        _bar.graphics.drawRect(0, 0, stage.stageWidth, 2);
        _bar.graphics.endFill();
        _bar.y = _progressTF.y + _progressTF.height + 4;

        addEventListener(Event.ENTER_FRAME, onUpdate, false, 0, true);
        setParcent(0);
    }

    private function onUpdate(event : Event) : void
    {
        alpha = (alpha == 1) ? 0.7 : 1;
    }

    public function setParcent(num : int) : void
    {
        if (_progressTF) _progressTF.text = "LOADING " + num + "%";
        if (_bar) _bar.scaleX = num * 0.01;
    }

    public function fadeOut() : void
    {
        Tween24.tween(this, 0.5).fadeOut().onComplete(function() : void{dispatchEvent(new Event("FADE_OUT_COMPLETE"));}).play();
    }

    public function dispose() : void
    {
        if (this && this.hasEventListener(Event.ENTER_FRAME)) this.removeEventListener(Event.ENTER_FRAME, onUpdate);
        if (_progressTF && _progressTF.parent) _progressTF.parent.removeChild(_progressTF);
        if (_bar && _bar.parent) _bar.parent.removeChild(_bar);
        _progressTF = null;
        _bar = null;
    }
}