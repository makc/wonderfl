// forked from nulldesign's Liquid10000
package {
    
    import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.geom.ColorTransform;
    import flash.display.BitmapDataChannel;
    import flash.filters.BlurFilter;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    [SWF(width=465,height=465,backgroundColor=0,frameRate=60)]
    public class BitmapDataSample11 extends Sprite {
        
        private var bmpdata:BitmapData;
        private var colortrans:ColorTransform;
        private var filter:BlurFilter;
        private var vectormap:BitmapData;
        private var particles:Array;
        private var particle_number:uint = 25000;
        private var size:Number = 465;
        
        public function BitmapDataSample11() {
            //BitmapDataを作成して表示リストに追加
            bmpdata = new BitmapData( size, size, false, 0 );
            addChild( new Bitmap( bmpdata ) );
            //エフェクト初期化
            colortrans = new ColorTransform( 0.95, 0.99, 0.99 );
            filter     = new BlurFilter( 2, 2, 1 );
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
            vectormap.perlinNoise( size/2, size/2, 4, randomSeed, false, true, colors );
            //パーティクルの初期化
            particles = new Array(particle_number);
            for (var i:int = 0; i < particle_number; i++) {
                particles[i] = new Particle( Math.random()*size, Math.random()*size );
            }
        }
        
        private function enterframe( e:Event ):void {
            //エフェクトの適用
            bmpdata.applyFilter( bmpdata, bmpdata.rect, bmpdata.rect.topLeft, filter );
            bmpdata.colorTransform( bmpdata.rect, colortrans );
            //パーティクルの描画
            bmpdata.lock();
            for (var i:int = 0; i <particle_number; i++) {
                var p:Particle = particles[i];
                //ベクトルマップのPixel値から加速度を算出
                var col:uint = vectormap.getPixel( p.x, p.y );
                p.ax += ( (col >> 16 & 0xff) - 128 )*0.0005;
                p.ay += ( (col >> 8  & 0xff) - 128 )*0.0005;
                //加速度から速度と位置を算出
                p.x += p.vx += p.ax;
                p.y += p.vy += p.ay;
                if ( p.x > size )  { p.x -= size; }
                else if ( p.x < 0 ){ p.x += size; }
                if ( p.y > size )  { p.y -= size; }
                else if ( p.y < 0 ){ p.y += size; }
                //Pixelへ描画
                bmpdata.setPixel( p.x, p.y, 0xffffff );
                //加速度と速度の減衰
                p.ax *= 0.96;  p.ay *= 0.96;
                p.vx *= 0.92;  p.vy *= 0.92;
            }
            bmpdata.unlock();
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
    function Particle( px:Number, py:Number ) {
        x = px;
        y = py;
    }
}
