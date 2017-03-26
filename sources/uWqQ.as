package  
{
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    public class city extends Sprite
    {
        private var main:city3d;
        
        public function city() 
        {    
            Wonderfl.disable_capture();
            main = new city3d(stage);
            stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown);
        }
        
        private function onMouseDown( e:MouseEvent ):void
        {
            main.choseMP3();
        }
    }
}
import flash.display.Loader;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DVertexBufferFormat;
import flash.events.EventDispatcher;
import flash.events.EventPhase;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Vector3D;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.utils.getTimer;
import flash.utils.Timer;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.Quad;
import org.libspark.betweenas3.easing.Quart;
import org.libspark.betweenas3.events.TweenEvent;
import org.libspark.betweenas3.tweens.ITween;

class ThreeD extends EventDispatcher
{
    // constant
    public static const ITS_OK:String = "ItsOK";
    public static const BOOT_SUCCESS:String = "BootSuccess";
    private static const INDEX_PADDING:int = 6;
    
    // dependences
    private var stg:Stage;
    
    // 3D
    public var context3D:Context3D;
    public var container:Sprite;
    public var indexBuffer:IndexBuffer3D;
    public var program:Program3D;
    public var asm:AGALMiniAssembler = new AGALMiniAssembler();
    public var projectionMatrix:PerspectiveMatrix3D = new PerspectiveMatrix3D();
    public var matrix3D:Matrix3D = new Matrix3D();
    
    // variables
    private var meshes:Vector.<Mesh> = new Vector.<Mesh>;
    private var vertexBuffers:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>;
    private var indexBuffers:Vector.<IndexBuffer3D> = new Vector.<IndexBuffer3D>;
    private var textures:Vector.<Texture> = new Vector.<Texture>;
    
    public function ThreeD(s:Stage)
    {
        stg = s;
    }
    
    public function check():void
    {
        var stage3D:Stage3D = stg.stage3Ds[0];
        stage3D.addEventListener( Event.CONTEXT3D_CREATE,
            function( e:Event ):void {
                // context3d setup
                context3D = e.target.context3D;
                if (!context3D) throw new Error( "no context3D" );
                
                // context
                context3D.enableErrorChecking = true;
                context3D.configureBackBuffer( 465, 465, 0, true );
                context3D.setRenderToBackBuffer();
                context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
                context3D.setCulling(Context3DTriangleFace.BACK);
                dispatchEvent( new Event( ITS_OK ) );
            }
        );
        stage3D.requestContext3D();
    }
    
    public function boot():void
    {    
        // programs
        program = context3D.createProgram();
        program.upload( asm.assemble( "vertex", vs ), asm.assemble( "fragment", fs ) );
        
        // matrix
        projectionMatrix.perspectiveFieldOfViewLH( 60 / 180 * 3.141592653589793, 1, 1, 65000 );
        
        // finish booting
        dispatchEvent( new Event( BOOT_SUCCESS ) );
    }

    public function addMesh( m:Mesh ):void
    {
        var index:int = meshes.length;
        meshes.push( m );
        m.vertices.fixed = true;
        m.indices.fixed = true;
        
        // buffers
        vertexBuffers.push( context3D.createVertexBuffer( m.currentIndex, m.INDEX_PADDING ) );
        indexBuffers.push( context3D.createIndexBuffer( m.indices.length ) );
        vertexBuffers[index].uploadFromVector( m.vertices, 0, m.currentIndex );
        indexBuffers[index].uploadFromVector( m.indices, 0, m.indices.length );
        
        // textures
        textures.push( context3D.createTexture( 512, 512, "bgra", false ) );
        textures[index].uploadFromBitmapData( m.material.bmd );
    }
    
    public function render():void
    {
        context3D.clear( 0.0, 0.0, 0.0, 1 );
        context3D.setDepthTest( true, "less" );
        context3D.setProgram( program );
        
        var i:int = 0;
        while ( i < meshes.length )
        {
            matrix3D.copyFrom( projectionMatrix );
            matrix3D.prepend( meshes[i].matrix );
            if( meshes[i].material.live )
                textures[i].uploadFromBitmapData( meshes[i].material.bmd );
            context3D.setTextureAt( 0, textures[i] );
            if ( meshes[i].live )
            {
                vertexBuffers[i].uploadFromVector( meshes[i].vertices, 0, meshes[i].currentIndex );
                indexBuffers[i].uploadFromVector( meshes[i].indices, 0, meshes[i].indices.length );
            }
            context3D.setVertexBufferAt( 0, vertexBuffers[i], 0, Context3DVertexBufferFormat.FLOAT_4 );
            context3D.setVertexBufferAt( 1, vertexBuffers[i], 4, Context3DVertexBufferFormat.FLOAT_2 );
            context3D.setProgramConstantsFromMatrix( "vertex", 0, matrix3D, true );
            context3D.drawTriangles( indexBuffers[i], 0, meshes[i].indices.length / 3 );
            i++;
        }

        context3D.present();
    }
}

class Material extends EventDispatcher
{
    public var live:Boolean = false;
    public var bmd:BitmapData;
    public function Material()
    {
        
    }
    
    public function update():void {}
}

class VehicleLightMaterial extends Material
{
    public var r:Number = 0;
    public var R:Number = 0;
    public var w:Number = 0;
    public var W:Number = 0;
    
    private var tmp:BitmapData;
    
