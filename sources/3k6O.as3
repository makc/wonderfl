package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.display.Sprite;
	import flash.text.TextFormat;

    [SWF(width = 465, height = 465, backgroundColor = 0xFFFFFF,frameRate=60)]
	/**
	 * ...
	 * @author F
	 */
	public class Main extends MovieClip
	{
		private var digitalbookMC:DigitalBook;
		private var searchTxt:TextField;
		private var searchBtn:Sprite;
		private var pageNoTxt:TextField;
		private var pageSelectBtn:Sprite;
		
		/*------------------------------------------------
		   コンストラクタ
		 ------------------------------------------------*/
		public function Main():void
		{
			
			searchTxt = addInputText("bird");
			searchTxt.x = 10;
			searchTxt.y = 5;
			addChild(searchTxt);
			
			searchBtn = addBtn("SEARCH");
			searchBtn.x = 120;
			searchBtn.y = 5;
			addChild(searchBtn);
			searchBtn.addEventListener(MouseEvent.CLICK, onSearchClick);
			
			pageNoTxt = addInputText("10");
			addChild(pageNoTxt);
			pageNoTxt.x = 210;
			pageNoTxt.y =5;
			searchBtn = addBtn("PageSelect");
			searchBtn.x = 320;
			searchBtn.y = 5;
			addChild(searchBtn);
			searchBtn.addEventListener(MouseEvent.CLICK, onClick);
			
			contentsSet();
		}
		
		
		/*------------------------------------------------
		   イベント
		 ------------------------------------------------*/
		
		private function onSearchClick(e:MouseEvent):void 
		{
			imgLoad();
		}
		
		
		private function onClick(event:MouseEvent):void
		{
			digitalbookMC.pageSelect(uint(pageNoTxt.text));
		}
		
		
		//xmlロード完了
		private function onXmlLoadComplete(event:Event):void {
			var loadXml:XML = new XML(event.currentTarget.data);
			var dataXml:XML =<digitalbook><setting pagewidth="230" pageheight="230" /><pages></pages></digitalbook>;
			var num:uint = loadXml.photos.photo.length();
			for (var i:uint = 0; i < num; i++ ) {
				var targetXml:XML = loadXml.photos.photo[i];
				var addXml:XML = <page />;
				addXml.@file="http://farm" + targetXml.@farm + ".static.flickr.com/" + targetXml.@server + "/" + targetXml.@id + "_" + targetXml.@secret + "_m.jpg";
				dataXml.pages[0].appendChild(addXml);
			}
			event.currentTarget.removeEventListener(Event.COMPLETE, onXmlLoadComplete);
			
			digitalbookMC = new DigitalBook();
			digitalbookMC.x = 117;
			digitalbookMC.y = 50;
			addChild(digitalbookMC);
			
			digitalbookMC.contentsSet(dataXml);
		}
		
		/*------------------------------------------------
		   メソッド
		 ------------------------------------------------*/
		public function contentsSet():void
		{
			visible = true;
			imgLoad();
		}
		
		private function imgLoad():void {
			if (digitalbookMC) {
				removeChild(digitalbookMC);
				digitalbookMC = null;
			}
			var url:String = "http://api.flickr.com/services/rest/?api_key=a13b8b1289e5dc6fc0121c0ac1500ba6&method=flickr.photos.search&tags="+searchTxt.text;
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.load(new URLRequest(url));
			xmlLoader.addEventListener(Event.COMPLETE, onXmlLoadComplete);
		}
		
		private function addInputText(str:String):TextField {
			var tf:TextField = new TextField();
			tf.border = true;
			tf.text = str;
			tf.type = TextFieldType.INPUT;
			tf.textColor = 0x000000;
			tf.height = 20;
			return tf;
		}
		
		private function addBtn(str:String):Sprite {
			var btn:Sprite = new Sprite();
			var tf:TextField = new TextField();
			var tfm:TextFormat = new TextFormat("Arial");
			tf.textColor = 0xFFFFFF;
			tf.background = true;
			tf.backgroundColor = 0x000000;
			tf.text = str;
			tf.height = 22;
			tf.autoSize = "left";
			tf.setTextFormat(tfm);
			btn.addChild(tf);
			btn.buttonMode = true;
			btn.mouseChildren = false;
			return btn;
		}
	}
}

