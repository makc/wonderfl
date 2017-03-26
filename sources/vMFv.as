////////////////////////////////////////////////////////////////////////////////
// TrackLight (1)
//
// [AS3.0] TrackLightクラスだ！ (6)
// http://www.project-nya.jp/modules/weblog/details.php?blog_id=1291
////////////////////////////////////////////////////////////////////////////////

package {

    import flash.display.Sprite;
    import flash.geom.Rectangle;

    [SWF(backgroundColor="#000000", width="465", height="465", frameRate="60")]

    public class Main extends Sprite {
        private var light:TrackLight;

        public function Main() {
            Wonderfl.capture_delay(4);
            init();
        }

        private function init():void {
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            //
            var rect:Rectangle = new Rectangle(0, 0, 465, 465);
            light = new TrackLight(rect);
            addChild(light);
            light.start();
        }
        
    }

}


//////////////////////////////////////////////////
// TrackLightクラス
//////////////////////////////////////////////////

import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.ColorTransform;
import flash.display.BlendMode;
import flash.filters.BlurFilter;
import __AS3__.vec.Vector;
import flash.utils.Timer;
import flash.events.TimerEvent;
import frocessing.color.ColorHSV;

class TrackLight extends Sprite {
    private var rect:Rectangle;
    private var cx:uint = 0;
    private var cy:uint = 0;
    private var bitmapData:BitmapData;
    private var bitmap:Bitmap;
    private var container:Sprite;
    private var color:ColorHSV;
    private var colorTrans:ColorTransform;
    private static var blur:BlurFilter;
    private static var point:Point = new Point();
    private var id:uint = 0;
    private var leader:TrackLeader;
    private static var max:uint = 3;
    private var followers:Array;
    private var tracks:Vector.<Point>;
    private static var interval:uint = 10;
    private var particles:Array;
    private var timer:Timer;

    public function TrackLight(r:Rectangle) {
        rect = r;
        cx = rect.x + rect.width/2;
        cy = rect.y + rect.height/2;
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
    }

    private function init(evt:Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        bitmapData = new BitmapData(rect.width, rect.height, true, 0x00000000);
        bitmap = new Bitmap(bitmapData);
        addChild(bitmap);
        container = new Sprite();
        addChild(container);
        color = new ColorHSV(0);
        colorTrans = new ColorTransform();
        blur = new BlurFilter(8, 8, 3);
        leader = new TrackLeader();
        leader.x = cx;
        leader.y = cy;
        followers = new Array();
        tracks = new Vector.<Point>();
        for (var n:uint = 0; n < max; n++) {
            var follower:TrackFollower = new TrackFollower();
            follower.x = cx;
            follower.y = cy;
            followers.push(follower);
            for (var t:uint = 0; t < interval; t++) {
                tracks.push(new Point(cx, cy));
            }
        }
        particles = new Array();
    }
    public function start():void {
        timer = new Timer(20);
        timer.addEventListener(TimerEvent.TIMER, create, false, 0, true);
        timer.start();
        addEventListener(Event.ENTER_FRAME, update, false, 0, true);
    }
    public function stop():void {
        timer.stop();
        timer.removeEventListener(TimerEvent.TIMER, create);
        removeEventListener(Event.ENTER_FRAME, update);
    }
    private function create(evt:TimerEvent):void {
        var particle:ParticleLight = new ParticleLight(8, 0xFFFFFF);
        particle.track(leader);
        particle.angle = Math.random()*360;
        particle.speed = Math.random()*3 + 5;
        particle.power = 1;
        particle.setup();
        particle.blendMode = BlendMode.ADD;
        container.addChild(particle);
        particles.push(particle);
        for (var n:uint = 0; n < max; n++) {
            particle = new ParticleLight(8, 0xFFFFFF);
            var follower:TrackFollower = followers[n];
            particle.track(follower);
            particle.angle = Math.random()*360;
            particle.speed = Math.random()*3 + 5;
            particle.power = 1;
            particle.setup();
            particle.blendMode = BlendMode.ADD;
            container.addChild(particle);
            particles.push(particle);
        }
    }
    private function update(evt:Event):void {
        setup();
        bitmapData.lock();
        for (var n:uint = 0; n < particles.length; n++) {
            var particle:ParticleLight = particles[n];
            particle.update();
            particle.scale = particle.alpha = particle.power;
            if (particle.power < 0) {
                container.removeChild(particle);
                particles.splice(n, 1);
                particle = null;
            }
        }
        color.h = id;
        colorTrans.color = color.value;
        bitmapData.draw(container, null, colorTrans, BlendMode.SCREEN, null, true);
        bitmapData.applyFilter(bitmapData, rect, point, blur);
        bitmapData.unlock();
        id ++;
    }
    private function setup():void {
        leader.update(new Point(mouseX, mouseY));
        for (var n:uint = 0; n < max; n++) {
            var follower:Object = followers[n];
            follower.update(tracks[interval*(n + 1) - 1]);
        }
        tracks.unshift(new Point(leader.x, leader.y));
        tracks.pop();        
    }

}


//////////////////////////////////////////////////
// TrackLeaderクラス
//////////////////////////////////////////////////

import flash.geom.Point;

class TrackLeader {
    public var x:Number = 0;
    public var y:Number = 0;
    private static var deceleration:Number = 0.16;

    public function TrackLeader() {
    }

    public function update(track:Point):void {
        x += (track.x - x)*deceleration;
        y += (track.y - y)*deceleration;
    }

}


//////////////////////////////////////////////////
// TrackFollowerクラス
//////////////////////////////////////////////////

import flash.geom.Point;

class TrackFollower {
    public var x:Number = 0;
    public var y:Number = 0;
    private static var deceleration:Number = 0.16;

    public function TrackFollower() {
    }

    public function update(track:Point):void {
        x = track.x;
        y = track.y;
    }

}


//////////////////////////////////////////////////
// ParticleLightクラス
//////////////////////////////////////////////////

import flash.display.Shape;

class ParticleLight extends Shape {
    private var radius:uint = 10;
    private var color:uint = 0xFFFFFF;
    private var target:Object;
    public var angle:Number = 0;
    public var speed:Number = 0;
    private var tx:Number = 0;
    private var ty:Number = 0;
    private var vx:Number = 0;
    private var vy:Number = 0;
    public var power:Number = 0;
    private static var radian:Number = Math.PI/180;
    private static var friction:Number = 0.96;
    private static var deceleration:Number = 0.02;
    private static var acceleration:Number = 0.05;
    private var _scale:Number = 1;

    public function ParticleLight(r:uint = 10, c:uint = 0xFFFFFF) {
        radius = r;
        color = c;
        draw();
    }

    private function draw():void {
        graphics.beginFill(color);
        graphics.drawCircle(0, 0, radius);
        graphics.endFill();
    }
    public function track(t:Object):void {
        target = t;
    }
    public function setup():void {
        x = target.x;
        y = target.y;
        vx = speed*Math.cos(angle*radian);
        vy = speed*Math.sin(angle*radian);
    }
    public function update():void {
        tx += vx;
        ty += vy;
        x += (target.x + tx - x)*acceleration;
        y += (target.y + ty - y)*acceleration;
        vx *= friction;
        vy *= friction;
        power -= deceleration;
    }
    public function get scale():Number {
        return _scale;
    }
    public function set scale(param:Number):void {
        _scale = param;
        scaleX = scaleY = _scale;
    }

}
