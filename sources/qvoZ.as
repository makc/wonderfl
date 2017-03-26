/**
 * 初めてのBetweenAS3とMovieClip複製のテスト
 * http://level0.kayac.com/2009/02/as3duplicatemovieclip.php
 * 
 * クリックで卵がかえって、ドラッグでカメラが回転します。
 * KAYACさんのワンコとProjectNyaさんのヒヨコをお借りしてます。
 * ヒヨコは初めて見たワンコを親だと思いこみます。
 */
package  {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import net.hires.debug.*;
	import org.libspark.betweenas3.*;
	import org.libspark.betweenas3.easing.*;
	public class KawaiiWanco extends Sprite {
		private const PIYO_SWF:String = "http://www.project-nya.jp/images/flash/piyo.swf";
		private const WANCO_SWF:String = "http://swf.wonderfl.net/static/assets/checkmate05/wancoAmateur.swf";
		private const TEXTURE_IMAGE:String = "http://assets.wonderfl.net/images/related_images/e/e4/e4e4/e4e44221b4bfa16baf5be3ad03e773f2454169d2";
		private const DATA_IMAGE:String = "http://assets.wonderfl.net/images/related_images/5/50/5015/501514f0887e723d196c6df86bbfb1641518fc07";
		private const BG_IMAGE:String = "http://assets.wonderfl.net/images/related_images/f/f1/f166/f16666a5b8f9c5947a1d00f3b0f0705af317ee38";
		
		private const WANCO_MOTION:String = "StayMotion";
		
		private var _piyoClass:Class;
		private var _wancoClass:Class;
		
		private var _worldContainer:Sprite;
		private var _stageContainer:Sprite;
		private var _animalContainer:Sprite;
		private var _bg:Sprite;
		private var _farBmp:BitmapData;
		private var _farLayer:Sprite;
		
		private var _camAngle:Number = -90;
		private var _camRotation:Number = 0;
		private var _camRadian:Number;
		private var _targetRotation:Number = 0;
		private var _dragger:MouseDrag;
		
		private var _animals:Vector.<Animal>;
		private var _heightBmp:BitmapData;
		private var _effectBmp:BitmapData;
		private var _effectMap:Bitmap;
		private var _refrectBmp:BitmapData;
		private var _rippleBmp:BitmapData;
		private var _horizon:Number = 220;
		
		private var _waterTransform:ColorTransform;
		private var _waterBlur:BlurFilter;
		private var _slide:Point = new Point(10, 10);
		private var _waterCount:int = 0;
		//コンストラクタ		
		public function KawaiiWanco() {
			//Wonderfl.capture_delay(10);
			Wonderfl.disable_capture();
			stage.frameRate = 30;
			stage.quality = StageQuality.MEDIUM;
			
			transform.perspectiveProjection.fieldOfView = 45;
			transform.perspectiveProjection.projectionCenter = new Point(DISPLAY.width / 2, 100);
			
			_bg = addChild(Painter.createColorRect(1000 + DISPLAY.width, 1000 + DISPLAY.height, GROUND_COLOR)) as Sprite;
			_bg.x = _bg.y = -500;
			_farLayer = addChild(new Sprite()) as Sprite;
			_farLayer.y = _horizon;
			
			_worldContainer = addChild(new Sprite()) as Sprite;
			_stageContainer = _worldContainer.addChild(new Sprite()) as Sprite;
			_worldContainer.x = DISPLAY.width/2;
			_worldContainer.y = DISPLAY.height/2 + 120;
			_worldContainer.z = 250;
			_stageContainer.x = -MAP_SIZE/2;
			_stageContainer.z = MAP_SIZE/2;
			_stageContainer.rotationX = _camAngle;
			_stageContainer.rotationY = _camRotation;
			
			_animals = new Vector.<Animal>();
			_waterBlur = new BlurFilter(2, 2);
			_waterTransform = new ColorTransform(1, 1, 1, 0.99, 0, 0, 0, 0)
			
			addChild(new Stats());
			//素材読み込み
			var loader:ImageLoader = new ImageLoader();
			loader.addImage(PIYO_SWF, "piyo");
			loader.addImage(WANCO_SWF, "wanco");
			loader.addImage(TEXTURE_IMAGE, "texture");
			loader.addImage(DATA_IMAGE, "data");
			loader.addImage(BG_IMAGE, "forest");
			loader.load(onLoadImage, function():void { trace("error") } );
		}
		/**
		 * 画像とSWFが全部ロードできた
		 */
		private function onLoadImage():void {
			var wancoMc:MovieClip = ImageLoader.image.wanco;
			var wancoStay:MovieClip = new (wancoMc.loaderInfo.applicationDomain.getDefinition(WANCO_MOTION));
			//MovieClipの複製ができるようにコンストラクタを取得しておく
			_wancoClass = wancoStay.constructor;
			_piyoClass = MovieClip(ImageLoader.image.piyo).constructor;
			
			_heightBmp = ImageLoader.image.data;
			var ground:Bitmap = _stageContainer.addChild(new Bitmap(ImageLoader.image.texture, "auto", true)) as Bitmap;
			ground.width = ground.height = MAP_SIZE;
			
			_refrectBmp = new BitmapData(_heightBmp.width, _heightBmp.height, true, 0xFF888888);
			var refrectMap:Bitmap = _stageContainer.addChild(new Bitmap(_refrectBmp)) as Bitmap;
			refrectMap.width = refrectMap.height = MAP_SIZE;
			refrectMap.blendMode = BlendMode.OVERLAY;
			
			_effectBmp = new BitmapData(100, 100, true, 0);
			_effectMap = _stageContainer.addChild(new Bitmap(_effectBmp)) as Bitmap;
			_effectMap.width = _effectMap.height = MAP_SIZE;
			
			_animalContainer = _stageContainer.addChild(new Sprite()) as Sprite;
			_farBmp = ImageLoader.image.forest;
			
			updateBackground();
			
			_dragger = new MouseDrag(stage, _camRotation);
			_dragger.speed.x = -0.5;
			_dragger.addEventListener(MouseEvent.MOUSE_MOVE, onDragStage);
			_dragger.addEventListener(MouseEvent.MOUSE_UP, onMouseUpStage);
			
			addEventListener(Event.ENTER_FRAME, onTick);
		}
		private function onDragStage(e:MouseEvent):void {
			_targetRotation = _dragger.position.x;
		}
		private function onMouseUpStage(e:MouseEvent):void {
			if (!_dragger.isDragged) createEgg();
		}
		private function createEgg():void {
			var mx:Number = _stageContainer.mouseX;
			var my:Number = _stageContainer.mouseY;
			var dx:Number = mx - CENTER_WORLD.x;
			var dy:Number = my - CENTER_WORLD.y;
			var r:Number = RADIUS + 200;
			if (dx * dx + dy * dy > r * r) return;
			
			var egg:Egg = _animalContainer.addChild(new Egg()) as Egg;
			egg.x = mx;
			egg.y = my;
			egg.rotationX = -_camAngle;
			egg.crack(onCrushEgg);
		}
		/**
		 * 卵が割れた瞬間
		 */
		private function onCrushEgg(egg:Egg):void {
			//ワンコかヒヨコか
			var chara:Animal = (Math.random() < 0.4)? new Wanco(new _wancoClass()) : new Piyo(new _piyoClass());
			var anm:Animal = _animalContainer.addChild(chara) as Animal;
			_animalContainer.addChild(anm);
			anm.x = egg.x;
			anm.y = egg.y;
			anm.face(Math.PI / 2);
			//スプライトを起こす
			anm.rotationX = -_camAngle;
			_animals.push(anm);
			BetweenAS3.tween(anm, { scaleX:anm.scale, scaleY:anm.scale }, { scaleX:0, scaleY:0 }, 1, Elastic.easeOut).play();
		}
		/**
		 * 毎フレーム処理
		 */
		private function onTick(e:Event):void {
			var i:int, leng:int, anm:Animal, rgb:uint, sortList:Vector.<Sprite> = new Vector.<Sprite>();
			_effectBmp.lock();
			//カメラ回転
			if (_targetRotation != _camRotation) {
				_camRotation += (_targetRotation - _camRotation) * 0.2;
				if (!_dragger.isMouseDown && Math.abs(_targetRotation - _camRotation) < 0.15) _camRotation = _targetRotation;
			}
			_camRadian = _camRotation * Math.PI / 180;
			_worldContainer.rotationY = _camRotation;
			
			//ソート用配列に追加＆キャラクターをカメラに向ける
			for (i = 0; i < _animalContainer.numChildren; i++) {
				var obj:Sprite = _animalContainer.getChildAt(i) as Sprite;
				sortList.push(obj);
				obj.rotationZ = -_camRotation;
			}
			//全員の行動
			for each(anm in _animals) {
				anm.tick(_animals);
				anm.updateAngle();
				rgb = _heightBmp.getPixel(anm.x / MAP_SIZE * (_heightBmp.width - 1), anm.y / MAP_SIZE * (_heightBmp.height - 1));
				var dper:Number = (rgb & 0xFF) / 0xFF;
				var sper:Number = (rgb >> 16 & 0xFF) / 0xFF;
				anm.setDepth(dper);
				anm.setShadow(sper);
				if (dper > 0.1) _effectBmp.fillRect(new Rectangle(anm.x / MAP_SIZE * (_effectBmp.width - 1) -1, anm.y / MAP_SIZE * (_effectBmp.height - 1) - 1, 2, 2), 0xFF9AD1F1);
			}
			//重なり順をソート
			sortList.sort(sortFunc);
			leng = sortList.length;
			for (i = 0; i < leng; i++) _animalContainer.setChildIndex(sortList[i], i);
			
			//水面エフェクト
			_effectBmp.applyFilter(_effectBmp, _effectBmp.rect, ZERO, _waterBlur);
			_effectBmp.colorTransform(_effectBmp.rect, _waterTransform);
			_effectBmp.unlock();
			_waterCount = (_waterCount + 1) % 2;
			//水のアニメーション
			if (_waterCount == 0) {
				_slide.x += 0.45;
				_slide.y += 0.25;
				_refrectBmp.perlinNoise(20, 4, 1, 1234, false, true, BitmapDataChannel.BLUE + BitmapDataChannel.GREEN, true, [_slide]);
				_refrectBmp.copyChannel(_heightBmp, _heightBmp.rect, ZERO, BitmapDataChannel.BLUE, BitmapDataChannel.ALPHA);
			}
			updateBackground();
		}
		private function sortFunc(a:Sprite, b:Sprite):int {
			var az:Number = a.x * Math.sin(_camRadian) + a.y * Math.cos(_camRadian);
			var bz:Number = b.x * Math.sin(_camRadian) + b.y * Math.cos(_camRadian);
			return az - bz;
		}
		private function updateBackground():void{
			var g:Graphics = _farLayer.graphics;
			g.clear();
			var tx:Number = _camRadian / Math.PI * 2 * 750 % _farBmp.width;
			g.beginBitmapFill(_farBmp, new Matrix(1, 0, 0, 1, tx, 0));
			g.drawRect(0, -_farBmp.height, DISPLAY.width, _farBmp.height);
			g.endFill();
		}
	}
}
import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.system.*;
import flash.utils.*;
import org.libspark.betweenas3.*;
import org.libspark.betweenas3.easing.*;
import org.libspark.betweenas3.tweens.*;

