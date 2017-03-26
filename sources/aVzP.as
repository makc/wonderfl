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
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.media.Sound;
import flash.media.SoundChannel;;
import flash.media.SoundLoaderContext;
import flash.media.SoundMixer;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.utils.ByteArray;

/**
 * Just a bunch of pixel shaders I've posted on wonderfl randomly strung together and set to some Meat Beat Manifesto.
 * 
 * Don't try this with bitmapdata...
 * 
 * @author Devon O.
 */

[SWF(width="465", height="465", frameRate="60", backgroundColor="#000000")]
public class Main extends Sprite
{
    
    private static const POLICY:String   = "http://www.onebyonedesign.com/crossdomain.xml";
    private static const SOUND:String    = "http://www.onebyonedesign.com/flash/djscratch/sound.mp3";
    
    private var mContext3d:Context3D;
    private var mVertBuffer:VertexBuffer3D;
    private var mIndexBuffer:IndexBuffer3D; 
    private var mSound:Sound;
    
    private var mMatrix:Matrix3D = new Matrix3D();
    private var mTexture:Texture;
    private var mTextureData:BitmapData;
    
    private var mCurrentEffect:Effect;
    
    private var mFX:Vector.<Effect>;

    public function Main()
    {    
        if (stage) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);    
    }
    
    private function init(event:Event = null):void
    {
        removeEventListener(Event.ADDED_TO_STAGE, init);
        
        Security.loadPolicyFile(POLICY);
        
        initStage();
        loadImage();
    }
    
    private function initStage():void
    {
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
    }
    
    private function loadImage():void 
    {
        var l:Loader = new Loader();
        l.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoad);
        l.load(new URLRequest("http://assets.wonderfl.net/images/related_images/9/9c/9cd7/9cd77ced068315cdc82c7c19681b1f91fe00da89"), new LoaderContext(true));
    }
    
    private function onImageLoad(event:Event = null):void
    {
        event.currentTarget.removeEventListener(Event.COMPLETE, onImageLoad);
        var l:Loader = (event.currentTarget as LoaderInfo).loader;
        mTextureData = (l.content as Bitmap).bitmapData;    
        
        setS3d();
        
        loadSound();
        
        addEventListener(Event.ENTER_FRAME, onTick);
    }
    
    private function setS3d():void
    {
        stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, initStage3d);
        stage.stage3Ds[0].requestContext3D();
    }
    
    private function initStage3d(event:Event):void
    {
        event.currentTarget.removeEventListener(Event.CONTEXT3D_CREATE, initStage3d);
        
        mContext3d = stage.stage3Ds[0].context3D;            
        
        mContext3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 1, true);
        
        var vertices:Vector.<Number> = Vector.<Number>([
//            x        y        z            u    v
            -1.0,     -1.0,    0,            0, 0, 
            -1.0,     1.0,    0,            0, 1,
             1.0,     1.0,    0,            1, 1,
             1.0,    -1.0,    0,            1, 0  ]);
        
        mVertBuffer = mContext3d.createVertexBuffer(4, 5);
        mVertBuffer.uploadFromVector(vertices, 0, 4);
        
        mIndexBuffer = mContext3d.createIndexBuffer(6);            
        mIndexBuffer.uploadFromVector (Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);

        mContext3d.setVertexBufferAt(0, mVertBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
        mContext3d.setVertexBufferAt(1, mVertBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
        
        mTexture = mContext3d.createTexture(mTextureData.width, mTextureData.height, Context3DTextureFormat.BGRA, true);
        mTexture.uploadFromBitmapData(mTextureData);
        
        initFX();
    }
    
    private function initFX():void
    {
        mFX = new Vector.<Effect>(7, true);
        
        mFX[0] = new Bokeh(mContext3d);
        mFX[1] = new DancingLights(mContext3d);
        mFX[2] = new PlaneDef1(mContext3d);
        mFX[3] = new PlaneDef2(mContext3d);
        mFX[4] = new Rays(mContext3d);
        mFX[5] = new Pulse(mContext3d);
        mFX[6] = new Curves(mContext3d);
        
        mCurrentEffect = mFX[2];
        //switchFX();
    }
    
    private function switchFX():void
    {
        var rand:int = Math.floor(Math.random() * mFX.length);
        //mCurrentEffect =  mFX[6];
        mCurrentEffect = mFX[rand];
    }
    
    private var mChannel:SoundChannel;
    private function loadSound():void
    {
        mSound = new Sound();
        mSound.load(new URLRequest(SOUND), new SoundLoaderContext(5000, true));
        mChannel = mSound.play();
    }
    
    private var mSoundBytes:ByteArray = new ByteArray();
    private var mSoundVector:Vector.<Number> = new Vector.<Number>(512, true);
    private function onTick(event:Event):void
    {
        if ( !mContext3d ) 
            return;
            
        mContext3d.clear ( 0, 0, 0, 1 );
        mContext3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mMatrix, true);
        mContext3d.setTextureAt(0, mTexture);
        
        mSoundBytes.clear();
        
        SoundMixer.computeSpectrum(mSoundBytes, true);
        bytesToVector(mSoundBytes, mSoundVector);
        
        if (mSoundVector[254]  > .350) switchFX();
        
        mContext3d.setProgram(mCurrentEffect.program);
        mCurrentEffect.update(mSoundVector);
        
        mContext3d.drawTriangles(mIndexBuffer);
        mContext3d.present();
    }
    
    private function bytesToVector(bytes:ByteArray, v:Vector.<Number>):void
    {
        var i:int = 0;
        while (bytes.bytesAvailable)
            v[i++] = bytes.readFloat();
    }
    
}
}

import flash.display3D.Program3D;
import flash.utils.ByteArray;
interface Effect
{
    function get program():Program3D;
    function update(sound:Vector.<Number>):void;
}


import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
class DancingLights implements Effect
{
    
