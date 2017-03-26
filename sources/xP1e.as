package
{
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.net.*;
    import flash.text.*;
    import flash.utils.*;
    
    import com.bit101.components.PushButton;
    
    [SWF(width = "465", height = "465", frameRate = "60", backgroundColor="0x000000")]
    public class WarpSmash extends Sprite
    {
        private var isGameOver:Boolean;
        private var gameOverCount:int;
        // スコアを見ないまま再スタートしてしまうのを防止するウェイト
        private const GAME_OVER_WAIT:int = 50;
        
        private const SCREEN_W:int = 465;
        private const SCREEN_H:int = 465;
        
        private const PADDLE_OFFSET:Number = 25;
        private var PADDLE_XS:Array = [ PADDLE_OFFSET, SCREEN_W - PADDLE_OFFSET ];
        
        private const PADDLE_HX:int = 7;
        private const PADDLE_HY:int = 50;
        // パドルの中央座標
        private var paddleX:Number = PADDLE_XS[side];
        private var paddleY:Number;
        
        // パドル左右
        private var side:int = 0;
        // テレポート中か？
        private var teleporting:Boolean;
        
        private var ballX:Number;
        private var ballY:Number;
        private var ballVX:Number;
        private var ballVY:Number;
        private var ballSpeed:Number;
        private const BALL_RADIUS:Number = 7;
        
        private var prevBallX:Number;
        
        private var paddle:Shape = new Shape();
        private var ball:Shape = new Shape();
        
        private var score:int;
        
        private var gameOverText:TextField;
        private var scoreText:TextField;
        private var instructionText:TextField;
        
        private var tweetButton:PushButton;
        
        // モーションブラーが暗くて見えないので明るくする
        private var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter(
            [
                1, 0, 0, 0, 0,
                0, 1, 0, 0, 0,
                0, 0, 1, 0, 0,
                0, 0, 0, 1, 30
            ]
        );
        private var glowFilter:GlowFilter = new GlowFilter(0x00FF00, 1, 8, 8);
        private var paddleFilters:Array = [ new BlurFilter(0, 0, 2), colorMatrixFilter, glowFilter ];
        
        public function WarpSmash()
        {
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            
            function createText(parent:Sprite, text:String, x:Number, y:Number, fontSize:Number):TextField {
                var tf:TextField = new TextField();
                tf.defaultTextFormat = new TextFormat("Helvetica", fontSize, 0xFFFFFF);
                tf.mouseEnabled = false;
                tf.x = x;
                tf.y = y;
                tf.text = text;
                tf.autoSize = TextFieldAutoSize.RIGHT;
                parent.addChild(tf);
                return tf;
            }
            
            gameOverText = createText(this, "GAME OVER", 225, 150, 23);
            gameOverText.visible = isGameOver;
            
            scoreText = createText(this, "", 252, 300, 160);
            
            instructionText = createText(this, "CLICK TO TELEPORT!", 248, 180, 23);
            
            tweetButton = new PushButton(this, 186, 216, "Tweet Your Score!", tweet);
            tweetButton.visible = isGameOver;

            var g:Graphics = paddle.graphics;
            g.beginFill(0xFFFFFF);
            g.drawRoundRect( -PADDLE_HX, -PADDLE_HY, PADDLE_HX * 2, PADDLE_HY * 2, 4, 4);
            g.endFill();
            addChild(paddle);
            
            g = ball.graphics;
            g.beginFill(0xFFFFFF);
            g.drawCircle(0, 0, BALL_RADIUS);
            g.endFill();
            ball.filters = [ glowFilter ];
            addChild(ball);
            
            initGame();
            
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        
        public function initGame():void
        {
            ballSpeed = 5;
            score = 0;
            scoreText.text = "0";
            
            side = 0;
            paddleX = PADDLE_XS[side];
            teleporting = false;
            setPaddleBlur(0);
            
            ballX = SCREEN_W;
            ballY = random(SCREEN_H * 0.1, SCREEN_H * 0.9);
            ballVX = -ballSpeed;
            ballVY = 0;
            
            isGameOver = false;
        }
        
        private function setPaddleBlur(blur:Number):void
        {
            paddleFilters[0].blurX = blur;
            paddle.filters = paddleFilters;
        }
        
        private function enterFrameHandler(event:Event):void
        {
            if (teleporting) {
                var d:Number = (PADDLE_XS[side] - paddleX) * 0.2;
                d += sign(d) * 4;
                if (Math.abs(PADDLE_XS[side] - paddleX) < d) {
                    paddleX = PADDLE_XS[side];
                    setPaddleBlur(0);
                    teleporting = false;
                } else {
                    paddleX += d;
                    setPaddleBlur(Math.abs(d * 0.65));
                }
            }
            paddleY = clamp(mouseY, PADDLE_HY, SCREEN_H - PADDLE_HY);
            
            if (!isGameOver) {
                if (!teleporting) {
                    if ((side == 0 && ballX < PADDLE_XS[0] + PADDLE_HX && prevBallX >= PADDLE_XS[0] + PADDLE_HX) ||
                        (side == 1 && ballX > PADDLE_XS[1] - PADDLE_HX && prevBallX <= PADDLE_XS[1] - PADDLE_HX)) {
                        if (Math.abs(ballY - paddleY) > PADDLE_HY + BALL_RADIUS * 0.8) {
                            isGameOver = true;
                            gameOverCount = 0;
                        } else {
                            ballSpeed = clamp(ballSpeed + 0.2, 0, 15);
                            
                            ballVX = -sign(ballVX) * ballSpeed;
                            ballVY += random( -ballSpeed, ballSpeed);
                            ballVY = clamp(ballVY, -ballSpeed, ballSpeed);
                            
                            score = clamp(score + 1, 0, 9999);
                            scoreText.text = String(score);
                        }
                    }
                }
                if (!inRange(ballX, -BALL_RADIUS, SCREEN_W + BALL_RADIUS)) {
                    isGameOver = true;
                    gameOverCount = 0;
                }
            } else {
                gameOverCount++;
            }
            if (!inRange(ballY + ballVY, BALL_RADIUS, SCREEN_H - BALL_RADIUS)) {
                ballVY = -ballVY;
            }
            prevBallX = ballX;
            ballX += ballVX;
            ballY += ballVY;
            
            paddle.x = paddleX;
            paddle.y = paddleY;
            ball.x = ballX;
            ball.y = ballY;
            
            gameOverText.visible = tweetButton.visible = isGameOver && (gameOverCount > GAME_OVER_WAIT);
        }
        
        private function mouseDownHandler(e:Event):void
        {
            if (e.target is PushButton) {
                return;
            }
            
            side = 1 - side;
            teleporting = true;
            
            if (gameOverText.visible) {
                initGame();
            }
            instructionText.visible = false;
        }
        
        private function tweet(e:MouseEvent):void
        {
            var message:String = "Score " + score + " - Warp Smash http://wonderfl.net/c/xP1e #warpsmash";
            navigateToURL(new URLRequest("https://twitter.com/intent/tweet?text=" + escapeMultiByte(message)), "_blank");
        }
        
        private function random(n:Number, m:Number):Number
        {
            return n + Math.random() * (m - n);
        }
        private function sign(n:Number):Number
        {
            if (n > 0) { return 1; }
            if (n < 0) { return -1; }
            return 0;
        }
        private function clamp(n:Number, min:Number, max:Number):Number
        {
            if (n < min) { n = min; }
            if (n > max) { n = max; }
            return n;
        }
        private function inRange(n:Number, min:Number, max:Number):Boolean
        {
            return (n >= min && n <= max);
        }
        
    }
    
}


