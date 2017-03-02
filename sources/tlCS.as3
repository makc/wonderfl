package {
    import com.adobe.utils.AGALMiniAssembler;
    import com.bit101.components.ComboBox;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
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
    import flash.utils.ByteArray;
    import net.hires.debug.Stats;

    /**
     * ...
     * @author
     */
    public class Main extends Sprite {

        private const WIDTH:uint = 466;
        private const HEIGHT:uint = 466;
        private const RAD:Number = Math.PI / 180;
        //
        private var stage3D:Stage3D;
        private var context3D:Context3D;
        //
        private var camera:SimpleCamera3D;
        private var program:Program3D;
        private var mipLinear:Program3D;
        private var mipNearest:Program3D;
        private var mipNone:Program3D;
        private var vBuffer:VertexBuffer3D;
        private var iBuffer:IndexBuffer3D;

        public function Main():void {
            stage.frameRate = 60;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            addChild(new Stats());
            //ui
            var combo:ComboBox = new ComboBox(this, 350, 0, "miplinear", ["miplinear", "mipnearest", "mipnone"]);
            combo.numVisibleItems = 3;
            combo.addEventListener(Event.SELECT, onSelect);
            //
            stage3D = stage.stage3Ds[0];
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
            stage3D.requestContext3D(Context3DRenderMode.AUTO);
        }

        private function onSelect(e:Event):void {
            switch (ComboBox(e.currentTarget).selectedIndex){
                case 0:
                    program = mipLinear;
                    break;
                case 1:
                    program = mipNearest;
                    break;
                case 2:
                    program = mipNone;
                    break;
                default:
                    break;
            }
        }

        private function onContextCreate(e:Event):void {
            context3D = stage3D.context3D;
            context3D.enableErrorChecking = true;
            context3D.configureBackBuffer(WIDTH, HEIGHT, 0, true);
            context3D.setCulling(Context3DTriangleFace.BACK);
            //
            camera = new SimpleCamera3D(45 * RAD, 1, 0.1, 30000);
            new RoundCameraController(camera, stage);
            createBuffer();
            createShader();
            var texture:Texture = context3D.createTexture(256, 256, Context3DTextureFormat.BGRA, false);
            var bd:BitmapData = new BitmapData(256, 256, false, 0xff0000);
            texture.uploadFromBitmapData(bd, 0);
            bd = new BitmapData(128, 128, false, 0x00ff00);
            texture.uploadFromBitmapData(bd, 1);
            bd = new BitmapData(64, 64, false, 0x0000ff);
            texture.uploadFromBitmapData(bd, 2);
            bd = new BitmapData(32, 32, false, 0xffff00);
            texture.uploadFromBitmapData(bd, 3);
            bd = new BitmapData(16, 16, false, 0x00ffff);
            texture.uploadFromBitmapData(bd, 4);
            bd = new BitmapData(8, 8, false, 0xff00ff);
            texture.uploadFromBitmapData(bd, 5);
            bd = new BitmapData(4, 4, false, 0xffffff);
            texture.uploadFromBitmapData(bd, 6);
            bd = new BitmapData(2, 2, false, 0xffffff);
            texture.uploadFromBitmapData(bd, 7);
            bd = new BitmapData(1, 1, false, 0xffffff);
            texture.uploadFromBitmapData(bd, 8);
            context3D.setTextureAt(0, texture);
            //
            addEventListener(Event.ENTER_FRAME, onEnter);
        }

        private function onEnter(e:Event):void {
            context3D.clear();
            context3D.setProgram(program);
            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, camera.cameraMtx, true);
            context3D.drawTriangles(iBuffer);
            context3D.present();
        }

        private function createShader():void {
            var agalAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            var code:String = "";
            code += "m44 op, va0, vc0\n";
            code += "mov v0, va1\n";
            var vertexShader:ByteArray = agalAssembler.assemble(Context3DProgramType.VERTEX, code);
            //
            code = "tex oc, v0, fs0 <2d,repeat,linear,miplinear>\n";
            var fragmentShader:ByteArray = agalAssembler.assemble(Context3DProgramType.FRAGMENT, code);
            mipLinear = context3D.createProgram();
            mipLinear.upload(vertexShader, fragmentShader);
            code = "tex oc, v0, fs0 <2d,repeat,linear,mipnearest>\n"
            fragmentShader = agalAssembler.assemble(Context3DProgramType.FRAGMENT, code);
            mipNearest = context3D.createProgram();
            mipNearest.upload(vertexShader, fragmentShader);
            code = "tex oc, v0, fs0 <2d,repeat,linear,mipnone>\n"
            fragmentShader = agalAssembler.assemble(Context3DProgramType.FRAGMENT, code);
            mipNone = context3D.createProgram();
            mipNone.upload(vertexShader, fragmentShader);
            program = mipLinear;
        }

        private function createBuffer():void {
            //vertex buffer
            vBuffer = context3D.createVertexBuffer(4, 5);
            vBuffer.uploadFromVector(Vector.<Number>([-100, 100, 0, 0, 0, -100, -100, 0, 0, 1, 100, 100, 0, 1, 0, 100, -100, 0, 1, 1]), 0, 4);
            context3D.setVertexBufferAt(0, vBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            context3D.setVertexBufferAt(1, vBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
            //index buffer
            iBuffer = context3D.createIndexBuffer(6);
            iBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 2, 1, 3]), 0, 6);
        }

    }
}