    private static const FRAGMENT_SHADER:String =
    <![CDATA[
    
    mov ft0.xy, v0.xy
    mul ft0.xy, ft0.xy, fc1.yy
    sub ft0.xy, ft0.xy, fc0.ww
    pow ft2.x, ft0.x, fc1.y
    pow ft2.y, ft0.y, fc1.y
    add ft2.z, ft2.x, ft2.y
    abs ft2.z, ft2.z
    mul ft2.z, ft2.z, fc1.y
    sub ft2.w, ft2.x, ft2.y
    abs ft2.w, ft2.w
    add ft2.w, ft2.z, ft2.w
    pow ft2.x, ft2.w, fc1.z
    tex ft1, v0, fs0<2d, clamp, nearest>
    mov ft2.x, fc0.x
    mul ft2.x, ft2.x, fc1.y
    add ft2.x, ft2.x, fc0.y
    mul ft2.y, ft2.x, fc1.y
    mul ft2.z, ft2.x, fc1.w
    sin ft3.x, ft2.y
    sin ft3.y, ft2.z
    mul ft3.z, ft2.x, fc0.z
    sin ft3.z, ft3.z
    cos ft3.w, ft2.y
    cos ft4.x, ft2.z
    mul ft4.y, fc2.x, ft3.z
    mul ft4.z, fc2.y, ft4.x
    add ft5.x, ft4.y, ft4.z
    mul ft4.y, fc2.y, ft3.x
    mul ft4.z, fc3.y, ft4.x
    add ft5.y, ft4.y, ft4.z
    mul ft4.y, fc3.x, ft3.y
    mul ft4.z, fc2.z, ft3.w
    add ft6.x, ft4.y, ft4.z
    neg ft4.y, ft3.z
    mul ft4.y, ft4.y, fc2.x
    mul ft4.z, fc2.z, ft4.x
    add ft6.y, ft4.y, ft4.z
    mul ft4.y, fc2.x, ft3.y
    mul ft4.z, fc2.w, ft4.x
    add ft7.x, ft4.y, ft4.z
    neg ft4.y, ft3.z
    mul ft4.y, ft4.y, fc2.x
    mul ft4.z, fc2.w, ft3.w
    add ft7.y, ft4.y, ft4.z
    sub ft2, ft5.xy, ft0.xy
    dp3 ft2, ft2, ft2
    sqt ft2.x, ft2
    mul ft1.x, ft1.x, ft2.x
    sub ft2, ft6.xy, ft0.xy
    dp3 ft2, ft2, ft2
    sqt ft2.x, ft2
    mul ft1.y, ft1.y, ft2.x
    sub ft2, ft7.xy, ft0.xy
    dp3 ft2, ft2, ft2
    sqt ft2.x, ft2
    mul ft1.z, ft1.z, ft2.x
    mov ft3.x, fc0.x
    add ft3.x, ft3.x, fc1.x
    sub ft3.y, ft5.x, ft0.x
    pow ft3.y, ft3.y, fc1.y
    sub ft3.z, ft5.y, ft0.y
    pow ft3.z, ft3.z, fc1.y
    add ft2.x, ft3.y, ft3.z
    div ft2.x, ft3.x, ft2.x
    sub ft3.y, ft6.x, ft0.x
    pow ft3.y, ft3.y, fc1.y
    sub ft3.z, ft6.y, ft0.y
    pow ft3.z, ft3.z, fc1.y
    add ft2.y, ft3.y, ft3.z
    div ft2.y, ft3.x, ft2.y
    sub ft3.y, ft7.x, ft0.x
    pow ft3.y, ft3.y, fc1.y
    sub ft3.z, ft7.y, ft0.y
    pow ft3.z, ft3.z, fc1.y
    add ft2.z, ft3.y, ft3.z
    div ft2.z, ft3.x, ft2.z
    add ft2.x, ft2.x, ft2.y
    add ft2.x, ft2.x, ft2.z
    pow ft2.x, ft2.x, fc3.z
    mul ft1.xyz, ft1.xyz, ft2.xxx
    mov ft1.w, fc0.w
    mov oc, ft1
    
    ]]>
    
    
    private var mProgram:Program3D;
    private var mContext:Context3D;
    
    public function DancingLights(context:Context3D):void
    {
        mContext = context;
        initProgram();
    }
    
    private function initProgram():void
    {
        var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
            "m44 op, va0, vc0 \n"+
            "mov v0, va1 "
        );
        
        var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
        fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);
        
        mProgram = mContext.createProgram();
        mProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
    }
    
    public function get program():Program3D { return mProgram; }
    
    private var mTime:Number = 0.0;
    private var mTimeInc:Number = 0.0;
    private var mBeat:Number = 0.0;
    private var fc0:Vector.<Number> = new <Number>[ 0, 0, 4.0, 1.0 ];
    private var fc1:Vector.<Number> = new <Number>[ .015, 2.0, 5.0, 3.0 ];
    private var fc2:Vector.<Number> = new <Number>[ .1, .4, .3, .5 ];
    private var fc3:Vector.<Number> = new <Number>[ .15, .2, 1.75, 1];
    public function update(sound:Vector.<Number>):void
    {
        var t:Number;
        
        t = sound[0] / 7;
        mTimeInc += (t - mTimeInc) / 8;
        mTime += mTimeInc;
        
        t = sound[511] * 1.5;
        mBeat += (t - mBeat) / 4;
        
        fc0[0] = mBeat;
        fc0[1] = mTime;
        
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0 );    
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fc2 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, fc3 );
    }
}



import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
class Bokeh implements Effect
{
    
