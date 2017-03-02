package 
{
    import com.adobe.utils.AGALMiniAssembler;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProfile;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DRenderMode;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.textures.Texture;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TouchEvent;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.ui.Keyboard;
    import flash.ui.Multitouch;
    import flash.ui.MultitouchInputMode;
    import flash.utils.getTimer;
    
    public class Main extends Sprite 
    {
        private var _cameraRotation:Vector3D = new Vector3D(-320, -5, 0);
        private var _cameraRadius:Number = 150;
        private var _mousePos2d:Vector3D;
        private var _texture:BitmapData;
        private var _mx:Matrix3D = new Matrix3D();
        
        private var _verts:Vector.<Number>; //xyzuvnnn, xyzuvnnn, ... (stride=8)
        private var _vStride:uint = 8;
        private var _indices:Vector.<uint>;
        
        private var _rotTime:int;
        
        private var _HQ:Boolean = true;
        
        private var _ctx3d:Context3D;
        private var _shaders:Program3D;
        
        private var _iBuf:IndexBuffer3D;
        private var _vBuf:VertexBuffer3D;
        
        private var _viewMx:Matrix3D;
        private var _projMx:Matrix3D;
        
        private var _diffTex:Texture;
        
        private var _camPos:Vector3D;
        
        private var _lightPos:Vector3D = new Vector3D(-100, 100, -100);
        private var _ambient:Number = .3;
        
        private var _needsSnapshot:Boolean = false;
        private var _snapshot:Bitmap;
        
        private var _brush:Vector3D = new Vector3D();
        private var _t:Number = 0;
        
        private var _dangle:Number = .005;
        
        private var _terrainW:Number = 100;
        private var _terrainH:Number = 100;
        private var _terrainStepsW:uint = 127;
        private var _terrainStepsH:uint = 127;
        private var _hmap:PerlinHeightMap;
        private var _hmapHolder:Bitmap;
        private var _bumpTex:Texture;
        
        public function Main():void 
        {
            trace('initializing stage 2d ...');
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            
            prepare2dStage();
            requestContext3DOf2dStage();
            
            initInteractivity();
        }
        
        private function prepare2dStage():void {
            stage.frameRate = 60;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = qualitySettings(StageQuality.LOW, StageQuality.HIGH);
            trace('stage 2d is ready!');
        }
        
        /// block 3d ///
        private function requestContext3DOf2dStage():void {
            trace('creating context 3d ...');
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
            stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
        }
        
        private function onContext3DCreate(e:Event):void {
            _ctx3d = (e.target as Stage3D).context3D;    
            if (!_ctx3d) {
                trace('Error: can\'t obtain context 3d!');
                return;
            } else {
                trace('context 3d created!');
            }
            
            initContet3D();
            initShaders();
            initMesh();
            
            initPerlinTerrain();
            
            // add keyboard handlers
            stage.addEventListener(KeyboardEvent.KEY_UP, keyboardHandler);
            // start rendering
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function initContet3D():void {
            // debug
            _ctx3d.enableErrorChecking = true;
            
            // handle resizing of a viewport
            stage.addEventListener(Event.RESIZE, onResize);
            onResize();
        }
        
        private function onResize(e:Event = null):void {
            _ctx3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, qualitySettings(0, 4), true, false);
        }
        
        private function initShaders():void {
            // vertex shader which does a 3d transformation of a model
            var vs:String =
                "m44 op, va0, vc0" + "\n" + // OutputPosition(op) = xyz(vt0) * transformMatrix(vc0)
                "mov v0, va0" + "\n" + // va0 = xyz, put it as v0
                "mov v1, va1" + "\n" + // va1 = uv, put it to FS as v1
                "mov v2, va2" + "\n" + // v2 = normal's xyz(va2)
                "sub v3, vc4, va0";    // v3 = "light's direction" = "light's position"(vc4) - "current vertex"(va0)
            var vsa:AGALMiniAssembler = new AGALMiniAssembler();
            vsa.assemble(Context3DProgramType.VERTEX, vs);            
            
            var texFlags:String = qualitySettings("<2d>", "<2d,linear>");
            // fragment shader to render a model
            /*var fs:String = 
                "tex ft0, v1, fs0 " + texFlags + "\n" + // take the texture color from texture(fs0) in uv(v1), <2d,linear,miplinear>
                "mov oc, ft0" + "\n"; // color to OutputColor(oc)*/
            var fs:String =
                // sample diffuse texture
                "tex ft0, v1, fs0 " + texFlags + "\n" + // take the texture color from texture(fs0) in uv(v1)
                /// <bump-mapping> ///
                // sample height at (u,v) -> ft1.x
                "mov ft2, fc1.xxxx" + "\n" + // zeros
                "mov ft2.xy, v1.xy" + "\n" + // ft2 = uv
                "tex ft1, ft2, fs1 <2d,linear>" + "\n" + // ft1 = heightmap[uv]
                // sample height at (u+du,v) -> ft4.x
                "mov ft3, fc1.xxxx" + "\n" + // zeros
                "mov ft3.xy, v1.xy" + "\n" + // ft3 = uv
                "add ft3.xy, ft3.xy, fc1.wx" + "\n" + // ft3 = u+du,v
                "tex ft4, ft3, fs1 <2d,linear>" + "\n" + // ft4 = heightmap[u+du,v]
                // sample height at (u,v+dv) -> ft6.x
                "mov ft5, fc1.xxxx" + "\n" + // zeros
                "mov ft5.xy, v1.xy" + "\n" + // ft5 = uv
                "add ft5.xy, ft5.xy, fc1.xw" + "\n" + // ft5 = u,v+dv
                "tex ft6, ft5, fs1 <2d,linear>" + "\n" + // ft6 = heightmap[u,v+dv]
                // calculate "du" vector -> ft2.xyz
                "mov ft2, fc1.wxxx" + "\n" + // d,0,0,{0} , where d = "size of 1 pixel"
                "sub ft2.y, ft4.x, ft1.x" + "\n" + // h[u+du,v] - h[u,v]
                "nrm ft2.xyz, ft2.xyz" + "\n" +
                // calculate "dv" vector -> ft3.xyz
                "mov ft3, fc1.xxwx" + "\n" + // 0,0,d,{0}
                "sub ft3.y, ft6.x, ft1.x" + "\n" + // h[u,v+dv] - h[u,v]
                "nrm ft3.xyz, ft3.xyz" + "\n" +
                // calculate the Normal vector: n = [du x dv] -> ft5.xyz
                "mov ft5, fc1.xxxx" + "\n" + // zeros
                "crs ft5.xyz, ft3.xyz, ft2.xyz" + "\n" + // [dv x du]
                /*"sub ft5.x, ft5.x, ft2.y" + "\n" + // grad - compute the h-gradient instead of cross product
                "sub ft5.z, ft5.z, ft3.y" + "\n" +*/ // grad
                "nrm ft5.xyz, ft5.xyz" + "\n" +
                /// </bump-mapping> ///
                // lambert lighting
                "nrm ft2.xyz, v3" + "\n" + // ft2 = norm(lightDirection), lightDirection=v3
                "dp3 ft3.x, ft5.xyz, ft2.xyz" + "\n" +     // ft3.x = dot(n, lightDirection)
                "max ft3.x, ft3.x, fc1.x" + "\n" +     // ft3.x > 0 !
                "mov ft3.xyz, ft3.xxx" + "\n" +
                "add ft3.xyz, ft3.xxx, fc0.xyz" + "\n" +     // ft3 += ambient(fc0.xyz)
                "mul ft0, ft0, ft3" + "\n" +     // color *= ft3
                // make lower zones darker according to heightmap
                "add ft1.xyz, ft1.xyz, fc0.xyz" + "\n" +     // ft1 += ambient(fc0.xyz)
                "mul ft0, ft0, ft1" + "\n" +
                //"mov oc, ft5";// draw a normal
                "mov oc, ft0"; // color to OutputColor(oc)
            var fsa:AGALMiniAssembler = new AGALMiniAssembler();
            fsa.assemble(Context3DProgramType.FRAGMENT, fs);
            
            // combine shaders into a single program ready to be uploaded to GPU
            _shaders = _ctx3d.createProgram();
            _shaders.upload(vsa.agalcode, fsa.agalcode)
        }
        
        private function initMesh():void {
            // read a raw data
            readModel();
            
            // indices
            _iBuf = _ctx3d.createIndexBuffer(_indices.length); // total amount of vertices forming the triandles
            _iBuf.uploadFromVector(_indices, 0, _indices.length);

            // vertices
            _vBuf = _ctx3d.createVertexBuffer(_verts.length / _vStride, _vStride);
            _vBuf.uploadFromVector(_verts, 0, _verts.length / _vStride);
            
            // textures
            _diffTex = createTexture(_texture);
        }
        
        private function createTexture(bd:BitmapData, mip:Boolean = true):Texture {
            var mipMap:BitmapData = bd;
            var tex:Texture = _ctx3d.createTexture(bd.width, bd.height, Context3DTextureFormat.BGRA, false);
            var mipLevel:int = 0;
            tex.uploadFromBitmapData(bd, mipLevel++);
            if (mip) {
                // create mipmaps
                while (bd.width > 1 || bd.height > 1) {                    
                    mipMap = new BitmapData(Math.max(1, bd.width >> 1), Math.max(1, bd.height >> 1), true, 0);
                    mipMap.draw(bd, new Matrix(0.5, 0, 0, 0.5, 0, 0), null, null, null, true);
                    tex.uploadFromBitmapData(mipMap, mipLevel++);
                    bd = mipMap;
                }
            }
            return tex;
        }
        
        private function onEnterFrame(e:Event):void {
            updatePerlin();
            //autoRotate();
            updateCamera();
            render();
        }
        
        private function updateCamera():void {
            _mx = new Matrix3D();
            _viewMx = viewMatrix(_cameraRotation, _cameraRadius, 0);
            _projMx = projMatrix(45, stage.stageWidth / stage.stageHeight, 0.1, 1000);
            
            // multiply matrices
            _mx.append(_viewMx);            
            _mx.append(_projMx);
            
            // camera's position
            _viewMx.invert();
            _camPos = _viewMx.position;
        }
        
        private function autoRotate():void {
            // update camera                    
            if (!_mousePos2d) {
                _cameraRotation.y += _dangle * 180 / Math.PI;
            }
        }
        
        private function render():void {
            if (!_ctx3d) return;
            
            _lightPos = _camPos;
            
            // init renderer for the new frame
            //_ctx3d.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
            //_ctx3d.setCulling(Context3DTriangleFace.FRONT);
            _ctx3d.clear(.5, .5, .5);
            
            // upload shaders
            _ctx3d.setProgram(_shaders);
            
            // upload constants
            // vertex
            _ctx3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _mx, true); // vc0 = a 4x4 transform matrix -> 4 registers (vc0-vc3)
            _ctx3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, Vector.<Number>([_lightPos.x, _lightPos.y, _lightPos.z, 0.0])); // vc4 = light's position
            _ctx3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, Vector.<Number>([_brush.x, _brush.y, _brush.z, _brush.w])); // vc5 = brush position (x,y=h,z, w = r^2)
            // fragment
            _ctx3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([_ambient, _ambient, _ambient, 1.0])); // fc0 = ambient
            _ctx3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Vector.<Number>([0.0, 1.0, 0.0, 1.0 / (_terrainStepsW + 1)])); // fc1.x = 0, fc1.y =1.0, fc1.w = nextUV
            
            // upload geometry
            _ctx3d.setVertexBufferAt(0, _vBuf,  0, Context3DVertexBufferFormat.FLOAT_3); // va0 = vertex xyz
            _ctx3d.setVertexBufferAt(1, _vBuf,  3, Context3DVertexBufferFormat.FLOAT_2); // va1 = texCoord uv
            _ctx3d.setVertexBufferAt(2, _vBuf,  5, Context3DVertexBufferFormat.FLOAT_3); // va2 = normal nnn    
            
            // upload texture
            _ctx3d.setTextureAt(0, _diffTex); // 0 means (fs0) in the fragment shader
            _ctx3d.setTextureAt(1, _bumpTex); // 0 means (fs1) in the fragment shader
            
            
            // draw!
            _ctx3d.drawTriangles(_iBuf, 0, _indices.length / 3);
            
            drawSnapshot();
            
            // backbuffer to the screen
            _ctx3d.present();
            
            // animate brush
            updateBrush();
        }
        
        private function updateBrush():void {
            var r:Number = 40;
            var h:Number = 20;
            var r0:Number = 10;
            _brush = new Vector3D(r * Math.sin(-_t), h * Math.sin(.5 * _t), r * Math.cos(-_t), r0 * r0 * (2 + Math.cos(.5 * _t)));
            _t += _dangle;
        }
        
        private function qualitySettings(low:*, high:*):* {
            if (_HQ) {
                return high;
            } else {
                return low;
            }
        }
        
        private function drawSnapshot():void {
            // render to texture if needed. should be called before _ctx3d.present();
            if (_needsSnapshot) {
                _needsSnapshot = false;
                _ctx3d.drawToBitmapData(_snapshot.bitmapData);
                _snapshot.visible = true;
                _needsSnapshot = false;
                
                // add text
                var tf:TextField = new TextField();
                tf.text = "This's a snapshot, press \"SPACE\" again to continue.";
                tf.autoSize = TextFieldAutoSize.LEFT;
                tf.textColor = 0xffffff;
                _snapshot.bitmapData.draw(tf);
            }
        }
        
        private function askForSnapshot():void {
            if (!_snapshot) {
                _snapshot = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false));
                addChild(_snapshot);
            }
            if (_snapshot.visible) {
                _snapshot.visible = false;
            } else {
                _needsSnapshot = true;
            }
        }
        
        private function keyboardHandler(e:KeyboardEvent):void {
            switch (e.keyCode) {
                case Keyboard.SPACE:
                    askForSnapshot();
                    break;
                default:
                    break;
            }
        }
        /// block
        
        private function initInteractivity():void {
            // mouse listeners
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDwn);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            
            // touch listeners
            Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
            stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
            stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
            stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
        }
        
        private function onMouseDwn(e:MouseEvent):void {
            _mousePos2d = new Vector3D(mouseX, mouseY);
        }
        
        private function onMouseUp(e:MouseEvent):void {
            _mousePos2d = null;
            _rotTime = getTimer();
        }
        
        private function onMouseMove(e:MouseEvent):void {
            if (!_mousePos2d) return;
            _cameraRotation.x += (mouseY - _mousePos2d.y) * 0.5;
            _cameraRotation.y += (mouseX - _mousePos2d.x) * 0.5;                    
            _mousePos2d = new Vector3D(mouseX, mouseY);
        }
        
        private function onMouseWheel(e:MouseEvent):void {
            var factor:Number = (e.delta > 0) ? 1.1 : 0.9;
            _cameraRadius *= factor;
        }
        
        private function onTouchBegin(e:TouchEvent):void {
            _mousePos2d = new Vector3D(e.stageX, e.stageY);
        }
        
        private function onTouchMove(e:TouchEvent):void { 
            if (!_mousePos2d) return;
            _cameraRotation.x += (e.stageY - _mousePos2d.y) * 0.5;
            _cameraRotation.y += (e.stageX - _mousePos2d.x) * 0.5;                    
            _mousePos2d = new Vector3D(e.stageX, e.stageY);
        }
        
        private function onTouchEnd(e:TouchEvent):void { 
            _mousePos2d = null;
            _rotTime = getTimer();
        }
        
        private function projMatrix(FOV:Number, aspect:Number, zNear:Number, zFar:Number):Matrix3D {
            var sy:Number = 1.0 / Math.tan(FOV * Math.PI / 360.0),
                sx:Number = sy / aspect;
            return new Matrix3D(Vector.<Number>([
                    sx, 0.0, 0.0, 0.0,
                    0.0, sy, 0.0, 0.0,
                    0.0, 0.0, zFar / (zNear - zFar), -1.0,
                    0.0, 0.0, (zNear * zFar) / (zNear - zFar), 0.0]));
        }
        
        private function viewMatrix(rot:Vector3D, dist:Number, centerY:Number):Matrix3D {
            var m:Matrix3D = new Matrix3D();
            m.appendTranslation(0, -centerY, 0);
            m.appendRotation(rot.z, new Vector3D(0, 0, 1));
            m.appendRotation(rot.y, new Vector3D(0, 1, 0));            
            m.appendRotation(rot.x, new Vector3D(1, 0, 0));
            m.appendTranslation(0, 0, -dist);
            return m;
        }
        
        private function readModel():void {
            TerrainMesh.createGeometry(_terrainW, _terrainH, _terrainStepsW, _terrainStepsH);
            TerrainMesh.createTexture();
            //TerrainMesh.calculateNormals();
            
            // texture
            _texture = TerrainMesh.texture;
            
            // geometry
            _verts = new Vector.<Number>();
            _indices = new Vector.<uint>();
            var i:uint;
            for (i = 0; i < TerrainMesh.vertices.length / 3; i++) {
                // xyz
                _verts.push(TerrainMesh.vertices[3*i]);
                _verts.push(TerrainMesh.vertices[3*i+1]);
                _verts.push(TerrainMesh.vertices[3*i+2]);
                // uv
                _verts.push(TerrainMesh.uvs[2*i]);
                _verts.push(TerrainMesh.uvs[2 * i + 1]);
                // nxnynz
                _verts.push(TerrainMesh.normals[3*i]);
                _verts.push(TerrainMesh.normals[3*i+1]);
                _verts.push(TerrainMesh.normals[3*i+2]);
            }
            for (i = 0; i < TerrainMesh.indices.length; i++) {
                _indices.push(TerrainMesh.indices[i]);
            }
        }
        
        // 2d stuff
        private function initPerlinTerrain():void {
            _hmap = new PerlinHeightMap(_terrainStepsW + 1, _terrainStepsH + 1);
            _hmapHolder = new Bitmap(_hmap);
            _hmapHolder.width = _hmapHolder.height = 50;
            addChild(_hmapHolder);
            
            /*var s:Shape = new Shape();
            s.graphics.beginFill(0);
            s.graphics.drawRect(0, 0, _terrainStepsW, _terrainStepsH);
            s.graphics.endFill();
            s.graphics.beginFill(0xffffff);
            s.graphics.drawCircle(_terrainStepsW / 4, _terrainStepsH / 4, _terrainStepsW / 4);
            s.graphics.drawCircle(_terrainStepsW * 3 / 4, _terrainStepsH * 3 / 4, _terrainStepsW / 8);
            s.graphics.endFill();
            _hmap.draw(s);*/
            
            _bumpTex = createTexture(BitmapCalculator.resize(_hmap, 128, 128), false);
        }
        
        private function updatePerlin(e:Event = null):void {
            _hmap.update();
            
            doDisplacement();
        }
        
        private function doDisplacement():void {
            // get heightmap
            var pixels:Vector.<uint> = _hmap.getVector(_hmap.rect);
            
            // update vertex data
            // each vertex has 8 values: "x,y,z,u,v,nx,ny,nz"
            var numVerts:uint = _verts.length / _vStride;
            var i:uint = numVerts;
            while (i > 0) { // the reverse "while" loop is the fastest one
                // y_index = i * stride + 1
                if (i < pixels.length) {
                    //ix = i - i % (_terrainStepsH + 1);
                    _verts[i * _vStride + 1] = _terrainW * .3 * BitmapCalculator.grayRGBColorToFloat(pixels[i]);
                }
                --i;
            }
            
            // update vertex buffer
            _vBuf.uploadFromVector(_verts, 0, _verts.length / _vStride);
            
            // convert heightmap to texture
            //_bumpTex.dispose();
            _bumpTex = createTexture(_hmap, false);
        }
    }
    
}

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.*;
    
