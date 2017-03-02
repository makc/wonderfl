/**
 * Box2 Lite in ActionScript 3.
 * (ported by nitoyon)
 * 
 * "Box2D Lite" is first release of Box2d.
 * Much simpler than current version of Box2d.
 * 
 * How to Use:
 *-------------------------------------------------------------
 * 1～9:  Change demo
 * Space: Launch bomb
 *-------------------------------------------------------------
 *
 * Original Code Copyright:
 *-------------------------------------------------------------
 * Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
 *
 * Permission to use, copy, modify, distribute and sell this software
 * and its documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies.
 * Erin Catto makes no representations about the suitability 
 * of this software for any purpose.  
 * It is provided "as is" without express or implied warranty.
 */
package{
    import flash.display.*;
    import flash.events.*;
    import flash.ui.Keyboard;

    [SWF(frameRate="30")]
    public class Box2dLite extends Sprite{
        private var bodies:Vector.<Body>;
        private var joints:Vector.<Joint>;

        private var bomb:Body;

        private var timeStep:Number = 1.0 / 30.0;
        private var iterations:int = 10;
        private var gravity:Vec2 = new Vec2(0.0, -10.0);

        private var demoIndex:int = 0;

        private var world:World = new World(gravity, iterations);

        private var demos:Array = [demo1, demo2, demo3, demo4, demo5, demo6, demo7, demo8, demo9];

        public static const W:Number = 200;
        public static const H:Number = 300;
        public static const SCALE:Number = 20;

        public function Box2dLite(){
            stage.scaleMode = "noScale";
            stage.align = "TL";
            GraphicsCache.g = graphics;

            initDemo(2);
            simulationLoop();
            addEventListener("enterFrame", function(event:*):void { simulationLoop(); });
            stage.addEventListener("keyDown", function(event:KeyboardEvent):void{
                if (event.charCode >= 49 && event.charCode - 49 < demos.length){
                    initDemo(event.charCode - 49);
                } else if (event.keyCode == Keyboard.RIGHT) {
                    initDemo((demoIndex + 1) % demos.length);
                } else if (event.keyCode == Keyboard.LEFT) {
                    initDemo((demoIndex - 1 + demos.length) % demos.length);
                } else if (event.charCode == 32){
                    launchBomb();
                }
            });
        }

        private function initDemo(index:int):void{
            world.clear();
            bomb = null;

            demoIndex = index;
            demos[index]();
        }

        private function demo1():void{
            bodies = new Vector.<Body>();
            joints = new Vector.<Joint>();

            var b:Body = new Body();
            b.set(new Vec2(100.0, 20.0), Number.MAX_VALUE);
            b.position.set(0.0, -0.5 * b.width.y);
            bodies.push(b);
            world.addBody(b);

            b = new Body();
            b.set(new Vec2(1.0, 1.0), 200.0);
            b.position.set(0.0, 4.0);
            bodies.push(b);
            world.addBody(b);
        }

        private function demo2():void{
            bodies = new Vector.<Body>();
            joints = new Vector.<Joint>();

            var b1:Body = new Body();
            b1.set(new Vec2(100.0, 20.0), Number.MAX_VALUE);
            b1.friction = 0.2;
            b1.position.set(0.0, -0.5 * b1.width.y);
            b1.rotation = 0.0;
            bodies.push(b1);
            world.addBody(b1);

            var b2:Body = new Body();
            b2.set(new Vec2(1.0, 1.0), 100.0);
            b2.friction = 0.2;
            b2.position.set(9.0, 11.0);
            b2.rotation = 0.0;
            bodies.push(b2);
            world.addBody(b2);

            var j:Joint = new Joint();
            j.set(b1, b2, new Vec2(0.0, 11.0));
            joints.push(j);
            world.addJoint(j);
        }

        private function demo3():void{
            bodies = new Vector.<Body>();
            joints = new Vector.<Joint>();

            var b:Body = new Body();
            b.set(new Vec2(100.0, 20.0), Number.MAX_VALUE);
            b.position.set(0.0, -0.5 * b.width.y);
            bodies.push(b);
            world.addBody(b);

            b = new Body();
            b.set(new Vec2(13.0, 0.25), Number.MAX_VALUE);
            b.position.set(-2.0, 11.0);
            b.rotation = -0.25;
            bodies.push(b);
            world.addBody(b);

            b = new Body();
            b.set(new Vec2(0.25, 1.0), Number.MAX_VALUE);
            b.position.set(5.25, 9.5);
            bodies.push(b);
            world.addBody(b);

            b = new Body();
            b.set(new Vec2(13.0, 0.25), Number.MAX_VALUE);
            b.position.set(2.0, 7.0);
            b.rotation = 0.25;
            bodies.push(b);
            world.addBody(b);

            b = new Body();
            b.set(new Vec2(0.25, 1.0), Number.MAX_VALUE);
            b.position.set(-5.25, 5.5);
            bodies.push(b);
            world.addBody(b);

            b = new Body();
            b.set(new Vec2(13.0, 0.25), Number.MAX_VALUE);
            b.position.set(-2.0, 3.0);
            b.rotation = -0.25;
            bodies.push(b);
            world.addBody(b);

            var friction:Array = [0.75, 0.5, 0.35, 0.1, 0.0];
            for (var i:int = 0; i < 5; ++i){
                b = new Body();
                b.set(new Vec2(0.5, 0.5), 25.0);
                b.friction = friction[i];
                b.position.set(-7.5 + 2.0 * i, 14.0);
                bodies.push(b);
                world.addBody(b);
            }
        }

        // A vertical stack
        private function demo4():void{
            bodies = new Vector.<Body>();
            joints = new Vector.<Joint>();

            var b:Body = new Body();
            b.set(new Vec2(100.0, 20.0), Number.MAX_VALUE);
            b.friction = 0.2;
            b.position.set(0.0, -0.5 * b.width.y);
            b.rotation = 0.0;
            bodies.push(b);
            world.addBody(b);

            for (var i:int = 0; i < 10; ++i){
                b = new Body();
                b.set(new Vec2(1.0, 1.0), 1.0);
                b.friction = 0.2;
                var x:Number = Math.random() * 0.2 - 0.1;
                b.position.set(x, 0.51 + 1.05 * i);
                bodies.push(b);
                world.addBody(b);
            }
        }

        // A pyramid
        private function demo5():void{
            bodies = new Vector.<Body>();
            joints = new Vector.<Joint>();

            var b:Body = new Body();
            b.set(new Vec2(100.0, 20.0), Number.MAX_VALUE);
            b.friction = 0.2;
            b.position.set(0.0, -0.5 * b.width.y);
            b.rotation = 0.0;
            bodies.push(b);
            world.addBody(b);

            var x:Vec2 = new Vec2(-6.0, 0.75);
            var y:Vec2 = new Vec2();

            for (var i:int = 0; i < 12; ++i){
                y = x;

                for (var j:int = i; j < 12; ++j){
                    b = new Body();
                    b.set(new Vec2(1.0, 1.0), 10.0);
                    b.friction = 0.2;
                    b.position = y;
                    bodies.push(b);
                    world.addBody(b);

                    y = y.add(new Vec2(1.125, 0.0));
                }

                //x += Vec2(0.5625, 1.125);
                x = x.add(new Vec2(0.5625, 2.0));
            }
        }

        // A teeter
        private function demo6():void{
            bodies = new Vector.<Body>();
            joints = new Vector.<Joint>();

            var b1:Body = new Body();
            b1.set(new Vec2(100.0, 20.0), Number.MAX_VALUE);
            b1.position.set(0.0, -0.5 * b1.width.y);
            bodies.push(b1);
            world.addBody(b1);

            var b2:Body = new Body();
            b2.set(new Vec2(12.0, 0.25), 100.0);
            b2.position.set(0.0, 1.0);
            bodies.push(b2);
            world.addBody(b2);

            var b3:Body = new Body();
            b3.set(new Vec2(0.5, 0.5), 25.0);
            b3.position.set(-5.0, 2.0);
            bodies.push(b3);
            world.addBody(b3);

            var b4:Body = new Body();
            b4.set(new Vec2(0.5, 0.5), 25.0);
            b4.position.set(-5.5, 2.0);
            bodies.push(b4);
            world.addBody(b4);

            var b5:Body = new Body();
            b5.set(new Vec2(1.0, 1.0), 100.0);
            b5.position.set(5.5, 15.0);
            bodies.push(b5);
            world.addBody(b5);

            var j:Joint = new Joint();
            j.set(b1, b2, new Vec2(0.0, 1.0));
            joints.push(j);
            world.addJoint(j);
        }

        // A suspension bridge
        private function demo7():void{
            bodies = new Vector.<Body>();
            joints = new Vector.<Joint>();

            var b:Body = new Body();
            b.set(new Vec2(100.0, 20.0), Number.MAX_VALUE);
            b.friction = 0.2;
            b.position.set(0.0, -0.5 * b.width.y);
            b.rotation = 0.0;
            bodies.push(b);
            world.addBody(b);

            var numPlanks:int = 15;
            var mass:Number = 50.0;

            for (var i:int = 0; i < numPlanks; ++i){
                b = new Body();
                b.set(new Vec2(1.0, 0.25), mass);
                b.friction = 0.2;
                b.position.set(-8.5 + 1.25 * i, 5.0);
                bodies.push(b);
                world.addBody(b);
            }

            // Tuning
            var frequencyHz:Number = 2.0;
            var dampingRatio:Number = 0.7;

            // frequency in radians
            var omega:Number = 2.0 * Math.PI * frequencyHz;

            // damping coefficient
            var d:Number = 2.0 * mass * dampingRatio * omega;

            // spring stifness
            var k:Number = mass * omega * omega;

            // magic formulas
            var softness:Number = 1.0 / (d + timeStep * k);
            var biasFactor:Number = timeStep * k / (d + timeStep * k);

            for (i = 0; i < numPlanks; ++i){
                var j:Joint = new Joint();
                j.set(bodies[i], bodies[i+1], new Vec2(-9.125 + 1.25 * i, 5.0));
                j.softness = softness;
                j.biasFactor = biasFactor;

                joints.push(j);
                world.addJoint(j);
            }

            j = new Joint();
            j.set(bodies[numPlanks], bodies[0], new Vec2(-9.125 + 1.25 * numPlanks, 5.0));
            j.softness = softness;
            j.biasFactor = biasFactor;
            joints.push(j);
            world.addJoint(j);
        }

        // Dominos
        private function demo8():void{
            bodies = new Vector.<Body>();
            joints = new Vector.<Joint>();

            var b1:Body = new Body();
            var b:Body = b1;
            b.set(new Vec2(100.0, 20.0), Number.MAX_VALUE);
            b.position.set(0.0, -0.5 * b.width.y);
            bodies.push(b);
            world.addBody(b);

            b = new Body();
            b.set(new Vec2(12.0, 0.5), Number.MAX_VALUE);
            b.position.set(-1.5, 10.0);
            bodies.push(b);
            world.addBody(b);

            for (var i:int = 0; i < 10; ++i){
                b = new Body();
                b.set(new Vec2(0.2, 2.0), 10.0);
                b.position.set(-6.0 + 1.0 * i, 11.125);
                b.friction = 0.1;
                bodies.push(b);
                world.addBody(b);
            }

            b = new Body();
            b.set(new Vec2(14.0, 0.5), Number.MAX_VALUE);
            b.position.set(1.0, 6.0);
            b.rotation = 0.3;
            bodies.push(b);
            world.addBody(b);

            var b2:Body = b = new Body();
            b.set(new Vec2(0.5, 3.0), Number.MAX_VALUE);
            b.position.set(-7.0, 4.0);
            bodies.push(b);
            world.addBody(b);

            var b3:Body = b = new Body();
            b.set(new Vec2(12.0, 0.25), 20.0);
            b.position.set(-0.9, 1.0);
            bodies.push(b);
            world.addBody(b);

            var j:Joint = new Joint();
            j.set(b1, b3, new Vec2(-2.0, 1.0));
            joints.push(j);
            world.addJoint(j);

            var b4:Body = b = new Body();
            b.set(new Vec2(0.5, 0.5), 10.0);
            b.position.set(-10.0, 15.0);
            bodies.push(b);
            world.addBody(b);

            j = new Joint();
            j.set(b2, b4, new Vec2(-7.0, 15.0));
            joints.push(j);
            world.addJoint(j);

            var b5:Body = b = new Body();
            b.set(new Vec2(2.0, 2.0), 20.0);
            b.position.set(6.0, 2.5);
            b.friction = 0.1;
            bodies.push(b);
            world.addBody(b);

            j = new Joint();
            j.set(b1, b5, new Vec2(6.0, 2.6));
            joints.push(j);
            world.addJoint(j);

            var b6:Body = b = new Body();
            b.set(new Vec2(2.0, 0.2), 10.0);
            b.position.set(6.0, 3.6);
            bodies.push(b);
            world.addBody(b);

            j = new Joint();
            j.set(b5, b6, new Vec2(7.0, 3.5));
            joints.push(j);
            world.addJoint(j);
        }

        // A multi-pendulum
        private function demo9():void{
            bodies = new Vector.<Body>();
            joints = new Vector.<Joint>();

            var b:Body = new Body();
            b.set(new Vec2(100.0, 20.0), Number.MAX_VALUE);
            b.friction = 0.2;
            b.position.set(0.0, -0.5 * b.width.y);
            b.rotation = 0.0;
            bodies.push(b);
            world.addBody(b);

            var b1:Body = b;

            var mass:Number = 10.0;

            // Tuning
            var frequencyHz:Number = 4.0;
            var dampingRatio:Number = 0.7;

            // frequency in radians
            var omega:Number = 2.0 * Math.PI * frequencyHz;

            // damping coefficient
            var d:Number = 2.0 * mass * dampingRatio * omega;

            // spring stiffness
            var k:Number = mass * omega * omega;

            // magic formulas
            var softness:Number = 1.0 / (d + timeStep * k);
            var biasFactor:Number = timeStep * k / (d + timeStep * k);

            var y:Number = 12.0;

            for (var i:int = 0; i < 15; ++i){
                var x:Vec2 = new Vec2(0.5 + i, y);
                b = new Body();
                b.set(new Vec2(0.75, 0.25), mass);
                b.friction = 0.2;
                b.position = x;
                b.rotation = 0.0;
                bodies.push(b);
                world.addBody(b);

                var j:Joint = new Joint();
                j.set(b1, b, new Vec2(i, y));
                j.softness = softness;
                j.biasFactor = biasFactor;
                joints.push(j);
                world.addJoint(j);

                b1 = b;
            }
        }

        private function simulationLoop():void{
            graphics.clear();

            world.step(timeStep);

            for each (var b:Body in bodies)
                drawBody(b);

            for each (var joint:Joint in joints)
                drawJoint(joint);
        }

        private function drawBody(body:Body):void{
            var R:Mat22 = Mat22.createRotate(body.rotation);
            var x:Vec2 = body.position;
            var h:Vec2 = body.width.mul(0.5);

            var v1:Vec2 = x.add(R.mul(new Vec2(-h.x, -h.y)));
            var v2:Vec2 = x.add(R.mul(new Vec2( h.x, -h.y)));
            var v3:Vec2 = x.add(R.mul(new Vec2( h.x,  h.y)));
            var v4:Vec2 = x.add(R.mul(new Vec2(-h.x,  h.y)));

            if (body == bomb)
                graphics.lineStyle(0, 0xcc0000);
            else
                graphics.lineStyle(0, 0x000080);

            graphics.moveTo(v1.x * SCALE + W, -v1.y * SCALE + H);
            graphics.lineTo(v2.x * SCALE + W, -v2.y * SCALE + H);
            graphics.lineTo(v3.x * SCALE + W, -v3.y * SCALE + H);
            graphics.lineTo(v4.x * SCALE + W, -v4.y * SCALE + H);
            graphics.lineTo(v1.x * SCALE + W, -v1.y * SCALE + H);
            graphics.lineStyle();
        }

        public function drawJoint(joint:Joint):void{
            var b1:Body = joint.body1;
            var b2:Body = joint.body2;

            var R1:Mat22 = Mat22.createRotate(b1.rotation);
            var R2:Mat22 = Mat22.createRotate(b2.rotation);

            var x1:Vec2 = b1.position;
            var p1:Vec2 = x1.add(R1.mul(joint.localAnchor1));

            var x2:Vec2 = b2.position;
            var p2:Vec2 = x2.add(R2.mul(joint.localAnchor2));

            graphics.lineStyle(0, 0x66ee66);
            graphics.moveTo(x1.x * SCALE + W, -x1.y * SCALE + H);
            graphics.lineTo(p1.x * SCALE + W, -p1.y * SCALE + H);
            graphics.lineTo(x2.x * SCALE + W, -x2.y * SCALE + H);
            graphics.lineTo(p2.x * SCALE + W, -p2.y * SCALE + H);
            graphics.lineStyle();
        }

        private function launchBomb():void{
            if (!bomb){
                bomb = new Body();
                bomb.set(new Vec2(1.0, 1.0), 50.0);
                bomb.friction = 0.2;
                bodies.push(bomb);
                world.addBody(bomb);
            }

            bomb.position.set(Math.random() * 30 - 15, 15.0);
            bomb.rotation = Math.random() * 3.0 - 1.5;
            bomb.velocity = bomb.position.mul(-1.5);
            bomb.angularVelocity = Math.random() * 40.0 - 20.0;
        }
    }
}

