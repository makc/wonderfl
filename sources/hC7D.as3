/**
 * ツリー表示の実験中
 * 
 * （済）ホイールスクロール
 * （済）背景クリックで選択解除
 * （済）ウィンドウリサイズ
 * （済）MinimalComps0.9.5で動くように変更
 * （済）コメントにあった複数選択を付けた
 * （済）lock()unlock()でフォルダを大量に追加するのがちょっとだけ速くなった
 * （済）ルートフォルダを表示しないhideRootプロパティを作った
 * （済）コードがぐちゃぐちゃになった
 * 
 * （謎）HScrollBarがうまく使えなくてVScrollBarで代用中
 */
package {
	import com.bit101.components.*;
	import flash.display.*;
	import flash.events.*;
	
	public class FileTree extends Sprite {
		/**スタイル*/
		private var _style:TreeStyle;
		/**WindowAのルートフォルダ*/
		private var _rootA:TreeLimb;
		/**WindowBのルートフォルダ*/
		private var _rootB:TreeLimb;
		
		private var _sliders:Vector.<HUISlider>;
		private var _buttonGroupA:VBox;
		private var _buttonGroupB:VBox;
		
		public function FileTree() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//サンプルアイコンをデコードする
			var loader:IconLoader = new IconLoader();
			loader.create(onDecode);
		}
		//デコードしたアイコン画像が引数に渡される
		private function onDecode(icons:Vector.<BitmapData>):void {
			
			//TreeWindowインスタンスの生成
			var winA:TreeWindow = new TreeWindow(this, 10, 80, "WINDOW A");
			var winB:TreeWindow = new TreeWindow(this, 240, 80, "WINDOW B");
			
			//ウィンドウの大きさ変更
			winA.setWindowSize(215, 350);
			winB.setWindowSize(215, 250);
			winA.hasMinimizeButton = true;
			winB.hasMinimizeButton = true;
			winB.resizable = false;
			
			//TreeWindow.folderがルートフォルダなのでこれにファイルやフォルダを追加していく
			_rootA = winA.folder;
			_rootB = winB.folder;
			
			//イベントは全てルートフォルダで発生する
			_rootA.addEventListener(TreeLimbEvent.CHANGE_SELECT, onChangeSelectA);
			_rootB.addEventListener(TreeLimbEvent.CHANGE_SELECT, onChangeSelectB);
			
			//一度に大量のアイテムを追加する場合はルートフォルダをlock()すると少し速くなる
			_rootA.lock();
			_rootB.lock();
			
			var folder:TreeLimb =  _rootA.addFolder("Object");
			folder.addFolder("EventDispatcher").addFolders(["LoaderInfo", "DisplayObject", "URLLoader", "URLStream", "Sound", "SoundChannel"]);
			_rootA.getLimbByLabel("EventDispatcher", true)[0].addFile("etc...", 0);
			_rootA.getLimbByLabel("DisplayObject", true)[0].addFolders(["AVM1Movie", "Bitmap", "InteractiveObject", "MorphShape", "Shape", "StaticText", "Video"]);
			_rootA.getLimbByLabel("InteractiveObject", true)[0].addFolders(["DisplayObjectContainer", "SimpleButton"])[0].addFolders(["Loader", "Sprite", "Stage", "TextLine"]);
			_rootA.getLimbByLabel("Video", true)[0].addFolder("VideoPlayer");
			_rootA.getLimbByLabel("Sprite", true)[0].addFolder("MovieClip");
			
			//新しいスタイルを作ってWindowAのルートフォルダに適用する
			_style = new TreeStyle();
			_style.closeIcon = icons[0];
			_style.openIcon = icons[1];
			_style.icons = icons.slice(2, icons.length);
			_style.textFormat.size = 12;
			_style.lineSpacing = 16;
			_rootA.setStyle(_style);
			
			//WindowBにもいくつかアイテムを追加
			var sortFolder:TreeLimb = _rootB.addFile("sort test", 5);
			sortFolder.addFiles(["10", "2", "8", "3", "0", "7"]);
			//sortFolder内にあるアイテムの並びを「label」プロパティの数字の大きさでソートする
			sortFolder.sortOnChild("label", Array.NUMERIC);
			
			//WindowBのフォルダ用にWindowAのフォルダのスタイルを複製してから色を変える
			var style2:TreeStyle = _style.clone();
			style2.textFormat.color = 0x57A7D7;
			style2.selectedBoxColor = 0x888888;
			_rootB.setStyle(style2);
			
			//lock()していたら最後にunlock()して描画を更新する
			_rootA.unlock();
			_rootB.unlock();
			
			//TreeWindowを使わずにフォルダだけ作る場合（数が少ない場合はlock()しなくてもいいかも）
			var tree:TreeLimb = new TreeLimb("folder", true);
			//スタイルの適用はフォルダを追加する前でも後でも構わない
			tree.setStyle(_style.clone());
			tree.addFiles(["file1", "file2", "file3", "file4"], [1, 2, 3, 4]);
			var limb:TreeLimb = tree.getLimbAt(0);
			limb.close();
			for (var n:int = 0; n < 2; n++)　limb.addFile("data" + n);
			addChild(tree);
			tree.x = 250;
			tree.y = 345;
			
			//ボタン＆スライダ配置
			createButtons();
		}
		//ボタンやスライダを作る
		private function createButtons():void {
			_buttonGroupA = new VBox(this);
			_buttonGroupA.x = 10;
			_buttonGroupA.y = 10
			_buttonGroupA.spacing = 2;
			new PushButton(_buttonGroupA, 0, 0, "A  |> |>  B", onClickMoveA).width = 80;
			new PushButton(_buttonGroupA, 0, 0, "DELETE A", onClickDeleteA).width = 80;
			_buttonGroupA.enabled = false;
			
			_buttonGroupB = new VBox(this);
			_buttonGroupB.x = 375;
			_buttonGroupB.y = 10
			_buttonGroupB.spacing = 2;
			new PushButton(_buttonGroupB, 0, 0, "A  <| <|  B", onClickMoveB).width = 80;
			new PushButton(_buttonGroupB, 0, 0, "DELETE B", onClickDeleteB).width = 80;
			_buttonGroupB.enabled = false;
				
			//スライダ
			var vox1:VBox = new VBox(this);
			vox1.x = 100;
			vox1.y = 10;
			vox1.spacing = -5;
			_sliders = new Vector.<HUISlider>();
			var labels:Array = ["LINE SPACING", "LINE INDENT", "BUTTON SIZE", "FONT SIZE"];
			var values:Array = [_style.lineSpacing, _style.lineIndent, _style.buttonSize, _style.textFormat.size];
			var mins:Array = [0, 0, 5, 1];
			var maxes:Array = [100, 100, 27, 40];
			for (var i:int = 0; i < labels.length; i++) {
				var slider:HUISlider = new HUISlider(vox1, 0, 0, labels[i]);
				slider.minimum = mins[i];
				slider.maximum = maxes[i];
				slider.value = values[i];
				slider.addEventListener(Event.CHANGE, onChangeSlider);
				_sliders.push(slider);
			}
		}
		//Aの選択が切り替わった
		private function onChangeSelectA(e:TreeLimbEvent):void {
			_buttonGroupA.enabled = (_rootA.getSelectedLimbs().length > 0);
		}
		//Aの選択アイテムを削除
		private function onClickDeleteA(e:MouseEvent):void {
			TreeUtil.disposeLimbs(_rootA.getSelectedLimbs());
		}
		//Aの選択アイテムをBに移動
		private function onClickMoveA(e:MouseEvent):void {
			_rootB.addLimbs(_rootA.getSelectedLimbs(), true);
		}
		//Bの選択が切り替わった
		private function onChangeSelectB(e:TreeLimbEvent):void {
			_buttonGroupB.enabled = (_rootB.getSelectedLimbs().length > 0);
		}
		//Bの選択アイテムを削除
		private function onClickDeleteB(e:MouseEvent):void {
			TreeUtil.disposeLimbs(_rootB.getSelectedLimbs());
		}
		//Bの選択アイテムをAに移動
		private function onClickMoveB(e:MouseEvent):void {
			_rootA.addLimbs(_rootB.getSelectedLimbs(), true);
		}
		//スライダを動かした
		private function onChangeSlider(...arg):void {
			_style.lineSpacing = _sliders[0].value;
			_style.lineIndent = _sliders[1].value;
			_style.buttonSize = int(_sliders[2].value / 2) * 2 + 1;
			_style.textFormat.size = _sliders[3].value;
			_rootA.updateAllStyle();
		}
	}
}
import com.bit101.components.*;
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.text.*;
import flash.utils.*;
import mx.utils.*;
/**
 * このサンプルに使うアイコン画像を生成する汎用性のないクラス
 */
