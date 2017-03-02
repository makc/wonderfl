package
{
    /*
    * SPHERE TEXTURED USING THE MP3 FILE PICTURE (ID3 TAG APIC)
    * --------------------------------------------------------
    * HIT SPACE BAR ONCE STARTED TO UPLOAD A TRACK
    * IF NO ID3 COVER AVAILABLE, WILL DISPLAY A WHITE TEXTURE
    * 
    * OTHERWISE
    * 
    * REQUIRES A MP3 FILE WITH COVER ART AND A SERVER WITH
    * CROSSDOMAIN.XML FILE TO AVOID SECURITY ISSUE
    */

    import flash.net.*;
    import flash.media.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.text.TextField;
    import flash.display.BitmapData;

    import frocessing.color.ColorHSV;

    import org.papervision3d.view.BasicView;
    import org.papervision3d.cameras.SpringCamera3D;

    import org.papervision3d.objects.primitives.Plane;
    import org.papervision3d.objects.primitives.Sphere;

    import org.papervision3d.core.geom.Lines3D;
    import org.papervision3d.core.geom.renderables.Line3D;

    import org.papervision3d.materials.ColorMaterial;
    import org.papervision3d.materials.BitmapMaterial;
    import org.papervision3d.materials.special.LineMaterial;

    /**
    *    @forker SPANVEGA // CHRISTIAN //
    **/

    [SWF(backgroundColor = '0x000000', width = '465', height = '465', frameRate = '25')]

    public class DEPARTURE extends BasicView
    {
        private var color : ColorHSV = new ColorHSV (Math.random () * 360);
        private var c_col : uint;

        private var particles : Vector.<Plane> = new Vector.<Plane>();

        private var H : uint = stage.stageHeight;
        private var W : uint = stage.stageWidth;

        private const A : Number = 10.0;
        private const B : Number = 25.0;
        private const C : Number = 8.0 / 3.0;
        private const D : Number = 0.01;

        private var RT : Number = 360;

        private var xx : Number = .15;
        private var yy : Number = .15;
        private var zz : Number = .15;

        private var sphere : Sphere;
        private var line : Lines3D;

        private var blur : BlurFilter;
        private var glow : GlowFilter;

        private var conf : Boolean;

        // --o SOUND DERIVED PROPERTIES

        private var track : String = 'http://mm4d.free.fr/tracks/sample_alt.mp3';

        private var music : FileReference = new FileReference ();
        private var lPeak : Number, rPeak : Number;
        private var sound : Sound = new Sound ();
        private var sChan : SoundChannel;
        private var urlRq : URLRequest;

        private var lChan : GRAPHIC_BAR, rChan : GRAPHIC_BAR;
        private var infos : TextField,   plays : TextField;
        private var fFram : Boolean;

        private var eCont : EffectContainer;

        private var cover : BitmapData;
        private var id3AP : ID3COVER;

        //

        public function DEPARTURE ()
        {
            Wonderfl.disable_capture ();

            super (W, H, true, false, 'Spring');

            addEventListener (Event.ADDED_TO_STAGE, init);
        }

        private function init (e : Event = null) : void
        {
            removeEventListener (Event.ADDED_TO_STAGE, init);

            SpringCamera3D (camera).mass = 20;
            SpringCamera3D (camera).damping = 30;
            SpringCamera3D (camera).stiffness = 8;

            super.opaqueBackground = true;

            //

            blur = new BlurFilter (3, 3, 2);
            glow = new GlowFilter (0xFFFFFF, 1, 6, 6, 2);

            // --o EFFECT CONTAINER

            eCont = new EffectContainer (W, H, viewport);

            eCont.srcX = W / 2;
            eCont.srcY = H / 2;

            eCont.colorIntegrity = true;
            eCont.intensity = 0.3;
            eCont.blur = true;

            eCont.passes = 8;
            eCont.scale = 4;

            addChild (eCont);

            // --o SOUND DERIVED INSTANCES

            infos = new TextField ();
            infos.selectable = false;
            infos.autoSize = 'left';
            infos.x = 7;
            infos.y = H - 24;

            //

            plays = new TextField ();
            plays.selectable = false;
            plays.autoSize = 'right';
            plays.x = W - 11;
            plays.y = 5;

            //

            lChan = new GRAPHIC_BAR
            (
                W - 23, H - 9, 0, 2, 'V'
            );

            rChan = new GRAPHIC_BAR
            (
                W - 11, H - 9, 0, 2, 'V'
            );

            //

            urlRq = new URLRequest (track);

            sound.addEventListener (Event.ID3, onID3);
            sound.addEventListener (Event.OPEN, onOpen);
            sound.addEventListener (Event.COMPLETE, onComplete);
            sound.addEventListener (IOErrorEvent.IO_ERROR, onIOError);
            sound.addEventListener (SecurityErrorEvent.SECURITY_ERROR, onSecurityError);

            sound.load (urlRq, new SoundLoaderContext (1000, true));

            // --o RETRIEVE MP3 COVER ART (250 x 250)

            id3AP = new ID3COVER (urlRq);

            id3AP.addEventListener (ID3COVER.UNAVAILABLE, onFault);
            id3AP.addEventListener (ID3COVER.AVAILABLE, onCover);

            //

            onResize ();

            stage.addEventListener (Event.RESIZE, onResize);
        }

        private function onFault (e : Event) : void
        {
            cover = new BitmapData (100, 100, false, 0xFFFFFF);

            conf ? onTexture () : setUp ();
        }

        private function onCover (e : Event) : void
        {
            cover = e.target.cover;

            e.target.removeEventListener (ID3COVER.AVAILABLE, onCover);

            //

            setUp ();
        }

        private function setUp () : void
        {
            conf = true;

            sphere = new Sphere (new ColorMaterial(0xffffff), 3, 24, 24);
 
            onTexture ();

            sphere.x = 1;
            sphere.y = 1;
            sphere.z = 1;

            sphere.filters = [glow];
            sphere.useOwnContainer = true;

            scene.addChild (sphere);

            //

            line = new Lines3D
            (
                new LineMaterial (0, 0)
            );

            scene.addChild (line);

            //

            super.startRendering ();

            music.addEventListener (Event.SELECT, select);
            music.addEventListener (Event.COMPLETE, complete);

            stage.addEventListener (KeyboardEvent.KEY_DOWN, onKey);

            stage.addEventListener (Event.ENTER_FRAME, onRotation);
        }

        private function onTexture () : void
        {
            var mat : BitmapMaterial = new BitmapMaterial (cover, true);
            mat.tiled = true;
            mat.smooth = true;

            sphere.material = mat;
        }

        private function onRotation (e : Event) : void
        {
            if ((RT -= 6) > 0)
            {
                sphere.roll (6);

                eCont.render ();
            }
            else
            {
                stage.removeEventListener (Event.ENTER_FRAME, onRotation);

                addChild (infos);
                addChild (plays);
                addChild (lChan);
                addChild (rChan);

                sChan = new SoundChannel();
                sChan = sound.play (0, 50);

                //

                eCont.intensity = 1.75;

                camera.target = sphere;

                stage.addEventListener (Event.ENTER_FRAME, onFrame);
            }
        }

        private function onFrame (event : Event) : void
        {
            c_col = color.value;

            lPeak = sChan.leftPeak;
            rPeak = sChan.rightPeak;

            lChan.draw (lPeak * (H / 7.15), c_col);
            rChan.draw (rPeak * (H / 7.15), c_col);

            plays.htmlText = '<font size=\'10\' color=\'#FFFFFF\'>[ ' + onDuration (sChan.position) + ' | ' + onDuration (sound.length) + ' ]</font>';

            // 3D RENDERING

            var sumP : Number = (fFram ? lPeak + rPeak * 4 : 80);

            // FROM
            var preX : Number = sphere.x;
            var preY : Number = sphere.y;
            var preZ : Number = sphere.z;

            var dx : Number = A * (yy - xx);
            var dy : Number = xx * (B - zz) - yy;
            var dz : Number = xx * yy - C * zz;
            // TO
            xx += D * dx;
            yy += D * dy;
            zz += D * dz;

            sphere.x = xx * 20;
            sphere.y = yy * 20;
            sphere.z = zz * 20;

            line.addNewLine (2, preX, preY, preZ, sphere.x, sphere.y, sphere.z);
            line.material = new LineMaterial(c_col);

            glow.color = c_col;

            for (var j : int = 0; j < Math.ceil (sumP); j++)
            {
                var mat : ColorMaterial = new ColorMaterial (onCoverPixel());
                mat.doubleSided = true;
                var p : Plane = new Plane (mat, 1, 1);
                p.x = sphere.x;
                p.y = sphere.y;
                p.z = sphere.z;
                p.useOwnContainer = true;
                p.filters = [blur];
                p.extra = { vx : Math.random() * 6 - 3, vy : Math.random() * 6 - 3, vz : Math.random() * 6 - 3 };
                scene.addChild(p);
                particles.push(p);
            }

            // --o PLANES

            for each (var e : Plane in particles)
            {
                e.x += e.extra.vx;
                e.y += e.extra.vy;
                e.z += e.extra.vz;

                e.rotationX += 18;
                e.rotationY += 18;
                e.rotationZ += 18;

                e.material.fillAlpha -= 0.05;

                if (e.material.fillAlpha <= 0)
                {
                    particles.splice (particles.indexOf(e), 1);
                    scene.removeChild (e);
                }
            }

            // --o LINES

            for each (var l : Line3D in line.lines)
            {
                l.material.lineAlpha -= 0.001;
                if (l.material.lineAlpha <= 0)
                {
                    line.removeLine (l);
                }
            }

            color.h += 0.1;

            //

            fFram ? eCont.render () : fFram = true;
        }

        private function onCoverPixel () : uint
        {
            return cover.getPixel
            (
                Math.random() * cover.width, Math.random () * cover.height
            );
        }

        // --o SOUND EVENT HANDLERS

        private function onID3 (e : Event) : void
        {   
            sound.removeEventListener (Event.ID3, onID3);

            var sTags : String = '<font size=\'10\' color=\'#FFFFFF\'>[ ';

            if (sound.id3.TPE1) sTags += sound.id3.TPE1;
            if (sound.id3.TIT2) sTags += ' | ' + sound.id3.TIT2;
            if (sound.id3.TALB) sTags += ' | ' + sound.id3.TALB;
            if (sound.id3.TBPM) sTags += ' | ' + sound.id3.TBPM + ' BPM';

            sTags += ' ]</font>';

            infos.htmlText = sTags;
        }

        private function onDuration (n : uint) : String
        {
            var m : uint = Math.floor(n / 1000 / 60);
            var s : uint = Math.floor(n / 1000) % 60;

            return m + ':' + (s < 10 ? '0' + s : s);
        }

        private function onOpen (e : Event) : void {}

        private function onComplete (e : Event) : void {}

        private function onIOError (e : IOErrorEvent) : void {}

        private function onSecurityError (e : SecurityErrorEvent) : void { }

        //

        private function onResize (e : Event = null) : void
        {
            H = stage.stageHeight;
            W = stage.stageWidth;

            // TEXTFIELDS

            infos.y = H - 24;
            plays.x = W - (7 + plays.width);

            // GRAPHIC BARS

            lChan.x = W - 23;
            lChan.y = H - 9;
    
            rChan.x = W - 11;
            rChan.y = H - 9;

            // EFFECT CONTAINER

            eCont.setViewportSize (W, H);

            eCont.srcX = W / 2;
            eCont.srcY = H / 2;
        }

        private function onKey (e :KeyboardEvent) : void
        {
            switch (e.keyCode) { case 32 : browse (); }
        }

        // FILE UPLOAD

        private function browse () : void 
        {
            music.browse ( [new FileFilter ('Music File (*.mp3)', '*.mp3;')] ); 
        }

        private function select (e : Event) : void 
        {
            music.load (); 
        }

        private function complete (e : Event) : void 
        {
            if (sChan) sChan.stop ();

            sound = new Sound ();
            sound.addEventListener (Event.ID3, onID3);
            sound.loadCompressedDataFromByteArray (music.data, music.data.length); 

            sChan = sound.play ();

            id3AP.readID3 (music.data);
            id3AP.addEventListener (ID3COVER.AVAILABLE, onCoverLocal);
        }

        private function onCoverLocal (e : Event) : void
        {
            cover = e.target.cover;

            onTexture ();
        }
    }
}

