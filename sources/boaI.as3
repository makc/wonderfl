// forked from phi16's forked from: Template
// forked from phi16's Template
package {
    import flash.text.TextFormat;
    import flash.text.TextField;
    import flash.geom.Point;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    public class Tp extends Sprite {
        public var spr:Sprite=new Sprite();
        public var dat:Array=new Array();
        public var mot:Array=new Array();
        public var i:int=0;
        public var stf:TextField=new TextField();
        public function Tp(){
            this.addChild(spr);
            this.addEventListener(Event.ENTER_FRAME,frame);
            for(i=0;i<465;i++){
                dat.push(new Point(0,0));
                mot.push(new Point(0,0));
            }
            stf.defaultTextFormat=new TextFormat("メイリオ",30,0xffffff);
            stf.x=465/2.0+20;
            stf.y=465-50.0;
            stf.width=250;
            stf.height=50;
            stf.text=String("y=0");
            this.addChild(stf);
        }
        public function frame(e:Event):void{
            spr.graphics.clear();
            spr.graphics.beginFill(0);
            spr.graphics.drawRect(0,0,465,465);
            spr.graphics.endFill();
            spr.graphics.lineStyle(1.0,0xffffff,0.5);
            spr.graphics.moveTo(465/2.0,0);
            spr.graphics.lineTo(465/2.0,465);
            spr.graphics.moveTo(0,465/2.0);
            spr.graphics.lineTo(465,465/2.0);

            var y:Number=this.mouseX*2.0/465-1.0;
            y=Math.tan(y*Math.PI*0.499);
            stf.text=String("y=x^"+String(y));

            spr.graphics.lineStyle(3.0,0xff7f00,1);
            spr.graphics.moveTo(-1,-mot[0].y*465/4.0+465/2.0);
            spr.graphics.lineTo(0,-mot[0].y*465/4.0+465/2.0);
            for(i=1;i<465;i++){
                spr.graphics.lineTo(i,-mot[i].y*465/4.0+465/2.0);
            }
            
            spr.graphics.lineStyle(3.0,0x007fff,1);
            spr.graphics.moveTo(-1,-mot[0].x*465/4.0+465/2.0);
            spr.graphics.lineTo(0,-mot[0].x*465/4.0+465/2.0);
            for(i=0;i<465;i++){
                if(i!=0)spr.graphics.lineTo(i,-mot[i].x*465/4.0+465/2.0);
                var f:Number=4/465.0*i-2.0;
                var x:Number=f;
                if(x>0){
                    dat[i].x=Math.pow(x,y);
                    dat[i].y=0;
                }else{
                    var l:Number=Math.exp(y*Math.log(-x));
                    dat[i].x=l*Math.cos(y*Math.PI);
                    dat[i].y=l*Math.sin(y*Math.PI);
                }
                mot[i].x+=(dat[i].x-mot[i].x)/4.0;
                mot[i].x=Math.min(Math.max(mot[i].x,-16.0),16.0);
                mot[i].y+=(dat[i].y-mot[i].y)/4.0;
                mot[i].y=Math.min(Math.max(mot[i].y,-16.0),16.0);
            }
        }
    }
}