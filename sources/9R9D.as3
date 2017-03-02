/**
 * 漁ってたらなんか出てきたので置いておく
 * 
 * マウス押しっぱなしでパーティクル生成する
 * create particle : MouseDown
 */
package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import net.hires.debug.Stats;
	import frocessing.color.ColorHSV;
	
	/**
	 * Main
	 * 
	 * @author alumican
	 */
	public class Main extends Sprite
	{
		//----------------------------------------
		//CLASS CONSTANTS
		
		private const SPH_RESTDENSITY:Number = 600.0;
		private const SPH_INTSTIFF:Number    = 1.0;
		private const SPH_PMASS:Number       = 0.00020543;
		private const SPH_SIMSCALE:Number    = 0.004;
		private const H:Number               = 0.01;
		private const H2:Number              = H * H;
		private const PI:Number              = Math.PI;
		private const DT:Number              = 0.004;
		private const SPH_VISC:Number        = 0.2;
		private const SPH_LIMIT:Number       = 200.0;
		private const SPH_LIMIT2:Number      = SPH_LIMIT * SPH_LIMIT;
		private const SPH_RADIUS:Number      = 0.004;
		private const SPH_EPSILON:Number     = 0.00001;
		private const SPH_EXTSTIFF:Number    = 10000.0;
		private const SPH_EXTDAMP:Number     = 256.0;
		private const SPH_PDIST:Number       = Math.pow(SPH_PMASS / SPH_RESTDENSITY, 1.0 / 3.0);
		
		private const MIN:Vector3            = new Vector3( 0.0,  0.0, -10.0);
		private const MAX:Vector3            = new Vector3(20.0, 20.0,  10.0);
		private const INIT_MIN:Vector3       = new Vector3( 0.0,  0.0, -10.0);
		private const INIT_MAX:Vector3       = new Vector3(10.0, 20.0,  10.0);
		private const Poly6Kern:Number       = 315.0 / (64.0 * PI * Math.pow(H, 9));
		private const SpikyKern:Number       = -45.0 / (       PI * Math.pow(H, 6));
		private const LapKern:Number         =  45.0 / (       PI * Math.pow(H, 6));
		private const VTERM:Number           = LapKern * SPH_VISC;
		
		private const AXIS_Z0:Vector3        = new Vector3( 0,  0,  1);
		private const AXIS_Z1:Vector3        = new Vector3( 0,  0, -1);
		private const AXIS_X0:Vector3        = new Vector3( 1,  0,  0);
		private const AXIS_X1:Vector3        = new Vector3(-1,  0,  0);
		private const AXIS_Y0:Vector3        = new Vector3( 0,  1,  0);
		private const AXIS_Y1:Vector3        = new Vector3( 0, -1,  0);
		
		private const GRAVITY:Vector3        = new Vector3(0.0, 9.8, 0.0);
		
		
		
		
		//----------------------------------------
		//VARIABLES
		
		/**
		 * イテレータ
		 */
		private var _first:Particle;
		private var _last:Particle;
		
		/**
		 * パーティクル数
		 */
		private var _particleCount:uint;
		
		/**
		 * 表示
		 */
		private var _canvas:BitmapData;
		private var _canvasRect:Rectangle;
		private var _pallet:Array;
		
		private var _blurFilter:BlurFilter   = new BlurFilter(32, 32, 2);
		private var _bevelFilter:BevelFilter = new BevelFilter(5, 45, 0xeeeeee, 1, 0x999999, 1, 25, 25, 1.5, 2);
		
		private var _clearBitmapData:BitmapData;
		private var _whiteBitmapData:BitmapData;
		private var _blobBitmapData:BitmapData;
		
		private const ZEROS:Point = new Point(0, 0);
		
		/**
		 * ボール
		 */
		private var _container:Sprite;
		
		/**
		 * マウスダウン中であればtrue
		 */
		private var _isMouseDown:Boolean;
		
		private var _colorHSV:ColorHSV;
		
		
		
		
		
		//----------------------------------------
		//STAGE INSTANCES
		
		
		
		
		
		//----------------------------------------
		//METHODS
		
		/**
		 * コンストラクタ
		 */
		public function Main():void 
		{
                        Wonderfl.disable_capture();
                       // Wonderfl.capture_delay(10);
                        
			var w:uint = 465;
			var h:uint = 465;
			
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.frameRate = 60;
			
			_canvas = new BitmapData(w, h, false, 0xffffff);
			_canvasRect = _canvas.rect;
			addChild( new Bitmap(_canvas) );
			
			_container = new Sprite();
			
			_pallet = new Array();
			for (var i:uint = 0; i < 0x100; i++)
			{
				_pallet.push((i < 30) ? 0x000000 : 0xff000000);
			}
			
			_clearBitmapData = new BitmapData(w, h, true, 0x00ffffff);
			_whiteBitmapData = new BitmapData(w, h, false, 0xffffff);
			_blobBitmapData  = new BitmapData(w, h, true);
			
			
			
			
			
			_createParticles();
			addEventListener(Event.ENTER_FRAME, _update);
			
		//	var stats:Stats = addChild( new Stats() ) as Stats;
		//	stats.x = stage.stageWidth - 70;
			
			_isMouseDown = false;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, _stageMouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, _stageMouseUpHandler);
		}
		
		
		
		
		
		/**
		 * 初期パーティクルの生成
		 */
		private function _createParticles():void
		{
			var p0:Particle,
				p1:Particle,
				d:Number = SPH_PDIST / SPH_SIMSCALE * 0.8, //0.87
				initMin:Vector3 = INIT_MIN,
				initMax:Vector3 = INIT_MAX,
				x:Number,
				y:Number,
				z:Number,
				i:uint,
				n:uint,
				tmp:Array = new Array();
			
			_colorHSV = new ColorHSV(0, 0.7, 0.9);
			
			//パーティクル生成
			for (x = initMin.x + d; x <= initMax.x - d; x += d)
			for (y = initMin.y + d; y <= initMax.y - d; y += d)
		//	for (z = initMin.z + d; z <= initMax.z - d; z += d)
			{
				z = 0;
				
				p0 = new Particle(x, y, z);
				
				_colorHSV.h += 0.1;
				p0.createBall(10, _colorHSV.value);
				_container.addChild(p0.ball);
				
				tmp.push(p0);
			}
			
			//パーティクル数
			_particleCount = tmp.length;
			
			//イテレータ
			_first = tmp[0];
			_last  = tmp[_particleCount - 1];
			
			//リンクリスト生成
			n = _particleCount - 1;
			for (i = 0; i < n; ++i) 
			{
				p0 = tmp[i    ];
				p1 = tmp[i + 1];
				
				p0.next = p1;
				p1.prev = p0;
			}
		}
		
		private function _generateParticle():void
		{
			//generate
			var px:Number = mouseX / 20;
			var py:Number = mouseY / 20;
			
			var p:Particle = new Particle(px, py, 0);
			
			_colorHSV.h += 0.5;
			p.createBall(Math.random() * 5 + 7.5, _colorHSV.value);
			_container.addChild(p.ball);
			
			_last.next = p;
			p.prev = _last;
			_last = p;
			
			++_particleCount;
			
			//delete
			p = _first;
			_container.removeChild(p.ball);
			_first = _first.next;
		}
		
		
		
		
		
		/**
		 * アップデータ
		 * @param	e
		 */
		private function _update(e:Event):void 
		{
			_simulation();
			_draw();
		}
		
		
		
		
		
		/**
		 * シミュレーション
		 */
		private function _simulation():void
		{
			if (_isMouseDown)
			{
				_generateParticle();
			}
			
			_calcAmount();
			_calcForce();
			_calcAdvance();
		}
		
		/**
		 * 密度の算出
		 */
		private function _calcAmount():void
		{
			var h2:Number             = H2,
				sphSimscale:Number    = SPH_SIMSCALE,
				sphPmass:Number       = SPH_PMASS,
				sphIntstiff:Number    = SPH_INTSTIFF,
				sphRestdensity:Number = SPH_RESTDENSITY,
				poly6Kern:Number      = Poly6Kern,
				sum:Number,
				r2:Number,
				c:Number,
				dr:Vector3,
				pi:Particle = _first,
				pj:Particle;
			
			do
			{
				sum = 0.0;
				pj  = _first;
				
				do
				{
					if (pi === pj) continue;
					
					dr = Vector3.subtraction(pi.pos, pj.pos).multiScalar(sphSimscale);
					
					r2 = Vector3.norm2(dr);
					
					if (h2 > r2)
					{
						c = h2 - r2;
						sum += c * c * c;
					}
				}
				while (pj = pj.next);
				
				pi.rho = sum * sphPmass * poly6Kern;
				pi.prs = (pi.rho - sphRestdensity) * sphIntstiff;
				pi.rho = 1.0 / pi.rho;
			}
			while (pi = pi.next);
		}
		
		/**
		 * 力の算出
		 */
		private function _calcForce():void
		{
			var sphSimscale:Number = SPH_SIMSCALE,
				sphVisc:Number     = SPH_VISC,
				h:Number           = H,
				h2:Number          = H2,
				spikyKern:Number   = SpikyKern,
				lapKern:Number     = LapKern,
				vterm:Number       = VTERM,
				pterm:Number,
				r:Number,
				r2:Number,
				c:Number,
				dr:Vector3,
				force:Vector3,
				fcurr:Vector3,
				pi:Particle = _first,
				pj:Particle,
				mx:Number = (mouseX / stage.stageWidth  - 0.5) * 2 / sphSimscale,
				my:Number = (mouseY / stage.stageHeight - 0.5) * 2 / sphSimscale,
				md:Number,
				pix:Number,
				piy:Number,
				dix:Number,
				diy:Number;
			
			do
			{
				force = new Vector3();
				pj = _first;
				
				do
				{
					if (pi === pj) continue;
					
					if (pi.pos.eq(pj.pos)) continue;
					
					dr = Vector3.subtraction(pi.pos, pj.pos);
					dr.multiScalar(sphSimscale);
					
					r2 = Vector3.norm2(dr);
					
					if (h2 > r2)
					{
						r = Math.sqrt(r2);
						c = h - r;
						
						pterm = -0.5 * c * spikyKern * (pi.prs + pj.prs) / r;
						
						fcurr = Vector3.multiplyScalar(dr, pterm).add( Vector3.subtraction(pj.vel, pi.vel).multiScalar(vterm) );
						fcurr.multiScalar(c * pi.rho * pj.rho);
						
						force.add(fcurr);
					}
					
					//マウス
					if (h2 > r2)
					{
						pix = pi.pos.x;
						piy = pi.pos.y;
						
						dix = pix - mx;
						diy = piy - my;
						
						md = Math.sqrt(dix * dix + diy * diy);
						
						force.x -= 10000 * (dix / md);
						force.y -= 10000 * (diy / md);
					}
				}
				while (pj = pj.next);
				
				pi.f = force;
			}
			while (pi = pi.next);
		}
		
		/**
		 * 粒子の移動
		 */
		private function _calcAdvance():void
		{
			var sphPmass:Number    = SPH_PMASS,
				sphLimit:Number    = SPH_LIMIT,
				sphLimit2:Number   = SPH_LIMIT2,
				sphRadius:Number   = SPH_RADIUS,
				sphSimscale:Number = SPH_SIMSCALE,
				sphEpsilon:Number  = SPH_EPSILON,
				sphExtstiff:Number = SPH_EXTSTIFF,
				sphExtdamp:Number  = SPH_EXTDAMP,
				dt:Number          = DT,
				min:Vector3        = MIN,
				max:Vector3        = MAX,
				axisZ0:Vector3     = AXIS_Z0,
				axisZ1:Vector3     = AXIS_Z1,
				axisX0:Vector3     = AXIS_X0,
				axisX1:Vector3     = AXIS_X1,
				axisY0:Vector3     = AXIS_Y0,
				axisY1:Vector3     = AXIS_Y1,
				g:Vector3          = GRAVITY,
				accel:Vector3,
				speed:Number,
				diff:Number,
				adj:Number,
				p:Particle = _first;
			
			do
			{
				accel = Vector3.multiplyScalar(p.f, sphPmass);
				speed = Vector3.norm2(accel);
				
				if (speed > sphLimit2)
				{
					accel.multiScalar(sphLimit / Math.sqrt(speed));
				}
				
				// Z-axis walls
				/*
				diff = 2.0 * sphRadius - (p.pos.z - min.z) * sphSimscale;
				if (diff > sphEpsilon)
				{
					adj = sphExtstiff * diff - sphExtdamp * Vector3.dot(axisZ0, p.vel);
					accel.add(Vector3.multiplyScalar(axisZ0, adj));
				}
				
				diff = 2.0 * sphRadius - (max.z - p.pos.z) * sphSimscale;
				if (diff > sphEpsilon)
				{
					adj = sphExtstiff * diff - sphExtdamp * Vector3.dot(axisZ1, p.vel);
					accel.add(Vector3.multiplyScalar(axisZ1, adj));
				}
				*/
				
				// X-axis walls
				diff = 2.0 * sphRadius - (p.pos.x - min.x) * sphSimscale + 0.005;
				if (diff > sphEpsilon)
				{
					adj = sphExtstiff * diff - sphExtdamp * Vector3.dot(axisX0, p.vel);
					accel.add(Vector3.multiplyScalar(axisX0, adj));
				}
				
				diff = 2.0 * sphRadius - (max.x - p.pos.x) * sphSimscale - 0.005;
				if (diff > sphEpsilon)
				{
					adj = sphExtstiff * diff - sphExtdamp * Vector3.dot(axisX1, p.vel);
					accel.add(Vector3.multiplyScalar(axisX1, adj));
				}
				
				// Y-axis walls
				diff = 2.0 * sphRadius - (p.pos.y - min.y) * sphSimscale + 0.005;
				if (diff > sphEpsilon)
				{
					adj = sphExtstiff * diff - sphExtdamp * Vector3.dot(axisY0, p.vel);
					accel.add(Vector3.multiplyScalar(axisY0, adj));
				}
				
				diff = 2.0 * sphRadius - (max.y - p.pos.y) * sphSimscale - 0.005;
				if (diff > sphEpsilon)
				{
					adj = sphExtstiff * diff - sphExtdamp * Vector3.dot(axisY1, p.vel);
					accel.add(Vector3.multiplyScalar(axisY1, adj));
				}
				
				accel.add(g);
				p.vel.add(accel.multiScalar(dt));
				p.pos.add(p.vel.multiScalar(dt / sphSimscale));
			}
			while (p = p.next);
		}
		
		
		
		
		
		/**
		 * 描画
		 */
		private function _draw():void
		{
			//_canvas.lock();
			//_canvas.fillRect(_canvasRect, 0xffffff);
			var p:Particle = _first;
			do
			{
				p.ball.x = p.pos.x * 20;
				p.ball.y = p.pos.y * 20;
				
				//_canvas.setPixel(p.pos.x * 20, p.pos.y * 20, 0x000000);
			}
			while (p = p.next);
			
			/*
			_canvas.draw(_container);
			_canvas.applyFilter(_canvas, _canvasRect, ZEROS, _blurFilter);
			*/
			
			_blobBitmapData.lock();
			_blobBitmapData.copyPixels(_clearBitmapData, _canvasRect, ZEROS);
			_blobBitmapData.draw(_container);
			_blobBitmapData.applyFilter(_blobBitmapData, _canvasRect, ZEROS, _blurFilter);
			_blobBitmapData.paletteMap(_blobBitmapData, _canvasRect, ZEROS, null, null, null, _pallet);
			//_blobBitmapData.applyFilter(_blobBitmapData, _canvasRect, ZEROS, _bevelFilter);
			_blobBitmapData.unlock();
			
			_canvas.lock();
			_canvas.copyPixels(_whiteBitmapData, _canvasRect, ZEROS);
			_canvas.copyPixels(_blobBitmapData, _canvasRect, ZEROS);
			_canvas.unlock();
		}
		
		
		
		
		
		private function _stageMouseDownHandler(e:MouseEvent):void 
		{
			_isMouseDown = true;
		}
		
		private function _stageMouseUpHandler(e:MouseEvent):void 
		{
			_isMouseDown = false;
		}
	}
}