import flash.display.Graphics;
import flash.utils.Dictionary;

class GraphicsCache{
    private static var _g:Graphics;

    public static function set g(g:Graphics):void{ _g = g; }
    public static function get g():Graphics { return _g; }
}


/*******************************************************************************
 *
 * MathUtils.h
 *
 *******************************************************************************/

class Vec2{
    public var x:Number;
    public var y:Number;

    public function Vec2(x:Number = 0, y:Number = 0){
        this.x = x;
        this.y = y;
    }

    public function set(_x:Number, _y:Number):void { x = _x; y = _y; }

    public function negative():Vec2 { return new Vec2(-x, -y); }
    
    public function add(v:Vec2):Vec2{
        return new Vec2(x + v.x, y + v.y);
    }

    public function sub(v:Vec2):Vec2{
        return new Vec2(x - v.x, y - v.y);
    }

    public function mul(a:Number):Vec2{
        return new Vec2(x * a, y * a);
    }

    public function abs():Vec2{
        return new Vec2(Math.abs(x), Math.abs(y));
    }

    public function dot(v:Vec2):Number{
        return x * v.x + y * v.y;
    }

    public function length():Number{
        return Math.sqrt(x * x + y * y);
    }

    public function clone():Vec2 { return new Vec2(x, y); }

