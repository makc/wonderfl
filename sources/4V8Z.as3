// forked from makc3d's forked from: SNOW DANCE
// forked from KBM's SNOW DANCE
package {
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.display.Sprite;
    import flash.geom.Vector3D;
    public class Base extends Sprite {
        public function Base() {
            // write as3 code here..
            var w:Vector3D = new Vector3D(10,10,10);
            var gr:Graphics = this.graphics;
            gr.beginFill(0x000000,0.6);
            gr.drawRect(0,0,stage.stageWidth,stage.stageHeight);
            addEventListener(Event.ENTER_FRAME,onEnterFrame);
            
            function onEnterFrame():void{
                var snp:SNparticle = new SNparticle(w);
                addChild(snp);
                w.x += (Math.random()-1) * .3;
                w.z += (Math.random()-1) * .3;
            }

            
            
        }
    }
}
import flash.geom.Vector3D;
import flash.filters.GlowFilter;
import flash.display.Graphics;
import flash.events.Event;
import flash.display.Sprite;

class SNparticle extends Sprite{

    private var v:Vector3D;
    private var w:Vector3D
    private var r:int;
    private var t:int;
    
    private var gr:Graphics;

    public function SNparticle(w:Vector3D){
       r = Math.random() *3;
       var gr:Graphics = this.graphics;
       gr.beginFill(0xEEEEEE,1);
       gr.drawCircle(0,0,1 + r);
       this.w = w ;
       this.v = new Vector3D(1,5,1);
       r/=10;
       gr.endFill();
       this.filters = [new GlowFilter(0xFFFFFF,1,7,7,1,3)] 
        
       addEventListener(Event.ADDED,onStage);
    }

    private function onStage(e:Event):void{
        removeEventListener(Event.ADDED,onStage);
        this.x = (-1 + 3*Math.random()) * this.stage.stageWidth;
        this.y = - this.stage.stageWidth; 
        this.z = (-1 + 3*Math.random()) * this.stage.stageWidth;
       
        addEventListener(Event.ENTER_FRAME,onEnterFrame);
    }
    
    private function onEnterFrame(e:Event):void{
        
        var dv:Vector3D = this.w.clone();
        dv.scaleBy(r);
        this.v = this.v.add(dv);
        this.x += this.v.x;
        this.y += this.v.y;
        this.z += this.v.z;
        if(this.x > 2*stage.stageWidth  || this.x < -stage.stageWidth){this.x = stage.stageWidth - this.x};
        if(this.y > stage.stageHeight - 1){addEventListener(Event.ENTER_FRAME,fade);
        removeEventListener(Event.ENTER_FRAME,onEnterFrame);}
    }
    
    private function fade(e:Event):void{
        if(this.alpha >= 0)this.alpha -= 0.02;
        else{this.visible = false; removeEventListener(Event.ENTER_FRAME,fade); this.stage.removeChild(this);}
        
    }


}