/**
 * Vector3
 * @author alumican
 */
class Vector3
{
	
	//----------------------------------------
	//CLASS CONSTANTS
	
	
	
	
	
	//----------------------------------------
	//VARIABLES
	
	public var x:Number;
	public var y:Number;
	public var z:Number;
	
	
	
	
	
	//----------------------------------------
	//STAGE INSTANCES
	
	
	
	
	
	//----------------------------------------
	//METHODS
	
	/**
	 * コンストラクタ
	 */
	public function Vector3(x:Number = 0, y:Number = 0, z:Number = 0):void 
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	
	
	
	
	/**
	 * == vec
	 */
	public function eq(vec:Vector3):Boolean
	{
		return (x == vec.x && y == vec.y && z == vec.z);
	}
	
	/**
	 * += vec
	 */
	public function add(vec:Vector3):Vector3
	{
		x += vec.x;
		y += vec.y;
		z += vec.z;
		return this;
	}
	
	/**
	 * -= vec
	 */
	public function sub(vec:Vector3):Vector3
	{
		x -= vec.x;
		y -= vec.y;
		z -= vec.z;
		return this;
	}
	
	/**
	 * *= vec
	 */
	public function multi(vec:Vector3):Vector3
	{
		x *= vec.x;
		y *= vec.y;
		z *= vec.z;
		return this;
	}
	
