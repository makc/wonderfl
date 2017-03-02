package
{
    import com.adobe.utils.AGALMiniAssembler;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.textures.Texture;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.utils.getTimer;
    
    /**
     * Inspired by this thing: https://www.shadertoy.com/view/Xsl3Wl
     * 
     * Never metaball I didn't like...
     * 
     * @author Devon O.
     */

    [SWF(width="465", height="465", frameRate="60", backgroundColor="#000000")]
    public class MetaBalls extends Sprite
    {
        
        private static const FRAGMENT_SHADER:String =
        <![CDATA[
        
        // calculate uv
        mov ft0.xy, v0.xy
        mov ft0.zw, fc5.xx
        sub ft0.xy, ft0.xy, fc3.ww
        mul ft0.xy, ft0.xy, fc4.xx
        
        // Cellular stuff
        mov ft1.x, fc4.z 
        pow ft1.x, ft1.x, fc4.y
        mul ft1.x, ft1.x, fc3.z
        
        mul ft2.x, ft1.x, ft0.y
        sin ft2.x, ft2.x
        mul ft2.x, ft2.x, fc5.y
        add ft0.y, ft0.y, ft2.x
        
        mul ft2.x, ft1.x, ft0.x
        sin ft2.x, ft2.x
        mul ft2.x, ft2.x, fc5.y
        add ft0.x, ft0.x, ft2.x
        
        //ball 1
        sub ft6, ft0, fc0
        dp3 ft2.x, ft6, ft6
        sqt ft2.x, ft2.x
        div ft2.x, fc4.w, ft2.x
        
        //ball 2
        sub ft6, ft0, fc1
        dp3 ft2.y, ft6, ft6
        sqt ft2.y, ft2.y
        div ft2.y, fc4.w, ft2.y
        
        //ball 3
        sub ft6, ft0, fc2
        dp3 ft2.z, ft6, ft6
        sqt ft2.z, ft2.z
        div ft2.z, fc4.w, ft2.z
        
        // add it up
        add ft2.x, ft2.x, ft2.y
        add ft2.x, ft2.x, ft2.z
        mov ft2.xyz, ft2.xxx
        
        // fall off
        pow ft2.x, ft2.x, fc3.y
        pow ft2.y, ft2.y, fc3.y
        pow ft2.z, ft2.z, fc3.y

        // crank up the red
        mul ft2.x, ft2.x, fc4.y
        
        // move 1 into alpha
        mov ft2.w, fc4.z
        
        mov oc, ft2
        
        ]]>
        
        private var mContext3d:Context3D;
        private var mVertBuffer:VertexBuffer3D;
        private var mIndexBuffer:IndexBuffer3D; 
        private var mProgram:Program3D;
        private var mMatrix:Matrix3D = new Matrix3D();
        private var mTexture:Texture;
        private var mTextureData:BitmapData;

        public function MetaBalls()
        {    
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);    
        }
        
        private function init(event:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            initStage();
            setS3d();

            addEventListener(Event.ENTER_FRAME, onTick);
        }
        
        
        private function setS3d():void
        {
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
            mContext3d = stage.stage3Ds[0].context3D;            
            
            mContext3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 1, true);
            
            var vertices:Vector.<Number> = Vector.<Number>([
            //    x        y        z            u     v
                -1.0,     -1.0,     0,          0, 0, 
                -1.0,      1.0,     0,             0, 1,
                 1.0,      1.0,     0,             1, 1,
                 1.0,     -1.0,     0,            1, 0  ]);
            
            mVertBuffer = mContext3d.createVertexBuffer(4, 5);
            mVertBuffer.uploadFromVector(vertices, 0, 4);
            
            mIndexBuffer = mContext3d.createIndexBuffer(6);            
            mIndexBuffer.uploadFromVector (Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);
    
            mContext3d.setVertexBufferAt(0, mVertBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            mContext3d.setVertexBufferAt(1, mVertBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
            
            generateProgram();
        }
        
        private function generateProgram():void
        {
            var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
                "m44 op, va0, vc0 \n" +
                "mov v0, va1 "
            );
            
            var fragmentShaderAssembler:AGALMiniAssembler= new AGALMiniAssembler();
            fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);
            
            mProgram = mContext3d.createProgram();
            mProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
        }
        
        // 3 metaballs
        private var mb1:Vector.<Number> = new <Number>[1.0, 1.0, 0.0, 0.0];
        private var mb2:Vector.<Number> = new <Number>[1.0, 1.0, 0.0, 0.0];
        private var mb3:Vector.<Number> = new <Number>[1.0, 1.0, 0.0, 0.0];
        
        // constants
        private var fc3:Vector.<Number> = new <Number>[ 1.0, 1.0, 1.0, 0.5];
        private var fc4:Vector.<Number> = new <Number>[ 2.0, 10.0, 1.0, 1.0];
        private var fc5:Vector.<Number> = new <Number>[ 0.0, .05, .025, 0.4];
        private function onTick(event:Event):void
        {
            if ( !mContext3d ) 
                return;
            
            mContext3d.clear ( 0, 0, 0, 1 );
            mContext3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mMatrix, true);
            mContext3d.setProgram(mProgram);
            mContext3d.setTextureAt(0, mTexture);
            
            var t:Number = getTimer() / 1000;
            var falloff:Number = 13.0;
            var ballSize:Number = .20;
            var cellSize:Number = 250.0;    // larger number = smaller cells
            
            // calculate ball positions
            mb1[0] = 1.0 * Math.sin(t);
            mb1[1] = 0.8 * Math.cos(t);
            
            mb2[0] = 1.0 * Math.sin(t);
            mb2[1] = 0.8 * Math.cos(t * 1.3);
            
            mb3[0] = 0.8 * Math.sin(t * 2.0);
            mb3[1] = 1.0 * Math.cos(t * 1.7);
            
            // some stuff to play with
            fc3[1] = falloff;
            fc4[3] = ballSize;
            fc3[2] = cellSize;
            
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mb1, 1);    
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, mb2, 1);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, mb3, 1);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, fc3, 1);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, fc4, 1);
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, fc5, 1);
            
            mContext3d.drawTriangles(mIndexBuffer);
            mContext3d.present();
        }
        
    }
}