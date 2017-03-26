// forked from makc3d's Explosions (now clickable)
// forked from makc3d's Explosions
package {
    import flash.filters.*;
    import flash.geom.*;
    import flash.display.*;
    import flash.events.*;

    [SWF(backgroundColor="#000000")]
    public class FlashTest extends Sprite {
        private var bmd : BitmapData;
        private var cell : Shape;

        private var r : Function = Math.random;
        private var mat : Matrix = new Matrix();
        private const N : uint = 18;
        private const R : uint = 100;
        private var _blurs : Array;
 
        // yeah, those fake-looking explosions...
        private function boo (ss : Array):Array {
            var ret : Array = [];
            
            bmd.lock();
            for each(var s : Seed in ss){
                if(s.v < 5)continue;
                
                mat.identity();
                mat.scale(s.v, s.v);
                mat.rotate(Math.PI * 2 * r());
                mat.translate(s.x, s.y);
                cell.filters = [_blurs[uint(s.v/3)]];
                // new BlurFilter (s.v / 3, s.v / 3) ];
                
                bmd.draw(cell, mat, null, BlendMode.ADD);
            
                ret.push(new Seed(
                    s.x + (r() - r()) * s.v,
                    s.y + (r() - r()) * s.v,
                    s.v * (0.8 + 0.2 * r())
                    ));
                if(Math.random() < 1.0 - _t / 12)ret.push(new Seed(
                    s.x + (r() - r()) * s.v,
                    s.y + (r() - r()) * s.v,
                    s.v * (0.8 + 0.2 * r())
                    ));
            }
            bmd.unlock();
            
            return ret;
        }

        private function init() : void
        {
            bmd = new BitmapData(465, 465, false, 0x000000);
            addChild(new Bitmap(bmd));

            cell = new Shape();
            repaint(0x3f170d);
            
            _blurs = new Array(uint(R / 3) + 1);
            for(var i : uint = 0;i <= R / 3;i++){
                _blurs[i] = new BlurFilter(i, i);
            }
        }
        
        private function repaint(c : uint) : void
        {
            var g : Graphics = cell.graphics;
            g.beginFill (c);
            g.drawRect (-0.5, -0.5, 1.0, 1.0); 
            g.endFill ();
        }

        public function FlashTest() {
            init();
            
            // catch clicks
            buttonMode = useHandCursor = true;
            stage.addEventListener (MouseEvent.CLICK, onClick);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);

            // 1st time
            onClick (null);
        }
        
        private var _t : uint;
        private var _seeds : Array;
        
        private function onEnterFrame(e : Event) : void
        {
            if(_t < N){
                _seeds = boo(_seeds);
            }
            bmd.colorTransform(bmd.rect, new ColorTransform(0.99, 0.99, 0.99));
//            bmd.applyFilter(bmd, bmd.rect, new Point(), new BlurFilter(6, 6));
            
            _t++;
        }

        private function onClick (e:MouseEvent):void {
            bmd.fillRect(bmd.rect, 0x000000);
            _t = 0;
            
            // now is the time...
//            boo (new Point (250, 250), 100);
            var s : Seed = new Seed(250, 250, R);
            _seeds = boo([s]);
        }
    }
}

class Seed
{
    public var x : Number;
    public var y : Number;
    public var v : Number;
    
    public function Seed(x : Number, y : Number, v : Number)
    {
        this.x = x;
        this.y = y;
        this.v = v;
    }
}