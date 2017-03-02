// forked from wonderwhyer's Northern Light
package {
    import flash.filters.BlurFilter;
    import flash.display.Graphics;
    import flash.display.BitmapData;
    import flash.geom.Point;
    import flash.geom.ColorTransform;
    import flash.display.Bitmap;
    import flash.geom.Matrix;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.display.GradientType;
    import flash.display.BlendMode;
    
    
    [SWF(width="600",height="400",frameRate="30",backgroundColor="#000000")]
    public class NorthLight extends Sprite {

        private var disMap:BitmapData;
        private var res:BitmapData;
        private var bmp2:Bitmap;
        private var bmp:Bitmap;
        private var sp:Sprite;
        private var ct:ColorTransform;
        private var ct2:ColorTransform ;
        private var m:Matrix;
        private var offsets:Array = [new Point(0,0),new Point(0,0),new Point(0,0),];
        
        //params to play with ********************************************************
        private var treshold:int = 50;
        private var oct:int = 3;
        private var baseX:Number = 80;
        private var baseY:Number = 80;
        private var fractal:Boolean = false;
        private var speeds:Array = [new Point(-0.1,-0.6),new Point(-0.6,-0.3),new Point(0.4,-0.8)];
        private var colors:int = 11;
        private var zshift:Number = -2;
        private var blur:BlurFilter = new BlurFilter(2,8,3);
        private var fade:Number = 0.9;
        //*****************************************************************************
        
        
        public function NorthLight() {
            disMap = new BitmapData(300,150,true,0);
            res = disMap.clone();
            bmp2 = new Bitmap(disMap);
            bmp = new Bitmap(res);
            bmp.scaleX=5;
            bmp.scaleY=5;
            bmp.x=-450;
            bmp2.rotationX=80;
            sp = new Sprite();
            sp.addChild(bmp2);
            addChildAt(bmp,0);
            ct = new ColorTransform(0.5,0.5,0.5,-0.5,0,0,0,255);
            bmp.rotationX = 80;
            ct2 = new ColorTransform(fade,fade,fade,fade,0,0,0,0);
            m = new Matrix(5,0,0,5,-450,0);
            addEventListener(Event.ENTER_FRAME,frame);
            
            var sp:Sprite = new Sprite();
            var g:Graphics = sp.graphics;
            var m:Matrix = new Matrix();
            m.createGradientBox(600,50,Math.PI/2,0,121);
            g.beginGradientFill(GradientType.LINEAR,[0,0],[0,1],[50,255],m);
            g.drawRect(0,121,600,50);
            addChild(sp);
        }
        
        private function frame(evt:Event):void{
            for(var i:uint=0;i<speeds.length;i++){
                offsets[i].x+=speeds[i].x;
                offsets[i].y+=speeds[i].y;
            }

            disMap.perlinNoise(baseX, baseY, oct, 1, false, fractal, colors , false, offsets);            
            disMap.threshold(disMap,disMap.rect,new Point(),">",treshold<<24,0,0xFF000000);
            disMap.colorTransform(disMap.rect,ct);
            res.scroll(0,zshift);
            res.colorTransform(res.rect,ct2);
            res.draw(bmp2,null,null,BlendMode.ADD);
            res.applyFilter(res,res.rect,res.rect.topLeft,blur); 
        }
    }
    
    
    
}