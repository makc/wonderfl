package  
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import frocessing.color.ColorBlend;
    import frocessing.color.FColor;
    import frocessing.math.FMath;
    
    /**
     * 激重です。
     * ステージをドラッグで別の形になります。
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0x0", frameRate = "30", width = "465", height = "465")]
    public class Attractor01 extends Sprite
    {
        private var bmd: BitmapData;
        private var isPlay: Boolean = true;
        private var count: int, maxden: int;
        private var a: Number, b: Number, c: Number, d: Number, nx: Number, ny: Number, ox: Number, oy: Number, lmd: Number;
        private var den: Vector.<Vector.<int>> = new Vector.<Vector.<int>>(465, true);
        private var pre: Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(465, true);
        private const sensitivity: Number = 0.0198411;
        private const hueBase: int = 180;
        
        public function Attractor01() 
        {
            Wonderfl.capture_delay( 30 );
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            addChild(new Bitmap(bmd = new BitmapData(465, 465, false, 0x0), "auto", true));
            for (var i:int = 0; i < 465; i++) 
            {
                den[i] = new Vector.<int>(465, true);
                pre[i] = new Vector.<Number>(465, true);
            }
            reparam();
            addEventListener(Event.ENTER_FRAME, loop);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            trace(hueBase);
        }
        
        private function onMouseUp(e: MouseEvent): void 
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            isPlay = true;
            count = 0;
        }
        
        private function onMouseDown(e: MouseEvent): void 
        {
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }
        
        private function onMouseMove(e: MouseEvent): void 
        {
            isPlay = false;
            reparam(mouseX, mouseY);
        }
        
        private function reparam(mx: Number = 0, my: Number = 0): void
        {
            a = FMath.map(mx, 0, 456, -1, 1) * sensitivity;
            b = FMath.map(my, 0, 465, -1, 1) * sensitivity;
            c = FMath.map(mx, 0, 465, 1, -1) * sensitivity;
            d = FMath.map(my, 0, 465, 1, -1) * sensitivity;
            ox = oy = 465 / 2;
            update(true, 1, 100);
        }
        
        private function loop(e: Event): void 
        {
            if (isPlay)
            {
                count++;
                if (count > 255) isPlay = false;
                update(false, 4, 0);
            }
        }
        
        private function update(clear: Boolean, s: int, f: Number): void
        {
            var i: int, j: int, k: int, e: int, h_: Number, s_: Number, v_: Number, le: Number, col: uint;
            if (clear) for (i = 0; i < 465; i++) for (j = 0; j < 465; j++) den[i][j] = pre[i][j] = 0;
            for (i = 0; i < s; i++) { for (j = 0; j < 10000; j++) {
                nx = (((Math.sin(a * oy) - Math.cos(b * ox)) * 93) + 232.5) + Math.random() * 0.002 - 0.001;
                ny = (((Math.sin(c * ox) - Math.cos(d * oy)) * 93) + 232.5) + Math.random() * 0.002 - 0.001;
                if ( (nx > 0) && (nx < 465) && (ny > 0) && (ny < 465) )
                {
                    if ((k = (den[int(nx)][int(ny)] += 1)) > maxden) maxden = k;
                    pre[int(nx)][int(ny)] = ox;
                }
                ox = nx;
                oy = ny;
            }}
            lmd = Math.log(maxden);
            bmd.lock();
            if (clear) bmd.fillRect(bmd.rect, 0x0);
            for (i = 0; i < 465; i++) { for (j = 0; j < 465; j++) {
                if ((e = den[i][j]) > 0) bmd.setPixel(i, j, ColorBlend.soft(FColor.HSVtoValue(hueBase + hueBase * (pre[i][j] / 465), 0.5 - 0.5 * ((le = Math.log(e)) / lmd), (le + f) / lmd), bmd.getPixel(i, j)));
            }}
            bmd.unlock();
        }
    }
}