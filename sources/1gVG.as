// forked from yooKo's TextFieldから文字の輪郭を取得して3Dにして砂の落下アニ・・以下省略
/**
 * @author yooKo@serialField
 * @version 1.5.0
 * Let's Click!
 * Papervision3DのPixcel3Dでまた遊んだ。
 * どうぞご自由に画面をClickしてください。
 * 
 * TextFieldから文字の輪郭を取得して3D上にPixcel3Dで描画 
 *  
 * ソースは荒れすぎてカオスな事になってます！！
 * 途中から自分でも何書いてるか分かんなくなった・・
 * 特にテキストの外枠の座標をとる為にifのネストしまくった
 * 箇所は飯も食わずに6時間悩み続けた・・orz
 * 
 * 後半から変数名とかちょー適当になってます。
 * やけくそで実装しました。「可読性？なにそれ」って感じになってます。 * 
 * 最適化もこれで精いっぱい　汗
 * ifのネストは自分の頭脳ではもう無理です
 *  
 * 今後思いついたらちょくちょく最適化する～
 *
 *
 * クリックイベントが受け取れない！！！ちくしょー
 * ローカルでは問題なかったのに・・
 * 本当はクリックしたらこうなる予定　↓
 * ttp://selflash.jp/wonderfl/Text3DSandAnime
 *
 * 修正：クリックイベントなおった。paqさんがforkしてくれたやつのまねした。　!flgのトグルはやらない方が
 * いいんかも
 * 砂のアニメーションを調整
 *
 * 10/12 21:39 コードの最適化　253行　→　228行になった
 * 228行　→　226行
 * 
 * 10/21 12:40 new Pixel3Dしまくってた箇所恥ずかしかったので修正。配列に突っ込んだ
 **/
