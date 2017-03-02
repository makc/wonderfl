// forked from KBM's SNOW DANCE
package {
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.display.Sprite;
    public class Base extends Sprite {
        public function Base() {
            // write as3 code here..
            var gr:Graphics = this.graphics;
            gr.beginFill(0x000000,0.8);
            gr.drawRect(0,0,stage.stageWidth,stage.stageHeight);
            addEventListener(Event.ENTER_FRAME,onEnterFrame);
            
            function onEnterFrame():void{
                var snp:SNparticle = new SNparticle();
                addChild(snp);
            }

            
            
        }
    }
}
import flash.filters.GlowFilter;
import flash.display.Graphics;
import flash.events.Event;
import flash.display.Sprite;

class SNparticle extends Sprite{
    private var vx:Number;
    private var vy:Number;
    private var a_arg:int; //速度算出時のsinの偏角 0 ~ 360
    private var frame:int; //フレーム数
    private const PI:int = 3.14;//簡略円周率
    private const ar:Number = 0.07; //空気抵抗
    private const ac_sn:Number = 0.2; // 雪の基本加速度 /* 最高速度はac_sn / ar */
    private var gr:Graphics;
    
    public function SNparticle(){
        vx = vy = a_arg = frame = 0;
        gr = this.graphics;
        
        gr.beginFill(0xEEEEEE,1);
        gr.drawCircle(0,0,1 + 3 * Math.random());
        gr.endFill();
        this.filters = [new GlowFilter(0xFFFFFF,1,7,7,1,3)]
        addEventListener(Event.ADDED,onStage);
    }
    
    private function onStage(e:Event):void{
        removeEventListener(Event.ADDED,onStage);
        this.x = Math.random() * this.stage.stageWidth;
        this.y = -5;
        vy = 0;
        addEventListener(Event.ENTER_FRAME,onEnterFrame);
    }
    
    private function onEnterFrame(e:Event):void{
        frame++; frame %= 120;
        if(frame % 4){a_arg += Math.random() * 40 - 20; a_arg %= 360}
        vx = Math.sin(a_arg * PI / 180)
        this.x += vx;
        
        vy += ac_sn - vy * ar;
        this.y += vy;
        
        if(this.x > stage.stageWidth + 5 || this.x < -5){this.x = stage.stageWidth - this.x};
        if(this.y > stage.stageHeight - 1){addEventListener(Event.ENTER_FRAME,fade);
        removeEventListener(Event.ENTER_FRAME,onEnterFrame);}
    }
    
    private function fade(e:Event):void{
        if(this.alpha >= 0)this.alpha -= 0.02;
        else{this.visible = false; removeEventListener(Event.ENTER_FRAME,fade)}
        
    }


}
