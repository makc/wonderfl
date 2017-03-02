package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
        [SWF(width = "465", height = "465", backgroundColor = "0", fps = "30")]
	public class Particles extends Sprite
	{
		private var NUM:int = 200;
		private var p:Particle = new Particle();
		private var bd:BitmapData = new BitmapData(465, 465,true,0);
		private var m:Matrix = new Matrix(1, 0, 0, 1,0,0);
		public function Particles() 
		{
			var bmp:Bitmap = new Bitmap(bd);
			bd.fillRect(bd.rect, 0xFF000000);
			addChild(bmp);
			for ( var i:int = 0; i < NUM; i++ ) {
				var next:Particle = p;
				p = new Particle();
				p.next = next;
				addChild( p );
			}
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onUp);
		}
		private var isDown:Boolean = false;
		private function onDown(e:MouseEvent):void {
			isDown = true;
		}
		private function onUp(e:Event):void {
			isDown = false;
		}
		private function onEnterFrame(e:Event):void {
			if ( !stage ) return;
			var current:Particle = this.p;
			var p:Point = isDown?new Point(stage.mouseX, stage.mouseY):null;
			do{
				current.update(p);
			} while( current = current.next ) 
			bd.applyFilter(bd, bd.rect, new Point(), new ColorMatrixFilter([
				0.9994, 0, 0, 0, 0,
				0, 0.9994, 0, 0, 0,
				0, 0, 0.9994, 0, 0,
				0, 0, 0, 0.9994, 0,
			]));
			bd.draw(stage);
			bd.applyFilter(bd, bd.rect, new Point(), new BlurFilter(4,4,2));
		}
		
	}
	
}
import flash.display.*;
import flash.geom.Point;

class Particle extends Sprite {
	public var next:Particle;
	private var vx:Number;
	private var vy:Number;
	private var vz:Number;
	public function Particle() {
		graphics.beginFill(0x8888| 0xFFFFFF * Math.random(), 1);
		graphics.drawRect(0, 0, 2, 2);
                init();
        }
        private function init():void{
		var theta:Number = Math.random() * Math.PI * 2;
		var phi:Number = Math.random() * Math.PI;
                // x,y,z: 初期位置の単位ベクトル
		x = Math.cos(theta) * Math.sin(phi);
		y = Math.sin(theta) * Math.sin(phi);
		z = Math.cos(phi);
                // px, py, pz: ランダム速度
		var px:Number = Math.random()-0.5;
		var py:Number = Math.random()-0.5;
		var pz:Number = Math.random()-0.5;
                // i: 速度の原点方向の成分の大きさ
		var i:Number =px * x + py * y + pz * z;
		px -= i * x;
		py -= i * y;
		pz -= i * z;
		var p:Number = 1 / Math.sqrt(px * px + py * py + pz * pz);
		px *= p;
		py *= p;
		pz *= p;
                // px, py, pz: 正規化完了
//		trace( x, y, z, px, py, pz, x * px + y * py + z * pz );
		
		var r:Number = 50; // 初期半径
		var v:Number = 2.39; // 初期速度
		x = 232 + r * x; // 232:wonderfl的中心座標
		y = 232 + r * y;
		z = r * z;
		vx = px * v;
		vy = py * v;
		vz = pz * v;
		this.blendMode = "add";
	}
	public function update(p:Point):void {
		if ( !p ) p = new Point(232, 232);
		var px:Number = x - p.x;
		var py:Number = y - p.y;
		var r:Number = 1000 / Math.pow(px*px+py*py+z*z,1.5);
		vx -= px * r;
		vy -= py * r;
		vz -= z * r;
		
		x += vx;
		y += vy;
		z += vz;
                if( x > 1465 || x < -1000 ){
                    init();
                }
	}
}