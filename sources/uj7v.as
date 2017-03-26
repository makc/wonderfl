package  {
    import net.hires.debug.Stats;
    import flash.display.MovieClip;
    import flash.media.Microphone;
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.events.MouseEvent;
    public class FlashTest extends MovieClip {
        private var dxy:Number=30
        private var w:uint=Math.floor(stage.stageWidth/dxy);
        private var h:uint=Math.floor(stage.stageHeight/dxy);
        //
        private var d_mc:MovieClip;
        private var mi_ar:Array;
        private var canvas:MovieClip
        public function FlashTest() {
            var stats:Stats=new Stats();
            addChild( stats );
            canvas=new MovieClip();
            addChild(canvas)
            // constructor code
            var i:uint;
            var ii:uint;
            var scx:Number=stage.stageWidth*.5;
            var scy:Number=stage.stageHeight*.5;
            //
            w=Math.floor(stage.stageWidth/dxy);
            h=Math.floor(stage.stageHeight/dxy);
            //
            var sx:Number=(stage.stageWidth-dxy*(w-1))*.5
            var sy:Number=(stage.stageHeight-dxy*(h-1))*.5
            //
            var p:MovieClip;
            mi_ar=new Array()
            for(i=0;i<h;i++){
                for(ii=0;ii<w;ii++){
                    if(i==0 || i==h-1 || ii==0 ||  ii==w-1){
                        p=new Pin();
                    }else{
                        p=new Mi();
                    }
                    canvas.addChild(p);
                    p.x=sx+ii*dxy;
                    p.y=sy+i*dxy;
                    mi_ar.push(p)
                }
            }
            for(i=0;i<mi_ar.length;i++){
                if(i>w-1 && i<mi_ar.length-w && i%w!=0 && i%w !=w-1){
                    p=mi_ar[i];
                    p.x+=-10+20*Math.random();
                    p.y+=-10+20*Math.random();
                    p.init([mi_ar[i-1],mi_ar[i+1],mi_ar[i-w],mi_ar[i+w]])
                }
            }
            //
            addEventListener(Event.ENTER_FRAME,ent)
        }
        //

        private function ent(evt:Event):void{
            var i:uint;
            var ii:uint;
            var g:Graphics=canvas.graphics;
            g.clear()
            g.lineStyle(1,0xFF0000);
            for(i=0;i<mi_ar.length;i++){
                if( i<mi_ar.length-w && i%w !=w-1){
                    g.moveTo(mi_ar[i].x,mi_ar[i].y);
                    g.lineTo(mi_ar[i+1].x,mi_ar[i+1].y);
                    g.lineTo(mi_ar[i+w+1].x,mi_ar[i+w+1].y);
                    g.lineTo(mi_ar[i+w].x,mi_ar[i+w].y);
                    g.lineTo(mi_ar[i].x,mi_ar[i].y);
                }
            }
        }
        //
    }
}


import flash.display.Graphics;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;

class Mi extends MovieClip {
    private var m:Number=1
    private var k:Number=0.01;
    private var t:Number=0.02;
    private var m_ar:Array
    
    private var ax:Number;
    private var ay:Number;
    private var vx:Number;
    private var vy:Number;
    private var flag:Boolean=true;
    public function Mi() {
        // constructor code
        var g:Graphics=this.graphics;
        g.beginFill(0xFF0000);
        g.drawCircle(0,0,5);
        
    }
    public function init(_ar:Array):void{
        m_ar=_ar;
        ax=0;
        vx=0;
        ay=0;
        vy=0;
        this.buttonMode=true;
        this.addEventListener(Event.ENTER_FRAME,ent);
        this.addEventListener(MouseEvent.MOUSE_DOWN,mdwn);
    }
    //
    private function mdwn(evt:MouseEvent):void{
        flag=false;
        this.startDrag()
        stage.addEventListener(MouseEvent.MOUSE_UP,mup)
    }
    private function mup(evt:MouseEvent):void{
        flag=true;
        this.stopDrag();
        vx=0;
        vy=0;
        stage.removeEventListener(MouseEvent.MOUSE_UP,mup)
    }
    private function ent(evt:Event):void{
        if(flag){
            var i:uint
            var dx:Number=0;
            var dy:Number=0;
            for(i=0;i<m_ar.length;i++){
                var mc:MovieClip=m_ar[i];
                dx+=mc.x-this.x;
                dy+=mc.y-this.y;
            }
            ax=k*dx//
            ay=k*dy//
            vx+=ax-t*vx;
            vy+=ay-t*vy;
            this.x+=vx;
            this.y+=vy;
        }
    }
}

import flash.display.MovieClip;
import flash.display.Graphics;
import flash.events.MouseEvent;
class Pin extends MovieClip {
    public function Pin() {
        // constructor code
        var g:Graphics=this.graphics;
        g.beginFill(0x000000);
        g.drawCircle(0,0,5);
        this.buttonMode=true;
        this.addEventListener(MouseEvent.MOUSE_DOWN,mdwn)
    }
    private function mdwn(evt:MouseEvent):void{
        this.startDrag()
        stage.addEventListener(MouseEvent.MOUSE_UP,mup);
    }
    private function mup(evt:MouseEvent):void{
        this.stopDrag();
        this.removeEventListener(MouseEvent.MOUSE_UP,mup);
    }
}


