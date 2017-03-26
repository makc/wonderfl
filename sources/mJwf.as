package  
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    
    /**
     * [企画]皆で動くパズル作ろうぜ
     * http://wonderfl.net/c/yb0z
     * 前から気になってた事があって、Wonderfl は色んな作品があるけど作品同士のつながりがないのが気になっていた。
     * 例えば、パーツだけ作って読み込んでロードするだけで使える[素材]を作るとか。
     * あと Fork することで何かに参加できるようにすればもっと面白い事になって行きそうなきがする。
     * チェックメイトやJAMのような方法ではなく、Forkされたもの全てが一つの作品を作るというか。
     * これからもチェックメイトやJAM以外にも[企画]タグや[素材]タグが増えていくといいなぁ。
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0x000000", frameRate = "60", width = "465", height = "465")]
    public class MoviePuzzle extends Sprite 
    {
        private static const BG_COLOR: uint = 0x000000;
        private static const FRAME_RATE: uint = 30;
        
        public function MoviePuzzle() 
        {
            // ローダーで読み込まれなかった時の為のデモ用
            addEventListener(Event.ADDED_TO_STAGE, demo);
        }
        
        /**
         * 
         * MoviePuzzle -> MovieJigsawPuzzle
         *         obj["disp"]      : DisplayObject : 描画対象このオブジェクトの440x440の範囲で切り取られて描画されます。
         *         obj["color"]     : uint : 背景色(省略時は0x000000)
         *         obj["frameRate"] : uint : フレームレート(省略時は60)
         *         obj["level"]     : uint : 上限レベル(省略時は1)
         * @param    obj : <Object>
         */
        public function initialize(obj: Object): void
        {
            disp = new MooPuzzle();
            obj["disp"]  = disp;
            obj["color"] = BG_COLOR;
            obj["frameRate"]  = FRAME_RATE;
        }
        
        /**
         * スタートする時に呼ばれます。
         * @param    level : uint : 指定レベル : 変える必要があれば。
         */
        public function start(level: uint): void
        {
            Object(disp).start(level);
        }
        
        /**
         * 終了した時に呼ばれます。
         */
        public function end(): void
        {
            Object(disp).end();
        }
        
        private var disp: DisplayObject;
        
        /**
         * デモ用
         * @param    e
         */
        private function demo(e: Event): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, demo);
            //
            var obj: Object = {};
            initialize(obj);
            disp = obj["disp"];
            var col: uint = obj["color"];
            var bmd: BitmapData = new BitmapData(440, 440, false, col);
            var bmp: Bitmap = new Bitmap(bmd, "auto", true);
            start(1);
            addChild(bmp);
            addEventListener(Event.ENTER_FRAME, function(e: Event): void {
                bmd.lock();
                bmd.fillRect(bmd.rect, col);
                bmd.draw(disp);
                bmd.unlock();
            } );
        }
    }
}
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.utils.getTimer;

/**
 * かんたんそうなのを探してこちらをお借りしました。
 * @see http://wonderfl.net/c/rR6A
 */
class MooPuzzle extends Bitmap
{
    private var _level: uint;
    private var isStart: Boolean;
    private var canvas: BitmapData;
    private var colorTf: ColorTransform = new ColorTransform(1, 1, 1, 1, -50, -35, -15);
    function MooPuzzle() 
    {
        super(canvas = new BitmapData(440, 440, false, 0));
    }
    
    public function start(level: uint): void
    {
        if (isStart) return;
        isStart = true;
        _level = level;
        addEventListener(Event.ENTER_FRAME, loop);
    }
    
    private function loop(e: Event): void 
    {
        var a: Number = Math.sin(getTimer() / 1000000) * 1000000, i: int, r: Number = 0;
        canvas.lock();
        canvas.colorTransform(canvas.rect, colorTf);
        for (i = 0; i < 10000; i++) 
        {
            r = 120 + 40 * Math.sin( a / 1000 ) * Math.sin( i / 40 + Math.sin(a / 500) * 1.5 ) + 
                100 * Math.sin( i * 2 * Math.cos(a / 1500000) + a / 10000 );
            canvas.setPixel(220 + r * Math.sin(i / 160), 220 + r * Math.cos(i / 160), 0xffffff);
        }
        canvas.unlock();
    }
    
    public function end(): void
    {
        removeEventListener(Event.ENTER_FRAME, loop);
        isStart = false;
    }
}