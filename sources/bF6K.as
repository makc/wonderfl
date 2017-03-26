// forked from codeonwort's Flint Study 1
// forked from codeonwort's Flint Study 2
package {
    import flash.geom.ColorTransform;
    import flash.display.Shape;
    
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
        
        private var zone:RectangleZone
        private var grav:GravityWell
        private var zero:Point = new Point
        
        public function FlashTest() {
            var emitter:Emitter2D = new Emitter2D
            
            // renderer
            var renderer:BitmapLineRenderer = new BitmapLineRenderer(new Rectangle(0, 0, 465, 465))
            renderer.addEmitter(emitter)
            addChild(renderer)
            
            // counter
            emitter.counter = new Steady(100)
            
            // initializers
            emitter.addInitializer( new ColorInit(0xff000000, 0xffff0000) )
            emitter.addInitializer( new Position( new DiscZone( new Point(465/2, 465/2), 200) ) )
            
            // actions
            emitter.addAction( new Move );
            /* make death zone */
            emitter.addAction( new DeathZone( zone = new RectangleZone(0, 0, 60, 60) ) )
            emitter.addAction( grav = new GravityWell(2500, 0, 0) )
            
            var indicator:Shape = new Shape
            indicator.graphics.lineStyle(1, 0xff0000)
            indicator.graphics.drawRect(0, 0, 60, 60)
            addChild(indicator)
            stage.addEventListener("mouseMove", function(e:Object):void{
                /* change properties of zone for death zone action */
                indicator.x = zone.left = mouseX - 30
                indicator.y = zone.top = mouseY - 30
                zone.right = zone.left + 60
                zone.bottom = zone.top + 60
                grav.x = mouseX
                grav.y = mouseY
            })
            
            // run
            emitter.start()
            
            var alphaCT:ColorTransform = new ColorTransform(1,1,1, 0.95)
            addEventListener("enterFrame", loop)
            function loop(e:Object):void {
                renderer.bitmapData.colorTransform(renderer.bitmapData.rect, alphaCT)
            }

        }
        
    }
    
}