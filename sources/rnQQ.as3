package 
{
    import flash.display.GradientType;
    import flash.display.Shape;
    import flash.geom.Matrix;
    import com.adobe.utils.AGALMiniAssembler;
    import com.adobe.utils.PerspectiveMatrix3D;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DRenderMode;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.textures.Texture;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.FontDescription;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextElement;
    import flash.text.engine.TextLine;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.utils.getTimer;
    /**
     * @author 9re
     */
    [SWF(frameRate="60")]
    public class S1_x_S1_Render_Test extends Sprite
    {
        private static const R0:Number = 5;
        private static const N0:int = 72;
        private static const R1:Number = 1.8;
        private static const N1:int = 64;
        private static const K:int = N0 * N1;
        private var _stage3D:Stage3D;
        private var _context3D:Context3D;
        private var _projection:PerspectiveMatrix3D;
        private var _eye:Vector3D;
        private var _at:Vector3D;
        private var _up:Vector3D;
        private var _textFactory:TextBlock = new TextBlock;
        private var _model:Matrix3D;
        private var _world:Matrix3D;
        private var _width:int;
        private var _height:int;
        private var _indecesBuffer:IndexBuffer3D;
        private var _timer:int = -1;
        private var _elf:ElementFormat = new ElementFormat(new FontDescription('_typewriter'), 12, 0x666666);
        private var _fragmentShaderTF:TextField;
        private var _vertexShaderTF:TextField;
        
        public function S1_x_S1_Render_Test() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(event:Event = null):void {
            if (event) removeEventListener(Event.ADDED_TO_STAGE, init);
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            var label:TextLine = getTextLine('vertex shader');
            var yPos:int = label.height;
            var xPos:int = stage.stageWidth - 200;
            label.x = xPos; label.y = yPos;
            addChild(label);
            yPos += label.height;
            _vertexShaderTF = getInputField(<>
m44 op va0 vc0
mov v0 vc14
mov vt1 vc14
m44 vt0 va0 vc4
m44 vt2 va1 vc4
sub vt3 vt2 vt0
nrm vt1.xyz vt3.xyz
sub vt4 vt0 vc12
nrm vt2.xyz vt4.xyz
dp3 v0.x vt1 vt2
sub vt2 vt0 vc13
nrm vt3.xyz vt2.xyz
dp3 v0.y vt1 vt3
                    </>, xPos, yPos);
            _vertexShaderTF.height = 300;
            yPos += _vertexShaderTF.height + 10;
            label = getTextLine('fragment shader');
            label.x = xPos; label.y = yPos;
            yPos += label.height;
            addChild(label);
            
            _fragmentShaderTF = getInputField(<>
<![CDATA[sub ft0 fc0 v0
abs ft1 ft0
tex ft0 ft1 fs0 <2d,clamp,linear>
mov oc ft0]]>
                    </>, xPos, yPos);
            _fragmentShaderTF.height = 100;
            yPos += _fragmentShaderTF.height + 10;
            var sp:Sprite = new Sprite;
            sp.addChild(getTextLine('update shader'));
            var rect:Rectangle = sp.getBounds(sp);
            sp.y = yPos + sp.height;
            sp.x = stage.stageWidth - rect.width;
            sp.graphics.beginFill(0x666666);
            sp.graphics.drawRect(rect.left, rect.top, rect.width, rect.height);
            sp.graphics.endFill();
            sp.buttonMode = true;
            sp.addEventListener(MouseEvent.CLICK, updateProgram);
            addChild(sp);
            
            _width = stage.stageWidth & ~1;
            _height = stage.stageHeight & ~1;
            
            _stage3D = stage.stage3Ds[0];
            _stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
            _stage3D.requestContext3D(Context3DRenderMode.AUTO);
            //_stage3D.viewPort = new Rectangle(0, 0, _width, _height);
        }
        
        private function onContext3DCreate(e:Event):void 
        {
            _context3D = _stage3D.context3D;
            _context3D.enableErrorChecking = true;
            _context3D.setDepthTest(true, Context3DCompareMode.LESS);
            //_context3D.setCulling(Context3DTriangleFace.FRONT_AND_BACK);
            _context3D.configureBackBuffer(_width, _height, 2, true);
            
            initTorus();
            
            var texture:Texture = _context3D.createTexture(64, 64, Context3DTextureFormat.BGRA, true);
            var textureData:BitmapData = new BitmapData(64, 64);
            var heights:Array = [8, 4, 20, 22, 10];
            var colors:Array = [0, 0x661100, 0xff7f00, 0xffd400, 0xffff66];
            var len:int = colors.length;
            var rect:Rectangle = new Rectangle(0, 0, 64);
            var yPos:int = 0, h:int;
            for (var i:int = 0; i < len; ++i) {
                rect.height = h = heights[i];
                rect.y = yPos;
                yPos += h;
                textureData.fillRect(rect, colors[i] | 0xff000000);
            }
            
            //textureData.perlinNoise(64, 64, 8, 0, true, true);
            texture.uploadFromBitmapData(textureData);
            _context3D.setTextureAt(0, texture);
            addChild(new Bitmap(textureData)).y = 40;
            
            _model = new Matrix3D;
            _world = new Matrix3D;
            _eye = new Vector3D(0, 0, 70);
            _at = new Vector3D(0, 1, -10, 1);
            _up = new Vector3D(0, 1);
            _projection = new PerspectiveMatrix3D();
            //_projection.lookAtRH(_eye, _at, _up);
            _projection.perspectiveFieldOfViewRH(42.7, stage.stageWidth / stage.stageHeight, 1.0, 40.0);
            
            updateProgram();
            
            var light:Vector3D = _projection.transformVector(new Vector3D(5.0, 20.0, 0.0));
            var eye:Vector3D = _projection.transformVector(_eye);
            _context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 12, new Vector.<Number>([  light.x, light.y, light.z, 1.0]));
            _context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 13, new Vector.<Number>([  eye.x, eye.y, eye.z, 0.0]));
            _context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 14, new Vector.<Number>([  0.0, 0.0, 0.0,  0.0]));
            _context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, new Vector.<Number>([  1.0, 1.0, 1.0,  0.0]));
            
            trace("eye: ", _projection.transformVector(_eye));
            trace("at: ", _projection.transformVector(_at));
            trace("up: ", _projection.transformVector(_up));

            var line:TextLine = getTextLine(<>rendering driver info: {_context3D.driverInfo}</>);
            line.y = line.height;
            addChild(line);
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function updateProgram(e:MouseEvent = null):void {
            var program:Program3D = _context3D.createProgram();
            program.upload(
                new AGALMiniAssembler(true).assemble(Context3DProgramType.VERTEX, _vertexShaderTF.text),
                new AGALMiniAssembler(true).assemble(Context3DProgramType.FRAGMENT, _fragmentShaderTF.text)
            );
            _context3D.setProgram(program);
        }
        
        private function initTorus():void {
            var i:int, j:int, k:int, m:int;
            var phi:Number, psi:Number;
            var verticies:Vector.<Number> = new Vector.<Number>(6 * K, true);
            for (i = 0; i < N0; ++i) {
                for (j = 0; j < N1; ++j) {
                    phi = i * 2 * Math.PI / N0;
                    psi = j * 2 * Math.PI / N1;
                    k = (j + N1 * i) * 6;
                    verticies[k]     = (R0 + R1 * Math.cos(psi)) * Math.cos(phi);
                    verticies[k + 1] = (R0 + R1 * Math.cos(psi)) * Math.sin(phi);
                    verticies[k + 2] = R1                        * Math.sin(psi);
                    verticies[k + 3] = Math.cos(psi) * Math.cos(phi);
                    verticies[k + 4] = Math.cos(psi) * Math.sin(phi);
                    verticies[k + 5] = Math.sin(psi);
                    for (m = 0; m < 3; ++m) {
                        verticies[k + m + 3] += verticies[k + m];
                    }
                }
            }
            var verticiesBuffer:VertexBuffer3D = _context3D.createVertexBuffer(K, 6);
            verticiesBuffer.uploadFromVector(verticies, 0, K);
            _context3D.setVertexBufferAt(0, verticiesBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            _context3D.setVertexBufferAt(1, verticiesBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
            
            var indeces:Vector.<uint> = new Vector.<uint>(6 * K, true);
            for (i = 0; i < N0; ++i) {
                for (j = 0; j < N1; ++j) {
                    k = j + i * N1;
                    m = 6 * k;
                    indeces[m]     = k;
                    indeces[m + 1] = (k + N1)     % K;
                    indeces[m + 2] = (k + 1)      % K;
                    indeces[m + 3] = (k + N1 + 1) % K;
                    indeces[m + 4] = (k + 1)      % K;
                    indeces[m + 5] = (k + N1)     % K;
                }
            }
            _indecesBuffer = _context3D.createIndexBuffer(indeces.length);
            _indecesBuffer.uploadFromVector(indeces, 0, indeces.length);
        }
        
        private var _pitch:Number = 0.0;
        private var _yaw:Number = 0.0;
        private var _lastTime:int = 0;
        private var _fps:int = 0;
        private var _fpsLine:TextLine;
        
        private function onEnterFrame(event:Event):void {
            calcFPS();
            _context3D.clear(1, 1, 1);
                _model.identity();
                _model.appendRotation(_pitch += 0.3, Vector3D.X_AXIS);
                _model.appendRotation(_yaw += 0.2, Vector3D.Y_AXIS);
                _model.appendTranslation(0, 0, -12);
                
                _world.identity();
                _world.append(_model);
                _world.append(_projection);
                
                _context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _world, true);
                _context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, _model, true);
                //_context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, _projection, true);
                _context3D.drawTriangles(_indecesBuffer);
            _context3D.present();
        }
        
        private function calcFPS():void {
            var t:int = getTimer();
            ++_fps;
            if (t - _lastTime > 1000) {
                if (_fpsLine) removeChild(_fpsLine);
                _lastTime = t;
                addChild(_fpsLine = getTextLine(<>fps: {_fps} / {stage.frameRate}</>)).y = 24;
                _fps = 0;
            }
        }
        
        private function getInputField(initText:String, xPos:int, yPos:int):TextField {
            var tf:TextField = new TextField;
            tf.defaultTextFormat = new TextFormat(_elf.fontDescription.fontName, _elf.fontSize, 0x666666);
            tf.multiline = true;
            tf.width = 200;
            tf.border = true;
            tf.borderColor = 0x333333;
            tf.text = initText;
            tf.type = TextFieldType.INPUT;
            tf.x = xPos;
            tf.y = yPos;
            addChild(tf);
            return tf;
        }
        
        private function getTextLine(string:String):TextLine {
            _textFactory.content = new TextElement(string, _elf.clone());
            return _textFactory.createTextLine();
        }
    }

}