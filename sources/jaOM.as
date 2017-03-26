package
{
    /**
     * "God Rays" / Fake Volumetric lighting.. 
     * See: http://http.developer.nvidia.com/GPUGems3/gpugems3_ch13.html
     * @author Devon O.
     */
    
    import com.adobe.utils.AGALMiniAssembler;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.textures.Texture;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;

    [SWF(width="465", height="465", frameRate="60", backgroundColor="#000000")]
    public class VolumetricLight extends Sprite
    {
        public static const NUM_SAMPLES:int = 30;
        
        // lightx, lighty
        private var lightPos:Vector.<Number> = Vector.<Number>( [ .5, .5, 1, 1 ]);
        
        // numsamples, density, numsamples * density, 1 / numsamples * density
        private var values1:Vector.<Number> = Vector.<Number>( [ 1, 1, 1, 1 ]);
        
        // weight, decay, exposure
        private var values2:Vector.<Number> = Vector.<Number>( [ 1, 1, 1, 1 ]);    
        
        private var context3d:Context3D;
        private var vertBuffer:VertexBuffer3D;
        private var indexBuffer:IndexBuffer3D; 
        private var program:Program3D;
        private var matrix:Matrix3D = new Matrix3D();
        private var textureData:BitmapData;
        
        public function VolumetricLight()
        {    
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);    
        }
        
        private function init(event:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            initStage();
            loadImage();
            
            addEventListener(Event.ENTER_FRAME, onTick);
        }
        
        
        private function loadImage():void {
            var l:Loader = new Loader();
            l.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoad);
            l.load(new URLRequest("http://assets.wonderfl.net/images/related_images/5/5f/5f28/5f28b9db30e27c26c176844b8cf5ac1d3ba0286e"), new LoaderContext(true));
        }
        
        private function onImageLoad(event:Event = null):void
        {
            event.currentTarget.removeEventListener(Event.COMPLETE, onImageLoad);
            var l:Loader = (event.currentTarget as LoaderInfo).loader;
            this.textureData = (l.content as Bitmap).bitmapData;    
            stage.stage3Ds[0].addEventListener( Event.CONTEXT3D_CREATE, initStage3d );
            stage.stage3Ds[0].requestContext3D();
        }
        
        private function initStage():void
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
        }
        
        private function initStage3d(event:Event):void
        {
            this.context3d = stage.stage3Ds[0].context3D;            
            this.context3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 1, true);
            
            var vertices:Vector.<Number> = Vector.<Number>([
            //      x         y        z            u  v
                -1.0,  -1.0,     0,          0, 0, 
                -1.0,      1.0,     0,             0, 1,
                 1.0,      1.0,     0,             1, 1,
                 1.0,  -1.0,     0,            1, 0  ]);
                 
            
            this.vertBuffer = this.context3d.createVertexBuffer(4, 5);
            this.vertBuffer.uploadFromVector(vertices, 0, 4);

            this.indexBuffer = this.context3d.createIndexBuffer(6);            
            this.indexBuffer.uploadFromVector (Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);
            
            this.texture = this.context3d.createTexture(this.textureData.width, this.textureData.height, Context3DTextureFormat.BGRA, true);
            this.texture.uploadFromBitmapData(this.textureData);
            
            this.context3d.setVertexBufferAt(0, this.vertBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            this.context3d.setVertexBufferAt(1, this.vertBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
            
            generateProgram();
        }
        
        
        private function generateProgram():void
        {
            var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
            vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
                "m44 op, va0, vc0        \n" +
                "mov v0, va1              "
            );
            
            var frag:String = "";
            
            // Calculate vector from pixel to light source in screen space.
            frag += "sub ft0.xy, v0.xy, fc0.xy \n";
            
            // Divide by number of samples and scale by control factor.  
            frag += "mul ft0.xy, ft0.xy, fc1.ww \n";
            
            // Store initial sample.  
            frag += "tex ft1,  v0, fs0 <2d, clamp, linear, mipnone> \n";
            
            // Set up illumination decay factor.  
            frag += "mov ft2.x, fc0.w \n";
            
            // Store the texcoords
            frag += "mov ft4.xy, v0.xy \n";
            
            for (var i:int = 0; i < NUM_SAMPLES; i++)
            {
                // Step sample location along ray. 
                frag += "sub ft4.xy, ft4.xy, ft0.xy \n";
                
                // Retrieve sample at new location.  
                frag += "tex ft3,  ft4.xy, fs0 <2d, clamp, linear, mipnone> \n";
                
                // Apply sample attenuation scale/decay factors.  
                frag += "mul ft2.y, ft2.x, fc2.x \n";
                frag += "mul ft3.xyz, ft3.xyz, ft2.yyy \n";
                
                // Accumulate combined color.  
                frag += "add ft1.xyz, ft1.xyz, ft3.xyz \n";
                
                // Update exponential decay factor.  
                frag += "mul ft2.x, ft2.x, fc2.y \n";
            }
            
            // Output final color with a further scale control factor. 
            frag += "mul ft1.xyz, ft1.xyz, fc2.zzz \n";
            frag += "mov oc, ft1";

            var fragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
            fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT, frag);
            
            this.program = this.context3d.createProgram();
            this.program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
        }
        
        private var texture:Texture;
        private function onTick(event:Event):void
        {
            if ( !this.context3d ) 
                return;
            
            this.context3d.clear ( 0, 0, 0, 1 );
            this.context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, this.matrix, true);
            this.context3d.setTextureAt(0, this.texture);
            this.context3d.setProgram(this.program);
            
            // light position
            this.lightPos[0] = stage.mouseX / stage.stageWidth;
            this.lightPos[1] = (stage.stageHeight - stage.mouseY) / stage.stageHeight;
            
            // numsamples, density, numsamples * density, 1 / numsamples * density
            this.values1[0] = NUM_SAMPLES;
            this.values1[1] = 2.25;
            this.values1[2] = NUM_SAMPLES * values1[1];
            this.values1[3] = 1 / values1[2];
            
            // weight, decay, exposure
            this.values2[0] = .50;
            this.values2[1] = .87;
            this.values2[2] = .35;
            
            this.context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.lightPos, 1 );    
            this.context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.values1,  1 );
            this.context3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, this.values2,  1 );
            
            this.context3d.drawTriangles(this.indexBuffer);
            this.context3d.present();
            
        }
    }
}