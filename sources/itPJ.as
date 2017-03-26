/*
 * milkmidi
 * http://milkmidi.com  
 * */
package   {			
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.net.URLRequest;		
	import caurina.transitions.Tweener;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;	
	import flash.system.LoaderContext;
	import flash.utils.setTimeout;
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.materials.BitmapMaterial;			
	import org.papervision3d.objects.primitives.Plane;	
	import org.papervision3d.view.BasicView;
	[SWF(width = "465", height = "465", frameRate = "31", backgroundColor = "#000000")]
	public class  CameraOrbit extends BasicView {					
		private var _sourceBmp1		:BitmapData;
		private var _sourceBmp2		:BitmapData;	
		private var _displayWidth	:int = 465;
		private var _displayHeight	:int = 465;
		public var camOrbitY		:Number = 270;	
		private var _disArr			:Array = [];	
	
		
		public function CameraOrbit()  {			
			super(0, 0, true, false);	
			loadingImg();	
		}		
		private function loadingImg():void {
			var _ldr:Loader = new Loader();
			_ldr.load(new URLRequest("http://assets.wonderfl.net/images/related_images/e/e1/e18c/e18ca4ebe44ad3c5aa082cbd2742c8581cafcf86"),new LoaderContext(true ));
			_ldr.contentLoaderInfo.addEventListener(Event.COMPLETE , _completeHandler);
			_ldr = new Loader();
			_ldr.load(new URLRequest("http://assets.wonderfl.net/images/related_images/e/ee/eed8/eed824227b0f145757eb3dd9b03027d90829cca6"),new LoaderContext(true ));
			_ldr.contentLoaderInfo.addEventListener(Event.COMPLETE , _completeHandler);
		}
		
		private function _completeHandler(e:Event):void {
			_disArr.push(Bitmap(e.currentTarget.loader.content).bitmapData);			
			if (_disArr.length>=2) {
				initObject();
				init3DObjects();			
				startRendering();		
			}
		}
		private function initObject():void{					
			_sourceBmp1 = _disArr[0];
			_sourceBmp2 = _disArr[1];	
		}			
		
		private function init3DObjects():void {												
			var _col		:int = 12;						
			var _row		:int = 10;					
			var _w			:int = _displayWidth / _col;			
			var _h			:int = _displayHeight / _row;			
			var _frontMat	:BitmapMaterial;
			var _backMat	:BitmapMaterial;
			var _precisePositionZ:Number = camera.focus * camera.zoom - Math.abs(camera.z);			
		
			for (var i:int = 0; i < _col; i++) {
				for (var j:int = 0; j < _row; j++) {
					var _bmp1		:BitmapData = new BitmapData(_w, _h, false, 0);
					var _matrix1	:Matrix = new Matrix();
					_matrix1.translate( i * -_w, (_row - j - 1) * -_h);					
					
					var _bmp2		:BitmapData = new BitmapData(_w, _h, false, 0);
					var _matrix2	:Matrix = new Matrix();					
					_matrix2.translate( (_col - i) * -_w, (_row - j - 1) * -_h);		
					_matrix2.scale( -1, 1);					
					_bmp1.draw( _sourceBmp1, _matrix1 );	
					_bmp2.draw( _sourceBmp2, _matrix2 );						
					_frontMat = new BitmapMaterial(_bmp1);
					_backMat  = new BitmapMaterial(_bmp2);	
										
					var _dMat	:DoubleSidedCompositeMaterial = new DoubleSidedCompositeMaterial(_frontMat, _backMat);
					//雙面材質
					var _d3d	:Plane  = new Plane(_dMat, _w, _h);
					scene.addChild( _d3d );																			
					_d3d.x = i * _w - (_col / 2 * _w) + _w / 2;											
					_d3d.y = j * _h  - (_row / 2 * _h) + _h / 2;										
					_d3d.z = _precisePositionZ;
					_d3d.extra = 
					{
						x:_d3d.x,
						y:_d3d.y,
						z:_d3d.z
					};					
					Tweener.addTween(_d3d, 
					{
						x			:random(-2000, 2000),
						y			:random(-2000, 2000),
						z			:random(-2000, 2000),
						rotationX	:random( -360, 360),						
						rotationY	:random( -360, 360),						
						rotationZ	:random( -360, 360),						
						delay		:0.06 * i + 1,												
						time		:1.6, 
						transition  :"easeInOutCubic",
						onComplete	:pv3dObjectTweenComplete,
						onCompleteParams:[_d3d]						
					} );
				}
			}						
			Tweener.addTween(this,
			{
				camOrbitY		:450,				
				time			:2.8,
				delay			:2,
				transition  :"easeOutCubic",
				onUpdate     	:function ():void {
					camera.orbit(90, camOrbitY);					
				}				
			} );
		}
		public static function random(pMin:Number, pMax:Number , pRound:Boolean = true):Number	{				
			var _number:Number = Math.random() * (pMax - pMin) + pMin;			
			return pRound ?  int(_number) : _number;						
		}	
		private function pv3dObjectTweenComplete(pD3D:Plane):void{
			Tweener.addTween(pD3D,
			{
				x			:pD3D.extra.x,
				y			:pD3D.extra.y,
				z			:pD3D.extra.z * -1,					
				time		:1.2,
				rotationX	:0,
				rotationY	:0,
				rotationZ	:0				
			} );
		}
		override protected function onRenderTick(event:Event = null):void {
			super.onRenderTick(event);
		}
	}
}