    private static const FRAGMENT_SHADER:String =
    <![CDATA[
    
    div ft0, v0.xy, fc0.y                
    mul ft0, ft0, fc27.y                
    sub ft0.x, ft0.x, fc0.y                
    sub ft0.y, ft0.y, fc0.x                
    mov ft2, fc0
    tex ft1, v0, fs0<2d, clamp, nearest>               
    add ft3, fc1.x, ft0.x                
    add ft4, fc1.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft1.x, fc0.x, ft3                
    add ft3, fc1.z, ft0.x                
    add ft4, fc1.w, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.x, fc0.x, ft3                
    add ft1.x, ft1.x, ft2.x                
    add ft3, fc2.x, ft0.x                
    add ft4, fc2.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.x, fc0.x, ft3                
    add ft1.x, ft1.x, ft2.x                
    add ft3, fc2.z, ft0.x                
    add ft4, fc2.w, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.x, fc0.x, ft3                
    add ft1.x, ft1.x, ft2.x                
    add ft3, fc3.x, ft0.x                
    add ft4, fc3.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.x, fc0.x, ft3                
    add ft1.x, ft1.x, ft2.x                
    add ft3, fc3.z, ft0.x                
    add ft4, fc3.w, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.x, fc0.x, ft3                
    add ft1.x, ft1.x, ft2.x                
    add ft3, fc4.x, ft0.x                
    add ft4, fc4.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.x, fc0.x, ft3                
    add ft1.x, ft1.x, ft2.x                
    add ft3, fc4.z, ft0.x                
    add ft4, fc4.w, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                    
    sqt ft3, ft3                
    div ft2.x, fc0.x, ft3                
    add ft1.x, ft1.x, ft2.x                
    add ft3, fc5.x, ft0.x                    
    add ft4, fc5.y, ft0.y                
    mul ft3, ft3, ft3                        
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.x, fc0.x, ft3                
    add ft1.x, ft1.x, ft2.x                
    add ft3, fc6.x, ft0.x                
    add ft4, fc6.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft1.y, fc0.x, ft3                
    add ft3, fc6.z, ft0.x                
    add ft4, fc6.w, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.y, fc0.x, ft3                
    add ft1.y, ft1.y, ft2.y                
    add ft3, fc7.x, ft0.x                
    add ft4, fc7.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.y, fc0.x, ft3                
    add ft1.y, ft1.y, ft2.y                
    add ft3, fc7.z, ft0.x                
    add ft4, fc7.w, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.y, fc0.x, ft3                
    add ft1.y, ft1.y, ft2.y                
    add ft3, fc8.x, ft0.x                
    add ft4, fc8.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.y, fc0.x, ft3                
    add ft1.y, ft1.y, ft2.y                
    add ft3, fc8.z, ft0.x                
    add ft4, fc8.w, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.y, fc0.x, ft3                
    add ft1.y, ft1.y, ft2.y                
    add ft3, fc9.x, ft0.x                
    add ft4, fc9.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.y, fc0.x, ft3                
    add ft1.y, ft1.y, ft2.y                
    add ft3, fc9.z, ft0.x                
    add ft4, fc9.w, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.y, fc0.x, ft3                
    add ft1.y, ft1.y, ft2.y                
    add ft3, fc10.x, ft0.x                
    add ft4, fc10.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.y, fc0.x, ft3                
    add ft1.y, ft1.y, ft2.y                
    add ft3, fc11.x, ft0.x                
    add ft4, fc11.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft1.z, fc0.x, ft3                
    add ft3, fc11.z, ft0.x                
    add ft4, fc11.w, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.z, fc0.x, ft3                
    add ft1.z, ft1.z, ft2.z                
    add ft3, fc12.x, ft0.x                
    add ft4, fc12.y, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.z, fc0.x, ft3                
    add ft1.z, ft1.z, ft2.z                
    add ft3, fc12.z, ft0.x                
    add ft4, fc12.w, ft0.y                
    mul ft3, ft3, ft3                
    mul ft4, ft4, ft4                
    add ft3, ft3, ft4                
    sqt ft3, ft3                
    div ft2.z, fc0.x, ft3                
    add ft1.z, ft1.z, ft2.z                
    add ft3, fc13.x, ft0.x                
    add ft4, fc13.y, ft0.y                
    mul ft3, ft3, ft3
    mul ft4, ft4, ft4
    add ft3, ft3, ft4
    sqt ft3, ft3  
    div ft2.z, fc0.x, ft3
    add ft1.z, ft1.z, ft2.z  
    add ft3, fc13.z, ft0.x 
    add ft4, fc13.w, ft0.y   
    mul ft3, ft3, ft3 
    mul ft4, ft4, ft4 
    add ft3, ft3, ft4   
    sqt ft3, ft3     
    div ft2.z, fc0.x, ft3     
    add ft1.z, ft1.z, ft2.z     
    div ft1, ft1, fc27.x   
    mov oc, ft1  
    
    ]]>
    
    
    private var mProgram:Program3D;
    private var mContext:Context3D;
    
    public function Bokeh(context:Context3D):void
    {
        mContext = context;
        initProgram();
    }
    
    private function initProgram():void
    {
        var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
            "m44 op, va0, vc0 \n"+
            "mov v0, va1 "
        );
        
