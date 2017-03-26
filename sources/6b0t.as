// forked from makc3d's Metaballs 3D

///Change the pattern and get beautiful results//
//Thanks makc3d and a great job

package {
    import flash.system.Security;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    import flash.utils.getTimer;
    [SWF(width=465,height=465)]
    /**
     * Ok, looks like I don't have right idea to improve this,
     * so maybe someone of you, oh wonderfl people, will..?
     * 
     * P.S. click anywhere for next track.
     */
    public class MetaBalls3D extends Sprite {
        private var texture:BitmapData;
        private var sphere:BauerSphere;
        private var metaballs:MetaBalls;
        private var canvas:Shape;
        private var waves:Wave2;
        private var player:BeatPortPlayer;

        public function MetaBalls3D () {
            Security.allowDomain("http://www.doorknobdesign.com");
            BeatPortPlayer (player = new BeatPortPlayer).play (18);

            waves = new Wave2;
            waves.w1 = new Wave;
            waves.w2 = new Wave;

            graphics.beginFill (0);
            graphics.drawRect (0, 0, 465, 465);

            addChild (canvas = new Shape);
            canvas.x = 465 / 2;
            canvas.y = 465 / 2;

            texture = new BitmapData (67, 68, false, 0);
            var loader:Loader = new Loader;
            loader.contentLoaderInfo.addEventListener (Event.COMPLETE, gotImage);
            loader.load (
                new URLRequest ("http://www.doorknobdesign.com/wfl/pattern.png"),
                new LoaderContext (true)
            );

            sphere = new BauerSphere;
            sphere.debug = false;
            sphere.build (2000);

            metaballs = new MetaBalls;
            metaballs.a = 0;

            addEventListener (Event.ENTER_FRAME, draw);

            stage.addEventListener (MouseEvent.CLICK, nextTrack);
        }

        private function nextTrack (e:MouseEvent):void {
            player.next ();
        }

        private function gotImage (e:Event):void {
            texture.draw (LoaderInfo (e.target).content);
        }

        private var m:Matrix4 = new Matrix4;
        private var s:Number = 0;
        private var ba:ByteArray = new ByteArray;
        private function draw (e:Event):void {
            // animate waves
            waves.w1.P = 5e-3 * getTimer ();
            waves.w2.P = waves.w1.P;

            // update wave amplitudes based on sound
            var aLt:Number = 0, aLt2:Number = 0;
            var aRt:Number = 0, aRt2:Number = 0;
            if (!SoundMixer.areSoundsInaccessible ()) {
                var i:int;
                SoundMixer.computeSpectrum (ba, true);

                // left
                ba.position = 0;
                for (i = 0; i < 64; i++) {
                    aLt += ba.readFloat ();
                }
                for (i = 64; i < 128; i++) {
                    aLt2 += ba.readFloat ();
                }
                aLt /= 100;
                aLt2 /= 100;

                // right
                ba.position = 4 * 256;
                for (i = 0; i < 64; i++) {
                    aRt += ba.readFloat ();
                }
                for (i = 64; i < 128; i++) {
                    aRt2 += ba.readFloat ();
                }
                aRt /= 100;
                aRt2 /= 100;

                waves.w1.A = maxOrMix (waves.w1.A, 0.1 * aLt); waves.w1.A2 = maxOrMix (waves.w1.A2, 10 * aLt2);
                waves.w2.A = maxOrMix (waves.w2.A, 0.1 * aRt); waves.w2.A2 = maxOrMix (waves.w2.A2, 10 * aRt2);
            }

            // swing balls
         //   metaballs.a = 1 + Math.sin (2.1e-3 * getTimer ());

            // rotate scene
          //  m.rotate (3.3e-4 * getTimer ());

            var ranges:Vector.<Range> = metaballs.ranges ();
            if (ranges.length > 1) {
                // render sphere twice
                if (m.Zz < 0) {
                    morphSphere (ranges [0], waves.w1);

                    sphere.transformVertices (m);
                    sphere.render (canvas.graphics, texture);

                    morphSphere (ranges [1], waves.w2);

                    sphere.transformVertices (m);
                    sphere.render (canvas.graphics, texture, false);
                } else {
                    morphSphere (ranges [1], waves.w2);

                    sphere.transformVertices (m);
                    sphere.render (canvas.graphics, texture);

                    morphSphere (ranges [0], waves.w1);

                    sphere.transformVertices (m);
                    sphere.render (canvas.graphics, texture, false);
                }
            } else {
                // render sphere once
                morphSphere (ranges [0], waves);

                sphere.transformVertices (m);
                sphere.render (canvas.graphics, texture);
            }
        }

        private function maxOrMix (a0:Number, a1:Number):Number {
            if (a0 < a1) return a1;
            return 0.9 * a0 + 0.1 * a1;
        }

        private var p:Point = new Point, q:Vector3D = new Vector3D;
        private function morphSphere (range:Range, wave:Wave):void {

            var aa:Number = (metaballs.a - 4 / 3) / 0.3;
            var cc:Number = 1.6 / (1 + aa * aa) - 0.8; // 0 to 0.8 to 0 when aa is -1 to 0 to +1

            sphere.resetVertices ();
            var i:int, L:int = sphere.tvertices.length;
            for (i = 0; i < L; i++) {
                var v:Vector3D = sphere.tvertices [i];
                p.x = v.x; p.y = v.y;
                var vz:Number = v.z;
                if (cc > 0) {
                    // to get better triangulation near a = 4/3 map z to 0.2*z*|z| + 0.8*z
                    if (vz < 0) {
                        vz = (1 - cc) * vz - cc * vz * vz;
                    } else {
                        vz = (1 - cc) * vz + cc * vz * vz;
                    }
                }
                var t:Number = 0.5 + 0.5 * vz;
                // shape as metaball
                v.z = range.x (t);
                p.normalize (metaballs.y (v.z));
                v.x = p.x; v.y = p.y;
                // metaball normal
                p.normalize (1);
                q.x = p.x; q.y = p.y; q.z = -metaballs.y1 ();
                q.normalize ();
                // apply wave modifier
                q.scaleBy (wave.f (t));
                v.incrementBy (q);
            }
        }
    }
}

