/**
 * Life Clock
 * 
 * 受精は「人間の動作」で最も神秘的な瞬間だと考えています。
 * 世界中で絶え間なく繰り返される生命誕生のタイムラインを時計で説きます。
 * "Life Clock"でご自身のリビドー(生命のエネルギー)を感じて下さい。
 * 
 * 誤解されそうですが、これは真面目に作ってます。その点ご理解いただけると嬉しいです。
 * ソースがスパゲッティなのは仕様です。私の仕様です。・・・ご、ごめんなさい。
 *
 *
 * 更新：Timerが(FP10.1の)バックグラウンド動作に支障があったので取り除きました。→そんなに変わんなかった。
 * 
 */


package {
    
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.media.Sound;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    
    [SWF(width="465", height="465", frameRate="60")]    
    
    public class LifeClock extends Sprite 
    {
        
        private const soundURL1:String = "http://asou.jp/wonderfl/lifeclock/clock1.mp3";
        private const soundURL2:String = "http://asou.jp/wonderfl/lifeclock/clock2.mp3";
        private var minShape:Shape;
        private var hourShape:Shape;
        private var secShape:Shape;
        private var se1:Sound;
        private var se2:Sound;
        private var ovum:OvumObject;
        private var timerCounter:int = 0;
        private const TIMER_RATE:int = 5;
        
        public function LifeClock()
        {
            //stage.addChild( new Stats() );
            se1 = new Sound();
            se1.addEventListener( Event.COMPLETE , loadSoundComplete1 );
            se1.addEventListener( IOErrorEvent.IO_ERROR , loadSoundIOError );
            se1.load( new URLRequest( soundURL1 ) );    
        }
        
        private function loadSoundComplete1(e:Event):void
        {
            se2 = new Sound();
            se2.addEventListener( Event.COMPLETE , loadSoundComplete2 );
            se2.addEventListener( IOErrorEvent.IO_ERROR , loadSoundIOError );
            se2.load( new URLRequest( soundURL2 ) );
        }
        
        private function loadSoundComplete2(e:Event):void
        {
            init();
        }
        
        private function loadSoundIOError(e:IOErrorEvent):void
        {
            var errorText:TextField = new TextField();
            errorText.autoSize = TextFieldAutoSize.CENTER;
            errorText.text = "サウンドファイルが読み込めませんでした。\n多分サーバー代を払ってないのでしょう、じきに復旧します。";
            stage.addChild( errorText  );
            errorText.x = (stage.stageWidth >> 1) - (errorText.width >> 1);
            errorText.y = (stage.stageHeight >> 1) - (errorText.height >> 1);
        }
        
        private function init():void
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.addEventListener( Event.RESIZE , resizeF );
            Controller.ovumRadius = Controller.ovumRadiusMin;
            ovum = addChild( new OvumObject(se1, se2) ) as OvumObject;
            ovum.x = stage.stageWidth >> 1;
            ovum.y = stage.stageHeight >> 1;
            hourShape = ovum.addChild(new Shape()) as Shape;
            minShape = ovum.addChild(new Shape()) as Shape;
            secShape = ovum.addChild(new Shape()) as Shape;
            addEventListener( Event.ENTER_FRAME , update );
            var time:Date = new Date();
            Controller.sec = time.getSeconds();
            resizeF(null);
        }
        
        private function update( e:Event ):void
        {
            if(timerCounter==TIMER_RATE){
                onTimer();
                timerCounter = 0;
            }else{
                timerCounter++;
            }
        }
        
        
        private function drawHand():void
        {
            var secLength:Number = Controller.ovumRadius * 0.236;
            var minLength:Number = secLength * 0.618;
            var hourLength:Number = minLength * 0.618;
            hourShape.graphics.clear();
            hourShape.graphics.beginFill(0xFFFFFF);
            hourShape.graphics.drawRect( -.5 , -Controller.ovumRadius+1 , 1 , hourLength );
            hourShape.graphics.endFill();
            minShape.graphics.clear();
            minShape.graphics.beginFill(0xFFFFFF);
            minShape.graphics.drawRect( -.5 , -Controller.ovumRadius+1 , 1 , minLength );
            minShape.graphics.endFill();
            secShape.graphics.clear();
            secShape.graphics.beginFill(0xFFFFFF);
            secShape.graphics.drawRect( -.5 , -Controller.ovumRadius+1 , 1 , secLength );
            secShape.graphics.endFill();
        }
        
        private function onTimer():void
        {
            var time:Date = new Date();
            var sec:Number = time.getSeconds();
            if (Controller.sec == sec) return;
            Controller.hor = time.getHours();
            Controller.min = time.getMinutes();
            Controller.sec = time.getSeconds();
            hourShape.rotation = (Controller.hor % 12) * 30 + Controller.min / 2;
            minShape.rotation = Controller.min * 6;
            secShape.rotation = Controller.sec * 6;    
            if ( Controller.sec == 0 ) {
                var num:int = Controller.hor;
                if (num == 0) num = 24;
                while (num--) {
                    ovum.spermArray.push( new SpermObject() );
                    ovum.addChild( ovum.spermArray[ovum.spermArray.length - 1] );
                    Controller.soundNumber = 1;
                }
            }else {
                ovum.spermArray.push( new SpermObject() );
                ovum.addChild( ovum.spermArray[ovum.spermArray.length - 1] );
                Controller.soundNumber = 0;
            }
        }
        
        private function resizeF(e:Event):void
        {
            Controller.ovumRadius = stage.stageWidth < stage.stageHeight ? stage.stageWidth * 0.1909 : stage.stageHeight * 0.1909;            
            if(ovum.spermArray.length){
                for (var i:int = ovum.spermArray.length-1; i >= 0 ; i-- )
                {
                    ovum.removeChild(ovum.spermArray[i])
                    ovum.spermArray.splice(i, 1);
                }
            }            
            ovum.createPointArray();
            drawHand();
        }
    }
}

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.*;
import flash.geom.Point;
import flash.media.Sound;
import flash.utils.getTimer;

