// forked from nutsu's PaintSample
// see http://gihyo.jp/design/feature/01/frocessing/0004
package {
    import frocessing.display.F5MovieClip2DBmp;
    [SWF(width=465,height=465,backgroundColor=0x000000,frameRate=60)]
    public class SketchSample1 extends F5MovieClip2DBmp
    {
        public function setup():void
        {
            //キャンバスのサイズ指定
            size( 465, 465 );
            //背景の描画
            background( 0 );
            //HSV
            colorMode( HSV, 1 );
        }
        
        public function draw():void
        {
            if ( isMousePressed )
                background( 0 );
            //描画
            stroke( random(0.95, 1), random(0.2, 1), random(0.3, 1) );
            line( pmouseX, pmouseY, mouseX, mouseY );
        }
    }
}