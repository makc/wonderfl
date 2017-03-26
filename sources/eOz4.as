/* 
 * 1. 画像の上を適当にドラッグして色を塗る
 * 2. 左上 Blur ボタンをクリックすればなめらか
 * 3. 満足いくまで塗ったら、左下 Make3D ボタンをクリック
 * 4. 画像をドラッグして回転したり、下の Height スライダを動かすなど
 * 5. 好きな画像を読み込んでみると楽しいかも
 */

package
{
	import adobe.utils.CustomActions;
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
	import org.papervision3d.core.math.*;
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
		
		public function Main():void
		{			
			stage.quality = StageQuality.MEDIUM;
			
			_imageWidth = _imageHeight = 465;
			
			/*
			var stats:Stats = new Stats();
			stats.x = -80;
			addChild(stats);
			*/
			
			super( _imageWidth,_imageHeight, false, false, CameraType.TARGET );
			
			init();
			
			loadImage("http://assets.wonderfl.net/images/related_images/7/78/7819/781939489515eb746625f701e5ee4731f69f0fbd");
		}
		
		private function init():void
		{
			_canvas = new BitmapData( _imageWidth, _imageHeight, true, 0x00000000 );
			
			_paint = new Paint( _canvas, _imageWidth, _imageHeight );			
			addChild(_paint);
			_paint.init();
			
			_plane = new Plane( new WireframeMaterial(0x00FF00,1), _imageWidth, _imageHeight, Math.floor( _imageWidth / 10 ), Math.floor( _imageHeight / 10 ) );

			scene.addChild( _plane );
			
			var loadButton:PushButton = new PushButton(this, stage.stageWidth - 100, 0, "Load Image", function():void {
				var f:FileReference = new FileReference();
				f.addEventListener(Event.SELECT, function(e:Event):void {
					f.addEventListener(Event.COMPLETE, function(e:Event):void {
						loadFile(f.data);
					});
					f.load();
				});
				f.browse();
			});
			
			var saveMapDataButton:PushButton = new PushButton(this, stage.stageWidth - 100, 20, "Save Map Data", function():void {
				var encoder:PNGEncoder = new PNGEncoder();
				var bytes:ByteArray = encoder.encode(_canvas);
				var fileReference:FileReference = new FileReference();
				fileReference.addEventListener(Event.OPEN, function(e:Event):void { trace("open");  } );
				fileReference.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void { trace("progress");  } );
				fileReference.addEventListener(Event.COMPLETE, function(e:Event):void { trace("complete");  } );
				fileReference.addEventListener(Event.CANCEL, function(e:Event):void { trace("cancel");  } );
				fileReference.addEventListener(Event.SELECT, function(e:Event):void { trace("select");  } );
				fileReference.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void { trace("ioError");  } );
				fileReference.save(bytes, "map" + new Date().valueOf() +".png");
			});
						
			_loadMapDataButton = new PushButton(this, stage.stageWidth - 100, 40, "Load Map Data", function():void {
				var f:FileReference = new FileReference();
				f.addEventListener(Event.SELECT, function(e:Event):void {
					f.addEventListener(Event.COMPLETE, function(e:Event):void {
						
						var loader:Loader = new Loader();
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
							var image:BitmapData = Bitmap(loader.content).bitmapData;
							_canvas.copyPixels( image, image.rect, new Point );
							loader.unload();
						});
						
						loader.loadBytes(f.data);
						
					});
					f.load();
				});
				f.browse();
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
			
			draw2d();
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
					s++;
				}
			}
			
			updateVertices();
			
			_hitArea.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
		}
		
		private function get loader():Loader {
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
				
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
				bmd.draw( loader.content, matrix);
				
				if (_material != null) _material.destroy();
				_material = new BitmapMaterial( bmd );
				_plane.material = _material;
				_material.doubleSided = true;
				
				loader.unload();
			});
			return loader;
		}
		
		private function loadFile(bytes:ByteArray):void
		{
			loader.loadBytes(bytes);
		}
		
		private function loadImage(url:String ):void
		{
			loader.load(new URLRequest(url), new LoaderContext(true));
		}
		
		private function mouseDownHandler( e:Event ):void
		{	
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
		
		_brush = new Brush( 25, 0xFF0000, .5 );
		
		_drawField = new Sprite();
		addChild( _drawField );
		
		var bitmap:Bitmap = new Bitmap(_canvas);
		addChild(bitmap)
		
		_pointer = new Pointer( _brush.thickness );
		addChild( _pointer );
		addEventListener( Event.ENTER_FRAME, drawPointer);
		
		_blurButton = new PushButton( this, 0, 0, "Blur", blurBitmapData );
		
		var clearButton:PushButton = new PushButton( this, 150, 0, "Clear", clearHandler );
		
		var thicknessSlider:HUISlider = new HUISlider( this, 0, 30, "Thickness", thicknessSliderHandler );
		thicknessSlider.value = 25;
		
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
		removeEventListener( Event.ENTER_FRAME, drawPointer);
		_pointer.alpha = 0;
		_drawField.graphics.lineStyle( _brush.thickness, _brush.color, _brush.alpha );
		_drawField.graphics.moveTo( mouseX, mouseY + .2 );
		_drawField.graphics.lineTo( mouseX, mouseY );
		_drawField.addEventListener( Event.ENTER_FRAME, drawingHandler );
	}
	
	private function mouseUpHandler( e:MouseEvent ):void
	{
		addEventListener( Event.ENTER_FRAME, drawPointer);
		_pointer.alpha = 1;
		_drawField.graphics.endFill();
		_canvas.draw( _drawField );
		_drawField.graphics.clear();
		_drawField.removeEventListener( Event.ENTER_FRAME, drawingHandler );
	}
	
	private function drawingHandler( e:Event = null ):void
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