class Controller
{
    public static const ovumRadiusMax:Number = 115;
    public static const ovumRadiusMin:Number = 90;
    public static function get ovumRadius():Number
    {
        return _ovumRadius;
    }
    public static function set ovumRadius(value:Number):void
    {
        if (value > ovumRadiusMax ) value = ovumRadiusMax;
        if (value < ovumRadiusMin ) value = ovumRadiusMin;
        _ovumRadius = value; 
        scale = value / ovumRadiusMax;
    };
    public static const ovumPointLength:int = 60;
    public static const spermTailLength:int = 9;
    public static const spermVelocity:int = 12;
    public static var scale:Number = 1;
    public static var fertilization:Number = 0;
    public static var hor:Number;
    public static var min:Number;
    public static var sec:Number;
    public static var soundNumber:int = 0;
    public static var seWait:Number = 50;    
    private static var _ovumRadius:Number;
}

class OvumObject extends Sprite
{
    public var spermArray:Vector.<SpermObject>;
    private var xv:Number;
    private var yv:Number;
    private var ctrs:Vector.<OvumPoint>;
    private var g:Graphics;
    private var se1:Sound;
    private var se2:Sound;
    private var seWaiter:int;
    private var spermLength:int;
    
    public function OvumObject(_se1:Sound,_se2:Sound)
    {
        se1 = _se1;
        se2 = _se2;
        init();
    }
    
    private function init():void
    {    
        seWaiter = 0;
        xv = 0;
        yv = 0;
        spermArray = new Vector.<SpermObject>();
        g = graphics;
        createPointArray();
        addEventListener( Event.ENTER_FRAME , update );
    }
    
    public function createPointArray():void
    {
        ctrs = new Vector.<OvumPoint>();
        var rot:Number = 360 / Controller.ovumPointLength;
        var rotate:Number = 0;
        for ( var i:int = 0; i < Controller.ovumPointLength; i++)
        {
            ctrs.push(new OvumPoint( Math.cos(rotate * Math.PI / 180) * Controller.ovumRadius , Math.sin(rotate * Math.PI / 180) * Controller.ovumRadius , Controller.ovumRadius , rotate ));
            rotate += rot;
        }
    }
    
