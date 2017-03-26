package  {
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    /**
     * old school demo effects: http://iquilezles.org/www/articles/deform/deform.htm
     * @author Devon O.
     */

    [SWF(width='465', height='465', backgroundColor='#000000', frameRate='31')]
    public class OldSkool extends Sprite {
        
        private var _input:BitmapData;
        private var _output:BitmapData;
        
        private var _lookUpTable:Vector.<uint> = new Vector.<uint>();
        private var _xres:int;
        private var _yres:int;
        private var _inputVector:Vector.<uint>;
        
        private var _time:Number = 0.0;
        
        private var _effect:int = 0;
        
        public function OldSkool() {
            if (stage) loadImage();
            else addEventListener(Event.ADDED_TO_STAGE, loadImage);
        }
        
        private function loadImage(event:Event = null):void {
            var l:Loader = new Loader();
            l.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoad);
            l.load(new URLRequest("http://assets.wonderfl.net/images/related_images/6/68/68ef/68efcb70438fb102c11265efe3fd1a737160999c"), new LoaderContext(true));
        }
        
        private function onImageLoad(event:Event):void {
            var l:Loader = event.currentTarget.loader;
            _input = (l.content as Bitmap).bitmapData;
            
            init();
        }
        
        private function init():void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            _xres = 128;
            _yres = 128;
            
            _output = new BitmapData(_xres, _yres, false, 0x000000);
            var bmp:Bitmap = new Bitmap(_output, PixelSnapping.AUTO, true);
            bmp.width = bmp.height = stage.stageHeight;
            addChild(bmp);
            
            createLUT();
            
            addEventListener(Event.ENTER_FRAME, frameHandler);
            
            stage.addEventListener(MouseEvent.CLICK, onClick);
        }
        
        private function onClick(event:MouseEvent):void {
            if (++_effect > 8) _effect = 0;
            createLUT();
        }
        
        private function frameHandler(event:Event):void {
            renderDeformation(_time);
            _time += .5;
        }
        
        private function renderDeformation(t:Number):void {
            _inputVector = _input.getVector(_input.rect);
            var outputVector:Vector.<uint> = new Vector.<uint>();
            var len:uint = _xres * _yres;

            var itime:int = int(10.0 * t);
            
            _output.lock();
            for( var j:int = 0; j < _yres; j++ ) {
                for ( var i:int = 0; i < _xres; i++ ) {            
                    var o:int = _xres * j + i;
                    var u:uint = _lookUpTable[ 2 * o + 0 ] + itime;
                    var v:uint = _lookUpTable[ 2 * o + 1 ] + itime;
                    outputVector[_xres * j + i] = _inputVector[512 * (v & 511) + (u & 511)];
                }
            }
            _output.setVector(_output.rect, outputVector);
            _output.unlock();
        }
        
        private function createLUT():void {
            
            var k:int = 0;
            for (var j:int = 0; j < _yres; j++) {
                for (var i:int = 0; i < _xres; i++) {
                    var xx:Number = -1.0 + 2.0 * i / _xres;
                    var yy:Number = -1.0 + 2.0 * j / _yres;
                    var d:Number = Math.sqrt(xx * xx + yy * yy);
                    var a:Number = Math.atan2(yy, xx);
                    var r:Number = 1; // 0 - 1 seems best
                    
                    //**********************************************
                    // MAGIC FORMULAS!
                    var u:Number;
                    var v:Number;
                    switch(_effect) {
                        case 0 :
                            u = Math.cos( a ) / d;
                            v = Math.sin( a ) / d ;
                            break;
                        case 1 :
                            u = xx * Math.cos(2 * r) - yy * Math.sin(2 * r);
                            v = yy * Math.cos(2 * r) + xx * Math.sin(2 * r);
                            break;
                        case 2 :
                            u = 0.5 * a / Math.PI;
                            v = Math.sin(7 * r);
                            break;
                        case 3 :
                            u = 0.3 / (r + 0.5 * xx);
                            v = 3.0 * a / Math.PI;
                            break;
                        case 4 :
                            u = r * Math.cos(a + r);
                            v = r * Math.sin(a + r);
                            break;
                        case 5 :
                            u = .02 * yy + .03 * Math.cos(a * 3) / r;
                            v = .02 * xx + .03 * Math.sin(a * 3) / r;
                            break;
                        case 6 :
                            u = 1 / (r + 0.5 + 0.5 * Math.sin(5 * a));
                            v = a * 3 / Math.PI;
                            break;
                        case 7 :
                            u = .1 * xx / (.11 + r * .5);
                            v = .1 * yy / (.11 + r * .5);
                            break;
                        case 8 :
                        default :
                            u = xx / (yy);
                            v = 1 / (yy);
                    }
                    //**********************************************
                    
                    _lookUpTable[k++] = uint(512.0 * u) & 511;
                    _lookUpTable[k++] = uint(512.0 * v) & 511;
                }
            }
        }
    }
}