class IconLoader {
	private var _loader:Loader;
	private var _iconImages:Vector.<BitmapData> = new Vector.<BitmapData>();
	private var _iconData:String = "iVBORw0KGgoAAAANSUhEUgAAAGgAAAANCAMAAABy+9t6AAAAA3NCSVQICAjb4U/gAAAAe1BMVEX//////5n//wCZ///x5L7/51Dv3a+97ard3d3/zMzq1Zvo0ZJm/wDMzMzly4Tmy4Sg4G3/zACqyu3tvarcuFh+0SyZzAAzzMyrq6u+qXNts+DIo1S+mFKgkXTgfW3/ZpksmdGFhVCffDxie1h7YlhYaHvROyxtVikAAADVecskAAAACXBIWXMAAArwAAAK8AFCrDSYAAAAFnRFWHRDcmVhdGlvbiBUaW1lADA0LzI4LzEwTP2JvQAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNAay06AAAAFWSURBVDiNvdRhV4IwFMbxkRVhMwOGZGqiFTzf/xN2790dd3bqlad29oK/wn4oZzjPA4Cfx7fw10YsJ8fL5TJ9C0zn/XwqXMaiyKPJo8yjtQD6vpdydLydpq1SxEwE7ZWCczyhTsFTo2l4apQlT4225YnE9JFyuCVjpg6TQkSJ47B6cFCnQH1XQJ0Gw2sDdUp0zyXUaTG+tXz5YqFQVYHvWKkQQHEQaEfBd/RC0GoVV8CJoLrW+CRoGDTeCeo6jQ+CxpEv32yEqqrjkaDwyNRTCDv6vzgO550EnUmGQWQYRIZBZBhEhkFMEROhwKvTyvxg8hBIRoJkJEhGgmQkSEaCNjdHg0K4j4/lIv4EWufQ+t8hDxjkAYM8YJAHDPLAz5CX1de6dS7CJ8q23wwpZTFDSsX7VIj3kTStbStnoRSyqPMY8ujyGNPPI0jfDLF/e9fFD66ItNoX84d0b8+P1/QAAAAASUVORK5CYII=";
	private const _ICON_SIZE:Rectangle = new Rectangle(0, 0, 13, 13);
	private const _ICON_NUM:int = 8;
	private const _ICON_ALPHA:uint = 0x66FF00;
	private var _completeFunc:Function;
	public function IconLoader() {
		_loader = new Loader();
		_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function():void { } );
	}
	public function create(complete:Function):void {
		_completeFunc = complete;
		var b64d:Base64Decoder = new Base64Decoder();
		b64d.decode(_iconData);
		var ba:ByteArray = b64d.toByteArray();
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onDecode);
		_loader.loadBytes(ba);
	}
	private function onDecode(e:Event):void {
		var img:BitmapData = Bitmap(_loader.content).bitmapData;
		var bmp:BitmapData = new BitmapData(img.width, img.height, true);
		bmp.copyPixels(img, img.rect, new Point());
		bmp.threshold(bmp, bmp.rect, new Point(), "==", 0xFF << 24 | _ICON_ALPHA, 0x00000000);//背景色を透明化
		_iconImages.length = 0;
		for (var i:int = 0; i < _ICON_NUM; i++) {
			_iconImages[i] = new BitmapData(_ICON_SIZE.width, _ICON_SIZE.height, true);
			_iconImages[i].copyPixels(bmp, new Rectangle(_ICON_SIZE.width * i, 0, _ICON_SIZE.width, _ICON_SIZE.height), new Point());
		}
		_completeFunc(_iconImages);
		_completeFunc = null;
	}
}
//##############################################################################################################
//	以下ツリー表示クラス
//##############################################################################################################
/**
 * ツリーウィンドウクラス。
 * 初期状態でTreeLimbオブジェクトが1つ不可視モードで配置されています。
 * この見えないルートフォルダにTreeLimbオブジェクトを追加してファイルやフォルダを表示します。
 */
class TreeWindow extends Window {
	private var _workSpace:Rectangle;
	private var _container:Sprite;
	private var _resizeCorner:Sprite;
	private var _resizeIcon:BitmapData;
	private var _bg:Sprite;
	private var _folder:TreeLimb;
	private var _vscroll:VScrollBar;
	private var _hscroll:VScrollBar;
	private var _padding:Number = 10;
	private var _bgcolor:uint = 0xF9F9F9;
	private var _isFirst:Boolean = true;
	private var _lastMousePos:Point = new Point();
	private var _lastWindowSize:Rectangle = new Rectangle();
	private var _contentsRect:Rectangle = new Rectangle();
	private var _resizable:Boolean = true;
	private var _resizeMinW:Number = 50;
	private var _resizeMinH:Number = 50;
	private var _resizeMaxW:Number = NaN;
	private var _resizeMaxH:Number = NaN;
	private var _isCTRL:Boolean = false;
	private var _isSHIFT:Boolean = false;
	private var _minSize:Rectangle = new Rectangle(0, 0, 30, 20);
	private var _maxLimit:Boolean = false;
	private var _maxSize:Rectangle = new Rectangle(0, 0, -1, -1);
	/**[g]ルートフォルダ*/
	public function get folder():TreeLimb { return _folder; }
	/**[g/s]ウィンドウ背景色*/
	public function get bgcolor():uint { return _bgcolor; }
	public function set bgcolor(value:uint):void {
		_bgcolor = value;
		var ct:ColorTransform = new ColorTransform();
		ct.color = _bgcolor;
		_bg.transform.colorTransform = ct;
	}
	/**[g/s]ウィンドウがリサイズできるか*/
	public function get resizable():Boolean { return _resizable; }
	public function set resizable(value:Boolean):void {
		_resizeCorner.mouseEnabled = value;
		_resizable = value;
	}
	/**[g]リサイズ可能最小サイズ*/
	public function get minSize():Rectangle { return _minSize; }
	/**[g]リサイズ可能最大サイズ*/
	public function get maxSize():Rectangle { return _maxSize; }
	/**[g/s]リサイズの上限があるかどうか*/
	public function get maxLimit():Boolean { return _maxLimit; }
	public function set maxLimit(value:Boolean):void {
		_maxLimit = value;
		setWindowSize(width, height);
	}
	
