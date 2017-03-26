// forked from codeonwort's Flint Study 4
// forked from codeonwort's Flint Study 3
// forked from codeonwort's Flint Study 1
// forked from codeonwort's Flint Study 2
package {
    import flash.filters.DisplacementMapFilter;
    import flash.filters.BlurFilter
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.display.BitmapData
    import flash.display.Bitmap
    
    import org.flintparticles.common.actions.*;
    import org.flintparticles.common.particles.*;
    import org.flintparticles.common.counters.*;
    import org.flintparticles.common.initializers.*;
    import org.flintparticles.common.displayObjects.*
    import org.flintparticles.twoD.actions.*;
    import org.flintparticles.twoD.emitters.Emitter2D;
    import org.flintparticles.twoD.initializers.*;
    import org.flintparticles.twoD.renderers.*;
    import org.flintparticles.twoD.zones.*
    import org.flintparticles.twoD.particles.*;
    
    public class FlintTest5 extends Sprite {
        
        private var emitter:Emitter2D
        private var bd:BitmapData
        
        public function FlintTest5() {
            emitter = new Emitter2D
            
            // renderer
            var renderer:BitmapLineRenderer = new BitmapLineRenderer(new Rectangle(0, 0, 465, 465))
            renderer.clearBetweenFrames = true
            renderer.addFilter(new BlurFilter(2, 2, 1))
            renderer.addEmitter(emitter)
            addChild(renderer)
            
            // initializers
            emitter.addInitializer( new ColorInit(0xffff0000, 0xff000000) )
            emitter.addInitializer( new Position( new RectangleZone(150, 0, 465, 465) ) )
            
            // actions
            emitter.addAction( new Move );
            emitter.addAction( new MutualGravity( -1000, 10000, 50 ) )
            emitter.addAction( new CollisionZone( new RectangleZone( 0, 0, 465, 465 ) ) )
            
            // run
            emitter.counter = new Blast(300)
            emitter.start()
            
            bd = renderer.bitmapData
            var zero:Point = new Point
            var dmf:DisplacementMapFilter = new DisplacementMapFilter(bd, zero, 1, 1, 100, 100)
            addEventListener("enterFrame", function(e:Object):void{
                dmf.scaleX = (Math.random()-0.5) * 800
                dmf.scaleY = (Math.random()-0.5) * 800
                bd.applyFilter(bd, bd.rect, zero, dmf)
            })
            
            var blend:BitmapData = new BitmapData(465, 465, false, 0x0)
            addChild(new Bitmap(blend)).blendMode = "invert"
        }
        
    }
    
}