    public function toString():String{
        return "Vec2(" + x + ", " + y + ")";
    }
}

class Mat22{
    public var col1:Vec2;
    public var col2:Vec2;

    public function Mat22(col1:Vec2 = null, col2:Vec2 = null){
        this.col1 = col1;
        this.col2 = col2;
        if (!this.col1) { this.col1 = new Vec2(); }
        if (!this.col2) { this.col2 = new Vec2(); }
    }

    public static function createRotate(angle:Number):Mat22{
        var c:Number = Math.cos(angle), s:Number = Math.sin(angle);
        var ret:Mat22 = new Mat22();
        ret.col1.x = c; ret.col2.x = -s;
        ret.col1.y = s; ret.col2.y = c;
        return ret;
    }

    public function transpose():Mat22{
        return new Mat22(new Vec2(col1.x, col2.x), new Vec2(col1.y, col2.y));
    }

    public function invert():Mat22{
        var a:Number = col1.x, b:Number = col2.x, c:Number = col1.y, d:Number = col2.y;
        var det:Number = a * d - b * c;
        if (det == 0) throw new Error("det is 0");
        det = 1.0 / det;

        var B:Mat22 = new Mat22();
        B.col1.x =  det * d;    B.col2.x = -det * b;
        B.col1.y = -det * c;    B.col2.y =  det * a;
        return B;
    }

