
// BradSedito 2011
// Just add cereal. =)


package {
[SWF(width=465,height=465,backgroundColor=0xffffff,frameRate=30)]
        
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.BlurFilter;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.ConvolutionFilter;
    import flash.geom.Matrix;
    import flash.display.BlendMode;
    import flash.geom.Point;

    public class rippleComponent extends Sprite {
        
        private static const SCALE:Number = 1;     
        private static const ZERO_POINT:Point = new Point(0, 0);
        private static const ZERO_ARRAY:Array = new Array(256);       
        private var _target:Sprite;
        private var _square:Shape;
        private var _canvas:BitmapData;
        private var _final:BitmapData;
        private var _drawMtx:Matrix;
        private var _filters:Array;
        private var _emboss:BitmapFilter;
        private var _waveMap:Array;
        private var _phongMap:Array;
        
        public function rippleComponent() {
            this._canvas = new BitmapData(stage.stageWidth / SCALE, stage.stageHeight / SCALE, false, 0x0);
            this._final = this._canvas.clone();
            var bm:Bitmap = this.addChild(new Bitmap(this._final)) as Bitmap;
            bm.scaleX = bm.scaleY = SCALE;
            this._target = new Sprite();
            var sh:Shape = this._target.addChild(new Shape()) as Shape;
            var g:Graphics = sh.graphics;
            g.beginFill(0xffffff);
            g.drawEllipse(-50, -50, 100, 100);
            g.endFill();
            sh.x = 320;
            sh.y = 240;
          //  sh.alpha = .6;
            this._square = sh;
            this._drawMtx = new Matrix(1 / SCALE, 0, 0, 1 / SCALE, 0, 0);
            
            this._filters = [];
            this._filters.push(new BlurFilter(16, 16, BitmapFilterQuality.HIGH));
            var a:Number = 1;
            var b:Number = -0;
            this._filters.push(new ColorMatrixFilter([
                a, 0, 0, 0, b,
                0, a, 0, 0, b,
                0, 0, a, 0, b,
                0, 0, 0, 1, 0
            ]));
            
            this._emboss = new ConvolutionFilter(3, 3, [
                2, 0, 0,
                0, -1, 0,
                0, 0, -1
            ], 3, 0xcc);
            

            this._waveMap = [];
            var n:int = 256;
            var c:int;
            while (n--) {
                c = int((Math.sin(n / 256 * Math.PI * 6) + 1) * 0x22);
                this._waveMap.push((c << 16) | (c << 8) | c);
            }
            
            this._phongMap = this._createPhongMap(0xffffff, 60, 0xffffff, 0x00);
            
            this.stage.addEventListener(Event.ENTER_FRAME, this._update);
        }
        
        private function _createPhongMap(specular:uint = 0xffffff, power:int = 100, diffuse:uint=0xffffff, ambient:uint=0x000000):Array {
            var col:Array = [];
            const sr:int = (specular >> 16) & 0xff;
            const sg:int = (specular >> 8) & 0xff;
            const sb:int = specular & 0xff;
            const dr:int = (diffuse >> 16) & 0xff;
            const dg:int = (diffuse >> 8) & 0xff;
            const db:int = diffuse & 0xff;
            const ar:int = (ambient >> 16) & 0xff;
            const ag:int = (ambient >> 8) & 0xff;
            const ab:int = ambient & 0xff;
            var i:int = 256;
            var ks:Number, kd:Number;
            while (i--) {
                ks = Math.pow(Math.cos(i / 256 * Math.PI / 2), power);
                kd = 1 - (i / 256);
                col.push(
                    (Math.min(0xff, ar + kd * dr + ks * sr) << 16) |
                    (Math.min(0xff, ag + kd * dg + ks * sg) << 8) |
                    (Math.min(0xff, ab + kd * db + ks * sb))
                );
            }
            return col;
        }
        
        private function _update(e:Event):void {
            this._square.x = this.mouseX;
            this._square.y = this.mouseY;
            this._canvas.draw(this._target, this._drawMtx);
            for each(var f:BitmapFilter in this._filters) {
                this._canvas.applyFilter(this._canvas, this._canvas.rect, ZERO_POINT, f);
            }
            this._final.draw(this._canvas);
            this._final.paletteMap(this._final, this._final.rect, ZERO_POINT, this._waveMap, ZERO_ARRAY, ZERO_ARRAY);
            var n:int = 2;    while (n--)    this._waveMap.push(this._waveMap.shift());
            this._final.applyFilter(this._final, this._final.rect, ZERO_POINT, this._emboss);
            this._final.paletteMap(this._final, this._final.rect, ZERO_POINT, this._phongMap, ZERO_ARRAY, ZERO_ARRAY);
        }        
    }    
}
//           g.drawRect(-50, -50, 100, 100);
