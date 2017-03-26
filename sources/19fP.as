// -------------------------------------------------
//
// １フレーム前の描画結果を次のフレームに重ねるブラー
//
// クリックすると１フレームだけグラデーションの描画を行います。
// 透明度が高いほど予測不能なブレンドになって面白いです。
//
// -------------------------------------------------
package {
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.geom.*;
	import flash.ui.*;
	import flash.media.*;

    public class Main extends Sprite {
        public function Main() {

        
// -------------------------------------------------
// コンストラクタ
// -------------------------------------------------

// フレームレート
stage.frameRate = 30;

// 100%表示
stage.scaleMode = StageScaleMode.NO_SCALE;

// 左上
stage.align = StageAlign.TOP_LEFT;
stage.align = "TL";

// スプライトを作成
var sprite:Sprite = new Sprite();
addChild(sprite);

// 背景用ビットマップ
var bmp_bg:Bitmap = new Bitmap();
sprite.addChild(bmp_bg);
bmp_bg.smoothing = true;

// ブラー用ビットマップ
var bmp_blur:Bitmap = new Bitmap();
sprite.addChild(bmp_blur);
bmp_blur.smoothing = true;

// ペイント用ビットマップ
var shape:Shape = new Shape();
sprite.addChild(shape);
var graphic:Graphics = shape.graphics;

// ビットマップバッファ
var bmp_data:Array = new Array();
var flip :int = 0;

var alpha : Number = 0.985;	// 透明度
var power : Number = 1.0;	// 強さ
var scale_base : Number = 0.0;	// 拡大ベース
var smooth : Boolean;		// スムーズ

// 初期化へ
init();



// -------------------------------------------------
// 初期化
// -------------------------------------------------
function init():void{

	// 画像のURL
	var url:String = "http://actionscript.web.officelive.com/wonderfl/bg003.jpg";

	// ステージサイズ
	var w:uint;
	var h:uint;
	
	// ローダー作成
	var loader_obj : Loader = new Loader();
	var info : LoaderInfo = loader_obj.contentLoaderInfo;
	
	// 読み込み完了
	info.addEventListener (Event.INIT,LoaderInfoInitFunc);
	function LoaderInfoInitFunc (event : Event):void {
		// メモリからインスタンス化
		var loader_memory : Loader = new Loader();
		loader_memory.contentLoaderInfo.addEventListener (Event.COMPLETE,LoaderInfoCompleteFunc);
		function LoaderInfoCompleteFunc (event : Event):void {

			// キャプチャ
			var bmp : BitmapData = new BitmapData(loader_memory.width,loader_memory.height,true,0);
			stage.addChild(loader_memory);
			bmp.draw(stage);
			stage.removeChild(loader_memory);
	
			bmp_bg.bitmapData = bmp;

			ResizeFunc(null);
		}
		
		// 読み込み開始
		loader_memory.loadBytes(loader_obj.contentLoaderInfo.bytes);
	}


	// 読み込み開始
	load(url);

	// リザルト作成
	var result : Sprite = new Sprite();
	addChild(result);
	result.x = 0;

	// ボタン作成
	var button:Button = new Button(stage);
	button.y = 80;
	button.setSize(60,20);
	button.setLabel("開く");
	result.addChild(button);

	// ボタンが押された
	button.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void{
		load(text.text);
	});
	
	function load(url:String):void{
		// 読み込み
		loader_obj.load(new URLRequest(url));
	}


	// ノックアウト用ラジオボタン
	var radio_off:RadioButton = new RadioButton(stage);
	result.addChild(radio_off);
	radio_off.setLabel("スムーズなし");
	radio_off.x = 10;
	radio_off.y = 35;
	radio_off.setSize(140,18);
	radio_off.onClick(function(obj:RadioButton):void{smooth = false;});

	var radio_on:RadioButton = new RadioButton(stage);
	result.addChild(radio_on);
	radio_on.setLabel("あり");
	radio_on.x = 120;
	radio_on.y = 35;
	radio_on.setSize(140,18);
	radio_on.onClick(function(obj:RadioButton):void{smooth = true;});

	// ラジオボタンを関連付け
	radio_on.attachGroup(radio_off);
	radio_off.select();


	// テキストフィールド作成
	var ft_result:TextField = new TextField();
	ft_result.x = 10;
	ft_result.y = 60;
	ft_result.width = 300;
	ft_result.height = 20;
	ft_result.selectable = false;

	// 書式
	var format_result:TextFormat = new TextFormat();
	format_result.font = "ＭＳ ゴシック";	// フォント名
	ft_result.defaultTextFormat = format_result;

	// テキスト表示
	result.addChild(ft_result);

	// 読み込み状況
	addEventListener (Event.ENTER_FRAME,EnterFrameFunc);
	function EnterFrameFunc (event : Event) :void{
		ft_result.text = "読込:" + info.bytesLoaded + " / 全体:" + info.bytesTotal;
	}

	// テキストフィールド作成
	var text:TextField = new TextField();
	text.x = 10;
	text.y = 80;
	text.height = 20;
	text.type = TextFieldType.INPUT;
	text.border = true;

	// 書式
	var format:TextFormat = new TextFormat();
	format.font = "ＭＳ ゴシック";	// フォント名
	text.defaultTextFormat = format;

	// テキスト表示
	text.text = url;
	result.addChild(text);


	// 書式
	var tf_fmt:TextFormat = new TextFormat();
	tf_fmt.font = "ＭＳ ゴシック";	// フォント名
	tf_fmt.align = TextFormatAlign.CENTER;	// 整列

	// スライダーコメント作成
	var tf_slider_a:TextField = new TextField();
	tf_slider_a.x = 10;
	tf_slider_a.y = 0;
	tf_slider_a.width = 300;
	tf_slider_a.height = 20;
	tf_slider_a.border = false;
	tf_slider_a.text = "透明度";
	result.addChild(tf_slider_a);
	tf_slider_a.defaultTextFormat = tf_fmt;
	result.addChild(tf_slider_a);

	// スライダー作成
	var slider_a:SliderH = new SliderH(stage);
	slider_a.x = 10;
	slider_a.y = 20;
	result.addChild(slider_a);
	slider_a.setMinimum(0.8);
	slider_a.setMaximum(1.0);

	// スライダーが更新された
	slider_a.setListener(function(v:Number):void{
		alpha = slider_a.value;
	});
	slider_a.value = alpha;



	// スライダーコメント作成
	var tf_slider_w:TextField = new TextField();
	tf_slider_w.x = 10;
	tf_slider_w.y = 0;
	tf_slider_w.width = 300;
	tf_slider_w.height = 20;
	tf_slider_w.border = false;
	tf_slider_w.text = "弱め";
	result.addChild(tf_slider_w);
	tf_slider_w.defaultTextFormat = tf_fmt;
	result.addChild(tf_slider_w);
	
	var tf_slider_s:TextField = new TextField();
	tf_slider_s.x = 10;
	tf_slider_s.y = 0;
	tf_slider_s.width = 300;
	tf_slider_s.height = 20;
	tf_slider_s.border = false;
	tf_slider_s.text = "強め";
	result.addChild(tf_slider_s);
	tf_slider_s.defaultTextFormat = tf_fmt;
	result.addChild(tf_slider_s);

	// スライダー作成
	var slider_p:SliderH = new SliderH(stage);
	slider_p.x = 10;
	slider_p.y = 20;
	result.addChild(slider_p);
	slider_p.setMinimum( 1.0);
	slider_p.setMaximum(20.0);

	// スライダーが更新された
	slider_p.setListener(function(v:Number):void{
		power = slider_p.value;
	});
	slider_p.value = power;



	// スライダーコメント作成
	var tf_slider_sm:TextField = new TextField();
	tf_slider_sm.x = 10;
	tf_slider_sm.y = 35;
	tf_slider_sm.width = 300;
	tf_slider_sm.height = 20;
	tf_slider_sm.border = false;
	tf_slider_sm.text = "縮小";
	result.addChild(tf_slider_sm);
	tf_slider_sm.defaultTextFormat = tf_fmt;
	result.addChild(tf_slider_sm);
	
	var tf_slider_la:TextField = new TextField();
	tf_slider_la.x = 10;
	tf_slider_la.y = 35;
	tf_slider_la.width = 300;
	tf_slider_la.height = 20;
	tf_slider_la.border = false;
	tf_slider_la.text = "拡大";
	result.addChild(tf_slider_la);
	tf_slider_la.defaultTextFormat = tf_fmt;
	result.addChild(tf_slider_la);

	// スライダー作成
	var slider_s:SliderH = new SliderH(stage);
	slider_s.x = 10;
	slider_s.y = 55;
	result.addChild(slider_s);
	slider_s.setMinimum(-1.0);
	slider_s.setMaximum( 1.0);

	// スライダーが更新された
	slider_s.setListener(function(v:Number):void{
		scale_base = slider_s.value;
	});
	slider_s.value = scale_base;


	// リサイズ時にフィット
	stage.addEventListener(Event.RESIZE,ResizeFunc);
	function ResizeFunc(e:Event):void{
		w = stage.stageWidth;
		h = stage.stageHeight;
		bmp_bg.width = w;
		bmp_bg.height = h - 110;

		result.y = h - 110;
	
		// テキストフィールド位置
		text.width = w - 10 - 10 - button.width - 10;
	
		// ボタン位置
		button.x = w - button.width - 10;
		
		// ビットマップバッファを再構築
		bmp_data[0] = new BitmapData(w,h,true,0x00FFFFFF);
		bmp_data[1] = new BitmapData(w,h,true,0x00FFFFFF);
		
		// コメント
		tf_slider_w.x = w / 2 + 5;
		tf_slider_s.x = w - 40;
		tf_slider_sm.x = w / 2 + 5;
		tf_slider_la.x = w - 40;
		
		// スライダー
		slider_a.setSize(w/2 - 10 - 5,10);
		slider_p.x = w/2 + 5;
		slider_p.setSize(w/2 - 10 - 5,10);
		slider_s.x = w/2 + 5;
		slider_s.setSize(w/2 - 10 - 5,10);
	}
	ResizeFunc(null);


	var color_cycle:Number = 0.0;		// カラー周期
	var rotate_cycle : Number = 0.0;	// 回転周期
	var scale_cycle : Number = 0.0;		// 拡大縮小周期
	var rotate_spd : Number = 0.05;		// 回転速度
	var scale_spd : Number = 0.021;		// 拡大縮小速度
	
	addEventListener(Event.ENTER_FRAME,function(e:Event):void{

		// グラデーション描画
		ShapeRender();

		rotate_cycle += rotate_spd;
		scale_cycle += scale_spd;

		var x:Number = stage.mouseX;
		var y:Number = stage.mouseY;
		var r:Number = Math.sin(rotate_cycle) * 0.1 * power;
		var s:Number = (Math.sin(scale_cycle) + scale_base) * 0.01 * power + 1.0;
		var raster_w:Number = w;
		var raster_h:Number = h - 110;
		var half_x:Number = x/2;
		var half_y:Number = y/2;
		
		// 行列作成
		var m:Matrix = new Matrix();
		m.identity();
		m.translate(-x,-y);
		m.scale(s,s);
		m.rotate(r*Math.PI/180);
		m.translate( x, y);
		
		// 透明度
		bmp_blur.alpha = alpha;
		
		// ビットマップを更新
		bmp_blur.transform.matrix = m;

		// 表示ビットマップ入れ替え
		bmp_blur.bitmapData = bmp_data[flip];
		bmp_blur.smoothing = smooth;
	
		// 現在の状態をキャプチャ
		bmp_data[1-flip].draw(
			sprite,
			new Matrix(1,0,0,1,0,0),
			new ColorTransform(1,1,1,1,0,0,0,0),
			BlendMode.NORMAL,
			new Rectangle(0,0,raster_w,raster_h),
			false
		);
	
		// 裏表更新
		flip ++;
		if(flip > 1)	flip = 0;
	});


	// マウス操作
	var mouse_down:Boolean = false;
	sprite.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void{
		mouse_down = true;
	});
	sprite.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void{
		mouse_down = false;
	});

	var r:uint = 0xFF;
	var g:uint = 0x00;
	var b:uint = 0x00;
	function ShapeRender():void{

		// シェイプクリア
		graphic.clear();
	
		// ドラッグ中はグラデーションを描画
		if(mouse_down){
			var x:Number = stage.mouseX;
			var y:Number = stage.mouseY;
		
			color_cycle += 0.001;
			if(color_cycle > 1.0)	color_cycle -= 1.0;

			var radius:Number = 100;
			var s:Number = radius/1638.4;
			var d:Number = color_cycle * 6;

			if(0 < d && d < 1)	g = Math.floor((1 - (1 - d)) * 0xFF);
			if(1 < d && d < 2)	r = Math.floor((    (2 - d)) * 0xFF);
			if(2 < d && d < 3)	b = Math.floor((1 - (3 - d)) * 0xFF);
			if(3 < d && d < 4)	g = Math.floor((    (4 - d)) * 0xFF);
			if(4 < d && d < 5)	r = Math.floor((1 - (5 - d)) * 0xFF);
			if(5 < d && d < 6)	b = Math.floor((    (6 - d)) * 0xFF);

			var color:uint = (r << 16) | (g << 8) | (b << 0);
		
			graphic.beginGradientFill ( 
				GradientType.RADIAL ,
				[color, color] ,
				[1.0,0.0] ,
				[0,255] ,
				new Matrix(s,0,0,s,x,y)
			);
			graphic.drawCircle ( x , y, radius );
			graphic.endFill();
		}
	}

}


		}
	}
}

