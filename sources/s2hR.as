// forked from nutsu's Draw worm by mouse gesture.
// forked from nutsu's Worm matrix based.
/**
LOVE MATRIX.
a study for drawing curl curve.
license under the GNU Lesser General Public License.
*/
package
{
    import flash.display.Sprite;
    
    [SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "0")]
    
    public class Main extends Sprite
    {
        
        private var _canvas:WormMatrix;
        
        public function Main()
        {
            _canvas = new WormMatrix();
            addChild(_canvas);
        }
    }
}

//package {
    import frocessing.display.F5MovieClip2DBmp;
    import frocessing.geom.FMatrix2D;
    import frocessing.color.ColorHSV;
    import flash.geom.ColorTransform;
    
    internal class WormMatrix extends F5MovieClip2DBmp{
        
        private var vms:Array;
        private var MAX_NUM:int = 150; 
        private var N:Number = 120;
        private var px:Number;
        private var py:Number;
        //private var col:uint;
        private var ct:ColorTransform = new ColorTransform(.995, .995, .995);
        private var t:Number = 0;
        
        public function WormMatrix () {
            //col = c
            super( false, 0 );
            vms = [];
        }
        
        public function check():void
        {
            var x0:Number = mouseX;
            var y0:Number = mouseY;
            var vx:Number = x0 - px;
            var vy:Number = y0 - py;
            var len:Number = min( mag( vx, vy ), 50 );
            
            if( len<10 ) return;
            
            var mtx:FMatrix2D = new FMatrix2D();
            mtx.rotate( atan2( vy, vx ) );
            mtx.translate( x0, y0 );
            
            createObj( mtx, len );
            
            px = x0;
            py = y0;
        }
        
        public function createObj( mtx:FMatrix2D, len:Number ):void
        {
            var angle:Number = random(PI/180, PI/2);
            if( Math.random() > 0.5 ) angle *= -1;
            var tmt:FMatrix2D = new FMatrix2D();
            tmt.scale( 0.95, 0.95 );
            tmt.rotate( angle );
            tmt.translate( len, 0 );
            var w:Number = 0.5;
               
            var obj:WormObject = new WormObject();
            obj.c1x = obj.p1x = -w * mtx.c + mtx.tx;
            obj.c1y = obj.p1y = -w * mtx.d + mtx.ty;
            obj.c2x = obj.p2x =  w * mtx.c + mtx.tx;
            obj.c2y = obj.p2y =  w * mtx.d + mtx.ty;
            obj.vmt = mtx;
            obj.tmt = tmt;
            obj.r = angle;
            obj.w = len * .1;
            obj.count = 0;
                
            vms.push( obj );
            if( vms.length > MAX_NUM )
                vms.shift();
        }
        
        public function setup():void
        {
            size( 465, 465 );
            background(0);
            noStroke();
            px = mouseX;
            py = mouseY;
        }
        
        public function draw():void
        {
            if( isMousePressed )
            {
                background(0);
                vms = [];
            }
            
            stroke(0xFFFFFF, .4);
            
            var len:int = vms.length;
            for( var i:int=0; i<len; i++ )
            {
                var o:WormObject = vms[i];
                if( o.count<N ){
                    drawWorm( o );
                    o.count++;
                }else{
                    len--;
                    vms.splice( i, 1 );
                    i--;
                }
            }
            
            check();
            
            bitmapData.colorTransform( bitmapData.rect, ct );
        }
        
        public function drawWorm( obj:WormObject ):void
        {
            
            var color:ColorHSV = new ColorHSV(t, 0.6, 1, 0.1);
            t += 0.1;
            
            if( Math.random()>0.9 ){
                obj.tmt.rotate( -obj.r*2 );
                obj.r *= -1;
            }
            obj.vmt.prepend( obj.tmt );
            var cc1x:Number = -obj.w*obj.vmt.c + obj.vmt.tx;
            var cc1y:Number = -obj.w*obj.vmt.d + obj.vmt.ty;
            var pp1x:Number = (obj.c1x+cc1x)/2;
            var pp1y:Number = (obj.c1y+cc1y)/2;
            var cc2x:Number = obj.w*obj.vmt.c + obj.vmt.tx;
            var cc2y:Number = obj.w*obj.vmt.d + obj.vmt.ty;
            var pp2x:Number = (obj.c2x+cc2x)/2;
            var pp2y:Number = (obj.c2y+cc2y)/2;
            beginFill( uint(color), .7 );
            moveTo( obj.p1x, obj.p1y );
            curveTo( obj.c1x, obj.c1y, pp1x, pp1y );
            lineTo( pp2x, pp2y );
            curveTo( obj.c2x, obj.c2y, obj.p2x, obj.p2y );
            closePath();
            endFill();
            obj.c1x = cc1x;
            obj.c1y = cc1y;
            obj.p1x = pp1x;
            obj.p1y = pp1y;
            obj.c2x = cc2x;
            obj.c2y = cc2y;
            obj.p2x = pp2x;
            obj.p2y = pp2y;
        }
    }
//}

import frocessing.geom.FMatrix2D;

internal class WormObject{
    public var c1x:Number;
    public var c1y:Number;
    public var c2x:Number;
    public var c2y:Number;
    public var p1x:Number;
    public var p1y:Number;
    public var p2x:Number;
    public var p2y:Number;
    public var w:Number;
    public var r:Number;
    public var count:int;
    public var vmt:FMatrix2D;
    public var tmt:FMatrix2D;
}
