package {import flash.display.Sprite;import flash.events.Event;[SWF(backgroundColor=0x84B7EE, width=465, height=456, frameRate=30)]public class FakeStage extends Sprite {
    public var bgColor:uint = 0x333333;            
public function FakeStage() {stage ? init() : addEventListener(Event.ADDED_TO_STAGE,init);} private function init(e:Event = null):void {removeEventListener(Event.ADDED_TO_STAGE,init);fillBg();addChild(new Main());stage.addEventListener(Event.RESIZE,fillBg);}private function fillBg(e:Event=null):void{graphics.clear();graphics.beginFill(bgColor);graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);graphics.endFill();}}}
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.display.*;
import flash.events.Event;
import flash.utils.getTimer;
import net.hires.debug.Stats;
import flash.utils.getTimer;
import com.bit101.components.Label;
import com.bit101.components.Style;

var _wheelRotationSpeedOnKeyDown:Number = 9;

var _ballMovementSpeedMax:Number = 6;
var _ballMovementSpeedMin:Number = 2;
var _ballMovementSpeedLevelMultiplier:Number = .4;

var _ballSpawnFrequencyMin:Number = 0;
var _ballSpawnFrequencyMax:Number = 0;


//25 seounds for each level.
var _levelDurationInSecounds:uint = 25;
    
// score += _score * level
var _scoreLostBall:uint = 2;
var _scoreBall:uint = 5;    
    
    
//new abs function, about 25x faster than Math.abs
function abs(value:Number):Number
    {
        return value < 0 ? -value : value;
    }
//new ceil function about 75% faster than Math.ceil.
function ceil(value:Number):Number
    {
        return (value % 1) ? int(value) + 1 : value;
    }
//Quick random boolean.
function rndBool():Boolean
    {
        return Math.random() > .5;
    }
//Get the number sign (fast) !dont use zero's on this function
function sign(value:Number):int
{
    return value < 0 ? -1 : 1;
}
//Function source : http://icodesnip.com/snippet/actionscript-3/as3-drawing-shapes-arc-burst-dashed-line-gear-polygon-star-wedge-line
function drawArc(target:Graphics, radius:Number, arc:Number, startAngle:Number=0, yRadius:Number=0):void
{
    if (startAngle == 0)startAngle = 0;    if (yRadius == 0)yRadius = radius;    if (abs(arc) > 360)arc = 360;
    var segAngle:Number, theta:Number, angle:Number, angleMid:Number, segs:Number, ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number;
    segs = ceil(abs(arc) / 45);segAngle = arc / segs;theta = -(segAngle / 180) * Math.PI;angle = -(startAngle / 180) * Math.PI;       
    if (segs > 0)
    {
        target.lineTo(Math.cos(angle) * radius, Math.sin(angle) * yRadius);
        for (var i:int = 0; i < segs; ++i)
            {
                angle += theta;                                                  angleMid = angle - (theta / 2);
                bx = Math.cos(angle) * radius;                                   by = Math.sin(angle) * yRadius;
                cx = Math.cos(angleMid) * (radius / Math.cos(theta / 2));        cy = Math.sin(angleMid) * (yRadius / Math.cos(theta / 2));
                target.curveTo(cx, cy, bx, by);
            }
     }
}



/*
*    MAIN CONTAINES GAME - ACTS AS CONTROLER
*/
class Main extends Sprite
{  
    private var game:Game;

    private var keyL:Boolean;
    private var keyR:Boolean;

    public function Main()
    {
        addEventListener(Event.ADDED_TO_STAGE,init);} private function init(e:Event):void {removeEventListener(Event.ADDED_TO_STAGE,init);        

        inittrace(stage);   
        var stats:Stats = new Stats();     
        addChild(stats);
        stats.x = stage.stageWidth - stats.width;
        stats.y = stage.stageHeight - stats.height;        
                
        stage.frameRate = 60;
                
        game = new Game();
        addChild(game);
        
        stage.addEventListener(KeyboardEvent.KEY_DOWN,onKD);
        stage.addEventListener(KeyboardEvent.KEY_UP,onKU);
        
        addEventListener(Event.ENTER_FRAME,loop);
    }
    private function onKU(e:KeyboardEvent):void
    {
        keyR = (!(e.keyCode == 39 || e.keyCode == 68) && keyR);
        keyL = (!(e.keyCode == 37 || e.keyCode == 65) && keyL);
    }
    private function onKD(e:KeyboardEvent):void
    {
        keyR = (e.keyCode == 39 || e.keyCode == 68);
        keyL = (e.keyCode == 37 || e.keyCode == 65);
    }
    
