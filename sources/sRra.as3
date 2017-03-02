// forked from makc3d's iterations fom zoom?
// forked from makc3d's if you're in that kind of thing...
// forked from jozefchutka's Fast mandelbrot
// forked from makc3d's forked from: マンデルブロ高速化
// forked from toyoshim's マンデルブロ高速化
// forked from toyoshim's マンデルブロ @ Frocessing
package {
    import flash.display.*;
    import flash.text.*;
    import flash.events.*;
//    import frocessing.color.ColorHSV;
//    import net.hires.debug.Stats;

    [SWF(backgroundColor="0x000000", width="465", height="465")]
    public class Mandelbrot extends Sprite
    {
        private var bmp:Bitmap;
        private var img:BitmapData;
        private var bmp2:Bitmap;
        private var img2:BitmapData;
        private var txt:TextField = new TextField;
        
        private var offset_x:Number = 0.0;
        private var offset_y:Number = 0.0;
        private var zoom:Number = 1;
//        private var colors:Vector.<uint> = new Vector.<uint>(256, true);

        public function Mandelbrot()
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            img = new BitmapData(465, 465, false, 0);
            bmp = new Bitmap(img);
            stage.addChild(bmp);
            
            img2 = new BitmapData(465, 465, false, 0);
            bmp2 = new Bitmap(img2);
            stage.addChild(bmp2).x = 465;
            
//            for(var i:uint=0; i < 256; i++)
//                colors[i] = new ColorHSV(i).value32;
            
            draw();
            stage.addEventListener(MouseEvent.CLICK, onClick);
//            stage.addChild(new Stats());
            stage.addChild(txt);
            
            txt.autoSize = "left";
            txt.background = true;
        }

        public function onClick(event:MouseEvent):void
        {
            offset_x = (offset_x + (stage.mouseX % 465) - img.width / 2.0) / zoom;
            offset_y = (offset_y + stage.mouseY - img.height / 2.0) / zoom;
            zoom *= 2;
            offset_x *= zoom;
            offset_y *= zoom;
            
            draw();
        }

        private function draw():void
        {
			// so I'm after perfect iterations(zoom) formula
			var iterations:int = 256 + Math.pow (Math.log (zoom), 4);
			
            var d:Date = new Date;
            img.setVector(img.rect, Fractals.mandelbrot2( 
                img.width, img.height, zoom, offset_x, offset_y, null, iterations));
            img2.setVector(img2.rect, Fractals.mandelbrot3( 
                img2.width, img2.height, zoom, offset_x, offset_y, null, iterations));
            txt.text = iterations + " iterations, " + (new Date().time - d.time) + " ms\n" +
            ((offset_x + img.width * .8 / 3)*2 / img.width / zoom) + " " + 
            ((offset_y + img.height / 2)*2 / img.height / zoom) +"i, zoom: "+zoom;
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
            colors = new <uint> [0xFFFFFF, 0x7F7F7F, 0x7FFFFF, 0x3F7F7F, 0xFF7FFF, 0x7F3F7F, 0xFFFF7F, 0x7F7F3F];
        }

		var len:int = colors.length;
        
        y = height;
        while(y--)
        {
            x = width, cy = (oy - y) * hz;
            while(x--)
            {
                cx = (ox - x) * wz, zx = zy = 0, i = iterations;
				if ((cx + 1) * (cx + 1) + cy * cy < 0.0625) {
					// period-2 bulb
					p++; continue;
				}
				var q:Number = (cx - 0.25) * (cx - 0.25) + cy * cy;
				if (q * (q + (cx - 0.25)) * 4 < cy * cy) {
					// cardioid
					p++; continue;
				}
                while(--i)
                {
                    zxx = zx * zx, zyy = zy * zy;
                    if(zxx + zyy > 4) {
						data[p] = colors[i % len];
                        break;
					}
                    zy = 2 * zx * zy + cy, zx = zxx - zyy + cx;
                }
				p++;
            }
        }
        
        return data;
    }


    public static function mandelbrot3(
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
            colors = new <uint> [0xFFFFFF, 0x7F7F7F, 0x7FFFFF, 0x3F7F7F, 0xFF7FFF, 0x7F3F7F, 0xFFFF7F, 0x7F7F3F];
        }

		var len:int = colors.length;
        
        y = height;
        while(y--)
        {
            x = width, cy = (oy - y) * hz;
            while(x--)
            {
                cx = (ox - x) * wz, zx = zy = 0, i = iterations;
				if ((cx + 1) * (cx + 1) + cy * cy < 0.0625) {
					// period-2 bulb
					p++; continue;
				}
				var q:Number = (cx - 0.25) * (cx - 0.25) + cy * cy;
				if (q * (q + (cx - 0.25)) * 4 < cy * cy) {
					// cardioid
					p++; continue;
				}
				var dzx:Number = 1, dzy:Number = 0;
                while(--i)
                {
					var zdzx:Number = zx * dzx - zy * dzy;
					var zdzy:Number = zy * dzx + zx * dzy;
					dzx = 2 * zdzx + 1;
					dzy = 2 * zdzy;
					
                    zxx = zx * zx, zyy = zy * zy;
                    zy = 2 * zx * zy + cy, zx = zxx - zyy + cx;
					
					var m2:Number = zx * zx + zy * zy;
                    if( m2 > 1234 ) {
						var d:Number = Math.sqrt( m2 / (dzx * dzx + dzy * dzy) ) * 0.5 * Math.log(m2);
						var f:Number = d * zoom * 42 //9999;
						data[p] = colors[int (Math.sqrt (Math.sqrt (f)) * 16) % len];
                        break;
					}
                }
				p++;
            }
        }
        
        return data;
    }
}