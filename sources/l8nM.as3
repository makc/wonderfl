package
{
    import flash.display.*;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.Point;
    import Box2D.Common.Math.b2Vec2;
    import com.actionsnippet.qbox.*;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.ITween;
    
    [SWF(width = "465", height = "465", backgroundColor = "0xFFFFFF", frameRate = "30")]
    
    public class Main extends MovieClip
    {
        private var _sim:QuickBox2D;
        private var _sion:SionNote = new SionNote();
        
        public function Main()
        {
            setup();
        }
        
        private function setup():void
        {
            _sim = new QuickBox2D(this, {debug:false});
            _sim.gravity = new b2Vec2(0, 0);
            _sim.setDefault({restitution:1, density:0, fillColor:0xFFFFFF, lineColor:0xFFFFFF});
            _sim.addBox({x:0, y:0, width:60, height:.1});
            _sim.addBox({x:0, y:15.5, width:60, height:.1});
            _sim.addBox({x:0, y:0, width:.1, height:60});
            _sim.addBox({x:15.5, y:0, width:.1, height:60});
            _sim.start();
            _sim.mouseDrag();
            //
            addSoundB2DObj(new Point(7, 7), 4);
            addB2DObj(new Point(4, 6), 2.2, 0xFF0000);
            addB2DObj(new Point(6, 5), 2, 0x55CCFF);
            addB2DObj(new Point(3, 3), 1.8, 0xFFCC66);
            addB2DObj(new Point(10, 3), 1.5, 0x33FF00);
            addB2DObj(new Point(4, 3), 1.6, 0x663399);
            addB2DObj(new Point(11, 7), 2.5, 0xCC9966);
            addB2DObj(new Point(13, 6), 1.2, 0x889933);
        }

        
        private function addSoundB2DObj(initPos:Point, radius:Number):void
        {
            var circles:Array = [];
            var len:int = 7;
            for(var i:int = 0; i<len; i++){
                var circle:QuickObject;
                var r:Number = 360 / len * i;
                var radian:Number = r * Math.PI / 180;
                var px:Number = initPos.x + radius * Math.cos(radian);
                var py:Number = initPos.y + radius * Math.sin(radian);
                var rad:Number = radius * .1;
                
                _sim.setDefault({lineAlpha:1, fillAlpha:1, restitution:2});
                circle = _sim.addCircle({x:px, y:py, friction:10, lineColor:0x000000, fillColor:0xFF0000, radius:rad, density:0});
                circle.userData.alpha = .5;
                circle.userData.filters = [new BlurFilter(8, 8)];
                circles.push(circle);
            }
            //
            var con:QuickContacts = _sim.addContactListener();
            con.addEventListener(QuickContacts.ADD, onHit);
            function onHit(e:Event):void {
            var l:int = circles.length;
                for (var j:int = 0; j <l; j++) {
                    var ball:QuickObject = circles[j];
                    if (con.inCurrentContact(ball)) {
                        _sion.noteOn(j, j);
                        ball.userData
                        var itween:ITween = circle.params.itween;
                                itween = circle.params.itween = BetweenAS3.serial(
                                BetweenAS3.to(ball.userData, {scaleX: 3, scaleY: 3, alpha:1}, .3, Bounce.easeOut),
                                BetweenAS3.to(ball.userData, {scaleX: 1, scaleY: 1, alpha:.5}, .5, Bounce.easeOut)
                             );
                        itween.play();
                    }
                }
            }
        }
        
        
        private function addB2DObj(initPos:Point, radius:Number, col:int):void
        {
            var circles:Array = [];
            var len:int = 3;
            for(var i:int = 0; i<len; i++){
                var circle:QuickObject;
                var r:Number = 360 / len * i;
                var radian:Number = r * Math.PI / 180;
                var px:Number = initPos.x + radius * Math.cos(radian);
                var py:Number = initPos.y + radius * Math.sin(radian);
                var rad:Number = radius * .2;
                
                _sim.setDefault({lineAlpha:0, fillAlpha:.8, restitution:1});
                circle = _sim.addCircle({x:px, y:py, friction:10, fillColor:col, radius:rad, density:rad * 10});
                circles.push(circle);
                
                _sim.setDefault({frequencyHz:5, dampingRatio:0, lineColor:0x666666, lineAlpha:.5});
                
                if(circles.length > 1 && circles.length < len){
                    _sim.addJoint({a:circle.body, b:circles[i-1].body, x1:circle.x, y1:circle.y, x2:circles[i-1].x, y2:circles[i-1].y});
                }else if(circles.length == len){
                    _sim.addJoint({a:circle.body, b:circles[i-1].body, x1:circle.x, y1:circle.y, x2:circles[i-1].x, y2:circles[i-1].y});
                    _sim.addJoint({a:circle.body, b:circles[0].body,  x1:circle.x, y1:circle.y, x2:circles[0].x, y2:circles[0].y});
                }
            }
        }
    }
}


import org.si.sion.*;
import org.si.sion.utils.SiONPresetVoice;

internal class SionNote
{
    private var driver:SiONDriver = new SiONDriver();
    private var presetVoice:SiONPresetVoice = new SiONPresetVoice();
    private var n1:SiONVoice;
    private var n2:SiONVoice;
    private var n3:SiONVoice;
    private var n4:SiONVoice;
    private var n5:SiONVoice;
    private var n6:SiONVoice;
    private var n7:SiONVoice;
    
    public function SionNote()
    {
        n1 = presetVoice["valsound.percus1"];
        n2 = presetVoice["valsound.percus2"];
        n3 = presetVoice["valsound.percus3"];
        n4 = presetVoice["valsound.percus4"];
        n5 = presetVoice["valsound.percus5"];
        n6 = presetVoice["valsound.percus6"];
        n7 = presetVoice["valsound.percus7"];
        driver.play();
    }
    
    public function noteOn(n:int, p:int):void{
        driver.noteOff(-1,0);
        var pitch:int = 48 - p;
        switch(n){
            case 0:
                driver.noteOn(pitch - 12, n1, 0, 0, 0, 0);
                break;
            case 1:
                driver.noteOn(pitch - 12, n2, 0, 0, 0, 0);
                break;
            case 2:
                driver.noteOn(pitch, n3, 0, 0, 0, 0);
                break;
            case 3:
                driver.noteOn(pitch, n4, 0, 0, 0, 0);
                break;
            case 4:
                driver.noteOn(pitch, n5, 0, 0, 0, 0);
                break;
            case 5:
                driver.noteOn(pitch, n6, 0, 0, 0, 0);
                break;
            case 6:
                driver.noteOn(pitch, n7, 0, 0, 0, 0);
                break;
            default:
                break;
        }
    }
}
