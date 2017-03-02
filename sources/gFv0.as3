// forked from okoi's flash on 2010-3-11
package {
    import flash.display.Sprite;
	import flash.display.MovieClip
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
    
    public class FlashTest extends Sprite {

		var	pathMC:MovieClip = new MovieClip();
		var pathlist:Array = new Array();
		
		var drawBMPData:BitmapData;
		var drawBMP:Bitmap;
		var drawMC:MovieClip = new MovieClip();

		var drawFlag:Boolean = false;
    
        public function FlashTest() {
            // write as3 code here..
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
            
        }
        	
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			// BackGround
			var g:Graphics = graphics;
			g.beginFill( 0x000000 );
			g.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			
			//	addMC
			addChild(pathMC);
			
			drawBMPData = new BitmapData( stage.stageWidth,  stage.stageHeight, true, 0x00000000 );
			drawBMP = new Bitmap(drawBMPData);
			addChild(drawBMP);
			
			//	CreatePath
			var p:Path = new Path();

			for ( var i:int = 0; i < 200; i++ )
			{
				p = new Path();
				p.Init(0, 0, 5 + (i/20), 0.5, 50);
				pathlist.push(p);
			}
			
			
			addEventListener(Event.ENTER_FRAME, EnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, ChangeDrawFlag );
			stage.addEventListener(MouseEvent.MOUSE_UP, ChangeDrawFlag );
		}
		
		public	function EnterFrame(event:Event):void 
		{
			//	DrawPath
			var g:Graphics = pathMC.graphics;
			g.clear();
			g.beginFill( 0xFFFFFF, 1 );
			//g.lineStyle (10, 0x000000, 1.0);	// 線のスタイル
			
			for each ( var p:Path in pathlist )
			{
				//	マウスの位置更新
				p.SetMousePos( stage.mouseX, stage.mouseY );
				if( !drawFlag )	g.drawCircle( p.point.x, p.point.y, 1 );
			}
			
			//	描画処理
			if ( drawFlag )
			{
				g = drawMC.graphics;
				g.clear();
				
				for ( var i:int = 0; i < pathlist.length - 1; i++ )
				{
					g.lineStyle (1, pathlist[i].color, 0.1);	// 線のスタイル
					g.moveTo( pathlist[i].prev.x, pathlist[i].prev.y );
					g.lineTo( pathlist[i].point.x, pathlist[i].point.y );
				}
				//	書いたデータをビットマップに追加
				drawBMPData.draw( drawMC, null, null, BlendMode.ADD ); 
			}
			
			
		}
		
		public	function ChangeDrawFlag(event:MouseEvent):void 
		{
			if ( drawFlag ) drawFlag = false;
			else 			drawFlag = true;

			//var	color:Array = [0xFF0000 , 0xFFFF00 , 0x00FF00 , 0x00FFFF , 0x0000FF];
			
			var colorMax:uint = 0xFFFF;
			var colorMin:uint = 0xFF00;
			
			for ( var i:int = 0; i < pathlist.length - 1; i++ )
			{
				pathlist[i].color = 0xFF0000 + 0xFF00 * (i/(pathlist.length-1));
			}
		}        
    }
}
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.Point;

	internal class Path extends MovieClip
	{
		var prev:Point = new Point();
		var	point:Point = new Point();
		var mouse:Point = new Point();
		
		var move:Point = new Point();
		
		var accele:Number = 1;
		var slowdown:Number = 1;
		var maxspeed:Number = 1;
		
		var color:uint;
		
		public function Path() 
		{
			super();
			addEventListener(Event.ENTER_FRAME, EnterFrame );
		}
		
		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	accele	マウスから離れて行く時の加速値
		 * @param	_effect
		 */
		public	function Init(x:int = 0, y:int = 0, _accele:Number = 1, _slowdown:Number = 1, _maxspeed:Number = 20):void 
		{
			prev.x = point.x = x;
			prev.y = point.y = y;
			move.x = 0;
			move.y = 0;
			accele = _accele;
			slowdown = _slowdown;
			maxspeed = _maxspeed;
		}
		
		public	function SetMousePos(x:int, y:int):void
		{
			mouse.x = x;
			mouse.y = y;
		}
		
		public	function EnterFrame(event:Event):void 
		{
			prev.x = point.x;
			prev.y = point.y;
			
			//	マウスとの距離を出す
			//	そこから影響係数を掛けて移動力を出す
			var nowLen:Number = Math.sqrt( (mouse.x - prev.x) * (mouse.x - prev.x) + (mouse.y - prev.y) * (mouse.y - prev.y) );		
			//var power:Number = len * power;
			var rad:Number = Math.atan2((mouse.y - point.y), (mouse.x - point.x));
			
			/*
			move.x /= 0.5;
			move.y /= 0.5;
			
			var	rate:Number = 1 - (len / 100);
			if ( rate < 0 )	rate = 0;
			var power:Number = 1 + rate * 10;
			//if ( 100 - len > 0 ) rate = (100-len)/10;
			power = 1;			
			
			move.x += Math.cos( rad ) * power;
			move.y += Math.sin( rad ) * power;
			*/
			
			move.x += Math.cos( rad ) * accele;
			move.y += Math.sin( rad ) * accele;
			
			
			//	移動速度、角度算出
			//	あまりにも速度が大きくなったら正規化する
			var moveS:Number = Math.sqrt( move.x * move.x + move.y * move.y );
			var moveR:Number = Math.atan2(move.y, move.x);
			
			if ( moveS >= maxspeed )
			{
				move.x = Math.cos( moveR ) * maxspeed;
				move.y = Math.sin( moveR ) * maxspeed;
			}
			
			point.x += move.x;
			point.y += move.y;
			
			//	離れていってる時ならスピード減衰
			var nextLen:Number = Math.sqrt( (mouse.x - point.x) * (mouse.x - point.x) + (mouse.y - point.y) * (mouse.y - point.y) );
			if ( nowLen < nextLen )
			{
				move.x *= slowdown;
				move.y *= slowdown;
			}

		}
		
	}