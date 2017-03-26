	/*
		作りかけw
		okmt.masaaki
		http://twitter.com/okamotomasaaki
		
		ちょっと前にはやっったやつをdrawTrianglesを
		使って再現してみた。
		
		プログラム末尾にinternal classとしてくっつけた
		BitmapTriangleというdrawTrianglesを使った
		Spriteを生成してくれるクラスのデモみたいな感じです。
		これによって超変形が可能に！！
		
		最適化してません。。。
		
		下のURLも同じクラス使ってます。
		http://wonderfl.net/c/fHNH
		
		
		
	*/
package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
    import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	
	public class Main extends Sprite {
		
		// クラスメンバー
		public static var refer:Main;
	    private const xDiv:uint = 10;
	    private const yDiv:uint = 10;
	    private var texture:BitmapData;
		private var imgWidth:uint;
	    private var imgHeight:uint;
		private const imgURL:String = "http://farm1.static.flickr.com/72/219505667_99ba96c6c8.jpg";
		private var sample:BitmapTriangles;
		
		//ヘルパー用オブジェクト
		private var helper:Sprite;
		private var pointArray:Array;
		private var weight:Array;
		private var dumyPos:Array;
		
		public function Main():void 
		{
			// 参照用
			refer = this;
			imgloading();
		}
		
		private function imgloading():void
		{
			var myLoader:Loader = new Loader();
			var myURLRequest:URLRequest = new URLRequest(imgURL);
			//LoaderContextを使うと、drawできるようになる。ただしcrossdomain.xmlで許可されている場合のみ
			//これ→http://farm4.static.flickr.com/crossdomain.xml
			var myLoaderContext:LoaderContext = new LoaderContext(true);
			myLoader.load(myURLRequest , myLoaderContext);
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
			{
				var myBitmap:Bitmap = e.target.content;
				imgWidth = myBitmap.width;
				imgHeight = myBitmap.height;
				texture = new BitmapData(myBitmap.width, myBitmap.height);
				texture.draw(myBitmap);
				initialize();
			});	
		}
		private function initialize():void 
		{
			createVertics();
			createObject();
			
			stageSetting();
			
			var a:TextField = new TextField();
			a.text = "ドラッグしてね！！！！！";
			addChild(a);
			
		}
		private function createVertics():void
		{
			dumyPos = new Array();
			weight = new Array();
			for (var j:int = 0; j <= yDiv; j++) {
				dumyPos[j] = new Vector.<Point>;
				weight[j] = new Vector.<Number>;
				for (var i:int = 0; i <= xDiv; i++) {
					var posx:Number = texture.width/xDiv*i - texture.width/2;
					var posy:Number = texture.height / yDiv * j - texture.height / 2;
					dumyPos[j][i] = new Point(posx,posy);
					weight[j][i] = Math.sqrt(Math.pow(posx, 2) + Math.pow(posy, 2))/70+1;
				}
			}
		}
		private function createObject():void
		{
			sample = new BitmapTriangles(texture, xDiv, yDiv);
			sample.pointArray = dumyPos;
			addChild(sample);
			helper = new Sprite();
			helper.buttonMode = true;
			helper.useHandCursor = true;
			helper.graphics.beginFill(0x000000, 0);
			helper.graphics.drawRect( -texture.width / 2, -texture.height / 2, texture.width, texture.height);
			helper.graphics.endFill();
			helper.x = texture.width / 2;
			helper.y = texture.height / 2;
			helper.addEventListener(MouseEvent.MOUSE_DOWN,function(e:Event):void{
				Sprite(e.target).startDrag();
				//sample.addEventListener(Event.ENTER_FRAME, reDraw);
			});
			helper.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
				Sprite(e.target).stopDrag();
				//sample.removeEventListener(Event.ENTER_FRAME, reDraw);
			});

			stage.addEventListener(Event.ENTER_FRAME, reDraw);
			addChild(helper);
			
		}
		
		private function reDraw(e:Event):void
		{
			resetPos(new Point(helper.x, helper.y));
		}
		
		private function resetPos(pos:Point):void
		{
			for(var j:uint = 0;j<= yDiv;j++){
				for (var i:uint = 0; i <= xDiv; i++) {
					var posx:Number = texture.width/xDiv*i - texture.width/2 + pos.x;
					var posy:Number = texture.height / yDiv * j - texture.height / 2 + pos.y;
					var tempx:Number = dumyPos[j][i].x + (posx - dumyPos[j][i].x) / weight[j][i];
					var tempy:Number = dumyPos[j][i].y + (posy - dumyPos[j][i].y) / weight[j][i];
					
					dumyPos[j][i] = new Point(tempx,tempy);;
				}
			}
			sample.pointArray = dumyPos;
			sample.bitmapUpdate();
		}
		
		private function stageSetting():void 
		{
        		stage.scaleMode = StageScaleMode.NO_SCALE;
        		stage.align = StageAlign.TOP_LEFT;
        		stage.addEventListener(Event.RESIZE, onResize);
				
        		onResize();
			
		}
        private function onResize(e:Event = null):void
        {
			
        }
		
		
		
	}
	
}



import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
internal class BitmapTriangles extends Sprite
{
	public var pointArray:Array;//頂点の座標格納用配列
	private var weight:Array;//頂点の重み
	public var xDivision:uint = 1;//水平方向の分割数
	public var yDivision:uint = 1;//垂直方向の分割数
	public var texture:BitmapData;//塗に設定するビットマップデータ

	
	//コンストラクタ
	public function BitmapTriangles(bmp:BitmapData, xDivision:uint , yDivision:uint) 
	{
		/* bmp : ソース
		 * xDivision : X方向の分割数 
		 * yDivision : Y方向の分割数
		 */

		pointArray = new Array();
		this.xDivision = xDivision;
		this.yDivision = yDivision;
		
		texture = bmp;
		
		
		createCoordinate();
		bitmapUpdate();
	}
	
	//頂点の生成（初期化）
	//x軸、y軸共に分割数＋１の頂点を生成する
	private function createCoordinate():void {
		for (var j:uint = 0; j <= yDivision; j++) {
			pointArray[j] = new Vector.<Point>();
			for (var i:uint = 0; i <= xDivision; i++) {
				pointArray[j][i] = new Point(texture.width/xDivision*i,texture.height/yDivision*j);
			}
		}
	}
	
	//描画を更新するメソッド
	public function bitmapUpdate():void {
		var i:uint;
		var j:uint;
		var vertices:Vector.<Number> = new Vector.<Number>();
		var indices:Vector.<int> = new Vector.<int>();
		var uvt:Vector.<Number> = new Vector.<Number>();
		
		
		for(j = 0;j<= yDivision;j++){
			for(i = 0;i<= xDivision;i++){
				vertices.push(pointArray[j][i].x ,pointArray[j][i].y);
				uvt.push(1/xDivision*i,1/yDivision*j);
			}	
		}
		
		for(j = 0;j< yDivision;j++){
			for(i = 0;i< xDivision;i++){
				indices.push((xDivision+1)*j+i,(xDivision+1)*j+1+i,i+(xDivision+1)*(j+1));
				indices.push((xDivision+1)*j+1+i,i+(xDivision+1)*(j+1),i+(xDivision+1)*(j+1)+1);
			}	
		}
		this.graphics.clear();
		this.graphics.beginBitmapFill(texture);
		this.graphics.drawTriangles(vertices, indices, uvt);
	}
	//座標取得
	public function getPointsArray():Array
	{
		return pointArray;
	}
	
	
}