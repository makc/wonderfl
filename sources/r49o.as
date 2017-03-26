// forked from codeonwort's context3D creation problem
package {
    
    import flash.display.Sprite;
    import flash.events.Event
    import flash.display.Stage3D
    import flash.display3D.Context3D
    import flash.display3D.Context3DRenderMode
    
    public class FlashTest extends Sprite {

        public function FlashTest() {
            // write as3 code here..
            //Wonderfl.disable_capture()
            stage ? init() : addEventListener("addedToStage", init)
        }
        
        private function init(e:Event=null):void {
            removeEventListener("addedToStage", arguments.callee)
            
            var s3d:Stage3D = stage.stage3Ds[0]
            s3d.addEventListener(Event.CONTEXT3D_CREATE, initStage3D)
            s3d.requestContext3D(Context3DRenderMode.AUTO)
        }
        
        private function initStage3D(e:Event):void {
            var context:Context3D = e.target.context3D as Context3D
            new Study03_ZoomBlur(this, context)
        }

    }
    
}
import flash.system.LoaderContext;
import flash.display.LoaderInfo;
import flash.display.DisplayObject;
import flash.text.TextField;
import flash.net.URLRequest;
import flash.display.Loader;

//package {
    import com.adobe.utils.AGALMiniAssembler;
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
        
        protected var worldTransform:Matrix3D
        
        protected var vertBuf:VertexBuffer3D
        protected var idxBuf:IndexBuffer3D
        
        protected var vertShaderAsm:AGALMiniAssembler
        protected var fragShaderAsm:AGALMiniAssembler
        protected var program:Program3D
        
        public function Study_Base(document:Sprite, context:Context3D) 
        {
            this.document = document
            stage = document.stage
            this.context = context
            
            stage.addEventListener("resize", resize)
            
            setupContext()
            readyResource()
            //render()
        }
        
        protected function resize(e:Event = null):void {
            setupContext()
        }
        
        protected function setupContext():void {
            context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 4, false)
            context.setCulling(Context3DTriangleFace.BACK)
            program = context.createProgram()
            vertShaderAsm = new AGALMiniAssembler
            fragShaderAsm = new AGALMiniAssembler
            worldTransform = new Matrix3D
            worldTransform.identity()
        }
        
        protected function readyResource():void {
            //
        }
        
        protected function render():void {
            //
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

//package {
    import flash.events.Event;
    import flash.utils.ByteArray;
    import flash.geom.Matrix;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.display.Sprite
    import flash.display3D.Context3D
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.Texture;
    
    import com.adobe.utils.AGALMiniAssembler
    import com.bit101.components.Slider
    /**
     * ...
     * @author codeonwort
     */
    internal class Study03_ZoomBlur extends Study_Base
    {
        public function Study03_ZoomBlur(document:Sprite, context:Context3D) 
        {
            super(document, context)
            var L:Loader = new Loader
            L.load(new URLRequest("http://assets.wonderfl.net/images/related_images/d/d9/d9b9/d9b9e27367920f3ef42cc14e1155ec0f18908b3b"), new LoaderContext(true))
            L.contentLoaderInfo.addEventListener("complete", load_complete)
            
            stage.addEventListener("keyDown", kd)
        }
        
        private var fragShaderAgalcodes:Vector.<ByteArray>
        
        private var cx_slider:Slider, cy_slider:Slider, step_slider:Slider
        private var zoomConst:Vector.<Number>
        
        protected override function resize(e:Event = null):void {
            super.resize(e)
            cx_slider.y = stage.stageHeight - 60
            cy_slider.y = stage.stageHeight - 40
            step_slider.y = stage.stageHeight - 20
            cx_slider.width = cy_slider.width = step_slider.width = stage.stageWidth - 40
        }
        
        /////////////////////////////////////////////////////////////////////////////////////////////
        // for capture the screen
        private var bmp:Bitmap
        private function kd(e:Object):void {
            if(bmp){
                bmp.bitmapData.dispose()
                document.removeChild(bmp)
                bmp = null
            }else{
                var bd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0xff0000)
                bmp = new Bitmap(bd)
                render()
                document.addChild(bmp)
            }
        }
        /////////////////////////////////////////////////////////////////////////////////////////////
        
        protected function load_complete(e:Event):void {
            var verts:Vector.<Number> = new Vector.<Number>
            verts.push( -1, -1, 0,
                        -1, 1, 0,
                        1, 1, 0,
                        1, -1, 0)
            vertBuf = context.createVertexBuffer(4, 3)
            vertBuf.uploadFromVector(verts, 0, 4)
            context.setVertexBufferAt(0, vertBuf, 0, "float3")
            
            var indices:Vector.<uint> = new Vector.<uint>
            indices.push(0, 1, 2,
                        2, 3, 0)
            idxBuf = context.createIndexBuffer(6)
            idxBuf.uploadFromVector(indices, 0, 6)
            
            var uv:Vector.<Number> = new Vector.<Number>
            uv.push(0, 1,
                    0, 0,
                    1, 0,
                    1, 1)
            var uvBuf:VertexBuffer3D = context.createVertexBuffer(4, 2)
            uvBuf.uploadFromVector(uv, 0, 4)
            context.setVertexBufferAt(1, uvBuf, 0, "float2")
            
            var info:LoaderInfo = e.target as LoaderInfo
            var img:Loader = info.loader
            var bd:BitmapData = new BitmapData(1024, 1024, false)
            var mat:Matrix = new Matrix
            mat.scale(bd.width / img.width, bd.height / img.height)
            try {
                bd.draw(img.content, mat)
            } catch(err:Error) {
                bd.perlinNoise(512, 512, 8, 12323, false, true)
            }
            var tex:Texture = context.createTexture(1024, 1024, "bgra", true)
            tex.uploadFromBitmapData(bd)
            context.setTextureAt(0, tex)
            
            // 슬라이더
            cx_slider = new Slider("horizontal", document, 20, stage.stageHeight - 60, change_center)
            cy_slider = new Slider("horizontal", document, 20, stage.stageHeight - 40, change_center)
            step_slider = new Slider("horizontal", document, 20, stage.stageHeight - 20, change_step)
            cx_slider.minimum = cy_slider.minimum = step_slider.minimum = 0
            cx_slider.maximum = cy_slider.maximum = 1
            step_slider.value = 10
            step_slider.maximum = 20
            cx_slider.value = cy_slider.value = 0.5
            cx_slider.width = cy_slider.width = step_slider.width = stage.stageWidth - 40
            
            // 정점 셰이더
            var vertShaderSrc:String = unify("m44 op, va0, vc0",
                                            "mov v0, va1")
            vertShaderAsm.assemble("vertex", vertShaderSrc)
            context.setProgramConstantsFromMatrix("vertex", 0, worldTransform)
            
            // 픽셀 셰이더 모든 단계별 캐싱
            fragShaderAgalcodes = new Vector.<ByteArray>
            zoomConst = new Vector.<Number>
            var zoomunit:String = unify("sub ft0.xy, ft0.xy, fc1.xy",
                                        "mul ft0.xy, ft0.xy, fc1.z",
                                        "add ft0.xy, ft0.xy, fc1.xy",
                                        "tex ft2, ft0, fs0 <2d,clamp,linear>",
                                        "mul ft2.xyz, ft2.xyz, fc2.w",
                                        "mul ft1.xyz, ft1.xyz, fc1.w",
                                        "add ft1.xyz, ft1.xyz, ft2.xyz")
            for (var j:int = 0; j <= step_slider.maximum; j++) {
                var fragShaderSrc:String = unify("mov ft0, v0",
                                                "tex ft1, ft0, fs0 <2d,clamp,linear>")
                for (var i:int = 0; i < j; i++) {
                    fragShaderSrc = unify(fragShaderSrc, zoomunit)
                }
                fragShaderSrc = unify(fragShaderSrc, "mov oc, ft1")
                fragShaderAsm.assemble("fragment", fragShaderSrc)
                fragShaderAgalcodes[j] = fragShaderAsm.agalcode
            }
            
            change_center()
            change_step()
        }
        
        private function change_center(e:Event = null):void {
            zoomConst.length = 0
            zoomConst.push(cx_slider.value, cy_slider.value, 0.99, 0.9,
                            0, 0, 0, 0.1)
            context.setProgramConstantsFromVector("fragment", 1, zoomConst, 2)
            
            render()
        }
        
        private function change_step(e:Event = null):void {
            program.upload(vertShaderAsm.agalcode, fragShaderAgalcodes[int(step_slider.value)])
            context.setProgram(program)
            
            render()
        }
        
        protected override function render():void {
            context.clear(0, 0, 0)
            context.drawTriangles(idxBuf, 0, 2)
            if(bmp) context.drawToBitmapData(bmp.bitmapData)
            context.present()
        }
        
    }

//}