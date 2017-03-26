/* ------------------------------------------------------------------------------------------------
 * [階段シリーズ]
 * http://wonderfl.net/c/zQW4 hiyoko vs. unko (HVU)
 * http://wonderfl.net/c/2epI A
 * http://wonderfl.net/c/z1Fp Penrose Stairs Complex
 * http://wonderfl.net/c/lVRx Penrose Stairs Fractal
 * http://wonderfl.net/c/atBv Complementary Penrose Stairs Fractal
 * ------------------------------------------------------------------------------------------------
 */
package {
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    import org.libspark.betweenas3.tweens.ITweenGroup;
    
    [SWF(width="465",height="465",frameRate="30")]
    public class Main extends Sprite {
        private var _objects:Array;
        
        public function Main() {
            _objects = [];
            
            // 階段の作成
            var boxSize:int = 60;
            var riser:Number = boxSize / 6;
            var boxX:Array = [0, 1, 2, 2, 2, 1];
            var baseX:Array = [0, 1, 2, 2, 1, 2];
            var boxZ:Array = [0, 0, 0, -1, -2, -2];
            for (var i:int = 0; i < 6; i++) {
                var box:IsoBox = new IsoBox(boxSize, 2 + i * riser);
                var base:IsoBox = new IsoBox(boxSize, 501);
                box.wx = boxSize * boxX[i];
                base.wx = boxSize * baseX[i];
                box.wy = -500;
                box.wz = base.wz = boxSize * boxZ[i];
                _objects.push(box);
                addChild(base);
            }
            
            // 移動用ノードの作成
            var _nodes:Array = [];
            for each (box in _objects) {
                _nodes.push( { x: box.wx, y: -box.height -500, z: box.wz } );
            }
            _nodes.push( { x: boxSize, y: -boxSize -500, z: -boxSize } );
            
            // 位置調整
            x = 232 - boxSize / 2;
            y = 732;
            graphics.beginFill(0x000000);
            graphics.drawRect(-x, -y, 465, 465);
            graphics.endFill();
                        
            // ひよこちゃんの作成
            var hiyoko:IsoPiyo = new IsoPiyo();
            hiyoko.turn("right");
            
            var hiyokoWithShadow:IsoObject = createIsoObjectWithShadow(hiyoko);
            hiyokoWithShadow.wx = _nodes[0].x;
            hiyokoWithShadow.wy = _nodes[0].y;
            hiyokoWithShadow.wz = _nodes[0].z;
            _objects.push(hiyokoWithShadow);
            
            var hiyokoTween:ITween = BetweenAS3.serial(
                hiyokoJumpTween(1),
                hiyokoJumpTween(2),
                BetweenAS3.func(hiyoko.turn, ["down"]),
                hiyokoJumpTween(3),
                hiyokoJumpTween(4),
                BetweenAS3.func(hiyoko.turn, ["left"]),
                hiyokoJumpTween(5),
                BetweenAS3.func(hiyoko.turn, ["up"]),
                hiyokoJumpTween(6),
                BetweenAS3.func(hiyoko.turn, ["right"])
            );
            hiyokoTween.stopOnComplete = false;
            
            function hiyokoJumpTween(toNode:int):ITweenGroup {
                return BetweenAS3.parallel(
                    BetweenAS3.bezierTo(hiyoko, { wy:0 }, { wy: -60 }, 0.5),
                    (toNode == 1)
                        ? BetweenAS3.tween(hiyokoWithShadow,
                            { wx: _nodes[1].x, wy: _nodes[1].y, wz: _nodes[1].z },
                            { wx: _nodes[0].x, wy: _nodes[0].y, wz: _nodes[0].z }, 0.5
                        )
                        : BetweenAS3.to(hiyokoWithShadow,
                            { wx: _nodes[toNode].x, wy: _nodes[toNode].y, wz: _nodes[toNode].z }, 0.5
                        )
                );
            }
            
            // ワンコの作成
            var unko:IsoWanco = new IsoWanco();
            unko.turn("down");
            
            var unkoWithShadow:IsoObject = createIsoObjectWithShadow(unko);
            unkoWithShadow.wx = _nodes[3].x;
            unkoWithShadow.wy = _nodes[3].y;
            unkoWithShadow.wz = _nodes[3].z;
            _objects.push(unkoWithShadow);
            
            var unkoTween:ITween = BetweenAS3.serial(
                unkoJumpTween(4),
                BetweenAS3.func(unko.turn, ["left"]),
                unkoJumpTween(5),
                BetweenAS3.func(unko.turn, ["up"]),
                unkoJumpTween(6),
                BetweenAS3.func(unko.turn, ["right"]),
                unkoJumpTween(1),
                unkoJumpTween(2),
                BetweenAS3.func(unko.turn, ["down"]),
                unkoJumpTween(3)
            );
            unkoTween.stopOnComplete = false;
            
            function unkoJumpTween(toNode:int):ITweenGroup {
                return BetweenAS3.parallel(
                    BetweenAS3.func(unko.jump),
                    BetweenAS3.delay(
                        (toNode == 1)
                            ? BetweenAS3.tween(unkoWithShadow,
                                { wx: _nodes[1].x, wy: _nodes[1].y, wz: _nodes[1].z },
                                { wx: _nodes[0].x, wy: _nodes[0].y, wz: _nodes[0].z }, 0.38
                            )
                            : BetweenAS3.to(unkoWithShadow, 
                                { wx: _nodes[toNode].x, wy: _nodes[toNode].y, wz: _nodes[toNode].z }, 0.38
                            ),
                        0.06, 0.06
                    )
                );
            }
            
            // アニメーション開始
            hiyokoTween.play();
            unkoTween.play();
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        private function createIsoObjectWithShadow(content:IsoObject):IsoObject {
            var obj:IsoObject = new IsoObject();
            
            var shadow:Shape = new Shape();
            shadow.graphics.beginFill(0x000000, 0.5);
            shadow.graphics.drawEllipse( -20, -10, 40, 20);
            shadow.graphics.endFill();
            shadow.filters = [new BlurFilter(20, 10)];
            
            obj.addChild(shadow);
            obj.addChild(content);
            
            return obj; 
        }
        
        private function update(event:Event):void {
            _objects.sort(IsoObject.compareDepth);
            for each (var obj:IsoObject in _objects) {
                addChild(obj);
            }
        }
    }
}
/* ------------------------------------------------------------------------------------------------
 * IsoObject
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    
    //public 
    class IsoObject extends Sprite {
        private var _world:Vector3D;
        private var _screen:Point;
        
        public function IsoObject() {
            _world = new Vector3D(0, 0, 0);
            _screen = new Point(0, 0);
        }
        
        public function update():void {
            x = _screen.x;
            y = _screen.y;
        }
        
        public static function compareDepth(a:IsoObject, b:IsoObject):Number {
            return IsoUtils.compareDepth(a._world, b._world);
        }
        
        public function get wx():Number { return _world.x; }
        public function set wx(value:Number):void { _world.x = value; IsoUtils.isoToScreen(_world, _screen); update(); }
        public function get wy():Number { return _world.y; }
        public function set wy(value:Number):void { _world.y = value; IsoUtils.isoToScreen(_world, _screen); update(); }
        public function get wz():Number { return _world.z; }
        public function set wz(value:Number):void { _world.z = value; IsoUtils.isoToScreen(_world, _screen); update(); }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * IsoBox
 * ------------------------------------------------------------------------------------------------
 */
//package {
    //public 
    class IsoBox extends IsoObject {
        private var _size:Number;
        private var _height:Number;
        
        public function IsoBox(size:Number, height:Number) {
            super();
            _size = size;
            _height = height;
            draw();
        }
        
        private function draw():void {
            var halfSize:Number = _size / 2;
            graphics.clear();
            graphics.moveTo(0, halfSize - _height);
            
            drawTopFace();
            drawLeftFace();
            drawRightFace();
            
            function drawTopFace():void {
                graphics.lineStyle(0, 0xC0C0C0);
                graphics.beginFill(0xFFFFFF);
                graphics.lineTo( -_size, -_height);
                graphics.lineTo(0, -halfSize - _height);
                graphics.lineTo(_size, -_height);
                graphics.lineTo(0, halfSize - _height);
                graphics.endFill();
            }
            
            function drawLeftFace():void {
                graphics.lineStyle();
                graphics.beginFill(0xC0C0C0);
                graphics.lineTo(0, halfSize);
                graphics.lineTo( -_size, 0);
                graphics.lineTo( -_size, -_height);
                graphics.lineTo(0, halfSize - _height);
                graphics.endFill();
            }
            
            function drawRightFace():void {
                graphics.lineStyle();
                graphics.beginFill(0x808080);
                graphics.lineTo(0, halfSize);
                graphics.lineTo(_size, 0);
                graphics.lineTo(_size, -_height);
                graphics.lineTo(0, halfSize - _height);
                graphics.endFill();
            }
        }
        
        override public function get height():Number { return _height; }
        override public function set height(value:Number):void { _height = value; draw(); }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * IsoPiyo
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    //public 
    class IsoPiyo extends IsoObject {
        private var _mc:MovieClip;
        private var _direction:String;
        
        private static var Piyo:Class = null;
        
        public function IsoPiyo() {
            super();
            _direction = "down";
            
            if (Piyo) {
                initialize();
            }else {
                var loader:Loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.INIT, onSWFLoaded);
                loader.load(
                    new URLRequest("http://www.project-nya.jp/images/flash/piyo25d.swf"),
                    new LoaderContext(true)
                );
            }
        }
        
        private function onSWFLoaded(event:Event):void {
            event.target.removeEventListener(Event.INIT, onSWFLoaded);
            Piyo = event.target.content.piyo.constructor;
            initialize();
        }
        
        private function initialize():void {
            addChild(_mc = new Piyo());
            _mc.y = 24 - 15 * IsoUtils.TRUE_SCALE;
            _mc.shade.visible = false;
            turn(_direction);
        }
        
        public function turn(direction:String):void {
            _direction = direction;
            if (!_mc) { return; }
            
            switch(direction) {
                case "up": { _mc.rotate(135); break; }
                case "down": { _mc.rotate(-45); break; }
                case "left": { _mc.rotate(-135); break; }
                case "right": { _mc.rotate(45); break; }
            }
        }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * IsoWanco
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    //public 
    class IsoWanco extends IsoObject {
        private var _mc:MovieClip;
        private var _direction:String;
        
        private static var Wanco:Class = null;
        
        public function IsoWanco() {
            super();
            _direction = "down";
            
            if (Wanco) {
                initialize();
            }else {
                var loader:Loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.INIT, onSWFLoaded);
                loader.load(
                    new URLRequest("http://swf.wonderfl.net/static/assets/checkmate05/wancoAmateur.swf"),
                    new LoaderContext(true)
                );
            }
        }
        
        private function onSWFLoaded(event:Event):void {
            event.target.removeEventListener(Event.INIT, onSWFLoaded);
            Wanco = event.target.applicationDomain.getDefinition("JumpMotion");
            initialize();
        }
        
        private function initialize():void {
            addChild(_mc = new Wanco());
            _mc.y = 27.5 - 15 * IsoUtils.TRUE_SCALE;
            turn(_direction);
        }
        
        public function turn(direction:String):void {
            _direction = direction;
            if (!_mc) { return; }
            
            switch(direction) {
                case "up": { _mc.wc2.wc3.gotoAndStop(10); break; }
                case "down": { _mc.wc2.wc3.gotoAndStop(1); break; }
                case "left": { _mc.wc2.wc3.gotoAndStop(14); break; }
                case "right": { _mc.wc2.wc3.gotoAndStop(4); break; }
            }
        }
        
        public function jump():void {
            if (_mc) { _mc.gotoAndPlay(1); }
        }
    }
//}
/* ------------------------------------------------------------------------------------------------
 * IsoUtils
 * ------------------------------------------------------------------------------------------------
 */
//package {
    import flash.geom.Point;
    import flash.geom.Vector3D;
    
    //public 
    class IsoUtils {
        public static const TRUE_SCALE:Number = Math.cos( -30 * Math.PI / 180) * Math.SQRT2;
        
        public static function isoToScreen(iso:Vector3D, out:Point = null):Point {
            out ||= new Point(0, 0);
            out.x = iso.x + iso.z;
            out.y = (iso.x - iso.z) / 2 + iso.y;
            return out;
        }
        
        public static function screenToIso(screen:Point, out:Vector3D = null):Vector3D {
            out ||= new Vector3D(0, 0, 0);
            out.x = (screen.x / 2 + screen.y) - out.y;
            out.z = (screen.x / 2 - screen.y) + out.y;
            return out;
        }
        
        public static function compareDepth(a:Vector3D, b:Vector3D):Number {
            return (a.x - a.y - a.z) - (b.x - b.y - b.z);
        }
    }
//}