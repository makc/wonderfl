package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.TriangleCulling;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import sliz.miniui.Checkbox;
	import sliz.miniui.Silder;

	/**
	 * ...
	 * @author sliz http://game-develop.net/blog/
	 */
	public class Test2 extends Sprite {
		private var cm:Matrix3D = new Matrix3D();
		private var cvm:Matrix3D = new Matrix3D();
		private var m:Matrix3D = new Matrix3D();
		private var vm:Matrix3D = new Matrix3D();
		private var p:PerspectiveProjection = new PerspectiveProjection();
		private var pm:Matrix3D = p.toMatrix3D();
		private var vins:Vector.<Number>;
		private var vouts:Vector.<Number> = new Vector.<Number>();
		private var uvts:Vector.<Number>;
		private var indexs:Vector.<int>;
		private var v2ds:Vector.<Number> = new Vector.<Number>();

		private var view:Shape = new Shape();
		private var bmd:BitmapData;
		private var offset:Point = new Point;

		private var uvbmd:BitmapData = new BitmapData(256, 90, false);
		private var fractal:Checkbox;
		private var base:Silder;
		private var numoctaves:Silder;
		private var hscale:Silder;
		private var wave:Checkbox;

		public function Test2(){
			bmd = new BitmapData(50, 50, false);
			indexs = new Vector.<int>();
			for (var j:int = 0; j < bmd.height - 1; j++){
				for (var i:int = 0; i < bmd.width - 1; i++){
					var a:int = j * bmd.width + i;
					indexs.push(a, a + 1, a + bmd.width, a + bmd.width + 1, a + bmd.width, a + 1);
				}
			}

			addEventListener(Event.ENTER_FRAME, render);
			addChild(view);
			view.x = 228;
			view.y = 228;
			addChild(new Bitmap(bmd));
			var uvimage:Bitmap = new Bitmap(uvbmd);
			addChild(uvimage);
			uvimage.x = bmd.width;
			reset();
			stage.addEventListener(MouseEvent.CLICK, reset);

			fractal = new Checkbox("fractal", 310, 0, this);
			fractal.setToggle(true);
			wave = new Checkbox("wave", 310, 20, this);
			base = new Silder(310, 40, this, "base");
			base.value = 0.3;
			numoctaves = new Silder(310, 60, this, "octaves");
			numoctaves.value = 0.5;
			hscale = new Silder(310, 80, this, "hscale");
			hscale.value = 0.5;
		}

		private function reset(e:MouseEvent = null):void {
			var pen:Shape = new Shape();
			var matr:Matrix = new Matrix();
			matr.createGradientBox(uvbmd.width, uvbmd.height);
			var c:int = 7 * Math.random();
			var colors:Array = [];
			var ratios:Array = [];
			var d:int = 0xff / c + 0.5;
			for (var i:int = 0; i < c; i++){
				var rc:uint = 0xffffff * Math.random();
				colors.push(rc, rc);
				ratios.push(d * i, Math.min(d * (i + 0.8), 0xff));
			}
			pen.graphics.beginGradientFill(GradientType.LINEAR, colors, null, ratios, matr);
			pen.graphics.drawRect(0, 0, uvbmd.width, uvbmd.height);
			uvbmd.draw(pen);
			for (i = 0; i < uvbmd.width; i++){
				var color:uint = uvbmd.getPixel(i, 0);
				for (var j:int = 1; j < uvbmd.height; j++){
					var a:Number = (uvbmd.height - j) / uvbmd.height;
					var r:int = (color << 8 >>> 24) * a;
					var g:int = (color << 16 >>> 24) * a;
					var b:int = (color << 24 >>> 24) * a;
					uvbmd.setPixel(i, j, (r << 16) | (g << 8) | b);
				}
			}
		}

		private function render(e:Event):void {
			cm.identity();
			cm.appendTranslation(0, 0, -300);
			cm.appendRotation(70 + view.mouseY / 20, Vector3D.X_AXIS);
			cm.appendRotation(view.mouseX / 20, Vector3D.Y_AXIS);
			offset.x += view.mouseX / 400;
			offset.y += view.mouseY / 400;
			var basev:Number = base.value * 50;
			var numoctavesV:int = numoctaves.value * 5 + 1;
			var offsets:Array = [];
			var c:int = numoctavesV;
			if(wave.getToggle()){
				while (c-- > 0) {
					if(c%2==0){
						offsets.push(new Point(offset.x,0));
					}else {
						offsets.push(new Point(0,offset.y));
					}
				}
			}else {
				while (c-- > 0){
					offsets.push(offset);
				}
			}
			bmd.perlinNoise(basev, basev, numoctavesV, 1, false, fractal.getToggle(), 7, false, offsets);
			vins = new Vector.<Number>();
			uvts = new Vector.<Number>();
			var hscalev:Number = hscale.value;
			for (var j:int = 0; j < bmd.height; j++){
				for (var i:int = 0; i < bmd.width; i++){
					var v:uint = bmd.getPixel(i, j) << 24 >>> 24;
					var v2:uint = bmd.getPixel(i, j + 1) << 24 >>> 24;
					uvts.push(v / 256, (v - v2 + 64) / 100, 0);
					vins.push((i - bmd.width / 2) * 10, (j - bmd.height / 2) * 10, (v - 128) * hscalev);
				}
			}

			cvm.rawData = cm.rawData;
			cvm.invert();
			vm.rawData = m.rawData;
			vm.append(cvm);
			vm.transformVectors(vins, vouts);
			Utils3D.projectVectors(pm, vouts, v2ds, uvts);
			view.graphics.clear();
			view.graphics.beginBitmapFill(uvbmd);
			//view.graphics.lineStyle(0);
			view.graphics.drawTriangles(v2ds, indexs, uvts, TriangleCulling.NEGATIVE);
		}
	}
}