const GROUND_COLOR:uint = 0x4F3E2D;
const MAP_SIZE:Number = 800;
const AREA:Number = 720;
const DISPLAY:Rectangle = new Rectangle(0, 0, 465, 465);
const ZERO:Point = new Point(0, 0);
const RADIUS:Number = AREA / 2;
const AREA2:Number = RADIUS * RADIUS;
const CENTER_WORLD:Point = new Point(MAP_SIZE/2, MAP_SIZE/2);
const CENTER_DISPLAY:Point = new Point(DISPLAY.width / 2, DISPLAY.height / 2);
/**
 * ワンコとヒヨコの元
 */
class Animal extends Sprite {
	protected var _mc:MovieClip;
	protected var _mother:Animal;
	public var px:Number = 0;
	public var py:Number = 0;
	public var scale:Number = 0.8;
	public var type:String = "";
	public var radius:Number = 20;
	public var weight:Number = 10;
	public var angle:Number = 0;
	public var rotateLimit:Number = Math.PI;
	private var _vx:Number = 0;
	private var _vy:Number = 0;
	protected var _dash:int = 0;
	private var _tweeen:ITween;
	private var _water:Sprite;
	private var _ct:ColorTransform;
	private var _targetAngle:Number = 0;
	private var _think:int = 20;
	private var _lastShadow:Number = -1;
	private var _lastDepth:Number = -1;
	private var _lastAngle:Number = NaN;
	public function Animal(target:MovieClip) {
		_ct = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
		_mc = addChild(target) as MovieClip;
		_water = addChild(new Sprite()) as Sprite;
		_water.graphics.beginFill(0, 0.8);
		_water.graphics.drawRect(-50, 0, 100, 100);
		_water.blendMode = BlendMode.ERASE;
		blendMode = BlendMode.LAYER;
		mouseEnabled = false;
		mouseChildren = false;
	}
	public function face(rad:Number):void {
		_targetAngle = rad;
		rad = Angle.changeNearRadian(rad, angle);
		if (_tweeen) _tweeen.stop();
		_tweeen = BetweenAS3.tween( this, { angle:rad }, null, 0.5, Cubic.easeOut);
		_tweeen.play();
	}
	public function updateAngle():void {
		var rad:Number = angle - rotationZ * Math.PI / 180;
		if (_lastAngle == rad) return;
		_lastAngle = rad;
		rotate(rad);
	}
	/**
	 * 毎フレーム処理
	 */
	public function tick(animals:Vector.<Animal>):void {
		var anm:Animal, dx:Number, dy:Number, rx:Number, ry:Number, vx:Number, vy:Number, rad:Number, distance:Number, movePer:Number;
		//他のキャラとの当たり判定
		for each(anm in animals) {
			if (anm === this) continue;
			dx = anm.x - x;
			dy = anm.y - y;
			vx = (dx < 0)? -1 : 1;
			vy = (dy < 0)? -1 : 1;
			distance = anm.radius + radius;
			if (dx * dx + dy * dy < distance * distance) {
				movePer = anm.weight / (anm.weight + weight);
				_vx += -vx * 2 * movePer;
				_vy += -vy * 2 * movePer;
			}
		}
		_vx *= 0.7;
		_vy *= 0.7;
		x += _vx;
		y += _vy;
		//エリアの外に出ないようにする
		rx = x - CENTER_WORLD.x;
		ry = y - CENTER_WORLD.y;
		if (rx * rx + ry * ry > AREA2) {
			rad = Math.atan2(ry, rx);
			x = Math.cos(rad) * RADIUS + CENTER_WORLD.x;
			y = Math.sin(rad) * RADIUS + CENTER_WORLD.y;
		}
		if (_dash > 0) {
			_dash--;
			if (_dash % 9 == 0) {
				_vx += Math.cos(angle) * 13;
				_vy += Math.sin(angle) * 13;
			} else {
				_vx *= 0.6;
				_vy *= 0.6;
			}
		}
		//定期的に何かする
		if (_think) {
			_think--;
			return;
		}
		_think = Math.random() * 20 + 30;
		action(animals);
	}
	public function action(animals:Vector.<Animal>):void {
		var rad:Number;
		var move:Boolean = true;
		if (_mother) {
			rad = Math.atan2(_mother.y - y, _mother.x - x);
			var dx:Number = _mother.x - x;
			var dy:Number = _mother.y - y;
			var rr:Number = _mother.radius + radius + 20;
			if (dx * dx + dy * dy < rr * rr) move = false;
		} else {
			rad = angle + (Math.random() - 0.5) * rotateLimit * 2;
		}
		face(rad);
		if (move) {
			_vx += Math.cos(rad) * 10;
			_vy += Math.sin(rad) * 10;
		}
	}
	public function setShadow(per:Number):void {
		if (per == _lastShadow) return;
		_lastShadow = per;
		_ct.blueMultiplier = _ct.redMultiplier = _ct.greenMultiplier = 1 - per * 0.5;
		_mc.transform.colorTransform = _ct;
	}
	public function setDepth(per:Number):void {
		if (per == _lastDepth) return;
		_lastDepth = per;
		_water.visible = (per > 0.1);
		_water.blendMode = (per > 0.1)? BlendMode.ERASE : BlendMode.NORMAL;
		_mc.y = per * 30;
	}
	public function rotate(radian:Number):void {
	}
}
/**
 * ワンコ
 */