    public function add(m:Mat22):Mat22{
        return new Mat22(new Vec2(col1.x + m.col1.x, col2.x + m.col2.x),
                         new Vec2(col1.y + m.col1.y, col2.y + m.col2.y));
    }

    public function mul(v:Vec2):Vec2{
        return new Vec2(col1.x * v.x + col2.x * v.y, col1.y * v.x + col2.y * v.y);
    }

    public function mulMat22(m:Mat22):Mat22{
        return new Mat22(mul(m.col1), mul(m.col2));
    }

    public function abs():Mat22{
        return new Mat22(col1.abs(), col2.abs());
    }

    public function toString():String{
        return "Mat22(" + col1.toString() + ", " + col2.toString() + ")";
    }
}

class MathUtils{
    public static function dot(a:Vec2, b:Vec2):Number{
        return a.x * b.x + a.y * b.y;
    }

    public static function crossVV(a:Vec2, b:Vec2):Number{
        return a.x * b.y - a.y * b.x;
    }

    public static function crossVN(a:Vec2, s:Number):Vec2{
        return new Vec2(s * a.y, -s * a.x);
    }

    public static function crossNV(s:Number, a:Vec2):Vec2{
        return new Vec2(-s * a.y, s * a.x);
    }

    public static function mulNV(s:Number, v:Vec2):Vec2{
        return new Vec2(s * v.x, s * v.y);
    }

    public static function clamp(a:Number, low:Number, high:Number):Number{
        return Math.max(low, Math.min(a, high));
    }
}

/*******************************************************************************
 *
 * Body.cpp, Body.h
 *
 *******************************************************************************/

class Body{
    public var position:Vec2;
    public var rotation:Number;

    public var velocity:Vec2;
    public var angularVelocity:Number;

    public var force:Vec2;
    public var torque:Number;

    public var width:Vec2;

    public var friction:Number;
    public var mass:Number, invMass:Number;
    public var I:Number, invI:Number;

    private var _id:int;
    private static var idCounter:int = 0;

    public function get id():int { return _id; }

    public function Body(){
        position = new Vec2(0.0, 0.0);
        rotation = 0.0;
        velocity = new Vec2(0.0, 0.0);
        angularVelocity = 0.0;
        force = new Vec2(0.0, 0.0);
        torque = 0.0;
        friction = 0.2;

        width = new Vec2(1.0, 1.0);
        mass = Number.MAX_VALUE;
        invMass = 0.0;
        I = Number.MAX_VALUE;
        invI = 0.0;

        _id = ++idCounter;
    }

    public function set(w:Vec2, m:Number):void{
        position.set(0.0, 0.0);
        rotation = 0.0;
        velocity.set(0.0, 0.0);
        angularVelocity = 0.0;
        force.set(0.0, 0.0);
        torque = 0.0;
        friction = 0.2;

        width = w;
        mass = m;

        if (mass < Number.MAX_VALUE){
            invMass = 1.0 / mass;
            I = mass * (width.x * width.x + width.y * width.y) / 12.0;
            invI = 1.0 / I;
        }else{
            invMass = 0.0;
            I = Number.MAX_VALUE;
            invI = 0.0;
        }
    }
}

/*******************************************************************************
 *
 * Joint.cpp, Joint.h
 *
 *******************************************************************************/

class Joint {
    public var M:Mat22;
    public var localAnchor1:Vec2 = new Vec2(), localAnchor2:Vec2 = new Vec2();
    public var r1:Vec2 = new Vec2(), r2:Vec2 = new Vec2();
    public var bias:Vec2 = new Vec2();
    public var P:Vec2 = new Vec2();        // accumulated impulse
    public var body1:Body = new Body();
    public var body2:Body = new Body();
    public var biasFactor:Number = 0;
    public var softness:Number = 0;

    public function set(b1:Body, b2:Body, anchor:Vec2):void{
        body1 = b1;
        body2 = b2;

        var Rot1:Mat22 = Mat22.createRotate(body1.rotation);
        var Rot2:Mat22 = Mat22.createRotate(body2.rotation);
        var Rot1T:Mat22 = Rot1.transpose();
        var Rot2T:Mat22 = Rot2.transpose();

        localAnchor1 = Rot1T.mul(anchor.sub(body1.position));
        localAnchor2 = Rot2T.mul(anchor.sub(body2.position));

        P.set(0.0, 0.0);

        softness = 0.0;
        biasFactor = 0.2;
    }

