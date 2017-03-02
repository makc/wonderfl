// forked from yd_niku's [1日1Wonderfl] Vector3D使ってみた
// forked from yd_niku's [1日1Wonderfl]Matrix3D使ってみた
// Matrix3Dを使ってみたバージョン
package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.text.*;
    [SWF(backgroundColor=0xFFFFDD, frameRate=60)]
    public class FlashTest extends Sprite {
        
        private var _camera:Camera;
        private var _renderList:Vector.<Cast> = new Vector.<Cast>();
        private  var _clearList:Vector.<Cast> = new Vector.<Cast>();
        private var _particles:Vector.<Particle > = new Vector.<Particle >();
        private var _report:TextField;
        
        private var _canvas:BitmapData;
        public function FlashTest() {
            addChild( _report = new TextField );
            _report.defaultTextFormat = new TextFormat( "_sans", 12, 0x33FF33 );
            _report.text = "Start";
            
            _canvas = new BitmapData( stage.stageWidth, stage.stageHeight, true, 0x00FFFFFF );
            addChild( new Bitmap(_canvas) );
            
            // Set up Camera3D Elements
            _camera = new Camera();
            _camera.zoom = 0.5;
            _camera.fl= 500;
            _camera.y= -400;
            _camera.z= -450;
            _camera.rotateX= 60;
            
            // Set up 3D Elements
            createElements();
            
            // Set up 
            addEventListener( Event.ENTER_FRAME, update );
        }
        
        private function createElements():void {
            const wlength:uint = 10;
            const hlength:uint = 10;
            const intervalX:uint = 100;
            const intervalY:uint = 100;
            for( var i:int = 0; i< wlength; ++i ) {
                for( var j:int = 0; j< hlength; ++j ) {
                    var ball:Ball = new Ball( ( i - wlength*0.5 ) * intervalX, 0, ( j - hlength*0.5 ) * intervalY, 5, 0xFFFF6633 );
                    addCastChild( ball );
                }
            }
            ball= new Ball( 0, 0, 0, 3, 0xFFFFFFFF );
            addCastChild( ball );    
        }
        public function addCastChild( cast:Cast ):Cast{
            _renderList.push( cast );
            return cast;
        }
        public function removeCastChild( cast:Cast ):Cast {
            var i:int = _renderList.indexOf( cast );
            _renderList.splice(i,1);
            return cast;
        }
        
        private function emitter():void {
            for( var i:int=0; i< 6; ++i ) {
                var p:Particle = new Particle(
                    Math.random()*100-50, 
                    Math.random()*100-50,
                    0,
                    Math.random()*20+2, 
                    0xFFCC0099
                );
                
                p.vx = Math.random()*30-15;
                p.vy = -40 * Math.random() - 20;
                p.vz = Math.random()*30-15;
                _particles.push( addCastChild( p ));
            }
            _report.text = String(_particles.length);
        }
        private const G:Vector3D= new Vector3D( 0, 0.2, 0 );
        private const FRICTION:Number = 0.98;
        private const WIND:Vector3D= new Vector3D( -0.08, 0.01, 0.10 );
        private function calcurate():void {
            _camera.rotateX +=  (( 90 * (mouseY - CENTER.y) / 435 + 0 ) - _camera.rotateX  )* 0.05 ;
            _camera.rotateY +=  (( -60 * (mouseX - CENTER.x) / 435 ) - _camera.rotateY ) * 0.03;
            
            var force:Vector3D = G.add( WIND );
            for each( var p :Particle in _particles ) {
                
                if( p.life <= 0 ) {
                    _clearList.push(p);
                    continue;
                }
                p.velocity.scaleBy( FRICTION );
                p.velocity.incrementBy( force );
                p.position.incrementBy( p.velocity );
                
                p.life--;
                //p.view.alpha -=0.002;
            }
            
            while( (p=_clearList.shift())!=null ){
                removeCastChild( p );
                var i:int = _particles.indexOf( p );
                _particles .splice(i,1);
            }
            
        }
        private function changeWind():void {
            WIND.incrementBy(
                new Vector3D( 
                    ( Math.random()-0.5 ) * 0.03,
                    ( Math.random()-0.5 ) * 0.03,
                    ( Math.random()-0.5 ) * 0.03
                )
            );
        }
        
        private const CENTER:Vector3D= new Vector3D(220,220);
        private var emitterCount:int = 0;
        private var windCount:int = 0;
        private function update(e:Event):void {
            if( emitterCount++ % 3== 0) emitter();
            if( windCount++ % 50 == 0 ) changeWind();
            calcurate();
            
            _canvas.fillRect( _canvas.rect, 0xFFFFFF );
            _canvas.lock();
            for each( var cast:Cast in _renderList ) {

                var diff:Vector3D = cast.position.subtract( _camera.position );
                diff.scaleBy( _camera.zoom );
   
                var mat:Matrix3D = new Matrix3D();
                
                // この辺ってVector3DとMatrix3Dでスマートにできないのかなー？？
                mat.appendTranslation( diff.x, diff.y, diff.z );
                mat.appendRotation( _camera.rotateZ, Vector3D.Z_AXIS );
                mat.appendRotation( _camera.rotateY, Vector3D.Y_AXIS );
                mat.appendRotation( _camera.rotateX, Vector3D.X_AXIS );
            
                var persepective :Number =_camera.fl / (_camera.fl + mat.position.z );
                var screenX:Number = mat.position.x* persepective + CENTER.x;
                var screenY:Number = mat.position.y* persepective + CENTER.y;
                var scale:Number = Math.max( 0.0, persepective*_camera.zoom );
            
                var view:BitmapData= Object( cast ).view;
                // CopyPixelにする
                _canvas.draw( view, new Matrix( scale, 0, 0, scale, screenX, screenY ) );
            }
            _canvas.unlock();
        }
    }
}