    public function update(e:Event):void
    {
        spermLength = spermArray.length;
        x += ( (stage.stageWidth >> 1) - x ) * .05;
        y += ( (stage.stageHeight >> 1) - y ) * .05;
        x += xv;    y += yv;
        xv *= 0.8;    yv *= 0.8;    
        draw();
    }
    
    private function draw():void
    {
        drawOvum();
        drawSperm();
    }
    
    private function drawOvum():void
    {
        g.clear();
        g.beginFill(0);
        g.moveTo( (ctrs[Controller.ovumPointLength - 1].x + ctrs[0].x) * .5 , (ctrs[Controller.ovumPointLength - 1].y + ctrs[0].y) * .5 );
        for (var i:int = 0; i < Controller.ovumPointLength ; i++)
        {
            if (i == Controller.ovumPointLength-1 )
            {
                g.curveTo( ctrs[Controller.ovumPointLength - 1].x , ctrs[Controller.ovumPointLength - 1].y , (ctrs[Controller.ovumPointLength - 1].x + ctrs[0].x) * .5 , (ctrs[Controller.ovumPointLength - 1].y + ctrs[0].y) * .5 );
                
            }else{
                g.curveTo( ctrs[i].x , ctrs[i].y , (ctrs[i].x+ctrs[i+1].x)*.5 , (ctrs[i].y + ctrs[i+1].y)*.5 );
            }
            ctrs[i].x += ( ctrs[i].defaultX - ctrs[i].x ) * 0.15;
            ctrs[i].y += ( ctrs[i].defaultY - ctrs[i].y ) * 0.15;
            ctrs[i].update();
        }
        g.endFill();
    }
    
    private function drawSperm():void
    {
        var j:int;
        var p:Point;
        var num:Number;
        for (var i:int = spermArray.length-1; i >= 0 ; i-- )
        {
            spermArray[i].run();
            for ( j = 0; j < Controller.ovumPointLength; j++)
            {
                p = ctrs[j].getRadius( ctrs[j].radius-10 );
                num = Math.sqrt( Math.pow( p.x - spermArray[i].x , 2 ) + Math.pow( p.y - spermArray[i].y , 2 ) );                
                if ( 20*Controller.scale > num ) {
                    ctrs[j].radius -= (20*Controller.scale - num)*.1;
                }
            }
            switch(spermArray[i].step)
            {
                case 0:
                {
                    spermArray[i].rotation = Math.atan2(spermArray[i].yv , spermArray[i].xv) * 180 / Math.PI;
                    spermArray[i].radius -= spermArray[i].v;
                    if ( spermArray[i].radius < Controller.ovumRadius )
                    {
                        xv += -spermArray[i].xv * 0.6;
                        yv += -spermArray[i].yv * 0.6;
                        spermArray[i].step++;
                        if (seWaiter == 0) {
                            if (Controller.soundNumber) {
                                se2.play();
                            }else {
                                se1.play();
                            }
                        }
                        seWaiter = Controller.seWait;
                    }
                    break;
                }
                case 1:
                {
                    spermArray[i].rotation = Math.atan2(spermArray[i].y , spermArray[i].x) * 180 / Math.PI;
                    spermArray[i].wait++;
                    if ( spermArray[i].wait > spermArray[i].waitRate )
                    {
                        var r:Number = Math.atan2( spermArray[i].y , spermArray[i].x ) * 180 / Math.PI;
                        xv += -Math.cos( r * Math.PI / 180)*2;
                        yv += -Math.sin( r * Math.PI / 180)*2;
                        spermArray[i].step++;
                    }
                    break;
                }
                case 2:
                {
                    spermArray[i].rotation = Math.atan2(spermArray[i].y , spermArray[i].x) * 180 / Math.PI;
                    spermArray[i].radius -= spermArray[i].v * 0.3;
                    for ( j = 0; j < Controller.ovumPointLength; j++)
                    {
                        p = ctrs[j].getRadius( ctrs[j].radius-10 );
                        num = Math.sqrt( Math.pow( p.x - spermArray[i].x , 2 ) + Math.pow( p.y - spermArray[i].y , 2 ) );                
                        if ( 20*Controller.scale > num ) {
                            ctrs[j].radius += (20*Controller.scale - num)*0.3;
                        }
                    }
                    if ( spermArray[i].radius < Controller.ovumRadius * 0.6 ) {
                        removeChild(spermArray[i])
                        spermArray.splice(i, 1);
                        Controller.fertilization++;
                    }
                    break;
                }
            }
        }            
        if(seWaiter) seWaiter--;    
    }
}