    private function loop(e:Event):void
    {
        if(keyL) game.rotate(-_wheelRotationSpeedOnKeyDown);
        if(keyR) game.rotate(_wheelRotationSpeedOnKeyDown);
    }
}



/*
_____/\\\\\\\\\\\\_____/\\\\\\\\\_____/\\\\____________/\\\\__/\\\\\\\\\\\\\\\_        
 ___/\\\//////////____/\\\\\\\\\\\\\__\/\\\\\\________/\\\\\\_\/\\\///////////__       
  __/\\\______________/\\\/////////\\\_\/\\\//\\\____/\\\//\\\_\/\\\_____________      
   _\/\\\____/\\\\\\\_\/\\\_______\/\\\_\/\\\\///\\\/\\\/_\/\\\_\/\\\\\\\\\\\_____     
    _\/\\\___\/////\\\_\/\\\\\\\\\\\\\\\_\/\\\__\///\\\/___\/\\\_\/\\\///////______    
     _\/\\\_______\/\\\_\/\\\/////////\\\_\/\\\____\///_____\/\\\_\/\\\_____________   
      _\/\\\_______\/\\\_\/\\\_______\/\\\_\/\\\_____________\/\\\_\/\\\_____________  
       _\//\\\\\\\\\\\\/__\/\\\_______\/\\\_\/\\\_____________\/\\\_\/\\\\\\\\\\\\\\\_ 
        __\////////////____\///________\///__\///______________\///__\///////////////__
*/
class Game extends Sprite
{
    
    private var lvl:uint;
    
    private var w:Wheel;
    
    private var ui:ScoreDisplay;
    
    private var startTime:uint;
    private var balls:Vector.<ColorBall>;
    
    public function Game()
    {
        trace("Game nit 1.4 - Game not finished yet.."); 
            
        addEventListener(Event.ADDED_TO_STAGE,init);} private function init(e:Event):void {removeEventListener(Event.ADDED_TO_STAGE,init);        
        
        // temp ... testing wonder fl score system...
        __main = this;
        //__scores.showHighScore();
        
        //Init socre and time display.
        ui = new ScoreDisplay(stage.stageWidth);
        addChild(ui);
        
        //Init balls Vector and timer.
        balls = new Vector.<ColorBall>();        
        startTime = getTimer();        
        
        //Init wheel.
        w = new Wheel();        
        w.x = stage.stageWidth / 2;
        w.y = stage.stageHeight / 2;
        addChild(w);
        
        //Init level.
        lvl = 0;
        updateLevel();
        
        addEventListener(Event.ENTER_FRAME,frame);
        
        
        
    }

    private var t:Number;
    private var sec:Number;
    
    private var spwnTime:Number;
    private var spwnFreq:Number;
    private var spwnAmount:Number;
    private var spwnCount:int;
    
    private function frame(e:Event):void
    {
        t = time;
        ui.time = t;
        t++;
        
        sec = int(1000 * (t - int(t))) / 1000; // Value Ranged [0,1] with fixed point 0.000        
        
        //trace("t",t.toFixed(2),"spwnTime",spwnTime.toFixed(2),"freq",spwnFreq.toFixed(2));
        
        //Ball Spawn frequency.
        if(t - spwnTime > spwnFreq * spwnCount)
        {
            spwnCount++;
            newBall();
        }       
        
        applyCollision();
        
        //25 sec for each level
        if(t > lvl * _levelDurationInSecounds)
            updateLevel();
            
        w.draw();
    }
    
    private function applyCollision():void
    {
        var b:ColorBall;
        var target:int;
        var correct:Boolean;
        
        for (var i:int = 0;i < balls.length; i++)
        {
            b = balls[i]; 
            if(Point.distance(w.pos,b.pos) <= w.radius + b.radius)      
            {
                target = w.target(b.pos);
                correct = target == b.index;
                
                if( !correct )
                {                    
                    w.value[target] -= .07;
                    
                    //Game over
                    if(w.value[target] <= 0)
                    {
                        removeEventListener(Event.ENTER_FRAME,frame);
                                        
                        while(balls.length > 0)
                            balls.pop().remove();
                            
                        trace("Game OVER");
                    }    
                    
                    
                    w.draw();
                    ui.score -= Math.max(_scoreLostBall * lvl,0);
                } else {
                    ui.score += _scoreBall * lvl;
                }

                
                b.remove(correct);
                balls.splice(i,1);
                i--;
            }
        }
    }