        var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
        fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);
        
        mProgram = mContext.createProgram();
        mProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
    }
    
    public function get program():Program3D { return mProgram; }
    
    private var mTime:Number = 0.0;
    private var mBeat:Number = 0.0;
    
    private var fc0:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc1:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc2:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc3:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc4:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc5:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc6:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc7:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc8:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc9:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc10:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc11:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc12:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc13:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc27:Vector.<Number> = new <Number>[ 1, 2, 3, 1 ];
    public function update(sound:Vector.<Number>):void
    {
        var p1:Object;
        var p2:Object;
        
        var val:Number;
        
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0 );
            
        
        // POINTS
        // R
        p1 = makePoint(3.3, 2.9, 0.1, 0.1, mTime);
        p2 = makePoint(1.9, 2.0, 0.4, 0.4, mTime);
        fc1[0] = p1.x;
        fc1[1] = p1.y;
        fc1[2] = p2.x;
        fc1[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1 );
        
        p1 = makePoint(0.8, 0.7, 0.4, 0.5, mTime);
        p2 = makePoint(2.3, 0.1, 0.6, 0.3, mTime);
        fc2[0] = p1.x;
        fc2[1] = p1.y;
        fc2[2] = p2.x;
        fc2[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fc2 );
        
        p1 = makePoint(0.8, 1.7, 0.5, 0.4, mTime);
        p2 = makePoint(0.3, 1.0, 0.4, 0.4, mTime);
        fc3[0] = p1.x;
        fc3[1] = p1.y;
        fc3[2] = p2.x;
        fc3[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, fc3 );
        
        p1 = makePoint(1.4, 1.7, 0.4, 0.5, mTime);
        p2 = makePoint(1.3, 2.1, 0.6, 0.3, mTime);
        fc4[0] = p1.x;
        fc4[1] = p1.y;
        fc4[2] = p2.x;
        fc4[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, fc4 );
        
        p1 = makePoint(1.8, 1.7, 0.5, 0.4, mTime);
        fc5[0] = p1.x;
        fc5[1] = p1.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, fc5 );
        
        
        // G
        p1 = makePoint(1.2, 1.9, 0.1, 0.2, mTime);
        p2 = makePoint(0.7, 2.7, 0.4, 0.4, mTime);
        fc6[0] = p1.x;
        fc6[1] = p1.y;
        fc6[2] = p2.x;
        fc6[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6, fc6);
        
        p1 = makePoint(1.4, 0.6, 0.4, 0.5, mTime);
        p2 = makePoint(2.6, 0.4, 0.6, 0.3, mTime);
        fc7[0] = p1.x;
        fc7[1] = p1.y;
        fc7[2] = p2.x;
        fc7[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 7, fc7 );
        
        p1 = makePoint(0.7, 1.4, 0.5, 0.4, mTime);
        p2 = makePoint(0.7, 1.7, 0.4, 0.4, mTime);
        fc8[0] = p1.x;
        fc8[1] = p1.y;
        fc8[2] = p2.x;
        fc8[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 8, fc8 );
        
        p1 = makePoint(0.8, 0.5, 0.4, 0.5, mTime);
        p2 = makePoint(1.4, 0.9, 0.6, 0.3, mTime);
        fc9[0] = p1.x;
        fc9[1] = p1.y;
        fc9[2] = p2.x;
        fc9[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 9, fc9);
        
        p1 = makePoint(0.7, 1.3, 0.5, 0.4, mTime);
        fc10[0] = p1.x;
        fc10[1] = p1.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 10, fc10 );
        
        // B
        p1 = makePoint(3.7, 0.3, 0.3, 0.3, mTime);
        p2 = makePoint(1.9, 1.3, 0.4, 0.4, mTime);
        fc11[0] = p1.x;
        fc11[1] = p1.y;
        fc11[2] = p2.x;
        fc11[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 11, fc11);

        p1 = makePoint(0.8, 0.9, 0.4, 0.5, mTime);
        p2 = makePoint(1.2, 1.7, 0.6, 0.3, mTime);
        fc12[0] = p1.x;
        fc12[1] = p1.y;
        fc12[2] = p2.x;
        fc12[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 12, fc12 );
        
        p1 = makePoint(0.3, 0.6, 0.5, 0.4, mTime);
        p2 = makePoint(0.3, 0.3, 0.4, 0.4, mTime);
        fc13[0] = p1.x;
        fc13[1] = p1.y;
        fc13[2] = p2.x;
        fc13[3] = p2.y;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 13, fc13 );
            
        // constants 
        fc27[0] = mBeat;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 27, fc27);
    
        val = sound[0];
        
        mTime += .05 + (val * .95);
        
        val = sound[3];
        var targ:Number = 175 - val * 175;
        if (targ < 8) targ = 8;
        
        mBeat += (targ - mBeat) / 1.75;
    }
    
    private function makePoint(fx:Number, fy:Number, sx:Number, sy:Number, t:Number):Object
    {
        var xx:Number = Math.sin(t * fx * 0.1) * sx;
        var yy:Number = Math.cos(t * fy * 0.1) * sy;
        return { x:xx, y:yy };
    }
}




import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
class PlaneDef1 implements Effect
{
    
    private static const FRAGMENT_SHADER:String =
    <![CDATA[
    
    mov ft0, v0 
    div ft1, ft0.xy, fc3.xy   
    mul ft2, fc6.x, ft1 
    sub ft3, ft2, fc5.x  
    mul ft1, ft3.y, fc9.x    
    mul ft2, ft3.x, fc8.x 
    sub ft4, ft2, ft1 
    mul ft1, ft3.x, fc9.x   
    mul ft2, ft3.y, fc8.x  
    add ft5, ft1, ft2   
    mov ft6, fc5  
    abs ft1, ft5  
    mul ft2, fc7.x, ft4   
    div ft6.x, ft2, ft1   
    abs ft1, ft5   
    div ft2, fc7.x, ft1    
    add ft6.y, fc4.x, ft2 
    tex ft0, ft6, fs0<2d, repeat, linear, nomip>  
    mul ft1, ft5, ft5  
    mul ft1, ft0.xyz, ft1   
    mov ft2.x, ft1  
    mov ft2.y, ft1  
    mov ft2.z, ft1  
    mov ft2.w, fc5.x    
    mov oc, ft2    
    
    ]]>
    
    
    private var mProgram:Program3D;
    private var mContext:Context3D;
    
    public function PlaneDef1(context:Context3D):void
    {
        mContext = context;
        initProgram();
    }
    
    private function initProgram():void
    {
        var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
            "m44 op, va0, vc0 \n"+
            "mov v0, va1 "
        );
        
        var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
        fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);
        
        mProgram = mContext.createProgram();
        mProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
    }
    
    public function get program():Program3D { return mProgram; }
    
    private var mTime:Number = 0.0;
    private var mTimeInc:Number = 0.0;
    private var mSize:Number = .25;
    
    private var fc3:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc4:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc5:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc6:Vector.<Number> = new <Number>[ 2, 1, 1, 1 ];
    private var fc7:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc8:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc9:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    public function update(sound:Vector.<Number>):void
    {
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, fc3 );
        
        fc4[0] = .15 * mTime;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, fc4 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, fc5 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6, fc6 );
        fc7[0] = mSize;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 7, fc7 );
        fc8[0] = Math.cos(.05 * mTime);
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 8, fc8 );
        fc9[0] = Math.sin(.25 * mTime)
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 9, fc9 );
        
        var t:Number;
        t = sound[0];
        mTimeInc += (t - mTimeInc) / 8;
        mTime += .025 + mTimeInc;
    }
    

}



import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
class PlaneDef2 implements Effect
{
    
