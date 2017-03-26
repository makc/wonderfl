package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    public class Tp extends Sprite {
        public var spr:Sprite=new Sprite();
        public function Tp(){
            this.addChild(spr);
            this.addEventListener(Event.ENTER_FRAME,frame);
        }
        public function frame(e:Event):void{
            spr.graphics.clear();
            spr.graphics.beginFill(0xffff00);
            spr.graphics.drawRect(this.mouseX-50,this.mouseY-50,100,100);
            spr.graphics.endFill();
        }
    }
}