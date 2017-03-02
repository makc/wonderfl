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
    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    
    
    public class Professional extends Sprite {
        public function Professional() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            //generate bitmap pattern.
            var pattern:BitmapData = sample1();
            //var pattern:BitmapData = sample2();
            //var pattern:BitmapData = sample3();
            
            var g:Graphics = graphics;
            g.beginBitmapFill(pattern);
            g.drawRect(0,0,480,480);
            g.endFill();
        }
        
        //most simple patern
        public function sample1():BitmapData{
            return BitmapPatternBuilder.build(
                [[1,0],
                 [0,1]],
                [0xff000000, 0xffffffff]
            );
        }
    
        //larger pattern
        public function sample2():BitmapData{
             return BitmapPatternBuilder.build(
                [[1,0,0,1,],
                 [0,1,1,0,],
                 [0,1,1,0,],
                 [1,0,0,1,]],
                [0xff000000, 0xffffff00]
                );
        }
    
        //complex pattern
        public function sample3():BitmapData{
             return BitmapPatternBuilder.build(
                [[1,1,1,1,1,0],
                 [1,2,2,2,1,0],
                 [1,2,1,2,1,0],
                 [1,2,2,2,1,0],
                 [1,1,1,1,1,0],
                 [0,0,0,0,0,0]],
                [0xff000000, 0xffffffff, 0xffff0000]
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