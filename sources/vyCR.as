// yd_niku さんの
// Flight404 の人のコードをAS3にしてみた ver2
// http://wonderfl.kayac.com/code/881224c6000816b64f79b854671a48eeeac7c8d0
// をもとに Flash でもそれなりの速度が出るよう書き直した

// 画像をプリレンダリングしたり
// Particle オブジェクトを使い回したり
// 機を見て BitmapData.draw でなく BitmapData.copyPixels を使ったり等している

// trails は未実装

package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	//import com.flashdynamix.utils.SWFProfiler;

	 [SWF(backgroundColor="#000000", frameRate="40")]

	public class Particles extends Sprite {

		private var canvas:BitmapData;
		private var emitter:Emitter;
		private var mousePressed:Boolean;
		private var stats:TextField;

		public function Particles() {
			//SWFProfiler.init(stage, this);
			stage.quality = "low";
			stage.scaleMode = "noScale";
			stage.align = "TL";

			canvas = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000);
			addChild(new Bitmap(canvas));
			emitter = new Emitter(canvas);

			/*stats = new TextField();
			stats.x = 5;
			stats.y = 5;
			stats.autoSize = "left";
			stats.textColor = 0xFFFFFF;
			addChild(stats);*/

			addEventListener(Event.ENTER_FRAME, render);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				mousePressed = true;
			});
			stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
				mousePressed = false;
			});
		}

		public function render(e:Event):void {
			emitter.moveTo(mouseX, mouseY);
			if (mousePressed) emitter.emitParticles(10);
			canvas.lock();
			canvas.fillRect(canvas.rect, 0x000000);
			emitter.render();
			canvas.unlock();
		}

	}
}

import flash.display.*;
import flash.geom.*;

class Emitter {

	private var position:Vector3D = new Vector3D();
	private var velocity:Vector3D = new Vector3D();
	private var canvas:BitmapData;
	private var particles:Vector.<Particle> = new Vector.<Particle>(500, true);
	private var candicates:uint = 0;

	public function Emitter(canvas:BitmapData) {
		this.canvas = canvas;
		var n:int = particles.length;
		while (n--) particles[n] = new Particle(canvas);
	}

	public function moveTo(x:Number, y:Number):void {
		velocity.x = (x - position.x) * 0.35;
		velocity.y = (y - position.y) * 0.35;
		position.incrementBy(velocity);
	}

	public function render():void {
		var n:int = particles.length;
		var particle:Particle;
		while (n--) {
			particle = particles[n];
			if (particle.alive) {
				particle.render();
			} else if (candicates) {
				candicates--;
				var p:Vector3D, v:Vector3D;
				p = position.clone();
				p.x += (Math.random() - 0.5) * 5;
				p.y += (Math.random() - 0.5) * 5;
				p.z += (Math.random() - 0.5) * 5;
				v = velocity.clone();
				v.x += (Math.random() - 0.5) * 10;
				v.y += (Math.random() - 0.5) * 10;
				v.z += (Math.random() - 0.5) * 10;
				particle.init(p, v);
			}
		}
	}

	public function emitParticles(n:uint):void {
		candicates += n;
	}

}

class Particle {

	static private const FLOOR_LEVEL:uint = 360;
	static private const Z_FAR:uint = 1000;

	// 画像はあらかじめ全て用意しておく
	static private const IMAGES:Vector.<BitmapData> = loadImages();

	private var position:Vector3D;
	private var velocity:Vector3D;
	private var canvas:BitmapData;
	//private var trail:Vector.<Vector3D>;
	private var lifeSpan:uint;
	private var age:uint;
	private var bounce:uint;
	private var images:Vector.<BitmapData>;
	private var matrix:Matrix = new Matrix();
	private var transform:ColorTransform = new ColorTransform();
	private var point:Point = new Point();
	private var rectangle:Rectangle = new Rectangle();
	public  var alive:Boolean = false;

	static private function loadImages():Vector.<BitmapData> {
		var s:Shape = new Shape();
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(64, 64);
		s.graphics.beginGradientFill(GradientType.RADIAL, [0xFFFFFF, 0xFF0000, 0xFF0000], [1, 0.2, 0], [0, 88, 255], matrix);
		s.graphics.drawCircle(32, 32, 32);
		s.graphics.endFill();
		var images:Vector.<BitmapData> = new Vector.<BitmapData>(64 * 64, true);
		var transform:ColorTransform = new ColorTransform();
		for (var i:int = 0; i < 64; i++) {
			for (var j:int = 1; j < 64; j++) {
				var image:BitmapData = new BitmapData(j, j, true, 0x000000);
				matrix.identity();
				matrix.scale(j/64, j/64);
				transform.blueOffset = i * 4;
				image.draw(s, matrix, transform);
				images[int(i * 64 + j)] = image;
			}
		}
		return images;
	}

	public function Particle(canvas:BitmapData) {
		this.canvas = canvas;
		images = IMAGES;
	}

	public function init(p:Vector3D, v:Vector3D):void {
		position = p;
		velocity = v;
		lifeSpan = (Math.random() + 0.5) * 60;
		age    = 0;
		bounce = 0;
		alive  = true;
	}

	public function render():void {
		var d:Number = position.x + position.y + position.z;
		velocity.x += Math.cos(d) * 0.5;
		velocity.y += Math.sin(d) * 0.5 + 0.35;
		velocity.z += Math.cos(d) * -0.5;
		if (position.y > FLOOR_LEVEL) {
			velocity.scaleBy(0.75);
			velocity.y *= -0.5;
			bounce++;
			age += bounce * 3;
		} else {
			age++;
		}
		position.x += velocity.x;
		position.y += velocity.y;
		position.z += velocity.z;
		//trail.push(position.clone());

		if (age < lifeSpan) {
			var perspective:Number = Z_FAR / (Z_FAR - position.z);
			var diameter:uint = (lifeSpan - age) * perspective * 0.64;
			var color:uint = 64 * age / lifeSpan;
			if (diameter <= 0 || 64 <= diameter) return;
			if (age < 20) {
				matrix.tx = position.x * perspective - diameter * 0.5;
				matrix.ty = position.y * perspective - diameter * 0.5;
				canvas.draw(images[int(color * 64 + diameter)], matrix, null, BlendMode.LIGHTEN);
			} else { // draw は重いので copyPixels でごまかす
				point.x = position.x * perspective - diameter * 0.5;
				point.y = position.y * perspective - diameter * 0.5;
				rectangle.width = rectangle.height = diameter;
				canvas.copyPixels(images[int(color * 64 + diameter)], rectangle, point, null, null, true);
			}
		} else {
			alive = false;
		}
	}

}

