/**
 * BoundaryResizerクラスを利用したリサイズ
 * 
 * このswfは下記URLで紹介している自作クラスのサンプルコードです
 * @see http://blog.alumican.net/2009/10/07_225251
 * 
 * @author alumican.net<Yukiya Okuda>
 */
package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import com.bit101.components.Label;
	import com.bit101.components.RadioButton;
	import com.bit101.components.PushButton;
	import flash.system.Security;
	
	[SWF(width = 465, height = 465, backgroundColor = 0xffffff, frameRate = 30)]
	public class BoundaryResizerDemo extends Sprite
	{
		//----------------------------------------
		//CLASS CONSTANTS
		
		private const W:uint = 465;
		private const H:uint = 465;
		
		
		
		
		
		//----------------------------------------
		//VARIABLES
		
		private var _picture:Bitmap;
		private var _border:Sprite;
		
		private var _scaleMode:String = BoundaryResizer.NO_SCALE;
		private var _align:String     = BoundaryResizer.CENTER;
		
		
		
		
		
		//----------------------------------------
		//METHODS
		
		private function _resize():void
		{
			var boundary:Rectangle = _border.getRect(this);
			var target:Rectangle   = _picture.bitmapData.rect;
			
			//IMPORTANT HERE--------------------------
			var resized:Rectangle = BoundaryResizer.resize(target, boundary, _scaleMode, _align);
			//----------------------------------------
			
			_picture.x      = resized.x;
			_picture.y      = resized.y;
			_picture.width  = resized.width;
			_picture.height = resized.height;
		}
		
		public function BoundaryResizerDemo():void 
		{
			Security.loadPolicyFile("http://swf.wonderfl.net/crossdomain.xml");
			
			var vBmd:BitmapData, hBmd:BitmapData;
			
			_picture = addChild(new Bitmap()) as Bitmap;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				var bmd:BitmapData = new BitmapData(W, H, true, 0x00000000);
				bmd.draw(loader);
				var rect:Rectangle = bmd.getColorBoundsRect(0xffffffff, 0x00000000, false);
				
				vBmd = new BitmapData(rect.width - 40, rect.height + 40, true, 0xff80ff80);
				vBmd.draw(bmd, new Matrix(0.84, 0, 0, 0.84, -rect.x + 17, -rect.y + 57), null, null, null, true);
				
				hBmd = new BitmapData(rect.width + 100, rect.height - 80, true, 0xff80ff80);
				hBmd.draw(bmd, new Matrix(0.72, 0, 0, 0.72, -rect.x + 115, -rect.y + 25), null, null, null, true);
				
				_picture.bitmapData = vBmd;
				_picture.smoothing = true;
				
				e.target.removeEventListener(e.type, arguments.callee);
				loader = null;
				
				_resize();
			} );
			loader.load(new URLRequest("http://swf.wonderfl.net/static/assets/checkmate04/AmateurAssets.swf"));
			
			_border = addChild(new Sprite()) as Sprite;
			var g:Graphics = _border.graphics;
			g.lineStyle(2, 0xff0000);
			g.drawRect(0, 0, 290, 290);
			_border.x = int((W - _border.width) / 2);
			_border.y = 60;
			
			var title:Label = new Label(this, 0, -8, "BoundaryResizer Demo");
			title.scaleX = title.scaleY = 2;
			
			new PushButton(this, W - 99 - 10, 19 * 0 + 10, "Vertical Image"  , function():void { _picture.bitmapData = vBmd; _picture.smoothing = true; _resize(); } );
			new PushButton(this, W - 99 - 10, 19 * 1 + 10, "Horizontal Image", function():void { _picture.bitmapData = hBmd; _picture.smoothing = true; _resize(); } );
			
			var label0:Label = new Label(this, 10, H - 19 * 5 - 10, "scaleMode : NO_SCALE");
			new PushButton(this, 10, H - 19 * 4 - 10, "EXACT_FIT", function():void { _scaleMode = BoundaryResizer.EXACT_FIT; _resize(); label0.text = "scaleMode : EXACT_FIT"; } );
			new PushButton(this, 10, H - 19 * 3 - 10, "SHOW_ALL" , function():void { _scaleMode = BoundaryResizer.SHOW_ALL;  _resize(); label0.text = "scaleMode : SHOW_ALL";  } );
			new PushButton(this, 10, H - 19 * 2 - 10, "NO_BORDER", function():void { _scaleMode = BoundaryResizer.NO_BORDER; _resize(); label0.text = "scaleMode : NO_BORDER"; } );
			new PushButton(this, 10, H - 19 * 1 - 10, "NO_SCALE" , function():void { _scaleMode = BoundaryResizer.NO_SCALE;  _resize(); label0.text = "scaleMode : NO_SCALE";  } );
			
			var label1:Label = new Label(this, W - 99 * 3 - 10, H - 19 * 4 - 10, "align : CENTER");
			new PushButton(this, W - 99 * 3 - 10, H - 19 * 3 - 10, "TOP_LEFT"    , function():void { _align = BoundaryResizer.TOP_LEFT;     _resize(); label1.text = "align : TOP_LEFT";     } );
			new PushButton(this, W - 99 * 2 - 10, H - 19 * 3 - 10, "TOP"         , function():void { _align = BoundaryResizer.TOP;          _resize(); label1.text = "align : TOP";          } );
			new PushButton(this, W - 99 * 1 - 10, H - 19 * 3 - 10, "TOP_RIGHT"   , function():void { _align = BoundaryResizer.TOP_RIGHT;    _resize(); label1.text = "align : TOP_RIGHT";    } );
			new PushButton(this, W - 99 * 3 - 10, H - 19 * 2 - 10, "LEFT"        , function():void { _align = BoundaryResizer.LEFT;         _resize(); label1.text = "align : LEFT";         } );
			new PushButton(this, W - 99 * 2 - 10, H - 19 * 2 - 10, "CENTER"      , function():void { _align = BoundaryResizer.CENTER;       _resize(); label1.text = "align : CENTER";       } );
			new PushButton(this, W - 99 * 1 - 10, H - 19 * 2 - 10, "RIGHT"       , function():void { _align = BoundaryResizer.RIGHT;        _resize(); label1.text = "align : RIGHT";        } );
			new PushButton(this, W - 99 * 3 - 10, H - 19 * 1 - 10, "BOTTOM_LEFT" , function():void { _align = BoundaryResizer.BOTTOM_LEFT;  _resize(); label1.text = "align : BOTTOM_LEFT";  } );
			new PushButton(this, W - 99 * 2 - 10, H - 19 * 1 - 10, "BOTTOM"      , function():void { _align = BoundaryResizer.BOTTOM;       _resize(); label1.text = "align : BOTTOM";       } );
			new PushButton(this, W - 99 * 1 - 10, H - 19 * 1 - 10, "BOTTOM_RIGHT", function():void { _align = BoundaryResizer.BOTTOM_RIGHT; _resize(); label1.text = "align : BOTTOM_RIGHT"; } );
			
			//＼(^o^)／
			//RadioButton.as : Currently only one group can be created.
			/*
			var scaleModeGroup:Sprite = addChild(new Sprite()) as Sprite;
			scaleModeGroup.x = 10;
			scaleModeGroup.y = H - 16 * 5 - 10;
			new Label(scaleModeGroup, 0, 0, "scaleMode");
			new RadioButton(scaleModeGroup, 0, 16 * 1 + 5, "EXACT_FIT", false, function():void { _scaleMode = BoundaryResizer.EXACT_FIT; _resize(); } );
			new RadioButton(scaleModeGroup, 0, 16 * 2 + 5, "SHOW_ALL" , false, function():void { _scaleMode = BoundaryResizer.SHOW_ALL;  _resize(); } );
			new RadioButton(scaleModeGroup, 0, 16 * 3 + 5, "NO_BORDER", false, function():void { _scaleMode = BoundaryResizer.NO_BORDER; _resize(); } );
			new RadioButton(scaleModeGroup, 0, 16 * 4 + 5, "NO_SCALE" , true , function():void { _scaleMode = BoundaryResizer.NO_SCALE;  _resize(); } );
			
			var alignGroup:Sprite = addChild(new Sprite()) as Sprite;
			alignGroup.x = W - 80 * 3 - 10;
			alignGroup.y = H - 16 * 4 - 10;
			new Label(alignGroup, 0, 0, "align");
			new RadioButton(alignGroup, 80 * 0, 16 * 1 + 5, "TOP_LEFT"    , false, function():void { _align = BoundaryResizer.TOP_LEFT;     _resize(); } );
			new RadioButton(alignGroup, 80 * 1, 16 * 1 + 5, "TOP"         , false, function():void { _align = BoundaryResizer.TOP;          _resize(); } );
			new RadioButton(alignGroup, 80 * 2, 16 * 1 + 5, "TOP_RIGHT"   , false, function():void { _align = BoundaryResizer.TOP_RIGHT;    _resize(); } );
			new RadioButton(alignGroup, 80 * 0, 16 * 2 + 5, "LEFT"        , false, function():void { _align = BoundaryResizer.LEFT;         _resize(); } );
			new RadioButton(alignGroup, 80 * 1, 16 * 2 + 5, "CENTER"      , true , function():void { _align = BoundaryResizer.CENTER;       _resize(); } );
			new RadioButton(alignGroup, 80 * 2, 16 * 2 + 5, "RIGHT"       , false, function():void { _align = BoundaryResizer.RIGHT;        _resize(); } );
			new RadioButton(alignGroup, 80 * 0, 16 * 3 + 5, "BOTTOM_LEFT" , false, function():void { _align = BoundaryResizer.BOTTOM_LEFT;  _resize(); } );
			new RadioButton(alignGroup, 80 * 1, 16 * 3 + 5, "BOTTOM"      , false, function():void { _align = BoundaryResizer.BOTTOM;       _resize(); } );
			new RadioButton(alignGroup, 80 * 2, 16 * 3 + 5, "BOTTOM_RIGHT", false, function():void { _align = BoundaryResizer.BOTTOM_RIGHT; _resize(); } );
			*/
		}
	}
}

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.geom.Rectangle;

