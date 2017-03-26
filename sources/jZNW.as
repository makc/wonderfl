/*
 * 顔領域抽出APIとして、face.comを使います。
 * http://face.com/
 * 写真はPicasaから取得します。
 * Picasa Web Albums Data API
 * http://code.google.com/intl/ja/apis/picasaweb/docs/2.0/reference.html
 * 
 * face.comは右目、左目、鼻、口のポイントを取得できるので、
 * 精度たかく変化をつけられる。
*/
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.text.TextField;
	import com.adobe.serialization.json.JSON;
	
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.tweens.ITween;
	
	[SWF(backgroundColor="0x000000")]
	public class Main extends Sprite {
		private var _data_array:Array;
		private var _loadImg_array:Array;
		private var _loadCount:int;
		private var _creditFromURL:Object;
		private var _linkFromURL:Object;
		private var _isWired:Boolean;
		
		private var _defaultItems:Array = [ { 
			link:"http://picasaweb.google.com/bsinay/JamesSinayFirstMonth#5399968342749500434", credit:"Brian", 
			imgURL:"http://lh5.ggpht.com/_9LEeoggU0a8/SvCKmPPwVBI/AAAAAAABhtY/YUE-ua-xQXM/s512/IMG_2617.JPG"
			}, { 
			link:"http://picasaweb.google.com/jkarteaga/SpockParty#5305544240681108210", credit:"jkarteaga", 
			imgURL:"http://lh4.ggpht.com/_XfCVkJdf81A/SaEUYH3qwvI/AAAAAAAADgo/SQnWoPZsBok/s512/IMGP2672.JPG"
			} ];
		
		public function Main() {
			//FULL SCREENに対応させるため、計算しやすいように左上基準、noScaleにする。
			stage.align = "TL";
			stage.scaleMode = "noScale";
			
			//URLLoaderを作る
			var myURLLoader:URLLoader = new URLLoader();
			myURLLoader.addEventListener(Event.COMPLETE, onCompleteXML);
			//検索ワードを数種類の中からランダムに出るようにする。
			var keywords_array:Array = ["manager", "japan", "smile", "boy", "swim"];
			var keyword:String = keywords_array[Math.floor(Math.random() * keywords_array.length)];
			//keyword = "japan";
			//trace(keyword)
			//モーフィングが始まるまでに時間がかかるため、検索キーワードを表示する
			var tf:TextField = new TextField();
			tf.textColor = 0xFFFFFF;
			tf.text = "Serch keyword is..." + keyword;
			tf.autoSize = "left";
			addChild(tf);
			
			//検索の開始位置を指定する。
			//var startIndex:int = Math.ceil(Math.random() * 30);
			var startIndex:int = Math.ceil(Math.random() * 10);
			//検索
			//face=trueが入っていることに注意
			var xmlURL:String = "http://photos.googleapis.com/data/feed/base/all?alt=rss&kind=photo&face=true&q=" + keyword + "&imglic=remix&max-results=3&imgmax=512&start-index=" + startIndex;
			//クロスドメインポリシーファイルの位置を指定
			Security.loadPolicyFile("http://photos.googleapis.com/data/crossdomain.xml");
			myURLLoader.load(new URLRequest(xmlURL));
			
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onCompleteXML(e:Event):void {
			//取得したデータをXML型に
			var myXML:XML = new XML(e.currentTarget.data);
			//namespaceを設定
			default xml namespace = new Namespace("http://search.yahoo.com/mrss/");
			_data_array = [];
			_creditFromURL = { };
			_linkFromURL = { };
			//Dump.object(myXML);
			//XMLを解析
			for (var i:int = 0; i < 3; i++) {
				//Objectをつくり、必要な値を入れている
				var data:Object = new Object();
				data["imgURL"] = String(myXML.channel.item[i].group.content.@url);
				//face.comは画像のリクエスト順に結果がくるわけではないので、urlで管理。
				_creditFromURL[data["imgURL"]] = String(myXML.channel.item[i].group.credit);
				_linkFromURL[data["imgURL"]] = String(myXML.channel.item[i].link);
				
				//arrayに入れて、後から使いやすいように
				_data_array[i] = data;
			}
			
			//顔領域が認識されやすい画像を指定
			//これにより、モーフィングが発生しない確率を減らす
			_data_array[3] = _defaultItems[0];
			_data_array[4] = _defaultItems[1];
			
			_creditFromURL[_defaultItems[0].imgURL] = _defaultItems[0].credit;
			_linkFromURL[_defaultItems[0].imgURL] = _defaultItems[0].link;
			
			_creditFromURL[_defaultItems[1].imgURL] = _defaultItems[1].credit;
			_linkFromURL[_defaultItems[1].imgURL] = _defaultItems[1].link;
			
			//kayacのImagePipesに取得したURLを渡して、顔の領域を取得する
			//まずは渡す内容を作る
			var myURLVariables:URLVariables = new URLVariables();
			var URLstr:String = "";
			URLstr += _data_array[0].imgURL + ",";
			URLstr += _data_array[1].imgURL + ",";
			URLstr += _data_array[2].imgURL + ",";
			URLstr += _data_array[3].imgURL + ",";
			URLstr += _data_array[4].imgURL;
			
			myURLVariables.api_key = "8160c151a8244f85edcb8e640972319d";
			myURLVariables.urls = URLstr;
			myURLVariables.api_secret = "1fd816bf613eac17d718790c661f1400";
			
			//顔領域抽出サービスの渡す先
			var myURLRequest:URLRequest = new URLRequest("http://api.face.com/faces/detect.format");
			myURLRequest.method = URLRequestMethod.POST;		//*1
			//渡す内容を関連付ける
			myURLRequest.data = myURLVariables;		//*2
			//ドキュメントルート上にcrossdomain.xmlがあるので、特に指定はしなくても自動的に読みにいく
			//http://api.face.com/crossdomain.xmlを確認のこと
			var loader:URLLoader = new URLLoader ();
			loader.addEventListener(Event.COMPLETE, onCompleteFacerecon);
			loader.load(myURLRequest);
			
		}
		
		private function onCompleteFacerecon(e:Event):void {
			//取得結果例
			var json:Object = JSON.decode(URLLoader(e.target).data);
			if (json.status != "success") {
				Dump.object(json);
				var tf:TextField = new TextField();
				tf.y = 50;
				tf.textColor = 0xFF0000;
				tf.text = "エラーが発生しました。リロードしてください。\n" + json.error_message;
				tf.width = tf.height = 465;
				this.addChild(tf);
				trace("活動停止");
				return;
			}
			
			var items:Array = json.photos;
			_loadImg_array = [];
			Dump.object(json);
			for (var i:int = 0; i < items.length; i++) {
				//顔領域を抽出できない場合にはitems[i].tagsの中身がないので、この存在を確認
				if (items[i].tags.length) {
					
					var m:int = items[i].tags.length;
					var shuffled:Array = shuffle(m);
					for (var k:int = 0; k < m; k++) {
						var j:int = shuffled[k];
						var face:Face = new Face();
						face.set_photo(items[i].width, items[i].height);
						face.set_eye_left(items[i].tags[j].eye_left);
						face.set_eye_right(items[i].tags[j].eye_right);
						face.set_nose(items[i].tags[j].nose);
						face.set_mouth_left(items[i].tags[j].mouth_left);
						face.set_mouth_center(items[i].tags[j].mouth_center);
						face.set_mouth_right(items[i].tags[j].mouth_right);
						face.set_gender(items[i].tags[j].attributes.gender.value);
						if (items[i].tags[j].pitch) {
							face.pitch = items[i].tags[j].pitch;
						}
						face.set_chin(items[i].tags[j].chin);
						
						if(face.isComp){
							//face.comは画像のリクエスト順に結果がくるわけではないので、
							//画像のURLを改めて指定。
							_data_array[i].imgURL = items[i].url;
							//画像のロード
							var myLoader:Loader = new Loader();
							//クロスドメインポリシーファイルをドキュメントルートから取得
							var myLoaderContext:LoaderContext = new LoaderContext(true);
							myLoader.load(new URLRequest(_data_array[i].imgURL), myLoaderContext);
							myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteImg);
							
							//face.comでは、100分率で位置や縦横サイズを返すので、それぞれピクセルに変換
							var photoWidth:Number = items[i].width*0.01;
							var photoHeight:Number = items[i].height*0.01;
							var w:Number = Math.round(items[i].tags[j].width*photoWidth);
							var h:Number = Math.round(items[i].tags[j].height*photoHeight);
							var cx:Number = Math.round(items[i].tags[j].center.x*photoWidth - w / 2);
							var cy:Number = Math.round(items[i].tags[j].center.y*photoHeight - h / 2);
							
							//Objectをつくり、必要な値を入れる
							var data:Object = { };
							data["face"] = face;
							data["credit"] = _creditFromURL[items[i].url];
							data["link"] = _linkFromURL[items[i].url];
							data["loader"] = myLoader;
							//arrayに入れて、後から使いやすいように
							_loadImg_array.push(data);
							//有効にすると、各写真１枚に限定
							break;
						}
					}
				}
			}
		}
		
		private function onCompleteImg(e:Event):void {
			//全部読むまでは処理が先に進まないように
			_loadCount ++;
			if (_loadCount < _loadImg_array.length) {
				return;
			};
			
			//読み込んだ画像を_loadImg_arrayにいれる。
			for (var i:int  = 0; i < _loadImg_array.length; i++) {
				_loadImg_array[i]["photoRect"] = new Rectangle(0, 0 , _loadImg_array[i].loader.width, _loadImg_array[i].loader.height);
			}
			//morphを実行する処理を設定。
			//{num:0}を設定することによって、何回目の呼び出しかを取得できるようにする。
			var t:ITween = BetweenAS3.func(morph, [ { num:0 } ]);
			//無限ループに設定
			t.stopOnComplete = false;
			//4秒目から実行
			t.play();
		}
		
		private function morph(count:Object):void {
			//モーフィングの処理
			
			//ステージ上のオブジェクトを全て削除
			while (this.numChildren) {
				this.removeChildAt(0);
			}
			
			//e.currentTarget.currentCountで何回目の呼び出しかを取得する
			//変化の割合（0～1）を決定する
			var ratio:Number = (count.num / 60) % 1;
			
			//呼び出すべき現在の画像、次の画像を決定する
			var currentImgNum:int = Math.floor(count.num / 60) % _loadImg_array.length;
			var nextImgNum:int = (currentImgNum + 1) % _loadImg_array.length;
			var currentImgObj:Object = _loadImg_array[currentImgNum];
			var nextImgObj:Object = _loadImg_array[nextImgNum];
			//カウントをひとつ繰り上げる
			count.num++;
			
			var indices:Vector.<int> = Vector.<int>([
			0, 16, 3, 0, 15, 16, 0, 1, 15, 1, 2, 15, 2, 17, 15, 2, 4, 17,
			3, 16, 18, 16, 8, 18, 16, 15, 8, 15, 9, 8, 15, 17, 9, 17, 19, 9, 17, 4, 19,
			8, 11, 18, 8, 10, 11, 8, 9, 10, 9, 13, 10, 9, 19, 13,
			11, 10, 12, 10, 13, 12,
			3, 18, 20, 18, 11, 20, 11, 12, 20, 12, 14, 20, 12, 21, 14, 12, 13, 21, 13, 19, 21, 19, 4, 21,
			3, 20, 5, 20, 14, 5, 5, 14, 6, 14, 7, 6, 14, 7, 21, 21, 4, 7
			]);
			
			var n:int = _loadImg_array[0].face.vertices.length;
			var vertices:Vector.<Number> = new Vector.<Number>(n);
			
			for (var i:int = 0; i < n; i++) {
				vertices[i] = currentImgObj.face.vertices[i] * (1 - ratio) + nextImgObj.face.vertices[i] * ratio;
			}
			
			var shapebg:Shape = new Shape();
			if(_isWired){
				shapebg.graphics.lineStyle(0, 0x0000FF);
			}
			shapebg.graphics.beginBitmapFill(currentImgObj.loader.content.bitmapData);
			shapebg.graphics.drawTriangles(vertices, indices, currentImgObj.face.uvtData);
			shapebg.x += (stage.stageWidth - shapebg.width) / 2;
			shapebg.y += (stage.stageHeight - shapebg.height) / 2;
			this.addChild(shapebg);
			
			var shape:Shape = new Shape();
			if(_isWired){
				shape.graphics.lineStyle(0, 0xFF0000);
			}
			shape.graphics.beginBitmapFill(nextImgObj.loader.content.bitmapData);
			shape.graphics.drawTriangles(vertices, indices, nextImgObj.face.uvtData);
			shape.x += (stage.stageWidth - shape.width) / 2;
			shape.y += (stage.stageHeight - shape.height) / 2;
			shape.alpha = ratio;
			this.addChild(shape);
			
			var credit:String = (ratio < 0.5)?currentImgObj.credit:nextImgObj.credit;
			var link:String = (ratio < 0.5)?currentImgObj.link:nextImgObj.link;
			
			//クレジット＆リンクのためのテキストフィールドを作る。
			var textField:TextField = new TextField();
			textField.htmlText = "<a href='" + link + "'>Photo by " + credit + "</a>";
			textField.autoSize = "left";
			textField.textColor = 0xFFFFFF;
			//ドロップシャドウをかける
			var dsf:DropShadowFilter = new DropShadowFilter();
			textField.filters = [dsf];
			addChild(textField);
		}
		private function shuffle(num:int):Array {
			var _array:Array = new Array();
			for (var i:int= 0; i<num; i++){
				_array[i] = Math.random();
			}
			return _array.sort(Array.RETURNINDEXEDARRAY);
		}
		private function onClick(e:MouseEvent):void {
			_isWired = !_isWired;
		}
	}
}


