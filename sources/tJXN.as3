/* 顔領域抽出APIとして、face.comを使います。
 * http://face.com/
 * 写真はPicasaから取得します。
 * Picasa Web Albums Data API
 * http://code.google.com/intl/ja/apis/picasaweb/docs/2.0/reference.html
*/
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
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
	import com.adobe.serialization.json.JSONDecoder;
	import com.adobe.serialization.json.JSON;
	import org.libspark.betweenas3.BetweenAS3;
	import org.libspark.betweenas3.tweens.ITween;
	
	[SWF(backgroundColor="0x000000")]
	public class Main extends Sprite {
		private var _data_array:Array;
		private var _loadImg_array:Array;
		private var _loadCount:int;
		private var _creditFromURL:Object = new Object();
		private var _linkFromURL:Object = new Object();
		
		private var _defaultItems:Array = [ { 
			link:"http://picasaweb.google.com/bsinay/JamesSinayFirstMonth#5399968342749500434", credit:"Brian", 
			imgURL:"http://lh5.ggpht.com/_9LEeoggU0a8/SvCKmPPwVBI/AAAAAAABhtY/YUE-ua-xQXM/s512/IMG_2617.JPG"
			}, { 
			link:"http://www.umehara.net", credit:"umhr", 
			imgURL:"http://lh5.ggpht.com/_u5gYAt2rVVo/SrxbVDBcWVI/AAAAAAAAAMk/adL_i4ETEhQ/ume32.jpg"
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
			
			//モーフィングが始まるまでに時間がかかるため、検索キーワードを表示する
			var tf:TextField = new TextField();
			tf.textColor = 0xFFFFFF;
			tf.text = "Serch keyword is..." + keyword;
			tf.autoSize = "left";
			addChild(tf);
			
			//検索の開始位置を指定する。
			var startIndex:int = Math.ceil(Math.random() * 10);
			//Picasaで検索するためのURLを作成。face=trueが入っていることに注意
			var xmlURL:String = "http://photos.googleapis.com/data/feed/base/all?alt=rss&kind=photo&face=true&q=" + keyword + "&imglic=commercial&max-results=3&imgmax=512&start-index=" + startIndex;
			//クロスドメインポリシーファイルの位置を指定
			Security.loadPolicyFile("http://photos.googleapis.com/data/crossdomain.xml");
			myURLLoader.load(new URLRequest(xmlURL));
		}
		
		private function onCompleteXML(e:Event):void {
			//取得したデータをXML型に
			var myXML:XML = new XML(e.currentTarget.data);
			//namespaceを設定
			default xml namespace = new Namespace("http://search.yahoo.com/mrss/");
			_data_array = [];
			//XMLを解析
			for (var i:int = 0; i < 3; i++) {
				//Objectをつくり、必要な値を入れている
				var data:Object = new Object();
				data["imgURL"] = String(myXML.channel.item[i].group.content.@url);
				//arrayに入れて、後から使いやすいように
				_data_array[i] = data;
				//face.comは画像のリクエスト順に結果がくるわけではないので、urlで管理。
				_creditFromURL[data["imgURL"]] = String(myXML.channel.item[i].group.credit);
				_linkFromURL[data["imgURL"]] = String(myXML.channel.item[i].link);
			}
			//顔領域が認識されやすい画像を指定。これにより、モーフィングが発生しない確率を減らす
			_data_array[3] = _defaultItems[0];
			_data_array[4] = _defaultItems[1];
			_creditFromURL[_defaultItems[0].imgURL] = _defaultItems[0].credit;
			_linkFromURL[_defaultItems[0].imgURL] = _defaultItems[0].link;
			_creditFromURL[_defaultItems[1].imgURL] = _defaultItems[1].credit;
			_linkFromURL[_defaultItems[1].imgURL] = _defaultItems[1].link;
			
			//face.comに取得したURLを渡して、顔の領域を取得する
			//URLをカンマ区切りでリクエストする。まずは渡す内容を作る
			var myURLVariables:URLVariables = new URLVariables();
			myURLVariables.urls = _data_array[0].imgURL + ",";
			myURLVariables.urls += _data_array[1].imgURL + ",";
			myURLVariables.urls += _data_array[2].imgURL + ",";
			myURLVariables.urls += _data_array[3].imgURL + ",";
			myURLVariables.urls += _data_array[4].imgURL;
			myURLVariables.api_key = "6fb3e9f17c8ea98788d3ed7e5f74a143";
			myURLVariables.api_secret = "8fb2a394f1232b930ff177ce79b3e3a3";
			
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
			
			var decoder:JSONDecoder = new JSONDecoder(e.currentTarget.data);
			var json:Object = decoder.getValue();
			if (json.status != "success") {
				var tf:TextField = new TextField();
				tf.y = 50;
				tf.textColor = 0xFF0000;
				tf.text = "エラーが発生しました。リロードしてください。\n" + json.error_message;
				tf.width = tf.height = 465;
				this.addChild(tf);
				return;
			}
			
			//取得結果はJSON形式で帰ってくる。コメントアウトをはずすと、
			//jsonの中身がtraceで確認できる。
			//Dump.object(json);
			
			var items:Array = json.photos;
			_loadImg_array = [];
			for (var i:int = 0; i < items.length; i++) {
				//顔領域を抽出できない場合にはitems[i].tagsの中身がないので、この存在を確認
				if (items[i].tags.length) {
					
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
					var w:Number = Math.round(items[i].tags[0].width*photoWidth);
					var h:Number = Math.round(items[i].tags[0].height*photoHeight);
					var cx:Number = Math.round(items[i].tags[0].center.x*photoWidth - w / 2);
					var cy:Number = Math.round(items[i].tags[0].center.y*photoHeight - h / 2);
					
					//Objectをつくり、必要な値を入れる
					var data:Object = { };
					data["faceRect"] = new Rectangle( cx, cy, w, h);		//*3
					data["credit"] = _creditFromURL[items[i].url];
					data["link"] = _linkFromURL[items[i].url];
					data["loader"] = myLoader;
					//arrayに入れて、後から使いやすいように
					_loadImg_array.push(data);
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
				//写真の矩形（Rectangle）を設定
				_loadImg_array[i]["photoRect"] = new Rectangle(0, 0 , _loadImg_array[i].loader.width, _loadImg_array[i].loader.height);
				//写真のに対して顔領域を元に９分割した矩形（Rectangle）を取得
				_loadImg_array[i]["sliceRect"] = getSliceRect(_loadImg_array[i].faceRect, _loadImg_array[i].photoRect);
				//写真ごとの９分割した画像（Bitmap）を取得
				_loadImg_array[i]["sliceBitmap"] = getSliceBitmap(_loadImg_array[i].loader.content, _loadImg_array[i].sliceRect);
			}
			
			//morphを実行する処理を設定。
			//{num:0}を設定することによって、何回目の呼び出しかを取得できるようにする。
			var t:ITween = BetweenAS3.func(morph, [ { num:0 } ]);
			//無限ループに設定
			t.stopOnComplete = false;
			//4秒目から実行
			t.play();
		}
		
		private function getSliceRect(faceRect:Rectangle, photoRect:Rectangle):Array {
			//写真の矩形と顔の矩形から、９分割の矩形を作り、arrayに入れて返す
			var result:Array = [];
			result[0] = new Rectangle(photoRect.x, photoRect.y, faceRect.x, faceRect.y);
			result[1] = new Rectangle(photoRect.x + faceRect.x, photoRect.y, faceRect.width, faceRect.y);
			result[2] = new Rectangle(photoRect.x + faceRect.right, photoRect.y, photoRect.width - faceRect.right, faceRect.y);
			result[3] = new Rectangle(photoRect.x , photoRect.y + faceRect.y, faceRect.x, faceRect.height);
			result[4] = new Rectangle(photoRect.x + faceRect.x, photoRect.y + faceRect.y, faceRect.width, faceRect.height);
			result[5] = new Rectangle(photoRect.x + faceRect.right, photoRect.y + faceRect.y, photoRect.width - faceRect.right, faceRect.height);
			result[6] = new Rectangle(photoRect.x , photoRect.y + faceRect.bottom, faceRect.x, photoRect.height - faceRect.bottom);
			result[7] = new Rectangle(photoRect.x + faceRect.x, photoRect.y + faceRect.bottom, faceRect.width, photoRect.height - faceRect.bottom);
			result[8] = new Rectangle(photoRect.x + faceRect.right, photoRect.y + faceRect.bottom, photoRect.width - faceRect.right, photoRect.height - faceRect.bottom);
			return result;
		}
		
		private function getSliceBitmap(photo:Bitmap, sliceRect:Array):Array {
			//写真をsliceRectに従って切り分け、arrayに入れて返す
			var result:Array = [];
			for (var i:int = 0; i < 9; i++) {
				var myBitmapData:BitmapData = new BitmapData(sliceRect[i].width, sliceRect[i].height);
				var myMatrix:Matrix = new Matrix();
				myMatrix.translate( -sliceRect[i].x, -sliceRect[i].y);
				myBitmapData.draw(photo, myMatrix);
				var myBitmap:Bitmap = new Bitmap(myBitmapData, "auto", true);
				myBitmap.x = sliceRect[i].x;
				myBitmap.y = sliceRect[i].y;
				result[i] = myBitmap;
			}
			return result;
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
			
			//変形＆重ね合わせた画像を作って、ステージ上にaddChildする
			var interRectPhoto:Rectangle = getInterpolateRect(currentImgObj.photoRect, nextImgObj.photoRect, ratio);
			//９分割画像ごとにratioに応じた画像を生成して、ステージに置く
			for (var i:int = 0; i < 9; i++) {
				//分割画像毎に画像を取得し、画面の中央に置く
				var shape:Shape = getMorphSliceImg(currentImgObj, nextImgObj, i, ratio);
				shape.x += (stage.stageWidth - interRectPhoto.width) / 2;
				shape.y += (stage.stageHeight - interRectPhoto.height) / 2;
				this.addChild(shape);
			}
			
			//主に見えているほうの写真のクレジットを取得。
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
		
		private function getInterpolateRect(currentRect:Rectangle, nextRect:Rectangle, ratio:Number):Rectangle {
			//二つのRectangleをpercentに応じた割合で合成する。
			var result:Rectangle = new Rectangle();
			result.x = currentRect.x * (1 - ratio) + nextRect.x * ratio;
			result.y = currentRect.y * (1 - ratio) + nextRect.y * ratio;
			result.width = currentRect.width * (1 - ratio) + nextRect.width * ratio;
			result.height = currentRect.height * (1 - ratio) + nextRect.height * ratio;
			return result;
		}
		
		private function getMorphSliceImg(currentImgObj:Object, nextImgObj:Object, num:int, ratio:Number):Shape {
			//写真を変形rectに応じて変形し、rationに応じて透明度を変えて、徐々に変形しているようにみせる
			
			//ratioに応じた矩形（Rectangle）を求める
			var interRectSlice:Rectangle = getInterpolateRect(currentImgObj.sliceRect[num], nextImgObj.sliceRect[num], ratio);
			
			//rectで指定したBitmapDataをつくる
			var myBitmapData:BitmapData = new BitmapData(interRectSlice.width, interRectSlice.height);
			
			//背景の画像をrectに応じて変形しBitmapDataにdraw
			var myMatrix:Matrix = new Matrix();
			myMatrix.scale(interRectSlice.width / currentImgObj.sliceRect[num].width, interRectSlice.height / currentImgObj.sliceRect[num].height);
			myBitmapData.draw(currentImgObj.sliceBitmap[num], myMatrix);
			
			//手前用の画像をrectに応じて変形する
			myMatrix = new Matrix();
			myMatrix.scale(interRectSlice.width / nextImgObj.sliceRect[num].width, interRectSlice.height / nextImgObj.sliceRect[num].height);
			//手前の画像はratioに応じて半透明にして、背景の画像に重ね合わせる
			var myColorTransform:ColorTransform = new ColorTransform(1, 1, 1, ratio);
			myBitmapData.draw(nextImgObj.sliceBitmap[num], myMatrix, myColorTransform);
			
			//shapeに書き込み、返す
			var shape:Shape = new Shape();
			//コメントアウトをはずすと、変形する様子がわかりやすい
			//shape.graphics.lineStyle(1,0x0000FF);
			shape.graphics.beginBitmapFill(myBitmapData, null, false, true);
			shape.graphics.drawRect(0, 0, interRectSlice.width + 1, interRectSlice.height + 1);
			shape.x = interRectSlice.x;
			shape.y = interRectSlice.y;
			return shape;
		}
	}
}

//書籍には説明はない。face.comへの対応時に追加した、おまけ。
//Objectの中身をtraceで確認しやすくするためのクラス。
//Dump.object(target)とやると、targetの中身を確認できる。
//138行目が使用例。
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