/**
 * BoundaryResizer
 * 様々なリサイズをRectangleベースで実行するクラスです．
 * @see http://blog.alumican.net/2009/10/07_225251
 * @author alumican.net<Yukiya Okuda>
 */
internal class BoundaryResizer
{
	//-------------------------------------
	//CLASS CONSTANTS
	
	/**
	 * scaleMode
	 * リサイズ方法を操作するscaleModeには以下の定数を指定できます．
	 */
	static public const EXACT_FIT:String = StageScaleMode.EXACT_FIT; // targetとboundaryが完全に一致するようにリサイズされます．多くの場合，targetの縦横比は保たれません．
	static public const SHOW_ALL:String  = StageScaleMode.SHOW_ALL;  // targetが縦横比を保ち，かつtargetがboundaryの内側にフィットするようにリサイズされます．targetがトリミングされることはありませんが，上下または左右に隙間ができることがあります．
	static public const NO_BORDER:String = StageScaleMode.NO_BORDER; // targetが縦横比を保ち，かつboundaryがtargetの内側にフィットするようにリサイズされます．targetとboundaryの間に隙間ができることはありませんが，targetがトリミングされることがあります．
	static public const NO_SCALE:String  = StageScaleMode.NO_SCALE;  // リサイズがおこなわれず，alignによる基準点合わせのみがおこなわれます．
	
