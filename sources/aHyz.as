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
package 
{
    /**
     * 矢印がいっぱいなんだけど、高速なデモ
     * 画質はディフォルトの StageQuality.HIGH で
     * 矢印 1000個
     * @author Yasu
     */
    import flash.display.*;
    import flash.geom.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.utils.*;
    import flash.geom.*;
    import net.hires.debug.Stats;
    
    [SWF(width="465", height="465", backgroundColor="0xFFFFFF")]
    public class Main extends Sprite {
        private const NUM_PARTICLE:uint = 1000;
        private const ROT_STEPS:int = 128;
        private const ALPHA_STEPS:int = 10;
        
        private var forceMap:BitmapData = new BitmapData( 233, 233, false, 0x000000 );
        private var randomSeed:uint = Math.floor( Math.random() * 0xFFFF );
        private var particleList:Vector.<Arrow> = new Vector.<Arrow>(NUM_PARTICLE, true);
        private var rect:Rectangle = new Rectangle( 0, 0, 465, 465 );
        private var seed:Number = Math.floor( Math.random() * 0xFFFF );
        private var offset:Array = [new Point(), new Point()];
        private var timer:Timer;
        private var world:Sprite = new Sprite();
        private var childrenArr:Vector.<Sprite> = new Vector.<Sprite>(ALPHA_STEPS, true);
        private var rotArr:Vector.<BitmapData> = new Vector.<BitmapData>(ROT_STEPS * ALPHA_STEPS, true);
        private var multiplyConst:Number = 64 / Math.PI;

        public function Main() {
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.frameRate = 60;
            
            addChild(world);
            
            // フォースマップの初期化をおこないます
            resetFunc();
            
            // ループ処理
            addEventListener( Event.ENTER_FRAME, loop );
            
            // 時間差でフォースマップと色変化の具合を変更しています
            var timer:Timer = new Timer(1000)
            timer.addEventListener(TimerEvent.TIMER, resetFunc);
            timer.start();
            
            // 矢印をプレレンダリング
            var dummy:Sprite = new Sprite();
            dummy.graphics.beginFill(0xFF4444, 1);
            dummy.graphics.lineStyle(1, 0x0, 1);
            dummy.graphics.moveTo(2, 4);
            dummy.graphics.lineTo(8, 4);
            dummy.graphics.lineTo(8, 0);
            dummy.graphics.lineTo(20, 7);
            dummy.graphics.lineTo(8, 14);
            dummy.graphics.lineTo(8, 10);
            dummy.graphics.lineTo(2, 10);
            dummy.graphics.lineTo(2, 4);
            var dummyBg:Sprite = new Sprite();
            dummyBg.graphics.beginFill(0x4444FF, 0.5);
            dummyBg.graphics.lineStyle(1, 0x0, 1);
            dummyBg.graphics.moveTo(2, 4);
            dummyBg.graphics.lineTo(8, 4);
            dummyBg.graphics.lineTo(8, 0);
            dummyBg.graphics.lineTo(20, 7);
            dummyBg.graphics.lineTo(8, 14);
            dummyBg.graphics.lineTo(8, 10);
            dummyBg.graphics.lineTo(2, 10);
            dummyBg.graphics.lineTo(2, 4);
            var dummyHolder:Sprite = new Sprite();
            dummyHolder.addChild(dummyBg);
            dummyHolder.addChild(dummy);
            var matrix:Matrix;
            var j:int = ALPHA_STEPS;
            while(j--){
                var i:int = ROT_STEPS;
                var k:int = j * ROT_STEPS;
                var sp: Sprite = new Sprite();
                world.addChild(sp);
                // 忘れがちだけどこれ入れるだけでマウスが乗った時の重さが違う
                sp.mouseChildren = sp.mouseEnabled = false;
                childrenArr[ALPHA_STEPS-1-j] = sp;
                dummy.alpha = j / (ALPHA_STEPS-1);
                dummyBg.filters = [new BlurFilter(4.0*(1.0 - j / (ALPHA_STEPS-1)),4.0*(1.0 - j / (ALPHA_STEPS-1)))];
                dummy.filters = [new BlurFilter(4.0*(1.0 - j / (ALPHA_STEPS-1)),4.0*(1.0 - j / (ALPHA_STEPS-1)))];
                while (i--)
                {
                    matrix = new Matrix();
                    matrix.translate( -11, -11);
                    matrix.rotate( ( 360 / ROT_STEPS * i )* Math.PI / 180);
                    matrix.translate( 11, 11);
                    rotArr[i+k] = new BitmapData(22, 22, true, 0x0);
                    rotArr[i+k].draw(dummyHolder, matrix);
                }
            }
            
            // パーティクルを生成します
            for (i = 0; i < NUM_PARTICLE; i++) {
                var px:Number = Math.random() * 465;
                var py:Number = Math.random() * 465;
                particleList[i] = new Arrow(px, py);
                world.addChild(particleList[i]);
            }
            
            // デバッグ用のスタッツを表示しています
            addChild(new Stats);
        }
        private function loop( e:Event ):void {
            
            var len:uint = particleList.length;
            var col:Number;
//            var changedCount:int = 0;
            for (var i:uint = 0; i < len; i++) {
                
                var arrow:Arrow = particleList[i];
                
                var oldX:Number = arrow.x;
                var oldY:Number = arrow.y;
                
                col = forceMap.getPixel( arrow.x >> 1, arrow.y >> 1);
                arrow.ax += ( (col      & 0xff) - 0x80 ) * .0005;
                arrow.ay += ( (col >> 8 & 0xff) - 0x80 ) * .0005;
                arrow.vx += arrow.ax;
                arrow.vy += arrow.ay;
                arrow.x += arrow.vx;
                arrow.y += arrow.vy;
                
                var _posX:Number = arrow.x;
                var _posY:Number = arrow.y;
                
                // rot成分
                // var rot:Number = - Math.atan2((_posX - oldX), (_posY - oldY)) * 180 / Math.PI + 90;
                // var angle:int = rot / 360 * ROT_STEPS | 0;
                // Math.absの高速化ね
                // angle = (angle ^ (angle >> 31)) - (angle >> 31);
                // angle = (angle + 130) & 119; // (angle + 130) % 120 の高速化
                // ↑これ & 2^n-1 になるときでないと使えないと思う
                // angle = (angle + 130) % 120;
                // arrow.rot += (angle - arrow.rot) * 0.2;
                
                // 計算式を簡単にしてみたのとビット演算使えるようにかえてみた
		var rot:Number = Math.atan2( arrow.vy, arrow.vx );
		arrow.rot = (128 + rot * multiplyConst) & 127;
                
                // alpha成分
                var speed:int = (arrow.vx*arrow.vx + arrow.vy*arrow.vy) >> 1; // *0.5
                speed = Math.min(ALPHA_STEPS-1, speed);
                arrow.bitmapData = rotArr[arrow.rot + ROT_STEPS * speed];

                // speedに応じてソート。これが重い
                // こんなのはどうだろう？
                // fps 29-31
                // Sprite(world.getChildAt(speed)).addChild(arrow);

                // fps 30-33
                // childrenArr[speed].addChild(arrow);
                
                // fps 35-38
                //if( arrow.parent != world.getChildAt(speed) )
                //    Sprite(world.getChildAt(speed)).addChild(arrow);
                    
                // fps 37-39
                if( arrow.parent != childrenArr[speed] )
                    childrenArr[speed].addChild(arrow);
//                    changedCount++;
                
                arrow.ax *= .96;
                arrow.ay *= .96;
                arrow.vx *= .92;
                arrow.vy *= .92;
                
                // あと配置座標を整数化しておきます
                arrow.x = arrow.x | 0;
                arrow.y = arrow.y | 0;
                
                ( _posX > 465 ) ? arrow.x = 0 :
                    ( _posX < 0 ) ? arrow.x = 465 : 0;
                ( _posY > 465 ) ? arrow.y = 0 :
                    ( _posY < 0 ) ? arrow.y = 465 : 0;
            }
//            trace( changedCount ); // 大体100-150, 多いときで250程度
        }
        
        private function resetFunc(e:Event = null):void{
            forceMap.perlinNoise(117, 117, 3, seed, false, true, 6, false, offset);
            
            offset[0].x += 1.5;
            offset[1].y += 1;
            seed = Math.floor( Math.random() * 0xFFFFFF );
        }
    }
}

import flash.display.*;

class Arrow extends Bitmap
{
    public var rot:int = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var ax:Number = 0;
    public var ay:Number = 0;

    function Arrow( x:Number, y:Number) {
        this.x = x;
        this.y = y;
    }
}