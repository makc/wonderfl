package {
    import flash.display.Sprite;
    import flash.events.Event;
    [SWF(width="512",height="512",backgroundColor="0x000000")]
    public class FlashTest extends Sprite {
        private var g:Graphics3D;
        private var yr:Number;
        public function FlashTest() {
            var spr:Sprite=new Sprite();
            spr.x=spr.y=256;
            addChild(spr);
            g=new Graphics3D(spr);
            yr=0;
            addEventListener(Event.ENTER_FRAME,onEnterFrame);
        }
        private function onEnterFrame(e:Event):void{
            g.clear();
            var starY:Number=Math.sin(yr/Math.PI)*100;
            if(Math.cos(yr)>0){
                g.lineStyle(10,0x30c0ff,1);
                var r:Number=yr-Math.PI/8;
                g.moveTo(Math.sin(-r)*140,starY,Math.cos(-r)*140);
                for(var i:int=0;i<5;i++){
                    g.lineTo(Math.sin(-r)*140,starY,Math.cos(-r)*140);
                    r+=Math.PI/20;
                }
                g.lineStyle(10,0xffc030,1);
                r=yr-Math.PI/8;
                g.moveTo(Math.sin(r)*120,starY,Math.cos(r)*120);
                for(i=0;i<5;i++){
                    g.lineTo(Math.sin(r)*120,starY,Math.cos(r)*120);
                    r+=Math.PI/20;
                }
                r=Math.PI/2;
                g.lineStyle(15,0xc0ff30,0.5);
                g.moveTo(Math.cos(r)*100,starY,Math.sin(r)*100);
                for(;r<=4*Math.PI+Math.PI/2;r+=Math.PI*4/5){
                    g.lineTo(Math.cos(r)*100,starY,Math.sin(r)*100);
                }
            }
            else{
                r=Math.PI/2;
                g.lineStyle(15,0xc0ff30,0.5);
                g.moveTo(Math.cos(r)*100,starY,Math.sin(r)*100);
                for(;r<=4*Math.PI+Math.PI/2;r+=Math.PI*4/5){
                    g.lineTo(Math.cos(r)*100,starY,Math.sin(r)*100);
                }
                g.lineStyle(10,0xffc030,1);
                r=yr-Math.PI/8;
                g.moveTo(Math.sin(r)*120,starY,Math.cos(r)*120);
                for(i=0;i<5;i++){
                    g.lineTo(Math.sin(r)*120,starY,Math.cos(r)*120);
                    r+=Math.PI/20;
                }
                g.lineStyle(10,0x30c0ff,1);
                r=yr-Math.PI/8;
                g.moveTo(Math.sin(-r)*140,starY,Math.cos(-r)*140);
                for(i=0;i<5;i++){
                    g.lineTo(Math.sin(-r)*140,starY,Math.cos(-r)*140);
                    r+=Math.PI/20;
                }
            }

            yr+=Math.PI/60;
        }

    }
}
import flash.display.Sprite;
import flash.display.Graphics;
class Graphics3D{
    private var g:Graphics;
    private var thickness:Number=0;
    private var lineColor:uint=0;
    private var lineAlpha:Number=1.0;
    private var lineStartX:Number=0;
    private var lineStartY:Number=0;
    private var lineStartZ:Number=0;
    private const VS:Number=200;
    public function Graphics3D(target:Sprite){
        g=target.graphics;
    }
    public function clear():void{
        g.clear();
    }
    public function lineStyle(thickness:Number,color:uint=0,alpha:Number=1.0):void{
        this.thickness=thickness;
        this.lineColor=color;
        this.lineAlpha=alpha;
    }
    public function moveTo(x:Number,y:Number,z:Number):void{
        this.lineStartX=x;
        this.lineStartY=y;
        this.lineStartZ=z;
    }
    public function lineTo(x:Number,y:Number,z:Number):void{
        var p:Number=VS/(VS+this.lineStartZ);
        g.beginFill(lineColor,lineAlpha);
        var startThickness:Number=thickness*p/2;
        var startX:Number=this.lineStartX*p;
        var startY:Number=this.lineStartY*p;
        g.drawCircle(startX,startY,startThickness);
        g.endFill();
        g.beginFill(lineColor,lineAlpha);
        p=VS/(VS+z);
        var endThickness:Number=thickness*p/2;
        var endX:Number=x*p;
        var endY:Number=y*p;
        g.drawCircle(endX,endY,endThickness);
        g.endFill();
        g.beginFill(lineColor,lineAlpha);
        var rX:Number=endX-startX;
        var rY:Number=endY-startY;
        var dT:Number=startThickness-endThickness;
        var t:Number=rX*rX+rY*rY;
        var dT2:Number=dT*dT;
        g.moveTo(startX+startThickness*(rX*dT+rY*Math.sqrt(t-dT2))/t
                ,startY+startThickness*(rY*dT-rX*Math.sqrt(t-dT2))/t);
        g.lineTo(startX+startThickness*(rX*dT-rY*Math.sqrt(t-dT2))/t
                ,startY+startThickness*(rY*dT+rX*Math.sqrt(t-dT2))/t);

        g.lineTo(endX+endThickness*(rX*dT-rY*Math.sqrt(t-dT2))/t
                ,endY+endThickness*(rY*dT+rX*Math.sqrt(t-dT2))/t);
        g.lineTo(endX+endThickness*(rX*dT+rY*Math.sqrt(t-dT2))/t
                ,endY+endThickness*(rY*dT-rX*Math.sqrt(t-dT2))/t);

        g.endFill();
        moveTo(x,y,z);
    }
}