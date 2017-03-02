/*
 * 流体シミュ最適化/Particle Fluid Optimization
 *
 * クリック：水を注ぐ
 * Click:Pouring
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
        public static const GRAVITY:Number = 0.05;//重力
        public static const RANGE:Number = 12;//影響半径
        public static const RANGE2:Number = RANGE * RANGE;//影響半径の二乗
        public static const DENSITY:Number = 1;//流体の密度
        public static const PRESSURE:Number = 2;//圧力係数
        public static const VISCOSITY:Number = 0.1;//粘性係数
        public static const NUM_GRIDS:int = 38;//グリッド数(≒ 465 / RANGE)
        public static const INV_GRID_SIZE:Number = 1 / (465 / NUM_GRIDS);//グリッドサイズの逆数(≒ 1 / RANGE)
        private var img:BitmapData;
        private var particles:Vector.<Particle>;
        private var numParticles:uint;
        private var neighbors:Vector.<Neighbor>;
        private var numNeighbors:uint;
        private var color:ColorTransform;
        private var filter:BlurFilter;
        private var count:int;
        private var press:Boolean;
        private var labP:TextField;
        private var grids:Vector.<Vector.<Grid>>;

        public function SPH() {
            initialize();
        }

        private function initialize():void {
            color = new ColorTransform(0.6, 0.9, 0.95);
            filter = new BlurFilter(2, 2, 1);
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
            img = new BitmapData(465, 465, false, 0);
            addChild(new Bitmap(img));
            addEventListener(Event.ENTER_FRAME, frame);
            labP = new TextField();
            labP.selectable = false;
            var tf:TextFormat = new TextFormat();
            tf.color = 0xffffff;
            tf.size = 12;
            tf.font = "MS UI Gothic";
            labP.defaultTextFormat = tf;
            labP.width = 256;
            labP.x = 70;
            var st:Stats = new Stats();
            st.alpha = 0.75;
            addChild(st);
            addChild(labP);
            Wonderfl.capture_delay(10);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {press = true;});
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {press = false;});
        }

        private function frame(e:Event):void {
            if(press) pour();
            move();
            img.lock();
            img.colorTransform(img.rect, color);
            img.applyFilter(img, img.rect, new Point(), filter);
            draw();
            img.unlock();
            labP.text = "Particle : " + numParticles;
        }

        private function draw():void {
            var rect:Rectangle = new Rectangle(0, 0, 2, 2);
            for(var i:int = 0; i < numParticles; i++) {
                var p:Particle = particles[i];
                rect.x = p.x - 1;
                rect.y = p.y - 1;
                img.fillRect(rect, p.color);
            }
        }

        private function pour():void {
            if(count % 2 == 0)
                for(var i:int = -4; i <= 4; i++) {
                     particles[numParticles++] = new Particle(mouseX + i * 8, mouseY);
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
                p.fx = p.fy = p.density = 0;
                p.gx = p.x * INV_GRID_SIZE;
                p.gy = p.y * INV_GRID_SIZE;
                if(p.gx < 0)
                    p.gx = 0;
                if(p.gy < 0)
                    p.gy = 0;
                if(p.gx > NUM_GRIDS - 1)
                    p.gx = NUM_GRIDS - 1;
                if(p.gy > NUM_GRIDS - 1)
                    p.gy = NUM_GRIDS - 1;
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
                grids[p.gx][p.gy].add(p);
            }
        }

        private function findNeighborsInGrid(pi:Particle, g:Grid):void {
            for(var j:int = 0; j < g.numParticles; j++) {
                var pj:Particle = g.particles[j];
                var distance:Number = (pi.x - pj.x) * (pi.x - pj.x) + (pi.y - pj.y) * (pi.y - pj.y);
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
                p.pressure = p.density - DENSITY;
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

class Particle {
    public var x:Number;
    public var y:Number;
    public var gx:int;
    public var gy:int;
    public var vx:Number;
    public var vy:Number;
    public var fx:Number;
    public var fy:Number;
    public var density:Number;
    public var pressure:Number;
    public var color:int;
    public var next:Particle;
    public function Particle(x:Number, y:Number) {
        this.x = x;
        this.y = y;
        vx = vy = fx = fy = 0;
        color = 0xffffff;
    }

    public function move():void {
        vy += SPH.GRAVITY;
        if(density > 0.05) {
            vx += fx / density;
            vy += fy / density;
        }
        x += vx;
        y += vy;
        if(x < 5)
            vx += (5 - x) * 0.5 - vx * 0.5;
        if(y < 5)
            vy += (5 - y) * 0.5 - vy * 0.5;
        if(x > 460)
            vx += (460 - x) * 0.5 - vx * 0.5;
        if(y > 460)
            vy += (460 - y) * 0.5 - vy * 0.5;
    }
}

class Neighbor {
    public var p1:Particle;
    public var p2:Particle;
    public var distance:Number;
    public var nx:Number;
    public var ny:Number;
    public var weight:Number;
    public static const pressure:Number = SPH.PRESSURE;
    public static const viscosity:Number = SPH.VISCOSITY;
    public function Neighbor() {
    }

    public function setParticle(p1:Particle, p2:Particle):void {
        this.distance = distance;
        this.p1 = p1;
        this.p2 = p2;
        nx = p1.x - p2.x;
        ny = p1.y - p2.y;
        distance = Math.sqrt(nx * nx + ny * ny);
        weight = 1 - distance / SPH.RANGE;
        var temp:Number = weight * weight;
        temp += temp * weight;
        p1.density += temp;
        p2.density += temp;
        temp = 1 / distance;
        nx *= temp;
        ny *= temp;
    }

    public function calcForce():void {
        var pressureWeight:Number = weight * (p1.pressure + p2.pressure) * pressure;
        if(pressureWeight < 0) pressureWeight = 0;
        var viscosityWeight:Number = weight * viscosity;
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
    public var numParticles:int;
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
