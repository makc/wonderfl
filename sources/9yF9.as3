/**
 * ローカルのDAEモデルを読み込んでツリー表示
 * 重いデータを読み込むとフリーズします
 * テクスチャが表示できないのが悲しい
 * （修正）ハイライト表示が重かったのでドラッグ時は無効にしました
 */
package  {
	import com.bit101.components.CheckBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import net.hires.debug.Stats;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.Papervision3D;
	public class DaeTree extends Sprite {
		private const DISPLAY:Rectangle = new Rectangle(0, 0, 465, 465);
		private var fr:FileReference;
		private var view:Preview;
		private var activeDae:DAE;
		private var loadBtn:PushButton;
		private var clearBtn:PushButton;
		private var win:TreeWindow;
		private var style:TreeStyle;
		private var activeTree:TreeLimb;
		private var bounding:BoundingManager;
		public function DaeTree() {
			Wonderfl.disable_capture();
			//Wonderfl.capture_delay(30);
			Style.BUTTON_FACE = 0xF0F0F0;
			var bg:Sprite = addChild(new Sprite()) as Sprite;
			bg.graphics.beginFill(0x444444, 1);
			bg.graphics.drawRect(0, 0, DISPLAY.width, DISPLAY.height);
			bg.graphics.endFill();
			stage.frameRate = 30;
			Papervision3D.PAPERLOGGER.unregisterLogger(Papervision3D.PAPERLOGGER.traceLogger);
			bounding = new BoundingManager();
			var loader:IconLoader = new IconLoader();
			loader.create(onDecode);
		}
		private function onDecode(icons:Vector.<BitmapData>):void {
			win = new TreeWindow(this, 10, 210, "DAE EXPLORER");
			win.setWindowSize(446, 242);
			win.draggable = false;
			win.folder.label = "";
			win.folder.icon = -1;
			win.folder.isFolder = false;
			win.folder.addEventListener(TreeEvent.CHANGE_SELECT, onChangeSelect);
			style = new TreeStyle();
			style.closeIcon = icons[0];
			style.openIcon = icons[1];
			style.icons = icons.slice(2, icons.length);
			style.textFormat.size = 12;
			style.lineSpacing = 16;
			win.folder.setStyle(style);
			//
			view = new Preview(DISPLAY.width-70, 200);
			view.x = DISPLAY.width - view.rect.width;
			addChild(view);
			addChild(new Stats()).x = DISPLAY.width - 70 - view.rect.width;
			fr = new FileReference();
			fr.addEventListener(Event.SELECT, onSelectFile);
			fr.addEventListener(Event.COMPLETE, onLoadFile);
			fr.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loadBtn = new PushButton(this, 2, 104, "LOAD DAE", onClickBrowse);
			loadBtn.setSize(66, 20);
			new PushButton(this, 48, 158, "+", onClickZoomIn).setSize(20,20);
			new PushButton(this, 48, 180, "-", onClickZoomOut).setSize(20,20);
			Style.LABEL_TEXT = 0xFFFFFF;
			new CheckBox(this, 30, 138, "GRID", onClickGrid).selected = true;
		}
		private function onClickGrid(e:MouseEvent):void{
			view.setGrid(CheckBox(e.currentTarget).selected);
		}
		private function onChangeSelect(...arg):void {
			var selected:Vector.<TreeLimb> = win.folder.getSelectedLimbs();
			if (selected.length == 0) {
				view.resetHighlight();
				return;
			}
			var obj:* = selected[0].extra;
			if (obj == null) return;
			view.highlightModel(obj);
			var bounds:BoundingData = bounding.getBounds(obj);
			if (bounds) {
				view.setTarget(bounds.globalCenter);
				view.setDistanceByBounds(bounds.size);
			}
		}
		private function onClickZoomIn(...arg):void {
			view.zoom(1);
		}
		private function onClickZoomOut(...arg):void {
			view.zoom(-1);
		}
		private function clearModel():void {
			if (!activeDae) return;
			bounding.deleteAllData();
			ModelUtil.disposeMaterials(activeDae);
			view.removeModel(activeDae);
			activeDae.stop();
			activeDae = null;
			for each(var l:TreeLimb in win.folder.getLimbs()) l.dispose();
		}
		private function onError(e:ErrorEvent):void {
		}
		private function onClickBrowse(...arg):void {
			fr.browse([new FileFilter("collada file(*.dae)", "*.dae")]);
		}
		private function onSelectFile(e:Event):void {
			loadBtn.enabled = false;
			win.folder.label = "LOADING...";
			fr.load();
		}
		private function onLoadFile(e:Event):void {
			clearModel();
			var dae:DAE = new DAE();
			dae.addEventListener(FileLoadEvent.LOAD_COMPLETE, onLoadDae);
			dae.load(fr.data);
		}
		private function onLoadDae(e:FileLoadEvent):void {
			win.folder.label = fr.name;
			if(1){
				//メモリリークしにくかったコード
				var dae:DAE = e.currentTarget as DAE;
				dae.removeEventListener(FileLoadEvent.LOAD_COMPLETE, onLoadDae);
				activeDae = dae;
			} else {
				//なぜかこっちだとメモリリーク
				activeDae = e.currentTarget as DAE;
				activeDae.removeEventListener(FileLoadEvent.LOAD_COMPLETE, onLoadDae);
			}
			loadBtn.enabled = true;
			//モデルをプレビュー画面に収める為に境界情報を取得
			var rootBounds:BoundingData = bounding.getBounds(activeDae);
			var size:Number = Math.max(rootBounds.size.x, rootBounds.size.y, rootBounds.size.z);
			var scale:Number = 300 / size;
			activeDae.scale = scale;
			bounding.scale(scale);
			var move:Number3D = new Number3D( -rootBounds.localCenter.x, -rootBounds.localAABB.minY, -rootBounds.localCenter.z);
			activeDae.position = Number3D.add(activeDae.position, move);
			bounding.move(move);
			view.setTarget(rootBounds.globalCenter);
			view.addModel(activeDae);
			view.setDistanceByBounds(rootBounds.size);
			//ルートフォルダに解析したDAEの階層構造を追加
			win.folder.addLimb(ModelUtil.getObjectTree(activeDae));
		}
	}
}
import com.bit101.components.VScrollBar;
import com.bit101.components.Window;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import flash.utils.describeType;
import flash.utils.Dictionary;
import mx.utils.Base64Decoder;
import org.papervision3d.cameras.CameraType;
import org.papervision3d.core.geom.Lines3D;
import org.papervision3d.core.geom.renderables.Line3D;
import org.papervision3d.core.geom.renderables.Triangle3D;
import org.papervision3d.core.geom.renderables.Vertex3D;
import org.papervision3d.core.geom.TriangleMesh3D;
import org.papervision3d.core.math.AxisAlignedBoundingBox;
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.proto.DisplayObjectContainer3D;
import org.papervision3d.materials.special.LineMaterial;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.objects.primitives.Plane;
import org.papervision3d.scenes.Scene3D;
import org.papervision3d.view.BasicView;
//##############################################################################################################
//	モデルプレビュー画面
//##############################################################################################################
class Preview extends BasicView {
	public var rect:Rectangle;
	private var _isDrag:Boolean = false;
	private var _isGrid:Boolean = true;
	private var _camTarget:DisplayObject3D;
	private var _camDistance:Number = 700;
	private var _camRotation:Number = -45;
	private var _camAngle:Number = 20;
	private var _saveRotation:Number;
	private var _saveAngle:Number;
	private var _saveMousePos:Point;
	private var _grid:Lines3D;
	private var _canvasContainer:Bitmap;
	private var _zoom:Number = 30;
	private var _canvas:BitmapData;
	private var _saveQuality:String;
	private var _startDrag:Boolean = false;
	private var _selectModels:Vector.<DisplayObject3D>;
	private var _activeModel:DisplayObject3D;
	private var _objectList:Vector.<DisplayObject3D>;
	public function get camDistance():Number { return _camDistance; }
	//
	public function Preview(width:Number, height:Number) {
		super(width, height, false, false, CameraType.FREE);
		_objectList = new Vector.<DisplayObject3D>();
		rect = new Rectangle(0, 0, width, height);
		_canvas = new BitmapData(width, height, true);
		_camTarget = new DisplayObject3D();
		_grid = new Lines3D(new LineMaterial(0x444444, 1));
		_grid.y = -10;
		var gridStep:Number = 50;
		var gridNum:int = 4;
		for (var i:int = -gridNum; i < gridNum; i++) {
			for (var n:int = -gridNum; n <= gridNum; n++) {
				_grid.addNewLine(0, gridStep * i, 0, gridStep * n, gridStep * (i + 1), 0, gridStep * n);
				_grid.addNewLine(0, gridStep * n, 0, gridStep * i, gridStep * n, 0, gridStep * (i + 1));
			}
		}
		scene.addChild(_grid);
		mouseEnabled = true;
		mouseChildren = false;
		buttonMode = true;
		var bg:Sprite = addChildAt(new Sprite(), 0) as Sprite;
		_canvasContainer = addChild(new Bitmap(_canvas)) as Bitmap;
		bg.graphics.beginFill(0x666666);
		bg.graphics.drawRect(0, 0, width, height);
		addEventListener(MouseEvent.MOUSE_DOWN, onMsDown);
		addEventListener(MouseEvent.MOUSE_WHEEL, onMsWheel);
		setDistance(camDistance);
	}
	public function setGrid(visible:Boolean):void {
		_isGrid = visible;
		render();
	}
	private function onMsWheel(e:MouseEvent):void {
		var vec:int = e.delta / Math.abs(e.delta);
		if (isNaN(vec)) vec = 1;
		zoom(vec);
	}
	public function zoom(vec:int):void {
		_zoom -= vec * 2;
		if (_zoom < 0.1) _zoom = 0.1;
		_camDistance = _zoom * _zoom;
		render();
	}
	private function onMsMove(e:MouseEvent):void {
		if (_startDrag) {
			_startDrag = false;
			stage.quality = "low";
		}
		var dragOffset:Point = new Point(viewport.mouseX, viewport.mouseY).subtract(_saveMousePos);
		_camRotation = _saveRotation - dragOffset.x * 0.5;
		_camAngle = _saveAngle + dragOffset.y * 0.5;
		if (_camAngle < -89) _camAngle = -89;
		if (_camAngle > 89) _camAngle = 89;
		render();
	}
	private function onMsDown(e:MouseEvent):void {
		_saveQuality = stage.quality;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMsUp);
		_isDrag = true;
		_startDrag = true;
		_saveRotation = _camRotation;
		_saveAngle = _camAngle;
		_saveMousePos = new Point(viewport.mouseX, viewport.mouseY);
		_objectList.forEach(function(o:DisplayObject3D, ...arg):void { o.visible = true; } );
	}
	private function onMsUp(...rest):void {
		stage.quality = _saveQuality;
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMsMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMsUp);
		_isDrag = false;
		render();
	}
	public function render():void {
		var per:Number = Math.cos(Math.PI / 180 * _camAngle);
		var px:Number = Math.cos(Math.PI / 180 * _camRotation) * _camDistance * per;
		var py:Number = Math.sin(Math.PI / 180 * _camAngle) * _camDistance;
		var pz:Number = Math.sin(Math.PI / 180 * _camRotation) * _camDistance * per;
		var offset:Number3D = new Number3D(px, py, pz);
		camera.position = Number3D.add(_camTarget.position, offset);
		camera.lookAt(_camTarget);
		if(_objectList != null && _selectModels != null && !_isDrag){
			_canvas.lock();
			_canvas.fillRect(_canvas.rect, 0);
			_objectList.forEach(function(o:DisplayObject3D, ...arg):void { o.visible = true; } );
			_grid.visible = (true && _isGrid);
			onRenderTick();
			_canvas.draw(viewport);
			_canvas.colorTransform(_canvas.rect, new ColorTransform(1, 1, 1, 0.3));
			_objectList.forEach(function(o:DisplayObject3D, ...arg):void { o.visible = _selectModels.indexOf(o) != -1; } );
			_grid.visible = false;
			onRenderTick();
			viewport.filters = [new GlowFilter(0xFFFF00, 1, 3, 3, 10, 1)];
			_canvas.draw(viewport);
			viewport.filters = [];
			_canvas.unlock();
			_canvasContainer.visible = true;
		} else {
			_grid.visible = (true && _isGrid);
			onRenderTick();
			_canvasContainer.visible = false;
		}
	}
	public function resetHighlight():void {
		_selectModels = null;
		_objectList.forEach(function(o:DisplayObject3D, ...arg):void { o.visible = true; } );
		render();
	}
	public function highlightModel(model:DisplayObject3D):void {
		_selectModels = ModelUtil.getChildObject(model, true).concat(ModelUtil.getParentObject(model, false));
		render();
	}
	public function addModel(model:DisplayObject3D):void {
		_activeModel = scene.addChild(model);
		_objectList = ModelUtil.getChildObject(_activeModel, true);
		render();
	}
	public function removeModel(model:DisplayObject3D):void {
		_activeModel = null;
		_selectModels = null;
		scene.removeChild(model);
		_objectList.length = 0;
		render();
	}
	public function setDistanceByBounds(size:Number3D):void {
		var sizeMax:Number = Math.max(size.x, size.y, size.z);
		setDistance(Math.max(1, sizeMax * 2.5));
	}
	public function setDistance(num:Number):void {
		_camDistance = num;
		_zoom = Math.sqrt(num);
		render();
	}
	public function setTarget(pos:Number3D):void {
		_camTarget.position = pos.clone();
	}
}
/**
 * モデルの境界情報を管理する
 */
