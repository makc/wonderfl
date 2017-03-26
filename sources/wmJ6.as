/**
 */
package
{
    import com.adobe.utils.NumberFormatter;
    import flash.display.*;
    import flash.events.Event;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.filters.BlurFilter;
    [SWF( width="465",height="465",backgroundColor="0x808080")]
    /**
     * ...
     * @author hogemaru
     */
     
    public class cumulusSmoke extends Sprite
    {
        public static const SW:int = 465;
        public static const SH:int = 465;
        
        /**
         * グラデーションかける
         * ang ... 線形グラデの角度
         * bRadial ... 円形グラデにする
         * bAlpha ... alpha抜きだけにする
         */
        private function makeGradation( buf:BitmapData, colors:Array,alphas:Array,ratios:Array,ang:Number, bRadial:Boolean, bAlpha:Boolean ):void {
            var sh:Shape = new Shape();
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(buf.width, buf.height, ang, 0, 0);
            if ( bRadial ) {
                sh.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios,matrix);
            }else {
                sh.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios,matrix);
            }
            sh.graphics.drawRect(0, 0, buf.width, buf.height );
            sh.graphics.endFill();
            if ( bAlpha ) {
                buf.draw(sh, null, null, BlendMode.ALPHA );
            }else {
                buf.draw(sh, null, null, BlendMode.NORMAL );
            }
        }
        /**
         */
        private function makeSmokeGraphic( buf:BitmapData ):void {
            var buf2:BitmapData = new BitmapData( buf.width, buf.height, true, 0   );
            var bmp2:Bitmap = new Bitmap( buf2 );
            makeGradation( buf, [0xffffff, 0xffffff,0x4060a0,0x002020], [1,1, 1,1], [0,50,150,255], 45*Math.PI/180, false ,false );
            buf2.perlinNoise( buf2.width / 4, buf2.height / 4, 4, Math.random() * 0xffff, true, true, 0x08);
            buf.draw(bmp2, null, null, BlendMode.ALPHA);
            makeGradation( buf, [0,0,0], [1,1,0], [0,128,255], 0, true, true );
        }
        /**
         */
        private function updateElems( ar:Array):void {
            for ( var i:int = 0; i < ar.length; i++ ) {
                var elem:Elem = ar[i];
                elem.update();
                if ( elem.angx < 0 ) {
                    if ( elem.bLive ) {
                        ar.splice( i, 1 );
                        i--;
                    }
                }else {
                    elem.bLive = true;
                }
            }
        }
        /**
         */
        private function drawElems( bufOut:BitmapData, spr:BitmapData, ar:Array):void {
            var mat:Matrix = new Matrix();
            var mat2:Matrix = new Matrix();
            for ( var i:int = 0; i < ar.length; i++ ) {
                var elem:Elem = ar[i];
                mat.identity();
                mat2.identity();
                mat2.translate( -spr.width * 0.5, -spr.height * 0.5);
                mat2.rotate( elem.angz );
                mat2.scale( elem.scale, elem.scale);
                mat2.translate( elem.x, elem.y);
                bufOut.draw(spr, mat2, new ColorTransform(1,1,1,elem.alpha), BlendMode.NORMAL);
            }
        }
        /**
         */
        public function cumulusSmoke() 
        {
            var cnt:int = 0;
            var cx:Number = SW * 0.5;
            var cy:Number = SH * 0.8;
            var pow:Number = 0;
            var canvas:Bitmap = new Bitmap( new BitmapData( SW, SH ) );
            var ar:Array = new Array();
            var spr:BitmapData = new BitmapData( 100, 100, true, 0 );

            addChild(canvas);
            makeSmokeGraphic(spr);

            addEventListener(Event.ENTER_FRAME, function(e:Event ):void {
                cnt++;
                canvas.bitmapData.fillRect(canvas.bitmapData.rect, 0xff0020a0);
                if (  ( cnt & 7 ) < 6 ) {
                    for ( var i:int = 0; i < 5; i++ ){
                        ar.push( new Elem( cx, cy + 60, 0 ) );
                    }
                }
                if ( cnt > 40 ){
                    cx = ( mouseX + cx ) * 0.5;
                    cy = ( mouseY + cy ) * 0.5;
                }
                updateElems( ar );
                drawElems( canvas.bitmapData, spr, ar );
            });
        }
    }
}
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

class Elem {
    public var x:Number;
    public var y:Number;
    public var z:Number;
    public var bx:Number;
    public var by:Number;
    public var bz:Number;
    public var vx:Number;
    public var vy:Number;
    public var vz:Number;
    public var angx:Number;
    public var angy:Number;
    public var angz:Number;
    public var scale:Number;
    public var alpha:Number;
    public var rad:Number;
    public var speed:Number;
    public var bLive:Boolean;
    /**
     */
    public function update():void {
        var mat:Matrix3D = new Matrix3D();
        mat.identity();
        mat.prependRotation( angx, new Vector3D( 0, 0, 1 ) );
        mat.appendRotation( angy, new Vector3D( 0, 1, 0 ) );
        var vec:Vector3D = mat.transformVector( new Vector3D( 0, 1, 0) );
        angx += -speed;
        angz += -0.02;
        x = bx + vec.x * rad * 1.25;
        y = by + vec.y * rad;
        z = bz + vec.z * rad;

        alpha = vec.z * 0.75 + 0.25;
        scale = vec.z * 0.9 + 0.1;
        
        bx += vx;
        by += vy;
        vy *= 0.99;
    }
    /**
     */
    public function Elem(_bx:Number, _by:Number, _bz:Number) {
        bx = _bx + ( Math.random() - 0.5 ) * 10;
        by = _by;
        bz = _bz;
        rad = 60;
        angz = ( Math.random() - 0.5 ) * 0.2;
        angy = Math.random() * 100 + ( 180 - 100 ) / 2;
        angx = Math.random() * 10 + 180;
        bLive = false;
        vx = Math.random() - 0.5;
        vy = Math.random() -  8;
        speed = Math.random() * 2.0 + 2;
    }
}