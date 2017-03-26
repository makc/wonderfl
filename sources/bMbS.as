// forked from codeonwort's stage3d study - shadow on plane
// forked from codeonwort's stage3d study - the tetrahedron
package {
    
    import flash.display.BitmapData
    import flash.display.Bitmap
    import flash.display.Sprite
    import flash.events.KeyboardEvent
    import flash.events.Event
    import flash.ui.Keyboard
    
    public class Main extends Sprite {
        
        private var app:Study_Base
        private var snapshot:Bitmap
        
        public function Main() {
            stage.scaleMode = "noScale"
            stage.align = "LT"
            
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, initStage3D)
            stage.stage3Ds[0].requestContext3D()
            
            stage.addEventListener('keyDown', kd)
        }
        
        private function initStage3D(e:Event):void {
            app = new Study_ShadowOnPlane(this, e.target.context3D)
            snapshot = new Bitmap
        }
        
        private function kd(e:KeyboardEvent):void {
            if(e.keyCode == Keyboard.SPACE){
                if(snapshot.bitmapData){
                    removeChild(snapshot)
                    snapshot.bitmapData = null
                }else{
                    snapshot.bitmapData = app.askSnapshot()
                    addChild(snapshot)
                }
            }
        }
        
    }
    
}

//package  
//{
    import com.adobe.utils.AGALMiniAssembler
    import com.adobe.utils.PerspectiveMatrix3D
    
    import flash.display.Sprite
    import flash.display.Stage
    import flash.display3D.Context3D
    import flash.display3D.Context3DTriangleFace
    import flash.display3D.IndexBuffer3D
    import flash.display3D.Program3D
    import flash.display3D.VertexBuffer3D
    import flash.events.Event
    import flash.geom.Matrix3D
    import flash.display.BitmapData
    
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
        
        protected var snapshot:BitmapData
        protected var snapshotAsked:Boolean = false
        
        public function Study_Base(document:Sprite, context:Context3D) {
            this.document = document
            stage = document.stage
            this.context = context
            
            stage.addEventListener("resize", resize)
            
            vsAsm = new AGALMiniAssembler
            fsAsm = new AGALMiniAssembler
            perspectiveTransform = new PerspectiveMatrix3D
            program = context.createProgram()
            
            snapshot = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x0)
            setupView()
        }
        
        protected function resize(e:Event = null):void {
            setupView()
        }
        
        protected function setupView():void {
            perspectiveTransform.perspectiveFieldOfViewLH(45, stage.stageWidth / stage.stageHeight, 0.1, 100)
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
        
        public function askSnapshot():BitmapData {
            snapshotAsked = true
            return snapshot
        }
        
    }

//}

