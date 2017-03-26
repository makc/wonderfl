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

    [SWF(width="465", height="465", frameRate="60", backgroundColor="#000000")]
    public class Curves extends Sprite
    {
        private var mContext3d:Context3D;
        private var mVertBuffer:VertexBuffer3D;
        private var mIndexBuffer:IndexBuffer3D; 
        private var mProgram:Program3D;
        
        private var mMatrix:Matrix3D = new Matrix3D();
        
        public function Curves()
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
            
            mContext3d.setProgram(mProgram);
        }
        
        
        private function generateProgram():void
        {
            var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
            vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
                "m44 op, va0, vc0                                \n" +
                "mov v0, va1                                      "
            );
            
            var fragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
            fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
                "div ft0.x, v0.xy, fc0.y  \n" + 
                "div ft0.y, v0.xy, fc0.y  \n" + 
                "mov ft0.z, fc0.x  \n" + 
                "div ft0.z, ft0.z, fc0.y  \n" + 
                "div ft0.z, ft0.z, fc1.w  \n" + 
                "sub ft0.x, ft0.x, ft0.z  \n" + 
                "sub ft0.y, ft0.y, fc1.x  \n" + 
                "mov ft1.x, fc0.z  \n" + 
                "mov ft1.y, fc0.z  \n" + 
                "mul ft1.z, ft1.y, fc1.y  \n" + 
                "add ft1.z, ft1.z, fc0.x  \n" + 
                "div ft1.z, ft1.z, fc1.z  \n" + 
                "mul ft1.w, ft1.y, fc1.y  \n" + 
                "add ft1.w, ft1.w, fc1.x  \n" + 
                "mul ft1.z, ft1.z, fc0.w  \n" + 
                "add ft1.z, ft1.z, ft1.w  \n" + 
                "mul ft2.x, ft0.x, fc1.w  \n" + 
                "add ft2.x, ft2.x, ft1.z  \n" + 
                "sin ft2.x, ft2.x  \n" + 
                "mul ft2.x, ft2.x, fc2.x  \n" + 
                "add ft0.y, ft0.y, ft2.x  \n" + 
                "mul ft2.w, ft0.y, fc1.z  \n" + 
                "sub ft2.w, ft2.w, ft1.z  \n" + 
                "sin ft2.w, ft2.w  \n" + 
                "mul ft2.w, ft2.w, fc2.y  \n" + 
                "add ft0.x, ft0.x, ft2.w  \n" + 
                "mov ft3.x, fc2.z  \n" + 
                "mul ft3.x, ft3.x, fc1.x  \n" + 
                "mul ft3.x, ft3.x, ft0.y  \n" + 
                "sin ft3.x, ft3.x  \n" + 
                "mul ft3.y, fc2.w, ft0.x  \n" + 
                "sub ft3.y, ft3.y, ft1.z  \n" + 
                "sin ft3.y, ft3.y  \n" + 
                "add ft3.x, ft3.x, ft3.y  \n" + 
                "abs ft3.y, ft3.x  \n" + 
                "sqt ft3.y, ft3.y  \n" + 
                "rcp ft3.y, ft3.y  \n" + 
                "div ft3.y, ft3.y, fc3.x  \n" + 
                "add ft1.x, ft1.x, ft3.y  \n" + 
                "add ft1.y, ft1.y, fc0.x  \n" + 
                "mul ft1.z, ft1.y, fc1.y  \n" + 
                "add ft1.z, ft1.z, fc0.x  \n" + 
                "div ft1.z, ft1.z, fc1.z  \n" + 
                "mul ft1.w, ft1.y, fc1.y  \n" + 
                "add ft1.w, ft1.w, fc1.x  \n" + 
                "mul ft1.z, ft1.z, fc0.w  \n" + 
                "add ft1.z, ft1.z, ft1.w  \n" + 
                "mul ft2.x, ft0.x, fc1.w  \n" + 
                "add ft2.x, ft2.x, ft1.z  \n" + 
                "sin ft2.x, ft2.x  \n" + 
                "mul ft2.x, ft2.x, fc2.x  \n" + 
                "add ft0.y, ft0.y, ft2.x  \n" + 
                "mul ft2.w, ft0.y, fc1.z  \n" + 
                "sub ft2.w, ft2.w, ft1.z  \n" + 
                "sin ft2.w, ft2.w  \n" + 
                "mul ft2.w, ft2.w, fc2.y  \n" + 
                "add ft0.x, ft0.x, ft2.w  \n" + 
                "mov ft3.x, fc2.z  \n" + 
                "mul ft3.x, ft3.x, fc1.x  \n" + 
                "mul ft3.x, ft3.x, ft0.y  \n" + 
                "sin ft3.x, ft3.x  \n" + 
                "mul ft3.y, fc2.w, ft0.x  \n" + 
                "sub ft3.y, ft3.y, ft1.z  \n" + 
                "sin ft3.y, ft3.y  \n" + 
                "add ft3.x, ft3.x, ft3.y  \n" + 
                "abs ft3.y, ft3.x  \n" + 
                "sqt ft3.y, ft3.y  \n" + 
                "rcp ft3.y, ft3.y  \n" + 
                "div ft3.y, ft3.y, fc3.x  \n" + 
                "add ft1.x, ft1.x, ft3.y  \n" + 
                "mov ft4.x, fc0.z  \n" + 
                "mov ft1.y, fc0.z  \n" + 
                "mul ft1.z, ft1.y, fc3.z  \n" + 
                "mov ft1.w, fc0.w  \n" + 
                "mul ft1.w, ft1.w, fc3.y  \n" + 
                "add ft1.z, ft1.z, ft1.w  \n" + 
                "mul ft6.x, ft1.z, fc3.w  \n" + 
                "sin ft6.x, ft6.x  \n" + 
                "mul ft6.y, ft1.z, fc1.y  \n" + 
                "add ft6.y, ft6.y, fc0.x  \n" + 
                "sin ft6.y, ft6.y  \n" + 
                "mul ft6.z, ft1.z, fc4.x  \n" + 
                "add ft6.z, ft6.z, fc4.y  \n" + 
                "sin ft6.z, ft6.z  \n" + 
                "mul ft5.x, ft6.x, ft6.y  \n" + 
                "mul ft5.x, ft5.x, ft6.z  \n" + 
                "mul ft6.x, ft1.z, fc4.z  \n" + 
                "add ft6.x, ft6.x, fc4.w  \n" + 
                "sin ft6.x, ft6.x  \n" + 
                "mul ft6.y, ft1.z, fc4.y  \n" + 
                "add ft6.y, ft6.y, fc5.y  \n" + 
                "sin ft6.y, ft6.y  \n" + 
                "mul ft6.z, ft1.z, fc5.x  \n" + 
                "add ft6.z, ft6.z, fc5.y  \n" + 
                "sin ft6.z, ft6.z  \n" + 
                "mul ft5.y, ft6.x, ft6.y  \n" + 
                "mul ft5.y, ft5.y, ft6.z  \n" + 
                "sub ft6.x, ft0.x, ft5.x  \n" + 
                "mul ft6.x, ft6.x, ft6.x  \n" + 
                "sub ft6.y, ft0.y, ft5.y  \n" + 
                "mul ft6.y, ft6.y, ft6.y  \n" + 
                "add ft6.w, ft6.x, ft6.y  \n" + 
                "sqt ft6.w, ft6.w  \n" + 
                "div ft6.w, fc5.z, ft6.w  \n" + 
                "add ft4.x, ft4.x, ft6.w  \n" + 
                "add ft1.y, ft1.y, fc0.x  \n" + 
                "mul ft1.z, ft1.y, fc3.z  \n" + 
                "mov ft1.w, fc0.w  \n" + 
                "mul ft1.w, ft1.w, fc3.y  \n" + 
                "add ft1.z, ft1.z, ft1.w  \n" + 
                "mul ft6.x, ft1.z, fc3.w  \n" + 
                "sin ft6.x, ft6.x  \n" + 
                "mul ft6.y, ft1.z, fc1.y  \n" + 
                "add ft6.y, ft6.y, fc0.x  \n" + 
                "sin ft6.y, ft6.y  \n" + 
                "mul ft6.z, ft1.z, fc4.x  \n" + 
                "add ft6.z, ft6.z, fc4.y  \n" + 
                "sin ft6.z, ft6.z  \n" + 
                "mul ft5.x, ft6.x, ft6.y  \n" + 
                "mul ft5.x, ft5.x, ft6.z  \n" + 
                "mul ft6.x, ft1.z, fc4.z  \n" + 
                "add ft6.x, ft6.x, fc4.w  \n" + 
                "sin ft6.x, ft6.x  \n" + 
                "mul ft6.y, ft1.z, fc4.y  \n" + 
                "add ft6.y, ft6.y, fc5.y  \n" + 
                "sin ft6.y, ft6.y  \n" + 
                "mul ft6.z, ft1.z, fc5.x  \n" + 
                "add ft6.z, ft6.z, fc5.y  \n" + 
                "sin ft6.z, ft6.z  \n" + 
                "mul ft5.y, ft6.x, ft6.y  \n" + 
                "mul ft5.y, ft5.y, ft6.z  \n" + 
                "sub ft6.x, ft0.x, ft5.x  \n" + 
                "mul ft6.x, ft6.x, ft6.x  \n" + 
                "sub ft6.y, ft0.y, ft5.y  \n" + 
                "mul ft6.y, ft6.y, ft6.y  \n" + 
                "add ft6.w, ft6.x, ft6.y  \n" + 
                "sqt ft6.w, ft6.w  \n" + 
                "div ft6.w, fc5.z, ft6.w  \n" + 
                "add ft4.x, ft4.x, ft6.w  \n" + 
                "mov ft6.x, ft1.x  \n" + 
                "mov ft7.x, fc0.w  \n" + 
                "mul ft7.x, ft7.x, fc1.y  \n" + 
                "sin ft7.x, ft7.x  \n" + 
                "abs ft7.x, ft7.x  \n" + 
                "max ft7.x, ft7.x, fc1.y  \n" + 
                "mul ft5.x, ft7.x, ft6.x  \n" + 
                "mov ft7.y, fc0.w  \n" + 
                "mul ft7.y, ft7.y, fc5.w  \n" + 
                "add ft7.y, ft7.y, fc0.x  \n" + 
                "sin ft7.y, ft7.y  \n" + 
                "abs ft7.y, ft7.y  \n" + 
                "sub ft7.w, ft6.x, ft4.x  \n" + 
                "mul ft7.y, ft7.y, ft7.w  \n" + 
                "max ft5.y, ft7.y, fc1.y  \n" + 
                "max ft5.z, fc1.y, ft4.x  \n" + 
                "mov ft5.w, fc0.x  \n" + 
                "mov oc, ft5"
            );
            
            mProgram = mContext3d.createProgram();
            mProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
        }
        
        
        private var mTime:Number = 0.0;
        private function onTick(event:Event):void
        {
            if ( !mContext3d ) 
                return;
            
            mContext3d.clear ( 0, 0, 0, 1 );
            mContext3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mMatrix, true);
            
            
            //    FC0 = [  1.00, 1.00, 0.00,  time]
            //    FC1 = [  0.50, 0.10, 3.00,  2.00  ]
            //    FC2 = [  0.45, 0.25, 8.00,  6.10]
            //    FC3 = [ 10.00, 1.30, 2.50,  0.30]
            //    FC4 = [  0.56, 0.24, 0.11,  0.04]
            //    FC5 = [  0.18, 0.40, 0.07,  0.03];
            
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>( [ 1, 1, 0, mTime ]) );    
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Vector.<Number>( [ 0.50, 0.10, 3.00,  2.00 ]) );
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>( [ 0.45, 0.25, 8.00,  6.10 ]) );
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, Vector.<Number>( [ 10.00, 1.30, 2.50,  0.30 ]) );
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, Vector.<Number>( [ 0.56, 0.24, 0.11,  0.04 ]) );
            mContext3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, Vector.<Number>( [ 0.18, 0.40, 0.07,  0.03 ]) );
            
            mContext3d.drawTriangles(mIndexBuffer);
            mContext3d.present();
            
            mTime += .05;
            
        }
        
    }
}