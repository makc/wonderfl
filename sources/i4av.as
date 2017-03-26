package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    [SWF(width ="465" , height ="465" , frameRate ="30")]
    public class Main extends Sprite 
    {
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            var view:View = new View();
            addChild(view);
            view.init();
        }
    }
}

import flash.display.MovieClip;
class View extends MovieClip 
{
    public function View() 
    {
        
    }
    public function init():void {
        var points:Points = new Points();
        addChild( points)
        points.init();
        var environment:Environment = new Environment();
        addChild( environment );
        environment.init();
    }
}


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
class Points extends MovieClip 
{
    private static var pointList:Vector.<Object>;
    private const WIDTH_Number:uint = 40;
    private const HEIGHT_Number:uint = 40;
    private const K:Number = 0.8;
    private const U:Number = 0.2;
    private var point_bmd:BitmapData;
    private var stage_bmd:BitmapData;
    private var stage_bm:Bitmap;
    private var clear_bmd:BitmapData;
    
    private var stageWidth:Number;
    private var stageHeight:Number;
    private var colorList:Vector.<BitmapData>;
    public function Points() 
    {
        
    }
    public function init():void {
        var g:Graphics;
        var i:uint;
        var n:uint = WIDTH_Number * HEIGHT_Number;
        stageWidth = stage.stageWidth;
        stageHeight = stage.stageHeight;
        pointList = new Vector.<Object>();
        
        var pointObject:Object;
        for ( i = 0 ; i < n ; i++) {
            pointObject = new Object();
            pointObject.vx = 0;
            pointObject.vy = 0;
            pointObject.start_x =
            pointObject.x = (i % WIDTH_Number) * stageWidth / WIDTH_Number;
            pointObject.start_y =
            pointObject.y =  Math.floor( i / WIDTH_Number ) * stageHeight / HEIGHT_Number;
            pointList.push(pointObject);
        }
        var _mc:MovieClip;
        _mc = new MovieClip();
        g = _mc.graphics;
        g.beginFill(0x6666FF);
        g.drawCircle(5, 5, 4 );
        point_bmd = new BitmapData(10, 10, true, 0xFFFFFF);
        point_bmd.draw( _mc );
        colorList = new Vector.<BitmapData>();
        var color_bmd:BitmapData;
        for ( i = 0; i <= 100 ; i++) {
            _mc = new MovieClip();
            g = _mc.graphics;
            g.beginFill(0x6666FF , 0.1 + (0.9/100) * i );
            g.drawCircle( 5, 5 , 4 );
            color_bmd = new BitmapData(10, 10, true, 0xFFFFFF);
            color_bmd.draw(_mc);
            colorList.push(color_bmd);
        }
        clear_bmd = new BitmapData( stageWidth , stageHeight , true, 0xFFFFFF);
        stage_bmd = clear_bmd.clone();
        stage_bm = new Bitmap(stage_bmd , "auto", true);
        addChild( stage_bm );
        addEventListener(Event.ENTER_FRAME, enterListener, false, 0, false);
        enterListener();
    }
    public static function get getList():Vector.<Object> {
        return pointList ;
    }
    private function enterListener( event:Event = null):void {
        //
        stage_bmd = clear_bmd.clone();
        stage_bmd.lock();
        var rect:Rectangle = new Rectangle(0,0,10,10);
        var pointClass:Point;
        var pointObject:Object;
        var i:uint;
        var n:uint = WIDTH_Number * HEIGHT_Number;
        var _ax:Number;
        var _ay:Number;
        var _x:Number;
        var _y:Number;
        for ( i = 0 ; i < n ; i++) {
            pointObject = pointList[i];
            _ax = K * (pointObject.start_x - pointObject.x);
            pointObject.vx += _ax - U * pointObject.vx;

            pointObject.x += pointObject.vx;
            _ay = K * (pointObject.start_y - pointObject.y);
            pointObject.vy += _ay - U * pointObject.vy;

            pointObject.y += pointObject.vy;
            pointClass = new Point( pointObject.x , pointObject.y);
            var v:Number = pointObject.vx * pointObject.vx + pointObject.vy * pointObject.vy;
            var distance:Number = (pointObject.x - pointObject.start_x) * (pointObject.x - pointObject.start_x) + (pointObject.y - pointObject.start_y) * (pointObject.y - pointObject.start_y);
            if ( Math.abs(v) < 0.005 && distance < 0.1 ) {
                pointObject.vy = 0;
                pointObject.vx = 0;
                pointObject.x = pointObject.start_x;
                pointObject.y = pointObject.start_y;
            }
            if (v > 100) {
                v = 100;
            }else if ( v < 0) {
                v = 0;
            }
            stage_bmd.copyPixels( colorList[Math.round(v)], rect, pointClass, null, null, true);
        }
        stage_bm.bitmapData = stage_bmd;
        stage_bmd.unlock();
        
    }
}


