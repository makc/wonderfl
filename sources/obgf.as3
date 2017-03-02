package 
{
    
    import com.adobe.utils.*;
    import flash.display.*;
    import flash.display3D.*;
    import flash.display3D.textures.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    import flash.text.*;
    import net.hires.debug.Stats;
    
    
    [SWF(width="465", height="465", frameRate="60", backgroundColor="#000000")]
    public class Main extends Sprite 
    {
        
        private const VERTEX_BUFFER_STEP:int = 14;
        
        //[Embed (source = "rock_d.jpg")] private var RockDiffuse:Class;
        //[Embed (source = "rock_n.png")] private var RockNormal:Class;
        
        private var dTexture:Texture;
        private var nTexture:Texture;
        
        private const swfWidth:int = 465;
        private const swfHeight:int = 465;
        private const textureSize:int = 512;
         
        private var context3D:Context3D;
        
        private var shaderProgram:Program3D;
        
        private var vertexBuffer:VertexBuffer3D;
        private var indexBuffer:IndexBuffer3D;
        private var meshVertexData:Vector.<Number>;
        private var meshIndexData:Vector.<uint>;
        
        private var camRot:Vector3D = new Vector3D(25, 0);
        private var lightPos:Vector.<Number> = Vector.<Number>([0, 0, 10, 0.0]); 
        private var ambient:Vector.<Number> = Vector.<Number>([0.25, 0.25, 0.25, 1.0]);
        private var specular:Vector.<Number> = Vector.<Number>([1.0, 1.0, 1.0, 16.0]);

        private var t:Number = 0;
        private var looptemp:int = 0;
        
        private var _bitmapData:BitmapData = new BitmapData(swfWidth, swfHeight);
        private var _bitmap:Bitmap = new Bitmap(_bitmapData);
        private var _filter:BloomFilter = new BloomFilter();        
    
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
            
            _filter._mix = 0.15;
            _filter._threshold = 100;
            
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            // entry point            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
            stage.stage3Ds[0].requestContext3D();
            
            addChild(_bitmap);
            _bitmapData.fillRect(_bitmapData.rect, 0x000000);
            addChild(new Stats());
        }
                
        private function onContext3DCreate(event:Event):void {
            removeEventListener(Event.ENTER_FRAME,enterFrame);
             
            var t:Stage3D = event.target as Stage3D;   
            context3D = t.context3D;   

            
            if (context3D == null) {
                return;
            }    
            
            context3D.enableErrorChecking = true;            
            initData();            
            
            context3D.configureBackBuffer(swfWidth, swfHeight, 0, true);
            
            initShaders();
            
            indexBuffer = context3D.createIndexBuffer(meshIndexData.length);
            indexBuffer.uploadFromVector(meshIndexData, 0, meshIndexData.length);

            vertexBuffer = context3D.createVertexBuffer(meshVertexData.length/VERTEX_BUFFER_STEP, VERTEX_BUFFER_STEP); 
            vertexBuffer.uploadFromVector(meshVertexData, 0, meshVertexData.length/VERTEX_BUFFER_STEP);
             
        //    nTexture = loadTexture(RockNormal);                
        //    dTexture = loadTexture(RockDiffuse);
        
            new AssetsLoader().loadURL("http://farm8.staticflickr.com/7013/6734664957_7d67b885cf_z.jpg", loadTexture1);        
            
        }        
        
        private function loadTexture1(data:BitmapData):void {
            dTexture = loadTextureFromData(data);
            new AssetsLoader().loadURL("http://farm8.staticflickr.com/7146/6734665121_c0bdf6b5c3_z.jpg", loadTexture2);
        }
        
        private function loadTexture2(data:BitmapData):void {
                nTexture = loadTextureFromData(data)
                addEventListener(Event.ENTER_FRAME,enterFrame);    
        }
        
        private function loadTexture(MapClass:Class):Texture {            
            var    bmp:BitmapData = (new MapClass() as Bitmap).bitmapData,
                mip:BitmapData = bmp,
                tex:Texture = context3D.createTexture(bmp.width, bmp.height, Context3DTextureFormat.BGRA, false),
                level:int = 0;
            tex.uploadFromBitmapData(bmp, level++);
            // MipMap levels
            while (bmp.width > 1 || bmp.height > 1) {                    
                mip = new BitmapData(Math.max(1, bmp.width >> 1), Math.max(1, bmp.height >> 1), true, 0);
                mip.draw(bmp, new Matrix(0.5, 0, 0, 0.5, 0, 0), null, null, null, true);
                tex.uploadFromBitmapData(mip, level++);
                bmp = mip;
            }
            return tex;
        }
        
        private function loadTextureFromData(bitmapData:BitmapData):Texture {            
            var    bmp:BitmapData = bitmapData,
                mip:BitmapData = bmp,
                tex:Texture = context3D.createTexture(bmp.width, bmp.height, Context3DTextureFormat.BGRA, false),
                level:int = 0;
            tex.uploadFromBitmapData(bmp, level++);
            // MipMap levels
            while (bmp.width > 1 || bmp.height > 1) {                    
                mip = new BitmapData(Math.max(1, bmp.width >> 1), Math.max(1, bmp.height >> 1), true, 0);
                mip.draw(bmp, new Matrix(0.5, 0, 0, 0.5, 0, 0), null, null, null, true);
                tex.uploadFromBitmapData(mip, level++);
                bmp = mip;
            }
            return tex;
        }
    
        private function initShaders():void {         

            var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexShaderAssembler.assemble (Context3DProgramType.VERTEX,
                'm44 op, va0, vc0\n' +        // position = vertex * viewProjMatrix (output)
                'mov v0, va1\n' +             // v0 = texCoord
                // transform lightVec
                'sub vt1, vc4, va0\n' +        // vt1 = lightPos - vertex (lightVec)                    
                'dp3 vt3.x, vt1, va4\n' +
                'dp3 vt3.y, vt1, va3\n' +
                'dp3 vt3.z, vt1, va2\n' +
                'mov v2, vt3.xyzx\n' +        // v2 = lightVec
                // transform viewVec
                'sub vt2, va0, vc5\n' +        // vt2 = viewPos - vertex (viewVec)
                'dp3 vt4.x, vt2, va4\n' +
                'dp3 vt4.y, vt2, va3\n' +
                'dp3 vt4.z, vt2, va2\n' +                    
                'mov v3, vt4.xyzx\n'        // v3 = viewVec
            );
        
            var fragmentShaderAssembler:AGALMiniAssembler  = new AGALMiniAssembler();
            fragmentShaderAssembler.assemble (Context3DProgramType.FRAGMENT,  
                'tex ft0, v0, fs0 <2d,repeat,linear,miplinear>\n' +  
                'tex ft1, v0, fs1 <2d,repeat,linear,miplinear>\n' +    // ft1 = normalMap(v0)
                // 0..1 to -1..1
                'add ft1, ft1, ft1\n' +                // ft1 *= 2
                'sub ft1, ft1, fc0.z\n' +            // ft1 -= 1
                'nrm ft1.xyz, ft1\n' +                // normal ft1 = normalize(normal)
                'nrm ft2.xyz, v2\n' +                // lightVec    ft2 = normalize(lerp_lightVec)
                'nrm ft3.xyz, v3\n' +                // viewVec    ft3 = normalize(lerp_viewVec)
                // calc reflect vec (ft4)
                'dp3 ft4.x, ft1.xyz ft3.xyz\n'+        // ft4 = dot(normal, viewVec)
                'mul ft4, ft1.xyz, ft4.x\n'+        // ft4 *= normal
                'add ft4, ft4, ft4\n'+                // ft4 *= 2                    
                'sub ft4, ft3.xyz, ft4\n' +            // reflect    ft4 = viewVec - ft4
                // lambert shading
                'dp3 ft5.x, ft1.xyz, ft2.xyz\n'+    // ft5 = dot(normal, lightVec)
                'max ft5.x, ft5.x, fc0.x\n'+        // ft5 = max(ft5, 0.0)                    
                'add ft5, fc1, ft5.x\n'+            // ft5 = ambient + ft5
                'mul ft0, ft0, ft5\n' +                // color *= ft5
                // phong shading
                'dp3 ft6.x, ft2.xyz, ft4.xyz\n' +    // ft6 = dot(lightVec, reflect)
                'max ft6.x, ft6.x, fc0.x\n' +        // ft6 = max(ft6, 0.0)
                'pow ft6.x, ft6.x, fc2.w\n' +        // ft6 = pow(ft6, specularPower)
                'mul ft6, ft6.x, fc2.xyz\n' +        // ft6 *= specularLevel
                'add ft0, ft0, ft6\n' +                // color += ft6
                'mov oc, ft0\n'                     // output
                
            );              

            shaderProgram = context3D.createProgram();
            shaderProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);         
              
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
        
        
        
        private function initData():void {
 
            meshIndexData = Vector.<uint> ([
                0, 1, 2,     0, 2, 3,   // Forward   
                4, 5, 6,     4, 6, 7,   // Backward
                8, 9, 10,    8, 10,11,  // Top
                12,13,14,    12,14,15,  // Bottom 
                16,17,18,    16,18,19,  // Left
                20,21,22,    20,22,23,  // Right     
                
                
            ]);
         
            // Cube model
            meshVertexData = Vector.<Number>  ([
                //X,  Y,  Z,   U, V,   nX, nY, nZ   bX, bY, bZ   tX, tY, tZ 
                // Forward
                -1, -1,  1,   0, 0,   0,  0,  1,   1,  0,  0,   0,  1,  0,
                 1, -1,  1,   1, 0,   0,  0,  1,   1,  0,  0,   0,  1,  0,
                 1,  1,  1,   1, 1,   0,  0,  1,   1,  0,  0,   0,  1,  0,
                -1,  1,  1,   0, 1,   0,  0,  1,   1,  0,  0,   0,  1,  0,
                
                // Backward
                 1, -1, -1,   0, 0,   0,  0, -1,  -1,  0,  0,   0,  1,  0,
                -1, -1, -1,   1, 0,   0,  0, -1,  -1,  0,  0,   0,  1,  0,
                -1,  1, -1,   1, 1,   0,  0, -1,  -1,  0,  0,   0,  1,  0,
                 1,  1, -1,   0, 1,   0,  0, -1,  -1,  0,  0,   0,  1,  0,
                
                // Top
                -1, -1, -1,   0, 0,   0, -1,  0,   1,  0,  0,   0,  0,  -1,
                 1, -1, -1,   1, 0,   0, -1,  0,   1,  0,  0,   0,  0,  -1,
                 1, -1,  1,   1, 1,   0, -1,  0,   1,  0,  0,   0,  0,  -1,
                -1, -1,  1,   0, 1,   0, -1,  0,   1,  0,  0,   0,  0,  -1,
                
                // Bottom
                -1,  1,  1,   0, 0,   0,  1,  0,   1,  0,  0,   0,  0, -1,
                 1,  1,  1,   1, 0,   0,  1,  0,   1,  0,  0,   0,  0, -1,
                 1,  1, -1,   1, 1,   0,  1,  0,   1,  0,  0,   0,  0, -1,
                -1,  1, -1,   0, 1,   0,  1,  0,   1,  0,  0,   0,  0, -1,                 
                
                // Left
                -1, -1, -1,   0, 0,  -1,  0,  0,   0,  0,  1,   0,  1,  0,
                -1, -1,  1,   1, 0,  -1,  0,  0,   0,  0,  1,   0,  1,  0,
                -1,  1,  1,   1, 1,  -1,  0,  0,   0,  0,  1,   0,  1,  0,
                -1,  1, -1,   0, 1,  -1,  0,  0,   0,  0,  1,   0,  1,  0,
                
                // Right
                 1, -1,  1,   0, 0,   1,  0,  0,   0,  0, -1,   0,  1,  0,
                 1, -1, -1,   1, 0,   1,  0,  0,   0,  0, -1,   0,  1,  0,
                 1,  1, -1,   1, 1,   1,  0,  0,   0,  0, -1,   0,  1,  0,
                 1,  1,  1,   0, 1,   1,  0,  0,   0,  0, -1,   0,  1,  0, 
                
            ]);                
        }
        
        private function enterFrame(e:Event):void  {            
                    
            
            var mViewProj:Matrix3D = new Matrix3D();
            var    mView:Matrix3D = viewMatrix(camRot, 5.7, 0.5);
            var    mProj:Matrix3D = projMatrix(45, stage.stageWidth / stage.stageHeight, 0.1, 1000);
            mViewProj.append(mView);            
            mViewProj.append(mProj);
            
            camRot.x = - 100 * Math.sin(t / 800);
            camRot.y = -100 * Math.cos(t / 800);
                    
            mView.invert();
            var viewPos:Vector3D = mView.position;        
            
            camRot.x = 100 * Math.sin(t / 200);
            camRot.z = 100 * Math.sin(t / 200);            
            
            lightPos[0] = viewPos.x;
            lightPos[1] = viewPos.y;
            lightPos[2] = viewPos.z - 4;
            
            context3D.clear(0, 0, 0);     
            context3D.setDepthTest(true, Context3DCompareMode.LESS_EQUAL);
            context3D.setCulling(Context3DTriangleFace.FRONT);
            t += 2.0;         
        
            context3D.setProgram (shaderProgram);            

            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mViewProj, true ); // vc0      
            context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, lightPos);  // vc4
            context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, Vector.<Number>([viewPos.x, viewPos.y, viewPos.z, 0.0])); // vc5
            context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([0.0, 0.5, 1.0, 2.0])); // Constants (fc0)
            context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, ambient); // ambient  (fc1)
            context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, specular); // specular  (fc2)
            
            // Vertex buffer
            context3D.setVertexBufferAt(0, vertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3);    // va0 = vertex
            context3D.setVertexBufferAt(1, vertexBuffer,  3, Context3DVertexBufferFormat.FLOAT_2);    // va1 = texCoord
            context3D.setVertexBufferAt(2, vertexBuffer,  5, Context3DVertexBufferFormat.FLOAT_3);    // va2 = normal    
            context3D.setVertexBufferAt(3, vertexBuffer,  8, Context3DVertexBufferFormat.FLOAT_3);    // va3 = binormal
            context3D.setVertexBufferAt(4, vertexBuffer, 11, Context3DVertexBufferFormat.FLOAT_3);    // va4 = tangent
            context3D.setTextureAt(0, dTexture);  // Diffuse texture
            context3D.setTextureAt(1, nTexture);  // Normal texture

            context3D.drawTriangles(indexBuffer, 0, meshIndexData.length/3);          

            context3D.drawToBitmapData(_bitmapData); 
            _filter.Process(_bitmapData);
            context3D.present();    
            
                         
        }        
    }    
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;