    public function preStep(inv_dt:Number):void{
        // Pre-compute anchors, mass matrix, and bias.
        var Rot1:Mat22 = Mat22.createRotate(body1.rotation);
        var Rot2:Mat22 = Mat22.createRotate(body2.rotation);

        r1 = Rot1.mul(localAnchor1);
        r2 = Rot2.mul(localAnchor2);

        // deltaV = deltaV0 + K * impulse
        // invM = [(1/m1 + 1/m2) * eye(2) - skew(r1) * invI1 * skew(r1) - skew(r2) * invI2 * skew(r2)]
        //      = [1/m1+1/m2     0    ] + invI1 * [r1.y*r1.y -r1.x*r1.y] + invI2 * [r1.y*r1.y -r1.x*r1.y]
        //        [    0     1/m1+1/m2]           [-r1.x*r1.y r1.x*r1.x]           [-r1.x*r1.y r1.x*r1.x]
        var K1:Mat22 = new Mat22();
        K1.col1.x = body1.invMass + body2.invMass;    K1.col2.x = 0.0;
        K1.col1.y = 0.0;                            K1.col2.y = body1.invMass + body2.invMass;

        var K2:Mat22 = new Mat22();
        K2.col1.x =  body1.invI * r1.y * r1.y;        K2.col2.x = -body1.invI * r1.x * r1.y;
        K2.col1.y = -body1.invI * r1.x * r1.y;        K2.col2.y =  body1.invI * r1.x * r1.x;

        var K3:Mat22 = new Mat22();
        K3.col1.x =  body2.invI * r2.y * r2.y;        K3.col2.x = -body2.invI * r2.x * r2.y;
        K3.col1.y = -body2.invI * r2.x * r2.y;        K3.col2.y =  body2.invI * r2.x * r2.x;

        var K:Mat22 = K1.add(K2).add(K3);
        K.col1.x += softness;
        K.col2.y += softness;

        M = K.invert();

        var p1:Vec2 = body1.position.add(r1);
        var p2:Vec2 = body2.position.add(r2);
        var dp:Vec2 = p2.sub(p1);

        if (World.positionCorrection){
            bias = dp.mul(-biasFactor * inv_dt);
        }else{
            bias.set(0.0, 0.0);
        }

        if (World.warmStarting){
            // Apply accumulated impulse.
            body1.velocity = body1.velocity.sub(P.mul(body1.invMass));
            body1.angularVelocity -= body1.invI * MathUtils.crossVV(r1, P);

            body2.velocity = body2.velocity.add(P.mul(body2.invMass));
            body2.angularVelocity += body2.invI * MathUtils.crossVV(r2, P);
        }else{
            P.set(0.0, 0.0);
        }
    }

    public function applyImpulse():void{
        var dv:Vec2 = body2.velocity.add(MathUtils.crossNV(body2.angularVelocity, r2)).sub(body1.velocity).sub(MathUtils.crossNV(body1.angularVelocity, r1));

        var impulse:Vec2 = M.mul(bias.sub(dv).sub(P.mul(softness)));

        body1.velocity = body1.velocity.sub(impulse.mul(body1.invMass));
        body1.angularVelocity -= body1.invI * MathUtils.crossVV(r1, impulse);

        body2.velocity = body2.velocity.add(impulse.mul(body2.invMass));
        body2.angularVelocity += body2.invI * MathUtils.crossVV(r2, impulse);

        P = P.add(impulse);
    }
}

/*******************************************************************************
 *
 * Arbiter.cpp, Arbiter.h
 *
 *******************************************************************************/

class FeaturePair{
    public var inEdge1:uint;
    public var outEdge1:uint;
    public var inEdge2:uint;
    public var outEdge2:uint;

    public function get value():String{
        return inEdge1 + ":" + outEdge1 + ":" + inEdge2 + ":" + outEdge2;
    }
};

class Contact{
    public var position:Vec2;
    public var normal:Vec2;
    public var r1:Vec2, r2:Vec2;
    public var separation:Number;
    public var Pn:Number;    // accumulated normal impulse
    public var Pt:Number;    // accumulated tangent impulse
    public var Pnb:Number;    // accumulated normal impulse for position bias
    public var massNormal:Number, massTangent:Number;
    public var bias:Number;
    public var feature:FeaturePair;

    public function Contact(){
        Pn = Pt = Pnb = 0.0;
        feature = new FeaturePair();
    }
}

class ArbiterKey{
    public var body1:Body;
    public var body2:Body;

    public function ArbiterKey(b1:Body, b2:Body){
        if (b1.id < b2.id){
            body1 = b1; body2 = b2;
        }else{
            body1 = b2; body2 = b1;
        }
    }

    public function get id():String{
        return body1.id + "," + body2.id;
    }
}

class Arbiter{
    private static const MAX_POINTS:int = 2;

    public var contacts:Vector.<Contact>;
    public var numContacts:int;

    public var body1:Body;
    public var body2:Body;

    // Combined friction
    public var friction:Number;

    public function Arbiter(b1:Body, b2:Body){
        if (b1.id < b2.id){
            body1 = b1; body2 = b2;
        }else{
            body1 = b2; body2 = b1;
        }

        contacts = Collide.collide(body1, body2);
        numContacts = contacts.length;
        friction = Math.sqrt(body1.friction * body2.friction);

        GraphicsCache.g.beginFill(0xff0000);
        for each (var contact:Contact in contacts){
            GraphicsCache.g.drawCircle(contact.position.x * Box2dLite.SCALE + Box2dLite.W, -contact.position.y * Box2dLite.SCALE + Box2dLite.H, 1);
        }
        GraphicsCache.g.endFill();
    }

    public function update(newContacts:Vector.<Contact>, numNewContacts:int):void{
        var mergedContacts:Vector.<Contact> = Vector.<Contact>([new Contact(), new Contact()]);

        for (var i:int = 0; i < numNewContacts; ++i){
            var cNew:Contact = mergedContacts[i];
            var k:int = -1;
            for (var j:int = 0; j < numContacts; ++j){
                var cOld:Contact = contacts[j];
                if (cNew.feature.value == cOld.feature.value){
                    k = j;
                    break;
                }
            }

            if (k > -1){
                var c:Contact = mergedContacts[i];
                cOld = contacts[k];
                c = cNew;
                if (World.warmStarting){
                    c.Pn = cOld.Pn;
                    c.Pt = cOld.Pt;
                    c.Pnb = cOld.Pnb;
                }else{
                    c.Pn = 0.0;
                    c.Pt = 0.0;
                    c.Pnb = 0.0;
                }
            }else{
                mergedContacts[i] = newContacts[i];
            }
        }

        for (i = 0; i < numNewContacts; ++i)
            contacts[i] = mergedContacts[i];

        numContacts = numNewContacts;
    }

