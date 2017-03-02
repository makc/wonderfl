// forked from clockmaker's Arrows Flow Simulation
// forked from nemu90kWw's BitmapData直描きにすれば残像付きでも超軽いよ
// forked from nemu90kWw's 画像をトリミングしてみた（中心点未調整）
// forked from keno42's ちょっと変えたけどそんなに速くならなかった
// forked from keno42's forked from: forked from: 速度比較したら一個前の方法が速かったっぽい
// forked from keno42's forked from: 速度比較したら一個前の方法が速かったっぽい
// forked from keno42's 速度比較したら一個前の方法が速かったっぽい
// forked from bkzen's forked from: 色と透明度もいれてみた。こんなのどうだろバージョン
// forked from bkzen's 色と透明度もいれてみた。速度向上したらいいなばーじょん
// forked from keno42's 角度計算修正、色と透明度もいれてみた。重ね順ソートが重い。
// forked from bkzen's forked from: BitmapDataで配列に格納すると高速化するよ(角度修正)
// forked from clockmaker's BitmapDataで配列に格納すると高速化するよ
// forked from clockmaker's 3D Flow Simulation with Field of Blur
// forked from clockmaker's 3D Flow Simulation
// forked from clockmaker's Interactive Liquid 10000
// forked from clockmaker's Liquid110000 By Vector
// forked from munegon's forked from: forked from: forked from: forked from: Liquid10000
// forked from Saqoosha's forked from: forked from: forked from: Liquid10000
// forked from nutsu's forked from: forked from: Liquid10000
// forked from nutsu's forked from: Liquid10000
// forked from zin0086's Liquid10000
package {
        //
    import flash.display.*;
    import flash.geom.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.utils.*;
    import flash.geom.*;
    //import net.hires.debug.Stats;    
    
    [SWF(width="465", height="465", backgroundColor="0x0", frameRate="90")]
    public class Main extends Sprite {
        
        private var forceMap:BitmapData = new BitmapData( 233, 233, false, 0x000000 );
        private var randomSeed:uint = Math.floor( Math.random() * 0xFFFF );
        private var seed:Number = Math.floor( Math.random() * 0xFFFF );
        private var offset:Array = [new Point(), new Point()];
        private var timer:Timer;
        private var buffer:BitmapData = new BitmapData(465, 465, false, 0);
        private var screen:Bitmap = new Bitmap(buffer);
        private var particleList:Array = [];
        
        function Main()
        {
            // フォースマップの初期化をおこないます
            resetFunc();
            
            // ループ処理
            addEventListener( Event.ENTER_FRAME, loop );
            
            // 時間差でフォースマップと色変化の具合を変更しています
            var timer:Timer = new Timer(1000);
            timer.addEventListener(TimerEvent.TIMER, resetFunc);
            timer.start();
            
            // 矢印をプレレンダリング
            var dummy:Sprite = new Sprite();
            var dummyBg:Sprite = new Sprite();
            var dummyHolder:Sprite = new Sprite();
            dummy.graphics.beginFill(0x003399, 1);
            dummy.graphics.drawPath(Vector.<int>([1,2,2,2,2,2,2,2]), Vector.<Number>([-9,-7,-3,-7,-3,-11,9,-4,-3,3,-3,-1,-9,-1,-9,-7]));
                        /*
            dummyBg.graphics.beginFill(0x0, 1);
            dummyBg.graphics.lineStyle(1, 0x0, 1);
            dummyBg.graphics.drawPath(Vector.<int>([1,2,2,2,2,2,2,2]), Vector.<Number>([-9,-7,-3,-7,-3,-11,9,-4,-3,3,-3,-1,-9,-1,-9,-7]));
            dummyHolder.addChild(dummyBg);
                        */
            dummyHolder.addChild(dummy);
                        dummy.scaleX = dummy.scaleY = 0.7;
            
            var temp:BitmapData;
            var rect:Rectangle;
            var matrix:Matrix = new Matrix();
            var j:int = ALPHA_STEPS;
            while(j--) {
                var i:int = ROT_STEPS;
                var k:int = j * ROT_STEPS;
                dummy.alpha = j / (ALPHA_STEPS-1);
                dummy.filters = dummyBg.filters = [new BlurFilter(4.0*(1.0 - j / (ALPHA_STEPS-1)),4.0*(1.0 - j / (ALPHA_STEPS-1)),3)];
                while (i--) {
                    matrix.identity();
                    matrix.rotate( ( 360 / ROT_STEPS * i )* Math.PI / 180);
                    matrix.translate(11, 11);
                    temp = new BitmapData(22, 22, true, 0x0);
                    temp.draw(dummyHolder, matrix);
                    rotArr[i+k] = new DisplayImage(temp, 11, 11);
                }
            }
            
            // パーティクルを生成します
            for (i = 0; i < NUM_PARTICLE; i++) {particleList[i] = new Arrow(Math.random() * 465, Math.random() * 465);}
            addChild(screen);
            
            // デバッグ用のスタッツを表示しています
            //addChild(new Stats);                                                    
        }
        private var _blkBmpd:BitmapData = new BitmapData(465,465,true,0x08);
                private var _destPoint:Point = new Point();
                private var _blurFilter:BlurFilter = new BlurFilter(8,8);
                private var _drawBmpd:BitmapData;
        private function loop( e:Event ):void {
            var len:int = particleList.length;
            var arrow:Arrow;
            buffer.lock();
            
                        //buffer.draw(_blkBmpd);
                        buffer.applyFilter(buffer, buffer.rect, _destPoint, _blurFilter);
                        buffer.colorTransform(buffer.rect, new ColorTransform(1, 1, 1, 1, 20, 10, 10, 0));
                        
            particleList.sortOn("speed", Array.NUMERIC);
            for (var i:int = 0; i < len; i++) {
                arrow = particleList[i];
                arrow.step(forceMap.getPixel( arrow.x >> 1, arrow.y >> 1));
                buffer.copyPixels(arrow.img.bmp, arrow.img.bmp.rect, new Point(arrow.x-arrow.img.cx, arrow.y-arrow.img.cy));
            }
            buffer.unlock();
        }
        
        private function resetFunc(e:Event = null):void {
            forceMap.perlinNoise(117, 117, 3, seed, false, true, 6, false, offset);
            
            offset[0].x += 1.5;
            offset[1].y += 1;
            seed = Math.floor( Math.random() * 0xFFFFFF );
        }
    }
}