/** 
* copy right By http://www.nabble.com/attachment/16002163/0/DoubleSidedCompositeMaterial.as 
*  
* fix to Papervision3D ActionScript 3.0 Library .ZIP rev 839  
* http://papervision3d.googlecode.com/files/Papervision3D_rev839.zip 
*  
* Mark in 2008.12.28 By tenchiwang 
*  
* modify milkmidi 
*/  
import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;	
	import org.papervision3d.core.render.command.RenderTriangle; 
	import org.papervision3d.core.geom.renderables.Vertex3DInstance;
	import org.papervision3d.core.material.TriangleMaterial;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.ITriangleDrawer;

	class DoubleSidedCompositeMaterial extends TriangleMaterial implements ITriangleDrawer
	{
		protected var materials:Array;		
		public function DoubleSidedCompositeMaterial(pFrontMaterial:MaterialObject3D, pBackMaterial:MaterialObject3D)		
		{			
			_initialize();
			if (pFrontMaterial) {
				this.addMaterial(pFrontMaterial);
			}
			if (pBackMaterial) {
				pBackMaterial.opposite = true;
				this.addMaterial(pBackMaterial);
			}			
			this.doubleSided = true;
		};
		
		private function _initialize():void	{
			materials = new Array();
		};
		
		private function addMaterial(material:MaterialObject3D):void{
			materials.push(material);
		};				
        override public function drawTriangle(face3D:RenderTriangle, graphics:Graphics, renderSessionData:RenderSessionData, altBitmap:BitmapData=null, altUV:Matrix = null):void		
		{
			var vertex0:Vertex3DInstance;
			var vertex1:Vertex3DInstance;
			var vertex2:Vertex3DInstance;
			var x0:Number;
			var y0:Number;
			var x1:Number;
			var y1:Number;
			var x2:Number;
			var y2:Number;
			var draw:Boolean;
			
			var material:MaterialObject3D;
			
			for each(material in materials) {				
				draw = true;
				vertex0 = face3D.v0.clone();
				vertex1 = face3D.v1.clone();
				vertex2 = face3D.v2.clone();
				
				x0 = vertex0.x;
				y0 = vertex0.y;
				x1 = vertex1.x;
				y1 = vertex1.y;
				x2 = vertex2.x;
				y2 = vertex2.y;
				
				if( material.opposite ) {
					if( ( x2 - x0 ) * ( y1 - y0 ) - ( y2 - y0 ) * ( x1 - x0 ) > 0 ) {
						draw = false;
					};
				} else 	{
					if( ( x2 - x0 ) * ( y1 - y0 ) - ( y2 - y0 ) * ( x1 - x0 ) < 0 ) {
						draw = false;
					};
				};
				
				if (draw && material != null) {					
					material.drawTriangle(face3D, graphics, renderSessionData);
				};
			};
		};
	};


