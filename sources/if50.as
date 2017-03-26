package {
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import net.hires.debug.Stats;
    
    [SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "0xFFFFFF")]
    public class Main extends Sprite {
        private var _bmd:BitmapData;
        
        private var _container1:Sprite;
        private var _container2:Bitmap;
        private var _screen2:BitmapData;
        
        private var _particles1:Vector.<Bitmap>;
        private var _particles2:Vector.<Particle>;
        
        private var _isTesting1:Boolean;
        
        public static const NUM_PARTICLES:int = 1000;
        public static const STAGE_RECT:Rectangle = new Rectangle(0, 0, 465, 465);
        public static const DEG_TO_RAD:Number = Math.PI / 180;
        
        public function Main() {
            _bmd = new BitmapData(32, 32, true, 0x40000000);
            
            _container1 = new Sprite();
            _container2 = new Bitmap(_screen2 = new BitmapData(465, 465, true, 0x00FFFFFF), "auto", true);
            
            _particles1 = new Vector.<Bitmap>(NUM_PARTICLES, true);
            _particles2 = new Vector.<Particle>(NUM_PARTICLES, true);
            for (var i:int = 0; i < NUM_PARTICLES; i++) {
                var bitmap:Bitmap = new Bitmap(_bmd, "auto", true);
                bitmap.x = 465 * Math.random();
                bitmap.y = 465 * Math.random();
                bitmap.rotation = 180 * Math.random();
                bitmap.scaleX = bitmap.scaleY = 0.5;
                _container1.addChild(_particles1[i] = bitmap);
                
                var particle:Particle = new Particle();
                particle.x = 465 * Math.random();
                particle.y = 465 * Math.random();
                particle.rotation = 180 * Math.random();
                _particles2[i] = particle;
            }
            
            _isTesting1 = true;
            addChild(_container1);
            
            stage.addChild(new Stats());
            stage.addChild(new PushButton(null, 182, 400, "Bitmap -> draw()", pushButtonHandler));
            
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        private function pushButtonHandler(event:MouseEvent):void {
            if (_isTesting1) {
                event.currentTarget.label = "draw() -> Bitmap";
                removeChild(_container1); addChild(_container2);
            } else {
                event.currentTarget.label = "Bitmap -> draw()";
                removeChild(_container2); addChild(_container1);
            }
            _isTesting1 = !_isTesting1;
        }
        
        private function update(event:Event):void {
            if (_isTesting1) {
                for (var i:int = 0; i < NUM_PARTICLES; i++) {
                    var bitmap:Bitmap = _particles1[i];
                    bitmap.x = (bitmap.x + 2) % 465;
                    bitmap.y = (bitmap.y + 2) % 465;
                    bitmap.rotation++;
                }
            } else {
                _screen2.lock();
                _screen2.fillRect(STAGE_RECT, 0x00FFFFFF);
                var matrix:Matrix = new Matrix();
                for (i = 0; i < NUM_PARTICLES; i++) {
                    var particle:Particle = _particles2[i];
                    particle.x = (particle.x + 2) % 465;
                    particle.y = (particle.y + 2) % 465;
                    particle.rotation++;
                    
                    matrix.identity();
                    matrix.translate( -16, -16);
                    matrix.scale(0.5, 0.5);
                    matrix.rotate(particle.rotation * DEG_TO_RAD);
                    matrix.translate(particle.x, particle.y);
                    
                    _screen2.draw(_bmd, matrix, null, null, null, true);
                }
                _screen2.unlock();
            }
        }
    }
}

class Particle {
    public var x:Number;
    public var y:Number;
    public var rotation:Number;
}