	/**
	 * @param	parent	このウィンドウを配置する場所
	 * @param	xpos	X座標
	 * @param	ypos	Y座標
	 * @param	title	ウィンドウタイトル
	 */
	public function TreeWindow(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, title:String = "Window") {
		super(parent, xpos, ypos, title);
		_workSpace = new Rectangle();
		_bg = content.addChild(new Sprite()) as Sprite;
		var g:Graphics = _bg.graphics;
		g.clear();
		g.beginFill(_bgcolor);
		g.drawRect(0, 0, 100, 100);
		g.endFill();
		_bg.addEventListener(MouseEvent.MOUSE_DOWN, onMsDownBg);
		_resizeCorner = content.addChild(new Sprite()) as Sprite;
		_resizeIcon = new BitmapData(10, 10, true, 0);
		for (var ih:int = 0; ih <= 6; ih+= 2) {
			for (var iw:int = 0; iw < ih; iw+= 2) {
				_resizeIcon.setPixel32(_resizeIcon.width - iw - 2, ih + 2, 0xFF000000);
			}
		}
		_resizeCorner.addChild(new Bitmap(_resizeIcon));
		_resizeCorner.buttonMode = true;
		_resizeCorner.addEventListener(MouseEvent.MOUSE_DOWN, onMsDownCorner);
		if (stage) onAddedStage(null);
		addEventListener(Event.ADDED_TO_STAGE, onAddedStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemovedStage);
		addEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
		
		_container = content.addChild(new Sprite()) as Sprite;
		_folder = _container.addChild(new TreeLimb()) as TreeLimb;
		_folder.hideRoot = true;
		_folder.addEventListener(TreeLimbEvent.RESIZE, onResize);
		_vscroll = new VScrollBar(content, 0, 0, updateContentsPos);
		_hscroll = new VScrollBar(content, 0, 0, updateContentsPos);
		_hscroll.rotation = -90;
		_vscroll.lineSize = 16;
		_hscroll.lineSize = 16;
		setWindowSize(width, height);
		var rect:Rectangle = _folder.getVisibleRect();
		rect.inflate(_padding, _padding);
		var px:int = int(rect.left), py:int = int(rect.top);
		_hscroll.setSliderParams(px, px + 100, px);
		_vscroll.setSliderParams(py, py + 100, py);
		bgcolor = _bgcolor;
		
		updateScrollStatus();
	}
	/**
	 * ウィンドウのリサイズの上限を設定
	 * @param	width
	 * @param	height
	 */
	public function setMaxSize(width:Number, height:Number):void {
		_maxLimit = true;
		_maxSize.width = Math.max(30, width);
		_maxSize.height = Math.max(20, height);
		setWindowSize(width, height);
	}
	/**
	 * ウィンドウのリサイズの下限を設定
	 * @param	width
	 * @param	height
	 */
	public function setMinSize(width:Number, height:Number):void {
		_minSize.width = Math.max(30, width);
		_minSize.height = Math.max(20, height);
		setWindowSize(width, height);
	}
	private function onRemovedStage(e:Event):void {
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	private function onAddedStage(e:Event):void {
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	private function onKeyUp(e:KeyboardEvent):void {
		_isSHIFT = e.shiftKey;
		_isCTRL = e.ctrlKey;
	}
	private function onKeyDown(e:KeyboardEvent):void {
		_isSHIFT = e.shiftKey;
		_isCTRL = e.ctrlKey;
	}
	private function onMsDownCorner(e:MouseEvent):void {
		_lastMousePos.x = stage.mouseX;
		_lastMousePos.y = stage.mouseY;
		_lastWindowSize.width = width;
		_lastWindowSize.height = height;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMoveCorner);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMsUpCorner);
		stage.addEventListener(Event.MOUSE_LEAVE, onMsUpCorner);
	}
	private function onMsMoveCorner(...rest):void {
		var w:Number = Math.max(0, _lastWindowSize.width + stage.mouseX - _lastMousePos.x);
		var h:Number = Math.max(50, _lastWindowSize.height + stage.mouseY - _lastMousePos.y);
		setWindowSize(w, h);
	}
	private function onMsUpCorner(e:Event):void {
		onMsMoveCorner();
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMoveCorner);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUpCorner);
		stage.removeEventListener(Event.MOUSE_LEAVE, onMsUpCorner);
	}
	private function onMsWheel(e:MouseEvent):void {
		if (!_vscroll.enabled) return;
		var vec:int = e.delta / Math.abs(e.delta);
		_vscroll.value += vec * -30;
		updateContentsPos();
	}
	private function onMsDownBg(e:MouseEvent):void {
		if(!_isSHIFT && !_isCTRL) _folder.deselectAll();
	}
	private function updateContentsPos(...rest):void {
		_folder.x = int(_workSpace.x - _hscroll.value);
		_folder.y = int(_workSpace.y - _vscroll.value);
	}
	private function onResize(e:TreeLimbEvent):void {
		_contentsRect = e.bounds;
		_contentsRect.inflate(_padding, _padding);
		_contentsRect.top = _contentsRect.top;
		_contentsRect.bottom = _contentsRect.bottom;
		_contentsRect.left = _contentsRect.left;
		_contentsRect.right = _contentsRect.right;
		addEventListener(Event.ENTER_FRAME, intervalResize);
	}
	private function intervalResize(e:Event):void {
		removeEventListener(Event.ENTER_FRAME, intervalResize);
		updateScrollStatus();
		updateContentsPos();
		if (_contentsRect.width) _isFirst = false;
	}
	private function updateScrollStatus():void {
		var perV:Number = Math.min(2, _workSpace.height / _contentsRect.height);
		var perH:Number = Math.min(2, _workSpace.width / _contentsRect.width);
		_vscroll.enabled = (perV < 1);
		_hscroll.enabled = (perH < 1);
		if (perV < 0.1 || isNaN(perV)) perV = 0.1;
		if (perH < 0.1 || isNaN(perH)) perH = 0.1;
		_vscroll.setThumbPercent(perV);
		_hscroll.setThumbPercent(perH);
		if (!_vscroll.enabled || _isFirst) _vscroll.value = _contentsRect.top;
		if (!_hscroll.enabled || _isFirst) _hscroll.value = _contentsRect.left;
		_vscroll.setSliderParams(_contentsRect.top, _contentsRect.height - _workSpace.height - _padding, _vscroll.value);
		_hscroll.setSliderParams(_contentsRect.left, _contentsRect.width - _workSpace.width - _padding, _hscroll.value);
	}
	/**
	 * ウィンドウサイズを変更
	 * @param	幅
	 * @param	高さ
	 */
	public function setWindowSize(w:Number, h:Number):void {
		if (w < _minSize.width) w = _minSize.width;
		if (h < _minSize.height) h = _minSize.height;
		if (_maxLimit && w > _maxSize.width) w = _maxSize.width;
		if (_maxLimit && h > _maxSize.height) h = _maxSize.height;
		setSize(w, h);
		_workSpace = new Rectangle(0, 0, width - _vscroll.width, height - _titleBar.height - _hscroll.width);
		_hscroll.x = _workSpace.left;
		_hscroll.y = _workSpace.bottom + 10;
		_vscroll.x = _workSpace.right;
		_vscroll.y = _workSpace.top;
		_hscroll.height = _workSpace.width;
		_vscroll.height = _workSpace.height;
		_container.scrollRect = _workSpace;
		_bg.width = _workSpace.width;
		_bg.height = _workSpace.height;
		_resizeCorner.x = _workSpace.right;
		_resizeCorner.y = _workSpace.bottom;
		updateScrollStatus();
		updateContentsPos();
	}
	/**
	 * このウィンドウを破棄
	 */
	public function dispose():void {
		_folder.dispose();
		_resizeIcon.dispose();
		removeEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
		_bg.removeEventListener(MouseEvent.MOUSE_DOWN, onMsDownBg);
		_folder.removeEventListener(TreeLimbEvent.RESIZE, onResize);
		_resizeCorner.removeEventListener(MouseEvent.MOUSE_DOWN, onMsDownCorner);
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedStage);
		removeEventListener(Event.ADDED_TO_STAGE, onAddedStage);
	}
}
/**
 * TreeLimb関係の処理
 */
