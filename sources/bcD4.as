// forked from Nao_u's forked from: Peak beta 1
// forked from shaktool's Peak beta 1
// forked from shaktool's Peak
// borrowed some code from psyark's BumpyPlanet:
// http://wonderfl.net/c/uLoH

package {
  import flash.display.*;
  import flash.events.*;
  import flash.filters.*;
  import flash.geom.*;
  import flash.text.*;
  import flash.utils.*;
  
  [SWF(width=465, height=465, frameRate=24, backgroundColor=0x000000)]
  public class Peak extends Sprite {
    private var maskMap:BitmapData = new BitmapData(230,230,false,0);
    private var heightMap:BitmapData = new BitmapData(230,230,false,0);
    private var pos: Bitmap = new Bitmap(heightMap);
    private var pos2: Bitmap = new Bitmap(maskMap);
    var palette: Array = new Array(256);

    public var Tbl:Array = new Array;
    public function Peak() {
        stage.addEventListener(Event.ENTER_FRAME , generate); 
            
        Tbl[0] = new Point;
        Tbl[1] = new Point;
        Tbl[2] = new Point;
        Tbl[3] = new Point;

        // 下地
        pos.scaleX = 2.0;
        pos.scaleY = 2.0;
        addChild(pos);

        // マスク
        pos2.scaleX = 2.0;
        pos2.scaleY = 2.0;
        pos2.blendMode = "multiply";
        addChild(pos2);

      // カラー変換テーブル
      var v:int;
      for (var i:int = 0; i < 256; i++) {
         v = (i+48)*1.1 - 140;
        v += 128;
        if( v < 0 ) v = 0;
        if( v > 255 ) v = 255;
      	palette[i] = (v<<16) + (v<<8) + v;
      }

        // マスクの生成
        maskMap.perlinNoise(50,50,4,0,true,true, 4, true);

        var col:int, r:int, g:int, b:int;        
        var mul:Number, dx:Number, dy:Number, dist:Number;
        var radius:Number = 130;
        for( var x:int=0; x<230; x++ ){ 
            for( var y:int=0; y<230; y++ ){ 
                dx = Math.abs(115-x);
                dy = Math.abs(115-y);
                dist = Math.sqrt( dx*dx + dy*dy );
                if( dist > radius ) dist = radius;
                mul = (radius - dist) / radius;
                mul = mul;
                col = maskMap.getPixel(x,y);
                r = (col>>16)&0xff;
                g = (col>>8)&0xff;
                b = col & 0xff;
                r = r * 0.5 + 1024 * mul * mul;
                g = g * 0.5 + 1024 * mul * mul;
                b = b * 0.5 + 1024 * mul * mul;
                if( r > 255 ) r = 255;
                if( g > 255 ) g = 255;
                if( b > 255 ) b = 255;
                r *= mul;
                g *= mul;
                b *= mul;
                col = (r<<16) + (g<<8) + b;
                maskMap.setPixel(x,y, col );
            }
        }
    }
    public function generate(event: Event): void {
      // それぞれのレイヤーのスクロール速度
      Tbl[0].x += 0.1;
      Tbl[0].y += 0.35;
      Tbl[1].x += -0.35;
      Tbl[1].y += 1.05;
      Tbl[2].x +=-0.05;
      Tbl[2].y += 0.825;
      Tbl[3].x += 0.1;
      Tbl[3].y += 0.455;
      heightMap.perlinNoise(50,50,4,0,true,true, 4, false, Tbl);
      
      // solarize:
      heightMap.paletteMap(heightMap, new Rectangle(0,0,heightMap.width,heightMap.height), new Point(0,0), null, null, palette, null);
      
    }
  }
}