class BoundingManager {
	private var boundsData:Dictionary;
	public function BoundingManager() {
		boundsData = new Dictionary();
	}
	public function deleteAllData():void {
		boundsData = new Dictionary();
	}
	public function move(point:Number3D):void {
		for (var k:* in boundsData) if(boundsData[k]) boundsData[k].move(point);
	}
	public function scale(num:Number, point:Number3D = null):void {
		for (var k:* in boundsData) if(boundsData[k]) boundsData[k].scale(num, point);
	}
	public function getBounds(obj:DisplayObject3D):BoundingData {
		if (!boundsData[obj]) (obj is TriangleMesh3D)? calculateTriangle(TriangleMesh3D(obj)) : calculateObject(obj);
		return boundsData[obj];
	}
	public function calculateObject(obj:DisplayObject3D):void {
		var transform:Matrix3D = ModelUtil.getWorldTransform(obj);
		var position:Number3D = obj.position.clone();
		Matrix3D.multiplyVector4x4(transform, position);
		var bounds:BoundingData = null;
		for each(var o:DisplayObject3D in obj.children) {
			var mixBound:BoundingData = getBounds(o);
			if (!bounds) {
				if (mixBound) bounds = mixBound.clone();
			} else if (mixBound) {
				bounds.union(mixBound, position);
			}
		}
		boundsData[obj] = bounds;
	}
	public function calculateTriangle(tri:TriangleMesh3D):void {
		var vts:Array = new Array();
		var transform:Matrix3D = ModelUtil.getWorldTransform(tri);
		var position:Number3D = tri.position.clone();//*
		Matrix3D.multiplyVector4x4(transform, position);
		for each(var vt:Vertex3D in tri.geometry.vertices) {
			var n:Number3D = vt.toNumber3D();
			Matrix3D.multiplyVector4x4(transform, n);
			vts.push(new Vertex3D(n.x - position.x, n.y - position.y, n.z - position.z));//*
		}
		var result:BoundingData = new BoundingData();
		result.localAABB = AxisAlignedBoundingBox.createFromVertices(vts);
		result.calculate();
		result.setPosition(position);
		boundsData[tri] = result;
	}
}
/**
 * モデルの境界情報
 */