    public function VehicleLightMaterial( radius:Number = 8, lc:uint = 0xFFFF0000, rc:uint = 0xFFFFCC33 )
    {
        r = radius;
        R = r * 2; // also, diameter
        w = Math.sqrt( R * R / 2 );
        W = 2 * r + w;
        //R = R + 1;
        W = W + 1;
        
        bmd = new BitmapData( 512, 512, true, 0x0 );
        tmp = new BitmapData( W, W, true, 0x0 );

        drawStar( bmd, r, r, lc );
        drawStar( bmd, W - r - 1, W - r - 1, rc );
        var m:Matrix = new Matrix();
        m.scale( bmd.width / tmp.width, bmd.height / tmp.height );
        bmd.draw( bmd, m );
    }
    
    public function drawStar( e:BitmapData, px:int, py:int, c:uint = 0xFFFF0000 ):void
    {
        lineFast( e, px -     r, py        , px +     r, py        , c );
        lineFast( e, px        , py -     r, px        , py +     r, c );
        lineFast( e, px - r / 2, py - r / 2, px + r / 2, py + r / 2, c );
        lineFast( e, px - r / 2, py + r / 2, px + r / 2, py - r / 2, c );
    }
    
    public function lineFast( e:BitmapData, x0:int, y0:int, x1:int, y1:int, c:uint = 0xFFFF0000 ):void
    {    
        var dy       :int = y1 - y0;
        var dx       :int = x1 - x0;
        var adx      :int = 0;
        var ady      :int = 0;
        var stepx    :int;
        var stepy    :int;
        var fraction :int;
        var ratio    :Number = 0;
        var ec       :uint = c & 0xFFFFFF; // ignore alpha
        var tc:uint = ec;
        tc = ec + uint(( 0xFF * 0.05 ) << 24);
        
        if ( dy < 0 ) { dy = -dy;  stepy = -1; } else { stepy = 1; }
        if ( dx < 0 ) { dx = -dx;  stepx = -1; } else { stepx = 1; }
        adx = Math.abs( dx ) + 2;
        ady = Math.abs( dy ) + 2;
        dy <<= 1;
        dx <<= 1;
        
        e.setPixel32( x0, y0, tc );
        if ( dx > dy )
        {
            fraction = dy - ( dx >> 1 );
            while ( x0 != x1 )
            {
                ratio = 1 - Math.abs( Math.abs( x0 - x1 ) / adx - 0.5 ) * 2;
                if ( fraction >= 0 )
                {
                    y0 += stepy;
                    fraction -= dx;
                }
                x0 += stepx;
                fraction += dy;
                tc = ec;
                tc += ( 0xFF * ratio ) << 24;
                e.setPixel32( x0, y0, tc );
            }
        } else {
            fraction = dx - ( dy >> 1 );
            while ( y0 != y1 )
            {
                ratio = 1 - Math.abs( Math.abs( y0 - y1 ) / ady - 0.5 ) * 2;
                if ( fraction >= 0 )
                {
                    x0 += stepx;
                    fraction -= dy;
                }
                y0 += stepy;
                fraction += dx;
                tc = ec;
                tc += ( 0xFF * ratio ) << 24;
                e.setPixel32( x0, y0, tc );
            }
        }
    }
}

class MusicMaterial extends Material
{
    public static const PEAK:String = "peak";
    
    // settings
    private var tcolor:uint = 0xFFFFCC32;
    private var windowX:int = 16;
    private var windowY:int = 32;
    
    // bitmaps
    private var ct:ColorTransform = new ColorTransform( 0.9, 0.8, 0.6, 1 );
    
    // sounds
    private var snd:Sound;
    private var bytes:ByteArray = new ByteArray();
    private var song:SoundChannel;
    private var url:String = "http://level0.kayac.com/images/murai/Digi_GAlessio_-_08_-_ekiti_son_feat_valeska_-_april_deegee_rmx.mp3";
    private var file:FileReference;
    
    public function MusicMaterial()
    {
        live = true;
        
        snd = new Sound();
        snd.load( new URLRequest( url ), new SoundLoaderContext( 10, true ) );
        song = snd.play(0, int.MAX_VALUE);

        bmd = new BitmapData( 512, 512, false, 0x0 );
    }
    
    private function onUserCancelled (e:Event):void { }
    private function onFileSelected (e:Event):void { file.load (); }
    private function onFileLoaded (e:Event):void {
        if ( song ) song.stop();
        
        snd = new Sound();
        snd.loadCompressedDataFromByteArray(file.data, file.data.length);
        song = snd.play(0, int.MAX_VALUE);
    }
    
    
    public function loadMP3():void
    {
        file = new FileReference;
        file.addEventListener (Event.CANCEL, onUserCancelled);
        file.addEventListener (Event.SELECT, onFileSelected);
        file.addEventListener (Event.COMPLETE, onFileLoaded);
        file.browse ([ new FileFilter ("MP3 files", "*.mp3") ]);
    }
    
    private function mp3Loaded(e:Event):void
    {
        if ( song ) song.stop();
        song = snd.play(0, int.MAX_VALUE);
    }
    
