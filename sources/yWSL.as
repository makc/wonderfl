// forked from J.J's forked from: forked from: Tentacle
// forked from kojiOGATA's forked from: Tentacle
// forked from yasuo_from_BDM's Tentacle
/*

original sorce code from "www.levitated.net"
Tentacle(AS3 version)

Yasuo Hasegawa from BIRDMAN

*/

package {
    import flash.display.Shape;
    import flash.geom.*;
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.events.*;
    import flash.filters.*;
    import flash.media.*;
    import flash.system.*;
    import flash.net.*;
    
    [SWF(backgroundColor="#ffffff", frameRate=120)]
    public class TentacleControl extends Sprite
    {
        private var inverted:Boolean;
        private var w:uint,h:uint
        private var circles:Sprite,container:Sprite
        private var ts:Vector.<Tentacle> = new Vector.<Tentacle>;
        private var url:String = "http://www.onebyonedesign.com/flash/djscratch/sound.mp3";
        private var s:Sound, ch:SoundChannel;
        private var normalTransform:ColorTransform = new ColorTransform;
        private var invertTransform:ColorTransform = new ColorTransform(-1,-1,-1,1,255,255,255,0)
        public function TentacleControl ()
        {
            w=stage.stageWidth,h=stage.stageHeight
            var bf:BlurFilter=new BlurFilter(4,4)
            var triangle:Shape=new Shape()
             triangle.graphics.beginFill(0x111111)
             var l:Number=25
             var vtx:Vector.<Number>=Vector.<Number>([0,0,0,l,l*4,l/2])
             var indx:Vector.<int>=Vector.<int>([0,1,2])
             triangle.graphics.drawTriangles(vtx,indx);
             
             var bigAssCircle:Sprite = new Sprite;
             bigAssCircle.graphics.beginFill (0xFFFFFF);
             bigAssCircle.graphics.drawCircle (0, 0, 500);
             bigAssCircle.graphics.endFill();
             
            var maxtents:int = 8;
            var tents:Number = 0;
            var rad:Number=50;
            var center:Point=new Point(w/2,h/2)
            var st:Number=(Math.PI*2)/maxtents
            var theta:Number=st/2
            container=new Sprite;
            container.addChild (bigAssCircle);
            addChild(container)
            for(var i:int;i<maxtents;i++){
               var tri:Shape=new Shape()
                tri.graphics.copyFrom(triangle.graphics)
//                container.addChild(tri)
                tri.x=Math.sin(theta)*rad
                tri.y=Math.cos(theta)*rad
                tri.rotation=-(theta*180)/Math.PI+90
           var t:Tentacle=new Tentacle()
           t.x=Math.sin(theta)*rad
           t.y=Math.cos(theta)*rad
           t.rotation=-(theta*180)/Math.PI
           t.head=20
           t.girth=9
           t.muscleRange=60
           t.friction=0
           container.addChild(t)
           ts.push(t);
           theta+=st
           
            }
            
            
            circles=new Sprite()
            circles.graphics.beginFill(0)
            circles.graphics.lineStyle(10,0xffffff)
            circles.graphics.drawCircle(0,0,75)
            circles.graphics.endFill()
           circles.graphics.lineStyle(10)
           circles.graphics.drawCircle(0,0,80)
           container.x=center.x,container.y=center.y;
           container.addChild(circles)
           addEventListener('enterFrame',loop)
           
           s = new Sound (new URLRequest (url));
           ch = s.play (0, int.MAX_VALUE);
        }
        private function loop(e:Event=null):void{
            container.rotation+=.5
            
            if ((ch.leftPeak > 0.8) && (Math.random() > 0.8)) {
                inverted = !inverted;
                container.transform.colorTransform = inverted ? invertTransform : normalTransform;
            }
            
            var scale:Number = 0.2 * (1 - 0.2 * (ch.leftPeak + ch.rightPeak)) + 0.8 * circles.scaleX;
            circles.scaleX = circles.scaleY = scale;
            
            for (var i:int = 0; i < ts.length; i++) {
                var t:Tentacle = ts[i];
                t.head = 5 * (ch.leftPeak - ch.rightPeak);
                // tentacles seem to gain "history" over time... no idea how to break it so far
                t.muscleFreq = 1 * ((i%2==0) ? ch.leftPeak * (1 - ch.rightPeak) : (1 - ch.leftPeak) * ch.rightPeak);
            }
        }
    }
}