class BoundingData {
	public var localAABB:AxisAlignedBoundingBox;
	public var globalAABB:AxisAlignedBoundingBox;
	public var localCenter:Number3D;
	public var globalCenter:Number3D;
	public var size:Number3D;
	public var position:Number3D;
	public function BoundingData() {
		localAABB = new AxisAlignedBoundingBox(0, 0, 0, 0, 0, 0);
		globalAABB = new AxisAlignedBoundingBox(0, 0, 0, 0, 0, 0);
		size = new Number3D();
		position = new Number3D();
		localCenter = new Number3D();
		globalCenter = new Number3D();
	}
	public function calculate():void {
		size.x = (localAABB.maxX - localAABB.minX);
		size.y = (localAABB.maxY - localAABB.minY);
		size.z = (localAABB.maxZ - localAABB.minZ);
		localCenter.x = (localAABB.maxX + localAABB.minX) * 0.5;
		localCenter.y = (localAABB.maxY + localAABB.minY) * 0.5;
		localCenter.z = (localAABB.maxZ + localAABB.minZ) * 0.5;
	}
	public function setPosition(pos:Number3D):void {
		position = pos.clone();
		for each(var v:String in ["x", "y", "z"]) {
			for each(var m:String in ["min", "max"]) {
				var v2:String = v.toUpperCase();
				globalAABB[m + v2] = localAABB[m + v2] + position[v];
			}
		}
		globalCenter = Number3D.add(localCenter, position);
	}
	public function union(bounds:BoundingData, pos:Number3D):void {
		position = pos.clone();
		globalAABB.merge(bounds.globalAABB);
		for each(var v:String in ["x", "y", "z"]) {
			for each(var m:String in ["min", "max"]) {
				var v2:String = v.toUpperCase();
				localAABB[m + v2] = globalAABB[m + v2] - position[v];
			}
		}
		calculate();
		globalCenter = Number3D.add(localCenter, position);
	}
	public function move(xyz:Number3D):void {
		position.plusEq(xyz);
		setPosition(position);
	}
	public function scale(num:Number, point:Number3D = null):void {
		if (!point) point = new Number3D();
		position.minusEq(point);
		position.multiplyEq(num);
		position.plusEq(point);
		for each(var v:String in ["maxX", "maxY", "maxZ", "minX", "minY", "minZ"]) localAABB[v] *= num;
		calculate();
		setPosition(position);
	}
	public function clone():BoundingData {
		var bd:BoundingData = new BoundingData();
		for each(var v:String in ["x", "y", "z"]) {
			for each(var m:String in ["min", "max"]) {
				var v2:String = v.toUpperCase();
				bd.localAABB[m + v2] = localAABB[m + v2];
				bd.globalAABB[m + v2] = globalAABB[m + v2];
			}
		}
		bd.size = size.clone();
		bd.localCenter = localCenter.clone();
		bd.globalCenter = globalCenter.clone();
		bd.position = position.clone();
		return bd;
	}
}
class ModelUtil {
	static public function getParentObject(obj:DisplayObject3D, addMe:Boolean = true):Vector.<DisplayObject3D> {
		var list:Vector.<DisplayObject3D> = new Vector.<DisplayObject3D>();
		if (addMe) list.push(obj);
		var parent:DisplayObject3D = obj.parent as DisplayObject3D;
		if (parent) list = list.concat(getParentObject(parent, true));
		return list;
	}
	static public function getChildObject(obj:DisplayObject3D, addMe:Boolean = true):Vector.<DisplayObject3D> {
		var list:Vector.<DisplayObject3D> = new Vector.<DisplayObject3D>();
		if(addMe) list.push(obj);
		for each(var d:DisplayObject3D in obj.children) list = list.concat(getChildObject(d, true));
		return list;
	}
	static public function getChildTriangle(obj:DisplayObject3D, addMe:Boolean = true):Vector.<TriangleMesh3D> {
		var list:Vector.<TriangleMesh3D> = new Vector.<TriangleMesh3D>();
		if (addMe && describeType(obj).@name.split("::")[1] == "TriangleMesh3D") list.push(obj);
		for each(var d:DisplayObject3D in obj.children) list = list.concat(getChildTriangle(d, true));
		return list;
	}
	static public function forEachModel(obj:DisplayObject3D, func:Function, thisArg:* = null):void {
		func.apply(thisArg, [obj]);
		for each(var d:DisplayObject3D in obj.children) forEachModel(d, func);
	}
	/**
	 * モデルの構造をTreeLimbオブジェクトで出力する
	 */
	static public function getObjectTree(obj:DisplayObjectContainer3D):TreeLimb {
		var className:String = describeType(obj).@name.split("::")[1];
		var icon:int = (obj is TriangleMesh3D)? 5 : 0;
		var isFolder:Boolean = (className == "DisplayObject3D" || className == "DAE");
		var disp:DisplayObject3D = obj as DisplayObject3D;
		var label:String;
		if (disp != null) {
			var error:String = (disp.id == Number(disp.name))? "*" : "";
			label = error + disp.name +" (" + className + ")";
		} else {
			label = "(" + className + ")\n";
		}
		var tree:TreeLimb = new TreeLimb(label, isFolder, icon, obj);
		for each(var d:DisplayObject3D in obj.children) tree.addLimb(getObjectTree(d));
		return tree;
	}
	static public function getWorldTransform(obj:DisplayObject3D):Matrix3D {
		obj.translate(0, new Number3D());
		var res:Matrix3D = new Matrix3D();
		res.copy(obj.transform);
		var parent3D:DisplayObject3D = obj.parent as DisplayObject3D;
		if (parent3D != null) res.calculateMultiply(getWorldTransform(parent3D), res);
		return res;
	}
	/**
	 * モデルのテクスチャを全部破棄（他と共有していた場合も関係なく消す）
	 */
	static public function disposeMaterials(model:DisplayObject3D):void {
		for each(var tr:TriangleMesh3D in getChildTriangle(model, true)) {
			for each(var tg:Triangle3D in tr.geometry.faces) {
				if (tg.material) {
					if (tg.material.bitmap) tg.material.bitmap.dispose();
					tg.material.destroy();
					tg.material = null;
				}
			}
		}
	}
}
//##############################################################################################################
//	以下ツリー表示クラス
//##############################################################################################################
/**
 * ツリーウィンドウ
 */