    private static const FRAGMENT_SHADER:String =
    <![CDATA[
    
    mov ft2, fc1    
    div ft2, v0.xy, fc0.xy    
    mul ft2, ft2, fc2.y    
    sub ft2, ft2, fc2.x    
    dp3 ft1, ft2, ft2    
    sqt ft1.x, ft1    
    abs ft3.z, ft2.x    
    abs ft3.w, ft2.y    
    max ft3.x, ft3.z, ft3.w    
    min ft3.y, ft3.z, ft3.w    
    rcp ft4.x, ft3.x    
    mul ft4.x, ft4.x, ft3.y    
    mul ft3.x, ft4.x, ft4.x    
    mul ft3.y, ft3.x, fc10.z    
    add ft3.y, ft3.y, fc10.w    
    mul ft3.y, ft3.y, ft3.x    
    add ft3.y, ft3.y, fc11.x    
    mul ft3.y, ft3.y, ft3.x    
    add ft3.y, ft3.y, fc11.y    
    mul ft3.y, ft3.y, ft3.x    
    add ft3.y, ft3.y, fc11.z    
    mul ft3.y, ft3.y, ft3.x    
    add ft3.y, ft3.y, fc11.w    
    mul ft4.x, ft4.x, ft3.y    
    sub ft3.x, fc12.x, ft4.x    
    slt ft3.w, ft3.z, ft3.w    
    mul ft3.y, ft3.w, ft3.x    
    sub ft3.w, fc10.y, ft3.w    
    mul ft3.w, ft3.w, ft4.x    
    add ft3.w, ft3.w, ft3.y    
    sub ft3.z, fc12.y, ft3.w    
    slt ft3.x, ft2.x, fc10.x    
    mul ft3.y, ft3.x, ft3.z    
    sub ft3.x, fc10.y, ft3.x    
    mul ft3.x, ft3.x, ft3.w    
    add ft3.x, ft3.x, ft3.y    
    neg ft3.y, ft4.x    
    slt ft4.x, ft2.y, fc10.x    
    mul ft3.z, ft4.x, ft3.y    
    sub ft4.x, fc10.y, ft4.x    
    mul ft4.x, ft4.x, ft3.x    
    add ft4.x, ft4.x, ft3.z    
    mov ft0, fc1    
    mov ft0.x, ft4.x    
    mul ft2.x, fc2.w, ft0.x    
    cos ft2.x, ft2.x    
    mul ft2.x, fc2.z, ft2.x    
    add ft2.x, ft2.x, fc2.z    
    mov ft5.x, fc3.x    
    mov ft4, fc1    
    max ft2.x, ft2.x, fc3.y    
    min ft2.x, ft2.x, ft5.x    
    sub ft2.x, ft2.x, fc3.y    
    sub ft4.x, ft5.x, fc3.y    
    rcp , ft4.x, ft4.x    
    mul ft4.x, ft2.x, ft4.x    
    mul ft2.x, ft4.x, ft4.x    
    mul ft4.x, ft2.x, ft4.x    
    mul ft4.x, ft4.x, fc2.y    
    mul ft2.x, ft2.x, fc5.y    
    sub ft2.x, ft2.x, ft4.x    
    mov ft4, fc1    
    max ft2.x, ft2.x, fc3.y    
    min ft2.x, ft2.x, ft5.x    
    sub ft2.x, ft2.x, fc3.y    
    sub ft4.x, ft5.x, fc3.y    
    rcp , ft4.x, ft4.x    
    mul ft4.x, ft2.x, ft4.x    
    mul ft2.x, ft4.x, ft4.x    
    mul ft4.x, ft2.x, ft4.x    
    mul ft4.x, ft4.x, fc2.y    
    mul ft2.x, ft2.x, fc5.y    
    sub ft2.x, ft2.x, ft4.x    
    mov ft4, fc1    
    max ft2.x, ft2.x, fc3.y    
    min ft2.x, ft2.x, ft5.x    
    sub ft2.x, ft2.x, fc3.y    
    sub ft4.x, ft5.x, fc3.y    
    rcp , ft4.x, ft4.x    
    mul ft4.x, ft2.x, ft4.x    
    mul ft2.x, ft4.x, ft4.x    
    mul ft4.x, ft2.x, ft4.x    
    mul ft4.x, ft4.x, fc2.y    
    mul ft2.x, ft2.x, fc5.y    
    sub ft2.x, ft2.x, ft4.x    
    mov ft4, fc1    
    max ft2.x, ft2.x, fc3.y    
    min ft2.x, ft2.x, ft5.x    
    sub ft2.x, ft2.x, fc3.y    
    sub ft4.x, ft5.x, fc3.y    
    rcp , ft4.x, ft4.x    
    mul ft4.x, ft2.x, ft4.x    
    mul ft2.x, ft4.x, ft4.x    
    mul ft4.x, ft2.x, ft4.x    
    mul ft4.x, ft4.x, fc2.y    
    mul ft2.x, ft2.x, fc5.y    
    sub ft2.x, ft2.x, ft4.x    
    mov ft3, fc1    
    mul ft3.x, fc5.x, ft2.x    
    add ft3.x, ft3.x, ft1.x    
    div ft3.x, fc2.x, ft3.x    
    add ft3.x, ft3.x, fc4.x    
    mul ft3.y, ft0.x, fc5.y    
    div ft3.y, ft3.y, fc3.z    
    mov ft4, fc1    
    mul ft4.x, ft2.x, fc2.z    
    add ft4.x, ft4.x, fc2.z    
    mul ft4.x, ft4.x, ft1    
    mul ft4.x, ft4.x, ft1    
    tex ft5, ft3, fs0<2d, repeat, linear, nomip>    
    mov ft5.w, fc3.x    
    mov ft7, fc1    
    mul ft7.x, fc2.w, ft0.x    
    cos ft7.x, ft7.x    
    mul ft7.x, ft7.x, fc2.z    
    add ft7.x, ft7.x, fc2.z    
    mul ft7.x, ft7.x, ft1.x    
    mul ft7.x, ft7.x, fc2.z    
    sub ft7.x, fc2.x, ft7.x    
    mov ft6, fc1    
    mul ft6.x, ft5, ft4.x    
    mul ft6.x, ft6.x, ft7.x    
    mul ft6.y, ft5, ft4.x    
    mul ft6.y, ft6.y, ft7.x    
    mul ft6.z, ft5, ft4.x    
    mul ft6.z, ft6.z, ft7.x    
    mov ft6.w, fc2.x    
    mov oc, ft6 
    
    ]]>
    
    
    private var mProgram:Program3D;
    private var mContext:Context3D;
    
    public function PlaneDef2(context:Context3D):void
    {
        mContext = context;
        initProgram();
    }
    
    private function initProgram():void
    {
        var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
            "m44 op, va0, vc0 \n"+
            "mov v0, va1 "
        );
        