import flash.display.Sprite;
import flash.events.*; 
import flash.text.TextField;
class Tentacle extends Sprite
{
    // total number of nodes
    public var numNodes:Number = 27;
        
    // the general size and speed
    public var head:Number  = 2+Math.floor(Math.random()*4);
    public var girth:Number = 8+Math.floor(Math.random()*12);
        
    // locomotion efficiency (0 - 1)
    public var speedCoefficient:Number =.09+Math.floor((Math.random()*10)/50);    
        
    // the viscosity of the water (0 - 1)    
    public var friction:Number = .90+Math.floor((Math.random()*10)/100);    
       
    // muscular range
    public var muscleRange:Number = 20+Math.floor(Math.random()*50);
        
    // muscular frequency
    public var muscleFreq:Number = .1+Math.floor((Math.random()*100)/250);    
           
    // create point array to represent nodes
    public var nodes:Array = [];
    
    private var tracefield:TextField; 
        
    private var tv:Number = 0;
    public var theta:Number = 0;
    private var count:Number = 0;
    
    private var moveEnd_evt:Event = new Event("moveend");

    public function Tentacle() 
    {
        init();
    } 
        
    private function init():void
    {   
        generateNodes();
        this.addEventListener(Event.ENTER_FRAME, moveHandler);
    }        
        
    public function generateNodes():void
    {
        nodes = [];
        for (var n:int = 0; n< numNodes; n++)
        {
            var point:Object = {x:0,y:0};
            nodes.push(point);
        }
    }
    
    public function moveHandler(event:Event):void
    {
            
        // directional node with orbiting handle
        // arbitrary direction
      /*  tv += 0.5*(Math.random()-Math.random());
        theta += tv;
        tv *= friction;*/
        
        nodes[0].x = head*Math.cos(Math.PI / 180 * theta);
        nodes[0].y = head*Math.sin(Math.PI / 180 * theta);
            
        // muscular node
        count += muscleFreq;
        
        var thetaMuscle:Number = muscleRange*Math.sin(count);
            
        nodes[1].x = -head*Math.cos(Math.PI / 180 * (theta + thetaMuscle));
        nodes[1].y = -head*Math.sin(Math.PI / 180 * (theta + thetaMuscle));
        
        // apply kinetic forces down through body nodes
        for (var i:Number = 2; i<numNodes; i++)
        {
            var dx:Number = nodes[i].x - nodes[i - 2].x;
            var dy:Number = nodes[i].y - nodes[i - 2].y;
                
            var d:Number = Math.sqrt (dx * dx + dy * dy);
            nodes[i].x   = nodes[i - 1].x + (dx * girth) / d;
            nodes[i].y   = nodes[i - 1].y + (dy * girth) / d;
        }
            
        // draw nodes using lines    
        this.graphics.clear();
        this.graphics.moveTo(nodes[1].x,nodes[1].y);
        for (var j:Number = 2; j<numNodes; j++)
        {
            //    this.lineStyle((this.numNodes/(i-1))*1.5, 0xFFFFFF, 100);  // with head
            //    this.lineStyle((this.numNodes-i), 0xFFFFFF, 100);  // with no head
            this.graphics.lineStyle(int(numNodes-j)*(numNodes-j)/20, 0x000000, 1);  // with no head
            this.graphics.lineTo(nodes[j].x,nodes[j].y);
        }
    }; 
}
