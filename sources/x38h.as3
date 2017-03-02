// see http://gihyo.jp/design/feature/01/frocessing/0003
package {
    import frocessing.display.F5MovieClip2DBmp;
    [SWF(width=465,height=465,backgroundColor=0x000000)]
    public class PaintSample extends F5MovieClip2DBmp
    {
        public function setup():void
        {
            //キャンバスのサイズ指定
            size( 465, 465 );
            //背景の描画
            background( 0 );
            //色指定
            stroke( 255, 0.5 );
        }
        
        public function draw():void
        {
            //マウスが押されているときは描画内容をクリア
            if ( isMousePressed )
                background( 0 );
            
            //直線の描画
            line( pmouseX, pmouseY, mouseX, mouseY );
        }
    }
}