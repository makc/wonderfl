// forked from Event's Simple MediaRSS Viewer
/**
 * flickrで検索した画像が広告になります。
 * 広告をクリックするとちょっと大きい画像が見れます。
 */
package  {
	import com.bit101.components.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.system.*;
	
	public class AdCity extends Sprite {
		private var _flickr:Flickr = new Flickr();
		private var _map:MapView = new MapView();
		private var _bg:Sprite;
		private var _fade:Sprite;
		private var _sky:Sprite;
		private var _mouseOverSprite:Sprite = new Sprite();
		private var _canvas:BitmapData = new BitmapData(Display.WIDTH, Display.HEIGHT, true, 0);
		private var _loader:ImageLoader = new ImageLoader();
		private var _viewer:Viewer = new Viewer();
		private var _loading:LoadingEffect;
		private var _drag:MouseDrag;
		private var _search:SearchDialog = new SearchDialog();
		private var _menu:TopMenu;
		private var _mousePos:Point = new Point();
		private var _cameraMng:CameraManager = new CameraManager();
		
		private const SCENE_SEARCH:int = 0;
		private const SCENE_NORMAL:int = 1;
		private const SCENE_ZOOM:int = 2;
		private var _scene:int = SCENE_SEARCH;
		
		public function AdCity() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Display.stage = stage;
			stage.frameRate = 30;
			stage.quality = StageQuality.LOW;
			Style.fontSize *= 2;
			Style.LABEL_TEXT = 0xFFFFFF;
			//画面構成
			_bg = Painter.createColorRect(2000, 2000, 0);
			_bg.x = (Display.WIDTH - _bg.width) / 2;
			_bg.y = (Display.HEIGHT - _bg.height) / 2;
			_sky = Painter.createColorRect(Display.WIDTH, Display.HEIGHT, 0x78B2F8);
			_sky.mouseEnabled = false;
			_loading = new LoadingEffect();
			_loading.x = (Display.WIDTH - _loading.width) / 2;
			_loading.y = (Display.HEIGHT - _loading.height) / 2;
			_menu = new TopMenu();
			_menu.hide();
			_fade = Painter.createColorRect(Display.WIDTH, Display.HEIGHT, 0);
			_fade.mouseEnabled = false;
			
			addChild(_bg);
			addChild(_sky);
			addChild(new Bitmap(_canvas));
			addChild(_viewer);
			addChild(_mouseOverSprite);
			addChild(_search);
			addChild(_menu);
			addChild(_fade);
			addChild(_loading);
			
			_menu.search.addEventListener(LabelButton.EVENT_CLICK, onClickSeach);
			_menu.camera.addEventListener(Event.CHANGE, onChangeCamera);
			_search.hide();
			//hitTestを有効にするためstageに配置しておく
			addChild(_map.container);
			_map.container.visible = false;
			//指マークに変えるためのボタン
			_mouseOverSprite.addChild(Painter.createColorRect(Display.WIDTH, Display.HEIGHT, 0, 0));
			_mouseOverSprite.buttonMode = true;
			_mouseOverSprite.mouseChildren = false;
			_mouseOverSprite.visible = false;
			
			_drag = new MouseDrag(_bg, 400, 400);
			_drag.speed.x = -0.5;
			_drag.speed.y = -0.5;
			
			//マップチップとかを読み込む
			_loader.addImage("http://assets.wonderfl.net/images/related_images/2/2f/2fca/2fca9c6a48ea9c729059dc8f7d4717283933b92d", "mapchip");
			_loader.addImage("http://assets.wonderfl.net/images/related_images/7/78/781f/781f056d44583c10d7b214cf2891e7258ad20520", "bldg");
			_loader.addImage("http://assets.wonderfl.net/images/related_images/9/91/9180/918077e79672d25963f77a8ff3f37a700574f2d4", "car");
			_loader.addImage("http://assets.wonderfl.net/images/related_images/6/67/67c9/67c9fe2e421ee0f5776ca969a38a0d3a9e3fdc4f", "ui");
			_loader.load(onLoadMaterial, onErrorMaterial, onProgressMaterial);
		}
		
		private function onProgressMaterial(per:Number):void {
			_loading.setProgress(per);
		}
		//メニューのSEARCHボタンを押した
		private function onClickSeach(e:Event):void {
			_scene = SCENE_SEARCH;
			_search.setSearch();
			setCamera(CameraManager.MODE_CAR);
			_menu.hide();
		}
		//カメラボタンで切り替えた
		private function onChangeCamera(e:Event):void {
			nextCamera();
		}
		//マップチップロード失敗
		private function onErrorMaterial():void {
			_loading.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 0xFF, 0, 0, 0);
		}
		//全ての素材を読み込めた
		private function onLoadMaterial():void {
			EaseMotion.ease(_fade, "alpha", 0, 0.15, function():void { _fade.parent.removeChild(_fade); } );
			_loading.hide();
			_loading.parent.removeChild(_loading);
			_viewer.init(_loader.image.ui);
			_map.init(_loader);
			initCamera();
			onSimulateTick(null);
			_search.init("poster logo", onSearch);
			_flickr.loadLimit = 16;
			_flickr.isSkipFlash = true;
			_flickr.addEventListener(Flickr.EVENT_LOADIMAGE, onLoadImage);
			_flickr.addEventListener(Flickr.EVENT_NOIMAGE, onNoImage);
			_flickr.addEventListener(ErrorEvent.ERROR, onErrorRss);
			_flickr.addEventListener(Event.COMPLETE, onCompleteImage);
		}
		//検索実行時
		private function onSearch(tag:String):void{
			//flickrのRSSを取得
			_search.setMessage("LOADING... ");
			_flickr.load(tag);
		}
		private function onNoImage(e:Event):void {
			_search.errorMessage("NO IMAGE!");
		}
		private function onErrorRss(e:ErrorEvent):void {
			_search.errorMessage("ERROR!");
		}
		private function onLoadImage(e:Event):void {
			var per:Number = _flickr.loaded.length / _flickr.items.length * 100;
			_search.setMessage("LOADING... " + int(per) + "%");
		}
		//全てのサムネイルが読み込まれた
		private function onCompleteImage(e:Event):void {
			_scene = SCENE_NORMAL;
			_search.hide();
			_bg.addEventListener(MouseEvent.MOUSE_DOWN, onClickStage);
			_mouseOverSprite.addEventListener(MouseEvent.MOUSE_DOWN, onClickStage);
			_menu.show();
			var count:int = -1;
			if (_flickr.items.length > 0) {
				for each(var obj:Piece in _map.piece.objects) {
					for each(var ad:Ad in obj.ads) {
						count = (count + 1) % _flickr.items.length;
						ad.setItem(_flickr.items[count]);
					}
				}
			}
			startSim();
		}
		//背景クリック時
		private function onClickStage(e:MouseEvent):void {
			switch(_scene) {
				case SCENE_ZOOM:
					startSim();
					_viewer.close();
					_menu.show();
					_scene = SCENE_NORMAL;
					break;
				case SCENE_NORMAL:
					var ad:Ad = _map.piece.hitTest(_mousePos.x, _mousePos.y);
					if (ad) {
						stopSim();
						_scene = SCENE_ZOOM;
						_menu.hide();
						_mouseOverSprite.visible = false;
						_viewer.setItem(ad.item);
					}
					break;
			}
		}
		//カメラ初期化
		private function initCamera():void {
			var cam_car:CameraData = new CameraData();
			var cam_drag:CameraData = new CameraData();
			var cam_sky:CameraData = new CameraData();
			cam_car.scale = 3;
			cam_car.speed = 1;
			cam_car.update = function(me:CameraData):void {
				me.position.x = _map.myCar.x;
				me.position.y = _map.myCar.y  - 30;
			}
			cam_drag.scale = 2;
			cam_drag.speed = 0.7;
			cam_drag.update = function(me:CameraData):void {
				me.position.x = _drag.position.x;
				me.position.y = _drag.position.y;
			}
			cam_sky.scale = 0.5;
			cam_sky.speed = 1;
			var pp:Point = Quarter.toScreen(_map.data.W / 2, _map.data.H / 2, 10);
			cam_sky.position.x = pp.x;
			cam_sky.position.y = pp.y;
			
			_cameraMng.cameras[CameraManager.MODE_CAR] = cam_car;
			_cameraMng.cameras[CameraManager.MODE_DRAG] = cam_drag;
			_cameraMng.cameras[CameraManager.MODE_SKY] = cam_sky;
			setCamera(CameraManager.MODE_CAR);
			_cameraMng.goto(_cameraMng.activeCamera);
		}
		//カメラ切り替え
		private function nextCamera():void {
			setCamera(_cameraMng.getNextMode());
		}
		private function setCamera(mode:int):void {
			var prev:CameraData = _cameraMng.activeCamera;
			_cameraMng.setMode(mode);
			_menu.camera.setLabel(mode);
			if (_cameraMng.mode == CameraManager.MODE_DRAG) {
				_drag.position = prev.position.clone();
			}
		}
		public function startSim():void {
			addEventListener(Event.ENTER_FRAME, onSimulateTick);
		}
		public function stopSim():void {
			removeEventListener(Event.ENTER_FRAME, onSimulateTick);
		}
		private function onSimulateTick(e:Event):void {
			_map.piece.objects.sort(sortFunc);
			var l:int = _map.piece.objects.length;
			for (var i:int = 0; i < l; i++) {
				_map.objLayer.setChildIndex(_map.piece.objects[i], i);
			}
			_map.myCar.simulateTick();
			var ad:Ad = _map.piece.hitTest(_mousePos.x, _mousePos.y)
			_mouseOverSprite.visible = !!ad;
			for each(var c:Car in _map.cars) c.simulateTick();
			_cameraMng.ease(_cameraMng.activeCamera);
			var cp:Point = _cameraMng.getPosition();
			var scl:Number = _cameraMng.scale;
			_mousePos = new Point((cp.x + stage.mouseX) / scl, (cp.y + stage.mouseY) / scl);
			_canvas.fillRect(_canvas.rect, 0);
			_canvas.draw(_map.container, new Matrix(scl, 0, 0, scl, int( -cp.x), int( -cp.y)));
		}
		private function sortFunc(a:Piece, b:Piece):int{
			return (a.y + a.basePos.y) - (b.y + b.basePos.y);
		}
	}
}