	/**
	 * /= value
	 */
	public function div(vec:Vector3):Vector3
	{
		if (vec.x == 0 || vec.y == 0 || vec.z == 0) throw new ArgumentError("division by 0");
		x /= vec.x;
		y /= vec.y;
		z /= vec.z;
		return this;
	}
	
	/**
	 * %= vec
	 */
	public function mod(vec:Vector3):Vector3
	{
		x %= vec.x;
		y %= vec.y;
		z %= vec.z;
		return this;
	}
	
	/**
	 * += value
	 */
	public function addScalar(value:Number):Vector3
	{
		x += value;
		y += value;
		z += value;
		return this;
	}
	
	/**
	 * -= value
	 */
	public function subScalar(value:Number):Vector3
	{
		x -= value;
		y -= value;
		z -= value;
		return this;
	}
	
	/**
	 * *= value
	 */
	public function multiScalar(value:Number):Vector3
	{
		x *= value;
		y *= value;
		z *= value;
		return this;
	}
	
	/**
	 * /= value
	 */
	public function divScalar(value:Number):Vector3
	{
		if (value == 0) throw new ArgumentError("division by 0");
		x /= value;
		y /= value;
		z /= value;
		return this;
	}
	
	/**
	 * %= value
	 */
	public function modScalar(value:Number):Vector3
	{
		x %= value;
		y %= value;
		z %= value;
		return this;
	}
	
