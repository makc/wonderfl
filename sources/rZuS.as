package  
{
    import com.adobe.utils.AGALMiniAssembler;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    /**
     * AGALとフラグメントシェーダーの練習。
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0x000000", frameRate = "30", width = "465", height = "465")]
    public class Test76 extends Sprite
    {
        private var stage3D: Stage3D;
        private var context3D: Context3D;
        private var indexBuffer: IndexBuffer3D;
        private var vc0: Matrix3D;
        private var fc0: Vector.<Number>;
        private var fc1: Vector.<Number>;
        
        public function Test76() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // 
            stage3D = stage.stage3Ds[0];
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onCreateContext3D);
            stage3D.requestContext3D();
        }
        
        private function onCreateContext3D(e: Event): void 
        {
            
            context3D = stage3D.context3D;
            if (!context3D) 
                return;
            //
            //CONFIG::debug
            {
                context3D.enableErrorChecking = true;
            }
            context3D.configureBackBuffer(465, 465, 0);
            
            createVertexBuffer();
            createIndexBuffer();
            createProgram();
            vc0 = new Matrix3D();
            vc0.appendScale(0.5, 0.5, 0.5);
            fc0 = Vector.<Number>([0, 0.8, 0.9, 0.5]);
            fc1 = Vector.<Number>([0.2, 0.3, 0, 0]);
            context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0);
            context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1);
            addEventListener(Event.ENTER_FRAME, loop);
        }
        
        private function createVertexBuffer(): void 
        {
            var a: Number = 2;
            var vertexBuffer: VertexBuffer3D = context3D.createVertexBuffer(4, 3);
            vertexBuffer.uploadFromVector(Vector.<Number>([
                -a, -a, 0, // x, y, z
                 a, -a, 0, 
                -a,  a, 0, 
                 a,  a, 0, 
            ]), 0, 4);
            context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
        }
        
        
        private function createIndexBuffer(): void
        {
            indexBuffer = context3D.createIndexBuffer(6);
            indexBuffer.uploadFromVector(Vector.<uint>([
                0, 1, 2,
                1, 3, 2
            ]), 0, 6);
        }
        
        private function createProgram():void 
        {
            var assembler: AGALMiniAssembler = new AGALMiniAssembler();
            var program: Program3D = context3D.createProgram();
            program.upload(
                assembler.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER), 
                assembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER)
            );
            context3D.setProgram(program);
        }
        private function loop(e:Event):void 
        {
            vc0.appendRotation(1, Vector3D.Z_AXIS);
            context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, vc0);
            context3D.clear();
            context3D.drawTriangles(indexBuffer);
            context3D.present();
        }
    }
}
const VERTEX_SHADER: String = <><![CDATA[
m44 op, va0, vc0
mov v0, va0
]]></>;
const FRAGMENT_SHADER: String = <><![CDATA[
add ft0.x, v0.x, fc1.x
add ft0.y, v0.y, fc1.y
mul ft0.x, ft0.x, ft0.x
mul ft0.y, ft0.y, ft0.y
add ft0.x, ft0.x, ft0.y
sqt ft0.x, ft0.x
sub ft0.x, fc0.w, ft0.x
kil ft0.x
mov oc, fc0
]]></>;