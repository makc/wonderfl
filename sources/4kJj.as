// forked from yooKo's 【3DDotText】レイヤー構造で立体に作って作って崩す！
// forked from yooKo's TextFieldから文字の輪郭を取得して3Dにして砂の落下アニ・・以下省略
/**
 * TextFieldから文字の輪郭を取得して3D上にPixcel3Dで描画 
 * 
 * @author yooKo@serialField
 * @version 1.0.0
 * Let's Click!
 * Papervision3DのPixcel3Dでまた遊んだ。
 * どうぞご自由に画面をClickしてください。
 * 3DdotTextが崩れる様をお楽しみください。
 * 
 * 砂の落ち切った後の挙動がおかしいので修正
 *
 * 2009/10/12 21:39 コードの最適化　257行　→　233行になった
 * 233行 →　231行
 * 
 * 2009/10/15 2:16
 * 常に new していた箇所を大幅に変更して配列に突っ込んで処理が軽くなったおかげで
 * 複数の文字も表現できるようになった。
 * 231行 → 300行
 * 
 * 2009/10/17 8:06
 * アニメーションしていない時も常にaddPixel3D()するのは好ましくないので
 * upDate()として切り分けた
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
	
	[SWF(width="465", height="465", backgroundColor="0x000000", frameRate="60")]

	public class TextDot3D extends BasicView {
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
		private const CAMERA_DISTANCE:int = -70;	
		
		//========================================================================
		// コンストラクタ	
		//========================================================================
		public function TextDot3D() {	
			super(0, 0, true, true);			
			stage.quality = StageQuality.LOW;
			
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
			_layer.addEffect(new BitmapColorEffect(1, 1, 1, .93));
			_layer.addEffect(new BitmapLayerEffect(new BlurFilter(16, 16, 1), false));
			_pixels = new Pixels(_layer);
			scene.addChild(_pixels);	
			
			createText();		
			
			// レイヤー構造でテキストPixel3Dで生成するお～～ 計17層
			createBody(-6, 1, 0xFFCCCC00);			
			createFrame(-5.5, 1, 0xFFFF0066);
			createFrame(-5, 1, 0xFFFF0066);
			createFrame(-4.5, 1, 0xFFFF0066);
			createFrame(-4, 1, 0xFFFF0066);
			createFrame(-3.5, 1, 0xFFFF0066);
			createFrame(-3, 1, 0xFFFF0066);
			createFrame(-2.5, 1, 0xFFFF0066);
			createFrame(-2, 1, 0xFFFF0066);
			createFrame(-1.5, 1, 0xFFFF0066);
			createFrame(-1, 1, 0xFFFF0066);
			createFrame(-.5, 1, 0xFFFF0066);
			createFrame(0, 1, 0xFFFF0066);
			createFrame(0.5, 1, 0xFFFF0066);
			createFrame(1, 1, 0xFFFF0066);
			createFrame(1.5, 1, 0xFFFF0066);
			createFrame(2, 1, 0xFFFF0066);
			createFrame(2.5, 1, 0xFFFF0066);
			createFrame(3, 1, 0xFFFF0066);
			createFrame(3.5, 1, 0xFFFF0066);
			createFrame(4, 1, 0xFFFF0066);
			createFrame(4.5, 1, 0xFFFF0066);
			createFrame(5, 1, 0xFFFF0066);
			createFrame(5.5, 1, 0xFFFF0066);
			createBody(6, 1, 0xFFFFFFFF);	
			
			upDate();
			
			stage.addEventListener(MouseEvent.CLICK, onClickHandler);		
			
			startRendering();	
			
			addChild(new Stats());
		}			
		//========================================================================
		// ClickHandler
		//========================================================================
		private function onClickHandler(e:MouseEvent = null):void {
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
					_pixel3Ds[_i] = new Pixel3D(p.c, p.x, p.y, p.z);
				};
				px = _pixel3Ds[_i];
				_pixels.addPixel3D(px);
			}			
		}
		//========================================================================
		// textの生成
		//========================================================================
		private function createText():void {
			var sprite:Sprite = new Sprite();
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat("小塚ゴシック Pro H", 20, 0x000000, true);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = "SELFLASH";
			tf.x = -1;
			tf.y = 1;
			_textW = tf.textWidth;
			_textH = tf.textHeight;			
			sprite.addChild(tf);
			
			_bmd = new BitmapData(_textW + 5, _textH + 10, false, 0xFFFFFF);
			_bmd.draw(sprite);
		}		
		//========================================================================
		// 中身を作成する
		//　いわゆる具ね
		//========================================================================
		private function createBody(depth:Number = 0, distance:Number = 2, color:Number = NaN):void {
			var p:Particle;
			
			var w:Number = _textW * .5;
			var h:Number = _textH * .5;			
				
			for ( _y = 0; _y < _textH; _y += distance ) {
				for ( _x = 0; _x < _textW; _x += distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != 0xFFFFFF) {
						_c = color || rgb2argb(_c, 1);	
						if (_particles[_i]) {
							p = _particles[_i];
							p.c = _c;
							p.x = _x - w;
							p.y = _y - h;
							p.z = depth;
						}else {
							_particles[_i] = new Particle(_x - w, _y - h, depth, _c);
						};
						_i++;					
					}
				}
			}
		}		
		//========================================================================
		// 枠組みを作成する 
		//　newする時にプロパティ突っ込んだ方が軽いのかな～？？
		//========================================================================
		private function createFrame(depth:Number = 4, distance:Number = 1, color:Number = NaN):void {	
			var p:Particle;
			
			var w:Number = _textW * .5;
			var h:Number = _textH * .5;					
			
			for ( _y = 0; _y < _textH; _y += distance ) {
				for ( _x = 0; _x < _textW; _x += distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != 0xFFFFFF) {
						_a = (_y == 0)?0:_x - w - _pre;
						if (_a > distance || _a < - distance) {
							_c = color || rgb2argb(_c, 1);	
							if (_particles[_i]) {
								p = _particles[_i];
								p.c = _c;
								p.x = _x - w;
								p.y = _y - h;
								p.z = depth;
							}else {
								_particles[_i] = new Particle(_x - w, _y - h, depth, _c);
							}
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
							_c = color || rgb2argb(_c, 1);	
							if (_particles[_i]) {
								p = _particles[_i];
								p.c = _c;
								p.x = _x - w;
								p.y = _y - h;
								p.z = depth;
							}else {
								_particles[_i] = new Particle(_x - w, _y - h, depth, _c);
							}
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
							_c = color || rgb2argb(_c, 1);	
							if (_particles[_i]) {
								p = _particles[_i];
								p.c = _c;
								p.x = _x - w;
								p.y = _y - h;
								p.z = depth;
							}else {
								_particles[_i] = new Particle(_x - w, _y - h, depth, _c);
							}
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
							_c = color || rgb2argb(_c, 1);	
							if (_particles[_i]) {
								p = _particles[_i];
								p.c = _c;
								p.x = _x - w;
								p.y = _y - h;
								p.z = depth;
							}else {
								_particles[_i] = new Particle(_x - w, _y - h, depth, _c);
							}
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
			camera.z += (-70 - camera.z) * .2;			

			var now:int = getTimer();
			var len:int = _particles.length;
			for ( _i = 0; _i < len; _i++ ) {
				var p:Particle = _particles[_i];
				if (p.y < GROUND_NUM) {
					var x_delay:Number = (1 - ((p.x + _textW * .6) / _textW )) * 40000;
					var y_delay:Number = (1 - ((p.y + _textH * .8) / _textH )) * 2000;
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
		//========================================================================
        // RGBをARGBに変換する
        //========================================================================
        private function rgb2argb(rgb:uint, alpha:Number):uint {
            return ((alpha * 0xff) << 24) + rgb;
        }
	}
}

//========================================================================
// 座標、色情報を保持するクラス		
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