class Wave {
    public var A:Number = 0, A2:Number = 0;
    public var P:Number = 0;
    public function f (t:Number):Number {
        var X:Number = 2 * t - 1;
        var Y:Number = ((X < 1) && (X > -1)) ? 0.5 + 0.5 * X * X : ((X > 0) ? X : -X);
        var S:Number = Math.sin (10 * Y - P) / Y;
        var C:Number = Math.cos (10000 * X);
        return A * S * S * (1 + A2 * C * C);
    }
}

class Wave2 extends Wave {
    public var w1:Wave;
    public var w2:Wave;
    override public function f (t:Number):Number {
        if (t < 0.5) return w1.f (2 * t);
        return w2.f (2 * t - 1);
    }
}

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.TriangleCulling;
import flash.geom.Vector3D;

class Matrix4 {
    public var Xx:Number = 1, Yx:Number = 0, Zx:Number = 0, Tx:Number = 0;
    public var Xy:Number = 0, Yy:Number = 1, Zy:Number = 0, Ty:Number = 0;
    public var Xz:Number = 0, Yz:Number = 0, Zz:Number = 1, Tz:Number = 5;

    public function rotate (a:Number):void {
        Xx =  Math.cos (a); Xz = Math.sin (a);
        Zx = -Math.sin (a); Zz = Math.cos (a);
    }
}

class BauerSphere {
    public var debug:Boolean;

    // original
    public var overtices:Vector.<Vector3D>;
    // transformed
    public var tvertices:Vector.<Vector3D>;

    // face normals
    public var faceNormals:Vector.<Vector3D>;
    // face map
    public var faceMap:Vector.<Vector.<int>>;

    // faces
    public var faceList1:Vector.<int>;
    public var faceList2:Vector.<int>;
    public var xy:Vector.<Number>;
    public var uv:Vector.<Number>;