import flash.display.MovieClip;
import flash.events.Event;
import flash.utils.Timer;
import flash.events.TimerEvent;

/**
 * ...
 * @author F
 */
class DigitalBook extends MovieClip
{
	public var pageArray:Array = new Array();
	private var pageListNum:uint;
	private var loadedPageNum:uint;
	public var book_mc:MovieClip;
	
	public var pageWidth:uint;
	public var pageHeight:uint;
	
	private var autoTargetPageNo:uint;
	private var autoFlipTimer:Timer;
	
	public var selectedOpenPageNo:uint;
	public var bookState:String = "wait";
	
	private const LOAD_ALLCOMPLETE:String = "loadAllComplete";
	
	/*------------------------------------------------
	   コンストラクタ
	 ------------------------------------------------*/
	public function DigitalBook():void
	{
		name = "digitalBook_mc";
	}
	
	/*------------------------------------------------
	   イベント
	 ------------------------------------------------*/
	
	
	private function onAutoFlipTimer(event:TimerEvent):void
	{
		pageAutoOpen();
	}
	
	/*------------------------------------------------
	   メソッド
	 ------------------------------------------------*/
	
	public function contentsSet(xml:XML):void
	{
		book_mc = new MovieClip();
		addChild(book_mc);
		pageWidth = uint(xml.setting.@pagewidth);
		pageHeight = uint(xml.setting.@pageheight);
		book_mc.x = uint(pageWidth / 2);
		
		pageListNum = xml.pages.page.length();
		for (var i:uint = 0; i < pageListNum; i++)
		{
			pageArray[i] = new Page(i + 1, xml.pages.page[i].@file, this);
			book_mc.addChildAt(pageArray[i], 0);
		}
		pageInit();
		pageLoad();
	}
	
	/*===内部操作用===================================*/
	private function pageInit():void
	{
		for (var i:uint = 0; i < pageListNum; i++)
		{
			pageArray[i].init();
		}
	}
	
	public function pageLoad():void
	{
		if (loadedPageNum < pageListNum)
		{
			pageArray[loadedPageNum].pageLoad();
			loadedPageNum++;
		}
		else
		{
			dispatchEvent(new Event(LOAD_ALLCOMPLETE));
		}
	}
	
	public function pageCurl(num:uint, rightFlag:Boolean):void
	{
		var targetPageNo:uint;
		if (rightFlag)
		{
			targetPageNo = num + 1;
		}
		else
		{
			targetPageNo = num - 1;
		}
		if (pageArray[targetPageNo - 1])
		{
			pageArray[targetPageNo - 1].pageCurl();
		}
	}
	
	/*===外部操作用===================================*/
	public function pageSelect(num:uint):void
	{
		if (bookState != "autoOpen")
		{
			autoTargetPageNo = num;
			pageAutoOpen();
			autoFlipTimer = new Timer(150);
			autoFlipTimer.addEventListener(TimerEvent.TIMER, onAutoFlipTimer);
			autoFlipTimer.start();
			mouseChildren = false;
		}
	}
	
	private function pageAutoOpen():void
	{
		bookState = "autoOpen";
		var targetNo:uint;
		if (selectedOpenPageNo == (Math.floor(autoTargetPageNo / 2) + 0.5) * 2)
		{
			pageAutoStop();
		}
		else
		{
			if (autoTargetPageNo > selectedOpenPageNo)
			{
				targetNo = selectedOpenPageNo + 1;
			}
			else if (autoTargetPageNo < selectedOpenPageNo - 1)
			{
				targetNo = selectedOpenPageNo - 2;
			}
			if (pageArray[targetNo - 1])
			{
				pageArray[targetNo - 1].pageCurl("auto");
				pageArray[targetNo - 1].pageOpen();
			}
			else
			{
				pageAutoStop();
			}
		}
	}
	
