package {
    
    import flash.display.Sprite
    import flash.events.Event
    
    import flash.display3D.Context3D
    
    public class Stage3DBase extends Sprite {
        
        private var context:Context3D
        
        public function Stage3DBase() {
            // write as3 code here..
            stage ? init() : addEventListener("addedToStage", init)
        }
        
        private function init(e:Event = null):void {
            // never mind
            if(e) removeEventListener(e.type, arguments.callee)
            
            // request context 3d
            stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, contextGained)
            stage.stage3Ds[0].requestContext3D("auto")
        }
        
        // when I request context3D by Stage3D::requestContext3D
        // or when device loss occurs this listener is called.
        // make this listener to handle both situations.
        private function contextGained(e:Event):void {
            context = e.target.context3D
            
            var study:StudyBase = new StudyExample
            study.init(this, context)
        }
        
    }
    
}

import flash.display.Stage
import flash.display.Sprite
import flash.display3D.Context3D
import flash.display3D.Program3D
import flash.display3D.IndexBuffer3D
import flash.display3D.VertexBuffer3D
import com.adobe.utils.AGALMiniAssembler
class StudyBase {
    
    protected var document:Sprite
    protected var stage:Stage
    protected var context:Context3D
    protected var asm:AGALMiniAssembler
    
    protected var hardwareAccelerated:Boolean
    
    protected var vertBuf:VertexBuffer3D
    protected var idxBuf:IndexBuffer3D
    protected var program:Program3D
    
    public function StudyBase() {
        asm = new AGALMiniAssembler
    }
    
    public function init(doc:Sprite, cont:Context3D):void {
        if(context) context.dispose()
        context = cont
        document = doc
        stage = document.stage
        
        hardwareAccelerated = context.driverInfo.toLowerCase().indexOf("software") == -1
        
        program = context.createProgram()
    }
    
    protected function makeVertBuf(verts:Vector.<Number>, data32PerVert:uint):void {
        vertBuf = context.createVertexBuffer(verts.length / data32PerVert, data32PerVert)
        vertBuf.uploadFromVector(verts, 0, verts.length / data32PerVert)
    }
    protected function makeIdxBuf(indices:Vector.<uint>):void {
        idxBuf = context.createIndexBuffer(indices.length)
        idxBuf.uploadFromVector(indices, 0, indices.length)
    }
    
}

import flash.text.TextFormat
import flash.text.TextField
class StudyExample extends StudyBase {
    
    public override function init(doc:Sprite, cont:Context3D):void {
        super.init(doc, cont)
        
        var info:TextField = new TextField
        info.defaultTextFormat = new TextFormat(null, 30)
        info.selectable = false
        info.autoSize = "left"
        info.text = context.driverInfo + "\n"
        info.appendText("hardware accelerated: " + hardwareAccelerated)
        document.addChild(info)
        
        // readyResources()
        // render()
    }
    
    private function readyResources():void {
        // width, height, anti-alising level, useDepthBufferAndStencilBuffer
        // context.configureBackBuffer(465, 465, 4, false)
        
        // your code
    }
    
    private function render():void {
        // context.clear(0, 0, 0)
        
        // your code
        // context.setProgram(program)
        // context.drawTriangles(idxBuf, startIndex, numTriangles)
        
        // context.present()
    }
    
}