	/**
	 * -
	 */
	public function inv():Vector3
	{
		x = -x;
		y = -y;
		z = -z;
		return this;
	}
	
	/**
	 * 複製
	 */
	public function clone():Vector3
	{
		return new Vector3(x, y, z);
	}
	
	
	
	
	
	/**
	 * a == b
	 */
	static public function equal(a:Vector3, b:Vector3):Boolean
	{
		return (a.x == b.x && a.y == b.y && a.z == b.z);
	}
	
	/**
	 * a + b
	 */
	static public function addition(a:Vector3, b:Vector3):Vector3
	{
		return new Vector3(a.x + b.x, a.y + b.y, a.z + b.z);
	}
	
	/**
	 * a - b
	 */
	static public function subtraction(a:Vector3, b:Vector3):Vector3
	{
		return new Vector3(a.x - b.x, a.y - b.y, a.z - b.z);
	}
	
	/**
	 * a * b
	 */
	static public function multiply(a:Vector3, b:Vector3):Vector3
	{
		return new Vector3(a.x * b.x, a.y * b.y, a.z * b.z);
	}
	
	/**
	 * a / b
	 */
	static public function division(a:Vector3, b:Vector3):Vector3
	{
		if (b.x == 0 || b.y == 0 || b.z == 0) throw new ArgumentError("division by 0");
		return new Vector3(a.x / b.x, a.y / b.y, a.z / b.z);
	}
	