    private function updateLevel():void
    {
        lvl++;
        ui.level = lvl;
        
        
        t = time + 1;
        
        trace("Level up:" + lvl.toString());
        
        spwnCount = 0;
        spwnTime = t;
        spwnFreq = 1 / Math.max(.5,lvl / 4);
        spwnAmount = Math.max(1, lvl / 3);
    
        //trace("Freq",spwnFreq);

        w.setColors(getColor());
        
        while(balls.length > 0)
            balls.pop().remove();
    }


    public function rotate(x:Number):void
    {
        if(! this.hasEventListener(Event.ENTER_FRAME)) return;
        
        w.rotation += x;
    }

    //Return time elapsed in secounds.
    public function get time():Number
    {
        return (getTimer() - startTime) / 1000;
    }
    
    
    public function newBall():void
    {
        var rndIndex:uint = Math.floor(Math.random() * w.color.length);
        var rndColor:uint = w.color[rndIndex];
        var rndRadius:Number = 10;
        var rndSpeed:Number = Math.min(Math.max(lvl / 2,_ballMovementSpeedMin),_ballMovementSpeedMax);
        
        
        var b:ColorBall = new ColorBall(rndColor,rndRadius);
        b.speed = rndSpeed;
        b.index = rndIndex;
                    
        var p1:Point;
        
        if(rndBool()) p1 = new Point(Math.random() * stage.stageWidth, 
        rndBool() ? -b.height : stage.stageHeight + b.height);
        else p1 = new Point(rndBool() ? -b.width : stage.stageWidth
         + b.width,Math.random() * stage.stageHeight);
        
        b.move(p1,new Point(w.x,w.y));
        
        addChild(b);
        balls.push(b);
    }
    private function getColor():Array
    {
        if(lvl < 3)
            return [0xFFFF00,0xFF0000,0x00FFFF];
        if(lvl < 5)
            return [0xFFFF00,0xFF0000,0x00FFFF,0x00FF00];
            
        return [0xFFFF00,0xFF0000,0x00FFFF,0x00FF00,0xFF00FF]

    }
}


/*

 U S E R   I N T E R F A C E 
 
*/

class ScoreDisplay extends Sprite
{
    private var scoreValue:int;
    
    private var lblScore:Label;
    private var lblTime:Label;
    private var lblLevel:Label;
    
    public function ScoreDisplay(width:Number)
    {
        Style.fontSize = 16;
        Style.LABEL_TEXT = 0xFFFFFF;
        
        lblScore = new Label(this,5,5,"Score");
        lblTime = new Label(this,width / 3,5,"Time");
        lblLevel = new Label(this,2 * width / 3,5,"Level");
        
        time = 0;
        score = 0;
        level = 0;
    }
    
    //Set time in secounds.
    public function set time(value:Number):void
    {
        lblTime.text = "Time: " + value.toFixed(2) + " s";
    }
    
    public function get score():int
    {
        return scoreValue;
    }
    public function set score(value:int):void
    {
        scoreValue = value;
        lblScore.text = "Score: " + value.toString();    
    }
    public function set level(value:uint):void
    {
        lblLevel.text = "Level: " + value.toString();    
    }
}



/*
   ___              __  __        ______           __ 
  / _ \ ___   ___  / / / /___    /_  __/___ __ __ / /_
 / ___// _ \ / _ \/ /_/ // _ \    / /  / -_)\ \ // __/
/_/    \___// .__/\____// .__/   /_/   \__//_\_\ \__/ 
           /_/         /_/                            
*/

//Pop up text
class PUTxt extends Label
{
    public function PUTxt(stage:Stage,text:String)
    {
        super();
        scaleX = scaleY = 3;
        this.text = text;
        stage.addChild(this);
        x = stage.stageWidth / 2 - width / 2;
        y = stage.stageHeight / 2 - height / 2;
        
        this.addEventListener(Event.ENTER_FRAME,hideMe);
    }
    
    private function hideMe(e:Event):void
    {
        
    }
}







/*        ** COLOR WHEEL ** 
         , - ~ ~ ~ - ,
     , '  \            ' ,
   ,       \              ,
  ,         \               ,
 ,           \               ,
 ,            \______________,
 ,            /              ,
  ,          /              ,
   ,        /             ,
     ,     /          , '
       ' - , _ _ _ ,  '
*/
class Wheel extends Sprite
{
    private var g:Graphics;
    public var gap:Number;
    public var radius:Number;

