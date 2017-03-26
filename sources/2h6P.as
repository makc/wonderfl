// It was a tricky task to scroll seamless mountains.
// Click to see how it works.

// 繋ぎ目のない山を無限スクロールさせるのにちょっと悩みました。
// クリックでどうなってるのかネタバレします。

// 架線柱のティアリングがひどいなあ……。

package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	[SWF(width = "465", height = "465", frameRate = "40")]
	public class Main extends Sprite
	{
		public static const WIDTH:Number = 465;
		public static const HEIGHT:Number = 465;
		
		private var debug:Boolean = false;

		private var entities:Vector.<Entity> = new Vector.<Entity>();

		public function Main():void
		{
			// 空を描画
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(WIDTH, HEIGHT, Math.PI / 2);
			graphics.beginGradientFill(GradientType.LINEAR, [0xD5E1FB, 0xFFFFFF], null, [0, 128], matrix);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
			
			var fogR:Number = 116;
			var fogG:Number = 126;
			var fogB:Number = 143;
			
			var mountainR:Number = 23;
			var mountainG:Number = 21;
			var mountainB:Number = 32;
			
			const NUMBER_OF_MOUNTAINS:int = 4;
			
			for (var i:int = 0; i < NUMBER_OF_MOUNTAINS; i++) {
				var blend:Number = i / (NUMBER_OF_MOUNTAINS - 1);
				
				var _r:Number = lerp(fogR, mountainR, blend);
				var _g:Number = lerp(fogG, mountainG, blend);
				var _b:Number = lerp(fogB, mountainB, blend);
				
				var baseHeight:Number = HEIGHT / 2 + i * 25;
				var color:uint = (_r << 16) | (_g << 8) | _b;
				
				var mountain:Mountain = new Mountain(-Math.pow(i + 1, 2), baseHeight, color);
				entities.push(addChild(mountain));
			}
			
			entities.push(addChild(new PoleAndWire()));
			entities.push(addChild(new Tunnel()));
			
			var outline:Shape = new Shape();
			var g:Graphics = outline.graphics;
			g.lineStyle(1, 0x808080);
			g.drawRect( -1, -1, WIDTH + 2, HEIGHT + 2);
			addChild(outline);
			
			restoreFilters(debug);
			
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			debug = !debug;
			
			var matrix:Matrix = new Matrix();
			if (debug) {
				// transformで表示領域外を確認。お手軽でいいと思う。
				matrix.scale(0.2, 0.2);
				matrix.translate(WIDTH * 0.4, HEIGHT * 0.4);
			}
			transform.matrix = matrix;
			
			restoreFilters(debug);
		}
		
		private function restoreFilters(debug:Boolean):void
		{
			for each (var entity:Entity in entities)
			{
				entity.restoreFilter(debug);
			}
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			for each (var entity:Entity in entities)
			{
				entity.update();
			}
		}
	}
}

import flash.display.*;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.geom.Matrix;

class Entity extends Sprite
{
	public function update():void { };
	public function restoreFilter(debug:Boolean):void { };
}

class Mountain extends Entity
{
	private var heightMap:Vector.<Number> = new Vector.<Number>();
	private const SEGMENT_LENGTH:Number = 10;
	
	private var baseHeight:Number;
	private var color:uint;
	private var speed:Number;
	
	function Mountain(speed:Number, baseHeight:Number, color:uint)
	{
		this.baseHeight = baseHeight;
		this.color = color;
		this.speed = speed;
		
		generateHeightMap();
		createShape();
	}
	
	public override function update():void
	{
		x += speed;
		if (x < -(width - Main.WIDTH)) {
			var removeSegmentNumber:int = (width - Main.WIDTH) / SEGMENT_LENGTH;
			heightMap.splice(0, removeSegmentNumber);
			x += removeSegmentNumber * SEGMENT_LENGTH;
			
			generateHeightMap();
			createShape();
		}
	}
	
	private function generateHeightMap():void
	{
		// 再帰で分割していく
		divide(baseHeight, baseHeight, 0, 200);
		
		function divide(left:Number, right:Number, depth:int, offset:Number):void
		{
			if (depth < 6) {
				var half:Number = (left + right) / 2 + rnd( -offset / 2, offset / 2);
				
				divide(left, half, depth + 1, offset / 2);
				divide(half, right, depth + 1, offset / 2);
			} else {
				// 十分に分割したら順番に書き出し
				heightMap.push(left);
			}
		}
	}
		
	private function createShape():void
	{
		var g:Graphics = graphics;
		
		g.clear();
		g.beginFill(color);
		g.moveTo(0, Main.HEIGHT);
		for (var i:int = 0; i < heightMap.length; i++) {
			g.lineTo(i * SEGMENT_LENGTH, heightMap[i]);
		}
		g.lineTo((i - 1) * SEGMENT_LENGTH, Main.HEIGHT);
		g.endFill();
		
		// デバッグ表示
		g.lineStyle(1, color);
		g.moveTo(0, heightMap[0]);
		g.lineTo(0, Main.HEIGHT * 2);
	}
}