// --o GRAPHIC BAR

import flash.geom.Matrix;

import flash.display.Shape;
import flash.display.GraphicsPath;
import flash.display.IGraphicsData;
import flash.display.GraphicsStroke;
import flash.display.GraphicsGradientFill;

/**
*    @author SPANVEGA // CHRISTIAN //
**/

internal class GRAPHIC_BAR extends Shape
{
    public var c : uint;
    public var m : Matrix;
    public var w : Number;
    public var h : Number;    

    private var g_p : GraphicsPath;
    private var g_s : GraphicsStroke;
    private var g_f : GraphicsGradientFill;

    private var g_c : Vector.<int> = new Vector.<int>();
    private var g_d : Vector.<Number> = new Vector.<Number>();
    private var g_v : Vector.<IGraphicsData> = new Vector.<IGraphicsData>();

    public function GRAPHIC_BAR (x : Number, y : Number, width : Number, height : Number, display : String = 'H' /* || 'V' */)
    {
        this.x = x;
        this.y = y;

        w =  width;
        h = height;

        m = new Matrix ();
        m.createGradientBox (2, 2);

        if (display == 'V') rotation = -90;

        //

        g_s = new GraphicsStroke (h);

        g_f = new GraphicsGradientFill
        (
            'linear', [c, 0], [1, 0], [64, 128], m, 'repeat'
        );
        g_s.fill = g_f;

        g_c.push (1, 2);

        g_p = new GraphicsPath (g_c, g_d);
    }

