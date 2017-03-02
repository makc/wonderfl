package 
{
	/*
		画像読んで、RチャンネルをピクセルのZに使う。
	*/
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.net.*;	
	
	[SWF(width=465, height=465, frameRate=60, backgroundColor=0x222222)]
	public class Main extends Sprite 
	{
		private var url　　　　　　　:String = "http://assets.wonderfl.net/images/related_images/8/80/80e0/80e07aa704555dd97cd1cf645a102c23e3735906";
		private var loader     :Loader;
		private var particles  :Array = [];
		private var bitmapData :BitmapData;
		private var renderer   :Renderer;
		
		public function Main():void 
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, complateHandler );
			loader.load( new URLRequest(url), new LoaderContext(true) );
		}
		
		private function complateHandler(e:Event):void
		{
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, complateHandler );
			bitmapData = e.target.content.bitmapData;
			
			addChild( new Bitmap( bitmapData ) );			
			
			var color :int = 0;
			var xx    :int = 0;
			var yy    :int = 0;
			var w     :int = bitmapData.width;
			var h     :int = bitmapData.height;
			var s     :int = 6;	
			
			for( yy	= 0; yy < h; yy++ ){
				for ( xx = 0; xx < w; xx++ ){
					color = bitmapData.getPixel( xx, yy );
					var red   :int    = (color >> 16) & 0xff;  
					var green :int    = (color >>  8) & 0xff;  
					var blue  :int    = (color >>  0) & 0xff;
					var px    :Number = ( xx * s ) - ( w / 2 * s );
					var py    :Number = ( yy * s ) - ( h / 2 * s );
					
					if ( red > 1 )
						particles.push( new Particle( px, py, int(red/2)) );
				}
			}
			
			// レンダリングスクリーン
			renderer = new Renderer( stage.stageWidth, stage.stageHeight, particles );
			addChild( renderer );
			
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouse );
			stage.addEventListener( MouseEvent.MOUSE_UP,   onMouse );
			addEventListener(Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function onMouse( e:MouseEvent ):void
		{
			if( e.type == "mouseDown" )mouseDown = true; 
			if( e.type == "mouseUp"   )mouseDown = false;
		}
			
		private var vx　:Number = 1;
		private var vy　:Number = 0;
		private var lx　:Number = 0;
		private var ly　:Number = 0;
		private var friction　　:Number = 0.999;
		private var mouseDown　:Boolean = false;
		
		private function onEnterFrame( e:Event ):void
		{
			// 横回転
			if ( mouseDown )
				vx = lx - stage.mouseX;
			else
				vx *= friction;
			if( Math.abs( vx ) <= 0.1 )
				vx = 0;
			lx = stage.mouseX;
			
			// 縦回転
			if( mouseDown )
				vy = ly - stage.mouseY;
			else
				vy *= friction;
			if( Math.abs( vy ) <= 0.1 )
				vy = 0;
			ly = stage.mouseY;
			
			// 座標回転
			for each( var particle:Particle in particles )
			{			
				rocalRotate( particle, "z", "y",  vy );
				rocalRotate( particle, "x", "z", -vx );
			}
			
			renderer.draw();
		}
		
		private function rocalRotate( particle:Particle, a:String, b:String, v:Number ):void
		{
			var cos	:Number, sin	:Number, posA:Number, posB:Number,
			rad	:Number = Math.PI / 360;
			
			cos	 = Math.cos( v * rad );
			sin	 = Math.sin( v * rad );
			posA = particle[a];
			posB = particle[b];
			particle[a] = posA * cos - posB * sin;
			particle[b] = posB * cos + posA * sin;
		}		
	}
}

	internal class Particle
	{
		public var x	:Number = 0;
		public var y	:Number = 0;
		public var z	:Number = 0;
		
		public function Particle( x:Number=0, y:Number=0, z:Number=0 ):void
		{
			this.x = x; this.y = y; this.z = z;			
		}
	}
	
	import flash.display.*;
	
	internal class Renderer extends Bitmap
	{
		private var particles :Array;
		private var vpX	:int  = 0;
		private var vpY	:int  = 0;
		private var fl	:uint = 500;
		
		public function Renderer( _w:int, _h:int, particles:Array ):void
		{
			this.particles = particles;
			bitmapData	= new BitmapData( _w, _h, true, 0x00 );
			
			vpX	= int( _w/2 );	vpY	= int( _h/2 );
			fl	= 500;
		}
		
		public function draw():void
		{
			var scale:Number, viewX:int, viewY:int, color:uint, c1:int;
			
			bitmapData.lock();
			bitmapData.fillRect( bitmapData.rect, 0x00 );
			
			for each( var p:Particle in particles )
			{
				scale = fl / ( fl + p.z );
				viewX = vpX + p.x * scale;
				viewY = vpY + p.y * scale;
				
				c1 = 255 - ( ( p.z + 50) / 100 * 255 );
				c1 = c1 < 0? 0:c1;
				c1 = c1 > 255? 255:c1; 
				color = 0xff000000 | c1 << 16 | c1 << 8 | c1;
				
				bitmapData.setPixel32( viewX, viewY, color );
			}
			bitmapData.unlock();
		}
	}