	private function pageAutoStop():void
	{
		if (autoFlipTimer)
		{
			autoFlipTimer.reset();
			autoFlipTimer.removeEventListener(TimerEvent.TIMER, onAutoFlipTimer);
			autoFlipTimer = null;
		}
		mouseChildren = true;
		bookState = "wait";
	}
	
	public function pageNoGet():uint
	{
		var num:uint = selectedOpenPageNo;
		if (selectedOpenPageNo > pageListNum)
		{
			num = pageListNum;
		}
		return num;
	}
	
	public function allPageNumGet():uint
	{
		return pageListNum;
	}
}

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.system.LoaderContext;


/**
 * ...
 * @author F
 */
class Page extends Sprite
{
	private var filePath:String;
	private var imgLoader:Loader = new Loader();
	public var ID:uint;
	public var pageRightFlag:Boolean;
	
	private var state:String = "";
	private var movePerMax:Number;
	private var baseMouseY:int;
	private var baseMouseYFlag:Boolean;
	private var vectorX:int = 1;
	public var hideFlag:Boolean;
	
	private var containerMC:Sprite;
	private var pageGraMC:Sprite;
	public var pageMaskMC:Sprite;
	public var pageMaskGra:Shape;
	private var mouseAreaMC:Sprite;
	private var shadowMC:Shape;
	private var shadowMaskMC:Shape
	private var digitalbookMC:DigitalBook;
	private var maskedPageMC:Page;
	private var sidePageMC:Page;
	private var backPageMC:Page;
	private var tempPageAreaMC:Shape;
	
	public static const PAGE_OPEN:String = "pageOpen";
	public static const PAGE_OPENCOMPLETE:String = "pageOpenComplete";
	public static const PAGE_CLOSE:String = "pageClose";
	public static const PAGE_CLOSECOMPLETE:String = "pageCloseComplete";
	
	/*------------------------------------------------
	   コンストラクタ
	 ------------------------------------------------*/
	public function Page(num:uint, str:String, digitalBookContainerMC:DigitalBook):void
	{
		ID = num;
		filePath = str;
		digitalbookMC = digitalBookContainerMC;
		
		containerMC = new Sprite();
		containerMC.y = digitalbookMC.pageHeight;
		addChild(containerMC);
		
		pageGraMC = new Sprite();
		pageGraMC.y = -digitalbookMC.pageHeight;
		containerMC.addChild(pageGraMC);
		
		pageGraMC.addChild(imgLoader);
		
		if (ID % 2 == 0)
		{
			pageRightFlag = false;
			vectorX = -1;
		}
		else
		{
			pageRightFlag = true;
		}
		
		if (ID > 1)
		{
			visible = false;
			mouseSet(false);
		}
		tempPageSet();
		maskSet();
		shadowSet();
		mouseAreaSet();
	}
	
	/*------------------------------------------------
	   イベント
	 ------------------------------------------------*/
	private function imgLoadComplete(event:Event):void
	{
		var smoothingCheck:Boolean = true;
		if (smoothingCheck)
		{
			var loadedImg:Bitmap = Bitmap(imgLoader.content);
			loadedImg.smoothing = true;
			loadedImg.scaleX = loadedImg.scaleY = Math.min(digitalbookMC.pageWidth / loadedImg.width, digitalbookMC.pageHeight / loadedImg.height);
			imgLoader.unload();
			pageGraMC.addChild(loadedImg);
			pageGraMC.removeChild(imgLoader);
			
			loadedImg.x =  Math.round((digitalbookMC.pageWidth-loadedImg.width) / 2);
			if (!pageRightFlag)
			{
				loadedImg.x -= digitalbookMC.pageWidth;
			}
			loadedImg.y = Math.round((digitalbookMC.pageHeight-loadedImg.height) / 2);
		}
		else
		{
			imgLoader.x =  Math.round((digitalbookMC.pageWidth-imgLoader.width) / 2);
			if (!pageRightFlag)
			{
				imgLoader.x -= digitalbookMC.pageWidth;
			}
			imgLoader.y = Math.round((digitalbookMC.pageHeight-imgLoader.height)/2);
		}
		
		digitalbookMC.pageLoad();
	}
	
	//マウス
	private function onMouseAreaOver(event:MouseEvent):void
	{
		digitalbookMC.pageCurl(ID, pageRightFlag);
	}
	
