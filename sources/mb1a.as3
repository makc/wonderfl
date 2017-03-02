package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Utils3D;
    import flash.geom.Vector3D;
    import flash.media.Sound;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    
    /**
     * @author Yukiya Okuda
     * http://alumican.net/
     */
    [SWF(backgroundColor="#000000", frameRate="30", width="465", height="465")]
    public class Main extends Sprite
    {
        private const PREFIX:String = "http://asset.alumican.net/autodesk123dcatch/";
        private const FILE_FBX:String = PREFIX + "bouze3d.fbx";
        private const FILE_BGM:String = PREFIX + "HouseOfCards_DataSample.mp3";
        
        private var _vi:Vector.<Number>;
        private var _vo:Vector.<Number>;
        private var _uvts:Vector.<Number>;
        private var _canvas:BitmapData;
        private var _bmp:Bitmap;
        private var _trans:ColorTransform;
        private var _blur:BlurFilter;
        private var _zero:Point;
        private var _zeros:Vector.<Number>;
        private var _rx:Number;
        private var _ry:Number;
        private var _sound:Sound;
        private var _spec:ByteArray;
        private var _specs:Vector.<Number>;
        private var _init:int;
        private var _tscale:Number;
        private var _scale:Number;
        private var _boost:Boolean;
        
        public function Main():void
        {
            _init = 0;
            Wonderfl.disable_capture();
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            var loader:URLLoader = new URLLoader(new URLRequest(FILE_FBX));
            loader.addEventListener(Event.COMPLETE, _loaderCompleteHandler);
            _sound = new Sound();
            _sound.addEventListener(Event.COMPLETE, _soundCompleteHandler);
            _sound.load(new URLRequest(FILE_BGM));
        }
        
        private function _soundCompleteHandler(e:Event):void 
        {
            _spec = new ByteArray();
            _specs = new Vector.<Number>(512);
            _zeros = new Vector.<Number>(_specs.length);
            for (var i:int = 0; i < _specs.length; ++i) _zeros;
            if (++_init == 2) _start();
        }
        
        private function _loaderCompleteHandler(e:Event):void 
        {
            var data:String = URLLoader(e.target).data;
            data.replace(/Geometry::.*?Vertices.*?{.*?a.*?:(.*?)}/ims, function(matched:String, capture:String, index:int, source:String):String {
                var ary:Array = capture.replace(/\s/igms, "").split(",");
                var n:int = ary.length;
                for (var i:int = 0; i < n; ++i) ary[i] = parseFloat(ary[i]);
                _initVert(ary);
                return "";
            } );
        }
        
        private function _initVert(ary:Array):void 
        {
            var i:int;
            _vi = new Vector.<Number>();
            var n:int = ary.length / 3;
            for (i = 0; i < n; ++i)
            {
                _vi.push(ary[i * 3]);
                _vi.push(-ary[i * 3 + 2]);
                _vi.push(-ary[i * 3 + 1]);
            }
            var indices:Array = new Array(n);
            for (i = 0; i < n; ++i) indices[i] = i;
            indices = indices.sort(function():int { return int(Math.random() * 3) - 1 } );
            var vi2:Vector.<Number> = _vi.concat();
            for (i = 0; i < n; ++i)
            {
                _vi[i * 3] = vi2[indices[i] * 3];
                _vi[i * 3 + 1] = vi2[indices[i] * 3 + 1];
                _vi[i * 3 + 2] = vi2[indices[i] * 3 + 2];
            }
            _vo = new Vector.<Number>(_vi.length / 3 * 2);
            _uvts = new Vector.<Number>(_vi.length);
            _rx = _ry = 0;
            _tscale = _scale = 10;
            _zero = new Point();
            _blur = new BlurFilter(4, 4);
            _trans = new ColorTransform(1, 1, 1, 0.95);
            _bmp = Bitmap(addChild(new Bitmap(_canvas = new BitmapData(465, 465, true, 0x0))));
            if (++_init == 2) _start();
        }
        
        private function _start():void 
        {
            _sound.play(0, int.MAX_VALUE);
            var trans:SoundTransform = SoundMixer.soundTransform;
            trans.volume = 0.5;
            SoundMixer.soundTransform = trans;
            addEventListener(Event.ENTER_FRAME, _enterFrameHandler);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, _mouseWheelHandler);
            stage.addEventListener(Event.RESIZE, _resizeHandler);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler);
            _resizeHandler();
        }
        
        private function _mouseDownHandler(e:MouseEvent):void 
        {
            _boost = true;
        }
        
        private function _mouseUpHandler(e:MouseEvent):void 
        {
            _boost = false;
        }
        
        private function _resizeHandler(e:Event = null):void 
        {
            opaqueBackground = 0x0;
            _bmp.width = stage.stageWidth;
            _bmp.height = stage.stageHeight;
        }
        
        private function _mouseWheelHandler(e:MouseEvent):void 
        {
            if (e.delta == 0) return;
            _tscale += e.delta > 0 ? 1 : -1;
            _tscale = Math.min(20, Math.max(3, _tscale));
        }
        
        private function _enterFrameHandler(e:Event):void
        {
            var i:int;
            try { SoundMixer.computeSpectrum(_spec, false); } catch (e:Error) { _specs = _zeros; }
            if (_spec.bytesAvailable > 0)
            {
                var ss:Number = _boost ? 6 : 4;
                var s:Number;
                for (i = 0; i < 512; ++i)
                {
                    s = _spec.readFloat();
                    s *= ss;
                    if (s > 1) s = 1;
                    _specs[i] = s;
                }
            }
            _scale += (_tscale - _scale) * 0.2;
            _ry += (85 * (mouseX - stage.stageWidth * 0.5) / (stage.stageWidth * 0.5) - _ry) * 0.1;
            _rx += (85 * (mouseY - stage.stageHeight * 0.5) / (stage.stageHeight * 0.5) - _rx) * 0.1;
            var mat:Matrix3D = new Matrix3D();
            mat.appendScale(_scale, _scale, _scale);
            mat.appendRotation(_rx, Vector3D.X_AXIS);
            mat.appendRotation( -_ry, Vector3D.Y_AXIS);
            Utils3D.projectVectors(mat, _vi, _vo, _uvts);
            _canvas.colorTransform(_canvas.rect, _trans);
            _canvas.applyFilter(_canvas, _canvas.rect, _zero, _blur);
            var n:int = _vo.length;
            var a:Number;
            var b0:int;
            var b1:int;
            var amin:Number = _boost ? 0.5 : 0.15;
            if (_boost)
            {
                for (i = 0; i < n; i += 2)
                {
                    a = _specs[int(511 * i / n)];
                    if (a < amin) a = amin;
                    b0 = int(a * 0xff);
                    b1 = int(a * 0x33);
                    _canvas.setPixel32(
                        180 + _vo[i],
                        210 + _vo[i + 1],
                        (b0 << 24) | 0xff0000 | (b1 << 8) | b1
                    );
                }
            }
            else
            {
                for (i = 0; i < n; i += 2)
                {
                    a = _specs[int(511 * i / n)];
                    if (a < amin) a = amin;
                    b0 = int(a * 0xff);
                    b1 = int(a * 0x66);
                    _canvas.setPixel32(
                        180 + _vo[i],
                        210 + _vo[i + 1],
                        (b0 << 24) | (b1 << 16) | (b1 << 8) | 0xff
                    );
                }
            }
        }
    }
}