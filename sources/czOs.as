package{
    import flash.events.StatusEvent;
    import com.bit101.components.*;
    import net.hires.debug.Stats;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.events.Event;
    
    
    public class FlashTest extends Sprite{
        private var lines:Lines;
        private var text_txt:TextField;
        public function FlashTest ():void{
            
            stage.align=StageAlign.TOP_LEFT;
            stage.scaleMode=StageScaleMode.NO_SCALE;

            var stats:Stats=new Stats();
            addChild( stats );
            
            lines=new Lines();
            lines.visible=false;
            addChild(lines);
            lines.init();
            
            text_txt = new TextField();
            text_txt.type=TextFieldType.INPUT;
            text_txt.border=true;
            text_txt.borderColor=0xCCCCCC;
            text_txt.x=75;
            text_txt.y=5;
            text_txt.width = 350;
            text_txt.height = 20;
            text_txt.text = "ベジェ曲線上を文字が等速で走ります。ここにインプットもできますよ。";  
            addChild(text_txt);
            
            var submit_btn:PushButton=new PushButton();
            submit_btn.x=75;
            submit_btn.y=30;
            submit_btn.label="submit";
            addChild(submit_btn);
            submit_btn.addEventListener(MouseEvent.CLICK,nclick);
            var visible_btn:PushButton=new PushButton();
            visible_btn.x=75;
            visible_btn.y=55;
            visible_btn.label="visible lines"
            addChild(visible_btn);
            visible_btn.addEventListener(MouseEvent.CLICK,vclick);
            setRunText()
        }
        /**/
        private function nclick(evt:MouseEvent):void {
            setRunText()
        }
        private function setRunText():void{
            var rt:RunText=new RunText(lines);
            addChild(rt);
            rt.init(lines,text_txt.text);
        }
        private function vclick(evt:MouseEvent):void{
            lines.visible=!lines.visible;
        }
    }
}
//package{
import flash.display.MovieClip;
import flash.display.Graphics;

import flash.events.Event;
import flash.events.MouseEvent;

class Lines extends MovieClip{
    private var total:uint=300;
    private var v:Number =10;
    private var i:uint;
    private var p_num:uint=6;
    //
    public var dot_ar:Array=new Array();

    private var p_ar:Array=new Array();
    //
    private var d_mc:MovieClip;
    private var drag_c_mc:MovieClip;
    private var press_flag:Boolean=false;
    //
    private var gv:Graphics;
    //
    public function Lines(){ 
    }
    public function init():void{
        gv=this.graphics;
        p_ar=new Array();
        for (i=0; i<p_num; i++) {
            var p_mc:MovieClip=new MovieClip()
            p_ar.push(p_mc)
        
            addChild(p_mc)
            
            var c_line_mc:MovieClip=new MovieClip();
            var c_line_g:Graphics=c_line_mc.graphics;
            p_mc.c_line_mc=c_line_mc;
            p_mc.addChild(c_line_mc);
            
            p_mc.x=50+(stage.stageWidth-100)*Math.random()
            p_mc.y=50+(stage.stageHeight-100)*Math.random()
            var center_mc:MovieClip=new MovieClip();
            var pb_g:Graphics=center_mc.graphics;
            pb_g.beginFill(0xcccccc,0.1)
            pb_g.drawCircle(0,0,20);
            
            p_mc.addChild(center_mc);
            center_mc.addEventListener(MouseEvent.MOUSE_DOWN,mdwn);
            //
            p_mc.buttonMode=true;
            var ra:Number=Math.PI*Math.random();
            var c0_p:MovieClip=new MovieClip();
            var pg:Graphics=c0_p.graphics;
            pg.beginFill(0x000000);
            pg.drawCircle(0,0,5);
            p_mc.addChild(c0_p);
            c0_p.x=100*Math.cos(ra);
            c0_p.y=100*Math.sin(ra);
            //
            p_mc.addChild(c0_p);
        
            var c1_p:MovieClip=new MovieClip();
            pg=c1_p.graphics;
            pg.beginFill(0x000000);
            pg.drawCircle(0,0,5);
            p_mc.addChild(c1_p);
            c1_p.x=100*Math.cos(ra-Math.PI);
            c1_p.y=100*Math.sin(ra-Math.PI);
            //
            p_mc.p_ar=new Array(c0_p,c1_p)
            c0_p.another=c1_p;
            c1_p.another=c0_p;
            c0_p.flag=true;
            c1_p.flag=true;
            c0_p.addEventListener(Event.ENTER_FRAME,c_ent);
            c1_p.addEventListener(Event.ENTER_FRAME,c_ent);
            c0_p.addEventListener(MouseEvent.MOUSE_DOWN,c_press);
            c1_p.addEventListener(MouseEvent.MOUSE_DOWN,c_press);
            //
            c_line_g.lineStyle(1,0x000000,0.5)
            c_line_g.moveTo(0,0)
            c_line_g.lineTo(c0_p.x,c0_p.y);
            //
            c_line_g.moveTo(0,0)
            c_line_g.lineTo(c1_p.x,c1_p.y);
        
            //
            p_mc.addChild(c0_p);
        }
        //
        drawLines();
        addEventListener(Event.ENTER_FRAME,ent);
    }
    
