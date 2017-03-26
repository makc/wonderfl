// forked from yd_niku's Flight404 の人のコードをAS3にしてみた
// Flight404 の人のコードをAS3にしてみた
// key == g; // 重力ON/OFF
// key == f; // 床ON/OFF
// key == p; // パーリンノイズON/OFF
// key == t; // 尻尾ON/OFF

// renderTailsと偽Perlinノイズ実装
// Vec3D#normalize()に0の余剰問題があったので修正

// Source Code release 1
// Particle Emitter
//
// February 11th 2008
//
// Built with Processing v.135 which you can download at http://www.processing.org/download
//
// Robert Hodgin
// flight404.com
// barbariangroup.com

// features:
//           Toxi's magnificent Vec3D library
//           perlin noise flow fields
//           ribbon trails
//           OpenGL additive blending
//           OpenGL display lists
//
// 
// Uses the very useful Vec3D library by Karsten Schmidt (toxi)
// You can download it at http://code.google.com/p/toxiclibs/downloads/list
//
// Please post suggestions and improvements at the flight404 blog. When nicer/faster/better
// practices are suggested, I will incorporate them into the source and repost. I think that
// will be a reasonable system for now.
//
// Future additions will include:
//           Rudimentary camera movement
//           Magnetic repulsion
//           More textures means more iron
//
// UPDATES
//
// February 11th 2008
// Reorganized some of the OpenGL calls as per Simon Gelfius' suggestion.
// http://www.kinesis.be/

package {
    import flash.display.*;
    import flash.events.*;

    [SWF(backgroundColor=0x00, frameRate=40)]
    public class FlashTest extends Sprite {

        public function FlashTest() {
            addChild( new MainDisplay() );
        }

    }
}

import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.net.*;
import flash.utils.*;

class BmdParticle extends BitmapData {
    public function BmdParticle ( w:Number,h:Number ) {
        super( 200, 200, true, 0x00 );
		var s:Shape = new Shape();
		var mat:Matrix = new Matrix();mat.createGradientBox( 200, 200 );
		s.graphics.beginGradientFill( GradientType.RADIAL, [ 0xFFFFFF, 0xFF0000, 0xFF0000 ], [ 1, 0.2, 0 ], [ 0, 88, 255 ], mat );
		s.graphics.drawCircle( 100,100,100 );
		s.graphics.endFill();
		draw( s );
    }
 }
 class BmdEmitter extends BitmapData {
    public function BmdEmitter( w:Number,h:Number ) {
        super( 120, 120, true, 0x00 );
		var s:Shape = new Shape();
		var mat:Matrix = new Matrix();mat.createGradientBox( 120, 120 );
		s.graphics.beginGradientFill( GradientType.RADIAL, [ 0xFFFFFF, 0xFF0000, 0xFF0066, 0xFF0000 ], [ 1, 0.5, 0.2, 0 ], [ 0, 60, 80, 255 ], mat );
		s.graphics.drawCircle( 60,60,60 );
		s.graphics.endFill();
		draw( s );
    }
 }
class Renderer {
	
		public static var gravity:Vec3D;
		public static var floorLevel:Number = 360;;

		public static var lineBuffer:Sprite;
		public static var particleImg:BitmapData;
		public static var emitterImg:BitmapData;
		
		public static var ALLOWGRAVITY:Boolean = true;    // add gravity vector?
		public static var ALLOWPERLIN:Boolean = true;     // add perlin noise flow field vector?
		public static var ALLOWTRAILS:Boolean = true;     // render particle trails?
		public static var ALLOWFLOOR:Boolean = true;      // add a floor?

		public static var mousePressed:Boolean = false;

		private var _emitter:Emitter;
		private var _canvas:BitmapData;
		private static var _counter:uint = 0;
		private static var instance:Renderer;

		public function Renderer( canvas:BitmapData ) {
			gravity = new Vec3D( 0, .35, 0 );
			instance = this;
			_canvas = canvas;
			_emitter     = new Emitter();
		
			lineBuffer = new Rect( _canvas.width, _canvas.height, 0x00 );
			particleImg = new BmdParticle(0, 0);
			emitterImg  = new BmdEmitter(0, 0);
		}
		public static function draw( mouseX:Number , mouseY:Number ):void {
			instance._draw( mouseX, mouseY );
		}
		private function _draw( mouseX:Number , mouseY:Number ):void {
			
			_canvas.fillRect( _canvas.rect, 0x00 );
			_canvas.lock();
			_emitter.exist( mouseX, mouseY );
			_canvas.unlock();

			// If the mouse button is pressed, then add 10 new particles.
			if( mousePressed ){
				if( ALLOWTRAILS && ALLOWFLOOR ){
					_emitter.addParticles( 5 );
				} else {
					_emitter.addParticles( 10 );
				}
			}

			_counter++;
		}

