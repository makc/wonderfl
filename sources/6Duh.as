package
{
    import flash.geom.*;
    import flash.media.*;
    import flash.events.*;
    import flash.display.*;
    import flash.net.URLRequest;

    public class Main extends Sprite
    {
        // https://developers.soundcloud.com/docs/api/reference
        private var CLIENT_ID : String = 'c644fa92a0e751bad397bdd5b8e35ae5',
                     TRACK_ID : Number = 115338118;

        private var smoothstep : Smoothsteps = new Smoothsteps (5),
                      channel : SoundChannel;

        private var w : uint = 465, h : uint = 465;

        private var kami : Vector.<Kamikire>,
                    n : int = 150;

        private var s : Sprite = new Sprite (),
                    e : EffectContainer;

        private var spots : int = 3,
                    areas : Vector.<Area> = new Vector.<Area>(spots, true);

        private var b : BitmapData, spot : BitmapData, matrix : Matrix = new Matrix ();


        public function Main () : void { addEventListener (Event.ADDED_TO_STAGE, init); }

        private function init ($ : Event = null) : void 
        {
            removeEventListener (Event.ADDED_TO_STAGE, init);

            with (stage) { scaleMode = 'noScale'; color = 0x0; frameRate = 60; }

            //

            spot = new BitmapData (10, 10, true, 0);

            var circle : Shape = new Shape ();
            circle.graphics.beginFill (0xFFFFFF, 0.75);
            circle.graphics.drawCircle (5, 5, 5);

            spot.draw (circle);

            //

            kami = new Vector.<Kamikire>(n, true);

            for (var i : int = 0; i < spots; i++)
            {
                var a : Area = new Area (0, 0, w, h);
                a.vx = 2 + Math.random () * 3;
                a.vy = 2 + Math.random () * 3;

                areas [i] = a;
            }

            e = new EffectContainer (w, h, s);
            e.colorIntegrity = true;
            e.blur = true;
            e.passes = 8;
            e.scale = 4;

            addChild (new Bitmap (b = new BitmapData (w, h, true, 0)));

            //

            var sound : Sound = new Sound (new URLRequest ('https://api.soundcloud.com/tracks/' + TRACK_ID + '/stream?client_id=' + CLIENT_ID));

            channel = sound.play (0, int.MAX_VALUE);

            //

            addEventListener (Event.ENTER_FRAME, frame);
        }

        private var current : int = 0;

        private function frame ($ : Event) : void
        {
            var k : Kamikire,

                level : Number = smoothstep.push ((channel.leftPeak + channel.rightPeak) / 2);

            for (var i : int = 0; i < n; i++)
            {
                if (i < current)
                {
                    k = kami [i];

                    k.fall ();

                    if (k.x - Kamikire.SIZE > w) { k.x = -Kamikire.SIZE; }
                    if (k.x + Kamikire.SIZE < 0) { k.x = w; }
                    if (k.y > h) { k.y = -Kamikire.SIZE; }
                }
                else if (level > 0.5)
                {
                    k = new Kamikire ();

                    k.x = (w / n) * current;
                    k.y = 0;

                    kami [current++] = k;

                    s.addChild (k);

                    break;
                }
            }

            //

            b.fillRect (b.rect, 0);

            for (i = 0; i < spots; i++)
            {
                areas [i].update ();

                matrix.tx = (e.srcX = areas [i].px - 5) - 5;
                matrix.ty = (e.srcY = areas [i].py - 5) - 5;

                e.intensity = level * 8;

                e.render ();

                b.draw (spot, matrix);

                b.draw (e, null, new ColorTransform (1, 1, 1, level), null, null, false);
            }
        }
    }
}

// http://wonderfl.net/c/tVmM

import flash.display.*;

class Kamikire extends Shape
{
    private var pi : Number = Math.PI;

    public static const SIZE : Number = 10;

    private var color : uint = Math.random () * 0xFFFFFF;

    private var _theta : Number, // amount of rotation along the axis
                _omega : Number, // angular velocity
                _fallTheta : Number,
                _fallSpeed : Number;

    private var _Ax : Number, _Ay : Number, _Az : Number, // axis of rotation
                _Bx : Number, _By : Number, _Bz : Number, // a unit vector perp to A
                _Cx : Number, _Cy : Number, _Cz : Number; // a unit vector perp to A and B
    