/**
* ...
* @author Ben Hopkins
*/
        
class BloomFilter 
{               
    private var _downSampleWidth:Number;
    private var _downSampleHeight:Number;
    private var _buffer:BitmapData;
    public var _mul:Number;
    public var _mix:Number;
    public var _threshold:uint;
                
    public function BloomFilter() 
    {
        _downSampleWidth = 0.25;
        _downSampleHeight = 0.25;
        _mul = 0.9;
        _mix = 0.1;
        _threshold = 100;
    }
                
    public function Process( source:BitmapData):void 
    {
        var w:uint = source.width * _downSampleWidth;
        var h:uint = source.height * _downSampleHeight;
        var matrix:Matrix = new Matrix();
        var point:Point = new Point( 0, 0);
        var colorTransform:ColorTransform = new ColorTransform();
                        
        // Color matrix for grayscale
        var a:Array = [ 0.33, 0.59, 0.11, 0, 0,   
                        0.33, 0.59, 0.11, 0, 0,  
                        0.33, 0.59, 0.11, 0, 0,   
                        0,0,0,1,0 ]; 
        var colorMatrix:ColorMatrixFilter = new ColorMatrixFilter( a);
        var blur:BlurFilter = new BlurFilter( 10, 10, 3);
                        
                        
        matrix.scale( _downSampleWidth, _downSampleHeight);
                        
        var downSampled:BitmapData = new BitmapData( w, h, true, 0);    
                        
        if( _buffer == null) 
           _buffer = new BitmapData( w, h, false, 0);
                                
        downSampled.draw( source, matrix);
                        
        var grayscale:BitmapData = downSampled.clone();
        grayscale.applyFilter( downSampled, downSampled.rect, point, colorMatrix);
                        
        downSampled.threshold( grayscale, downSampled.rect, point, "<", _threshold, 0, 0x000000ff);
        downSampled.applyFilter( downSampled, _buffer.rect, point, blur);               
                        
        colorTransform.alphaMultiplier = _mul;
        colorTransform.redMultiplier = _mul;
        colorTransform.greenMultiplier = _mul;
        colorTransform.blueMultiplier = _mul;   
                        
        _buffer.draw( _buffer, null, colorTransform);           
                        
        colorTransform.alphaMultiplier = _mix;
        colorTransform.redMultiplier = 1;
        colorTransform.greenMultiplier = 1;
        colorTransform.blueMultiplier = 1;
        _buffer.draw( downSampled, null, colorTransform);
                        
        matrix.invert();
        source.draw( _buffer, matrix, null, BlendMode.ADD, null, true);
    }
}


    import flash.net.*; 
    import flash.display.*;
    import flash.events.*;
    import flash.net.FileReference;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    
    class AssetsLoader extends Sprite {

        private var loader:Loader;
        private var file:FileReference;
        private var _onLoad:Function;
        
        public function AssetsLoader() {}
        
        public function loadURL(url:String, onLoad:Function):void
        {
            loader = new Loader;
            loader.contentLoaderInfo.addEventListener (Event.COMPLETE, init);
                  loader.load (new URLRequest (url),
                  new LoaderContext (true));                  
            _onLoad = onLoad;
        }
        
        public function init (e:Event):void {
            _onLoad(loader.content["bitmapData"]);     
            
        }      

    }