    public function draw (value : Number, color : uint) : void
    {
        clear ();

        g_f.colors = [c=color, 0];

        g_d.length = 0;
        g_d.push (0, 0, value, 0);

        g_p.data = g_d;

        g_v.length = 0;
        g_v.push (g_s, g_p);

        graphics.drawGraphicsData (g_v);
    }

    public function clear () : void
    {
        graphics.clear ();
    }

    public function reset () : void
    {
        draw (w, c);
    }
}

//

import flash.utils.ByteArray;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.BitmapData;

import flash.net.URLStream;
import flash.net.URLRequest;

import flash.events.Event;
import flash.events.ProgressEvent;

/**
* ID3IMAGE CLASS DERIVED FROM
* ---------------------------
* ORIGINAL CLASS BY: AEDE SYMEN HOEKSTRA 
* DOWNLOADURL:http://code.google.com/p/id3imagereader/downloads/list
*/

class ID3COVER extends URLStream
{
    public var cover : BitmapData;
    //
    private var img : ByteArray;
    private var len : uint = 0;
    private var version : Number;
    private var len2 : Number;
    private var frames : Array;
    private var bytes : ByteArray;
    private var unsynchronisation : Boolean;
    private var extendedHeader : Boolean;
    private var experimental : Boolean;
    private var frameIdSize : uint = 3;
    private var frameHeadSize : uint = 10;
    private var _bytes : ByteArray = new ByteArray();