    public function Kamikire ()
    {
        _omega = (Math.random () * 2 - 1) * pi / 4;
        _fallTheta = 0;
        _fallSpeed = 3 + Math.random () * 2;
        _theta = Math.random () * pi * 2;

        _Ax = 1;
        _Ay = Math.random ();
        _Az = Math.random () * 2 - 1;
        
        var _l : Number = Math.sqrt (_Ax * _Ax + _Ay * _Ay + _Az * _Az);
        _Ax /= _l;
        _Ay /= _l;
        _Az /= _l;
        var _s : Number = Math.sqrt (_Ax * _Ax + _Ay * _Ay);

        if ( _s == 0 ) { // then A == ( 0, 0, -1 );
            _Bx = 1.0; _By = 0.0; _Bz = 0.0;
            _Cx = 0.0; _Cy = 1.0; _Cz = 0.0;
        } else {
            _Bx = _Ay; _By = -_Ax; _Bz = 0;
            _Cx = _Ax * _Az; _Cy = _Ay * _Az; _Cz = -(_s * _s);
            _Bx /= _s; _By /= _s;
            _Cx /= _s * _l; _Cy /= _s * _l; _Cz /= _s * _l;
        }

        graphics.beginFill (color);
        graphics.drawRect (-SIZE / 2, -SIZE / 2, SIZE, SIZE);
        graphics.endFill ();
    }

    public function set rotation3D (theta : Number) : void
    {
        _theta = theta - (pi * 2) * Math.floor (theta / (pi * 2));

        var _cos : Number = Math.cos (_theta);
        var _sin : Number = Math.sin (_theta);
        // vector F is the rotated image of (1,0,0);
        var _Fx : Number = _Ax * _Ax + (_Bx * _Bx + _Cx * _Cx) * _cos;
        var _Fy : Number = _Ax * _Ay + (_Bx * _By + _Cx * _Cy) * _cos + (_Bx * _Cy - _Cx * _By) * _sin;
        //var _Fz : Number = _Ax * _Az + (_Bx * _Bz + _Cx * _Cz) * _cos - (_Bx * _Cz - _Cx * _Bz) * _sin;
        // vector G is the rotated image of (0,1,0);
        var _Gx : Number = _Ax * _Ay + (_By * _Bx + _Cy * _Cz) * _cos + (_By * _Cx - _Cy * _Bx) * _sin;
        var _Gy : Number = _Ay * _Ay + (_By * _By + _Cy * _Cy) * _cos;
        // var _Gz : Number = _Ay * _Az + (_By * _Bz + _Cy * _Cz) * _cos + (_By * _Cz - _Cy * _Bz) * _sin;

        graphics.clear ();
        graphics.beginFill (color);
        graphics.moveTo ( _Fx * SIZE / 2 + _Gx * SIZE / 2, _Fy * SIZE / 2 + _Gy * SIZE / 2);
        graphics.lineTo (-_Fx * SIZE / 2 + _Gx * SIZE / 2,-_Fy * SIZE / 2 + _Gy * SIZE / 2);
        graphics.lineTo (-_Fx * SIZE / 2 - _Gx * SIZE / 2,-_Fy * SIZE / 2 - _Gy * SIZE / 2);
        graphics.lineTo ( _Fx * SIZE / 2 - _Gx * SIZE / 2, _Fy * SIZE / 2 - _Gy * SIZE / 2);
        graphics.lineTo ( _Fx * SIZE / 2 + _Gx * SIZE / 2, _Fy * SIZE / 2 + _Gy * SIZE / 2);
        graphics.endFill ();
    }

    public function get rotation3D () : Number { return _theta - (pi * 2) * Math.floor (_theta / (pi * 2)); }

    public function fall () : void
    {
        rotation3D += _omega;
        x += _fallSpeed * Math.sin (_fallTheta);
        y += _fallSpeed * Math.cos (_fallTheta);

        _fallTheta += (Math.random () * 2 - 1) * pi / 12;
        if ( _fallTheta < -pi / 2 ) { _fallTheta = -pi - _fallTheta; }
        if ( _fallTheta >  pi / 2 ) { _fallTheta = pi - _fallTheta; }
    }
}

import flash.geom.*;
import flash.filters.BlurFilter;

class Area extends Rectangle
{
    public var px : Number, py : Number;
    public var vx : Number = 1;
    public var vy : Number = 1;

    public function Area (x : Number = 0, y : Number = 0, width : Number = 100, height : Number = 100)
    {
        super (x, y, width, height);

        px = x + Math.random () * width;
        py = y + Math.random () * height;
    }

    public function update () : void
    {
        px += vx;
        py += vy;

        if (px < x) { px = x; vx = -vx; }
        if (py < y) { py = y; vy = -vy; }
        if (px > x + width)  { px = width  + x; vx = -vx; }
        if (py > y + height) { py = height + y; vy = -vy; }
    }
}

class Smoothsteps
{
    public var previous : Number, current : Number = 0;

    private var values : Vector.<Number>;

    private var iterator : int = 0;

    private var steps : int;


    public function Smoothsteps (steps : int) : void
    {
        values = new Vector.<Number> (steps, true);

        this.steps = steps;
    }

    public function push (value : Number) : Number
    {
        values [iterator++ % steps] = value;

        var sum : Number = 0,

            tmp : int = iterator < steps ? iterator : steps;

        for (var i : int = 0; i < tmp; i++)
        {
            sum += values [i];
        }

        previous = current;

        current = sum / tmp;

        return current;
    }
}

class EffectContainer extends Sprite
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
        if (! ((_lightBmp.visible = intensity) > 0)) return;
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