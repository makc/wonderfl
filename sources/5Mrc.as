package
{
    import com.adobe.utils.AGALMiniAssembler;
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DRenderMode;
    import flash.display3D.Context3DTriangleFace;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.ByteArray;
    import frocessing.color.ColorHSV;
    import net.hires.debug.Stats;
    
    /**
     * ...
     * @author 9ballsyndrome
     */
    public class Main extends Sprite
    {
        
        private const NUM_PARTICLES:uint = 16383;
        private const P_SIZE:Number = 0.5 * 0.015;
        private const WIDTH:uint = 466;
        private const HEIGHT:uint = 466;
        private const RAD:Number = Math.PI / 180;
        //
        private var loadImageButton:PushButton;
        private var fileReference:FileReference;
        private var imageBD:BitmapData;
        private var bdWidth:Number = 466;
        private var bdHeight:Number = 466;
        //
        private var stage3D:Stage3D;
        private var context3D:Context3D;
        //
        private var camera:SimpleCamera3D;
        private var controller:RoundCameraController;
        private var particleProgram:Program3D;
        private var vBufferR0:VertexBuffer3D;
        private var vBufferR1:VertexBuffer3D;
        private var vBufferOffset:VertexBuffer3D;
        private var vBufferColor:VertexBuffer3D;
        private var iBuffer:IndexBuffer3D;
        //
        private var theta:Number = -Math.PI / 2;
        //
        private var filter:TwinkleFilter3D;
        private var isFilter:Boolean = false;
        private var filterButton:PushButton;
        
        public function Main():void
        {
            Wonderfl.disable_capture();
            stage.frameRate = 60;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            addChild(new Stats());
            //
            //
            //set ui
            var tfP:TextField = new TextField();
            tfP.autoSize = TextFieldAutoSize.LEFT;
            tfP.textColor = 0xffffff;
            tfP.text = "Particle : " + NUM_PARTICLES;
            tfP.x = 250;
            //addChild(tfP);
            filterButton = new PushButton(this, 350, 0, "Twinkle", onPush);
            filterButton.toggle = true;
            filterButton.visible = false;
            //
            fileReference = new FileReference();
            fileReference.addEventListener(Event.SELECT, selectHandler);
            fileReference.addEventListener(Event.COMPLETE, completeHandler);
            loadImageButton = new PushButton(this, 100, 0, "Load Image", loadImage);
        }
        
        private function loadImage(e:MouseEvent):void
        {
            var fileFilter:FileFilter = new FileFilter("Images(JPEG, GIF, PNG)", "*.jpg;*.gif;*.png");
            fileReference.browse([fileFilter]);
        }
        
        private function selectHandler(e:Event):void
        {
            fileReference.load();
        }
        
        private function completeHandler(e:Event):void
        {
            var loader:Loader = new Loader();
            loader.loadBytes(fileReference.data);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, initHandler);
        }
        
        private function initHandler(e:Event):void
        {
            var loader:Loader = e.currentTarget.loader;
            loader.removeEventListener(Event.COMPLETE, initHandler);
            imageBD = (loader.content as Bitmap).bitmapData;
            init();
        }
        
        private function init():void
        {
            //Stage3Dをリクエスト
            stage3D = stage.stage3Ds[0];
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
            stage3D.requestContext3D(Context3DRenderMode.AUTO);
        }
        
        private function onPush(e:MouseEvent):void
        {
            isFilter = !isFilter;
        }
        
        private function onContextCreate(e:Event):void
        {
            context3D = stage3D.context3D;
            context3D.enableErrorChecking = true;
            context3D.configureBackBuffer(WIDTH, HEIGHT, 0, true);
            context3D.setCulling(Context3DTriangleFace.BACK);
            //
            filter = new TwinkleFilter3D(context3D, WIDTH, HEIGHT, 3);
            camera = new SimpleCamera3D(45 * RAD, 1, 0.1, 3000);
            controller = new RoundCameraController(camera, stage);
            controller.radius = 1000;
            controller.rotate(0, 0);
            createBuffer();
            createShader();
            //
            filterButton.visible = true;
            addEventListener(Event.ENTER_FRAME, onEnter);
        }
        
        private function onEnter(e:Event):void
        {
            if (!controller.isMouseDown)
            {
                controller.rotate(0.5, 0);
            }
            theta += 0.002;
            context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([1000, theta, 0.0, 10])); //c0
            if (isFilter)
            {
                filter.setRenderToTexture();
            }
            context3D.clear();
            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, camera.cameraMtx, true);
            context3D.drawTriangles(iBuffer);
            if (isFilter)
            {
                context3D.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_3);
                context3D.setVertexBufferAt(1, null, 0, Context3DVertexBufferFormat.FLOAT_3);
                context3D.setVertexBufferAt(2, null, 0, Context3DVertexBufferFormat.FLOAT_2);
                context3D.setVertexBufferAt(3, null, 0, Context3DVertexBufferFormat.FLOAT_3);
                filter.applyFilter();
                context3D.setProgram(particleProgram);
                context3D.setVertexBufferAt(0, vBufferR0, 0, Context3DVertexBufferFormat.FLOAT_3);
                context3D.setVertexBufferAt(1, vBufferR1, 0, Context3DVertexBufferFormat.FLOAT_3);
                context3D.setVertexBufferAt(2, vBufferOffset, 0, Context3DVertexBufferFormat.FLOAT_2);
                context3D.setVertexBufferAt(3, vBufferColor, 0, Context3DVertexBufferFormat.FLOAT_3);
            }
            context3D.present();
        }
        
        private function createShader():void
        {
            var agalAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            ////Particle
            var code:String = "";
            
            code += "div vt0.x, va0.x, vc4.x\n"; //vt0.x=x0/c0.x
            code += "add vt0.x, vt0.x, vc4.y\n"; //vt0.x+=c0.y
            code += "sin vt0.x, vt0.x\n"; //vt0.x=sin(vt0.x)
            code += "add vt0.x, vt0.x, vc4.z\n"; //vt0.x+=0.5
            code += "mul vt0.x, vt0.x, vc4.w\n"; //vt0.x*=0.5c0.z
            code += "sat vt0.x, vt0.x\n"; //vt0.x*=sat(vt0.x)
            
            code += "sub vt1, va1, va0\n"; //vt1=va1-va0
            code += "mul vt1, vt1, vt0.x\n"; //vt1*=vt0.x
            code += "add vt1, vt1, va0\n"; //vt1*=vt0.x
            
            //matrix
            code += "m44 vt0, vt1, vc0\n";
            code += "mul vt1, vt0.w, va2\n";
            code += "add vt0, vt0, vt1\n";
            code += "mov op, vt0\n";
            //color
            code += "mov v0, va3\n";
            //
            var vertexShader:ByteArray = agalAssembler.assemble(Context3DProgramType.VERTEX, code);
            var fragmentShader:ByteArray = agalAssembler.assemble(Context3DProgramType.FRAGMENT, "mov oc v0\n");
            particleProgram = context3D.createProgram();
            particleProgram.upload(vertexShader, fragmentShader);
            context3D.setProgram(particleProgram);
        }
        
        private function createBuffer():void
        {
            //bitmapdata
            bdWidth = imageBD.width + 1;
            bdHeight = imageBD.height + 1;
            var numPixels:Number = bdWidth * bdHeight;
            var rate:Number = Math.sqrt(numPixels / NUM_PARTICLES);
            ////Particle
            var numVertices:uint = NUM_PARTICLES * 4;
            var numIndices:uint = NUM_PARTICLES * 6;
            //hs,rgb
            var index0:uint = 0;
            var index1:uint = 0;
            var index2:uint = 0;
            var x0:Number;
            var y0:Number;
            var z0:Number;
            var x1:Number;
            var y1:Number;
            var z1:Number;
            var color:uint;
            var hsv:ColorHSV = new ColorHSV();
            var radius:Number;
            var r:Number;
            var g:Number;
            var b:Number;
            var r0:Vector.<Number> = new Vector.<Number>(numVertices * 3);
            var r1:Vector.<Number> = new Vector.<Number>(numVertices * 3);
            var colorVec:Vector.<Number> = new Vector.<Number>(numVertices * 3);
            vBufferR0 = context3D.createVertexBuffer(numVertices, 3);
            vBufferR1 = context3D.createVertexBuffer(numVertices, 3);
            vBufferColor = context3D.createVertexBuffer(numVertices, 3);
            for (var i:int = 0; i < NUM_PARTICLES; i++)
            {
                //color
                color = imageBD.getPixel((rate * i) % bdWidth, bdHeight - rate * (rate * i / bdWidth));
                r = (color >> 16 & 0xFF) / 255;
                g = (color >> 8 & 0xFF) / 255;
                b = (color & 0xFF) / 255;
                colorVec[index2++] = r;
                colorVec[index2++] = g;
                colorVec[index2++] = b;
                colorVec[index2++] = r;
                colorVec[index2++] = g;
                colorVec[index2++] = b;
                colorVec[index2++] = r;
                colorVec[index2++] = g;
                colorVec[index2++] = b;
                colorVec[index2++] = r;
                colorVec[index2++] = g;
                colorVec[index2++] = b;
                //
                //並べられた位置(状態0)
                x0 = (rate * i) % bdWidth - bdWidth / 2;
                y0 = rate * (rate * i / bdWidth) - bdHeight / 2;
                z0 = 0;
                r0[index0++] = x0;
                r0[index0++] = y0;
                r0[index0++] = z0;
                r0[index0++] = x0;
                r0[index0++] = y0;
                r0[index0++] = z0;
                r0[index0++] = x0;
                r0[index0++] = y0;
                r0[index0++] = z0;
                r0[index0++] = x0;
                r0[index0++] = y0;
                r0[index0++] = z0;
                //ランダムな位置(状態1)
                hsv.value = color;
                radius = 500 + Math.random() * 500;
                x1 = radius * Math.sin(hsv.h * RAD);
                y1 = 100 * Math.random();
                z1 = radius * Math.cos(hsv.h * RAD);
                r1[index1++] = x1;
                r1[index1++] = y1;
                r1[index1++] = z1;
                r1[index1++] = x1;
                r1[index1++] = y1;
                r1[index1++] = z1;
                r1[index1++] = x1;
                r1[index1++] = y1;
                r1[index1++] = z1;
                r1[index1++] = x1;
                r1[index1++] = y1;
                r1[index1++] = z1;
            }
            vBufferR0.uploadFromVector(r0, 0, numVertices);
            vBufferR1.uploadFromVector(r1, 0, numVertices);
            vBufferColor.uploadFromVector(colorVec, 0, numVertices);
            context3D.setVertexBufferAt(0, vBufferR0, 0, Context3DVertexBufferFormat.FLOAT_3);
            context3D.setVertexBufferAt(1, vBufferR1, 0, Context3DVertexBufferFormat.FLOAT_3);
            context3D.setVertexBufferAt(3, vBufferColor, 0, Context3DVertexBufferFormat.FLOAT_3);
            //offset
            vBufferOffset = context3D.createVertexBuffer(numVertices, 2);
            var offsetVec:Vector.<Number> = new Vector.<Number>(numVertices * 2);
            index0 = 0;
            for (i = 0; i < NUM_PARTICLES; i++)
            {
                offsetVec[index0++] = -P_SIZE;
                offsetVec[index0++] = -P_SIZE;
                offsetVec[index0++] = -P_SIZE;
                offsetVec[index0++] = P_SIZE;
                offsetVec[index0++] = P_SIZE;
                offsetVec[index0++] = -P_SIZE;
                offsetVec[index0++] = P_SIZE;
                offsetVec[index0++] = P_SIZE;
            }
            vBufferOffset.uploadFromVector(offsetVec, 0, numVertices);
            context3D.setVertexBufferAt(2, vBufferOffset, 0, Context3DVertexBufferFormat.FLOAT_2);
            
            //index buffer
            iBuffer = context3D.createIndexBuffer(numIndices);
            var iVec:Vector.<uint> = new Vector.<uint>(numIndices);
            index0 = 0;
            var p:uint;
            var length:uint = NUM_PARTICLES * 6;
            for (i = 0; i < length; i++)
            {
                p = i << 2;
                iVec[index0++] = p;
                iVec[index0++] = p + 1;
                iVec[index0++] = p + 2;
                iVec[index0++] = p + 2;
                iVec[index0++] = p + 1;
                iVec[index0++] = p + 3;
            }
            iBuffer.uploadFromVector(iVec, 0, numIndices);
        }
    
    }
}

