// forked from clockmaker's Interactive Liquid 10000
// forked from clockmaker's Liquid110000 By Vector
// forked from munegon's forked from: forked from: forked from: forked from: Liquid10000
// forked from Saqoosha's forked from: forked from: forked from: Liquid10000
// forked from nutsu's forked from: forked from: Liquid10000
// forked from nutsu's forked from: Liquid10000
// forked from zin0086's Liquid10000
package {
    /**
    * 3D にしてみました
    * 500パーティクル
    */    
    import flash.display.*;
    import flash.geom.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.geom.*;
    import net.hires.debug.Stats;
    
    public class Liquid3D extends Sprite {
        private const NUM_PARTICLE:uint = 500;
        private var bmpData:BitmapData = new BitmapData( 465, 465, false, 0x000000 );
        private var forceMap:BitmapData = new BitmapData( 233, 233, false, 0x000000 );
        private var randomSeed:uint = Math.floor( Math.random() * 0xFFFF );
        private var particleList:Vector.<Particle> = new Vector.<Particle>(NUM_PARTICLE, true);
        private var rect:Rectangle = new Rectangle( 0, 0, 465, 465 );
        private var seed:Number = Math.floor( Math.random() * 0xFFFF );
        private var offset:Array = [new Point(), new Point()];
        private var colorTransform:ColorTransform = new ColorTransform( 0.85, .92, .92, 1.0 );
        private var timer:Timer;
        private var world:Sprite = new Sprite();

        public function Liquid3D() {
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.LOW;
            stage.frameRate = 60;
            
            // 画面に表示用の Bitmap を作ります
            addChild(new Bitmap( bmpData )) as Bitmap;
            //addChild(new Bitmap( forceMap )) as Bitmap;
            
            // フォースマップの初期化をおこないます
            resetFunc();
            
            // パーティクルを生成します
            for (var i:uint = 0; i < NUM_PARTICLE; i++) {
                var px:Number = Math.random() * 465;
                var py:Number = Math.random() * 465;
                var pz:Number = Math.random() * 465 * 2 - 465;
                particleList[i] = new Particle(px, py, pz);
                world.addChild(particleList[i]);
            }
            
            // ループ処理
            addEventListener( Event.ENTER_FRAME, loop );
            
            // 時間差でフォースマップと色変化の具合を変更しています
            var timer:Timer = new Timer(500)
            timer.addEventListener(TimerEvent.TIMER, resetFunc);
            timer.start();
            
            // デバッグ用のスタッツを表示しています
            addChild(new Stats);
        }
        
        private function loop( e:Event ):void {
            
            var len:uint = particleList.length;
            var col:Number
            
            for (var i:uint = 0; i < len; i++) {
                
                var dots:Particle = particleList[i];
                
                col = forceMap.getPixel( dots.x >> 1, dots.y >> 1);
                dots.ax += ( (col >> 8 & 0xff) - 128 ) * .0005;
                dots.ay += ( (col >> 4  & 0xff) - 128 ) * .0005;
                dots.az += ( (col >> 16  & 0xff) - 128 ) * .0005;
                dots.vx += dots.ax;
                dots.vy += dots.ay;
                dots.vz += dots.az;
                dots.x += dots.vx;
                dots.y += dots.vy;
                dots.z += dots.vz;

                var _posX:Number = dots.x;
                var _posY:Number = dots.y;
                var _posZ:Number = dots.z;
                    
                dots.ax *= .95;
                dots.ay *= .95;
                dots.az *= .95;
                dots.vx *= .90;
                dots.vy *= .90;
                dots.vz *= .90;
                
                ( _posX > 465 ) ? dots.x = 0 :
                    ( _posX < 0 ) ? dots.x = 465 : 0;
                ( _posY > 465 ) ? dots.y = 0 :
                    ( _posY < 0 ) ? dots.y = 465 : 0;
                ( _posZ > 465 ) ? dots.z = -465 :
                    ( _posZ < -465 ) ? dots.z = 465 : 0;
            }
            
            bmpData.colorTransform(rect, colorTransform);
            bmpData.draw(world);
        }
        
        private function resetFunc(e:Event = null):void{
            forceMap.perlinNoise(233, 233, 3, seed, false, false, 1|2|4|0, false, offset );
            offset[0].x += 1.5;
            offset[1].y += 1;
            seed = Math.floor( Math.random() * 0xFFFFFF );
        }
    }
}

import flash.display.Sprite;

class Particle extends Sprite{
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var vz:Number = 0;
    public var ax:Number = 0;
    public var ay:Number = 0;
    public var az:Number = 0;

    function Particle( x:Number, y:Number, z:Number ) {
        this.x = x;
        this.y = y;
        this.z = z;
        
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect( -1, -1, 2, 2);
    }
}