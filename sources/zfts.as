/*
 * 上部にあるミニ画面内の光っているボールの位置を覚えて、
 * 同じ配置になるようにボールをクリックしてください。
 * 
 * Wonderflにログインしないとランキングに登録できません。
 * ランキングウィンドウを閉じるには右上の四角マークをクリックします。
 */
﻿package
{
    import flash.display.Bitmap;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BevelFilter;
    import flash.filters.GlowFilter;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    import net.wonderfl.score.basic.BasicScoreForm;
    import net.wonderfl.score.basic.BasicScoreRecordViewer;
     
    public class Main extends Sprite
    {
        public static var container:Main;
        private var miniBoard:MiniBoard;
        private var mainBoard:MainBoard;
        private var timer:Timer;
        public var life:Gauge;
        public var hint:Gauge;
        
        public function Main()
        {            
            Main.container = this;
            initialize();
        }
        
        private function initialize():void
        {
            removeEventListener(Event.ENTER_FRAME, update);
            
            Status.noMissBonus = 500;
            Stage.nowStage = 1;
            Stage.nowFloor = 0;
            
            graphics.clear();
            graphics.beginFill(0x0);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            graphics.endFill();
            
            while (this.numChildren) removeChildAt(0);
            
            var tf:TextField = Utils.createTextField("CLICK TO START", 20, 0xFFFFFF);
            tf.x = (stage.stageWidth - tf.width) / 2;
            tf.y = 300;
            addChild(tf);
            
            var button:Sprite = new Sprite();
            addChild(button);
            
            tf = Utils.createTextField("STM.", 45, 0x0);
            tf.filters = [new GlowFilter(0xF0F0F0, 1, 30, 30, 10)];
            button.addChild(tf);
            
            button.buttonMode = true;
            button.mouseChildren = false;
            button.filters = [new GlowFilter(0x009AD6, 1, 8, 8, 1), new BevelFilter(4, 45, 0x009aD6, 1, 0xFF00000, 1, 4, 4, 1, 3)];
            button.x = (stage.stageWidth - button.width) / 2;
            button.y = 150;
            
            stage.addEventListener(MouseEvent.CLICK, initialize2);
        }
        
        private function initialize2(event:MouseEvent = null):void
        {
            stage.removeEventListener(MouseEvent.CLICK, initialize2);
            while (this.numChildren) removeChildAt(0);
            
            mainBoard = new MainBoard();
            mainBoard.x = 150;
            mainBoard.y = 330;
            addChild(mainBoard);
            
            miniBoard = new MiniBoard();
            miniBoard.x = 160;
            miniBoard.y = 80;
            addChild(miniBoard);
            
            timer = new Timer();
            timer.x = 30;
            timer.y = 160;
            addChild(timer);
            
            Score.init(this, 350, 120);
            Score.setScore = Score.setCurrentScore = 0;
            
            life = new Gauge(0x009AD6, "Life", 6);
            life.x = 380, life.y = 30;
            addChild(life);
            life.setValue(3);
            
            hint = new Gauge(0xED1A3D, "Hint", 6);
            hint.x = 380, hint.y = 55;
            addChild(hint);
            hint.setValue(2);
            
            var up:State = new State(0xFFFFFF);
            var over:State = new State(0xFF9900);
 
            var button:SimpleButton = new SimpleButton(up, over, over, over);
            button.x = 400;
            button.y = hint.y + hint.height;
            button.addEventListener(MouseEvent.CLICK, hintButtonClick);
            addChild(button);
            
            nextStage();
        }
        
        private function hintButtonClick(e:MouseEvent):void 
        {
            if (!hint.value || !mainBoard.clickable) return;
            if (miniBoard.alpha < 0.3) miniBoard.alpha = 0.7;
            else miniBoard.alpha = 1.0;
            hint.setValue(hint.value - 1);
        }
        
        private function nextStage():void
        {
            Stage["stage" + Stage.nowStage]();
            Status.hitCount = 0;
            Status.noMiss = true;
            mainBoard.init();
            miniBoard.init();
            miniBoard.setBall();
            timer.init();
            mainBoard.clickable = true;
            
            if (Stage.rotation) miniBoard.mark.visible = true;
            else miniBoard.mark.visible = false;
            
            addEventListener(Event.ENTER_FRAME, update);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function update(event:Event):void
        {
            Score.update();
        }
        
        private function onEnterFrame(event:Event):void 
        {
            if (Status.hitCount == Status.hitBall) clear();
            
            miniBoard.alpha -= Stage.speed;
            timer.w -= Stage.time;
            timer.update();
            
            miniBoard.rotation += Stage.rotation;
            
            if (timer.w == 0 || life.value == 0) gameOver();
        }
        
        private function gameOver():void
        {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            mainBoard.clickable = false;
            
            Score.setCurrentScore = Score.getScore;
            
            var bitmap:Bitmap = Utils.textToBitmap(Utils.createTextField("GAME OVER", 20, 0xFFFFFF));
            bitmap.x = 330;
            bitmap.y = 170;
            bitmap.alpha = 0.0;
            addChild(bitmap);
            
            BetweenAS3.serial
            (
                BetweenAS3.tween(bitmap, { alpha:1.0 } ),
                BetweenAS3.delay(BetweenAS3.func(result), 1.0)
            ).play();
        }
        
        private function result():void
        {
            new MyScoreForm(this, (465 - BasicScoreForm.WIDTH) / 2, (465 - BasicScoreForm.HEIGHT) / 2, Score.getScore, showRanking);
        }
        
        private function showRanking():void
        {
            var viewer:BasicScoreRecordViewer = new BasicScoreRecordViewer(this, 122.5, 112.5, "RANKING", 30, true, closeHandler);
            
            function closeHandler():void
            {
                viewer.parent.removeChild(viewer);
                BetweenAS3.delay(BetweenAS3.func(initialize), 1.0).play();
            }
        }
        
        private function clear():void
        {
            mainBoard.clickable = false;
            if (hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            var ty:int = 170;
            var i:int, t:ITween, ball:Ball;
            Stage.nowFloor++;
            if (Stage.nowFloor != Stage.floor)
            {
                for (i = 0; i < Status.hitBall; i++)
                {
                    ball = mainBoard.balls[Status.hits[i]];
                    ball.visible = false;
                    Effect.diamond(this, 20, mainBoard.x + ball.x, mainBoard.y + ball.y, 5 + Math.random() * 4, 0.7);
                }
                t = BetweenAS3.tween(timer, { w:0 } )
                t.onUpdate = timer.update;
                t.onComplete = nextStage;
                t.play();
                
                Score.setScore = Score.getScore + Stage.nowStage * 1000;
            }
            else
            {
                for (i = 0; i < mainBoard.balls.length; i++)
                {
                    ball = mainBoard.balls[i];
                    ball.visible = false;
                    Effect.diamond(this, 30, mainBoard.x + ball.x, mainBoard.y + ball.y, 20 + Math.random() * 4, 0.4);
                }
                t = BetweenAS3.tween(timer, { w:0 } )
                t.onUpdate = timer.update;
                t.onComplete = stageClear;
                t.play();
                
                Score.setScore = Score.getScore + Stage.nowStage * 3000;
                Effect.createScoreText(this, 470, ty, "Life & Hint\n BONUS", life.value * 800 + hint.value * 500);
                ty += 100;
            }
            
            if (Status.noMiss)
            {
                Effect.createScoreText(this, 470, ty, "NO MISS\n BONUS", Status.noMissBonus);
                ty += 100;
                
                Status.noMissBonus += 50;
            }
            else Status.noMissBonus = 500;
            
            Effect.createScoreText(this, 470, ty, "TIME\n BONUS", int(timer.w * 5));
        }
        
        private function stageClear():void
        {
            miniBoard.rotation = 0;
            
            var str:String = (Stage.nowStage + 1 <= Stage.MAXSTAGE) ? "STAGE " + Stage.nowStage + "\n CLEAR!!" : "ALL STAGE\n CLEAR!!";
            var clear:Bitmap = Utils.textToBitmap(Utils.createTextField(str, 20, 0xFFFFFF));
            clear.x = 340;
            clear.y = 180;
            addChild(clear);
            
            Stage.nowStage++;
            Stage.nowFloor = 0;
            
            var button:Sprite = new Sprite();
            if (Stage.nowStage <= Stage.MAXSTAGE) addChild(button);
            else
            {
                BetweenAS3.delay(BetweenAS3.func(result), 4.0).play();
            }
            
            var tf:TextField = Utils.createTextField("Next Stage", 16, 0x0);
            tf.filters = [new GlowFilter(0xF0F0F0, 1, 30, 30, 10)];
            button.addChild(tf);
            
            button.buttonMode = true;
            button.mouseChildren = false;
            button.filters = [new GlowFilter(0x009AD6, 1, 8, 8, 1), new BevelFilter(4, 45, 0xF8ABA6, 1, 0xF8ABA6, 1, 4, 4, 1, 3)];
            button.x = 340;
            button.y = 250;
            button.addEventListener(MouseEvent.CLICK, stageClear2);
            
            clear.alpha = button.alpha = 0.0;
            BetweenAS3.delay
            (
                BetweenAS3.serial
                (
                    BetweenAS3.addChild(clear, this),
                    BetweenAS3.parallel
                    (
                        BetweenAS3.tween(clear, { alpha:1.0 }, null),
                        BetweenAS3.tween(button, { alpha:1.0 }, null)
                    )
                ), 2.6
            ).play();
            
            var _this:Sprite = this;
            function stageClear2():void
            {
                if (Stage.nowStage % 2) life.setValue(life.value + 1);
                else hint.setValue(hint.value + 1);
                BetweenAS3.parallel
                (
                    BetweenAS3.tween(button, { alpha:0.0 } ),
                    BetweenAS3.tween(clear, { alpha:0.0 } )
                ).play();
                nextStage();
            }
        }
    }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import frocessing.math.Random;
import org.libspark.betweenas3.BetweenAS3;
import net.wonderfl.score.basic.BasicScoreForm;
import com.bit101.components.Label;

class MyScoreForm extends BasicScoreForm
{
    private var complete:Function;
    
    public function MyScoreForm(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, score:int = 0, complete:Function = null)
    {        
        super(parent, xpos, ypos, score, "Score");
        
        var stage:String = (Stage.nowStage > Stage.MAXSTAGE) ? "ALL" : "Stage" + Stage.nowStage; 
        _lblScore.text = stage + " - " + score;
        _lblYourScore.text = "SCORE";
        _lblYourName.text = "PLAYER";
        _userNameField.visible = false;
        new Label(this, _lblScore.x, _userNameField.y, _userNameField.text);
        this.complete = complete;
        
        if (_userNameField.text == "anonymous")
        {
            _btnSend.enabled = false;
            var label:Label = new Label(this, 0, 0, "You are not currently logged in.");
            label.y = _btnSend.y + _btnSend.height;
            label.x = (BasicScoreForm.WIDTH - label.width) / 2; 
        }
    }
    
    override protected function _onCloseClick($didSendComplete:Boolean):void 
    {        
        this.parent.removeChild(this);
        complete();        
    }
}

class Ball extends Sprite
{
    public static const RADIUS:Number = 25;
    public var clicked:Boolean = false;
    public var id:int;
    
    public function Ball(id:int)
    {
        this.id = id;
        
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(RADIUS * 2, RADIUS * 2, 45 * Math.PI / 180, -RADIUS, -RADIUS);
        graphics.lineStyle(1.0, 0x222222);
        graphics.beginGradientFill("linear", [0xFFFFFF, 0x777777], [1.0, 1.0], [0, 255], matrix);
        graphics.drawCircle(0, 0, RADIUS);
        graphics.endFill();
        
        addEventListener(MouseEvent.CLICK, onMouseClick);
    }
    
    private function onMouseClick(event:MouseEvent):void
    {
        if (!Board(this.parent).clickable) return;
        if (clicked) return;
        clicked = true;
        
        var index:int = Status.hits.indexOf(id)
        if (index != -1)
        {
            Status.hitCount++;
            select();
        }
        else
        {
            graphics.clear();
            graphics.lineStyle(1.0, 0x0);
            graphics.beginFill(0x009AD6);
            graphics.drawCircle(0, 0, RADIUS);
            graphics.endFill();
            
            var life:Gauge = Main.container.life;
            life.setValue(life.value - 1);
            Status.noMiss = false;
        }
    }
    
    public function select():void
    {
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(RADIUS * 2, RADIUS * 2, 45 * Math.PI / 180, -RADIUS, -RADIUS);
        graphics.clear();
        graphics.lineStyle(1.0, 0x0);
        graphics.beginGradientFill("linear", [0xFF9900, 0xFF9933], [1.0, 1.0], [0, 255], matrix);
        graphics.drawCircle(0, 0, RADIUS);
        graphics.endFill();
    }
}

class Board extends Sprite
{
    public var balls:/*Ball*/Array = [];
    public var clickable:Boolean;
    
    public function Board()
    {    
    }
    
    public function init():void
    {
        alpha = 1.0;
        
        for (var i:int = 0; i < balls.length; i++) removeChild(balls[i]);
        balls = [];
        
        var num:int = 0;
        for (var y:int = 0; y < 5; y++)
        {
            for (var x:int = 0; x < 5; x++)
            {
                if ((y == 0 && x == 0) ||
                    (y == 0 && x == 4) ||
                    (y == 4 && x == 0) ||
                    (y == 4 && x == 4)) continue;
                var ball:Ball = new Ball(num++);
                ball.y = y * Ball.RADIUS * 2 - 4 * Ball.RADIUS
                ball.x = x * Ball.RADIUS * 2 - 4 * Ball.RADIUS
                addChild(ball);
                balls.push(ball);
            }
        }
    }
}

class Effect
{
    public static function star(container:Sprite, num:int, x:Number, y:Number, delay:Number = 0.0):void
    {
        for (var i:int = 0; i < num; i++)
        {
            var star:Shape = createPolygon(5, 0, 0, Math.random() * 7 + 5, true, 1.0, 0x0, int.MAX_VALUE * Math.random());
            star.x = x, star.y = y;
            var scale:Number = Math.random() / 2;
            
            BetweenAS3.delay
            (
                BetweenAS3.serial
                (
                    BetweenAS3.addChild(star, container),
                    BetweenAS3.tween(star, { rotation:Math.random() * 720 - 360, scaleX:scale, scaleY:scale, $x:Math.random() * 40 - 20, $y:-(Math.random() * 50 + 10) }, null, Math.random()),
                    BetweenAS3.removeFromParent(star)
                ), delay
            ).play();
        }
    }
    
    public static function diamond(container:Sprite, num:int, x:Number, y:Number, size:Number, scale:Number):void
    {
        for (var i:int = 0; i < num; i++)
        {
            var star:Shape = createPolygon(4, 0, 0, size, true, 2.0, int.MAX_VALUE * Math.random(), 0xFFFFFF);
            star.x = x, star.y = y;
            BetweenAS3.serial
            (
                BetweenAS3.addChild(star, container),
                BetweenAS3.tween(star, { rotation:Math.random() * 720 - 360, scaleX:scale, scaleY:scale, $x:Math.random() * 40 - 20, $y:-(Math.random() * 50 + 10) }, null, Math.random()),
                BetweenAS3.removeFromParent(star)
            ).play();
        }
    }

    public static function createPolygon(vertex:int, x:Number, y:Number, size:int, star:Boolean = false, thickness:Number = 1.0, lineColor:int = 0x0, color:int = 0x0):Shape
    {
        var points:Array = new Array();
        for (var degree:Number = -90; degree < 270; degree += 360 / vertex)
        {
            var tx:Number = x + Math.cos(degree * Math.PI / 180) * size;
            var ty:Number = y + Math.sin(degree * Math.PI / 180) * size;
            points.push(new Point(tx, ty));

            if (star)
            {
                tx = x + Math.cos((degree + 360 / vertex / 2) * Math.PI / 180) * (size / 2);
                ty = y + Math.sin((degree + 360 / vertex / 2) * Math.PI / 180) * (size / 2);
                points.push(new Point(tx, ty));
            }
        }

        var polygon:Shape = new Shape();
        polygon.graphics.lineStyle(thickness, lineColor);
        polygon.graphics.beginFill(color);
        polygon.graphics.moveTo(points[0].x, points[0].y);
        for (var i:int = 1; i < points.length; i++)
        {
            polygon.graphics.lineTo(points[i].x, points[i].y);
        }
        polygon.graphics.lineTo(points[0].x, points[0].y);
        
        return polygon;
    }
    
    public static function createScoreText(container:Sprite, x:Number, y:Number, _title:String, _score:Number):void
    {
        var title:Bitmap = Utils.textToBitmap(Utils.createTextField(_title, 18, 0xFFFFFF), true, 0xFFE08040);
        title.x = x;
        title.y = y;
        
        var score:Bitmap = Utils.textToBitmap(Utils.createTextField(_score.toString(), 18, 0xFFFFFF), true, 0xFFB55A5A);
        score.x = x;
        score.y = title.y + score.height + 20;
        
        BetweenAS3.serial
        (
            BetweenAS3.addChild(title, container),
            BetweenAS3.addChild(score, container),
            BetweenAS3.parallel
            (
                BetweenAS3.tween(title, { $x: -128 }, null, 0.6),
                BetweenAS3.tween(score, { x: title.x - 65 - score.width }, null, 0.6)
            ),
            BetweenAS3.delay
            (
                BetweenAS3.parallel
                (
                    BetweenAS3.tween(title, { alpha:0, $x:30 }, null, 1.0),
                    BetweenAS3.serial
                    (
                        BetweenAS3.tween(score, { y:Score.tf.y }, null, 0.9),
                        BetweenAS3.removeFromParent(score),
                        BetweenAS3.func(function():void { Score.setScore = Score.getScore + _score; } )
                    )
                ), 2.0
            ),
            BetweenAS3.removeFromParent(title)
        ).play();
    }
}

class Gauge extends Sprite
{
    public var value:int = 0;
    private var canvas:Sprite;
    private var color:int;
    private var stars:Array = [];
    private var max:int;
    
    public function Gauge(color:int, text:String, max:int):void
    {
        this.max = max;
        this.color = color;
        for (var i:int = 0; i < 6; i++)
        {
            addChild(Effect.createPolygon(5, i * 14, 0, 7, true, 1.0, 0x797979, 0x797979));
        }
        
        var tf:TextField = Utils.createTextField(text, 14, 0xFFFFFF);
        tf.x = -50;
        tf.y = -10;
        addChild(tf);
        
        canvas = new Sprite();
        addChild(canvas);
    }
    
    public function setValue(value:int):void
    {
        if (max < value) value = max;
        
        var shape:Shape, i:int;
        if (this.value < value)
        {
            for (i = this.value; i < value; i++)
            {
                shape = Effect.createPolygon(5, i * 14, 0, 7, true, 1.0, color, 0xFFFFFF);
                canvas.addChild(shape);
                stars.push(shape);
                
                BetweenAS3.tween(shape, { alpha:1.0 }, { alpha:0.0 } ).play();
            }
        }
        else if (this.value > value)
        {
            for (i = this.value - 1; i >= value; i--)
            {
                BetweenAS3.serial
                (
                    BetweenAS3.tween(stars[i], { alpha:0.0 }, null, 0.4 ),
                    BetweenAS3.removeFromParent(stars[i])
                ).play();
                stars.splice(i, 1);
            }
        }
        this.value = value;
    }
}

class MainBoard extends Board
{
    public function MainBoard()
    {
        clickable = true;
    }
}

class MiniBoard extends Board
{
    public var mark:Sprite;
    
    public function MiniBoard()
    {    
        clickable = false;
        scaleX = scaleY = 0.4;
        
        mark = new Sprite();
        mark.graphics.beginFill(0xFFFFFF);
        mark.graphics.drawCircle(0, 0, 15);
        mark.graphics.endFill();
        mark.visible = false;
        addChild(mark);
        
        mark.y = -160;
        mark.filters = [new GlowFilter()];
    }
    
    public function setBall():void
    {
        var data:Array = Random.shakedIntegers(Status.numBall);
        Status.hits = data.slice(0, Status.hitBall);
        for (var i:int = 0; i < Status.hits.length; i++)
        {
            balls[Status.hits[i]].select();
        }
    }
}

class Score
{
    public static var tf:TextField;
    private static var score:int = 0;
    public static var currentScore:int = 0;
    
    public static function init(container:Sprite, x:Number, y:Number):void
    {
        tf = Utils.createTextField("0", 25, 0xFFFFFF);
        tf.x = x;
        tf.y = y;
        container.addChild(tf);
    }
    
    public static function set setScore(value:int):void
    {
        score = value;
    }
    
    public static function get getScore():int
    {
        return score;
    }
    
    public static function set setCurrentScore(value:int):void
    {
        currentScore = value;
        tf.text = currentScore.toString();
    }
    
    public static function get getCurrentScore():int
    {
        return currentScore;
    }
    
    public static function update():void
    {
        if (currentScore < score)
        {
            if (score - currentScore < 10) setCurrentScore = currentScore + 1;
            else setCurrentScore = currentScore + (score - currentScore) / 10;
        }
    }
}

class Stage
{
    public static var nowStage:int = 1;
    public static var nowFloor:int = 0;
    public static var floor:int;
    public static var speed:Number;
    public static var rotation:Number;
    public static var time:Number;
    public static const MAXSTAGE:int = 7;
    
    public static function stage1():void
    {
        Status.hitBall = 6;
        floor = 7;
        speed = 0.005;
        rotation = 0;
        time = 1.0;
    }
    
    public static function stage2():void
    {
        Status.hitBall = 6;
        floor = 7;
        speed = 0.010;
        rotation = 0;
        time = 1.0;
    }
    
    public static function stage3():void
    {
        Status.hitBall = 3;
        floor = 5;
        speed = 0.009;
        rotation = 0.3;
        time = 1.0;
    }
    
    public static function stage4():void
    {
        Status.hitBall = 7;
        floor = 6;
        speed = 0.030;
        rotation = 0;
    }
    
    public static function stage5():void
    {
        Status.hitBall = 12;
        floor = 7;
        speed = 0.008;
        rotation = 0;
        time = 0.8;
    }
    
    public static function stage6():void
    {
        Status.hitBall = 3;
        floor = 6;
        speed = 0.007;
        rotation = 10;
        time = 1.0;
    }
    
    public static function stage7():void
    {
        Status.hitBall = 7;
        floor = 10;
        speed = 0.120;
        rotation = 0;
        time = 1.0;
    }
}

class State extends Sprite
{
    public function State(color:int)
    {
        graphics.lineStyle(2.0, color);
        graphics.drawRect(0, 0, 50, 25);
        graphics.endFill();
 
        var tf:TextField = Utils.createTextField("Hint", 13, color);
        tf.x = (this.width  - tf.width)  / 2;
        tf.y = (this.height - tf.height) / 2;
        addChild(tf);
    }
}

class Status
{
    public static var hitCount:int = 0;
    public static var hits:/*int*/Array;
    public static var hitBall:int = 5;
    public static var numBall:int = 21;
    public static var noMiss:Boolean;
    public static var noMissBonus:int = 500;
}

class Timer extends Sprite
{
    public var bar:Sprite;
    private var WIDTH:Number = 250;
    public var w:Number = 250;
    
    public function Timer()
    {
        graphics.beginFill(0xB0987F);
        graphics.drawRoundRect(0, 0, WIDTH, 20, 10, 10);
        graphics.endFill();
        
        graphics.beginFill(0x402210);
        graphics.drawRoundRect(2, 2, WIDTH - 4, 16, 8, 8);
        graphics.endFill();
        
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(w - 8, 12, 0 * Math.PI / 180, 4, 4);
        bar = new Sprite();
        bar.graphics.beginGradientFill("linear", [0xE08040, 0xFFBF3F], [1.0, 1.0], [0, 255], matrix);
        bar.graphics.drawRoundRect(4, 4, w - 8, 12, 6, 6);
        bar.graphics.endFill();
        addChild(bar);
        
        init();
    }
    
    public function init():void
    {
        w = WIDTH;
    }
    
    public function update():void
    {
        var tw:Number = w - 8;
        if (tw < 0) tw = w = 0;
        var matrix:Matrix = new Matrix();
        matrix.createGradientBox(tw, 12, 0 * Math.PI / 180, 4, 4);
        bar.graphics.clear();
        bar.graphics.beginGradientFill("linear", [0xE08040, 0xFFBF3F], [1.0, 1.0], [0, 255], matrix);
        bar.graphics.drawRoundRect(4, 4, tw, 12, 6, 6);
        bar.graphics.endFill();
    }
}

class Utils
{
    public static function createTextField(text:String, size:int, color:int):TextField
    {
        var tf:TextField = new TextField();
        tf.defaultTextFormat = new TextFormat("Consolas, メイリオ, _typeWriter", size, color, true);
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.text = text;
        tf.selectable = false;
        
        return tf;
    }
    
    public static function textToBitmap(tf:TextField, transparent:Boolean = true, color:uint = 0xFFBBBBBB, blurXY:Number = 4):Bitmap
    {
        var bd:BitmapData = new BitmapData(tf.width, tf.height, transparent, 0x0);
        bd.draw(tf);
        
        var bitmap:Bitmap = new Bitmap(bd);
        bitmap.filters = [new GlowFilter(color, 1, blurXY, blurXY, 10)];
        return bitmap;
    }
}