    public function preStep(inv_dt:Number):void{
        var k_allowedPenetration:Number = 0.01;
        var k_biasFactor:Number = World.positionCorrection ? 0.2 : 0.0;

        for each (var c:Contact in contacts){
            var r1:Vec2 = c.position.sub(body1.position);
            var r2:Vec2 = c.position.sub(body2.position);

            // Precompute normal mass, tangent mass, and bias.
            var rn1:Number = MathUtils.dot(r1, c.normal);
            var rn2:Number = MathUtils.dot(r2, c.normal);
            var kNormal:Number = body1.invMass + body2.invMass;
            kNormal += body1.invI * (MathUtils.dot(r1, r1) - rn1 * rn1) + body2.invI * (MathUtils.dot(r2, r2) - rn2 * rn2);
            c.massNormal = 1.0 / kNormal;

            var tangent:Vec2 = MathUtils.crossVN(c.normal, 1.0);
            var rt1:Number = MathUtils.dot(r1, tangent);
            var rt2:Number = MathUtils.dot(r2, tangent);
            var kTangent:Number = body1.invMass + body2.invMass;
            kTangent += body1.invI * (r1.dot(r1) - rt1 * rt1) + body2.invI * (r2.dot(r2) - rt2 * rt2);
            c.massTangent = 1.0 /  kTangent;

            c.bias = -k_biasFactor * inv_dt * Math.min(0.0, c.separation + k_allowedPenetration);

            if (World.accumulateImpulses){
                // Apply normal + friction impulse
                var P:Vec2 = c.normal.mul(c.Pn).add(tangent.mul(c.Pt));

                body1.velocity = body1.velocity.sub(P.mul(body1.invMass));
                body1.angularVelocity -= body1.invI * MathUtils.crossVV(r1, P);

                body2.velocity = body2.velocity.add(P.mul(body2.invMass));
                body2.angularVelocity += body2.invI * MathUtils.crossVV(r2, P);
            }
        }
    }

    public function applyImpulse():void{
        var b1:Body = body1;
        var b2:Body = body2;

        for each (var c:Contact in contacts){
            c.r1 = c.position.sub(b1.position);
            c.r2 = c.position.sub(b2.position);

            // Relative velocity at contact
            var dv:Vec2 = b2.velocity.add(MathUtils.crossNV(b2.angularVelocity, c.r2)).sub(b1.velocity).sub(MathUtils.crossNV(b1.angularVelocity, c.r1));

            // Compute normal impulse
            var vn:Number = MathUtils.dot(dv, c.normal);

            var dPn:Number = c.massNormal * (-vn + c.bias);

            if (World.accumulateImpulses){
                // Clamp the accumulated impulse
                var Pn0:Number = c.Pn;
                c.Pn = Math.max(Pn0 + dPn, 0.0);
                dPn = c.Pn - Pn0;
            }else{
                dPn = Math.max(dPn, 0.0);
            }

            // Apply contact impulse
            var Pn:Vec2 = c.normal.mul(dPn);

            b1.velocity = b1.velocity.sub(Pn.mul(b1.invMass));
            b1.angularVelocity -= b1.invI * MathUtils.crossVV(c.r1, Pn);

            b2.velocity = b2.velocity.add(Pn.mul(b2.invMass));
            b2.angularVelocity += b2.invI * MathUtils.crossVV(c.r2, Pn);

            // Relative velocity at contact
            dv = b2.velocity.add(MathUtils.crossNV(b2.angularVelocity, c.r2)).sub(b1.velocity).sub(MathUtils.crossNV(b1.angularVelocity, c.r1));

            var tangent:Vec2 = MathUtils.crossVN(c.normal, 1.0);
            var vt:Number = MathUtils.dot(dv, tangent);
            var dPt:Number = c.massTangent * (-vt);

            if (World.accumulateImpulses){
                // Compute friction impulse
                var maxPt:Number = friction * c.Pn;

                // Clamp friction
                var oldTangentImpulse:Number = c.Pt;
                c.Pt = MathUtils.clamp(oldTangentImpulse + dPt, -maxPt, maxPt);
                dPt = c.Pt - oldTangentImpulse;
            }else{
                maxPt = friction * dPn;
                dPt = MathUtils.clamp(dPt, -maxPt, maxPt);
            }

            // Apply contact impulse
            var Pt:Vec2 = tangent.mul(dPt);

            b1.velocity = b1.velocity.sub(Pt.mul(b1.invMass));
            b1.angularVelocity -= b1.invI * MathUtils.crossVV(c.r1, Pt);

            b2.velocity = b2.velocity.add(Pt.mul(b2.invMass));
            b2.angularVelocity += b2.invI * MathUtils.crossVV(c.r2, Pt);
        }
    }
}

/*******************************************************************************
 *
 * Collide.cpp
 *
 *******************************************************************************/

// Box vertex and edge numbering:
//
//        ^ y
//        |
//        e1
//   v2 ------ v1
//    |        |
// e2 |        | e4  --> x
//    |        |
//   v3 ------ v4
//        e3

class Axis{
    public static const FACE_A_X:String = "faceAX";
    public static const FACE_A_Y:String = "faceAY";
    public static const FACE_B_X:String = "faceBX";
    public static const FACE_B_Y:String = "faceBY";
}

class EdgeNumbers{
    public static const NO_EDGE:uint = 0;
    public static const EDGE1:uint = 1;
    public static const EDGE2:uint = 2;
    public static const EDGE3:uint = 3;
    public static const EDGE4:uint = 4;
}

class ClipVertex{
    public var v:Vec2;
    public var fp:FeaturePair;

    public function ClipVertex() {
        v = new Vec2();
        fp = new FeaturePair();
    }
}

class Collide{
    private static function flip(fp:FeaturePair):void{
        var tmp:uint;

        tmp = fp.inEdge1;
        fp.inEdge1 = fp.inEdge2;
        fp.inEdge2 = tmp;

        tmp = fp.outEdge1;
        fp.outEdge1 = fp.outEdge2;
        fp.outEdge2 = tmp;
    }

    private static function clipSegmentToLine(vOut:Vector.<ClipVertex>, vIn:Vector.<ClipVertex>,
                      normal:Vec2, offset:Number, clipEdge:uint):int{
        // Start with no output points
        var numOut:uint = 0;

        // Calculate the distance of end points to the line
        var distance0:Number = normal.dot(vIn[0].v) - offset;
        var distance1:Number = normal.dot(vIn[1].v) - offset;

        // If the points are behind the plane
        if (distance0 <= 0.0) vOut[numOut++] = vIn[0];
        if (distance1 <= 0.0) vOut[numOut++] = vIn[1];

        // If the points are on different sides of the plane
        if (distance0 * distance1 < 0.0){
            // Find intersection point of edge and plane
            var interp:Number = distance0 / (distance0 - distance1);
            vOut[numOut].v = vIn[0].v.add(vIn[1].v.sub(vIn[0].v).mul(interp));
            if (distance0 > 0.0){
                vOut[numOut].fp = vIn[0].fp;
                vOut[numOut].fp.inEdge1 = clipEdge;
                vOut[numOut].fp.inEdge2 = EdgeNumbers.NO_EDGE;
            }else{
                vOut[numOut].fp = vIn[1].fp;
                vOut[numOut].fp.outEdge1 = clipEdge;
                vOut[numOut].fp.outEdge2 = EdgeNumbers.NO_EDGE;
            }
            ++numOut;
        }

        return numOut;
    }

