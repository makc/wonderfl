// forked from jozefchutka's Fast mandelbrot
// forked from makc3d's forked from: マンデルブロ高速化
// forked from toyoshim's マンデルブロ高速化
// forked from toyoshim's マンデルブロ @ Frocessing
package {
    import flash.display.*;
    import flash.text.*;
    import flash.events.*;
//    import frocessing.color.ColorHSV;
    import net.hires.debug.Stats;

    [SWF(backgroundColor="0x000000")]
    public class Mandelbrot extends Sprite
    {
        private var bmp:Bitmap;
        private var img:BitmapData;
        private var txt:TextField = new TextField;
        
        private var offset_x:Number = 0.0;
        private var offset_y:Number = 0.0;
        private var zoom:Number = 1;
//        private var colors:Vector.<uint> = new Vector.<uint>(256, true);

        public function Mandelbrot()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            img = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0);
            bmp = new Bitmap(img);
            stage.addChild(bmp);
            
//            for(var i:uint=0; i < 256; i++)
//                colors[i] = new ColorHSV(i).value32;
            
            draw();
            stage.addEventListener(MouseEvent.CLICK, onClick);
            stage.addChild(new Stats());
            stage.addChild(txt);
            
            txt.width = 50;
            txt.height = 20;            
            txt.x = stage.stageWidth - txt.width;
            txt.background = true;
        }

        public function onClick(event:MouseEvent):void
        {
            offset_x = (offset_x + stage.mouseX - img.width / 2.0) / zoom;
            offset_y = (offset_y + stage.mouseY - img.height / 2.0) / zoom;
            zoom *= 2;
            offset_x *= zoom;
            offset_y *= zoom;
            
            draw();
        }

        private function draw():void
        {
            var d:Date = new Date;
            img.setVector(img.rect, Fractals.mandelbrot2( 
                img.width, img.height, zoom, offset_x, offset_y, null, 256));
            txt.text = String(new Date().time - d.time) + " ms";
        }
    }
}

class Fractals
{
    public static function mandelbrot2(
        width:uint, height:uint, zoom:Number, offsetX:Number, offsetY:Number,
        colors:Vector.<uint> = null, iterations:uint = 256, bailout:uint = 4):Vector.<uint>
    {
        var x:int, y:int, cx:Number, cy:Number, c:uint, rgb:uint;
        var zx:Number, zy:Number, zxx:Number, zyy:Number, i:int, p:int = 0;
        var wz:Number = 2 / width / zoom;
        var hz:Number = 2 / height / zoom;
        var ox:Number = offsetX + width * .8 / 3;
        var oy:Number = offsetY + height / 2;
        var data:Vector.<uint> = new Vector.<uint>(width * height, true);
        
        if(!colors)
        {
            colors = new Vector.<uint>(iterations, true);
            for(c = 0; c < iterations; c++)
                rgb = 256 / iterations * c, colors[c] = rgb << 16 | rgb << 8 | rgb;
        }
        
        y = height;
        while(y--)
        {
            x = width, cy = (oy - y) * hz;
            while(x--)
            {
                cx = (ox - x) * wz, zx = zy = 0, i = iterations;
				if ((cx + 1) * (cx + 1) + cy * cy < 0.0625) {
					// period-2 bulb
					data[p++] = colors [0]; continue;
				}
				var q:Number = (cx - 0.25) * (cx - 0.25) + cy * cy;
				if (q * (q + (cx - 0.25)) * 4 < cy * cy) {
					// cardioid
					data[p++] = colors [0]; continue;
				}
                while(--i)
                {
                    zxx = zx * zx, zyy = zy * zy;
                    if(zxx + zyy > 4)
                        break;
                    zy = 2 * zx * zy + cy, zx = zxx - zyy + cx;
                }            
                data[p++] = colors[i];
            }
        }
        
        return data;
    }
}