class TerrainMesh {
    public static var vertices:Array = [];
    public static var indices:Array = [];
    public static var uvs:Array = [];
    public static var normals:Array = [];
    public static var texture:BitmapData;
    
    public static function createGeometry(w:Number = 100, h:Number = 100, nW:uint = 16, nH:uint = 16):void {
        // vertices
        var x:Number, y:Number;
        var xi:uint, yi:uint;
        var square:uint;
        var tiles_w:uint = nW + 1;
        //var numVertices:uint = (nH + 1) * (nW + 1);
        //var numIndices:uint = nH * nW * 6;

        vertices = new Array();
        indices = new Array();
        uvs = new Array();
        normals = new Array();
        
        for (yi = 0; yi <= nH; yi++) {
            for (xi = 0; xi <= nW; xi++) {
                x = (xi / nW - .5) * w;
                y = (yi / nH - .5) * h;

                vertices.push(x);
                vertices.push(0);
                vertices.push(y);
                
                uvs.push(xi / nW);
                uvs.push(yi / nH);
                
                normals.push(0);
                normals.push(1);
                normals.push(0);
                
                if (xi != nW && yi != nH) {
                    square = yi * tiles_w + xi;
                    
                    indices.push(square);
                    indices.push(square + tiles_w);
                    indices.push(square + tiles_w + 1);
                    indices.push(square);
                    indices.push(square + tiles_w + 1);
                    indices.push(square + 1);
                }
            }
        }
    }
    