import flash.display.*;
import flash.geom.*;
import flash.filters.*;

internal class Cast {
    public var position:Vector3D = new Vector3D();
    public var rotate:Vector3D = new Vector3D();
    public function Cast( x:Number = 0, y:Number =0, z:Number =0 ){
        position.x = x;
        position.y = y;
        position.z = z;    
    }
    public function set x( value:Number ):void{
        position.x = value;
    }
    public function get x():Number {
        return position.x;
    }
    public function set y( value:Number ):void{
        position.y = value;
    }
    public function get y():Number {
        return position.y;
    }
    public function set z( value:Number ):void{
        position.z = value;
    }
    public function get z():Number {
        return position.z;
    }
    public function set rotateX( value:Number ):void{
        rotate.x = value;
    }
    public function get rotateX():Number {
        return rotate.x;
    }
    public function set rotateY( value:Number ):void{
        rotate.y = value;
    }
    public function get rotateY():Number {
        return rotate.y;
    }
    public function set rotateZ( value:Number ):void{
        rotate.z = value;
    }
    public function get rotateZ():Number {
        return rotate.z;
    }
}

internal class DisplayCast extends Cast {
    public var view:DisplayObject;
    public function DisplayCast( view:DisplayObject, x:Number = 0, y:Number =0, z:Number =0 ) {
        super( x, y, z );
        this.view =  view;
    }
}
internal class Camera extends Cast {
    public var fl:Number = 500;
    public var zoom:Number = 1.0;
    public function Camera( x:Number = 0, y:Number =0, z:Number =-300 ) {
        super( x, y, z );
    }
}

internal class BallView extends Sprite {
    private static const blur:BlurFilter = new BlurFilter();
    public function BallView( r:Number = 10.0, color:uint = 0xFFcc0000 ) {
        super();
        graphics.beginFill( color & 0xFFFFFF, color >> 24 & 0xFF );
        graphics.drawCircle( 0, 0, r );
        graphics.endFill();
    }
}


internal class Particle extends Cast {
    public var velocity:Vector3D = new Vector3D();
    public var life:int= Math.random()*100 + 100;
    public var color:uint = 0;
    public var radius:int = 0;
    
    //public var view:Sprite;
    
    private static const PRERENDER:Vector.<BitmapData> = new Vector.<BitmapData>();
    {
        initialize();
    }
    
    private static function initialize():void {
        
        var origin:Sprite = new BallView( 5, 0xFFff0000 );
        for( var i:int=1; i< 50; ++i ) {
            var bmpd:BitmapData = new BitmapData( 10, 10, true, 0x00 );
            bmpd.draw( origin, new Matrix( i*0.1, 0, 0, i*0.2, 5, 5 )  );
            PRERENDER.push( bmpd );
        }
    }
    
    public function Particle ( x:Number = 0, y:Number =0, z:Number =0, r:int= 10, c:uint = 0xFFcc0000 ) {
        super( x, y, z );
        radius = r;
        color = c;
    }
    public function get view():BitmapData {
        
        return PRERENDER[ Math.min( radius, PRERENDER.length-1 )];
    }
    public function set vx( value:Number ):void {
        velocity.x = value;
    }
    public function get vx():Number {
        return velocity.x;
    }
    public function set vy( value:Number ):void {
        velocity.y = value;
    }
    public function get vy():Number {
        return velocity.y;
    }
    public function set vz( value:Number ):void {
        velocity.z = value;
    }
    public function get vz():Number {
        return velocity.z;
    }
}

internal class Ball extends Particle {
    //public var view:Sprite;
    public function Ball( x:Number = 0, y:Number =0, z:Number =0, r:Number = 10.0, color:uint = 0xFFcc0000 ) {
        super( x, y, z,  r, color  );
    }
}
