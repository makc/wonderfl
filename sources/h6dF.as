package 
{
    
import com.adobe.utils.AGALMiniAssembler;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.StageAlign;
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
import flash.geom.Matrix3D;
import flash.utils.setTimeout;

/**
 * @author Devon O.
 */

[SWF(width='465', height='465', backgroundColor='#000000', frameRate='60')]
public class Main extends Sprite 
{
 
    private static var VERTEX_SHADER:String =
    <![CDATA[
    
    m44 op, va0, vc0
    mov v0, va1 
    
    ]]>;
    
    
    private static var FRAGMENT_SHADER:String =
    <![CDATA[
    
    // slow cloud
    mov ft0.x, fc0.x 
    mov ft0.y, fc0.w
    add ft0.xy, ft0.xy, v0.xy
    tex ft1, ft0.xy, fs0<2d, wrap, linear, mipnone>
    
    // fast cloud
    mov ft0.x, fc1.w
    mov ft0.y, fc2.w
    add ft0.xy, ft0.xy, v0.xy
    tex ft6, ft0.xy, fs0<2d, wrap, linear, mipnone>
    
    // blend clouds
    mul ft1, ft1, ft6
    
    // get intensity
    add ft2.x, ft1.x, ft1.y
    add ft2.x, ft2.x, ft1.z
    div ft2.x, ft2.x, fc0.y
    
    // mix sky color and cloud color according to intesity
    mov ft3.xyz, fc1.xyz 
    sub ft4.xyz, fc2.xyz, ft3.xyz 
    mul ft4.xyz, ft4.xyz, ft2.xxx
    add ft4.xyz, ft4.xyz, ft3.xyz
    
    // multiply by light intensity
    mul ft4.xyz, ft4.xyz, fc0.zzz 
    
    // clamp
    sat ft4.xyz, ft4.xyz
    mov ft4.w, fc0.w
    
    mov oc, ft4
    
    ]]>;
    
    private var context:Context3D;
    private var isReady:Boolean;
    private var program:Program3D;
    private var renderMatrix:Matrix3D;
    private var vertexBuffer:VertexBuffer3D;
    private var indexBuffer:IndexBuffer3D;
    private var textureData:BitmapData;
    private var texture:Texture;
    private var textureWidth:int;
    private var textureHeight:int;
    
    public function Main():void 
    {
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }
    
    private function init(e:Event = null):void 
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        this.isReady = false;
        this.renderMatrix = new Matrix3D();
        
        createNoise();
        requestContext();
        startRender();
    }
    
    private function createNoise():void 
    {
        var dat:BitmapData = new BitmapData(1024, 512, false, 0x0);
        dat.perlinNoise(256, 256, 20, int(Math.random() * 9999), true, true, 7, true);
        this.textureData = dat;
    }
    
    private function onImageLoad(event:Event=null):void
    {
        event.currentTarget.removeEventListener(Event.COMPLETE, onImageLoad);
        var l:Loader = (event.currentTarget as LoaderInfo).loader;
        this.textureData = (l.content as Bitmap).bitmapData;    
        
        requestContext();
    }
    
    private function startRender():void
    {
        addEventListener(Event.ENTER_FRAME, onFrame);
    }
    
    private function requestContext():void
    {
        stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onStage3dContext);
        stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
    }
    
    private function onStage3dContext(e:Event):void
    {
        this.context = stage.stage3Ds[0].context3D;
        this.context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 1, false, false);
        
        createVertexBuffer();
        createIndexBuffer();
        createTextures();
        createPrograms();
        
        this.isReady = true;
    }
    
    private function createVertexBuffer():void
    {
        var vertices:Vector.<Number> = new <Number>[
        //    x            y        u  v
            -1.0,         1.0,      0, 0, 
             1.0,         1.0,      1, 0,
            -1.0,        -1.0,      0, 1,
             1.0,        -1.0,      1, 1  ];
            
        this.vertexBuffer = this.context.createVertexBuffer(4, 4);
        this.vertexBuffer.uploadFromVector(vertices, 0, 4);
    }
    
    private function createIndexBuffer():void
    {
        this.indexBuffer = this.context.createIndexBuffer(6);
        
       // 2 triangles (0, 1, 2) & (1, 3, 2)
       //   0 - 1
       //   | / |
       //   2 - 3
        this.indexBuffer.uploadFromVector(new <uint>[0, 1, 2,   1, 3, 2], 0, 6);
    }
    
    private function createTextures():void
    {
        this.textureWidth = this.textureData.width;
        this.textureHeight = this.textureData.height;
        this.texture = this.context.createTexture(this.textureWidth, this.textureHeight, Context3DTextureFormat.BGRA, false);
        this.texture.uploadFromBitmapData(this.textureData);
        this.textureData.dispose();
    }

    private function createPrograms():void
    {
        var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER);
        
        var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);
        
        this.program = this.context.createProgram();
        this.program.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
    }
    
    private var doLightning:Boolean = false;
    private var shaderConstants:Vector.<Number> = new <Number>[1, 1, 1, 1];
    private var cloudColor:Vector.<Number> = new <Number>[.75, .75, .78, 1];
    private var skyColor:Vector.<Number> = new <Number>[.001, .001, .001, 1];
    private var time:Number = 0.0;
    private function onFrame(e:Event):void
    {
        if (!this.isReady)
            return;
            
        this.context.clear(0, 0, 0, 1);
        
        this.renderMatrix.identity();
        this.renderMatrix.appendScale(this.textureWidth / stage.stageWidth, this.textureHeight / stage.stageHeight, 1.0);
        this.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, this.renderMatrix, true);
        
        this.context.setVertexBufferAt(0, this.vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
        this.context.setVertexBufferAt(1, this.vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
        
        const cloudSpeed:Number = 1.25;
        const chanceOfLightning:Number = .010;
        
        this.time += cloudSpeed;
        this.shaderConstants[0] = -this.time / this.textureWidth;   // time
        this.skyColor[3] = this.shaderConstants[0] * 1.75; // fast time
        this.cloudColor[3] = .60;   // y offset for fast moving cloud
        this.shaderConstants[1] = 3;    // divisor
        
        // light intensity
        if (!this.doLightning && Math.random() < chanceOfLightning)
        {
            this.doLightning = true;
            setTimeout(function():void { doLightning = false; }, 750);
        }
        if (this.doLightning)
            this.shaderConstants[2] = Math.random() + 2.23; 
        else
            this.shaderConstants[2] = 1.0;
           
        this.shaderConstants[3] = 1;    // alpha
        
        this.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.shaderConstants, 1);
        this.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.skyColor, 1);
        this.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, this.cloudColor, 1);
        
        this.context.setTextureAt(0, this.texture);
        
        this.context.setProgram(this.program);
  
        this.context.drawTriangles(this.indexBuffer);
        
        this.context.present();

    }
    
}
    
}