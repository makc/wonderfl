/*
 * 混相流 / Multiphase flow
 * 
 * いくつかの種類の液体のシミュレーションです。
 * クリックで注ぎます。
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
    [SWF(frameRate = "60")]
    public class Fluid extends Sprite {
        public static const GRAVITY:Number = 0.05;//重力
        public static const RANGE:Number = 16;//影響半径
        public static const RANGE2:Number = RANGE * RANGE;//影響半径の二乗
        public static const DENSITY:Number = 2.5;//流体の基準(安定する)密度
        public static const PRESSURE:Number = 1;//圧力係数
        public static const PRESSURE_NEAR:Number = 1;//近距離圧力係数
        public static const VISCOSITY:Number = 0.1;//粘性係数
        public static const NUM_GRIDS:int = 29;//グリッド数(≒ 465 / RANGE)
        public static const INV_GRID_SIZE:Number = 1 / (465 / NUM_GRIDS);//グリッドサイズの逆数(≒ 1 / RANGE)
        private var particles:Vector.<Particle>;
        private var numParticles:uint;
        private var neighbors:Vector.<Neighbor>;
        private var numNeighbors:uint;
        private var count:int;
        private var press:Boolean;
        private var bitmap:BitmapData;
        private var grids:Vector.<Vector.<Grid>>;
        private const COLOR_TRANSFORM:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);

        public function Fluid() {
            initialize();
        }

        private function initialize():void {
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
            bitmap = new BitmapData(465, 465, false, 0);
            addChild(new Bitmap(bitmap));
            // var s:Stats = new Stats();
            // s.alpha = 0.8;
            // addChild(s);
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
                 particles[numParticles++] = new Particle(mouseX + i * 10, mouseY,
                     count / 10 % 5);
                 particles[numParticles - 1].vy = 5;
            }
        }

        private function move():void {
            count++;
            updateGrids();
            findNeighbors();
            calcForce();
            bitmap.lock();
            bitmap.colorTransform(bitmap.rect, COLOR_TRANSFORM);
            for(var i:uint = 0; i < numParticles; i++) {
                const p:Particle = particles[i];
                p.move();
                bitmap.fillRect(new Rectangle(p.x - 1, p.y - 1, 3, 3), p.color);
            }
            bitmap.unlock();
        }

        private function updateGrids():void {
            var i:uint;
            var j:uint;
            for(i = 0; i < NUM_GRIDS; i++)
                for(j = 0; j < NUM_GRIDS; j++)
                    grids[i][j].numParticles = 0;
            for(i = 0; i < numParticles; i++) {
                const p:Particle = particles[i];
                p.fx = p.fy = p.density = p.densityNear = 0;
                p.gx = p.x * INV_GRID_SIZE; // グリッドのどこにいるか計算
                p.gy = p.y * INV_GRID_SIZE;
                if(p.gx < 0) // グリッドから外れてたら一番近いとこに入ってることにする
                    p.gx = 0;
                if(p.gy < 0)
                    p.gy = 0;
                if(p.gx > NUM_GRIDS - 1)
                    p.gx = NUM_GRIDS - 1;
                if(p.gy > NUM_GRIDS - 1)
                    p.gy = NUM_GRIDS - 1;
            }
        }

        private function findNeighbors():void { // 空間分割で近接粒子を計算
            numNeighbors = 0;
            for(var i:uint = 0; i < numParticles; i++) {
                const p:Particle = particles[i];
                const xMin:Boolean = p.gx != 0;
                const xMax:Boolean = p.gx != NUM_GRIDS - 1;
                const yMin:Boolean = p.gy != 0;
                const yMax:Boolean = p.gy != NUM_GRIDS - 1;
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
            for(var j:uint = 0; j < g.numParticles; j++) {
                var pj:Particle = g.particles[j];
                const distance:Number = (pi.x - pj.x) * (pi.x - pj.x) + (pi.y - pj.y) * (pi.y - pj.y);
                if(distance < RANGE2) {
                    if(neighbors.length == numNeighbors)
                        neighbors[numNeighbors] = new Neighbor();
                    neighbors[numNeighbors++].setParticle(pi, pj);
                }
            }
        }

        private function calcForce():void {
            for(var i:uint = 0; i < numNeighbors; i++)
                neighbors[i].calcForce();
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
    public var densityNear:Number;
    public var color:int;
    public var type:int;
    public const GRAVITY:Number = Fluid.GRAVITY;
    public function Particle(x:Number, y:Number, type:int) {
        this.x = x;
        this.y = y
        this.type = type;
        vx = vy = fx = fy = 0;
        switch(type) {
        case 0:
            color = 0x6060ff;
            break;
        case 1:
            color = 0xff6000;
            break;
        case 2:
            color = 0xff0060;
            break;
        case 3:
            color = 0x00d060;
            break;
        case 4:
            color = 0xd0d000;
            break;
        }
    }

    public function move():void {
        vy += GRAVITY;
        if(density > 0) {
            vx += fx / (density * 0.9 + 0.1); // 本当は密度で割る計算だけど0に近かった時に
            vy += fy / (density * 0.9 + 0.1); //     粒子が飛び出すから微調整
        }
        x += vx;
        y += vy;
        if(x < 5) // 壁境界
            vx += (5 - x) * 0.5 - vx * 0.5;
        if(x > 460)
            vx += (460 - x) * 0.5 - vx * 0.5;
        if(y < 5)
            vy += (5 - y) * 0.5 - vy * 0.5;
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
    public const RANGE:Number = Fluid.RANGE;
    public const PRESSURE:Number = Fluid.PRESSURE;
    public const PRESSURE_NEAR:Number = Fluid.PRESSURE_NEAR;
    public const DENSITY:Number = Fluid.DENSITY;
    public const VISCOSITY:Number = Fluid.VISCOSITY;
    public function Neighbor() {
    }

    public function setParticle(p1:Particle, p2:Particle):void { // 使いまわし
        this.distance = distance;
        this.p1 = p1;
        this.p2 = p2;
        nx = p1.x - p2.x;
        ny = p1.y - p2.y;
        distance = Math.sqrt(nx * nx + ny * ny);
        weight = 1 - distance / RANGE;
        var density:Number = weight * weight; // 普通の圧力カーネルは距離の二乗
        p1.density += density;
        p2.density += density;
        density *= weight * PRESSURE_NEAR; // 粒子が近づきすぎないよう近距離用のカーネルを計算
        p1.densityNear += density;
        p2.densityNear += density;
        const invDistance:Number = 1 / distance;
        nx *= invDistance;
        ny *= invDistance;
    }

    public function calcForce():void {
        var p:Number;
        if(p1.type != p2.type) // 違うタイプの粒子なら安定する密度をちょっと減らす
            p = (p1.density + p2.density - DENSITY * 1.5) * PRESSURE;
        else // 同じタイプなら普通に計算
            p = (p1.density + p2.density - DENSITY * 2) * PRESSURE;
        const pn:Number = (p1.densityNear + p2.densityNear) * PRESSURE_NEAR; // 基準密度に関係なく近づきすぎたら跳ね返す！
        var pressureWeight:Number = weight * (p + weight * pn); // 結果としてかかる圧力
        var viscosityWeight:Number = weight * VISCOSITY;
        var fx:Number = nx * pressureWeight;
        var fy:Number = ny * pressureWeight;
        fx += (p2.vx - p1.vx) * viscosityWeight; // 単純に粘性項を解く
        fy += (p2.vy - p1.vy) * viscosityWeight;
        p1.fx += fx;
        p1.fy += fy;
        p2.fx -= fx;
        p2.fy -= fy;
    }
}

class Grid {
    public var particles:Vector.<Particle>;
    public var numParticles:uint;
    public function Grid() {
        particles = new Vector.<Particle>;
    }

    public function add(p:Particle):void {
        particles[numParticles++] = p;
    }
}