		private static var zFar:Number = 1000;
		public static function renderImage( symbol:BitmapData, loc:Vec3D, diam:Number, color:uint, alpha:uint ):void {
			/*
			gl.glTranslatef( _loc.x, _loc.y, _loc.z );
			gl.glScalef( _diam, _diam, _diam );
			gl.glColor4f( red(_col), green(_col), blue(_col), _alpha );
			*/
			// trace( loc.z );
			var perspective:Number = zFar / (zFar -loc.z );
			var x :Number = loc.x * perspective;
			var y :Number = loc.y * perspective;
			
			diam *= perspective;
			
			var offsetX:Number = symbol.width * diam *0.5;
			var offsetY:Number = symbol.height * diam * 0.5;
			var mat:Matrix = new Matrix( diam, 0, 0, diam, x - offsetX, y - offsetY );
			var r:uint = color << 16 & 0xFF;
			var g:uint = color << 8 & 0xFF;
			var b:uint = color & 0xFF;
			var ctf:ColorTransform = new ColorTransform();
			ctf.redOffset = r;
			ctf.greenOffset = g;
			ctf.blueOffset = b;
			ctf.alphaMultiplier = alpha;
			instance.canvas.draw( symbol, mat, ctf, BlendMode.LIGHTEN );
		}
		
		public static function renderTails( vertices:Array ):void {
			
			var color32:uint, p00:Vec3D, p01:Vec3D, p10:Vec3D,  p11:Vec3D;

			lineBuffer.graphics.clear();
			for (var i:uint = 3, l:uint=vertices.length; i < l; i+= 3 ) {
				
				color32 = vertices[i-3];
				p00 = vertices[i-2];
				p01 = vertices[i-1];

				//color32 = vertices[i];
				p10 = vertices[i+1];
				p11 = vertices[i+2];
				var f00:Number = zFar / (zFar -p00.z );
				var f01:Number = zFar / (zFar -p01.z );
				var f10:Number = zFar / (zFar -p10.z );
				var f11:Number = zFar / (zFar -p11.z );
		
				lineBuffer.graphics.beginFill( color32 & 0xFFFFFF, Number( color32 >> 24 & 0xFF ) *0.005 );
				lineBuffer.graphics.moveTo( p00.x * f00, p00.y * f00 );
				lineBuffer.graphics.lineTo( p01.x * f01, p01.y * f01 );
				lineBuffer.graphics.lineTo( p11.x * f11, p11.y * f11 );
				lineBuffer.graphics.lineTo( p10.x * f10, p10.y * f10 );
				lineBuffer.graphics.lineTo( p00.x * f00, p00.y * f00 );
				lineBuffer.graphics.endFill();
			}

			instance.canvas.draw( lineBuffer, null, null, BlendMode.LIGHTEN );
		}
		private static var _first:Boolean = false;

		public function get canvas():BitmapData {
			return _canvas;
		}
		public static var minNoise:Number = 0.499;
		public static var maxNoise:Number = 0.501;
		public static function getRads( val1:Number, val2:Number, mult:Number, div:Number ):Number {
			var rads:Number = noise(val1/div, val2/div, _counter/div);

			if (rads < minNoise) minNoise = rads;
			if (rads > maxNoise) maxNoise = rads;

			rads -= minNoise;
			rads *= 1.0/(maxNoise - minNoise);

			return rads * mult;
		}

		private static function noise( x:Number, y:Number, len:Number ) :Number {
			return Math.random();// 偽ノイズ
		}
}
/*
The emitter is just an object that follows the cursor and
can spawn new particle objects. It would be easier to just make
the location vector match the cursor position but I have opted
to use a velocity vector because later I will be allowing for 
multiple emitters.
*/
class Emitter {
			public var myColor:uint;
		public var particles:Array;
  
		public var loc:Vec3D;
		public var vel:Vec3D;
		public var velToMouse:Vec3D;

		public function Emitter() {
			loc        = new Vec3D();
			vel        = new Vec3D();
			velToMouse = new Vec3D();
			
			myColor    = 0xFFFFFF;
			
			particles  = new Array();
		}