import com.bit101.components.*;
import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.system.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;

/**
 * ローディング用ノイズバー
 */
class LoadingEffect extends Sprite {
	private var _img:BitmapData;
	private var _slide:int = 0;
	private var _zoomX:int = 8;
	private var _zoomY:int = 3;
	private var _loop:int = 100;
	private var _count:int = 0;
	private var _label:Label;
	public function LoadingEffect() {
		_img = new BitmapData(20, _loop, false, 0xFF00000000);
		_img.noise(1234, 0, 255, 7);
		_img.applyFilter(_img, _img.rect, new Point(), new BlurFilter(0, 2, 2));
		_label = new Label(this, 0, -15, "");
		_label.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 0xA0, 0xA0, 0xA0, 0);
		_label.scaleX = _label.scaleY = 0.5;
		setProgress(0);
		show();
	}
	private function onEnterFrame(e:Event):void {
		if (++_count % 2) update();
	}
	public function setProgress(per:Number):void {
		_label.text = int(per * 100) + "%";
	}
	private function update():void {
		_slide = ++_slide % _loop;
		graphics.clear();
		graphics.beginBitmapFill(_img, new Matrix(_zoomX, 0, 0, _zoomY, 0, _slide * _zoomY), true, false);
		graphics.drawRect(0, 0, _img.width * _zoomX, _zoomY);
	}
	public function show():void {
		update();
		visible = true;
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	public function hide():void {
		visible = false;
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
}

/**
 * カメラの動き管理
 */
class CameraManager {
	public var activeCamera:CameraData;
	public var cameras:Vector.<CameraData> = new Vector.<CameraData>();
	public var position:Point = new Point();
	public var scale:Number = 1;
	public var mode:int = 0;
	private var _speed:Number = 0;
	private var _targetPos:Point = new Point();
	private var _targetScale:Number = 1;
	private var _targetSpeed:Number = 0.2;
	static public const MODE_CAR:int = 0;
	static public const MODE_DRAG:int = 1;
	static public const MODE_SKY:int = 2;
	public function CameraManager() {
	}
	public function getNextMode():int {
		return (mode + 1) % cameras.length;
	}
	public function setMode(mode:int):void {
		this.mode = mode;
		resetTrackingSpeed();
		activeCamera = cameras[mode];
	}
	public function resetTrackingSpeed():void {
		_speed = 0;
	}
	public function goto(cam:CameraData):void {
		ease(cam);
		position = _targetPos.clone();
		scale = _targetScale;
		_speed = _targetSpeed;
	}
	public function ease(cam:CameraData):void {
		cam.update(cam);
		_targetScale = cam.scale;
		_targetPos = cam.position.clone();
		_targetSpeed = cam.speed;
		update();
	}
	public function getPosition():Point {
		var p:Point = new Point();
		p.x = position.x * scale - Display.CENTER.x;
		p.y = position.y * scale - Display.CENTER.y;
		return p;
	}
	public function update():void {
		_speed += (_targetSpeed - _speed) * 0.03;
		position.x += (_targetPos.x - position.x) * _speed;
		position.y += (_targetPos.y - position.y) * _speed;
		scale += (_targetScale - scale) * _speed;
		if (Math.abs(_targetScale - scale) < 0.01) scale = _targetScale;
	}
}

/**
 * カメラデータ
 */
class CameraData {
	//画面位置
	public var position:Point = new Point();
	//画面スケール
	public var scale:Number = 1;
	//最終的な追尾速度
	public var speed:Number = 0.2;
	//毎フレーム実行する処理
	public var update:Function = function(me:CameraData):void { };
	public function CameraData() {
	}
}

/**
 * 上部メニュー
 */
class TopMenu extends Sprite {
	private var _base:Sprite;
	public var search:LabelButton;
	public var camera:CameraSwitch;
	private var _height:Number = 35;
	public function TopMenu() {
		_base = addChild(Painter.createColorRect(Display.WIDTH, _height, 0, 0.7)) as Sprite;
		search = new LabelButton(this, 8, 0, "SEARCH", 100);
		camera = new CameraSwitch(this, Display.WIDTH - 145, 0);
		vanish();
	}
	public function show():void {
		mouseEnabled = true;
		mouseChildren = true;
		EaseMotion.ease(this, "y", 0, 0.4);
		EaseMotion.ease(search, "alpha", 1, 0.2);
		EaseMotion.ease(camera, "alpha", 1, 0.2);
	}
	public function vanish():void {
		mouseEnabled = false;
		y = -_height;
		search.alpha = 0;
		camera.alpha = 0;
	}
	public function hide():void {
		mouseEnabled = false;
		mouseChildren = false;
		EaseMotion.ease(this, "y", -_height, 0.4);
		EaseMotion.ease(search, "alpha", 0, 0.2);
		EaseMotion.ease(camera, "alpha", 0, 0.2);
	}
}

/**
 * 検索窓
 */
class SearchDialog extends Sprite {
	private var _base:Sprite = new Sprite();
	private var _message:Label;
	private var _input:InputText;
	private var _searchLayer:Sprite = new Sprite();
	private var _searchFunc:Function;
	private var _timer:Timer = new Timer(2000, 1);
	public function SearchDialog() {
		_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimesUp);
		addChild(_base);
		var imgBase:BitmapData = new BitmapData(170, 34, true, 0);
		var imgTri:BitmapData = new BitmapData(11, 11, true, 0);
		var i:int, px:int, py:int;
		var round:int = 3;
		for (i = 0; i < imgTri.width; i += 2) {
			imgTri.fillRect(new Rectangle(i, 0, 2, imgTri.height-i), 0xFFffffff);
		}
		for (i = 0; i < round; i++) {
			px = i * 2;
			py = (round - i -1) * 2;
			imgBase.fillRect(new Rectangle(px, py, imgBase.width - px * 2, imgBase.height - py * 2), 0xFFffffff);
		}
		var tri:Bitmap = _base.addChild(new Bitmap(imgTri)) as Bitmap;
		var base:Bitmap = _base.addChild(new Bitmap(imgBase)) as Bitmap;
		tri.y = -tri.height;
		base.y = -imgTri.height + 1 - imgBase.height;
		base.x = int( -imgBase.width / 2);
		addChild(_searchLayer);
		_input = new InputText(_searchLayer, -78, -35, "");
		new PushButton(_searchLayer, 28, -35, "SEARCH", onClickSearch).setSize(50, 16);
		_message = new Label(this, -34, -37, "");
		_message.visible = false;
		filters = [new DropShadowFilter(2, 45, 0, 0.5, 6, 6, 100, 1)];
		x = 230;
		y = 270;
	}
	public function init(text:String, onSearch:Function):void {
		_searchFunc = onSearch;
		setSearch();
		_input.text = text;
	}
	public function getKeyword():String {
		return _input.text.replace(/\s+|\/|\./g, ",");
	}
	public function setSearch():void {
		visible = true;
		EaseMotion.ease(this, "scaleX", 2, 0.6);
		EaseMotion.ease(this, "scaleY", 2, 0.6);
		_searchLayer.visible = true;
		_message.visible = false;
		stage.focus = _input.textField;
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}
	private function onKeyDown(e:KeyboardEvent):void {
		if (e.keyCode == Keyboard.ENTER) onClickSearch(null);
	}
	public function hide():void {
		visible = false;
		EaseMotion.goto(this, "scaleX", 0);
		EaseMotion.goto(this, "scaleY", 0);
	}
	public function errorMessage(text:String):void {
		setMessage(text);
		_timer.reset();
		_timer.start();
	}
	private function onTimesUp(e:TimerEvent):void {
		setSearch();
	}
	public function setMessage(text:String):void {
		_searchLayer.visible = false;
		_message.text = text;
		_message.visible = true;
	}
	private function onClickSearch(e:MouseEvent):void {
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		if (_input.text.replace(/\s*/g, "") == "") return;
		if (_searchFunc != null)_searchFunc.apply(null, [getKeyword()]);
	}
}

/**
 * メニューのラベルボタン
 */
class LabelButton extends Label {
	static public const EVENT_CLICK:String = "onClickMe";
	private var _base:Sprite = new Sprite();
	private var _mainColor:ColorTransform = new ColorTransform();
	private var _overColor:ColorTransform = new ColorTransform();
	public function LabelButton(parent:DisplayObjectContainer, xpos:Number, ypos:Number, text:String = "", width:Number = 150) {
		super(parent, xpos, ypos, text);
		_mainColor.color = 0xFFFFFF;
		_overColor.color = 0xFFFF63;
		_base.addChild(Painter.createColorRect(width, 30, 0, 0));
		_base.addEventListener(MouseEvent.ROLL_OVER, onOver);
		_base.addEventListener(MouseEvent.ROLL_OUT, onOut);
		_base.addEventListener(MouseEvent.CLICK, onClick);
		_base.buttonMode = true;
		_base.x = -4;
		_base.y = 3;
		mouseEnabled = true;
		mouseChildren = true;
		addChildAt(_base, 0);
	}
	private function onOut(e:MouseEvent):void {
		textField.transform.colorTransform = _mainColor;
	}
	private function onOver(e:MouseEvent):void {
		textField.transform.colorTransform = _overColor;
	}
	protected function onClick(e:MouseEvent):void {
		dispatchEvent(new Event(EVENT_CLICK));
	}
}