class TreeWindow extends Window {
	private var _workSpace:Rectangle;
	private var _container:Sprite;
	private var _bg:Sprite;
	private var _folder:TreeLimb;
	private var _vscroll:VScrollBar;
	private var _hscroll:VScrollBar;
	private var _padding:Number = 10;
	private var _bgcolor:uint = 0xF9F9F9;
	public function get folder():TreeLimb { return _folder; }
	public function get bgcolor():uint { return _bgcolor; }
	public function set bgcolor(value:uint):void {
		_bgcolor = value;
		var ct:ColorTransform = new ColorTransform();
		ct.color = _bgcolor;
		_bg.transform.colorTransform = ct;
	}
	public function TreeWindow(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, title:String = "Window") {
		super(parent, xpos, ypos, title);
		_workSpace = new Rectangle();
		_bg = content.addChild(new Sprite()) as Sprite;
		_bg.graphics.clear();
		_bg.graphics.beginFill(0xFFFFFF);
		_bg.graphics.drawRect(0, 0, 100, 100);
		_bg.graphics.endFill();
		_bg.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownBg);
		addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		_container = content.addChild(new Sprite()) as Sprite;
		_folder = _container.addChild(new TreeLimb()) as TreeLimb;
		_folder.addEventListener(TreeEvent.RESIZE, onResize);
		_vscroll = new VScrollBar(content, 0, 0, onVScroll);
		_hscroll = new VScrollBar(content, 0, 0, onHScroll);
		_hscroll.rotation = -90;
		setWindowSize(width, height);
		var rect:Rectangle = _folder.getVisibleRect();
		rect.inflate(_padding, _padding);
		var px:int = int(rect.left), py:int = int(rect.top);
		_hscroll.setSliderParams(px, px + 100, px);
		_vscroll.setSliderParams(py, py + 100, py);
		bgcolor = _bgcolor;
	}
	private function onMouseWheel(e:MouseEvent):void {
		var vec:int = e.delta / Math.abs(e.delta);
		if (!_vscroll.enabled) return;
		_vscroll.value += vec * -30;
	}
	private function onMouseDownBg(e:MouseEvent):void {
		_folder.resetSelect();
	}
	private function onHScroll(...arg):void{
		_folder.x = int(_workSpace.x - _hscroll.value);
	}
	private function onVScroll(...arg):void {
		_folder.y = int(_workSpace.y - _vscroll.value);
	}
	private function onResize(e:TreeEvent):void {
		e.bounds.inflate(_padding, _padding);
		var perV:Number = Math.min(2, _workSpace.height / e.bounds.height);
		var perH:Number = Math.min(2, _workSpace.width / e.bounds.width);
		_vscroll.enabled = (perV < 1);
		_hscroll.enabled = (perH < 1);
		if (perV < 0.1 || isNaN(perV)) perV = 0.1;
		if (perH < 0.1 || isNaN(perH)) perH = 0.1;
		_vscroll.setThumbPercent(perV);
		_hscroll.setThumbPercent(perH);
		if (!_vscroll.enabled) _vscroll.value = e.bounds.top;
		if (!_hscroll.enabled) _hscroll.value = e.bounds.left;
		_vscroll.setSliderParams(e.bounds.top, e.bounds.height - _workSpace.height - _padding, _vscroll.value);
		_hscroll.setSliderParams(e.bounds.left, e.bounds.width - _workSpace.width - _padding, _hscroll.value);
	}
	public function setWindowSize(w:Number, h:Number):void {
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
	}
	public function dispose():void {
		_folder.dispose();
		removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		_bg.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownBg);
		_folder.removeEventListener(TreeEvent.RESIZE, onResize);
	}
}
/**
 * ツリー表示用スタイル
 */
