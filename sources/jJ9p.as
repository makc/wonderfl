package  
{
	import fl.motion.easing.*;
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.Point;
	import flash.text.*;
	import gs.TweenMax;
	import org.papervision3d.core.effects.BitmapLayerEffect;
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.core.geom.renderables.Pixel3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	
	[SWF(width="465", height="465", backgroundColor="0x000000", frameRate="60")]
	/**
	 * いま LA で大人気のunkoをクリックではじき飛ばそう！コードはクソ汚いYO!
	 * @author katapad
	 * @version 0.1
	 * @since 2009/10/06 19:06
	 */
	public class UnkoField extends BasicView 
	{
		//----------------------------------
		//  static var/const
		//----------------------------------
		private static const _TEXT_SIZE:Number = 40;
		
		//----------------------------------
		//  instance var 
		//----------------------------------
		private var _root:DisplayObject3D;
		private var _defaultForm:Boolean;
		private var _pixelList:Array;
		private var _textPosList:Array;
		
		/**
		 * コンストラクタ
		 */
		public function UnkoField() 
		{
			if (!stage)
				addEventListener(Event.ADDED_TO_STAGE, init);
			else
				init();
		}
		
		/**
		 * 初期化
		 */
		private function init(event:Event = null):void 
		{
    
                        //facebook背景問題用
			graphics.beginFill(0x0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
                        
			removeEventListener(Event.ADDED_TO_STAGE, init);
			_defaultForm = true;
			initScene();
			createText();
			
			setupInteraction();
			startRendering();
		}
		
		//--------------------------------------------------------------------------
		//
		//  OVERRIDE
		//
		//--------------------------------------------------------------------------
		override protected function onRenderTick(event:Event = null):void 
		{
			super.onRenderTick(event);
			_root.rotationX += ( -viewport.containerSprite.mouseX - _root.rotationX) * 0.1; 
            _root.rotationY += ( -viewport.containerSprite.mouseY - _root.rotationY) * 0.1;
            _root.rotationZ += ( -viewport.containerSprite.mouseY - _root.rotationZ) * 0.05;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE
		//
		//--------------------------------------------------------------------------
		private function initScene():void
		{
			_root = scene.addChild(new DisplayObject3D());
			_camera.z = -70;
		}
		
		private function createText():void
		{
			_textPosList = getTextPos();
			
			var bfx:BitmapEffectLayer = new BitmapEffectLayer(viewport, stage.stageWidth, stage.stageHeight, true, 0, "clear_pre", false, false);
            bfx.drawCommand.blendMode = BlendMode.ADD;
            bfx.addEffect(new BitmapLayerEffect(new BlurFilter(8, 8, BitmapFilterQuality.MEDIUM), false));
            viewport.containerSprite.addLayer(bfx);
			
			var pixels:Pixels  = new Pixels(bfx);
			_pixelList = [];
			_root.addChild(pixels);
			for (var i:int = 0, n:int = _textPosList.length; i < n; ++i) 
			{
				var pxd:PxData = _textPosList[i];
				var px:Pixel3D = new Pixel3D(pxd.color, pxd.x, pxd.y, 0);
				pixels.addPixel3D(px);
				_pixelList[i] = px;
			}
			
			bfx.addDisplayObject3D(pixels);
		}
		
		private function getTextPos():Array
		{
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("_sans", _TEXT_SIZE, 0xFFFFFF, true);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = "unko";
			
			var bmd:BitmapData = new BitmapData(tf.textWidth + 2, tf.textHeight, true, 0x00000000);
			bmd.draw(tf);
			
			var result:Array = [];
			for (var i:int = 0, n:int = bmd.width; i < n; ++i) 
			{
				for (var j:int = 0, m:int = bmd.height; j < m; ++j) 
				{
					var color:uint = bmd.getPixel(i, j);
					if (color)
					{
						switch (i % 3) 
						{
							case 0:
								color = 0xFFEF8080;
								break;
							case 1:
								color = 0xFF80EF80;
								break;
							case 2:
								color = 0xFF8080EF;
								break;
						}
						result.push(new PxData(i  - n * 0.5, j - m * 0.5, color));
					}
				}
			}
			return result;
		}
		
		private function setupInteraction():void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		private function downHandler(event:MouseEvent):void 
		{
			if (_defaultForm)
				explosion();
			else
				defaultPosition();
		}
		
		private function explosion():void
		{
			_defaultForm = false;
			for (var i:int = 0, n:int = _pixelList.length; i < n; ++i) 
			{
				var px:Pixel3D = _pixelList[i];
				TweenMax.to(px, 1.5, { x: Math.random() * 300 - 150, y: Math.random() * 300 - 150, z: Math.random() * 300 - 150, ease: Quintic.easeOut, delay: 0.0001 * i, overwrite: true});
			}
		}
		
		private function defaultPosition():void
		{
			_defaultForm = true;
			for (var i:int = 0, n:int = _pixelList.length; i < n; ++i) 
			{
				var px:Pixel3D = _pixelList[i];
				var pxd:PxData = _textPosList[i];
				TweenMax.to(px, 0.7, { x: pxd.x, y: pxd.y, z: 0, ease: Quintic.easeOut, delay: 0.0005 * i, overwrite: true });
			}
		}
		
	}
	
}
class PxData
{
	public var x:Number;
	public var y:Number;
	public var color:uint;
	function PxData(x:Number, y:Number, color:uint)
	{
		this.x = x;
		this.y = y;
		this.color = color;
	}
	
}