const SPEED:Number = 80;

class PoleAndWire extends Entity
{
	private const SPACING:Number = Main.WIDTH * 5;
	
	private const POLE_THICK:Number = 40;
	private const WIRE_TOP:Number = 20;
	private const WIRE_BOTTOM:Number = 100;
	
	function PoleAndWire()
	{
		var g:Graphics = graphics;
		
		g.beginFill(0x333344);
		g.drawRect(-POLE_THICK / 2, 0, POLE_THICK, Main.HEIGHT);
		g.endFill();
		
		g.lineStyle(1, 0x222233);
		g.moveTo(POLE_THICK / 2, WIRE_TOP);
		g.curveTo(SPACING / 2, WIRE_BOTTOM, SPACING - POLE_THICK, WIRE_TOP);
		g.moveTo(-POLE_THICK / 2, WIRE_TOP);
		g.curveTo(-SPACING / 2, WIRE_BOTTOM, -SPACING + POLE_THICK, WIRE_TOP);
		
		x = (SPACING + Main.WIDTH) / 2;
	}
	
	public override function update():void
	{
		x -= SPEED;
		if (x < (-SPACING + Main.WIDTH) / 2) {
			x += SPACING;
		}
	}
	
	public override function restoreFilter(debug:Boolean):void
	{
		filters = debug ? null : [ new BlurFilter(80, 0, 1) ];
	}
}

class Tunnel extends Entity
{
	// |ENTRANCE|SPACE|LIGHT|SPACE|ENTRANCE|
	// ^ origin
	
	private const LIGHT:Number = 100;
	private const SPACE:Number = Main.WIDTH * 1.4;
	private const ENTRANCE:Number = Main.WIDTH * 1.5;
	private const WIDTH:Number = LIGHT + SPACE * 2 + ENTRANCE * 2;
	
	private const ENTRANCE_COLOR:uint = 0x888899;
	private const DARKNESS_COLOR:uint = 0x0A0908;
	private const LIGHT_COLOR:uint = 0xFFF0E0;
	
	private var lightCount:int;
	private var light:Shape;
	
	function Tunnel()
	{
		var g:Graphics = graphics;
		
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(ENTRANCE, Main.HEIGHT);
		g.beginGradientFill(GradientType.LINEAR, [ENTRANCE_COLOR, DARKNESS_COLOR], null, [0, 255], matrix);
		g.drawRect(0, 0, ENTRANCE, Main.HEIGHT);
		matrix.createGradientBox(ENTRANCE, Main.HEIGHT, 0, WIDTH - ENTRANCE, 0);
		g.beginGradientFill(GradientType.LINEAR, [DARKNESS_COLOR, ENTRANCE_COLOR], null, [0, 255], matrix);
		g.drawRect(WIDTH - ENTRANCE, 0, ENTRANCE, Main.HEIGHT);
		g.endFill();
		
		g.beginFill(DARKNESS_COLOR);
		g.drawRect(ENTRANCE, 0, LIGHT + SPACE * 2, Main.HEIGHT);
		g.endFill();
		
		light = new Shape();
		light.graphics.beginFill(LIGHT_COLOR);
		light.graphics.drawRect(WIDTH / 2, Main.HEIGHT * 0.55, LIGHT, 20);
		light.graphics.endFill();
		addChild(light);
		
		prepareNextTunnel();
		
		// 最初のトンネルまでは定距離にする。
		x = SPEED * 600;
	}
	
	public override function update():void
	{
		x -= SPEED;
		if (x < -(WIDTH - ENTRANCE - Main.WIDTH)) {
			if (--lightCount >= 0) {
				// ライトをループ
				x += SPACE * 2 + LIGHT - Main.WIDTH;
				trace(length);
			}
		}
		if (x < -WIDTH * 2) {
			prepareNextTunnel();
		}
	}
	
	public override function restoreFilter(debug:Boolean):void
	{
		filters = debug ? null : [ new BlurFilter(80, 0, 1) ];
		light.filters = debug ? null : [ new GlowFilter(0xFF8000, 1, 50, 50, 3, 4) ];
	}
	
	private function prepareNextTunnel():void
	{
		x = SPEED * rnd(300, 1500);
		lightCount = rnd(6, 60);
	}
}

// 線形補間
function lerp(n0:Number, n1:Number, p:Number):Number
{
	return n0 * (1 - p) + n1 * p;
}

// [min, max)の乱数を取得
function rnd(min:Number, max:Number):Number
{
	return min + Math.random() * (max - min);
//	return lerp(min, max, Math.random());
}


