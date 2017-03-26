/*
 * クリック：水を注ぐ
 * Click:Pouring
 * 
 * ・表面張力もどき
 */
package {
    import flash.utils.*;
    import flash.text.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.events.*;
    import flash.display.*;
    import net.hires.debug.Stats;
    [SWF(frameRate = 60)]
    public class SPH extends Sprite {
        public static const GRAVITY:Number = 0.025;//重力
        public static const RANGE:Number = 10;//影響半径
        public static const RANGE2:Number = RANGE * RANGE;//影響半径の二乗
        public static const DENSITY:Number = 2;//流体の密度
        public static const PRESSURE:Number = 0.5;//圧力係数
        public static const PRESSURE2:Number = 1;//圧力係数その2
        public static const VISCOSITY:Number = 0.1;//粘性係数
        public static const NUM_GRIDS:int = 46;//グリッド数(≒ 465 / RANGE)
        public static const INV_GRID_SIZE:Number = 1 / (465 / NUM_GRIDS);//グリッドサイズの逆数(≒ 1 / RANGE)
        private var particles:Vector.<Particle>;
        private var numParticles:uint;
        private var neighbors:Vector.<Neighbor>;
        private var numNeighbors:uint;
        private var count:int;
        private var press:Boolean;
        private var grids:Vector.<Vector.<Grid>>;

        public function SPH() {
            initialize();
        }

        private function initialize():void {
            graphics.beginFill(0);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            particles = new Vector.<Particle>();
            numParticles = 0;
            neighbors = new Vector.<Neighbor>();
            numNeighbors = 0;
            grids = new Vector.<Vector.<Grid>>(NUM_GRIDS, true);
            for(var i:int = 0; i < NUM_GRIDS; i++) {
                grids[i] = new Vector.<Grid>(NUM_GRIDS, true);
                for(var j:int = 0; j < NUM_GRIDS; j++)
                    grids[i][j] = new Grid();
            }
            count = 0;
            addEventListener(Event.ENTER_FRAME, frame);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {press = true;});
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {press = false;});
        }

        private function frame(e:Event):void {
            if(press)
                pour();
            move();
        }

        private function pour():void {
            for(var i:int = -4; i <= 4; i++) {
                 particles[numParticles++] = new Particle(mouseX + i * 8, mouseY);
                 addChild(particles[numParticles - 1]);
                 particles[numParticles - 1].vy = 5;
            }
        }

        private function move():void {
            count++;
            var i:int;
            var j:int;
            var dist:Number;
            var p:Particle;
            updateGrids();
            findNeighbors();
            calcPressure();
            calcForce();
            for(i = 0; i < numParticles; i++) {
                p = particles[i];
                p.move();
            }
        }

        private function updateGrids():void {
            var i:int;
            var j:int;
            for(i = 0; i < NUM_GRIDS; i++)
                for(j = 0; j < NUM_GRIDS; j++)
                    grids[i][j].clear();
            for(i = 0; i < numParticles; i++) {
                var p:Particle = particles[i];
                p.fx = p.fy = p.density = p.density2 = 0;
                p.gx = p.px * INV_GRID_SIZE;
                p.gy = p.py * INV_GRID_SIZE;
                if(p.gx < 0)
                    p.gx = 0;
                if(p.gy < 0)
                    p.gy = 0;
                if(p.gx > NUM_GRIDS - 1)
                    p.gx = NUM_GRIDS - 1;
                if(p.gy > NUM_GRIDS - 1)
                    p.gy = NUM_GRIDS - 1;
                grids[p.gx][p.gy].add(p);
            }
        }

        private function findNeighbors():void {
            numNeighbors = 0;
            for(var i:int = 0; i < numParticles; i++) {
                var p:Particle = particles[i];
                var xMin:Boolean = p.gx != 0;
                var xMax:Boolean = p.gx != NUM_GRIDS - 1;
                var yMin:Boolean = p.gy != 0;
                var yMax:Boolean = p.gy != NUM_GRIDS - 1;
                findNeighborsInGrid(p, grids[p.gx][p.gy]);
                if(xMin) findNeighborsInGrid(p, grids[p.gx - 1][p.gy]);
                if(xMax) findNeighborsInGrid(p, grids[p.gx + 1][p.gy]);
                if(yMin) findNeighborsInGrid(p, grids[p.gx][p.gy - 1]);
                if(yMax) findNeighborsInGrid(p, grids[p.gx][p.gy + 1]);
                if(xMin && yMin) findNeighborsInGrid(p, grids[p.gx - 1][p.gy - 1]);
                if(xMin && yMax) findNeighborsInGrid(p, grids[p.gx - 1][p.gy + 1]);
                if(xMax && yMin) findNeighborsInGrid(p, grids[p.gx + 1][p.gy - 1]);
                if(xMax && yMax) findNeighborsInGrid(p, grids[p.gx + 1][p.gy + 1]);
            }
        }

        private function findNeighborsInGrid(pi:Particle, g:Grid):void {
            for(var j:int = 0; j < g.numParticles; j++) {
                var pj:Particle = g.particles[j];
                if(pi == pj)
                    continue;
                var distance:Number = (pi.px - pj.px) * (pi.px - pj.px) + (pi.py - pj.py) * (pi.py - pj.py);
                if(distance < RANGE2) {
                    if(neighbors.length == numNeighbors)
                        neighbors[numNeighbors] = new Neighbor();
                    neighbors[numNeighbors++].setParticle(pi, pj);
                }
            }
        }

        private function calcPressure():void {
            for(var i:int = 0; i < numParticles; i++) {
                var p:Particle = particles[i];
                if(p.density < DENSITY * 0.3)
                    p.density = DENSITY * 0.3;
                p.pressure = (p.density - DENSITY) * SPH.PRESSURE;
            }
        }

        private function calcForce():void {
            var i:int;
            for(i = 0; i < numNeighbors; i++) {
                var n:Neighbor = neighbors[i];
                n.calcForce();
            }
        }
    }
}
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.display.Sprite;