import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
class Environment extends MovieClip 
{
    private var start_count:uint;
    private var start_id:uint;
    private var mouse_x:Number;
    private var mouse_y:Number;
    private var mouseFlag:Boolean = false;
    //
    private var windTimer:Timer;
    private var rippleTimer:Timer;
    //
    public function Environment() 
    {
        
    }
    public function init():void {
        rippleTimer = new Timer( 150 , 3);
        rippleTimer.addEventListener(TimerEvent.TIMER, randomStart);
        rippleTimer.addEventListener(TimerEvent.TIMER_COMPLETE , randomStartComplete, false, 0 , false);
        rippleTimer.start();
        
        windTimer = new Timer( 1000 + 2000 * Math.random() , 1);
        windTimer.addEventListener(TimerEvent.TIMER_COMPLETE , windListener, false, 0 , false);
        windTimer.start();
        //
        var eventManager:EventManager = new EventManager();
        addChild(eventManager);
        eventManager.init();
        eventManager.addEventListener(FlickEvent.FLICK , flickListenr , false , 0 , false);
        eventManager.addEventListener(FlickEvent.FLICK_CLICK , clickListener , false, 0 , false);
        
    }
    private function flickListenr ( event:FlickEvent ):void
    {
        var theta:Number = Math.atan2( event.vy , event.vx);
        setWind(theta);
        //
        windTimer.reset();
        setWindTimer();
    }
    private function setWindTimer():void {
        windTimer = new Timer( 5000 + 5000 * Math.random() , 1);
        windTimer.addEventListener(TimerEvent.TIMER_COMPLETE , windListener, false, 0 , false);
        windTimer.start();
    }
    private function windListener( event:TimerEvent ):void {
        var theta:Number = 2 * Math.PI * Math.random();
        setWind(theta);
        //
        setWindTimer();
    }
    private function randomStart( event:TimerEvent ):void {
        setRipple( Math.random() * (stage.stageWidth - 100) + 50 , Math.random() * (stage.stageHeight - 100) + 50 );
    }
    private function randomStartComplete(event:Event):void {
        rippleTimer = new Timer(Math.floor(3000+Math.random()*3000) , 1);
        rippleTimer.addEventListener(TimerEvent.TIMER_COMPLETE , timeListener);
        rippleTimer.start();
    }
    private function timeListener( event:Event):void {
        setRipple( Math.random() * (stage.stageWidth - 100) + 50 , Math.random() * (stage.stageHeight - 100) + 50 );
        setRippleTimer();
    }
    private function setRippleTimer():void {
        rippleTimer = new Timer(Math.floor( 3000+Math.random()*3000 ) , 1);
        rippleTimer.addEventListener(TimerEvent.TIMER_COMPLETE , timeListener);
        rippleTimer.start();
    }
    private function clickListener( event:FlickEvent ):void {
        setRipple( mouseX, mouseY);
        //
        rippleTimer.reset();
        setRippleTimer();
    }
    private function setWind( theta:Number ):void {
        var wind:Wind = new Wind();
        addChild(wind);
        var R:Number = ( 0.5 * 465) * Math.sqrt(2);
        wind.start_x = stage.stageWidth * 0.5 + R * Math.cos(theta);
        wind.start_y = stage.stageHeight * 0.5 + R * Math.sin(theta);
        wind.start();
    }
    private function setRipple( _x:Number , _y:Number):void {
        var ripple:Ripple = new Ripple();
        ripple.v = 10;
        addChild( ripple );
        ripple.x = _x;
        ripple.y = _y;
        ripple.start();
    }
}


