package {
	/**
	 * @author YOSHIDA, Akio
	 * 2009/01/22　手抜きで実装していなかった裏面判定処理を追加
	 */
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Vector3D;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.system.Security;
	
	
	[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "#000000")]

	public class MainProxy extends Sprite {
		
		private var loader:Loader;	// ローダー
		private var loading:TextField;	// ナウローディング表示
		
		// 画像をピクセルスキャン
		private var ipx:ImagePixelizer;

		// プロジェクション
		private var fov:PerspectiveProjection;
		// ドットのキャンバス
		private var canvasUpper:BitmapData;    // 裏
		private var canvasLower:BitmapData;    // 表
		// 頂点格納 Vector
		private var vctrVertics:Vector.<Vertex>;
		
		// 回転に関わる変数
		private var aX:Number = 0;
		private var aY:Number = 0;
		
		// 定数
		private const SW:uint = 465;		// stage.stageWidth
		private const SH:uint = 465;		// stage.stageHeight
		private const DIST:uint = 150;		// 中心から頂点までの距離
		private const XOFF:Number = SW / 2;	// stageWidth / 2
		private const YOFF:Number = SH / 2;	// stageheight / 2
		
		public function MainProxy():void {
			Security.loadPolicyFile("http://5ivestar.org/proxy/crossdomain.xml");
			// Loader 生成
			loader = new Loader();
			// イベントリスナー登録
			configureListeners(loader.contentLoaderInfo);
			// ロード開始
			loader.load(new URLRequest("http://5ivestar.org/proxy/http://homepage3.nifty.com/aquioux/swf/as3/wonderfl/aquioux002.png"));
			// ナウローディング
			loading = new TextField();
			loading.defaultTextFormat = new TextFormat("_sans", 24, 0xffffff);
			loading.text = "Now Loading...";
			loading.autoSize = "left";
			loading.x = (stage.stageWidth - loading.width) / 2;
			loading.y = (stage.stageHeight - loading.height) / 2;
			addChild(loading);
		}
		// イベントリスナー登録
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
		}
		// 読み込み完了時のイベントハンドラ
		private function completeHandler(e:Event):void {
			removeChild(loading);
			loading = null;
			
			// 表示イメージ
			var w:uint = loader.width;
			var h:uint = loader.height;
			var bmd:BitmapData = new BitmapData(w, h, true, 0x00ffffff);
			bmd.draw(loader.content);
			
			ipx = new ImagePixelizer();
			ipx.addEventListener(PixelizerEvent.COMPLETE, init);
			ipx.pixelize(new Bitmap(bmd));
			
			loader = null;
		}

		private function init(e:PixelizerEvent = null):void {
			createCanvas();		// キャンバス生成
			createProjection();	// プロジェクション生成
			createVertics();	// 頂点生成
			// イベントハンドラ
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		
		// onEnterFrame
		private function onEnterFrameHandler(e:Event):void {
			// 回転角度を増加
			aX += (mouseX - XOFF) * 0.01;
			aY -= (mouseY - YOFF) * 0.01;

			// 変換行列生成
			var mat:Matrix3D = new Matrix3D();
			// 回転を変換行列に合成
			mat.appendRotation(aX, Vector3D.Y_AXIS);
			mat.appendRotation(aY, Vector3D.X_AXIS);

			perspective(mat, fov);	// 投影
			render();				// レンダリング
		}

		// 投影
		private function perspective(mat:Matrix3D, fov:PerspectiveProjection):void {
			for each (var element:Vertex in vctrVertics) {
				element.perspective(mat, fov);
			}
		}
		// レンダリング
		private function render():void {
			canvasLower.lock();
			canvasUpper.lock();
			canvasLower.fillRect(canvasLower.rect, 0x000000);
			canvasUpper.fillRect(canvasUpper.rect, 0x000000);
			for each (var element:Vertex in vctrVertics) {
				if (element.z < 0) {
					canvasLower.setPixel(element.x+XOFF, element.y+YOFF, 0x0033ff);
				} else {
					canvasUpper.setPixel32(element.x+XOFF, element.y+YOFF, 0xffffcc00);
				}
			}
			canvasLower.unlock();
			canvasUpper.unlock();
		}

		// キャンバス生成
		private function createCanvas():void{
			canvasLower = new BitmapData(SW, SH, false, 0x000000);
			canvasUpper = new BitmapData(SW, SH, true,  0x00000000);
			addChild(new Bitmap(canvasLower));
			addChild(new Bitmap(canvasUpper));
		}
		// プロジェクション生成
		private function createProjection():void {
			fov = new PerspectiveProjection();
			fov.fieldOfView = 55;	// 視野角の設定
		}
		// 頂点生成
		private function createVertics():void {
			var vNum:uint = ipx.height;
			var hNum:uint = ipx.width;
			var data:Vector.<Pixel> = ipx.data;
			
			// theta:シータ（θ）は緯度、phi:ファイ（φ）は経度
			var theta:Number = Math.PI / vNum;
			var phi:Number   = Math.PI * 2 / hNum;
			
			vctrVertics = new Vector.<Vertex>();
			var i:uint = 0;
			for (var v:int = 0; v < vNum ; v++) {
				for (var h:int = 0; h < hNum ; h++) {
					var p:Pixel = data[i++];
					var alpha:uint = getAlpha(p.color);
					if (alpha >= 0x7f){
						var px:Number = DIST * Math.sin(theta * v) * Math.cos(phi * h);
						var py:Number = DIST * Math.cos(theta * v);
						var pz:Number = DIST * Math.sin(theta * v) * Math.sin(phi * h);
						var vertex:Vertex = new Vertex(px, -py, -pz);
						vctrVertics.push(vertex);
					}
				}
			}
			ipx = null;
		}
		// 32 bit color からアルファ値を求める
		private function getAlpha(hex:uint):uint {
			return (hex >> 24) & 0xff;
		}
	}
}

