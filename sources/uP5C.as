package  
{
    import flash.display.*;
    import flash.filters.*;
    import flash.geom.*;
    import sandy.core.data.*;
    import sandy.core.scenegraph.*;
    import sandy.core.*;
    import sandy.extrusion.data.*;
    import sandy.extrusion.*;
    import sandy.materials.*;
    import sandy.materials.attributes.*;
    import sandy.primitive.*;
    import sandy.*;

    [SWF(width="465", height="465", backgroundColor="#000000", frameRate="20")]
    public class FlashTest extends Sprite
    {
        private var red:BitmapMaterial;
        private var scene:Scene3D;
        private var stuff:TransformGroup;

        public function FlashTest () {
            scene = new Scene3D ("scene", this, new Camera3D (465, 465), new Group ("root"));
            scene.camera.z = -1000; stuff = new TransformGroup ("stuff"); scene.root.addChild (stuff);

            // get the logo
            var logo:Bitmap = Logo.GetBitmap (); logo.y = 465 - 19; addChild (logo);

            // make materials
            red = new BitmapMaterial (makeSeamlessTextureFromLogo (logo),
                new MaterialAttributes (new VertexNormalAttributes (50, 5, 0x007F00)));

            var ph:PhongAttributes = new PhongAttributes (true);
            ph.specular = 2; ph.gloss = 5; ph.onlySpecular = true;
            var yel:ColorMaterial = new ColorMaterial (0xFFFFAF, 1,
                new MaterialAttributes (ph)); yel.lightingEnable = true;

            // glowing sphere
            var radius:Number = 100;
            var sphere:Sphere = new Sphere ("sphere", radius);
            sphere.appearance = new Appearance (yel);
            sphere.container.filters = [ new GlowFilter (0xFFFFAF, 1, 160, 160, 1) ];
            stuff.addChild (sphere);

            // make... emm... things
            var profile:Polygon2D = new Polygon2D (
                [new Point (-10, -5), new Point (+10, -5), new Point (0, +10)]);
            for (var i:int = 0; i < 6; i++) {
                var thing:Curve3D = new Curve3D;
                var up:Point3D = new Point3D (0, 1, 0);
                var t:Point3D = new Point3D (r(), r(), r());
                var len:Number = 0.5 * (1 + Math.random ());
                for (var j:int = 0; j < 4; j++) {

                    // randomize direction
                    var k:Number = 0.1 * (1.5 * j + 1);
                    t.x += k * r(); t.y += k * r(); t.z += k * r(); t.normalize ();
                    thing.t.push (t.clone ());

                    // progressive position
                    var v:Point3D = t.clone (); v.scale (radius * (0.9 + len * j));
                    thing.v.push (v);

                    // select any normal vector
                    var n:Point3D = up.cross (t); n.normalize ();
                    thing.n.push (n);

                    // scale
                    thing.s.push (3 - j);
                }

                var ext:Extrusion = new Extrusion ("thing" + i, profile, thing.toSections (), false, false);
                ext.appearance = new Appearance (red); stuff.addChild (ext);
            }

            // spin it
            addEventListener ("enterFrame", loop);
        }

        private var tw:Number = 1, th:Number = 3, tu:Number = 0, tv:Number = 0;

        private function loop (e:*):void {
            tv -= 0.05; if (tv < -1) tv += 1;
            red.setTiling (tw, th, tu, tv);

            stuff.rotateY += 2; scene.render();
        }

        private function makeSeamlessTextureFromLogo (logo:Bitmap):BitmapData {
            var pattern:BitmapData = new BitmapData (22, 19 * 2 - 1, false, 0);
            pattern.draw (logo.bitmapData, new Matrix (+1, 0, 0, +1, -100));
            pattern.draw (logo.bitmapData, new Matrix (-1, 0, 0, -1, +363.5, 19 * 2 - 1));
            return pattern;
        }

        private function r ():Number {
            var v:Number = 0; while (v == 0) v = Math.random () - Math.random (); return v;
        }
    }
}