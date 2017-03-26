package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.text.*;
    public class FlashTest extends Sprite {
        
        private var list:Array;
        private var total:Number;
        private var shape:Sprite;
        private var samples:BitmapData;
        private var m3:Matrix3D;
        private var time:int;
        
        public function FlashTest() {
            shape = new Sprite();
            var tf:TextField = new TextField();
            tf.mouseEnabled = false;
            tf.defaultTextFormat = new TextFormat('_sans', 18);
            tf.text = 'wonderfl';
            tf.x = -0.5 * tf.textWidth;
            tf.y = -0.5 * tf.textHeight;
            shape.addChild(tf);
            
            shape.graphics.lineStyle(12, 0x000000);
            shape.graphics.drawCircle(0, 0, 64);
            shape.graphics.lineStyle();
            list = [];
            total = 0;
            for (var i:int = 0; i < 5; i++) {
                var t:Number = Math.PI / 25 * (i * i + i);
                var e:Number = i + 2;
                var r:Number = 70 - e;
                var p:Particle = new Particle();
                p.place(e, t, r * Math.sin(t), -r * Math.cos(t));
                p.bend(0.97, 1, -0.19 * Math.random() - 0.01);
                list.push(p);
                total += e;
            }
            addEventListener(Event.ENTER_FRAME, grow);
            
            shape.filters = [new GlowFilter(0x000000, 0.5, 8, 8, 1, BitmapFilterQuality.HIGH)];
            samples = new BitmapData(512, 1, false, 0x808080);
            samples.perlinNoise(60, 2, 3, new Date().getTime(), true, true, BitmapDataChannel.GREEN | BitmapDataChannel.BLUE);
            time = 0;
            shape.transform.matrix3D = m3 = new Matrix3D();
            addEventListener(Event.ENTER_FRAME, wobble);
            
            var back:BitmapData = new BitmapData(465, 465, false, 0xffffff);
            back.perlinNoise(465, 465, 9, new Date().getTime(), false, true, 7, true);
            back.colorTransform(back.rect, new ColorTransform(1, 1, 1, 1, 100, 100, 100, 0));
            var grad:Shape = new Shape();
            grad.graphics.beginGradientFill(GradientType.RADIAL, [0x00ace2, 0x000000], [1, 1], [0, 255], new Matrix(0.6, 0, 0, 0.6, 232.5, 232.5));
            grad.graphics.drawRect(0, 0, 465, 465);
            back.draw(grad, null, null, BlendMode.MULTIPLY);
            addChild(new Bitmap(back));
            
            addChild(shape);
        }
        
        private function grow(e:Event):void {
            var prob:Number = 0.5 * (1 - total / 20);
            total *= 0.97;
            for (var i:int = 0; i < list.length; i++) {
                var p:Particle = list[i];
                var x1:Number = p.x + p.b;
                var y1:Number = p.y - p.a;
                var x2:Number = p.x - p.b;
                var y2:Number = p.y + p.a;
                p.advance();
                var x3:Number = p.x - p.b;
                var y3:Number = p.y + p.a;
                var x4:Number = p.x + p.b;
                var y4:Number = p.y - p.a;
                shape.graphics.beginFill(0x000000);
                shape.graphics.moveTo(x1, y1);
                shape.graphics.lineTo(x2, y2);
                shape.graphics.lineTo(x3, y3);
                shape.graphics.lineTo(x4, y4);
                shape.graphics.endFill();
                shape.graphics.beginFill(0x000000);
                shape.graphics.moveTo(-x1, -y1);
                shape.graphics.lineTo(-x2, -y2);
                shape.graphics.lineTo(-x3, -y3);
                shape.graphics.lineTo(-x4, -y4);
                shape.graphics.endFill();
                
                if (Math.random() < prob) {
                    list.push(p.fork());
                    total += p.e * 0.8;
                }
                
                if (p.e < 0.4) {
                    if (list.length == 1) {
                        removeEventListener(Event.ENTER_FRAME, grow);
                        return;
                    } else {
                        list.splice(i--, 1);
                    }
                }
            }
        }
        
        private function wobble(e:Event):void {
            var u:uint = samples.getPixel(time++ % samples.width, 0);
            var x:Number = (u & 0xff) - 127.5;
            var y:Number = (u >> 8 & 0xff) - 127.5;
            var r2:Number = x * x + y * y;
            var r:Number = Math.sqrt(r2);
            var h:Number = Math.sqrt(r2 + 150 * 150);
            var s:Number = r / h;
            var c:Number = 150 / h;
            var v:Vector.<Number> = m3.rawData;
            v[0] = (c * x * x + y * y) / r2;
            v[1] = (c * x * y - x * y) / r2;
            v[2] = s * x / r;
            v[4] = (c * x * y - x * y) / r2;
            v[5] = (x * x + c * y * y) / r2;
            v[6] = s * y / r;
            v[8] = -s * x / r;
            v[9] = -s * y / r;
            v[10] = c;
            v[12] = -100 * v[8] + 232.5;
            v[13] = -100 * v[9] + 235.5;
            v[14] = -100 * v[10] + 100;
            m3.rawData = v;
            // removeEventListener(Event.ENTER_FRAME, wobble);
        }
        
    }
}

internal class Particle {
    
    public var a:Number;
    public var b:Number;
    public var x:Number;
    public var y:Number;
    public var da:Number;
    public var db:Number;
    public var dx:Number;
    public var dy:Number;
    
    public function get e():Number {
        return Math.sqrt(a * a + b * b);
    }
    
    public function place(v:Number, r:Number, x:Number, y:Number):void {
        this.a = v * Math.cos(r);
        this.b = v * Math.sin(r);
        this.x = x;
        this.y = y;
    }
    
    public function bend(s:Number, t:Number, r:Number):void {
        var sin:Number = Math.sin(r);
        var cos:Number = Math.cos(r);
        da = s * cos;
        db = s * sin;
        dx = t * cos;
        dy = t * sin;
    }
    
    public function advance():void {
        var na:Number = a * da - b * db;
        var nb:Number = b * da + a * db;
        a = na;
        b = nb;
        x += a * dx - b * dy;
        y += b * dx + a * dy;
    }
    
    public function fork():Particle {
        var p:Particle = new Particle();
        p.a = a * 0.8; p.b = b * 0.8; p.x = x; p.y = y;
        p.bend(0.95, 1, (Math.random() - 0.5) * 0.4);
        return p;
    }
    
}
