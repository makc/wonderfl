package {
    
    import Box2D.Collision.Shapes.b2PolygonDef;
    import Box2D.Collision.b2AABB;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2World;
    
    import com.flashdynamix.utils.SWFProfiler;
    
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.display.StageQuality;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getTimer;
    
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.Back;

    [SWF(width=465, height=465, backgroundColor=0xffffff, frameRate=30)]

    public class WaraWara extends Sprite {
        
        private static const RADtoDEG:Number = 180 / Math.PI;
        
        private static const NUM_ITERATIONS:int = 20;
        private static const DRAW_SCALE:Number = 30;
        
        private var _world:b2World;
        private var _lastTime:int;
        
        public function WaraWara() {
            stage.quality = StageQuality.LOW;
            scaleX = scaleY = DRAW_SCALE;
            
            SWFProfiler.init(this);
            
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set(-100, -100);
            worldAABB.upperBound.Set(465 + 100, 465 + 100);
            _world = new b2World(worldAABB, new b2Vec2(0.0, 10.0), true);
            
            // set debug draw
//            var dbgDraw:b2DebugDraw = new b2DebugDraw();
//            var dbgSprite:Sprite = new Sprite();
//            addChild(dbgSprite);
//            dbgDraw.m_sprite = dbgSprite;
//            //dbgDraw.m_drawScale = 1;//30.0;
//            dbgDraw.m_fillAlpha = 0.0;
//            dbgDraw.m_lineThickness = 0;
//            dbgDraw.m_drawFlags = 0xFFFFFFFF;
//            _world.SetDebugDraw(dbgDraw);
            
            _buildFloor();
            Wara.init();
            
            _lastTime = getTimer();
            addEventListener(Event.ENTER_FRAME, _update);
            
            var timer:Timer = new Timer(150, 0);
            timer.addEventListener(TimerEvent.TIMER, _addWara);
            timer.start();
        }
        
        private function _buildFloor():void {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(465 / 2 / DRAW_SCALE, (465 + 20) / DRAW_SCALE);
            var boxDef:b2PolygonDef = new b2PolygonDef();
            boxDef.SetAsBox(465 / 2 / DRAW_SCALE, 20 / DRAW_SCALE);
            boxDef.friction = 0.3;
            boxDef.density = 0;
            var body:b2Body = _world.CreateBody(bodyDef);
            body.CreateShape(boxDef);
            body.SetMassFromShapes();
        }
        
        private function _addWara(e:Event):void {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.angle = Math.random() * Math.PI * 2;
            bodyDef.position.x = (stage.stageWidth / 2 + (Math.random() - 0.5) * 200) / DRAW_SCALE;
            bodyDef.position.y = (300 - Math.random() * 50) / DRAW_SCALE;

            var wara:Wara = addChild(new Wara(Math.random() + 0.2)) as Wara;
            wara.y = -100;
            
            var boxDef:b2PolygonDef = new b2PolygonDef();
            boxDef.SetAsBox(wara.width / 2 / DRAW_SCALE, wara.height / 2 / DRAW_SCALE);
            boxDef.density = 1.0;
            boxDef.friction = 0.5;
            boxDef.restitution = 0.2;
            
            bodyDef.userData = wara;
            wara.scaleX = wara.scaleY = 0;
            BetweenAS3.tween(wara, {scaleX: 1 / DRAW_SCALE, scaleY: 1 / DRAW_SCALE}, null, 0.5, Back.easeOut).play();
            
            var body:b2Body = _world.CreateBody(bodyDef);
            body.CreateShape(boxDef);
            body.SetMassFromShapes();
        }
        
        private function _update(e:Event):void {
            var now:int = getTimer();
            var dt:Number = now - _lastTime;
            _lastTime = now;
            _world.Step(dt / 1000, NUM_ITERATIONS);
            
            for (var bb:b2Body = _world.m_bodyList; bb; bb = bb.m_next){
                var px:Number = bb.GetPosition().x * DRAW_SCALE;
                var py:Number = bb.GetPosition().y * DRAW_SCALE;
                if (px < 0 - 50 || 465 + 50 < px || 465 + 50 < py) {
                    removeChild(bb.GetUserData());
                    _world.DestroyBody(bb);
                    break;
                }
                if (bb.m_userData is Sprite){
                    bb.m_userData.x = bb.GetPosition().x;
                    bb.m_userData.y = bb.GetPosition().y;
                    bb.m_userData.rotation = bb.GetAngle() * RADtoDEG;
                }
            }
        }
    }
}



import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.getTimer;

import frocessing.color.ColorHSV;

class Wara extends Sprite {
    
    public static var _waraImage:BitmapData;
    
    public static function init():void {
        var tf:TextField = new TextField();
        var fmt:TextFormat = new TextFormat('Verdana', 64, 0xffffff, true);
        fmt.letterSpacing = -10;
        tf.defaultTextFormat = fmt;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.text = 'ワラ';
        var tmp:BitmapData = new BitmapData(tf.width, tf.height, true, 0x0);
        tmp.draw(tf);
        var rect:Rectangle = tmp.getColorBoundsRect(0xff000000, 0xff000000, true);
        _waraImage = new BitmapData(rect.width, rect.height, true, 0x0);
        _waraImage.draw(tmp, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
    }
    
    public function Wara(scale:Number) {
        var b:Bitmap = addChild(new Bitmap(_waraImage)) as Bitmap;
        b.scaleX = b.scaleY = scale;
        b.x = -b.width / 2;
        b.y = -b.height / 2;
        var col:ColorHSV = new ColorHSV((getTimer() / 30) % 360);
        transform.colorTransform = new ColorTransform(col.r / 255, col.g / 255, col.b / 255);
    }
}