package {
    
    import flash.geom.ColorTransform
    import flash.geom.Matrix
    import flash.display.Bitmap
    import flash.display.BitmapData
    import flash.display.Sprite
    import flash.display.Graphics
    import flash.display.Shape
    import flash.geom.Point
    import flash.events.Event
    import flash.filters.ColorMatrixFilter
    
    [SWF(width=500, height=500, frameRate=60, backgroundColor=0xffffff)]
    public class FlashTest extends Sprite {
        
        private const NUM:int = 33
        private var ps:Vector.<P> = new Vector.<P>(NUM, true) // N
        private var sh:Shape = new Shape
        private var g:Graphics = sh.graphics
        
        private var from:uint = Math.random() * 0xFF
        private var to:uint = Math.random() * 0xFF
        private var progress:Number = 0
        
        private var mat:Matrix
        private var cmf:ColorMatrixFilter = new ColorMatrixFilter([1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,0.9,0])
        private var pt:Point = new Point
        private var bd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0xffffff)
        
        public function FlashTest() {
            // write as3 code here..
            for(var i:int = 0 ; i < NUM ; i++){
                ps[i] = new P(i/NUM*stage.stageWidth, stage.stageHeight)
            }
            
            mat = new Matrix
            mat.translate(-stage.stageWidth/2, -stage.stageHeight)
            mat.scale(1.02, 1.035)
            mat.translate(stage.stageWidth/2, stage.stageHeight)
            addChild(new Bitmap(bd))
            addEventListener("enterFrame", loop)
        }
        
        private function loop(e:Event=null):void {
            for each(var p:P in ps) p.update()
            g.clear()
            progress += 0.05
            if(progress >= 1){
                progress = 0
                from = Math.random() * 0xff
                to = Math.random() * 0xff
            }
            g.lineStyle(0, interp(from, to, progress), 0.3)
            for(var i:int = 0 ; i < NUM-2 ; i+=2){
                g.moveTo(ps[i].x, ps[i].y)
                g.curveTo(ps[i+1].x, ps[i+1].y, ps[i+2].x, ps[i+2].y)
            }
            bd.draw(bd, mat)
            bd.draw(sh)
            bd.applyFilter(bd, bd.rect, pt, cmf)
        }
        
        private function interp(from:uint, to:uint, t:Number):uint {
            var r1:uint = (from >> 16) & 0xFF, g1:uint = (from >> 8) & 0xFF, b1:uint = from & 0xFF
            var r2:uint = (to >> 16) & 0xFF, g2:uint = (to >> 8) & 0xFF, b2:uint = to & 0xFF
            var r:uint = r1+(r2-r1)*t, g:uint = g1+(g2-g1)*t, b:int = b1+(b2-b1)*t
            return (r<<16) | (g<<8) | b
        }
        
    }
    
}

internal class P {
    public var x:Number, y:Number
    public var ty:Number, y0:Number
    public function P(x:Number, y0:Number) {
        this.x = x ; this.y = y0
        ty = this.y0 = y
    }
    public function update():void {
        if(y < ty) y += 1
        else if(y > ty) y -= 1
        if(Math.abs(y-ty)<3) ty = y0 - Math.random() * 40
    }

}