    /** Dispatch ID3COVER.AVAILABLE Event **/
    static public const AVAILABLE : String = 'AVAILABLE';
    /** Dispatch ID3COVER.UNAVAILABLE Event **/
    static public const UNAVAILABLE : String = 'UNAVAILABLE';

    public function ID3COVER (request : URLRequest = null) : void
    {
        if (request)
        {
            load(request);

            addEventListener (ProgressEvent.PROGRESS, onID3Progress);
        }
    }

    private function onID3Progress (e : ProgressEvent) : void
    {
        if (len == 0)
        {
            getID3Length();
        }
        else if (bytesAvailable >= len)
        {
            readBytes(_bytes, 10, bytesAvailable);

            close();

            removeEventListener (ProgressEvent.PROGRESS, onID3Progress);
            readID3 (_bytes);
        }
    }

    public function readID3 (data : ByteArray = null) : void
    {
        frames = [];
        img = new ByteArray ();
        data ? _load(data) : 0;
    }

    private function _load (data : ByteArray) : void
    {
        bytes = data;
        bytes.position = 0;
        if (bytes.readUTFBytes(3).toUpperCase() == 'ID3')
        {
            version = bytes.readByte() + bytes.readByte() / 100;
            if (version >= 3)
            {
                frameIdSize = 4;
            }
            var flags : uint = bytes.readByte ();
            var unsynchronisation : uint = flags >> 7;
            var extendedHeader : uint = flags >> 6 && 01;
            var experimental : uint = flags >> 5 && 001;
            len2 = readSynchsafeIntA (bytes.readInt ());
            readFrames();

            if (img.length > 0)
            {
                var loader:Loader = new Loader();
                loader.loadBytes (img);
                loader.contentLoaderInfo.addEventListener (Event.COMPLETE, makeCover);
            }
            else
            {
                dispatchEvent (new Event (ID3COVER.UNAVAILABLE));
            }
        }
    }

