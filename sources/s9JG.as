/**
 * ※処理重いので注意！！！！！
 
 * 1.外部SWFから輪郭を取得する。
 * 2.Papervision3DのPixcel3Dで描画 
 * 
 * @author yooKo@seｌflash
 * @graphic chibitami
 * @version 2.32
 * Let's Click!
 * Click毎に3Dエフェクトが切り替わるお～～
 * 
 * 2009/10/13 13:49
 * swfアニメの素材を変更
 *  chibitami さんのswfアニメのモーションがかなり見栄えがよくサンプルに
 * ちょうどよかったので許可を頂いてお借りしました。
 * 画像元
 * 【CHiBiTAMi.NET/WORKS/】
 * http://chibitami.net/works/
 * 【chibitami's Twitter】
 * http://twitter.com/chibitami
 *
 *　【修正】
 * ・ゴミ残ってたの消した。_vxとか_xxとかもう使ってなかったから全部削除 
 * ・StageQuality.LOW;　→　stage.quality = StageQuality.LOW;
 * 　記述間違ってたのか。あまり変えた事なかったから・・恥ずかしい、、
 * ・最適化をした。forの中でnew Pixel3D()をしていたので配列に突っ込んで操作する
 *  用に修正。
 * ・ｆｐｓが格段に向上したので代わりにドットを細かくしてクオリティをあげた。
 *
 *  あともっとやるとしたらvector使うのとエフェクト切り替えた時に使ってない配列の中身を都度削除する
 *  くらいかな。
 * ・処理が速くなるわけじゃないけど効率悪い書き方している箇所をちょっと修正。
 **/
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.filters.BitmapFilterQuality;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	
	import org.papervision3d.core.effects.BitmapLayerEffect;
	import org.papervision3d.core.effects.BitmapColorEffect;
	import org.papervision3d.core.effects.utils.BitmapClearMode;
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.core.geom.renderables.Pixel3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.BitmapEffectLayer;
	
	import net.hires.debug.Stats;
	
	[SWF(width="465", height="465", backgroundColor="0x000000", frameRate="60")]

	public class Pixcel3DAnime extends BasicView {
		private const IMAGE_URL:String = "http://selflash.jp/wonderfl/dance_girl.swf";
		private const TRANSFORM_COLOR:ColorTransform = new ColorTransform(0, 0, 0, 0, 0, 0, 0, 0); 
		private const CAMERA_DISTANCE:int = -200;
		private const TRIMMING_LEFT:int = 0; //ソースの解析を開始するx位置
		private const TRIMMING_TOP:int = 0; //ソースの解析を開始するy位置
		private const TRIMMING_RIGHT:int = 280; //ソースの解析を終わるxの位置　
		private const TRIMMING_BOTTOM:int = 280; //ソースの解析を終わるyの位置　
		
		private var _layer:BitmapEffectLayer;
		private var _loader:Loader;
		private var _pixels:Pixels;
		private var _rotateX:Number = 0;
		private var _rotateY:Number = 0;
		private var _currentNum:int = 0;
		private var _bmd:BitmapData;
		
		//========================================================================
		// コンストラクタ	
		//========================================================================
		public function Pixcel3DAnime() {	
			super(0, 0, true, true);			
			stage.quality = StageQuality.LOW;
			
			if (!stage)
                addEventListener(Event.ADDED_TO_STAGE, init);
            else
                init();
        }
		//========================================================================
		// 画像の読み込み	
		//========================================================================
        private function init(e:Event = null):void {	
            removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_loader = new Loader(); 
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
			_loader.load(new URLRequest(IMAGE_URL), new LoaderContext(true));
		}		
		//========================================================================
		// ロード完了後の処理
		//========================================================================
		private function onCompleteHandler(e:Event):void {
			e.target.removeEventListener(Event.COMPLETE, init);
			
			_bmd = new BitmapData(TRIMMING_RIGHT, TRIMMING_BOTTOM, true, 0xFFFFFF); //こいつから毎回色、座標を解析する
			var bmp:Bitmap = new Bitmap(_bmd, "auto", false); //左下に表示するためのやつね
			bmp.scaleX = .4;
			bmp.scaleY = .4;
			bmp.y = stage.stageHeight - bmp.height;		
			addChild(bmp);
			
			camera.z = CAMERA_DISTANCE;	
			
			_layer = new BitmapEffectLayer(viewport, stage.stageWidth, stage.stageHeight, true, 0, BitmapClearMode.CLEAR_PRE, false);
			viewport.containerSprite.addLayer(_layer);
			_layer.addEffect(new BitmapColorEffect(1.2, 1.2, 1.2, .5));
			_pixels = new Pixels(_layer);
			scene.addChild(_pixels);	
			
			addEventListener(MouseEvent.MOUSE_DOWN, onDownHandler);		
			
			startRendering();	
			
			addChild(new Stats());
		}	
		
		//========================================================================
		// 表示の切り替え
		// ここ失敗作。。切り替えの仕組みがしょぼすぎる・・・なんか挙動が変、、スマートな方法あったら教えてください、、
		// stage.addEventLisner()でもだめ。クリックイベントがなにかと重複してる感じだけどよくわからない、、
		//========================================================================
		private function onDownHandler(e:MouseEvent = null):void {
			_currentNum++;			
			if (_currentNum > 8)_currentNum = 0;		
		}
		
		//========================================================================
		//　常に行う処理
		//========================================================================
		override protected function onRenderTick(event:Event = null):void { 
			renderer.renderScene(scene, _camera, viewport);

			_i = 0;
			
			_rotateX += (- viewport.containerSprite.mouseX - _rotateX) * 0.1;
			_rotateY += (- viewport.containerSprite.mouseY - 170 - _rotateY) * 0.1;
			_pixels.rotationY = _rotateX;
			_pixels.rotationX = _rotateY;
			
			_bmd.colorTransform(_bmd.rect, TRANSFORM_COLOR);
			_bmd.draw(_loader);
			_pixels.removeAllpixels();		
			
			/** エフェクトの切り替え
			 * =================================================================
			 * 基本的には createBody()で全体,createFrame()で枠組みのみを生成します。
			 * 引数の説明
			 * 1つ目はレイヤーのz座標。
			 * 2つ目はドットの細かさ。
			 * 3つ目の色を指定しないという事はBitmapDataから取得した色をそのまま使うという事です。
			 * 引数を調整したりcreateBody(),createFrame()を増やしたりして調整してください。
			 * ==================================================================	
			 */
			switch (_currentNum) {
				//　ノーマル //////////////////////////////////////
                case 0: 
				    // swfから取得した色で全体を表示する1層のレイヤー画像を作成
				    createBody(0, 1);
                break;
				// 3D //////////////////////////////////////////
				case 1:
				    // 指定した色で表示をする13層のレイヤーからなる厚みのある画像を作成。bodyでframeをサンドイッチ
				    createBody(-12, 2, 0xFFCCFF33);
				    createFrame(-10, 3.5, 0xFFCCFF33);
				    createFrame(-8, 3.5, 0xFFCCFF33);
				    createFrame(-6, 3.5, 0xFFCCFF33);
				    createFrame(-4, 3.5, 0xFFCCFF33);
				    createFrame(-2, 3.5, 0xFFCCFF33);
				    createFrame(0, 3.5, 0xFFCCFF33);
				    createFrame(2, 3.5, 0xFFCCFF33);
				    createFrame(4, 3.5, 0xFFCCFF33);
				    createFrame(6, 3.5, 0xFFCCFF33);
				    createFrame(8, 3.5, 0xFFCCFF33);
				    createFrame(10, 3.5, 0xFFCCFF33);
				    createBody(12, 2, 0xFFCCFF33);
				break;
				// シルエット /////////////////////////////////////
				case 2:
				    // 指定した色で全体を表示する1層のレイヤー画像を作成。
				    createBody(0, 1, 0xFFCCFF00);
				break;
				// フレーム //////////////////////////////////////
				case 3:
				    // 指定した色で枠組みを表示する1層のレイヤー画像を作成。
				    createFrame(0, 1, 0xFFCCFF99, 0);
				break;
				// 地震エフェクト？ /////////////////////////////////
				case 4:
				    // 指定した色で枠組みを表示する1層のレイヤー画像を作成。
				    createBody(0, 1, 0, ((Math.random() - .5) * 50));
				break;
				// ディスコエフェクト //////////////////////////////////
				case 5:
				    // 指定した色で枠組みを表示する1層のレイヤー画像を作成。
				    createBody(0, 1, ((Math.random() - .6) * 5), ((Math.random() - .8) * 200));
				break;
				//ノイズエフェクト /////////////////////////////////////
				case 6: 
				    // 指定した色で枠組みを表示する1層のレイヤー画像を作成。
				    createBody(0, 1, 0xFF33CC00, 0, true);
				break;
				//マルチカラーエフェクト /////////////////////////////////////
				case 7: 
				    // 指定した色で枠組みを表示する1層のレイヤー画像を作成。
				    createBody(0, 1, 0xFFFFFFFF * Math.random());
				break;
            };	
		}	
		
		private var _bodyArray:Array/*Pixel3D*/ = [];
		private var _frameArray:Array/*Pixel3D*/ = [];		
		private var _i:int = 0;
		private var _px:Pixel3D;
		private var _pre:Number;
		private var _a:Number;
		private var _y:Number;
		private var _x:Number;
		private var _c:uint;				
		private const EXCLUSION_COLOR:int = 0x00; //除外したい色の設定		
	    private const W:Number = (TRIMMING_RIGHT + TRIMMING_LEFT) * .5; // 画像横幅の半分を先に計算する。
	    private const H:Number = (TRIMMING_BOTTOM + TRIMMING_TOP) * .5; // 画像縦幅の半分を先に計算する。
		//========================================================================
		//　定数以外EXCLUSION_COLORの色を除外してキャラクターをPixelsに描画する
		//========================================================================
		private function createBody(depth:Number = 0, distance:Number = 2, color:Number = NaN, disco:Number = 0, noise:Boolean = false):void {
			for ( _y = TRIMMING_TOP; _y < TRIMMING_BOTTOM; _y += distance ) {
				for ( _x = TRIMMING_LEFT; _x < TRIMMING_RIGHT; _x += distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != EXCLUSION_COLOR) {
						_c = (color)?color:rgb2argb(_c, 1);
						if (noise) {
							depth = depth + ((Math.random() - .5) * 1);
						};
							if(!_bodyArray[_i]) _bodyArray[_i] = new Pixel3D(0);
							_px = _bodyArray[_i];
							_px.color = _c;
							_px.x = _x - W;
							_px.y = _y - H;
							_px.z = depth + disco;
							_pixels.addPixel3D(_px);
							_i++;
					}
				}
			}
		}	
		
		//========================================================================
		//　定数以外EXCLUSION_COLORの色を除外してキャラクターの枠だけをPixelsに描画する
		//========================================================================
		private function createFrame(depth:Number = -4, distance:Number = 2, color:Number = NaN, disco:Number = 0, noise:Boolean = false):void {			
			var pre:Number;	
			for ( _y = TRIMMING_TOP; _y < TRIMMING_BOTTOM; _y += distance ) {
				for ( _x = TRIMMING_LEFT; _x < TRIMMING_RIGHT; _x += distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != EXCLUSION_COLOR) {
						_a = (_y == 0)?0:_x - W - pre;
						if (_a > distance || _a < - distance) {
							_c = (color)?color:rgb2argb(_c, 1);
						    if (noise) {
								depth = depth + ((Math.random() - .5) * 2);
							};
							if(!_frameArray[_i]) _frameArray[_i] = new Pixel3D(0);
							_px = _frameArray[_i];
							_px.color = _c;
							_px.x = _x - W;
							_px.y = _y - H;
							_px.z = depth + disco;
							_pixels.addPixel3D(_px);
							_i++;
						}
						pre = _x - W;
					}
				}
			}
			
			for ( _x = TRIMMING_LEFT; _x < TRIMMING_RIGHT; _x += distance ) {
				for ( _y = TRIMMING_TOP; _y < TRIMMING_BOTTOM; _y += distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != EXCLUSION_COLOR) {
						_a = (_x == 0)?0:_y - H - pre;
						if(_a > distance || _a < - distance) {
							_c = (color)?color:rgb2argb(_c, 1);
						    if (noise) {
								depth = depth + ((Math.random() - .5) * 2);
							};
							if(!_frameArray[_i]) _frameArray[_i] = new Pixel3D(0);
							_px = _frameArray[_i];
							_px.color = _c;
							_px.x = _x - W;
							_px.y = _y - H;
							_px.z = depth + disco;
							_pixels.addPixel3D(_px);
							_i++;
						}
						pre = _y - H;
					}
				}
			}
			
			for ( _y = TRIMMING_BOTTOM; _y > TRIMMING_TOP; _y -= distance ) {
				for ( _x = TRIMMING_RIGHT; _x > TRIMMING_LEFT; _x -= distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != EXCLUSION_COLOR) {
						_a = (_y == TRIMMING_TOP + TRIMMING_BOTTOM)?0:_x - W - pre;
						if(_a > distance || _a < - distance) {
							_c = (color)?color:rgb2argb(_c, 1);
						    if (noise) {
								depth = depth + ((Math.random() - .5) * 2);
							};
							if(!_frameArray[_i]) _frameArray[_i] = new Pixel3D(0);
							_px = _frameArray[_i];
							_px.color = _c;
							_px.x = _x - W;
							_px.y = _y - H;
							_px.z = depth + disco;
							_pixels.addPixel3D(_px);
							_i++;
						}
						pre = _x - W;
					}
				}
			}
			
			for ( _x = TRIMMING_RIGHT; _x > TRIMMING_LEFT; _x -= distance ) {
				for ( _y = TRIMMING_BOTTOM; _y > TRIMMING_TOP; _y -= distance ) {
					_c = _bmd.getPixel( _x, _y );
					if (_c != EXCLUSION_COLOR) {
						_a = (_x == TRIMMING_LEFT + TRIMMING_RIGHT)?0:_y - H - pre;
						if(_a > distance || _a < - distance) {
							_c = (color)?color:rgb2argb(_c, 1);
						    if (noise) {
								depth = depth + ((Math.random() - .5) * 2);
							};
							if(!_frameArray[_i]) _frameArray[_i] = new Pixel3D(0);
							_px = _frameArray[_i];
							_px.color = _c;
							_px.x = _x - W;
							_px.y = _y - H;
							_px.z = depth + disco;
							_pixels.addPixel3D(_px);
							_i++;
						}
						pre = _y - H;
					}
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
