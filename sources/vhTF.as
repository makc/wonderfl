package {
    import Box2D.Collision.Shapes.b2CircleDef;
    import Box2D.Collision.Shapes.b2PolygonDef;
    import Box2D.Collision.b2AABB;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2DebugDraw;
    import Box2D.Dynamics.b2World;

    import com.bit101.components.Label;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;

    [SWF(backgroundColor="#ffffff", frameRate="60", width="475", height="475")]

    
    public class Mosaic extends Sprite {
        
        private static const NUM_CIRCLES:int = 200;
        private static const DEBUG_DRAW:Boolean = false;
        
        private static const TO_PHYSICS_SCALE:Number = 1.0 / 30.0;
        private static const TO_DRAW_SCALE:Number = 1 / TO_PHYSICS_SCALE;
        private static const ITERATIONS:int = 5;
        private static const TIME_STEP:Number = 1.0 / 30.0;
        
        private static const STEP1_SIMULATE:int = 0;
        private static const STEP2_WAIT_FOR_SLEEP:int = 1;
        private static const STEP3_RECONSTRUCTION:int = 2;
        
        
        private var _label:Label;
        private var _refImage:BitmapData;
        private var _world:b2World;
        private var _objects:Array = [];
        private var _frameCount:int = 0;
        private var _maxFrames:int;
        private var _step:int = STEP1_SIMULATE;
        private var _enterFrameHandler:Function;

        
        public function Mosaic(){
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.BEST;
            
            _label = new Label(this, 10, 5, 'LOADING.....');
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLoadComplete);
            loader.load(new URLRequest('http://saqoo.sh/a/labs/wonderfl/color.png'), new LoaderContext(true));
        }
        
        
        private function _onLoadComplete(event:Event):void {
            var loader:Loader = LoaderInfo(event.target).loader;
            _refImage = Bitmap(loader.content).bitmapData;
            
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set(-1000.0, -1000.0);
            worldAABB.upperBound.Set(1000.0, 1000.0);
            _world = new b2World(worldAABB, new b2Vec2(0.0, 10.0), true);
            _world.SetWarmStarting(true);
            
            _buildStaticBox(5 - 50, 475 / 2, 100, 1000);
            _buildStaticBox(475 - 5 + 50, 475 / 2, 100, 1000);
            _buildStaticBox(475 / 2, 475 - 5 + 50, 1000, 100);
            _buildStaticBox(0, 0, 50, 5);
            
            if (DEBUG_DRAW) {
                var dbgDraw:b2DebugDraw = new b2DebugDraw();
                dbgDraw.m_sprite = this;
                dbgDraw.m_drawScale = 30.0;
                dbgDraw.m_fillAlpha = 0.0;
                dbgDraw.m_lineThickness = 1.0;
                dbgDraw.m_drawFlags = 0xFFFFFFFF;
                _world.SetDebugDraw(dbgDraw);
            }
            
            _enterFrameHandler = _step1;
            
            addEventListener(Event.ENTER_FRAME, _onEnterFrame, false, 0, true);
        }

        
        private function _buildStaticBox(centerX:Number, centerY:Number, width:Number, height:Number):b2Body {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(centerX * TO_PHYSICS_SCALE, centerY * TO_PHYSICS_SCALE);
            
            var boxDef:b2PolygonDef = new b2PolygonDef();
            boxDef.SetAsBox(width * TO_PHYSICS_SCALE / 2, height * TO_PHYSICS_SCALE / 2);
            boxDef.friction = 0.3;
            boxDef.density = 0;
            
            var body:b2Body = _world.CreateBody(bodyDef);
            body.CreateShape(boxDef);
            body.SetMassFromShapes();

            return body;
        }
        
        
        private function _buildDynamicCircle(centerX:Number, centerY:Number, radius:Number, graphic:DisplayObject = null):b2Body {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.position.Set(centerX * TO_PHYSICS_SCALE, centerY * TO_PHYSICS_SCALE);

            var circleDef:b2CircleDef = new b2CircleDef();
            circleDef.radius = radius * TO_PHYSICS_SCALE;
            circleDef.density = 1.0;
            circleDef.friction = 0.3;
            circleDef.restitution = 0.5;
            
            var body:b2Body = _world.CreateBody(bodyDef);
            body.CreateShape(circleDef);
            body.SetMassFromShapes();
            
            return body;
        }

        
        private function _onEnterFrame(event:Event):void {
            if (_enterFrameHandler is Function) {
                _enterFrameHandler();
            }
        }

        
        private function _step1():void {
            if (_frameCount % 3 == 0) {
                var px:Number = Math.random() * 475;
                var py:Number = -30;
                var r:Number = Math.random() * Math.random() * 30 + 5;
                var b:b2Body = _buildDynamicCircle(px, py, r);
                var v:Number = (Math.random() - 0.5) * 50;
                b.ApplyImpulse(new b2Vec2(v, 0), new b2Vec2());
                var sp:Recorder = new Recorder();
                sp.frameOffset = _frameCount;
                b.SetUserData(sp);
                _objects.push({
                    px: px,
                    py: py,
                    r: r,
                    v: v,
                    b: b,
                    sp: sp
                });
                if (_objects.length == NUM_CIRCLES) {
                    _step = STEP2_WAIT_FOR_SLEEP;
                    _enterFrameHandler = _step2;
                    _maxFrames = _frameCount;
                    _frameCount = 0;
                }
            }
            _step2();
        }
        
        
        private function _step2():void {
            _world.Step(TIME_STEP, ITERATIONS);
            if (DEBUG_DRAW && _frameCount % 30 == 0) {
                _world.DrawDebugData();
            }

            for (var bb:b2Body = _world.GetBodyList(); bb; bb = bb.GetNext()){
                var rec:Recorder = bb.GetUserData() as Recorder;
                if (rec) {
                    var pos:b2Vec2 = bb.GetPosition();
                    rec.save(pos.x * TO_DRAW_SCALE, pos.y * TO_DRAW_SCALE);
                }
            }
            _frameCount++;
            
            if (_step == Mosaic.STEP2_WAIT_FOR_SLEEP && _frameCount > 300) {
                _enterFrameHandler = null;
                _step = STEP3_RECONSTRUCTION;
                graphics.clear();
                var n:int = _objects.length;
                for (var i:int = 0; i < n; ++i) {
                    var info:Object = _objects[i];
                    var b:b2Body = info.b;
                    var p:b2Vec2 = b.GetPosition();
                    var dx:Number = p.x * TO_DRAW_SCALE;
                    var dy:Number = p.y * TO_DRAW_SCALE;
                    var c:uint = _refImage.getPixel(dx / 475 * _refImage.width, dy / 475 * _refImage.height);
                    var sp:Recorder = info.sp;
                    sp.draw(c, info.r);
                    _objects[i] = sp;
                }
                _maxFrames += _frameCount;
                _frameCount = 0;
                _label.text = 'CLICK TO START';
                stage.addEventListener(MouseEvent.CLICK, _onClickStage);
            }
        }
        
        
        private function _step3():void {
            var n:int = _objects.length;
            for (var i:int = 0; i < n; ++i) {
                var sp:Recorder = _objects[i];
                if (sp.frameOffset <= _frameCount) {
                    if (!sp.parent) {
                        addChild(sp);
                    }
                    sp.restore(_frameCount - sp.frameOffset);
                }
            }
            _frameCount++;
        }

        
        private function _onClickStage(event:MouseEvent):void {
            var n:int = numChildren;
            while (n--) {
                removeChildAt(n);
            }
            _frameCount = 0;
            _enterFrameHandler = _step3;
        }
    }
}

import flash.display.Sprite;


class Recorder extends Sprite {

    
    public var frameOffset:int = 0;
    private var _px:Vector.<Number>;
    private var _py:Vector.<Number>;


    public function Recorder() {
        _px = new Vector.<Number>();
        _py = new Vector.<Number>();
    }
    
    
    public function save(rx:Number = NaN, ry:Number = NaN):void {
        if (isNaN(rx)) {
            _px.push(x); 
            _py.push(y);
        } else {
            _px.push(rx);
            _py.push(ry);
        }
    }
    
    
    public function restore(frame:int):void {
        if (frame < _px.length) {
            x = _px[frame];
            y = _py[frame];
        }
    }
    
    
    public function draw(color:uint, radius:Number):void {
        graphics.beginFill(color);
        graphics.drawCircle(0, 0, radius);
        graphics.endFill();
    }
}
