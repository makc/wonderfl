// forked from phi16's Template
package {
    import flash.display.AVM1Movie;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    public class Tp extends Sprite {
        public var spr:Sprite=new Sprite();
        public var arr:Array=new Array();
        public var clicking:Boolean=false;
        public function Tp(){
            this.addChild(spr);
            this.addEventListener(MouseEvent.MOUSE_DOWN,this.onClkDn);
            this.addEventListener(MouseEvent.MOUSE_UP,this.onClkUp);
            this.addEventListener(Event.ENTER_FRAME,frame);
        }
        public function frame(e:Event):void{
            spr.graphics.clear();
            spr.graphics.beginFill(0x000000);
            spr.graphics.drawRect(0,0,465,465);
            spr.graphics.endFill();
            if(clicking){
                var i:int=arr.length-1;
                arr[i].s=Math.min(465,Math.sqrt(Math.pow(-mouseY+465-arr[i].x,2)+Math.pow(mouseX-465/2-arr[i].y,2))*6);
                if(arr[i].x!=mouseX || arr[i].y!=mouseY){
                   arr[i].r=Math.atan2(mouseX-465/2-arr[i].y,-mouseY+465-arr[i].x);
                }
            }
            drawR(new Rect(465/2,465,465,-Math.PI/2),10); 
        }
        private function drawR(t:Rect,c:int):void{
            if(t.s<10 || t.s>465 || c<0)return;
            t.draw(spr);
            for each(var a:Rect in arr){
                var s:Rect=new Rect(t.x,t.y,t.s,t.r);
                s.x+=(Math.cos(t.r)*a.x-Math.sin(t.r)*a.y)*t.s/465;
                s.y+=(Math.sin(t.r)*a.x+Math.cos(t.r)*a.y)*t.s/465;
                s.s*=a.s/465; 
                s.r+=a.r;
                drawR(s,c-1);
            }
        }
        private function onClkDn(e:MouseEvent):void{
            clicking=true;
            arr.push(new Rect(-mouseY+465,mouseX-465/2,0,0));
        }
        private function onClkUp(e:MouseEvent):void{
            clicking=false;
        }
    }
}
import flash.display.Sprite;

class Rect {
    public var x:Number,y:Number,s:Number,r:Number;
    public function Rect(x_:Number,y_:Number,s_:Number,r_:Number){
        x=x_,y=y_,s=s_,r=r_;
    }
    public function draw(spr:Sprite):void{
        spr.graphics.lineStyle(s/40,0xffffff);
        spr.graphics.moveTo(x,y);
        spr.graphics.lineTo(x+Math.cos(r)*s/6,y+Math.sin(r)*s/6);
    }
}
