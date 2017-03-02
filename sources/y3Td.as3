// forked from alumican_net's Clifford Attractor Rainbow ver.
/**
 * Clifford Attractor.
 * 
 * x' = sin(a * y) + c * cos(a * x)
 * y' = sin(b * x) + d * cos(b * y)
 * 
 * @author alumican.net
 */
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.filters.BlurFilter;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import org.libspark.betweenas3.easing.*;
	import com.flashdynamix.utils.SWFProfiler;
	
	public class CliffordAttractorDynamic extends Sprite
	{
		//----------------------------------------
		//CLASS CONSTANTS
		
		//パーティクル数
		private const N:uint = 15000;
		
		private const W:uint = 465;
		private const H:uint = 465;
		
		private const W1_2:uint = uint(W / 2);
		private const H1_2:uint = uint(H / 2);
		
		private const RECT:Rectangle = new Rectangle(0, 0, W, H);
		private const ZEROS:Point = new Point(0, 0);
		
		
		
		
		
		//----------------------------------------
		//VARIABLES
		
		private var _a:Number;
		private var _b:Number;
		private var _c:Number;
		private var _d:Number;
		
		private var _va:Number;
		private var _vb:Number;
		private var _vc:Number;
		private var _vd:Number;
		
		private var _cx:Number;
		private var _cy:Number;
		
		private var _head:Particle;
		
		private var _canvas:BitmapData;
		private var _buffer:BitmapData;
		
		private var _blurFilter:BlurFilter;
		private var _colorTransForm:ColorTransform;
		
		private var _gradation:Gradation;
		
		
		
		
		
		//--------------------------------------------------
		//METHODS
		
		public function CliffordAttractorDynamic():void
		{
			Wonderfl.disable_capture();
			
			addChild(new Bitmap(_canvas = new BitmapData(W, H, false, 0x000000)));
			_buffer = _canvas.clone();
			
			_gradation = new Gradation(0xcc0000, 0xcc6000, 0xcccc00, 0x00cc00, 0x00cccc, 0x0000cc, 0x6000cc);
			_gradation.setEasing(Linear.easeNone);
			
			_blurFilter = new BlurFilter(16, 16, 1);
			_colorTransForm = new ColorTransform(0.95, 0.95, 0.95);
			
			var o:Particle = _head = new Particle();
			for (var i:uint = 0; i < N; ++i)
			{
				o = o.next = new Particle();
			}
			
			addEventListener(Event.ENTER_FRAME, _update);
			stage.addEventListener(MouseEvent.CLICK, _reset);
			
			SWFProfiler.init(this);
			
			_reset();
		}
		
		private function _reset(e:MouseEvent = null):void
		{
			_a = (Math.random() - 0.5) * 3;
			_b = (Math.random() - 0.5) * 3;
			_c = (Math.random() - 0.5) * 6;
			_d = (Math.random() - 0.5) * 6;
			if (Math.abs(_a) < 0.4) _a += 0.8 * _a / Math.abs(_a);
			if (Math.abs(_b) < 0.4) _b += 0.8 * _b / Math.abs(_b);
			if (Math.abs(_c) < 1.0) _c += 1.0 * _c / Math.abs(_c);
			if (Math.abs(_d) < 1.0) _d += 1.0 * _d / Math.abs(_d);
			
            _va = 0.01; 
            _vb = 0.01; 
            _vc = 0.01; 
            _vd = 0.01; 
            _cx = 0.000002;
            _cy = 0.000002;
			
			var p:Particle = _head;
			do {
				p.x1 = p.x0 = (Math.random() - 0.5);
				p.y1 = p.y0 = (Math.random() - 0.5);
			}
			while (p = p.next);
		}
		
		private function _update(e:Event):void
		{
			var p:Particle = _head,
				vx:Number,
				vy:Number;
			
			_buffer.lock();
			_buffer.fillRect(RECT, 0x000000);
			do {
				p.x1 = Math.sin(_a * _cx) + _c * Math.cos(_a * _cy);
				p.y1 = Math.sin(_b * _cx) + _d * Math.cos(_b * _cy);
				
				vx = p.x1 - p.x0;
				vy = p.y1 - p.y0;
				
				p.x0 = p.x1;
				p.y0 = p.y1;
				
				_buffer.setPixel(W1_2 + p.x1 * 70, H1_2 + p.y1 * 70, _gradation.getColor((vx * vx + vy * vy) * 0.1) );
				
				 _cx += 0.000002;
				 _cy += 0.000002;
				 
                if (_a < -3.0 || _a > 3.0) _va *= -1; 
                if (_b < -3.0 || _b > 3.0) _vb *= -1; 
                if (_c < -3.0 || _c > 3.0) _vc *= -1; 
                if (_d < -3.0 || _d > 3.0) _vd *= -1; 
                _a += _va; 
                _b += _vb; 
                _c += _vc; 
                _d += _vd; 
			}
			while (p = p.next);
			_buffer.unlock();
			
			_canvas.lock();
			_canvas.colorTransform(RECT, _colorTransForm);
			_canvas.applyFilter(_canvas, RECT, ZEROS, _blurFilter);
			_canvas.draw(_buffer, null, null, BlendMode.ADD);
			_canvas.unlock();
			
			if (_a < -3.0 || _a > 3.0) _va *= -1;
			if (_b < -3.0 || _b > 3.0) _vb *= -1;
			if (_c < -3.0 || _c > 3.0) _vc *= -1;
			if (_d < -3.0 || _d > 3.0) _vd *= -1;
			_a += _va;
			_b += _vb;
			_c += _vc;
			_d += _vd;
		}
	}
}


//--------------------------------------------------
//1ファイル内にクラスを3つ以上作成するとCS4でビルドできなくなるバグ対策クラス
internal class EmptyClass { }


//--------------------------------------------------
//パーティクル
internal class Particle extends EmptyClass
{
	public var x1:Number;
	public var y1:Number;
	public var x0:Number;
	public var y0:Number;
	public var next:Particle;
}


//--------------------------------------------------
/**
 * @author saqoosha
 * @see http://wonderfl.net/code/7ed2d650b9d513edf9a499fb704c19ecb7aa4694
 */
import frocessing.color.ColorLerp;
import org.libspark.betweenas3.core.easing.IEasing;
import org.libspark.betweenas3.easing.Linear;
class Gradation extends EmptyClass
{
	private var _colors:Array;
	private var _easing:IEasing;
	
	public function Gradation(...args):void
	{
		_colors = args.concat();
		_easing = Linear.linear;
	}
	
	public function setEasing(easing:IEasing):void
	{
		_easing = easing;
	}
	
	public function getColor(position:Number):uint
	{
		position = (position < 0 ? 0 : position > 1 ? 1 : position) * (_colors.length - 1);
		var idx:int = position;
		var alpha:Number = _easing.calculate(position - idx, 0, 1, 1);
		if (alpha == 0)
		{
			return _colors[idx];
		}
		else
		{
			return ColorLerp.lerp(_colors[idx], _colors[idx + 1], alpha);
		}
	}
}