import flash.events.*;
import flash.display.*;
import flash.text.*;
import flash.geom.*;

// -------------------------------------------------
// ボタン
// -------------------------------------------------
internal class Button extends Sprite {

	private var _width:Number;
	private var _height:Number;
	
	private var _text:TextField;
	private var _background:Sprite;
	

	public function Button(stage:Stage) {
		var slider:Button = this;

		// 背景用スプライト作成
		_background = new Sprite();
		addChild(_background);

		// テキストフィールド
		_text = new TextField();
		addChild(_text);
	
		_text.x = 0;
		_text.y = 0;
		_text.selectable = false;

		// 書式
		var format:TextFormat = new TextFormat();
		format.align = TextFormatAlign.CENTER;	// 整列
		format.font = "ＭＳ ゴシック";	// フォント名
		format.size = 14;				// 文字のポイントサイズ
		format.color = 0x202020;		// 文字の色
		_text.defaultTextFormat = format;
	
		// マウスオーバーで少し明るく
		addEventListener(MouseEvent.MOUSE_OVER,function(e:MouseEvent):void{
			var color : ColorTransform = new ColorTransform(1,1,1,1,8,8,8,0);
			transform.colorTransform = color;
		});

		// マウスアウトで元に戻す
		addEventListener(MouseEvent.MOUSE_OUT,function(e:MouseEvent):void{
			var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
			transform.colorTransform = color;														   
		});

		// デフォルト値
		setSize(100,100);
		update();
	}
	// リサイズ
	public function setSize(w:Number,h:Number):void{
		// 背景リサイズ
		_width = w;
		_height = h;
		update();
	}
	// ラベルセット
	public function setLabel(str:String):void{
		_text.text = str;
		update();
	}
	// 描画更新
	private function update():void{
		// 背景描画
		var g:Graphics = _background.graphics;
		
		// 角丸矩形描画
		g.clear();
		g.lineStyle ( 0 , 0x808080 , 1.0,false,LineScaleMode.NONE,CapsStyle.ROUND,JointStyle.ROUND);
		g.beginFill ( 0xF0F0F0 , 1.0 );
		g.drawRoundRect ( 0 , 0 , _width , _height , 5 , 5 );
		g.endFill();
		
		// テキスト位置修正
		_text.width  = _width;
		_text.height = _height;
	}
}



