package {
    
    import flash.display.Sprite
    import flash.events.Event
    
    public class Main extends Sprite {
        
        public function Main() {
            stage.scaleMode = "noScale"
            stage.align = "LT"
            
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, initStage3D)
            stage.stage3Ds[0].requestContext3D()
        }
        
        private function initStage3D(e:Event):void {
            new Study_Tetrahedron(this, e.target.context3D)
        }
        
    }
    
}

//package  
//{
    import com.adobe.utils.AGALMiniAssembler;
    import com.adobe.utils.PerspectiveMatrix3D;
    
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTriangleFace
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.Event
    import flash.geom.Matrix3D;
    /**
     * ...
     * @author codeonwort
     */
    internal class Study_Base 
    {
        
        protected var document:Sprite, stage:Stage, context:Context3D
        //protected var antiAlias:int = 4, enableDepthAndStencil:Boolean = false
        
        protected var perspectiveTransform:PerspectiveMatrix3D
        
        //protected var vertBuf:VertexBuffer3D
        //protected var idxBuf:IndexBuffer3D
        
        protected var vsAsm:AGALMiniAssembler
        protected var fsAsm:AGALMiniAssembler
        protected var program:Program3D
        
        public function Study_Base(document:Sprite, context:Context3D) 
        {
            this.document = document
            stage = document.stage
            this.context = context
            
            stage.addEventListener("resize", resize)
            
            vsAsm = new AGALMiniAssembler
            fsAsm = new AGALMiniAssembler
            perspectiveTransform = new PerspectiveMatrix3D
            perspectiveTransform.perspectiveFieldOfViewLH(45, stage.stageWidth / stage.stageHeight, 0, 100)
            program = context.createProgram()
            
            setupContext()
        }
        
        protected function resize(e:Event = null):void {
            setupContext()
        }
        
        protected function setupContext():void {
            context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 4, false)
        }
        
        // 셰이더 코드에 \n + 붙이기 귀찮아서
        protected function unify(...commands):String {
            var str:String = ""
            for each(var cmd:String in commands) {
                str += cmd + "\n"
            }
            return str
        }
        
    }

//}

//package  
//{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    /**
     * ...
     * @author ...
     */
    internal class Geometry 
    {
        private static const xAxis:Vector3D = new Vector3D(1, 0, 0)
        private static const yAxis:Vector3D = new Vector3D(0, 1, 0)
        private static const zAxis:Vector3D = new Vector3D(0, 0, 1)
        
        private var _transform:Matrix3D
        public var vbuf:Vector.<Number> // data for vertex buffer
        public var ibuf:Vector.<uint> // data for index buffer
        
        public function Geometry() 
        {
            _transform = new Matrix3D
            vbuf = new Vector.<Number>
            ibuf = new Vector.<uint>
        }
        
        // append
        public function move(x:Number, y:Number, z:Number):void {
            _transform.appendTranslation(x, y, z)
        }
        public function spin(degrees:Number, axis:Vector3D, pivot:Vector3D=null):void {
            _transform.appendRotation(degrees, axis, pivot)
        }
        public function spinX(degrees:Number, pivot:Vector3D = null):void {
            _transform.appendRotation(degrees, xAxis, pivot)
        }
        public function spinY(degrees:Number, pivot:Vector3D = null):void {
            _transform.appendRotation(degrees, yAxis, pivot)
        }
        public function spinZ(degrees:Number, pivot:Vector3D = null):void {
            _transform.appendRotation(degrees, zAxis, pivot)
        }
        public function zoom(x:Number, y:Number, z:Number):void {
            _transform.appendScale(x, y, z)
        }
        
        // prepend
        public function premove(x:Number, y:Number, z:Number):void {
            _transform.prependTranslation(x, y, z)
        }
        public function prespin(degrees:Number, axis:Vector3D, pivot:Vector3D=null):void {
            _transform.prependRotation(degrees, axis, pivot)
        }
        public function prespinX(degrees:Number, pivot:Vector3D = null):void {
            _transform.prependRotation(degrees, xAxis, pivot)
        }
        public function prespinY(degrees:Number, pivot:Vector3D = null):void {
            _transform.prependRotation(degrees, yAxis, pivot)
        }
        public function prespinZ(degrees:Number, pivot:Vector3D = null):void {
            _transform.prependRotation(degrees, zAxis, pivot)
        }
        public function prezoom(x:Number, y:Number, z:Number):void {
            _transform.prependScale(x, y, z)
        }
        
        public function get transform():Matrix3D { return _transform }
        
    }