import com.adobe.utils.AGALMiniAssembler;
import com.adobe.utils.PerspectiveMatrix3D;
import flash.display.InteractiveObject;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.ui.Keyboard;
import flash.utils.ByteArray;

//////////////////////////////////////////////////
// SimpleCamera3D
//////////////////////////////////////////////////
class SimpleCamera3D
{
    
    private const RAD:Number = Math.random() / 180;
    private const DIRECTION:Vector3D = new Vector3D(0, 0, 1);
    //
    private var _cameraUP:Vector3D = new Vector3D(0, 1, 0);
    private var _direction:Vector3D = DIRECTION.clone();
    //
    private var _projectionMtx:PerspectiveMatrix3D = new PerspectiveMatrix3D();
    private var _cameraMtx:Matrix3D = new Matrix3D();
    private var _rotationMtx:Matrix3D = new Matrix3D();
    //
    public var x:Number = 0;
    public var y:Number = 0;
    public var z:Number = 0;
    
    public function SimpleCamera3D(fov:Number, aspect:Number, zNear:Number, zFar:Number):void
    {
        _projectionMtx.perspectiveFieldOfViewLH(fov, aspect, zNear, zFar);
    }
    
    public function get cameraMtx():Matrix3D
    {
        var forwardX:Number = _direction.x;
        var forwardY:Number = _direction.y;
        var forwardZ:Number = _direction.z;
        var rightX:Number = _cameraUP.y * forwardZ - _cameraUP.z * forwardY;
        var rightY:Number = _cameraUP.z * forwardX - _cameraUP.x * forwardZ;
        var rightZ:Number = _cameraUP.x * forwardY - _cameraUP.y * forwardX;
        var distance:Number = Math.sqrt(rightX * rightX + rightY * rightY + rightZ * rightZ);
        rightX /= distance;
        rightY /= distance;
        rightZ /= distance;
        var upX:Number = forwardY * rightZ - forwardZ * rightY;
        var upY:Number = forwardZ * rightX - forwardX * rightZ;
        var upZ:Number = forwardX * rightY - forwardY * rightX;
        var right:Number = rightX * x + rightY * y + rightZ * z;
        var up:Number = upX * x + upY * y + upZ * z;
        var forward:Number = forwardX * x + forwardY * y + forwardZ * z;
        _cameraMtx.rawData = Vector.<Number>([rightX, upX, forwardX, 0, rightY, upY, forwardY, 0, rightZ, upZ, forwardZ, 0, -right, -up, -forward, 1]);
        _cameraMtx.append(_projectionMtx);
        return _cameraMtx;
    }
    
