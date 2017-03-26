// forked from nutsu's SketchSample6
// forked from nutsu's SketchSample5
// forked from nutsu's SketchSample4
// forked from nutsu's SketchSample3
// forked from nutsu's SketchSample2
// forked from nutsu's SketchSample1
// forked from nutsu's PaintSample
// see http://gihyo.jp/design/feature/01/frocessing/0004
package {
    import frocessing.display.F5MovieClip2DBmp;
    import frocessing.geom.FGradientMatrix;
    [SWF(width=465,height=465,backgroundColor=0x000000,frameRate=60)]
    public class SketchSample7 extends F5MovieClip2DBmp
    {
        //グラデーション用の変数
        private var mtx:FGradientMatrix;
        private var colors:Array;
        private var alphas:Array;
        private var ratios:Array;
        //線の数
        private var n:int;
        private var brushs:Array;
        
        public function setup():void
        {
            //キャンバスのサイズ指定
            size( 465, 465 );
            //背景の描画
            background( 0 );
            //HSV
            colorMode( HSV, 1 );
            //初期化
            n = 10;
            brushs = [];
            for ( var i:int = 0; i < n; i++ ) {
                var o:BrushState = new BrushState();
                o.vx = o.vy = 0.0;
                o.xx = mouseX;
                o.yy = mouseY;
                o.ac = random( 0.1, 0.15 );
                o.de = 0.96;
                o.wd = random( 0.03, 0.06 );
                o.px0 = [o.xx, o.xx, o.xx];
                o.py0 = [o.yy, o.yy, o.yy];
                o.px1 = [o.xx, o.xx, o.xx];
                o.py1 = [o.yy, o.yy, o.yy];
                brushs[i] = o;
            }
            //グラデーション用の変数
            mtx = new FGradientMatrix();
            colors = [0, 0];
            alphas = [1.0,1.0];
            ratios = [0,255];
        }
        
        public function draw():void
        {
            if ( isMousePressed )
                background( 0 );
            //描画
            drawing( mouseX, mouseY );
        }
        
        private function drawing( x:Number, y:Number ):void
        {
            colors[0] = colors[1];
            colors[1] = color( random(0.95, 1), random(0.2, 1), random(0.3, 1) );
            
            for ( var i:int = 0; i < n; i++ ) {
                var brush:BrushState = brushs[i];
                
                with( brush ){
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
                    
                    //グラデーション形状指定
                    mtx.createLinear( px0[1], py0[1], px0[2], py0[2] );
                    
                    //描画
                    noStroke();
                    beginGradientFill( "linear", colors, alphas, ratios, mtx );
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
                    endFill();
                    //ボーダーの描画
                    stroke( 0, 0.1 );
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
    }
}

class BrushState {
    //加速度運動の変数
    public var xx:Number;
    public var yy:Number;
    public var vx:Number;
    public var vy:Number;
    public var ac:Number;
    public var de:Number;
    //線幅の係数
    public var wd:Number;
    //描画座標
    public var px0:Array;
    public var py0:Array;
    public var px1:Array;
    public var py1:Array;
    public function BrushState(){}
}