	/**
	 * a % b
	 */
	static public function modulo(a:Vector3, b:Vector3):Vector3
	{
		return new Vector3(a.x % b.x, a.y % b.y, a.z % b.z);
	}
	
	/**
	 * a + value
	 */
	static public function additionScalar(a:Vector3, value:Number):Vector3
	{
		return new Vector3(a.x + value, a.y + value, a.z + value);
	}
	
	/**
	 * a - value
	 */
	static public function subtractionScalar(a:Vector3, value:Number):Vector3
	{
		return new Vector3(a.x - value, a.y - value, a.z - value);
	}
	
	/**
	 * a * value
	 */
	static public function multiplyScalar(a:Vector3, value:Number):Vector3
	{
		return new Vector3(a.x * value, a.y * value, a.z * value);
	}
	
	/**
	 * a / value
	 */
	static public function divisionScalar(a:Vector3, value:Number):Vector3
	{
		if (value == 0) throw new ArgumentError("division by 0");
		return new Vector3(a.x / value, a.y / value, a.z / value);
	}
	
	/**
	 * a % value
	 */
	static public function moduloScalar(a:Vector3, value:Number):Vector3
	{
		return new Vector3(a.x % value, a.y % value, a.z % value);
	}
	
	/**
	 * -a
	 */
	static public function invert(a:Vector3):Vector3
	{
		return new Vector3(-a.x, -a.y, -a.z);
	}
	