	private function onStageMouseDown(event:MouseEvent):void
	{
		pageFlip();
	}
	
	private function onStageMouseUp(event:MouseEvent):void
	{
		if (vectorX * parent.mouseX > -digitalbookMC.pageWidth)
		{
			pageOpen();
		}
		else
		{
			pageFlat();
		}
	}
	
	//マウスチェック
	private function onMouseCheckEnter(event:Event):void
	{
		var movePer:Number;
		var mouseDistanceX:Number = digitalbookMC.pageWidth + (vectorX * parent.mouseX);
		movePer = mouseDistanceX / digitalbookMC.pageWidth / 2;
		if (movePer > movePerMax || movePer < 0 || parent.mouseY < 0 || parent.mouseY > digitalbookMC.pageHeight)
		{
			pageFlat();
		}
		else if (state == "curl")
		{
			if (mouseY > digitalbookMC.pageHeight * 0.2 && mouseY < digitalbookMC.pageHeight * 0.8)
			{
				state = "wait";
			}
		}
		else if (state == "wait")
		{
			if (mouseY < digitalbookMC.pageHeight * 0.2 || mouseY > digitalbookMC.pageHeight * 0.8)
			{
				pageCurl();
			}
		}
	}
	
	/*動き方*/
	private function onPageEnter(event:Event):void
	{
		var accelNum:Number = 0.15;
		var targetX:int;
		var targetY:Number = digitalbookMC.pageHeight;
		var targetBaseX:int;
		var adjustX:Number = 0;
		var r:Number = 0;
		var targetRotation:Number = 0;
		var rotationLimit:Number = 0;
		var mouseDistanceX:Number = digitalbookMC.pageWidth + (vectorX * parent.mouseX);
		var mouseDistanceY:int = baseMouseY - parent.mouseY;
		
		//移動の計算
		if (state == "open")
		{
			mouseDistanceX = digitalbookMC.pageWidth * 2;
			mouseDistanceY = baseMouseY;
		}
		else if (state == "flat" || state == "wait")
		{
			mouseDistanceX = 0;
			mouseDistanceY = baseMouseY;
			if (baseMouseY == 0)
			{
				targetY = 0;
			}
		}
		else
		{
			if (mouseDistanceX < 10)
			{
				mouseDistanceX = 10;
			}
			targetRotation = -vectorX * Math.atan(mouseDistanceY / mouseDistanceX) * 180 / Math.PI;
		}
		
		var centerX:Number = mouseDistanceX / 2;
		var centerY:Number = (baseMouseY + parent.mouseY) / 2;
		r = (90 - targetRotation) * Math.PI / 180;
		adjustX = (digitalbookMC.pageHeight - centerY) / Math.tan(r);
		targetBaseX = -vectorX * (digitalbookMC.pageWidth - centerX);
		targetX = targetBaseX - adjustX;
		
		//移動制限
		r = (vectorX * -targetRotation) * Math.PI / 180;
		if (vectorX * targetX > 0)
		{
			targetX = 0;
		}
		else if (vectorX * targetX < -digitalbookMC.pageWidth)
		{
			targetY = digitalbookMC.pageHeight - (digitalbookMC.pageWidth + vectorX * targetX) / Math.tan(r);
			if (targetY < 0)
			{
				targetY = 0;
			}
			else if (targetY > digitalbookMC.pageHeight)
			{
				targetY = digitalbookMC.pageHeight;
			}
			targetX = vectorX * -digitalbookMC.pageWidth;
		}
		
		//回転制限
		rotationLimit = (Math.atan(-targetX / targetY) * 180 / Math.PI);
		
		if (vectorX * targetRotation > vectorX * rotationLimit)
		{
			targetRotation = rotationLimit;
		}
		else if (vectorX * targetRotation > 90)
		{
			targetRotation = vectorX * 90;
		}
		
		//動作
		var moveDistance:Number = targetX - x;
		x += moveDistance * accelNum;
		containerMC.y += (targetY - containerMC.y) * accelNum;
		pageGraMC.x = x;
		pageGraMC.y = -containerMC.y;
		pageMaskMC.y = containerMC.y;
		//最終角度
		var resultRotation:Number = pageMaskMC.rotation + (targetRotation - pageMaskMC.rotation) * accelNum;
		rotationLimit = (Math.atan(-x / containerMC.y) * 180 / Math.PI);
		if (vectorX * resultRotation > vectorX * rotationLimit)
		{
			resultRotation = rotationLimit;
		}
		pageMaskMC.rotation = resultRotation;
		containerMC.rotation = resultRotation * 2;
		
		shadowMC.rotation = pageMaskMC.rotation;
		shadowMC.alpha = -vectorX * (targetBaseX / digitalbookMC.pageWidth);
		shadowMC.scaleX = (vectorX * targetBaseX / digitalbookMC.pageWidth) + 1.05;
		shadowMC.y = containerMC.y;
		shadowMaskMC.x = -x;
		
		maskedPageMC.pageMaskMC.x = x;
		maskedPageMC.pageMaskMC.y = containerMC.y;
		maskedPageMC.pageMaskMC.rotation = pageMaskMC.rotation;
		
		//動作完了
		if (Math.abs(moveDistance) < 0.5 && Math.abs(containerMC.rotation) < 0.5)
		{
			if (state == "open")
			{
				pageOpenComplete();
			}
			else if (state == "flat")
			{
				pageFlatComplete();
			}
		}
	}
	
