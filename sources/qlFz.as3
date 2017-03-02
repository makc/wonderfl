// forked from Altschuler's flash on 2010-1-29
package {
    import flash.display.Sprite;
    import frocessing.color.ColorHSV;
    [SWF( backgroundColor=0, frameRate=60 )]
    public class FlashTest extends Sprite {
         public function FlashTest() {
            // one line
            addEventListener("enterFrame",function(n){
                return function() {
                    var r=235, m=Math, h=new ColorHSV();
                    with(graphics) {
                        clear();
                        moveTo(r, r);
                        for(var i=0; i<r; i++){
                            h.h = i/r * 135 + n * 4000;
                            lineStyle(1, h.value32);
                            lineTo(
                                r + (i * m.cos(i + (i * n))),
                                r + (i * m.sin(i + (i * n))));
                        }
                    }
                    n+=.00025; }}(0));
        }
    }
}
