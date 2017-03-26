// forked from devon_o's Old Skool
//**********************************************************************************
//Old school demo effects [Optimised]
//Did some optimisation there,
//Fast integer maths gained around 30% cpu,
//Vector calls with uint casting then gained around 50% cpu,
//enabling the jump from 128 to 256 resolution in 60fps easily (ok, on my little mac)
//**update: more optimisation enabling to jump from 256 to 512 resolution @~60fps with fast math integer (again) instead of using _xres
//**update: uint casting now done with >>0
//ensured stable @60 fps with pixel snapping off.
//Added around 40 more "magic" equations
//Click on stage to loop through them
//thx @devon_o
//@Hasufel 2010
//**********************************************************************************/
package  {
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    //import flash.display.PixelSnapping;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import net.hires.debug.Stats;
    
    /**
     * old school demo effects: http://iquilezles.org/www/articles/deform/deform.htm
     * @author Devon O.
     * @optimisation Hasufel
     */

    [SWF(width='465', height='465', backgroundColor='#000000', frameRate='60')]
    public class OldSkool extends Sprite {
        private static const _rect:Rectangle = new Rectangle(0,0,512,512);
        private const _xres:uint = 512;//256//128
        private const _yres:uint = 512;//256//128
        private var _input:BitmapData;
        private var _output:BitmapData;        
        private var _lookUpTable:Vector.<uint> = new Vector.<uint>();
        private var _inputVector:Vector.<uint> = new Vector.<uint>();
        private var _time:uint = 0;
        private var _effect:int = 0;
        private var _maxEffects:int = 51; //you should add more, your imagination is the limit!
        private var _outputVector:Vector.<uint> = new Vector.<uint>();
        
        public function OldSkool() {
            if (stage) loadImage();
            else addEventListener(Event.ADDED_TO_STAGE, loadImage);
        }
        
        private function loadImage(event:Event = null):void {
            var l:Loader = new Loader();
            l.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoad);
            l.load(new URLRequest("http://assets.wonderfl.net/images/related_images/d/da/da78/da78a4737f4c266442240a6a37b866116a75cb1b"), new LoaderContext(true));
        }
        
        private function onImageLoad(event:Event):void {
            var l:Loader = event.currentTarget.loader;
            _input = (l.content as Bitmap).bitmapData;
            _inputVector = _input.getVector(_rect);
           init();
        }
        
        private function init():void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            _output = new BitmapData(_xres, _yres, false, 0x000000);
            var bmp:Bitmap = new Bitmap(_output);//, PixelSnapping.AUTO, true);
            bmp.width = bmp.height = stage.stageHeight;
            addChild(bmp);
            addChild(new Stats());
            createLUT();
            addEventListener(Event.ENTER_FRAME, frameHandler);
            stage.addEventListener(MouseEvent.CLICK, onClick);
        }
        
        private function onClick(e:MouseEvent):void {
            if (++_effect > _maxEffects) _effect = 0;
            createLUT();
        }
        
        private function frameHandler(e:Event):void {
            renderDeformation();
            _time += 5;
        }
         
        private function renderDeformation():void {
            for(var j:uint=0; j < _yres; ++j) {
                for (var i:uint = 0; i < _xres; ++i) {            
                    var o:uint = ((j<<9) + i)>>0;//uint((j<<9) + i);//_xres * j +i; //lets stick to 512 (<<9) for now
                    var u:uint = _lookUpTable[(o<<1)>>0] + _time;//uint(o<<1)] + _time; //cast
                    var v:uint = _lookUpTable[((o<<1)+1)>>0] + _time;//uint((o<<1) + 1)] + _time;//cast
                _outputVector[((j<<9) + i)>>0] = _inputVector[(((v & 511) <<9) + (u & 511))>>0];// _outputVector[uint((j<<9) + i)] = _inputVector[uint(((v & 511)<<9) + (u & 511))]; //never forget casting!
                }
            }
            _output.lock();
            _output.setVector(_rect, _outputVector);
            _output.unlock();
        }                 
        
        private function createLUT():void {
            var k:uint = 0;
            for (var j:int = 0; j < _yres; ++j) {
                for (var i:int = 0; i < _xres; ++i) {
                    var xx:Number = -1.0 + 2.0 * i / _xres;
                    var yy:Number = -1.0 + 2.0 * j / _yres;
                    var d:Number = Math.sqrt(xx * xx + yy * yy);
                    var a:Number = Math.atan2(yy, xx);
                    var r:Number = 1;
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
                            u = .5 * a / Math.PI;
                            v = Math.sin(7 * r);
                            break;
                        case 3 :
                            u = .3 / (r + 0.5 * xx);
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
                            u = 1 / (r + .5 + .5 * Math.sin(5 * a));
                            v = a * 3 / Math.PI;
                            break;
                        case 7 :
                            u = .1 * xx / (.11 + r * .5);
                            v = .1 * yy / (.11 + r * .5);
                            break;
                        case 8 :
                            u = .2 / Math.abs(yy);
                            v = .2 * xx / Math.abs(yy);
                            break;
                        case 9 :
                            u = Math.abs(Math.cos(1.5 * a)/r);
                            v = .2 +.5 * Math.abs(Math.cos(1.5 * a)/r);
                            break;
                        case 10 :
                            u = .3 / (xx*xx-yy);

                            v = 1 -.1 * (Math.abs(xx) + Math.abs(1/(xx*xx-yy)));
                            break;
                        case 11 :
                            u = Math.pow(yy,2);
                            v = Math.pow(xx,2);

                        break;
                        case 12 :
                            u = Math.pow(yy,3);
                            v = Math.pow(xx,2);

                        break;
                        case 13 :
                            u = Math.sin(yy);
                            v = Math.cos(xx);

                        break;
                        case 14 :
                            u = r;
                            v = .2 + .8 * (1.2+ .6 * Math.sin(13 * a))/r;

                        break;
                        case 15 :
                            u = .2 * xx / Math.abs(yy);
                            v = Math.pow(xx,2);

                        break;
                        case 16 :
                            u = .2 * xx / Math.sin(yy);
                            v = .2 * xx / Math.sin(yy);

                        break;
                        case 17 :
                            u = .2 * xx / Math.sin(yy);
                            v = .2 * yy / Math.cos(xx);

                        break;
                        case 18 :
                            u = .2 * xx / Math.tan(yy);
                            v = .2 * yy / Math.cos(yy);

                        break;
                        case 19 :
                            u = xx / Math.tan(yy) * d;
                            v = yy / Math.cos(yy) * d;

                        break;
                        case 20 :
                            u = r * xx / Math.tan(yy) * d * Math.sin(a);
                            v = yy / Math.cos(yy) * d * Math.tan(a);

                        break;
                        case 21 :
                            u = Math.pow(xx,2) * Math.sin(r) * .2 * Math.cos(d);
                            v = Math.pow(yy,2) * Math.cos(r) * .2 * Math.sin(d);

                        break;
                        case 22 :
                            u = a * (3 * Math.cos(d) - Math.cos(3 * d));
                            v = a * (3 * Math.sin(d) - Math.sin(3 * d));

                        break;
                        case 23 :
                            u = Math.pow(a,2);
                            v = Math.pow(d,2);

                        break;
                        case 24 :
                            u = Math.pow(r,2);
                            v = Math.pow(d,2);

                        break;
                        case 25 :
                            u = Math.pow((a + xx),2);
                            v = Math.pow((3*a - yy),2);

                        break;
                        case 26 :
                            u = xx * Math.cos(3) * d;
                            v = yy * Math.sin(3) * d;

                        break;
                        case 27 :
                            u = xx * Math.cos(d);
                            v = yy * Math.sin(d);

                        break;
                        case 28 :
                            u = Math.pow(Math.pow(a,2) - Math.pow(xx,2),2);
                            v = Math.pow((Math.pow(xx,2) + (2 * a * yy) - Math.pow(a,2)),2);

                        break;
                        case 29 :
                            u = xx * d - r * Math.sin(d);
                            v = yy * d - r * Math.cos(d);
                        break;
                        case 30 :
                            u = (a + xx) * Math.cos(d) - yy* Math.cos((a/xx + 1) * d);
                            v = (a + yy) * Math.sin(d) - xx* Math.sin((a/yy + 1) * d);
                        break;
                        case 31 :
                            u = Math.sqrt(d * Math.PI) * xx;
                            v = Math.sqrt(r * Math.PI) * yy;
                        break;
                        case 32 :
                            u = xx * (Math.cos(d) + r * Math.sin(d));
                            v = yy * (Math.sin(d) + r * Math.cos(d));
                        break;
                        case 33 :
                            u = r * (Math.cos(xx) + r * Math.sin(a));
                            v = r * (Math.sin(yy) + r * Math.cos(a));
                        break;
                        case 34 :
                            u = Math.pow((Math.pow(xx,2) + Math.pow(yy,2) - 2 * a * xx),2);
                            v = d * (Math.pow(xx,2) + Math.pow(yy,2));
                        break;
                        case 36 :
                            u = Math.sin(r) * Math.pow(yy,2) + d * yy;
                            v = Math.cos(r) * Math.pow(xx,2) + d * xx;
                        break;
                        case 37 :
                            u = Math.cos( a ) / d;
                            v = Math.sin( a ) / d * xx;
                        break;
                        case 38 :
                            u = Math.cos( a ) / d - yy;
                            v = Math.sin( a ) / d * xx;
                        break;
                        case 39 :
                            u = Math.cos( a ) / d - yy;
                            v = Math.sin( a ) / d - xx;
                        break;
                        case 40 :
                            u = Math.cos( a ) / d * Math.cos(a)*.2;
                            v = Math.sin( a ) / d * Math.sin(a)*.2;
                        break;
                        case 41 :
                            u = Math.cos( a ) / d * Math.tan(a)*.2;
                            v = Math.sin( a ) / d * Math.cos(a)*.2;
                        break;
                        case 42 :
                            u = .1 / yy;
                            v = .1 * xx / Math.abs(yy);
                        break;
                        case 43 :
                            u = Math.PI * .1 / Math.abs(yy) + Math.pow(d * Math.PI,2);
                            v = .1 * xx / Math.abs(yy);
                        break;
                        case 44 :
                            u = .1 / (Math.abs(yy) + Math.pow(d * Math.PI,2));
                            v = .1 * xx / Math.abs(yy);
                        break;
                        case 45 :
                            u = Math.cos( a ) / d;
                            v = 10 * yy / Math.pow(Math.abs(d) * Math.PI, xx * yy * d);
                        break;
                        case 46 :
                            u = 10 * a / Math.PI;
                            v = .1 * yy / (Math.abs(d) * Math.PI,xx * yy * d);
                        break;
                        case 47 :
                            u = 50 * Math.pow(d, Math.PI);
                            v = 50 * Math.pow(d, Math.PI);
                        break;
                        case 48 :
                            u = 500 * Math.pow(d, Math.PI);
                            v = 50 * Math.pow(d, Math.PI);
                        break;
                        case 49 :
                            u = 500 * Math.pow(d, Math.PI);
                            v = 50 * Math.pow(r, Math.PI);
                        break;
                        case 50 :
                            u = 500 * Math.pow(d, Math.PI);
                            v = Math.sin( r ) * a;
                        break;
                        default :
                            u = xx / (yy);
                            v = 1 / (yy);
                    }
                    _lookUpTable[(k++)>>0] = (512.0 * u)>>0 & 511;//_lookUpTable[uint(k++)] = uint(512.0 * u) & 511;
                    _lookUpTable[(k++)>>0] = (512.0 * v)>>0 & 511;//_lookUpTable[uint(k++)] = uint(512.0 * v) & 511;
                }
            }
        }
    }
}