package {
	import flash.display.*;
	import flash.text.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.display.StageQuality;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import org.papervision3d.core.effects.BitmapLayerEffect;
	import org.papervision3d.core.effects.BitmapColorEffect;
	import org.papervision3d.core.effects.utils.BitmapClearMode;
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.core.geom.renderables.Pixel3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	
	import net.hires.debug.Stats;	
import com.bit101.components.*;
	[SWF(width="465", height="465", backgroundColor="0x000000", frameRate="60")]

	public class Text3DSandAnime extends BasicView {
		private var _pixels:Pixels;
		private var _rotateX:Number = 0;
		private var _rotateY:Number = 0;
		private var _pixel3Ds:Array/*Pixel3D*/ = []; 
		private var _particles:Array/*Particle*/ = [];
		private var _startTime:int;
		private var _flg:Boolean = false;
		private var _bmd:BitmapData;
		private var _pre:Number;
		private var _i:int;
		private var _a:Number;
		private var _y:Number;
		private var _x:Number;
		private var _c:uint;
		
		private var _textW:Number;
		private var _textH:Number;
		// 地面との距離
		private const GROUND_NUM:int = 70;
		private const CAMERA_DISTANCE:int = -100;
		
		//========================================================================
		// コンストラクタ	
		//========================================================================
		public function Text3DSandAnime() {	
			super(0, 0, true, true);			
			StageQuality.LOW;
			
			if (!stage)
                addEventListener(Event.ADDED_TO_STAGE, init);
            else
                init();
        }
		//========================================================================
		// メイン
		//========================================================================
        private function init(e:Event = null):void {	
            removeEventListener(Event.ADDED_TO_STAGE, init);			
			camera.z = CAMERA_DISTANCE;			
			var _layer:BitmapEffectLayer = new BitmapEffectLayer(viewport, stage.stageWidth, stage.stageHeight, true, 0, BitmapClearMode.CLEAR_PRE, false);
			viewport.containerSprite.addLayer(_layer);
			_layer.addEffect(new BitmapColorEffect(1, 1, 1, .85));
			_layer.addEffect(new BitmapLayerEffect(new BlurFilter(4, 4, 1), false));
			//_layer.clippingPoint = new Point(0, -4);			
			_pixels = new Pixels(_layer);
			scene.addChild(_pixels);	
			
			createText();		
			
			// レイヤー構造でテキストPixel3Dで生成するお～～
			createBody(-12, 2, 0xFFCCCC00);			
			//createFrame(-7, 3, 0xFFFF0066);
			createFrame(-2, 2, 0xFFFF0066);
			//createFrame(3, 2, 0xFFFF0066);
			createFrame(8, 1, 0xFFFFFFFF);	
			
			upDate();
			
			stage.addEventListener(MouseEvent.CLICK, onClickHandler);		
			
			startRendering();	

			new Label(this, 400, 440, "LET'S CLICK!")
			addChild(new Stats());
		}		
		
		//========================================================================
		// textの生成
		//========================================================================
		private function createText():void {
			var sprite:Sprite = new Sprite();
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("小塚ゴシック Pro H", 30, 0x000000, true);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = "SELFISH\n        X";
			_textW = tf.textWidth;
			_textH = tf.textHeight;			
			sprite.addChild(tf);
			
			tf = new TextField();
			tf.x = 10;
			tf.y = 80;
			tf.defaultTextFormat = new TextFormat("小塚ゴシック Pro H", 30, 0xCCFF33, true);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = "FLASH";	
			_textW += tf.textWidth;
			_textH += tf.textHeight + tf.y;
			sprite.addChild(tf);
		
			_bmd = new BitmapData(_textW + 2, _textH + 10, false, 0xFFFFFF);
			_bmd.draw(sprite);
		}		
		//========================================================================
		// ClickHandler
		//　なんか知らないけど _flg = !_flg　がうまくいかなかったから冗長なコードになってしまった
		//========================================================================
		public function onClickHandler(e:MouseEvent = null):void {
			_startTime = getTimer();
			_flg = true;;
		}		
		//========================================================================
		//　常に行う処理
		//========================================================================
		override protected function onRenderTick(event:Event = null):void { 
			renderer.renderScene(scene, _camera, viewport);
		
			_rotateX += (- viewport.containerSprite.mouseX - _rotateX) * 0.1;
			_rotateY += (- viewport.containerSprite.mouseY - 170 - _rotateY) * 0.1;
			_pixels.rotationY = _rotateX;
			_pixels.rotationX = _rotateY;
			
			if (_flg) {
                sandAnimation();
                upDate();
            }
		}
		//========================================================================
		//　描画の更新
		//========================================================================
		private function upDate():void {			
			_pixels.removeAllpixels();
			var len:int = _particles.length;
			for (_i = 0; _i < len; _i++) {
				var p:Particle = _particles[_i];
				var px:Pixel3D;
                if (_pixel3Ds[_i]) {
                    px = _pixel3Ds[_i];
                    px.color = p.c;
                    px.x = p.x;
                    px.y = p.y;
                    px.z = p.z;
                }else {
                    px = new Pixel3D(p.c, p.x, p.y, p.z);
					_pixel3Ds[_i] = px;
                };
                _pixels.addPixel3D(px);			
			}			
		}	
		

		//========================================================================
		// 中身を作成する
		//　いわゆる具ね
		//========================================================================
		public function createBody(depth:int = 0, distance:Number = 2, color:Number = NaN):void {
			var w:Number = _textW * .3;
			var h:Number = _textH * .3;			
				
			for ( _y = 0; _y < _textH; _y += distance ) {
				for ( _x = 0; _x < _textW; _x += distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != 0xFFFFFF) {
						_particles[_i] = new Particle(_x - w, _y - h, depth, color);
						_i++;
					}
				}
			}
		}		
		//========================================================================
		// 枠組みを作成する 
		//　newする時にプロパティ突っ込んだ方が軽いのかな～？？
		//========================================================================
		public function createFrame(depth:int = 4, distance:Number = 1, color:Number = NaN):void {			
			var w:Number = _textW * .3;
			var h:Number = _textH * .3;			
			
			for ( _y = 0; _y < _textH; _y += distance ) {
				for ( _x = 0; _x < _textW; _x += distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != 0xFFFFFF) {
						_a = (_y == 0)?0:_x - w - _pre;
						if (_a > distance || _a < - distance) {
							_c = (color)? color:_c;
							_particles[_i] = new Particle(_x - w, _y - h, depth, _c);
							_i++;
						}
						_pre = _x - w;
					}
				}
			}
			
			for ( _x = 0; _x < _textW; _x += distance ) {
				for ( _y = 0; _y < _textH; _y += distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != 0xFFFFFF) {
						_a = (_x == 0)?0:_y - h - _pre;
						if(_a > distance || _a < - distance) {
							_particles[_i] = new Particle(_x - w, _y - h, depth, color);
							_i++;
						}
						_pre = _y - h;
					}
				}
			}
			
			for ( _y = _textH; _y > 0; _y -= distance ) {
				for ( _x = _textW; _x > 0; _x -= distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != 0xFFFFFF) {
						_a = (_y == _textH)?0:_x - w - _pre;
						if (_a > distance || _a < - distance) {
							_particles[_i] = new Particle(_x - w, _y - h, depth, color);
							_i++;
						}
						_pre = _x - w;
					}
				}
			}
			
			for ( _x = _textW; _x > 0; _x -= distance ) {
				for ( _y = _textH; _y > 0; _y -= distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != 0xFFFFFF) {
						_a = (_x == _textW)?0:_y - h - _pre;
						if (_a > distance || _a < - distance) {
							_particles[_i] = new Particle(_x - w, _y - h, depth, color);
							_i++;
						}
						_pre = _y - h;
					}
				}
			}
		}
		
		//========================================================================
		// 砂のアニメーション	
		// _flgがtrueの時に発動!!!!
		//========================================================================
		private function sandAnimation():void {
			camera.z += (-150 - camera.z) * .2;			

			var now:int = getTimer();
			var len:int = _particles.length;
			for ( _i = 0; _i < len; _i++ ) {
				var p:Particle = _particles[_i];
				if (p.y < GROUND_NUM) {
					var x_delay:Number = (1 - ((p.x + _textW * .7) / _textW )) * 25000;
					var y_delay:Number = (1 - ((p.y + _textH * .8) / _textH )) * 5000;
					var z_delay:Number = (1 - ((p.z + 8 * .5) / 8 )) * 2000;
					var delay:Number = x_delay + y_delay + z_delay;
					if (_startTime + delay > now) continue ;
					p.vy = p.vy * p.af + p.g;
					p.y += p.vy;
				}else {
					p.y = GROUND_NUM;
					p.vx = p.vx * p.gf * (Math.random() - .5) * 3;
					p.x += p.vx;
					p.vz = p.vz * p.gf * (Math.random() - .5) * 3;
					p.z += p.vz;
				}
			}
		}	
	}
}

//========================================================================
// 座標、色情報を保持するプロパティ持ちすぎクラス		
//========================================================================
class Particle {
	public var x:Number;
	public var y:Number;
	public var z:Number;
	public var c:int;	
	//=====================================
	// 砂のアニメーションに使うプロパティ
	//=====================================
	public var g:Number  = .98;
    public var af:Number = .99;
	public var gf:Number = .999999;
	public var vx:Number = 8;
	public var vy:Number = 4;	
	public var vz:Number = 8;
	
	public function Particle(_x:Number, _y:Number, _z:Number, _c:int) {
		x = _x;
		y = _y;
		z = _z;
		c = _c;
	}
}