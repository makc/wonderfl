// forked from checkmate's fladdict challenge for professionals
/**
 * Theme:
 * Play with BitmapPatterBuilder.
 * Purpose of this trial is to find the possibility of the dot pattern.
 *
 * by Takayuki Fukatsu aka fladdict
 **/
package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.ColorTransform;
    import frocessing.geom.*;
    import frocessing.color.*;
    
    [SWF(width=465,height=465,frameRate=60,background=0)]
    public class Professional extends Sprite {
        private var fs:Sprite;
        private var gc1:Graphics;
        private var gc2:Graphics;
        private var bg:BitmapData;
        private var ct:ColorTransform;
        
        private var img1:BitmapData;
        private var img2:BitmapData;
        private var next:BitmapData;
        private var pattern:BitmapData;
        private var offset:Number = 0;
        private var step:int = 0;
        
        private var mtx:FMatrix2D;
        private var vx:Number;
        private var vy:Number;
        private var xx:Number;
        private var yy:Number;
        
        public function Professional () {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            //generate bitmap pattern.
            var f1:BitmapData = fig1();
            var f2:BitmapData = fig2();
            img1 = new BitmapData( 16, 24, false, 0 );
            img2 = img1.clone();
            img1.draw( f1, FMatrix2D.translateMatrix( 0, 2) );
            img1.draw( f1, FMatrix2D.translateMatrix( 0, 14) );
            img2.draw( f2, FMatrix2D.translateMatrix( -8, 2) );
            img2.draw( f2, FMatrix2D.translateMatrix( 8, 2) );
            img2.draw( f2, FMatrix2D.translateMatrix( 0, 14) );
            pattern = img1.clone();
            next    = img2;
            
            //view
            bg = new BitmapData( 465, 465, false, 0 );
            addChild( new Bitmap( bg ) );
            
            fs  = new Sprite();
            gc1 = fs.graphics;
            var cs:Shape = fs.addChild(new Shape()) as Shape;
            gc2 = cs.graphics;
            cs.blendMode = "subtract";
            
            ct = new ColorTransform(1, 1, 1, 1, -25, -25, -25);
            
            //geom
            mtx = new FMatrix2D();
            xx = yy = vx = vy = 0;
            
            addEventListener( Event.ENTER_FRAME, update );
        }
        
        private function update( e:Event ):void {
            if ( ++step == 30 ) {
                pattern.copyPixels( next, pattern.rect, pattern.rect.topLeft );
                next = ( next != img1 ) ? img1 : img2;
                offset++;
                step = 0;
            }
            xx += vx = ( mouseX - 232 - xx ) * 0.2;
            yy += vy = ( mouseY - 232 - yy ) * 0.2;
            vx *= 0.95;
            vy *= 0.95;
            var ss:Number = Math.max(1,23-Math.sqrt(xx*xx + yy*yy)/10);
            var ra:Number = Math.atan2(yy, xx) + Math.PI/2*int(offset/4);
            
            mtx.identity();
            mtx.translate( offset*4, 0 );
            mtx.scale( ss, ss );
            mtx.rotate( ra );
            mtx.translate( xx+232, yy+232 );
            
            gc1.clear();
            gc1.beginBitmapFill( pattern, mtx );
            gc1.drawRect(0,0,465,465);
            gc1.endFill();
            
            var c1:uint = 0xffffffff^FColor.HSVtoValue( ra*180/Math.PI, 0.8, 0.5 );
            var c2:uint = 0xffffffff^FColor.HSVtoValue( (ra - Math.PI/1.5)*180/Math.PI, 0.8, 0.5 );
            
            mtx.prependRotation( Math.PI/2 );
            mtx.prependScale( 24*0.0006103515625, 12*0.0006103515625 );
            gc2.clear();
            gc2.beginGradientFill("linear",[c1,0xeeeeee,c2,0xeeeeee],[1,1,1,1],[0,127,128,255],mtx,"repeat");
            gc2.drawRect(0,0,465,465);
            gc2.endFill();
            
            bg.colorTransform( bg.rect, ct );
            bg.draw( fs, null, null, "screen" );
        }
        
        //most simple patern
        public function fig1():BitmapData{
            return BitmapPatternBuilder.build(
                [[0,0,1,0,0,0,0,0,1,0,0],
                 [0,0,0,1,0,0,0,1,0,0,0],
                 [0,0,1,1,1,1,1,1,1,0,0],
                 [0,1,1,0,1,1,1,0,1,1,0],
                 [1,1,1,1,1,1,1,1,1,1,1],
                 [1,0,1,1,1,1,1,1,1,0,1],
                 [1,0,1,0,0,0,0,0,1,0,1],
                 [0,0,0,1,1,0,1,1,0,0,0]],
                [0x00000000, 0xffffffff]
            );
        }
        public function fig2():BitmapData{
            return BitmapPatternBuilder.build(
                [[0,0,1,0,0,0,0,0,1,0,0],
                 [1,0,0,1,0,0,0,1,0,0,1],
                 [1,0,1,1,1,1,1,1,1,0,1],
                 [1,1,1,0,1,1,1,0,1,1,1],
                 [1,1,1,1,1,1,1,1,1,1,1],
                 [0,1,1,1,1,1,1,1,1,1,0],
                 [0,0,1,0,0,0,0,0,1,0,0],
                 [0,1,0,0,0,0,0,0,0,1,0]],
                [0x00000000, 0xffffffff]
            );
        }
    }
}

/**-----------------------------------------------------
 * Use following BitmapPatternBuilder class 
 * 
 * DO NOT CHANGE any codes below this comment.
 *
 * -----------------------------------------------------
*/
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
    
class BitmapPatternBuilder{
    /**
     * creates BitmapData filled with dot pattern.
     * First parameter is 2d array that contains color index for each pixels;
     * Second parameter contains color reference table.
     *
     * @parameter pattern:Array 2d array that contains color index for each pixel.
     * @parameter colors:Array 1d array that contains color table.
     * @returns BitmapData
     */
    public static function build(pattern:Array, colors:Array):BitmapData{
        var bitmapW:int = pattern[0].length;
        var bitmapH:int = pattern.length;
        var bmd:BitmapData = new BitmapData(bitmapW,bitmapH,true,0x000000);
        for(var yy:int=0; yy<bitmapH; yy++){
            for(var xx:int=0; xx<bitmapW; xx++){
                var color:int = colors[pattern[yy][xx]];
                bmd.setPixel32(xx, yy, color);
            }
        }
        return bmd;
    }
    
    /**
     * short cut function for Graphics.beginBitmapFill with pattern.
     */
    public static function beginBitmapFill(pattern:Array, colors:Array, graphics:Graphics):void{
        var bmd:BitmapData = build(pattern, colors);
        graphics.beginBitmapFill(bmd);
        bmd.dispose();        
    }
}