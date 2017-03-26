/*
またショートコーディングもどきのようなことをしてしまった
しかもしょぼい
変な書き方してるので真似しちゃだめよ
*/
package {
    import flash.display.Sprite;
    [SWF(width=465,height=465,backgroundColor=0xffffff,frameRate=10)]
    public class A extends Sprite {
        public function A() {
            var m:Sprite = addChild(new Sprite()) as Sprite;
            for (var i:int=(m.x=m.y=232.5)/232.5; i < 16; i+=2) {
                m.graphics.beginFill(i<<20|i<<12|i<<4);
                m.graphics.drawCircle(70*Math.cos(i*.39),70*Math.sin(i*.39),10);
            }
            addEventListener("enterFrame",function():void{m.rotation-=34;});           
        }
    }
}