class TreeStyle {
	public var openIcon:BitmapData;	//フォルダを開いた時の画像
	public var closeIcon:BitmapData;	//フォルダを閉じた時の画像
	public var noIcon:BitmapData;	//アイコンが無い時の画像
	public var icons:Vector.<BitmapData> = new Vector.<BitmapData>();	//アイコン画像リスト
	public var textFormat:TextFormat = new TextFormat("_sans", 14, 0x000000);	//テキストフォーマット
	public var selectedBoxColor:uint = 0x4CA4D8;	//
	public var selectedLabelColor:uint = 0xFFFFFF;	//
	public var dotV:BitmapData;	//破線画像（縦）
	public var dotH:BitmapData;	//破線画像（横）
	public var buttonSize:Number = 11;	//フォルダ開閉ボタンのサイズ（奇数値推奨）
	public var lineSpacing:Number = 20;	//行間
	public var lineIndent:Number = 14;	//横線の長さ
	public var labelOffset:Point = new Point(10, 0);	//ラベルの位置
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
 * ツリーアイテム
 */
class TreeLimb extends Sprite {
	private var _icon:int;
	private var _isFolder:Boolean;
	private var _label:String;
	private var _extra:*;
	private var _isOpen:Boolean = true;
	private var _selected:Boolean = false;
	private var _parentLimb:TreeLimb;
	private var _rootLimb:TreeLimb;
	private var _isRoot:Boolean = true;
	private var _style:TreeStyle = new TreeStyle();
	private var _isDirtyStyle:Boolean = true;
	private var _lastParent:DisplayObjectContainer;
	private var _lastLineVisible:Boolean = true;
	private var _lastBounds:Rectangle;
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
	private var _selectedItems:Vector.<TreeLimb>;
	private var _onStage:Boolean = false;	//ステージ上に配置されているか
	private var _isAdding:Boolean = false;	//addLimb()等で追加されたオブジェクトか
	private var _beforeMoveParent:TreeLimb;	//移動直前の親
	private var _isGhost:Boolean = false;	//既に破棄されたアイテムか
	private var _isDirtyChild:Boolean = true;	//自分の子も更新対象にするか
	private var _lastVisibleCount:int = 1;	//最新の見えているフォルダ数
	private var _isDirtyVisibleCount:Boolean = true;	//見えているフォルダの数が変化した
	/**[g/s]ユーザーデータ*/
	public function get extra():* { return _extra; }
	public function set extra(value:*):void { _extra = value; }
	/**[g/s]表示テキスト*/
	public function get label():String { return _label; }
	public function set label(value:String):void { _labelText.text = _label = value; refreshLabel(); }
	/**[g/s]フォルダアイコンを使うか*/
	public function get isFolder():Boolean { return _isFolder; }
	public function set isFolder(value:Boolean):void { _isFolder = value; refresh(false); }
	/**[g/s]ファイルアイコンの種類（isFolder=trueで無効。-1でアイコン無し。）*/
	public function get icon():int { return _icon; }
	public function set icon(value:int):void { _icon = value; refreshStyle(); }
	/**[g/s]自分が選択されているか*/
	public function get selected():Boolean { return _selected; }
	public function set selected(value:Boolean):void { setSelect(value, true); }
	/**[g/s]サブフォルダを開いているか*/
	public function get isOpen():Boolean { return _isOpen; }
	public function set isOpen(value:Boolean):void { setOpen(value); }
	/**[g]ルートフォルダ*/
	public function get rootLimb():TreeLimb { return _rootLimb; }
	/**[q]自分がルートフォルダか*/
	public function get isRoot():Boolean { return _isRoot; }
	/**[g]スタイル*/
	public function get style():TreeStyle { return _style; }
	/**[q]子の数*/
	public function get numLimb():int { return _limbs.numChildren; }
	//コンストラクタ
	public function TreeLimb(label:String = "New Item", isFolder:Boolean = true, icon:int = 0, extra:* = null) {
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
		_iconSprite.addEventListener(MouseEvent.CLICK, onClickIcon);
		_iconSprite.addEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
		_selectBox.addEventListener(MouseEvent.CLICK, onClickIcon);
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
		refresh();
	}
	private function onRemoveStage(e:Event):void {
		_onStage = false;
		if (_isAdding) _beforeMoveParent = _parentLimb;
	}
	private function onAddedStage(e:Event):void {
		_onStage = true;
	}
	private function onAdded(e:Event):void { checkRoot(); }
	private function onClickOpen(e:MouseEvent):void { setOpen(!_isOpen); }
	private function onClickIcon(e:MouseEvent):void {
		setSelect(true);
		_rootLimb.dispatchEvent(new TreeEvent(TreeEvent.CLICK_ITEM, this));
	}
	private function onWclickIcon(e:MouseEvent):void {
		setOpen(!_isOpen);
		_rootLimb.dispatchEvent(new TreeEvent(TreeEvent.WCLICK_ITEM, this));
	}
	private function getRoot():TreeLimb { return (_parentLimb == null)? this : _parentLimb.getRoot(); }
	private function checkRoot(exe:Boolean = false):void {
		if (parent === _lastParent && !exe) return;
		_lastParent = parent;
		_parentLimb = (parent == null || parent.parent == null)? null : parent.parent as TreeLimb;
		_rootLimb = getRoot();
		_isRoot = _rootLimb === this;
		for each(var l:TreeLimb in getLimbs()) l.checkRoot(true);
	}
	/**選択されている全てのアイテムを取得*/
	public function getSelectedLimbs():Vector.<TreeLimb> {
		return _rootLimb._selectedItems.concat();
	}
	/**全ての選択を解除*/
	public function resetSelect(dispatch:Boolean = true):void {
		for each(var l:TreeLimb in _rootLimb._selectedItems) l.setSelect(false, false, false);
		if (dispatch) _rootLimb.dispatchEvent(new TreeEvent(TreeEvent.CHANGE_SELECT, this));
	}
	/**自分を選択or解除*/
	public function setSelect(selected:Boolean = true, multiSelect:Boolean = false, dispatch:Boolean = true):void {
		_selected = selected;
		if (_selected && !multiSelect) for each(var l:TreeLimb in _rootLimb._selectedItems) if(l !== this) l.setSelect(false, multiSelect, false);
		var index:int = _rootLimb._selectedItems.indexOf(this);
		if (_selected && index == -1) _rootLimb._selectedItems.push(this);
		if (!_selected && index != -1) _rootLimb._selectedItems.splice(index, 1);
		refreshSelect();
		if (dispatch) _rootLimb.dispatchEvent(new TreeEvent(TreeEvent.CHANGE_SELECT, this));
	}
	/**フォルダの開閉*/
	public function setOpen(isOpen:Boolean = true, subLimbs:Boolean = false):void {
		_isOpen = isOpen;
		if (subLimbs) for each(var l:TreeLimb in getLimbs(true)) l.setOpen(isOpen, subLimbs);
		refreshDirty();
	}
	/**自分のインデックス位置を取得*/
	public function getIndex():int {
		return (!parent)? 0 : parent.getChildIndex(this);
	}
	private function getParentLimbs():Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		if (!isRoot) {
			result.push(_parentLimb);
			result = result.concat(_parentLimb.getParentLimbs());
		}
		return result;
	}
	private function getUpdateLimbs():Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		if (isRoot) {
			result.push(this);
		} else if (_parentLimb) {
			for (var i:int = getIndex(); i < _parentLimb.numLimb; i++) result.push(_parentLimb.getLimbAt(i) as TreeLimb);
			result = result.concat(_parentLimb.getUpdateLimbs());
		}
		return result;
	}
	/**自分の子をまとめて取得*/
	public function getLimbs(subLimbs:Boolean = false, addMe:Boolean = false):Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for (var i:int = 0; i < numLimb; i++) {
			var limb:TreeLimb = getLimbAt(i);
			result.push(limb);
			if (subLimbs) result = result.concat(limb.getLimbs(subLimbs));
		}
		if (addMe) result.push(this);
		return result;
	}
	/**ユーザーデータが一致する全ての子を取得*/
	public function getLimbByExtra(extra:*, subLimbs:Boolean = true):Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for each(var limb:TreeLimb in getLimbs(subLimbs)) if (limb.extra === extra) result.push(limb);
		return result;
	}
	/**ラベル名が一致する全ての子を取得*/
	public function getLimbByLabel(label:String, subLimbs:Boolean = true):Vector.<TreeLimb> {
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for each(var limb:TreeLimb in getLimbs(subLimbs)) if (limb._label == label) result.push(limb);
		return result;
	}
	/**指定インデックスの子を取得*/
	public function getLimbAt(index:int):TreeLimb {
		return (index < 0 || index >= numLimb)? null : _limbs.getChildAt(index) as TreeLimb;
	}
	/**TreeLimbオブジェクトを子に追加*/
	public function addLimb(limb:TreeLimb):TreeLimb {
		return addLimbAt(limb, numLimb);
	}
	/**複数のTreeLimbオブジェクトを子に追加*/
	public function addLimbs(limbs:Vector.<TreeLimb>):Vector.<TreeLimb> {
		for each(var l:TreeLimb in limbs) addLimb(l);
		return limbs;
	}
	/**TreeLimbオブジェクトを指定インデックスに追加*/
	public function addLimbAt(limb:TreeLimb, index:int = -1):TreeLimb {
		for each(var l:TreeLimb in limb.getLimbs(true, true)) if(l.selected) l.setSelect(false);
		limb._isAdding = true;
		if (limb._parentLimb === this) limb.parent.removeChild(limb);
		if (index > numLimb || index < 0) index = numLimb;
		if (limb.parent != null) limb.parent.removeChild(limb);
		_limbs.addChildAt(limb, index);
		limb.newStyle(_style, true);
		limb.refreshDirty();
		if (limb._beforeMoveParent) {
			limb._beforeMoveParent.refreshDirty();
		}
		_beforeMoveParent = null;
		limb.refresh();
		limb._isAdding = false;
		return limb;
	}
	/**ファイルを子に追加*/
	public function addFile(label:String = "", icon:int = 0, extra:* = null):TreeLimb {
		return addLimb(new TreeLimb(label, false, icon, extra));
	}
	/**複数のファイルを子に追加*/
	public function addFiles(labels:Array, icons:Array = null, extras:Array = null):Vector.<TreeLimb> {
		if (icons == null) icons = new Array();
		if (extras == null) extras = new Array();
		while (icons.length < labels.length) icons.push(0);
		while (extras.length < labels.length) extras.push(null);
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for (var i:int = 0; i < labels.length; i++) result.push(addFile(labels[i], icons[i], extras[i]));
		return result;
	}
	/**フォルダを子に追加*/
	public function addFolder(label:String = "", extra:* = null):TreeLimb {
		return addLimb(new TreeLimb(label, true, 0, extra));
	}
	/**複数のフォルダを子に追加*/
	public function addFolders(labels:Array, extras:Array = null):Vector.<TreeLimb> {
		if (extras == null) extras = new Array();
		while (extras.length < labels.length) extras.push(null);
		var result:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for (var i:int = 0; i < labels.length; i++) result.push(addFolder(labels[i], extras[i]));
		return result;
	}
	/**TreeLimbオブジェクトを子から切り離す*/
	public function removeLimb(limb:TreeLimb):Boolean {
		for each(var l:TreeLimb in getLimbs(true, true)) if (l === limb) { l.remove(); return true; }
		return false;
	}
	/**複数のTreeLimbオブジェクトを子から切り離す*/
	public function removeLimbs(limbs:Vector.<TreeLimb>):int {
		var count:int = 0;
		for each(var l:TreeLimb in limbs) count += int(l.removeLimb(l));
		return count;
	}
	private function destroyData(subLimbs:Boolean = true):void {
		removeAllListeners();
		_extra = null;
		_selected = false;
		_isGhost = true;
		_selectedItems.length = 0;
		if(subLimbs) for each(var l:TreeLimb in getLimbs()) l.destroyData(true);
	}
	/**自分を破棄する*/
	public function dispose(subLimbs:Boolean = true):void {
		remove();
		destroyData(subLimbs);
	}
	/**自分を親から切り離す*/
	public function remove():Boolean {
		for each(var l:TreeLimb in getLimbs(true, true)) if(l.selected) l.setSelect(false);
		if (parent == null) return false;
		parent.removeChild(this);
		if (!isRoot && !_rootLimb._isGhost) refreshDirty();
		checkRoot(true);
		return true;
	}
	/**内部イベントリスナを全て削除*/
	public function removeAllListeners():void {
		removeEventListener(Event.ADDED, onAdded);
		removeEventListener(Event.ADDED_TO_STAGE, onAddedStage);
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveStage);
		_iconSprite.removeEventListener(MouseEvent.CLICK, onClickIcon);
		_iconSprite.removeEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
		_selectBox.removeEventListener(MouseEvent.CLICK, onClickIcon);
		_selectBox.removeEventListener(MouseEvent.DOUBLE_CLICK, onWclickIcon);
		_openSprite.removeEventListener(MouseEvent.CLICK, onClickOpen);
	}
	/**自分の子をソートして再配置*/
	public function sortOn(names:String, options:Object = null):void {
		var list:Array = new Array();
		for each(var l:TreeLimb in getLimbs()) list.push(l);
		list.sortOn(names, options);
		var sortedLimbs:Vector.<TreeLimb> = new Vector.<TreeLimb>();
		for each(var limb:TreeLimb in list) sortedLimbs.push(limb);
		addLimbs(sortedLimbs);
	}
	/**繋がった全てのアイテムのスタイルを更新*/
	public function updateStyle():void {
		setStyle(_style);
	}
	/**繋がった全てのアイテムにスタイルを適用*/
	public function setStyle(style:TreeStyle):void {
		_rootLimb.newStyle(style, true);
	}
	private function newStyle(style:TreeStyle, subLimbs:Boolean = true):void {
		_style = style;
		refreshStyle();
		refreshSelect();
		if (subLimbs) for each(var l:TreeLimb in getLimbs()) l.newStyle(_style, subLimbs);
		refresh();
	}
	private function refreshSelect():void {
		_labelText.textColor = (_selected)? _style.selectedLabelColor : uint(_style.textFormat.color);
		_selectBox.alpha = int(_selected);
	}
	private function refreshDirty():void {
		_isDirtyVisibleCount = true;
		for each(var tl1:TreeLimb in getParentLimbs()) tl1._isDirtyVisibleCount = true;
		for each(var tl2:TreeLimb in getUpdateLimbs()) {
			tl2._isDirtyChild = false;
			tl2.refresh(true);
		}
	}
	private function refresh(subLimbs:Boolean = true):void {
		var showLine:Boolean = !(_isRoot && numLimb == 0);
		if (showLine != _lastLineVisible) refreshStyle();
		var lineHeight:Number = 0;
		var heightList:Array = new Array();
		if (_isOpen && subLimbs) {
			var nextY:Number = 0;
			for (var i:int = 0; i < numLimb; i++ ) {
				var limb:TreeLimb = _limbs.getChildAt(i) as TreeLimb;
				limb.x = 0;
				limb.y = nextY;
				if (_isDirtyChild) limb.refresh(subLimbs);
				nextY += heightList[heightList.push(limb.getVisibleCount() * _style.lineSpacing) - 1];
			}
			heightList.forEach(function(...arg):void { lineHeight += (arg[1] == heightList.length - 1)? _style.lineSpacing : arg[0]; } );
		}
		if (_isFolder) _closeIcon.visible = !(_openIcon.visible = (_isOpen && numLimb));
		_limbs.visible = _isOpen;
		_openSprite.visible = (numLimb > 0);
		_closeSprite.visible = _openSprite.visible && !_isOpen;
		_lineV.graphics.clear();
		_lineV.graphics.beginBitmapFill(_style.dotV);
		_lineV.graphics.drawRect(0, 0, 1, lineHeight);
		_lineV.graphics.endFill();
		if (_isRoot) {
			var rect:Rectangle = getVisibleRect();
			if (_lastBounds == null || !rect.equals(_lastBounds)) {
				var event:TreeEvent = new TreeEvent(TreeEvent.RESIZE, this);
				event.bounds = rect.clone();
				dispatchEvent(event);
				_lastBounds = rect;
			}
		}
		_isDirtyChild = false;
		_lastLineVisible = showLine;
	}
	private function refreshLabel():void {
		_labelText.setTextFormat(_style.textFormat);
		_selectBox.width = _labelText.textWidth + 4;
		_selectBox.height = _labelText.textHeight;
		refreshSelect();
	}
	private function refreshStyle():void {
		refreshLabel();
		var showLine:Boolean = !(_isRoot && numLimb == 0);
		var cornerX:int = _style.treeOffset.x + (int(_style.buttonSize / 2) + _style.lineIndent) * int(showLine);
		while (_iconSprite.numChildren) _iconSprite.removeChildAt(0);
		var icons:Vector.<Bitmap> = new Vector.<Bitmap>();
		if (_isFolder) {
			_openIcon = new Bitmap(_style.openIcon);
			_closeIcon = new Bitmap(_style.closeIcon);
			icons.push(_openIcon, _closeIcon);
		} else if (_style.icons.length > _icon && _icon >= 0) icons.push(new Bitmap(_style.icons[_icon]));
		else icons.push(new Bitmap(_style.noIcon));
		for each(var ico:Bitmap in icons){
			_iconSprite.addChild(ico);
			ico.x = cornerX - int(ico.width / 2);
			ico.y = _style.treeOffset.y - int(ico.height / 2);
		}
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
		_limbs.x = cornerX - _style.treeOffset.x;
		_limbs.y = _style.lineSpacing;
	}
	/**自分より下の階層の矩形サイズを取得する*/
	public function getVisibleRect():Rectangle {
		var rect:Rectangle = _itemContainer.getBounds(rootLimb);
		if (_isOpen) for each(var l:TreeLimb in getLimbs()) rect = rect.union(l.getVisibleRect());
		return rect;
	}
	private function getVisibleCount():int {
		var count:int = 1;
		if (!_isDirtyVisibleCount) {
			count = _lastVisibleCount;
		} else {
			if (_isOpen) for each(var l:TreeLimb in getLimbs()) count += l.getVisibleCount();
			_isDirtyVisibleCount = false;
			_lastVisibleCount = count;
		}
		return count;
	}
	/**複製*/
	public function clone(subLimbs:Boolean = true):TreeLimb {
		var newLimb:TreeLimb = new TreeLimb();
		for each(var x:XML in describeType(this).accessor.(@declaredBy.split("::").pop() == "TreeLimb" && @access == "readwrite")) newLimb[x.@name] = this[x.@name];
		newLimb._style = _style;
		if(subLimbs) for each(var l:TreeLimb in getLimbs()) newLimb.addLimb(l.clone());
		return newLimb;
	}
}
class TreeEvent extends Event {
	public var extra:*;
	public var targetLimb:TreeLimb;
	public var bounds:Rectangle;
	static public const CHANGE_SELECT:String = "onChangeSelect";
	static public const CLICK_ITEM:String = "onClickItem";
	static public const WCLICK_ITEM:String = "onWclickItem";
	static public const RESIZE:String = "onResize";
	public function TreeEvent(type:String, target:TreeLimb = null, extra:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
		this.extra = extra;
		targetLimb = target;
		super(type, bubbles, cancelable);
	}
}
/**
 * このサンプルに使うアイコン画像を生成する汎用性のないクラス
 */
