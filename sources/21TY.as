// forked from makc3d's flash on 2013-1-28
package {
    import com.actionscriptbible.Example;
    import flash.geom.*;
    import flash.display.*;
    import flash.net.*;
    public class FlashTest extends Example {
        public function FlashTest() {
            // write as3 code here..
            
            // http://en.wikipedia.org/wiki/Platonic_solid#Angles
            var solidAngle:Number = Math.acos (23 / 27);
            
            var volume:Number = 1 / (6 * Math.sqrt(2)) - 4 * solidAngle * (0.5 * 0.5 * 0.5) / 3;
            var ratio:Number = volume * (6 * Math.sqrt(2));
            
            trace ("Remaining volume is", int (ratio * 100), "% of tetrahedron");
            trace ("Corresponding height increase is", 1/ratio, "times");

            var l:Loader = (addChild (new Loader) as Loader);
            l.load (new URLRequest ("http://lh3.googleusercontent.com/-5DkQShFUrd0/UQWwOElBqYI/AAAAAAAAM4U/F8BQyKJ66Bk/w497-h373/530642_498216553564364_1568614648_n.jpg"));
            l.y = 100;            
        }
    }
}