    public function addFace (a:int, b:int, c:int):void {
        var L:int = faceNormals.length;
        faceMap [a].push (L);
        faceMap [b].push (L);
        faceMap [c].push (L);
        faceNormals.push (new Vector3D);
        faceList1.push (a, b, c);
        faceList2.unshift (c, a, b);
    }

    public function build (N:int = 456):void {
        overtices = new Vector.<Vector3D> (N, true);
        tvertices = new Vector.<Vector3D> (N, true);

        faceNormals = new <Vector3D> [];
        faceMap = new <Vector.<int>> [];

        faceList1 = new <int> [];
        faceList2 = new <int> [];
        xy = new Vector.<Number> (2 * N, true);
        uv = new Vector.<Number> (2 * N, true);

        // uniformly distributed directions:
        // Bauer, Robert, "Distribution of Points on a Sphere with Application to Star Catalogs",
        // Journal of Guidance, Control, and Dynamics, January-February 2000, vol.23 no.1 (130-137).
        var radius:Number = 1;
        for (var i:int = 1; i <= N; i++) {
            var phi:Number = Math.acos ( -1 + (2 * i -1) / N);
            var theta:Number = Math.sqrt (N * Math.PI) * phi;

            var rxy:Number = radius * Math.sin (phi);
            overtices [i - 1] = new Vector3D ( -rxy * Math.sin (theta), rxy * Math.cos (theta), radius * Math.cos (phi) );

            tvertices [i - 1] = overtices [i - 1].clone ();
            faceMap [i - 1] = new <int> [];
        }

        // make faces (and edges), 1st and last by hand
        addFace (0, 1, 2);

        var lastEdgeA:int = 0;
        var lastEdgeB:int = 2;

        while ((lastEdgeB < N - 1) || (lastEdgeA < N - 3)) {
            var vA:Vector3D = tvertices [lastEdgeA];
            var vB:Vector3D = tvertices [lastEdgeB];
            var vA1:Vector3D = tvertices [lastEdgeA + 1];
            var vB1:Vector3D; if (lastEdgeB < N - 1) vB1 = tvertices [lastEdgeB + 1];

            var canIncA:Boolean = (lastEdgeA < lastEdgeB - 2) &&
                (lastEdgeA < N - 3) &&
                // only if B-A-A1 angle < 90°
                (vB.subtract (vA).dotProduct (vA1.subtract (vA)) > 0);

            var canIncB:Boolean = (vB1 != null) &&
                (lastEdgeB < N - 1) && 
                // only if B1-B-A angle < 90°
                (vB1.subtract (vB).dotProduct (vA.subtract (vB)) > 0);

            if (!(canIncA || canIncB)) break;

            if (  canIncA && canIncB ) {
                // prefer shortest edge
                canIncA = (
                    vB1.subtract (vA).lengthSquared > vA1.subtract (vB).lengthSquared
                );
            }

            if (canIncA) {
                // add face A-B-A1
                addFace (lastEdgeA, lastEdgeB, lastEdgeA + 1);

                // inc A
                lastEdgeA++;
            } else {
                // add face A-B-B1
                addFace (lastEdgeA, lastEdgeB, lastEdgeB + 1);

                // inc B
                lastEdgeB++;
            }
        }

        // last face
        addFace (N - 1, N - 2, N - 3);

        if (debug) trace ("Sphere stats:", tvertices.length, "vertices,", faceNormals.length, "faces");
    }

    public function resetVertices ():void {
        var N:int = overtices.length;
        for (var i:int = 0; i < N; i++) {
            var t:Vector3D = tvertices [i];
            var o:Vector3D = overtices [i];
            t.x = o.x;
            t.y = o.y;
            t.z = o.z;
        }
    }

