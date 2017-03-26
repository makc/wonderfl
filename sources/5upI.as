package {
    import flash.display.*;
    import flash.events.*;
    public class FlashTest extends Sprite {
        //
        private var p_:Particle;
        private var Yw:Number = stage.stageWidth;
        private var Yh:Number = stage.stageHeight;
        private var step:Number = 5;
        private var maxPointNum:Number = 200;
        public function FlashTest() {
            // write as3 code here..
            var B:Bitmap = new Bitmap(new BitmapData(Yw,Yh,false,0x000000));
            addChild(B);
            //
            for(var i:int = 0; i < maxPointNum; i ++){
                draw();
            }
        }
        function draw():void{
            var angle:Number = Math.random() * 360;
            var radius:Number = Math.random() * 30 + 120;
            p_ = new Particle(Math.floor(Math.random() * 2 + 1) * step);
            addChild(p_);
            p_.rotationX = Math.random() * 360;
            p_.rotationY = Math.random() * 360;
            p_.rotationZ = Math.random() * 360;
            //
            p_.addEventListener(Event.ENTER_FRAME,function p_fr(event:Event):void{
                var t:Particle = event.target as Particle;
                angle ++;
                t.Move(angle,radius);
            });
            //
        }

    }
}
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.display.Shape;
class Particle extends Shape {
    var glow:GlowFilter = new GlowFilter(0x0066ff,0.5,20,10,2);
    public function Particle(st:Number):void{
        filters = [glow];
        graphics.beginFill(Math.random() * 0x5555ff);
        graphics.drawRect(0,0,st,st);
        graphics.endFill();
        //
    }
    public function Move(angle:Number,radius:Number):void{
        x = Math.cos(angle * (Math.PI / 180)) * radius + (stage.stageWidth / 2);
        y = Math.sin(angle * (Math.PI / 180)) * -50 + (stage.stageHeight / 2);
        z = Math.sin(angle * (Math.PI / 180)) * radius;
        alpha = Math.sin((angle + 180) * (Math.PI / 180)) + 1;
    }

}
