package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.BlurFilter;
    import flash.geom.*;
    import flash.text.*;
    import net.wonderfl.utils.FontLoader;
    import com.bit101.components.*;
    
    [SWF(frameRate="60")]
    public class Typography extends Sprite {
        private const W : Number = stage.stageWidth;
        private const H : Number = stage.stageHeight;
    		
    		private var _tf : TextField; // BitmapData製作用に文字を書くTextField
        private var font : String = "Aqua"; // font name
        
        private var _it : TextField;
        private var _submit : PushButton;
        
  		private var _particles : Array;
  		private var _tlim : Number; // 終了時刻
  		private var _canvas : BitmapData; // ここにかく
  		private var _t : Number; // 経過時間
  		private var _offset : Number; // 色位相のオフセット
  		
        public function Typography() {
        		Wonderfl.capture_delay(4);
        	
        		_canvas = new BitmapData(W, H, false, 0x000000);
        		addChild(new Bitmap(_canvas));
        		
        		_it = new TextField();
        		_it.type = "input";
        		_it.x = 10;
        		_it.y = 10;
        		_it.textColor = 0xffffff;
        		_it.border = true;
        		_it.borderColor = 0x7f7f7f;
        		_it.width = 100;
        		_it.height = 20;
        		addChild(_it); 
        		
        		_it.text = "wonderfl";
        		_submit = new PushButton(this, 120, 10, "go!", onSubmit);
        		_submit.width = 40;
        		_submit.height = 21;
        		_submit.enabled = false;
        		
            var fl : FontLoader = new FontLoader();
            fl.load(font);
            fl.addEventListener(Event.COMPLETE, onFontLoaded);
        }
  
  		// fontがロードされた
  		private function onFontLoaded(e : Event) : void
  		{
  			_tf = new TextField();
        		_tf.defaultTextFormat = new TextFormat(font, 100);
        		_tf.autoSize = "left";
        		_tf.embedFonts = true;
        		_submit.enabled = true;
        		
        		stage.addEventListener(MouseEvent.CLICK, onClick);
        		
        		init();
  		}
  		
        	private function onSubmit(e : MouseEvent) : void
        	{
        		if(_it.text.length == 0)return;
        		init();
        	}
        	
        	private function onClick(e : MouseEvent) : void
        	{
        		if(e.target is TextField || e.target is PushButton)return;
        		start();
        	}
        	
        	// 文字列からパーティクルの経路を作成する
        	private function init() : void
        	{
        		if(_it.text == "")return;
        		
        		// 白抜き作成
        		var bmds : Array = [];
        		for each(var c : String in _it.text.split('')){
        			if(c == " " || c == "　")continue; // スペースはノーカウント
	        		_tf.text = c;
	        		var bmd : BitmapData = textFieldToBitmap(_tf, 4);
	        		var blurred : BitmapData = new BitmapData(W, H, false, 0xffffff);
	        		
	        		// 元のBitmapDataにblurをかけ、さらに元のBitmapDataを描く、というのの繰り返しで
	        		// 文字の周囲を濃くする
	        		bmd.lock();
	        		blurred.lock();
	        		for(var i : uint = 0;i < 10;i++){
		        		blurred.applyFilter(blurred, blurred.rect, new Point(), new BlurFilter(100, 100, 1));
		        		blurred.draw(bmd);
	        		}
	        		// んノックアウトォ！
	        		blurred.draw(bmd, null, null, "invert");
	        		bmd.dispose();
	        		
	        		bmds.push(blurred);
        		} 
        		
        		// パーティクルの経路をつくる
        		// できた白抜きの黒い部分を経由するように
        		_particles = [];
        		for(i = 0;i < 2000;i++){
        			var xs : Array = [];
        			var ys : Array = [];
        			var r : Number = (W + H) / 2;
        			var theta : Number = Math.random() * 2 * Math.PI;
        			
        			// 初期値はstageの外
        			xs.push(W / 2 + r * Math.cos(theta)); 
        			ys.push(H / 2 + r * Math.sin(theta));
        			
        			// 各BitmapDataに対して座標をひとつきめる
        			for each(bmd in bmds){
        				while(true){
	        				var x : Number = Math.random() * W;
	        				var y : Number = Math.random() * H;
	        				var pc : uint = bmd.getPixel(x, y) & 0xff;
	        				// 黒いほど採用しやすい
	        				if(Math.random() < 1 - pc / 210)break;
        				}
        				xs.push(x);
        				ys.push(y);
        			}
        			
        			// 最後もstageの外
        			xs.push(W / 2 + r * Math.cos(theta));
        			ys.push(H / 2 + r * Math.sin(theta));
        			
        			// スプラインの係数を計算して格納
        			var xCoes : Object = Spline.calcCoordinate(xs);
        			var yCoes : Object = Spline.calcCoordinate(ys);
        			_particles.push(new Particle(xCoes, yCoes));
        		}
        		
        		_tlim = bmds.length + 2;
        
        		// _bmdsは用済み		
    			for each(bmd in bmds){
    				bmd.dispose();
    			}
        		
        		start();
  		}
  		
  		private function start() : void
  		{
        		_t = 0;
        		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        		addEventListener(Event.ENTER_FRAME, onEnterFrame);
        		_offset = Math.random() * 2 * Math.PI;
  		}
  		
  		private function onEnterFrame(e : Event) : void
  		{
  			_canvas.lock();
  			// パーティクルの描画
  			for each(var p : Particle in _particles){
  				var px : Number = Spline.calc(p.xCoes, _t);
  				var py : Number = Spline.calc(p.yCoes, _t);
  				_canvas.setPixel(px, py, 0xffffff);
  			}
  			
  			// 色減衰
  			// 減衰度をまわすことによって色調を変える
  			_canvas.colorTransform(_canvas.rect, 
  				new ColorTransform(
  					0.96 + 0.02 * Math.sin(_t + _offset),
  					0.96 + 0.02 * Math.sin(_t + Math.PI * 2 / 3 + _offset),
  					0.96 + 0.02 * Math.sin(_t + Math.PI * 4 / 3 + _offset)
  					));
  			
  			_canvas.unlock();
  			_t += 0.009;
  			if(_t >= _tlim)removeEventListener(Event.ENTER_FRAME, onEnterFrame);
  		}
  		
  		// tfを画面の中央に置いてscale倍してBitmapDataに転写
  		private function textFieldToBitmap(tf : TextField, scale : Number = 1) : BitmapData
  		{
        		var bmd : BitmapData = new BitmapData(W, H, true, 0x00ffffff);
        		var mat : Matrix = new Matrix();
        		mat.scale(scale, scale);
        		mat.translate(W / 2 - tf.width * scale / 2, H / 2 - tf.height * scale / 2);
        		bmd.draw(tf, mat);
        		return bmd;
        }
    }
}