    override public function update():void
    {
        SoundMixer.computeSpectrum( bytes, false, 0 );
        var byteTotal:Number = 0;
        var i:int = 0, j:int = 0;
        var byte:Number = 0;
        bytes.position = 0;
        var split:int = 2;
        var dsplit:int = split * 2;
        var w:int = 20 / split;
        var h:int = 25 / split;
        var p:int =  8 / split;
        
        bmd.colorTransform( bmd.rect, ct );

        var size:Number = bmd.width * 0.8;
        var hsize:Number = bmd.width * 0.4;
        var sw:Number = hsize / windowX;
        var sh:Number = hsize / windowY;
        
        var tcolor:uint = 0xFFFFCC33;
        var iw:int = 0;
        var ih:int = 0;
        
        var d:int = 0;
        
        for( i = 0; i < 512; i++ )
        {
            byte = Math.abs( bytes.readFloat() );
            byteTotal += byte;
            if( ( byte > 0.3 && Math.random() > 0.5 ) || Math.random() < 0.0001 )
            {
                for ( j = 0; j < split * 2; j++ )
                {
                    switch( j )
                    {
                        case 0:
                            iw = i % windowX;
                            ih = int( i / windowX );
                            tcolor = 0xFFFFCC33;
                            break;
                        case 1:
                            iw = i % windowX;
                            ih = windowY - int( i / windowX ) - 1;
                            tcolor = 0xFFFFFFFF;
                            break;
                        case 2:
                            iw = windowX - i % windowX - 1;
                            ih = int( i / windowX );
                            tcolor = 0xFFFFFFAA;
                            break;
                        case 3:
                            iw = windowX - i % windowX - 1;
                            tcolor = 0xFF99CCFF;
                            ih = windowY - int( i / windowX ) - 1;
                            break;
                    }
                    if ( Math.random() < 0.001 ) continue;
                    bmd.fillRect( new Rectangle(
                            iw * sw + p / 2 + ( j % split ) * hsize,
                            ih * sh + int( j / split ) * hsize,
                            sw - p, sh - p
                        ), 
                        tcolor 
                    );
                }
            }
        }
        
        byteTotal /= 512;
        
        if ( byteTotal > 0.3 )
        {
            dispatchEvent( new Event( PEAK ) );
        }
        
        /*
        if (byteTotal > 0.3 )
        {
            var k:int = int( Math.random() * 4 );
            for ( i = 0; i < 4; i++ )
            {
                if ( i == k )
                {
                    bmd.fillRect( new Rectangle(
                            i * hsize/2,
                            size,
                            hsize/2, hsize/2
                        ), 
                        0x3FFFCC33 
                    );
                    bmd.fillRect( new Rectangle(
                            ( i % split ) * hsize,
                            int( i / split ) * hsize,
                            hsize, hsize
                        ), 
                        0x3FFFCC33
                    );
                }
            }
        }
        //*/
    }
}

class Mesh
{
    public var INDEX_PADDING:int = 6;
    public var vertices:Vector.<Number>;
    public var indices:Vector.<uint>;
    public var matrix:Matrix3D = new Matrix3D();
    public var material:Material;
    public var live:Boolean = false;
    
    public function Mesh()
    {
        vertices = new Vector.<Number>;
        indices = new Vector.<uint>;
    }
    
    public function pushVertex( ...arg ):Mesh
    {
        for each( var v:Number in arg ) vertices.push( v );
        return this;
    }
    
    public function pushIndex( ...arg ):Mesh
    {
        for each( var v:int in arg ) indices.push( v );
        return this;
    }
    
    public function get currentIndex():int
    {
        return vertices.length / INDEX_PADDING;
    }
}

class ToyCar
{
    public var rotation:Number = 0;
    public var x:Number = 0;
    public var y:Number = 0;
    public function ToyCar() {}
}

class FireworksManager
{
    private static const MAX_FIREWORKS:int = 3;
    private static const MAX_PARTICLES:int = 400;
    private static const PARTICLE_RADIUS:Number = 8;
    private static const PARTICLE_W:Number = Math.sqrt( PARTICLE_RADIUS * PARTICLE_RADIUS / 2 );
    private var particles:Vector.<Vector3D> = new Vector.<Vector3D>;
    private var keeper:Vector.<Vector3D> = new Vector.<Vector3D>;
    
    public function FireworksManager()
    {
        for ( var i:int = 0; i < MAX_PARTICLES; i++ )
        {
            particles.push( new Vector3D() ); // w -> alpha
            keeper.push( particles[i] );
        }
    }
    
    private function withdraw(px:Number, py:Number, pz:Number):Boolean
    {
        if (keeper.length > 0)
        {
            var rd:Number = 2000 + Math.random() * 1000;
            var rand:Number = Math.random() * 2 * Math.PI;
            var rx:Number = Math.cos(rand);
            var ry:Number = Math.sin(rand);
            var rz:Number = (2*Math.random()) - 1;
            var mz:Number = Math.sqrt(1 - rz * rz);
            var r3x:Number = rx * mz * rd;
            var r3y:Number = ry * mz * rd;
            rz *= rd;
            var itw:ITween = BetweenAS3.tween(keeper.shift(), { x:r3x+px, y:r3y+py, z:rz+pz, w:1.0 }, { x:px, y:py, z:pz, w:1.0 }, 0.5+Math.random() * 1.0, Quad.easeOut);
            itw.addEventListener( TweenEvent.COMPLETE, 
                function( e:TweenEvent ):void
                {
                    var iw:ITween = BetweenAS3.tween(e.currentTarget.target, { w:0.0 }, null, 0.5);
                    iw.addEventListener( TweenEvent.COMPLETE, function( e:TweenEvent ):void
                    {
                        keeper.push(e.currentTarget.target);
                    });
                    iw.play()
                });
            itw.play();
            return true;
        }
        return false;
    }
    
