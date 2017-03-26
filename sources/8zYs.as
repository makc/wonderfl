package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.ui.Mouse;
	import caurina.transitions.Tweener;
	import flash.display.GradientType;
	import flash.media.Sound;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.filters.DropShadowFilter;
	import flash.system.Security;


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
		private var focus:Sprite;
		private var shutter:Sprite;
		private var bg:Sprite;
/*
camera sound by SFX Bible on soundSnap
http://www.soundsnap.com/node/41248
*/
		private var shutterSndURL:String = "http://www.t-p.jp/flash/FOLEY CAMERA TAKE PICTURE 01.mp3";
		private var shutterSnd:Sound;
		
		public function SporeLane():void 
		{
			Security.loadPolicyFile("http://www.t-p.jp/crossdomain.xml");
			//lane
			lane= new Lane();
			lane.laneHeight = 550;
			lane.y = -20;

			//focus
			focus = new Sprite();
			var fx:Number = 48;
			var fy:Number = 36;
			var fr:Number = 6;
			focus.graphics.lineStyle(1.5,0,0.5);
            focus.graphics.moveTo(-fx-fr, -fy);
            focus.graphics.curveTo(-fx-fr, -fy-fr, -fx, -fy-fr);
            focus.graphics.moveTo(fx+fr, -fy);
            focus.graphics.curveTo(fx+fr, -fy-fr, fx, -fy-fr);
            focus.graphics.moveTo(-fx-fr, fy);
            focus.graphics.curveTo(-fx-fr, fy+fr, -fx, fy+fr);
            focus.graphics.moveTo(fx+fr, fy);
            focus.graphics.curveTo(fx + fr, fy + fr, fx, fy + fr);
            focus.graphics.moveTo(-fr, 0);
            focus.graphics.lineTo(fr, 0);
            focus.graphics.moveTo(0, -fr);
            focus.graphics.lineTo(0, fr);
			focus.filters = [
				new GlowFilter(0xFFFFFF, 0.7,2,2,6)
			];
			Mouse.hide();
			
			//shutter
			shutter = new Sprite();
			shutter.graphics.beginFill(0);
			shutter.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			shutter.visible = false;
			
			shutterSnd = new Sound(new URLRequest(shutterSndURL));
			//bg
			bg = new Sprite();
			var mtr:Matrix = new Matrix();
			mtr.createGradientBox(stage.stageWidth, stage.stageHeight, Math.PI/2);
			bg.graphics.beginGradientFill(
				GradientType.LINEAR, 
				[0xEEEEEE, 0xDDDDCC], 
				[1,1],
				[0, 255],
				mtr
			);
			bg.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			//add
			addChild(bg);
			addChild(lane);
			addChild(focus);
			addChild(shutter);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			//PreLoad mochi
			//achaSpore
			lane.addImg("http://www.t-p.jp/flash/achaSpore128.png");
			//achamo
			lane.addImg("http://www.t-p.jp/flash/Achamo128.png");
			//mochi
			lane.addImg("http://www.t-p.jp/flash/mochi128.png");

			
			// initiate the query
			mLoader = new URLLoader();
			mLoader.addEventListener(Event.COMPLETE, GotData);
			GetSpecialFeed(mQueries[mCurrentQuery], mStartIndex, mCount); 
		}
		private function mouseMoveHandler(e:MouseEvent):void 
		{
			focus.x = mouseX;
			focus.y = mouseY;
		}
		private function mouseDownHandler(e:MouseEvent):void 
		{
			//film
			var bd:BitmapData = new BitmapData(120,90);
			bd.draw(bg, new Matrix(1, 0, 0, 1, -mouseX + 60, -mouseY + 45));
			bd.draw(lane, new Matrix(1, 0, 0, 1, -mouseX + 60, -mouseY + 45));
			
			var film:Film = new Film(bd);
			film.addEventListener(Event.ENTER_FRAME, filmThrow,false,0,true);
			film.x = mouseX;
			film.y = mouseY;
			addChild(film);
			
			//shutter
			shutter.y = -shutter.height;
			shutter.visible = true;
			setChildIndex(shutter, numChildren - 1);
			
			shutterSnd.play();
			Tweener.addTween(shutter, {
				y:0,
				time:0.03,
				transition: "linear",
				onComplete: function():void {
					Tweener.addTween(shutter, {
						y:-shutter.height,
						time:0.03,
						transition: "linear",
						onComplete: function():void {
							shutter.visible = false
						}
					});
				}
			});
			
		}
		private function filmThrow(e:Event):void 
		{
			var film:Film = e.target as Film;
			film.x += film.moveX;
			film.y += film.moveY;
			
			film.moveY += 0.2;
			if (film.y - film.height > stage.stageHeight) 
			{
				removeChild(film);
				film.removeEventListener(Event.ENTER_FRAME, filmThrow);
				film = null;
			}
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
				GetSmallPNG(id);
				counter++;
				if(counter == mCount)
				{
					break;
				}
			}
//			mStatusText.text = "Loaded query: " + mCurrentQueryString;
			
		}		
		
		public function GetSmallPNG(assetId:String):void
		{
			var subId1:String = assetId.substr(0,3);
			var subId2:String = assetId.substr(3,3);
			var subId3:String = assetId.substr(6,3);
			var smallPNGURL:String = "http://www.spore.com/static/thumb/" + subId1 + "/" + subId2 + "/" + subId3 + "/" + assetId + ".png"
			//var smallPNGURL:String = "http://www.spore.com/static/image/" + subId1 + "/" + subId2 + "/" + subId3 + "/" + assetId + "_lrg.png"
			
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
			var my:Number = Math.abs(cell.mouseY+cell.height/2) / cell.height;
			
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

import flash.display.BitmapData
import flash.display.Bitmap;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
class Film
extends Sprite
{
	public var moveX:Number;
	public var moveY:Number;
	public function Film(bd:BitmapData):void 
	{
		var bmp:Bitmap = new Bitmap(bd);
		graphics.beginFill(0xFFFFFF);
		graphics.drawRect( -70, -70, 140, 140);
		bmp.x = -60;
		bmp.y = -45;
		rotation = Math.random()*30-15;
		scaleX = scaleY = Math.random()*1+0.5;
		addChild(bmp);
		filters = [
			new DropShadowFilter(width * 0.05, 45, 0, 0.30, width * 0.15, height * 0.15), 
			new GlowFilter(0xCCCCCC, 1.0, width * 0.04, height * 0.04)
		];		
		
		moveX = Math.random() * 4 -2;
		moveY = -(Math.random() * 4 + 5);
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
		
		hole.graphics.beginFill(0x110909);
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