/*
 * 頂点クラス
 */
import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import flash.geom.PerspectiveProjection;

/* 
 * 頂点クラス
 */
class Vertex {
	private var home:Vector3D = new Vector3D();	// 座標ホームポジション
	private var proj:Vector3D = new Vector3D();	// 投影座標
	
	public function Vertex(x:Number, y:Number, z:Number) {
		home.x = x;
		home.y = y;
		home.z = z;
	}
	// 投影処理（透視投影）
	public function perspective(mat:Matrix3D, fov:PerspectiveProjection):void {
		proj = mat.transformVector(home);
		proj.w = fov.focalLength / (fov.focalLength + proj.z);
		proj.project();
	}
	// getter
	public function get x():Number { return proj.x; }
	public function get y():Number { return proj.y; }
	public function get z():Number { return proj.z; }
	public function get w():Number { return proj.w; }
}

/* 
 * ピクセルクラス
 */
class Pixel {
	private var _x:Number;
	private var _y:Number;
	private var _color:uint;	// 32 bit color

	public function Pixel(x:Number, y:Number, color:uint) {
		_x = x;
		_y = y;
		_color = color;
	}
	// getter
	public function get x():Number { return _x; }
	public function get y():Number { return _y; }
	public function get color():uint { return _color; }
	// setter
	public function set x(value:Number):void { _x = value; }
	public function set y(value:Number):void { _y = value; }
	public function set color(value:uint):void { _color = value; }
}

/* 
 * BitmapData を1ピクセル単位でスキャン
 * 結果は Vector.<Pixel> で返す
 * バックエンドクラスとして Pixelizer を使用
 */
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;

class ImagePixelizer extends EventDispatcher {
	// バックエンドクラス
	private var px:Pixelizer;

	public function ImagePixelizer() {}

	// ピクセル情報作成
	public function pixelize(bm:Bitmap):void {
		// バックエンドクラス設定
		px = new Pixelizer();
		px.addEventListener(PixelizerEvent.COMPLETE, completeHandler);
		
		// BitmapData 生成
		var bmd:BitmapData = new BitmapData(bm.width, bm.height, true, 0x00ffffff);
		bmd.draw(bm);
		
		// 走査
		px.scan(bmd);
	}
	private function completeHandler(e:Event):void {
		dispatchEvent(new PixelizerEvent(PixelizerEvent.COMPLETE));
	}

	// getter（pixelize 実行後に有効）
	public function get data():Vector.<Pixel> { return px.data; }
	public function get width():uint { return px.width; }
	public function get height():uint { return px.height; }
}

/* 
 * BitmapData を1ピクセル単位でスキャン
 * ピクセルの32ビットカラーを二次元配列に格納
 * ImagePixelizer と TextPixelizer からバックエンドクラスとして呼び出される
 */
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;

class Pixelizer extends EventDispatcher {
	// ピクセル格納ベクター
	private var _data:Vector.<Pixel>;
	// スキャンサイズ
	private var _width:uint = 0;	// 幅
	private var _height:uint = 0;	// 高

	public function Pixelizer() {}

	// 走査
	public function scan(bmd:BitmapData):void {
		var w:uint = _width = bmd.width;
		var h:uint = _height = bmd.height;
		var i:uint = 0;
		_data = new Vector.<Pixel>(w*h, true);
		for (var y:uint = 0; y < h; y++){
			for (var x:uint = 0; x < w; x++){
				_data[i++] = new Pixel(x, y, bmd.getPixel32(x, y));
			}
		}
		// BitmapData 消去
		bmd.dispose();
		// イベント発行
		dispatchEvent(new PixelizerEvent(PixelizerEvent.COMPLETE));
	}

	// getter（pixelize 実行後に有効）
	public function get data():Vector.<Pixel> { return _data; }
	public function get width():uint { return _width; }
	public function get height():uint { return _height; }
}

/*
 * Pixelizer イベント
 */
import flash.events.Event;

class PixelizerEvent extends Event {
	public static const COMPLETE:String = "complete";

	public function PixelizerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
		super(type, bubbles, cancelable);
	}
	public override function clone():Event {
		return new PixelizerEvent(type, bubbles, cancelable);
	}
	public override function toString():String {
		return formatToString("PixelizerEvent", "type", "bubbles", "cancelable", "eventPhase");
	}
}