    private function mdwn(evt:MouseEvent):void {
        press_flag=true;
        d_mc=evt.currentTarget as MovieClip;
        MovieClip(d_mc.parent).startDrag();
        stage.addEventListener(MouseEvent.MOUSE_UP,mup);
    }
    private function mup(evt:MouseEvent):void {
        press_flag=false;
        d_mc.stopDrag();
        stage.removeEventListener(MouseEvent.MOUSE_UP,mup);
    }

    private function c_press(evt:MouseEvent):void{
        press_flag=true;
        //
        var _mc:MovieClip=evt.currentTarget as MovieClip;
        _mc.flag=false;
        _mc.startDrag();
        drag_c_mc=_mc;
        stage.addEventListener(MouseEvent.MOUSE_UP,stage_mup);
    }
    private function stage_mup(evt:MouseEvent):void{
        press_flag=false;
        //
        drag_c_mc.stopDrag();
        drag_c_mc.flag=true;
        stage.removeEventListener(MouseEvent.MOUSE_UP,stage_mup);
    
    }
    //
    private function c_ent(evt:Event):void{
        var _mc:MovieClip=evt.currentTarget as MovieClip;
        if(_mc.flag){
            var another:MovieClip=_mc.another;
            var another_theta:Number=Math.atan2(another.y,another.x);
            var another_r:Number=Math.sqrt(Math.pow(another.y,2)+Math.pow(another.x,2))
            _mc.x=another_r*Math.cos(another_theta+Math.PI);
            _mc.y=another_r*Math.sin(another_theta+Math.PI);
        }
    }
    //
    private function ent(evt:Event):void{
        if(press_flag){
            drawLines();
        }
    }
    //
    private function drawLines():void{
        var i:uint
        gv.clear();
        gv.lineStyle(1,0x000000,0.5);
        dot_ar=new Array();
        for(i=0;i<p_ar.length-1;i++){
            drawLine(p_ar[i],p_ar[i+1]);
        }
        drawCP();
    }
    //
    private function drawLine(p0:MovieClip,p1:MovieClip):void {
        gv.moveTo(p0.x,p0.y);
        var c0:MovieClip=p0.p_ar[1];
        var c1:MovieClip=p1.p_ar[0];
        dot_ar.push([p0.x,p0.y]);
        var i:uint;
        //
        for (i=1; i<total; i++) {
            var cnt:Number=i/total;
            var c0p0x:Number=(p0.x+c0.x)*cnt+p0.x*(1-cnt);
            var c0p0y:Number=(p0.y+c0.y)*cnt+p0.y*(1-cnt);
            var c0c1x:Number=(p1.x+c1.x)*cnt+(p0.x+c0.x)*(1-cnt);
            var c0c1y:Number=(p1.y+c1.y)*cnt+(p0.y+c0.y)*(1-cnt);
            
            //
            var c1p1x:Number=p1.x*cnt+(p1.x+c1.x)*(1-cnt);
            var c1p1y:Number=p1.y*cnt+(p1.y+c1.y)*(1-cnt);
            //
            var cc0x:Number=c0c1x*cnt+c0p0x*(1-cnt);
            var cc0y:Number=c0c1y*cnt+c0p0y*(1-cnt);
            var cc1x:Number=c1p1x*cnt+c0c1x*(1-cnt);
            var cc1y:Number=c1p1y*cnt+c0c1y*(1-cnt);
            //
            var px:Number=cc1x*cnt+cc0x*(1-cnt);
            var py:Number=cc1y*cnt+cc0y*(1-cnt);
            gv.lineTo(px,py);
            dot_ar.push([px,py])
        }
        gv.lineTo(p1.x,p1.y);
        //

    }
    private function drawCP():void{
        var i:uint;
        
        for (i=0; i<p_ar.length; i++) {
            var p_mc:MovieClip=p_ar[i];
            var c_line_mc:MovieClip=p_mc.c_line_mc;
            var c_g:Graphics=c_line_mc.graphics;
            c_g.clear()
            c_g.lineStyle(1,0x000000,0.5)
            var c0_p:MovieClip=p_mc.p_ar[0];
            var c1_p:MovieClip=p_mc.p_ar[1];
            c_g.moveTo(0,0)
            c_g.lineTo(c0_p.x,c0_p.y);
            //
            c_g.moveTo(0,0)
            c_g.lineTo(c1_p.x,c1_p.y);
        }
    }
    //
}



    import flash.display.MovieClip;
    
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;
    import flash.display.Bitmap;
    
    import flash.text.AntiAliasType;
    import flash.display.BlendMode;
    import flash.display.PixelSnapping;
    
    import flash.events.Event;
    
    class RunText extends MovieClip{
        private var lines:MovieClip;
        //
        private var v:Number=10
        
        private var lgt:Number;
        private var cnt:Number;
        private var _ar:Array;
        private var delete_ar:Array
        public function RunText(_mc:MovieClip):void{
            lines=_mc;
        }
        
        public function init(_mc:MovieClip,txt:String):void{
            var i:uint
            cnt=0;
            lgt=txt.length;
            _ar=new Array();
            delete_ar=new Array();
            for(i=0;i<lgt;i++){
                var st:String=txt.substr(i,1);
                var _mc:MovieClip=new MovieClip();
                addChild(_mc);
                setText(_mc,st);
                _ar.push(_mc)
            }
            
            addEventListener(Event.ENTER_FRAME,ent);
        }
        //
        private function setText(_mc:MovieClip,txt:String):void {
            var tf:TextField=new TextField();
            tf.selectable=false;
            tf.antiAliasType=AntiAliasType.ADVANCED;
            tf.multiline=true;
            tf.wordWrap=true;
            //
            var format:TextFormat=new TextFormat();
            format.size=18;
            format.color=0xFF0000;
            tf.defaultTextFormat=format;
            //
            tf.text=txt
            //
            tf.width=tf.textWidth+5;
            var bw:Number=tf.width
            var bh:Number=tf.textHeight
            //
            var bmp_data : BitmapData = new BitmapData(bw,bh , true , 0xFFFFFF);
            var matrix : Matrix = new Matrix();
            var color : ColorTransform = new ColorTransform();
            var rect : Rectangle = new Rectangle(0,0,tf.width,tf.textHeight);
            bmp_data.draw(tf, matrix, color, BlendMode.NORMAL, rect, true);
            var bmp_obj : Bitmap = new Bitmap( bmp_data , PixelSnapping.AUTO , true);
            bmp_obj.x=bmp_obj.width*-0.5;
            bmp_obj.y=bmp_obj.height*-0.5;
            //
            //
            _mc.addChild(bmp_obj)
            _mc.cnt=1;
            _mc.x=lines.dot_ar[0][0];
            _mc.y=lines.dot_ar[0][1];
        }
        //
        private function ent(evt:Event):void{
            var i:uint;
            var ii:uint;
            //
            var dot_ar:Array=lines.dot_ar
            var top_mc:MovieClip=_ar[0]
            var Length:Number=0;
            var n:uint=0;
            for(i=top_mc.cnt;i<dot_ar.length;i++){
                n++;
                Length+=Math.sqrt(Math.pow(dot_ar[i][0]-dot_ar[i-1][0],2)+Math.pow(dot_ar[i][1]-dot_ar[i-1][1],2));
                if(Length>v){
                    break;
                }
            }
            top_mc.cnt+=n;

            for(i=1;i<_ar.length;i++){
                var _mc:MovieClip=_ar[i];
                Length=0;
                n=0;
                for(ii=top_mc.cnt-2;ii>=0;ii--){
                    n++;
                    Length+=Math.sqrt(Math.pow(dot_ar[ii][0]-dot_ar[ii+1][0],2)+Math.pow(dot_ar[ii][1]-dot_ar[ii+1][1],2));
                    if(Length>20*i){
                        break;
                    }
                    if(ii==0){
                        n=0
                    }
                }
                if(n!=0){
                    _mc.cnt=top_mc.cnt-n;
                }
                mc_move(_mc,dot_ar);
                //
            }
            mc_move(top_mc,dot_ar);    
            //
        }
        //
        private function mc_move(_mc:MovieClip,dot_ar:Array):void{
            if(_mc.cnt>=dot_ar.length){
                //uzuStart(_mc);
                
                textComp();
            }else if (_mc.cnt>0) {
                var theta:Number=Math.atan2(dot_ar[_mc.cnt][1]-dot_ar[_mc.cnt-1][1],dot_ar[_mc.cnt][0]-dot_ar[_mc.cnt-1][0]);
                _mc.rotation=theta*(180/Math.PI)
                _mc.x=dot_ar[_mc.cnt][0];
                _mc.y=dot_ar[_mc.cnt][1];
            }
        }
        //
        private function textComp():void{
            var _mc:MovieClip=_ar.shift();
            _mc.visible=false;
            delete_ar.push(_mc);
            cnt++;
            if(cnt==lgt){
                removeEventListener(Event.ENTER_FRAME,ent);
                parent.removeChild(this)
                //addEventListener(Event.ENTER_FRAME,removeAlphaMove);
            }
        }
    }
