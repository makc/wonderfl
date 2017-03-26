// forked from shinh's circle pong
package {
    import flash.display.*
    import flash.geom.*
    import flash.text.*
    import flash.events.*
    public class CirclePong extends Sprite {
        private var screen:BitmapData
        private const W:int = 465, H:int = 465
        private var ba:Number = 0, bv:Number = 0
        private var cnt:int, noColCnt:int
        private var running:Boolean
        private var ball:Shape = new Shape()
        private var wall:Shape = new Shape()
        private var score:TextField = new TextField()
        private var text:TextField = new TextField()
        private var dbg:TextField = new TextField()
        private function makeTextField(t:TextField, x:int, y:int, s:int):TextField {
            t.x = x
            t.y = y
            t.width = W
            t.height = H
            var fm:TextFormat = new TextFormat
            fm.color = 0xffffff
            fm.font = '_typewriter'
            fm.size = s
            fm.bold = true
            t.defaultTextFormat = fm
            return t
        }
        public function CirclePong() {
            addChild(new Bitmap(screen = new BitmapData(W, H, false, 0)))
            ball.graphics.beginFill(0xffffff)
            ball.graphics.drawCircle(0, 0, 7)
            addChild(ball)
            wall.graphics.beginFill(0xffffff)
            wall.graphics.drawRect(-25, -2, 50, 5)
            addChild(wall)
            score.text = '0'
            addChild(makeTextField(score, 10, 10, 20))
            addChild(makeTextField(text, 100, 150, 30))
            addChild(makeTextField(dbg, 0, 20, 10))
            ball.x = -50
            running = true
            addEventListener(Event.ENTER_FRAME, update)
            addEventListener(MouseEvent.CLICK, init)
        }
        public function init(event:MouseEvent): void {
            if (running) return
            running = true
            bv = 2
            ba = 0
            ball.x = W / 2
            ball.y = H / 2
            score.text = '' + (cnt = 0)
            text.text = ''
        }
        public function update(event:Event): void {
            var a:Number = Math.atan2(stage.mouseX - W / 2,
                                      stage.mouseY - H / 2)
            var bx:Number = ball.x - W / 2
            var by:Number = ball.y - H / 2
            var da:Number = Math.abs(Math.atan2(bx, by) - a)
            if ((noColCnt -= 1) < 0 &&
                (da < 0.2 || da > Math.PI * 2 - 0.2) &&
                Math.abs(Math.sqrt(bx*bx + by*by) - 200) < 10) {
                ba = Math.PI - ba + a * 2
                bv += 0.3
                score.text = '' + (cnt += 1)
                noColCnt = 10
            }
            wall.rotation = - a / 3.141592 * 180
            ball.x += bv * Math.sin(ba)
            ball.y += bv * Math.cos(ba)
            wall.x = W / 2 + Math.sin(a) * 200
            wall.y = H / 2 + Math.cos(a) * 200
            if ((ball.x < 0 || ball.x > W ||
                 ball.y < 0 || ball.y > H) && running) {
                text.text = ' Circle  Pong\n\n\n  GAME  OVER\nCLICK TO START'
                running = false
            }
        }
    }
}