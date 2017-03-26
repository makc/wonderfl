package {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;

	import flash.system.LoaderContext;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;

	import flash.net.URLRequest;

/*-----------------------------------------------
turn the pages transition 

フィルムがめくれるようなトランジションです

3年前に作ったコードなので、
ライブラリは何も使っていません。
その為、ちょいと長いコードに・・・

@narutohyper

------------------------------------------------*/

	[SWF(width = 465, height = 465, frameRate = 60)]
	public class Main extends Sprite {

		//後々外部xmlからの読み込みに対応させるられるよう、XMLで、画像のURLを設定
		private var dataXml:XML =
			<menu>
					<imgurl>http://marubayashi.net/archive/sample/images/11.jpg</imgurl>
					<imgurl>http://marubayashi.net/archive/sample/images/12.jpg</imgurl>
					<imgurl>http://marubayashi.net/archive/sample/images/13.jpg</imgurl>
					<imgurl>http://marubayashi.net/archive/sample/images/14.jpg</imgurl>
					<imgurl>http://marubayashi.net/archive/sample/images/15.jpg</imgurl>
					<imgurl>http://marubayashi.net/archive/sample/images/16.jpg</imgurl>
					<imgurl>http://marubayashi.net/archive/sample/images/17.jpg</imgurl>
					<imgurl>http://marubayashi.net/archive/sample/images/18.jpg</imgurl>
					<imgurl>http://marubayashi.net/archive/sample/images/19.jpg</imgurl>
					<imgurl>http://marubayashi.net/archive/sample/images/20.jpg</imgurl>
			</menu>;

		private var dataCounter:uint=0;
		private var dataArray:Array;
		private var imgArray:Array;
		private var thumbnailArray:Array;

		private var progress:Sprite
		private var bar:Sprite

		private var nowPage:int=-1;
		private var mainFrame:Sprite;
		private var page:turnPage;

		public function Main() {

			dataArray = new Array();
			imgArray = new Array();
			mainFrame=new Sprite;
			addChild(mainFrame);

			//取り込んだXMLデータの中の画像URL情報を配列に収納
			for each (var item:String in dataXml.imgurl) {
				dataArray.push(item)
			}

			//画像の読み込み開始
			imgLoader(0)

			//簡易progressBar
			progress=new Sprite()
			progress.graphics.beginFill(0x666666,1)
			progress.graphics.drawRect(0,0,102,10)
			progress.x=(464-102)/2
			progress.y=(464-10)/2
			bar=new Sprite()
			bar.graphics.beginFill(0x6666FF,1)
			bar.graphics.drawRect(0,0,100,8)
			bar.x=1
			bar.y=1
			bar.width=0
			addChild(progress)
			progress.addChild(bar)

		}


		//画像読み込み
		private function imgLoader(no:uint):void {
			var loader:Loader = new Loader();
			loader.load(new URLRequest(dataArray[no]), new LoaderContext(true));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, error); 

			function loaded(e:Event):void {
				//trace(dataArray[no]);
				imgArray.push(loader);
				nextProc()
			}

			function error(e:IOErrorEvent):void {
				nextProc()
			}

			function nextProc():void {
				dataCounter++
				bar.width+=10
				if (dataArray.length>dataCounter) {
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,loaded);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, error); 

					imgLoader(dataCounter)
				} else {
					init();
				}
			}
		}

		private function init():void {
			removeChild(progress)

			thumbnailArray=[];

			for (var i:uint=0;i<imgArray.length;i++) {
				//サムネール画像の作成
				thumbnailArray[i]=new thumbnail(i,imgArray[i])
				addChild(thumbnailArray[i])
				thumbnailArray[i].addEventListener(MouseEvent.CLICK,thumbnailHandler)

				//メイン画像の配置
				imgArray[i].content.scaleX=imgArray[i].content.scaleY=445/640
				mainFrame.addChild(imgArray[i]);
				imgArray[i].visible=false;
			}

			//transition用Sprite
			page = new turnPage(this,445,340)
			mainFrame.x=page.x=10;
			mainFrame.y=page.y=50;
			changePage(0)
		}

		private function thumbnailHandler(e:MouseEvent):void {
			changePage(e.target.id)
		}


		public function changePage(nextPage:uint):void {
			for (var i:uint=0;i<thumbnailArray.length;i++) {
				if (i==nextPage) {
					thumbnailArray[i].down()
				} else {
					thumbnailArray[i].disable()
				}
				thumbnailArray[i].removeEventListener(MouseEvent.CLICK,thumbnailHandler)
			}

			if (nowPage>=0) {
				page.addEventListener(turnPage.CLOSE_END,closeEnd)
				page.close(imgArray[nowPage])
			} else {
				openStart()
			}

			//openStart()


			function closeEnd(event:Event=null):void {
				page.removeEventListener(turnPage.CLOSE_END,closeEnd)
				imgArray[nowPage].visible=false;

				openStart()
			}

			function openStart():void {
				nowPage=nextPage

				imgArray[nowPage].visible=true;
				page.addEventListener(turnPage.OPEN_END,openEnd)
				page.open(imgArray[nowPage])
			}

			function openEnd(event:Event=null):void {
				page.removeEventListener(turnPage.OPEN_END,openEnd)
				for (var i:uint=0;i<thumbnailArray.length;i++) {
					if (i!=nowPage) {
						thumbnailArray[i].enable()
						thumbnailArray[i].addEventListener(MouseEvent.CLICK,thumbnailHandler)
					}
				}
			}
		}


	}

}