        var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
        fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);
        
        mProgram = mContext.createProgram();
        mProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
    }
    
    public function get program():Program3D { return mProgram; }
    
    private var mTime:Number = 0.0;
    private var mTimeInc:Number = 0.0;
    private var mSize:Number = .20;
    
    private var fc0:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc1:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc2:Vector.<Number> = new <Number>[ 1, 2, .5, 7  ];
    private var fc3:Vector.<Number> = new <Number>[ 1, 0, Math.PI, 1 ];
    private var fc4:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc5:Vector.<Number> = new <Number>[ 1, 1, .4, .7 ];
    private var fc10:Vector.<Number> = new <Number>[ 0, 1, -0.013480470, 0.057477314 ];
    private var fc11:Vector.<Number> = new <Number>[  -0.121239071, 0.195635925, -0.332994597, 0.999995630 ];
    private var fc12:Vector.<Number> = new <Number>[ 1.570796327, 3.141592654, 1, 1 ];
    public function update(sound:Vector.<Number>):void
    {
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fc2 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, fc3 );
        
        fc4[0] = mTime;
        fc4[1] = mTime * .50;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, fc4 );
        
        fc5[0] = mSize;
        fc5[1] = mSize + 3;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, fc5 );

        
        //fc10 = [ 0, 1, -0.013480470, 0.057477314 ];
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 10, fc10 );
        //fc11 = [ -0.121239071, 0.195635925, -0.332994597, 0.999995630 ]
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 11, fc11);
        //fc12 = [ 1.570796327, 3.141592654, 1, 1 ]
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 12, fc12 );
        
        mSize = .20 + 8 * sound[128];
        
        var t:Number;
        t = sound[0];
        mTimeInc += (t - mTimeInc) / 16;
        mTime += .005 + mTimeInc;
    }
    

}




import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
class Rays implements Effect
{
    
    private var mProgram:Program3D;
    private var mContext:Context3D;
    
    public function Rays(context:Context3D):void
    {
        mContext = context;
        initProgram();
    }
    
    private function initProgram():void
    {
        var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
            "m44 op, va0, vc0 \n"+
            "mov v0, va1 "
        );
        
        var frag:String = "";
        frag += "sub ft0.xy, v0.xy, fc0.xy \n";
        frag += "mul ft0.xy, ft0.xy, fc1.ww \n";
        frag += "tex ft1,  v0, fs0 <2d, clamp, linear, mipnone> \n";  
        frag += "mov ft2.x, fc0.w \n";
        frag += "mov ft4.xy, v0.xy \n";
        
        for (var i:int = 0; i < 30; i++)
        {
            frag += "sub ft4.xy, ft4.xy, ft0.xy \n"; 
            frag += "tex ft3,  ft4.xy, fs0 <2d, clamp, linear, mipnone> \n";  
            frag += "mul ft2.y, ft2.x, fc2.x \n";
            frag += "mul ft3.xyz, ft3.xyz, ft2.yyy \n";
            frag += "add ft1.xyz, ft1.xyz, ft3.xyz \n";
            frag += "mul ft2.x, ft2.x, fc2.y \n";
        }
        
        // Output final color with a further scale control factor. 
        frag += "mul ft1.xyz, ft1.xyz, fc2.zzz \n";
        frag += "mov oc, ft1";
        
        var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
        fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, frag);
        
        mProgram = mContext.createProgram();
        mProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
    }
    
    public function get program():Program3D { return mProgram; }
    
    private var mTime:Number = 0.0;
    private var mxpos:Number = 0.0;
    private var mypos:Number = 0.0;
    
    
    private var mLightPos:Vector.<Number> = Vector.<Number>( [ .5, .5, 1, 1 ]);
    private var mValues1:Vector.<Number> = Vector.<Number>( [ 1, 1, 1, 1 ]);
    private var mValues2:Vector.<Number> = Vector.<Number>( [ 1, 1, 1, 1 ]);    
        
    public function update(sound:Vector.<Number>):void
    {
        // light position
        
        var tx:Number = sound[1] * 465;
        var ty:Number = sound[256] * 465;
        
        mxpos += (tx - mxpos) / 4;
        mypos += (ty - mypos) / 4;
        
        mLightPos[0] = mxpos / 465;
        mLightPos[1] = mypos / 465;
        
        // numsamples, density, numsamples * density, 1 / numsamples * density
        mValues1[0] = 30;
        mValues1[1] = 2.25;
        mValues1[2] = 30 * mValues1[1];
        mValues1[3] = 1 / mValues1[2];
        
        // weight, decay, exposure
        mValues2[0] =sound[128] + .650;// 1-(sound[128] + .1);// .85;//sound[255];
        mValues2[1] = .90;// 1-(sound[128] + .1);
        mValues2[2] = sound[47] * .85;// .35;
        
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mLightPos, 1 );    
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, mValues1,  1 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, mValues2,  1 );
    }
    

}




import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
class Pulse implements Effect
{
    
    private static const FRAGMENT_SHADER:String =
    <![CDATA[
    
    mul ft5, v0, fc3.w  
    mul ft5, ft5, fc6.z  
    mov ft0, v0.xy  
    mul ft4, fc3.x, ft5.x  
    mul ft4, ft4, fc2.x  
    mul ft6, fc3.y, ft5.x  
    mul ft6, ft6, fc2.z  
    add ft6, ft4, ft6  
    add ft6, ft6, ft5.x  
    sub ft0.x, ft0.x, ft6.x  
    add ft0.x, ft0.x, fc4.x  
    mul ft4, fc3.z, ft5.y  
    mul ft4, ft4, fc2.y  
    mul ft6, fc3.y, ft5.y  
    mul ft6, ft6, fc2.z  
    add ft6, ft4, ft6  
    add ft6, ft6, ft5.y  
    sub ft0.y, ft0.y, ft6.y  
    sub ft0.y, ft0.y, fc4.y  
    dp3 ft1, ft0, ft0  
    sqt ft1.x, ft1  
    div ft4, v0.xy, fc8.xy  
    div ft5, ft0, ft1.x  
    div ft6, ft1, fc6.y  
    sub ft6, ft6, fc6.w  
    sin ft6, ft6  
    mul ft6, ft6, ft5  
    div ft6, ft6, fc6.x  
    add ft2, ft4, ft6  
    tex ft4, ft2, fs0<2d, repeat, linear, nomip>  
    mul ft4, ft4.xyz, fc6.z  
    div ft4, ft4, ft1  
    mov oc, ft4
    ]]>
    
