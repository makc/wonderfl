// forked from keno42's 重力＋パーティクル
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
		private var NUM:int = 300;
		private var p:Particle = new Particle();
		private var bd:BitmapData = new BitmapData(465, 465,true,0);
		private var m:Matrix = new Matrix(1, 0, 0, 1,0,0);
		public function Particles() 
		{
            // take a capture after 10 sec
            Wonderfl.capture_delay( 10 );
			var bmp:Bitmap = new Bitmap(bd);
			bd.fillRect(bd.rect, 0);
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
			} while ( current = current.next )
			bd.lock();
			bd.applyFilter(bd, bd.rect, new Point(), new ColorMatrixFilter([
				0.9994, 0, 0, 0, 0,
				0, 0.9994, 0, 0, 0,
				0, 0, 0.9994, 0, 0,
				0, 0, 0, 0.9994, 0,
			]));
			bd.draw(stage);
			bd.applyFilter(bd, bd.rect, new Point(), new BlurFilter(4, 4, 2));
			bd.unlock();
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
		graphics.drawRect(-1, -1, 2, 2);
		init();
	}
	private function init():void{
		var theta:Number = Math.random() * Math.PI * 2;
		var phi:Number = Math.random() * Math.PI; phi = - Math.PI * 0.35;
		// x,y,z: 初期位置の単位ベクトル
		var x:Number = Math.cos(theta); // 最初から x を使うとなにかおかしい
		var y:Number = Math.sin(theta) * Math.cos(phi);
		var z:Number = Math.sin(theta) * Math.sin(phi);
		// px, py, pz: ランダム速度
		var px:Number = Math.random() - 0.5;
		var py:Number = Math.random() - 0.5;
		var pz:Number = Math.random() - 0.5;
		// i: 速度の原点方向の成分の大きさ
		var i:Number = px * x + py * y + pz * z;
		px -= i * x;
		py -= i * y;
		pz -= i * z;
		
		// i: ジャイロの軸方向の成分の大きさ
		i = py * Math.sin(phi) - pz * Math.cos(phi);
		py -= i * Math.sin(phi);
		pz += i * Math.cos(phi);
		
		var p:Number = 1 / Math.sqrt(px * px + py * py + pz * pz);
		px *= p;
		py *= p;
		pz *= p;
		// px, py, pz: 正規化完了
		
		if ( (x * py - y * px) > 0 ) { // 座標と進行方向の外積のz座標
			px *= -1;
			py *= -1;
			pz *= -1;
		}
		// 向きを揃えた
		
		var r:Number = 130+Math.random() * Math.random()*130; // 初期半径
		var v:Number = Math.sqrt(r)*0.185; // 初期速度
		this.x = 232 + r * x; // 232:wonderfl的中心座標
		this.y = 200 + r * y;
		this.z = r * z;
		vx = px * v;
		vy = py * v;
		vz = pz * v;
		this.blendMode = "add";
	}
	public function update(p:Point):void {
		x += vx;
		y += vy;
		z += vz;
		if ( !p ) p = new Point(232, 200);
		var px:Number = x - p.x;
		var py:Number = y - p.y;
		var r:Number = 1000 / Math.pow(px*px+py*py+z*z,1.5);
		vx -= px * r;
		vy -= py * r;
		vz -= z * r;
		
                if( x > 1465 || x < -1000 ){
                    init();
                }
	}
}