import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.*
import flash.geom.Matrix;
import flash.geom.Point;

import flash.events.MouseEvent;



//ページめくり演出用スプライト
class turnPage extends Sprite{
	//コンストラクタ
	public static const OPEN_END:String = "open_end";
	public static const CLOSE_END:String = "close_end";

	private var targetMc:DisplayObject;
	private var _parent:DisplayObjectContainer;

	private var maskA:Sprite;
	private var maskB:Sprite;

	private var backSprite:Sprite;
	private var frontSprite:Sprite;
	private var backBmd:BitmapData;
	private var backBm:Bitmap;
	private var frontBmd:BitmapData;
	private var frontBm:Bitmap;

	private var w:Number
	private var h:Number

	public function turnPage(mc:DisplayObjectContainer,_w:Number,_h:Number):void {
		_parent=mc;
		_parent.addChild(this);
		this.visible=false;
		w=_w
		h=_h

		//---------------------------------------------
		//EFFECT用
		//---------------------------------------------
		//後景
		backSprite=new Sprite();
		backBmd = new BitmapData(w,h,true, 0x0000FFFF);
		backBm = new Bitmap(backBmd);
		backSprite.addChild(backBm)
		this.addChild(backSprite);


		//前景
		frontSprite=new Sprite();
		frontBmd = new BitmapData(w,h,true, 0x0000FFFF);
		frontBm = new Bitmap(frontBmd);
		frontSprite.addChild(frontBm)
		this.addChild(frontSprite);

		maskA=new Sprite()
		maskB=new Sprite()

		this.addChild(maskA)
		this.addChild(maskB)

		backSprite.mask=maskA
		frontSprite.mask=maskB
		//clone()
	}


	public function clone():void {
		backBmd = new BitmapData(w,h,true, 0x00000000);
		frontBmd = new BitmapData(w,h,true, 0x00000000);

		backBm.bitmapData = backBmd
		frontBm.bitmapData = frontBmd

		backBmd.draw(targetMc)
		frontBmd.draw(targetMc)

		backSprite.visible=true
		frontSprite.visible=true
		targetMc.visible=false

	}


	public function open(_targetMc:DisplayObject):void {
		targetMc=_targetMc
		clone()

		this.visible=true;

		var minute:uint=600;
		var no:uint=15;
		var fadeTimer:Timer = new Timer(minute/no, no);
		var angle:uint=0;
		
		// 時間間隔イベントおよび完了イベント用のリスナーを指定する
		fadeTimer.addEventListener(TimerEvent.TIMER, onTime);
		fadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeComplete);

		fadeTimer.start();
		openMask(angle)

		function onTime(event:TimerEvent):void {
			angle+=4
			openMask(angle)

		}