    public function explode():void
    {
        if ( keeper.length < 30 ) return;
        var rx:Number = CityFactory.MAP_WIDTH / 4 + Math.random() * CityFactory.MAP_WIDTH / 2;
        var ry:Number = CityFactory.MAX_BUILDING_HEIGHT * 1.5  + Math.random() * 3000;
        var rz:Number = CityFactory.MAP_WIDTH / 4 + Math.random() * CityFactory.MAP_WIDTH / 2;
        for ( var i:int = 0; i < 50; i++ )
        {
            if ( !withdraw( rx, ry, rz ) ) break;
        }
    }
    
    public function initMesh( m:Mesh ):void
    {
        m.vertices = new Vector.<Number>( particles.length * 18, true );
        
        var j:int = 0;
        var k:int = 0, o:int = 0, l:int = 0, u:int = 0;
        for ( var i:int = 0; i < particles.length; i++ )
        {
            j = i * 3;
            
            k = i * 18 + 4;
            if (Math.random() > 0.5)
            {
                m.vertices[k - 1] = 1;
                // .(0,1)
                m.vertices[k] = 0;
                m.vertices[k + 1] = 1;
                
                k += 6;
                m.vertices[k - 1] = 1;
                // .(0,0)
                m.vertices[k] = 0;
                m.vertices[k + 1] = 0;
                
                k += 6;
                m.vertices[k - 1] = 1;
                // .(1,0)
                m.vertices[k] = 1;
                m.vertices[k + 1] = 0;
            } else {
                m.vertices[k - 1] = 1;
                // .(1,0)
                m.vertices[k] = 1;
                m.vertices[k + 1] = 0;
                
                k += 6;
                m.vertices[k - 1] = 1;
                // .(1,1)
                m.vertices[k] = 1;
                m.vertices[k + 1] = 1;
                
                k += 6;
                m.vertices[k - 1] = 1;
                // .(0,1)
                m.vertices[k] = 0;
                m.vertices[k + 1] = 1;
            }
            
            m.pushIndex( 
                j    , j + 1, j + 2
            );
        }
    }
    
    public function updateMesh( m:Mesh, sm:Matrix3D, offset:Point ):void // sprite particle need some magic
    {
        var j:int = 0;
        var k:int = 0;
        var o:int = 0;
        
        var mat:VehicleLightMaterial = VehicleLightMaterial( m.material );
        var r:Number = PARTICLE_RADIUS;
        var w:Number = PARTICLE_W;
        var scale:Number = 40;
        var scale2:Number = 20;
        var tl_x:Number = -r;
        var tl_y:Number = -r;
        var tr_x:Number = w + r;
        var tr_y:Number = -r;
        var bl_x:Number = -r;
        var bl_y:Number = w + r;
        var tri:Vector.<Number> = new Vector.<Number>;
        tri.push(
            bl_x * scale, 0, bl_y * scale,
            tl_x * scale, 0, tl_y * scale,
            tr_x * scale,  0, tr_y * scale
        );

        var cv:Vector3D = new Vector3D();
        for ( var i:int = 0; i < particles.length; i++ )
        {
            for ( k = 0; k < 3; k++ )
            {
                o = i * 18 + k * 6;
                cv.x = particles[i].x + offset.x;
                cv.y = particles[i].y;
                cv.z = particles[i].z + offset.y;
                cv = sm.transformVector( cv);
                m.vertices[o]     = cv.x + tri[k];
                m.vertices[o + 1] = cv.y + tri[k + 1];
                m.vertices[o + 2] = cv.z + tri[k + 2];
                m.vertices[o + 3] = particles[i].w;
            }
        }
    }
}

class TrafficManager
{
    private static const MAX_VEHICLES:int = 300;
    private static const PARTICLE_RADIUS:Number = 8;
    private static const PARTICLE_W:Number = Math.sqrt( PARTICLE_RADIUS * PARTICLE_RADIUS / 2 );
    
    public var worldMatrix:Matrix3D;
    
    public var highways:Vector.<Vector.<Point>>;
    
    public var cars:Vector.<ToyCar> = new Vector.<ToyCar>;
    
    private var count:int = 0;
    
    public function TrafficManager( hw:Vector.<Vector.<Point>> )
    {
        highways = hw;
        for ( var i:int = 0; i < MAX_VEHICLES; i++ )
        {
            cars.push( new ToyCar() );
        }
    }
    
    public function boot():void
    {
        trace("TrafficManager:: boot.");
        
        
        var timer:Timer = new Timer(100);
        timer.addEventListener( TimerEvent.TIMER, addVehicle );
        timer.start();
    }
    
    private function addVehicle( e:TimerEvent ):void
    {
        if ( count < cars.length )
        {
            inviteVehicle( count );
            count++;
        }
    }
    
