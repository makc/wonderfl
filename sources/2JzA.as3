package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	[SWF(width="465", height="465", backgroundColor= 0xffffff, frameRate="60")]
	public class SporeLane
	extends Sprite
	{
		// our search types:
		public var mQueries:Array = new Array("FEATURED", "RANDOM", "TOP_RATED", "TOP_RATED_NEW", "NEWEST", "CUTE_AND_CREEPY", "MAXIS_MADE");
		// a loader for the query
		public var mLoader:URLLoader;
		
		public var mServerString:String = "http://www.spore.com";
		public var mCurrentQueryString:String = "";
		public var mCurrentQuery:Number = Math.floor(Math.random()*mQueries.length);
		public var mStartIndex:Number = 0;
		public var mCount:Number = 50;
		
		private var lane:Lane;
		public function SporeLane():void 
		{
			lane= new Lane();
			addChild(lane);
			lane.laneHeight = 550;
			lane.y = -20;

			
			// initiate the query
			mLoader = new URLLoader();
			mLoader.addEventListener(Event.COMPLETE, GotData);
			GetSpecialFeed(mQueries[mCurrentQuery], mStartIndex, mCount); 
		}
		public function GetSpecialFeed(feed:String, startIndex:Number, numAssets:Number):void
		{
			var queryString:String = mServerString + "/rest/assets/search/" + feed + "/" + startIndex + "/" + numAssets;
			mLoader.load(new URLRequest(queryString));			
		}
		public function GotData(e:Event):void
		{
			var dataXML:XML = new XML(e.target.data);
			
			// Parse the XML
			namespace atomenv = "http://www.w3.org/2005/Atom";
			use namespace atomenv;
			
			var counter:Number = 0;
//			trace(dataXML);
			for each (var asset:XML in dataXML..asset)
			{
				var id:String = asset..id.toString();
				GetSmallPNG(id, counter);
				counter++;
				if(counter == mCount)
				{
					break;
				}
			}
//			mStatusText.text = "Loaded query: " + mCurrentQueryString;
			
		}		
		
		public function GetSmallPNG(assetId:String, counter:Number):void
		{
			var subId1:String = assetId.substr(0,3);
			var subId2:String = assetId.substr(3,3);
			var subId3:String = assetId.substr(6,3);
			var smallPNGURL:String = "http://www.spore.com/static/thumb/" + subId1 + "/" + subId2 + "/" + subId3 + "/" + assetId + ".png"
//			var smallPNGURL:String = "http://www.spore.com/static/image/" + subId1 + "/" + subId2 + "/" + subId3 + "/" + assetId + "_lrg.png"
			
			lane.addImg(smallPNGURL);
		}
	}
}
	
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite
import flash.events.MouseEvent;
import caurina.transitions.Tweener;
import flash.net.URLRequest;
import flash.events.Event;
import flash.system.LoaderContext;
import flash.geom.Rectangle;
import flash.filters.BlurFilter;