class Wanco extends Animal {
	private var _body:MovieClip;
	public function Wanco(target:MovieClip) {
		super(target);
		type = "wanco";
		_body = _mc.wc2.wc3;
		rotateLimit = Math.PI * 0.7;
		rotate(Math.PI / 2);
	}
	override public function rotate(radian:Number):void {
		super.rotate(radian);
		var round:Number = Math.PI * 2;
		var total:int = _mc.wc2.wc3.totalFrames;
		var rad:Number = ((Math.PI * 0.6 - radian) % round + round) % round;
		var fm:int = Math.round(rad / round * (total)) % total + 1;
		_body.gotoAndStop(fm);
	}
	override public function action(animals:Vector.<Animal>):void {
		super.action(animals);
		if (_dash <= 0) if (Math.random() < 0.1) _dash = Math.random() * 100 + 50;
	}
}
/**
 * ヒヨコ
 */
class Piyo extends Animal {
	private var _skin:MovieClip;
	private var _mouth:MovieClip;
	private var _eyeR:MovieClip;
	private var _wingR:MovieClip;
	private var _wingL:MovieClip;
	private var _eyeL:MovieClip;
	private var _body:MovieClip;
	private var _head:MovieClip;
	private var _headSize:Number;
	public function Piyo(target:MovieClip) {
		super(target);
		type = "piyo";
		scale = 0.6;
		radius = 15;
		weight = 2;
		_headSize = _mc.piyo.head.width;
		var fill:Shape = _mc.piyo.head.getChildAt(0) as Shape;
		var line:Shape = _mc.piyo.head.getChildAt(4) as Shape;
		_skin = _mc.piyo.head.addChildAt(new MovieClip(), 0) as MovieClip;
		_skin.addChild(fill);
		_skin.addChild(line);
		_head = _mc.piyo.head;
		_mouth = _mc.piyo.head.mouth;
		_eyeL = _mc.piyo.head.eyeL;
		_wingL = _mc.piyo.wingL;
		_wingR = _mc.piyo.wingR;
		_eyeR = _mc.piyo.head.eyeR;
		_body = _mc.piyo.body;
		rotate(Math.PI / 2);
	}
	override public function action(animals:Vector.<Animal>):void {
		if (!_mother) {
			var min:Number = Number.MAX_VALUE;
			for each(var anm:Animal in animals) {
				if (anm.type != "wanco") continue;
				var dx:Number = anm.x - x;
				var dy:Number = anm.y - y;
				var dd:Number = dx * dx + dy * dy;
				if (dd < min && dd < 10000) {
					min = dd;
					_mother = anm;
				}
			}
		}
		super.action(animals);
	}
	override public function rotate(radian:Number):void {
		var i:int;
		super.rotate(radian);
		var radEyeL:Number = radian + Math.PI / 7;
		var radEyeR:Number = radian - Math.PI / 7;
		var radMouth:Number = radian;
		_eyeL.scaleX = 1 - Math.pow(Math.cos(radEyeL), 2);
		_eyeR.scaleX = 1 - Math.pow(Math.cos(radEyeR), 2);
		_mouth.scaleX = Math.max(0.5, 1 - Math.pow(Math.cos(radMouth), 2));
		_eyeL.x = Math.cos(radEyeL) * _headSize / 2;
		_eyeR.x = Math.cos(radEyeR) * _headSize / 2;
		_mouth.x = Math.cos(radMouth) * _headSize / 2;
		_skin.sort = 0;
		_mouth.sort = Math.sin(radMouth);
		_eyeL.sort = Math.sin(radEyeL);
		_eyeR.sort = Math.sin(radEyeR);
		var sortHead:Array = [_skin, _mouth, _eyeL, _eyeR];
		sortHead.sortOn("sort", Array.NUMERIC);
		for (i = 0; i < sortHead.length; i++) _head.setChildIndex(sortHead[i], i);
		var radWingL:Number = radian + Math.PI / 3;
		var radWingR:Number = radian - Math.PI / 3;
		_wingL.x = Math.cos(radWingL) * 18;
		_wingL.y = -26 + Math.sin(radWingL) * 5;
		_wingR.y = -26 + Math.sin(radWingR) * 5;
		_wingR.x = Math.cos(radWingR) * 18;
		_wingR.rotation = 25 - Math.cos(radWingR) * 30;
		_wingL.rotation = -25 - Math.cos(radWingL) * 30;
		_head.sort = 2;
		_body.sort = 0;
		_wingL.sort = Math.sin(radWingL);
		_wingR.sort = Math.sin(radWingR);
		var sortBody:Array = [_head, _body, _wingL, _wingR];
		sortBody.sortOn("sort", Array.NUMERIC);
		for (i = 0; i < sortBody.length; i++) _mc.piyo.setChildIndex(sortBody[i], i);
	}
}
/**
 * たまご
 */