    private function inviteVehicle( id:int ):void
    {
        var index:int = int( Math.random() * highways.length );
        var highway:Vector.<Point> = highways[index];
        var a:int = 0, b:int = 1;
        var vx:Number = 0, vy:Number = 0, d:Number = 0;
        var rvx:Number = 0, rvy:Number = 0;
        if ( Math.random() < 0.5 )
        {
            a = 1; b = 0;
        }
        vx = highway[b].x - highway[a].x;
        vy = highway[b].y - highway[a].y;
        d = Math.sqrt(vx * vx + vy * vy);
        rvx = -vy/d*160;
        rvy = vx/d*160;
        cars[id].rotation = Math.atan2( vy, vx ) * 180 / Math.PI;
        var itw:ITween = BetweenAS3.tween( cars[id], { x: highway[b].x+rvx, y: highway[b].y+rvy }, { x: highway[a].x+rvx, y: highway[a].y+rvy }, 15.0 * d / 62500 );
        itw.addEventListener( Event.COMPLETE, function( e:Event ):void {
            inviteVehicle( id );
        });
        itw.play();
    }
    
    public function initMesh( m:Mesh ):void
    {
        // 1 car ~ 4 lights ~ 4 triangles ~ 12 indices ~ 12 vertices ~ 12 uv ~ 60 numbers ( 12 x 3 + 12 x 2 ); vertices 0 -> 5 front lights, 6 -> 11 back lights
        m.vertices = new Vector.<Number>( cars.length * 72, true );

        var j:int = 0;
        var k:int = 0, o:int = 0, l:int = 0, u:int = 0;
        for ( var i:int = 0; i < cars.length; i++ )
        {
            j = i * 12;
            l = i * 72;
            for ( k = 0; k < 4; k++ )
            {
                u = i * 72 + k * 18 + 4;
                if (k < 2)
                {
                    // left light   __
                    //             |
                    m.vertices[u - 1] = 1;
                    // .(0,1)
                    m.vertices[u] = 0;
                    m.vertices[u + 1] = 1;
                    u += 6;
                    m.vertices[u - 1] = 1;
                    // .(0,0)
                    m.vertices[u] = 0;
                    m.vertices[u + 1] = 0;
                    u += 6;
                    m.vertices[u - 1] = 1;
                    // .(1,0)
                    m.vertices[u] = 1;
                    m.vertices[u + 1] = 0;
                } else {
                    // right light
                    //              __|
                    m.vertices[u - 1] = 1;
                    // .(1,0)
                    m.vertices[u] = 1;
                    m.vertices[u + 1] = 0;
                    u += 6;
                    m.vertices[u - 1] = 1;
                    // .(1,1)
                    m.vertices[u] = 1;
                    m.vertices[u + 1] = 1;
                    u += 6;
                    m.vertices[u - 1] = 1;
                    // .(0,1)
                    m.vertices[u] = 0;
                    m.vertices[u + 1] = 1;
                }
            }
            m.pushIndex( 
                j    , j + 1, j + 2,
                j + 3, j + 4, j + 5,
                j + 6, j + 7, j + 8, 
                j + 9, j + 10, j + 11 
            );
        }
    }
    
    public function updateMesh( m:Mesh, sm:Matrix3D, offset:Point ):void // sprite particle need some magic
    {
        var j:int = 0;
        var k:int = 0;
        var q:int = 0;
        var o:int = 0;
        var mt:Matrix3D = new Matrix3D();
        mt.copyFrom( sm );
        var v:Vector3D = new Vector3D();
        mt.copyColumnTo(3, v);
        mt.appendTranslation(-v.x, -v.y, -v.z);
        mt.invert();
        
        var mat:VehicleLightMaterial = VehicleLightMaterial( m.material );
        var r:Number = PARTICLE_RADIUS;
        var w:Number = PARTICLE_W;
        var scale:Number = 30;
        var scale2:Number = 20;
        var tl_x:Number = -r;
        var tl_y:Number = -r;
        var tr_x:Number = w + r;
        var tr_y:Number = -r;
        var bl_x:Number = -r;
        var bl_y:Number = w + r;
        var tri:Vector.<Number> = new Vector.<Number>;
        tri.push(
            bl_x * scale, 0, bl_y * scale,
            tl_x * scale, 0, tl_y * scale,
            tr_x * scale,  0, tr_y * scale
        );

        var staticData:Vector.<Number> = new Vector.<Number>;
        staticData.push(
            -3 * scale2, 0, -5 * scale2,
             3 * scale2, 0, -5 * scale2,
            -3 * scale2, 0,  5 * scale2,
             3 * scale2, 0,  5 * scale2
        );
        
        var dynamicData:Vector.<Number> = new Vector.<Number>( 12, true );
        var ma:Matrix3D = new Matrix3D();
        var cv:Vector3D = new Vector3D();
        for ( var i:int = 0; i < cars.length; i++ )
        {
            for ( j = 0; j < 12; j++ )
            {
                dynamicData[j] = staticData[j];
            }
            ma.identity();
            ma.appendRotation( 90 - cars[i].rotation, Vector3D.Y_AXIS );
            ma.transformVectors( dynamicData, dynamicData );
            for ( j = 0; j < 4; j++ )
            {
                for ( k = 0; k < 3; k++ )
                {
                    o = i * 72 + j * 18 + k * 6;
                    q = j * 3;
                    cv.x = dynamicData[q]     + cars[i].x + offset.x;
                    cv.y = dynamicData[q + 1];
                    cv.z = dynamicData[q + 2] + cars[i].y + offset.y;
                    cv = sm.transformVector( cv);
                    m.vertices[o]     = cv.x + tri[k];
                    m.vertices[o + 1] = cv.y + tri[k + 1];
                    m.vertices[o + 2] = cv.z + tri[k + 2];
                }
            }
        }
    }
}