class TreeUtil {
	/**
	 * 複数のTreeLimbオブジェクトを破棄する
	 * @param	limbs
	 */
	static public function disposeLimbs(limbs:Vector.<TreeLimb>):void {
		var list:Vector.<TreeLimb> = limbs.concat();
		while (list.length) list.pop().dispose();
	}
	/**
	 * TreeLimbリストの中で親子関係のあるアイテムがあれば親だけを残して子は削除した新しい配列を返す
	 * @param	limbs
	 * @return
	 */
	static public function adjustFamily(limbs:Vector.<TreeLimb>):Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for each(var limb1:TreeLimb in limbs) {
			var isMatch:Boolean = false;
			loop: for each(var limb2:TreeLimb in limbs) {
				if (limb1 == limb2) continue;
				if (limb1.checkAncestor(limb2)) {
					isMatch = true;
					break loop;
				}
			}
			if (!isMatch) result.push(limb1);
		}
		return result;
	}
}
/**
 * ツリー表示用スタイル
 */
class TreeStyle {
	/**フォルダを開いた時の画像*/
	public var openIcon:BitmapData;
	/**フォルダを閉じた時の画像*/
	public var closeIcon:BitmapData;
	/**アイコンが無い時の画像*/
	public var noIcon:BitmapData;
	/**アイコン画像リスト*/
	public var icons:Vector.<BitmapData> = new Vector.<BitmapData>();
	/**テキストフォーマット*/
	public var textFormat:TextFormat = new TextFormat("_sans", 14, 0x000000);
	public var selectedBoxColor:uint = 0x4CA4D8;
	public var selectedLabelColor:uint = 0xFFFFFF;
	/**破線画像（縦）*/
	public var dotV:BitmapData;
	/**破線画像（横）*/
	public var dotH:BitmapData;
	/**フォルダ開閉ボタンのサイズ（奇数値推奨）*/
	public var buttonSize:Number = 11;
	/**行間*/
	public var lineSpacing:Number = 20;
	/**横線の長さ*/
	public var lineIndent:Number = 14;
	/**ラベルの位置*/
	public var labelOffset:Point = new Point(10, 0);
	public var treeOffset:Point = new Point(8, 8);
	public function TreeStyle():void {
		dotV = new BitmapData(1, 2, true, 0);
		dotV.setPixel32(0, 0, 0xFF000000);
		dotH = new BitmapData(2, 1, true, 0);
		dotH.setPixel32(0, 0, 0xFF000000);
		noIcon = new BitmapData(3, 3, false, 0xFF000000);
		openIcon = new BitmapData(7, 7, false, 0xFF000000);
		openIcon.fillRect(new Rectangle(1, 1, 5, 5), 0xFFFFFFFF);
		closeIcon = openIcon.clone();
		closeIcon.fillRect(new Rectangle(2, 2, 3, 3), 0xFF000000);
	}
	/**
	 * 複製
	 */
	public function clone():TreeStyle {
		var newStyle:TreeStyle = new TreeStyle();
		for each(var v:XML in describeType(this).variable) {
			if (v.@type.indexOf("Vector") != -1) for each(var bd:BitmapData in this[v.@name]) newStyle.icons.push(bd.clone());
			else if (v.@type.indexOf("BitmapData") != -1) newStyle[v.@name] = this[v.@name].clone();
			else if (v.@type.indexOf("TextFormat") == -1) newStyle[v.@name] = this[v.@name];
		}
		var ba:ByteArray = new ByteArray();
		ba.writeObject(textFormat);
		ba.position = 0;
		var obj:Object = ba.readObject();
		for (var k:String in obj) newStyle.textFormat[k] = obj[k];
		return newStyle;
	}
}
/**
 * ツリーアイテムクラス。
 * ファイルやフォルダにあたるクラスです。
 */
class TreeLimb extends Sprite {
	private var _itemContainer:Sprite;
	private var _switchContainer:Sprite;
	private var _openSprite:Sprite;
	private var _closeSprite:Sprite;
	private var _iconSprite:Sprite;
	private var _openIcon:Bitmap;
	private var _closeIcon:Bitmap;
	private var _labelText:TextField;
	private var _limbs:Sprite;
	private var _lineV:Sprite;
	private var _lineH:Sprite;
	private var _selectBox:Sprite;
	
	private var _extra:*;
	private var _icon:int;
	private var _label:String;
	private var _isFolder:Boolean;
	private var _isOpen:Boolean = true;
	private var _selected:Boolean = false;
	private var _multiSelect:Boolean = true;
	private var _selectable:Boolean = true;
	private var _closable:Boolean = true;
	private var _hideRoot:Boolean = false;
	private var _isRoot:Boolean = true;
	private var _style:TreeStyle;
	
	private var _parentLimb:TreeLimb;
	private var _rootLimb:TreeLimb;
	private var _selectedItems:Vector.<TreeLimb>;	//[root専用]	選択されているアイテムリスト
	
	private var _lastParent:DisplayObjectContainer;
	private var _lastLineVisible:Boolean = true;	//最新の横線表示状況
	private var _lastBounds:Rectangle;	//最新の自分の子を含む矩形サイズ
	private var _lastVisibleCount:int = 1;	//最新の見えているフォルダ数
	private var _lastIcon:int = -4;	//最新のアイコン番号
	
	private var _isUpdateStyleOnce:Boolean = false;
	private var _isUpdatedOnce:Boolean = false;
	private var _isAdding:Boolean = false;	//addLimb()等で追加されたオブジェクトか
	private var _isGhost:Boolean = false;	//既に破棄されたアイテムか
	private var _isDirtyChild:Boolean = true;	//自分の子も更新対象にするか
	private var _isDirtyVisibleCount:Boolean = true;	//見えているフォルダの数が変化した
	private var _isShiftKey:Boolean = false;	//[root専用]
	private var _isCtrlKey:Boolean = false;	//[root専用]
	private var _lastClickItem:TreeLimb;	//[root専用]最後にクリックしたアイテム
	private var _isLock:Boolean;	//[root専用]表示の更新を無効にする
	private var _isNewStyle:Boolean = false;	//スタイルが新しくなった
	