/**
 * カメラ切り替えボタン
 */
class CameraSwitch extends LabelButton {
	public function CameraSwitch(parent:DisplayObjectContainer, xpos:Number, ypos:Number) {
		super(parent, xpos, ypos);
	}
	override protected function onClick(e:MouseEvent):void {
		dispatchEvent(new Event(Event.CHANGE));
		super.onClick(e);
	}
	public function setLabel(mode:int):void {
		text = "CAMERA: " + ["  CAR", "DRAG", "  SKY"][mode];
	}
}

/**
 * マウスドラッグ管理
 */
class MouseDrag extends EventDispatcher {
	public var position:Point = new Point();
	public var speed:Point = new Point(1, 1);
	public var clickRange:Number = 2;
	private var _sprite:DisplayObjectContainer;
	private var _isDragged:Boolean = false;
	private var _isMouseDown:Boolean = false;
	private var _savePosition:Point = new Point();
	private var _saveMousePos:Point;
	static public const EVENT_STARTDRAG:String = "onStartDrag";
	public function get isMouseDown():Boolean { return _isMouseDown; }
	public function get isDragged():Boolean { return _isDragged; }
	public function MouseDrag(target:DisplayObjectContainer, x:Number = 0, y:Number = 0) {
		position.x = x;
		position.y = y;
		_sprite = target;
		setEnabled(true);
	}
	public function setEnabled(enabled:Boolean):void {
		if (enabled) {
			_sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
		} else {
			_sprite.removeEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
		}
	}
	private function onMsDown(e:MouseEvent):void {
		_isMouseDown = true;
		_isDragged = false;
		_sprite.stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
		_sprite.stage.addEventListener(Event.MOUSE_LEAVE, onMsUp);
		_sprite.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		_savePosition = position.clone();
		_saveMousePos = new Point(_sprite.mouseX, _sprite.mouseY);
		dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
	}
	private function onMsUp(...rest):void {
		_isMouseDown = false;
		_sprite.stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
		_sprite.stage.removeEventListener(Event.MOUSE_LEAVE, onMsUp);
		_sprite.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		checkDrag();
		dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
	}
	private function onMsMove(e:MouseEvent):void {
		checkDrag();
	}
	private function checkDrag():void {
		var drag:Point = new Point(_sprite.mouseX, _sprite.mouseY).subtract(_saveMousePos);
		if (!_isDragged && drag.length > clickRange) {
			dispatchEvent(new Event(EVENT_STARTDRAG));
			_isDragged = true;
		}
		if (_isDragged) {
			position.x = _savePosition.x + drag.x * speed.x;
			position.y = _savePosition.y + drag.y * speed.y;
			dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
		}
	}
}

/**
 * 拡大画像ビューワ
 */
class Viewer extends Sprite {
	private var _viewRect:Rectangle = new Rectangle(27, 45, 411, 330);
	private var _bg:Sprite;
	private var _bmp:Bitmap;
	private var _slideLayer:Sprite = new Sprite();
	private var _imageContainer:Sprite = new Sprite();
	private var _loader:ImageLoader = new ImageLoader();
	private var _title:Label;
	private var _loading:LoadingEffect;
	private var _errorLabel:Label;
	public function Viewer() {
		mouseEnabled = false;
		mouseChildren = false;
	}
	/**
	 * フレーム画像を渡して初期化
	 */
	public function init(bmp:BitmapData):void {
		_bg = Painter.createColorRect(Display.WIDTH, Display.HEIGHT, 0xFFFFFF);
		_bg.alpha = 0;
		_bg.visible = false;
		_bg.blendMode = BlendMode.ADD;
		addChild(_bg);
		addChild(_slideLayer);
		_loading = new LoadingEffect();
		_loading.x = (Display.WIDTH - _loading.width) / 2;
		_loading.y = 215;
		_slideLayer.addChild(new Bitmap(bmp));
		_slideLayer.addChild(_loading);
		_slideLayer.addChild(_imageContainer);
		_title = new Label(_slideLayer, 30, 420);
		_title.x = 30;
		_title.width = 200;
		_title.height = 50;
		_title.scrollRect = new Rectangle(0, 0, 400, 100);
		_errorLabel = new Label(_slideLayer, 130, 180, "");
		_errorLabel.visible = false;
		_imageContainer.mask = addChild(Painter.createColorRect(_viewRect.width, _viewRect.height, 0, 1, _viewRect.x, _viewRect.y));
		mask = addChild(Painter.createColorRect(Display.WIDTH, Display.HEIGHT, 0));
		_slideLayer.y = Display.HEIGHT;
	}
	public function dispose():void {
		if(_bmp) _bmp.bitmapData.dispose();
		while (_imageContainer.numChildren) _imageContainer.removeChildAt(0);
		_loader.stop();
		_loader.disposeAll();
	}
	public function setItem(item:MediaItem):void {
		dispose();
		EaseMotion.goto(_loading, "alpha", 0);
		_imageContainer.alpha = 0;
		EaseMotion.ease(_slideLayer, "y", 0, 0.4, loadImage, [item]);
		EaseMotion.ease(_bg, "alpha", 0.5, 0.25);
		_bg.visible = true;
		_title.text = item.authorName +" - "+ item.title;
	}
	private function loadImage(item:MediaItem):void {
		_loading.show();
		_loading.setProgress(0);
		EaseMotion.ease(_loading, "alpha", 1);
		_loader.resetItem();
		_loader.addImage(item.content, "image");
		_loader.load(onLoadImage, null, onLoading);
	}
	private function onLoading(per:Number):void {
		_loading.setProgress(per);
	}
	private function onLoadImage():void {
		if (!(_loader.image.image is BitmapData)) return;
		var img:BitmapData = _loader.image.image;
		EaseMotion.ease(_loading, "alpha", 0, 0.2, function():void { _loading.hide(); } );
		//画像が大きすぎたらエラー
		if (img.width > 8192 || img.height > 8192 || img.width * img.height > 16777216) {
			_errorLabel.text = "ERROR: Image too large\n(" + img.width + " X " + img.height + " px)";
			_errorLabel.visible = true;
			return;
		}
		var bmpTemp:Bitmap = new Bitmap(img, "auto", true);
		var rect:Rectangle = RectUtil.adjustRect(img.rect, _viewRect, RectUtil.FULL, false);
		var scaleW:Number = rect.width / img.width;
		var scaleH:Number = rect.height / img.height;
		var img2:BitmapData = new BitmapData(rect.width, rect.height, false, 0xFF000000);
		
		//一時的に最高画質でキャプチャ
		stage.quality = StageQuality.BEST;
		img2.draw(bmpTemp, new Matrix(scaleW, 0, 0, scaleH), null, null, null, true);
		stage.quality = StageQuality.LOW;
		
		_loader.disposeAll();
		_bmp = _imageContainer.addChild(new Bitmap(img2)) as Bitmap;
		_bmp.x = _viewRect.x + (_viewRect.width - _bmp.width) * 0.5;
		_bmp.y = _viewRect.y + (_viewRect.height - _bmp.height) * 0.5;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		onMsMove(null);
		EaseMotion.ease(_imageContainer, "alpha", 1);
	}
	private function onMsMove(e:MouseEvent):void {
		if (!_bmp) return;
		var centerX:Number = _viewRect.left + _viewRect.right / 2;
		var centerY:Number = _viewRect.top + _viewRect.bottom / 2;
		var perX:Number = (_bmp.width < _viewRect.width)? 0.5 : (stage.mouseX - centerX) / Display.WIDTH * 2 + 0.5;
		var perY:Number = (_bmp.height < _viewRect.height)? 0.5 : (stage.mouseY - centerY) / Display.HEIGHT * 2 + 0.5;
		perX = Math.max(0, Math.min(1, perX));
		perY = Math.max(0, Math.min(1, perY));
		EaseMotion.ease(_bmp, "x", _viewRect.x + (_viewRect.width - _bmp.width) * perX, 0.3);
		EaseMotion.ease(_bmp, "y", _viewRect.y + (_viewRect.height - _bmp.height) * perY, 0.3);
	}
	public function close():void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		dispose();
		_errorLabel.visible = false;
		EaseMotion.ease(_slideLayer, "y", 465, 0.4, function():void { } );
		EaseMotion.ease(_bg, "alpha", 0, 0.25, function():void { _bg.visible = false; } );
	}
}

class RectUtil {
	static public const FULL:String = "full";
	static public const AUTO:String = "auto";
	static public const FIT:String = "fit";
	static public const NONE:String = "none";
	static public function adjustRect(target:Rectangle, frame:Rectangle, mode:String = AUTO, isExpand:Boolean = true):Rectangle {
		var asp1:Number = frame.width / frame.height;
		var asp2:Number = target.width / target.height;
		var resize:Rectangle = new Rectangle();
		if (mode == FIT) {
			resize = frame.clone();
		} else if (mode == NONE) {
			resize = target.clone();
		} else if ((mode == AUTO && asp1 < asp2) || (mode == FULL && asp1 > asp2)) {
			resize.width = (!isExpand && target.width < frame.width)? target.width : frame.width;
			resize.height = resize.width / asp2;
		} else {
			resize.height = (!isExpand && target.height < frame.height)? target.height : frame.height;
			resize.width = resize.height * asp2;
		}
		return resize;
	}
}

/**
 * マップ上に配置するオブジェクト
 */
