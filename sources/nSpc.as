// forked from nitoyon's AS3で半径小さい円を描いて拡大したらつぶれていて面白い
// See also: http://d.hatena.ne.jp/nitoyon/20081230/as_circle_skew
package{
import flash.display.*;
import flash.text.*;
public class GunyaGunya extends Sprite{
    public static var SIDE:int = 9;
    public static var SCALE:Number = 0.005;

    public function GunyaGunya(){
        for(var i:int=0;i < 70; i++){
            var s:Sprite = new Sprite();
            s.graphics.beginFill(i*0x783489);
            s.graphics.drawCircle(0, 0, i?SCALE*i:10);
            s.graphics.endFill();

            s.scaleX = s.scaleY = i?10 / (SCALE*i):1;
            s.x = 25 + 50 * (i%SIDE);
            s.y = 45 + 50 * int(i/SIDE);
            addChild(s);

            var t:TextField = new TextField();
            //t.defaultTextFormat = new TextFormat(null, 20);
            t.text = i?(SCALE*i).toString().substr(0,5):"Original";
            t.x = 10 + 50 * (i%SIDE);
            t.y = 10 + 50 * int(i/SIDE);
            addChild(t);
        }
    }
}}5