    private function readFrames () : void
    {
        var id : String = '';
        var size : uint = 0;
        while (bytes.position < len2 + 1)
        {
            id = bytes.readUTFBytes (frameIdSize);
            size = bytes.readInt ();
            if (version >= 3)
            {
                bytes.readByte ();
                bytes.readByte ();
            }
            if (id == 'APIC' || id == 'PIC')
            {
                frames[id] = readAPIC(size);
            }
            else if (id=='')
            {
                break;
            }
            else
            {
                readUnknown(size);
            }
        }
    }

    private function readSynchsafeIntA (synch : int) : int
    {
        return (synch & 127) + 128 * ((synch >> 8) & 127) + 16384 * ((synch >>16) & 127) + 2097152 * ((synch >> 24) & 127);
    }

    private function readAPIC (size : uint) : Object
    {
        var start : uint = bytes.position;
        var obj : Object = new Object ();
        obj.data = new ByteArray ();
        obj.encoding = bytes.readByte ();
        obj.mime = readString ();
        obj.type = bytes.readByte ();
        obj.description = readString ();
        bytes.readBytes(img, 0, size - (bytes.position - start));
        img.position = 0;
        return obj;
    }

    private function readUnknown (size : uint) : void
    {
        for (var i : uint = 0; i < size; i++)
        {
            bytes.readByte ();
        }
    }

    private function readString () : String
    {
        var ba : ByteArray = new ByteArray ();
        var b : int = bytes.readByte ();
        while (b != 0)
        {
            ba.writeByte (b);
            b = bytes.readByte ();
        }
        ba.position = 0;
        return ba.readUTFBytes (ba.length);
    }

    private function getID3Length () : void
    {
        if (len == 0 && bytesAvailable >= 10)
        {
            readBytes(_bytes, 0, 10);

            if (_bytes.readUTFBytes(3).toUpperCase() == 'ID3')
            {
                _bytes.readByte ();
                _bytes.readByte ();
                _bytes.readByte ();
                len = _bytes.readInt();
            }
        }
    }

    private function makeCover (e : Event) : void
    {
        var _loaderInfo : LoaderInfo = LoaderInfo (e.target);

        cover = new BitmapData (_loaderInfo.width, _loaderInfo.height, true, 0);

        cover.draw (_loaderInfo.loader);

        dispatchEvent (new Event (ID3COVER.AVAILABLE));
    }
}

//

import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;

import flash.filters.BlurFilter;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.display.BitmapData;
import flash.display.DisplayObject;

/*
* ORIGINAL CLASS AVAILABLE @
* https://github.com/yonatan/volumetrics/blob/master/src/org/zozuar/volumetrics/EffectContainer.as
* CORRESPONDING DOCUMENTATION @
* http://zozuar.org/volumetrics/org/zozuar/volumetrics/EffectContainer.html
* 
* IF NEEDED USE CLASS MENTIONNED ABOVE, SINCE THIS ONE IS PARTLY TRUNCATED
*/ 

internal class EffectContainer extends Sprite
{
    public var colorIntegrity : Boolean = false;
    public var smoothing : Boolean = true;
    public var blur : Boolean = false;
    public var intensity : Number = 4;
    public var scale : Number = 2;
    public var passes : uint = 6;

    public var srcX : Number;
    public var srcY : Number;

    //

    protected var _blurFilter : BlurFilter = new BlurFilter (2, 2);
    protected var _emission : DisplayObject;
    protected var _occlusion : DisplayObject;
    protected var _ct : ColorTransform = new ColorTransform;
    protected var _halve : ColorTransform = new ColorTransform (0.5, 0.5, 0.5);
    protected var _occlusionLoResBmd : BitmapData;
    protected var _occlusionLoResBmp : Bitmap;
    protected var _baseBmd : BitmapData;
    protected var _bufferBmd : BitmapData;
    protected var _lightBmp : Bitmap = new Bitmap;
    protected var _bufferSize : uint = 0x8000;
    protected var _bufferWidth : uint;
    protected var _bufferHeight : uint;
    protected var _viewportWidth : uint;
    protected var _viewportHeight : uint;
    protected var _mtx : Matrix = new Matrix;

    public function EffectContainer (width : uint, height : uint, emission : DisplayObject, occlusion : DisplayObject = null)
    {
        addChild (_emission = emission);
        if (occlusion) addChild (_occlusion = occlusion);
        setViewportSize (width, height);
        _lightBmp.blendMode = BlendMode.ADD;
        addChild (_lightBmp);
        srcY = height / 2;
        srcX = width / 2;
    }

