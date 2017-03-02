package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        
        private var _ball:Ball;
        private var _camera:Camera;
        private var _balls:Vector.<Ball> = new Vector.<Ball>();
        
        private const CENTER:Point = new Point(220,220);
        public function FlashTest() {
            
            _camera = new Camera();
            _camera.zoom = 1;
            _camera.fl= 400;
            _camera.x= 0;
            _camera.y= 400;
            _camera.z= -300;
            _camera.rotateX= -30;
            
            const wlength:uint = 10;
            const hlength:uint = 10;
            const intervalX:uint = 100;
            const intervalY:uint = 100;
            for( var i:int = 0; i< wlength; ++i ) {
                for( var j:int = 0; j< hlength; ++j ) {
                    var ball:Ball = new Ball( ( i - wlength*0.5 ) * intervalX,  ( j - hlength*0.5 ) * intervalY, 0, 5, 0xCCCCCCCC );
                    _balls.push( ball );
                    addCastChild( ball );
                }
            }
            
            _ball= new Ball( 0, 0, 0, 3, 0xFF000066 );
            addCastChild( _ball );
            
            addEventListener( Event.ENTER_FRAME, update );
        }
        public function addCastChild( cast:DisplayCast ):void{
            addChild( cast.view );
        }
        private function update(e:Event):void {
            //_camera.x += ( (mouseX - CENTER.x) - _camera.x ) * 0.1;
            //_camera.y += ( (mouseY - CENTER.y) - _camera.y ) * 0.1;
            //_camera.rotateX += 1;
            //_camera.rotateY += 1;
            _camera.rotateX +=  (( 60 * (mouseY - CENTER.y) / 435 -90 ) - _camera.rotateX  )* 0.01 ;
            _camera.rotateZ +=  (( -60 * (mouseX - CENTER.x) / 435 ) - _camera.rotateZ ) * 0.1;
            
            renderCast( _ball );
            
            for each( var ball:Ball in _balls ) {
                renderCast( ball );
            }
        }
        private function renderCast( cast:DisplayCast ):void {
            var radX:Number = Math.PI*_camera.rotateX/180;
            var radY:Number = Math.PI*_camera.rotateY/180;
            var radZ:Number = Math.PI*_camera.rotateZ/180;
            
            var diffX:Number = (cast.x - _camera.x)*_camera.zoom;
            var diffY:Number = (cast.y - _camera.y)*_camera.zoom;
            var diffZ:Number = (cast.z - _camera.z)*_camera.zoom;
            
            var rotZdiffX:Number = diffX*Math.cos(radZ) - diffY*Math.sin(radZ);
            var rotZdiffY:Number = diffX*Math.sin(radZ) + diffY*Math.cos(radZ);
            
            diffX= rotZdiffX;
            diffY= rotZdiffY;
            
            var rotXdiffY:Number = diffY*Math.cos(radX) - diffZ*Math.sin(radX);
            var rotXdiffZ:Number = diffY*Math.sin(radX) + diffZ*Math.cos(radX);
            
            diffY= rotXdiffY;
            diffZ= rotXdiffZ;
            
            var rotYdiffZ:Number = diffZ*Math.cos(radY) - diffX*Math.sin(radY);
            var rotYdiffX:Number = diffZ*Math.sin(radY) + diffX*Math.cos(radY);
            
            diffZ= rotYdiffZ;
            diffX= rotYdiffX;
            
            var persepective :Number =_camera.fl / (_camera.fl + diffZ);
            cast.view.x = diffX * persepective + CENTER.x;
            cast.view.y = diffY * persepective + CENTER.y;
            
            cast.view.scaleX = cast.view.scaleY = persepective*_camera.zoom;
        }
    }
}



import flash.display.*;
internal class Cast {
    public var x:Number = 0;
    public var y:Number = 0;
    public var z:Number = 0;
    public var rotateX:Number = 0;
    public var rotateY:Number = 0;
    public var rotateZ:Number = 0;
    public function Cast( x:Number = 0, y:Number =0, z:Number =0 ){
        this.x = x;
        this.y = y;
        this.z = z;    
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
    public function BallView( r:Number = 10.0, color:uint = 0xFFcc0000 ) {
        super();
        graphics.beginFill( color & 0xFFFFFF, color >> 24 & 0xFF );
        graphics.drawCircle( 0, 0, r );
        graphics.endFill();
    }
}

internal class Ball extends DisplayCast {
    public function Ball( x:Number = 0, y:Number =0, z:Number =0, r:Number = 10.0, color:uint = 0xFFcc0000 ) {
        super( new BallView( r, color ), x, y, z );
    }
}

