/**
 * Alternativa3D7.5の練習
 * Colladaモデルを読み込んでカメラを動かしているだけです
 * カメラの位置によってはエラーが出てしまうみたいで時々固まります。。
 */
package  {
	import alternativ7.engine3d.containers.BSPContainer;
	import alternativ7.engine3d.controllers.SimpleObjectController;
	import alternativ7.engine3d.core.Camera3D;
	import alternativ7.engine3d.core.Object3D;
	import alternativ7.engine3d.core.Sorting;
	import alternativ7.engine3d.core.View;
	import alternativ7.engine3d.loaders.events.LoaderErrorEvent;
	import alternativ7.engine3d.loaders.events.LoaderProgressEvent;
	import alternativ7.engine3d.loaders.MaterialLoader;
	import alternativ7.engine3d.loaders.ParserCollada;
	import alternativ7.engine3d.materials.FillMaterial;
	import alternativ7.engine3d.materials.TextureMaterial;
	import alternativ7.engine3d.objects.Mesh;
	import com.bit101.components.CheckBox;
	import com.bit101.components.Label;
	import com.bit101.components.Style;
	import com.bit101.components.VBox;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.Dictionary;
	import net.hires.debug.Stats;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.easing.Quad;
	import org.libspark.betweenas3.tweens.ITween;
	import org.libspark.betweenas3.tweens.ITweenGroup;
	public class Alternativa3DTest extends Sprite {
		private var _autoCamera:Object3D = new Object3D();
		private var _userCamera:Object3D = new Object3D();
		private var _cameraMode:int = 0;
		private var _camera:Camera3D;
		private var _controller:SimpleObjectController;
		private var _scene:BSPContainer;
		private var _dragger:GlobeDragger;
		
		private var _stats:Stats;
		private var _bg:Sprite;
		private var _header:Sprite;
		private var _info:Label;
		private var _loadingTxt:Label;
		private var _wireMaterial:FillMaterial = new FillMaterial(0, 0, 0, 0xffffff);
		private var _rawTextures:Dictionary = new Dictionary();
		
		private var _loader:URLLoader;
		private var _parser:ParserCollada;
		private var _mloader:MaterialLoader;
		private var _isInitError:Boolean = false;
		
		private const PATH_POLICY:String = "http://shelter.s377.xrea.com/crossdomain.xml";
		private const PATH_DIR:String = "http://shelter.s377.xrea.com/assets/wonderfl/alt3dtest/";
		private const PATH_DAE:String = "model_wdfl.DAE";
		
		/**
		 * コンストラクタ
		 */
		public function Alternativa3DTest() {
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onResize);
			
			_camera = new Camera3D();
			_camera.view = new View(465, 465);
			_camera.view.alpha = 0;
			_controller = new SimpleObjectController(stage, _camera, 1);
						
			_scene = new BSPContainer();
			_scene.addChild(_camera);
			
			//マウスドラッグで動かすカメラ用
			_dragger = new GlobeDragger(this, 45, 2, 320);
			_dragger.enabled = false;
			_dragger.wheelEnabled = false;
			_dragger.angleSpeed = _dragger.rotationSpeed = 0.75;
			_dragger.setAngleLimit( -7, 90);
			_dragger.setDistanceLimit(10, 420);
			
			var v:Vector3D = _dragger.position;
			_userCamera.x = v.x;
			_userCamera.y = v.z;
			_userCamera.z = v.y;
			
			//画面に配置するもの色々
			_bg = Painter.createColorRect(465, 465, 0x000000);
			_header = new Sprite();
			_header.addChild(Painter.createColorRect(465, 40, 0, 0.5));
			Style.LABEL_TEXT = 0x000000;
			new SwitchButton(_header, 10, 10, ["CAMERA : AUTO", "CAMERA : DRAG"], onSwitchCamera);
			new SwitchButton(_header, 120, 10, ["WIREFRAME : OFF", "WIREFRAME : ON"], onSwitchMaterial);
			Style.LABEL_TEXT = 0xFFFFFF;
			_info = new Label(_header, 230, 10, "");
			_loadingTxt = new Label(null, 10, 10, "LOADING COLLADA MODEL ...");
			_stats = new Stats( { bg:0x222222 } );
			Style.BACKGROUND = 0x444444;
			var vox:VBox = new VBox(_header);
			vox.x = 8;
			vox.y = 50;
			vox.spacing = 12;
			for (var i:int = 0; i < 3; i++) {
				var chk:CheckBox = new CheckBox(vox, 0, 0, ["VOLUME LIGHT", "REFLECTION", "BSP SORTING"][i], onClickCheckBox);
				chk.tag = i;
				chk.selected = true;
			}
			addChild(_bg);
			addChild(_loadingTxt);
			addChild(_camera.view);
			addChild(_header);
			addChild(_stats);
			
			_header.visible = false;
			
			onResize(null);
			startLoad();
		}
		private function onClickCheckBox(e:MouseEvent):void{
			var rb:CheckBox = e.currentTarget as CheckBox;
			switch(rb.tag) {
				case 0:
					_scene.getChildByName("volumelight").visible = rb.selected;
					break;
				case 1:
					_scene.getChildByName("floor").blendMode = (rb.selected)? BlendMode.ADD : BlendMode.NORMAL;
					break;
				case 2:
					setBSPEnabled(rb.selected);
					break;
			}
		}
		/**
		 * BSPソートとZソートを切り替える
		 * @param	enabled
		 */
		private function setBSPEnabled(enabled:Boolean):void{
			for (var i:int = 0; i < _scene.numChildren; i++) {
				var m:Mesh = _scene.getChildAt(i) as Mesh;
				if (!m) continue;
				if (["floor", "sunlight", "containerbox", "truss", "poles"].indexOf(m.name) != -1) {
					m.sorting = (enabled)? Sorting.DYNAMIC_BSP : Sorting.AVERAGE_Z;
				}
			}
		}
		/**
		 * カメラモード切り替え
		 */
		private function onSwitchCamera(e:MouseEvent, mode:int):void {
			_cameraMode = mode;
			_dragger.enabled = (_cameraMode == 1);
			onTick(null);
		}
		/**
		 * マテリアル張り替え
		 */
		private function onSwitchMaterial(e:MouseEvent, mode:int):void {
			for (var i:int = 0; i < _scene.numChildren; i++) {
				var o:Object3D = _scene.getChildAt(i);
				if (o is Mesh) {
					var m:Mesh = o as Mesh;
					m.setMaterialToAllFaces(mode? _wireMaterial : _rawTextures[m]);
				}
			}
			_camera.render();
		}
		/**
		 * 画面リサイズ時
		 */
		private function onResize(e:Event):void {
			var sw:Number = stage.stageWidth;
			var sh:Number = stage.stageHeight;
			_bg.width = sw;
			_bg.height = sh;
			_stats.y = sh - 100;
			_camera.view.width = sw;
			_camera.view.height = sh;
			_camera.render();
			_header.getChildAt(0).width = sw;
		}
		/**
		 * Collada読み込み開始
		 */
		private function startLoad():void {
			Security.loadPolicyFile(PATH_POLICY);
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onLoadCollada);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorAsset);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorAsset);
			_loader.load(new URLRequest(PATH_DIR + PATH_DAE));
		}
		private function onErrorAsset(e:ErrorEvent):void {
			_loadingTxt.text = e.text;
			_loadingTxt.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 0xFF, 0, 0);
			_isInitError = true;
		}		
		/**
		 * Colladaモデル読み込み完了時
		 * @param	e
		 */
		private function onLoadCollada(e:Event):void {
			//Colladaファイルをパース
			_parser = new ParserCollada();
			_parser.parse(new XML(_loader.data), PATH_DIR);
			
			//テクスチャ読み込み
			_mloader = new MaterialLoader();
			_mloader.addEventListener(LoaderErrorEvent.LOADER_ERROR, onErrorAsset);
			_mloader.addEventListener(LoaderProgressEvent.LOADER_PROGRESS, onProgressMaterial);
			_mloader.addEventListener(Event.COMPLETE, onCompleteMaterial);
			_mloader.load(_parser.textureMaterials, new LoaderContext(true));
		}
		private function onProgressMaterial(e:LoaderProgressEvent):void {
			if (_isInitError) return;
			var per:Number = e.totalProgress;
			_loadingTxt.text = "LOADING COLLADA MODEL ... " + int(per * 100) + "%";
		}
		/**
		 * テクスチャ読み込み完了時
		 * @param	e
		 */
		private function onCompleteMaterial(e:Event):void {
			//マテリアルの読み込みに失敗していたら処理停止
			if (_isInitError) return;
			addEventListener(Event.ENTER_FRAME, onTick);
			//黒画面からのフェードイン
			BetweenAS3.to(_camera.view, { alpha:1 }, 2, Quad.easeIn).play();
			_header.visible = true;
			_loadingTxt.visible = false;
			
			//全テクスチャのリピートをOFFにする
			for each(var tm:TextureMaterial in _parser.textureMaterials) tm.repeat = false;
			
			//天井からの光の筋
			_parser.getObjectByName("volumelight").blendMode = BlendMode.OVERLAY;
			//床
			_parser.getObjectByName("floor").blendMode = BlendMode.ADD;
			
			var totalFaceNum:int = 0;
			var cameras:Vector.<Object3D> = new Vector.<Object3D>();
			
			for each(var o:Object3D in _parser.objects) {
				if (!o.name) continue;
				_scene.addChild(o);
				if (o is Mesh) {
					var m:Mesh = o as Mesh;
					_rawTextures[m] = m.geometry.orderedFaces[0].material;
					totalFaceNum += m.geometry.orderedFaces.length;
				} else if (o.name.indexOf("Camera") != -1) {
					//カメラリストに追加
					cameras.push(o);
				}
			}
			setBSPEnabled(true);
			_info.text = "TOTAL FACES: " + totalFaceNum;
			//カメラリストを名前順にソート
			cameras.sort(function(a:Object3D, b:Object3D):int { return int(a.name > b.name) - int(a.name < b.name) } );
			
			//自動カメラの動きをBetweenAS3で設定する
			var list:Array = [];
			var leng:int = cameras.length;
			for (var i:int = 0; i < leng; i++) {
				var cf:Object3D = cameras[i];
				var ct:Object3D = cameras[(i + 1) % leng];
				var it:ITween = BetweenAS3.tween(
					_autoCamera,
					{ x:ct.x, y:ct.y, z:ct.z, rotationX:ct.rotationX, rotationY:ct.rotationY, rotationZ:ct.rotationZ },
					{ x:cf.x, y:cf.y, z:cf.z, 
						rotationX:Angle.toNearRadian(cf.rotationX, ct.rotationX),
						rotationY:Angle.toNearRadian(cf.rotationY, ct.rotationY),
						rotationZ:Angle.toNearRadian(cf.rotationZ, ct.rotationZ)
					},
					2.5,
					Quad.easeInOut
				);
				it = BetweenAS3.delay(it, 0.5, 0);
				list.push(it);
			}
			if (leng) {
				var itg:ITweenGroup = BetweenAS3.serialTweens(list);
				itg.stopOnComplete = false;
				itg.play();
			}
			
			onResize(null);
		}
		/**
		 * 毎フレーム処理
		 * @param	e
		 */
		private function onTick(e:Event):void {
			if (_cameraMode == 0) {
				//自動カメラモード
				_controller.setObjectPosXYZ(_autoCamera.x, _autoCamera.y, _autoCamera.z);
				_controller.lookAtXYZ(0, 0, 0);
				_camera.rotationX = _autoCamera.rotationX;
				_camera.rotationY = _autoCamera.rotationY;
				_camera.rotationZ = _autoCamera.rotationZ;
			} else {
				//ドラッグカメラモード
				var v:Vector3D = _dragger.position;
				_userCamera.x += (v.x - _userCamera.x) * 0.3;
				_userCamera.y += (v.z - _userCamera.y) * 0.3;
				_userCamera.z += (v.y - _userCamera.z) * 0.3;
				_controller.setObjectPosXYZ(_userCamera.x, _userCamera.y, _userCamera.z + 80);
				_controller.lookAtXYZ(0, 0, 80);
			}
			_camera.render();
		}
	}
}
import com.bit101.components.PushButton;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Vector3D;
class Angle {
	static public const PI2:Number = Math.PI * 2;
	/**
	 * baseのラジアン度をnearに一番近くなるよう再設定(+Math.PI*2/-Math.PI*2)する
	 */
	static public function toNearRadian(base:Number, near:Number):Number {
		var rad:Number = base - near;
		rad = (rad % PI2 + PI2) % PI2;
		if (rad > Math.PI) rad -= PI2;
		return rad + near;
	}
}
/**
 * シーンをマウスでぐるぐる
 */