class Lane
extends Sprite 
{
	private var imgContainer:Sprite = new Sprite();
	public var laneWidth:Number = 465;
	public var laneHeight:Number = 465;
	
	

	public function Lane():void 
	{		
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	private function init(e:Event):void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		addChild(imgContainer);		
		stage.addEventListener(Event.ENTER_FRAME, setBlurs);
	}
	public function addImg(url:String):void 
	{
		var cell:ImgCell = new ImgCell(url);
		cell.x = Math.random() * laneWidth;
		imgContainer.addChild(cell);
		cell.addEventListener("loaded", cellLoadCompleteHandler, false, 0, true);
		setDepth(cell);
	}
	private function cellLoadCompleteHandler(e:Event):void 
	{
		var cell:ImgCell = e.target as ImgCell;
		cell.removeEventListener("loaded", cellLoadCompleteHandler);
		cell.addEventListener("appeared", cellAppearCompleteHandler, false, 0, true);
	}
	private function setDepth(cell:ImgCell):void 
	{
		var scale:Number = Math.random() + 0.01;
		cell.scaleX = cell.scaleY = scale * 1.4 + 0.2;
		cell.y =  laneHeight * scale;
		sortDepth();
	}
	private function sortDepth():void 
	{
		var num:uint = imgContainer.numChildren;
		var cells:Array = new Array();
		while (num--) cells.unshift(imgContainer.getChildAt(num));
		cells.sortOn("y", Array.NUMERIC);	
		num = cells.length;
		while (num--) imgContainer.setChildIndex(cells[num], 0);
	}
	private function cellAppearCompleteHandler(e:Event):void 
	{
		var cell:ImgCell = e.target as ImgCell;
		cell.removeEventListener("appeared", cellLoadCompleteHandler);
		cell.addEventListener("out", cellOutHandler);
	}
	private function cellOutHandler(e:Event):void 
	{
		var cell:ImgCell = e.target as ImgCell;
		cell.x = laneWidth + cell.width;
		setDepth(cell);
	}
	private function setBlurs(e:Event):void 
	{
		var num:uint = imgContainer.numChildren;
		while (num--) {
			var cell:ImgCell = imgContainer.getChildAt(num) as ImgCell;
			var mx:Number = Math.abs(cell.mouseX) / cell.width;
			var my:Number = Math.abs(cell.mouseY) / cell.height;
			
			var r:Number = Math.sqrt(mx * mx + my * my);
			if (r < 1) r *=r;
			
			var b:Number = Math.min(100 * cell.scaleX, r *  6 * cell.scaleX);
			
			cell.filters = 
			[
				new BlurFilter(b,b,1)
			];
		}
	}
}


class ImgCell
extends Sprite
{
	private var img:Loader;	
	private var maskSp:Sprite = new Sprite();
	private var hole:Sprite = new Sprite();
	
	public function ImgCell(url:String):void 
	{
//		visible = false;
		mouseChildren = true;
		//loader
		img = new Loader();
		img.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
		img.load(new URLRequest(url));
	}
	private function loadCompleteHandler(e:Event):void 
	{
		img.x = -img.width / 2
		maskSp.graphics.beginFill(0);
		maskSp.graphics.drawEllipse(-img.width/2, -img.height/8, img.width, img.height / 4);
		maskSp.graphics.drawRect(-img.width/2, -img.height, img.width, img.height);
		
		hole.graphics.beginFill(0x333333);
		hole.graphics.drawEllipse(-img.width/2, -img.height/8, img.width, img.height / 4);
		hole.y = maskSp.y = 0//-hole.height/2;
		
		img.mask = maskSp;
		
		addChild(hole);
		addChild(img);
		addChild(maskSp);
		//
		visible = true;
		dispatchEvent(new Event("loaded"));
		
		hole.scaleX = hole.scaleY = 0.1;
		Tweener.addTween(hole, {
			scaleX: 1,
			scaleY: 1,
			time: 0.5,
			transition: "easeOutQuint"
		});
		
		img.y = img.height*0.5;
		Tweener.addTween(img, {
			y: -img.height,
			time: 0.2 + Math.random() * 0.5,
			delay:0.1,
			transition: "easeOutCubic",
			onComplete: appearCompleteHandler
		});
	}
	private function appearCompleteHandler():void 
	{
		Tweener.addTween(hole, {
			scaleX: 0.1,
			scaleY: 0.1,
			time: 0.2,
			transition: "easeInQuint",
			onComplete: holeCompleteHandler
		});
	}
	private function holeCompleteHandler():void 
	{
		removeChild(hole);
		removeChild(maskSp);
		img.mask = null;
		hole = maskSp = null;
		dispatchEvent(new Event("appeared"));
		
		addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
	}
	private function enterFrameHandler(e:Event):void 
	{
		x -= width * 0.01;// (Math.random() * 1 + 1) * 0.01;
		if (x + width / 2 < 0) dispatchEvent(new Event("out"));
	}
}