class Egg extends Sprite {
	private var _egg:Sprite;
	private var _crackLine:Sprite;
	private var _maskClip:Sprite;
	private var _shadow:Sprite
	private var _size:Rectangle;
	private var _color:uint = 0xEDEDED;
	public function Egg() {
		_size = new Rectangle(0, 0, 40, 50);
		_shadow = addChild(new Sprite()) as Sprite;
		_shadow.graphics.beginFill(0x000000, 0.2);
		_shadow.graphics.drawCircle(0, 0, 15);
		_shadow.height = 10;
		_egg  = addChild(new Sprite()) as Sprite;
		_egg.graphics.lineStyle(1, 0x000000);
		_egg.graphics.beginFill(_color, 1);
		_egg.graphics.drawEllipse(-_size.width/2, -_size.height, _size.width, _size.height);
		_egg.filters = [new DropShadowFilter(5, -135, 0x000000, 0.5, 10, 10, 1, 1, true)];
		_crackLine = addChild(new Sprite()) as Sprite;
		_crackLine.graphics.lineStyle(0, 0x000000, 0.5);
		var lx:Number = 0, ly:Number = 0;
		var cmd:Vector.<int> = Vector.<int>([1]);
		var line:Vector.<Number> = Vector.<Number>([lx, ly]);
		for (var i:int = 0; i < 9; i++) {
			lx = (i % 2 * 2 - 1) * Math.random() * 5 + 2;
			ly += 6;
			cmd.push(2);
			line.push(lx, ly);
		}
		_crackLine.rotation = 90 - Math.atan2(ly, lx) * 180 / Math.PI;
		_crackLine.graphics.drawPath(cmd, line);
		_crackLine.y = -_size.height;
		_maskClip = addChild(new Sprite()) as Sprite;
		_maskClip.graphics.beginFill(0);
		_maskClip.graphics.drawRect(0, 0, _size.width, _size.height);
		_maskClip.x = -_size.width / 2;
		_maskClip.y = -_size.height;
		_maskClip.height = 0;
		_crackLine.mask = _maskClip;
	}
	/**
	 * ヒビを入れる
	 */
	public function crack(crushFunc:Function = null):void {
		BetweenAS3.serial(
			BetweenAS3.tween(_maskClip, { height:_size.height }, null, 1, Linear.linear),
			BetweenAS3.func(crush),
			BetweenAS3.func(crushFunc, [this])
		).play();
	}
	/**
	 * 卵を割る
	 */
	private function crush():void {
		_shadow.visible = false;
		_crackLine.visible = false;
		_egg.visible = false;
		for (var i:int = 0; i < 20; i++) {
			var rad:Number = Math.random() * Math.PI * 2;
			var x1:Number = Math.cos(rad) * _size.width / 4;
			var x2:Number = Math.cos(rad) * _size.width;
			var y1:Number = Math.sin(rad) * _size.height / 3 - _size.height / 2;
			var y2:Number = Math.sin(rad) * 10;
			var tx:Number = -(x1 + _size.width / 2);
			var ty:Number = -(y1 + _size.height);
			var piece:Sprite = addChild(new Sprite()) as Sprite;
			piece.graphics.lineStyle(1, 0, 0.5);
			piece.graphics.beginFill(0xFDFDFD);
			var vector:Vector.<Number> = new Vector.<Number>();
			for (var n:int = 0; n < 3; n++) {
				var rad2:Number = Math.random() * Math.PI * 2;
				vector.push(Math.cos(rad2) * 10, Math.sin(rad2) * 10);
			}
			piece.graphics.drawPath(Vector.<int>([1, 2, 2]), vector);
			BetweenAS3.parallel(
				BetweenAS3.tween(piece, { x:x2, scaleY:0.2 }, { x:x1 }, 1, Cubic.easeOut),
				BetweenAS3.tween(piece, { alpha:0 }, { alpha:1 }, 1.5, Cubic.easeInOut),
				BetweenAS3.tween(piece, { y:y2 }, { y:y1 }, Math.random() * 0.2 + 0.5, Bounce.easeOut)
			).play();
		}
		var timer:Timer = new Timer(1500, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimesUp);
		timer.start();
	}
	private function onTimesUp(e:TimerEvent):void {
		var timer:Timer = e.currentTarget as Timer;
		timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimesUp);
		parent.removeChild(this);
	}
}
/**
 * 画像とか読み込み
 */
