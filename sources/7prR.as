//
//	繋がる点の亜種！！のつもりで作った全然違うもの
//
//	～彼らは斜めには繋がることができないのです。
//	　　　直角に曲がるのが好きだから仕方がないのです。～
//
//	繋がる点はこちら	
//		http://wonderfl.net/c/gJA7
//
package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Graphics;
	import flash.filters.GlowFilter;
	
	/**
	 * ...
	 * @author okoi
	 */
	public class Main extends Sprite 
	{
		private var paths:Array = new Array();
				
		private var bgBmpData:BitmapData;
		private var layer:Shape = new Shape();
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			var i:uint = 0;
			var x:Number;
			var y:Number;

			//	背景の線と点の初期配置
			bgBmpData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0);
			var shape:Shape = new Shape();
			var g:Graphics = shape.graphics;
			g.beginFill(0x000000);
			g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			g.endFill();
			g.lineStyle( 1, 0x555555 );
			
			var x_num:int = int(stage.stageWidth / PATH_SPAN);
			for ( i = 0; i < x_num; i++ )
			{
				x = i * PATH_SPAN;
				if ( i % 2 == 0 )	paths.push(new Path(x, stage.stageHeight/2, Path.DIR_UP));
				else 				paths.push(new Path(x, stage.stageHeight / 2, Path.DIR_DOWN));
				
				g.moveTo( x, 0 );	g.lineTo( x, stage.stageHeight );
			}
			var y_num:int = int(stage.stageHeight / PATH_SPAN);
			for ( i = 0; i < y_num; i++ )
			{
				y = i * PATH_SPAN;
				if ( i % 2 == 0 )	paths.push(new Path(stage.stageWidth/2, y, Path.DIR_LEFT));
				else 				paths.push(new Path(stage.stageWidth / 2, y, Path.DIR_RIGHT));
				
				g.moveTo( 0, y );	g.lineTo( stage.stageWidth, y );
			}					
			
			bgBmpData.draw( shape );
			addChild(new Bitmap(bgBmpData));
			layer.filters = [new GlowFilter(0xFFFFAA,1,4,4,4,4)];
			addChild(layer);
			
			addEventListener( Event.ENTER_FRAME, EnterFrame );
		}
		
		private function EnterFrame(e:Event):void 
		{
			var i:int = 0;
			var j:int = 0;
			var path_num:int = paths.length;
			for ( i = 0; i < path_num; i++ )
			{
				paths[i].Update(stage);
				paths[i].jointLen = 99999999;
			}
			for ( i = 0; i < path_num; i++ )
			{
				var ip:Path = paths[i];
				var no:int = -1;
				
				for ( j = 0; j < path_num; j++ )
				{
					if ( i == j ) continue;
					var jp:Path = paths[j];
					var len:Number = ((jp.posX - ip.posX) * (jp.posX - ip.posX) + (jp.posY - ip.posY) * (jp.posY - ip.posY));
					if ( ip.jointLen > len )
					{
						no = j;
						ip.jointLen = len;
					}
				}
				if ( ip.jointNo != no )
				{
					ip.jointNo = no;
					ip.Spark();
				}
			}			
			
			var g:Graphics = layer.graphics;
			g.clear();
			for ( i = 0; i < path_num; i++ )
			{
				paths[i].Draw(g,paths);
			}
		}
		
	}
	
}
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
import flash.display.Graphics;
import flash.display.Stage;

const PATH_SPAN:int = 3;

class Path {
	public var defX:Number;
	public var defY:Number;
	public var posX:Number;
	public var posY:Number;
	public var moveX:Number;
	public var moveY:Number;
	
	public var jointNo:int = -1;
	public var jointLen:Number = 99999999;
	public var spark:int = 0;
	
	public	static	const	DIR_UP:int = 0;
	public	static	const	DIR_LEFT:int = 1;
	public	static	const	DIR_DOWN:int = 2;
	public	static	const	DIR_RIGHT:int = 3;
	
	public	var dir:int;
	
	public	var alphaStep:int;
	public	var alpha:Number;

	public	function Path(_x:Number, _y:Number, _dir:int) {
		Init(_x, _y, _dir);
	}
	
	public	function Init(_x:Number, _y:Number, _dir:int):void
	{
		posX = _x;
		posY = _y;
		defX = _x;
		defY = _y;
		moveX = 0;
		moveY = 0;
		dir = _dir;
		var rnd:Number = Math.random() * 3 + 2;
		if ( _dir == DIR_UP )	moveY = -1 * rnd;
		if ( _dir == DIR_DOWN )	moveY = 1 * rnd;
		if (_dir == DIR_LEFT)	moveX = -1 * rnd;
		if (_dir == DIR_RIGHT)	moveX = 1 * rnd;
		
		alphaStep = int(Math.random() * 360);
	}
	
	
	public	function Update(stage:Stage):void 
	{
		posX += moveX;
		posY += moveY;
		if ( posX < 0 )	posX = stage.stageWidth;
		if ( posX > stage.stageWidth ) posX = 0;
		if ( posY < 0 ) posY = stage.stageHeight;
		if ( posY > stage.stageHeight ) posY = 0;
		
		alpha = (Math.sin( alphaStep * Math.PI / 180 ) + 1) / 2;
		alphaStep = (alphaStep + 30) % 360;
		
		//spark--;
	}
	
	public	function Draw(g:Graphics,paths:Array):void
	{
	//	g.beginFill( 0xFFFFAA );
	//	g.drawCircle( posX, posY, 1 );
	//	g.endFill();
		
		if ( jointNo != -1 && spark != 0 )
		{
			var jdir:int = paths[jointNo].dir;
			var yy:Number;
			var xx:Number;
			
			g.lineStyle(1, 0xFFFFAA, alpha);
			
			g.moveTo(posX, posY);
			if ( dir == DIR_UP || dir == DIR_DOWN )
			{
				if ( jdir == DIR_LEFT || jdir == DIR_RIGHT )
				{
					g.lineTo( posX, paths[jointNo].posY );
				}else
				{
					if ( dir == DIR_UP )	yy = int(posY / PATH_SPAN) * PATH_SPAN;	
					else 					yy = int((posY+PATH_SPAN) / PATH_SPAN) * PATH_SPAN;	
					g.lineTo( posX, yy );
					g.lineTo( paths[jointNo].posX, yy );
				}
			}else
			{
				if ( jdir == DIR_UP || jdir == DIR_DOWN )
				{
					g.lineTo( paths[jointNo].posX, posY );
				}else
				{
					if ( dir == DIR_LEFT )	xx = int(posX / PATH_SPAN) * PATH_SPAN;	
					else 					xx = int((posX+PATH_SPAN) / PATH_SPAN) * PATH_SPAN;	
					g.lineTo( xx, posY );
					g.lineTo( xx, paths[jointNo].posY );
				}				
			}
			g.lineTo( paths[jointNo].posX, paths[jointNo].posY );
		}	
	}
	
	public	function Spark():void 
	{
		spark = 10;
	}
}
