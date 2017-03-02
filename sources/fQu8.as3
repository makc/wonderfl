// forked from undo's ぼんよよよ〜ん forked from: spring ball
// forked from hacker_szoe51ih's spring ball
//「ActionScript3.0」アニメーション参照
package  {
    import flash.display.MovieClip;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.events.MouseEvent;
    import flash.display.Shape;
    import flash.display.Sprite;
    public class Main extends Sprite {
        public static var ball_num:Number=24;
        public static var R:Number=100;
        //
        private var flag:Boolean=true;
        private var prex:Number;
        private var prey:Number;
        private var G:Number=0.098;
        //
        private var ball_mc:MovieClip;
        private var point_ar:Array;
        private var g:Graphics;
        public function Main() {
            var i:uint
            // constructor code
            ball_mc=new MovieClip();
            ball_mc.x=stage.stageWidth*0.5;
            ball_mc.y=stage.stageHeight*0.5;
            prex=ball_mc.x;
            prey=ball_mc.y;
            var v:Number=10;
            var v_theta:Number=2*Math.PI*Math.random();
            ball_mc.vx=v*Math.cos(v_theta);
            ball_mc.vy=v*Math.sin(v_theta)
            //
            addChild(ball_mc)
            g=ball_mc.graphics;
            point_ar=new Array();
            var pin_sh:Shape
            for(i=0;i<ball_num;i++){
                var point_mc:MovieClip=new MovieClip();
                ball_mc.addChild(point_mc)
                //
                var spring:Spring=new Spring(15,3,0.2,Math.floor(Math.random()*0xFFFFFF));
                spring.length=R;
                point_mc._spring = spring;
                point_mc.addChild(spring);
                //
                pin_sh=new Shape();
                point_mc.addChild(pin_sh);
                //
                var point_g:Graphics=pin_sh.graphics;
                point_g.beginFill(0x0);
                point_g.drawCircle(0,0,3);
                //
                var theta:Number=(2*Math.PI)*(i/ball_num)
                point_mc.x=R*Math.cos(theta)
                point_mc.y=R*Math.sin(theta)
                //
                spring.rotation=180+theta*180/Math.PI;

                
                point_ar.push(point_mc);
            }
            pin_sh=new Shape();
            ball_mc.addChild(pin_sh)
            var center_g:Graphics=pin_sh.graphics;
            center_g.beginFill(0x0)
            center_g.drawCircle(0,0,3)
            drawLines();
            ball_mc.buttonMode=true;
            ball_mc.addEventListener(MouseEvent.MOUSE_DOWN,mdwn);
            addEventListener(Event.ENTER_FRAME,ent);
        }
        //
        private var fy:Number=0;
        private var fx:Number=0;
        
        private function mdwn(evt:MouseEvent):void{
            var _mc:MovieClip=evt.currentTarget as MovieClip;
            flag=false;
            ball_mc.startDrag()
            stage.addEventListener(MouseEvent.MOUSE_UP,mup)
            ball_mc.removeEventListener(MouseEvent.MOUSE_DOWN,mdwn);
        }
        private function mup(evt:MouseEvent):void{
            flag=true;
            ball_mc.stopDrag()
            ball_mc.vx=ball_mc.x-prex;
            ball_mc.vy=ball_mc.y-prey;
            ball_mc.addEventListener(MouseEvent.MOUSE_DOWN,mdwn);
            stage.removeEventListener(MouseEvent.MOUSE_UP,mup)
        }
        
        private function ent(evt:Event):void{
            var i:uint;
            var k:Number=0.0005;
            var t:Number=0.001;
            if(flag){
                var ax:Number=fx;
                var ay:Number=G+fy;
                ball_mc.vx+=ax-t*ball_mc.vx;
                ball_mc.x+=ball_mc.vx;
                ball_mc.vy+=ay-t*ball_mc.vy;
                ball_mc.y+=ball_mc.vy;
                if(ball_mc.y<0){
                    ball_mc.y=0;
                    ball_mc.vy*=-1;
                }else if(ball_mc.y>stage.stageHeight){
                    ball_mc.y=stage.stageHeight;
                    ball_mc.vy*=-1;
                }

                if(ball_mc.x<0){
                    ball_mc.x=0;
                    ball_mc.vx*=-1;
                }else if(ball_mc.x>stage.stageWidth){
                    ball_mc.x=stage.stageWidth;
                    ball_mc.vx*=-1;
                }
                
                fx=0
                fy=0;
                for(i=0;i<ball_num;i++){
                    var F_x:Number=0;
                    var F_y:Number=0;
                    var gl_point:Point;
                    var point_mc:MovieClip=point_ar[i];
                    var theta:Number=(2*Math.PI)*(i/ball_num)
                    point_mc.x=R*Math.cos(theta)
                    point_mc.y=R*Math.sin(theta)
                    //
                    var p_point:Point=new Point(point_mc.x,point_mc.y);
                    var lg_point:Point=ball_mc.localToGlobal(p_point);
                    
                    if(lg_point.y>stage.stageHeight-10){
                        p_point=new Point(lg_point.x,stage.stageHeight-10)
                        gl_point=ball_mc.globalToLocal(p_point)
                        point_mc.y=gl_point.y;
                        F_y=k*(R*Math.sin(theta)-(ball_mc.y-point_mc.y));
                        fy+=F_y
                    }else if(lg_point.y<10){
                        p_point=new Point(lg_point.x,10)
                        gl_point=ball_mc.globalToLocal(p_point)
                        point_mc.y=gl_point.y;
                        F_y=-1*k*(R*Math.sin(theta)-(ball_mc.y-point_mc.y));
                        fy+=F_y
                    }

                    if(lg_point.x>stage.stageWidth-10){
                        p_point=new Point(stage.stageWidth-10,lg_point.y)
                        gl_point=ball_mc.globalToLocal(p_point)
                        point_mc.x=gl_point.x;
                        F_x=k*(R*Math.cos(theta)-(ball_mc.x-point_mc.x));
                        fx+=F_x
                    }else if(lg_point.x<10){
                        p_point=new Point(10,lg_point.y)
                        gl_point=ball_mc.globalToLocal(p_point)
                        point_mc.x=gl_point.x;
                        F_x=-1*k*(R*Math.cos(theta)-(ball_mc.x-point_mc.x));
                        fx+=F_x
                    }
                    var l:Number=Math.sqrt(Math.pow(point_mc.x,2)+Math.pow(point_mc.y,2));
                    theta=Math.atan2(point_mc.y,point_mc.x);
                    var spring:Spring=point_mc._spring;
                    spring.rotation=180+theta*180/Math.PI;
                    spring.length=l;
                }
            }
            drawLines();
            
            prex=ball_mc.x;
            prey=ball_mc.y;
            
        }
        private function drawLines():void{
            var i:uint=0
            g.clear();
            g.beginFill(0x0);
            g.drawCircle(0,0,5);
            g.lineStyle(1,0x0);
            g.beginFill(0xFF0000,0)
            g.moveTo(point_ar[ball_num-1].x,point_ar[ball_num-1].y);
            for(i=0;i<ball_num;i++){
                g.lineTo(point_ar[i].x,point_ar[i].y);
            }
        }
    }
}

