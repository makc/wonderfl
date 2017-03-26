/*
Yahoo!Pipes経由でFlickrの画像を検索して表示します。
下のコードの検索キーワードを変更すれば、表示する写真が変わります。
日本語での検索にも対応しました。

履歴
2009/01/06　タイトル表示など大幅修正
2008/12/27 escape()をflash.utils.escapeMultiByte()に変更
2008/12/24 22:14 Flickrへのリンク追加
2008/12/24 17:28 URLのqueryにescape()を追加
*/
package {
	import caurina.transitions.*;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.escapeMultiByte;

 	[SWF(width="464", height="464",backgroundColor="#000000",frameRate="30")]  
 	
	public class FlickrPipes extends Sprite
	{
//		private var query:String = "strawberry red";//検索キーワード
		private var query:String = "イチゴ";//検索キーワード
        private var numOfImage:uint = 36;
        private var URL:String = "http://pipes.yahooapis.com/pipes/pipe.run?_id=1FZD9tbQ3RGdxrAHbbsjiw&_render=rss&n=" + String(numOfImage) + "&q=" + flash.utils.escapeMultiByte(query);
		
		private var logText:TextField= new TextField();
		private var labelText:TextField= new TextField();
		private var data:XML;
		private var loader:URLLoader;
		private var imgWidth:uint = 77;
		private var imgHeight:uint = 77;
		private var imgOffset:uint = 2;
		
		private var xmlData:XML;
		
		private var media:Namespace = new Namespace("http://search.yahoo.com/mrss/");
		
		public function FlickrPipes()
		{
			var format:TextFormat = new TextFormat();
			format.color = 0xFFFFFF;
			format.size = 9;
            logText.defaultTextFormat = format;
            logText.multiline = true;
            logText.wordWrap = true;
            logText.autoSize = flash.text.TextFieldAutoSize.LEFT;
            logText.width = stage.stageWidth -20;
            logText.height = stage.stageHeight -20;
            addChild(logText);
            
			var labelFormat:TextFormat = new TextFormat();
			labelFormat.color = 0x000000;
			labelFormat.size = 12;
            labelText.autoSize = flash.text.TextFieldAutoSize.LEFT;
            labelText.defaultTextFormat = labelFormat;
            labelText.background = true;
            labelText.backgroundColor = 0xfefefe;
            labelText.text ="ラベル";
            labelText.x = -100;
            labelText.y = -100;
            labelText.selectable = false;

			var req:URLRequest = new URLRequest(URL);
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			req.method = "GET";
		    req.url = URL;
			configureListeners(loader);
		    
		    log("loader load:" + req.method + ";" +req.url);
			
			try {
				loader.load(req);
            } catch (error:Error) {
                log("Unable to load requested document.");
            }
		}
		private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }

		private function completeHandler(event:Event):void {
            var loader:URLLoader = URLLoader(event.target);
            log("completeHandler: " + loader.data);
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
				img.addEventListener(MouseEvent.MOUSE_OVER,mouseoverHandler);
				img.addEventListener(MouseEvent.MOUSE_OUT,mouseoutHandler);
				img.addEventListener(MouseEvent.CLICK,mouseclickHandler);
				count++;
            }
            
            addChild(labelText);
    
//            var vars:URLVariables = new URLVariables(loader.data);
//            log("The answer is " + vars.answer);
        }
        private function mouseclickHandler(event:MouseEvent):void{
        	log("mouseclickHandler");
			var element:Object = xmlData.channel.item[getChildIndex(event.target as Loader)-1];
			
			var url_send:URLRequest = new URLRequest( element.link );
			navigateToURL(url_send);
        }
        private function mouseoverHandler(event:MouseEvent):void{
			labelText.visible = true;
			
			var element:Object = xmlData.channel.item[getChildIndex(event.target as Loader)-1];
			
            labelText.text = element.title;
            var posX:Number = event.stageX - (labelText.width / 2);

            if(posX < 0){
            	posX = 0;
            }
            Tweener.addTween(labelText, {
            	alpha:1,
            	x:posX,
            	y:event.stageY+10,
            	time:1});
            log(labelText.width.toString());
        }
        private function mouseoutHandler(event:MouseEvent):void{
			labelText.visible = false;
        }

        private function openHandler(event:Event):void {
            log("openHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void {
            log("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            log("securityErrorHandler: " + event);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
            log("httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            log("ioErrorHandler: " + event);
        }

		private function log(msg:String):void{
            logText.text = msg;
        }
	}
}
