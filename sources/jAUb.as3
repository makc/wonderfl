// forked from checkmate's adobe challenge 1
/**
 * 
 * "Use Flash Player 10 drawing API,
 *  specifically drawTriangles.
 *  My favorite part of the new capabilities
 *  is the ability to specify
 *  UVT texture mapping data."
 *                     by Justin Everett-Church
 *  
 * This code is a example of drawTriangle.
 */
package {
    
    //Kaleidoscope:
    //Web camera is required.
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Matrix;
    import flash.media.Camera;
    import flash.media.Video;
    import flash.text.TextField;
    import flash.net.FileReference;
    import flash.net.FileFilter;
    
    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="60")]
    public class drawTriangleTest extends Sprite{
    
        private var bmpd     :BitmapData;
        
        private var verD     :Vector.<Number>;
        private var indD     :Vector.<int>;
        private var uvtD     :Vector.<Number>;
        private var uvID     :Vector.<int>;
        private var uvVal    :Vector.<Number>;

        private var _display :DisplayObject;
        private var ptnShape :Shape;
        private var ptn      :BitmapData;
        
        private var camera   :Camera;
        private var video    :Video;
        
        private var mtx:Matrix;
        private var mtxt:Matrix;
        private var mtx0:Matrix;
        
        private var psize    :Number = 100;
        private var hx       :Number = 465 / 2;
        private var hy       :Number = 465 / 2;
        private var tx       :Number = hx;
        private var ty       :Number = hy;
        private var a        :Number = 0;
        
        private var fileReference:FileReference;
        private var loader:Loader;
        
        public function drawTriangleTest() {
            
            initTriangles();
            
            //texture src triangle
            bmpd = new BitmapData( 320, 240 );
            ptn  = new BitmapData( 3 * psize, 2 * psize * Math.sin(Math.PI / 3 ) );
            ptnShape = new Shape();
            mtx  = new Matrix();
            mtx0 = new Matrix();
            mtxt = new Matrix( 1, 0, 0, 1, psize / 2 );
            
            camera = Camera.getCamera();
            if ( camera == null ) {
                setAltImage();
            }else {
                camera.setMode(320, 240, 15);
                video = new Video(320, 240);
                video.attachCamera(camera);
                _display = video;
                camera.addEventListener(ActivityEvent.ACTIVITY, cameraStart);
            }
        }
        
        private function cameraStart(e:ActivityEvent):void {
            camera.removeEventListener( ActivityEvent.ACTIVITY, cameraStart );
            addEventListener( Event.ENTER_FRAME, handleEnterFrame );
        }
        
        private function handleEnterFrame(e:Event):void {            
            bmpd.draw( _display, mtx0 );
            
            tx += ( mouseX - tx ) * 0.2;
            ty += ( mouseY - ty ) * 0.2;
            
            var ra:Number = 2 * Math.PI * (hx - tx) / 465;
            var nv:Number = 0.5 - 0.4 * Math.min( 1, Math.abs(ty/465) );
            
            var i:int;
            for ( i = 0; i < 3; i++ ) {
                var aa:Number = ra + i * 2 * Math.PI / 3;
                uvVal[i*2]   = ( 0.5 + nv * Math.cos( aa ) );
                uvVal[i*2+1] = ( 0.5 + nv * Math.sin( aa ) );
            }
            var len:int = uvID.length;
            for ( i = 0; i < len; i++ ) {
                uvtD[i] = uvVal[ uvID[i] ];
            }
            
            ptnShape.graphics.clear();
            ptnShape.graphics.beginBitmapFill( bmpd );
            ptnShape.graphics.drawTriangles( verD, indD, uvtD );
            ptnShape.graphics.endFill();
            ptn.draw( ptnShape, mtxt );
            
            mtx.identity();
            mtx.scale( nv / 0.5, nv / 0.5 );
            mtx.rotate( a );
            mtx.translate( hx, hy );
            graphics.clear();
            graphics.beginBitmapFill( ptn, mtx, true );
            graphics.drawRect( 0, 0, 465, 465 );
            graphics.endFill();
            a += 0.005;
        }
        
        private function initTriangles():void {
            var xx:Number = psize;
            var yy:Number = psize * Math.sin(Math.PI / 3 );;
            
            uvVal = Vector.<Number>( [0,0,1,0,1,1] );
            verD  = new Vector.<Number>();
            uvID  = new Vector.<int>();
            
            verD.push( xx, yy );
            uvID.push( 0, 1 );//0
            var uf:Boolean = true;
            for ( var i:int = 0; i < 6; i++ ) {
                var vx:Number = psize * Math.cos( i * Math.PI / 3 );
                var vy:Number = psize * Math.sin( i * Math.PI / 3 );
                verD.push( xx + vx, yy + vy );
                if( uf=!uf )
                    uvID.push( 2, 3 ); //1
                else
                    uvID.push( 4, 5 ); //2
            }
            
            var ex:Number = psize * Math.cos( Math.PI / 3 );
            verD.push( 3 * xx,  yy );
            uvID.push( 2, 3 );//1
            verD.push( 2 * xx + ex,  2 * yy );
            uvID.push( 0, 1 );//0
            verD.push( - ex,  2 * yy );
            uvID.push( 0, 1 );//0
            verD.push( - xx,  yy );
            uvID.push( 4, 5 );//2
            verD.push( - ex,  0 );
            uvID.push( 0, 1 );//0
            verD.push( 2 * xx + ex,  0 );
            uvID.push( 0, 1 );//0
            
            uvtD = new Vector.<Number>( uvID.length );
            
            indD = Vector.<int>([
                    0, 1, 2,
                    0, 2, 3,
                    0, 3, 4,
                    0, 4, 5,
                    0, 5, 6,
                    0, 6, 1,
                    1, 7, 8,
                    1, 8, 2,
                    3, 9, 4,
                    4, 9, 10,
                    4, 10, 11,
                    4, 11, 5,
                    6, 12, 1,
                    1, 12, 7 ]);
        }
        
        private function setAltImage():void {
            var tf:TextField = new TextField();
            tf.autoSize = "left";
            tf.x = 20;
            tf.y = 20;
            tf.text = "WebCamera is required.\nClick stage to select alternative image.";
            tf.selectable = false;
            tf.textColor = 0xffffff;
            addChild( tf );
            //
            fileReference = new FileReference();
            fileReference.addEventListener( Event.SELECT, select );
            fileReference.addEventListener( Event.COMPLETE, complete );
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener( Event.INIT, imageInit );
            //
            stage.addEventListener( MouseEvent.CLICK, ffstart );
        }
        
        private function ffstart( e:MouseEvent ):void {
            var fileFilter:FileFilter = new FileFilter("Images", "*.jpg;*.gif;*.png");
            fileReference.browse([fileFilter]);
        }
        
        private function select( e:Event ):void {
            fileReference.load();
        }
        
        private function complete(e:Event):void {
            loader.loadBytes( fileReference.data );
        }
        
        private function imageInit(e:Event):void {
            removeChildAt( 0 );
            _display = Bitmap( loader.content );
            mtx0 = new Matrix( 320 / _display.width, 0, 0, 240 / _display.height );
            loader.removeEventListener( Event.INIT, imageInit );
            stage.removeEventListener( MouseEvent.CLICK, ffstart );
            fileReference.removeEventListener( Event.SELECT, select );
            fileReference.removeEventListener( Event.COMPLETE, complete );
            addEventListener( Event.ENTER_FRAME, handleEnterFrame );
        }
    }
}


