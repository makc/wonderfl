/*
 * //////////////////////////////////////////////////////////
 * Re-BUILD

 * BGM(BPM)に同期してアニメーションします。
 * 
 * BPMとの同期にはBeInteractive!先生のBeatTimerを使ってます。
 * 
 * デフォルトのBGMは友人に作ってもらいました。
 * http://araoto.com
 * 
 * //////////////////////////////////////////////////////////
 * ステージクリックするとローカルのmp3もアップロードも可能です
 * BPMを設定してスタート（mp3のBPMは事前に調べてね）
 * 
 * 4拍子のBGMだといい感じに同期するようにしてます。
 * 
 * mp3のアップロードに関しては、makc3dさんの
 * http://wonderfl.net/c/wzzu
 * に書いてあった「ClientMP3Loader」クラスを拝借しました。
 * 
 * /////////////////////////////////////////////////////////
 * 同期のタイミング
 * 建物　　　：4拍毎
 * 車→　　　：16拍毎
 * 車←　　　：4泊毎
 * バイク　　：16泊毎
 * 白線　　　：1泊毎
 * カメラ移動：8泊毎
 * 
 * //////////////////////////////////////////////////////////
 * 地面の色の変化：60秒間茶色保持→100秒かけて緑に変化
 * 以降、100秒毎に緑と白を繰り返し
 * 緑色になるとバイク登場
 * 空の色の変化：60秒間で一日
 * 
 * //////////////////////////////////////////////////////////
 * 以下のサイトでSCREEN SAVERとして配布してるので気に入ったら使ってやってくださいませ。
 * http://re-build.393.bz
 * */