		function onTimeComplete(event:TimerEvent):void {
			fadeTimer.removeEventListener(TimerEvent.TIMER, onTime);
			fadeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimeComplete);
			targetMc.visible=true
			backSprite.visible=false
			frontSprite.visible=false
			dispatchEvent(new Event(OPEN_END));

		}
		
	}


	public function close(_targetMc:DisplayObject):void {
		targetMc=_targetMc
		clone()
		
		var minute:uint=600
		var no:uint=15
		var fadeTimer:Timer = new Timer(minute/no, no);
		var angle:uint=60
		
		// 時間間隔イベントおよび完了イベント用のリスナーを指定する
		fadeTimer.addEventListener(TimerEvent.TIMER, onTime);
		fadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeComplete);

		closeMask(angle)
		fadeTimer.start();

		function onTime(event:TimerEvent):void {
			angle-=4
			closeMask(angle)

		}

		function onTimeComplete(event:TimerEvent):void {
			fadeTimer.removeEventListener(TimerEvent.TIMER, onTime);
			fadeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimeComplete);
			backSprite.visible=false
			frontSprite.visible=false

			dispatchEvent(new Event(CLOSE_END));
			this.visible=false;
		}

	}



	private function openMask(angle:Number=0,dh:Number=1400,h:Number=470):void {

		var th:Number=w*dh/1000

		clone()

		var radian:Number=angle*Math.PI/180
		var a:Number=Math.tan(radian)*th
		var b:Number=Math.tan(radian)*(th-h)
		maskA.graphics.clear()
		maskA.graphics.beginFill(0xFF0000)
		maskA.graphics.moveTo(0,0)
		maskA.graphics.lineTo(a,0)
		maskA.graphics.lineTo(b,h)
		maskA.graphics.lineTo(0,h)
		maskA.graphics.endFill()

		maskB.graphics.clear()
		maskB.graphics.beginFill(0x0000FF)
		maskB.graphics.moveTo(a-b,-h)
		maskB.graphics.lineTo(2000,-h)
		maskB.graphics.lineTo(2000,0)
		maskB.graphics.lineTo(0,0)
		maskB.graphics.endFill()

		var mtr:Matrix= new Matrix()
		var mtr2:Matrix= new Matrix()
		mtr.scale(-1,1)
		mtr.rotate(radian*2)
		mtr.translate(b,h)

		frontBm.x=-b
		frontBm.y=-h
		frontSprite.transform.matrix = mtr

		frontSprite.alpha=0.5

		frontSprite.mask=maskB
		frontSprite.visible=true
		maskB.transform.matrix = mtr

	}



	private function closeMask(angle:Number=0,dh:Number=1400,h:Number=470):void {

		var th:Number=w*dh/1000
		var tw:Number=w

		clone()

		var radian:Number=angle*Math.PI/180
		var a:Number=Math.tan(radian)*th
		var b:Number=Math.tan(radian)*(th-h)

		maskA.graphics.clear()
		maskA.graphics.beginFill(0xFF0000)
		maskA.graphics.moveTo(tw,0)
		maskA.graphics.lineTo(tw-a,0)
		maskA.graphics.lineTo(tw-b,h)
		maskA.graphics.lineTo(tw,h)
		maskA.graphics.endFill()

		maskB.graphics.clear()
		maskB.graphics.beginFill(0x0000FF)
		maskB.graphics.moveTo(a-b,-h)
		maskB.graphics.lineTo(2000,-h)
		maskB.graphics.lineTo(2000,0)
		maskB.graphics.lineTo(0,0)
		maskB.graphics.endFill()

		var mtr:Matrix= new Matrix()
		mtr.scale(-1,1)
		mtr.rotate(-radian*2)
		mtr.translate(tw-b,h)
		frontBm.x=-(tw-b)
		frontBm.y=-h
		frontSprite.transform.matrix = mtr
		frontSprite.alpha=0.5

		var mtr2:Matrix= new Matrix()
		mtr2.scale(1,1)
		mtr2.rotate(-radian*2)
		mtr2.translate(tw-b,h)
		maskB.transform.matrix = mtr2

	}


}


















//簡易thumbnailボタン
class thumbnail extends Sprite{
	public var id:uint
	private var disableFlag:Boolean=false
	public function thumbnail(_id:uint,mc:DisplayObject):void {
		id=_id
		var bmd:BitmapData =new BitmapData(44,34,true,0x00000000)
		var mtx:Matrix=new Matrix;

		mtx.createBox(40/mc.width,30/mc.height,0,2,2)
		bmd.draw(mc,mtx,null,null,null,true)
		graphics.beginFill(0xCCCCCC)
		graphics.drawRect(1,1,42,32)
		addChild(new Bitmap(bmd));
		x=id*45+8
		y=400
		addEventListener(MouseEvent.MOUSE_OVER,thumbnailHandler)
		addEventListener(MouseEvent.MOUSE_OUT,thumbnailHandler)
		disableFlag=false
	}

	private function thumbnailHandler(e:MouseEvent):void {
		if(e.type==MouseEvent.MOUSE_OVER) {
			e.target.graphics.clear()
			e.target.graphics.beginFill(0xFF6666)
			e.target.graphics.drawRect(0,0,44,34)
		} else if (e.type==MouseEvent.MOUSE_OUT) {
			e.target.graphics.clear()
			e.target.graphics.beginFill(0xCCCCCC)
			e.target.graphics.drawRect(1,1,42,32)
		}
	}

	public function down():void {
		alpha=0.5
		if (!disableFlag) {
			removeEventListener(MouseEvent.MOUSE_OVER,thumbnailHandler)
			removeEventListener(MouseEvent.MOUSE_OUT,thumbnailHandler)
			disableFlag=true
		}
		graphics.clear()
		graphics.beginFill(0x6666FF)
		graphics.drawRect(0,0,44,34)
	}

	public function enable():void {
		if(disableFlag) {
			addEventListener(MouseEvent.MOUSE_OVER,thumbnailHandler)
			addEventListener(MouseEvent.MOUSE_OUT,thumbnailHandler)
			disableFlag=false
		}
		graphics.clear()
		var p:Point=localToGlobal(new Point(mouseX,mouseY))
		if (hitTestPoint(p.x,p.y)) {
			graphics.beginFill(0xFF6666)
			graphics.drawRect(0,0,44,34)
		} else {
			graphics.beginFill(0xCCCCCC)
			graphics.drawRect(1,1,42,32)
		}
		alpha=1
	}

	public function disable():void {
		alpha=0.5
		if (!disableFlag) {
			removeEventListener(MouseEvent.MOUSE_OVER,thumbnailHandler)
			removeEventListener(MouseEvent.MOUSE_OUT,thumbnailHandler)
			disableFlag=true
		}
		graphics.clear()
		graphics.beginFill(0xCCCCCC)
		graphics.drawRect(1,1,42,32)
	}




}