import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;
class Face {
	public var pitch:Number;
	public var isMale:Boolean;
	public var uvtData:Vector.<Number>;
	public var vertices:Vector.<Number>;
	public function Face() { };
	public function set_gender(value:String):void {
		isMale = (value == "male");
	}
	
	public function get isComp():Boolean {
		return (_eye_right && _eye_left && _nose && _mouth_left && _mouth_center && _mouth_right);
	}
	
	private var _photo:Rectangle;
	public function get photo():Rectangle { return _photo };
	public function set_photo(valueW:Number, valueH:Number):void {
		uvtData = Vector.<Number>([0, 0, 0.5, 0, 1, 0, 0, 0.5, 1, 0.5, 0, 1, 0.5, 1, 1, 1]);
		vertices = Vector.<Number>([0, 0, valueW / 2, 0, valueW, 0, 0, valueH / 2, valueW, valueH / 2, 0, valueH, valueW / 2, valueH, valueW, valueH]);
		_photo = new Rectangle(0, 0, valueW, valueH);
	}
	
	private var _eye_left:Point;
	public function get eye_left():Point { return _eye_left };
	public function set_eye_left(value:Object):void {
		if (value) {
			uvtData[16] = value.x*0.01;
			uvtData[17] = value.y * 0.01;
			_eye_left = new Point(value.x*_photo.width*0.01, value.y*_photo.height*0.01);
			vertices[16] = _eye_left.x;
			vertices[17] = _eye_left.y;
		}
	}
	