    public function transformVertices (m:Matrix4):void {
        var N:int = overtices.length;
        for (var i:int = 0; i < N; i++) {
            var t:Vector3D = tvertices [i];
            var x:Number = t.x;
            var y:Number = t.y;
            var z:Number = t.z;
            t.x = m.Xx * x + m.Yx * y + m.Zx * z + m.Tx;
            t.y = m.Xy * x + m.Yy * y + m.Zy * z + m.Ty;
            t.z = m.Xz * x + m.Yz * y + m.Zz * z + m.Tz;
        }

        // update face normals
        N = faceNormals.length;
        for (i = 0; i < N; i++) {
            var i3:int = i * 3;
            var a:Vector3D = tvertices [faceList1 [i3]];
            var b:Vector3D = tvertices [faceList1 [i3 + 1]];
            var c:Vector3D = tvertices [faceList1 [i3 + 2]];
            var x1:Number = b.x - a.x, y1:Number = b.y - a.y, z1:Number = b.z - a.z;
            var x2:Number = c.x - a.x, y2:Number = c.y - a.y, z2:Number = c.z - a.z;
            t = faceNormals [i];
            t.x = y1 * z2 - y2 * z1;
            t.y = z1 * x2 - z2 * x1;
            t.z = x1 * y2 - x2 * y1;
        }
    }

    public var normal:Vector3D = new Vector3D;
    public function render (gfx:Graphics, bd:BitmapData, clear:Boolean = true):void {
        var focalLength:Number = 400;
        var N:int = tvertices.length;
        for (var i:int = 0; i < N; i++) {
            var j:int = 2 * i;
            var t:Vector3D = tvertices [i];

            // project
            var zoom:Number = focalLength / t.z;
            xy [j]     = t.x * zoom;
            xy [j + 1] = t.y * zoom;

            // estimate vertex normals
            normal.scaleBy (0);
            var map:Vector.<int> = faceMap [i];
            var mapL:int = map.length;
            for (var k:int = 0; k < mapL; k++) {
                normal.incrementBy (faceNormals [map [k]]);
            }
            normal.normalize ();

            // env. mapping
            uv [j]     = 0.5 + 0.5 * normal.x;
            uv [j + 1] = 0.5 + 0.5 * normal.y;
        }

        if (clear) gfx.clear ();
        if (debug) gfx.lineStyle (0, 0xFF0000);
        gfx.beginBitmapFill (bd, null, true, true);
        gfx.drawTriangles (xy,
            // half-assed distance sorting
            (tvertices[1].z > tvertices[tvertices.length - 2].z) ? faceList1 : faceList2,
        uv, TriangleCulling.POSITIVE);
    }
}

class Range {
    public var a:Number;
    public var b:Number;
    public function Range (from:Number = 0, to:Number = 0) {
        a = from; b = to;
    }
    public function x (t:Number):Number {
        return a + (b - a) * t;
    }
}

/**
 * Metaballs calculator.
 * @see http://wonderfl.net/c/1TYy/read
 */
class MetaBalls {
    private var a1:Number, a2:Number, b2:Number;
    private var d1:Number, d2:Number;

    public function get a ():Number {
        return a1;
    }
    public function set a (A:Number):void {
        a1 = A;
        a2 = A * A;
        b2 = 1 + (A + a2) / 4; b2 *= b2;
        d1 = 3 * a2 - A - 4;
        d2 = 5 * a2 + A + 4;
    }

    private var x1:Number, x2:Number;
    private var s1:Number, s2:Number;

    public function y (x:Number):Number {
        x1 = x;
        x2 = x * x;
        s1 = Math.sqrt (Math.max (0, 4 * a2 * x2 + b2));
        s2 = Math.sqrt (Math.max (0, s1 - a2 - x2));
        return s2;
    }

    /** 1st derivative, dy/dx. y(x) is expected to be called 1st. */
    public function y1 ():Number {
        return (2 * a2 * x1 / s1 - x1) / s2;
    }

    private var r1:Vector.<Range> = new <Range> [ new Range ];
    private var r2:Vector.<Range> = new <Range> [ new Range, new Range ];