    public static function createTexture():void {
        var bmpsize:uint = 1024;
        var cellsize:uint = 32;
        var alpha:Number = 1;
        var color:uint = 0x00ccff;
        var checkerBmd:BitmapData = new BitmapData(bmpsize, bmpsize, false, 0xffffff);
        var i:uint, j:uint;
        var size:uint = cellsize;
        var checker:Sprite = new Sprite();
        checker.graphics.beginFill(color, alpha);
        for (i = 0; i < checkerBmd.width / size; i++) {
            for (j = 0; j < checkerBmd.height / size; j++) {
                with (checker.graphics) {
                    drawRect((2 * i + j % 2) * size, j * size, size, size);
                }
            }
        }
        checker.graphics.endFill();
        checkerBmd.draw(checker);
        
        texture = checkerBmd;
    }
    
    public static function calculateNormals():void {
        // 3 points of a triangle
        var p:Vector.<Vector3D>;
        // 2 adjacent edges of a triangle sharing the same origin (point 0)
        var e01:Vector3D;
        var e02:Vector3D;
        // a normal
        var n:Vector3D;
        
        // fill the initial array of normals
        var norms:Array = new Array(vertices.length, true);
        
        var i:uint;
        var j:uint;
        var k:uint;
        // for each triangle in mesh
        for (i = 0; i < indices.length; i++) {
            // get the coordinates of each 3 points of a face
            p = new Vector.<Vector3D>();
            for (j = 0; j < 3; j++) {
                k = indices[3 * i + j]; // index of a j-th point of a triangle
                p.push(new Vector3D(vertices[3 * k], vertices[3 * k + 1], vertices[3 * k + 2]));
            }
            // compute vectors of edges
            e01 = p[1].subtract(p[0]);
            e02 = p[2].subtract(p[0]);
            // compute the normal and normalize (convert to unit vector)
            n = e01.crossProduct(e02);
            n.normalize();
            // save the faceted normal
            for (j = 0; j < 3; j++) {
                k = indices[3 * i + j]; // index of a j-th point of a triangle
                // assume, that for each 3 points of a trinagle the normal is the same
                norms[3 * k] = n.x;
                norms[3 * k + 1] = n.y;
                norms[3 * k + 2] = n.z;
            }
        }
        normals = norms;
    }
}