	private var _eye_right:Point;
	public function get eye_right():Point { return _eye_right };
	public function set_eye_right(value:Object):void {
		if (value) {
			uvtData[18] = value.x*0.01;
			uvtData[19] = value.y*0.01;
			_eye_right = new Point(value.x * _photo.width * 0.01, value.y * _photo.height * 0.01);
			vertices[18] = _eye_right.x;
			vertices[19] = _eye_right.y;
		}
	}
	
	private var _nose:Point;
	public function get nose():Point { return _nose };
	public function set_nose(value:Object):void {
		if (value) {
			uvtData[20] = value.x*0.01;
			uvtData[21] = value.y*0.01;
			_nose = new Point(value.x*_photo.width*0.01, value.y*_photo.height*0.01);
			vertices[20] = _nose.x;
			vertices[21] = _nose.y;
		}
	}
	
	private var _mouth_left:Point;
	public function get mouth_left():Point { return _mouth_left };
	public function set_mouth_left(value:Object):void {
		if (value) {
			uvtData[22] = value.x*0.01;
			uvtData[23] = value.y*0.01;
			_mouth_left = new Point(value.x*_photo.width*0.01, value.y*_photo.height*0.01);
			vertices[22] = _mouth_left.x;
			vertices[23] = _mouth_left.y;
		}
	}
	