    public var value:Vector.<Number> = null;
    public var color:Vector.<int> = null;
    
    public function Wheel(...colors)
    {
        setColors(colors);
        radius = 80;
        gap = radius * .25;
        g = this.graphics
    }   
    public function setColors(colors:Array):void
    {
        if(value == null) 
            value = new Vector.<Number>();
        else if(colors.length == value.length + 1)
            value.push(1);
        else if(colors.length > value.length) {
            value = new Vector.<Number>();
            while(value.length < colors.length)
                value.push(1);
        }
        color = new Vector.<int>(colors.length,true);
        for(var i:int = colors.length - 1; i >= 0; i--)
            color[i] = colors[i];
    }
    
    public function get count():int
    {
        return color.length;
    }
    public function draw():void
    {
        var r:Number = 360 / count;

        g.clear();     

        for(var i:int = 0; i < color.length; ++i)
        {
            value[i] = Math.max(0,value[i]);
            
            g.beginFill(color[i], .4);   
            arc(radius, r, -r * (i+1));
            g.beginFill(color[i], 1);
            arc(gap + (value[i] * (radius - gap)), r, -r * (i+1));
        }        
        
        g.beginFill(0xFFFFFF);
        g.drawCircle(0,0,gap);
        g.endFill();
    }
    
    ///arcIndex starts from 0
    public function containes(p:Point,arcIndex:int):Boolean
    {        
        var rot:Number = (Math.atan2(p.y - y,p.x - x) + Math.PI) * 360 / Math.PI / 2;        
        var aLength:Number = 360 / count;
        var aStart:Number = aLength * arcIndex;
        aStart = fix(aStart + rotation + 180);
        return ((rot > aStart) && (rot < aStart + aLength)) 
        || ((aStart + aLength > 360) && (rot < aStart + aLength - 360));
    }
     
    public function target(p:Point):int
    {
        var rot:Number = (Math.atan2(p.y - y,p.x - x) + Math.PI) * 360 / Math.PI / 2;        
        var aLength:Number = 360 / count;
        var aStart:Number;
        
        for(var r:Number = 0; r < count; r ++)
        {
            aStart = aLength * r;
            aStart = fix(aStart + rotation + 180);
            if( ((rot > aStart) && (rot < aStart + aLength)) 
            || ((aStart + aLength > 360) && (rot < aStart + aLength - 360)))
            return r;
        }
        return -1;
    }
   
    
    private function fix(value:Number):Number
    {
        return value < 0 ? value + 360 : (value > 360 ? value - 360 : value);
    }
    
    private function arc(rad:Number, arc:Number, start:Number):void
    {
        g.moveTo(0,0);
        drawArc(g, rad,arc,start);
        g.lineTo(0,0);
        g.endFill();
    }
    public function get pos():Point
    {
        return new Point(x,y);
    }
}






/*    ** SHOOTING COLOR BALL **
                                          
  ~(_]---'     ((((0
 /_(U      
 
*/


class ColorBall extends Sprite
{
    public var speed:Number = 1;
    public var radius:Number;
    public var index:uint = 0;
    
    public function ColorBall(color:uint,radius:uint)
    {
        this.radius = radius;
        draw(color);
    }
    
    private function draw(color:uint):void
    {
        graphics.clear();
        graphics.beginFill(color);
        graphics.drawCircle(0,0,radius);
    }

    
    public function moveOnFrame(e:Event):void
    {
        this.x += vec.x;
        this.y += vec.y;
    }
    private var vec:Point;
    
    public function move(from:Point,to:Point):void
    {
        this.x = from.x;
        this.y = from.y;
        
        vec = new Point(to.x - from.x,to.y - from.y);
        vec.normalize(speed);
        
        addEventListener(Event.ENTER_FRAME,moveOnFrame);
    }        
    
    private var correct:Boolean;
    
    public function remove(correct:Boolean = true):void
    {
        this.correct = correct;
        if(!correct) draw(0);
        
        removeEventListener(Event.ENTER_FRAME,moveOnFrame);
        addEventListener(Event.ENTER_FRAME,hideOnFrame);
    }
    
    private var hideSpeed:Number = .02;
    
    private function hideOnFrame(e:Event):void
    {
        alpha -= hideSpeed;
        
        if(!correct)
            scaleX = scaleY = scaleY + hideSpeed / 2;
        else 
            scaleX = scaleY = scaleY - hideSpeed / 2;
        
        if(alpha <= 0)
        {
            removeEventListener(Event.ENTER_FRAME,hideOnFrame);
            parent.removeChild(this);
        }

    }

