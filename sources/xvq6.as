package  
{
	import flash.utils.ByteArray;
    import flash.display.Bitmap;
	import flash.display.BitmapData;
    import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	/**
	 * 読み込んだ画像をポヨンポヨンさせる。
	 * クリックでdrawTrianglesのラインを表示/非表示。
	 * ドラッグして別の場所をポヨンポヨン。
	 * 半径が小さいと振動が発散してしまうのを何とかしたい。
	 * 
	 * 画像 http://www.flickr.com/photos/iwao_kobayashi/2694620804/
	 */
	[SWF(width="465",height="465",backgroundColor="0x0",frameRate="30")]
	public class FlashTest extends Sprite
	{
		
		private var url:String;
		private var loader:Loader;
		private var domeData:BitmapData;
		private var r:Number;
		private var h:Number;
		private var layer:Sprite;
        
		public function FlashTest() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			url = "http://farm4.static.flickr.com/3195/2694620804_ab0fc9137f.jpg";
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, comp)
			loader.load(new URLRequest(url), new LoaderContext(true));
		}
		
		private function comp(e:Event):void 
		{
			domeData = new BitmapData(loader.width, loader.height);
			domeData.draw(loader);
            addChild(loader);
			
            layer = new Sprite();
            addChild(layer);
            
			createDome(168, 290, 113);
			
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
        
        private var circleX:Number;
        private var circleY:Number;
        private var circleR:Number;
        private function onDown(e:MouseEvent):void 
        {
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
            circleX = mouseX;
            circleY = mouseY;
            circleR = 0;
            stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
        }
        
        private function mouseMove(e:MouseEvent):void 
        {
            var dx:Number = mouseX - circleX;
            var dy:Number = mouseY - circleY;
            circleR = Math.sqrt(dx * dx + dy * dy);
            var g:Graphics = layer.graphics;
            g.clear();
            g.lineStyle(1, 0xffffff, 0.5);
            g.drawCircle(circleX, circleY, circleR);
        }
        
        private function mouseUp(e:MouseEvent):void 
        {
            layer.graphics.clear();
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
            
            if (circleR == 0) return;
            
			createDome(circleX, circleY, circleR);
       }
	   
       private var dm:Dome;
	   private function createDome(x:Number, y:Number, r:Number):void
	   {
            if (dm) removeChild(dm);
            dm = new Dome(domeData, x, y, r, r, 16, 8);
			dm.x = x;
			dm.y = y;
            addChild(dm);
	   }
		
	}
	
}

    import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.TriangleCulling;
	import flash.events.Event;
    import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
    class Dome extends Sprite
    {
        private var _bitmapData :BitmapData;
        private var _x:Number;
        private var _y:Number;
        private var _r:Number;
        private var _h:Number;
        
        private var _n:uint;
        private var disks:Vector.<Disk>;
		private var startIndices:Vector.<uint>;
        private var func:DomeFunction;
        private var vertices:Vector.<Number>;
        private var indices:Vector.<int>;
        private var uvtData:Vector.<Number>;
		private var mat:Matrix;
		
		private var oscillators:Vector.<Oscillator>;
        
		private var showsLines:Boolean;
        private var isMouseOn:Boolean;
		
		/**
		 * 
		 * @param	bitmapData ターゲットのBitmapData
		 * @param	x BitmapData上の位置
		 * @param	y
		 * @param	r 半径
		 * @param	h 高さ
		 * @param	polygon 円をN角形で近似
		 * @param	diskNumber Diskを何枚重ねてDomeとするか
		 */
        public function Dome(bitmapData:BitmapData,
            x:Number, y:Number, r:Number, h:Number,
            polygon:uint, diskNumber:uint ) 
        {
			_bitmapData = bitmapData;
            _x = x;
            _y = y;
            _r = r;
            _h = h;
            _n = polygon;
			mat = new Matrix(1, 0, 0, 1, -x, -y);
            disks = new Vector.<Disk>();
			startIndices = new Vector.<uint>();
			oscillators = new Vector.<Oscillator>();
            func = new CircFunction(_r, _h, 0.1 * _h);
			vertices = new Vector.<Number>();
            vertices.push(0, 0);
			uvtData = new Vector.<Number>();
            uvtData.push(x / _bitmapData.width, y / _bitmapData.height);
            var i:int;
            var height:Number;
            var radius:Number;
            var disk:Disk;
			var osc:Oscillator;
			var thickness: Number = _h / diskNumber;
            for (i = diskNumber - 1; i > -1; i--) 
            {
                height = i * thickness;
                radius = func.domeRadius(height);
				
                disk = new Disk(bitmapData.rect, x, y, radius, polygon)
                disks.push(disk);
				
				startIndices.push(vertices.length);
                disk.mergeVertices(vertices, vertices.length);
                disk.mergeUVData(uvtData, uvtData.length);
				
				osc = new Oscillator();
				osc.mass = thickness * radius * radius;
				osc.z = height;
				osc.spring = _h * _r * _r;
				oscillators.push(osc);
            }
            
			buildIndices();
            redrawDome();
			
			addEventListener(Event.ENTER_FRAME, update);
            addEventListener(MouseEvent.CLICK, onClick);
            addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        }
        
        private function onMouseOut(e:MouseEvent):void 
        {
            isMouseOn = false;
        }
        
        private function onMouseOver(e:MouseEvent):void 
        {
            isMouseOn = true;
        }
        
        private function onClick(e:MouseEvent):void 
        {
            showsLines = !showsLines;
        }
		
		private function buildIndices():void
		{
			indices = new Vector.<int>();
			var i:int;
			for (i = 1; i < _n; i++) 
			{
				indices.push(0, i, i + 1);
			}
			indices.push(0, _n, 1);
            var j: int;
			var length:uint = disks.length;
			for (j = 1; j < length; j++)
            {
                var jn:uint = j * _n;
                var j1n:uint = (j - 1) * _n;
                for (i = 1; i < _n; i++) 
                {
                    var i1:uint = i + 1;
                    indices.push(j1n + i, jn + i, jn + i1);
                    indices.push(j1n + i, jn + i1, j1n + i1);
                }
                indices.push(jn, jn + _n, jn + 1);
                indices.push(jn, jn + 1, j1n + 1);
            }
			indices = indices.reverse();
		}
		
		private function update(e:Event):void 
		{
            if (isMouseOn)
            {
				var f0:Number = 0.001 * _h * _r * _r;
                var dist:Number = Math.sqrt(mouseX * mouseX + mouseY * mouseY);
                var fx:Number = - f0 * mouseX / dist;
                var fy:Number = - f0 * mouseY / dist;
            }
            
			var i:int;
			var length:uint = disks.length;
			var disk:Disk;
			var disk1:Disk;
			var osc:Oscillator;
            for (i = length - 2; i > -1; i--) 
            {
                disk = disks[i];
				disk1 = disks[i + 1]
				osc = oscillators[i];
                if (isMouseOn) osc.addForce(fx, fy);
				osc.update();
				disk.moveTo(disk1.x + osc.x, disk1.y + osc.y);
                disk.mergeVertices(vertices, startIndices[i]);
            }
			disk = disks[0];
            disk1 = disks[1]
            vertices[0] = 2 * disk.x - disk1.x;
            vertices[1] = 2 * disk.y - disk1.y;
			redrawDome();
		}
        
        private function redrawDome():void
        {
            graphics.clear();
            if(showsLines)graphics.lineStyle(0, 0xffffff, 0.5);
            graphics.beginBitmapFill(_bitmapData, mat, false, true);
            graphics.drawTriangles(vertices, indices, uvtData, TriangleCulling.POSITIVE);
        }
        
        public function get bitmapData():BitmapData { return _bitmapData; }
        
        public function get r():Number { return _r; }
        
        public function get h():Number { return _h; }
                
    }

	import flash.geom.Rectangle;
	
	class Disk
	{
		private var _x:Number;
		private var _y:Number;
		private var _n:uint;
		private var _uvData:Vector.<Number>;
		private var _dRad:Number;
		
		private var _r:Number;
		private var _vertices:Vector.<Number>;
		private var _rotation:Number;
		
		public function Disk(rect:Rectangle, trimX:Number, trimY:Number, trimR:Number, n:uint) 
		{
			_x = 0;
			_y = 0;
			_r = trimR;
			_n = n;
			_vertices = new Vector.<Number>();
			_uvData = new Vector.<Number>();
			_dRad = 2 * Math.PI / _n;
			_rotation = 0;
			initializeUV(rect.width, rect.height, trimX, trimY, trimR);
			updateVertices();
		}
		
		private function initializeUV(w:Number, h:Number, x:Number, y:Number, r:Number):void
		{
			for (var i:uint = 0; i < _n; i++) 
			{
				var cos:Number = Math.cos(i * _dRad);
				var sin:Number = Math.sin(i * _dRad);
				var _2i:uint = i << 1;
				_uvData[_2i] = (x + r * cos) / w;
				_uvData[_2i + 1] = (y + r * sin) / h;
			}
		}
		
		private function updateVertices():void
		{
			var rad:Number = _rotation;
			for (var i:uint = 0; i < _n; i++) 
			{
				var cos:Number = Math.cos(rad);
				var sin:Number = Math.sin(rad);
				var _2i:uint = i << 1;
				_vertices[_2i] = _x + _r * cos;
				_vertices[_2i + 1] = _y + _r * sin;
				rad += _dRad;
			}
		}
		
		public function move(dx:Number, dy:Number):void
		{
			for (var i:uint = 0; i < _n; i++) 
			{
				var _2i:uint = i << 1;
				_vertices[_2i] += dx;
				_vertices[_2i + 1] += dy;
			}
			_x += dx;
			_y += dy;
		}
		
		public function moveTo(x:Number, y:Number):void
		{
			move(x - _x, y - _y);
		}
		
		public function mergeVertices(vertices:Vector.<Number>, startIndex:uint):void
		{
			mergeVector(vertices, startIndex, _vertices);
		}
		
		public function mergeUVData(uvData:Vector.<Number>, startIndex:uint):void
		{
			mergeVector(uvData, startIndex, _uvData);
		}
		
		private function mergeVector(into:Vector.<Number>, start:uint, from:Vector.<Number>):void
		{
			var last:uint = (_n << 1) + start;
			var i:uint = start;
			var j:uint = 0;
			for (; i < last;) 
			{
				into[i++] = from[j++]
			}
		}
		
		public function get x():Number { return _x; }
		
		public function set x(value:Number):void 
		{
			move(value - _x, 0);
		}
		
		public function get y():Number { return _y; }
		
		public function set y(value:Number):void 
		{
			move(0, value - _y);
		}
		
		public function get r():Number { return _r; }
		
		public function set r(value:Number):void 
		{
			_r = value;
			updateVertices();
		}
		
		public function get rotation():Number { return _rotation; }
		
		public function set rotation(value:Number):void 
		{
			_rotation = value;
			updateVertices();
		}
	}
	
    class Oscillator
    {
		public static const G:Number = 1.0; //振動子にはたらくy方向の重力
		public static const K:Number = 1.1; //ばねの強さ
		public static const R:Number = 0.9; //減衰の大きさ
		
        public var x:Number;
        public var y:Number;
		
        private var vx:Number;
        private var vy:Number;
        private var ax:Number;
        private var ay:Number;
        
        public var mass:Number;
		public var z:Number;
		public var spring:Number;
        
        public function Oscillator() 
        {
			x = 0;
			y = 0;
			vx = 0;
			vy = 0;
			ax = 0;
			ay = 0;
        }
        public function update():void
        {
			var param:Number = K * spring / z / mass;
            ax = - param * x;
			ay = - param * y + G;
            vx += ax;
            vy += ay;
			vx *= R;
			vy *= R;
            x += vx;
            y += vy;
        }
        public function addForce(fx:Number, fy:Number):void
        {
            var param:Number = z / mass;
            vx += param * fx;
            vy += param * fy;
        }
		
    }
	
	class DomeFunction
	{		
		private var alpha:Number;
		private var beta:Number;
		private var gamma:Number;
		
		protected function basicFunction(x:Number):Number
		{
			throw "override basicFunction()";
		}
		protected function basicInverse(y:Number):Number
		{
			throw "override basicInverse()";
		}
		
		public function DomeFunction(radius:Number, height:Number, depth:Number) 
		{
			gamma = depth;
			beta = height + gamma;
			alpha = radius / basicInverse(gamma / beta);
		}
		
		public final function domeHeight(radius:Number):Number
		{
			return beta * basicFunction(radius / alpha) - gamma;
		}
		
		public final function domeRadius(height:Number):Number
		{
			return alpha * basicInverse((height + gamma) / beta);
		}
	}
	
	class CircFunction extends DomeFunction
	{
		override protected function basicFunction(x:Number):Number 
		{
			return Math.sqrt(1 - x * x);
		}
		override protected function basicInverse(y:Number):Number 
		{
			return Math.sqrt(1 - y * y);
		}
		public function CircFunction(radius:Number, height:Number, depth:Number) 
		{
			super(radius, height, depth);
		}
		
	}