    public function lookAt(point:Vector3D):void
    {
        _direction.x = point.x - x;
        _direction.y = point.y - y;
        _direction.z = point.z - z;
        _direction.normalize();
    }

}

//////////////////////////////////////////////////
// RoundCameraController
//////////////////////////////////////////////////
class RoundCameraController
{
    
    private var _camera:SimpleCamera3D;
    private var _stage:InteractiveObject;
    private var _target:Vector3D;
    public var radiusOffset:Number = 40;
    //
    private const RAD:Number = Math.PI / 180;
    //
    public var isMouseDown:Boolean;
    public var radius:Number = 2000;
    private var _theta:Number = 0;
    private var _oldX:Number = 0;
    private var _phi:Number = 90;
    private var _oldY:Number = 0;
    
    public function RoundCameraController(camera:SimpleCamera3D, stage:InteractiveObject)
    {
        _camera = camera;
        _stage = stage;
        _target = new Vector3D();
        enable();
        _upDateCamera();
    }
    
    public function enable():void
    {
        _stage.stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyHandler);
        _stage.stage.addEventListener(MouseEvent.MOUSE_UP, _upHandler);
        _stage.addEventListener(MouseEvent.MOUSE_DOWN, _downHandler);
        _stage.addEventListener(MouseEvent.MOUSE_MOVE, _moveHandler);
        _stage.addEventListener(MouseEvent.MOUSE_WHEEL, _wheelHandler);
    }
    
    //
    private function _keyHandler(e:KeyboardEvent):void
    {
        switch (e.keyCode)
        {
            case Keyboard.UP: 
                radius -= radiusOffset;
                if (radius < 10)
                {
                    radius = 10;
                }
                _upDateCamera();
                break;
            case Keyboard.DOWN: 
                radius += radiusOffset;
                _upDateCamera();
                break;
            default: 
                break;
        }
    }
    
    private function _upHandler(e:MouseEvent):void
    {
        isMouseDown = false;
    }
    
    private function _downHandler(e:MouseEvent):void
    {
        isMouseDown = true;
        _oldX = _stage.mouseX;
        _oldY = _stage.mouseY;
    }
    
    private function _wheelHandler(e:MouseEvent):void
    {
        if (e.delta > 0)
        {
            radius -= radiusOffset;
            if (radius < 10)
            {
                radius = 10;
            }
        }
        else
        {
            radius += radiusOffset;
        }
        _upDateCamera();
    }
    
    private function _moveHandler(e:MouseEvent):void
    {
        if (isMouseDown)
        {
            _theta += (e.stageX - _oldX) >> 2;
            _oldX = e.stageX;
            _phi -= (e.stageY - _oldY) >> 2;
            _oldY = e.stageY;
            //
            if (_theta < 0)
            {
                _theta += 360;
            }
            else if (_theta > 360)
            {
                _theta -= 360;
            }
            if (_phi < 20)
            {
                _phi = 20;
            }
            else if (_phi > 160)
            {
                _phi = 160;
            }
            _upDateCamera();
        }
    }
    
    private function _upDateCamera():void
    {
        var t:Number = _theta * RAD;
        var p:Number = _phi * RAD;
        var rsin:Number = radius * Math.sin(p);
        _camera.x = rsin * Math.sin(t) + _target.x;
        _camera.z = rsin * Math.cos(t) + _target.z;
        _camera.y = radius * Math.cos(p) + _target.y;
        _camera.lookAt(_target)
    }
    
    public function rotate(dTheta:Number, dPhi:Number):void
    {
        _theta += dTheta;
        _phi += dPhi;
        _upDateCamera();
    }

}