import flash.display.Graphics;
import flash.display.MovieClip;
import flash.events.Event;
class Ripple extends MovieClip 
{
    public var v:Number ;
    private var radius:Number;
    private var pointList:Vector.<Object>;
    private var chackList:Vector.<Boolean>;
    public function Ripple() 
    {
        pointList = Points.getList;
        chackList = new Vector.<Boolean>();
        var i:uint;
        var n:uint = pointList.length;
        for ( i = 0; i < n; i++) {
            chackList.push(true);
        }
    }
    public function start():void {
        radius = 0;
        addEventListener(Event.ENTER_FRAME , enterListener, false, 0, false);
    }
    private function enterListener(event:Event):void {
        /*
        var g:Graphics = this.graphics;
        g.clear();
        */
        v *= 0.98;
        radius += 　v;
        var i:uint;
        var n:uint = pointList.length;
        var pointObject:Object;
        var theta:Number;
        for ( i = 0; i < n; i++) {
            if ( chackList[i] ) {
                pointObject = pointList[i];
                var distance:Number = Math.sqrt( ( this.x -pointObject.x)*( this.x -pointObject.x) + ( this.y - pointObject.y)*( this.y - pointObject.y));
                if ( distance < radius ) {
                    chackList[i] = false;
                    theta = Math.atan2( this.y - pointObject.y , this.x - pointObject.x);
                    pointObject.vx = v * Math.cos( theta );
                    pointObject.vy = v * Math.sin( theta );
                }
            }
        }
        /*
        g.lineStyle( 3, 0x00FF00, v/10);
        g.drawCircle( 0, 0, radius)
        */
        if ( v < 0.5) {
            v = 0;
            removeEventListener(Event.ENTER_FRAME , enterListener);
            MovieClip(this.parent).removeChild( this );
        }
        
    }
}

import flash.display.MovieClip;
import flash.display.Graphics;
import flash.events.Event;
class Wind extends MovieClip 
{
    public var vx:Number = 10;
    public var vy:Number = 0;
    public var start_x:Number = 0;
    public var start_y:Number = 0;
    
    private var lineHeadX:Number;
    private var lineHeadY:Number;
    private var lineTailX:Number;
    private var lineTailY:Number;
    
    private var pointList:Vector.<Object>;
    private var chackList:Vector.<Boolean>;
    public function Wind() 
    {
        pointList = Points.getList;
        chackList = new Vector.<Boolean>();
        var i:uint;
        /**/
        var n:uint = pointList.length;
        for ( i = 0; i < n; i++) {
            chackList.push(true);
        }
        
    }
    public function start():void {
        //
        var theta:Number = Math.atan2( stage.stageHeight * 0.5 - start_y , stage.stageWidth * 0.5 - start_x);
        vx = 10 * Math.cos(theta);
        vy = 10 * Math.sin(theta);
        //
        lineHeadX = start_x+456*Math.cos(theta - 0.5*Math.PI);
        lineHeadY = start_y+456*Math.sin(theta - 0.5*Math.PI);
        
        lineTailX = start_x+456*Math.cos(theta + 0.5*Math.PI);;
        lineTailY = start_y+456*Math.sin(theta + 0.5*Math.PI);
        addEventListener(Event.ENTER_FRAME , enterListener, false, 0, false);
    }
    private function enterListener( event:Event ):void {
        vx *= 0.988;
        vy *= 0.988;
        lineHeadX += vx;
        lineHeadY += vy;
        
        lineTailX += vx;
        lineTailY += vy;
        var v:Number = Math.sqrt( Math.pow( vx, 2) + Math.pow( vy, 2 ));
        
        /*
        var g:Graphics = this.graphics;
        g.clear();
        g.lineStyle( 3, 0x00FF00, v/10);
        g.moveTo(lineHeadX, lineHeadY);
        g.lineTo(lineTailX, lineTailY);
        */
        //
        var pointObject:Object;
        var i:uint = 0;
        var n:uint = pointList.length;
        for ( i = 0; i < n; i++) {
            if ( chackList[i] ) {
                pointObject = pointList[i];

                var exteriorProduct:Number = (( lineTailX - lineHeadX ) * ( pointObject.y - lineHeadY)) -  ((pointObject.x - lineHeadX) * ( lineTailY - lineHeadY )) ;
                if ( exteriorProduct > 0 ) {
                    chackList[i] = false;
                    pointObject.vx = vx;
                    pointObject.vy = vy;
                }
            }
        }
        if ( v < 0.5) {
            v = 0;
            removeEventListener(Event.ENTER_FRAME , enterListener);
            MovieClip(this.parent).removeChild( this );
        }
        
    }
}

