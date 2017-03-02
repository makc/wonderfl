// ネタ元 http://www.nicovideo.jp/watch/sm9277616
// forked from matsumos's エセ3Dモデラー
/* 
 * 1. 画像の上を適当にドラッグして色を塗る
 * 2. 左上 Blur ボタンをクリックすればなめらか
 * 3. 満足いくまで塗ったら、左下 Make3D ボタンをクリック
 * 4. 画像をドラッグして回転したり、下の Height スライダを動かすなど
 * 5. 好きな画像を読み込んでみると楽しいかも
 * 6. 3Dモードの時に Ctrl キーを押しながらマウスで画像をつかんではなすと・・・！！
 *
 * JellyPicsのコードをPV3Dで動くようにして強引に組み込ませていただきました。
 * http://dotfla.net/
 */

package
{
	import com.bit101.components.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import mx.graphics.codec.PNGEncoder;
	import org.papervision3d.cameras.*;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.utils.Mouse3D;
	import org.papervision3d.materials.*
	import org.papervision3d.objects.*;
	import org.papervision3d.objects.primitives.*;
	import org.papervision3d.view.*;
	import net.hires.debug.Stats;

	public class Main extends BasicView
	{
		private var _plane:Plane;
		private var _material:BitmapMaterial;
		private var _paint:Paint;
		private var _canvas:BitmapData;
		private var _imageWidth:int;
		private var _imageHeight:int;
		private var _make3dButton:PushButton;
		private var _draw2dButton:PushButton;
		private var _hitArea:Sprite;
		private var _heightSlider:HUISlider;
		private var _loadMapDataButton:PushButton;
		
		// ドラッグによってかかっている力
		private var _power:Rectangle;
		
		// オリジナルの頂点データ
		private var _baseVertices:Array = [];
		// 力がかかった状態の頂点データ
		private var _poweredVertices:Array = [];
		// 現在の頂点データ
		private var _vertices:Array;
		// 各頂点にかかる力
		private var _energies:Array = [];
		
		private var _forces:Array = [];
		
		public function Main():void
		{
			stage.quality = StageQuality.MEDIUM;
			
			_imageWidth = _imageHeight = 465;
			
			/*
			var stats:Stats = new Stats();
			stats.x = -80;
			addChild(stats);
			*/
			
			super( _imageWidth,_imageHeight, false, true, CameraType.TARGET );
			Mouse3D.enabled = true;
			
			init();
			
			loader(setCanvas).load(new URLRequest("http://assets.wonderfl.net/images/related_images/0/0f/0f55/0f55917fef21710db05932fa8a2e0c2d6a85fecf"), new LoaderContext(true));
		}
		
		private function init():void
		{
			_canvas = new BitmapData( _imageWidth, _imageHeight, true, 0x00000000 );
			
			_paint = new Paint( _canvas, _imageWidth, _imageHeight );			
			addChild(_paint);
			_paint.init();
			
			_plane = new Plane( new WireframeMaterial(0x00FF00,1), _imageWidth, _imageHeight, Math.floor( _imageWidth / 20 ), Math.floor( _imageHeight / 20 ) );
			
			_vertices = _plane.geometry.vertices;
			for (var i:int = 0; i < _vertices.length; i++) 
			{
				_baseVertices.push(new Vertex3D(_plane.geometry.vertices[i].x,_plane.geometry.vertices[i].y,_plane.geometry.vertices[i].z));
				_poweredVertices.push(new Vertex3D(_plane.geometry.vertices[i].x,_plane.geometry.vertices[i].y,_plane.geometry.vertices[i].z));
				_energies.push(new Vertex3D(0, 0, 0));
				_forces.push(0);
			}
			
			scene.addChild( _plane );
			
			var loadButton:PushButton = new PushButton(this, stage.stageWidth - 100, 0, "Load Image", function():void {
				fileRefelence( loader(setCanvas).loadBytes ).browse();
			});
			
			var saveMapDataButton:PushButton = new PushButton(this, stage.stageWidth - 100, 20, "Save Map Data", function():void {
				var encoder:PNGEncoder = new PNGEncoder();
				var bytes:ByteArray = encoder.encode(_canvas);
				var fileReference:FileReference = new FileReference();
				fileReference.save(bytes, "map" + new Date().valueOf() +".png");
			});
			
			_loadMapDataButton = new PushButton(this, stage.stageWidth - 100, 40, "Load Map Data", function():void {
				fileRefelence( loader(setMapData).loadBytes ).browse();
			});
			
			var targetPos:DisplayObject3D = new DisplayObject3D();
			targetPos.copyTransform( _plane );
			targetPos.moveBackward( camera.focus * camera.zoom * this.scaleX );

			camera.x = targetPos.x;
			camera.y = targetPos.y;
			camera.z = targetPos.z;

			_draw2dButton = new PushButton( this, 0, stage.stageHeight - 20, "Draw2D", draw2d );
			_make3dButton = new PushButton( this, 0, stage.stageHeight - 20, "Make3D", make3d );
			
			_heightSlider = new HUISlider( this, stage.stageHeight / 2, stage.stageHeight - 20, "Height", heightSlideHandler );
			_heightSlider.value = 20;
			pheight = .2;
			
			_hitArea = new Sprite();
			_hitArea.graphics.beginFill( 0x0, 0 );
			_hitArea.graphics.drawRect( 0, 0, stage.stageWidth,stage.stageHeight );
			_hitArea.graphics.endFill();
			addChildAt(_hitArea, getChildIndex(viewport) + 1);
			
			startRendering();
			startRenderingVercities();
			
			draw2d();
			
		}
		
		private function fileRefelence( func:Function ):FileReference {
			var f:FileReference = new FileReference();
			f.addEventListener(Event.SELECT, function(e:Event):void {
				f.addEventListener(Event.COMPLETE, function(e:Event):void {
					func(f.data);
				});
				f.load();
			});
			return f;
		}
		
		private function startRenderingVercities():void
		{
			// 各マウスイベント
			_hitArea.addEventListener(MouseEvent.MOUSE_DOWN, amouseDownHandler);
			_hitArea.addEventListener(MouseEvent.MOUSE_MOVE, amouseMoveHandler);
			_hitArea.addEventListener(MouseEvent.MOUSE_UP, amouseUpHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, kayUpHandler);
		}
		
		private var _ctrlKey:Boolean;
		
		private function keyDownHandler(e:KeyboardEvent):void
		{
			if ( e.keyCode == 17 ) _ctrlKey = true;
		}
		
		private function kayUpHandler(e:KeyboardEvent):void
		{
			if ( e.keyCode == 17 ) _ctrlKey = false;
		}
		
		/**
		 * 頂点に力をかける (詳しくは本を見てください)
		 *
		 * @param power かける力
		 * @param vertices 力をかける頂点
		 */
		private function addPower(power:Rectangle, vertices:Array, _forces:Array):void
		{
			// 力の開始点
			var px:Number = power.x;
			var py:Number = power.y;
			// 力のベクトル (矢印)
			var vx:Number = power.width;
			var vy:Number = power.height;
			
			// 力のベクトルの長さ
			var vl:Number = Math.sqrt(vx * vx + vy * vy);
			// 正規化された力のベクトル
			var nvx:Number = vl != 0 ? vx / vl : 0;
			var nvy:Number = vl != 0 ? vy / vl : 0;
			
			// 各頂点について
			for (var i:uint = 0; i < _vertices.length; ++i) {
				// 頂点を取り出す
				var baseX:Number = _vertices[i].x;
				var baseY:Number = _vertices[i].y;
				
				// 力の開始点から頂点までの距離ベクトル
				var dx:Number = baseX - px;
				var dy:Number = baseY - py;
				var d:Number = dx * dx + dy * dy;
				// 力の開始点から頂点までの距離ベクトルの長さ
				var dl:Number = Math.sqrt(d);
				// 正規化された力の開始点から頂点までの距離ベクトル
				var ndx:Number = dl != 0 ? dx / dl : 0;
				var ndy:Number = dl != 0 ? dy / dl : 0;
				
				// 力のベクトルと力の開始点から頂点までの距離ベクトルとの角度
				var t:Number = Math.atan2(nvx * ndy - nvy * ndx, nvx * ndx + nvy * ndy);
				// 0度のとき 1.0 〜 45度の時 0.0 になる係数
				var f:Number = 1.0 - Math.abs(t) / (Math.PI / 4);
				if (f < 0) {
					f = 0;
				}
				
				// 影響範囲の長さ
				var l:Number = 120.0 * (1.0 + f * 1.2);
				
				// 力の開始点から頂点までの距離が影響範囲内であれば 1.0 に近づく係数
				var factor:Number = 1.0 - d / (l * l);
				if (factor < 0) {
					factor = 0;
				}
				
				// 力と係数を掛け合わせて頂点の座標に足して移動させる
				//_vertices[i].x = baseX + vx * factor;
				_vertices[i].x = baseX + vx * _forces[i] * factor;
				//_vertices[i].y = baseY + vy * factor;
				_vertices[i].y = baseY + vy * _forces[i] * factor;
			}
		}
		
		/**
		 * 各頂点にかかる力を計算する (詳しくは本を見てください)
		 */
		private function calcEnergy():void
		{
			for (var i:uint = 0; i < _vertices.length; ++i) {
				_energies[i].x = (_energies[i].x + (_poweredVertices[i].x - _vertices[i].x)) * 0.4;
				_energies[i].y = (_energies[i].y + (_poweredVertices[i].y - _vertices[i].y)) * 0.4;
				
				_vertices[i].x += _energies[i].x;
				_vertices[i].y += _energies[i].y;
			}
		}
		
		/**
		 * ENTER_FRAME でレンダリング (詳しくは本を見てください)
		 */
		private function enterFrameHandler(e:Event):void
		{
			// 頂点データを元に戻す
			for (var i:uint = 0; i < _vertices.length; ++i) {
				_poweredVertices[i].x = _poweredVertices[i].x;
				_poweredVertices[i].y = _poweredVertices[i].y;				
			}
						
			// 力があればかける
			if (_power != null) {
				addPower(_power, _poweredVertices, _forces);
			}
			
			// 慣性の計算
			calcEnergy();
			
			//_plane.yaw(1);
		}
		
		/**
		 * マウス押し下げイベント
		 */
		private function amouseDownHandler(e:MouseEvent):void
		{
			if (!_ctrlKey) return;
			if (_power == null) {
				_power = new Rectangle();				
				_power.x = viewport.interactiveSceneManager.mouse3D.x;
				_power.y = viewport.interactiveSceneManager.mouse3D.y;
			}
		}
		
		/**
		 * マウス移動イベント
		 */
		private function amouseMoveHandler(e:MouseEvent):void
		{
			if (!_ctrlKey) return;
			if (_power != null) {
				_power.width = (viewport.interactiveSceneManager.mouse3D.x - _power.x) / 1.5;
				_power.height = (viewport.interactiveSceneManager.mouse3D.y - _power.y) / 1.5;
			}
		}
		
		/**
		 * マウス押し上げイベント
		 */
		private function amouseUpHandler(e:MouseEvent):void
		{
			if (_power != null) {
				_power = null;
			}
		}
		
		/**
		 * マウスステージ外イベント
		 */
		private function mouseLeaveHandler(e:Event):void
		{
			mouseUpHandler(null);
		}
		
		private var pheight:Number = 0;
		private var pointArray:Array = [];
		
		private function heightSlideHandler( e:Event ):void
		{
			pheight = e.target.value / 100;
			updateVertices();
		}
		
		private function updateVertices():void
		{
			for ( var i:int = 0; i < pointArray.length; i++ ) 
			{
				_plane.geometry.vertices[i].z = pointArray[i] * pheight;
			}
		}
		
		private var _lastRotationX:Number = 0;
		private var _lastRotationY:Number = 0;
		
		private function draw2d( e:Event = null ):void
		{
			addChildAt(_paint, getChildIndex(viewport) + 2);
			_make3dButton.visible = true;
			_draw2dButton.visible = false;
			_heightSlider.visible = false;
			_loadMapDataButton.visible = true;
			
			for ( var i:int = 0; i < pointArray.length; i++ ) 
			{
				_plane.geometry.vertices[i].z = 0;
			}
			
			_lastRotationX = _plane.rotationX;
			_lastRotationY = _plane.rotationY;
			
			_plane.rotationX = 0;
			_plane.rotationY = 0;
			
			_hitArea.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function make3d( e:Event ):void
		{
			_plane.rotationX = _lastRotationX;
			_plane.rotationY = _lastRotationY;
			
			removeChild( _paint );
			_make3dButton.visible = false;
			_draw2dButton.visible = true;
			_heightSlider.visible = true;
			_loadMapDataButton.visible = false;
			
			var pcanvas:BitmapData = new BitmapData( _imageWidth, _imageHeight, false, 0x000000 );
			pcanvas.draw( _canvas );
			
			var s:int = 0;
			
			for ( var i:int = 0; i <= _plane.segmentsW; i++ ) 
			{
				for ( var j:int = _plane.segmentsH; j >= 0; j-- ) 
				{
					var xp:int = _imageWidth * ( i / _plane.segmentsW );
					xp = xp < _imageWidth ? xp : _imageWidth -1;
					var yp:int = _imageHeight * ( j / _plane.segmentsH );
					yp = yp < _imageHeight ? yp : _imageHeight -1;
					pointArray[s] = - ( pcanvas.getPixel( xp, yp ) >> 16);
					_forces[s] = -pointArray[s] / 100;
					s++;
				}
			}
			
			updateVertices();
			
			_hitArea.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function loader(func:Function):Loader {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function():void { func(loader); } );
			return loader;
		}
		
		private function setCanvas(loader:Loader):void {
				
			var image:BitmapData = Bitmap(loader.content).bitmapData;
			var bmd:BitmapData = new BitmapData(_imageWidth, _imageHeight, true, 0x0);
			var matrix:Matrix = new Matrix();
			
			var rate:Number = image.width / image.height;
			var scale:Number;
			if ( rate > 1 ) {
				scale = _imageWidth / image.width;
				matrix.translate(0, (_imageWidth - (scale * image.height)) / 2);
			}
			else if ( rate < 1 ) {
				scale = _imageHeight / image.height;
				matrix.translate((_imageWidth - (scale * image.width)) / 2, 0);
			}
			else if ( rate == 1 ) {
				scale = _imageWidth / image.width;
			}
			
			matrix.scale(scale, scale);
			bmd.draw( image, matrix);
			image.dispose();
			image = null;
			
			if (_material != null) _material.destroy();
			_material = new BitmapMaterial( bmd );
			_plane.material = _material;
			_material.interactive = true;
			_material.doubleSided = true;
			
			loader.unload();
			
		}
		
		private function setMapData(loader:Loader):void {
			var bmd:Bitmap = Bitmap(loader.content);
			_canvas.copyPixels( bmd.bitmapData, new Rectangle(0, 0, _imageWidth, _imageHeight), new Point() );
			bmd.bitmapData.dispose();
			bmd = null;
			loader.unload();
		}
		
		private function mouseDownHandler( e:Event ):void
		{
			if (_ctrlKey) return;
			curX = mouseX;
			curY = mouseY;
			addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
		}
		
		private function mouseUpHandler( e:MouseEvent ):void
		{
			removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
		}
		
		private var curX:Number = 0;
		private var curY:Number = 0;
		
		private function mouseMoveHandler( e:MouseEvent ):void 
		{
			_plane.rotationY += ( curX - mouseX );
			_plane.rotationX -= ( curY - mouseY );
			
			curX = mouseX;
			curY = mouseY;
		}
	}
}





import com.bit101.components.*;
import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;

class Paint extends Sprite
{
	
	private var _brush:Brush;
	private var _pointer:Pointer;
	private var _drawField:Sprite;
	private var _background:Bitmap;
	private var _canvas:BitmapData;
	private var _imageHeight:Number;
	private var _imageWidth:Number;
	private var _blurButton:PushButton;
	
	public function Paint( canvas:BitmapData, imageWidth:Number, imageHeight:Number )
	{
		_canvas = canvas;
		_imageWidth = imageWidth;
		_imageHeight = imageHeight;
	}

	public function init():void
	{
		
		var hitArea:Sprite = new Sprite();
		hitArea.graphics.beginFill( 0x0, 0 );
		hitArea.graphics.drawRect( 0, 0, _imageWidth, _imageHeight );
		hitArea.graphics.endFill();
		addChild( hitArea );
		hitArea.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
		stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
		
		this.x = stage.stageWidth - _imageWidth >> 1;
		this.y = stage.stageHeight - _imageHeight >> 1;
		
		_brush = new Brush( 50, 0xFF0000, .5 );
		
		_drawField = new Sprite();
		addChild( _drawField );
		
		var bitmap:Bitmap = new Bitmap(_canvas);
		addChild(bitmap)
		
		_pointer = new Pointer( _brush.thickness );
		addChild( _pointer );
		hitArea.addEventListener( MouseEvent.MOUSE_MOVE, drawPointer);
		
		_blurButton = new PushButton( this, 0, 0, "Blur", blurBitmapData );
		
		var clearButton:PushButton = new PushButton( this, 150, 0, "Clear", clearHandler );
		
		var thicknessSlider:HUISlider = new HUISlider( this, 0, 30, "Thickness", thicknessSliderHandler );
		thicknessSlider.value = 50;
		
		var alphaSlider:HUISlider = new HUISlider( this, 0, 50, "Alpha", alphaSlider );
		alphaSlider.value = 50;
		
	}
	
	private function clearHandler( e:Event ):void
	{
		_canvas.fillRect( _canvas.rect, 0x0 );
	}
	
	private function alphaSlider( e:Event ):void
	{
		_brush.alpha = e.target.value/100;
	}
	
	private function thicknessSliderHandler( e:Event ):void
	{
		_brush.thickness = _pointer.thickness =  e.target.value;
		_pointer.update();
	}
	
	private function blurBitmapData( e:Event ):void
	{
		_canvas.applyFilter(_canvas, _canvas.rect, new Point, new BlurFilter( 32, 32, 4 ));
	}
	
	private function drawPointer(e:Event):void
	{
		_pointer.x = mouseX;
		_pointer.y = mouseY;
		if ( mouseX < 0 || mouseX > _imageWidth || mouseY < 0 || mouseY > _imageHeight ) {
			_pointer.visible = false;
		}
		else {
			_pointer.visible = true;
		}
	}
	
	private function mouseDownHandler( e:MouseEvent ):void
	{
		_pointer.alpha = 0;
		_drawField.graphics.lineStyle( _brush.thickness, _brush.color, _brush.alpha );
		_drawField.graphics.moveTo( mouseX, mouseY + .2 );
		_drawField.graphics.lineTo( mouseX, mouseY );
		_drawField.addEventListener( Event.ENTER_FRAME, drawingHandler );
	}
	
	private function mouseUpHandler( e:MouseEvent ):void
	{
		_pointer.alpha = 1;
		_drawField.graphics.endFill();
		_canvas.draw( _drawField );
		_drawField.graphics.clear();
		_drawField.removeEventListener(Event.ENTER_FRAME, drawingHandler );
	}
	
	private function drawingHandler( e:Event ):void
	{
		_drawField.graphics.lineTo( mouseX, mouseY );
	}
	
}



import flash.display.Shape;

class Pointer extends Shape
{
	public var thickness:uint = 1;
	
	public function Pointer( thickness:uint = 10 )
	{
		this.thickness = thickness;
		this.blendMode = BlendMode.INVERT;
		update();
	}
	
	public function update():void
	{
		graphics.clear();
		
		graphics.lineStyle( 1, 0x000000, .5, false) 
		graphics.drawCircle( 0, 0, thickness/2 );
		graphics.endFill();
	}
	
}



class Brush 
{
	public var thickness:uint = 1;
	public var color:uint = 0x000000;
	public var alpha:Number = alpha;
	
	public function Brush( thickness:uint = 10, color:uint = 0xFF0000, alpha:Number = 1 )
	{
		this.thickness = thickness;
		this.color = color;
		this.alpha = alpha;
	}
	
}