class CityFactory
{
    // settings
    public static const MAP_WIDTH:Number = 42500;
    public static const MAP_HEIGHT:Number = 42500;
    public static const MAX_BUILDING_HEIGHT:Number = 4000;
    public static const SPLIT_AMOUNT:int = 1200;
    private var offset:Point = new Point( -MAP_WIDTH / 2, -MAP_HEIGHT / 2 );
    
    public var building:Mesh = new Mesh();
    public var traffic:Mesh = new Mesh();
    public var fireworks:Mesh = new Mesh();
    
    private var trafficManager:TrafficManager;
    private var fireworksManager:FireworksManager;
    
    public function CityFactory()
    {
        building.material = new MusicMaterial();
        traffic.material = new VehicleLightMaterial(10);
        fireworks.material = new VehicleLightMaterial(18, 0xFFFF33CC, 0xFF33CCFF);
        building.material.addEventListener( MusicMaterial.PEAK, shotFireworks );
    }
    
    public function planAndConstruct():void
    {
        var i:int = 0, j:int = 0;
        var cell:Cell = new Cell(new Point(0 , 0), new Point(MAP_WIDTH, 0), new Point(0, MAP_HEIGHT), new Point(MAP_WIDTH, MAP_HEIGHT));
        cell.setOriginal( cell.tl, cell.tr, cell.bl, cell.br );
        cell.setPatterns(
            function(c:*):Boolean { return c < 6; }, // chose
            null, // slope
            function(c:Number = 1):Number { return 0.993 - Math.random() * 0.001 * c * c; } // size
        );
        for( i = SPLIT_AMOUNT; i; i-- ) cell.leaf( new Point( Math.random() * MAP_WIDTH, Math.random() * MAP_HEIGHT ) ).divide();
                
        var newRegions:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
        newRegions = cell.checkOut();
        
        for each( var region:Vector.<Point> in newRegions )
        {
            pushBuilding( region );
        }
        
        var highways:Vector.<Vector.<Point>> = cell.checkOutHighway();
        
        trafficManager = new TrafficManager( highways );
        trafficManager.initMesh( traffic );
        trafficManager.boot();
        traffic.live = true;
        
        fireworksManager = new FireworksManager();
        fireworksManager.initMesh( fireworks );
        fireworks.live = true;
    }
    
    private function pushBuilding( v:Vector.<Point> ):void
    {
        var index:int = 0;
        var split:int = 4;
        var hsplit:int = split / 2;
        var vratio:Number = 0.8;
        var hratio:Number = 0.4;
        var min:Number = MAX_BUILDING_HEIGHT * 0.20;
        var max:Number = MAX_BUILDING_HEIGHT * 0.80;
        var randomHeight:Number = -( min + Math.random() * Math.random() * max );
        var i1:int, i2:int, i3:int, i4:int, j:int, k:int;
        var rand:int = int( Math.random() * 4 );
        var o:int = int( Math.random() * 4 );
        var ox:Number = ( o % 2 ) * hratio;
        var oy:Number = int( o / 2 ) * hratio;
        for(var i:int = 0; i < v.length; i++)
        {
            k = ( i + rand ) % v.length;
            j = ( k + 1 ) % v.length;
            index = building.currentIndex;
            i1 = index;
            i2 = index + 1;
            i3 = index + 2;
            i4 = index + 3;
            building.pushVertex(
                v[k].x + offset.x, 
                -randomHeight, 
                v[k].y + offset.y,
                1,
                ( k % hsplit ) * vratio / split + ox,
                int( k / hsplit ) * vratio / split + oy
            ).pushVertex(
                v[j].x + offset.x,
                -randomHeight,
                v[j].y + offset.y,
                1,
                ( ( k % hsplit ) + 1 ) * vratio / split + ox,
                int( k / hsplit ) * vratio / split + oy
            ).pushVertex(
                v[k].x + offset.x,
                0,
                v[k].y + offset.y,
                1,
                ( k % hsplit ) * vratio / split + ox,
                ( int( k / hsplit ) + 1 ) * vratio / split + oy
            ).pushVertex(
                v[j].x + offset.x,
                0,
                v[j].y + offset.y,
                1,
                ( ( k % hsplit ) + 1 ) * vratio / split + ox,
                ( int( k / hsplit ) + 1 ) * vratio / split + oy
            ).pushIndex( i1, i2, i3, i3, i2, i4 );
        }
        // top
        index = building.currentIndex;
        i1 = index;
        i2 = index + 1;
        i3 = index + 2;
        i4 = index + 3;
        building.pushVertex(
            v[1].x + offset.x,
            -randomHeight,
            v[1].y + offset.y,
            1,
            o*hratio/2, vratio
        ).pushVertex(
            v[0].x + offset.x,
            -randomHeight,
            v[0].y + offset.y,
            1,
            (o+1)*hratio/2, vratio
        ).pushVertex(
            v[2].x + offset.x,
            -randomHeight,
            v[2].y + offset.y,
            1,
            o*hratio/2, 1
        ).pushVertex(
            v[3].x + offset.x,
            -randomHeight,
            v[3].y + offset.y,
            1,
            (o+1)*hratio/2, 1
        ).pushIndex( i1, i2, i3, i3, i2, i4 );
    }
    