		public function exist( mouseX:Number, mouseY:Number ):void {
			velToMouse.set( mouseX - loc.x, mouseY - loc.y, 0 );
			vel.interpolateToSelf( velToMouse, .35 );
			loc.addSelf( vel );

			if( Renderer.ALLOWFLOOR ){
				if( loc.y > Renderer.floorLevel ){
					loc.y = Renderer.floorLevel;
					vel.y = 0;
				}
			}

			for ( var i:int = 0, l:int = particles.length; i < l; ++i ) {
				var p:Particle = particles[i];
				if ( !p.ISDEAD ) {
					p.exist();
				} else {
					particles.splice( i, 1 );
					--i;
					--l;
				}
			}

			Renderer.renderImage( Renderer.emitterImg, loc, 1.5, myColor, 1.0 );

			if( Renderer.ALLOWTRAILS )
				iterateListRenderTrails();
		}

		public function iterateListRenderTrails():void {
			for each( var p:Particle in particles ){
				p.renderTrails();
			}
		}

		public function addParticles( amount:int ):void{
			for( var i:int=0; i<amount; i++ ){
				particles.push( new Particle( loc, vel ) );
			}
		}
}
/*
General Structure notes.
My classes tend to have a similar naming scheme and flow. I start with the 'exist' method.
Exist is what an object needs to do every frame. Usually 'existing' consists of four main things.
1) Find the velocity. This involves determining what influences there are on the velocity.
2) Apply the velocity to the location.
3) Render the object.
4) Age the object.

I also use the metaphor of aging and death. When first made, a particle's age will be zero.
Every frame, the age will increment. If the age reaches the lifeSpan (which is a random number
that I set in the constructor), then the boolean ISDEAD is set to true and the arraylist iterator
removes the dead element from the list.
*/

class Particle {

		public var len:int;            // number of elements in position array
		public var loc:Array = [];         // array of position vectors
		public var startLoc:Vec3D;     // just used to make sure every loc[] is initialized to the same position
		public var vel:Vec3D;          // velocity vector
		public var perlin:Vec3D;       // perlin noise vector
		public var radius:Number;       // particle's size
		public var age:Number;          // current age of particle
		public var lifeSpan:int ;      // max allowed age of particle
		public var agePer:Number;       // range from 1.0 (birth) to 0.0 (death)
		public var bounceAge:int;    // amount to age particle when it bounces off floor
		public var ISDEAD:Boolean = false;     // if age == lifeSpan, make particle die
		public var ISBOUNCING:Boolean; // if particle hits the floor...

		public function Particle( _loc:Vec3D, _vel:Vec3D ) {
			radius      = Math.round( Math.random() * 20 + 10 );
			len         = radius;

			// This confusing-looking line does three things at once.
			// First, you make a random vector.
			// new Vec3D().randomVector()
			// Next, you multiply that vector by a random number from 0.0 to 5.0.
			// scaleSelf( 5.0 );
			// Finally, you add this new vector to the original sent vector.
			// _loc.add( );
			// This is just a way to make sure all the particles made this frame
			// don't all start on the exact same pixel. This staggering will be useful
			// when we incorporate magnetic repulsion in a later tutorial.
			startLoc    = _loc.add( new Vec3D().randomVector().scaleSelf( Math.random()*5.0 -2.5) ).clone(); 

			for( var i:int=0; i<len; i++ ){
			  loc[i]    = startLoc.clone();
			}


			// This next confusing-looking line does four things.
			// 1) Make a random vector.
			// new Vec3D().randomVector()
			//
			// 2) Multiply that vector by a random number from 0.0 to 10.0.
			// scaleSelf( 15.0 )
			//
			// 3) Scale down the original sent velocity just to calm things down a bit.
			// _vel.scale( .5 )
			//
			// 4) Add this new vector to the scaled down original sent vector.
			// addSelf( )
			//
			// This randomizes the original sent velocity so the particles
			// dont all move at the same speed in the same direction.
			vel         = _vel.scale( .5 ).addSelf( new Vec3D().randomVector().scaleSelf( Math.random()*10.0 -5 ) ).clone();

			perlin      = new Vec3D();

			age         = 0;
			bounceAge   = 2;
			lifeSpan    = radius as int;
		}

		public function exist():void {
			if( Renderer.ALLOWPERLIN )
				findPerlin();

			findVelocity();
			setPosition();
			render();
			setAge();
		}
  
