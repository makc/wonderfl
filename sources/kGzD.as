// forked from makc3d's Double Pendulum in QuickBox2D
// forked from makc3d's forked from: Double Pendulum Symplectic Euler
// forked from aont's Double Pendulum
package {
    import com.actionsnippet.qbox.*;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.utils.Timer;
    import org.si.sion.*;
    import org.si.sion.effector.SiCtrlFilterLowPass;
    import org.si.sion.utils.SiONPresetVoice;
    import org.si.sion.sequencer.SiMMLTrack;
    [SWF(backgroundColor=0x3f7f00)]
    public class DoublePendulum extends MovieClip
    {
        private var circle:Sprite;
        private var circleObject:QuickObject;
        private var circleA:QuickObject;
        private var circleB:QuickObject;
        private var circleCoords:Array = [];
        private var line_ratio:Number;
        private var length_1:Number = 0.5;
        private var length_2:Number = 0.25;
        private var radius:Number = 2;
        
        private var mass_1:Number = 0.08;
        private var mass_2:Number = 0.01;
        private var color_3:Number = 0xff7f00;
        private var center:Number;
        private var bd:BitmapData;
        private var ct:ColorTransform;
        
        private var strys:Array;
        private var strns:Array;
        private var circPy:Number;
        private var circCy:Number;
        private var circBPy:Number;
        private var circBCy:Number;

        private var driver:SiONDriver;
        private var voice:SiONVoice;
        
        public function DoublePendulum()
        {
            this.center = 230;
            this.line_ratio = center /  (this.length_1+this.length_2);

            bd = new BitmapData (465, 465, true, 0); addChild (new Bitmap (bd));
            ct = new ColorTransform; ct.color = color_3;
            ct.alphaMultiplier = 1 - 1e-3;

            circle = new Sprite; circle.graphics.beginFill (0xffffff);
            circle.graphics.drawCircle (0, 0, radius);

            var sim:QuickBox2D = new QuickBox2D(this, { debug:false } );
            circleA = sim.addCircle({x:465/2/30, y:465/2/30,
                radius:8/30, density:0});
            circleB = sim.addCircle({x:465/2/30, y:(465/2 + this.length_1*line_ratio)/30,
                radius:8/30, density:mass_1});
            circleObject = sim.addCircle({x:465/2/30, y:(465/2 + (this.length_1 + this.length_2)*line_ratio)/30,
                radius:8/30, density:mass_2});

            sim.addJoint({type:"distance", a:circleA.body, b:circleB.body});
            sim.addJoint({type:"distance", a:circleB.body, b:circleObject.body});

            strys = [5, 8, 10, 11, 13];
            strns = [10, 7, 5, 3, 0];
            for (var i:int = 0; i < strys.length; i++) {
                sim.addBox( { x:0, y:strys[i], width:465, height:0.1, 
                    density:0, lineColor:0xFF0000, lineAlpha:0, fillAlpha:0.5, categoryBits: 0 } );                
            }
            
            sim.gravity.y = 6;

            sim.start();
            sim.mouseDrag();

            addEventListener (Event.ENTER_FRAME, ReDraw);
            
            driver = new SiONDriver();
            var preset:SiONPresetVoice = new SiONPresetVoice();
            voice = preset["valsound.guitar1"];
            driver.play();
        }
        private function ReDraw(e:Event=null):void
        {
            if (circleCoords.length == 4) circleCoords.shift ();
            while (circleCoords.length != 4) circleCoords.push (new Point (circleObject.x*30, circleObject.y*30));
            var m:Matrix = new Matrix, n:Number = 40 / radius;
            for (var i:int = 1; i < n + 1; i++) {
                var p:Point = spline (circleCoords [0], circleCoords [1], circleCoords [2], circleCoords [3], i / n);
                m.tx = p.x; m.ty = p.y;
                bd.draw (circle, m);
            }
            bd.colorTransform (bd.rect, ct);
            
            circPy = circCy;
            circCy = circleObject.y * 30;
            circBPy = circBCy;
            circBCy = circleB.y * 30;
            for (i = 0; i < strys.length;  i++) {
                if (doPluck(circBPy, circBCy, strys[i] * 30)) {
                    driver.noteOn(48 + strns[i], voice, 4);
                }
                if (doPluck(circPy, circCy, strys[i] * 30)) {
                    driver.noteOn(60 + strns[i], voice, 4);
                }
            }
        }
        /* 
        * Calculates 2D cubic Catmull-Rom spline.
        * @see http://www.mvps.org/directx/articles/catmull/ 
        */ 
        private function spline (p0:Point, p1:Point, p2:Point, p3:Point, t:Number):Point {
            return new Point (
                0.5 * ((          2*p1.x) +
                    t * (( -p0.x           +p2.x) +
                    t * ((2*p0.x -5*p1.x +4*p2.x -p3.x) +
                    t * (  -p0.x +3*p1.x -3*p2.x +p3.x)))),
                0.5 * ((          2*p1.y) +
                    t * (( -p0.y           +p2.y) +
                    t * ((2*p0.y -5*p1.y +4*p2.y -p3.y) +
                    t * (  -p0.y +3*p1.y -3*p2.y +p3.y))))
            );
        }
        
        private function doPluck(py:Number, cy:Number, sy:Number):Boolean {
            return (py > sy && sy > cy) || (py < sy && sy < cy);
        }
    }
}