class Particle
{
	public var xCoes : Object;
	public var yCoes : Object;
	
	public function Particle(xCoes : Object, yCoes : Object) : void
	{
		this.xCoes = xCoes; this.yCoes = yCoes;
	}
}

// @see http://www5d.biglobe.ne.jp/~stssk/maze/spline.html
class Spline {
    public static function calc(cs : Object, t : Number) : Number
    { 
        var p : int = int(t);
        if(p >= cs.a.length)p--;
        if(p < 0)p = 0;
        var dt : Number = t - p;
        return cs.a[p] + (cs.b[p] + (cs.c[p] + cs.d[p] * dt) * dt) * dt;
    }
    
    public static function calcCoordinate(a : Array) : Object
    {
        var n : int = a.length;

        var b : Array = [];
        var c : Array = [];
        var d : Array = [];
        var w : Array = [];

        var i : int;

        c.push(0);
        for(i = 1;i < n - 1;i++){
            c.push(3 * (a[i + 1] - 2 * a[i] + a[i - 1]));
        }
        c.push(0);

        w.push(0);

        for(i = 1;i < n - 1;i++){
            var l : Number = 4.0 - w[i - 1];
            c[i] = (c[i] - c[i - 1]) / l;
            w.push(1.0 / l);
        }
        for(i = n - 2;i > 0;i--){
            c[i] -= c[i + 1] * w[i];
        }


        for(i = 0;i < n - 1;i++){
            d.push((c[i + 1] - c[i]) / 3.0);
            b.push(a[i + 1] - a[i] - c[i] - d[i]);
        }
        b.push(0);
        d.push(0);
            
        return {a : a, b : b, c : c, d : d};
    }
}