class PerlinHeightMap extends BitmapData {
    private var _baseX:Number;
    private var _baseY:Number;
    private var _octaves:uint; 
    private var _speed:Number;
    private var _movX:Number;
    private var _movY:Number;
    
    private var _tile:uint = 5;
    private var _lim:Number;
    private var _offsets:Array = [0];
    private var _i:uint = 0;
    
    public function PerlinHeightMap($width:uint, $height:uint,
        octaves:uint = 2, movX:Number = .1, movY:Number = 1) {
        
        _baseX = $width / _tile;
        _baseY = $height / _tile;
        _octaves = octaves;
        _speed = .07 * (_baseX + _baseY) / 2;
        _movX = movX;
        _movY = movY;
        
        super($width, $height, false, 0);
        _lim = 1000 * _tile * this.width;
    }
    
    public function update():void {
        _offsets[0] = new Point(_i * _movX * _speed, _i * _movY * _speed);
        this.perlinNoise(_baseX, _baseY, _octaves, 1, true, true, 7, true, _offsets);
        _i = (_i > _lim) ? 0 : _i + 1;
    }
}

import flash.geom.Point;
import flash.display.BlendMode;
import flash.geom.Matrix;

/**
 * Flash is extremely fast in manipulating bitmaps, so let's use it for arrays
 * Note: "a" and "b" operands must be the same size (width x height)
 */