		public function findPerlin():void {
			var xyRads:Number = Renderer.getRads( loc[0].x, loc[0].z, 10.0, 20.0 );
			var yRads:Number  = Renderer.getRads( loc[0].x, loc[0].y, 10.0, 20.0 );
			perlin.set( Math.cos(xyRads), -Math.sin(yRads), Math.sin(xyRads) );
			perlin.scaleSelf( .5 );
		}
		
		public function findVelocity():void {
			if( Renderer.ALLOWGRAVITY )
				vel.addSelf( Renderer.gravity );

			if( Renderer.ALLOWPERLIN )
				vel.addSelf( perlin );

			if( Renderer.ALLOWFLOOR ){
				if( loc[0].y + vel.y > Renderer.floorLevel ){
					ISBOUNCING = true;
				} else {
					ISBOUNCING = false;
				}
			}

			if( ISBOUNCING ){
				vel.scaleSelf( .75 );
				vel.y *= -.5;
			}
		}

		public function setPosition():void {
			// Every frame, the current location will be passed on to
			// the next element in the location array. Think 'cursor trail effect'.
			for ( var i:int = len - 1; i > 0; i-- ) {
				var v:Vec3D = loc[i - 1];
				loc[i].set( v.x, v.y, v.z );
			}

			// Set the initial location.
			// loc[0] represents the current position of the particle.
			loc[0].addSelf( vel );
		}

		public function render():void {
			// As the particle ages, it will gain blue but will lose red and green.
			var c:uint =  Math.round(agePer*0xFF) << 16 | Math.round(agePer * .75 * 0xFF) << 8 | Math.round(( 1.0 - agePer ) * 0xFF);
			Renderer.renderImage( Renderer.particleImg, loc[0], radius*agePer*0.01, c, 1.0 );
		}

		public function renderTrails():void {
			var xp:Number, yp:Number, zp:Number;
			var xOff:Number, yOff:Number, zOff:Number;

			var total:Number = Number(len) - 1;
			var verteics:Array = [];
			for ( var i:Number=0; i<len - 1; i++ ){
				var per:Number     = 1.0 - i / total;
				xp            = loc[i].x;
				yp            = loc[i].y;
				zp            = loc[i].z;

				if ( i < len - 2 ){
					// Okay, here is some vector craziness that I probably cant explain very well.
					// This is one of those things that I was taught and though I can picture in my mind
					// what the following 4 lines of code does, I doubt I can explain it.  In short,
					// I am using the cross product (wikipedia it) of the vector between adjacent
					// location array elements (perp0), and finding two vectors that are at right angles to 
					// it (perp1 and perp2). I then use perp1 to allow me to draw a ribbon with controllable
					// widths.
					// 
					// It's much more useful when dealing with a 3D space and a rotating camera. Think of it
					// like this. These trails are meant to function like motion blurs rather than dragged ribbons.
					// A dragged ribbon can be observed at different angles which would make its width fluctuate.
					// You can view it side-on and it would be incredibly thin but you can also view it top-down
					// and you would see its full width. I don't want this effect for the trails so I need to
					// make sure I am always looking at them top-down. So no matter where the camera is, I will
					// always see the ribbons with their width oriented to the camera. The one change I made for
					// this particular piece of source which has no camera object is I have replaced the eyeNormal
					// (which would be the vector pointing from ribbon towards camera) with a generic Vec3D(0, 1, 0).
					// Why? Well cause it works and thats enough for me. WHEE!
					var perp0:Vec3D = loc[i].sub( loc[i + 1] );
					var perp1:Vec3D = perp0.cross( new Vec3D( 0, 1, 0 ) ).normalize();
					var perp2:Vec3D = perp0.cross( perp1 ).normalize();
					perp1 = perp0.cross( perp2 ).normalize();

					xOff        = perp1.x * radius * agePer * per * .1;
					yOff        = perp1.y * radius * agePer * per * .1;
					zOff        = perp1.z * radius * agePer * per * .1;

					var color:uint = Math.round( per * .5 * 0xFF ) << 24 | Math.round( per * 0xFF ) << 16 | Math.round( per * .25 * 0xFF ) << 8 | Math.round( (1.0 - per) * 0xFF );
					verteics.push( color, new Vec3D( xp - xOff, yp - yOff, zp - zOff ), new Vec3D( xp + xOff, yp + yOff, zp + zOff ) );
				}
			}

			Renderer.renderTails( verteics );
			//gl.glEnd();
		}
  
