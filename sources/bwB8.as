// forked from nutsu's SketchSample2
// forked from nutsu's SketchSample1
// forked from nutsu's PaintSample
// see http://gihyo.jp/design/feature/01/frocessing/0004
package {
    import frocessing.display.F5MovieClip2DBmp;
    [SWF(width=465,height=465,backgroundColor=0x000000,frameRate=60)]
    public class SketchSample3 extends F5MovieClip2DBmp
    {
        //加速度運動の変数
        private var xx:Number;
        private var yy:Number;
        private var vx:Number;
        private var vy:Number;
        private var ac:Number;
        private var de:Number;
        //線幅の係数
        private var wd:Number;
        
        public function setup():void
        {
            //キャンバスのサイズ指定
            size( 465, 465 );
            //背景の描画
            background( 0 );
            //HSV
            colorMode( HSV, 1 );
            //初期化
            vx = vy = 0.0;
            xx = mouseX;
            yy = mouseY;
            ac = 0.15;
            de = 0.96;
            wd = 0.1;
        }
        
        public function draw():void
        {
            if ( isMousePressed )
                background( 0 );
            //描画
            drawing( mouseX, mouseY );
        }
        
        //描画関数
        private function drawing( x:Number, y:Number ):void
        {
            var px:Number = xx;
            var py:Number = yy;
            //加速度運動
            xx += vx += ( x - xx ) * ac;
            yy += vy += ( y - yy ) * ac;
            
            //速度のベクトル長
            var len:Number = mag( vx, vy );
            //線幅の指定
            strokeWeight( len * wd );
            //描画
            stroke( random(0.95, 1), random(0.2, 1), random(0.3, 1) );
            line( px, py, xx, yy );
            
            //減衰処理
            vx *= de;
            vy *= de;
        }
    }
}