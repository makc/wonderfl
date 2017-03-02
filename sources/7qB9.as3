package  {
    import flash.display.MovieClip;
    [SWF(width = "465", height = "465", backgroundColor = "0x000000", frameRate = "30")]
    public class FlashTest extends MovieClip {
        public function FlashTest() {
            var space:Space=new Space();
            addChild(space);
            var tools:Tools=new Tools();
            addChild(tools);
        }
    }
}
import net.hires.debug.Stats;
import com.bit101.components.*;
class Tools extends MovieClip{
    public static var num:Number=50;
    public static var label_planets:Label;
    private var hslider:HSlider;
    private var label_hslider:Label
    public function Tools(){
        addChild( new Stats() );
        label_planets=new Label(this,80,0);
        label_planets.text="planets : 0"
        hslider=new HSlider(this,80,20,hslider_change)
        hslider.minimum=1;
        hslider.maximum=1000;
        hslider.value=num;
        addChild(hslider);
        label_hslider = new Label(this,80,30);
        label_hslider.text =String("Interval :: "+ num + " ms");
    }
    private function hslider_change(evt:Event):void{
        num=evt.currentTarget.value ;
        label_hslider.text = String("Interval :: "+ num + " ms");
    }
}
import flash.display.*;
import flash.display.*;
import flash.events.Event;
import flash.utils.*;

class Space extends MovieClip{
    private var planet_stage:MovieClip
    private var s_mc:MovieClip;
    private var m_mc:MovieClip;
    private var h_mc:MovieClip;
    private var s_r:Number=130;
    private var m_r:Number=100;
    private var h_r:Number=60;
    private var black_ar:Array
    private var id:uint
    public function Space() {
        planet_stage=new MovieClip();
        addChild(planet_stage)
        //
        black_ar=new Array()
        //
        s_mc=new MovieClip();
        var g:Graphics=s_mc.graphics;
        g.lineStyle(1,0x333333)
        g.moveTo(0,0)
        g.lineTo(-1*s_r,0);
        g.lineStyle()
        g.beginFill(0xCCCCCC);
        g.drawCircle(0,0,5)
        s_mc.rotation=90

        addChild(s_mc);
        //
        m_mc=new MovieClip();
        g=m_mc.graphics;

        g.lineStyle(1,0x333333)
        g.moveTo(0,0)
        g.lineTo(-1*m_r,0);
        g.lineStyle()
        g.beginFill(0x999999);
        g.drawCircle(0,0,2)
        //
        m_mc.M=0.6;
        addChild(m_mc);
        black_ar.push(m_mc);
        //
        h_mc=new MovieClip();
        g=h_mc.graphics;
        g.lineStyle(1,0x333333)
        g.moveTo(0,0)
        g.lineTo(-1*h_r,0);
        g.lineStyle()
        g.beginFill(0x666666);
        g.drawCircle(0,0,5)
        h_mc.M=1.8;
        addChild(h_mc)
        black_ar.push(h_mc);
        /**/
        addEventListener(Event.ENTER_FRAME,blackMove)
        id=setTimeout(setPlanet,Tools.num);
        
    }
    private function setPlanet():void{
        var p_mc:Planet=new Planet();
        planet_stage.addChild(p_mc)
        p_mc.init(black_ar);
        p_mc.x=s_mc.x;
        p_mc.y=s_mc.y;
        id=setTimeout(setPlanet,Tools.num);
    }
    private function blackMove(evt:Event):void{
        Tools.label_planets.text="planets : "+planet_stage.numChildren
        setHoles();
    }
    private function setHoles():void{
        var dObj:Date=new Date();
        var h:uint=dObj.hours
        var m:uint=dObj.minutes;
        var s:uint=dObj.seconds;
        var ms:uint=dObj.milliseconds;
        //
        var sr:Number=Math.PI-2*Math.PI*(s/60)-(1/60)*2*Math.PI*(ms/1000);
        var mr:Number=Math.PI-2*Math.PI*(m/60)-(1/60)*2*Math.PI*(s/60);
        var hr:Number=Math.PI-2*Math.PI*(h/12)-(1/12)*2*Math.PI*(m/60);
        //
        holeMove(h_mc,hr,h_r)
        holeMove(m_mc,mr,m_r)
        holeMove(s_mc,sr,s_r)
    }
    private function holeMove(mc:MovieClip,theta:Number,R:Number):void{    
        mc.x=stage.stageWidth*0.5+R*Math.sin(theta);
        mc.y=stage.stageHeight*0.5+R*Math.cos(theta);
        mc.rotation=180*(Math.atan2(mc.y-0.5*stage.stageHeight,mc.x-0.5*stage.stageWidth)/Math.PI);
    }
}
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.utils.*;
import flash.display.*;
class Planet extends MovieClip{
    private var vx:Number;
    private var vy:Number;
    private var G:Number=0.003;
    private var sv:Number=0.15;
    private var black_ar:Array
    private var h:uint;
    private var m:uint;
    private var s:uint;    
    public function Planet(){
        //
        var date:Date=new Date();
        h=date.hours
        m=date.minutes;
        s=date.seconds;
        //
        var color:Number=Math.floor(((256*256)*Math.floor(sv*255)+256*Math.floor(255*(m/60))+Math.floor(255*(s/60))));
        var g:Graphics=this.graphics;
        g.beginFill(color)
        g.drawCircle(0,0,1)

        var id:uint=setTimeout(removePlanet,60*1000)
    }
    public function init(_ar:Array):void{
        black_ar=_ar
        var r:Number=2*Math.PI*Math.random();
        vx=sv*Math.cos(r)
        vy=sv*Math.sin(r)
        //
        addEventListener(Event.ENTER_FRAME,ent)
    }
    private function removePlanet():void{
        addEventListener(Event.ENTER_FRAME,remove_ent);
    }
    private function remove_ent(evt:Event):void{
        var da:Number=0-this.alpha;
        this.alpha+=da*0.1;
        if(Math.abs(da)<0.02){
            removeEventListener(Event.ENTER_FRAME,remove_ent);
            removeEventListener(Event.ENTER_FRAME,ent);
            this.parent.removeChild(this);
        }
    }
    
    private function ent(evt:Event):void{
        var i:uint
        for(i=0;i<black_ar.length;i++){
            var dx:Number=black_ar[i].x-this.x;
            var dy:Number=black_ar[i].y-this.y;
            var r:Number=Math.sqrt(Math.pow(dx,2)+Math.pow(dy,2))
            var a:Number=G*black_ar[i].M/r*r
            var ax:Number=a*(dx/r)
            var ay:Number=a*(dy/r)
            vx+=ax;
            vy+=ay;
        }
        this.x+=vx;
        this.y+=vy;
        //
        var v:Number=Math.sqrt(Math.pow(vx,2)+Math.pow(vy,2));
        if(v>1)v=1;
        var color:Number = Math.floor(((256*256)*Math.floor(v*255)+256*Math.floor(255*(m/60))+Math.floor(255*(s/60))));
        var g:Graphics=this.graphics;
        g.clear()
        g.beginFill(color);
        var w:Number=1
        g.drawCircle(0,0,w)
    }
}






