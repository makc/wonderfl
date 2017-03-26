// forked from checkmate's Checkmate vol4 Massmedian
/*
 * BGM: 夢いっぱいの箱
 *      フリー音楽素材 H/MIX GALLERY
 *      http://www.hmix.net/
 */
package {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.geom.*;
    
    import flash.media.Sound;
    import flash.media.SoundMixer;
    import flash.media.SoundChannel;
    import flash.utils.ByteArray;
    import flash.system.Security;
    
    [SWF(width="465", height="465", frameRate="60", backgroundColor="0x00")]
    public class FlashTest extends Sprite {
        /*
         * [Checkmate Vol4 by MASSMEDIAN]
         * Please produce the illumination freely with a color palette. 
         *
         * usage of Palette class
         *   A single value is used.
         *     var white:uint = Palette.WHITE;
         *     var green:uint = Palette.GREEN;
         *     var red:uint = Palette.RED;
         *     var gold:uint = Palette.GOLD;
         *     var silver:uint = Palette.SILVER;
         *     var black:uint = Palette.BLACK;
         *   All the values are used.
         *     var colors:Array = Palette.getColors();
         */
        private function init( e:Event = null ):void {
            resize();
            //drawXmasTree()
            createSnow();
            //showPaletteMap();
            loadSound();
        }
        
        public var rect:Rectangle= new Rectangle();
        public var center:Point = new Point();
        
        private const SLOW_LENGTH:int = 1000;
        private var _snow:Vector.<Snow> = new Vector.<Snow>();
        
        private var _twincles:BitmapData;
        private var _canvas:BitmapData;
        
        private var _matrix:Matrix;
        private var _ctf:ColorTransform = new ColorTransform( 0.75, 0.8, 0.8, 0.95 );
        
        private const COLORS:Array = Palette.getColors();
        private var s:Sound;
        private const star:Array = [
            [0, 0, 0, 0, 1, 0, 0, 0, 0],
            [0, 0, 0, 0, 1, 0, 0, 0, 0],
            [0, 0, 0, 1, 1, 1, 0, 0, 0],
            [1, 1, 1, 1, 1, 1 ,1 ,1 ,1],
            [0, 1, 1, 1, 1, 1, 1, 1, 0],
            [0, 0, 1, 1, 1, 1, 1, 0, 0],
            [0, 0, 1, 1, 1, 1, 1, 0, 0],
            [0, 1, 1, 1, 0, 1, 1, 1, 0],
            [0, 1, 0, 0, 0, 0, 0, 1, 0]];
        
        private function createSnow():void {
            // The value used for generation is prepared.
            const RADIAN:Number = Math.PI*2;
            
            // The canvas to draw in illumination.
            var snow:Snow, speed:Number, angle:Number;
            for( var i :int = 0; i<SLOW_LENGTH; ++i ) {
                snow = new Snow();
                snow.x   = (Math.random()-0.5)*50 + center.x;
                snow.y   = Math.random()*rect.height;
                snow.vx = (Math.random()-0.5) * 4;
                snow.vy = Math.random()*-2;
                snow.color = Palette.WHITE;
                _snow.push( snow );
            }
            
            // The canvas to draw in illumination.
            _canvas = new BitmapData( rect.height, rect.height, true, 0 );
            var cbm :Bitmap = addChild( new Bitmap( _canvas ) ) as Bitmap;
            cbm.smoothing = true;
            
            // The canvas to draw in twincles.
            _twincles = new BitmapData( rect.width/4>>0, rect.height/4>>0, true, 0 );
            var tbm:Bitmap = addChild( new Bitmap( _twincles ) ) as Bitmap;
            tbm.scaleX = tbm.scaleY = 4;
            tbm.smoothing = true;
            tbm.blendMode = BlendMode.ADD;
            
            // Matrix to draw by size of 1/4
            _matrix = new Matrix(0.25, 0, 0, 0.25);
        }
        
        private function updateSnow(e:Event):void {
            _canvas.lock();
            for each( var snow:Snow in _snow ) {
                // The Brownian motion is added.
                snow.vx += (Math.random()-0.5)*0.04;
                snow.vy += (Math.random()-0.5)*0.04;
                
                // Gravity is added.
                snow.vy += 0.015;
                
                // The wind drag is added.
                snow.vx *= 0.987;
                snow.vy *= 0.987;
                
                // The speed is added to the position. 
                snow.x += snow.vx;
                snow.y += snow.vy;
                
                // draw to canvas in position.
                _canvas.setPixel32( snow.x, snow.y, snow.color | 0xFF<<24 );
                
                // It resets it when going out of the area. 
                if( snow.x < rect.x -50 ||  snow.y < rect.y -50 || snow.x > rect.width +50 || snow.y > rect.height + 50 ) {
                    snow.x = center.y + (Math.random() -0.5) * 10;
                    snow.y = Math.random() *-30;
                    snow.vx = (Math.random() -0.5) * 3;
                    snow.vy = Math.random() *-3;
                }
            }
            
            const OY:uint = 80;
            var ba:ByteArray = new ByteArray();
            SoundMixer.computeSpectrum(ba, false, 0);
            drawTree(ba, OY, true);//left
            drawTree(ba, OY, false);//right
			
            // draw star
            for (var j:uint = 0; j < 9; j++) {
                for (var i:uint = 0; i < 9; i++ ) {
                    if (star[j][i]) {
                        _canvas.setPixel32( i*4+2+center.x-8*4/2, j*4+2+OY, Palette.GOLD | 0xFF<<24 );
                    }
                }
            }
			
            // ColorTransform(effect that dose blackout) is made to adjust. 
            _canvas.colorTransform( _canvas.rect, _ctf );
            _canvas.unlock();
            
             // draw to canvas in twincles by using Matrix.
            _twincles.draw( _canvas, _matrix );
        }
        
        private function drawTree(ba:ByteArray, oy:uint, lr:Boolean):void {
	    const H:int = 100;
	    var spectrum:Number = 0;
	    for (var j:uint = 0; j < 256; j++) {
		    if((ba.position/ba.length-1)) spectrum = (j/256)*ba.readFloat() * H + j/20;
		    for (var i:uint = 0; i < spectrum ; i++) {
		        lr?
		        _canvas.setPixel32( int(-i*4+2+center.x), int(j+32+oy), COLORS[int(COLORS.length * Math.random())] | 0xFF << 24 ):
		        _canvas.setPixel32( int(i*4+2+center.x), int(j+32+oy), COLORS[int(COLORS.length * Math.random())] | 0xFF << 24 );
		    }
	    }
	}
        
        
        private function resize( e:Event = null ):void {
            rect.width = stage.stageWidth;
            rect.height= stage.stageHeight;
            
            center.x = rect.width /2>>0;
            center.y = rect.height /2>>0;
        }
        
        private function drawXmasTree():void {
            var loader :Loader = new Loader();
            addChild( loader );
            loader.load( new URLRequest("http://swf-dev.wonderfl.net/static/assets/checkmate04/tree.jpg") );
        }
        private function showPaletteMap():void {
            var colors:Array = Palette.getColors();
            var palette:Sprite = addChild( new ColorMap( colors ) ) as Sprite;
            palette.x = ( rect.width - palette.width )  /2 >>0;
            palette.y = ( rect.height- palette.height ) /2 >>0;
        }
        
        public function FlashTest() {
            if( stage ) init();
            else addEventListener( Event.ADDED_TO_STAGE, init );
        }
        
        private function loadSound():void {
	    Security.loadPolicyFile("http://flash-scope.com/wonderfl/crossdomain.xml");
	    s = new Sound();
	    var sc:SoundChannel = new SoundChannel();
	    s.addEventListener(Event.COMPLETE, function(e:Event):void{
	        sc = s.play(0,9999);
			//sc.stop();
			addEventListener( Event.ENTER_FRAME, updateSnow );
	    });
	    s.load(new URLRequest("http://flash-scope.com/wonderfl/ChristmasSpectrum/o13.mp3"));
	}
    }
}
/* for Checkmate */
class Palette {
    public static const WHITE:uint = 0xF0F0F0;
    public static const GREEN:uint = 0x008800;
    public static const RED:uint = 0xCC0000;
    public static const GOLD:uint = 0xFFCC66;
    public static const SILVER:uint = 0xCCCCCC;
    public static const BLACK:uint = 0x101010;
    public static const COLORS:Array = [ WHITE, GREEN,  RED, GOLD, SILVER, BLACK ];
    public static function getColors():Array { return COLORS.slice(); }
}
/* for Example. */
class Snow {
    public var x:Number = 0;
    public var y:Number = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var color:uint = 0x00;
}
/* for debug. */
import flash.display.*;
class ColorMap extends Sprite {
    public function ColorMap(colors:Array) {
        var l:int = colors.length;
        var rect:Sprite;
        for( var i:int=0; i<l; ++i ) {
            addChild( rect = new ColorRect( colors[ i ] ) );
            rect.x =i * ColorRect.WIDTH;
            rect.y =0;
        }
    }
}
/* for debug. */
class ColorRect extends Sprite {
    public static const WIDTH:int = 40;
    public static const HEIGHT:int = 40;
    public function ColorRect( color:uint ) {
        super();
        graphics.beginFill( color, 1 );
        graphics.drawRect( 0, 0, WIDTH, HEIGHT );
        graphics.endFill();
    }
}