    private var mProgram:Program3D;
    private var mContext:Context3D;
    
    public function Pulse(context:Context3D):void
    {
        mContext = context;
        initProgram();
    }
    
    private function initProgram():void
    {
        var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
            "m44 op, va0, vc0 \n"+
            "mov v0, va1 "
        );
        
        
        var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
        fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);
        
        mProgram = mContext.createProgram();
        mProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
    }
    
    public function get program():Program3D { return mProgram; }
    
    private var mTime:Number = 0.0; 
    private var mxpos:Number = 0.0;
    private var mypos:Number = 0.0;
    private var mxposSpeed:Number = 2.0;
    private var myposSpeed:Number = 2.0;
    private var mSize:Number = 0.0;
    
    private var fc1:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc2:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc4:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    private var fc3:Vector.<Number> = new <Number>[ .50, .3, .4, 2.0 ];
    private var fc6:Vector.<Number> = new <Number>[ 25, 10, 50, 1 ];
    private var fc8:Vector.<Number> = new <Number>[ 1, 1, 1, 1 ];
    public function update(sound:Vector.<Number>):void
    {
        // light position
        
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1 );
            
        //time     = FC2 = [sin(time / 2), sin(time / 5), cos(time), time]
        
        fc2[0] = Math.sin(mTime / 2.0);
        fc2[1] = Math.sin(mTime / 5.0);
        fc2[2] = Math.cos(mTime);
        fc2[3] = mTime;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fc2 );
        
        // position

        var xpos:Number = (mxpos / 465) * 64;
        var ypos:Number = ((mypos / 465) * 64) - 64;
        mxpos += mxposSpeed;
        mypos += myposSpeed;
        if (mxpos > 465)
        {
            mxposSpeed *= -1;
            mxpos = 465;
        }
        
        if ( mxpos < 0)
        {
            mxposSpeed *= -1;
            mxpos = 0;
        }
        
        if (mypos > 465)
        {
            myposSpeed *= -1;
            mypos = 465;
        }
        
        if (mypos < 0)
        {
            myposSpeed *= -1;
            mypos = 0;
        }
        
        var tsize:Number = sound[145] * 100;
        mSize = tsize;
        
        fc4[0] = xpos;
        fc4[1] = ypos;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, fc4 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, fc3 );
        
        fc6[3] = mTime * 10;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6, fc6 );
        
        fc8[0] = mSize;
        fc8[1] = mSize;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 8, fc8 );
        
        mTime += .025;
    }
    

}




import com.adobe.utils.AGALMiniAssembler;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
class Curves implements Effect
{
    
