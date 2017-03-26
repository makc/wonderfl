/**
 * FlashPlayer10から追加になったdrawTrianglesで球面マッピング
 * 重複頂点はできるだけマージ
 * あとクォータニオンで回転とか
 * 
 * ブログでちょっとだけ解説
 * http://blog.alumican.net/2009/12/20_014813
 * 
 * @author alumican.net
 * @see texture http://visibleearth.nasa.gov/
 */
package
{
	import com.bit101.components.HUISlider;
	import com.bit101.components.Label;
	import com.bit101.components.RadioButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import net.hires.debug.Stats;
	
	/**
	 * FP10Sphere
	 * 
	 * @author alumican
	 */
	public class FP10Sphere extends Sprite
	{
		//----------------------------------------
		//CLASS CONSTANTS
		
		
		
		
		
		//----------------------------------------
		//VARIABLES
		
		/**
		 * スフィア
		 */
		private var _sphere:Sphere;
		
		/**
		 * 回転速度
		 */
		private var _vx:Number;
		private var _vy:Number;
		
		
		
		
		
		//----------------------------------------
		//STAGE INSTANCES
		
		
		
		
		
		//----------------------------------------
		//METHODS
		
		/**
		 * コンストラクタ
		 */
		public function FP10Sphere():void
		{
			stage.align     = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			addChild(new Stats());
			
			_createSphere();
		}
		
		/**
		 * 初期化
		 */
		private function _createSphere():void
		{
			var texture:BitmapData;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				var texture:BitmapData = Bitmap(loader.contentLoaderInfo.content).bitmapData;
				
				_vx = 0;
				_vy = 0;
				
				//UI色々
				var vertexCountLabel:Label  = new Label(stage, 100, 86, "");
				var surfaceCountLabel:Label = new Label(stage, 180, 86, "");
				function updateCount():void
				{
					vertexCountLabel.text  = "vertex : "  + String(_sphere.vertexCount);
					surfaceCountLabel.text = "surface : " + String(_sphere.surfaceCount);
				}
				
				new Label(stage, 300, 10, "PROJECTOR");
				new RadioButton(stage, 300, 30, "Utils3D.projectVectors"   , true , function(e:Event):void { _sphere.useProjectVectors = true;  } );
				new RadioButton(stage, 300, 50, "Matrix3D.transformVectors", false, function(e:Event):void { _sphere.useProjectVectors = false; } );
				
				new Label(stage, 100, 10, "SHAPE");
				var segWSlider:HUISlider   = new HUISlider(stage, 100, 26, "Segment W", function(e:Event):void { _sphere.segmentW = Math.round(e.target.value); updateCount(); } );
				var segHSlider:HUISlider   = new HUISlider(stage, 100, 46, "Segment H", function(e:Event):void { _sphere.segmentH = Math.round(e.target.value); updateCount(); } );
				var radiusSlider:HUISlider = new HUISlider(stage, 100, 66, "Radius"   , function(e:Event):void { _sphere.radius   = Math.round(e.target.value); } );
				radiusSlider.minimum = 10;
				radiusSlider.maximum = 200;
				radiusSlider.labelPrecision = 0;
				radiusSlider.value = 150;
				segWSlider.minimum = segHSlider.minimum = 2;
				segWSlider.maximum = segHSlider.maximum = 64;
				segWSlider.labelPrecision = segHSlider.labelPrecision = 0;
				segWSlider.value = 16;
				segHSlider.value = 8;
				
				//スフィアを生成する
				_sphere   = addChild(new Sphere(texture, radiusSlider.value, segWSlider.value, segHSlider.value)) as Sphere;
				_sphere.x = stage.stageWidth  * 0.5;
				_sphere.y = stage.stageHeight * 0.5 + 50;
				
				updateCount();
				
				addEventListener(Event.ENTER_FRAME, _update);
			});
			loader.load(new URLRequest("http://lab.alumican.net/wonderfl/fp10sphere/texture.png"), new LoaderContext(true));
		}
		
		/**
		 * 毎フレーム実行
		 * @param	e
		 */
		private function _update(e:Event):void 
		{
			//回転
			_sphere.rotateByQuaternion(
				_vx += (-(mouseY / stage.stageHeight - 0.5) * 10 - _vx) * 0.3,
				_vy += ( (mouseX / stage.stageWidth  - 0.5) * 10 - _vy) * 0.3,
				0
			);
			
			//レンダリング
			_sphere.render();
		}
	}
}

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.TriangleCulling;
import flash.geom.Matrix3D;
import flash.geom.Utils3D;
import flash.geom.Vector3D;

