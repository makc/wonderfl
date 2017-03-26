// forked from nutsu's BitmapDataSample11
// forked from nulldesign's Liquid10000
package {
    
    import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.geom.ColorTransform;
    import flash.display.BitmapDataChannel;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import frocessing.core.F5BitmapData2D;    
    
    [SWF(width=465,height=465,backgroundColor=0,frameRate=60)]
    public class F5BitmapDataSample2 extends Sprite {
        
        private var fb:F5BitmapData2D;
        private var colortrans:ColorTransform;
        private var vectormap:BitmapData;
        private var particles:Array;
        private var particle_number:uint = 50;
        private var size:Number = 465;
        
        public function F5BitmapDataSample2() {
            //F5BitmapDataを作成して表示リストに追加
            fb = new F5BitmapData2D( size, size, false, 0 );
            fb.colorMode( "hsv", 1.0 );
            addChild( new Bitmap( fb.bitmapData ) );
            //エフェクト初期化
            colortrans = new ColorTransform( 0.82, 0.82, 0.82 );
            //ベクトルマップとパーティクルの初期化
            vectormap = new BitmapData( size, size, false, 0 );
            reset();
            //イベント
            addEventListener( Event.ENTER_FRAME, enterframe );
            stage.addEventListener( MouseEvent.CLICK, reset );
        }
        
        private function reset( e:MouseEvent = null ):void {
            //ベクトルマップの初期化
            var randomSeed:int = Math.random()*0xFFFFFFFF;
            var colors:uint    = BitmapDataChannel.RED | BitmapDataChannel.GREEN;
            vectormap.perlinNoise( size/2, size/2, 2, randomSeed, false, true, colors );
            //パーティクルの初期化
            var c:uint;
            particles = new Array(particle_number);
            for (var i:int = 0; i < particle_number; i++) {
                if ( Math.random() > 0.05 )
                    c = fb.color( 0.95, 0.6+Math.random()*0.4, 0.5+Math.random()*0.5 );
                else
                    c = 0xffffff;
                particles[i] = new Particle( Math.random()*size, Math.random()*size, c );
            }
            //エフェクト
            fb.bitmapData.colorTransform( fb.bitmapData.rect, colortrans );
        }
        
        private function enterframe( e:Event ):void {
            //描画
            fb.beginDraw();
            for (var i:int = 0; i <particle_number; i++) {
                var p:Particle = particles[i];
                var x0:Number  = p.x;
                var y0:Number  = p.y;
                var vx0:Number = p.vx;
                var vy0:Number = p.vy;
                //加速度と速度の減衰
                p.ax *= 0.58;  p.ay *= 0.58;
                p.vx *= 0.84;  p.vy *= 0.84;
                //ベクトルマップのPixel値から加速度を算出
                var col:uint = vectormap.getPixel( p.x, p.y );
                p.ax += ( (col >> 16 & 0xff) - 128 )*0.02;
                p.ay += ( (col >> 8  & 0xff) - 128 )*0.02;
                //加速度から速度と位置を算出
                var x1:Number = p.x += p.vx += p.ax;
                var y1:Number = p.y += p.vy += p.ay;
                if ( p.x > size )  { p.x -= size; }
                else if ( p.x < 0 ){ p.x += size; }
                if ( p.y > size )  { p.y -= size; }
                else if ( p.y < 0 ){ p.y += size; }
                //線の描画
                var x2:Number = x1 + p.vy / 3;
                var y2:Number = y1 - p.vx / 3;
                var x3:Number = x0 + vy0 / 3;
                var y3:Number = y0 - vx0 / 3;
                fb.noStroke();
                fb.fill( p.color );
                fb.quad( x0, y0, x1, y1, x2, y2, x3, y3 );
                fb.stroke( 0, 0.1 );
                fb.line( x0, y0, x1, y1 );
                fb.line( x2, y2, x3, y3 );
            }
            fb.endDraw();
        }
    }    
}
//パーティクルクラス
class Particle {
    //位置
    public var x:Number;
    public var y:Number;
    //加速度
    public var ax:Number = 0;
    public var ay:Number = 0;
    //速度
    public var vx:Number = 0;
    public var vy:Number = 0;
    //色
    public var color:uint;
    function Particle( px:Number, py:Number, col:uint ) {
        x = px;
        y = py;
        color = col;
    }
}