// -------------------------------------------------
// 水平方向スライダー
// -------------------------------------------------
internal class SliderH extends Sprite {

	private var _value:Number;
	private var _minimum:Number;
	private var _maximum:Number;
	private var _width:Number;
	private var _height:Number;
	private var _width_bar:Number;
	private var _drag:Boolean;
	private var _listener:Function;
	
	private var _bar:Sprite;
	private var _background:Sprite;
	

	public function SliderH(stage:Stage) {
		var slider:SliderH = this;
		var g:Graphics;
		
		// 背景配置
		_background = new Sprite();
		addChild(_background);
		
		// バー配置
		_bar = new Sprite();
		addChild(_bar);
		_bar.x = 1;
		_bar.y = 1;
		
		// 背景描画
		g = _background.graphics;
		g.lineStyle ( 0 , 0xB0B0B0 , 1.0);
		g.beginFill ( 0xF0F0F0 , 1.0 );
		g.drawRect ( 0 , 0 , 100 , 100);
		g.endFill();
		
		// バー描画
		g = _bar.graphics;
		g.lineStyle ( 0 , 0x808080 , 1.0);
		g.beginFill ( 0xA0A0A0 , 1.0 );
		g.drawRect ( 0 , 0 , 100 , 100);
		g.endFill();

		// マウスイベント
		stage.addEventListener(MouseEvent.MOUSE_DOWN,function(e:MouseEvent):void{
			if(!_drag){
				if(slider.hitTestPoint ( e.stageX , e.stageY , false )){
					if(e.buttonDown){
						_drag = true;
						
						var color : ColorTransform = new ColorTransform(1,1,1,1,4,4,4,0);
						transform.colorTransform = color;

						DragEvent(e);
					}
				}
			}
		});

		// マウスイベント
		stage.addEventListener(MouseEvent.MOUSE_MOVE,function(e:MouseEvent):void{
			if(_drag){
				if(!e.buttonDown){
					_drag = false;

					// マウスアウトで元に戻す
					var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
					transform.colorTransform = color;
				}
			}

			if(_drag)		DragEvent(e);
		});
		
		function DragEvent(e:MouseEvent):void{
			// ステージマウス座標をローカル座標系に落とし込む
			var p : Point = new Point(e.stageX,e.stageY);
			var m : Matrix = slider.transform.matrix;
			m.invert();
			p = m.transformPoint(p);

			// バーの位置更新
			_bar.x = p.x - _bar.width/2;
			if(_bar.x < 0)	_bar.x = 0;
			if(_bar.x > _width - _bar.width){
				_bar.x = _width - _bar.width;
			}
			
			// バーの位置からデフォルト値を決定
			var d:Number = (_bar.x) / (_width - _bar.width);
			d = (_maximum - _minimum) * d + _minimum;
			value = d;

			e.updateAfterEvent();		
		}

		// デフォルト値
		_value = 0.0;
		_minimum = 0.0;
		_maximum = 1.0;
		_drag = false;
		_listener = null;
		setSize(100,10);
		setSizeBar(20);
		update();
	}
	// 最小値セット
	public function setMinimum(v:Number):void{
		_minimum = v;
		update();
	}
	// 最大値セット
	public function setMaximum(v:Number):void{
		_maximum = v;
		update();
	}
	// 通常値取得
	public function get value():Number{
		return _value;
	}
	// 通常値セット
	public function set value(v:Number):void{
		_value = v;
		update();
		
		// 通知
		if(_listener != null)	_listener(_value);
	}
	// 更新通知
	public function setListener(func:Function):void{
		_listener = func;
	}
	// リサイズ
	public function setSize(w:Number,h:Number):void{
		// 背景リサイズ
		_width = w;
		_height = h;
		update();
	}
	// バーのリサイズ
	public function setSizeBar(w:Number):void{
		// 背景リサイズ
		_width_bar = w;
		update();
	}

