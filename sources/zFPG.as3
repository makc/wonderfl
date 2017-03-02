//    Epic laser
package
{
//    author Bobyshev Alexander
    import flash.display.Sprite;
    import flash.events.MouseEvent;

    [SWF(frameRate="60", backgroundColor=0xCCCCCC, width="465", height="465")]
    public class Main extends Sprite
    {
        private var laser:Laser;
        private var targets:Vector.<Target> = new Vector.<Target>();

        public function Main()
        {
            laser = new Laser();
            laser.x = stage.stageWidth * 0.5;
            laser.y = stage.stageHeight - 20;
            stage.addChild(laser);
            graphics.beginFill(0x0);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            graphics.endFill();
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            populate();
        }

        private function populate():void
        {
            for (var i:int = 9; i > 0; i--)
            {
                var target:Target = new Target(Math.random() * (stage.stageWidth - 50) + 25,
                    Math.random() * (stage.stageHeight - 150) + 25, Math.random() * 90 + 10);
                targets.push(target);
                stage.addChild(target);
            }
        }

        private function onMouseDown(event:MouseEvent):void
        {
            laser.charge();
        }

        private function onMouseMove(event:MouseEvent):void
        {
            if (targets.length == 0)
            {
                populate();
            }
            laser.aim(event.stageX, event.stageY);
        }

        private function onMouseUp(event:MouseEvent):void
        {
            laser.shoot(targets);
        }
    }
}

import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.geom.Matrix;

class Laser extends Sprite
{
    private var _charge:Number = 0;
    private var isCharging:Boolean = false;
    private var particles:Vector.<EnergyParticle> = new Vector.<EnergyParticle>();
    private var ray:Ray;
    private var glow:GlowFilter = new GlowFilter(0xFFFFFF, 1.0, 1.0, 1.0, 2, 2);
    private var f:Array = [glow];
    private var targetAngle:Number = 180;
    private var targets:Vector.<Target>;

    public function Laser()
    {
        rotation = 180;
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(20, 80);
        with (graphics)
        {
            lineStyle(1);
            beginGradientFill(GradientType.LINEAR, [0, 0xFFFFFF], null, [0, 200], matrix, SpreadMethod.REFLECT);
            drawRect(-10, -10, 20, 50);
            endFill();
        }
        addEventListener(Event.ENTER_FRAME, onFrame);
    }

    public function charge():void
    {
        if (_charge > 0) return;
        isCharging = true;
    }

    public function aim(stageX:Number, stageY:Number):void
    {
        var angle:Number = (Math.atan2(stageY - y, stageX - x) - Math.PI * 0.5) * 180 / Math.PI;
        if (angle < 180) angle += 360;
        if (angle > 180) angle -= 360;
        targetAngle = angle;
    }

    public function shoot(targets:Vector.<Target>):void
    {
        isCharging = false;
        this.targets = targets;
    }

    private function onFrame(event:Event):void
    {
        var p:EnergyParticle;
        if (isCharging)
        {
            //generate particles
            for each(p in particles)
            {
                p.update();
            }
            _charge += 1;
            if (_charge > 100) _charge = 100;
            if (Math.abs(Math.round(_charge) - _charge) < 0.01)
            {
                var angle:Number = rotation / 180 * Math.PI + Math.PI * 0.5;
                p = new EnergyParticle(x + 50 * Math.cos(angle), y + 50 * Math.sin(angle), _charge, _charge);
                stage.addChild(p);
                particles.push(p);
            }
        }
        else
        if (_charge > 0 && particles.length == 0)
        {
            //create ray
            if (ray == null)
            {
                ray = new Ray(x, y, rotation);
                stage.addChildAt(ray, 1);
            }
            ray.charge = _charge;
            if (_charge > 0)
            {
                processTargets();
            }
            _charge -= 1;
            if (_charge <= 0)
            {
                _charge = 0;
                stage.removeChild(ray);
                ray = null;
            }
        }
        if (!isCharging)
        {
            for (var i:int = particles.length - 1; i >= 0; i--)
            {
                p = particles[i];
                p.alpha -= 0.02;
                if (p.alpha <= 0)
                {
                    stage.removeChild(p);
                    particles.splice(i, 1);
                }
                else p.update();
            }
        }
        if (_charge == 0)
        {
            var delta:Number = targetAngle - rotation;
            if (delta < -180) delta += 360;
            if (delta > 180) delta -= 360;
            rotation += delta > 0 ? Math.min(1, delta) : Math.max(-1, delta);
        }
        glow.alpha = _charge * 0.1;
        var blur:Number = Math.max((_charge - 50) * 0.2, 0);
        glow.blurX = glow.blurY = blur;
        filters = f;
    }

    private function processTargets():void
    {
        var x1:Number = ray.x - 100 * Math.cos((ray.rotation - 90) / 180 * Math.PI);
        var y1:Number = ray.y - 100 * Math.sin((ray.rotation - 90) / 180 * Math.PI);
        var a:Number = ray.y - y1;
        var b:Number = x1 - ray.x;
        var c:Number = -b * y1 - x1 * a;
        for (var i:int = targets.length - 1; i >= 0; i--)
        {
            var target:Target = targets[i];
            if (target.parent == null)
            {
                targets.splice(i, 1);
                return;
            }
            var distance:Number = Math.abs(a * target.x + b * target.y + c) / Math.sqrt(a * a + b * b);
            if ((target.radius + ray.rayWidth * 0.5) > distance)
            {
                target.hit(_charge);
            }
        }
    }
}

