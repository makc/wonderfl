package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	//import net.hires.debug.Stats;
	[SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#FFFFFF")]
	
	/**
	 * ボロノイ図描画
	 * Quasimondo 先生が 2002 年に書いたコードの写経です。
	 * ステージをクリックしてね。何度も何度もクリックしてね。
	 * オリジナル：http://www.quasimondo.com/archives/000110.php
	 * 説明：http://aquioux.blog48.fc2.com/blog-entry-654.html
	 */
	public class Main extends Sprite {
		private const STAGE_WIDTH:uint  = stage.stageWidth;
		private const STAGE_HEIGHT:uint = stage.stageHeight;

		private var dots:Array;		// Dot の配列
		private var sx:Array;		// 線開始座標（X座標）
		private var sy:Array;		// 線開始座標（Y座標）
		private var ex:Array;		// 線終了座標（X座標）
		private var ey:Array;		// 線終了座標（Y座標）
		
		private var dotLayer:Sprite;		// ドットのコンテナ
		private var lineLayer:Sprite;		// 線描画用レイヤ
		private var textField:TextField;	// "Click STAGE"
		
		
		public function Main():void {
			// 配列初期化
			dots = [];
			sx = [];
			sy = [];
			ex = [];
			ey = [];
			
			// コンテナ等
			addChild(dotLayer  = new Sprite());
			addChild(lineLayer = new Sprite());
			//addChild(new Stats());
			textField = new TextField();
			textField.defaultTextFormat = new TextFormat("_serif", 20, 0x000000);
			textField.text = "Click STAGE";
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.selectable = false;
			textField.x = (STAGE_WIDTH  - textField.width)  / 2;
			textField.y = (STAGE_HEIGHT - textField.height) / 2;
			addChild(textField);
			
			// 最初に Dot を3つ配置
			for (var i:int = 0; i < 3; i++) {
				addDot(Math.random() * STAGE_WIDTH, Math.random() * STAGE_HEIGHT);
			}
			
			// イベントリスナー
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		

		// ENTER_FRAME
		private function enterFrameHandler(event:Event):void {
			moveDot();		// Dot の移動
			setVoronoi();	// ボロノイ境界線の計算
			drawVolonoi();	// ボロノイ境界線の描画
		}
		
		// Dot の移動
		private function moveDot():void {
			var n:uint = dots.length;
			for (var i:int = 0; i < n; i++) {
				var dot:Dot = dots[i];
				dot.update();
			}
		}
		
		// ボロノイ境界線の計算
		private function setVoronoi():void {
			var a:Number;
			var b:Number;
			var a0:Number;
			var b0:Number;
			var a1:Number;
			var b1:Number;
			var x:Number;
			var y:Number;
			var x0:Number;
			var y0:Number;
			var x1:Number;
			var y1:Number;
			
			var n:uint = dots.length;
			var m:uint = n + 3;
			for (var i:int = 0; i < n; i++) {
				x0 = dots[i].x;
				y0 = dots[i].y;
				var idx1:int = i * m + i + 1;
				for (var j:int = i + 1; j < n; j++) {
					x1 = dots[j].x;
					y1 = dots[j].y;
					
					if (x1 == x0) {
						a = 0;
					} else if (y1 == y0) {
						a = 10000;
					} else {
						a = -1 / ((y1 - y0) / (x1 - x0));
					}
					
					b = (y0 + y1) / 2 - a * (x0 + x1) / 2;
					
					if (a > -1 && a <= 1) {
						sx[idx1] = 0;
						sy[idx1] = a * sx[idx1] + b;
						ex[idx1] = STAGE_WIDTH - 1;
						ey[idx1] = a * ex[idx1] + b;
					} else {
						sy[idx1] = 0;
						sx[idx1] = (sy[idx1] - b) / a;
						ey[idx1] = STAGE_HEIGHT - 1;
						ex[idx1] = (ey[idx1] - b) / a;
					}
					idx1++;
				}
				sx[idx1] = 0;
				sy[idx1] = 0;
				ex[idx1] = STAGE_WIDTH;
				ey[idx1] = 0;
				idx1++;
				sx[idx1] = 0;
				sy[idx1] = 0;
				ex[idx1] = 0;
				ey[idx1] = STAGE_HEIGHT;
				idx1++;
				sx[idx1] = STAGE_WIDTH;
				sy[idx1] = 0;
				ex[idx1] = STAGE_WIDTH;
				ey[idx1] = STAGE_HEIGHT;
				idx1++;
				sx[idx1] = 0;
				sy[idx1] = STAGE_HEIGHT;
				ex[idx1] = STAGE_WIDTH;
				ey[idx1] = STAGE_HEIGHT;
			}
			
			for (i = 0; i < n; i++) {
				x0 = dots[i].x;
				y0 = dots[i].y;
				for (j = 0; j < m + 1; j++) {
					if (j != i) {
						if (j > i) {
							idx1 = i * m + j;
						} else {
							idx1 = j * m + i;
						}
						if (sx[idx1] > -Number.MAX_VALUE) {
							a0 = (ey[idx1] - sy[idx1]) / (ex[idx1] - sx[idx1]);
							b0 = sy[idx1] - a0 * sx[idx1];
							for (var k:int = i + 1; k < m + 1; k++) {
								if (k != j) {
									var idx2:int = i * m + k;
									if (sx[idx2] > -Number.MAX_VALUE) {
										a1 = (ey[idx2] - sy[idx2]) / (ex[idx2] - sx[idx2]);
										b1 = sy[idx2] - a1 * sx[idx2];
										x = -(b1 - b0) / (a1 - a0);
										y = a0 * x + b0;
										if ((a0 * x0 + b0 - y0) * (a0 * sx[idx2] + b0 - sy[idx2]) < 0) {
											sx[idx2] = x;
											sy[idx2] = y;
										}
										if ((a0 * x0 + b0 - y0) * (a0 * ex[idx2] + b0 - ey[idx2]) < 0) {
											if (sx[idx2] == x) {
												sx[idx2] = -Number.MAX_VALUE;
											} else {
												ex[idx2] = x;
												ey[idx2] = y;
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		
		// ボロノイ境界線の描画
		private function drawVolonoi():void {
			lineLayer.graphics.clear();
			lineLayer.graphics.lineStyle(0, 0x666666);

			var n:uint = dots.length;
			var m:uint = n + 3;
			for (var i:int = 0; i < n; i++) {
				var idx:uint = i * m + i + 1;
				for (var j:int = i + 1; j < m + 1; j++) {
					if (sx[idx] > -Number.MAX_VALUE) {
						lineLayer.graphics.moveTo(sx[idx], sy[idx]);
						lineLayer.graphics.lineTo(ex[idx], ey[idx]);
					}
					idx++;
				}
			}
		}
		
		
		// マウスイベント
		private function clickHandler(event:MouseEvent):void {
			if (textField) {
				removeChild(textField);
				textField = null;
			}
			addDot(mouseX, mouseY);
		}

		// Dot をコンテナ上に追加する
		private function addDot(x:Number, y:Number):void {
			var dot:Dot = new Dot();
			dot.x = x;
			dot.y = y;
			dots.push(dot);
			dotLayer.addChild(dot);
		}
	}
}


	import flash.display.Shape;
	import flash.events.Event;
	
	class Dot extends Shape {
		private const RADIUS:uint = 3;
		private var vx:Number = 2.0;	// X軸ベロシティ
		private var vy:Number = 2.0;	// Y軸ベロシティ
		private var sw:Number;			// ステージ幅
		private var sh:Number;			// ステージ高
		
		public function Dot() {
			graphics.beginFill(0xCC0033);
			graphics.drawCircle(0, 0, RADIUS);
			graphics.endFill();
			addEventListener(Event.ADDED_TO_STAGE, addHandler);
		}
		
		private function addHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addHandler);
			sw = stage.stageWidth;
			sh = stage.stageHeight;
			if (Math.random() < 0.5) {
				vx *= -1;
			}
			if (Math.random() < 0.5) {
				vy *= -1;
			}
		}
		
		// 移動
		public function update():void {
			x += vx;
			y += vy;

			if (x < RADIUS) {
				x = RADIUS;
				vx *= -1;
			}
			if (x > sw - RADIUS) {
				x = sw - RADIUS;
				vx *= -1;
			}
			if (y < RADIUS) {
				y = RADIUS;
				vy *= -1;
			}
			if (y > sh - RADIUS) {
				y = sh - RADIUS;
				vy *= -1;
			}
		}
	}