    private static function computeIncidentEdge(c:Vector.<ClipVertex>, h:Vec2, pos:Vec2,
                                    Rot:Mat22, normal:Vec2):void{
        // The normal is from the reference box. Convert it
        // to the incident boxe's frame and flip sign.
        var RotT:Mat22 = Rot.transpose();
        var n:Vec2 = RotT.mul(normal).negative();
        var nAbs:Vec2 = n.abs();

        if (nAbs.x > nAbs.y){
            if (n.x > 0.0){
                c[0].v.set(h.x, -h.y);
                c[0].fp.inEdge2 = EdgeNumbers.EDGE3;
                c[0].fp.outEdge2 = EdgeNumbers.EDGE4;

                c[1].v.set(h.x, h.y);
                c[1].fp.inEdge2 = EdgeNumbers.EDGE4;
                c[1].fp.outEdge2 = EdgeNumbers.EDGE1;
            }else{
                c[0].v.set(-h.x, h.y);
                c[0].fp.inEdge2 = EdgeNumbers.EDGE1;
                c[0].fp.outEdge2 = EdgeNumbers.EDGE2;

                c[1].v.set(-h.x, -h.y);
                c[1].fp.inEdge2 = EdgeNumbers.EDGE2;
                c[1].fp.outEdge2 = EdgeNumbers.EDGE3;
            }
        }else{
            if (n.y > 0.0){
                c[0].v.set(h.x, h.y);
                c[0].fp.inEdge2 = EdgeNumbers.EDGE4;
                c[0].fp.outEdge2 = EdgeNumbers.EDGE1;

                c[1].v.set(-h.x, h.y);
                c[1].fp.inEdge2 = EdgeNumbers.EDGE1;
                c[1].fp.outEdge2 = EdgeNumbers.EDGE2;
            }else{
                c[0].v.set(-h.x, -h.y);
                c[0].fp.inEdge2 = EdgeNumbers.EDGE2;
                c[0].fp.outEdge2 = EdgeNumbers.EDGE3;

                c[1].v.set(h.x, -h.y);
                c[1].fp.inEdge2 = EdgeNumbers.EDGE3;
                c[1].fp.outEdge2 = EdgeNumbers.EDGE4;
            }
        }

        c[0].v = Rot.mul(c[0].v).add(pos);
        c[1].v = Rot.mul(c[1].v).add(pos);
    }


    // The normal points from A to B
    public static function collide(bodyA:Body, bodyB:Body):Vector.<Contact>{
        var contacts:Vector.<Contact> = new Vector.<Contact>();

        // Setup
        var hA:Vec2 = bodyA.width.mul(0.5);
        var hB:Vec2 = bodyB.width.mul(0.5);

        var posA:Vec2 = bodyA.position;
        var posB:Vec2 = bodyB.position;

        var RotA:Mat22 = Mat22.createRotate(bodyA.rotation);
        var RotB:Mat22 = Mat22.createRotate(bodyB.rotation);

        var RotAT:Mat22 = RotA.transpose();
        var RotBT:Mat22 = RotB.transpose();

        var a1:Vec2 = RotA.col1, a2:Vec2 = RotA.col2;
        var b1:Vec2 = RotB.col1, b2:Vec2 = RotB.col2;

        var dp:Vec2 = posB.sub(posA);
        var dA:Vec2 = RotAT.mul(dp);
        var dB:Vec2 = RotBT.mul(dp);

        var C:Mat22 = RotAT.mulMat22(RotB);
        var absC:Mat22 = C.abs();
        var absCT:Mat22 = absC.transpose();

        GraphicsCache.g.lineStyle(0, 0xff0000);

        // Box A faces
        var faceA:Vec2 = dA.abs().sub(hA).sub(absC.mul(hB));
        //GraphicsCache.g.moveTo(bodyA.position.x * 10, bodyA.position.y * 10);
        //GraphicsCache.g.lineTo((bodyA.position.x + faceA.x) * 10, (bodyA.position.y + faceA.y) * 10);
        if (faceA.x > 0.0 || faceA.y > 0.0)
            return contacts;

        // Box B faces
        var faceB:Vec2 = dB.abs().sub(absCT.mul(hA)).sub(hB);
        //GraphicsCache.g.moveTo(bodyB.position.x * 10, bodyB.position.y * 10);
        //GraphicsCache.g.lineTo((bodyB.position.x + faceB.x) * 10, (bodyB.position.y + faceB.y) * 10);
        if (faceB.x > 0.0 || faceB.y > 0.0)
            return contacts;

        // Find best axis
        var axis:String;
        var separation:Number;
        var normal:Vec2;

        // Box A faces
        axis= Axis.FACE_A_X;
        separation = faceA.x;
        normal = dA.x > 0.0 ? RotA.col1 : RotA.col1.negative();

        const relativeTol:Number = 0.95;
        const absoluteTol:Number = 0.01;

        if (faceA.y > relativeTol * separation + absoluteTol * hA.y){
            axis = Axis.FACE_A_Y;
            separation = faceA.y;
            normal = dA.y > 0.0 ? RotA.col2 : RotA.col2.negative();
            //GraphicsCache.g.moveTo(bodyA.position.x * 10, bodyA.position.y * 10);
            //GraphicsCache.g.lineTo((bodyA.position.x + normal.x * 10) * 10, (bodyA.position.y + normal.y * 10) * 10);
        }

        // Box B faces
        if (faceB.x > relativeTol * separation + absoluteTol * hB.x){
            axis = Axis.FACE_B_X;
            separation = faceB.x;
            normal = dB.x > 0.0 ? RotB.col1 : RotB.col1.negative();
        }

        if (faceB.y > relativeTol * separation + absoluteTol * hB.y){
            axis = Axis.FACE_B_Y;
            separation = faceB.y;
            normal = dB.y > 0.0 ? RotB.col2 : RotB.col2.negative();
        }

        // Setup clipping plane data based on the separating axis
        var frontNormal:Vec2, sideNormal:Vec2;
        var incidentEdge:Vector.<ClipVertex> = Vector.<ClipVertex>([new ClipVertex(), new ClipVertex()]);
        var front:Number, negSide:Number, posSide:Number;
        var negEdge:uint, posEdge:uint;
        var side:Number;

        // Compute the clipping lines and the line segment to be clipped.
        switch (axis){
        case Axis.FACE_A_X:
            frontNormal = normal;
            front = posA.dot(frontNormal) + hA.x;
            sideNormal = RotA.col2;
            side = posA.dot(sideNormal);
            negSide = -side + hA.y;
            posSide =  side + hA.y;
            negEdge = EdgeNumbers.EDGE3;
            posEdge = EdgeNumbers.EDGE1;
            computeIncidentEdge(incidentEdge, hB, posB, RotB, frontNormal);
            break;

        case Axis.FACE_A_Y:
            frontNormal = normal;
            front = posA.dot(frontNormal) + hA.y;
            sideNormal = RotA.col1;
            side = posA.dot(sideNormal);
            negSide = -side + hA.x;
            posSide =  side + hA.x;
            negEdge = EdgeNumbers.EDGE2;
            posEdge = EdgeNumbers.EDGE4;
            computeIncidentEdge(incidentEdge, hB, posB, RotB, frontNormal);
            break;

        case Axis.FACE_B_X:
            frontNormal = normal.negative();
            front = posB.dot(frontNormal) + hB.x;
            sideNormal = RotB.col2;
            side = posB.dot(sideNormal);
            negSide = -side + hB.y;
            posSide =  side + hB.y;
            negEdge = EdgeNumbers.EDGE3;
            posEdge = EdgeNumbers.EDGE1;
            computeIncidentEdge(incidentEdge, hA, posA, RotA, frontNormal);
            break;

        case Axis.FACE_B_Y:
            frontNormal = normal.negative();
            front = posB.dot(frontNormal) + hB.y;
            sideNormal = RotB.col1;
            side = posB.dot(sideNormal);
            negSide = -side + hB.x;
            posSide =  side + hB.x;
            negEdge = EdgeNumbers.EDGE2;
            posEdge = EdgeNumbers.EDGE4;
            computeIncidentEdge(incidentEdge, hA, posA, RotA, frontNormal);
            break;
        }

        // clip other face with 5 box planes (1 face plane, 4 edge planes)

        var clipPoints1:Vector.<ClipVertex> = Vector.<ClipVertex>([new ClipVertex(), new ClipVertex()]);
        var clipPoints2:Vector.<ClipVertex> = Vector.<ClipVertex>([new ClipVertex(), new ClipVertex()]);
        var np:int;

        // Clip to box side 1
        np = clipSegmentToLine(clipPoints1, incidentEdge, sideNormal.negative(), negSide, negEdge);

        if (np < 2)
            return contacts;

        // Clip to negative box side 1
        np = clipSegmentToLine(clipPoints2, clipPoints1,  sideNormal, posSide, posEdge);

        if (np < 2)
            return contacts;

        // Now clipPoints2 contains the clipping points.
        // Due to roundoff, it is possible that clipping removes all points.

        var numContacts:int = 0;
        for (var i:int = 0; i < 2; ++i){
            separation = frontNormal.dot(clipPoints2[i].v) - front;

            if (separation <= 0){
                contacts.push(new Contact());
                contacts[numContacts].separation = separation;
                contacts[numContacts].normal = normal;
                // slide contact point onto reference face (easy to cull)
                contacts[numContacts].position = clipPoints2[i].v.sub(frontNormal.mul(separation));
                contacts[numContacts].feature = clipPoints2[i].fp;
                if (axis == Axis.FACE_B_X || axis == Axis.FACE_B_Y)
                    flip(contacts[numContacts].feature);
                ++numContacts;
            }
        }

        return contacts;
    }
}

