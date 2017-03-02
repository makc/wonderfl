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
    import com.bit101.components.Label;
    import com.bit101.components.NumericStepper;
    import flash.display.Sprite;
    import flash.events.Event;
    
    [SWF(width="465",height="465",frameRate="30",backgroundColor="0x000000")]
    public class Main extends Sprite {
        private var _penroseStairs:IsoObject;
        
        private static const TILE_SIZE:Number = 90;
        
        public function Main() {
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            var isoContainer:Sprite = new Sprite();
            isoContainer.x = 232;
            isoContainer.y = 432;
            addChild(isoContainer);
            
            new Label(this, 10, 10, "level");
            var level:NumericStepper = new NumericStepper(this, 50, 10, function(event:Event):void {
                isoContainer.removeChild(_penroseStairs);
                isoContainer.addChild(_penroseStairs = createPenroseStairs(level.value, TILE_SIZE));
            });
            level.minimum = 1;
            level.maximum = 4;
            
            isoContainer.addChild(_penroseStairs = createPenroseStairs(1, TILE_SIZE));
        }
        
        private function createPenroseStairs(level:int, tileSize:Number):IsoObject {
            if (level == 0) { return new IsoBox(tileSize * 3.4, 200); }
            
            var result:IsoObject = new IsoObject();    
            var boxContainer:Sprite = new Sprite();
            var step:Array = [0,1,2,3,4,9,5,8,7,6];
            var tileX:Array = [0,1,2,3,3,1,3,1,2,3];
            var tileZ:Array = [0,0,0,0,1,2,2,3,3,3];
            for (var i:int = 0; i < 10; i++) {
                var tile:IsoObject = createPenroseStairs(level - 1, tileSize / 3.4);
                tile.wx = tileSize * tileX[i];
                tile.wy = -tileSize / 10 * step[i];
                tile.wz = -tileSize * tileZ[i];
                boxContainer.addChild(tile);
            }
            boxContainer.x = -tileSize / 2;
            boxContainer.y = -(tileSize * 1.2);
            result.addChild(boxContainer);
            return result;
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