	// 描画更新
	private function update():void{
		// リサイズ
		_background.scaleX = _width / 100;
		_background.scaleY = _height / 100;
		_bar.scaleX = (_width_bar - 2) / 100;
		_bar.scaleY = (_height - 2) / 100;
		
		// バーの位置
		var length : Number = _width - 2 - _bar.width;
		var d : Number = (_value - _minimum) / (_maximum - _minimum);
		_bar.x = length * d + 1;
	}

}



import flash.events.*;
import flash.display.*;
import flash.text.*;
import flash.geom.*;

// -------------------------------------------------
// ラジオボタン
// -------------------------------------------------
internal class RadioButton extends Sprite {

	private var _width:Number;
	private var _height:Number;
	
	private var _text:TextField;
	private var _background:Sprite;
	private var _button:Sprite;
	private var _check:Sprite;
	
	private var _pref:RadioButton;
	private var _post:RadioButton;
	
	private var _selected:Boolean;
	private var _onClick:Function;

	public function RadioButton(stage:Stage) {
		var slider:RadioButton = this;
		
		_onClick = null;
		_selected = false;
		
		// リングリスト作成
		_pref = this;
		_post = this;

		// 背景用スプライト作成
		_background = new Sprite();
		addChild(_background);

		// ボタン用スプライト作成
		_button = new Sprite();
		addChild(_button);

		// チェック用スプライト作成
		_check = new Sprite();
		addChild(_check);

		// テキストフィールド
		_text = new TextField();
		addChild(_text);
	
		_text.x = 20;
		_text.y = 0;
		_text.selectable = false;

		// 書式
		var format:TextFormat = new TextFormat();
		format.align = TextFormatAlign.LEFT;	// 整列
		format.font = "ＭＳ ゴシック";			// フォント名
		format.size = 14;						// 文字のポイントサイズ
		format.color = 0x202020;				// 文字の色
		_text.defaultTextFormat = format;
	
		// マウスオーバーで少し明るく
		addEventListener(MouseEvent.MOUSE_OVER,function(e:MouseEvent):void{
			var color : ColorTransform = new ColorTransform(1,1,1,1,8,8,8,0);
			transform.colorTransform = color;
		});

		// マウスアウトで元に戻す
		addEventListener(MouseEvent.MOUSE_OUT,function(e:MouseEvent):void{
			var color : ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
			transform.colorTransform = color;														   
		});

		// クリック
		addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void{
			select();											   
		});