    public function setViewportSize (width : uint, height : uint) : void
    {
        _viewportWidth = width;
        _viewportHeight = height;
        scrollRect = new Rectangle (0, 0, width, height);
        _updateBuffers ();
    }

    public function setBufferSize (size : uint) : void
    {
        _bufferSize = size;
        _updateBuffers ();
    }

    protected function _updateBuffers () : void
    {
        var aspect : Number = _viewportWidth / _viewportHeight;
        _bufferHeight = Math.max (1, Math.sqrt (_bufferSize / aspect));
        _bufferWidth  = Math.max (1, _bufferHeight * aspect);
        dispose ();
        _baseBmd = new BitmapData (_bufferWidth, _bufferHeight, false, 0);
        _bufferBmd = new BitmapData (_bufferWidth, _bufferHeight, false, 0);
        _occlusionLoResBmd = new BitmapData (_bufferWidth, _bufferHeight, true, 0);
        _occlusionLoResBmp = new Bitmap (_occlusionLoResBmd);
    }

    public function render () : void
    {
        if (! (_lightBmp.visible = intensity > 0)) return;
        var mul : Number = colorIntegrity ? intensity : intensity/ (1<<passes);
        _ct.redMultiplier = _ct.greenMultiplier = _ct.blueMultiplier = mul;
        _drawLoResEmission ();
        if (_occlusion) _eraseLoResOcclusion ();
        var s : Number = 1 + (scale-1) / (1 << passes);
        var tx : Number = srcX/_viewportWidth*_bufferWidth;
        var ty : Number = srcY/_viewportHeight*_bufferHeight;
        _mtx.identity ();
        _mtx.translate (-tx, -ty);
        _mtx.scale (s, s);
        _mtx.translate (tx, ty);
        _lightBmp.bitmapData = _applyEffect (_baseBmd, _bufferBmd, _mtx, passes);
        _lightBmp.width = _viewportWidth;
        _lightBmp.height = _viewportHeight;
        _lightBmp.smoothing = smoothing;
    }

    protected function _drawLoResEmission () : void
    {
        _copyMatrix (_emission.transform.matrix, _mtx);
        _mtx.scale (_bufferWidth / _viewportWidth, _bufferHeight / _viewportHeight);
        _baseBmd.fillRect (_baseBmd.rect, 0);
        _baseBmd.draw (_emission, _mtx, colorIntegrity ? null : _ct);
    }

    protected function _eraseLoResOcclusion () : void
    {
        _occlusionLoResBmd.fillRect (_occlusionLoResBmd.rect, 0);
        _copyMatrix (_occlusion.transform.matrix, _mtx);
        _mtx.scale (_bufferWidth / _viewportWidth, _bufferHeight / _viewportHeight);
        _occlusionLoResBmd.draw (_occlusion, _mtx);
        _baseBmd.draw (_occlusionLoResBmp, null, null, BlendMode.ERASE);
    }

    protected function _applyEffect (src : BitmapData, buffer : BitmapData, mtx : Matrix, passes : uint) : BitmapData
    {
        var tmp : BitmapData;
        while (passes--)
        {
            if (colorIntegrity) src.colorTransform (src.rect, _halve);
            buffer.copyPixels (src, src.rect, src.rect.topLeft);
            buffer.draw (src, mtx, null, BlendMode.ADD, null, true);
            mtx.concat (mtx);
            tmp = src; src = buffer; buffer = tmp;
        }
        if (colorIntegrity) src.colorTransform (src.rect, _ct);
        if (blur) src.applyFilter (src, src.rect, src.rect.topLeft, _blurFilter);
        return src;
    }

    public function dispose () : void
    {
        if (_baseBmd) _baseBmd.dispose ();
        if (_occlusionLoResBmd) _occlusionLoResBmd.dispose ();
        if (_bufferBmd) _bufferBmd.dispose ();
        _baseBmd = _occlusionLoResBmd = _bufferBmd = _lightBmp.bitmapData = null;
    }
    
    protected function _copyMatrix (src : Matrix, dst : Matrix) : void
    {
        dst.a = src.a;
        dst.b = src.b;
        dst.c = src.c;
        dst.d = src.d;
        dst.tx = src.tx;
        dst.ty = src.ty;
    }
}