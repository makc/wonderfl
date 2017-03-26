// forked from lizhi's 3d ccd pool
// forked from makc3d's ff[4]: ccd pool
// forked from makc3d's ff[3]: ccd pool
// forked from makc3d's ff[2]: ccd pool
// forked from lizhi's forked from: ccd pool
// forked from makc3d's ccd pool
// forked from makc3d's Continuous Collision w. Restitution
// forked from generalrelativity's Continuous Elastic Collision
package 
{
    
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.display.BitmapData;  
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Utils3D;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    import net.hires.debug.Stats;
    import flash.text.TextField;

    //[SWF(backgroundColor="#DDDDDD", frameRate=60, width=465, height=465)]
    public class CCDPool extends Sprite
    {
        
        private var simulator:Simulator;
        private var p2b:Vector.<BitmapData> = new Vector.<BitmapData>;
        private var p2n:Vector.<BitmapData> = new Vector.<BitmapData>;
        
        //3d
        private var camera:Matrix3D = new Matrix3D;
        private var wrapper:Matrix3D = new Matrix3D;
        private var project:Matrix3D = new PerspectiveProjection().toMatrix3D();
        private var focalLength:Number = project.rawData[0];
        private var force:flash.text.TextField = new flash.text.TextField;
        //3d end
        
        public function CCDPool()
        {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        public function init(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            // colors: http://en.wikipedia.org/wiki/Billiard_ball#International_pool
            var ball:Ball = new Ball;
            var tr:Number = 50;
            p2b[1 -1] = ball.createBallTexture (tr, 255, 255,   0);
            p2b[2 -1] = ball.createBallTexture (tr,   0,   0, 255);
            p2b[3 -1] = ball.createBallTexture (tr, 255,   0,   0);
            p2b[4 -1] = ball.createBallTexture (tr, 255,   0, 255);
            p2b[5 -1] = ball.createBallTexture (tr, 255, 127,   0);
            p2b[6 -1] = ball.createBallTexture (tr,   0, 255,   0);
            p2b[7 -1] = ball.createBallTexture (tr, 127,  63,   0);
            p2b[8 -1] = ball.createBallTexture (tr,   0,   0,   0);
            p2b[9 -1] = ball.createBallTexture (tr, 255, 255,   255);            
            
            for (var i:int = 1; i < 9; i++) {
                p2n[i -1] = ball.createNumberTexture (10, i);
            }
            
            initSimulation();
            
            addChild(new Stats);
            
            //3d init
            camera.appendTranslation(0, 0, -400);
            wrapper.appendRotation( -45, Vector3D.X_AXIS);
            addChild(force);
            force.autoSize = "left";
            force.x = 70;
            //3d init end
        }
        
        private function initSimulation() : void
        {
            
            simulator = new Simulator();
            
            simulator.addWall( new Wall(  40,  10, 425,  10 ) );
            simulator.addWall( new Wall( 455,  40, 455, 425 ) );
            simulator.addWall( new Wall( 425, 455,  40, 455 ) );
            simulator.addWall( new Wall(  10, 425,  10,  40 ) );
            
            simulator.addParticle( createParticle(232, 230, 0, 0, 1, 10 ) );
            
            for (var i:int = 0; i < 10; i++) {
                for (var j:int = 0; j < i; j++) {
                    var px:Number = 282 + 18 * i, py:Number = 240 + 21 * j - 10 * i;
                    simulator.addParticle (createParticle (px, py, 0, 0, 1, 10));
                    simulator.addParticle (createParticle (465 - px, py, 0, 0, 1, 10));
                }
            }
                        
            simulator.addEventListener( Simulator.STEP, onSimulationStep );
            simulator.run( this, Event.ENTER_FRAME );
            
            stage.addEventListener (MouseEvent.CLICK, onClick);
        }
        
        private function createParticle(xx:Number, xy:Number, vx:Number, vy:Number, mass:Number = 1.0, radius:Number = 5 ):Particle {
            var p:Particle = new Particle(xx, xy, vx, vy, mass, radius);
            return p;
        }
        
        private function onClick(e:MouseEvent):void 
        {
            var p:Particle = simulator.particles[0];
            var xy:Vector3D = getMousePos();
            if(xy)
            p.v = p.x.minus (new Vec2D (xy.x, xy.y)).times (Number(force.text));
        }
        
        private function onSimulationStep( event:Event ) : void
        {
            render();

            for (var i:int = 0, n:int = simulator.particles.length; i < n; i++) {
                var p:Particle = simulator.particles[i];
                if ((p.x.x < - p.r) || (p.x.y < -p.r) || (p.x.x > 465 + p.r) || (p.x.y > 465 + p.r)) {
                    simulator.particles.splice (i, 1); i--; n--;
                } else {
                    // linear friction
                    const f:Number = 0.1;
                    p.v.normalize (Math.max (0, p.v.magnitude - f));
                }
            }
            
            p = simulator.particles[0];
            
            graphics.lineStyle (Number(force.text), 255 * 65536, 0.1);
            var obj:Object = tp(p.x.x, p.x.y);
            var dx:Number = mouseX-obj.x;
            var dy:Number = mouseY-obj.y;
            var length:Number = Math.sqrt(dx*dx+dy*dy);
            graphics.moveTo (obj.x-dx/length*100, obj.y-dy/length*100);            
            graphics.lineTo (obj.x,obj.y);
        }
        
        private var matrix:Matrix = new Matrix;
        private var matrix2:Matrix = new Matrix;
        private var help:Matrix3D;
        private var help2:Matrix3D;
        private function tp(x:Number, y:Number,z:Number=0):Object {
            var obj3d:Object = { };
            var display:Matrix3D = new Matrix3D;
            display.appendTranslation(x - 465 / 2, y - 465 / 2, z);
            help.copyFrom(display);
            help.append(wrapper);
            help.append(help2);
            var v3d:Vector3D = new Vector3D;
            v3d = help.transformVector(v3d);
            obj3d.z = v3d.z;
            v3d = Utils3D.projectVector(project, v3d);
            obj3d.x =v3d.x+ 465 / 2;
            obj3d.y = v3d.y + 465 / 2;
            return obj3d;
        }
        
        private function getMousePos():Vector3D {
            var matrix:Matrix3D = new Matrix3D;
            matrix.copyFrom(wrapper);
            matrix.invert();
            matrix.prepend(camera);
            var p1:Vector3D = new Vector3D;
            p1 = matrix.transformVector(p1);
            var p2:Vector3D = new Vector3D(mouseX - 465 / 2, mouseY - 465 / 2,focalLength);
            p2 = matrix.transformVector(p2);
            p2 = p2.subtract(p1);
            var ret:Vector3D = calPlaneLineIntersectPoint(Vector3D.Z_AXIS, new Vector3D(), p2, p1);
            ret.x += 465 / 2;
            ret.y += 465 / 2;
            return ret;
        }
         
        /**
         * 求平面和直线的交点
         * http://blog.csdn.net/abcjennifer/article/details/6688080
         * @param    planeVector 平面的法线向量
         * @param    planePoint 平面经过的一点坐标
         * @param    lineVector 直线的方向向量
         * @param    linePoint 直线经过的一点坐标
         * @return 返回交点坐标
         */
        private function calPlaneLineIntersectPoint(planeVector:Vector3D,planePoint:Vector3D,lineVector:Vector3D,linePoint:Vector3D):Vector3D
        {
            var returnResult:Vector3D = new Vector3D;
            var vpt:Number = lineVector.x * planeVector.x + lineVector.y * planeVector.y + lineVector.z * planeVector.z;
            //首先判断直线是否与平面平行
            if (vpt == 0)
            {
                returnResult = null;
            }
            else
            {
                var t:Number = ((planePoint.x - linePoint.x) * planeVector.x + (planePoint.y - linePoint.y) * planeVector.y + (planePoint.z - linePoint.z) * planeVector.z) / vpt;
                returnResult.x = linePoint.x + lineVector.x * t;
                returnResult.y = linePoint.y + lineVector.y * t;
                returnResult.z = linePoint.z + lineVector.z * t;
            }
            return returnResult;
        }
        
        private function render() : void
        {
            force.text = "" + (int((Math.sin(getTimer() / 500.0 as Number )+1.0)*10));
            wrapper.identity();
            wrapper.appendRotation((-stage.stageHeight / 2 - mouseY)/5+45, Vector3D.X_AXIS);
            wrapper.appendRotation((-stage.stageWidth / 2 + mouseX)/5, Vector3D.Y_AXIS);
            help = new Matrix3D;
            help2 = new Matrix3D;
            help2.copyFrom(camera);
            help2.invert();
            
            graphics.clear();
            
            graphics.lineStyle( 1 );
            
            var wallobjs:Array = [];
            for each( var wall:Wall in simulator.walls )
            {
                var wallA:Object = tp(wall.A.x, wall.A.y,7);
                var wallB:Object = tp(wall.B.x,wall.B.y,7);
                var wallA2:Object = tp(wall.A.x, wall.A.y,-7);
                var wallB2:Object = tp(wall.B.x,wall.B.y,-7);
                graphics.moveTo(wallA.x, wallA.y);
                graphics.lineTo( wallA2.x,wallA2.y);
                graphics.lineTo( wallB2.x, wallB2.y );
                //graphics.lineTo( wallB2.x, wallB2.y );
                graphics.lineTo( wallB.x, wallB.y );
                //graphics.lineTo( wallB2.x, wallB2.y );
                wallobjs.push(wallA, wallB);
            }
            graphics.beginFill(0x50A050);
            graphics.moveTo(wallB.x, wallB.y);
            for each(var obj:Object in wallobjs) {
                graphics.lineTo(obj.x, obj.y);
            }
            graphics.endFill();
            
            graphics.lineStyle ();
            var particles:Array = [];
            var fill:BitmapData;
            for each( var particle:Particle in simulator.particles )
            {
                var obj3d:Object = tp(particle.x.x, particle.x.y);
                obj3d.p = particle;
                particles.push(obj3d);
                continue;
            }
            
            particles.sortOn("z", Array.NUMERIC | Array.DESCENDING);
            
            // TODO : draw shadow
            
            for each(obj3d in particles) {
                particle = obj3d.p;
                var perspR:Number=particle.r*focalLength/obj3d.z;
                var perspR2:Number=perspR*2;
                if (simulator.particles[0]==particle)
                    fill = p2b[9-1]; //white ball
                else
                    fill = p2b[particle.number];
                matrix.createBox(perspR2/fill.width, perspR2/fill.height, 0, obj3d.x - perspR, obj3d.y - perspR);
                graphics.beginBitmapFill (fill, matrix, true, true);
                graphics.drawRect (matrix.tx, matrix.ty, perspR2, perspR2);
                graphics.endFill ();
                
                // now the numbers are tricky
                // real angle depends on ball collision history
                // like the guy from 9ria.com, we shall not give a fuck
                var ir:Number = 1 / particle.r, ipr:Number = ir / Math.PI, ix:int, iy:int;

                var rx:Number = Math.cos (ir * particle.x.x);
                var ry:Number = Math.cos (ir * particle.x.y);

                // this fork attempts to better imitate balls with 2 numbers on them
                var r2:Number = rx * rx + ry * ry;
                if (r2 < 1) {
                    ix = ipr * particle.x.x;
                    iy = ipr * particle.x.y;
                } else {
                    rx = Math.sin (ir * particle.x.x);
                    ry = Math.sin (ir * particle.x.y);
                    r2 = rx * rx + ry * ry;
                    ix = ipr * particle.x.x + 1.5;
                    iy = ipr * particle.x.y + 1.5;
                }

                if (ix % 2 == 1) rx *= -1;
                if (iy % 2 == 1) ry *= -1;

                    var nxx:Number, nxy:Number, nyx:Number, nyy:Number;
                    nxx = 1 - rx * rx; nyx = 0 - rx * ry;
                    nxy = 0 - rx * ry; nyy = 1 - ry * ry;
                    
                    // some magic numbers to make it look better, as well as 0.92 below
                    nxx *= 1.2; nyx *= 1.2;
                    nxy *= 1.2; nyy *= 1.2;
                    
                    // now to the batmobile :)
                    matrix2.a = nxx; matrix2.c = nyx; matrix2.tx = particle.x.x - (0.5*(nxx+nyx)+0.92*rx)*perspR;
                    matrix2.b = nxy; matrix2.d = nyy; matrix2.ty = particle.x.y - (0.5*(nxy+nyy)+0.92*ry)*perspR;
                    fill = p2n[particle.number];

                    graphics.beginBitmapFill (fill, matrix2, false, r2 < 0.9);
                    graphics.drawRect (matrix.tx, matrix.ty, perspR2, perspR2);
                    graphics.endFill ();             
            }
            /*graphics.lineStyle (0, 0, 0.1);
            
            for each( particle in simulator.particles )
            {
                var po:Object = tp(particle.x.x, particle.x.y);
                graphics.moveTo (po.x, po.y);
                po = tp(particle.x.x + particle.v.x, particle.x.y + particle.v.y);
                graphics.lineTo (po.x,po.y);
            }*/
            
        }
        
    }
}




import flash.display.GradientType;
import flash.display.BitmapData;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getTimer;

//http://bbs.9ria.com/forum.php?mod=redirect&goto=findpost&ptid=161522&pid=1577947&fromuid=15322
class Ball extends Sprite{
    private var offset:Number = 0;
    public function createBallTexture(ballRadius:Number,r:int=-1,g:int=-1,b:int=-1):BitmapData {
        var matr:Matrix = new Matrix();
        matr.createGradientBox(ballRadius * 3, ballRadius * 3, 0, -ballRadius * 1.8, -ballRadius * 1.8);
        r = (r >= 0) ? r : 0xff * Math.random();
        g = (g >= 0) ? g : 0xff * Math.random();
        b = (b >= 0) ? b : 0xff * Math.random();
        graphics.beginGradientFill(GradientType.RADIAL, [r<<16|g<<8|b,(r/3)<<16|(g/3)<<8|(b/3)], [100, 100], [0x00, 0xFF], matr, SpreadMethod.PAD); 
        graphics.drawCircle(0,0,ballRadius);
        
        var bd:BitmapData = new BitmapData (Math.ceil(ballRadius)*2, Math.ceil(ballRadius)*2, true, 0);
        bd.draw (this, new Matrix (1,0,0,1, Math.ceil(ballRadius), Math.ceil(ballRadius)));
        
        graphics.clear();
        return bd;
    }
    public function createNumberTexture(ballRadius:int,number:int):BitmapData {
        var bd:BitmapData = new BitmapData(ballRadius, ballRadius, true, 0xff000000);
        
        graphics.beginFill(0xFFFFFF);
        graphics.drawCircle(ballRadius*0.5, ballRadius*0.5, ballRadius*0.4);
        
        bd.draw (this);
        
        var tfd:TextField = new TextField; tfd.autoSize = "left";
        var tft:TextFormat = tfd.defaultTextFormat; tft.size = 8; tfd.defaultTextFormat = tft;
        tfd.text = number.toString ();
        bd.draw (tfd, new Matrix (1,0,0,1, 0.5*(ballRadius - tfd.width), 0.5*(ballRadius - tfd.height + 1)));
        
        // green -> alpha (green seems to survive "cleartype" better)
        bd.copyChannel(bd, bd.rect, bd.rect.topLeft, 2, 8);
        
        graphics.clear();
        return bd;
    }
}
    
[Event(name="step", type="Simulator")]


class Simulator extends EventDispatcher
{
    
    public static const STEP:String = "step";
    
    public var particles:Vector.<Particle>;
    public var walls:Vector.<Wall>;
    
    //holds all the pairs that passed coarse collision detection
    private var coarsePass:Vector.<ICollidablePair>;
    
    private var time:uint;
    
    
    public function Simulator()
    {
        
        super();
        
        particles = new Vector.<Particle>();
        walls = new Vector.<Wall>();
        
    }
    
    
    public function addParticle( particle:Particle ) : void
    {
        particles.push( particle );
    }
    
    
    public function addWall( wall:Wall ) : void
    {
        walls.push( wall );
    }
    
    
    //advances the simulation at each dispatch of the passed event type
    public function run( updateDispatcher:EventDispatcher, eventType:String = Event.ENTER_FRAME ) : void
    {
        time = getTimer();
        updateDispatcher.addEventListener( eventType, step, false, 0, true );
    }
    
    
    //advances the simulation by the amount of time that has passed since the last step
    private function step( event:Event ) : void
    {
        
        const MAX_ITERATIONS:uint = 100;
        
        //delta time in milliseconds
        var dtms:uint = getTimer() - time;
        
        //delta time in seconds
        var elapsed:Number = dtms / 1000;
        
        //start this step at 0 and advance to elapsed
        var t:Number = 0;
        
        var dt:Number;
        var iteration:uint;
        
        while( t < elapsed && ++iteration <= MAX_ITERATIONS )
        {
            
            //start by trying to step over the entire remainder
            dt = elapsed - t;
            
            //neglect pairs whose bounding boxes don't overlap
            doCoarsePhase( dt );
            
            //holds the next future collision
            var minPair:ICollidablePair = null;
            var minT:Number = Number.POSITIVE_INFINITY;
            
            for each( var pair:ICollidablePair in coarsePass )
            {
                
                //if the collision will happen within the current time-step
                //compare the time against the current minimum
                if( pair.willCollide( dt ) )
                {
                    
                    //if it's less, store it as the min and proceed
                    if( pair.timeToCollision < minT )
                    {
                        minT = pair.timeToCollision;
                        minPair = pair;
                    }
                    
                }
                
            }
            
            //change the actual time to integrate
            if( minT < Number.POSITIVE_INFINITY ) dt = minT;
            
            //update the simulation to the time of collision
            for each( var particle:Particle in particles )
            {
                particle.integrate( dt - 1e-8 );
            }
            
            //resolve the collision instantaneously
            if( minPair != null )
            {
                minPair.resolve();
            }
            
            //update time by the stepped amount
            t += dt;
            
        }
        
        time += dtms;
        
        dispatchEvent( new Event( Simulator.STEP ) );
        
    }
    
    
    //rules out some unnecessary collision checks
    private function doCoarsePhase( dt:Number ) : void
    {
        
        coarsePass = new Vector.<ICollidablePair>();
        
        var aabb:AABB;
        
        for each( var particle:Particle in particles )
        {
            
            //update the particle's bounding box to account for its velocity
            particle.update( dt );
            aabb = particle.aabb;
            
            //check each particle against each wall
            for each( var wall:Wall in walls )
            {
                
                if( aabb.isOverlapping( wall.aabb ) )
                {
                    coarsePass.push( new ParticleWallPair( particle, wall ) );
                }
                
            }
            
        }
        
        var n:int = particles.length;
        
        //check each particle against each other
        for( var i:int = 0; i < n - 1; i++ )
        {
            
            var p1:Particle = particles[ i ];
            aabb = p1.aabb;
            
            for( var j:int = i + 1; j < n; j++ )
            {
                
                var p2:Particle = particles[ j ];
                
                if( aabb.isOverlapping( p2.aabb ) ) 
                {
                    coarsePass.push( new ParticleParticlePair( p1, p2 ) );
                }
                
            }
            
        }
        
    }
    
}




//describes a common interface for collision pairs 
interface ICollidablePair
{
    
    function get timeToCollision() : Number;
    
    function willCollide( dt:Number ) : Boolean;
    function resolve() : void;
    
}




class ParticleParticlePair implements ICollidablePair
{
    
    public var p1:Particle;
    public var p2:Particle;
    
    private var t:Number;
    
    public function ParticleParticlePair( p1:Particle, p2:Particle )
    {
        this.p1 = p1;
        this.p2 = p2;
    }
    
    public function get timeToCollision() : Number
    {
        return t;
    }
    
    
    public function willCollide( dt:Number ) : Boolean
    {
        
        const EPSILON:Number = 1e-4;
        
        //points from 1 -> 2
        var dx:Vec2D = p2.x.minus( p1.x );
        
        //if the circle's are already overlapped, return true (this brings the sim to a halt)
        var c:Number = dx.dot( dx ) - ( p1.r + p2.r ) * ( p1.r + p2.r );
        if( c < 0 )
        {
            t = EPSILON;
            return true;
        }
        
        //relative velocity
        var dv:Vec2D = p2.v.minus( p1.v );
        
        var a:Number = dv.dot( dv );
        if( a < EPSILON ) return false; //not moving enough toward each other to warrant a response
        
        var b:Number = dv.dot( dx );
        if( b >= 0 ) return false; //moving apart
        
        var d:Number = b * b - a * c;
        if( d < 0 ) return false; //no intersection
        
        t = ( -b - Math.sqrt( d ) ) / a;
        
        //circle's collide if the time of collision is within the current time-step
        return t <= dt;

    }
    
    //simulation has been updated so that the particles are just colliding
    public function resolve() : void
    {
        
        //points from 1 -> 2
        var cn:Vec2D = p2.x.minus( p1.x );
        
        cn.normalize();
        
        //relative velocity
        var dv:Vec2D = p2.v.minus( p1.v );
        
        //perfectly elastic impulse
        var impulse:Number = cn.dot( dv.times( -2 ) ) / cn.dot( cn.times( 1 / p1.mass + 1 / p2.mass ) );
        
        //scale normal by the impulse
        p1.v.plusEquals( cn.times( -impulse / p1.mass ) );
        p2.v.plusEquals( cn.times(  impulse / p2.mass ) );
        
        //damping
        p1.v.x *= p1.restitution;
        p1.v.y *= p1.restitution;
        p2.v.x *= p2.restitution;
        p2.v.y *= p2.restitution;
    }

    
}





class ParticleWallPair implements ICollidablePair
{
    
    public var p:Particle;
    public var w:Wall;
    
    private var t:Number;
    
    public function ParticleWallPair( p:Particle, w:Wall )
    {
        
        this.p = p;
        this.w = w;
        
    }
    
    public function get timeToCollision() : Number
    {
        return t;
    }
    
             
    public function willCollide( dt:Number ) : Boolean
    {
        
        //this is line/line intersection
        
        //A is the position of the particle
        //B is the position + velocity
        //together they make the segment AB
        
        //CD is the line segment made up of the wall's end points
        
        var A:Vec2D = p.x;
        var B:Vec2D = p.x.plus( p.v );
        
        var AB:Vec2D = B.minus( A );
        
        //inflate the normal by the particle's radius
        var normScaledRadius:Vec2D = w.normal.times( -p.r );
        
        //push the wall segment in by this amount
        var C:Vec2D = w.A.plus( normScaledRadius );
        var D:Vec2D = w.B.plus( normScaledRadius );
        
        var CD:Vec2D = D.minus( C )
        var AC:Vec2D = C.minus( A );
        
        t = w.normal.dot( AC ) / w.normal.dot( AB );
        
        if( isNaN( t ) ) t = 0;
        
        var couldCollide:Boolean = (t <= dt) && (t >= 0);
        // the above is very "approximate" collision test
        // let's try to refine it checking particle position
        // at the time of supposed collision
        if (couldCollide) {
            // A <- future particle position
            A = p.x.plus (p.v.times (t));
            // see if it projects into the wall along its normal
            AC = A.minus (C);
            // CD should have been called DC :)
            var m:Number = CD.magnitude;
            var dot:Number = AC.dot (CD.times (1 / m));
            if((dot < 0) || (dot > m)) {
                // collision is unlikely
                return false;
            }
        }
        
        return couldCollide;
    }
    
    //simulation has been updated so that the particles are coincident
    public function resolve() : void
    {
                
        var cn:Vec2D = w.normal;        
                        
        //relative velocity
        var dv:Vec2D = p.v;
        
        //perfectly elastic
        var impulse:Number = cn.dot( dv.times( -2 ) ) / ( 1 / p.mass );
        
        p.v.plusEquals( cn.times( impulse / p.mass ) );
        
        //damping
        p.v.x *= p.restitution;
        p.v.y *= p.restitution;
    }
    
}





class Wall
{
    
    public var A:Vec2D;
    public var B:Vec2D;
    
    public var aabb:AABB;
    
    public var normal:Vec2D;
    
    public function Wall( ax:Number, ay:Number, bx:Number, by:Number ) 
    {
        
        A = new Vec2D( ax, ay );
        B = new Vec2D( bx, by );
        
        normal = new Vec2D( B.y - A.y, -( B.x - A.x ) );
        normal.normalize();
        
        aabb = new AABB();
        
        aabb.minx = Math.min( ax, bx );
        aabb.maxx = Math.max( ax, bx );
        aabb.miny = Math.min( ay, by );
        aabb.maxy = Math.max( ay, by );
        
    }
    
}


class Particle
{
    public var number:uint;

    public var restitution:Number = 0.7;
    
    //position
    public var x:Vec2D;
    
    //velocity
    public var v:Vec2D;
    
    public var mass:Number;
    
    //radius
    public var r:Number;
    
    //bounding box
    public var aabb:AABB;
    
    public function Particle( xx:Number, xy:Number, vx:Number, vy:Number, mass:Number = 1.0, radius:Number = 5 )
    {
        number = Math.random () * 8; number %= 8; // solids + 8th ball
        
        x = new Vec2D( xx, xy );
        v = new Vec2D( vx, vy );
        
        this.mass = mass;
        this.r = radius;
        
        aabb = new AABB();
        
    }
    
    public function update( t:Number ) : void
    {
        
        var xt:Number = x.x + v.x * t;
        var yt:Number = x.y + v.y * t;
        
        var minx:Number = Math.min( x.x, xt );
        var maxx:Number = Math.max( x.x, xt );
        
        var miny:Number = Math.min( x.y, yt );
        var maxy:Number = Math.max( x.y, yt );
        
        aabb.minx = minx - r;
        aabb.maxx = maxx + r;
        aabb.miny = miny - r;
        aabb.maxy = maxy + r;
        
    }
    
    public function integrate( dt:Number ) : void
    {
        x.x += v.x * dt;
        x.y += v.y * dt;
    }
    
}


class AABB
{
    
    public var minx:Number = 0;
    public var maxx:Number = 0;
    public var miny:Number = 0;
    public var maxy:Number = 0;
    
    public function isOverlapping( aabb:AABB ) : Boolean
    {
        
        if( minx > aabb.maxx ) return false;
        if( miny > aabb.maxy ) return false;
        if( maxx < aabb.minx ) return false;
        if( maxy < aabb.miny ) return false;
        
        return true;
        
    }
    
}


class Vec2D
{
    
    public var x:Number;
    public var y:Number;
    
    public function Vec2D( x:Number = 0.0, y:Number = 0.0 )
    {
        this.x = x;
        this.y = y;
    }
    
    public function plusEquals( vec2D:Vec2D ) : void
    {
        x += vec2D.x;
        y += vec2D.y;
    }
    
    public function plus( vec2D:Vec2D ) : Vec2D
    {
        return new Vec2D( x + vec2D.x, y + vec2D.y );
    }
    
    public function minus( vec2D:Vec2D ) : Vec2D
    {
        return new Vec2D( x - vec2D.x, y - vec2D.y );
    }
    
    public function times( s:Number ) : Vec2D
    {
        return new Vec2D( x * s, y * s );
    }
    
    public function dot( vec2D:Vec2D ) : Number
    {
        return x * vec2D.x + y * vec2D.y;
    }
    
    public function get magnitude() : Number
    {
        return Math.sqrt( x * x + y * y );
    }
    
    public function normalize(v : Number = 1) : void
    {
        
        var length:Number = magnitude;
        
        if( length == 0 ) return;
        
        x *= v / length;
        y *= v / length;
        
    }
    
}