		// デフォルト値
		setSize(100,100);
		update();
	}
	// リサイズ
	public function setSize(w:Number,h:Number):void{
		// 背景リサイズ
		_width = w;
		_height = h;
		update();
	}
	// ラベルセット
	public function setLabel(str:String):void{
		_text.text = str;
		update();
	}
	// 描画更新
	private function update():void{
		// 背景描画
		var g:Graphics;
		var height_half:Number = _height / 2;
		var r:Number;

		
		// 背景描画
		g = _background.graphics;
		g.clear();
		g.beginFill ( 0xFFFFFF , 0.0 );
		g.drawRect ( 0 , 0 , _width , _height );
		g.endFill();

		
		// ボタン描画
		g = _button.graphics;
		g.clear();
		g.lineStyle ( 0 , 0x808080 , 1.0,false,LineScaleMode.NONE,CapsStyle.ROUND,JointStyle.ROUND);
		g.beginFill ( 0xF0F0F0 , 1.0 );
		r = height_half - 4;
		if(r < 4) r = 4;
		g.drawCircle ( height_half , height_half , r );
		g.endFill();

		// 背景描画
		g = _check.graphics;
		g.clear();
		g.lineStyle ( 0 , 0x404040 , 1.0,false,LineScaleMode.NONE,CapsStyle.ROUND,JointStyle.ROUND);
		g.beginFill ( 0x606060 , 1.0 );
		r = height_half - 8;
		if(r < 2) r = 2;
		g.drawCircle ( height_half , height_half , r );
		g.endFill();

		// テキスト位置修正
		_text.x  = _height;
		_text.width  = _width;
		_text.height = _height;

		if(_selected)	_check.visible = true;
		else			_check.visible = false;
	}
	
	// グループにセット
	public function attachGroup(button:RadioButton):void{
		button.removeGroup();

		var pref:RadioButton = this;
		var post:RadioButton = _post;

		pref._post = button;
		post._pref = button;
		button._pref = pref;
		button._post = post;
	}

	// グループから外す
	public function removeGroup():void{
		var pref:RadioButton = _pref;
		var post:RadioButton = _post;
		pref._post = post;
		post._pref = pref;
		_pref = this;
		_post = this;
	}
	
	// 選択
	public function select():void{
		// すべてのチェックを外す
		var list:RadioButton = this._post;
		while(true){
			if(list == this)	break;

			list._selected = false;
			list.update();
			list = list._post;
		}
		// チェック
		list._selected = true;
		list.update();
		
		// コールバック関数呼び出し
		if(_onClick != null){
			_onClick(this);
		}
	}

	// イベント登録
	public function onClick(func:Function):void{
		_onClick = func;
	}
}


