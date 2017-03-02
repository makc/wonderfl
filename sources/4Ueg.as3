package {
    import flash.display.*;
    import flash.events.*;
    public class FlashTest extends Sprite {
        private var canvas :BitmapData;
        private var particles:Vector.<Particle> = new Vector.<Particle>();
        public function FlashTest() {
            var wLength:Number = stage.stageWidth*0.005;
            var hLength:Number = stage.stageHeight*0.005;
            
            for( var i :int =0; i<200; ++i ) {
                for( var j:int =0;j<200; ++j ) {
                    particles.push( new Particle( i*wLength, j*hLength ) );
                }
            }
            
            canvas = new BitmapData( stage.stageWidth, stage.stageHeight, true, 0xFF000000 );
            addChild( new Bitmap(canvas) );
            addEventListener( Event.ENTER_FRAME, onUpdate );
        }
        private function onUpdate( e:Event ):void {
            for each ( var p:Particle in particles ) {
                var dx:Number = mouseX - p.x;
                var dy:Number = mouseY - p.y;
                var far:Number = Math.sqrt( dx*dx +dy*dy );
                var idx:Number = dx/far * 200/far;
                var idy:Number = dy/far * 200/far;
                p.vx = p.vx*0.96+ idx;
                p.vy = p.vy*0.96+ idy;
                
                p.x += (p.ax-(p.x+p.vx))*0.9;
                p.y += (p.ay-(p.y+p.vy))*0.9;
            }
            
            canvas.lock();
            canvas.fillRect( canvas.rect, 0xFF000000 );
            for each ( p in particles ) {
                canvas.setPixel32( p.x, p.y, 0xFF660000 );
            }
            canvas.unlock();
        }
    }
}
internal class Particle {
    public var x:Number = 0;
    public var y:Number = 0;
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var ax:Number = 0;
    public var ay:Number = 0;
    public function Particle( x:Number, y:Number ){
        this.x = this.ax = x;
        this.y = this.ay = y;
    }
}