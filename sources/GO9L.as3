/**
 * たーまやー。
 * 正規表現に苦戦しながらも、twitterでヘルプを求めて出来上がった作品。
 * Twitterで打ち上げたいコメントを、
 * #hanabi [（ ﾟдﾟ ）]
 * のように #hanabi [コメント]って書けば打ち上げリストに追加されるよ！
 * []は必須だからちゃんと付けてね！
 * 
 * Tweet hanabi!のボタンを押せばテンプレが表示される。
 * 
 * 花火リスト
 * http://search.twitter.com/search?q=%23hanabi
 * 
 * katan_t irgal_ Horiuchi_H katan_t repeatedly aibou nakawake seisuke uwitenpen beinteractive 
 * に感謝！
 * @author coppieee
 */
package {
	import com.bit101.components.PushButton;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.*;
	import flash.system.*;
	import com.flashdynamix.utils.*;

	[SWF(backgroundColor=0x000000, frameRate=60)]
	public class Sponsor extends Sprite {
	 
		private var _particles:Vector.<Object>;
		private var _gradientMap:BitmapData; 
		private var _timer:Timer; 
   
		private static const PARTICLES_LENGTH:int = 1000;
		//private static const _texts:Array = ["（ ﾟдﾟ ）","＼(＾o＾)／","(｢・ω・)｢",""];
		private var _texts:Array;
		private var _newestTexts:Array;
		private function setup():void {
			//Wonderfl.capture_delay(2);
			_gradientMap= new BitmapData(200,10, true, 0);
			 //addChild( new Bitmap( _gradientMap) ); // for debug
			updateGradientFill();
				
			//shotFirework();
			shotAA();
		   
			_timer = new Timer( 5000, 0 );
			_timer.addEventListener( TimerEvent.TIMER, timerHadler );
			_timer.start();
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoadComplete );
			_loader.load( new URLRequest("http://level0.kayac.com/space.jpg"), new LoaderContext(true) );
			
			
			//var textLoader:URLLoader =  new URLLoader(new URLRequest("http://search.twitter.com/search.atom?q=%23hanabi&rpp=100"));
			//textLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
				//default xml namespace = new Namespace("http://www.w3.org/2005/Atom");
				//var htmlText:XML = XML(textLoader.data);
				//var title:XMLList = htmlText.entry.title;
				//var xs:Array = [];
				//for each(var c:XML in  title)
				//{
					//xs.push.apply(null,scan(c.toString(),/\[(.+)\]/));
				//}
				//if (xs.length >= 1)
				//{
					//_texts = xs;
				//}
			//});
			var loadTexts:Function = function (rpp:int, arraySetter:Function):void {
				var textLoader:URLLoader = new URLLoader(new URLRequest("http://search.twitter.com/search.atom?q=%23hanabi&rpp=" + rpp));
				textLoader.addEventListener(Event.COMPLETE, function(e:Event):void {
					default xml namespace = new Namespace("http://www.w3.org/2005/Atom");
					var htmlText:XML = XML(textLoader.data);
					var title:XMLList = htmlText.entry.title;
					var xs:Array = [];
					for each(var c:XML in  title)
					{
						xs.push.apply(null,scan(c.toString(),/\[(.+)\]/));
					}
					if (xs.length >= 1)
					{
						//_texts = xs;
						arraySetter(xs);
					}
				});
			}
			loadTexts(100, function(arr:Array):void { _texts = arr } );
			loadTexts(20, function(arr:Array):void { _newestTexts = arr } );
			
			var tweetButton:PushButton = new PushButton(this);
			tweetButton.label = "Tweet Hanabi!";
			tweetButton.alpha = 0.8;
			tweetButton.x = (465 - tweetButton.width) / 2;
            tweetButton.y = (465 - tweetButton.height);
			tweetButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                navigateToURL(new URLRequest("http://twitter.com/home/?status=" 
                    + escapeMultiByte("#hanabi [] http://bit.ly/AAHanabi")
                ));
            });
			
		}
		private var _loader:Loader;
		private function onLoadComplete(e:Event):void {
			addChildAt( _loader.content, 0 ); 
		}
		
		private function shotAA():void
		{
			var text:String = "(・ω・)";
			
			if (_texts != null && _newestTexts != null)
			{
				if (Math.random() > 0.5)
				{
					text = _texts[Math.floor(_texts.length * Math.random())];
				}else
				{
					text = _newestTexts[Math.floor(_newestTexts.length * Math.random())];
				}
			}
			_particles = new Vector.<Object>();
			
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			var format:TextFormat = new TextFormat();
			format.size = 20;
			tf.defaultTextFormat = format;
			tf.text = text;
			var b:BitmapData = new BitmapData(tf.width, tf.height, false);
			b.draw(tf);
			const offsetX:int = 0;
			const offsetY:int = - 45;
			const scale:Number = 20/b.width;
			for (var i:int = 0; i < b.width; i++ )
			{
				for (var j:int = 0; j < b.height; j++ )
				{
					if (b.getPixel(i, j) == 0xFFFFFF) { continue ; }
					
					var direction:Number = Math.random()*Math.PI*2;
					var tx:Number = Math.sin(direction);
					var ty:Number = Math.cos(direction);
					//var sl:Number = Math.random()* radius +2;
					var vl:Number = Math.random()/10;
					
					var p:Object = {
						x:_center.x,
						y:_center.y,
						vx:(i -b.width / 2) *scale + tx*vl,
						vy:(j -b.height / 2) *scale +ty*vl,
						life:Math.random()*30+170
					};
					_particles.push(p);
					
				}
			}
			b.dispose();
			
		}
		
		private static const FRICTION:Number = 0.96;
		private static const GRAVITY:Number = 0.006;
		private static const WIND:Point = new Point(0.001,0 );
		
		private function updateCalcuration():void{
			for each( var p:Object in _particles ) {
				p.vx =  p.vx * FRICTION + WIND.x + Math.random()*0.01-.005;
				p.vy =  p.vy * FRICTION + WIND.y + GRAVITY + Math.random()*0.01-.005;
				p.x = p.x + p.vx;
				p.y = p.y + p.vy;
				p.life--;
			}
		}
		
		private function updateDrawing():void{
			_canvas.colorTransform( _canvas.rect, CTF );
			_canvas.lock();
			for each( var p:Object in _particles ) {
				if( p.life <= 0 ) continue;
				_canvas.setPixel32( p.x, p.y, getColor(p.life) );
			}
			_canvas.unlock();
		}
		 
		private function timerHadler (e:Event):void{
		   updateGradientFill();
			_particles = null;
			//shotFirework();
			shotAA();
		}
		 
		private function getColor(position:int):uint {
			return _gradientMap.getPixel( position, 0 ) | 0xFF000000;
		}
		
		private const CTF:ColorTransform = new ColorTransform( 0.94, 0.94, 0.94, 0.9 );
		private const COLORS:Array = [ 0xFFCCFF, 0xFF9999, 0xFFFF99, 0x99CCFF, 0xCCFF99 ];
		private function updateGradientFill():void {
			var sp:Shape= new Shape();
			var color:uint = COLORS[ Math.random()*COLORS.length>>0];
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(200, 0, 0, 0, 0);
			sp.graphics.beginGradientFill( GradientType.LINEAR,
				[ 0x333333, color, color, color*0.9>>0, 0x000000 ],
				[ 1, 1, 1, 1, 1 ],
				[ 8, 64, 102, 204, 255],
				mtx,
				InterpolationMethod.RGB
			);
			sp.graphics.drawRect( 0, 0, 200, 10 );
			sp.graphics.endFill();
			_gradientMap.draw(sp);
			sp = null;	
		}
		
		private var _canvas:BitmapData;
		private var _center:Point;
		private function init():void{
			_center= new Point();
			_center.x = stage.stageWidth*0.5>>0;
			_center.y = stage.stageHeight*0.5>>0;
			
			_canvas  = new BitmapData( stage.stageWidth, stage.stageHeight, true, 0 );
			addChild( new Bitmap(_canvas) );
			
			setup();
			addEventListener( Event.ENTER_FRAME, enterFrame);
			
			SWFProfiler.init( this );
		}
		private function enterFrame( e:Event ):void {
			updateCalcuration();
			updateDrawing();
		}
		
		public function Sponsor() {
			addEventListener( Event.ADDED_TO_STAGE, addToStage );
		}
		private function addToStage (e:Event):void {
			init();
		}
	}
}
/**
 * @see http://takumakei.blogspot.com/2009/05/actionscriptrubystringscan.html
 */ 
//package com.blogspot.takumakei.utils
//{
	//public
    function scan(str:String, re:RegExp):Array
    {
        if(!re.global){
            var flags:String = 'g';
            
            if(re.dotall)
                flags += 's';
            if(re.multiline)
                flags += 'm';
            if(re.ignoreCase)
                flags += 'i';
            if(re.extended)
                flags += 'x';

            re = new RegExp(re.source, flags);                    
        }

        var r:Array = [];
        var m:Array = re.exec(str);
        while(null != m){
            if(1 == m.length)
                r.push(m[0]);
            else
                r.push(m.slice(1, m.length));
            m = re.exec(str);
        }
        return r;
    }
//}
	