/*******************************************************************************
 *
 * World.cpp, World.h
 *
 *******************************************************************************/

class World{
    public var bodies:Vector.<Body> = new Vector.<Body>();
    public var joints:Vector.<Joint> = new Vector.<Joint>();
    public var arbiters:Object = {};
    public var gravity:Vec2;
    public var iterations:int;
    public static var accumulateImpulses:Boolean = true;
    public static var warmStarting:Boolean = true;
    public static var positionCorrection:Boolean = true;

    public function World(gravity:Vec2, iterations:int){
        this.gravity = gravity;
        this.iterations = iterations;
    }

    public function addBody(body:Body):void{
        bodies.push(body);
    }

    public function addJoint(joint:Joint):void{
        joints.push(joint);
    }

    public function clear():void{
        bodies.length = 0;
        joints.length = 0;
        arbiters = {};
    }

    private function broadPhase():void{
        // O(n^2) broad-phase
        for (var i:int = 0; i < bodies.length; ++i){
            var bi:Body = bodies[i];

            for (var j:int = i + 1; j < bodies.length; ++j){
                var bj:Body = bodies[j];

                if (bi.invMass == 0.0 && bj.invMass == 0.0)
                    continue;

                var newArb:Arbiter = new Arbiter(bi, bj);
                var key:ArbiterKey = new ArbiterKey(bi, bj);

                if (newArb.numContacts > 0){
                    if (!arbiters.hasOwnProperty(key.id)){
                        arbiters[key.id] = newArb;
                    }else{
                        (arbiters[key.id] as Arbiter).update(newArb.contacts, newArb.numContacts);
                    }
                }else{
                    delete arbiters[key.id];
                }
            }
        }
    }

    public function step(dt:Number):void{
        var inv_dt:Number = dt > 0.0 ? 1.0 / dt : 0.0;

        // Determine overlapping bodies and update contact points.
        broadPhase();

        // Integrate forces.
        for each (var b:Body in bodies){
            if (b.invMass == 0.0)
                continue;

            b.velocity = gravity.add(b.force.mul(b.invMass)).mul(dt).add(b.velocity);
            b.angularVelocity += dt * b.invI * b.torque;
        }

        // Perform pre-steps.
        for each (var arb:Arbiter in arbiters){
            arb.preStep(inv_dt);
        }

        for each (var joint:Joint in joints){
            joint.preStep(inv_dt);
        }

        // Perform iterations
        for (var i:int = 0; i < iterations; ++i){
            for each (arb in arbiters){
                arb.applyImpulse();
            }

            for each (joint in joints){
                joint.applyImpulse();
            }
        }

        // Integrate Velocities
        for each (b in bodies){
            b.position = b.velocity.mul(dt).add(b.position);
            b.rotation += dt * b.angularVelocity;

            b.force.set(0.0, 0.0);
            b.torque = 0.0;
        }
    }
}
