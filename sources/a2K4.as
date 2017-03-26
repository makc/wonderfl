// forked from codeonwort's Flint Study 3
// forked from codeonwort's Flint Study 1
// forked from codeonwort's Flint Study 2
package {
    import flash.display.Shape;
    import flash.text.TextField;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.Event
    import flash.display.Sprite;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.ui.Keyboard
    import flash.utils.setInterval
    import flash.utils.clearInterval
    
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
    
    public class FlintTest4 extends Sprite {
        
        private var key:Object = {}
        private var player:Player
        private var emitter:Emitter2D
        private var itvID:int
        private var score:int = 0
        
        public function FlintTest4() {
            emitter = new Emitter2D
            
            // renderer
            var renderer:DisplayObjectRenderer = new DisplayObjectRenderer
            renderer.addEmitter(emitter)
            addChild(renderer)
            
            // initializers
            emitter.addInitializer( new ColorInit(0xff000000, 0xffff0000) )
            emitter.addInitializer( new ImageClass( Dot, 25 ) )
            emitter.addInitializer( new Position( new RectangleZone(150, 0, 465, 465) ) )
            
            // actions
            emitter.addAction( new Move );
            emitter.addAction( new MutualGravity( -1000, 10000, 50 ) )
            emitter.addAction( new CollisionZone( new RectangleZone( 0, 0, 465, 465 ) ) )
            
            // run
            emitter.counter = new Blast(5)
            emitter.start()
            itvID = setInterval(levelUp, 2000)
            
            addChild( player = new Player )
            player.x = player.y = player.radius
            
            addEventListener("enterFrame", gameLoop)
            stage.addEventListener("keyDown", kd)
            stage.addEventListener("keyUp", ku)
        }
        
        private function gameLoop(e:Event):void {
            if(isDown(Keyboard.LEFT)) player.x -= 7
            else if(isDown(Keyboard.RIGHT)) player.x += 7
            if(isDown(Keyboard.UP)) player.y -= 7
            else if(isDown(Keyboard.DOWN)) player.y += 7
            player.x = Math.max(10, Math.min(455, player.x))
            player.y = Math.max(10, Math.min(455, player.y))
            
            score ++
            
            // hit test
            var dx:Number, dy:Number
            for each(var p:Particle2D in emitter.particles){
                dx = p.x - player.x
                dy = p.y - player.y
                if(Math.sqrt(dx*dx + dy*dy) < (25 + player.radius)){
                    gameOver()
                }
            }
        }
        
        private function levelUp():void {
            var shape:Shape = new Shape
            shape.graphics.beginFill(0x0)
            shape.graphics.drawCircle(0, 0, 25)
            shape.x = 25 + Math.random() * 440
            shape.y = 25 + Math.random() * 440
            shape.alpha = 0
            addChild(shape)
            shape.addEventListener("enterFrame", particle_appearing)
            function particle_appearing(e:Object):void {
                shape.alpha += 0.05
                if(shape.alpha >= 1){
                    shape.removeEventListener("enterFrame", particle_appearing)
                    removeChild(shape)
                    var p:Particle2D = new Particle2D
                    emitter.addExistingParticles([p], true)
                    //emitter.addParticle(p, true)
                    p.x = shape.x
                    p.y = shape.y
                    p.collisionRadius = 25
                }
            }
        }
        
        private function gameOver():void {
            removeEventListener("enterFrame", gameLoop)
            for(;numChildren;)removeChildAt(0)
            var tf:TextField = new TextField
            tf.autoSize = "center"
            tf.x = tf.y = 465 / 2
            tf.text = "Game Over\nYour score is " + score
            tf.selectable = false
            addChild(tf)
            
            emitter.stop()
            clearInterval(itvID)
            player.alpha = .5
        }

        
        private function kd(e:KeyboardEvent):void {
            key[e.keyCode] = true
        }
        private function ku(e:KeyboardEvent):void {
            delete key[e.keyCode]
        }
        private function isDown(keyCode:uint):Boolean {
            return key[keyCode] != null
        }
        
    }
    
}

import flash.display.Shape
class Player extends Shape {
    public var radius:Number = 10
    public function Player() {
        with(graphics){
            lineStyle(1, 0x0)
            beginFill(0x123456)
            drawCircle(0, 0, radius)
        }
    }
}