package 
{
    import com.bit101.components.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.media.*;
    import flash.net.*;
    import flash.text.*;
    import org.libspark.betweenas3.*;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.*;
    import org.papervision3d.*;
    import org.papervision3d.cameras.*;
    import org.papervision3d.lights.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.shadematerials.*;
    import org.papervision3d.materials.special.*;
    import org.papervision3d.materials.utils.*;
    import org.papervision3d.objects.*;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.render.*;
    import org.papervision3d.view.*;
    import org.papervision3d.view.stats.*;
    
    /**
     * ...
     * @author 393
     */
    public class MainNoScale extends BasicView 
    {
        protected var _cubeArray:/*DisplayObject3D*/Array = [];
        protected var _planeArray:/*DisplayObject3D*/Array = [];
        protected var _lineArray:/*DisplayObject3D*/Array = [];
        protected var _carArray:/*DisplayObject3D*/Array = [];
        protected var _car:Car;
        
        protected var _beatTimer:BeatTimer;
        protected var _sound:Sound;
        protected var _soundChannel:SoundChannel;
        
        protected var _light:PointLight3D;
        
        protected var _isOnBeat:Boolean;
        protected var _isOnBeatLine:Boolean;
        protected var _isOnBeatCar:Boolean;
        protected var _isOnBeatCarReverse:Boolean;
        protected var _isNight:Boolean;
        protected var _isOnBeatRoad:Boolean;
        protected var _isOnBeatTempo:Boolean;
            
        protected var _skyColor:Object = {lowR:0xCC,lowG:0xFF,lowB:0xFF, highR:0x77,highG:0xCC,highB:0xEE};
        protected var _skyColorBlue:Object = { lowR:0xCC,lowG:0xFF,lowB:0xFF, highR:0x77,highG:0xCC,highB:0xEE };
        protected var _skyColorOrange:Object = { lowR:0xFF,lowG:0x99,lowB:0x00, highR:0xCC,highG:0x33,highB:0x00 };
        protected var _skyColorBlack:Object = { lowR:0x99,lowG:0x99,lowB:0xCC, highR:0x33,highG:0x33,highB:0x66 };
        protected var _skyColorArray:/*Object*/Array;
        protected var _layerColorArray:/*Object*/Array = [{color:0,alpha:0},{color:0x993300,alpha:0.4},{color:0,alpha:0.5}];
        protected var _starAlphaArray:/*int*/Array = [0,0.2,1];
        protected var _timeArray:/*Object*/Array = [{tween:5,delay:10},{tween:10,delay:25},{tween:5,delay:5}];
        protected var _bodyColorArray:/*int*/Array = [0x333366, 0x333399,  0x336633, 0x339933, 0x663333, 0x993333, 0x003333, 0x336666, 0x339999, 0x333300, 0x666633, 0x999933, 0x330033, 0x663366, 0x993399,0x666666];
        protected var _bodyColorTruckArray:/*int*/Array = [0x333399, 0x336633, 0x993333, 0x333333 ];
        protected var _landColorArray:/*Object*/Array = [{r:0x99,g:0x66,b:0x33},{r:0xAA,g:0xCC,b:0x33},{r:0xFF,g:0xFF,b:0xFF}];
        protected var _carScaleArray:/*Number*/Array = [1.0,1.2,1.4];
        
        protected var _buildingColor:Object             = {R:0x33,G:0x33,B:0x33};
        protected var _bulidingColorRed:Object         = {R:0xCC,G:0x33,B:0x33};
        protected var _buildingColorYellow:Object     = {R:0xCC,G:0xCC,B:0x33};
        protected var _buildingColorGreen:Object     = {R:0x33,G:0xCC,B:0x33};
        protected var _buildingColorMosGreen:Object     = {R:0x33,G:0xCC,B:0xCC};
        protected var _buildingColorBlue:Object      = {R:0x33,G:0x33,B:0xCC};
        protected var _buildingColorPurple:Object      = {R:0xCC,G:0x33,B:0xCC};
        protected var _buildingColorArray:Array;
        protected var _buildingColorTime:int;
        
        protected var _matrix:Matrix = new Matrix();
        
        protected var _layer:Sprite;
        protected var _field:Sprite;
        protected var _sky:Sprite;
        protected var _star:Sprite;
        protected var _ship:Ship;
        
        protected var _w:int;
        protected var _h:int;
        
        protected var _mousePoint:Point;
        protected var _angle:Number = 0;
        protected var _angleSpeed:Number = 0.04;
        protected var _count:Number = 0;
        
        protected var _carCount:int = 1;
        protected var _carLength:int = 4;
        protected var _speed:int = 20;
        protected var _destroyLength:int = 10;
        protected var _measureSec:Number = 0;
        protected var _roadTweenCount:int = 0;
        protected var _carsTweenTime:Number = 0;
        protected var _carTweenTime:Number = 0;
        protected var _landTweenTime:int = 240;
        protected var _buildColorTweenDelay:int = 0;
        
        protected var _beatTime:int = 140;
        
        protected var _controller:Sprite;
        protected var _text:Text;
        protected var _isOnBeatBike:Boolean;
        protected var _bike:Bike;
        protected var _isLandGreen:Boolean;
        
        protected var _landTweenDelayTime:int;
        private var _bg:Sprite;
        private var _tempoCount:int;
        
        private var _bikeMoveTween:ITween;
        private var _isBikeMoving:Boolean;
        private var _carsMoveTween:ITween;
        private var _isCarsMoving:Boolean;
        private var _carMoveTween:ITween;
        private var _isCarMoving:Boolean;
        private var _mp3:ClientMP3Loader;
        private var _controllerContainer:Sprite;
        private var _controllerBg:Sprite;
        private var _isDefaultSound:Boolean = true;
        
        public function MainNoScale(w:int = 465, h:int = 465,landTweenTime:int = 30, landTweenDelayTime:int = 60):void 
        {
            _w = w;
            _h = h;
            
            _mousePoint = new Point(w / 2, h / 2);
            _beatTimer = new BeatTimer();
            
            Papervision3D.PAPERLOGGER.unregisterLogger(Papervision3D.PAPERLOGGER.traceLogger);
            super(_w, _h, false, false, CameraType.FREE);
            
            _measureSec = 4 / (_beatTime / 60);
            _carTweenTime = _measureSec / 4;
            _carsTweenTime = _measureSec * 2;
            _speed = _beatTime / 6;
            _buildingColorTime = _measureSec * 4;
            _landTweenTime = landTweenTime;
            _landTweenDelayTime = landTweenDelayTime;
            _buildColorTweenDelay = _landTweenTime + _landTweenDelayTime;
            
            if (stage) init(null);
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        public function setBeatTime(beatTime:int):void
        {
            _beatTime = beatTime;
            _measureSec = 4 / (_beatTime / 60);
            _carTweenTime = _measureSec / 4;
            _carsTweenTime = _measureSec * 2;
            _speed = _beatTime / 6;
            _buildingColorTime = _measureSec * 4;
            
            _beatTimer.start(_beatTime);
        }
        
        protected function init(e:Event):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.MEDIUM;
            
            var index:int = 1;
            var hour:int = new Date().hours;
            if (hour >= 6 && hour <= 15) index = 1;
            else if (hour >= 16 && hour <= 19) index = 2;
            else if (hour >= 19 || hour > 0 && hour <= 5 ) index = 0;
            
            create2DObject(index);
            create3DObject();
            
            var colorIndex:int = index - 1;
            if (colorIndex < 0) colorIndex = 2;
            var ct:ColorTransform = new ColorTransform(1, 1, 1, _layerColorArray[colorIndex].alpha);
            ct.color = _layerColorArray[colorIndex].color;
            _layer.transform.colorTransform = ct;
            
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            
            createSound();
            next(index);
            
            _buildingColorArray = [_bulidingColorRed, _buildingColorYellow,_buildingColorGreen,_buildingColorMosGreen, _buildingColorBlue,_buildingColorPurple];
            _buildingColorTime = _measureSec * 8;
            buildingColorNext(0);
            
            stage.addEventListener(Event.RESIZE, resizeHandler);
            resizeHandler(null);
        }
        
        protected function create2DObject(index:int = 1):void 
        {
            var skyColorLow:int;
            var skyColorHight:int;
            if (index == 2) 
            {
                skyColorLow = _skyColorOrange.lowR << 16 | _skyColorOrange.lowG << 8 | _skyColorOrange.lowB;
                skyColorHight = _skyColorOrange.highR << 16 | _skyColorOrange.highG << 8 | _skyColorOrange.highB;
                _skyColor = {lowR:_skyColorOrange.lowR,lowG:_skyColorOrange.lowG,lowB:_skyColorOrange.lowB, highR:_skyColorOrange.highR,highG:_skyColorOrange.highG,highB:_skyColorOrange.highB};
            }
            else if (index == 0) 
            {
                skyColorLow = _skyColorBlack.lowR << 16 | _skyColorBlack.lowG << 8 | _skyColorBlack.lowB;
                skyColorHight = _skyColorBlack.highR << 16 | _skyColorBlack.highG << 8 | _skyColorBlack.highB;
                _skyColor = {lowR:_skyColorBlack.lowR,lowG:_skyColorBlack.lowG,lowB:_skyColorBlack.lowB, highR:_skyColorBlack.highR,highG:_skyColorBlack.highG,highB:_skyColorBlack.highB};
            }
            else
            {
                skyColorLow = _skyColorBlue.lowR << 16 | _skyColorBlue.lowG << 8 | _skyColorBlue.lowB;
                skyColorHight = _skyColorBlue.highR << 16 | _skyColorBlue.highG << 8 | _skyColorBlue.highB;
                _skyColor = {lowR:_skyColorBlue.lowR,lowG:_skyColorBlue.lowG,lowB:_skyColorBlue.lowB, highR:_skyColorBlue.highR,highG:_skyColorBlue.highG,highB:_skyColorBlue.highB};
            }
            
            
            //
            _bg = new Sprite();
            addChildAt(_bg,0);
            with (_bg.graphics)
            {
                //堤防
                beginFill(0xEFEFEF);
                drawRect(0, _h / 2 +10, _w, 10);
                beginFill(0xDEDEDE);
                drawRect(0, _h / 2 +10, _w, 2);
                //海
                beginFill(0x6699CC);
                drawRect(0, _h/2-10, _w, 20);
            }
            
            //地面
            addChildAt(_field = new Sprite(), 0);
            _field.graphics.beginFill(0);
            _field.transform.colorTransform = new ColorTransform(1, 1, 1, 1, _landColorArray[0].r, _landColorArray[0].g, _landColorArray[0].b);
            _field.graphics.drawRect(0, _h / 2, _w, _h / 2);
            var landTween:ITween = BetweenAS3.delay(BetweenAS3.to(_field, { transform: { colorTransform: { redOffset:_landColorArray[1].r, greenOffset:_landColorArray[1].g, blueOffset:_landColorArray[1].b }}}, _landTweenTime, Linear.linear), _landTweenDelayTime);
            landTween.onComplete = function():void
            {
                _isLandGreen = true;
                var landTween0:ITween = BetweenAS3.delay(BetweenAS3.tween(_field, { transform: { colorTransform:  { redOffset:_landColorArray[2].r, greenOffset:_landColorArray[2].g, blueOffset:_landColorArray[2].b }}},{ transform: { colorTransform:  { redOffset:_landColorArray[1].r, greenOffset:_landColorArray[1].g, blueOffset:_landColorArray[1].b }}}, 5, Linear.linear), 100);
                var landTween1:ITween = BetweenAS3.delay(BetweenAS3.tween(_field, { transform: { colorTransform:  { redOffset:_landColorArray[1].r, greenOffset:_landColorArray[1].g, blueOffset:_landColorArray[1].b }}},{ transform: { colorTransform:  { redOffset:_landColorArray[2].r, greenOffset:_landColorArray[2].g, blueOffset:_landColorArray[2].b }}}, 5, Linear.linear), 100);
                var repeatLandTween:ITween = BetweenAS3.serial(landTween0, landTween1);
                repeatLandTween.stopOnComplete = false;
                repeatLandTween.play();
            }
            landTween.play();
            
            //星
            addChildAt(_star = new Sprite(),0).alpha = 0;
            var starLength:int = 50;
            var i:int = 0;
            for (i = 0; i < starLength; i++)
            {
                _star.graphics.beginFill(0xFFFF00, 1);
                _star.graphics.drawCircle(3000/starLength * i + Math.random()*3000/starLength,Math.random()*100 + 60, Math.random()+0.2);
                _star.graphics.endFill();
            }
            //バイク
            addChild(_bike = new Bike());
            _bike.scaleX =  -0.6;
            _bike.scaleY =  0.6;
            _bike.x = -_bike.width;
            _bike.y = 375;
            
            //車の生成
            for ( i =  0; i < _carLength; i++)
            {
                addChild(_carArray[i] = new Car("truck"));
                _carArray[i].scaleX = _carArray[i].scaleY = 0.5;
                _carArray[i].x = -_carArray[i].width;
                _carArray[i].y = _h / 2 + 145;
            }
            //対向車
            addChild(_car = new Car("truck"));
            _car.scaleX = -0.6;
            _car.scaleY =  0.6;
            _car.x = _w + _car.width;
            _car.y = _h / 2 + 167;
            
            //船
            addChildAt(_ship = new Ship(),3);
            _ship.scaleX = -0.3;
            _ship.scaleY = 0.3;
            _ship.x = _w + _ship.width;
            _ship.y = _h / 2 - 15;
            
            //前面カラーフィルター
            addChild(_layer = new Sprite()).alpha = 0;
            _layer.graphics.beginFill(0);
            _layer.graphics.drawRect(0, 0, _w, _h);
            
            //背景
            _skyColorArray = [_skyColorBlue,_skyColorOrange,_skyColorBlack];
            _matrix.createGradientBox(_w, _h, -Math.PI / 2);
            _sky = new Sprite();
            _sky.graphics.beginGradientFill("linear", [skyColorLow, skyColorHight], [1, 1], [125, 255], _matrix);
            _sky.graphics.drawRect(0, 0, _w, _h);
            addChildAt(_sky,0);
        }
        
        protected function create3DObject():void 
        {
            //道路
            var road:Plane = new Plane(new ColorMaterial(0xCCCCCC, 1), 5000, 100);
            road.rotationX = 90;
            scene.addChild(road);
            road.y = -1001;
            road.z = -1035;
            
            _light = new PointLight3D(true, false);
            scene.addChild(_light);
            _light.y = -4000;
            _light.z = -1000;
            
            camera.z = -1500;
            camera.y = -800;
                        
            //レンダラーの更新
            renderer = new QuadrantRenderEngine(QuadrantRenderEngine.ALL_FILTERS);
            startRendering();
                    
            stage.addChild(new StatsView(renderer));
        };
        
        private function resizeHandler(e:Event):void 
        {
            _w = stage.stageWidth;
            _h = stage.stageHeight;
            
            viewport.viewportWidth = stage.stageWidth;
            viewport.viewportHeight = stage.stageHeight;
            
            _layer.width = _w;
            _layer.height =  _h;
            
            _field.width = _w;
            _field.height = _h / 2;
            
            for (var i:int = 0; i < _carLength; i++)
            {
                _carArray[i].visible = false;
            }
            _car.visible = false;
            _bike.visible = false;
            
            with (_bg.graphics)
            {
                //堤防
                clear();
                beginFill(0xEFEFEF);
                drawRect(0, _h / 2 +10, _w, 10);
                beginFill(0xDEDEDE);
                drawRect(0, _h / 2 +10, _w, 2);
                //海
                beginFill(0x6699CC);
                drawRect(0, _h/2-10, _w, 20);
            }
            
            _car.y = _h / 2 + 167;
            _ship.y = _h / 2 - 15;
            
            _controllerBg.width = _w;
            _controllerBg.height = _h;
            _controllerContainer.x = _w / 2 - _controllerContainer.width / 2;
            _controllerContainer.y = _h / 2 - _controllerContainer.height / 2;
        }
        
        protected function buildingColorNext(index:int = 0):void 
        {
            var obj:Object = _buildingColorArray[index];
            var iTween:ITween = BetweenAS3.delay(BetweenAS3.to(_buildingColor, { R:obj.R, G:obj.G, B:obj.B }, _buildingColorTime, Linear.linear),_buildColorTweenDelay);
            iTween.onComplete = function():void {
                index++;
                _buildColorTweenDelay = 0;
                if (index >= _buildingColorArray.length) index = 0;
                buildingColorNext(index);
            };
            iTween.play();
        }
        
        protected function createSound():void 
        {
            _sound = new Sound();
            _sound.load(new URLRequest("http://re-build.393.bz/sound/393_hukkou_BPM140_ver2.mp3"));
            _sound.addEventListener(Event.COMPLETE, loadCompleteHadler);
            _sound.addEventListener(IOErrorEvent.IO_ERROR, function():void{});
            
            //コントローラーUI
            _mp3 = new ClientMP3Loader;
            _mp3.addEventListener(Event.CANCEL, cancelHandler);
            _mp3.addEventListener(Event.COMPLETE, loadCompleteHandler);
            
            _controller = createController();
            addChild(_controller).visible = false;
            
            stage.addEventListener(MouseEvent.CLICK, stage_clickHandler);
            this.buttonMode = true;
        }
        protected function createController():Sprite 
        {
            _controllerBg = new Sprite();
            _controllerBg.graphics.beginFill(0x000000,0.5);
            _controllerBg.graphics.drawRect(0, 0, _w, _h);
            _controllerBg.graphics.endFill();
            _controllerContainer = new Sprite();
            _controllerContainer.graphics.beginFill(0xFFFFFF);
            _controllerContainer.graphics.drawRect(0, 0, 400, 200);
            _controllerContainer.graphics.endFill();
            _controllerContainer.x = _w / 2 - _controllerContainer.width / 2;
            _controllerContainer.y = _h / 2 - _controllerContainer.height / 2;
            var label:Label = new Label(_controllerContainer, 50, 10, "BPM:");
            label.scaleX = label.scaleY = 5;
            _text = new Text(_controllerContainer, 198, 28, "120");
            _text.scaleX = _text.scaleY = 3;
            var tf:TextField = _text.textField;
            tf.restrict = "0-9";
            tf.maxChars = 3;
            tf.autoSize = "right";
            _text.width = 50;
            _text.height = 20;
            var button:PushButton = new PushButton(_controllerContainer, 50, 110, "START",startClickHandler);
            button.width = 100;
            button.height = 20;
            button.scaleX = button.scaleY = 3;
            var sp:Sprite =  new Sprite();
            sp.addChild(_controllerBg);
            sp.addChild(_controllerContainer);
            
            return sp;
        }
        //サウンド読み込み完了後の処理
        protected function loadCompleteHadler(e:Event):void {
            _sound.removeEventListener(Event.COMPLETE, loadCompleteHadler);
            soundStart(_beatTime);
        }
        //サウンドの開始
        protected function soundStart(beatTime:int):void {
            _soundChannel = _sound.play(0);
            setBeatTime(_beatTime);
            _beatTimer.start(beatTime);
            _soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler );
        }
        //サウンド終了後の処理
        protected function soundCompleteHandler(e:Event):void {
            _soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler );
            soundStart(_beatTime);
        }
        //BPMパネルからスタート
        protected function startClickHandler(e:MouseEvent):void 
        {
            _controller.visible = false;
            _isDefaultSound = false;
            _beatTime = int(_text.text);
            soundStart(_beatTime);
            e.stopPropagation();
            stage.addEventListener(MouseEvent.CLICK, stage_clickHandler);
        }
        //ステージクリック時の処理
        protected function stage_clickHandler(e:MouseEvent):void
        {
            stage.removeEventListener(MouseEvent.CLICK, stage_clickHandler);
            _beatTimer.start(0);
            if(_soundChannel) _soundChannel.stop();
            _mp3.load ();
        }
        //アップロードキャンセル時の処理
        protected function cancelHandler(e:Event):void 
        {
            stage.addEventListener(MouseEvent.CLICK, stage_clickHandler);
            soundStart(_beatTime);
        }
        //MP3読み込み完了後の処理
        protected function loadCompleteHandler(e:Event):void 
        {
            _controller.visible = true;
            if (_soundChannel) 
            {
                _soundChannel.stop();
                _soundChannel = null;
            }
            _sound = _mp3.sound;
        }
        
        protected function next(index:int = 0):void 
        {
            if (!index) _star.alpha = 1;
            
            var r:uint = (_layerColorArray[index].color & 0xFF0000) >> 16;
            var g:uint = (_layerColorArray[index].color & 0xFF00) >> 8;
            var b:uint = _layerColorArray[index].color & 0xFF;
            var obj:Object = _skyColorArray[index];
            var iTween1:ITween = BetweenAS3.delay(BetweenAS3.to(_skyColor, { lowR:obj.lowR, lowG:obj.lowG, lowB:obj.lowB, highR:obj.highR, highG:obj.highG, highB:obj.highB }, _timeArray[index].tween, Linear.linear), _timeArray[index].delay);
            var iTween2:ITween = BetweenAS3.delay(BetweenAS3.to(_layer, {transform:{colorTransform:{redOffset:r,greenOffset:g,blueOffset:b,alphaMultiplier:_layerColorArray[index].alpha}}}, _timeArray[index].tween, Linear.linear),_timeArray[index].delay);
            var iTween3:ITween = BetweenAS3.delay(BetweenAS3.to(_star, { alpha:_starAlphaArray[index]}, _timeArray[index].tween, Linear.linear),_timeArray[index].delay);
            iTween1.onComplete = function():void {
                if (index == 2) _isNight = true;
                else _isNight = false;
                var length:int = _carArray.length;
                for (var i:int = 0; i < length; i++)
                {
                    _carArray[i].light = _isNight;
                }
                _car.light = _isNight;
                _bike.light = _isNight
                
                index++;
                if (index >= _skyColorArray.length) index = 0;
                next(index);
            };
            iTween1.play();
            iTween2.play();
            iTween3.play();
        }
        
        protected function enterFrameHandler(e:Event):void
        {
            _matrix.createGradientBox(stage.stageWidth, stage.stageHeight, -Math.PI / 2);
            var color1:int = _skyColor.lowR << 16 | _skyColor.lowG << 8 | _skyColor.lowB;
            var color2:int = _skyColor.highR << 16 | _skyColor.highG << 8 | _skyColor.highB;
            _sky.graphics.clear();
            _sky.graphics.beginGradientFill("linear", [color1,color2] , [1, 1], [125, 255],_matrix);
            _sky.graphics.drawRect(0, 0, stage.stageWidth*2, stage.stageHeight);
            
            _beatTimer.update();
            
            //テンポアップ用
            //ある拍数になったらテンポアップする処理
            //デフォルトの曲に合わせた設定値なのでアップロード後は無効化
            if (_isDefaultSound)
            {
                if ((_beatTimer.beatPosition | 0) % 4 == 0)
                {
                    if (!_isOnBeatTempo)
                    {
                        _isOnBeatTempo = true;
                        _tempoCount++;
                        if (_tempoCount == 17) setBeatTime(280);
                        if (_tempoCount == 49) setBeatTime(140);
                        if (_tempoCount == 57) setBeatTime(280);
                    }
                }
                else _isOnBeatTempo = false;
            }
            
            
            if ((_beatTimer.beatPosition | 0) % 4 == 3)
            {
                if (!_isOnBeat)
                {
                    _isOnBeat = true;
                    
                    //建物生成
                    var cubeW:int = 500 + int(Math.random() * 4) * 150;
                    var cubeD:int = cubeW;
                    var cubeH:int = 200 + int(Math.random() * 6) * 200;
                    //var cubeColor:int = Math.random() * 0xFFFF7F;
                    var cubeColor:int = _buildingColor.R << 16 | _buildingColor.G << 8 | _buildingColor.B;
                    var flatShadeMaterial:FlatShadeMaterial = new FlatShadeMaterial(_light, 0xFFFFFF, cubeColor);
                    var cubeMaterialFront:BitmapMaterial = cubeWall(cubeW, cubeH, cubeColor, true );
                    var cubeMaterialSide:BitmapMaterial = cubeWall(cubeW, cubeH, cubeColor, false );
                    var compositeMaterialFront:CompositeMaterial = new CompositeMaterial();
                    compositeMaterialFront.addMaterial(flatShadeMaterial);
                    compositeMaterialFront.addMaterial(cubeMaterialFront);
                    var compositeMaterialSide:CompositeMaterial = new CompositeMaterial();
                    compositeMaterialSide.addMaterial(flatShadeMaterial);
                    compositeMaterialSide.addMaterial(cubeMaterialSide);
                    var colorMaterial:ColorMaterial = new ColorMaterial(0,0);
                    var materialList:MaterialsList = new MaterialsList( { back:compositeMaterialFront, left:compositeMaterialSide, right:compositeMaterialSide, bottom:colorMaterial,front:colorMaterial,top:colorMaterial } );
                    var cube:Cube = new Cube(materialList, cubeW, cubeD, cubeH);
                    cube.name = "cube";
                    var cubeContainer:DisplayObject3D = new DisplayObject3D();
                    cubeContainer.addChild(cube);
                    cube.y = cubeH / 2;
                    scene.addChild(cubeContainer);
                    cubeContainer.x = 800;
                    cubeContainer.y = -1000;
                    cubeContainer.z = int(Math.random() * 4) * 500;
                    cubeContainer.scaleY = 0;
                    _cubeArray.push(cubeContainer);
                    
                    //道路生成
                    var cMaterial:ColorMaterial = new ColorMaterial(0xCCCCCC);
                    var planeD:int = cubeContainer.z +1000 - cubeD / 2;
                    var plane:Plane = new Plane(cMaterial, 100, planeD);
                    plane.name = "plane";
                    var planeContainer:DisplayObject3D = new DisplayObject3D();
                    planeContainer.addChild(plane);
                    plane.y = planeD / 2;
                    planeContainer.rotationX = 90;
                    planeContainer.y = -1000;
                    planeContainer.x = 800;
                    planeContainer.z = -1000;
                    planeContainer.scaleY = 0;
                    scene.addChild(planeContainer);
                    _planeArray.push(planeContainer);
                    
                    var cubeTween:ITween = BetweenAS3.to(cubeContainer, { scaleY:1 }, 1, Elastic.easeOut);
                    var planeTween:ITween = BetweenAS3.to(planeContainer, { scaleY:1 }, .3, Sine.easeOut);
                    BetweenAS3.serial(planeTween, cubeTween).play();
                                                            
                    //破棄
                    if (_cubeArray.length > _destroyLength)
                    {
                        var delCube:Cube = _cubeArray[0].getChildByName("cube") as Cube;
                        delCube.material.destroy();
                        _cubeArray[0].removeChild(delCube);
                        scene.removeChild(_cubeArray[0]);
                        _cubeArray[0] = null;
                        
                        var delPlane:Plane = _planeArray[0].getChildByName("plane") as Plane;
                        delPlane.material.destroy();
                        _planeArray[0].removeChild(delPlane);
                        scene.removeChild(_planeArray[0]);
                        _planeArray[0] = null;
                        
                        _cubeArray.shift();
                        _planeArray .shift();
                    }
                }
            }
            else _isOnBeat = false;
            
            //cameraZのTween
            if ((_beatTimer.beatPosition | 0) % 8 == 2)
            {
                if (!_isOnBeatRoad)
                {
                    _isOnBeatRoad = true;
                    if (_roadTweenCount % 2)
                    {
                        var posY:int = 465
                    }
                    else
                    {
                        posY = 0;
                    }
                    var _mousePointTween0:ITween = BetweenAS3.to(_mousePoint, { y:posY }, _measureSec *2 , Sine.easeOut);
                    var _mousePointTween1:ITween = BetweenAS3.to(_mousePoint, { y:232 }, _measureSec *2, Sine.easeIn);
                    BetweenAS3.serial(_mousePointTween0, _mousePointTween1).play();
                    _roadTweenCount ++;
                }
            }
            else _isOnBeatRoad = false;

            if (_beatTimer.isOnBeat)
            {
                //白線
                cMaterial = new ColorMaterial(0xEFEFEF);
                var line:Plane = new Plane(cMaterial, 130, 10);
                line.name = "line";
                line.rotationX = 90;
                line.y = -1000;
                line.x = 1000;
                line.z = -1030;
                scene.addChild(line);
                _lineArray.push(line);
                //破棄
                if (_lineArray.length > _destroyLength)
                {
                    _lineArray[0].material.destroy();
                    scene.removeChild(_lineArray[0]);
                    _lineArray[0] = null;
                    _lineArray.shift();
                }
            }
            //対向車
            var array:Array;
            if ((_beatTimer.beatPosition | 0) % 4 == 1)
            {
                if (!_isOnBeatCarReverse)
                {
                    for (i = 0; i < _carCount; i++)
                    {
                        if (Math.random() > _count)
                        {
                            if (Math.random() > 0.5) _car.type = "truck";
                            else _car.type = "truck_horo";
                        }
                        else
                        {
                            if (Math.random() > 0.8) _car.type = "normal";
                            else _car.type = "normal_hb";
                        }
                        if (_car.type == "normal" || _car.type == "normal_hb") array = _bodyColorArray;
                        else array = _bodyColorTruckArray;
                        _car.bodyColor = array[int(Math.random() * array.length)];
                        _car.changeBodyScaleX(_carScaleArray[int(_carScaleArray.length*Math.random())]);
                        _isOnBeatCarReverse = true;
                        
                        
                        if (! _isCarMoving)
                        {
                            _car.visible = true;
                            _carMoveTween = BetweenAS3.tween(_car, { x: -_car.width }, { x: _car.width + _w }, _carTweenTime, Linear.linear);
                            _carMoveTween.onComplete = function():void { _isCarMoving = false; };
                            _carMoveTween.play();
                            _isCarMoving = true;
                        }
                    }
                }
            }
            else _isOnBeatCarReverse = false;
            //バイク
            if ((_beatTimer.beatPosition | 0) % 16 == 11)
            {
                if (!_isOnBeatBike && _isLandGreen)
                {
                    _isOnBeatBike = true;
                    _bikeMoveTween = BetweenAS3.tween(_bike, { x: _bike.width + _w }, { x: -_bike.width }, _measureSec * 4 - 0.1, Back.easeOutIn);
                    _bikeMoveTween.onComplete = function():void { _isBikeMoving = false; };
                    
                    if (!_isBikeMoving)
                    {
                        _bikeMoveTween.play();
                        _bike.visible = true;
                        _isBikeMoving = true;
                    }
                    
                }
            }
            else _isOnBeatBike = false;
            //車
            if ((_beatTimer.beatPosition | 0) % 16 == 15)
            {
                if (!_isOnBeatCar)
                {
                    _count += 0.05;
                    if (_count > 0.9) _count = 0.9;
                    var tweenArray:Array = [];
                    for (i = 0; i < _carCount; i++)
                    {
                        if (Math.random() > _count)
                        {
                            if (Math.random() > 0.5) _carArray[i].type = "truck";
                            else _carArray[i].type = "truck_horo";
                        }
                        else
                        {
                            if (Math.random() > 0.8) _carArray[i].type = "normal";
                            else _carArray[i].type = "normal_hb";
                        }
                        if (_carArray[i].type == "normal" || _carArray[i].type == "normal_hb") array = _bodyColorArray;
                        else array = _bodyColorTruckArray;
                        _carArray[i].bodyColor = array[int(Math.random() * array.length)];
                        var carScaleX:Number = _carScaleArray[int(_carScaleArray.length * Math.random())];
                        _carArray[i].changeBodyScaleX(carScaleX);
                        _isOnBeatCar = true;
                        
                        _carArray[i].visible = true;
                        
                        tweenArray[i] = BetweenAS3.delay(BetweenAS3.tween(_carArray[i], { x:_w + (_carArray[i].width * 3) * (_carCount - i) }, { x: -_carArray[i].width * 2 * (_carCount) }, _carsTweenTime, Circ.easeOutIn), i * _measureSec / 4);
                    }
                    
                    
                    if (!_isCarsMoving)
                    {
                        _carsMoveTween = BetweenAS3.parallelTweens(tweenArray);
                        _carsMoveTween.onComplete = function():void {
                            _isCarsMoving = false 
                        };
                        _carsMoveTween.play();
                        _isCarsMoving = true;
                    }
                    
                    _carCount++;
                    if (_carCount > _carLength) _carCount = 1;
                }
            }
            else _isOnBeatCar = false;
            
            //ビル、道路、白線の移動
            var length:int = _cubeArray.length;
            for (var i:int = 0; i < length; i++)
            {
                _cubeArray[i].x -= _speed;
                _planeArray[i].x -= _speed;
            }
            length = _lineArray.length;
            for (i = 0; i < length; i++)
            {
                _lineArray[i].x -=_speed;
            }
            //船のループ
            _ship.x -= 0.1;
            if (_ship.x < -_ship.width) _ship.x = _w + _ship.width;
            
            //cameraのアングル変更
            var distance:int = ((_mousePoint.y / 465) -0.5) * 300 + 1500;
            camera.z = -distance;
            
            //車の奥行き移動
            length = _carArray.length;
            for (i = 0; i < length; i++)
            {
                _carArray[i].y = (_h/2 + 105)  + Math.pow((_mousePoint.y - 140) / 465 -1, 2) * 62
                _carArray[i].scaleX = _carArray[i].scaleY = (338 + Math.pow((_mousePoint.y - 100) / 465 -1, 2) * 90) / 378 * 0.5;
            }
            _car.y = (_h/2 + 117) + Math.pow(((_mousePoint.y) - 120) / 465 -1, 2) * 80;
        
            _car.scaleX = -(350 + Math.pow((_mousePoint.y - 120) / 465 -1, 2) * 100) / 400 * 0.6;
            _car.scaleY = _car.scaleX * -1;
            
            _bike.y = _h/2 + 105 + Math.pow((_mousePoint.y - 110) / 465 -1, 2) * 58
            _bike.scaleX = _bike.scaleY = (338 + Math.pow((_mousePoint.y - 100) / 465 -1, 2) * 90) / 378 * 0.35;
        }
        
        protected function cubeWall(w:int, h:int, color:int , isFront:Boolean = false):BitmapMaterial
        {
            var bmd:BitmapData = new BitmapData(w, h, true, 0x00FFFFFF);
            var windowColor:int;
            if (_isNight) windowColor = 0xCCFFFF00;
            else windowColor = 0x7FFFFFFF;
            
            var lengthW:int = w / 150;
            var lengthH:int = (h) / 200;
            for (var i:int = 0; i < lengthH; i++)
            {
                for (var ii:int = 0; ii < lengthW; ii++)
                {
                    var windowW:int = 120;
                    var windowH:int = 60;
                    var rect:Rectangle = new Rectangle(ii * 150 + 40, i * 200 + 50, windowW, windowH);
                    bmd.fillRect(rect, windowColor);
                }
            }
            var bmMaterial:BitmapMaterial = new BitmapMaterial(bmd);
            bmMaterial.precise = !isFront;
            return bmMaterial;
        }
        
        
    }
}
import com.codeazur.as3swf.*;
import com.codeazur.as3swf.data.*;
import com.codeazur.as3swf.tags.*;
import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.media.*;
import flash.net.*;
import flash.utils.*;
import frocessing.shape.*;
class BeatTimer
{
    public function BeatTimer()
    {
    }
    