class OvumPoint
{
    private var _defaultX:Number = 0;
    private var _defaultY:Number = 0;
    public var _defaultRadius:Number = 0;
    public var x:Number;
    public var y:Number;
    public var radius:Number;
    public var rotation:Number;
    public function get defaultX():Number { return _defaultX };
    public function get defaultY():Number { return _defaultY };
    public function get defaultRadius():Number { return _defaultRadius };
    
    public function OvumPoint(_x:Number,_y:Number,_radius:Number,_rotation:Number)
    {
        _defaultX = x = _x;
        _defaultY = y = _y;
        _defaultRadius = radius = _radius;
        rotation = _rotation;
    }
    
    public function update():void
    {
        radius += ( _defaultRadius - radius ) * 0.15;
        var p:Point = getRadius(radius);
        x = p.x;
        y = p.y;
    }
    
    public function getRadius(_radius:Number):Point
    {
        var _x:Number = Math.cos( ( rotation * Math.PI / 180 ) ) * _radius;
        var _y:Number = Math.sin( ( rotation * Math.PI / 180 ) ) * _radius;
        return new Point(_x,_y);
    }    
}

class SpermObject extends Sprite
{
    public var xv:Number;
    public var yv:Number;
    public var v:Number;
    public var waitRate:int;
    public var radius:Number;
    public var step:int;
    public var wait:int;
    
    private var dots:Array;
    private var _x:Number;
    private var _y:Number;
    private var swingv:Number;
    private var swing:Number;
    private var wrap:Number;
    private var tailsThic:Vector.<int> = Vector.<int>([3,2,1,1,1,1,1,1,1]);
    private var timeRand:Number;
    
    public function SpermObject()
    {
        init();        
    }
    
    private function init():void
    {
        scaleX = scaleY = Controller.scale;
        v = Controller.spermVelocity * Controller.scale;
        timeRand = Math.random()*10000;
        waitRate = 30 + Math.random() * 180;
        step = 0;
        xv = yv;
        wrap = Math.random() * 360;
        swing = (Math.random() * 10 - 5) * Controller.scale;
        swingv = 0;
        radius = Controller.ovumRadius * 6;
        x = (Math.cos( swing * Math.PI / 180)) * radius;
        y = (Math.sin( swing * Math.PI / 180)) * radius;    
        createTailArray();
    }
    
    private function createTailArray():void
    {
        dots = [];
        var space:int = 10;
        for (var i:int = 0; i < Controller.spermTailLength; i++) {
            dots.push(new SpermPoint(space,0));
            space+=4;
        }                
    }
    
    public function run():void
    {
        _x = x;
        _y = y;
        if (step == 0){
            swingv += -3*Math.sin(swing*Math.PI/180);
            swing += swingv;
        }else if (step == 1){
            swing += swingv*.3;
        }
        x = (Math.cos( (swing+wrap) * Math.PI / 180)) * radius;
        y = (Math.sin( (swing+wrap) * Math.PI / 180)) * radius;
        xv = _x - x;
        yv = _y - y;        
        for (var i:int = 0 ; i < Controller.spermTailLength ; i++ )
        dots[i].y = Math.cos( i - getTimer() * .05 + timeRand ) * ( 5 * ( i / Controller.spermTailLength ) );
        draw();
    }
    
    private function draw():void
    {
        graphics.clear();
        graphics.beginFill( 0 );
        graphics.drawEllipse( -6 , -4 , 12 , 8 );
        graphics.endFill();
        for (var i:int = 0; i < Controller.spermTailLength; i++) {
            graphics.lineStyle(tailsThic[i], 0);
            graphics.lineTo( dots[i].x , dots[i].y );
        }
    }
}    

class SpermPoint
{
    
    public var x:Number;
    public var y:Number;
    public var _x:Number;
    public var _y:Number;
    
    public function SpermPoint(__x:Number,__y:Number) 
    {
        x = _x = __x;
        y = _y = __y;
    }    
}