class Piece extends Sprite {
	public var bmp:Bitmap;
	public var image:BitmapData;
	public var w:int;
	public var h:int;
	public var materialID:int = -1;
	public var offsetX:int = 0;
	public var offsetY:int = 0;
	public var ads:Vector.<Ad> = new Vector.<Ad>();
	public var basePos:Point = new Point();
	protected var _px:Number;
	protected var _py:Number;
	protected var _pz:Number;
	public function Piece(img:BitmapData, sizeW:int = 2, sizeH:int = 2) {
		image = img;
		bmp = addChild(new Bitmap(image)) as Bitmap;
		w = sizeW;
		h = sizeH;
		var min:Number = Math.min(w, h) / 2
		basePos = (w >= h)? Quarter.toLocalScreen(w - min, h / 2, 0) : Quarter.toLocalScreen(w / 2, h - min, 0);
		bmp.x = h * -22;
		bmp.y = -bmp.height + (w + h) * 11;
	}
	public function setPosition(px:Number, py:Number, pz:Number):void {
		_px = px;
		_py = py;
		_pz = pz;
		update();
	}
	public function update():void {
		var p:Point = Quarter.toScreen(_px, _py, _pz);
		x = p.x + offsetX;
		y = p.y + offsetY;
	}
	public function addAd(px:Number, py:Number, width:Number, height:Number, skew:Number = -0.5):void {
		var ad:Ad = new Ad(width, height, skew);
		ad.x = bmp.x + px;
		ad.y = bmp.y + py;
		addChild(ad);
		ads.push(ad);
	}
}

/**
 * 車
 */
class Car extends Piece {
	private var _size:Rectangle = new Rectangle(0, 0, 21, 18);
	private var _carImage:BitmapData;
	private var _snapPos:Point = new Point();
	private var _map:MapView;
	//速度
	public var speed:Number = 0.05;
	//現在の方向
	private var _direction:int = 0;
	//次に曲がる方向
	private var _nextDirection:int = -1;
	public var route:Array = [];
	private var _routCount:int = -1;
	public function Car(img:BitmapData, xx:int, yy:int, map:MapView) {
		_map = map;
		_carImage = img;
		super(new BitmapData(_size.width, _size.height, true, 0), 1, 1);
		_snapPos.x = xx;
		_snapPos.y = yy;
		setPosition(xx, yy, 2);
		bmp.x += 10;
		bmp.y += -15;
		basePos.x = 0;
		basePos.y = 0;
		setDirection(_direction);
	}
	//道路に沿うように調整
	private function adjustPos():void {
		if (_direction == 0) _px = _snapPos.x + 0.25;
		else if (_direction == 2) _px = _snapPos.x + 0.75;
		else if (_direction == 1) _py = _snapPos.y + 0.25;
		else if (_direction == 3) _py = _snapPos.y + 0.75;
	}
	//前方のベクトルを取得
	private function getVector(dir:int):Point {
		var px:int = [0, 1, 0, -1][dir];
		var py:int = [ -1, 0, 1, 0][dir];
		return new Point(px, py);
	}
	//前方のタイルの座標を調べる
	private function getNextPos():Point {
		return _snapPos.add(getVector(_direction));
	}
	//次にどっちに曲がるか調べる
	private function checkNextPath():void {
		var p:Point = getNextPos();
		var path:Array = [];
		//前方のタイルからマップ外に続く進路を削る
		for each(var dir:int in _map.data.roadPath[_map.toIndex(p.x, p.y)]) {
			var p2:Point = getVector(dir).add(p);
			var num:int = _map.toIndex(p2.x, p2.y);
			if (num >= 0 && num < _map.data.W * _map.data.H) path.push(dir); 
		}
		//自分と逆方向の進路を削る
		if (path.length >= 2) {
			var ngPath:int = (_direction + 2) % 4;
			var index:int = path.indexOf(ngPath);
			if (index != -1) path.splice(index, 1);
		}
		var routeDir:int = -1;
		if (route.length && path.length >= 2) {
			_routCount = (_routCount + 1) % route.length;
			routeDir = route[_routCount];
		}
		_nextDirection = (!path.length)? -1 : (routeDir != -1)? routeDir : path[Math.floor(Math.random() * path.length)];
		if (_direction == _nextDirection) _nextDirection = -1;
	}
	/**
	 * 方向設定
	 */
	public function setDirection(dir:int):void {
		_direction = dir;
		image.copyPixels(_carImage, new Rectangle(_size.width * dir, 0, _size.width, _size.height), new Point());
	}
	/**
	 * 動かす
	 */
	public function simulateTick():void {
		var vec:Point = getVector(_direction);
		var nextTile:Point = getNextPos();
		if (_nextDirection != -1) {
			if (_nextDirection == 0) {
				if (_direction == 1 && _px > nextTile.x + 0.25) nextPath();
				else if (_direction == 3 && _px < nextTile.x + 0.25) nextPath();
				else if (_direction == 2 && _py > nextTile.y + 0.25) nextPath();
			} else if (_nextDirection == 2) {
				if (_direction == 1 && _px > nextTile.x + 0.75) nextPath();
				else if (_direction == 3 && _px < nextTile.x + 0.75) nextPath();
				else if (_direction == 0 && _py < nextTile.y + 0.75) nextPath();
			} else if (_nextDirection == 1) {
				if (_direction == 0 && _py < nextTile.y + 0.25) nextPath();
				else if (_direction == 2 && _py > nextTile.y + 0.25) nextPath();
				else if (_direction == 3 && _px < nextTile.x + 0.25) nextPath();
			} else if (_nextDirection == 3) {
				if (_direction == 0 && _py < nextTile.y + 0.75) nextPath();
				else if (_direction == 2 && _py > nextTile.y + 0.75) nextPath();
				else if (_direction == 1 && _px > nextTile.x + 0.75) nextPath();
			}
		} else {
			nextPath();
		}
		_px += vec.x * speed;
		_py += vec.y * speed;
		_pz = _map.getAltitude(_px, _py);
		rotation = _slopeRotation[_map.getSlope(_px, _py)];
		adjustPos();
		update();
	}
	private var _slopeRotation:Array = [0, -20, -20, 20, 20];
	private function nextPath():void {
		_snapPos = getNextPos();
		if(_nextDirection != -1) setDirection(_nextDirection);
		adjustPos();
		checkNextPath();
	}
}

/**
 * 色変換
 */
class ColorMatrix {
	static private const _LUM_R:Number = 0.212671;
	static private const _LUM_G:Number = 0.715160;
	static private const _LUM_B:Number = 0.072169;
	/**
	 * 色相変化フィルター用配列を取得
	 */
	static public function getHueArray(num:Number):Array {
		var rad:Number = Math.PI * num;
		var cos:Number = Math.cos(rad);
		var sin:Number = Math.sin(rad);
		var rNum:Number = 1 - cos - sin;
		var gNum:Number = 1 - cos;
		var bNum:Number = 1 - cos + sin;
		var r1:Number = _LUM_R * rNum + cos;
		var r2:Number = _LUM_G * rNum;
		var r3:Number = _LUM_B * rNum + sin;
		var g1:Number = _LUM_R * gNum + sin * 0.143;
		var g2:Number = _LUM_G * gNum + sin * 0.140 + cos;
		var g3:Number = _LUM_B * gNum - sin * 0.283;
		var b1:Number = _LUM_R * bNum - sin;
		var b2:Number = _LUM_G * bNum;
		var b3:Number = _LUM_B * bNum + cos;
		return [r1, r2, r3, 0, 0, g1, g2, g3, 0, 0, b1, b2, b3, 0, 0, 0, 0, 0, 1, 0];
	}
}

/**
 * 広告
 */
class Ad extends Sprite{
	public var item:MediaItem;
	private var _mask:Sprite;
	private var _container:Sprite = new Sprite();
	private var _size:Rectangle = new Rectangle();
	public function Ad(width:Number, height:Number, skew:Number = -0.5) {
		_mask = Painter.createColorRect(width, height);
		addChild(_container);
		addChild(_mask);
		_size.width = width;
		_size.height = height;
		_container.mask = _mask;
		_container.blendMode = BlendMode.ADD;
		transform.matrix = new Matrix(1, skew, 0, 1);
	}
	public function setItem(item:MediaItem):void {
		this.item = item;
		while (_container.numChildren) _container.removeChildAt(0);
		var bmp:Bitmap = _container.addChild(new Bitmap(item.image, "auto")) as Bitmap;
		var rect:Rectangle = RectUtil.adjustRect(bmp.bitmapData.rect, _size, RectUtil.FULL);
		bmp.width = rect.width;
		bmp.height = rect.height;
		bmp.x = (_size.width - rect.width) / 2;
		bmp.y = (_size.height - rect.height) / 2;
	}
}

/**
 * マップデータ
 */
