// Matrix3Dを使ってみたバージョン
package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.text.*;
    [SWF(backgroundColor=0x000033, frameRate=60)]
    public class FlashTest extends Sprite {
        
        private var _camera:Camera;
        private var _renderList:Vector.<DisplayCast> = new Vector.<DisplayCast>();
        private var _particles:Vector.<Particle> = new Vector.<Particle>();
        private  var _clearList:Vector.<Particle> = new Vector.<Particle>();
        private var _report:TextField;
        public function FlashTest() {
            addChild( _report = new TextField );
            _report.defaultTextFormat = new TextFormat( "_sans", 12, 0x33FF33 );
            _report.text = "Start";
            
            _camera = new Camera();
            _camera.zoom = 0.5;
            _camera.fl= 500;
            _camera.y= -400;
            _camera.z= -450;
            _camera.rotateX= 60;
            
            const wlength:uint = 10;
            const hlength:uint = 10;
            const intervalX:uint = 100;
            const intervalY:uint = 100;
            for( var i:int = 0; i< wlength; ++i ) {
                for( var j:int = 0; j< hlength; ++j ) {
                    var ball:Ball = new Ball( ( i - wlength*0.5 ) * intervalX, 0, ( j - hlength*0.5 ) * intervalY, 5, 0xFF336633 );
                    addCastChild( ball );
                }
            }
            ball= new Ball( 0, 0, 0, 3, 0xFFFFFFFF );
            addCastChild( ball );
            addEventListener( Event.ENTER_FRAME, update );
            
            //Wonderfl.disable_capture();
            //Wonderfl.capture_delay( 10 );
        }
        public function addCastChild( cast:DisplayCast ):DisplayCast {
            addChild( cast.view );
            _renderList.push( cast );
            return cast;
        }
        public function removeCastChild( cast:DisplayCast ):DisplayCast {
            removeChild( cast.view );
            var i:int = _renderList.indexOf( cast );
            _renderList.splice(i,1);
            return cast;
        }
        
        private function emitter():void {
            for( var i:int=0; i< 6; ++i ) {
                var p:Particle = addCastChild( new Particle( Math.random()*100-50, Math.random()*100-50, 0, Math.random()*20+2, 0xFFCCFF99 ) ) as Particle;
                p.vx = Math.random()*30-15;
                p.vy = -40 * Math.random() - 20;
                p.vz = Math.random()*30-15;
                _particles.push(p);
            }
            _report.text = String(_particles.length);
        }
        private const G:Vector3D= new Vector3D( 0, 0.2, 0 );
        private const FRICTION:Number = 0.98;
        private const WIND:Vector3D= new Vector3D( -0.08, 0.01, 0.10 );
        private function calcurate():void {
            _camera.rotateX +=  (( 90 * (mouseY - CENTER.y) / 435 + 0 ) - _camera.rotateX  )* 0.05 ;
            _camera.rotateY +=  (( -60 * (mouseX - CENTER.x) / 435 ) - _camera.rotateY ) * 0.03;
            
            for each( var p :Particle in _particles ) {
                
                if( p.life <= 0 ) {
                    _clearList.push(p);
                    continue;
                }
                //次回はこの辺をVector3Dとかにする
                p.vx *=FRICTION;
                p.vy *=FRICTION;
                p.vz *=FRICTION;
                p.vx +=G.x + WIND.x +Math.random()*0.4-0.2;
                p.vy +=G.y + WIND.y +Math.random()*0.4-0.2;
                p.vz +=G.z + WIND.z +Math.random()*0.4-0.2;
                p.x  += p.vx;
                p.y  += p.vy;
                p.z  += p.vz;
                p.life--;
                p.view.alpha -=0.002;
            }
            while( (p=_clearList.shift())!=null ){
                removeCastChild( p );
                var i:int = _particles.indexOf( p );
                _particles .splice(i,1);
            }
            
        }
        private function changeWind():void {
            WIND.x += ( Math.random()-0.5 ) * 0.03;
            WIND.y += ( Math.random()-0.5 ) * 0.03;
            WIND.z += ( Math.random()-0.5 ) * 0.03;
        }
        
        private const CENTER:Point = new Point(220,220);
        private var emitterCount:int = 0;
        private var windCount:int = 0;
        private function update(e:Event):void {
            if( emitterCount++ % 3== 0) emitter();
            if( windCount++ % 50 == 0 ) changeWind();
            calcurate();
            for each( var cast:DisplayCast in _renderList ) {
                renderCast( cast );
            }
        }
        private function renderCast( cast:DisplayCast ):void {
            
            var diffX:Number = (cast.x - _camera.x)*_camera.zoom;
            var diffY:Number = (cast.y - _camera.y)*_camera.zoom;
            var diffZ:Number = (cast.z - _camera.z)*_camera.zoom;
   
            //すっきりしたとこ
            var mat:Matrix3D = new Matrix3D();
            
            // appendは行列的タスクをpush的につんでいく
            // prependは前に突っ込んでいく
            
            // 先に平行移動する
            mat.appendTranslation( diffX, diffY, diffZ );
            
            // 回転はどの順序でも結果は同じ
            mat.appendRotation( _camera.rotateZ, Vector3D.Z_AXIS );
            mat.appendRotation( _camera.rotateY, Vector3D.Y_AXIS );
            mat.appendRotation( _camera.rotateX, Vector3D.X_AXIS );
            
            var persepective :Number =_camera.fl / (_camera.fl + mat.position.z );
            cast.view.x = mat.position.x* persepective + CENTER.x;
            cast.view.y = mat.position.y* persepective + CENTER.y;
            
            cast.view.scaleX = cast.view.scaleY = Math.max( 0.0, persepective*_camera.zoom );
        }
    }
}



import flash.display.*;
import flash.filters.*;

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
    private static const blur:BlurFilter = new BlurFilter();
    public function BallView( r:Number = 10.0, color:uint = 0xFFcc0000 ) {
        super();
        graphics.beginFill( color & 0xFFFFFF, color >> 24 & 0xFF );
        graphics.drawCircle( 0, 0, r );
        graphics.endFill();
        //blendMode = BlendMode.SCREEN;
        //filters = [blur];
    }
}
internal class Ball extends DisplayCast {
    public function Ball( x:Number = 0, y:Number =0, z:Number =0, r:Number = 10.0, color:uint = 0xFFcc0000 ) {
        super( new BallView( r, color ), x, y, z );
    }
}


internal class Particle extends Ball {
    public var vx:Number = 0;
    public var vy:Number = 0;
    public var vz:Number = 0;
    public var life:int= Math.random()*100 + 100;
    
    public function Particle ( x:Number = 0, y:Number =0, z:Number =0, r:Number = 10.0, color:uint = 0xFFcc0000 ) {
        super( x, y, z, r, color );
    }
}