		public function setAge():void {

			if( Renderer.ALLOWFLOOR ){
				if( ISBOUNCING ){
					age += bounceAge;
					bounceAge++;
				} else {
					age += 0.35;
				}
			} else {
				age ++;
			}

			if( age > lifeSpan ){
				ISDEAD = true;
			} else {
				// When spawned, the agePer is 1.0.
				// When death occurs, the agePer is 0.0.
				var a :Number = Number(Number(age) / Number(lifeSpan));
				agePer = 1.0 - a;
			}
		}
}

class Vec3D {

	public var x:Number;
	public var y:Number;
	public var z:Number;
	public function Vec3D( x:Number=0.0, y:Number=0.0, z:Number=0.0 ) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	public function normalize():Vec3D {
		var dx:Number = x * x;
		var dy:Number = y * y;
		var dz:Number = z * z;
			
		var magnitude:Number = Math.sqrt( dx + dy + dz );
			
		var nx:Number = x != 0 ? x / magnitude : 0;
		var ny:Number = y != 0 ? y / magnitude : 0;
		var nz:Number = z != 0 ? z / magnitude : 0;
		
		return new Vec3D( nx, ny, nz );
	}
	public function add( value :Vec3D ):Vec3D {
		return new Vec3D( x+value.x, y+value.y, z+value.z );
	}
	public function sub( value :Vec3D ):Vec3D {
		return new Vec3D( x-value.x, y-value.y, z-value.z );
	}
	public function cross( value :Vec3D ):Vec3D {
		return new Vec3D( y * value.z - z * value.y, z * value.x - x * value.z, x * value.y - y * value.x );
	}
	public function scale( value :Number ):Vec3D {
		return new Vec3D( x*value, y*value, z*value );
	}
	public function randomVector():Vec3D {
		x = Math.random();
		y = Math.random();
		z = Math.random();
		return this;
	}
	public function set( vx:Number, vy:Number, vz:Number ):Vec3D {
		x = vx;
		y = vy;
		z = vz;
		return this;
	}
	public function scaleSelf( value :Number ):Vec3D {
		x *= value;
		y *= value;
		z *= value;
		return this;
	}
	public function addSelf( value :Vec3D ):Vec3D {
		x += value.x;
		y += value.y;
		z += value.z;
		return this;
	}
	public function interpolateToSelf( value:Vec3D, scale:Number ):void {
		x = value.x * scale;
		y = value.y * scale;
		z = value.z * scale;
	}
	public function clone():Vec3D {
		return new Vec3D( x, y, z );
	}
	
	public function toString():String {
		return "[Vec3D] x="+x+", y="+y+", z=" + z;
	}
}

class MainDisplay extends Sprite {
	private var _renderer:Renderer;
	private var _canvas:BitmapData;

	public function MainDisplay(){
		addEventListener( Event.ADDED_TO_STAGE, init );
	}

	protected function init(e:Event):void{
		removeEventListener( Event.ADDED_TO_STAGE, init );

		stage.quality = StageQuality.LOW;
		_canvas = new BitmapData( stage.stageWidth, stage.stageHeight, false, 0x00 );
		addChild( new Bitmap(_canvas) );
		_renderer = new Renderer( _canvas );

		addEventListener( Event.ENTER_FRAME, onRender );
		
		var rect:Sprite = addChild( new Rect( _canvas.width, _canvas.height ) ) as Sprite;
		rect.alpha = 0;
		rect.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		rect.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler);

	}
	
	private function onMouseDown(e:MouseEvent):void {
		Renderer.mousePressed = true;
	}
	
	private function onMouseUp(e:MouseEvent):void {
		Renderer.mousePressed = false;
	}
	
	private function onRender(e:Event):void {
		Renderer.draw( mouseX, mouseY);
	}


	public function keyDownHandler( e:KeyboardEvent ):void {
		var key:String =  String.fromCharCode(e.charCode);
		trace( key );
		if( key == 'g' || key == 'G' )
			Renderer.ALLOWGRAVITY = !Renderer.ALLOWGRAVITY;

		if( key == 'p' || key == 'P' )
			Renderer.ALLOWPERLIN  = !Renderer.ALLOWPERLIN;

		if( key == 't' || key == 'T' )
			Renderer.ALLOWTRAILS  = !Renderer.ALLOWTRAILS;

		if( key == 'f' || key == 'F' )
			Renderer.ALLOWFLOOR   = !Renderer.ALLOWFLOOR;

	}


}


class Rect extends Sprite{

	public function Rect( w:Number,h:Number, c:uint=0xFF0000 ) {
		graphics.beginFill( c )
		graphics.drawRect( 0, 0, w, h );
		graphics.endFill();
	}

}