//package  
//{
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    
    internal class Geometry 
    {
        private static const xAxis:Vector3D = new Vector3D(1, 0, 0)
        private static const yAxis:Vector3D = new Vector3D(0, 1, 0)
        private static const zAxis:Vector3D = new Vector3D(0, 0, 1)
        
        protected var _transform:Matrix3D
        public var vbuf:Vector.<Number> // data for vertex buffer
        //public var vtbuf:Vector.<Number>
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
    internal class TetrahedronGeometry extends Geometry 
    {
        
        public function TetrahedronGeometry(size:Number=1, CW:Boolean = true) 
        {
            var angle0:Number = Math.PI / 2
            var angle_delta:Number = 120 * Math.PI / 180
            var len:Number = size / Math.sqrt(3)
            var r:Number = 0.20412 * size
            
            vbuf.push(len * Math.cos(angle0), -r, len * Math.sin(angle0),
                    len * Math.cos(angle0 + angle_delta), -r, len * Math.sin(angle0 + angle_delta),
                    len * Math.cos(angle0 - angle_delta), -r, len * Math.sin(angle0 - angle_delta),
                    0, 0.61237 * size, 0)
            if(CW){
                ibuf.push(1, 2, 0,
                    3, 2, 1,
                    3, 0, 2,
                    3, 1, 0)
            }else{
                ibuf.push(0, 2, 1,
                    1, 2, 3,
                    2, 0, 3,
                    0, 1, 3)
            }
        }
        
    }

//}

    /**
     * 2차원 평면을 나타낸다.
     * @author codeonwort
     */
    internal class PlaneGeometry extends Geometry 
    {
        private var _norm:Vector3D
        private var _innerPoint:Vector3D
        
        public function PlaneGeometry(w:Number, h:Number, cw:Boolean = true) {
            w *= .5
            h *= .5
            vbuf.push( -w, -h, 0, w, -h, 0, w, h, 0, -w, h, 0)
            //vtbuf.push(0,1,1,1,1,0,0,0)
            ibuf.push(0, 1, 2, 2, 3, 0)
            if (cw) ibuf = ibuf.reverse()
            
            _norm = new Vector3D(0, 0, 1, 0)
            _innerPoint = new Vector3D(0, 0, 0, 1)
        }
        
        public function get numVertices():uint { return 4 }
        public function get numTriangles():uint { return 2 }
        public function get normal():Vector3D {
            return _transform.deltaTransformVector(_norm)
        }
        public function get innerPoint():Vector3D {
            return _transform.transformVector(_innerPoint)
        }
        
    }

//package  
//{
    import flash.display.Sprite;
    import flash.display3D.Context3D;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Vector3D;
    
    /**
     * 평면에 그림자 렌더링하기
     * @author codeonwort
     */
    internal class Study_ShadowOnPlane extends Study_Base 
    {
        private var tet:TetrahedronGeometry
        private var tet_vbuf:VertexBuffer3D
        private var colorbuf:VertexBuffer3D
        private var ibuf:IndexBuffer3D
        
        private var plane:PlaneGeometry
        private var plane_colorBuf:VertexBuffer3D
        private var plane_vbuf:VertexBuffer3D
        private var plane_ibuf:IndexBuffer3D
        private var plane_colorbuf:VertexBuffer3D
        
        private var shadowColor:Vector.<Number> = Vector.<Number>([0, 0, 0, 0.6])
        private var shadowProgram:Program3D
        private var shadowProj:Vector.<Number>
        
        public function Study_ShadowOnPlane(document:Sprite, context:Context3D) 
        {
            super(document, context)
            
            // make a tetrahedron
            tet = new TetrahedronGeometry(1)
            tet.move(0, 0.7, 2)
            
            tet_vbuf = context.createVertexBuffer(4, 3)
            tet_vbuf.uploadFromVector(tet.vbuf, 0, 4)
            
            colorbuf = context.createVertexBuffer(4, 3)
            colorbuf.uploadFromVector(
            Vector.<Number>([0, 1, 1, /* r g b */
                            1, 0, 0,
                            1, 0, 1,
                            1, 1, 0]), 0, 4)
            
            ibuf = context.createIndexBuffer(tet.ibuf.length)
            ibuf.uploadFromVector(tet.ibuf, 0, tet.ibuf.length)
            
            // make a plane
            plane = new PlaneGeometry(2, 1.7)
            plane.spinX(45)
            plane.move(0, -0.2, 2)
            plane_vbuf = context.createVertexBuffer(plane.numVertices, 3)
            plane_vbuf.uploadFromVector(plane.vbuf, 0, plane.numVertices)
            plane_ibuf = context.createIndexBuffer(plane.ibuf.length)
            plane_ibuf.uploadFromVector(plane.ibuf, 0, plane.ibuf.length)
            plane_colorbuf = context.createVertexBuffer(plane.numVertices, 3)
            plane_colorbuf.uploadFromVector(
                Vector.<Number>([0,1,1, 1,0,0, 1,0,1, 1,1,0]), 0, 4)
            
            vsAsm.assemble('vertex', vshader)
            fsAsm.assemble('fragment', fshader)
            program.upload(vsAsm.agalcode, fsAsm.agalcode)
            
            shadowProgram = context.createProgram()
            shadowProgram.upload(vsAsm.assemble('vertex', vshader2), fsAsm.assemble('fragment', fshader2))
            
            var plane_n:Vector3D = plane.normal
            var plane_r:Vector3D = plane.innerPoint
            var light_d:Vector3D = new Vector3D(1, -1, 0)
            light_d.normalize()
            shadowProj = makeShadowProj(plane_n, plane_r, light_d)
            
            render()
            document.addEventListener('enterFrame', render)
        }
        
        // 특정 평면에 대한 그림자 투영 행렬을 만든다.
        // n: 평면의 단위 법선 벡터
        // r: 평면이 포함하는 임의의 점
        // L: 빛의 단위 방향 벡터
        private function makeShadowProj(n:Vector3D, r:Vector3D, L:Vector3D):Vector.<Number> {
            var nL:Number = n.dotProduct(L)
            var nr:Number = n.dotProduct(r)
            var proj:Vector.<Number> = new Vector.<Number>
            proj.push(nL - n.x * L.x, -n.y * L.x, -n.z * L.x, nr * L.x)
            proj.push(-n.x * L.y, nL - n.y * L.y, -n.z * L.y, nr * L.y)
            proj.push(-n.x * L.z, -n.y * L.z, nL - n.z * L.z, nr * L.z)
            proj.push(0, 0, 0, 1)
            for (var i:int = 0 ; i < 12 ; i++) proj[i] /= nL
            return proj
        }
        
        protected override function setupView():void {
            perspectiveTransform.perspectiveFieldOfViewLH(45, stage.stageWidth / stage.stageHeight, 0.1, 100)
            context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 4, true)
        }
        
        private function render($:Object=null):void {
            context.clear(.5, .5, .5, 1,
                            1 /*depth*/,
                            0 /*stencil*/)
            
            tet.prespinX(3)
            tet.prespinY(1)
            
            context.setCulling('back')
            
            // render the plane
            context.setDepthTest(true, 'less')
            context.setStencilReferenceValue(127)
            context.setStencilActions('frontAndBack', 'always', 'set', 'set', 'set')
            context.setBlendFactors('one', 'zero')
            context.setProgram(program)
            context.setVertexBufferAt(0, plane_vbuf, 0, 'float3')
            context.setVertexBufferAt(1, plane_colorbuf, 0, 'float3')
            context.setProgramConstantsFromMatrix('vertex', 0, plane.transform, true)
            context.drawTriangles(plane_ibuf, 0, plane.numTriangles)
            
            // render the shadow of the tetrahedron
            context.setDepthTest(true, 'always')
            context.setStencilReferenceValue(0)
            context.setStencilActions('frontAndBack', 'less')
            context.setBlendFactors('one', 'oneMinusSourceAlpha')
            context.setProgram(shadowProgram)
            context.setVertexBufferAt(0, tet_vbuf, 0, 'float3')
            context.setProgramConstantsFromMatrix('vertex', 0, tet.transform, true)
            context.setProgramConstantsFromVector('fragment', 0, shadowColor)
            context.setProgramConstantsFromVector('vertex', 8, shadowProj, 4)
            context.drawTriangles(ibuf, 0, 4)
            
            // render the tetrahedron
            context.setDepthTest(true, 'less')
            context.setStencilActions('frontAndBack', 'always')
            context.setBlendFactors('one', 'zero')
            context.setVertexBufferAt(0, tet_vbuf, 0, 'float3')
            context.setVertexBufferAt(1, colorbuf, 0, 'float3')
            context.setProgram(program)
            context.setProgramConstantsFromMatrix('vertex', 0, tet.transform, true)
            context.setProgramConstantsFromMatrix('vertex', 4, perspectiveTransform, true)
            context.drawTriangles(ibuf, 0, 4)
            
            if(snapshotAsked){
                snapshotAsked = false
                context.drawToBitmapData(snapshot)
            }
            
            context.present()
        }
        
    }

//}

// shaders //

/* 정점에 모델 - 원근 변환 적용
va0: vertex position
va1: vertex color
vc0~3: model transform matrix
vc4~7: perspective transform matrix
*/
const vshader:String = <agal><![CDATA[
m44 vt0, va0, vc0
m44 op, vt0, vc4
mov v0, va1
]]></agal>

const fshader:String = "mov oc, v0"

/* 그림자 투영을 위한 정점 셰이더 (모델 -> 그림자 -> 원근 변환)
va0: vertex position
va1: vertex color
vc0~3: model transform matrix
vc4~7: perspective transform matrix
vc8~11: shadow projection matrix
*/
const vshader2:String = <agal><![CDATA[
m44 vt0, va0, vc0
m44 vt0, vt0, vc8
m44 op, vt0, vc4
mov v0, va1
]]></agal>

/* 그림자를 위한 픽셀 셰이더
fc0: 그림자 색
*/
const fshader2:String = <agal><![CDATA[
mov oc, fc0
]]></agal>
