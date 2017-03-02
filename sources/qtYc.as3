package {
	import flash.display.*;
	
	[SWF(width = "465", height = "465", frameRate = "60")]
	public class Main extends Sprite {
		public function Main() {
			main = this;
			initialize();
		}
	}
}

import flash.display.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.text.*;

var main:Main;
var floor:Sprite = new Sprite();
var space:Sprite = new Sprite();

const SCREEN_W:int = 465;
const SCREEN_H:int = 465;

const FLOOR_Y:Number = 400;

class Ball {
	private var radius:Number;
	
	private var x:Number;
	private var y:Number;
	private var vx:Number;
	private var vy:Number;
	
	// contact offset point for deformation
	private var cx:Number = 0;
	private var cy:Number = 0;
	private var priority:int = 0;
	
	private var body:Shape;
	private var shadow:Shape;
	
	private var shadowFilter:BlurFilter = new BlurFilter();

	private static var matrix:Matrix = new Matrix();
	
	function Ball(radius:Number, color:uint) {
		this.radius = radius;
		
		x = random(radius, SCREEN_W - radius);
		y = random(50, FLOOR_Y - radius);
		vx = random( -1.5, 1.5);
		vy = random( 0, 1.5);
		
		body = new Shape();
		var g:Graphics = body.graphics;
		
		matrix.createGradientBox(radius * 2, radius * 2, 0, -radius, -radius);
		g.beginGradientFill(GradientType.RADIAL, 
			[color, color, color], [0.9, 0.8, 0.4], [0, 240, 255], matrix);
		g.drawCircle(0, 0, radius);
		g.endFill();
		
		shadow = new Shape();
		g = shadow.graphics;
		g.beginFill(0x000050);
		g.drawCircle(0, 0, radius);
		g.endFill();
		
		floor.addChild(shadow);
		space.addChild(body);
	}
	
	// 接触点の絶対座標を指定
	public function contact(contactX:Number, contactY:Number, priority:int, force:Number):void {
		var tx:Number = contactX - x;
		var ty:Number = contactY - y;
		
		var angle:Number = Math.atan2(ty, tx);
		var length:Number = Math.sqrt(tx * tx + ty * ty);
		
		vx -= (1 - length / radius) * force * Math.cos(angle);
		vy -= (1 - length / radius) * force * Math.sin(angle);
		
		// 変形のための接触点は１つしか使用できない。床を優先させる。
		if (this.priority < priority) {
			this.priority = priority;
			cx = tx;
			cy = ty;
		}
	}
	
	public function update():void {
		cx = 0;
		cy = 0;
		priority = 0;
		
		x += vx;
		y += vy;
		
		if (x - radius < 0) {
			contact(0, y, 1, 0.125);
		}
		if (x + radius > SCREEN_W) {
			contact(SCREEN_W, y, 1, 0.125);
		}
		if (y + radius > FLOOR_Y) {
			contact(x, FLOOR_Y, 3, 0.125);
		} else {
			vy += 0.005;
		}
		
		// すごい勢いで壁にぶつかったときは即座に反射
		if (x < 0 || x > SCREEN_W) { vx = -vx; }
		if (y > FLOOR_Y) { vy = -vy; }
		
		// 画面外のボールをこっそり減速して、全体の動きを永続化
		if (y < -radius) {
			vx *= 0.9996;
			vy *= 0.9996;
		}
	}
	
	public function hitTest(ball:Ball):void {
		var dx:Number = ball.x - x;
		var dy:Number = ball.y - y;
		var distanceSquared:Number = dx * dx + dy * dy;
		var contactDistance:Number = radius + ball.radius;
		if (distanceSquared < contactDistance * contactDistance) {
			var tx:Number = linearTransform(radius, 0, contactDistance, x, ball.x);
			var ty:Number = linearTransform(radius, 0, contactDistance, y, ball.y);
			contact(tx, ty, 2, 0.2);
			ball.contact(tx, ty, 2, 0.2);
		}
	}
	
	public function render():void {
		matrix.identity();
		if (priority > 0) {
			var angle:Number = Math.atan2(cy, cx);
			var length:Number = Math.sqrt(cx * cx + cy * cy);
			
			matrix.scale(length / radius, 1 + (1 - length / radius)); // 縦方向は適当
			matrix.rotate(angle);
		}
		matrix.translate(x, y);
		body.transform.matrix = matrix;
		
		var height:Number = FLOOR_Y - (y + radius);
		shadow.x = x;
		shadow.y = FLOOR_Y + height * 0.3;
		shadow.alpha = linearTransform(height, 0, 300, 0.3, 0);
		
		var scale:Number = 1.2 + height * 0.005;
		shadow.width = body.width * scale ;
		shadow.height = body.height * scale * 0.2;
		
		var blur:Number = linearTransform(height, 0, 200, 3, 25);
		shadowFilter.blurX = blur;
		shadowFilter.blurY = blur / 3;
		shadow.filters = [ shadowFilter ];
	}
}

var balls:Vector.<Ball> = new Vector.<Ball>();

function initialize():void {
	balls.push(new Ball(60, 0x000000));
	balls.push(new Ball(45, 0x4040FF));
	balls.push(new Ball(30, 0x20C040));
	balls.push(new Ball(30, 0xA0A0B0));
	balls.push(new Ball(20, 0xC08080));
	balls.push(new Ball(20, 0x706050));
	balls.push(new Ball(20, 0xF0A090));
	
	var background:Shape = new Shape();
	var g:Graphics = background.graphics;
	var matrix:Matrix = new Matrix();
	matrix.createGradientBox(SCREEN_W, SCREEN_H, Math.PI / 2);
	g.beginGradientFill(GradientType.LINEAR, 
		[0xFFFFF8, 0xE0E0E0, 0xD0D0D0, 0xF8F8F0, 0xFFFFF8], null, [0, 150, 168, 170, 255], matrix);
	g.drawRect(0, 0, SCREEN_W, SCREEN_H);
	g.endFill();
	main.addChild(background);
	
	main.addChild(floor);
	main.addChild(space);
	
	main.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
}

function enterFrameHandler(event:Event):void {
	for (var i:int = 0; i < 4; i++) {
		for each (var ball:Ball in balls) {
			ball.update();
		}
		
		for (var n:int = 0; n < balls.length; n++) {
			for (var m:int = n + 1; m < balls.length; m++) {
				balls[n].hitTest(balls[m]);
			}
		}
	}
	
	for each (ball in balls) {
		ball.render();
	}
}

function random(min:Number, max:Number):Number {
	return min + Math.random() * (max - min);
}

function linearTransform(n:Number, s0:Number, s1:Number, d0:Number, d1:Number):Number {
	return (d0 + (n - s0) * (d1 - d0) / (s1 - s0));
}


