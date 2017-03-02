// forked from nutsu's SketchSample4
// forked from nutsu's SketchSample3
// forked from nutsu's SketchSample2
// forked from nutsu's SketchSample1
// forked from nutsu's PaintSample
// see http://gihyo.jp/design/feature/01/frocessing/0004
package {
    import frocessing.display.F5MovieClip2DBmp;
    [SWF(width=465,height=465,backgroundColor=0x000000,frameRate=60)]
    public class SketchSample5 extends F5MovieClip2DBmp
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
        //描画座標
        private var px0:Array;
        private var py0:Array;
        private var px1:Array;
        private var py1:Array;
        
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
            wd = 0.05;
            px0 = [xx, xx, xx];
            py0 = [yy, yy, yy];
            px1 = [xx, xx, xx];
            py1 = [yy, yy, yy];
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
            
            //新しい描画座標
            var x0:Number  = px + vy*wd;
            var y0:Number  = py - vx*wd;
            var x1:Number  = px - vy*wd;
            var y1:Number  = py + vx*wd;
            
            //描画
            noStroke();
            fill( random(0.95, 1), random(0.2, 1), random(0.3, 1) );
            beginShape();
            curveVertex( px0[0], py0[0] );
            curveVertex( px0[1], py0[1] );
            curveVertex( px0[2], py0[2] );
            curveVertex( x0, y0 );
            vertex( px1[2], py1[2] );
            curveVertex( x1, y1 );
            curveVertex( px1[2], py1[2] );
            curveVertex( px1[1], py1[1] );
            curveVertex( px1[0], py1[0] );
            endShape();
            //ボーダーの描画
            stroke( 0, 0.2 );
            noFill();
            curve( px0[0], py0[0], px0[1], py0[1], px0[2], py0[2], x0, y0 );
            curve( px1[0], py1[0], px1[1], py1[1], px1[2], py1[2], x1, y1 );
            
            //描画座標
            px0.shift(); px0.push( x0 );
            py0.shift(); py0.push( y0 );
            px1.shift(); px1.push( x1 );
            py1.shift(); py1.push( y1 );
            //減衰処理
            vx *= de;
            vy *= de;
        }
    }
}