class MapData {
	public const W:int = 25;
	public const H:int = 25;
	//水面の高さ
	public const WATER_LEVEL:int = 2;
	//道路の最低高度
	public const ROAD_LEVEL:int = 3;
	public var roadPath:Vector.<Array> = new Vector.<Array>();
	//地形の高さ
	public var level:Array = [
		[8,7,6,6,5,5,5,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[5,6,5,5,4,5,4,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[4,5,5,4,4,4,4,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[4,4,4,4,4,4,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,1],
		[4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,1],
		[3,4,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1],
		[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
		[1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2],
		[1,1,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
		[1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
		[1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
		[1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
		[1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
		[1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
		[1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
		[1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3]
	];
	//地形の傾き
	public var slope:Array = [
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0],
		[0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,4,0],
		[0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[0,0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
		[0,0,2,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],
		[0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	];
	/**
	 * 地面の種類
	 * 0:地面
	 * 1:道路
	 * 2:草
	 * 3：アスファルト
	 * 4：砂
	 * 5：木
	 * 6：電話ボックス
	 * 7：丸い植物
	 * 8：排水管（斜面専用）
	 */
	public var material:Array = [
		[2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,6,7,5,5,5,0,0,0],
		[2,2,2,2,2,2,2,0,0,1,1,1,1,1,1,1,1,1,1,1,1,5,0,0,0],
		[2,2,2,2,2,2,4,0,0,1,0,0,0,0,1,0,0,0,0,5,1,0,0,0,0],
		[2,2,2,2,2,4,0,0,0,1,0,0,0,0,1,0,0,0,0,0,1,5,8,0,0],
		[2,2,2,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0],
		[0,0,0,0,0,0,0,0,5,1,0,0,0,0,1,0,0,0,0,0,1,5,0,0,0],
		[0,0,7,1,1,1,1,1,1,1,0,0,0,0,1,5,5,5,5,7,1,5,0,0,0],
		[0,0,5,1,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,1,1,1,1,1],
		[0,0,7,1,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0],
		[0,0,0,1,0,0,0,0,0,1,5,0,0,5,1,0,0,0,0,1,0,0,8,0,0],
		[0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5,0,0,0,0],
		[0,0,7,0,0,6,5,5,5,1,5,0,6,5,1,5,0,0,5,1,5,0,0,0,0],
		[1,1,5,0,8,0,0,0,0,1,0,8,0,0,1,0,8,0,0,1,0,0,0,0,0],
		[0,1,5,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0],
		[0,1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0],
		[0,1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0],
		[1,1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0],
		[0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0],
		[0,0,0,0,5,0,0,0,0,1,0,0,0,0,1,5,6,7,7,1,0,0,0,0,5],
		[0,0,0,0,5,0,0,0,0,1,0,0,0,0,1,1,1,1,1,1,0,0,0,0,5],
		[0,0,0,0,5,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,5],
		[0,0,0,0,5,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,3,3,3,3,5],
		[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,5,0,0,6,5],
		[0,0,0,0,5,5,5,5,0,0,0,0,0,2,1,1,1,1,1,1,1,1,1,1,1],
		[0,0,0,0,0,0,5,5,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2]
	];
	public function MapData() {
		//二重配列の前後にダミーのデータを入れる
		var a:Array, i:int;
		level.unshift(level[0].concat());
		level.push(level[level.length - 1].concat());
		for each(a in level) {
			a.unshift(a[0]);
			a.push(a[a.length - 1]);
		}
		a.length = 0;
		for (i = 0; i < slope[0].length; i++) a.push(0);
		slope.unshift(a);
		slope.push(a.concat());
		for each(a in slope) {
			a.unshift(0);
			a.push(0);
		}
		material.unshift(material[0].concat());
		material.push(material[material.length - 1].concat());
		for each(a in material) {
			a.unshift(a[0]);
			a.push(a[a.length - 1]);
		}
		//
		var l:int = W * H;
		for (i = 0; i < l; i++) roadPath[i] = [];
	}
}

/**
 * オブジェクト管理
 */
class PieceMaker {
	private var _rawImage:BitmapData;
	public var image:Object = { };
	public var objects:Vector.<Piece> = new Vector.<Piece>();
	public function PieceMaker(img:BitmapData) {
		_rawImage = img;
	}
	public function hitTest(x:Number, y:Number):Ad {
		for each(var obj:Piece in objects) {
			for each(var ad:Ad in obj.ads) {
				if (ad.hitTestPoint(x, y, true)) return ad;
			}
		}
		return null;
	}
	public function newImage(x:int, y:int, width:int, height:int):BitmapData {
		var img:BitmapData = new BitmapData(width, height, true, 0);
		img.copyPixels(_rawImage, new Rectangle(x, y, width, height), new Point(), null, null, true);
		return img;
	}
	public function createPiece(name:String, x:int, y:int, width:int, height:int, sizeW:int = 2, sizeH:int = 2, matID:int = -1):Piece {
		return newPiece(name, newImage(x, y, width, height), sizeW, sizeH, matID);
	}
	public function newPiece(name:String, image:BitmapData, sizeW:int = 2, sizeH:int = 2, matID:int = -1):Piece {
		var obj:Piece = new Piece(image, sizeW, sizeH);
		obj.name = name;
		obj.materialID = matID;
		objects.push(obj);
		return obj;
	}
	public function addPiece(p:Piece):Piece {
		objects.push(p);
		return p;
	}
	public function getPiece(name:String):Piece {
		for each(var p:Piece in objects) {
			if (name == p.name) return p;
		}
		return null;
	}
	public function addChildAll(target:DisplayObjectContainer):void {
		for each(var p:Piece in objects) target.addChild(p);
	}
}

/**
 * マップ管理
 */
class MapView {
	public var container:Sprite = new Sprite();
	public var objLayer:Sprite = new Sprite();
	public var canvas:BitmapData;
	public var waterSection:BitmapData;
	public var chip:MapChip = new MapChip();
	public var data:MapData = new MapData();
	public var piece:PieceMaker;
	public var myCar:Car;
	public var cars:Vector.<Car> = new Vector.<Car>();
	public function MapView() {
		canvas = new BitmapData(1100, 865, true, 0);
		waterSection = new BitmapData(canvas.width, canvas.height, false, 0xFF000000);
		container.addChild(new Bitmap(canvas));
		container.addChild(objLayer);
	}
	private function transparent(img:BitmapData):BitmapData {
		var temp:BitmapData = new BitmapData(img.width, img.height, true, 0);
		temp.copyPixels(img, img.rect, new Point());
		temp.threshold(temp, temp.rect, new Point(), "==", 0xFF << 24 | chip.TRANSPARENT1, 0x00FFFFFF);
		temp.threshold(temp, temp.rect, new Point(), "==", 0xFF << 24 | chip.TRANSPARENT2, 0x00FFFFFF);
		return temp;
	}
	public function init(loader:ImageLoader):void {
		//マップチップ切り出し開始
		var ix:int, iy:int, i:int, k:String, img:BitmapData;
		var bmp:BitmapData = transparent(loader.image.mapchip);
		var bmp2:BitmapData = transparent(loader.image.bldg);
		var bmp3:BitmapData = transparent(loader.image.car);
		loader.image.bldg = bmp2;
		var images:Vector.<BitmapData> = new Vector.<BitmapData>();
		for (i = 0; i < 60 ; i++) {
			ix = i % 10;
			iy = int(i / 10);
			img = chip.newBitmap();
			img.copyPixels(bmp, new Rectangle(ix * chip.W, iy * chip.H, chip.W, chip.H), new Point());
			images.push(img);
		}
		//地形
		chip.terrain = images.splice(0, 15);
		//断面
		for each(k in ["L", "R"]) chip["section" + k] = images.shift();
		chip.sections = images.splice(0, 4);
		//道路
		chip.road = images.splice(0, 5);
		//歩道
		for each(k in ["TLI", "TRI", "BRI", "BLI", "TLO", "TRO", "BRO", "BLO", "T", "R", "B", "L"]) chip.sidewalk[k] = images.shift();
		//橋のフェンスと柱
		for each(k in ["PN", "PW1", "PW2", "base", "T", "R", "B", "L"]) chip.bridge[k] = images.shift();
		//白線
		for each(k in ["T", "R", "B", "L"]) chip.centerline[k] = images.shift();
		//横断歩道
		for each(k in ["X", "Y"]) chip["crosswalk" + k] = images.shift();
		for each(k in ["Grass", "Asphalt", "Sand"]) chip["ground" + k] = images.shift();
		
		chip.phoneBooth = images.shift();
		chip.grassBall = images.shift();
		images.shift();
		chip.drainpipe.B = images.shift();
		chip.drainpipe.R = images.shift();
		
		
		//オブジェクト
		piece = new PieceMaker(loader.image.bldg);
		piece.createPiece("bldg1", 0, 183, 108, 150, 2, 3, -1);
		piece.createPiece("bldg2", 230, 0, 86, 163, 2, 2, -1);
		piece.createPiece("bldg3", 0, 0, 121, 178, 3, 3, -1);
		piece.createPiece("bldg4", 121, 0, 109, 168, 2, 3, -1);
		piece.createPiece("bldg5", 316, 0, 132, 220, 4, 2, -1);
		piece.createPiece("house1", 174, 356, 174, 94, 4, 4, 2);
		piece.createPiece("house2", 0, 358, 174, 92, 4, 4, 2);
		piece.createPiece("conveni", 112, 189, 135, 84, 4, 3, 3);
		piece.createPiece("park", 110, 274, 112, 76, 4, 2, 2);
		piece.createPiece("busstopV", 255, 227, 56, 49, 1, 2, -1);
		piece.createPiece("busstopH", 319, 227, 60, 49, 2, 1, -1);
		piece.createPiece("adsignV", 383, 229, 61, 69, 1, 2, -1);
		piece.createPiece("adsignH", 444, 229, 53, 69, 2, 1, -1);
		piece.createPiece("parking", 348, 313, 152, 112, 4, 3, 3);
		piece.image.tree = piece.newImage(232, 313, 42, 37);
		
		piece.getPiece("bldg1").addAd(19, 40, 40, 34, 0.5);
		piece.getPiece("bldg1").addAd(88, 280 - 183, 20, 30, -0.5);
		piece.getPiece("bldg2").addAd(15, 16, 27, 28, 0.5);
		piece.getPiece("bldg2").addAd(44, 29, 27, 28, -0.5);
		piece.getPiece("bldg3").addAd(56, 51, 29, 61, -0.5);
		piece.getPiece("bldg3").addAd(4, 9, 31, 21, 0.5);
		piece.getPiece("bldg4").addAd(59, 66, 44, 46, -0.5);
		piece.getPiece("bldg5").addAd(11, 81, 22, 45, 0.5);
		piece.getPiece("bldg5").addAd(11, 129, 22, 45, 0.5);
		piece.getPiece("bldg5").addAd(69, 110, 40, 94, 0);
		piece.getPiece("conveni").addAd(44, 11, 22, 13, 0.5);
		piece.getPiece("adsignV").addAd(15, 19, 36, 36, -0.5);
		piece.getPiece("adsignH").addAd(10, 1, 36, 36, 0.5);
		piece.getPiece("parking").addAd(56, 2, 36, 35, 0.5);
		piece.getPiece("parking").addAd(100, 24, 36, 35, 0.5);
		
		putObject(piece.getPiece("bldg1"), 16, 7);
		putObject(piece.getPiece("bldg2"), 11, 7);
		putObject(piece.getPiece("bldg3"), 17, 3);
		putObject(piece.getPiece("bldg4"), 0, 8);
		putObject(piece.getPiece("bldg5"), 4, 7);
		putObject(piece.getPiece("house2"), 10, 18);
		putObject(piece.getPiece("house1"), 5, 18);
		putObject(piece.getPiece("park"), 9, 23);
		putObject(piece.getPiece("conveni"), 15, 20);
		putObject(piece.getPiece("busstopV"), 2, 9);
		putObject(piece.getPiece("busstopH"), 21, 22);
		putObject(piece.getPiece("adsignV"), 13, 23);
		putObject(piece.getPiece("adsignH"), 11, 9);
		putObject(piece.getPiece("parking"), 20, 18);
		
		drawTerrain();
		
		myCar = piece.addPiece(new Car(bmp3, 7, 22, this)) as Car;
		//myCar.route = [1,2,0,3,0,1,0,0,2,3,0,3,2];
		myCar.route = [1,2,0,0,0,0,2,3,0,3,2];
		myCar.setDirection(1);
		for (i = 0; i < 10; i++) {
			var c:Car = piece.addPiece(new Car(bmp3, i+3, 12, this)) as Car;
			c.filters = [new ColorMatrixFilter(ColorMatrix.getHueArray(Math.random() * 2 - 1))];
			cars.push(c);
		}
		piece.addChildAll(objLayer);
		
		bmp.dispose();
		bmp2.dispose();
	}
	/**
	 * 建造物を指定の位置に置く
	 */
	public function putObject(obj:Piece, x:int, y:int, z:int = 0):void {
		var h:int, maxH:int = int.MIN_VALUE, ix:int, iy:int;
		for (ix = x; ix < x + obj.w; ix++) {
			for (iy = y; iy < y + obj.h; iy++) {
				h = getLevel(ix, iy);
				if (h > maxH) maxH = h;
			}
		}
		obj.setPosition(x, y, Math.max(z, maxH, data.WATER_LEVEL));
		if (obj.materialID == -1) return;
		for (ix = x; ix < x + obj.w; ix++) {
			for (iy = y; iy < y + obj.h; iy++) {
				setMaterial(ix, iy, obj.materialID);
			}
		}
	}
	/**
	 * 地形マップを描画する
	 */
	public function drawTerrain():void {
		canvas.fillRect(canvas.rect, 0);
		var ct_white1:ColorTransform = new ColorTransform();
		var ct_white2:ColorTransform = new ColorTransform();
		var ct_black:ColorTransform = new ColorTransform();
		var ct_water1:ColorTransform = new ColorTransform();
		var ct_water2:ColorTransform = new ColorTransform();
		ct_white1.color = 0xFFFFFF;
		ct_white2.color = 0x888888;
		ct_black.color = 0x000000;
		ct_water1.color = 0x1C3C82;
		ct_water2.color = 0x1F459B;//0x617DBE;
		
		var dirSign1:Array = ["t", "l", "b", "r"];
		var dirSign2:Array = ["tl", "tr", "bl", "br"];
		var dirSign3:Array = ["t", "l", "b", "r", "tl", "tr", "bl", "br"];
		var ofx:Object = { t:0, r:1, b:0, l: -1, tl:-1, tr:1, bl:-1, br:1 };
		var ofy:Object = { t: -1, r:0, b:1, l:0, tl:-1, tr:-1, bl:1, br:1 };
		var index:Object = { t: 0, r:1, b:2, l:3 };
		
		var k:String, i:int, slope:int, h:int, h2:Number, ix:int, iy:int, iz:int, pz:int, img:BitmapData;
		var isSubmerged:Boolean, id:int, isHorizon:Boolean;
		var level:int = Math.max(data.ROAD_LEVEL, data.WATER_LEVEL);
		for (ix = 0; ix < data.W; ix++) {
			for (iy = 0; iy < data.H; iy++) {
				h = getLevel(ix, iy);
				//背面の水の断面を描画
				if (!ix || !iy || ix == (data.W - 1) || iy == (data.H - 1)) {
					for (iz = 0; iz <= data.WATER_LEVEL; iz++) {
						var txy:Point = Quarter.toScreen(ix, iy, iz).add(new Point(0, -chip.H));
						if (!ix) paintBlock(canvas, chip.sectionR, ix, iy, iz, -20, -11, ct_water1);
						if (!iy) paintBlock(canvas, chip.sectionL, ix, iy, iz, 20, -11, ct_water2);
						if (ix == (data.W - 1)) paintBlock(waterSection, chip.sectionR, ix, iy, iz, 0, 0, ct_white1);
						if (iy == (data.H - 1)) paintBlock(waterSection, chip.sectionL, ix, iy, iz, 0, 0, ct_white2);
					}
				}
				slope = 0
				//地形を描画
				for (iz = 0; iz <= h; iz++) {
					var deep:int = 5 * Math.min(2, Math.max(0, (data.WATER_LEVEL - iz + 1)));
					slope = (iz == h)? getSlope(ix, iy) : 0;
					img = chip.terrain[slope + deep];
					drawBlock(img, ix, iy, iz);
					//地形の断面を描画
					if (ix == (data.W - 1) && slope != 4) {
						//右端
						img = (slope == 0 || slope == 2)? chip.sectionR : chip.sections[slope-1];
						drawBlock(img, ix, iy, iz);
						paintBlock(waterSection, img, ix, iy, iz, 0, 0, ct_black);
					}
					if (iy == (data.H - 1) && slope != 1) {
						//左端
						img = (slope == 0 || slope == 3)? chip.sectionL : chip.sections[slope-1];
						drawBlock(img, ix, iy, iz);
						paintBlock(waterSection, img, ix, iy, iz, 0, 0, ct_black);
					}
				}
				iz = h;
				h2 = getHeight(ix, iy);
				isSubmerged = h2 < data.WATER_LEVEL;
				id = getMaterial(ix, iy);
				isHorizon = (slope == 0);
				//道路
				if (id == 1) {
					if(h2 >= level){
						//普通に描画
						img = chip.road[slope];
						iz = h;
					} else {
						//最低レベルより下にいかないようにする
						img = chip.road[0];
						iz = level;
						setLevel(ix, iy, iz);
						setSlope(ix, iy, 0);
						//橋の支柱
						if (isHorizon) {
							for (pz = h; pz < level; pz++) {
								var pict:BitmapData = [chip.bridge.PN, chip.bridge.PW1, chip.bridge.PW2][Math.min(2, Math.max(0, data.WATER_LEVEL - pz))];
								drawPlane(pict, ix, iy, pz);
							}
						}
						drawPlane(chip.bridge.base, ix, iy, iz, 0, 3);
					}
					drawBlock(img, ix, iy, iz);
					//橋のフェンス
					if (h2 < level) {
						for each(k in dirSign1) {
							if (getMaterial(ix + ofx[k], iy + ofy[k]) != 1) drawPlane(chip.bridge[k.toUpperCase()], ix, iy, iz);
						}
					}
				}
				if (!isSubmerged && isHorizon) {
					if (id == 2) drawBlock(chip.groundGrass, ix, iy, iz);
					if (id == 3) drawBlock(chip.groundAsphalt, ix, iy, iz);
					if (id == 4) drawBlock(chip.groundSand, ix, iy, iz);
					if (id == 5) putObject(piece.newPiece("tree", piece.image.tree, 1, 1), ix, iy, iz);
				}
			}
		}
		var noLine:Array = [];
		var slopeH:Object = {
			t:[0, -0.5, 0, 0.5, 0],
			b:[0, 0.5, 0, -0.5, 0],
			l:[0, 0, 0.5, 0, -0.5],
			r:[0, 0, -0.5, 0, 0.5]
		}
		//道路の歩道と白線
		for (ix = 0; ix < data.W; ix++) {
			for (iy = 0; iy < data.H; iy++) {
				h2 = getHeight(ix, iy);
				id = getMaterial(ix, iy);
				slope = getSlope(ix, iy);
				iz = getLevel(ix, iy);
				isHorizon = slope == 0;
				isSubmerged = (h2 < data.WATER_LEVEL);
				var cn:Object = { };
				for each(k in dirSign3) {
					var plusH:Number = (k.length == 2)? 0 : slopeH[k][getSlope(ix + ofx[k], iy +ofy[k])];
					cn[k] = getMaterial(ix + ofx[k], iy + ofy[k]) == 1 && h2 == getHeight(ix + ofx[k], iy + ofy[k]) + plusH;
				}
				//道路
				if (id == 1) {
					//白線描画
					if (isHorizon) {
						if (cn.t + cn.b + cn.r + cn.l >= 3 && !cn.tl && !cn.tr && !cn.br && !cn.bl) {
							for each(k in dirSign1) {
								if (cn[k]) {
									img = (k == "t" || k == "b")? chip.crosswalkX : chip.crosswalkY;
									drawBlock(chip.road[0], ix + ofx[k], iy + ofy[k], iz);
									drawBlock(img, ix + ofx[k], iy + ofy[k], iz);
									if (k == "r" || k == "b") noLine[toIndex(ix + ofx[k], iy + ofy[k])] = true;
								}
							}
						} else if (!noLine[toIndex(ix, iy)]) {
							for each(k in dirSign1) if (cn[k]) drawBlock(chip.centerline[k.toUpperCase()], ix, iy, iz);
						}
					}
					//進行可能な方向を記録
					for each(k in dirSign1) {
						if (cn[k]) data.roadPath[toIndex(ix, iy)].push(index[k]);
					}
				} else if (isHorizon && iz >= level) {
					//歩道描画
					if(cn.t) drawBlock(chip.sidewalk.T, ix, iy, iz);
					if(cn.b) drawBlock(chip.sidewalk.B, ix, iy, iz);
					if(cn.l) drawBlock(chip.sidewalk.L, ix, iy, iz);
					if(cn.r) drawBlock(chip.sidewalk.R, ix, iy, iz);
					if(cn.t && cn.r) drawBlock(chip.sidewalk.TRI, ix, iy, iz);
					if(cn.t && cn.l) drawBlock(chip.sidewalk.TLI, ix, iy, iz);
					if(cn.b && cn.r) drawBlock(chip.sidewalk.BRI, ix, iy, iz);
					if(cn.b && cn.l) drawBlock(chip.sidewalk.BLI, ix, iy, iz);
					if(!cn.t && !cn.r && cn.tr) drawBlock(chip.sidewalk.TRO, ix, iy, iz);
					if(!cn.t && !cn.l && cn.tl) drawBlock(chip.sidewalk.TLO, ix, iy, iz);
					if(!cn.b && !cn.r && cn.br) drawBlock(chip.sidewalk.BRO, ix, iy, iz);
					if(!cn.b && !cn.l && cn.bl) drawBlock(chip.sidewalk.BLO, ix, iy, iz);
				}
				if (!isSubmerged) {
					if (id == 6) drawPlane(chip.phoneBooth, ix, iy, iz);
					if (id == 7) drawPlane(chip.grassBall, ix, iy, iz);
					if (id == 8) {
						if(slope == 4) drawBlock(chip.drainpipe.R, ix, iy, iz);
						if(slope == 1) drawBlock(chip.drainpipe.B, ix, iy, iz);
					}
				}
			}
		}
		//水の断面を描画
		var bmp:BitmapData = new BitmapData(canvas.width, canvas.height, true, 0xFF324856);
		bmp.copyChannel(waterSection, waterSection.rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA);
		canvas.draw(bmp, new Matrix(), new ColorTransform(1, 1, 1, 1), BlendMode.MULTIPLY);
		bmp.dispose();
	}
	public function toIndex(x:int, y:int):int {
		return x * data.W + y;
	}
	public function getSlope(x:int, y:int):int {
		return data.slope[y + 1][x + 1];
	}
	public function getMaterial(x:int, y:int):int {
		return data.material[y + 1][x + 1];
	}
	/**
	 * 正確な高度を取得
	 */
	public function getAltitude(x:Number, y:Number):Number {
		var lv:Number = getLevel(int(x), int(y));
		var intX:Number = x - int(x);
		var intY:Number = y - int(y);
		var slope:int = getSlope(int(x), int(y));
		if (slope == 1) lv += -intY;
		if (slope == 2) lv += - 1 + intX;
		if (slope == 3) lv += - 1 + intY;
		if (slope == 4) lv += -intX;
		return lv;
	}
	/**
	 * 斜面も考慮した高さを取得
	 */
	public function getHeight(x:int, y:int):Number {
		return data.level[y + 1][x + 1] - int(!!getSlope(x, y)) * 0.5;
	}
	/**
	 * 斜面を無視した高さを取得
	 */
	public function getLevel(x:int, y:int):int {
		return data.level[y + 1][x + 1];
	}
	public function setMaterial(x:int, y:int, id:int):void {
		data.material[y + 1][x + 1] = id;
	}
	public function setSlope(x:int, y:int, slope:int):void {
		data.slope[y + 1][x + 1] = slope;
	}
	public function setLevel(x:int, y:int, lv:int):void {
		data.level[y + 1][x + 1] = lv;
	}
	public function paintBlock(target:BitmapData, img:BitmapData, x:Number, y:Number, z:Number, offsetX:int = 0, offsetY:int = 0, ct:ColorTransform = null):void {
		paintPlane(target, img, x, y, z - 1, offsetX, offsetY - 1, ct);
	}
	public function paintPlane(target:BitmapData, img:BitmapData, x:Number, y:Number, z:Number, offsetX:int = 0, offsetY:int = 0, ct:ColorTransform = null):void {
		var p:Point = Quarter.toScreen(x, y, z);
		p.x -= 22;
		p.y += 22;
		target.draw(img, new Matrix(1, 0, 0, 1, p.x + offsetX, p.y - img.height + offsetY), ct);
	}
	public function drawBlock(img:BitmapData, x:Number, y:Number, z:Number, offsetX:int = 0, offsetY:int = 0):void {
		drawPlane(img, x, y, z - 1, offsetX, offsetY - 1);
	}
	public function drawPlane(img:BitmapData, x:Number, y:Number, z:Number, offsetX:int = 0, offsetY:int = 0):void {
		var p:Point = Quarter.toScreen(x, y, z);
		p.x -= 22;
		p.y += 22;
		canvas.copyPixels(img, img.rect, new Point(p.x + offsetX, p.y - img.height + offsetY), null, null, true); 
	}
}
class Quarter {
	/**
	 * クオータービュー座標をスクリーン座標に変換する
	 */
	static public function toScreen(x:Number, y:Number, z:Number):Point {
		return toLocalScreen(x, y, z).add(new Point(550, 150));
	}
	static public function toLocalScreen(x:Number, y:Number, z:Number):Point {
		return new Point(x * 22 - y * 22, x * 11 + y * 11 - z * 16);
	}
}
/**
 * マップチップ
 */
class MapChip {
	public const W:int = 42;
	public const H:int = 37;
	public const SIZE:Rectangle = new Rectangle(0, 0, W, H);
	//透過色
	public const TRANSPARENT1:uint = 0x324856;
	public const TRANSPARENT2:uint = 0x182329;
	//道路マップリスト
	public var road:Vector.<BitmapData>;
	//T,B,L,R,TL,TR,BL,BR,TLI,TRI,BLI,BRI,TLO,TRO,BLO,BRO
	public var sidewalk:Object = { };
	//RB(TL)
	public var drainpipe:Object = { };
	//TRBL
	public var centerline:Object = { };
	//TBLR
	public var bridge:Object = { };
	//地形マップリスト
	public var terrain:Vector.<BitmapData>;
	public var crosswalkX:BitmapData;
	public var crosswalkY:BitmapData;
	public var groundGrass:BitmapData;
	public var groundAsphalt:BitmapData;
	public var groundSand:BitmapData;
	public var phoneBooth:BitmapData;
	public var grassBall:BitmapData;
	//断面
	public var sectionL:BitmapData;
	public var sectionR:BitmapData;
	public var sections:Vector.<BitmapData>;
	public function MapChip() {
	}
	public function newBitmap(transparent:Boolean = true, color:uint = 0x000000):BitmapData {
		var bg:uint = (transparent)? 0x00 << 24 | color : 0xFF << 24 | color;
		return new BitmapData(W, H, transparent, bg);
	}
}
/**
 * 画面サイズ
 */
class Display {
	static public var stage:Stage;
	static public const WIDTH:int = 465;
	static public const HEIGHT:int = 465;
	static public const SIZE:Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
	static public const CENTER:Point = new Point(SIZE.width / 2, SIZE.height / 2);
}
/**
 * Flickrから画像読み込み
 */
class Flickr extends EventDispatcher {
	static public const API:String = "http://api.flickr.com/services/feeds/photos_public.gne";
	static public const NS_MEDIA:String = "http://search.yahoo.com/mrss/";
	static public const NS_DC:String = "http://purl.org/dc/elements/1.1/";
	static public const NS_CC:String = "http://cyber.law.harvard.edu/rss/creativeCommonsRssModule.html";
	static public const NS_FLICKR:String = "urn:flickr:";
	/**サムネイルが読み込み完了する度に呼び出されるイベント*/
	static public const EVENT_LOADIMAGE:String = "onLoadImage";
	/**条件にマッチする画像が1つも見つからなかった時のイベント*/
	static public const EVENT_NOIMAGE:String = "onNoImage";
	/**画像を読み込む枚数*/
	public var loadLimit:int = 20;
	/**Flash以外を読み込む*/
	public var isSkipFlash:Boolean = true;
	/**全MediaItemデータ*/
	public var items:Vector.<MediaItem> = new Vector.<MediaItem>();
	/**サムネイルの読み込みが完了したMediaItemデータ*/
	public var loaded:Vector.<MediaItem> = new Vector.<MediaItem>();
	private var _stock:Vector.<MediaItem>;
	private var _rssLoader:URLLoader;
	private var _activeItem:MediaItem;
	private var _imageLoader:Loader;
	public function Flickr() {
		_rssLoader = new URLLoader();
		_imageLoader = new Loader();
	}
	/**
	 * Flickrの画像を検索する
	 */
	public function load(tag:String):void {
		items.length = 0;
		loaded.length = 0;
		removeEventImage();
		_rssLoader.addEventListener(Event.COMPLETE, onLoadRss);
		_rssLoader.addEventListener(IOErrorEvent.IO_ERROR, onErrorRss);
		_rssLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorRss);
		_rssLoader.load(new URLRequest(getSearchPath(tag)));
	}
	private function onErrorRss(e:ErrorEvent):void {
		removeEventRss();
		dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.text));
	}
	private function onLoadRss(e:Event):void {
		for each(var itm:MediaItem in items) itm.dispose();
		_stock = new Vector.<MediaItem>();
		removeEventRss();
		var xml:XML = new XML(_rssLoader.data);
		var media:Namespace = new Namespace(NS_MEDIA);
		var dc:Namespace = new Namespace(NS_DC);
		var cc:Namespace = new Namespace(NS_CC);
		var flickr:Namespace = new Namespace(NS_FLICKR);
		var tf:TextField = new TextField();
		for each(var node:XML in xml..item) {
			var item:MediaItem = new MediaItem();
			item.title = node.media::title;
			tf.htmlText = node.media::description;
			item.authorName = String(node.author).match(/.*?\((.*)\)/)[1];
			item.authorURL = node.author.@flickr::profile;
			item.descriptionHTML = node.media::description;
			item.descriptionText = tf.text;
			item.date.setDate(node.dc::date.Taken);
			item.thumbnail = node.media::thumbnail.@url;
			item.type = node.media::content.@type;
			item.content = node.media::content.@url;
			item.content_t = item.content.replace(/_[mstbo]\./, "_t.");
			item.isFlash = item.type == "application/x-shockwave-flash";
			if (!isSkipFlash || !item.isFlash) _stock.push(item);
		}
		_stock.sort(function():int { return 1 - Math.floor(Math.random() * 3) } );
		if (_stock.length > loadLimit) _stock.length = loadLimit;
		items = _stock.concat();
		if (!items.length) {
			dispatchEvent(new Event(EVENT_NOIMAGE));
		} else {
			loadNext();
		}
	}
	private function loadNext():void {
		if (!_stock.length || loaded.length >= loadLimit) {
			completeLoad();
			return;
		}
		_activeItem = _stock.shift();
		if (!_activeItem.thumbnail) {
			loadNext();
			return;
		}
		_imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadImage);
		_imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
		_imageLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
		_imageLoader.load(new URLRequest(_activeItem.thumbnail), new LoaderContext(true));
	}
	private function onErrorImage(e:ErrorEvent):void {
		removeEventImage();
		_activeItem.isLoading = false;
		_activeItem.isError = true;
		loadNext();
	}
	private function onLoadImage(e:Event):void {
		removeEventImage();
		_activeItem.isLoading = false;
		_activeItem.image = Bitmap(_imageLoader.content).bitmapData;
		loaded.push(_activeItem);
		dispatchEvent(new Event(EVENT_LOADIMAGE));
		loadNext();
	}
	private function completeLoad():void {
		_activeItem = null;
		dispatchEvent(new Event(Event.COMPLETE));
	}
	private function removeEventImage():void {
		_imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadImage);
		_imageLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
		_imageLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
	}
	private function removeEventRss():void {
		_rssLoader.removeEventListener(Event.COMPLETE, onLoadRss);
		_rssLoader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorRss);
		_rssLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorRss);
	}
	public function getSearchPath(tag:String):String {
		return API + "?format=rss_200&tags=" + tag;
	}
}
/**
 * MediaRSSから取りだした画像データ
 */
class MediaItem {
	/**サムネイル読み込み中か*/
	public var isLoading:Boolean = true;
	/**サムネイルの読み込みに失敗したか*/
	public var isError:Boolean = false;
	/**タイトル*/
	public var title:String;
	/**作者名*/
	public var authorName:String;
	/**作者URL*/
	public var authorURL:String;
	/**投稿日時*/
	public var date:Date = new Date();
	/**説明文（HTMLテキスト）*/
	public var descriptionHTML:String;
	/**説明文（テキスト）*/
	public var descriptionText:String;
	/**サムネイルURL*/
	public var thumbnail:String;
	/**原寸画像URL*/
	public var content:String;
	public var type:String;
	public var isFlash:Boolean;
	public var content_t:String;
	/**サムネイルBitmapData*/
	public var image:BitmapData;
	public function MediaItem() {
	}
	/**
	 * データを破棄
	 */
	public function dispose():void {
		image.dispose();
	}
}
/**
 * 複数画像読み込み
 */
class ImageLoader {
	public var image:Object = new Object();
	private var _images:Array = new Array();
	private var _count:int;
	private var _completeFunc:Function;
	private var _errorFunc:Function;
	private var _progressFunc:Function;
	private var _activeLoader:Loader;
	public function ImageLoader() {
	}
	public function addImage(src:String, name:String):void {
		_images.push( { src:src, name:name } );
	}
	public function stop():void {
		if (_activeLoader) {
			_activeLoader.unloadAndStop();
			removeEvent(_activeLoader.contentLoaderInfo);
			_activeLoader = null;
		}
	}
	public function load(complete:Function, error:Function = null, progress:Function = null):void {
		_count = -1;
		_completeFunc = complete;
		_errorFunc = error;
		_progressFunc = progress;
		next();
	}
	public function resetItem():void {
		_images.length = 0;
	}
	public function disposeAll():void {
		for (var k:String in image) {
			dispose(k);
		}
	}
	public function dispose(id:String):void {
		if (image[id] is BitmapData) {
			var bmp:BitmapData = image[id];
			if (bmp) bmp.dispose();
		}
	}
	private function next():void {
		if (++_count >= _images.length) {
			if (_completeFunc != null) _completeFunc();
			return;
		}
		_activeLoader = new Loader();
		_activeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		_activeLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
		_activeLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
		_activeLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		_activeLoader.load(new URLRequest(_images[_count].src), new LoaderContext(true));
	}
	private function onProgress(e:ProgressEvent):void {
		var info:LoaderInfo = e.currentTarget as LoaderInfo;
		var per:Number = (_count + info.bytesLoaded / info.bytesTotal) / _images.length;
		if (_progressFunc != null) {
			var args:Array = [per, LoaderInfo(e.currentTarget)];
			if (_progressFunc.length < args.length) args.length = _progressFunc.length;
			_progressFunc.apply(null, args);
		}
	}
	private function onError(e:ErrorEvent):void {
		_activeLoader = null;
		removeEvent(e.currentTarget as LoaderInfo);
		if (_errorFunc != null) _errorFunc.apply(null, []);
	}
	private function onComplete(e:Event):void {
		_activeLoader = null;
		var info:LoaderInfo = e.currentTarget as LoaderInfo;
		removeEvent(info);
		if (info.content is Bitmap) {
			image[_images[_count].name] = Bitmap(info.content).bitmapData;
		} else {
			image[_images[_count].name] = info.content;
		}
		next();
	}
	private function removeEvent(target:LoaderInfo):void {
		target.removeEventListener(ProgressEvent.PROGRESS, onProgress);
		target.removeEventListener(Event.COMPLETE, onComplete);
		target.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
	}
}
/**
 * 簡易イージング
 */
class EaseMotion {
	private static var _sprite:Sprite = new Sprite();
	private static var _targets:Dictionary = new Dictionary();
	private static var _isInit:Boolean = false;
	public function EaseMotion() {
	}
	private static function init():void {
		if (_isInit) return;
		_isInit = true;
		_sprite.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	static private function onEnterFrame(e:Event):void {
		var p:ParamData, o:Object, k:String;
		for each(o in _targets) {
			for (k in o) {
				p = ParamData(o[k]);
				p.position += (p.to - p.position) * p.speed;
				var n:Number = p.position < p.to ? p.to - p.position : p.position - p.to;
				p.target[k] = p.position;
				if (n <= p.snap) {
					p.target[k] = p.to;
					if (p.completeFunc != null) {
						p.completeFunc.apply(null, p.args);
						p.completeFunc = null;
					}
					delete o[k];
				}
			}
		}
	}
	static public function goto(target:Object, param:String, to:Number):void {
		var tgt:Object = _targets[target];
		if (tgt) delete tgt[param];
		target[param] = to;
	}
	/**
	 * オブジェクトのプロパティを指定の数値に近付ける
	 * @param	target	対象オブジェクト
	 * @param	param	プロパティ名
	 * @param	to	近づける値
	 * @param	speed	速度(0超過～1以下)
	 * @param	complete	移動しきった時に呼び出す関数
	 * @param	args	関数に渡す引数
	 * @param	snap	
	 */
	static public function ease(target:Object, param:String, to:Number, speed:Number = NaN, complete:Function = null, args:Array = null, snap:Number = NaN):void {
		init();
		var p:ParamData;
		var tgt:Object = _targets[target];
		if (tgt) {
			p = tgt[param];
			if (p) {
				p.to = to;
				p.snap = (isNaN(snap))? (p.to - p.position) * 0.01 : snap;
				if (p.snap < 0) p.snap = -p.snap;
				if (!isNaN(speed)) p.speed = speed;
				p.completeFunc = complete;
				p.args = (!args)? [] : args;
				return;
			}
		} else {
			_targets[target] = { };
		}
		p = new ParamData();
		p.target = target;
		p.position = target[param];
		p.to = to;
		p.snap = (isNaN(snap))? (p.to - p.position) * 0.01 : snap;
		p.completeFunc = complete;
		p.args = (!args)? [] : args;
		if (p.snap < 0) p.snap = -p.snap;
		if (!isNaN(speed)) p.speed = speed;
		_targets[target][param] = p;
	}
	static public function setSpeed(target:Object, param:String, speed:Number):void {
		var pd:ParamData = getEase(target, param);
		if (pd) pd.speed = speed;
	}
	static public function getEase(target:Object, param:String):ParamData {
		if (!_targets[target]) return null;
		return _targets[target][param];
	}
}
/**
 * イージング用データ
 */
class ParamData {
	public var target:Object;
	public var position:Number = 0;
	public var to:Number = 0;
	public var speed:Number = 0.2;
	public var snap:Number = 0;
	public var args:Array = [];
	public var completeFunc:Function;
	public function ParamData() {
	}
}
class Painter {
	/**
	 * べた塗りスプライト生成
	 */
	static public function createColorRect(width:Number, height:Number, color:uint = 0x000000, alpha:Number = 1, x:Number = 0, y:Number = 0):Sprite {
		var sp:Sprite = new Sprite();
		sp.graphics.beginFill(color, alpha);
		sp.graphics.drawRect(0, 0, width, height);
		sp.graphics.endFill();
		sp.x = x;
		sp.y = y;
		return sp;
	}
}