package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.utils.Timer;
    import frocessing.color.ColorHSV;


    [SWF(width=465, height=465, frameRate=60)]
    /**
     * Dumping Graphics
     * マウスクリックすると拡大するよ
     * @author yasu
     */
    public class DumpingGraphics extends Sprite
    {
        private static const MAX:int = 10;
        private static const STAGE_W:int = 465;
        private static const STAGE_H:int = 465;

        public function DumpingGraphics()
        {
            addChild(bmp = new Bitmap(bmd = new BitmapData(STAGE_W * 2, STAGE_H * 2, true, 0xFF000000)));
            bmp.scaleX = bmp.scaleY = 1 / 2;

            for (var i:int = 0; i < MAX; i++)
            {
                addChild(canvas[ i ] = new Sprite);

                colors[ i ] = [];
                var j:int = 10;
                while (j--)
                {
                    var color:ColorHSV = new ColorHSV(Math.random() * 30 + i * 15 + 180, Math.random(), 1);
                    colors[ i ].push(color.value);
                }

                target[ i ] = new Point(STAGE_W * Math.random(), STAGE_H * Math.random());

                stack[ i ] = [];

                vx[ i ] = 0;
                vy[ i ] = 0;

                nowX[ i ] = STAGE_W / 2;
                nowY[ i ] = STAGE_H / 2;

                timer[ i ] = new Timer(30 * i + 50);
                timer[ i ].addEventListener(TimerEvent.TIMER, tick);
                timer[ i ].start();
            }

            captureMatrix.scale(2, 2);

            addEventListener(Event.ENTER_FRAME, loop);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, _onDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, _onUp);
        }

        private var ac:Number = 0.02;
        private var bmd:BitmapData;

        private var bmp:Bitmap;
        private var canvas:Vector.<Sprite> = new Vector.<Sprite>(MAX, true);
        private var captureMatrix:Matrix = new Matrix();
        private var colors:Vector.<Array> = new Vector.<Array>(MAX, true);
        private var de:Number = 0.95;
        private var nowX:Vector.<Number> = new Vector.<Number>(MAX, true);
        private var nowY:Vector.<Number> = new Vector.<Number>(MAX, true);

        private var oldP:Point = new Point(STAGE_W / 2, STAGE_H / 2);
        private var speed:Number = 1;
        private var stack:Vector.<Array> = new Vector.<Array>(MAX, true);
        private var target:Vector.<Point> = new Vector.<Point>(MAX, true);
        private var timer:Vector.<Timer> = new Vector.<Timer>(MAX, true);
        private var vx:Vector.<Number> = new Vector.<Number>(MAX, true);
        private var vy:Vector.<Number> = new Vector.<Number>(MAX, true);
        private var zoom:Number = 1;

        private function _onDown(e:MouseEvent):void
        {
            zoom = 2;
        }

        private function _onUp(e:MouseEvent):void
        {
            zoom = 1;
        }

        private function loop(e:Event):void
        {
            bmd.lock();

            for (var i:int = 0; i < MAX; i++)
            {
                var oldX:Number = nowX[ i ];
                var oldY:Number = nowY[ i ];

                //加速度運動
                vx[ i ] += (target[ i ].x - nowX[ i ]) * ac;
                vy[ i ] += (target[ i ].y - nowY[ i ]) * ac;

                nowX[ i ] += vx[ i ];
                nowY[ i ] += vy[ i ];

                //減衰処理
                vx[ i ] *= de;
                vy[ i ] *= de;

                stack[ i ].push([ nowX[ i ], nowY[ i ], oldX, oldY ]);
                if (stack[ i ].length > 10)
                    stack[ i ].shift();

                canvas[ i ].graphics.clear();

                for (var j:int = 0; j < stack[ i ].length; j++)
                {
                    var o:Array = stack[ i ][ j ];
                    var rand:Number = Math.random();

                    canvas[ i ].graphics.beginFill(colors[ i ][(colors.length * Math.random()) >> 0 ], 0.5 * rand);

                    var r:Number = Math.sqrt((o[ 0 ] - o[ 2 ]) * (o[ 0 ] - o[ 2 ]) + (o[ 1 ] - o[ 3 ]) * (o[ 1 ] - o[ 3 ]))
                    r *= 0.75;
                    r *= rand * rand;
                    canvas[ i ].graphics.drawCircle(o[ 0 ], o[ 1 ], r);
                }

                target[ i ].x += (STAGE_W / 2 - target[ i ].x) * ac;
                target[ i ].y += (STAGE_H / 2 - target[ i ].y) * ac;

                bmd.draw(canvas[ i ], captureMatrix);
            }
            bmd.unlock();

            oldP.x += (target[ 0 ].x - oldP.x) * 0.05;
            oldP.y += (target[ 0 ].y - oldP.y) * 0.05;

            speed += (zoom - speed) * 0.1;

            var mt:Matrix = new Matrix();
            mt.translate(-oldP.x, -oldP.y);
            mt.scale(speed, speed);
            mt.translate(oldP.x, oldP.y);
            this.transform.matrix = mt;
        }

        private function tick(e:TimerEvent):void
        {
            for (var i:int = 0; i < MAX; i++)
            {
                if (timer[ i ] == e.currentTarget)
                    break;
            }

            target[ i ].x = mouseX;
            target[ i ].y = mouseY;
        }
    }
}