import com.adobe.utils.PerspectiveMatrix3D;
import flash.display.InteractiveObject;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.ui.Keyboard;

//////////////////////////////////////////////////
// SimpleCamera3D
//////////////////////////////////////////////////
class SimpleCamera3D extends Object {

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

    public function SimpleCamera3D(fov:Number, aspect:Number, zNear:Number, zFar:Number):void {
        _projectionMtx.perspectiveFieldOfViewLH(fov, aspect, zNear, zFar);
    }

    public function get cameraMtx():Matrix3D {
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

    public function lookAt(point:Vector3D):void {
        _direction.x = point.x - x;
        _direction.y = point.y - y;
        _direction.z = point.z - z;
        _direction.normalize();
    }

}

//////////////////////////////////////////////////
// RoundCameraController
//////////////////////////////////////////////////
class RoundCameraController extends Object {

    private var _camera:SimpleCamera3D;
    private var _stage:InteractiveObject;
    private var _target:Vector3D;
    public var radiusOffset:Number = 40;
    //
    private const RAD:Number = Math.PI / 180;
    //
    public var isMouseDown:Boolean;
    private var _radius:Number = 2000;
    private var _theta:Number = 0;
    private var _oldX:Number = 0;
    private var _phi:Number = 90;
    private var _oldY:Number = 0;

    public function RoundCameraController(camera:SimpleCamera3D, stage:InteractiveObject){
        _camera = camera;
        _stage = stage;
        _target = new Vector3D();
        enable();
        _upDateCamera();
    }

    public function enable():void {
        _stage.stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyHandler);
        _stage.stage.addEventListener(MouseEvent.MOUSE_UP, _upHandler);
        _stage.addEventListener(MouseEvent.MOUSE_DOWN, _downHandler);
        _stage.addEventListener(MouseEvent.MOUSE_MOVE, _moveHandler);
        _stage.addEventListener(MouseEvent.MOUSE_WHEEL, _wheelHandler);
    }

    //
    private function _keyHandler(e:KeyboardEvent):void {
        switch (e.keyCode){
            case Keyboard.UP:
                _radius -= radiusOffset;
                if (_radius < 10){
                    _radius = 10;
                }
                _upDateCamera();
                break;
            case Keyboard.DOWN:
                _radius += radiusOffset;
                _upDateCamera();
                break;
            default:
                break;
        }
    }

    private function _upHandler(e:MouseEvent):void {
        isMouseDown = false;
    }

    private function _downHandler(e:MouseEvent):void {
        isMouseDown = true;
        _oldX = _stage.mouseX;
        _oldY = _stage.mouseY;
    }

    private function _wheelHandler(e:MouseEvent):void {
        if (e.delta > 0){
            _radius -= radiusOffset;
            if (_radius < 10){
                _radius = 10;
            }
        } else {
            _radius += radiusOffset;
        }
        _upDateCamera();
    }

    private function _moveHandler(e:MouseEvent):void {
        if (isMouseDown){
            _theta += (e.stageX - _oldX) >> 2;
            _oldX = e.stageX;
            _phi -= (e.stageY - _oldY) >> 2;
            _oldY = e.stageY;
            //
            if (_theta < 0){
                _theta += 360;
            } else if (_theta > 360){
                _theta -= 360;
            }
            if (_phi < 20){
                _phi = 20;
            } else if (_phi > 160){
                _phi = 160;
            }
            _upDateCamera();
        }
    }

    private function _upDateCamera():void {
        var t:Number = _theta * RAD;
        var p:Number = _phi * RAD;
        var rsin:Number = _radius * Math.sin(p);
        _camera.x = rsin * Math.sin(t) + _target.x;
        _camera.z = rsin * Math.cos(t) + _target.z;
        _camera.y = _radius * Math.cos(p) + _target.y;
        _camera.lookAt(_target)
    }

}