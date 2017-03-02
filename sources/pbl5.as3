package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.utils.*;
    import flash.system.*;
    import com.flashdynamix.utils.*;

    [SWF(backgroundColor=0x000000, frameRate=60)]
    public class Sponsor extends Sprite {
     
        private var _particles:Vector.<Object>;
        private var _gradientMap:BitmapData; 
        private var _timer:Timer; 
   
        private const PARTICLES_LENGTH:int = 1000;

        private function setup():void{
            _gradientMap= new BitmapData(200,10, true, 0);
            // addChild( new Bitmap( _gradientMap) ); // for debug
            updateGradientFill();
                
            shotFirework();
           
            _timer = new Timer( 5000, 0 );
            _timer.addEventListener( TimerEvent.TIMER, timerHadler );
            _timer.start();
            
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoadComplete );
            _loader.load( new URLRequest("http://level0.kayac.com/space.jpg"), new LoaderContext(true) );
        }
        private var _loader:Loader;
        private function onLoadComplete(e:Event):void {
            addChildAt( _loader.content, 0 ); 
        }
        
        private function shotFirework():void {
            _particles = new Vector.<Object>();
            var radius:Number = Math.random()* 5 + 2;
            var radian:Number = Math.PI*2;
            for( var i :int=0; i<PARTICLES_LENGTH; i++ ) {
                var direction:Number = Math.random()*radian;
                var tx:Number = Math.sin(direction);
                var ty:Number = Math.cos(direction);
                
                var sl:Number = Math.random()* radius +2;
                var vl:Number = Math.random()* radius;
                
                const offsetX:int = 0, offsetY:int = - 45;
                
                var particle :Object= {
                    x: _center.x + tx*sl + offsetX,
                    y: _center.y + ty*sl + offsetY,
                    vx: tx*vl,
                    vy: ty*vl,
                    life: Math.random()* 30 + 170
                };
                _particles.push(particle);
            }
        }
        
        private const FRICTION:Number = 0.96;
        private const GRAVITY:Number = 0.006;
        private const WIND:Point = new Point(0.001,0 );
        
        private function updateCalcuration():void{
            for each( var p:Object in _particles ) {
                p.vx =  p.vx * FRICTION + WIND.x + Math.random()*0.01-.005;
                p.vy =  p.vy * FRICTION + WIND.y + GRAVITY + Math.random()*0.01-.005;
                p.x = p.x + p.vx;
                p.y = p.y + p.vy;
                p.life--;
            }
        }
        
        private function updateDrawing():void{
            _canvas.colorTransform( _canvas.rect, CTF );
            _canvas.lock();
            for each( var p:Object in _particles ) {
                if( p.life <= 0 ) continue;
                _canvas.setPixel32( p.x, p.y, getColor(p.life) );
            }
            _canvas.unlock();
        }
         
        private function timerHadler (e:Event):void{
           updateGradientFill();
            _particles = null;
            shotFirework();
        }
         
        private function getColor(position:int):uint {
            return _gradientMap.getPixel( position, 0 ) | 0xFF000000;
        }
        
        private const CTF:ColorTransform = new ColorTransform( 0.94, 0.94, 0.94, 0.9 );
        private const COLORS:Array = [ 0xFFCCFF, 0xFF9999, 0xFFFF99, 0x99CCFF, 0xCCFF99 ];
        private function updateGradientFill():void {
            var sp:Shape= new Shape();
            var color:uint = COLORS[ Math.random()*COLORS.length>>0];
            var mtx:Matrix = new Matrix();
            mtx.createGradientBox(200, 0, 0, 0, 0);
            sp.graphics.beginGradientFill( GradientType.LINEAR,
                [ 0x333333, color, color, color*0.9>>0, 0x000000 ],
                [ 1, 1, 1, 1, 1 ],
                [ 8, 64, 102, 204, 255],
                mtx,
                InterpolationMethod.RGB
            );
            sp.graphics.drawRect( 0, 0, 200, 10 );
            sp.graphics.endFill();
            _gradientMap.draw(sp);
            sp = null;    
        }
        
        
        
        private var _canvas:BitmapData;
        private var _center:Point;
        private function init():void{
            _center= new Point();
            _center.x = stage.stageWidth*0.5>>0;
            _center.y = stage.stageHeight*0.5>>0;
            
            _canvas  = new BitmapData( stage.stageWidth, stage.stageHeight, true, 0 );
            addChild( new Bitmap(_canvas) );
            
            setup();
            addEventListener( Event.ENTER_FRAME, enterFrame);
            
            SWFProfiler.init( this );
        }
        private function enterFrame( e:Event ):void {
            updateCalcuration();
            updateDrawing();
        }
        
        
        
        
        public function Sponsor() {
            addEventListener( Event.ADDED_TO_STAGE, addToStage );
        }
        private function addToStage (e:Event):void {
            init();
        }
    }
}
    