    public function shotFireworks( e:Event ):void
    {
        fireworksManager.explode();
    }
    
    public function update():void
    {
        building.material.update();
        building.matrix.identity();
        building.matrix.prependRotation( -45+30*Math.cos(getTimer()/10000), Vector3D.X_AXIS );
        building.matrix.prependRotation( (getTimer() / 200)%360, Vector3D.Y_AXIS );
        building.matrix.appendTranslation( 0, 0, 15000 );
        trafficManager.updateMesh( traffic, building.matrix, offset );
        fireworksManager.updateMesh( fireworks, building.matrix, offset );
    }
}

import com.adobe.utils.AGALMiniAssembler;
import com.adobe.utils.PerspectiveMatrix3D;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Stage;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display.Sprite;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.geom.ColorTransform;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundLoaderContext;
import flash.media.SoundMixer;
import flash.display3D.textures.Texture;
import flash.net.URLRequest;
import flash.events.Event;
import flash.utils.ByteArray;

class city3d
{
    // objects
    private var city:CityFactory;
    
    // misc
    private var stg:Stage;
    
    // utils
    private var threeD:ThreeD;
    
    public function city3d(s:Stage)
    {
        stg = s;
        city = new CityFactory();
        threeD = new ThreeD( stg );
        threeD.addEventListener( ThreeD.ITS_OK, initThreeD );
        threeD.check();
    }
    
    private function initThreeD( e:Event ):void
    {
        // init objects
        city.planAndConstruct();
        
        // add objects
        threeD.addMesh( city.building );
        threeD.addMesh( city.traffic );
        threeD.addMesh( city.fireworks );
        
        // boot
        threeD.removeEventListener( ThreeD.ITS_OK, initThreeD );
        threeD.addEventListener( ThreeD.BOOT_SUCCESS,
            function( e:Event ):void
            {
                stg.addEventListener( Event.ENTER_FRAME, processing );
            }
        );
        threeD.boot();
    }
    
    public function choseMP3():void
    {
        MusicMaterial(city.building.material).loadMP3();
    }
    
    private function processing( e:Event ):void
    {
        // update objects
        city.update();
        
        // render
        threeD.render();
    }
}

import flash.geom.Point;
class Cell {
    
    public var tl:Point;
    public var tr:Point;
    public var bl:Point;
    public var br:Point;
    
    private var _tl:Point;
    private var _tr:Point;
    private var _bl:Point;
    private var _br:Point;
    
    private var d0:Point;
    private var d1:Point;
    
    private var hw0:Point;
    private var hw1:Point;
    
    private var c0:Cell;
    private var c1:Cell;
    
    private var margin:Number = 0.2;
    private var hmargin:Number = margin / 2;
    
    private var chosePattern:Function;
    private var slopePattern:Function;
    private var sizePattern:Function;
    
    public var level:int = 0;
    
    public function Cell( tl:Point, tr:Point, bl:Point, br:Point, r:Number = 1, l:int = 0 ) {
        this.level = ++l;
        this.tl = tl.clone();
        this.tr = tr.clone();
        this.bl = bl.clone();
        this.br = br.clone();
        if ( r != 1 ) resizeCell( this.tl, this.tr, this.br, this.bl, r );
    }
    
    public function setOriginal( otl:Point, otr:Point, obl:Point, obr:Point ):void
    {
        this._tl = otl.clone();
        this._tr = otr.clone();
        this._bl = obl.clone();
        this._br = obr.clone();
    }
    
    private function get width():Number {
        return (tr.subtract(tl).length + br.subtract(bl).length) / 2;
    }
    
    private function get height():Number {
        return (bl.subtract(tl).length + br.subtract(tr).length) / 2;
    }
    
    private function get ratio():Number {
        var w:Number = width;
        var h:Number = height;
        return w * w / (w * w + h * h);
    }
    
    public function leaf(p:Point):Cell {
        if (!c0) return this;
        var dp:Point = p.subtract(d0);
        var dd:Point = d1.subtract(d0);
        if (dd.x * dp.y - dd.y * dp.x >= 0) return c0.leaf(p);
        else return c1.leaf(p);
    }
    
    public function divide():void {
        var i0:Number = 0.5 + Math.random() * margin - hmargin;
        var i1:Number = (Math.random() < 0.5)? i0: 0.5 + Math.random() * margin - hmargin;
        var thw0:Point;
        var thw1:Point;
        if (Math.random() < ratio) {
            // vertical
            d0 = interpolate( tl, tr, i0 );
            d1 = interpolate( bl, br, i1 );
            thw0 = intersection( d0, d1, _tl, _tr );
            thw1 = intersection( d0, d1, _bl, _br );
            c0 = new Cell( tl, d0, bl, d1, (sizePattern != null)? sizePattern( level ): 1, level );
            c1 = new Cell( d0, tr, d1, br, (sizePattern != null)? sizePattern( level ): 1, level );
            c0.setOriginal( _tl, thw0, _bl, thw1 );
            c1.setOriginal( thw0, _tr, thw1, _br );
        } else {
            // horizontal
            d0 = interpolate( br, tr, i0 );
            d1 = interpolate( bl, tl, i1 );
            thw0 = intersection( d0, d1, _br, _tr );
            thw1 = intersection( d0, d1, _bl, _tl );
            c0 = new Cell( tl, tr, d1, d0, (sizePattern != null)? sizePattern( level ): 1, level );
            c1 = new Cell( d1, d0, bl, br, (sizePattern != null)? sizePattern( level ): 1, level );
            c0.setOriginal( _tl, _tr, thw1, thw0 );
            c1.setOriginal( thw1, thw0, _bl, _br );
        }
        if ( chosePattern != null && chosePattern( level ) ) { hw0 = thw0.clone(); hw1 = thw1.clone(); }
        c0.setPatterns( this.chosePattern, this.slopePattern, this.sizePattern );
        c1.setPatterns( this.chosePattern, this.slopePattern, this.sizePattern );
    }
    