import flash.display.Sprite;
import flash.display.Graphics;
class Spring extends Sprite
{
    private var _radius:Number;
    private var _numWind:uint;
    private var _color:uint;
    private var _lineStrength:Number;
    private var _length:Number = 200;

    private var _ratio:Number = 0.4;
    private var _mgn:int = 2;
    private var _springGraphic:Sprite;

    public function Spring(radius:Number = 30, numWind:uint = 5, lineStrength:Number = 3, color:uint = 0x0)
    {
        this._radius = radius;
        this._numWind = numWind;
        this._color = color;
        this._lineStrength = lineStrength;

        init();
    }

    private function init():void
    {
        this._springGraphic = new Sprite();
        var g:Graphics = this._springGraphic.graphics;
        g.clear();
        g.lineStyle(1, _color);
        g.moveTo(0, 0);

        var interval:Number = this.length / (this._numWind + this._mgn * 2);

        g.lineTo(interval * this._mgn, 0);
        for(var i:int = this._mgn; i < this._numWind + this._mgn; i++)
        {
            g.curveTo(interval * i, -this._radius, interval * (1 + this._ratio) / 2 + interval * i, -this._radius);
            g.curveTo(interval * (1 + this._ratio) + interval * i, -this._radius, interval * (1 + this._ratio) + interval * i, 0);
            g.curveTo(interval * (1 + this._ratio) + interval * i, this._radius, interval * (i + 1) + interval * this._ratio / 2, this._radius);
            g.curveTo(interval * (i + 1), this._radius, interval * (i + 1), 0);
        }
        g.lineTo(interval * (this._numWind + this._mgn * 2), 0);

        this.addChild(this._springGraphic);
    }

    public function get length():Number
    {
        return this._length;
    }

    public function set length(newLength:Number):void
    {
        this._length = newLength;
        this._springGraphic.width = this._length;
    }
}
