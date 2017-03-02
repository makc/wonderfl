/*
Yahoo!Pipes経由でFlickrの画像を検索して表示します。
下のコードの検索キーワードを変更すれば、表示する写真が変わります。
日本語での検索にも対応しました。

履歴
2008/12/27 escape()をflash.utils.escapeMultiByte()に変更
2008/12/24 22:14 Flickrへのリンク追加
2008/12/24 17:28 URLのqueryにescape()を追加
*/

package {
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.escapeMultiByte;

 	[SWF(width="464", height="464",backgroundColor="#000000",frameRate="30")]  
 	
	public class flickr extends Sprite
	{
		private var query:String = "イチゴ";//検索キーワード
		private var numOfImage:uint = 36;
		private var URL:String = "http://pipes.yahooapis.com/pipes/pipe.run?_id=1FZD9tbQ3RGdxrAHbbsjiw&_render=rss&n=" + String(numOfImage) + "&q=" + escapeMultiByte(query);
		
		private var loader:URLLoader;
		private var imgWidth:uint = 77;
		private var imgHeight:uint = 77;
		private var imgOffset:uint = 2;
		private var xmlData:XML;
		private var media:Namespace = new Namespace("http://search.yahoo.com/mrss/");
		
		public function flickr()
		{
			var req:URLRequest = new URLRequest(URL);
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			req.method = "GET";
			req.url = URL;
			configureListeners(loader);
		    
		   trace("loader load:" + req.method + ";" +req.url);
			
			try {
				loader.load(req);
            } catch (error:Error) {
               trace("Unable to load requested document.");
            }
		}
		private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
        }

		private function completeHandler(event:Event):void {
            var loader:URLLoader = URLLoader(event.target);
           trace("completeHandler: " + loader.data);
           xmlData = new XML(loader.data);
            
			var count:uint = 0;
			default xml namespace = media;

			for each(var element:Object in xmlData.channel.item){
	        	var imgURL:String = element.media::group.media::thumbnail.@url;
	        	var imgReq:URLRequest = new URLRequest(imgURL);
	        	var img:Loader = new Loader();
	        	img.load(imgReq);
	        	img.x = imgWidth * (count % 6) + imgOffset;
	        	img.y = imgHeight * Math.round(count / 6 -0.5) + imgOffset;
				addChild( img );
				img.addEventListener(MouseEvent.CLICK,mouseclickHandler);
				count++;
            }
    
        }
        private function mouseclickHandler(event:MouseEvent):void{
			var element:Object = xmlData.channel.item[getChildIndex(event.target as Loader)];
			var url_send:URLRequest = new URLRequest( element.link );
			navigateToURL(url_send);
        }
    }
}