// -------------------------------------------------
// 外部画像をサムネイルとしてキャプチャ
// -------------------------------------------------
import flash.net.*;
import flash.events.*;
import flash.display.*;
import flash.geom.*;
function ThumbnailCapture(url:String,time:uint,stage:Stage):void{

	// キャプチャタイミング
	Wonderfl.capture_delay( time );

	// スプライト作成
	var sprite : Sprite = new Sprite();

	// ステージ最前面に配置
	stage.addChildAt(sprite,stage.numChildren);
	
	// ローダー
	var loader_obj : Loader = new Loader();
	loader_obj.contentLoaderInfo.addEventListener (Event.INIT,function(e:Event):void{

		// メモリからインスタンス化
		var loader_memory : Loader = new Loader();
		loader_memory.contentLoaderInfo.addEventListener (Event.INIT,function(e:Event):void{

			// キャプチャ
			var bmp : BitmapData = new BitmapData(loader_memory.width,loader_memory.height,true,0);
			sprite.addChild(loader_memory);
			bmp.draw(sprite);
			sprite.removeChild(loader_memory);
			loader_memory.unload();
			loader_obj.unload();
			loader_memory = null;
			loader_obj = null;
			
			
			// 画像を配置
			var bmp_obj : Bitmap = new Bitmap(bmp);
			bmp_obj .width = stage.stageWidth;
			bmp_obj .height = stage.stageHeight;
			stage.addChild(bmp_obj );
			
		});
		
		// 読み込み開始
		loader_memory.loadBytes(loader_obj.contentLoaderInfo.bytes);
	});
	
	// 読み込み開始
	loader_obj.load(new URLRequest(url));
}

