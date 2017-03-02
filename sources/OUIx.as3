// forked from codeonwort's stage3d study - shadow on plane
// forked from codeonwort's stage3d study - the tetrahedron
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
            new Study_ShadowOnPlane(this, e.target.context3D)
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
            perspectiveTransform.perspectiveFieldOfViewLH(45, stage.stageWidth / stage.stageHeight, 0.1, 100)
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
        public var vbuf:Vector.<Number> // data for vertex buffer. position
        public var nbuf:Vector.<Number> // normal
        public var cbuf:Vector.<Number> // color
        public var ibuf:Vector.<uint> // data for index buffer
        
        public function Geometry() 
        {
            _transform = new Matrix3D
            vbuf = new Vector.<Number>
            nbuf = new Vector.<Number>
            cbuf = new Vector.<Number>
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
        public function get deltaTransform():Matrix3D {
            var d:Vector.<Number> = _transform.rawData
            d[12] = d[13] = d[14] = 0
            return new Matrix3D(d)
        }
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
            nbuf = vbuf.concat();
            cbuf = Vector.<Number>([0, 1, 1, /* r g b */
                    1, 0, 0,
                    1, 0, 1,
                    1, 1, 0])
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
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Vector3D;
    import flash.utils.getTimer;
    
    /**
     * 평면에 그림자 렌더링하기
     * @author codeonwort
     */
    internal class Study_ShadowOnPlane extends Study_Base 
    {
        private var tet:TetrahedronGeometry
        
        private var colorbuf2:VertexBuffer3D
        private var ibuf:IndexBuffer3D
        
        private var plane_n:Vector3D = new Vector3D(0, 4, -1)
        private var plane_r:Vector3D = new Vector3D(0, 0, 5)
        private var light_d:Vector3D = new Vector3D(0, -1, 0)
        
        private var shadowColor:Vector.<Number> = Vector.<Number>([0, 0, 0, 0.6])
        private var shadowProgram:Program3D
        private var shadowProj:Vector.<Number>
        
        public function Study_ShadowOnPlane(document:Sprite, context:Context3D) 
        {
            super(document, context)
            
            tet = new TetrahedronGeometry(1, 1)
            tet.move(0, 0.5, 2.5)
            
            var vbuf:VertexBuffer3D = context.createVertexBuffer(4, 3)
            vbuf.uploadFromVector(tet.vbuf, 0, 4)
            context.setVertexBufferAt(0, vbuf, 0, 'float3')
            
            var cbuf:VertexBuffer3D = context.createVertexBuffer(4, 3)
            cbuf.uploadFromVector(tet.cbuf, 0, 4)
            context.setVertexBufferAt(1, cbuf, 0, 'float3')
            
            var nbuf:VertexBuffer3D = context.createVertexBuffer(4, 3)
            nbuf.uploadFromVector(tet.nbuf, 0, 4)
            context.setVertexBufferAt(2, nbuf, 0, 'float3')
            
            ibuf = context.createIndexBuffer(tet.ibuf.length)
            ibuf.uploadFromVector(tet.ibuf, 0, tet.ibuf.length)
            
/* 정점에 월드 - 원근 변환 적용
va0: vertex position
va1: vertex color
va2: vertex normal
vc0~3: world transform matrix
vc4~7: perspective transform matrix
vc12 : delta transform matrix
vc16 : light vector
*/
var vshader:String = <agal><![CDATA[
m44 vt0, va0, vc0
m44 op, vt0, vc4
mov v0, va1
m44 v1, va2, vc12
mov vt0, vc16
neg vt0, vt0
mov v2, vt0
neg vt1, va0
sub v3, vt1, vt0
]]></agal>
/* 픽셀 셰이더
v0: 버텍스 색
v1: 버텍스 노말
v2: 조명 벡터
v3 : 하프 벡터
fc0: 상수 - x:2, y:0.5, z:4
*/
var fshader:String = <agal><![CDATA[
dp3 ft0.x, v1, v2
sat ft0.x, ft0.x
div ft0.x, ft0.x, fc0.x
add ft0.x, ft0.x, fc0.y
pow ft0.x, ft0.x, fc0.z
dp3 ft1.x, v1, v3
pow ft1.x, ft1.x, fc0.z
mul ft2, v0, ft0.x
add oc, ft2, ft1.x
]]></agal>
            vsAsm.assemble('vertex', vshader)
            fsAsm.assemble('fragment', fshader)
            program.upload(vsAsm.agalcode, fsAsm.agalcode)
            
            context.setProgramConstantsFromMatrix('vertex', 4, perspectiveTransform, true)
            
/* 그림자 투영을 위한 정점 셰이더 (월드 -> 그림자 -> 원근 변환)
va0: vertex position
va1: vertex color
vc0~3: world transform matrix
vc4~7: perspective transform matrix
vc8~11: shadow projection matrix
*/
var vshader2:String = <agal><![CDATA[
m44 vt0, va0, vc0
m44 vt1, vt0, vc8
m44 op, vt1, vc4
mov vt0, va1
mov vt0, va2
]]></agal>
/* 그림자를 위한 픽셀 셰이더
fc0: 그림자 색
*/
var fshader2:String = <agal><![CDATA[
mov oc, fc1
]]></agal>
            shadowProgram = context.createProgram()
            shadowProgram.upload(vsAsm.assemble('vertex', vshader2), fsAsm.assemble('fragment', fshader2))
            
            render()
            document.addEventListener('enterFrame', render)
        }
        
        // 특정 평면에 대한 그림자 투영 행렬을 만든다.
        // n: 평면의 단위 법선 벡터
        // r: 평면이 포함하는 임의의 점
        // L: 빛의 단위 방향 벡터
        private function makeShadowProj(n:Vector3D, r:Vector3D, L:Vector3D):Vector.<Number> {
            n.normalize();
            L.normalize();
            var nL:Number = n.dotProduct(L)
            var nr:Number = n.dotProduct(r)
            var proj:Vector.<Number> = new Vector.<Number>
            proj.push(nL - n.x * L.x, -n.y * L.x, -n.z * L.x, nr * L.x)
            proj.push(-n.x * L.y, nL - n.y * L.y, -n.z * L.y, nr * L.y)
            proj.push(-n.x * L.z, -n.y * L.z, nL - n.z * L.z, nr * L.z)
            proj.push(0, 0, 0, nL)
            for (var i:int = 0 ; i < proj.length ; i++) {
                proj[i] /= nL
            }
            /*
            proj.push(nL - n.x * L.x, -n.y * L.x, -n.z * L.x, nr * L.x)
            proj.push(-n.x * L.y, nL - n.y * L.y, -n.z * L.y, nr * L.y)
            proj.push(-n.x * L.z, -n.y * L.z, nL - n.z * L.z, nr * L.z)
            proj.push(0, 0, 0, nL)
            */
            return proj
        }
        
        protected override function setupContext():void {
            context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 4, true)
            context.setDepthTest(true, 'less')
        }
        
        private function render($:Object=null):void {
            var time:Number = getTimer()/1000
            light_d.x = Math.sin(time)/2
            light_d.z = Math.cos(time)/2
            shadowProj = makeShadowProj(plane_n, plane_r, light_d)
            var lightVec:Vector.<Number> = Vector.<Number>([light_d.x, light_d.y, light_d.z, light_d.w])
            var shaderConstV:Vector.<Number> = Vector.<Number>([1, 1, 1, 1])
            var shaderConstF:Vector.<Number> = Vector.<Number>([2, 0.5, 4, 0])
            context.setProgramConstantsFromVector('vertex', 16, lightVec)
            context.setProgramConstantsFromVector('vertex', 17, shaderConstV)
            context.setProgramConstantsFromVector('fragment', 0, shaderConstF)
            
            context.clear(.5, .5, .5, 1,
                            1 /*depth*/,
                            0 /*stencil*/)
            
            tet.prespinX(1)
            tet.prespinY(.75)
            tet.prespinZ(2)
            
            context.setCulling('back')
            
            context.setBlendFactors('one', 'zero')
            
            context.setProgram(program)
            context.setProgramConstantsFromMatrix('vertex', 0, tet.transform, true)
            context.setProgramConstantsFromMatrix('vertex', 12, tet.deltaTransform, true)
            context.drawTriangles(ibuf, 0, 4)

            context.setBlendFactors('one', 'oneMinusSourceAlpha')
            context.setProgram(shadowProgram)
            context.setProgramConstantsFromVector('fragment', 1, shadowColor)
            context.setProgramConstantsFromVector('vertex', 8, shadowProj, 4)
            context.drawTriangles(ibuf, 0, 4)
            
            context.present()
        }
        
    }

//}