package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
    import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ボロノイ図を作図するためのFortuneのアルゴリズムを可視化。
	 * ↓ の説明図そのまんま
	 * http://en.wikipedia.org/wiki/Fortune%27s_algorithm
	 * @author 
	 */
	[SWF(frameRate="60")]
	public class TestParabola extends Sprite
	{
		private var bmd:BitmapData;
		private var bmp:Bitmap;
		
		private const _W:Number = stage.stageWidth;
		private const _H:Number = stage.stageHeight;
		private var focuses:Vector.<Point>; //放物線の焦点=ボロノイ母点
		private var directrix:Number; //放物線の準線=Fortuneアルゴリズムのsweepline
		
		public function TestParabola() 
		{
			bmd = new BitmapData(_W, _H, true, 0x0);
			bmp = new Bitmap(bmd);
			addChild(bmp);
			
			focuses = new Vector.<Point>(40);
			resetFocuses();
			directrix = 0.0;
			addEventListener(Event.ENTER_FRAME, update);
            stage.addEventListener(MouseEvent.CLICK, function(e:Event):void {
                hasEventListener(Event.ENTER_FRAME)? removeEventListener(Event.ENTER_FRAME, update): addEventListener(Event.ENTER_FRAME, update);
            });
		}
		
        // 母点の初期化。ランダムに点を打つ。
		private function resetFocuses():void
		{
			for (var i:int = 0; i < focuses.length; i++) 
			{
				focuses[i] = new Point(_W * Math.random() , _H * Math.random());
			}
		}
		
		private function update(e:Event):void 
		{
			graphics.clear();
			graphics.lineStyle(0);
            
			var paras:Vector.<Parabola> = new Vector.<Parabola>();
			var para:Parabola;
			for each(var focus:Point in focuses)
			{
                //各点を描画
				graphics.drawCircle(focus.x, focus.y, 2.5);
                //sweeplineより下の母点は無視する
				if (focus.y > directrix) continue;
                //母点を焦点、sweeplineを準線とする放物線を生成
                /* 放物線は焦点と準線それぞれからの距離が等しい点の集合なので
                 * 準線を共有する2つの放物線の交点はそれぞれの焦点からの距離が等しくなる
                 * よって、このような交点の集合がボロノイ境界となる
                 * */
				para = Parabola.createAsQuadricCurve(focus, directrix);
				if (para)
				{
					paras.push(para);
				}
			}
			
			bmd.lock();
            
            /* 放物線の交点は複数考えられるが、sweeplineにより上から走査するので
             * 最もsweeplineに近い部分とその交点だけ考慮すればボロノイ境界になる
             * その様子が波打ち際に見えるからbeach lineと呼ぶんだと思う。
             * */
            
			var currPara:Parabola; 
			var nextPara:Parabola = paras.length > 0?paras[0]:null;
			var pts:Vector.<Point>;
			var maxVal:Number = paras.length > 0?paras[0].getY(0):null;
			var minVal:Number = 0.0;
			var tmpVal:Number = 0.0;
			
			//beach line を引くためにx=0から走査する。
            //最初の放物線はx=0において最も下にあるそれ
			for each (para in paras)
			{
				tmpVal = para.getY(0); //放物線のx=0におけるyの値を求めている
				if (maxVal < tmpVal)
				{
					maxVal = tmpVal;
					nextPara = para;
				}
			}
			currPara = nextPara;
			if (currPara) currPara.render(graphics, 0, _W);
            
			for (;; )
			{
				maxVal = Number.MAX_VALUE;
				for each (para in paras)
				{
					if (currPara == para) continue;
                    //現在の放物線と他の放物線との交点を求め
                    //交点のxが最も前回の交点に近い点がボロノイ境界上の点になる
					pts = Parabola.getCrossPoints(currPara, para);
					for each( var pt:Point in pts)
					{
						tmpVal = pt.x;
						if (tmpVal > minVal && tmpVal < maxVal)
						{
							maxVal = tmpVal;
							nextPara = para; //交点で最も下の放物線が入れ替わる
						}
					}
				}
				if (maxVal < _W) 
				{
					bmd.setPixel32(maxVal, currPara.getY(maxVal), 0xff000000);
					minVal = maxVal;
					currPara = nextPara;
					currPara.render(graphics, 0, _W);
				}
				else
				{
					break;
				}
				
			}
			
			//sweeplineを引く
			graphics.lineStyle(0, 0xff0000, 0.75);
			graphics.moveTo(0, directrix);
			graphics.lineTo(_W, directrix);
			directrix += 1.0;
			
			if (directrix > 2 * _H)
			{
				resetFocuses();
				directrix = 0.0;
				bmd.fillRect(bmd.rect, 0x0);
			}
			
			bmd.unlock();
		}
		
		
	}

}

	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * ...
	 * @author 
	 */
	class Parabola
	{
		private var _a:Number;
		private var _b:Number;
		private var _c:Number;
		//private var _d:Number;
		
		/**
		 * Dy = Ax2 + Bx + C の形式に合わせて、各係数を引数に放物線を生成
		 * @param	coefY 0を除く実数
		 * @param	coefX2 0を除く実数
		 * @param	coefX
		 * @param	coef1
		 */
		public function Parabola(coefY:Number = 1.0, coefX2:Number = 1.0, coefX:Number = 0.0, coef1:Number = 0.0) 
		{
			var inv:Number;
			inv = 1.0 / coefY;
			_a = coefX2 * inv;
			_b = coefX * inv;
			_c = coef1 * inv;
			//_d = 1.0;
		}
		
		/**
		 * 
		 * @param	focus focus Point
		 * @param	directrix y value of directrix line
		 * @return yの係数が0になる(x=focux.xの直線になる)場合は容赦なくnullを返す
		 */
		public static function createAsQuadricCurve(focus:Point, directrix:Number):Parabola
		{
			var x0:Number = focus.x;
			var y0:Number = focus.y;
			var c:Number = 0.5 * ( -x0 * x0 + directrix * directrix - y0 * y0);
			var d:Number = directrix - y0;
			if (d != 0)
			{
				return new Parabola(d, -0.5, x0, c);
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * 放物線上のxに対応するyの値を返す。
		 * @param	x
		 * @return
		 */
		public function getY(x:Number):Number
		{
			return _a * x * x + _b * x + _c;
		}
		
		/**
		 * 放物線上のyに対応するxをVectorで返す。Vector.lengthは2以下。
		 * @param	y
		 * @return
		 */
		public function getX(y:Number):Vector.<Number>
		{
			return formula(_a, _b, _c - y);
		}
		
		/**
		 * 解の公式から ax2+bx+c=0 のxを求める。
		 * 2次方程式の解ならVector.length=2(重解含む)
		 * 1次方程式の解(a=0)ならVector.length=1
		 * 解がなければVector.length=0
		 * @param	a
		 * @param	b
		 * @param	c
		 * @return
		 */
		private static function formula(a:Number, b:Number, c:Number):Vector.<Number>
		{
			var xVec:Vector.<Number>;
			if (a != 0)
			{
				var det:Number = b * b - 4 * a * c;
				var aInv:Number = 0.5 / a;
				var x0:Number = -b * aInv;
				if (det > 0)
				{
					xVec = new Vector.<Number>(2, true);
					det = Math.sqrt(det) * aInv;
					xVec[0] = x0 - det;
					xVec[1] = x0 + det; 
				}
				else if (det < 0)
				{
					xVec = new Vector.<Number>(0, true);
				}
				else
				{
					xVec = new Vector.<Number>(2, true);
					xVec[0] = x0;
					xVec[1] = x0;
				}
			}
			else
			{
				if (b != 0)
				{
					xVec = new Vector.<Number>(1, true);
					xVec[0] = -c/b;
				}
				else
				{
					xVec = new Vector.<Number>(0, true);
				}
			}
			return xVec;
		}
		
		public static function getCrossPoints(p1:Parabola, p2:Parabola):Vector.<Point>
		{
			var subA:Number = p1._a - p2._a;
			var subB:Number = p1._b - p2._b;
			var subC:Number = p1._c - p2._c;
			var crossXVec:Vector.<Number>;
			var pts:Vector.<Point>;
			
			crossXVec = formula(subA, subB, subC);
			
			pts = new Vector.<Point>(crossXVec.length, true);
			for (var i:int = 0; i < pts.length; i++) 
			{
				var __x:Number = crossXVec[i];
				pts[i] = new Point(__x, p1.getY(__x));
			}
			
			return pts;
		}
		
		/**
		 * for debug
		 * @param	graphics
		 * @param	fromX
		 * @param	toX
		 */
		public function render(graphics:Graphics, fromX:Number, toX:Number):void
		{
			var i:uint = 100;
			var __x:Number = fromX;
			var dx:Number = (toX - fromX) / i;
			graphics.lineStyle(0, 0xff, 0.5);
			graphics.moveTo(__x, getY(__x));
			while (i-- > 0)
			{
				__x += dx;
				graphics.lineTo(__x, getY(__x));
			}
		}
	}
