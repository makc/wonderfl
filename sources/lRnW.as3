package 
{
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.InterpolationMethod;
    import flash.display.SpreadMethod;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
   
    /**
     * マーチングアント
     * マーチングバンドじゃないよ。
     * @author jc at bk-zen.com
     */
    public class MATest extends Sprite
    {
        private var startX: Number;
        private var startY: Number;
        private var maWidth: Number;
        private var maHeight: Number;
        private const MA_COLORS: Array = [0x0000000, 0xFFFFFF];
        private const MA_ALPHAS: Array = [100, 100];
        private const MA_SIZE: int = 5;
        private var maColors: Array;
        private var maAlphas: Array;
        private var maMatrix: Matrix;
        private var maRatios: Array;
       
        public function MATest()
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
       
        private function init(e: Event = null): void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            //
            maMatrix = new Matrix();
            maRatios = [];
            maColors = [];
            maAlphas = [];
            var n: int = MA_COLORS.length, j: int;
            for (var i: int = 0; i < n; i++)
            {
                maRatios.push(int(0xFF / n * i));
                maRatios.push(int((0xFF / n * (i + 1)) - 1));
                maColors.push(MA_COLORS[i]);
                maColors.push(MA_COLORS[i]);
                maAlphas.push(MA_ALPHAS[i]);
                maAlphas.push(MA_ALPHAS[i]);
            }
            trace(maRatios);
            trace(maColors);
            trace(maAlphas);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
        }
       
        private function onMove(e: MouseEvent ): void
        {
            var g: Graphics = graphics;
            g.clear();
            g.lineStyle(1);
            g.lineGradientStyle(GradientType.LINEAR, maColors, maAlphas, maRatios, maMatrix, SpreadMethod.REPEAT, InterpolationMethod.LINEAR_RGB);
            g.drawRect(startX, startY, (maWidth = stage.mouseX - startX), (maHeight = stage.mouseY - startY));
            g.endFill();
        }
       
        private function onDown(e: MouseEvent ): void
        {
            startX = stage.mouseX;
            startY = stage.mouseY;
            maWidth = maHeight = 0;
            maMatrix.createGradientBox(MA_SIZE, MA_SIZE, 2.356195, startX, startY);
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
            removeEventListener(Event.ENTER_FRAME, onEnter);
        }
       
        private function onUp(e: MouseEvent): void
        {
            stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
            addEventListener(Event.ENTER_FRAME, onEnter);
        }
       
        private function onEnter(e: Event ): void
        {
            var g: Graphics = graphics;
            g.clear();
            g.lineStyle(1);
            g.lineGradientStyle(GradientType.LINEAR, maColors, maAlphas, maRatios, maMatrix, SpreadMethod.REPEAT, InterpolationMethod.LINEAR_RGB);
            g.drawRect(startX, startY, maWidth, maHeight);
            g.endFill();
            maMatrix.tx -= 0.5;
        }
       
    }

}