	/*------------------------------------------------
	   メソッド
	 ------------------------------------------------*/
	//ページ巻く
	public function pageCurl(str:String = "manual"):void
	{
		state = "curl";
		movePerMax = 0;
		movePerMax = 0.1;
		baseMouseY = digitalbookMC.pageHeight / 2;
		x = vectorX * (-digitalbookMC.pageWidth);
		maskedPageMC.pageMaskGra.x = vectorX * maskedPageMC.pageMaskGra.width;
		
		pageMaskGra.x = 0;
		pageGraMC.x = maskedPageMC.pageMaskMC.x = x
		shadowMaskMC.x = -x;
		
		parent.setChildIndex(this, parent.numChildren - 1);
		
		var defaultRotation:Number = 0;
		var defaultY:Number = digitalbookMC.pageHeight;
		
		if (str == "auto")
		{
			defaultRotation = 30 - Math.floor(60 * Math.random());
			baseMouseY = digitalbookMC.pageHeight / 2 + 40 - Math.floor(80 * Math.random());
		}
		else
		{
			if (mouseY < digitalbookMC.pageHeight * 0.2)
			{
				baseMouseY = 0;
				defaultRotation = vectorX * 45;
				defaultY = 0;
			}
			else if (mouseY > digitalbookMC.pageHeight * 0.8)
			{
				defaultRotation = vectorX * -45;
				baseMouseY = digitalbookMC.pageHeight;
			}
			else
			{
				state = "wait";
			}
		}
		
		containerMC.y = defaultY;
		containerMC.rotation = defaultRotation * 2;
		pageGraMC.y = -containerMC.y;
		pageMaskMC.y = containerMC.y;
		pageMaskMC.rotation = defaultRotation;
		
		shadowMC.y = containerMC.y;
		shadowMC.rotation = defaultRotation;
		
		maskedPageMC.pageMaskMC.y = containerMC.y;
		maskedPageMC.pageMaskMC.rotation = pageMaskMC.rotation;
		
		if (state == "curl")
		{
			addEventListener(Event.ENTER_FRAME, onPageEnter);
		}
		if (digitalbookMC.bookState == "autoOpen")
		{
			pageEnterStart();
		}
		else
		{
			addEventListener(Event.ENTER_FRAME, onMouseCheckEnter);
		}
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
		
		mouseSet(false);
		maskedPageMC.mouseSet(false);
		if (backPageMC)
		{
			backPageMC.mouseSet(false);
		}
		if (sidePageMC)
		{
			sidePageMC.mouseSet(false);
		}
		shadowMC.visible = true;
		visibleSet(true);
	}
	
