package {
    import flash.events.MouseEvent;
    
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.utils.setTimeout
    
    import org.flintparticles.common.events.EmitterEvent
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
        
        private var startx:Number, starty:Number
        
        public function FlashTest() {
            // write as3 code here..
            stage.addEventListener("mouseDown", md)
        }
        
        private function md(e:MouseEvent):void {
            startx = e.stageX
            starty = e.stageY
            stage.addEventListener("mouseMove", mm)
            stage.addEventListener("mouseUp", mu)
        }
        
        private function mm(e:MouseEvent):void {
            graphics.clear()
            graphics.lineStyle(1, 0x00ff00)
            graphics.moveTo(startx, starty)
            graphics.lineTo(e.stageX, e.stageY)
        }
        
        private function mu(e:MouseEvent):void {
            bleedItOut( new Point(startx, starty) , new Point(e.stageX, e.stageY) )
            stage.removeEventListener("mouseMove", mm)
            stage.removeEventListener("mouseUp", mu)
        }
        
        public function bleedItOut(e0:Point, e1:Point):void {
            var emitter:Emitter2D = new Emitter2D
            
            // renderer
            var renderer:BitmapLineRenderer = new BitmapLineRenderer(new Rectangle(0, 0, 465, 465))
            renderer.clearBetweenFrames = true
            renderer.addEmitter(emitter)
            addChild(renderer)
            
            // counter
            emitter.counter = new TimePeriod(1000, 2)
            
            // initializers
            emitter.addInitializer( new ColorInit(0xffff0000, 0xffff0000) )
            emitter.addInitializer( new Position( new LineZone(e0, e1) ) );
            emitter.addInitializer( new Velocity( new LineZone( new Point(-100, -300), new Point(100, -300) ) ) )
            emitter.addInitializer( new Lifetime(2) )
            
            // actions
            emitter.addAction( new Age )
            emitter.addAction( new Move );
            emitter.addAction( new CollisionZone( new RectangleZone(0, 0, 465, 465) , 0.2 ) )
            emitter.addAction( new Accelerate( 0, 600 ) );
            
            // run
            emitter.start()
            
            emitter.addEventListener(EmitterEvent.EMITTER_EMPTY, dispose)
            function dispose(e:EmitterEvent):void {
                emitter.stop()
                removeChild(renderer)
            }

        }
        
    }
    
}