//}

//package  
//{
    /**
     * ...
     * @author ...
     */
    internal class TetrahedronGeometry extends Geometry 
    {
        
        public function TetrahedronGeometry(size:Number=1, winding:int = 1) 
        {
            var angle0:Number = Math.PI / 2
            var angle_delta:Number = 120 * Math.PI / 180
            var len:Number = size / Math.sqrt(3)
            var r:Number = 0.20412 * size
            
            vbuf.push(len * Math.cos(angle0), -r, len * Math.sin(angle0),
                    len * Math.cos(angle0 + angle_delta), -r, len * Math.sin(angle0 + angle_delta),
                    len * Math.cos(angle0 - angle_delta), -r, len * Math.sin(angle0 - angle_delta),
                    0, 0.61237 * size, 0)
            if (winding == -1) {
                ibuf.push(0, 2, 1,
                        1, 2, 3,
                        2, 0, 3,
                        0, 1, 3)
            }else if (winding == 1) {
                ibuf.push(1, 2, 0,
                        3, 2, 1,
                        3, 0, 2,
                        3, 1, 0)
            }else throw new ArgumentError('winding should be 1 or -1')
        }
        
    }

//}

//package  
//{
    import flash.display.Sprite;
    import flash.display3D.Context3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    
    /**
     * ...
     * @author ...
     */
    internal class Study_Tetrahedron extends Study_Base 
    {
        private var tet:TetrahedronGeometry
        private var ibuf:IndexBuffer3D
        
        public function Study_Tetrahedron(document:Sprite, context:Context3D) 
        {
            super(document, context)
            
            tet = new TetrahedronGeometry(1, 1)
            tet.move(0, 0, 3)
            
            var vbuf:VertexBuffer3D = context.createVertexBuffer(4, 3)
            vbuf.uploadFromVector(tet.vbuf, 0, 4)
            context.setVertexBufferAt(0, vbuf, 0, 'float3')
            
            var colorbuf:VertexBuffer3D = context.createVertexBuffer(4, 3)
            colorbuf.uploadFromVector(Vector.<Number>([0,0,0, 0,0,1, 0,1,0, 0,1,1]), 0, 4)
            context.setVertexBufferAt(1, colorbuf, 0, 'float3')
            
            ibuf = context.createIndexBuffer(tet.ibuf.length)
            ibuf.uploadFromVector(tet.ibuf, 0, tet.ibuf.length)
            
var vshader:String = <agal><![CDATA[
m44 vt0, va0, vc0
m44 op, vt0, vc4
mov v0, va1
]]></agal>
            
            vsAsm.assemble('vertex', vshader)
            fsAsm.assemble('fragment', 'mov oc, v0')
            program.upload(vsAsm.agalcode, fsAsm.agalcode)
            context.setProgram(program)
            
            context.setProgramConstantsFromMatrix('vertex', 4, perspectiveTransform, true)
            
            render()
            document.addEventListener('enterFrame', render)
        }
        
        private function render($:Object=null):void {
            context.clear(.5, .5, .5)
            
            tet.prespinX(5)
            tet.prespinY(2)
            
            context.setCulling('back')
            context.setProgramConstantsFromMatrix('vertex', 0, tet.transform, true)
            context.drawTriangles(ibuf, 0, 4)
            
            context.present()
        }
        
    }

//}