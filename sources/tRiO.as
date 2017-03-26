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
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.system.LoaderContext;
    import flash.system.SecurityDomain;
    import flash.system.ApplicationDomain;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.net.URLRequest;
    [SWF(width="650", height="600", frameRate="30", backgroundColor="#FFFFFF")]
    public class BalloonMain extends Sprite {        
        private var points:Array;
        private var sticks:Array;
        private var numdots:int;        
        private var prevPoint:Point;
        private var startPoint:Point;
        private var endPoint:Point;
        private var nextPoint:Point;
        private var xloc:Number;
        private var yloc:Number;        
        private var draggable:DraggableDot;
        private var draggers:Array;
        private var balloon:Sprite;
        private var rotation_target:Number;        
        private const numSteps:int = 20;
        private const numStepsFact:int = 1/numSteps;
        private const RAD_DEG:Number = (180 / Math.PI);                
        private var t:TextField;
        function BalloonMain():void {            
            rotation_target = 0;
            stage.align = StageAlign.TOP_LEFT;            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            // entry point            
            points = new Array();
            var i:int;
            for (i=0; i<30; i++){
                points[i] = new VerletPoint(i%2==0?400:405, 500-(i*5));
            }
            numdots = points.length;        
            //points[6].anchor(400, 500);
            prevPoint = new Point();
            startPoint = new Point();
            endPoint = new Point();
            nextPoint = new Point();            
            
            sticks = new Array();
            for (i=0; i<points.length-1; i++){
                sticks.push(new VerletStick(points[i], points[i+1]));
            }            
            //create draggers
            draggers = new Array();
            for (i = 0; i < sticks.length; i++) {
                var sp:DraggableDot = new DraggableDot(VerletStick(sticks[i])._pointA);                
                sp.graphics.beginFill(0x0011FF,0);
                sp.graphics.drawCircle(0, 0, 5);                
                sp.addEventListener(MouseEvent.MOUSE_DOWN, drag);
                addChild(sp);
                draggers[i] = sp;                
            }
            stage.addEventListener(MouseEvent.MOUSE_UP, drop);
            draggable = null;            
            balloon = new Sprite();
            balloon.y = 500;
            addChild(balloon);            
            
            t = new TextField();
            t.text = "Balloon, beta version by Alex Nino (YoAmbulante.com), 28th Oct 2009 - 3:45am";
            t.selectable = false;
            t.width = 350;
            t.textColor = 0xCCCCCC;
            addChild(t);
            
            this.addEventListener(Event.ENTER_FRAME, enterFrame);
            enterFrame(null);
            
            //load external balloon skin asset
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, attachBalloonSkin);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, emptyEvent);
            loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, emptyEvent);
    
            var context:LoaderContext = new LoaderContext();
            context.applicationDomain = ApplicationDomain.currentDomain;
            context.securityDomain = SecurityDomain.currentDomain;
            
            loader.load(new URLRequest("http://www.yoambulante.com/swf/labs/BalloonSkin.swf"), context);
        }        
        private function attachBalloonSkin(e:Event):void {
            var C:Class = LoaderInfo(e.currentTarget).applicationDomain.getDefinition("BalloonRed") as Class;
            balloon.addChild( new C as Sprite );
        }
        private function emptyEvent(e:Event):void {
            t.text = "error "+e;
        }
        private function drag(e:MouseEvent):void {
            draggable = e.currentTarget as DraggableDot;            
            draggable.startDrag(true);            
            draggable.dragging = true;
            draggable.point.anchored = true;            
        }
        private function drop(e:MouseEvent):void {
            if (draggable == null) return;
            draggable.stopDrag();            
            draggable.dragging = false;
            draggable.point.anchored = false;            
            draggable = null;
        }
        private function enterFrame(e:Event):void {
            if (draggable != null) {
                draggable.point.x = draggable.x;
                draggable.point.y = draggable.y;
            }                
            var total:int = sticks.length - 1;
            var i:int;
            var time:Number = new Date().getTime();
            var stick:VerletStick;
            var moving:Boolean = true;
            for (i=0; i<=total; i++){
                stick = VerletStick(sticks[i]);                
                stick._pointA.y += .4;                
                stick._pointA.update(); //check new position depending on its position.
                if (i == total){
                    stick._pointB.y += .4;
                    if (balloon.y > 80){
                        stick._pointB.y -= draggable?10:14; //apply ballon force
                    } else {
                        stick._pointB.y -= 12; //neutral force                        
                    }
                }
                stick._pointB.update();                
                stick.update();    //stick the two points togueter    i >= dot_index
            }
            var loops:int = 11;
            do {
                for (i = 0; i <= total; i++) {
                    stick = VerletStick(sticks[i]);    
                    stick.update();    //stick the points togueter                        
                }
            } while (--loops > 0);                    
            //update draggers positions.
            for (i = 0; i < sticks.length; i++) {
                DraggableDot(draggers[i]).update();
            }                
            balloon.x = points[numdots - 3].x;
            balloon.y = points[numdots - 3].y;            
            //renders all dots using cardinal splines.
            if (true) {
                graphics.clear();    
                graphics.lineStyle(1,0x999999,1,false,"normal","round","round");
                var n:uint = numdots - 2;
                graphics.moveTo(points[0].x, points[0].y);                
                //update rotation.            
                var dx:Number = balloon.x - points[numdots - 10].x;
                var dy:Number = balloon.y - points[numdots - 10].y;
                var dist:Number = Math.sqrt(dx * dx + dy * dy);        
                balloon.rotation = Math.asin(dx / dist) * RAD_DEG * .5;
                for (i = 2; i < n; i++) {
                    if (i-1 >= 0){
                        prevPoint.x = points[i-1].x;
                        prevPoint.y = points[i-1].y;
                    }                
                    startPoint.x = points[i].x;
                    startPoint.y = points[i].y;                    
                    if (i+1 < numdots){
                        endPoint.x = points[i+1].x;
                        endPoint.y = points[i+1].y;    
                    }
                    if (i+2 < numdots){
                        nextPoint.x = points[i+2].x;
                        nextPoint.y = points[i+2].y;    
                    }            
                    for (var j:int=0; j<=numSteps; j++) {                                        
                        xloc = getCardinalSplinePoint(prevPoint.x, startPoint.x, endPoint.x, nextPoint.x, numStepsFact, j, .5);
                        yloc = getCardinalSplinePoint(prevPoint.y, startPoint.y, endPoint.y, nextPoint.y, numStepsFact, j, .5);                    
                        if ((i == 0) && (j == 0)) {
                            graphics.moveTo(xloc, yloc);
                        } else {
                            graphics.lineTo(xloc, yloc);
                        }
                    }
                }
            }
        }        
    }    
}
function getCardinalSplinePoint(prevVal:Number, startVal:Number, endVal:Number, nextVal:Number, numSteps:Number, curStep:Number, tension:Number):Number {
    var t1:Number = (endVal - prevVal)*tension; 
    var t2:Number = (nextVal - startVal)*tension;                        
    var s:Number = curStep * numSteps; 
    var h1:Number = (2 * Math.pow(s,3)) - (3 * Math.pow(s,2)) + 1; 
    var h2:Number = -(2 * Math.pow(s,3)) + (3 * Math.pow(s,2)); 
    var h3:Number = Math.pow(s,3) - (2 * Math.pow(s,2)) + s; 
    var h4:Number = Math.pow(s,3) - Math.pow(s,2);            
    var value:Number = (h1 * startVal) + (h2 * endVal) + (h3 * t1) + (h4 * t2);            
    return value; 
}
class DraggableDot extends flash.display.Sprite {
    public var point:VerletPoint;            
    public var dragging:Boolean;                    
    public function DraggableDot(p:VerletPoint) {                        
        dragging = false;
        point = p;                        
        update();
    }
    public function update():void {
        if (!dragging){
            x = point.x;
            y = point.y;
        }
    }    
}
class VerletPoint {
    public var x:Number;
    public var y:Number;    
    public var anc_x:Number;
    public var anc_y:Number;
    public var anchored:Boolean;                
    private var _oldX:Number;
    private var _oldY:Number;
    private static const SPEED_FACT:Number = .92;
    function VerletPoint(x:Number, y:Number) {                        
        anchored = false;
        anc_x = 0;
        anc_y = 0;
        setPosition(x, y);
    }
    public function anchor(x:Number, y:Number):void {
        anchored = true;
        anc_x = x;
        anc_y = y;
    }
    public function update():void {
        //move this dot to next position depending on its speed and direction.            
        var tempX:Number = x;
        var tempY:Number = y;
        if (!anchored){
            x += vx; //vel in x (speed)
            y += vy; //vel in y (speed)
        }
        _oldX = tempX;
        _oldY = tempY;
    }
    public function setPosition(x:Number, y:Number):void {
        //setup a point position and reset speed.
        this.x = _oldX = x;
        this.y = _oldY = y;
    }
    public function constrain(left:Number, right:Number, top:Number, bottom:Number):void {
        //ensure that the points are still inside limits (the screen)
        x = Math.max(left, Math.min(right, x));
        y = Math.max(top, Math.min(bottom, y));
    }
    public function get vx():Number    {
        return (x - _oldX) * SPEED_FACT;
    }
    public function get vy():Number {
        return (y - _oldY) * SPEED_FACT;
    }        
}
class VerletStick {
    public var _pointA:VerletPoint;
    public var _pointB:VerletPoint;
    private var _length:Number;        
    function VerletStick(pointA:VerletPoint, pointB:VerletPoint, length:Number = NaN) {
        _pointA = pointA;
        _pointB = pointB;            
        if(isNaN(length)){
            var dx:Number = _pointA.x - _pointB.x;
            var dy:Number = _pointA.y - _pointB.y;
            _length = Math.sqrt(dx * dx + dy * dy);
        } else {
            _length = length;
        }
    }
    public function update(stiff:Boolean = false):void {
        var dx:Number = _pointB.x - _pointA.x;
        var dy:Number = _pointB.y - _pointA.y;                        
        var dist:Number = Math.sqrt(dx * dx + dy * dy);
        var diff:Number = _length - dist;
        var offsetX:Number = (diff * dx / dist) / 2;
        var offsetY:Number = (diff * dy / dist) / 2;        
        _pointA.x -= offsetX;
        _pointA.y -= offsetY;
        _pointB.x += offsetX;
        _pointB.y += offsetY;
    }
}
