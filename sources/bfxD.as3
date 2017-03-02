package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.utils.*;
    
    import net.hires.debug.Stats;
    public class FlashTest extends Sprite {
        
        private static const SIZE:int = 256;
        private static const EPSILON:Number = Math.PI / SIZE;
        private static const QUAD:ColorTransform = new ColorTransform(0, 3. / SIZE, 0);
        
        private var sf:ShaderFilter = new ShaderFilter(new Shader(ba(169, [-1593769472,810831,1970553711,1869767680,-1560279949,1919090849,33816832,258241396,10551555,33558121,1901312,-1056833376,197376,-1056964608,852736,-2147287040,787200,1073938496,1901312,537001984,1901312,268435520,131840,822214736,1900800,-1056767984,196864,-1056767840,3277056,549421056,196864,537067584,1900800,268632064,196864,822280432,65792,-1056898896,65792,-1056833456,3145984,-251592688,0])));
        private var src:BitmapData = new BitmapData(SIZE, SIZE, false, 0x000000);
        private var dst:BitmapData = new BitmapData(SIZE, SIZE, false, 0x000000);
        private var acc:BitmapData = new BitmapData(SIZE, SIZE, false, 0x000000);
        private var line:Shape = new Shape();
        
        private static function ba(l:int, d:Array):ByteArray {
            var r:ByteArray = new ByteArray();
            for each (var w:int in d)
                r.writeInt(w);
            r.length = l;
            return r;
        }
        
        public function FlashTest() {
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(e:UncaughtErrorEvent):void { trace(e.error) });
            
            addChild(new Stats()).y = SIZE;
            
            addChild(new Bitmap(acc));
            
            var shape:Shape = new Shape();
            shape.graphics.lineStyle(4, 0xffffff);
            for (var i:int = 0; i < 5; i++) {
                shape.graphics.moveTo(Math.random() * SIZE, Math.random() * SIZE);
                shape.graphics.lineTo(Math.random() * SIZE, Math.random() * SIZE);
            }
            src.draw(shape);
            with (addChild(new Bitmap(src))) { alpha = 0.5; blendMode = BlendMode.ADD;  }
            
            line.graphics.lineStyle(0, 0xff00ff);
            line.graphics.moveTo(-SIZE, 0);
            line.graphics.lineTo(SIZE, 0);
            addChild(line);
            
            stage.addEventListener(Event.ENTER_FRAME, step);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, ref);
        }
        
        private var current:int = 0;
        private function step(e:Event=null):void {
            if (current >= SIZE) {
                stage.removeEventListener(Event.ENTER_FRAME, step);
                return;
            }
            var t:int = getTimer();
            sf.shader.data.i.value = [current++, SIZE / 2, EPSILON];
            dst.applyFilter(src, src.rect, new Point(), sf);
            acc.draw(dst, null, QUAD, BlendMode.ADD);
            trace(getTimer() - t);
        }
        
        private function ref(e:MouseEvent):void {
            var m:Matrix = line.transform.matrix;
            m.identity();
            m.translate(0, e.stageY - SIZE / 2);
            m.rotate(EPSILON * e.stageX);
            m.translate(SIZE / 2, SIZE / 2);
            line.transform.matrix = m;
        }
        
    }
}
/*
parameter "_OutCoord", float2, f0.rg, in
texture "src", t0
parameter "dst", float4, f1, out
parameter "i", float3, f2.rgb, in

; compute trig value
mov f3.rg, f2.bb
mul f3.rg, f0.rr
;mul f3.rg, f2.rr
cos f3.r, f3.r
sin f3.g, f3.g

; get offsets
mov f3.b, f2.r
;mov f3.b, f0.r
mov f3.a, f0.g
sub f3.ba, f2.gg

; compute component 1
mov f1.rg, f3.rg
mul f1.rg, f3.bb

; compute component 2
set f1.b, -1
mul f1.b, f3.g
mov f1.a, f3.r
mul f1.ba, f3.aa

; compute location and sample
add f1.rg, f1.ba
add f1.rg, f2.gg
texn f1, f1.rg, t0
*/