/*****************************************//**
 * 頂点座標情報
 * 
 * @author alumican.net
 */
internal class Vertex3D
{
	//----------------------------------------
	//CLASS CONSTANTS
	
	
	
	
	
	//----------------------------------------
	//VARIABLES
	
	/**
	 * 3D座標
	 */
	public var x:Number;
	public var y:Number;
	public var z:Number;
	
	/**
	 * UV座標
	 */
	public var u:Number;
	public var v:Number;
	
	/**
	 * 頂点インデックス
	 */
	public var index:int;
	
	
	
	
	
	//----------------------------------------
	//STAGE INSTANCES
	
	
	
	
	
	//----------------------------------------
	//METHODS
	
	/**
	 * コンストラクタ
	 */
	public function Vertex3D():void 
	{
		index = -1;
	}
}

/*****************************************//**
 * 3Dオブジェクトの基底クラス
 * 
 * @author alumican.net
 */
internal class Object3D extends Sprite
{
	//----------------------------------------
	//CLASS CONSTANTS
	
	static public const PI:Number        = Math.PI;
	static public const PI2:Number       = PI * 2;
	static public const TO_RADIAN:Number = PI  / 180;
	static public const TO_DEGREE:Number = 180 / PI;
	
	
	
	
	
	//----------------------------------------
	//VARIABLES
	
	/**
	 * レンダリング先
	 */
	public var _viewport:Sprite;
	
	/**
	 * テクスチャ画像
	 */
	public var _texture:BitmapData;
	
	/**
	 * 3D変形マトリックス
	 */
	private var _transform3D:Matrix3D;
	
	/**
	 * 3D頂点情報
	 */
	private var _vertices3D:Vector.<Number>;
	private var _indices:Vector.<int>;
	private var _uvData:Vector.<Number>;
	
	/**
	 * 頂点/サーフィス数
	 */
	public function get vertexCount():uint { return _vertices3D.length / 3; }
	public function get surfaceCount():uint { return _indices.length / 3; }
	
	/**
	 * プロジェクト後の座標
	 */
	private var _transformedVertices3D:Vector.<Number>;
	private var _transformedVertices2D:Vector.<Number>;
	
	/**
	 * projectVectors用
	 */
	private var _uvtData:Vector.<Number>;
	
	/**
	 * クォータニオン
	 */
	private var _qx:Number;
	private var _qy:Number;
	private var _qz:Number;
	private var _qw:Number;
	
	/**
	 * レンダリング方法の指定
	 * true  : projectVectors
	 * false : transformVectors
	 */
	public var useProjectVectors:Boolean;
	
	
	
	
	
	//----------------------------------------
	//STAGE INSTANCES
	
	
	
	
	
	//----------------------------------------
	//METHODS
	
	/**
	 * コンストラクタ
	 */
	public function Object3D(texture:BitmapData = null):void 
	{
		_viewport = addChild( new Sprite() ) as Sprite;
		
		_texture = texture;
		
		useProjectVectors = true;
		
		_transform3D = new Matrix3D();
		_transform3D.identity();
		
		_qx = _qy = _qz = 0;
		_qw = 1;
		
		create();
	}
	
	/**
	 * オブジェクトを生成する
	 */
	public function create():void
	{
		_vertices3D = new Vector.<Number>();
		_indices    = new Vector.<int>();
		_uvData     = new Vector.<Number>();
		
		_createVetices(_vertices3D, _indices, _uvData);
		
		_transformedVertices2D = new Vector.<Number>(_uvData.length, true);
		_transformedVertices3D = new Vector.<Number>(_vertices3D.length, true);
		
		_uvtData = new Vector.<Number>(_vertices3D.length, true);
		var n:uint = _uvData.length;
		var i:uint = 0;
		var j:uint = 0;
		while (i < n)
		{
			_uvtData[j++] = _uvData[i++];
			_uvtData[j++] = _uvData[i++];
			_uvtData[j++] = null;
		}
	}
	
	/**
	 * 3D頂点座標、頂点インデックス、UVデータを生成する（オーバーライド用）
	 * @param	vertices3D
	 * @param	indices
	 * @param	uvData
	 */
	protected function _createVetices(vertices3D:Vector.<Number>, indices:Vector.<int>, uvData:Vector.<Number>):void
	{
	}
	
