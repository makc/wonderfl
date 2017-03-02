// forked from codeonwort's Flint Study 2
package {
    
    import flash.filters.BlurFilter;
    import flash.events.MouseEvent;
    import flash.events.Event
    import flash.display.BitmapData
    import flash.display.Bitmap
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    
    import org.flintparticles.common.actions.*;
    import org.flintparticles.common.particles.*;
    import org.flintparticles.common.counters.*;
    import org.flintparticles.common.initializers.*;
    import org.flintparticles.twoD.actions.*;
    import org.flintparticles.twoD.emitters.Emitter2D;
    import org.flintparticles.twoD.initializers.*;
    import org.flintparticles.twoD.renderers.*;
    import org.flintparticles.twoD.zones.*;
    
    public class FlashTest extends Sprite {
        
        private var colorInit:ColorInit
        private var dst:BitmapData
        
        public function FlashTest() {
            var emitter:Emitter2D = new Emitter2D
            
            // renderer
            var renderer:BitmapLineRenderer = new BitmapLineRenderer(new Rectangle(0, 0, 465, 465))
            renderer.addFilter( new BlurFilter(4, 4, 2) )
            renderer.addEmitter(emitter)
            
            dst = new BitmapData(465, 465, true, 0x0)
            addChild( new Bitmap(dst) )
            
            // counter
            emitter.counter = new Blast(1000)
            
            // initializers
            emitter.addInitializer( colorInit = new ColorInit(0xff00ff00, 0xffffff00) )
            emitter.addInitializer( new Position( new DiscZone( new Point(465/2, 465/2), 200) ) )
            
            // actions
            emitter.addAction( new Move );
            emitter.addAction( new GravityWell(100, 100, 100) )
            emitter.addAction( new GravityWell(100, 465 - 100, 100) )
            emitter.addAction( new GravityWell(100, 100, 465 - 100) )
            emitter.addAction( new GravityWell(100, 465 - 100, 465 - 100) )
            emitter.addAction( new GravityWell(300, 465 / 2, 465 / 2) )
            
            stage.addEventListener(MouseEvent.MOUSE_DOWN, recolor)
            function recolor(e:MouseEvent):void {
                colorInit.minColor = 0xff000000 | Math.random() * 0xffffff
                colorInit.maxColor = 0xff000000 | Math.random() * 0xffffff
                for each(var p:Particle in emitter.particles){
                    colorInit.initialize(emitter, p)
                }
            }
            
            addEventListener(Event.ENTER_FRAME, loop)
            function loop(e:Event):void {
                halo(renderer.bitmapData, renderer.bitmapData.rect, dst, zero, 6)
            }
            
            // run
            emitter.start()
        }
        
    }
    
}

    import flash.display.BitmapData
    
    import flash.filters.BlurFilter
    import flash.filters.ColorMatrixFilter
    import flash.filters.DisplacementMapFilter
    import flash.geom.ColorTransform
    import flash.geom.Rectangle
    import flash.geom.Matrix
    import flash.geom.Point

        const DEGREE_TO_RAD:Number = Math.PI / 180
        const zero:Point = new Point
        const blur4:BlurFilter = new BlurFilter(4, 4)
        const blur8:BlurFilter = new BlurFilter(8, 8)
        const halfAlphaCT:ColorTransform = new ColorTransform(1,1,1, 0.5)
        const blackCMF:ColorMatrixFilter
            =  new ColorMatrixFilter( [1/3, 1/3, 1/3, 0, 0, 1/3, 1/3, 1/3, 0, 0, 1/3, 1/3, 1/3, 0, 0,  0, 0, 0, 1, 0] )

function halo(src:BitmapData, srcRect:Rectangle, dst:BitmapData, dstPoint:Point,
                                        steps:uint, threshold:uint=127, centerX:Number=0.5, centerY:Number=0.5,
                                        scaleFactor:Number=1.02, isMonochrome:Boolean=false):void {
    if(steps == 0){
        dst.copyPixels(src, src.rect, dstPoint)
        return
    }
    
    var cx:Number = centerX * srcRect.width
    var cy:Number = centerY * srcRect.height
    var mat:Matrix = new Matrix
    
    var temp:BitmapData = new BitmapData(srcRect.width, srcRect.height, true, 0xffffffff)
    if(isMonochrome){
        temp.threshold(src, src.rect, zero, "<", threshold, 0x00000000, 0xff)
    }else{
        var temp2:BitmapData = new BitmapData(srcRect.width, srcRect.height, true, 0xffffffff)
        temp2.applyFilter(src, srcRect, zero, blackCMF)
        temp.threshold(temp2, temp2.rect, zero, "<", threshold, 0x00000000, 0xff)
        temp2.dispose()
    }
    
    for(var i:int=0 ; i<steps ; i++){
        temp.draw(temp, mat, halfAlphaCT)
        mat.translate(-cx, -cy)
        mat.scale(scaleFactor, scaleFactor)
        mat.translate(cx, cy)
    }
    temp.applyFilter(temp, temp.rect, zero, blur8)
    
    dst.copyPixels(src, srcRect, dstPoint)
    dst.draw(temp, new Matrix, null, "add")
    temp.dispose()
}