	/**
	 * align
	 * リサイズ後のオブジェクトの基準点を操作するalignには以下の定数を指定できます．
	 */
	static public const TOP_LEFT:String     = StageAlign.TOP_LEFT;     // x軸方向:左  , y軸方向:上
	static public const TOP:String          = StageAlign.TOP;          // x軸方向:中央, y軸方向:上
	static public const TOP_RIGHT:String    = StageAlign.TOP_RIGHT;    // x軸方向:右  , y軸方向:上
	static public const LEFT:String         = StageAlign.LEFT;         // x軸方向:左  , y軸方向:中央
	static public const CENTER:String       = "";                      // x軸方向:中央, y軸方向:中央
	static public const RIGHT:String        = StageAlign.RIGHT;        // x軸方向:右  , y軸方向:中央
	static public const BOTTOM_LEFT:String  = StageAlign.BOTTOM_LEFT;  // x軸方向:左  , y軸方向:下
	static public const BOTTOM:String       = StageAlign.BOTTOM;       // x軸方向:中央, y軸方向:下
	static public const BOTTOM_RIGHT:String = StageAlign.BOTTOM_RIGHT; // x軸方向:右  , y軸方向:下
	
	
	
	
	
	//-------------------------------------
	//METHODS
	
	/**
	 * targetをboundaryに合わせてリサイズした矩形を返します．
	 * リサイズ方法と基準点をscaleMode，alignで指定できます．
	 * @param	target    リサイズ対象オブジェクトの矩形を指定します．(例)リサイズしたい画像の矩形
	 * @param	boundary  リサイズの基準となる矩形を指定します．(例)リサイズ後の画像を収める枠
	 * @param	scaleMode リサイズ時のスケールモードを指定します．このパラメータはStageScaleModeと互換性があります．このパラメータを省略した場合はBoundaryResizer.NO_SCALEとなり，リサイズはおこなわれません．
	 * @param	align     boundaryに対するtargetの基準位置を指定します．このパラメータはStageAlignと互換性があります．このパラメータを省略した場合はBoundaryResizer.CENTERとなり，縦横ともに中央揃えとなります．
	 * @return            リサイズ後の矩形が返されます．target及びboundaryは変更しません．
	 */
	static public function resize(target:Rectangle, boundary:Rectangle, scaleMode:String = "noScale", align:String = ""):Rectangle
	{
		var tx:Number = target.x,
		    ty:Number = target.y,
		    tw:Number = target.width,
		    th:Number = target.height,
		    bx:Number = boundary.x,
		    by:Number = boundary.y,
		    bw:Number = boundary.width,
		    bh:Number = boundary.height;
		
		switch (scaleMode)
		{
			case SHOW_ALL:
			case NO_BORDER:
				var ratioW:Number = bw / tw,
				    ratioH:Number = bh / th,
				    ratio:Number  = (scaleMode == SHOW_ALL) ? ( (ratioW < ratioH) ? ratioW : ratioH ) :
				                                              ( (ratioW > ratioH) ? ratioW : ratioH ) ;
				tw *= ratio;
				th *= ratio;
				break;
			
			case EXACT_FIT:
				return new Rectangle(bx, by, bw, bh);
		}
		
		tx = bx + ( (align == TOP_LEFT    || align == LEFT   || align == BOTTOM_LEFT ) ? 0               :
		            (align == TOP_RIGHT   || align == RIGHT  || align == BOTTOM_RIGHT) ? (bw - tw)       :
		                                                                                 (bw - tw) / 2 ) ;
		ty = by + ( (align == TOP_LEFT    || align == TOP    || align == TOP_RIGHT   ) ? 0               :
		            (align == BOTTOM_LEFT || align == BOTTOM || align == BOTTOM_RIGHT) ? (bh - th)       :
		                                                                                 (bh - th) / 2 ) ;
		
		return new Rectangle(tx, ty, tw, th);
	}
}