	/**
	 * オブジェクトをレンダリングする
	 */
	public function render():void
	{
		if (!_texture) return;
		
		if (useProjectVectors)
		{
			//projectVectorsを使う
			Utils3D.projectVectors(_transform3D, _vertices3D, _transformedVertices2D, _uvtData);
		}
		else
		{
			//transformVectorsを使う
			_transform3D.transformVectors(_vertices3D, _transformedVertices3D);
			
			var n:uint = _uvData.length,
				j:uint = 0;
			for (var i:uint = 0; i < n; i += 2)
			{
				_transformedVertices2D[i    ] = _transformedVertices3D[j    ];
				_transformedVertices2D[i + 1] = _transformedVertices3D[j + 1];
				j += 3;
			}
		}
		
		var g:Graphics = _viewport.graphics;
		g.clear();
		g.beginBitmapFill(_texture, null, false, false);
		g.drawTriangles(_transformedVertices2D, _indices, _uvData, TriangleCulling.NEGATIVE);
	}
	
	/**
	 * クォータニオンを用いた回転を付与する
	 * @param	rotateX
	 * @param	rotateY
	 * @param	rotateZ
	 * @param	useDegree
	 */
	public function rotateByQuaternion(rotateX:Number, rotateY:Number, rotateZ:Number, useDegree:Boolean = true):void
	{
		if (useDegree)
		{
			rotateX *= TO_RADIAN;
			rotateY *= TO_RADIAN;
			rotateZ *= TO_RADIAN;
		}
		
		//----------------------------------------
		//回転クォータニオンの生成
		var fSinPitch:Number       = Math.sin(rotateY * 0.5),
			fCosPitch:Number       = Math.cos(rotateY * 0.5),
			fSinYaw:Number         = Math.sin(rotateZ * 0.5),
			fCosYaw:Number         = Math.cos(rotateZ * 0.5),
			fSinRoll:Number        = Math.sin(rotateX * 0.5),
			fCosRoll:Number        = Math.cos(rotateX * 0.5),
			fCosPitchCosYaw:Number = fCosPitch * fCosYaw,
			fSinPitchSinYaw:Number = fSinPitch * fSinYaw,
			
			rx:Number = fSinRoll * fCosPitchCosYaw     - fCosRoll * fSinPitchSinYaw,
			ry:Number = fCosRoll * fSinPitch * fCosYaw + fSinRoll * fCosPitch * fSinYaw,
			rz:Number = fCosRoll * fCosPitch * fSinYaw - fSinRoll * fSinPitch * fCosYaw,
			rw:Number = fCosRoll * fCosPitchCosYaw     + fSinRoll * fSinPitchSinYaw,
			
			//----------------------------------------
			//元のクォータニオンに回転を合成
			qx:Number = _qw * rx + _qx * rw + _qy * rz - _qz * ry,
			qy:Number = _qw * ry - _qx * rz + _qy * rw + _qz * rx,
			qz:Number = _qw * rz + _qx * ry - _qy * rx + _qz * rw,
			qw:Number = _qw * rw - _qx * rx - _qy * ry - _qz * rz,
			
			//----------------------------------------
			//正規化
			norm:Number = Math.sqrt(qx * qx + qy * qy + qz * qz + qw * qw),
			inv:Number,
			
			//----------------------------------------
			//行列へ変換
			xx:Number,
			xy:Number,
			xz:Number,
			xw:Number,
			
			yy:Number,
			yz:Number,
			yw:Number,
			
			zz:Number,
			zw:Number,
			
			m:Vector.<Number> = _transform3D.rawData;
		
		//----------------------------------------
		//正規化
		
		if(((norm < 0) ? -norm : norm) < 0.000001)
		{
			qx = qy = qz = 0.0;
			qw = 1.0;
		}
		else
		{
			inv = 1 / norm;
			qx *= inv;
			qy *= inv;
			qz *= inv;
			qw *= inv;
		}
		
		//----------------------------------------
		//行列へ変換
		xx = qx * qx;
		xy = qx * qy;
		xz = qx * qz;
		xw = qx * qw;
		
		yy = qy * qy;
		yz = qy * qz;
		yw = qy * qw;
		
		zz = qz * qz;
		zw = qz * qw;
		
		m[0]  = 1 - 2 * (yy + zz);
		m[1]  =     2 * (xy - zw);
		m[2]  =     2 * (xz + yw);
		
		m[4]  =     2 * (xy + zw);
		m[5]  = 1 - 2 * (xx + zz);
		m[6]  =     2 * (yz - xw);
		
		m[8]  =     2 * (xz - yw);
		m[9]  =     2 * (yz + xw);
		m[10] = 1 - 2 * (xx + yy);
		
		_transform3D.rawData = m;
		
		//----------------------------------------
		//クォータニオンの保存
		_qx = qx;
		_qy = qy;
		_qz = qz;
		_qw = qw;
	}
}

