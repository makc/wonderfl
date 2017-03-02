/*
 画面をクリックするとリセットします
*/

package {
    
    import flash.display.*;
    import flash.geom.*;
    import flash.events.*;
    
    public class Spiral extends MovieClip {
        
        var WIDTH:Number;
        var HEIGHT:Number;
        
        var MAX_LINE:Number = 75;
        var _particles:Array;
        
        var _screen:BitmapData;
        var _canvas:MovieClip;
        
        public function Spiral():void {
            init();
        }
        
        private function init():void {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            WIDTH = stage.stageWidth;
            HEIGHT = stage.stageHeight;

            _screen = new BitmapData( WIDTH, HEIGHT, false, 0x0 );
            this.addChild( new Bitmap( _screen ) ) as Bitmap;
        
            stage.addEventListener( Event.ENTER_FRAME, enterframeHandler );
            stage.addEventListener( MouseEvent.CLICK, reset );
            stage.addEventListener( Event.RESIZE, resize );
            reset();
        }
        
        private function reset( e:Event = null ):void {
            _particles = [];
            _screen.fillRect( _screen.rect, 0x0 );
            
            var i:int = MAX_LINE;
            while( i-- ) createParticle(i);
        }
        
        private function resize( e:Event = null ){
            stage.removeEventListener( Event.ENTER_FRAME, enterframeHandler );
            stage.removeEventListener( MouseEvent.CLICK, reset );
            stage.removeEventListener( Event.RESIZE, resize );
            init();
        }
        
        private function createParticle(ID):void {
            var p:Particle = new Particle();
            
            p.inertia = 0.85- ID*0.01;
            
            var colB = Math.floor( Math.random()*128 + 128 );
            var colG = Math.floor( Math.random()*( colB * 0.5 ) + colB * 0.105 );
            var colR = Math.floor( Math.random()*( colG * 0.5 ) + colG * 0.105 );
            
            var color = "0x"+ colR.toString(16) + colG.toString(16) + colB.toString(16);
            
            p.col = color;
            
            _particles.push( p );
        }
        
        private function enterframeHandler( e:Event = null ):void {
            update();            
        }
        
        private function update():void {
            
            _canvas = new MovieClip();
            
            stage.addChild( _canvas );
            
            
            var i:int = _particles.length;
            while( i -- ){
                var p:Particle = _particles[i];
                
                var sp:Sprite = new Sprite();
                _canvas.addChild( sp );
                
                sp.graphics.lineStyle( 0, p.col, 0.4 );                
                sp.graphics.moveTo( p.oldx, p.oldy );

                p.difx = p.difx*p.inertia+( stage.mouseX - p.oldx )*p.k;
                p.dify = p.dify*p.inertia+( stage.mouseY - p.oldy )*p.k;
                
                // 現在の座標から、ばねの力のだけ移動
                p.newx += p.difx;
                p.newy += p.dify;

                sp.graphics.lineTo( p.newx, p.newy );
                
                p.oldx = p.newx;
                p.oldy = p.newy;
                
            }
            
            capture();
            
            _canvas.removeChild( sp );
            stage.removeChild( _canvas );
            _canvas = null;
            
            
        }
        
        private function capture():void {
            var matrix : Matrix = new Matrix(1,0,0,1,0,0);
            var color : ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
            var rect : Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
            _screen.draw(_canvas, matrix, color, BlendMode.ADD, rect, true);
        }

    }
    
}


class Particle {
    public var oldx:Number;
    public var oldy:Number;
    
    public var newx:Number;
    public var newy:Number;
    
    public var difx:Number;
    public var dify:Number;
    
    public var inertia:Number;
    public var k:Number;
    public var col:uint;
    
    public function Particle() {
        
        this.oldx = 0;
        this.oldy = 0;
        
        this.newx = 0;
        this.newy = 0;
        
        this.difx = 0;
        this.dify = 0;
        
        this.inertia = 0;
        this.k = 0.05;
        
        this.col = 0xFFFFFF;
    }
}