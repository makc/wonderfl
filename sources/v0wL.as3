package {
    import com.actionscriptbible.Example;
    import flash.geom.*;
    import flash.display.*;
    import flash.net.*;
    public class FlashTest extends Example {
        public var x1:Number, y1:Number, z1:Number;
        public var x2:Number, y2:Number, z2:Number;
        public var x3:Number, y3:Number, z3:Number;
        public var x4:Number, y4:Number, z4:Number;
        public var r:Number;
        public function FlashTest() {
            // write as3 code here..

            // http://www.wolframalpha.com/input/?i=vertex+coordinates+and+volume+of+regular+tetrahedron
            x1 = 0; y1 = 0; z1 = Math.sqrt(2/3)-1/(2 * Math.sqrt(6));
            x2 = -1/(2 * Math.sqrt(3)); y2 = -1/2; z2 = -1/(2 * Math.sqrt(6));
            x3 = -1/(2 * Math.sqrt(3)); y3 = 1/2; z3 = -1/(2 * Math.sqrt(6));
            x4 = 1/Math.sqrt(3); y4 = 0; z4 = -1/(2 * Math.sqrt(6));
            
            // edge length, must be 1
            r = Math.sqrt ((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) + (z1-z2)*(z1-z2)) / 2;
            trace ("1 =", r * 2);
            r *= r;

            // volume, must be 1 /(6 * sqrt(2))
            var hits:uint = 0, total:uint = 1e6;
            for (var i:int = 0; i < total; i++) {
                var x:Number = -2 + 4 * Math.random ();
                var y:Number = -2 + 4 * Math.random ();
                var z:Number = -2 + 4 * Math.random ();
                if (inTetrahedron (x, y, z)) hits++;
            }
            trace (1 / (6 * Math.sqrt(2)), "~", hits * 4 * 4 * 4 / total);
            
            // ok, we're good
            // now, estimate the volume that remains between
            // balls placed in tetrahedron vertices...
            hits = 0; total *= 3;
            for (i = 0; i < total; i++) {
                var x:Number = -2 + 4 * Math.random ();
                var y:Number = -2 + 4 * Math.random ();
                var z:Number = -2 + 4 * Math.random ();
                if (inTetrahedron (x, y, z)) {
                    if ((x-x1)*(x-x1) + (y-y1)*(y-y1) + (z-z1)*(z-z1) < r) continue;
                    if ((x-x2)*(x-x2) + (y-y2)*(y-y2) + (z-z2)*(z-z2) < r) continue;
                    if ((x-x3)*(x-x3) + (y-y3)*(y-y3) + (z-z3)*(z-z3) < r) continue;
                    if ((x-x4)*(x-x4) + (y-y4)*(y-y4) + (z-z4)*(z-z4) < r) continue;
                    hits ++;
                }
            }
            
            var volume:Number = hits * 4 * 4 * 4 / total;
            var ratio:Number = volume * (6 * Math.sqrt(2));
            
            trace ("Remaining volume is", int (ratio * 100), "% of tetrahedron");
            trace ("Corresponding height increase is", 1/ratio, "times");

            var l:Loader = (addChild (new Loader) as Loader);
            l.load (new URLRequest ("http://lh3.googleusercontent.com/-5DkQShFUrd0/UQWwOElBqYI/AAAAAAAAM4U/F8BQyKJ66Bk/w497-h373/530642_498216553564364_1568614648_n.jpg"));
            l.y = 100;            
        }
        
        private var matrix:Matrix3D = new Matrix3D;
        private var v:Vector.<Number> = new Vector.<Number> (16);
        public function inTetrahedron (x:Number, y:Number, z:Number):Boolean {
            // http://steve.hollasch.net/cgindex/geometry/ptintet.html
            v [0] = x1; v [1] = y1; v [2] = z1; v [3] = 1;
            v [4] = x2; v [5] = y2; v [6] = z2; v [7] = 1;
            v [8] = x3; v [9] = y3; v[10] = z3; v[11] = 1;
            v[12] = x4; v[13] = y4; v[14] = z4; v[15] = 1;
            matrix.copyRawDataFrom(v); var D0:Number = matrix.determinant;

            v [0] = x ; v [1] = y ; v [2] = z ; v [3] = 1;
            v [4] = x2; v [5] = y2; v [6] = z2; v [7] = 1;
            v [8] = x3; v [9] = y3; v[10] = z3; v[11] = 1;
            v[12] = x4; v[13] = y4; v[14] = z4; v[15] = 1;
            matrix.copyRawDataFrom(v); var D1:Number = matrix.determinant;

            v [0] = x1; v [1] = y1; v [2] = z1; v [3] = 1;
            v [4] = x ; v [5] = y ; v [6] = z ; v [7] = 1;
            v [8] = x3; v [9] = y3; v[10] = z3; v[11] = 1;
            v[12] = x4; v[13] = y4; v[14] = z4; v[15] = 1;
            matrix.copyRawDataFrom(v); var D2:Number = matrix.determinant;

            v [0] = x1; v [1] = y1; v [2] = z1; v [3] = 1;
            v [4] = x2; v [5] = y2; v [6] = z2; v [7] = 1;
            v [8] = x ; v [9] = y ; v[10] = z ; v[11] = 1;
            v[12] = x4; v[13] = y4; v[14] = z4; v[15] = 1;
            matrix.copyRawDataFrom(v); var D3:Number = matrix.determinant;

            v [0] = x1; v [1] = y1; v [2] = z1; v [3] = 1;
            v [4] = x2; v [5] = y2; v [6] = z2; v [7] = 1;
            v [8] = x3; v [9] = y3; v[10] = z3; v[11] = 1;
            v[12] = x ; v[13] = y ; v[14] = z ; v[15] = 1;
            matrix.copyRawDataFrom(v); var D4:Number = matrix.determinant;
            
            return ((D0 * D1 > 0) && (D0 * D2 > 0) && (D0 * D3 > 0) && (D0 * D4 > 0));
        }
    }
}