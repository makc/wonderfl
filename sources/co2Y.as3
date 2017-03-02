package  
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import net.hires.debug.Stats;
    
    /**
     * 久々の朝ワン(∪＾ω＾)ワン
     * 荒波日本海！
     * 岩壁にぶつかって荒々しく唸る日本海的なイメージ。
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0x0", frameRate = "30", width = "465", height = "465")]
    public class Asawon7 extends Sprite
    {
        private var bmd: BitmapData;
        private var forceMap: BitmapData;
        private const PARTICLE_NUM: int = 50000;
        private const WIDTH: int = 465;
        private const HEIGHT: int = 465;
        private var COLOR: uint = 0xFFFFFF;
        private var particle: Particle;
        private var seed: int;
        private var mw: int;
        private var mh: int;
        private var arr: Array;
        private var point: Point;
        private var point2: Point;
        private var basePoint: Point = new Point();
        private var colorTf: ColorTransform;
        private var blur: BlurFilter;
        private var baseMatrix: Matrix;
        
        public function Asawon7() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            //
            addChild(new Bitmap(bmd = new BitmapData(WIDTH, HEIGHT, false, 0x0)));
            var p: Particle, prev: Particle = particle = new Particle();
            forceMap = new BitmapData(WIDTH / 2, HEIGHT / 2);
            forceMap.perlinNoise(mw = forceMap.width >> 2, mh = forceMap.height >> 2, 4, 
                seed = Math.random() * 0xFFFF, false, true, 3);
            arr = [point = new Point(), point2 = new Point()];
            for (var i:int = 0; i < PARTICLE_NUM; i++) 
            {
                p = new Particle();
                p.x = WIDTH * Math.random();
                p.y = HEIGHT * Math.random();
                prev = prev.next = p;
            }
            colorTf = new ColorTransform(1, 1, 1, 1, -8, -2, -1);
            blur = new BlurFilter(2, 2);
            addEventListener(Event.ENTER_FRAME, loop);
            addChild(new Stats());
            mouseChildren = mouseEnabled = false;
            baseMatrix = new Matrix(0.75, 0.31, -0.72, 0.67, 227.05, 10);
        }
        
        private function loop(e: Event): void 
        {
            var p: Particle = particle, col: uint, h: Number;
            point.x ++;
            point2.y ++;
            forceMap.perlinNoise(mw, mh, 4, seed, false, true, 3, false, arr);
            bmd.lock();
            while ((p = p.next) != null)
            {
                col = forceMap.getPixel(p.x >> 1, p.y >> 1);
                p.x += (p.vx = p.vx * 0.98 + (( col >> 16 & 0xff) - 128) * 0.004);
                p.y += (p.vy = p.vy * 0.98 + (( col >>  8 & 0xff) - 128) * 0.004);
                if (p.x < 0) p.x += WIDTH;
                else if (p.x >= WIDTH) p.x -= WIDTH;
                if (p.y < 0) p.y += HEIGHT;
                else if (p.y >= HEIGHT) p.y -= HEIGHT;
                h = p.vx * p.vy * 3;
                h = h < 0 ? h : - h;
                bmd.setPixel(p.x * baseMatrix.a + p.y * baseMatrix.c + baseMatrix.tx, 
                    p.x * baseMatrix.b + p.y * baseMatrix.d + baseMatrix.ty + h, COLOR);
            }
            bmd.applyFilter(bmd, bmd.rect, basePoint, blur);
            bmd.colorTransform(bmd.rect, colorTf);
            bmd.unlock();
        }
        
    }
}

class Particle
{
    public var x: Number = 0;
    public var y: Number = 0;
    public var vx: Number = 0;
    public var vy: Number = 0;
    public var next: Particle;
    
}