    public function get pos():Point
    {
       return new Point(x,y);     
    }


}














var __main:Sprite;
var __score:int = 0;
var __scores:PlatformWonderfl = new PlatformWonderfl();

// WONDER FL SCORE SYSTEM.

import net.wonderfl.score.basic.BasicScoreForm;
import net.wonderfl.score.basic.BasicScoreRecordViewer;

class PlatformWonderfl {

    public var clickStr:String = "CLICK";
    public var isTouchDevice:Boolean = false;
    public var titleX:Number = 0.85;
    
    private const HIGHSCORE_COUNT:uint = 50;
    private var scoreRecordViewer:BasicScoreRecordViewer;
    private var scoreForm:BasicScoreForm;
    
    public function recordHighScore(score:int):void {
        scoreForm = new BasicScoreForm(__main, 5, 5, __score);
        scoreForm.onCloseClick = function():void {
            closeHighScore();
            showHighScore();
        }    
    }
    
    public function showHighScore():void {
        scoreRecordViewer =
            new BasicScoreRecordViewer(__main, 5, 220, "SCORE RANKING", HIGHSCORE_COUNT);
    }
    
    public function closeHighScore():void {
        if (scoreRecordViewer) {
            __main.removeChild(scoreRecordViewer);
            scoreRecordViewer = null;
        }
        if (scoreForm) {
            __main.removeChild(scoreForm);
            scoreForm = null;
        }
    }
}












/*
__/\\\\\\\\\\\\\\\____/\\\\\\\\\_________/\\\\\\\\\___________/\\\\\\\\\__/\\\\\\\\\\\\\\\_        
 _\///////\\\/////___/\\\///////\\\_____/\\\\\\\\\\\\\______/\\\////////__\/\\\///////////__       
  _______\/\\\_______\/\\\_____\/\\\____/\\\/////////\\\___/\\\/___________\/\\\_____________      
   _______\/\\\_______\/\\\\\\\\\\\/____\/\\\_______\/\\\__/\\\_____________\/\\\\\\\\\\\_____     
    _______\/\\\_______\/\\\//////\\\____\/\\\\\\\\\\\\\\\_\/\\\_____________\/\\\///////______    
     _______\/\\\_______\/\\\____\//\\\___\/\\\/////////\\\_\//\\\____________\/\\\_____________   
      _______\/\\\_______\/\\\_____\//\\\__\/\\\_______\/\\\__\///\\\__________\/\\\_____________  
       _______\/\\\_______\/\\\______\//\\\_\/\\\_______\/\\\____\////\\\\\\\\\_\/\\\\\\\\\\\\\\\_ 
        _______\///________\///________\///__\///________\///________\/////////__\///////////////__
*/
import flash.text.TextField;
import flash.text.TextFormat;

/////  WONDERFL TRACE /////
function inittrace(s:Stage):void
{
    WTrace.initTrace(s);
}
//global trace function
var trace:Function;
//wtreace class
class WTrace
{
        private static var FONT:String = "_sans";
        private static var SIZE:Number = 12;
        private static var TextFields:Array = [];
        private static var trace_stage:Stage;   
        public static function initTrace(stg:Stage):void
        {
            trace_stage = stg;
            trace = wtrace;
        }   
        private static function scrollup():void
        {
            // maximum number of lines: 4
            if (TextFields.length > 4) 
            {
                var removeme:TextField = TextFields.shift();
                trace_stage.removeChild(removeme);
                removeme = null;
            }
            for(var x:Number=0;x<TextFields.length;x++)
            {
                (TextFields[x] as TextField).y -= SIZE*1.2;
            }
        }    
        public static function wtrace(... args):void
        {
        
            var s:String="";
            var tracefield:TextField;            
            for (var i:int;i < args.length;i++)
            {
                // imitating flash:
                // putting a space between the parameters
                if (i != 0) s+=" ";
                s+=args[i].toString();
            }

            tracefield= new TextField();
            tracefield.autoSize = "left";
            tracefield.textColor = 0xFFFFFF;
            tracefield.text = s;
            tracefield.y = trace_stage.stageHeight - 20;
            var tf:TextFormat = new TextFormat(FONT, SIZE);
            tracefield.setTextFormat(tf);
            trace_stage.addChild(tracefield);
            scrollup();                      
            TextFields.push(tracefield);
        }
}