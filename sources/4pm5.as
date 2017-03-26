// forked from clockmaker's Liquid110000 By Vector
// forked from munegon's forked from: forked from: forked from: forked from: Liquid10000
// forked from Saqoosha's forked from: forked from: forked from: Liquid10000
// forked from nutsu's forked from: forked from: Liquid10000
// forked from nutsu's forked from: Liquid10000
// forked from zin0086's Liquid10000
package {
    /**
    * マウス判定をつけてみました
    * 参照: http://wonderfl.kayac.com/code/8e43498120fd4403504b7987f73d3274d12f1a42
    * 2万パーティクル
    */    
    import flash.display.*;
    import flash.geom.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.geom.*;
    import net.hires.debug.Stats;
    
    [SWF(backgroundColor="0")];
    public class Liquid extends Sprite {
        private const NUM_PARTICLE:uint = 10000;
        private var bmpData:BitmapData = new BitmapData( 465, 465, false, 0x000000 );
        private var forceMap:BitmapData = new BitmapData( 57, 57, false, 0x000000 );
        private var randomSeed:uint = Math.floor( Math.random() * 0xFFFF );
        private var particleList:Vector.<Particle> = new Vector.<Particle>(NUM_PARTICLE, true);
        private var rect:Rectangle = new Rectangle( 0, 0, 465, 465 );
        private var seed:Number = Math.floor( Math.random() * 0xFFFF );
        private var offset:Array = [new Point(), new Point()];
        private var colorTransform:ColorTransform = new ColorTransform( 0.9, .85, .85, 1.0 );
        private var timer:Timer;
        private var lastMouseX:Number = 0;
        private var lastMouseY:Number = 0;

        public function Liquid() {
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.LOW;
            stage.frameRate = 60;
            
            // 画面に表示用の Bitmap を作ります
            addChild(new Bitmap( bmpData )) as Bitmap;
            
            // フォースマップの初期化をおこないます
            forceMap.perlinNoise( 14, 14, 3, randomSeed, false, true, 1 | 2 | 0 | 0 );
            
            // パーティクルを生成します
            for (var i:uint = 0; i < NUM_PARTICLE; i++) {
                var px:Number = Math.random() * 465;
                var py:Number = Math.random() * 465;
                particleList[i] = new Particle(px, py);
            }
            
            // ループ処理
            addEventListener( Event.ENTER_FRAME, loop );
            
            // 時間差でフォースマップと色変化の具合を変更しています
            timer = new Timer(1000, 0);
            timer.addEventListener(TimerEvent.TIMER, resetFunc);
            timer.start();
            
            // デバッグ用のスタッツを表示しています
            addChild(new Stats);
        }
        
        private function loop( e:Event ):void {
            bmpData.lock();
            bmpData.colorTransform( rect, colorTransform );
            
            var len:uint = particleList.length;
            var col:Number
            
            var sx:Number = 5000 * (mouseX - lastMouseX);
            var sy:Number = 5000 * (mouseY - lastMouseY);
            var dx:Number, dy:Number;
            var dist:Number;
            
            var mx:int = mouseX;
            var my:int = mouseY;
            
            for (var i:uint = 0; i < len; i++) {
                
                var dots:Particle = particleList[i];
                
                // マウスの値を適用
                dx = dots.px - mx;
                dy = dots.py - my;
                dist = dx * dx + dy * dy + 50;
                
                // ここ上手くやれば高速化できそう
                col = forceMap.getPixel( dots.px >> 3,  dots.py >> 3);
                dots.ax += ( (col >> 16 & 0xff) - 128 ) * .0005;
                dots.ay += ( (col >> 8  & 0xff) - 128 ) * .0005;
                dots.vx += dots.ax;
                dots.vy += dots.ay;
                dots.px += dots.vx  + sx / dist;
                dots.py += dots.vy  + sy / dist;

                var _posX:Number = dots.px;
                var _posY:Number = dots.py;
                    
                dots.ax *= .96;
                dots.ay *= .96;
                dots.vx *= .92;
                dots.vy *= .92;
                
                ( _posX > 465 ) ? dots.px = 0 :
                ( _posX < 0 ) ? dots.px = 465 : 0;
                ( _posY > 465 ) ? dots.py = 0 :
                ( _posY < 0 ) ? dots.py = 465 : 0;
                
                bmpData.setPixel( dots.px, dots.py, 0xffffff );
            }
            bmpData.unlock();
            
            lastMouseX = mouseX;
            lastMouseY = mouseY;
        }
        
        private function resetFunc(e:Event):void {
            forceMap.perlinNoise( 14, 14, 3, seed, false, true, 1|2|0|0, false, offset );
            offset[0].x += 1.5;
            offset[1].y += 1.0;    
        }
    }
}

class Particle {
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var ax:Number = 0;
    public var ay:Number = 0;
    public var px:Number;
    public var py:Number;

    function Particle( px:Number, py:Number ) {
        this.px = px;
        this.py = py;
    }
}