	//ページめくり
	private function pageFlip():void
	{
		state = "flip";
		movePerMax = 1;
		if (baseMouseY != digitalbookMC.pageHeight && baseMouseY != 0)
		{
			baseMouseY = mouseY;
		}
		pageEnterStart();
		stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		if (backPageMC)
		{
			backPageMC.hideFlag = true;
		}
	}
	
	//ページ開く
	public function pageOpen():void
	{
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		state = "open";
		movePerMax = 1;
		digitalbookMC.selectedOpenPageNo = (Math.floor(ID / 2) + 0.5) * 2;
		if (digitalbookMC.bookState != "autoOpen")
		{
			dispatchOpenEvent();
			if (sidePageMC)
			{
				sidePageMC.dispatchOpenEvent();
				sidePageMC.mouseSet(true);
			}
		}
		maskedPageMC.dispatchCloseEvent();
		if (backPageMC)
		{
			backPageMC.dispatchCloseEvent();
			backPageMC.mouseSet(false);
		}
		mouseSet(false);
	}
	
	private function pageOpenComplete():void
	{
		state = "openComplete";
		if (ID == digitalbookMC.selectedOpenPageNo || ID == digitalbookMC.selectedOpenPageNo - 1)
		{
			dispatchOpenCompleteEvent();
			if (sidePageMC)
			{
				sidePageMC.dispatchOpenCompleteEvent();
			}
		}
		maskedPageMC.dispatchCloseCompleteEvent();
		if (backPageMC)
		{
			backPageMC.dispatchCloseCompleteEvent();
		}
		removeEventListener(Event.ENTER_FRAME, onPageEnter);
		if (!hideFlag)
		{
			mouseSet(true);
		}
		hidePageVisibleSet(false);
		init();
	}
	
	//ページ開かない
	private function pageFlat():void
	{
		state = "flat";
		maskedPageMC.mouseSet(true);
		if (sidePageMC)
		{
			sidePageMC.dispatchOpenEvent();
		}
		if (backPageMC)
		{
			backPageMC.mouseSet(true);
			backPageMC.hideFlag = false;
		}
		movePerMax = 0;
		removeEventListener(Event.ENTER_FRAME, onMouseCheckEnter);
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
	}
	
	private function pageFlatComplete():void
	{
		visibleSet(false);
		maskedPageMC.pageMaskMC.x = 0;
		maskedPageMC.pageMaskGra.x = 0;
		maskedPageMC.pageMaskMC.y = digitalbookMC.pageHeight;
		maskedPageMC.pageMaskMC.rotation = 0;
		removeEventListener(Event.ENTER_FRAME, onPageEnter);
	}
	
	/*基本セット*/
	public function init():void
	{
		shadowMC.visible = false;
		x = pageMaskMC.x = pageGraMC.x = 0;
		containerMC.rotation = pageMaskMC.rotation = 0;
		maskedPageSet();
	}
	
	public function mouseSet(check:Boolean):void
	{
		if (state != "open")
		{
			mouseEnabled = mouseChildren = check;
		}
	}
	
	private function visibleSet(check:Boolean):void
	{
		visible = check;
		if (sidePageMC)
		{
			sidePageMC.visible = check;
		}
	}
	
	private function hidePageVisibleSet(check:Boolean):void
	{
		maskedPageMC.visible = check;
		if (backPageMC)
		{
			backPageMC.visible = check;
		}
	}
	
	private function pageEnterStart():void
	{
		removeEventListener(Event.ENTER_FRAME, onMouseCheckEnter);
		addEventListener(Event.ENTER_FRAME, onPageEnter);
	}
	
	private function tempPageSet():void
	{
		tempPageAreaMC = new Shape();
		tempPageAreaMC.graphics.beginFill(0xFFFFFF);
		tempPageAreaMC.graphics.lineStyle(1,0xCCCCCC);
		tempPageAreaMC.graphics.drawRect(0, 0, vectorX * digitalbookMC.pageWidth, digitalbookMC.pageHeight);
		pageGraMC.addChildAt(tempPageAreaMC, 0);
	}
	
