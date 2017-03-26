// See also: http://d.hatena.ne.jp/nitoyon/20081230/as_circle_skew
package{
import flash.display.Sprite;
public class GunyaGunya extends Sprite{
    public function GunyaGunya(){
        var s:Sprite = new Sprite();
        s.graphics.beginFill(0xff0000);
        s.graphics.drawCircle(0, 0, 0.1);
        s.graphics.endFill();
        s.scaleX = s.scaleY = 200;
        s.x = s.y = 100;
        addChild(s);

        s = new Sprite();
        s.graphics.beginFill(0x0000ff);
        s.graphics.drawCircle(0, 0, 0.2);
        s.graphics.endFill();
        s.scaleX = s.scaleY = 100;
        s.x = s.y = 200;
        addChild(s);

        s = new Sprite();
        s.graphics.beginFill(0x006600);
        s.graphics.drawCircle(0, 0, 0.3);
        s.graphics.endFill();
        s.scaleX = s.scaleY = 100;
        s.x = 240; s.y = 80;
        addChild(s);
    }
}
}