class ImageLoader {
	static public var image:Object = new Object();
	private var _images:Array = new Array();
	private var _count:int;
	private var _completeFunc:Function;
	private var _errorFunc:Function;
	public function ImageLoader() {
	}
	public function addImage(src:String, name:String):void {
		_images.push( { src:src, name:name } );
	}
	public function load(complete:Function, error:Function = null):void {
		_count = -1;
		_completeFunc = complete;
		_errorFunc = error;
		next();
	}
	private function next():void {
		if (++_count >= _images.length) {
			if(_completeFunc != null) _completeFunc.apply(null, []);
			return;
		}
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
		loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		loader.load(new URLRequest(_images[_count].src), new LoaderContext(true));
	}
	private function onError(e:ErrorEvent):void {
		removeEvent(e.currentTarget as LoaderInfo);
		if (_errorFunc != null) _errorFunc.apply(null, []);
	}
	private function onComplete(e:Event):void {
		var info:LoaderInfo = e.currentTarget as LoaderInfo;
		removeEvent(info);
		if (info.content is Bitmap) ImageLoader.image[_images[_count].name] = Bitmap(info.content).bitmapData;
		if (info.content is MovieClip) ImageLoader.image[_images[_count].name] = info.content as MovieClip;
		next();
	}
	private function removeEvent(target:LoaderInfo):void {
		target.removeEventListener(Event.COMPLETE, onComplete);
		target.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
	}
}
class Painter {
	/**
	 * 一色塗りスプライト生成
	 */
	static public function createColorRect(width:Number, height:Number, color:uint = 0x000000, alpha:Number = 1):Sprite {
		var sp:Sprite = new Sprite();
		sp.graphics.beginFill(color, alpha);
		sp.graphics.drawRect(0, 0, width, height);
		sp.graphics.endFill();
		return sp;
	}
}
class Angle {
	static private var ROUND:Number = Math.PI * 2;
	static public function correctRound(rad:Number):Number {
		return (rad % ROUND + ROUND) % ROUND;
	}
	static public function correctPI(rad:Number):Number {
		rad = correctRound(rad);
		if (rad > Math.PI) rad -= ROUND;
		return rad;
	}
	static public function changeNearRadian(base:Number, near:Number):Number {
		return correctPI(base - near) + near;
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
	public function get isMouseDown():Boolean { return _isMouseDown; }
	public function get isDragged():Boolean { return _isDragged; }
	public function MouseDrag(target:DisplayObjectContainer, x:Number = 0, y:Number = 0) {
		position.x = x;
		position.y = y;
		_sprite = target;
		_sprite.addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
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
	private function checkDrag():void{
		var drag:Point = new Point(_sprite.mouseX, _sprite.mouseY).subtract(_saveMousePos);
		if (!_isDragged && drag.length > clickRange) _isDragged = true;
		if (_isDragged) {
			position.x = _savePosition.x + drag.x * speed.x;
			position.y = _savePosition.y + drag.y * speed.y;
			dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));
		}
	}
}