    public function ranges ():Vector.<Range> {
        var S2:Number = 0.5 * Math.sqrt (d2);
        if (d1 > 0) {
            var S1:Number = 0.5 * Math.sqrt (d1);
            r2 [0].a = -S2; r2 [0].b = -S1;
            r2 [1].a =  S1; r2 [1].b =  S2;
            return r2;
        }
        r1 [0].a = -S2; r1 [0].b = S2;
        return r1;
    }
}

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundLoaderContext;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

class BeatPortPlayer {
    private var gid:int;

    public function next ():void {
        if (channel) {
            channel.stop ();
            playRandomSample (new Event ("whatever"))
        }
    }

    /**
     * Plays random samples by genre non-stop.
     * @see http://api.beatport.com/catalog/genres?format=xml&v=1.0
     */
    public function play (genreId:int):void {
        // 1st we need to get total number of tracks
        var loader:URLLoader = new URLLoader;
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        subscribeLoader (loader, getCount, onIOFailure1);
        loader.load (new URLRequest (makeUrl (gid = genreId, 1)));
    }

    private function makeUrl (genreId:int, page:int):String {
        return "http://api.beatport.com/catalog/tracks?genreId=" + genreId + "&perPage=1&page=" + page + "&format=xml&v=1.0";
    }

    private var count:int, sound:Sound, channel:SoundChannel;
    private var context:SoundLoaderContext = new SoundLoaderContext (10, true);

    private function getCount (e:Event):void {
        var loader:URLLoader = URLLoader (e.target);
        unsubscribeLoader (loader, getCount, onIOFailure1);

        var result:XML = XML (loader.data);
        count = parseInt (result.result.@count);

        playRandomSample ();
    }

    private function playRandomSample (e:Event = null):void {
        if (e != null) {
            unsubscribeSoundStuff (); channel = null;
        }

        var loader:URLLoader = new URLLoader;
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        subscribeLoader (loader, getRandomSampleUrl, onIOFailure2);
        loader.load (new URLRequest (makeUrl (gid, 1 + (count - 1) * Math.random ())));
    }

    private function getRandomSampleUrl (e:Event):void {
        var loader:URLLoader = URLLoader (e.target);
        unsubscribeLoader (loader, getRandomSampleUrl, onIOFailure2);

        var result:XML = XML (loader.data);

        channel = Sound (sound = new Sound (
            new URLRequest (result.result.document.track.@url), context
        )).play ();

        subscribeSoundStuff ();
    }

    private function subscribeLoader (loader:URLLoader, onComplete:Function, onIOFailure:Function):void {
        loader.addEventListener (Event.COMPLETE, onComplete);
        loader.addEventListener (IOErrorEvent.IO_ERROR, onIOFailure);
    }

    private function unsubscribeLoader (loader:URLLoader, onComplete:Function, onIOFailure:Function):void {
        loader.removeEventListener (Event.COMPLETE, onComplete);
        loader.removeEventListener (IOErrorEvent.IO_ERROR, onIOFailure);
    }

    private function subscribeSoundStuff ():void {
        sound.addEventListener (IOErrorEvent.IO_ERROR, onIOFailure3);
        channel.addEventListener (Event.SOUND_COMPLETE, playRandomSample);
    }

    private function unsubscribeSoundStuff ():void {
        sound.removeEventListener (IOErrorEvent.IO_ERROR, onIOFailure3);
        channel.removeEventListener (Event.SOUND_COMPLETE, playRandomSample);
    }

    private function onIOFailure1 (e:IOErrorEvent):void {
        unsubscribeLoader (URLLoader (e.target), getCount, onIOFailure1);
        play (gid);
    }

    private function onIOFailure2 (e:IOErrorEvent):void {
        unsubscribeLoader (URLLoader (e.target), getRandomSampleUrl, onIOFailure2);
        playRandomSample ();
    }

    private function onIOFailure3 (e:IOErrorEvent):void {
        // assumes sound's ioError comes before channel's soundComplete
        unsubscribeSoundStuff ();
        playRandomSample ();
    }
}