import flash.display.*;
import flash.geom.*;

const NUM_PARTICLE:uint = 2000;
const ROT_STEPS:int = 128;
const ALPHA_STEPS:int = 20;
var rotArr:Vector.<DisplayImage> = new Vector.<DisplayImage>(ROT_STEPS * ALPHA_STEPS, true);
var multiplyConst:Number = 64 / Math.PI;

class DisplayImage {
    
    public var bmp:BitmapData;
    public var rect:Rectangle;
    public var cx:int, cy:int;
    
    function DisplayImage(bmp:BitmapData, cx:int, cy:int) {
        this.bmp = bmp;
        this.rect = bmp.rect;
        this.cx = cx;
        this.cy = cy;
        trimming();
    }
    
    private function trimming():void {
        var rect:Rectangle = bmp.getColorBoundsRect(0xFF000000, 0x00000000);
        var temp:BitmapData = new BitmapData(rect.width, rect.height, true, 0x00000000);
        cx -= rect.x;
        cy -= rect.y;
        temp.copyPixels(bmp, rect, new Point(0, 0));
        bmp = temp;
    }
}

class Arrow {
    
    public var img:DisplayImage;
    public var x:int, y:int;
    public var vx:Number = 0, vy:Number = 0, ax:Number = 0, ay:Number = 0;
    public var rot:int = 0, speed:int = 0;
    
    function Arrow(x:int, y:int) {
        this.x = x;
        this.y = y;
    }
    
    public function step(col:uint):void {
        ax += ( (col      & 0xff) - 0x80 ) * .0005;
        ay += ( (col >> 8 & 0xff) - 0x80 ) * .0005;
        vx += ax;
        vy += ay;
        x += vx;
        y += vy;
        
        var dir:Number = Math.atan2( vy, vx );
        rot = (128 + dir * multiplyConst) & 127;
        speed = Math.min(ALPHA_STEPS-1, (vx*vx + vy*vy) >> 1); // *0.5
        img = rotArr[rot + ROT_STEPS * speed];
        
        ax *= .96;
        ay *= .96;
        vx *= .92;
        vy *= .92;
        
        ( x > 465 ) ? x = 0 : ( x < 0 ) ? x = 465 : 0;
        ( y > 465 ) ? y = 0 : ( y < 0 ) ? y = 465 : 0;
    }
}