    private var _bpm:Number;
    private var _startTime:uint;
    private var _beatPosition:Number;
    private var _phase:Number;
    private var _isOnBeat:Boolean = false;
    
    public function get bpm():Number
    {
        return _bpm;
    }
    
    public function get beatPosition():Number
    {
        return _beatPosition;
    }
    
    public function get phase():Number
    {
        return _phase;
    }
    
    public function get isOnBeat():Boolean
    {
        return _isOnBeat;
    }
    
    public function start(bpm:Number):void
    {
        _bpm = bpm;
        _startTime = getTimer();
        update();
    }
    
    public function update():void
    {
        var currentTime:uint = getTimer();
        var beatInterval:Number = (60 * 1000) / _bpm;
        var oldPosition:Number = _beatPosition;
        
        _beatPosition = (currentTime - _startTime) / beatInterval;
        _phase = _beatPosition - int(_beatPosition);
        _isOnBeat = int(oldPosition) != int(_beatPosition);
    }
}

/**
 * ...
 * @author 393
 */
    class Car extends Sprite 
    {
        private var _bodyColor:uint;
        private var _windowColor:uint;
        private var _bgColor:uint;
        private var _wheelColor:uint;
        private var _tireColor:uint;
        private var _body:Sprite;
        private var _window:Sprite;
        private var _frontTire:Sprite;
        private var _rearTire:Sprite;
        private var _car:Sprite;
        private var _shadow:Sprite;
        private var _rearTireArea:Sprite;
        private var _frontTireArea:Sprite;
        private var _light:Sprite;
        private var _type:String;
        
        public function Car(type:String="normal",bodyColor:int = 0x666666,windowColor:int = 0xEEEEEE,tireColor:int = 0x666666,wheelColor:int = 0xEEEEEE,bgColor:int = 0xCCCCCC) 
        {            
            _car = new Sprite();
            addChild(_car);
            _type = type;
            _bodyColor = bodyColor;
            _windowColor = windowColor;
            _wheelColor = wheelColor;
            _tireColor = tireColor;
            _bgColor = bgColor;
            
            createCar(_type);
            _car.height
        }    
        private function changeTirePosition(type:String):void 
        {
            switch(type)
            {
                case "normal":
                {
                    _rearTireArea.x = 23;
                    _rearTireArea.y = 42;
                    _frontTireArea.x = _body.width - 26;
                    _frontTireArea.y = 42;
                    _rearTire.x = 23;
                    _frontTire.x = _body.width - 26;
                    _frontTire.y = _rearTire.y = _body.height - 5;
                    _light.x = _body.width * 0.9;
                    _light.y = 24;
                    break;
                }
                case "normal_hb":
                {
                    _rearTireArea.x = 23;
                    _rearTireArea.y = 42;
                    _frontTireArea.x = _body.width - 26;
                    _frontTireArea.y = 42;
                    _rearTire.x = 23;
                    _frontTire.x = _body.width - 26;
                    _frontTire.y = _rearTire.y = _body.height - 5;
                    _light.x = _body.width * 0.9;
                    _light.y = 20;
                    break;
                }
                case "truck":
                case "truck_horo":
                {
                    _rearTireArea.x = 24;
                    _rearTireArea.y = 75;
                    _frontTireArea.x = _body.width - 28;
                    _frontTireArea.y = 74;
                    _rearTire.x = 24;
                    _frontTire.x = _body.width - 28;
                    _frontTire.y = _rearTire.y = _body.height - 5;
                    _light.y = 50;
                    _light.x = _body.width * 1;
                    break;
                }
            }
        }
        
        private function createCar(type:String = "normal"):void 
        {
            _rearTireArea = createTireArea();
            _frontTireArea = createTireArea();
            _frontTire = createTire(_tireColor,_wheelColor,_bgColor);
            _rearTire = createTire(_tireColor,_wheelColor,_bgColor);
            _light = new Sprite();
            
            _window = new Sprite();
            windowColor = _windowColor;
            _body = new Sprite();
            bodyColor = _bodyColor;
            
            changeTirePosition(_type);
            
            _car.addChild(_body);
            _body.addChild(_window);
            _car.addChild(_rearTireArea);
            _car.addChild(_frontTireArea);
            _car.addChild(_frontTire);
            _car.addChild(_rearTire);
            
            _car.x = -_car.width / 2;
            _car.y = -_car.height;
            
            _shadow = new Sprite();
            _car.addChildAt(_shadow, 0);
            _shadow.graphics.beginFill(0, 0.2);
            _shadow.graphics.drawEllipse(0, 0, _body.width, 10);
            _shadow.filters = [new BlurFilter(8, 8, 1)];
            _shadow.y = _car.height - 10;
            
            var matrix:Matrix = new Matrix();
            with (_light)
            {
                matrix.createGradientBox(60, 30,Math.PI/8);
                graphics.beginGradientFill("linear", [0xFFFF00, 0xFFFF00], [0.5, 0], [45, 200],matrix);
                graphics.moveTo(0, 0);
                graphics.lineTo(70, -5);
                graphics.lineTo(60, 30);
                graphics.lineTo(0, 10);
                graphics.lineTo(0, 0);
            }
            _car.addChildAt(_light,0);
            _light.visible = false;
            
            this.width
            
        }
        
        private function createTireArea():Sprite 
        {
            var mask:Sprite = new Sprite();
            mask.graphics.beginFill(0);
            mask.graphics.drawRect(-13, -13, 26, 17.5);
            var sp:Sprite = new Sprite();
            sp.graphics.beginFill(0xCCCCCC);
            sp.graphics.drawCircle(0, 0, 13);
            sp.mask = mask;
            sp.addChild(mask);
            return sp;
        }
        
        public function changeBodyScaleX(value:Number):void
        {
            _body.scaleX = value;
            _shadow.width = _body.width;
            switch(_type)
            {
                case "normal":
                case "normal_hb":
                {
                    _frontTire.x = _frontTireArea.x  =_body.width - 26;
                    _light.x = _body.width * 0.9;
                    break;
                }
                case "truck":
                case "truck_horo":
                {
                    _frontTire.x = _frontTireArea.x  = _body.width - 28*value;
                    _rearTire.x = _rearTireArea.x = 24 * value;
                    _light.x = _body.width * 1;
                    break;
                }
            }
        }

        private function createWindowNormal(color:int):Sprite 
        {
            var sp:Sprite = new Sprite();
            with (sp)
            {
                graphics.beginFill(color);
                graphics.moveTo(20, 3);
                graphics.lineTo(31, 3);
                graphics.lineTo(24, 15);
                graphics.lineTo(13, 14);
                graphics.lineTo(20, 3);
                graphics.endFill();
                graphics.beginFill(color);
                graphics.moveTo(35, 3);
                graphics.lineTo(47, 3);
                graphics.lineTo(52, 15);
                graphics.lineTo(29, 15);
                graphics.lineTo(35, 3);
                graphics.endFill();
                graphics.beginFill(color);
                graphics.moveTo(51, 3);
                graphics.lineTo(68, 3);
                graphics.lineTo(79, 15);
                graphics.lineTo(56, 15);
                graphics.lineTo(51, 3);
                graphics.endFill();
            }
            return sp;
        }
        
        private function createWindowTruck(color:int):Sprite 
        {
            var sp:Sprite = new Sprite();
            with (sp)
            {
                graphics.beginFill(color);
                graphics.moveTo(100, 8);
                graphics.lineTo(117, 8);
                graphics.lineTo(127, 25);
                graphics.lineTo(127, 33);
                graphics.lineTo(100, 33);
                graphics.lineTo(100, 8);
                graphics.endFill();
                graphics.beginFill(color);
                graphics.moveTo(5, 0);
                graphics.lineTo(80, 0);
                graphics.lineTo(80, 40);
                graphics.lineTo(5, 40);
                graphics.lineTo(5, 0);
            }
            return sp;
        }
        
        private function createBodyNormal(color:int):Sprite 
        {
            var sp:Sprite = new Sprite();
            with (sp)
            {
                graphics.beginFill(color);
                graphics.moveTo(16, 0);
                graphics.lineTo(70, 0);
                graphics.lineTo(82, 14);
                graphics.lineTo(112, 20);
                graphics.lineTo(120, 35);
                graphics.lineTo(115, 47);
                graphics.lineTo(6, 47);
                graphics.lineTo(2, 35);
                graphics.lineTo(0, 22);
                graphics.lineTo(16, 0);
                graphics.endFill();
            }
            return sp;
        }
        private function createBodyTruck(color:int):Sprite 
        {
            var sp:Sprite = new Sprite();
            with (sp)
            {
                graphics.beginFill(color);
                graphics.moveTo(0, 40);
                graphics.lineTo(80, 40);
                graphics.lineTo(80, 0);
                graphics.lineTo(87, 0);
                graphics.lineTo(87, 40);
                graphics.lineTo(90, 40);
                graphics.lineTo(90, 2);
                graphics.lineTo(120, 2);
                graphics.lineTo(143, 40);
                graphics.lineTo(143, 68);
                graphics.lineTo(131, 78);
                graphics.lineTo(96, 78);
                graphics.lineTo(90, 73);
                graphics.lineTo(40, 73);
                graphics.lineTo(40, 78);
                graphics.lineTo(8, 78);
                graphics.lineTo(8, 62);
                graphics.lineTo(0, 62);
                graphics.lineTo(0, 40);
                graphics.endFill();
            }
            return sp;
        }
        private function createTire(bodyColor:int,bodyColor2:int,bgColor:int):Sprite 
        {
            var sp:Sprite = new Sprite();
            //タイヤ
            sp.graphics.beginFill(bodyColor);
            sp.graphics.drawCircle(0, 0, 11);
            sp.graphics.endFill();
            //タイヤホイール
            sp.graphics.beginFill(bodyColor2);
            sp.graphics.drawCircle(0, 0, 7);
            sp.graphics.endFill();
            //タイヤホイール
            for (var i:int = 0; i < 5; i++)
            {
                var wheel:Sprite = new Sprite();
                wheel.graphics.beginFill(0x999999);
                wheel.graphics.drawCircle(0, 0, 1.5);
                wheel.x = 5 * Math.sin(i * Math.PI * 2 / 5);
                wheel.y = 5 * Math.cos(i * Math.PI * 2 / 5);
                sp.addChild(wheel);
            }
            sp.addEventListener(Event.ENTER_FRAME, function(e:Event):void { sp.rotation+= 25} );
            return sp;
        }
        
        public function set bodyColor(value:uint):void 
        {
            _bodyColor = value;
            _body.graphics.clear();
            _body.graphics.beginFill(value);
            switch(_type)
            {
                case "normal":
                {
                    with (_body)
                    {
                        graphics.moveTo(0, 25);
                        graphics.moveTo(2, 18);
                        graphics.lineTo(24, 12);
                        graphics.lineTo(28, 0);
                        graphics.lineTo(65, 0);
                        graphics.lineTo(83, 18);
                        graphics.lineTo(112, 24);
                        graphics.lineTo(120, 35);
                        graphics.lineTo(115, 47);
                        graphics.lineTo(6, 47);
                        graphics.lineTo(2, 35);
                        graphics.lineTo(0, 22);
                        graphics.endFill();
                    }
                    break;
                }
                case "normal_hb":
                {
                    with (_body)
                    {
                        graphics.moveTo(16, 0);
                        graphics.lineTo(70, 0);
                        graphics.lineTo(82, 14);
                        graphics.lineTo(112, 20);
                        graphics.lineTo(120, 35);
                        graphics.lineTo(115, 47);
                        graphics.lineTo(6, 47);
                        graphics.lineTo(2, 35);
                        graphics.lineTo(0, 22);
                        graphics.lineTo(16, 0);
                        graphics.endFill();
                    }
                    break;
                }
                case "truck":
                case "truck_horo":
                {
                    with (_body)
                    {
                        graphics.moveTo(0, 40);
                        graphics.lineTo(80, 40);
                        graphics.lineTo(80, 0);
                        graphics.lineTo(87, 0);
                        graphics.lineTo(87, 40);
                        graphics.lineTo(90, 40);
                        graphics.lineTo(90, 2);
                        graphics.lineTo(120, 2);
                        graphics.lineTo(143, 40);
                        graphics.lineTo(143, 68);
                        graphics.lineTo(131, 78);
                        graphics.lineTo(96, 78);
                        graphics.lineTo(90, 73);
                        graphics.lineTo(40, 73);
                        graphics.lineTo(40, 78);
                        graphics.lineTo(8, 78);
                        graphics.lineTo(8, 62);
                        graphics.lineTo(0, 62);
                        graphics.lineTo(0, 40);
                        graphics.endFill();
                    }
                    break;
                }
            }
        }
        
        public function set windowColor(value:uint):void 
        {
            _windowColor = value;
            _window.graphics.clear();
            _window.graphics.beginFill(value);
            switch(_type)
            {
                case "normal":
                {
                    with (_window)
                    {
                        graphics.beginFill(value);
                        graphics.moveTo(32, 3);
                        graphics.lineTo(40, 3);
                        graphics.lineTo(44, 15);
                        graphics.lineTo(29, 13);
                        graphics.lineTo(32, 3);
                        graphics.endFill();
                        graphics.beginFill(value);
                        graphics.moveTo(44, 3);
                        graphics.lineTo(62, 3);
                        graphics.lineTo(77, 17);
                        graphics.lineTo(48, 15);
                        graphics.lineTo(44, 3);
                        graphics.endFill();
                    }
                    break;
                }
                case "normal_hb":
                {
                    with (_window)
                    {
                        graphics.moveTo(20, 3);
                        graphics.lineTo(31, 3);
                        graphics.lineTo(24, 15);
                        graphics.lineTo(13, 14);
                        graphics.lineTo(20, 3);
                        graphics.endFill();
                        graphics.beginFill(value);
                        graphics.moveTo(35, 3);
                        graphics.lineTo(47, 3);
                        graphics.lineTo(52, 15);
                        graphics.lineTo(29, 15);
                        graphics.lineTo(35, 3);
                        graphics.endFill();
                        graphics.beginFill(value);
                        graphics.moveTo(51, 3);
                        graphics.lineTo(68, 3);
                        graphics.lineTo(79, 15);
                        graphics.lineTo(56, 15);
                        graphics.lineTo(51, 3);
                        graphics.endFill();
                    }
                    break;
                }
                case "truck":
                {
                    with (_window)
                    {
                        graphics.moveTo(100, 8);
                        graphics.lineTo(117, 8);
                        graphics.lineTo(127, 25);
                        graphics.lineTo(127, 33);
                        graphics.lineTo(100, 33);
                        graphics.lineTo(100, 8);
                        graphics.endFill();
                        graphics.beginFill(value);

                    }
                    break;
                }
                case "truck_horo":
                {
                    with (_window)
                    {
                        graphics.moveTo(100, 8);
                        graphics.lineTo(117, 8);
                        graphics.lineTo(127, 25);
                        graphics.lineTo(127, 33);
                        graphics.lineTo(100, 33);
                        graphics.lineTo(100, 8);
                        graphics.endFill();
                        graphics.beginFill(value);
                        graphics.moveTo(2, 0);
                        graphics.lineTo(80, 0);
                        graphics.lineTo(80, 40);
                        graphics.lineTo(2, 40);
                        graphics.lineTo(2, 0);
                    }
                    break;
                }
                
            }
        }
        
        public function set light(value:Boolean):void 
        {
            _light.visible = value;
        }
        public function get type():String 
        {
            return _type;
        }
        
        public function set type(value:String):void 
        {
            _type = value;
            bodyColor = _bodyColor;
            windowColor = _windowColor;
            changeTirePosition(_type);
            _car.removeChild(_shadow);
            _shadow.width = _body.width;
            _shadow.y = _car.height - 10;
            _car.addChild(_shadow);
            _car.x = -_car.width / 2;
            _car.y = -_car.height;
        }
    }
    
    class Ship extends Sprite
    {
        public function Ship() 
        {
            var _ship:Sprite = new Sprite();
            with (_ship)
            {
                graphics.beginFill(0xFFFFFF);
                graphics.moveTo(0, 0);
                graphics.lineTo(20, 0);
                graphics.lineTo(20, 15);
                graphics.lineTo(20, 15);
                graphics.lineTo(20, 20);
                graphics.lineTo(50, 20);
                graphics.lineTo(48, 30);
                graphics.lineTo(-25, 30);
                graphics.lineTo(-30, 20);
                graphics.lineTo(-10, 20);
                graphics.lineTo(-10, 10);
                graphics.lineTo(15, 10);
                graphics.lineTo(15, 0);
                graphics.lineTo(0, 0);
                graphics.endFill();
                graphics.beginFill(0xFF9999);
                graphics.drawRect( -30, 20, 80, 2);
                graphics.endFill();
                graphics.beginFill(0xCCCCCC);
                graphics.drawRect( 20, 0, 2, 20);
                graphics.drawRect( -10, 12, 20, 4);
                graphics.endFill();                
            }
            _ship.x = -this.width / 2;
            _ship.y = -this.height;
            addChild(_ship);
        }
    }
    
    /**
     * ...
     * @author 393
     */
    class Bike extends Sprite 
    {
        private var _light:Sprite;
        private var _array:/*Sprite*/Array = [];
        private var _shadow:Sprite;
        
        public function Bike() 
        {
            var sp:Sprite = new Sprite();

            var shapedata:FShapeSVG = new FShapeSVG(_svg);
            shapedata.getChildAt(0)
            for (var i:int = 0; i < _svg.*.length();i++ )
            {
                _array[i] = shapedata.getChildAt(i).toSprite();
                sp.addChild(_array[i]);
            }
            
            addChild(sp);
            var frontTire:Sprite = createTire(0, 0xC7B299);
            var rearTire:Sprite = createTire(0, 0xC7B299);
            frontTire.x = sp.width - rearTire.width / 2 - 2;
            rearTire.x = 14;
            frontTire.y = rearTire.y = sp.height - frontTire.height / 2 + 4;
            sp.addChildAt(frontTire,0);
            sp.addChildAt(rearTire, 0);
            
            var matrix:Matrix = new Matrix();
            _light = new Sprite();
            with (_light)
            {
                matrix.createGradientBox(60, 30,Math.PI/8);
                graphics.beginGradientFill("linear", [0xFFFF00, 0xFFFF00], [0.5, 0], [45, 200],matrix);
                graphics.moveTo(0, 0);
                graphics.lineTo(70, -5);
                graphics.lineTo(60, 30);
                graphics.lineTo(0, 10);
                graphics.lineTo(0, 0);
            }
            
            sp.x = -sp.width / 2;
            sp.y = -sp.height;
            
            _shadow = new Sprite();
            sp.addChildAt(_shadow, 0);
            _shadow.graphics.beginFill(0, 0.2);
            _shadow.graphics.drawEllipse(0, 0, sp.width+4, 5);
            _shadow.filters = [new BlurFilter(8, 8, 1)];
            _shadow.x = -5;
            _shadow.y = sp.height - 4;
            
            sp.addChildAt(_light,0);
            _light.visible = false;
            _light.x = 76;
            _light.y = 42;
        }
        private function createTire(bodyColor:int,bodyColor2:int):Sprite 
        {
            var sp:Sprite = new Sprite();
            //タイヤ
            sp.graphics.beginFill(bodyColor);
            sp.graphics.drawCircle(0, 0, 11);
            sp.graphics.endFill();
            //タイヤホイール
            sp.graphics.beginFill(bodyColor2);
            sp.graphics.drawCircle(0, 0, 9);
            sp.graphics.endFill();
            //タイヤホイール
            for (var i:int = 0; i < 3; i++)
            {
                var wheel:Sprite = new Sprite();
                wheel.graphics.beginFill(0x999999);
                wheel.graphics.drawEllipse( -2, -4, 4, 8);
                wheel.x = 5 * Math.cos(i * Math.PI * 2 / 3);
                wheel.y = 5 * Math.sin(i * Math.PI * 2 / 3);
                wheel.rotation = 120 *i;
                sp.addChild(wheel);
            }
            
            sp.addEventListener(Event.ENTER_FRAME, function(e:Event):void { sp.rotation+= 35} );
            return sp;
        }
        
        public function set light(value:Boolean):void 
        {
            _light.visible  = value;
        }
        
        private var _svg:XML = <svg>
                <polygon points="72.046,68.437 59.825,40.923 64.313,38.605 76.531,66.277     "/>
                <path fill="#C7B299" d="M66.5,34.486c3.278-0.76,5.961-0.862,6.542,2.022s-1.696,7.14-4.975,7.899c-3.28,0.76-6.315-2.262-6.897-5.146C60.59,36.376,63.221,35.245,66.5,34.486z"/>
                <polygon points="66.207,45.818 64.672,46.492 58.77,31.048 60.307,30.374     "/>
                <path fill="#C7B299" d="M78.234,69.389c-6.798,4.141-12.148,12.174-12.197,7.146c-0.061-6.264-0.391-12.215,6.405-16.354c6.799-4.141,15.781-1.5,19.04,3.85C94.742,69.38,85.031,65.248,78.234,69.389z"/>
                <polygon fill="#666666" points="56,74 1.66,74 4.758,57.721 56,58.526     "/>
                <path fill="#C7B299" d="M76.155,46.223c0,2.794,0.98,6.01-2.951,6.01c-3.931,0-7.118-3.216-7.118-6.01c0-2.797,3.188-5.063,7.118-5.063C77.136,41.16,76.155,43.426,76.155,46.223z"/>
                <path fill="#C7B299" d="M56.446,72h-2.905c0,0,4.565-12-1.245-12c-5.812,0-3.597,0-10.377,0c-6.778,0-8.439,12.271-8.439,12.271L0,69.161C0,69.161,3.32,49,16.602,49c10,0,32.235,0,42.612,0c3.405,0,13.004-7.658,13.004-7.658s-3.32,20.306-8.301,25.63C59.091,72.131,56.446,72,56.446,72z"/>
                <polygon points="42,51 14,51 12,46 42,46     "/>
                <path fill="#C7B299" d="M64.747,46.518c0,4.653-2.081,9.589-10.791,9.589c-8.711,0-15.772-4.936-15.772-9.589c0-4.652,7.062-8.424,15.772-8.424C62.666,38.094,64.747,41.865,64.747,46.518z"/>
                <polygon points="34,74 0.83,74 0,69 34,69     "/>
                <polygon points="59.877,30.967 60.525,32.606 55.94,34.691 55.292,33.053     "/>
                <path fill="#C7B299" d="M32.435,9.365c0,5.172,3.855,9.365,8.611,9.365c2.971,0-2.02-4.621-0.472-7.111c0.93-1.495,9.083-0.314,9.083-2.254C49.657,4.194,45.801,0,41.046,0C36.29,0,32.435,4.194,32.435,9.365z"/>
                <path d="M39,41.056C39,44.705,36.247,48,32.835,48h-0.093C29.329,48,27,44.705,27,41.056v-8.969C27,28.438,29.329,26,32.742,26h0.093C36.247,26,39,28.438,39,32.087V41.056z"/>
                <path d="M39.982,37.605c-1.345,4.314-0.141,5.75-4.186,4.363l-8.736,0.053c-3.56-3.228-2.397-7.287-1.764-9.45l2.756-8.832c1.01-3.235,3.698-5.74,6.32-7.573c0.72-0.503,1.827,0.083,2.837,0.43l1.268,0.802c4.045,1.386,6.315,4.789,4.968,9.104L39.982,37.605z"/>
                <path d="M45.006,43.649C48.416,43.834,51,45.445,51,47.256v0.017c0,1.81-2.896,3.118-6.305,2.934l-8.724-0.477C32.563,49.543,30,47.933,30,46.123v-0.016c0-1.811,2.874-3.122,6.282-2.935L45.006,43.649z"/>
                <path fill="#C7B299" d="M49.295,28.342c4.024,1.847,10.167,3.314,9.729,4.682l-0.004,0.014c-0.438,1.367-8.14,0.143-12.162-1.703l-6.53-4.034c-4.022-1.847-6.729-4.362-6.291-5.729l0.004-0.013c0.438-1.368,2.536-2.322,6.557-0.474L49.295,28.342z"/>
                <path d="M49.617,63.781c1.686,0.305,2.846,1.997,2.605,3.786l-0.002,0.017c-0.24,1.789-1.945,2.975-3.631,2.669l-4.192-0.787C42.713,69.16,42,67.454,42,65.683v-0.017c0-1.773,1.738-2.979,3.423-2.674L49.617,63.781z"/>
                <path fill="#666666" d="M41.218,16.757c0.709,3.604,2.907,0.664,4.918,1.596c2.7,1.251,0.354,4.561,4.579-3.465C57.352,2.281,42.623,5.359,40,5.875C37.378,6.391,40.509,13.153,41.218,16.757z"/>
                <path d="M49.072,60.937C48.292,64.49,47.25,66,45.583,65h-2.406c-1.666,0-0.865-2.01-0.083-5.562l1.998-8.947C45.872,46.94,47.813,45,49.478,45h0.016c1.666,0,2.36,3.44,1.577,6.99L49.072,60.937z"/>
                <path d="M47.727,27.099c3.767,1.765,9.915,2.578,9.33,4.266L56.208,33c-0.585,1.688-7.457-0.279-11.222-2.042l-5.998-4.105c-3.765-1.764-6.158-4.476-5.572-6.163l0.005-0.016c0.586-1.688,2.763-3.066,6.528-1.3L47.727,27.099z"/>
        </svg>
    }
    /**
     * This loads MP3 from HDD.
     * 
     * @see http://wiki.github.com/claus/as3swf/play-mp3-directly-from-bytearray
     * @see http://github.com/claus/as3swf/raw/master/bin/as3swf.swc
     */
    
    class ClientMP3Loader extends EventDispatcher {

        /**
         * Use this object after Event.COMPLETE.
         */
        public var sound:Sound;

        /**
         * Call this to load MP3 from HDD.
         */
        public function load ():void {
            file = new FileReference;
            file.addEventListener (Event.CANCEL, onUserCancelled);
            file.addEventListener (Event.SELECT, onFileSelected);
            file.addEventListener (Event.COMPLETE, onFileLoaded);
            file.browse ([ new FileFilter ("MP3 files", "*.mp3") ]);
        }

        private var file:FileReference;
        private function onUserCancelled (e:Event):void { dispatchEvent (new Event (Event.CANCEL)); }
        private function onFileSelected (e:Event):void { file.load (); }
        private function onFileLoaded (e:Event):void {
            // Wrap the MP3 with a SWF
            var swf:ByteArray = createSWFFromMP3 (file.data);
            // Load the SWF with Loader::loadBytes()
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
            loader.loadBytes(swf);
        }

        private function initHandler(e:Event):void {
            // Get the sound class definition
            var SoundClass:Class = LoaderInfo(e.currentTarget).applicationDomain.getDefinition("MP3Wrapper_soundClass") as Class;
            // Instantiate the sound class
            sound = new SoundClass() as Sound;
            // Report Event.COMPLETE
            dispatchEvent (new Event (Event.COMPLETE));
        }

        private function createSWFFromMP3(mp3:ByteArray):ByteArray
        {
            // Create an empty SWF
            // Defaults to v10, 550x400px, 50fps, one frame (works fine for us)
            var swf:SWF = new SWF();
            
            // Add FileAttributes tag
            // Defaults: as3 true, all other flags false (works fine for us)
            swf.tags.push(new TagFileAttributes());

            // Add SetBackgroundColor tag
            // Default: white background (works fine for us)
            swf.tags.push(new TagSetBackgroundColor());
            
            // Add DefineSceneAndFrameLabelData tag 
            // (with the only entry being "Scene 1" at offset 0)
            var defineSceneAndFrameLabelData:TagDefineSceneAndFrameLabelData = new TagDefineSceneAndFrameLabelData();
            defineSceneAndFrameLabelData.scenes.push(new SWFScene(0, "Scene 1"));
            swf.tags.push(defineSceneAndFrameLabelData);

            // Add DefineSound tag
            // The ID is 1, all other parameters are automatically
            // determined from the mp3 itself.
            swf.tags.push(TagDefineSound.createWithMP3(1, mp3));
            
            // Add DoABC tag
            // Contains the AS3 byte code for the document class and the 
            // class definition for the embedded sound
            swf.tags.push(TagDoABC.create(abc));
            
            // Add SymbolClass tag
            // Specifies the document class and binds the sound class
            // definition to the embedded sound
            var symbolClass:TagSymbolClass = new TagSymbolClass();
            symbolClass.symbols.push(SWFSymbol.create(1, "MP3Wrapper_soundClass"));
            symbolClass.symbols.push(SWFSymbol.create(0, "MP3Wrapper"));
            swf.tags.push(symbolClass);
            
            // Add ShowFrame tag
            swf.tags.push(new TagShowFrame());

            // Add End tag
            swf.tags.push(new TagEnd());
            
            // Publish the SWF
            var swfData:SWFData = new SWFData();
            swf.publish(swfData);
            
            return swfData;
        }
        
        private static var abcData:Array = [
            0x10, 0x00, 0x2e, 0x00, 0x00, 0x00, 0x00, 0x19, 0x07, 0x6d, 0x78, 0x2e, 0x63, 0x6f, 0x72, 0x65, 
            0x0a, 0x49, 0x46, 0x6c, 0x65, 0x78, 0x41, 0x73, 0x73, 0x65, 0x74, 0x0a, 0x53, 0x6f, 0x75, 0x6e, 
            0x64, 0x41, 0x73, 0x73, 0x65, 0x74, 0x0b, 0x66, 0x6c, 0x61, 0x73, 0x68, 0x2e, 0x6d, 0x65, 0x64, 
            0x69, 0x61, 0x05, 0x53, 0x6f, 0x75, 0x6e, 0x64, 0x12, 0x6d, 0x78, 0x2e, 0x63, 0x6f, 0x72, 0x65, 
            0x3a, 0x53, 0x6f, 0x75, 0x6e, 0x64, 0x41, 0x73, 0x73, 0x65, 0x74, 0x00, 0x15, 0x4d, 0x50, 0x33, 
            0x57, 0x72, 0x61, 0x70, 0x70, 0x65, 0x72, 0x5f, 0x73, 0x6f, 0x75, 0x6e, 0x64, 0x43, 0x6c, 0x61, 
            0x73, 0x73, 0x0a, 0x4d, 0x50, 0x33, 0x57, 0x72, 0x61, 0x70, 0x70, 0x65, 0x72, 0x0d, 0x66, 0x6c, 
            0x61, 0x73, 0x68, 0x2e, 0x64, 0x69, 0x73, 0x70, 0x6c, 0x61, 0x79, 0x06, 0x53, 0x70, 0x72, 0x69, 
            0x74, 0x65, 0x0a, 0x73, 0x6f, 0x75, 0x6e, 0x64, 0x43, 0x6c, 0x61, 0x73, 0x73, 0x05, 0x43, 0x6c, 
            0x61, 0x73, 0x73, 0x2a, 0x68, 0x74, 0x74, 0x70, 0x3a, 0x2f, 0x2f, 0x77, 0x77, 0x77, 0x2e, 0x61, 
            0x64, 0x6f, 0x62, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x32, 0x30, 0x30, 0x36, 0x2f, 0x66, 0x6c, 
            0x65, 0x78, 0x2f, 0x6d, 0x78, 0x2f, 0x69, 0x6e, 0x74, 0x65, 0x72, 0x6e, 0x61, 0x6c, 0x07, 0x56, 
            0x45, 0x52, 0x53, 0x49, 0x4f, 0x4e, 0x06, 0x53, 0x74, 0x72, 0x69, 0x6e, 0x67, 0x07, 0x33, 0x2e, 
            0x30, 0x2e, 0x30, 0x2e, 0x30, 0x0b, 0x6d, 0x78, 0x5f, 0x69, 0x6e, 0x74, 0x65, 0x72, 0x6e, 0x61, 
            0x6c, 0x06, 0x4f, 0x62, 0x6a, 0x65, 0x63, 0x74, 0x0c, 0x66, 0x6c, 0x61, 0x73, 0x68, 0x2e, 0x65, 
            0x76, 0x65, 0x6e, 0x74, 0x73, 0x0f, 0x45, 0x76, 0x65, 0x6e, 0x74, 0x44, 0x69, 0x73, 0x70, 0x61, 
            0x74, 0x63, 0x68, 0x65, 0x72, 0x0d, 0x44, 0x69, 0x73, 0x70, 0x6c, 0x61, 0x79, 0x4f, 0x62, 0x6a, 
            0x65, 0x63, 0x74, 0x11, 0x49, 0x6e, 0x74, 0x65, 0x72, 0x61, 0x63, 0x74, 0x69, 0x76, 0x65, 0x4f, 
            0x62, 0x6a, 0x65, 0x63, 0x74, 0x16, 0x44, 0x69, 0x73, 0x70, 0x6c, 0x61, 0x79, 0x4f, 0x62, 0x6a, 
            0x65, 0x63, 0x74, 0x43, 0x6f, 0x6e, 0x74, 0x61, 0x69, 0x6e, 0x65, 0x72, 0x0a, 0x16, 0x01, 0x16, 
            0x04, 0x18, 0x06, 0x16, 0x07, 0x18, 0x08, 0x16, 0x0a, 0x18, 0x09, 0x08, 0x0e, 0x16, 0x14, 0x03, 
            0x01, 0x01, 0x01, 0x04, 0x14, 0x07, 0x01, 0x02, 0x07, 0x01, 0x03, 0x07, 0x02, 0x05, 0x09, 0x02, 
            0x01, 0x07, 0x04, 0x08, 0x07, 0x04, 0x09, 0x07, 0x06, 0x0b, 0x07, 0x04, 0x0c, 0x07, 0x04, 0x0d, 
            0x07, 0x08, 0x0f, 0x07, 0x04, 0x10, 0x07, 0x01, 0x12, 0x09, 0x03, 0x01, 0x07, 0x04, 0x13, 0x07, 
            0x09, 0x15, 0x09, 0x08, 0x02, 0x07, 0x06, 0x16, 0x07, 0x06, 0x17, 0x07, 0x06, 0x18, 0x0d, 0x00, 
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
            0x00, 0x00, 0x00, 0x00, 0x04, 0x01, 0x00, 0x05, 0x00, 0x02, 0x00, 0x02, 0x03, 0x09, 0x03, 0x01, 
            0x04, 0x05, 0x00, 0x05, 0x02, 0x09, 0x05, 0x00, 0x08, 0x00, 0x06, 0x07, 0x09, 0x07, 0x00, 0x0b, 
            0x01, 0x08, 0x00, 0x00, 0x09, 0x00, 0x01, 0x00, 0x04, 0x01, 0x0a, 0x06, 0x01, 0x0b, 0x11, 0x01, 
            0x07, 0x00, 0x0a, 0x00, 0x05, 0x00, 0x01, 0x0c, 0x06, 0x00, 0x00, 0x08, 0x08, 0x03, 0x01, 0x01, 
            0x04, 0x00, 0x00, 0x06, 0x01, 0x02, 0x04, 0x00, 0x01, 0x09, 0x01, 0x05, 0x04, 0x00, 0x02, 0x0c, 
            0x01, 0x06, 0x04, 0x01, 0x03, 0x0c, 0x00, 0x01, 0x01, 0x01, 0x02, 0x03, 0xd0, 0x30, 0x47, 0x00, 
            0x00, 0x01, 0x00, 0x01, 0x03, 0x03, 0x01, 0x47, 0x00, 0x00, 0x03, 0x02, 0x01, 0x01, 0x02, 0x0a, 
            0xd0, 0x30, 0x5d, 0x04, 0x20, 0x58, 0x00, 0x68, 0x01, 0x47, 0x00, 0x00, 0x04, 0x02, 0x01, 0x05, 
            0x06, 0x09, 0xd0, 0x30, 0x5e, 0x0a, 0x2c, 0x11, 0x68, 0x0a, 0x47, 0x00, 0x00, 0x05, 0x01, 0x01, 
            0x06, 0x07, 0x06, 0xd0, 0x30, 0xd0, 0x49, 0x00, 0x47, 0x00, 0x00, 0x06, 0x02, 0x01, 0x01, 0x05, 
            0x17, 0xd0, 0x30, 0x5d, 0x0d, 0x60, 0x0e, 0x30, 0x60, 0x0f, 0x30, 0x60, 0x03, 0x30, 0x60, 0x03, 
            0x58, 0x01, 0x1d, 0x1d, 0x1d, 0x68, 0x02, 0x47, 0x00, 0x00, 0x07, 0x01, 0x01, 0x06, 0x07, 0x03, 
            0xd0, 0x30, 0x47, 0x00, 0x00, 0x08, 0x01, 0x01, 0x07, 0x08, 0x06, 0xd0, 0x30, 0xd0, 0x49, 0x00, 
            0x47, 0x00, 0x00, 0x09, 0x02, 0x01, 0x01, 0x06, 0x1b, 0xd0, 0x30, 0x5d, 0x10, 0x60, 0x0e, 0x30, 
            0x60, 0x0f, 0x30, 0x60, 0x03, 0x30, 0x60, 0x02, 0x30, 0x60, 0x02, 0x58, 0x02, 0x1d, 0x1d, 0x1d, 
            0x1d, 0x68, 0x05, 0x47, 0x00, 0x00, 0x0a, 0x01, 0x01, 0x08, 0x09, 0x03, 0xd0, 0x30, 0x47, 0x00, 
            0x00, 0x0b, 0x02, 0x01, 0x09, 0x0a, 0x0b, 0xd0, 0x30, 0xd0, 0x60, 0x05, 0x68, 0x08, 0xd0, 0x49, 
            0x00, 0x47, 0x00, 0x00, 0x0c, 0x02, 0x01, 0x01, 0x08, 0x23, 0xd0, 0x30, 0x65, 0x00, 0x60, 0x0e, 
            0x30, 0x60, 0x0f, 0x30, 0x60, 0x11, 0x30, 0x60, 0x12, 0x30, 0x60, 0x13, 0x30, 0x60, 0x07, 0x30, 
            0x60, 0x07, 0x58, 0x03, 0x1d, 0x1d, 0x1d, 0x1d, 0x1d, 0x1d, 0x68, 0x06, 0x47, 0x00, 0x00
        ];

        private static function abcDataToByteArray():ByteArray {
            var ba:ByteArray = new ByteArray();
            for (var i:uint = 0; i < abcData.length; i++) {
                ba.writeByte(abcData[i]);
            }
            return ba;
        }
        
        private static var abc:ByteArray = abcDataToByteArray();
    }