class IconLoader {
	private var loader:Loader;
	private var iconImages:Vector.<BitmapData> = new Vector.<BitmapData>();
	private var iconSize:Rectangle = new Rectangle(0, 0, 13, 13);
	private var iconNum:int = 8;
	private var iconData:String = "iVBORw0KGgoAAAANSUhEUgAAAGgAAAANCAMAAABy+9t6AAAAA3NCSVQICAjb4U/gAAAAe1BMVEX//////5n//wCZ///x5L7/51Dv3a+97ard3d3/zMzq1Zvo0ZJm/wDMzMzly4Tmy4Sg4G3/zACqyu3tvarcuFh+0SyZzAAzzMyrq6u+qXNts+DIo1S+mFKgkXTgfW3/ZpksmdGFhVCffDxie1h7YlhYaHvROyxtVikAAADVecskAAAACXBIWXMAAArwAAAK8AFCrDSYAAAAFnRFWHRDcmVhdGlvbiBUaW1lADA0LzI4LzEwTP2JvQAAABx0RVh0U29mdHdhcmUAQWRvYmUgRmlyZXdvcmtzIENTNAay06AAAAFWSURBVDiNvdRhV4IwFMbxkRVhMwOGZGqiFTzf/xN2790dd3bqlad29oK/wn4oZzjPA4Cfx7fw10YsJ8fL5TJ9C0zn/XwqXMaiyKPJo8yjtQD6vpdydLydpq1SxEwE7ZWCczyhTsFTo2l4apQlT4225YnE9JFyuCVjpg6TQkSJ47B6cFCnQH1XQJ0Gw2sDdUp0zyXUaTG+tXz5YqFQVYHvWKkQQHEQaEfBd/RC0GoVV8CJoLrW+CRoGDTeCeo6jQ+CxpEv32yEqqrjkaDwyNRTCDv6vzgO550EnUmGQWQYRIZBZBhEhkFMEROhwKvTyvxg8hBIRoJkJEhGgmQkSEaCNjdHg0K4j4/lIv4EWufQ+t8hDxjkAYM8YJAHDPLAz5CX1de6dS7CJ8q23wwpZTFDSsX7VIj3kTStbStnoRSyqPMY8ujyGNPPI0jfDLF/e9fFD66ItNoX84d0b8+P1/QAAAAASUVORK5CYII=";
	private var iconAlpha:uint = 0x66FF00;
	public function IconLoader() {
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function():void { } );
	}
	public function create(func:Function):void {
		var b64d:Base64Decoder = new Base64Decoder();
		b64d.decode(iconData);
		var ba:ByteArray = b64d.toByteArray();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function():void {
			onDecode.apply();
			func.apply(null, [iconImages]);
		});
		loader.loadBytes(ba);
	}
	private function onDecode():void {
		loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onDecode);
		var img:BitmapData = Bitmap(loader.content).bitmapData;
		var bmp:BitmapData = new BitmapData(img.width, img.height, true);
		bmp.copyPixels(img, img.rect, new Point());
		bmp.threshold(bmp, bmp.rect, new Point(), "==", 0xFF << 24 | iconAlpha, 0x00000000);//背景色を透明化
		iconImages.length = 0;
		for (var i:int = 0; i < iconNum; i++) {
			iconImages[i] = new BitmapData(iconSize.width, iconSize.height, true);
			iconImages[i].copyPixels(bmp, new Rectangle(iconSize.width * i, 0, iconSize.width, iconSize.height), new Point());
		}
	}
}