	/**[g/s]ユーザーデータ*/
	public function get extra():* { return _extra; }
	public function set extra(value:*):void { _extra = value; }
	/**[g/s]ラベルテキスト*/
	public function get label():String { return _label; }
	public function set label(value:String):void { _labelText.text = _label = value; updateLabel(); }
	/**[g/s]フォルダアイコンを使うか*/
	public function get isFolder():Boolean { return _isFolder; }
	public function set isFolder(value:Boolean):void { _isFolder = value; updateIcon(); }
	/**[g/s]ファイルアイコンの種類（isFolder=trueで無効、-1でアイコン無し）*/
	public function get icon():int { return _icon; }
	public function set icon(value:int):void { _icon = value; updateStyle(); }
	/**[g/s]自分が選択されているか*/
	public function get selected():Boolean { return _selected; }
	public function set selected(value:Boolean):void { setSelect(value, true); }
	/**[g/s]サブフォルダを開いているか*/
	public function get isOpen():Boolean { return _isOpen; }
	public function set isOpen(value:Boolean):void { setOpen(value); }
	/**[g]ルートフォルダ*/
	public function get rootLimb():TreeLimb { return _rootLimb; }
	/**[g]親のTreeLimbオブジェクト*/
	public function get parentLimb():TreeLimb { return _parentLimb; }
	/**[q]自分がルートフォルダか*/
	public function get isRoot():Boolean { return _isRoot; }
	/**[g]スタイル*/
	public function get style():TreeStyle { return _style; }
	/**[q]子の数*/
	public function get numChildLimb():int { return _limbs.numChildren; }
	/**[g/s][root専用]マウス操作で複数選択が可能か*/
	public function get multiSelect():Boolean { return _rootLimb._multiSelect; }
	public function set multiSelect(value:Boolean):void { _rootLimb._multiSelect = value; }
	/**[g/s][root専用]マウス操作で選択が可能か*/
	public function get selectable():Boolean { return _rootLimb._selectable; }
	public function set selectable(value:Boolean):void { _rootLimb._selectable = value; }
	/**[g/s][root専用]ルートフォルダを隠して複数ルートフォルダがあるように見せる*/
	public function get hideRoot():Boolean { return _rootLimb._hideRoot; }
	public function set hideRoot(value:Boolean):void { _rootLimb._hideRoot = value; }
	/**[g/s][root専用]マウス操作でフォルダの開閉を弄れるか*/
	public function get closable():Boolean { return _rootLimb._closable; }
	public function set closable(value:Boolean):void { _rootLimb._closable = value; }
	