    private static const FRAGMENT_SHADER:String =
    <![CDATA[
    
    tex ft0, v0, fs0<2d, clamp, linear, nomip>  
    div ft0.x, ft0.xy, fc0.y   
    div ft0.y, ft0.xy, fc0.y   
    mov ft0.z, fc0.x   
    div ft0.z, ft0.z, fc0.y   
    div ft0.z, ft0.z, fc1.w   
    sub ft0.x, ft0.x, ft0.z   
    sub ft0.y, ft0.y, fc1.x   
    mov ft1.x, fc0.z   
    mov ft1.y, fc0.z   
    mul ft1.z, ft1.y, fc1.y   
    add ft1.z, ft1.z, fc0.x   
    div ft1.z, ft1.z, fc1.z   
    mul ft1.w, ft1.y, fc1.y   
    add ft1.w, ft1.w, fc1.x   
    mul ft1.z, ft1.z, fc0.w   
    add ft1.z, ft1.z, ft1.w   
    mul ft2.x, ft0.x, fc1.w   
    add ft2.x, ft2.x, ft1.z   
    sin ft2.x, ft2.x   
    mul ft2.x, ft2.x, fc2.x   
    add ft0.y, ft0.y, ft2.x   
    mul ft2.w, ft0.y, fc1.z   
    sub ft2.w, ft2.w, ft1.z   
    sin ft2.w, ft2.w   
    mul ft2.w, ft2.w, fc2.y   
    add ft0.x, ft0.x, ft2.w   
    mov ft3.x, fc2.z   
    mul ft3.x, ft3.x, fc1.x   
    mul ft3.x, ft3.x, ft0.y   
    sin ft3.x, ft3.x   
    mul ft3.y, fc2.w, ft0.x   
    sub ft3.y, ft3.y, ft1.z   
    sin ft3.y, ft3.y   
    add ft3.x, ft3.x, ft3.y   
    abs ft3.y, ft3.x   
    sqt ft3.y, ft3.y   
    rcp ft3.y, ft3.y   
    div ft3.y, ft3.y, fc3.x   
    add ft1.x, ft1.x, ft3.y   
    add ft1.y, ft1.y, fc0.x   
    mul ft1.z, ft1.y, fc1.y   
    add ft1.z, ft1.z, fc0.x   
    div ft1.z, ft1.z, fc1.z   
    mul ft1.w, ft1.y, fc1.y   
    add ft1.w, ft1.w, fc1.x   
    mul ft1.z, ft1.z, fc0.w   
    add ft1.z, ft1.z, ft1.w   
    mul ft2.x, ft0.x, fc1.w   
    add ft2.x, ft2.x, ft1.z   
    sin ft2.x, ft2.x   
    mul ft2.x, ft2.x, fc2.x   
    add ft0.y, ft0.y, ft2.x   
    mul ft2.w, ft0.y, fc1.z   
    sub ft2.w, ft2.w, ft1.z   
    sin ft2.w, ft2.w   
    mul ft2.w, ft2.w, fc2.y   
    add ft0.x, ft0.x, ft2.w   
    mov ft3.x, fc2.z   
    mul ft3.x, ft3.x, fc1.x   
    mul ft3.x, ft3.x, ft0.y   
    sin ft3.x, ft3.x   
    mul ft3.y, fc2.w, ft0.x   
    sub ft3.y, ft3.y, ft1.z   
    sin ft3.y, ft3.y   
    add ft3.x, ft3.x, ft3.y   
    abs ft3.y, ft3.x   
    sqt ft3.y, ft3.y   
    rcp ft3.y, ft3.y   
    div ft3.y, ft3.y, fc3.x   
    add ft1.x, ft1.x, ft3.y   
    mov ft4.x, fc0.z   
    mov ft1.y, fc0.z   
    mul ft1.z, ft1.y, fc3.z   
    mov ft1.w, fc0.w   
    mul ft1.w, ft1.w, fc3.y   
    add ft1.z, ft1.z, ft1.w   
    mul ft6.x, ft1.z, fc3.w   
    sin ft6.x, ft6.x   
    mul ft6.y, ft1.z, fc1.y   
    add ft6.y, ft6.y, fc0.x   
    sin ft6.y, ft6.y   
    mul ft6.z, ft1.z, fc4.x   
    add ft6.z, ft6.z, fc4.y   
    sin ft6.z, ft6.z 
    mul ft5.x, ft6.x, ft6.y   
    mul ft5.x, ft5.x, ft6.z   
    mul ft6.x, ft1.z, fc4.z   
    add ft6.x, ft6.x, fc4.w   
    sin ft6.x, ft6.x   
    mul ft6.y, ft1.z, fc4.y   
    add ft6.y, ft6.y, fc5.y   
    sin ft6.y, ft6.y   
    mul ft6.z, ft1.z, fc5.x   
    add ft6.z, ft6.z, fc5.y   
    sin ft6.z, ft6.z   
    mul ft5.y, ft6.x, ft6.y   
    mul ft5.y, ft5.y, ft6.z   
    sub ft6.x, ft0.x, ft5.x   
    mul ft6.x, ft6.x, ft6.x   
    sub ft6.y, ft0.y, ft5.y   
    mul ft6.y, ft6.y, ft6.y   
    add ft6.w, ft6.x, ft6.y   
    sqt ft6.w, ft6.w   
    div ft6.w, fc5.z, ft6.w   
    add ft4.x, ft4.x, ft6.w   
    add ft1.y, ft1.y, fc0.x   
    mul ft1.z, ft1.y, fc3.z   
    mov ft1.w, fc0.w   
    mul ft1.w, ft1.w, fc3.y   
    add ft1.z, ft1.z, ft1.w   
    mul ft6.x, ft1.z, fc3.w   
    sin ft6.x, ft6.x   
    mul ft6.y, ft1.z, fc1.y   
    add ft6.y, ft6.y, fc0.x   
    sin ft6.y, ft6.y   
    mul ft6.z, ft1.z, fc4.x   
    add ft6.z, ft6.z, fc4.y   
    sin ft6.z, ft6.z   
    mul ft5.x, ft6.x, ft6.y   
    mul ft5.x, ft5.x, ft6.z   
    mul ft6.x, ft1.z, fc4.z   
    add ft6.x, ft6.x, fc4.w   
    sin ft6.x, ft6.x   
    mul ft6.y, ft1.z, fc4.y   
    add ft6.y, ft6.y, fc5.y   
    sin ft6.y, ft6.y   
    mul ft6.z, ft1.z, fc5.x   
    add ft6.z, ft6.z, fc5.y   
    sin ft6.z, ft6.z   
    mul ft5.y, ft6.x, ft6.y   
    mul ft5.y, ft5.y, ft6.z   
    sub ft6.x, ft0.x, ft5.x   
    mul ft6.x, ft6.x, ft6.x   
    sub ft6.y, ft0.y, ft5.y   
    mul ft6.y, ft6.y, ft6.y   
    add ft6.w, ft6.x, ft6.y   
    sqt ft6.w, ft6.w   
    div ft6.w, fc5.z, ft6.w   
    add ft4.x, ft4.x, ft6.w   
    mov ft6.x, ft1.x   
    mov ft7.x, fc0.w   
    mul ft7.x, ft7.x, fc1.y   
    sin ft7.x, ft7.x   
    abs ft7.x, ft7.x   
    max ft7.x, ft7.x, fc1.y   
    mul ft5.x, ft7.x, ft6.x   
    mov ft7.y, fc0.w   
    mul ft7.y, ft7.y, fc5.w   
    add ft7.y, ft7.y, fc0.x   
    sin ft7.y, ft7.y   
    abs ft7.y, ft7.y   
    sub ft7.w, ft6.x, ft4.x   
    mul ft7.y, ft7.y, ft7.w   
    max ft5.y, ft7.y, fc1.y   
    max ft5.z, fc1.y, ft4.x   
    mov ft5.w, fc0.x   
    mov oc, ft5
    
    ]]>
    
    private var mProgram:Program3D;
    private var mContext:Context3D;
    
    public function Curves(context:Context3D):void
    {
        mContext = context;
        initProgram();
    }
    
    private function initProgram():void
    {
        var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
        vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
            "m44 op, va0, vc0 \n"+
            "mov v0, va1 "
        );
        
        
        var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
        fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);
        
        mProgram = mContext.createProgram();
        mProgram.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
    }
    
    public function get program():Program3D { return mProgram; }
    
    private var mTime:Number = 0.0; 
    
    private var mBlue:Number = 0.0;
    private var mTimeInc:Number = 0.0;
    
    private var fc0:Vector.<Number> = new <Number>[ 1, 1, 0, 1 ];
    private var fc1:Vector.<Number> = new <Number>[ 0.50, 0.10, 3.00,  2.00 ];
    private var fc2:Vector.<Number> = new <Number>[ 0.45, 0.25, 8.00,  6.10 ];
    private var fc3:Vector.<Number> = new <Number>[ 10.00, 1.30, 2.50,  0.30 ];
    private var fc4:Vector.<Number> = new <Number>[ 0.56, 0.24, 0.11,  0.04  ];
    private var fc5:Vector.<Number> = new <Number>[ 0.18, 0.40, 1,  0.03  ];
    public function update(sound:Vector.<Number>):void
    {
        mBlue = sound[145];
        
        var t:Number = sound[0] / 4;
        mTimeInc += (t - mTimeInc) / 8;
        mTime += mTimeInc;
        
        fc0[3] = mTime;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0 );    
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, fc2 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, fc3 );
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, fc4 );
        
        fc5[2] = mBlue;
        mContext.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, fc5 );
    }
    
}