class Particle extends Sprite {
    public var px:Number;
    public var py:Number;
    public var gx:int;
    public var gy:int;
    public var vx:Number;
    public var vy:Number;
    public var fx:Number;
    public var fy:Number;
    public var density:Number;
    public var density2:Number;
    public var pressure:Number;
    public var color:int;
    public var form:Matrix;
    public function Particle(px:Number, py:Number) {
        this.px = px;
        this.py = py;
        vx = vy = fx = fy = 0;
        color = 0x3366ff;
        graphics.beginFill(color);
        graphics.drawEllipse(-6, -6, 12, 12);
        graphics.endFill();
        filters = [new BlurFilter()];
        form = new Matrix();
    }

    public function move():void {
        vy += SPH.GRAVITY;
        if(density > 0) {
            vx += fx / density;
            vy += fy / density;
        }
        px += vx;
        py += vy;
        if(px < 5)
            vx += (5 - px) * 0.5 - vx * 0.5;
        if(px > 460)
            vx += (460 - px) * 0.5 - vx * 0.5;
        if(py > 460) {
            if(px > 365) {
                px = Math.random() * 50;
                py = Math.random() * 80 - 40;
                vy = 3;
                vx = 0;
            } else vy += (460 - py) * 0.5 - vy * 0.5;
        }
        form.identity();
        form.translate(px, py);
        transform.matrix = form;
    }
}

class Neighbor {
    public var p1:Particle;
    public var p2:Particle;
    public var distance:Number;
    public var nx:Number;
    public var ny:Number;
    public var weight:Number;
    public function Neighbor() {
    }

    public function setParticle(p1:Particle, p2:Particle):void {
        this.distance = distance;
        this.p1 = p1;
        this.p2 = p2;
        nx = p1.px - p2.px;
        ny = p1.py - p2.py;
        distance = Math.sqrt(nx * nx + ny * ny);
        weight = 1 - distance / SPH.RANGE;
        var temp:Number = weight * weight;
        p1.density += temp;
        p2.density += temp;
        temp *= weight * SPH.PRESSURE2;
        p1.density2 += temp;
        p2.density2 += temp;
        temp = 1 / distance;
        nx *= temp;
        ny *= temp;
    }

    public function calcForce():void {
        var pressureWeight:Number = weight * (p1.pressure + p2.pressure + weight * (p1.density2 + p2.density2)) * 0.5;
        var viscosityWeight:Number = weight * SPH.VISCOSITY * 0.5;
        p1.fx += nx * pressureWeight;
        p1.fy += ny * pressureWeight;
        p2.fx -= nx * pressureWeight;
        p2.fy -= ny * pressureWeight;
        var rvx:Number = p2.vx - p1.vx;
        var rvy:Number = p2.vy - p1.vy;
        p1.fx += rvx * viscosityWeight;
        p1.fy += rvy * viscosityWeight;
        p2.fx -= rvx * viscosityWeight;
        p2.fy -= rvy * viscosityWeight;
    }
}

class Grid {
    public var particles:Vector.<Particle>;
    public var numParticles:uint;
    public function Grid() {
        particles = new Vector.<Particle>;
        numParticles = 0;
    }

    public function clear():void {
        numParticles = 0;
    }

    public function add(p:Particle):void {
        particles[numParticles++] = p;
    }
}
