/********************************************************/
/*  Copyright © YoAmbulante (alex.nino@yoambulante.com) */
/*                                                      */
/*  You may modify or sell this code, you can do        */
/*  whatever you want with it, I don't mind. Just don't */
/*  forget to contribute with a beer thru the website.  */
/*                                                      */
/*  Visit http://www.yoambulante.com to clarify any     */
/*  doubt with this code. Note that donators have       */
/*  priority on information enquiries.                  */
/*                                                      */
/********************************************************/
package {
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.MouseEvent;    
    import flash.filters.BlurFilter;    
    import flash.geom.Matrix;
    import flash.geom.Rectangle;    
    [SWF(width="500", height="100", frameRate="30", backgroundColor="#FFFFFF")]
    public class GrassMain extends Sprite {        
        private var a:Array;
        private var mouse_down:Boolean = false;                
        private var drawing:Boolean = false;        
        private var blur_rect:Rectangle;
        private var blur_mx:Matrix;                            
        private var gradient_bg:Sprite;
        function GrassMain():void {            
            //-------------- gradient background ------------------            
            gradient_bg = new Sprite();
            var m:Matrix = new Matrix();
            m.createGradientBox(500, 100, (Math.PI / 180) * 90, 0, 0);            
            gradient_bg.graphics.beginGradientFill("linear", [0x9ED0F1, 0xD6EDF5], [1, 1], [0,130], m);
            gradient_bg.graphics.drawRect(0, 0, 500, 100);    
            gradient_bg.cacheAsBitmap = true;            
            this.addChild(gradient_bg);            
            //-------------- gradient background ------------------
            //-------------- grass layers ------------------
            var grass_areas:Array = new Array();            
            var i:int;
            var sp:Sprite;
            var blur_fac:int = 2;
            for (i = 0; i < 3; i++) {                
                sp = new Sprite();
                sp.mouseEnabled = false;
                sp.mouseChildren = false;
                if (i != 1){
                    var blur_eff:BlurFilter = new BlurFilter(blur_fac, blur_fac, 1);
                    blur_fac *= 2;                    
                    sp.filters = [blur_eff];                    
                }
                grass_areas.push(sp);
                sp.x = 4;
                sp.y = 20;
                this.addChild(sp);            
                //add mask for each
                var grass_mask:Shape = new Shape();
                grass_mask.graphics.beginFill(0, 1);                
                grass_mask.x = 6;
                grass_mask.graphics.drawRect(0, 0, 500, 100);            
                this.addChild(grass_mask);
                sp.mask = grass_mask;
            }
            //-------------- grass layers ------------------
            //-------------- grass leaves ------------------
            var max_size:int = 0;
            a = new Array();
            for (i = 0; i < 500; i++) {
                var dp:int = int(i / 167);
                sp = grass_areas[dp];
                var len:int = Grass.rand(100) + 50;
                if (len > max_size) {
                    max_size = len;
                }
                var g:Grass = new Grass(Grass.rand(600), 0, len, (Grass.rand(100) / 100) * 1, 60, Grass.rand(40) - 20, (Grass.rand(100) / 100) * 1);
                if (dp == 0) {
                    g.y += 15;
                    g.scaleX = .75;
                    g.scaleY = g.scaleX;                    
                } else if (dp == 2) {
                    g.y -= 10;
                    g.scaleX = 1.7;
                    g.scaleY = g.scaleX;                
                }
                sp.addChild(g);
                g.next(0, true);            
                a.push(g);
            }    
            //-------------- grass leaves ------------------            
            this.addEventListener(Event.ENTER_FRAME, enterFrame);            
            this.addEventListener(MouseEvent.MOUSE_DOWN, mDown);            
        }                
        public function mDown (e:MouseEvent):void {                
            mouse_down = true;            
            stage.addEventListener(MouseEvent.MOUSE_UP, mUp);
            this.addEventListener(MouseEvent.MOUSE_UP,  mUp);            
            this.addEventListener(MouseEvent.ROLL_OUT,  mUp);            
        }
        public function mUp (e:MouseEvent):void {                        
            mouse_down = false;                    
            stage.removeEventListener(MouseEvent.MOUSE_UP, mUp);
            this.removeEventListener(MouseEvent.MOUSE_UP,  mUp);            
            this.removeEventListener(MouseEvent.ROLL_OUT,  mUp);            
        }        
        public function enterFrame (e:Event):void {
            if (drawing || mouse_down){    
                drawing    = false;
                for (var i:int = 0; i < a.length; i++) {
                    var wind:Number = 0;
                    if (mouse_down){                    
                        var diff:Number = Grass(a[i]).x - stage.mouseX;
                        if (Math.abs(diff) < 100) {                            
                            wind = (1 - Math.abs(diff / 100)) * 50 * (diff < 0 ? -1 : 1);                        
                        }
                    }
                    if (Grass(a[i]).next(wind, false)) {                    
                        drawing    = true;                        
                    }                    
                }                
            }            
        }
        
    }    
}
class Grass extends flash.display.Shape {        
    private var size:Number; /* pixels length */
    private var stiffness:Number; /* 0..1 how flexible it should be */
    private var springiness:Number; /* max limit applyed by the wind */
    private var wind_force:Number; //used for moving the whole body, is like his actual position.     
    private var zero_force:Number; //is the position when it is stopped.
    private var shadow_width:Number;             
    private var shadow_color:Number;
    private var grass_color:Number;
    private var px:Number; //x position
    private var py:Number; //y position        
    //using in drawing function.
    private var st_mov:Number; //depending of its position, ending point will be lower.
    private var tension:Number; //constant value, see object creation
    private var tension2:Number; //constant value, see object creation
    private var redraw:Boolean;                            
    //vars used in animation.
    private var vel:Number = 0;    //velocity applyed during animation.
    private var fact_friction:Number;
    private var fact_acc:Number;
    private var last_wf:Number;
    private var returning:Boolean;
    private var shadow_green:uint;
    private var grass_green:uint;
    private var status:uint;
    //colors during animation.
    public static var GRASS_GREEN:uint = 120;    
    public static var SHADOW_GREEN:uint = 60;    
    public static var GRASS_RED:uint = 0x66;
    public static var SHADOW_RED:uint = 0x33;        
    function Grass(newx:Number, newy:Number, len:Number, st:Number, sp:Number, zf:Number, sw:Number) {            
        status = 0;
        redraw = true;
        returning = false;            
        x = newx;
        y = newy;
        px = 0;
        py = 170;
        size = len;
        stiffness = st;        
        st_mov = .8 + (1 - stiffness) * .2;
        springiness = sp;
        zero_force = zf;
        shadow_width = sw;            
        shadow_green = rand(40);
        grass_green = rand(40);            
        shadow_color = RGBtoNum(SHADOW_RED, SHADOW_GREEN + shadow_green, 0x00);
        grass_color = RGBtoNum(GRASS_RED, GRASS_GREEN + grass_green, 0x00);            
        tension = this.size / 4;
        tension2 = tension / 16;            
        fact_friction = .95 + (stiffness * .025);            
        resetSpeed();
    }
    public static function rand(n:uint):uint {
        return int(Math.random() * n);
    }
    public static function RGBtoNum(i_r:int,i_g:int,i_b:int):Number{
        return i_r<<16 | i_g<<8 | i_b;
    }        
    public function resetSpeed():void {
        fact_acc = 0;        
        vel = 0;    
    }
    private function applyAnimation(limit:Number):Boolean {
        var diff:Number = limit-wind_force;        
        if (fact_acc == 0){
            fact_acc = 0.5 * (diff < 0 ? -1 : 1);
            fact_acc += (stiffness * .45)
        } else if ((diff > 0 && fact_acc < 0) || (diff < 0 && fact_acc > 0)){                
            fact_acc *= -1;        
        }                
        var old_vel:Number = vel;            
        vel = (vel+fact_acc)*fact_friction;
        if ((vel > 0 && old_vel < 0) || (vel < 0 && old_vel > 0)){
            fact_acc *= .7;
            if (Math.abs(diff) <= 0.65){                    
                return false;
                vel = 0;
            }
        }                
        wind_force += vel;            
        return true;
    }
    public function next(wf:Number, refresh_color:Boolean = false):Boolean {
        if (wf != 0){
            if (status != 1) {
                resetSpeed();                    
                status = 1;
            }
            if (last_wf != wf) {
                last_wf = wf;
                if (fact_acc < .5) {
                    fact_acc += .5;
                }
            }
            returning = true;
            redraw = true;                
            applyAnimation(zero_force + wf);
        } else if (returning) {    
            if (status != 2) {
                resetSpeed();
                status = 2;
            }
            redraw = true;
            returning = applyAnimation(zero_force);
        } else {
            wind_force = zero_force;
            status = 0;
        }    
        if (redraw || refresh_color) {
            if (refresh_color) {
                shadow_color = RGBtoNum(SHADOW_RED, SHADOW_GREEN + shadow_green, 0x00);
                grass_color = RGBtoNum(GRASS_RED, GRASS_GREEN + grass_green, 0x00);
            }
            var canvas:flash.display.Graphics = this.graphics;                
            canvas.clear();                
            var end_x:Number = px+wind_force;
            var end_y:Number = py - size + (Math.abs(wind_force) * Math.abs(wind_force/springiness)*.3);        
            var control_y:Number = tension*stiffness+tension;                
            canvas.beginFill(shadow_color);
            canvas.moveTo(px,py);
            canvas.curveTo(px,control_y,end_x,end_y);
            canvas.curveTo(px+tension2,control_y,px+tension2,py);
            canvas.lineTo(px,py);
            canvas.endFill();
            canvas.beginFill(grass_color);
            canvas.moveTo(px,py);
            canvas.curveTo(px,control_y,end_x,end_y);
            canvas.curveTo(px-tension2*(1+shadow_width),control_y,px-tension2,py);
            canvas.lineTo(px,py);
            canvas.endFill();                
            redraw = wind_force != zero_force;                
            return redraw; 
        }            
        return false;
    }        
}