//////////////////////////////////////////////////
// TwinkleFilter3D
//////////////////////////////////////////////////
class TwinkleFilter3D
{
    private var _context3D:Context3D;
    private var _width:Number;
    private var _height:Number;
    //twinkle
    private var _canvasTexture:Texture;
    private var _shrinkTexture:Texture;
    private var _vertexBuffer:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _shrinkProgram:Program3D;
    private var _compositeProgram:Program3D;
    
    public function TwinkleFilter3D(context3D:Context3D, width:uint, height:uint, twinkleStrength:uint = 4)
    {
        _context3D = context3D;
        _width = _toPowerOfTwo(width);
        _height = _toPowerOfTwo(height);
        twinkleStrength = twinkleStrength < 2 ? 2 : twinkleStrength;
        var sW:uint = _width >> twinkleStrength;
        var sH:uint = _height >> twinkleStrength;
        sW = sW < 1 ? 1 : sW;
        sH = sH < 1 ? 1 : sH;
        ////texture
        _canvasTexture = _context3D.createTexture(_width, _height, Context3DTextureFormat.BGRA, true);
        _shrinkTexture = _context3D.createTexture(sW, sH, Context3DTextureFormat.BGRA, true);
        ////buffer
        //vertex buffer
        _vertexBuffer = _context3D.createVertexBuffer(4, 4);
        _vertexBuffer.uploadFromVector(Vector.<Number>([-1, -1, 0, 1, -1, 1, 0, 0, 1, -1, 1, 1, 1, 1, 1, 0]), 0, 4);
        //index buffer
        _indexBuffer = _context3D.createIndexBuffer(6);
        _indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 3, 2]), 0, 6);
        ////shader
        //shrink
        var agal:AGALMiniAssembler = new AGALMiniAssembler();
        var vertexShader:ByteArray = agal.assemble(Context3DProgramType.VERTEX, "mov op, va0 \n" + "mov v0, va1\n");
        var code:String = "";
        code += "mov ft0 v0\n";
        code += "tex ft0, ft0, fs0<2d,repeat,linear>\n";
        code += "mov oc, ft0\n";
        var fragmentShader:ByteArray = agal.assemble(Context3DProgramType.FRAGMENT, code);
        _shrinkProgram = _context3D.createProgram();
        _shrinkProgram.upload(vertexShader, fragmentShader);
        //composite
        code = "";
        code += "mov ft0 v0\n";
        code += "tex ft1, ft0, fs0<2d,repeat,linear>\n";
        code += "tex ft0, ft0, fs1<2d,repeat,linear>\n";
        code += "add ft0, ft0, ft1\n";
        code += "mov oc, ft0\n";
        fragmentShader = agal.assemble(Context3DProgramType.FRAGMENT, code);
        _compositeProgram = _context3D.createProgram();
        _compositeProgram.upload(vertexShader, fragmentShader);
    }
    
    public function setRenderToTexture():void
    {
        _context3D.setRenderToTexture(_canvasTexture, true);
    }
    
    public function applyFilter():void
    {
        _context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
        _context3D.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
        //shrink
        _context3D.setProgram(_shrinkProgram);
        _context3D.setRenderToTexture(_shrinkTexture);
        _context3D.clear();
        _context3D.setTextureAt(0, _canvasTexture);
        _context3D.drawTriangles(_indexBuffer);
        //composite
        _context3D.setRenderToBackBuffer();
        _context3D.setProgram(_compositeProgram);
        _context3D.setTextureAt(0, _canvasTexture);
        _context3D.setTextureAt(1, _shrinkTexture);
        _context3D.clear();
        _context3D.drawTriangles(_indexBuffer);
        //
        _context3D.setTextureAt(0, null);
        _context3D.setTextureAt(1, null);
        _context3D.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_2);
        _context3D.setVertexBufferAt(1, null, 2, Context3DVertexBufferFormat.FLOAT_2);
    }
    
    //
    private function _toPowerOfTwo(x:uint):uint
    {
        if ((x & (x - 1)))
        {
            var i:uint = 1;
            while (i < x)
            {
                i <<= 1;
            }
            x = i;
        }
        return x;
    }

}