    public function checkOut():Vector.<Vector.<Point>> {
        var arr:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
        pump(arr);
        return arr;
    }
    
    public function checkOutHighway():Vector.<Vector.<Point>> {
        var arr:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
        pumpHighway( arr );
        return arr;
    }
    
    public function setPatterns( chose_pattern:Function, slope_pattern:Function, size_pattern:Function ):void
    {
        this.chosePattern = chose_pattern;
        this.slopePattern = slope_pattern;
        this.sizePattern = size_pattern;
    }
    
    public function pump( arr:Vector.<Vector.<Point>> ):void
    {
        if(c0) {
            c0.pump(arr); c1.pump(arr);
        } else {
            var ar:Vector.<Point> = new Vector.<Point>();
            ar.push(tl,tr,br,bl);
            arr.push(ar);
        }
    }
    
    public function pumpHighway( arr:Vector.<Vector.<Point>> ):void
    {
        if(c0) {
            c0.pumpHighway(arr); c1.pumpHighway(arr);
        }
        if ( hw0 )
        {
            var ar:Vector.<Point> = new Vector.<Point>();
            ar.push( hw0, hw1 );
            arr.push( ar );
        }
    }
    
    public function intersection( p1:Point, p2:Point, p3:Point, p4:Point ):Point
    {
        var p21x:Number = p2.x - p1.x;
        var p21y:Number = p2.y - p1.y;
        var p43x:Number = p4.x - p3.x;
        var p43y:Number = p4.y - p3.y;
        var d:Number = p21x * p43y - p21y * p43x;
        if ( d == 0 ) return null;
        var p31x:Number = p3.x - p1.x;
        var p31y:Number = p3.y - p1.y;
        var m1:Number = ( p31x * p43y - p31y * p43x ) / d;
        //if ( ( p31x * p43y - p31y * p43x ) / d < 0 || m1 > 1 ) return null;
        //var m2:Number = (p31x * p21y - p31y * p21x) / d;
        //if ( ( p31x * p21y - p31y * p21x ) / d < 0 || m2 > 1 ) return null;
        return new Point( p1.x + m1 * p21x, p1.y + m1 * p21y );
    }
    
    private static function interpolate( p0:Point, p1:Point, i:Number ):Point {
        var j:Number = 1 - i;
        return new Point( p0.x * j + p1.x * i, p0.y * j + p1.y * i );
    }

    private function resizeCell( p1:Point, p2:Point, p3:Point, p4:Point, r:Number ):void
    {
        var center:Point = com( p1, p2, p3, p4 );
        resizePoint( p1, center, r );
        resizePoint( p2, center, r );
        resizePoint( p3, center, r );
        resizePoint( p4, center, r );
    }
    
    private function resizePoint( p:Point, ct:Point, r:Number ):void
    {
        p.x = ct.x + ( p.x - ct.x ) * r;
        p.y = ct.y + ( p.y - ct.y ) * r;
    }
    
    private function com( p1:Point, p2:Point, p3:Point, p4:Point ):Point
    {
        var arr:Vector.<Point> = new Vector.<Point>();
        arr.push( p1, p2, p3, p4 );
        var cm:Point = new Point();
        var tx:Number = 0;
        var ty:Number = 0;
        var a:Number = area( arr );
        var i:int = 0;
        var j:int = 0;
        var d:Number = 0;
        i = 0;
        while ( i < arr.length )
        {
            
            j = ( i + 1 ) % arr.length;
            d = arr[i].x * arr[j].y - arr[j].x * arr[i].y;
            tx = tx + ( arr[i].x + arr[j].x ) * d;
            ty = ty + ( arr[i].y + arr[j].y ) * d;
            i++;
        }
        a = a * 6;
        d = 1 / a;
        tx = tx * d;
        ty = ty * d;
        cm.x = tx;
        cm.y = ty;
        return cm;
    }
    
    private function area( p:Vector.<Point> ):Number
    {
        var i:int = 0;
        var j:int = 0;
        var a:Number = 0;
        i = 0;
        while ( i < p.length )
        {
            j = ( i + 1 ) % p.length;
            a = a + p[i].x * p[j].y;
            a = a - p[i].y * p[j].x; 
            i++;
        }
        a = a / 2;
        return a;
    }
}

var vs:String = <agalCode><![CDATA[
mov vt0, va0
m44 op, vt0, vc0
mov v0, va1
mov v1, va0
]]></agalCode>;

var fs:String = <agalCode><![CDATA[
tex ft0, v0.xy, fs0 <2d,clamp,nearest>
mul ft0, ft0, v1.www
mov oc, ft0
]]></agalCode>;