	private var _mouth_center:Point;
	public function get mouth_center():Point { return _mouth_center };
	public function set_mouth_center(value:Object):void {
		if (value) {
			uvtData[24] = value.x*0.01;
			uvtData[25] = value.y*0.01;
			_mouth_center = new Point(value.x*_photo.width*0.01, value.y*_photo.height*0.01);
			vertices[24] = _mouth_center.x;
			vertices[25] = _mouth_center.y;
		}
	}
	
	private var _mouth_right:Point;
	public function get mouth_right():Point { return _mouth_right };
	public function set_mouth_right(value:Object):void {
		if (value) {
			uvtData[26] = value.x*0.01;
			uvtData[27] = value.y*0.01;
			_mouth_right = new Point(value.x * _photo.width * 0.01, value.y * _photo.height * 0.01);
			vertices[26] = _mouth_right.x;
			vertices[27] = _mouth_right.y;
		}
	}
	//chin
	private var _chin:Point;
	public function get chin():Point { return _chin };
	public function set_chin(value:Object):void {
		if (value) {
			uvtData[28] = value.x*0.01;
			uvtData[29] = value.y*0.01;
			_chin = new Point(value.x * _photo.width * 0.01, value.y * _photo.height * 0.01);
			vertices[28] = _chin.x;
			vertices[29] = _chin.y;
		}else {
			//あごのデータが無い場合。口の中央から鼻までの長さを口の中央に足している。
			//男のほうがあごが長いので1.5倍。
			var ago:Number = (isMale?1.5:1);
			//角度によって、調整
			ago *= Math.cos(pitch * Math.PI / 180);
			uvtData[28] = uvtData[24] + (uvtData[24] - uvtData[20])*ago;
			uvtData[29] = uvtData[25] + (uvtData[25] - uvtData[21])*ago;
			_chin = new Point(uvtData[28] * _photo.width, uvtData[29] * _photo.height);
			vertices[28] = _chin.x;
			vertices[29] = _chin.y;
		}
		//おでこ
		var dx:Number = (uvtData[16] + uvtData[18]) / 2 - uvtData[20];
		var dy:Number = (uvtData[17] + uvtData[19]) / 2 - uvtData[21];
		uvtData[30] = uvtData[20] + dx * 3.5;
		uvtData[31] = uvtData[21] + dy * 3.5;
		uvtData[31] = Math.max(0, uvtData[31]);
		vertices[30] = uvtData[30] * _photo.width;
		vertices[31] = uvtData[31] * _photo.height;
		//おでこ左
		uvtData[32] = uvtData[16] - uvtData[20] + uvtData[16];
		uvtData[33] = uvtData[17] - uvtData[21] + uvtData[17];
		vertices[32] = uvtData[32] * _photo.width;
		vertices[33] = uvtData[33] * _photo.height;
		//おでこ右
		uvtData[34] = uvtData[18] - uvtData[20] + uvtData[18];
		uvtData[35] = uvtData[19] - uvtData[21] + uvtData[19];
		vertices[34] = uvtData[34] * _photo.width;
		vertices[35] = uvtData[35] * _photo.height;
		//左のこめかみ
		dx = (uvtData[16] + uvtData[22]) / 2 - uvtData[20];
		dy = (uvtData[17] + uvtData[23]) / 2 - uvtData[21];
		uvtData[36] = uvtData[20] + dx * 2;
		uvtData[37] = uvtData[21] + dy * 2;
		vertices[36] = uvtData[36] * _photo.width;
		vertices[37] = uvtData[37] * _photo.height;
		//右のこめかみ
		dx = (uvtData[18] + uvtData[26]) / 2 - uvtData[20];
		dy = (uvtData[19] + uvtData[27]) / 2 - uvtData[21];
		uvtData[38] = uvtData[20] + dx * 2;
		uvtData[39] = uvtData[21] + dy * 2;
		vertices[38] = uvtData[38] * _photo.width;
		vertices[39] = uvtData[39] * _photo.height;
		//おでこ左
		uvtData[40] = uvtData[22] - uvtData[20] + uvtData[22];
		uvtData[41] = uvtData[23] - uvtData[21] + uvtData[23];
		vertices[40] = uvtData[40] * _photo.width;
		vertices[41] = uvtData[41] * _photo.height;
		//おでこ右
		uvtData[42] = uvtData[26] - uvtData[20] + uvtData[26];
		uvtData[43] = uvtData[27] - uvtData[21] + uvtData[27];
		vertices[42] = uvtData[42] * _photo.width;
		vertices[43] = uvtData[43] * _photo.height;
		
	}
}