/*****************************************//**
 * スフィア
 * 
 * @author alumican.net
 */
class Sphere extends Object3D
{
	//----------------------------------------
	//CLASS CONSTANTS
	
	
	
	
	
	//----------------------------------------
	//VARIABLES
	
	/**
	 * 半径
	 */
	public function get radius():Number { return _radius; }
	public function set radius(value:Number):void { _radius = value;  create(); }
	private var _radius:Number;
	
	/**
	 * 水平方向の分割数
	 */
	public function get segmentW():uint { return _segmentW; }
	public function set segmentW(value:uint):void { _segmentW = value; create(); }
	private var _segmentW:uint;
	
	/**
	 * 垂直方向の分割数
	 */
	public function get segmentH():uint { return _segmentH; }
	public function set segmentH(value:uint):void { _segmentH = value; create(); }
	private var _segmentH:uint;
	
	
	
	
	
	//----------------------------------------
	//METHODS
	
	/**
	 * コンストラクタ
	 */
	public function Sphere(texture:BitmapData = null, radius:Number = 100, segmentW:uint = 8, segmentH:uint = 6):void
	{
		_radius   = radius;
		_segmentW = segmentW;
		_segmentH = segmentH;
		
		super(texture);
	}
	
	/**
	 * 頂点情報を生成する
	 */
	override protected function _createVetices(vertices3D:Vector.<Number>, indices:Vector.<int>, uvData:Vector.<Number>):void 
	{
		var i:uint,
			j:uint,
			n:uint,
			p:Vertex3D,
			index:uint,
			x:Number,
			y:Number,
			u:Number,
			v:Number,
			angleU:Number,
			angleV:Number,
			points:Vector.<Vertex3D> = new Vector.<Vertex3D>(),
			poly:Vector.<Vertex3D> = new Vector.<Vertex3D>(4),
			poleN:Vertex3D,
			poleS:Vertex3D,
			segW:uint = _segmentW + 1,
			segH:uint = _segmentH + 1;
		
		//頂点の生成
		for (i = 0; i < segH; ++i)
		{
			for (j = 0; j < segW; ++j)
			{
				p = new Vertex3D();
				
				//このあたりの頂点をマージしたい
				//if (i == 0       ) { if (j == 0) poleN = p; else p = poleN; }		// テクスチャ上端に対応する頂点
				//if (i == segH - 1) { if (j == 0) poleS = p; else p = poleS; }		// テクスチャ下端に対応する頂点
				//if (j == segW - 1) { p = _points[_points.length - segW + 1]; }	// テクスチャ右端に対応する頂点
				
				u = j / (segW - 1);
				v = i / (segH - 1);
				
				angleU = u * PI2;
				angleV = v * PI;
				
				y = -_radius * Math.cos(angleV);
				x =  _radius * Math.sin(angleU) * Math.sin(angleV);
				z = -_radius * Math.cos(angleU) * Math.sin(angleV);
				
				p.x = x;
				p.y = y;
				p.z = z;
				p.u = u;
				p.v = v;
				
				points.push(p);
			}
		}
		
		//ポリゴンの生成
		n = points.length;
		index = 0;
		for (i = 0; i < n; ++i)
		{
			if (i + segW + 1 >= n) break;
			if ((i + 1) % segW == 0) continue;
			
			poly[0] = points[i];
			poly[1] = points[i + 1];
			poly[2] = points[i + segW];
			poly[3] = points[i + segW + 1];
			
			for (j = 0; j < 4; ++j)
			{
				//新規頂点を追加
				if ((p = poly[j]).index == -1)
				{
					p.index = index++;
					
					//3D座標
					vertices3D.push(p.x, p.y, p.z);
					
					//UV座標
					uvData.push(p.u, p.v);
				}
			}
			
			//頂点インデックスに追加(時計回り)
			indices.push(
				poly[0].index, poly[1].index, poly[2].index,
				poly[1].index, poly[3].index, poly[2].index
			);
		}
	}
}