	/**
	 * @param	label	ラベルテキスト
	 * @param	isFolder	フォルダアイコンを使うか
	 * @param	icon	ファイルアイコンの種類（isFolder=trueで無効、-1でアイコン無し）
	 * @param	extra	ユーザーデータ
	 */
	public function TreeLimb(label:String = "New Item", isFolder:Boolean = true, icon:int = 0, extra:* = null) {
		_style = new TreeStyle();
		_selectedItems = new Vector.<TreeLimb>();
		_lineV = addChild(new Sprite()) as Sprite;
		_lineH = addChild(new Sprite()) as Sprite;
		_itemContainer = addChild(new Sprite()) as Sprite;
		_selectBox = _itemContainer.addChild(new Sprite()) as Sprite;
		_selectBox.graphics.beginFill(0xBE9852, 1);
		_selectBox.graphics.drawRect(0, 0, 100, 10);
		_switchContainer = _itemContainer.addChild(new Sprite()) as Sprite;
		_openSprite = _switchContainer.addChild(new Sprite()) as Sprite;
		_closeSprite = _switchContainer.addChild(new Sprite()) as Sprite;
		_closeSprite.mouseEnabled = false;
		_openSprite.addEventListener(MouseEvent.CLICK, onClickOpen);
		_openSprite.buttonMode = true;
		_iconSprite = _itemContainer.addChild(new Sprite()) as Sprite;
		_labelText = _itemContainer.addChild(new TextField()) as TextField;
		_labelText.autoSize = TextFieldAutoSize.LEFT;
		_labelText.selectable = false;
		_limbs = addChild(new Sprite()) as Sprite;
		_iconSprite.buttonMode = _selectBox.buttonMode = true;
		_iconSprite.doubleClickEnabled = _selectBox.doubleClickEnabled = true;
		_iconSprite.addEventListener(MouseEvent.CLICK, onClickItem);
		_iconSprite.addEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
		_selectBox.addEventListener(MouseEvent.CLICK, onClickItem);
		_selectBox.addEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
		_label = label;
		_labelText.text = _label;
		_labelText.mouseEnabled = false;
		_isFolder = isFolder;
		_icon = icon;
		_extra = extra;
		checkRoot(true);
		addEventListener(Event.ADDED, onAdded);
		addEventListener(Event.ADDED_TO_STAGE, onAddedStage);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemoveStage);
	}
	private function onRemoveStage(e:Event):void {
		if (this === _rootLimb._lastClickItem) {
			_rootLimb._lastClickItem = null;
		}
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyUpDown);
		stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUpDown);
	}
	private function onAddedStage(e:Event):void {
		if (_isRoot) {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyUpDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpDown);
		}
	}
	private function onKeyUpDown(e:KeyboardEvent):void {
		_isShiftKey = e.shiftKey;
		_isCtrlKey = e.ctrlKey;
	}
	private function onAdded(e:Event):void {
		if (!checkRoot()) return;
		//addLimb系メソッドを使わずaddChildしている時
		if (!_isAdding) updateOnce();
	}
	private function onClickOpen(e:MouseEvent):void {
		setOpen(!_isOpen);
	}
	private function onClickItem(e:MouseEvent):void {
		clickItem();
		_rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.CHANGE_SELECT, this));
		_rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.CLICK_ITEM, this));
	}
	private function clickItem():void {
		if (_rootLimb._selectable) {
			//何か選択している状態で、前回と同じ階層で、SHIFTを押している場合
			if (_rootLimb._multiSelect && _parentLimb && _rootLimb._lastClickItem != null && _rootLimb._isShiftKey && _rootLimb._lastClickItem.parent == parent) {
				var index1:int = _rootLimb._lastClickItem.getIndex();
				var index2:int = getIndex();
				if (index1 > index2) {
					var tmp:int = index2;
					index2 = index1;
					index1 = tmp;
				}
				if (!_rootLimb._isCtrlKey) deselectAll(false);
				for (var i:int = index1; i <= index2; i++) {
					_parentLimb.getLimbAt(i).setSelect(true, true, false);
				}
			} else {
				//CTRLを押していたら選択のONOFF切り替え。そうでなければONにする。
				if (_rootLimb._isCtrlKey && (_selected || _rootLimb._multiSelect)) {
					setSelect(!_selected, true, false);
				} else setSelect(true, false, false);
				_rootLimb._lastClickItem = this;
			}
		}
	}
	private function onWclickIcon(e:MouseEvent):void {
		clickItem();
		if (_rootLimb._closable) setOpen(!_isOpen);
		_rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.WCLICK_ITEM, this));
	}
	private function getRoot():TreeLimb {
		return (_parentLimb == null)? this : _parentLimb.getRoot();
	}
	/**
	 * 親が変化している場合はルートを再設定する
	 * @param	exe	trueにすると親が変化したかに関わらずルートを再設定する
	 * @return	親が変化していたらtrue
	 */
	private function checkRoot(exe:Boolean = false):Boolean {
		if (parent === _lastParent && !exe) return false;
		_lastParent = parent;
		_parentLimb = (parent == null || parent.parent == null)? null : parent.parent as TreeLimb;
		_rootLimb = getRoot();
		_isRoot = _rootLimb === this;
		for each(var l:TreeLimb in getChildLimbs()) l.checkRoot(true);
		return true;
	}
	/**
	 * 繋がっているアイテムの全ての選択を解除
	 * @param	dispatch	CHANGE_SELECTイベントを発生させるか
	 */
	public function deselectAll(dispatch:Boolean = true):void {
		while(_rootLimb._selectedItems.length) _rootLimb._selectedItems[0].setSelect(false, false, false);
		if (dispatch) _rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.CHANGE_SELECT, this));
	}
	/**
	 * 自分を選択/解除
	 * @param	selected	選択するかどうか
	 * @param	multiSelect	trueで追加選択モード。falseで他に選択しているものがあれば解除される。
	 * @param	dispatch	CHANGE_SELECTイベントを発生させるか
	 */
	public function setSelect(selected:Boolean = true, multiSelect:Boolean = false, dispatch:Boolean = true):void {
		if (selected && !multiSelect) deselectAll(false);
		_selected = selected;
		var index:int = _rootLimb._selectedItems.indexOf(this);
		if (_selected && index == -1) _rootLimb._selectedItems.push(this);
		if (!_selected && index != -1) _rootLimb._selectedItems.splice(index, 1);
		updateSelect();
		if (dispatch) _rootLimb.dispatchEvent(new TreeLimbEvent(TreeLimbEvent.CHANGE_SELECT, this));
	}
	/**
	 * フォルダの開閉
	 * @param	isOpen	開くかどうか
	 * @param	subLimbs	サブフォルダ以下も開閉するか
	 */
	public function setOpen(isOpen:Boolean = true, subLimbs:Boolean = false):void {
		_isOpen = isOpen;
		if (subLimbs) for each(var l:TreeLimb in getChildLimbs(true)) l.setOpen(isOpen, subLimbs);
		updateDirty();
	}
	/**
	 * フォルダを開く
	 */
	public function open():void {
		setOpen(true);
	}
	/**
	 * フォルダを閉じる
	 */
	public function close():void {
		setOpen(false);
	}
	/**
	 * 選択されている全てのアイテムを取得
	 */
	public function getSelectedLimbs():Vector.<TreeLimb> {
		return _rootLimb._selectedItems.sort(sortFunc);
	}
	private function sortFunc(a:TreeLimb, b:TreeLimb):int {
		return a.getIndex() - b.getIndex();
	}
	/**
	 * 自分のインデックス位置を取得
	 * @return
	 */
	public function getIndex():int {
		return (!parent)? 0 : parent.getChildIndex(this);
	}
	/**
	 * 全ての親を取得する（親に親がいたらそれも取得）
	 * @return
	 */
	public function getParentLimbs():Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		if (!isRoot) {
			result.push(_parentLimb);
			result = result.concat(_parentLimb.getParentLimbs());
		}
		return result;
	}
	/**
	 * 自分の表示状態に位置が影響される全てのアイテムを取得する
	 * @return
	 */
	private function getUpdateLimbs():Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		if (_isRoot) result.push(this);
		if (_parentLimb) {
			var leng:int = _parentLimb.numChildLimb;
			for (var i:int = getIndex(); i < leng; i++) result.push(_parentLimb.getLimbAt(i) as TreeLimb);
			result = result.concat(_parentLimb.getUpdateLimbs());
		}
		return result;
	}
	/**
	 * 自分の子のリストを取得
	 * @param	subLimbs	孫以降も取得するか
	 * @param	addMe	自分も含めるか
	 * @return
	 */
	public function getChildLimbs(subLimbs:Boolean = false, addMe:Boolean = false):Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		var leng:int = numChildLimb;
		for (var i:int = 0; i < leng; i++) {
			var limb:TreeLimb = getLimbAt(i);
			result.push(limb);
			if (subLimbs) result = result.concat(limb.getChildLimbs(subLimbs));
		}
		if (addMe) result.push(this);
		return result;
	}
	/**
	 * ユーザーデータが一致する全ての子を取得
	 * @param	extra
	 * @param	subLimbs	孫以降も検索するか
	 * @return
	 */
	public function getLimbByExtra(extra:*, subLimbs:Boolean = true):Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for each(var limb:TreeLimb in getChildLimbs(subLimbs)) if (limb.extra === extra) result.push(limb);
		return result;
	}
	/**
	 * ラベル名が一致する全ての子を取得
	 * @param	label
	 * @param	subLimbs	孫以降も検索するか
	 * @return
	 */
	public function getLimbByLabel(label:String, subLimbs:Boolean = true):Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for each(var limb:TreeLimb in getChildLimbs(subLimbs)) if (limb._label == label) result.push(limb);
		return result;
	}
	/**
	 * 指定インデックスの子を取得
	 * @param	index
	 * @return
	 */
	public function getLimbAt(index:int):TreeLimb {
		return (index < 0 || index >= numChildLimb)? null : _limbs.getChildAt(index) as TreeLimb;
	}
	/**
	 * TreeLimbオブジェクトを子に追加
	 * @param	limb
	 * @return
	 */
	public function addLimb(limb:TreeLimb):TreeLimb {
		return addLimbAt(limb, numChildLimb);
	}
	/**
	 * 複数のTreeLimbオブジェクトを子に追加
	 * @param	limbs	追加するTreeLimbオブジェクトの配列
	 * @param	checkOverlap	配列内で親子関係のあるアイテムがあった場合、親だけを追加して親子関係が崩れないようにする
	 * @return	追加した分のTreeLimbリスト
	 */
	public function addLimbs(limbs:Vector.<TreeLimb>, checkOverlap:Boolean = true):Vector.<TreeLimb> {
		var list:Vector.<TreeLimb>;
		if (checkOverlap) list = TreeUtil.adjustFamily(limbs);
		else list = limbs.concat();
		while (list.length) addLimb(list.shift());
		return limbs;
	}
	/**
	 * TreeLimbオブジェクトを指定インデックスに子に追加
	 * @param	limb
	 * @param	index
	 * @return
	 */
	public function addLimbAt(limb:TreeLimb, index:int = -1):TreeLimb {
		for each(var l:TreeLimb in limb.getChildLimbs(true, true)) if(l.selected) l.setSelect(false);
		limb._isAdding = true;
		if (limb._parentLimb === this) limb.parent.removeChild(limb);
		if (index > numChildLimb || index < 0) index = numChildLimb;
		if (limb.parent != null) limb.remove();
		_limbs.addChildAt(limb, index);
		limb.newStyle(_style, true);
		limb.updateDirty();
		if (_hideRoot && _rootLimb.numChildLimb > 0) _rootLimb.getLimbAt(0).checkShowLine();
		else _rootLimb.checkShowLine();
		limb.update();
		limb._isAdding = false;
		return limb;
	}
	/**
	 * ファイルを子に追加
	 * @param	label
	 * @param	icon
	 * @param	extra
	 * @return
	 */
	public function addFile(label:String = "", icon:int = 0, extra:* = null):TreeLimb {
		return addLimb(new TreeLimb(label, false, icon, extra));
	}
	/**
	 * 複数のファイルを子に追加
	 * @param	labels
	 * @param	icons
	 * @param	extras
	 * @return
	 */
	public function addFiles(labels:Array, icons:Array = null, extras:Array = null):Vector.<TreeLimb> {
		if (icons == null) icons = new Array();
		if (extras == null) extras = new Array();
		while (icons.length < labels.length) icons.push(0);
		while (extras.length < labels.length) extras.push(null);
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for (var i:int = 0; i < labels.length; i++) result.push(addFile(labels[i], icons[i], extras[i]));
		return result;
	}
	/**
	 * フォルダを子に追加
	 * @param	label
	 * @param	extra
	 * @return
	 */
	public function addFolder(label:String = "", extra:* = null):TreeLimb {
		return addLimb(new TreeLimb(label, true, 0, extra));
	}
	/**
	 * 複数のフォルダを子に追加
	 * @param	labels
	 * @param	extras
	 * @return
	 */
	public function addFolders(labels:Array, extras:Array = null):Vector.<TreeLimb> {
		if (extras == null) extras = new Array();
		while (extras.length < labels.length) extras.push(null);
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for (var i:int = 0; i < labels.length; i++) result.push(addFolder(labels[i], extras[i]));
		return result;
	}
	/**
	 * TreeLimbオブジェクトを自分から切り離す
	 * @param	limb
	 * @return
	 */
	public function removeChildLimb(limb:TreeLimb):Boolean {
		for each(var l:TreeLimb in getChildLimbs(true, true)) if (l === limb) { l.remove(); return true; }
		return false;
	}
	/**
	 * 複数のTreeLimbオブジェクトを子から切り離す
	 * @param	limbs
	 * @return
	 */
	public function removeChildLimbs(limbs:Vector.<TreeLimb>):int {
		var count:int = 0;
		for each(var l:TreeLimb in limbs) count += int(l.removeChildLimb(l));
		return count;
	}
	/**
	 * 内部データを破棄する
	 * @param	subLimbs
	 */
	private function destroyData(subLimbs:Boolean = true):void {
		removeAllListeners();
		_extra = null;
		_selected = false;
		_isGhost = true;
		_selectedItems.length = 0;
		_lastClickItem = null;
		if(subLimbs) for each(var l:TreeLimb in getChildLimbs()) l.destroyData(true);
	}
	/**
	 * 自分を破棄する
	 * @param	subLimbs
	 */
	public function dispose(subLimbs:Boolean = true):void {
		remove();
		destroyData(subLimbs);
	}
	/**
	 * 自分を親から切り離す
	 * @return
	 */
	public function remove():Boolean {
		for each(var l:TreeLimb in getChildLimbs(true, true)) if(l.selected) l.setSelect(false);
		if (parent == null) return false;
		parent.removeChild(this);
		if (!isRoot && !_rootLimb._isGhost) updateDirty();
		checkRoot(true);
		return true;
	}
	/**
	 * 内部イベントリスナを全て削除
	 */
	public function removeAllListeners():void {
		removeEventListener(Event.ADDED, onAdded);
		removeEventListener(Event.ADDED_TO_STAGE, onAddedStage);
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveStage);
		_iconSprite.removeEventListener(MouseEvent.CLICK, onClickItem);
		_iconSprite.removeEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
		_selectBox.removeEventListener(MouseEvent.CLICK, onClickItem);
		_selectBox.removeEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
		_openSprite.removeEventListener(MouseEvent.CLICK, onClickOpen);
	}
	/**
	 * 自分の子をソートして再配置(Array.sortOn()と同じ)
	 * @param	names
	 * @param	options
	 */
	public function sortOnChild(names:String, options:Object = null):void {
		var list:Array = new Array();
		for each(var l:TreeLimb in getChildLimbs()) list.push(l);
		list.sortOn(names, options);
		var sortedLimbs:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for each(var limb:TreeLimb in list) sortedLimbs.push(limb);
		addLimbs(sortedLimbs);
	}
	/**
	 * 繋がった全てのアイテムの表示の更新を無効にする
	 */
	public function lock():void {
		_rootLimb._isLock = true;
	}
	/**
	 * 繋がった全てのアイテムの表示の更新を有効にする
	 */
	public function unlock():void {
		if (!_rootLimb._isLock) return;
		_rootLimb._isLock = false;
		_rootLimb.newStyle(_rootLimb._style, true);
	}
	/**
	 * 繋がった全てのアイテムにスタイルを適用
	 * @param	style	スタイル
	 */
	public function setStyle(style:TreeStyle):void {
		_rootLimb.newStyle(style, true);
	}
	/**
	 * 繋がった全てのアイテムのスタイルを更新
	 */
	public function updateAllStyle():void {
		setStyle(_style);
	}
	/**
	 * スタイルを適用する
	 * @param	style	スタイル
	 * @param	subLimbs	サブフォルダ以下も適用するか
	 */
	private function newStyle(style:TreeStyle, subLimbs:Boolean = true):void {
		_style = style;
		_isNewStyle = true;
		updateStyle();
		updateSelect();
		if (subLimbs) for each(var l:TreeLimb in getChildLimbs()) l.newStyle(_style, subLimbs);
		update();
	}
	/**
	 * 選択状況の見た目を更新する
	 */
	private function updateSelect():void {
		if (_rootLimb._isLock) return;
		_labelText.textColor = (_selected)? _style.selectedLabelColor : uint(_style.textFormat.color);
		_selectBox.alpha = int(_selected);
	}
	/**
	 * 変化したものだけ表示を更新する
	 */
	private function updateDirty():void {
		if (_rootLimb._isLock) return;
		_isDirtyVisibleCount = true;
		for each(var tl1:TreeLimb in getParentLimbs()) tl1._isDirtyVisibleCount = true;
		for each(var tl2:TreeLimb in getUpdateLimbs()) {
			tl2._isDirtyChild = false;
			tl2.update(true);
		}
	}
	/**
	 * 初回のみ表示を更新する
	 */
	private function updateOnce():void {
		if (_isUpdatedOnce) return;
		_isUpdatedOnce = true;
		updateStyleOnce();
		update();
	}
	/**
	 * 表示を更新する
	 * @param	subLimbs	サブフォルダ以下も更新する
	 */
	private function update(subLimbs:Boolean = true):void {
		if (_rootLimb._isLock) return;
		updateStyleOnce();
		checkShowLine();
		var lineHeight:Number = 0;
		var heightList:Array = new Array();
		var numChild:int = numChildLimb;
		if (_isOpen && subLimbs) {
			var nextY:Number = 0;
			for (var i:int = 0; i < numChild; i++ ) {
				var limb:TreeLimb = _limbs.getChildAt(i) as TreeLimb;
				limb.x = 0;
				limb.y = nextY;
				if (_isDirtyChild) limb.update(subLimbs);
				nextY += heightList[heightList.push(limb.getVisibleCount() * _style.lineSpacing) - 1];
			}
			heightList.forEach(function(...arg):void {
				lineHeight += (arg[1] == heightList.length - 1)? _style.lineSpacing : arg[0];
			});
		}
		//ルートを隠すモードの場合は縦線の高さを調整
		if (_isRoot && _hideRoot && numChild > 0) lineHeight -= _style.lineSpacing;
		updateIcon();
		_limbs.visible = _isOpen;
		_openSprite.visible = (numChildLimb > 0);
		_closeSprite.visible = _openSprite.visible && !_isOpen;
		_lineV.graphics.clear();
		_lineV.graphics.beginBitmapFill(_style.dotV);
		_lineV.graphics.drawRect(0, 0, 1, lineHeight);
		_lineV.graphics.endFill();
		
		if (_isRoot) {
			var rect:Rectangle = getVisibleRect();
			if (_lastBounds == null || !rect.equals(_lastBounds)) {
				var event:TreeLimbEvent = new TreeLimbEvent(TreeLimbEvent.RESIZE, this);
				event.bounds = rect.clone();
				dispatchEvent(event);
				_lastBounds = rect;
			}
		}
		_isDirtyChild = false;
	}
	/**
	 * 一度だけスタイルを更新
	 */
	private function updateStyleOnce():void{
		if (_isUpdateStyleOnce) return;
		_isUpdateStyleOnce = true;
		updateStyle();
	}
	/**
	 * ラベル表示を更新する
	 */
	private function updateLabel():void {
		if (_rootLimb._isLock) return;
		_labelText.setTextFormat(_style.textFormat);
		_selectBox.width = _labelText.textWidth + 4;
		_selectBox.height = _labelText.textHeight;
		updateSelect();
	}
	/**
	 * 横線を表示するかチェックして、前回と違ったらスタイルを更新
	 */
	private function checkShowLine():void {
		var hideMe:Boolean = _hideRoot && _isRoot;
		var hideSub:Boolean = _rootLimb._hideRoot && _parentLimb === _rootLimb && numChildLimb == 0 && _parentLimb.numChildLimb == 1;
		var showLine:Boolean = !(_isRoot && numChildLimb == 0) && !(hideMe || hideSub);
		if (showLine != _lastLineVisible) {
			_lastLineVisible = showLine;
			updateStyle();
		}
	}
	/**
	 * スタイルに関連する表示を更新する
	 */
	private function updateStyle():void {
		if (_rootLimb._isLock) return;
		updateLabel();
		var showLine:Boolean = _lastLineVisible;
		var cornerX:int = _style.treeOffset.x + (int(_style.buttonSize / 2) + _style.lineIndent) * int(showLine);
		_iconSprite.x = cornerX;
		_iconSprite.y = _style.treeOffset.y;
		updateIcon();
		_lineV.x = cornerX;
		_lineH.x = _style.treeOffset.x;
		_lineV.y = _lineH.y = _style.treeOffset.y;
		_lineH.graphics.clear();
		if (showLine) {
			_lineH.graphics.beginBitmapFill(_style.dotH);
			_lineH.graphics.drawRect(0, 0, int(_style.buttonSize / 2) + _style.lineIndent, 1);
		}
		var boxw:Number = _style.buttonSize, thick:Number = 1, linew:Number = Math.max(3, boxw - thick * 2 - 4), lineh:Number = 1;
		_openSprite.graphics.clear();
		for each(var draw:Array in [[0, 0, 0, boxw, boxw], [1, thick, thick, boxw - thick * 2, boxw - thick * 2], [0, (boxw - linew) / 2, (boxw - lineh) / 2, linew, lineh]]) {
			_openSprite.graphics.beginFill(draw.shift() * 0xFFFFFF);
			_openSprite.graphics.drawRect.apply(null, draw);
		}
		_closeSprite.graphics.clear();
		_closeSprite.graphics.beginFill(0);
		_closeSprite.graphics.drawRect((boxw - lineh) / 2, (boxw - linew) / 2, lineh, linew);
		_switchContainer.x = _style.treeOffset.x - (_style.buttonSize-1) / 2;
		_switchContainer.y = _style.treeOffset.y - (_style.buttonSize-1) / 2;
		_labelText.x = cornerX + _style.labelOffset.x;
		_labelText.y = _style.treeOffset.y - _labelText.textHeight / 2 - 2  + _style.labelOffset.y;
		_selectBox.x = _labelText.x;
		_selectBox.y = _labelText.y + 3;
		var ct:ColorTransform = new ColorTransform();
		ct.color = _style.selectedBoxColor;
		ct.alphaMultiplier = _selectBox.alpha;
		_selectBox.transform.colorTransform = ct;
		_limbs.x = (_hideRoot)? 0 : cornerX - _style.treeOffset.x;
		_limbs.y = (_hideRoot)? 0 : _style.lineSpacing;
		
		var hideMe:Boolean = _hideRoot && _isRoot;
		_selectBox.visible = _labelText.visible = _iconSprite.visible = !hideMe;
		_switchContainer.visible = _rootLimb._closable && !hideMe;
	}
	/**
	 * アイコン表示更新
	 */
	private function updateIcon():void {
		var type:int = (_isFolder)? (_isOpen && numChildLimb)? -3 : -2 : _icon;
		if (type == _lastIcon && !_isNewStyle) return;
		_lastIcon = type;
		_isNewStyle = false;
		while (_iconSprite.numChildren) _iconSprite.removeChildAt(0);
		var bmd:BitmapData;
		if (type == -3) bmd = _style.openIcon;
		else if (type == -2) bmd = _style.closeIcon;
		else if (_style.icons.length <= _icon || _icon < 0) bmd = _style.noIcon;
		else bmd = _style.icons[type];
		var bmp:Bitmap = new Bitmap(bmd);
		_iconSprite.addChild(bmp);
		bmp.x =  -int(bmp.width / 2);
		bmp.y =  -int(bmp.height / 2);
	}
	/**
	 * 指定のTreeLimbがこのTreeLimbオブジェクトの祖先かどうかをチェック
	 * @param	limb
	 * @return
	 */
	public function checkAncestor(limb:TreeLimb):Boolean {
		var target:TreeLimb = _parentLimb;
		while (target) {
			if (target === limb) return true;
			target = target._parentLimb;
		}
		return false;
	}
	/**
	 * 自分より下の階層の矩形サイズを取得する
	 * @return
	 */
	public function getVisibleRect():Rectangle {
		var rect:Rectangle = _itemContainer.getBounds(rootLimb);
		if (_isOpen) for each(var l:TreeLimb in getChildLimbs()) rect = rect.union(l.getVisibleRect());
		return rect;
	}
	/**
	 * 自分より下の階層の見えているアイテム数を取得する
	 * @return
	 */
	private function getVisibleCount():int {
		var count:int = 1;
		if (!_isDirtyVisibleCount) {
			count = _lastVisibleCount;
		} else {
			if (_isOpen) for each(var l:TreeLimb in getChildLimbs()) count += l.getVisibleCount();
			_isDirtyVisibleCount = false;
			_lastVisibleCount = count;
		}
		return count;
	}
	/**
	 * 複製
	 * @param	subLimbs	サブフォルダ以下も複製するか
	 * @return
	 */
	public function clone(subLimbs:Boolean = true):TreeLimb {
		var newLimb:TreeLimb = new TreeLimb();
		for each(var x:XML in describeType(this).accessor.(@declaredBy.split("::").pop() == "TreeLimb" && @access == "readwrite")) newLimb[x.@name] = this[x.@name];
		newLimb._style = _style;
		if(subLimbs) for each(var l:TreeLimb in getChildLimbs()) newLimb.addLimb(l.clone());
		return newLimb;
	}
}
/**
 * ファイルツリー関係のイベント
 */
class TreeLimbEvent extends Event {
	public var extra:*;
	/**呼び出し元のTreeLimbオブジェクト（クリック時等はcurrentTargetと違う場合もあります）*/
	public var targetLimb:TreeLimb;
	/**ツリーサイズ*/
	public var bounds:Rectangle;
	/**選択状況が変化した時*/
	static public const CHANGE_SELECT:String = "onChangeSelect";
	/**アイテムがクリックされた時*/
	static public const CLICK_ITEM:String = "onClickItem";
	/**アイテムがWクリックされた時*/
	static public const WCLICK_ITEM:String = "onWclickItem";
	/**ツリーのサイズが変化した時*/
	static public const RESIZE:String = "onResize";
	public function TreeLimbEvent(type:String, target:TreeLimb = null, extra:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
		this.extra = extra;
		targetLimb = target;
		super(type, bubbles, cancelable);
	}
}