class GlobeDragger extends EventDispatcher {
	public var zoomSpeed:Number = 1.2;
	public var rotationSpeed:Number = 1;
	public var angleSpeed:Number = 1;
	public var distanceMin:Number = NaN;
	public var distanceMax:Number = NaN;
	public var rotationMin:Number = NaN;
	public var rotationMax:Number = NaN;
	public var angleMin:Number = NaN;
	public var angleMax:Number = NaN;
	public var wheelEnabled:Boolean = false;
	
	private var _distance:Number;
	private var _rotation:Number;
	private var _angle:Number;
	private var _enabled:Boolean = true;
	private var _eventObj:InteractiveObject;
	private var _saveRotation:Number;
	private var _saveAngle:Number;
	private var _saveMousePos:Point;
	private var _position:Vector3D = new Vector3D();
	
	public var onMoveCamera:Function;
	
	public function get position():Vector3D { return _position; }
	public function get enabled():Boolean { return _enabled; }
	public function set enabled(value:Boolean):void {
		onMsUp();
		_enabled = value;
	}
	
	/**
	 * @param	obj	マウスイベントを登録する場所
	 * @param	rotation	初期の横方向角度
	 * @param	angle	初期の縦方向角度
	 * @param	distance	初期の中心点からの距離
	 */
	public function GlobeDragger(obj:InteractiveObject, rotation:Number = 0, angle:Number = 30, distance:Number = 1000) {
		_distance = distance;
		_angle = angle;
		_rotation = rotation;
		_eventObj = obj;
		_eventObj.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
		_eventObj.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
	}
	private function dispose():void {
		_eventObj.removeEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
		_eventObj.stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
		_eventObj.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
		_eventObj.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
	}
	private function onMsWheel(e:MouseEvent):void {
		if (!_enabled || !wheelEnabled) return;
		var vec:int = (e.delta < 0)? -1 : 1;
		_distance *= Math.pow(zoomSpeed, -vec);
		_distance = checkLimit(_distance, distanceMin, distanceMax);
		updatePosition();
	}
	public function dispatch():void {
		dispatchEvent(new Event(Event.CHANGE));
		if (onMoveCamera != null) onMoveCamera.apply(null, [_position]);
	}
	public function setDistanceLimit(min:Number, max:Number):void {
		distanceMin = min;
		distanceMax = max;
	}
	public function setAngleLimit(min:Number, max:Number):void {
		angleMin = min;
		angleMax = max;
	}
	public function setRotationLimit(min:Number, max:Number):void {
		rotationMin = min;
		rotationMax = max;
	}
	private function onMsDown(e:MouseEvent):void {
		if (!_enabled) return;
		_eventObj.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		_eventObj.stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
		_saveRotation = _rotation;
		_saveAngle = _angle;
		_saveMousePos = new Point(_eventObj.mouseX, _eventObj.mouseY);
	}
	private function onMsMove(e:MouseEvent):void {
		if (!_enabled) return;
		var dragOffset:Point = new Point(_eventObj.mouseX, _eventObj.mouseY).subtract(_saveMousePos);
		_rotation = _saveRotation - dragOffset.x * rotationSpeed;
		_rotation = checkLimit(_rotation, rotationMin, rotationMax);
		_angle = Math.max(-89, Math.min(89, _saveAngle + dragOffset.y * angleSpeed));
		_angle = checkLimit(_angle, angleMin, angleMax);
		updatePosition();
	}
	private function checkLimit(num:Number, min:Number, max:Number):Number {
		if (!isNaN(min) && num < min) num = min;
		if (!isNaN(max) && num > max) num = max;
		return num;
	}
	private function onMsUp(...rest):void {
		_eventObj.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		_eventObj.stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
		updatePosition();
	}
	private function updatePosition():void {
		var per:Number = Math.cos(Math.PI / 180 * _angle);
		var px:Number = Math.cos(Math.PI / 180 * _rotation) * _distance * per;
		var py:Number = Math.sin(Math.PI / 180 * _angle) * _distance;
		var pz:Number = Math.sin(Math.PI / 180 * _rotation) * _distance * per;
		_position = new Vector3D(px, py, pz)
		dispatch();
	}
}
/**
 * クリックでラベルが切り替わるボタン
 */
class SwitchButton extends PushButton {
	private var _mode:int = 0;
	private var _labels:Array = [];
	private var _switchFunc:Function;
	public function get mode():int { return _mode; }
	public function SwitchButton(parent:DisplayObjectContainer = null, x:Number = 0, y:Number = 0, labels:Array = null, clickFunc:Function = null) {
		_switchFunc = clickFunc;
		_labels = (labels == null)? [""] : labels.concat();
		if (_labels.length == 0) _labels = [""];
		super(parent, x, y, _labels[0], onClick);
	}
	public function setMode(mode:int):void {
		_mode = mode;
		label = _labels[mode];
	}
	private function onClick(e:MouseEvent):void {
		setMode(++_mode % _labels.length);
		//引数の数が足りない場合は処理を振り分ける
		if (_switchFunc != null) {
			try {
				_switchFunc.apply(null, [e, _mode]);
			} catch (error:Error) {
				try {
					_switchFunc.apply(null, [e]);
				} catch (error:Error) {
					_switchFunc.apply(null, []);
				}
			}
		}
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