import flash.utils.getQualifiedClassName;
class Dump {
	static public function stringFromObject(obj:Object):String {
		var str:String = _dump(obj);
		if (getQualifiedClassName(obj) == "Array") {
			str = "[\n" + str.slice( 0, -2 ) + "\n]";
		}else {
			str = "{\n" + str.slice( 0, -2 ) + "\n}";
		}
		return str;
	}
	static public function object(obj:Object):void {
		trace(stringFromObject(obj));
	}
	static private function _dump(obj:Object, indent:int = 0):String {
		var result:String = "";
		
		var da:String = (getQualifiedClassName(obj) == "Array")?'':'"';
		
		var tab:String = "";
		for ( var i:int = 0; i < indent; ++i ) {
			tab += "    ";
		}
		
		for (var key:String in obj) {
			if (typeof obj[key] == "object") {
				var type:String = getQualifiedClassName(obj[key]);
				if (type == "Object" || type == "Array") {
					result += tab + da + key + da + ":"+((type == "Array")?"[":"{");
					var dump_str:String = _dump(obj[key], indent + 1);
					if (dump_str.length > 0) {
						result += "\n" + dump_str.slice(0, -2) + "\n";
						result += tab;
					}
					result += (type == "Array")?"],\n":"},\n";
				}else {
					result += tab + '"' + key + '":<' + type + ">,\n";
				}
			}else if (typeof obj[key] == "function") {
				result += tab + '"' + key + '":<Function>,\n';
			}else {
				var dd:String = (typeof obj[key] == "string")?"'":"";
				result += tab + da + key + da + ":" + dd + obj[key] +dd + ",\n";
			}
		}
		return result;
	}
}