	private function maskSet():void
	{
		pageMaskMC = new Sprite();
		pageMaskMC.y = digitalbookMC.pageHeight;
		addChild(pageMaskMC);
		pageMaskGra = new Shape();
		pageMaskMC.addChild(pageMaskGra);
		
		pageMaskGra.graphics.beginFill(0xAAAAFF);
		pageMaskGra.graphics.drawRect(0, -digitalbookMC.pageHeight * 2, vectorX * digitalbookMC.pageWidth * 2, digitalbookMC.pageHeight * 3);
		
		containerMC.mask = pageMaskMC;
	}
	
	private function shadowSet():void
	{
		shadowMC = new Shape();
		shadowMC.y = digitalbookMC.pageHeight;
		if (pageRightFlag)
		{
			shadowMC.graphics.beginGradientFill("linear", [0x000000, 0x000000], [0, 0.8], [0, 100]);
		}
		else
		{
			shadowMC.graphics.beginGradientFill("linear", [0x000000, 0x000000], [0.8, 0], [150, 255]);
		}
		shadowMC.graphics.drawRect(0, -digitalbookMC.pageHeight * 2, vectorX * -100, digitalbookMC.pageHeight * 3);
		addChild(shadowMC);
		
		shadowMaskMC = new Shape();
		shadowMaskMC.graphics.beginFill(0x00CCCC);
		shadowMaskMC.graphics.drawRect(-digitalbookMC.pageWidth, 0, digitalbookMC.pageWidth * 2, digitalbookMC.pageHeight);
		addChild(shadowMaskMC);
		shadowMC.mask = shadowMaskMC;
		shadowMC.visible = false;
	}
	
	private function mouseAreaSet():void
	{
		mouseAreaMC = new Sprite();
		mouseAreaMC.graphics.beginFill(0xAAAAFF, 0);
		
		var mouseAreaPosiX:int = digitalbookMC.pageWidth - mouseAreaMC.width;
		var mouseAreaWidth:uint = digitalbookMC.pageWidth * 0.2;
		mouseAreaMC.graphics.drawRect(0, 0, vectorX * (-mouseAreaWidth), digitalbookMC.pageHeight);
		mouseAreaMC.x = vectorX * mouseAreaPosiX;
		
		addChild(mouseAreaMC);
		mouseAreaMC.addEventListener(MouseEvent.ROLL_OVER, onMouseAreaOver);
	}
	
	private function maskedPageSet():void
	{
		if (!maskedPageMC)
		{
			if (pageRightFlag)
			{
				maskedPageMC = digitalbookMC.pageArray[ID];
				if (digitalbookMC.pageArray[ID + 1])
				{
					backPageMC = digitalbookMC.pageArray[ID + 1];
				}
				if (digitalbookMC.pageArray[ID - 2])
				{
					sidePageMC = digitalbookMC.pageArray[ID - 2];
				}
			}
			else
			{
				maskedPageMC = digitalbookMC.pageArray[ID - 2];
				if (digitalbookMC.pageArray[ID - 3])
				{
					backPageMC = digitalbookMC.pageArray[ID - 3];
				}
				if (digitalbookMC.pageArray[ID])
				{
					sidePageMC = digitalbookMC.pageArray[ID];
				}
			}
		}
		if (maskedPageMC)
		{
			maskedPageMC.pageMaskMC.x = 0;
			maskedPageMC.pageMaskMC.rotation = 0
		}
	}
	
	//イベントdispach
	public function dispatchOpenEvent():void
	{
		dispatchEvent(new Event(Page.PAGE_OPEN));
	}
	
	public function dispatchOpenCompleteEvent():void
	{
		dispatchEvent(new Event(Page.PAGE_OPENCOMPLETE));
	}
	
	public function dispatchCloseEvent():void
	{
		dispatchEvent(new Event(Page.PAGE_CLOSE));
	}
	
	public function dispatchCloseCompleteEvent():void
	{
		dispatchEvent(new Event(Page.PAGE_CLOSECOMPLETE));
	}
	
	//ページロード
	public function pageLoad():void
	{
		imgLoad(filePath);
	}
	
	private function imgLoad(str:String):void
	{
		var context:LoaderContext = new LoaderContext(true);
		imgLoader.load(new URLRequest(str),context);
		imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoadComplete);
	}

}