	/**
	 * 内積
	 */
	static public function dot(a:Vector3, b:Vector3):Number
	{
		return a.x * b.x + a.y * b.y + a.z * b.z;
	}
	
	/**
	 * 大きさの二乗
	 */
	static public function norm2(a:Vector3):Number
	{
		return a.x * a.x + a.y * a.y + a.z * a.z;
	}
	
	/**
	 * 大きさ
	 */
	static public function norm(a:Vector3):Number
	{
		return Math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
	}
	
	
	
	
	
	/**
	 * toString
	 */
	public function toString():String
	{
		return "x = " + String(x) + ", y = " + String(y) + ", z = " + String(z);
	}
}





import flash.display.Sprite;
/**
 * Particle
 * 
 * @author alumican
 */
class Particle
{
	//----------------------------------------
	//CLASS CONSTANTS
	
	
	
	
	
	//----------------------------------------
	//VARIABLES
	
	/**
	 * 座標
	 */
	public var pos:Vector3;
	
	/**
	 * 速度
	 */
	public var vel:Vector3;
	
	/**
	 * 力
	 */
	public var f:Vector3;
	
	/**
	 * 密度
	 */
	public var rho:Number;
	
	/**
	 * 圧力
	 */
	public var prs:Number;
	
	/**
	 * イテレータ
	 */
	public var prev:Particle;
	public var next:Particle;
	
	/**
	 * 表示オブジェクト
	 */
	public var ball:Ball;
	
	
	
	
	
	//----------------------------------------
	//STAGE INSTANCES
	
	
	
	
	
	//----------------------------------------
	//METHODS
	
	/**
	 * コンストラクタ
	 */
	public function Particle(x:Number = 0, y:Number = 0, z:Number = 0):void
	{
		pos  = new Vector3(x, y, z);
		vel  = new Vector3(0, 0, 0);
		f    = new Vector3(0, 0, 0);
		rho  = 0;
		prs  = 0;
		next = null;
	}
	
	public function createBall(radius:Number = 10, color:uint = 0x0):void
	{
		ball = new Ball(radius, color);
	}
}





import flash.display.Sprite;

/**
 * Ball
 * 
 * @author alumican
 */
class Ball extends Sprite
{
	
	//----------------------------------------
	//CLASS CONSTANTS
	
	
	
	
	
	//----------------------------------------
	//VARIABLES
	
	
	
	
	
	//----------------------------------------
	//STAGE INSTANCES
	
	
	
	
	
	//----------------------------------------
	//METHODS
	
	/**
	 * コンストラクタ
	 */
	public function Ball(radius:Number = 10, color:uint = 0x0):void 
	{
		graphics.beginFill(color);
		graphics.drawCircle(0, 0, radius);
		graphics.endFill();
	}
}
