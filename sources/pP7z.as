package
{
    import com.adobe.utils.AGALMiniAssembler;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.utils.getTimer;
    
    /**
     * Ported from: http://glsl.heroku.com/e#10113.0
     * @author Devon O.
     */

    [SWF(width="465", height="465", frameRate="60", backgroundColor="#000000")]
    public class Main extends Sprite
    {
        
        // Really is the max, unfortunately
        private static const MAX:int = 4;

        private var mContext3d:Context3D;
        private var mVertBuffer:VertexBuffer3D;
        private var mIndexBuffer:IndexBuffer3D; 
        private var mProgram:Program3D;
        
        private var mMatrix:Matrix3D = new Matrix3D();
        
        public function Main()
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
            
            mContext3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 1);

            var vertices:Vector.<Number> = Vector.<Number>([
            //    x        y        z            u     v
                -1.0,  -1.0,    0,          0, 0, 
                -1.0,   1.0,    0,          0, 1,
                 1.0,   1.0,    0,          1, 1,
                 1.0,  -1.0,    0,          1, 0  ]);
            
            mVertBuffer = mContext3d.createVertexBuffer(4, 5);
            mVertBuffer.uploadFromVector(vertices, 0, 4);
            
            mIndexBuffer = mContext3d.createIndexBuffer(6);            
            mIndexBuffer.uploadFromVector (Vector.<uint>([0, 1, 2, 2, 3, 0]), 0, 6);
    
            mContext3d.setVertexBufferAt(0, mVertBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            mContext3d.setVertexBufferAt(1, mVertBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
            generateProgram();
            
            mContext3d.setProgram(mProgram);
        }
        
        private function generateProgram():void
        {
            var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
            vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
                "m44 op, va0, vc0 \n" +
                "mov v0, va1"
            );
            
            var fragmentShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
            
            var shader:String = "";
            shader += "mov ft0.xy, v0.xy \n";
            shader += "sub ft0.xy, ft0.xy, fc2.zz \n";
            shader += "mul ft0.xy, ft0.xy, fc0.xx \n";
            shader += "mov ft1.xy, ft0.xy \n";
            
            // color
            shader += "mov ft2.x, fc0.y \n";
            // intensity
            shader += "mov ft2.y, fc0.z \n";
            // counter
            shader += "mov ft2.z, fc2.y \n";
            
            //loop code
            var loop:String = "";
            loop += "rcp ft3.x, ft2.z \n";
            loop += "sub ft3.x, fc2.y, ft3.x \n";
            loop += "mul ft3.x, ft3.x, fc2.x \n";
            
            loop += "sub ft4.x, ft3.x, ft1.x \n";
            loop += "cos ft4.x, ft4.x \n";
            loop += "add ft4.y, ft3.x, ft1.y \n";
            loop += "cos ft4.y, ft4.y \n";
            loop += "add ft4.x, ft4.x, ft4.y \n";
        
            loop += "sub ft4.y, ft3.x, ft1.y \n";
            loop += "sin ft4.y, ft4.y \n";
            loop += "add ft4.z, ft3.x, ft1.x \n";
            loop += "cos ft4.z, ft4.z \n";
            loop += "add ft4.y, ft4.y, ft4.z \n";
        
            loop += "add ft1.x, ft1.x, ft4.x \n";
            loop += "add ft1.y, ft1.y, ft4.y \n";
        
            loop += "add ft4.x, ft1.x, ft3.x \n";
            loop += "sin ft4.x, ft4.x \n";
            loop += "div ft4.x, ft4.x, ft2.y \n";
            loop += "div ft4.x, ft0.x, ft4.x \n";
        
            loop += "add ft4.y, ft1.y, ft3.x \n";
            loop += "cos ft4.y, ft4.y \n";
            loop += "div ft4.y, ft4.y, ft2.y \n";
            loop += "div ft4.y, ft0.y, ft4.y \n";
        
            loop += "mov ft4.zw, fc0.yy \n";
            loop += "dp3 ft4.x, ft4, ft4 \n";
            loop += "rcp ft4.x, ft4.x \n";
        
            loop += "add ft2.x, ft2.x, ft4.x \n";
            loop += "add ft2.z, ft2.z, fc2.y \n";
            
            for (var i:int = 0; i < MAX; i++)
            {
                shader += loop;
            }
            
            shader += "div ft2.x, ft2.x, fc1.w \n";
            shader += "pow ft2.x, ft2.x, fc0.w \n";
            shader += "mul ft0.xyz, ft2.xxx, fc1.xyz \n";
            shader += "mov ft0.w, fc2.y \n";
            shader += "mov oc, ft0";
            
            fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT, shader);
            
            mProgram = mContext3d.createProgram();
            mProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
        }
        
        private function onTick(event:Event):void
        {
            if ( !mContext3d ) 
                return;
            
            mContext3d.clear ( 0, 0, 0, 1 );
            mContext3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mMatrix, true);
            
            var time:Number = getTimer() / 1000;
            var intensity:Number = .75;
            
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>( [ 6, 0, intensity, 1.25 ]) );    
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Vector.<Number>( [ .25, .3, 1.8, MAX ]) );
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>( [ time, 1.0, 0.5, 1.0 ]) );
            
            mContext3d.drawTriangles(mIndexBuffer);
            mContext3d.present();
        }
        
    }
}