class BitmapCalculator {
    /*public static function colorToFloat(a:BitmapData):Number {
        var multiplier
        var c:BitmapData = new BitmapData(a.width, a.height, false, 0);
    }*/
    
    /**
     * c = a
     */
    public static function copy(a:BitmapData):BitmapData {
        var c:BitmapData = new BitmapData(a.width, a.height, false, 0);
        c.copyPixels(a, a.rect, new Point());
        return c;
    }
    
    /**
     * c = a + b
     */
    public static function add(a:BitmapData, b:BitmapData):BitmapData {
        var c:BitmapData = copy(a);
        c.draw(b, null, null, BlendMode.ADD);
        return c;
    }
    
    /**
     * c = a - b
     */
    public static function subtract(a:BitmapData, b:BitmapData):BitmapData {
        var c:BitmapData = copy(a);
        c.draw(b, null, null, BlendMode.SUBTRACT);
        return c;
    }
    
    /**
     * c = a * b
     */
    public static function multiply(a:BitmapData, b:BitmapData):BitmapData {
        var c:BitmapData = copy(a);
        c.draw(b, null, null, BlendMode.MULTIPLY);
        return c;
    }
    
    /**
     * c = [v,v,....v]
     */
    public static function dataOf(w:Number, h:uint, v:Number):BitmapData {
        return new BitmapData(w, h, false, v);
    }
    
    /**
     * c = [a*f, a*f, ... a*f]
     */
    public static function multiplyBy(a:BitmapData, f:Number):BitmapData {
        var b:BitmapData = dataOf(a.width, a.height, f);
        return multiply(a, b);
    }
    
    public static function grayRGBColorToFloat(rgb:uint):Number {
        return ( rgb & 0xff ) / 255;
    }
    
    public static function resize(a:BitmapData, w:uint, h:uint):BitmapData {
        var c:BitmapData = new BitmapData(w, h, false);
        var mx:Matrix = new Matrix();
        mx.scale(w / a.width, h / a.height);
        c.draw(a);
        return c;
    }
}