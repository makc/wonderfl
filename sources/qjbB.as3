/*
 * SPH - Smoothed Particle Hydrodynamics
 *
 * クリック：水を注ぐ
 * Click:Pouring
 * 
 * SPH(もどき)をASで実装してみました。
 * 最適化していないので重いです。
 * タイムステップを考えていなかったりといろいろ適当な部分がありますので注意。
 * カーネルを除く基本的な計算方法は一緒です。
 */
package {
    import flash.text.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.events.*;
    import flash.display.*;
    [SWF(frameRate = 60)]
    public class SPH extends Sprite {
        public static const GRAVITY:Number = 0.05;//重力
        public static const RANGE:Number = 12;//影響半径
        public static const RANGE2:Number = RANGE * RANGE;//影響半径の二乗
        public static const DENSITY:Number = 1;//流体の密度
        public static const PRESSURE:Number = 2;//圧力係数
        public static const VISCOSITY:Number = 0.075;//粘性係数
        private var img:BitmapData;
        private var particles:Vector.<Particle>;
        private var numParticles:uint;
        private var color:ColorTransform;
        private var filter:BlurFilter;
        private var count:int;
        private var press:Boolean;

        public function SPH() {
            initialize();
        }
        
        private function initialize():void {
            color = new ColorTransform(0.5, 0.9, 0.95);
            filter = new BlurFilter(2, 2, 1);
            particles = new Vector.<Particle>();
            numParticles = 0;
            count = 0;
            img = new BitmapData(465, 465, false, 0);
            addChild(new Bitmap(img));
            addEventListener(Event.ENTER_FRAME, frame);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {press = true;});
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {press = false;});
        }

        private function frame(e:Event):void {
            if(press)
                pour();
            move();
            img.lock();
            img.colorTransform(img.rect, color);
            img.applyFilter(img, img.rect, new Point(), filter);
            draw();
            img.unlock();
        }

        private function draw():void {
            for(var i:int = 0; i < numParticles; i++) {
                var p:Particle = particles[i];
                img.fillRect(new Rectangle(p.x - 1, p.y - 1, 2, 2), p.color);
                //img.setPixel(p.x, p.y, p.color);
            }
        }

        private function pour():void {
                for(var i:int = -3; i <= 3; i++) {
                     particles[numParticles++] = new Particle(mouseX + i * 8, 5);
                     particles[numParticles - 1].vy = 5;
                }
        }

        private function move():void {
            count++;
            var i:int;
            var j:int;
            var dist:Number;
            var pi:Particle;
            var pj:Particle;
            var dx:Number;
            var dy:Number;
            var weight:Number;
            var pressureWeight:Number;
            var viscosityWeight:Number;
            for(i = 0; i < numParticles; i++) {
                pi = particles[i];
                pi.numNeighbors = 0;
                for(j = 0; j < i; j++) {
                    pj = particles[j];
                    if((pi.x - pj.x) * (pi.x - pj.x) + (pi.y - pj.y) * (pi.y - pj.y) < RANGE2) {
                        pi.neighbors[pi.numNeighbors++] = pj;
                        pj.neighbors[pj.numNeighbors++] = pi;
                    }
                }
            }
            for(i = 0; i < numParticles; i++) {
                pi = particles[i];
                pi.density = 0;
                for(j = 0; j < pi.numNeighbors; j++) {
                    pj = pi.neighbors[j];
                    dist = Math.sqrt((pi.x - pj.x) * (pi.x - pj.x) + (pi.y - pj.y) * (pi.y - pj.y));
                    pi.density += (1 - dist / RANGE) * (1 - dist / RANGE);
                }
                if(pi.density < DENSITY)
                    pi.density = DENSITY;
                pi.pressure = pi.density - DENSITY;
            }
            for(i = 0; i < numParticles; i++) {
                pi = particles[i];
                pi.fx = 0;
                pi.fy = 0;
                for(j = 0; j < pi.numNeighbors; j++) {
                    pj = pi.neighbors[j];
                    dx = pi.x - pj.x;
                    dy = pi.y - pj.y;
                    dist = Math.sqrt(dx * dx + dy * dy);
                    weight = 1 - dist / RANGE;
                    pressureWeight = weight * (pi.pressure + pj.pressure) / (2 * pj.density) * PRESSURE;
                    dist = 1 / dist;
                    dx *= dist;
                    dy *= dist;
                    pi.fx += dx * pressureWeight;
                    pi.fy += dy * pressureWeight;
                    viscosityWeight = weight / pj.density * VISCOSITY;
                    dx = pi.vx - pj.vx;
                    dy = pi.vy - pj.vy;
                    pi.fx -= dx * viscosityWeight;
                    pi.fy -= dy * viscosityWeight;
                }
            }
            for(i = 0; i < numParticles; i++) {
                pi = particles[i];
                pi.move();
            }
        }
    }
}

class Particle {
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var fx:Number;
    public var fy:Number;
    public var density:Number;
    public var pressure:Number;
    public var neighbors:Vector.<Particle>;
    public var numNeighbors:int;
    public var color:int;
    public function Particle(x:Number, y:Number) {
        this.x = x;
        this.y = y;
        vx = vy = fx = fy = 0;
        neighbors = new Vector.<Particle>();
        color = 0xffffff;
    }

    public function move():void {
        vy += SPH.GRAVITY;
        vx += fx;
        vy += fy;
        x += vx;
        y += vy;
        if(x < 5)
            vx += 5 - x;
        if(y < 5)
            vy += 5 - y;
        if(x > 460)
            vx += 460 - x;
        if(y > 460)
            vy += 460 - y;
    }
}