import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.ui.MouseCursor;
class EventManager extends Sprite 
{
    private var pre_x:Number;
    private var pre_y:Number;
    private var mousedown_x:Number;
    private var mousedown_y:Number;
    private var mouseCheck:Boolean = false;
    private var clickCheck:Boolean = false;
    public function EventManager() 
    {
        pre_x = mouseX;
        pre_y = mouseY;

    }
    public function init():void {
        addEventListener(Event.ENTER_FRAME, enterLisnter, false, 0, false);
        stage.addEventListener(MouseEvent.MOUSE_DOWN , mousedownListener);
        stage.addEventListener(MouseEvent.MOUSE_UP , mouseupListener );
    }
    private function mousedownListener( event:MouseEvent):void
    {
        mousedown_x = mouseX;
        mousedown_y = mouseY;
        mouseCheck = true;
        clickCheck = true;
    }
    private function mouseupListener( event:Event ):void
    {
        mouseCheck = false;
        var _flickEvent:FlickEvent;
        /*
        var _vx:Number = pre_x - mouseX;
        var _vy:Number = pre_y - mouseY;
        var _v:Number = Math.sqrt( _vx * _vx + _vy * _vy);
        if ( _v > 50 ) {
            _flickEvent = new FlickEvent(FlickEvent.FLICK);
            _flickEvent.vx = _vx;
            _flickEvent.vy = _vy;
            dispatchEvent( _flickEvent );
        }
        */
        //
        if ( clickCheck ) {
            _flickEvent = new FlickEvent(FlickEvent.FLICK_CLICK);
            dispatchEvent( _flickEvent );
        }
    }
    
    private function enterLisnter(event:Event):void {
        if ( clickCheck ) {
            var d:Number = Math.sqrt( Math.pow( mousedown_x - mouseX , 2) + Math.pow( mousedown_y - mouseY , 2));
            if ( d > 5) {
                clickCheck = false;
            }
        }
        if ( mouseCheck ) {

            
            var _vx:Number = pre_x - mouseX;
            var _vy:Number = pre_y - mouseY;
            var _v:Number = Math.sqrt( _vx * _vx + _vy * _vy);
            if ( _v > 50 ) {
                mouseCheck = false;
                var _flickEvent:FlickEvent = new FlickEvent(FlickEvent.FLICK);
                _flickEvent.vx = _vx;
                _flickEvent.vy = _vy;
                dispatchEvent( _flickEvent );
            }
        }
        pre_x = mouseX;
        pre_y = mouseY;
    }
}

import flash.events.Event;
class FlickEvent extends Event
{
    /**
     * consts
     */
    public static const FLICK:String = "frick";
    public static const FLICK_CLICK:String = "frick_click";
    /**
     *  vars
     */
    public var vx:Number;
    public var vy:Number;
    //
    public function FlickEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
    }
    
}