class Ray extends Sprite
{
    public var rayWidth:Number;

    private var glow:GlowFilter = new GlowFilter(0xFF0000, 1.0, 3, 3, 1, 1);
    private var f:Array = [glow];

    public function Ray(x:Number, y:Number, rotation:Number)
    {
        this.x = x;
        this.y = y;
        this.rotation = rotation;
    }

    public function set charge(value:Number):void
    {
        rayWidth = value * 0.2;
        graphics.clear();
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(-rayWidth * 0.5, 0, rayWidth, 1000);
        graphics.endFill();
        glow.blurX = value * 0.1;
        filters = f;
    }
}

class EnergyParticle extends Sprite
{
    private var glow:GlowFilter;
    private var _time:Number = 0;
    private var f:Array;
    private var targetX:Number;
    private var targetY:Number;

    public function EnergyParticle(x:Number, y:Number, minR:Number, maxR:Number)
    {
        super();
        targetX = x;
        targetY = y;
        var r:Number = Math.random() * (maxR - minR) + minR;
        var a:Number = (2 * Math.random() - 1) * Math.PI;
        this.x = x + r * Math.cos(a);
        this.y = y + r * Math.sin(a);
        graphics.beginFill(0xFFFFFF);
        graphics.drawCircle(0, 0, 10);
        graphics.endFill();
        scaleX = scaleY = 0;
        glow = new GlowFilter(0xFFFFFF, 1.0, 0, 0, 2, 2);
        f = [glow];
    }

    public function update():void
    {
        _time += 1;
        time = _time;
        var dx:Number = x - targetX;
        var dy:Number = y - targetY;
        x -= dx * 0.1;
        y -= dy * 0.1;
    }

    public function set time(value:Number):void
    {
        var scale:Number = value * (2 / 100.0);
        if (scale > 0.5) scale = 0.5;
        scaleX = scaleY = scale;
        var glowScale:Number = value * (20.0 / 100.0);
        if (glowScale > 5) glowScale = 5;
        glow.blurX = glow.blurY = glowScale;
        filters = f;
    }
}

class TargetParticle extends Sprite
{
    public var speedX:Number;
    public var speedY:Number;

    public function TargetParticle(x:Number, y:Number, radius:Number)
    {
        this.x = x;
        this.y = y;
        graphics.beginFill(0xFFFFFF);
        graphics.drawCircle(-radius * 0.5, -radius * 0.5, radius);
        graphics.endFill();
    }
}

class Target extends Sprite
{
    public var radius:Number;
    public var maxCharge:Number;

    private var particles:Vector.<TargetParticle>;
    private var dead:Boolean = false;
    private var wounded:Boolean = false;
    private var glow:GlowFilter;

    public function Target(x:Number, y:Number, maxCharge:Number)
    {
        radius = maxCharge * 0.2;
        this.maxCharge = maxCharge;
        var r2:Number = radius * 0.5;
        graphics.beginFill(0xFFFFFF);
        graphics.drawCircle(0, 0, radius);
        graphics.endFill();
        graphics.lineStyle(1, 0xFFFFFF);
        //graphics.drawRect(-radius*2, 0, 4*radius, 1);
        //graphics.drawRect(0, -radius*2, 1, 4*radius);
        this.x = x;
        this.y = y;
        addEventListener(Event.ENTER_FRAME, onFrame);
    }

    public function hit(charge:Number):void
    {
        if (dead) return;
        if (charge > maxCharge)
        {
            //explode
            dead = true;
            particles = new Vector.<TargetParticle>();
            for (var i:Number = maxCharge; i > 0; i -= 0.2)
            {
                var r:Number = radius * (Math.random() * 0.2 + 0.1);
                var p:TargetParticle = new TargetParticle(x + Math.random() * (radius - r),
                                              y + Math.random() * (radius - r), r);
                var speed:Number = Math.random() * 5 + 3;
                var angle:Number = Math.random() * Math.PI * 2;
                p.speedX = speed * Math.cos(angle);
                p.speedY = speed * Math.sin(angle);
                stage.addChild(p);
                particles.push(p);
            }
        }
        else
        {
            //glow
            var blur:Number;
            if (glow == null)
            {
                blur = charge * 0.5;
                glow = new GlowFilter(0xFFFFFF, 1.0, blur, blur, 2, 2);
                filters = [glow];
            }
        }
    }

    private function onFrame(event:Event):void
    {
        if (dead)
        {
            if (alpha > 0) alpha -= 0.08;
            for (var i:int = particles.length - 1; i >= 0; i--)
            {
                var p:TargetParticle = particles[i];
                p.x += p.speedX;
                p.y += p.speedY;
                p.alpha -= 0.01;
                if (p.alpha <= 0)
                {
                    stage.removeChild(p);
                    particles.splice(i, 1);
                }
            }
            if (particles.length == 0 && alpha <= 0)
            {
                removeEventListener(Event.ENTER_FRAME, onFrame);
                parent.removeChild(this);
            }
        }
        else
        {
            if (glow != null)
            {
                var blur:Number = glow.blurX * 0.95;
                if (blur < 1)
                {
                    filters = [];
                    glow = null;
                    return;
                }
                glow.blurX = glow.blurY = blur;
                filters = [glow];
            }
        }
    }
}