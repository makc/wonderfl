/**
 * bkzenさんのスコア登録ウィンドウを使いたいのでテスト
 * @see	http://wonderfl.net/c/cuY4
 * @see	http://wonderfl.net/c/kYyY
 */
package  {
	
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class ScoreWindowTest extends Sprite {
		
		private var _message:Label;
		public function ScoreWindowTest() {
			ScoreWindow.title = "Hoge Moja";
			ScoreWindow.init(loaderInfo, onComplete, onError);
			_message = new Label(this, 5, 5, "...");
		}
		
		private function onError():void {
			_message.text = "ERROR...";
		}
		
		private function onComplete():void {
			_message.text = "LOADED";
			new PushButton(this, 180, 60, "REGISTER", onClick);
			addChild(ScoreWindow.sprite);
		}
		
		private function onClick(e:MouseEvent):void {
			_message.text = "SHOW WINDOW";
			ScoreWindow.show(Math.random() * 100000, onClose, "Moja Point", "moja", 3, 99, false);
		}
		
		private function onClose():void{
			_message.text = "CLOSED";
		}
		
	}
	
}

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import net.wonderfl.utils.WonderflAPI;

/**
 * スコア登録ウィンドウ
 */
class ScoreWindow {
	
	public static var sprite:Sprite = new Sprite();
	public static var title:String = "Test";
	private static var _api:WonderflAPI;
	private static var _content:Object;
	private static const SWF:String = "http://swf.wonderfl.net/swf/usercode/5/57/579a/579a46e1306b5770d429a3738349291f05fec4f3.swf";
	
	public static function init(loaderInfo:LoaderInfo, complete:Function = null, error:Function = null): void {
		_api = new WonderflAPI(loaderInfo.parameters);
		var loader:Loader = new Loader();
		var removeEvent:Function = function():void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, compFunc);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorFunc);
			loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorFunc);
		}
		var errorFunc:Function = function(e:Event): void {
			removeEvent();
			if(error != null) error();
		}
		var compFunc:Function = function(e:Event): void{
			removeEvent();
			_content = loader.content;
			if(complete != null) complete();
		}
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, compFunc);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorFunc);
		loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorFunc);
		loader.load(new URLRequest(SWF), new LoaderContext(true));
	}
	
	/**
	 * スコア登録ウィンドウを開く
	 * @param	score	登録するスコア
	 * @param	close	閉じられた時呼ばれる
	 * @param	scoreTitle	スコアの種類を決める名前
	 * @param	unit	スコアの後ろにつけるテキスト
	 * @param	decimal	小数点を何桁まで使うか
	 * @param	limit	スコア表示件数
	 * @param	reverse	trueでスコアが小さい方が上位になる
	 * @param	modal	モーダル処理
	 */
	public static function show(score:int, close:Function = null, scoreTitle:String = "Score", unit:String = "", decimal:int = 0, limit:int = 99, reverse:Boolean = false, modal:Boolean = true):void {
		var tweet:String = "Playing " + title + " [" + scoreTitle + ": %SCORE%" + unit + "] #wonderfl";
		var win:DisplayObject = _content.makeScoreWindow(_api, score, title, Math.pow(10, decimal), tweet, scoreTitle, unit, limit, int(!reverse));
		var closeFunc:Function = function(e: Event):void {
			win.removeEventListener(Event.CLOSE, closeFunc);
			if(close != null) close();
		}
		win.addEventListener(Event.CLOSE, closeFunc);
		sprite.addChild(win);
	}
	
}