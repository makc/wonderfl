package
{
    import com.bit101.components.PushButton;
    import com.bit101.components.Text;
    import com.greensock.TweenLite;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;
    
    public class Maze extends Sprite
    {
        private const DIR:Array = 
            [
                [ 1,  0],
                [-1,  0],
                [ 0,  1],
                [ 0, -1]
            ];
        private var RDIR:Array = [1, 0, 3, 2];
        
        private var bmd:BitmapData;
        private var list:Array = new Array();
        private var size:int = 25;
        private var _zoom:Number = 1;
        
        private var gameBoard:Sprite;
        private var pos:Point = new Point(2, 2);
        private var char:Bitmap;
        
        private var moveDir:int = -1;
        private var moving:Boolean = false;
        
        private var button_very_easy:PushButton;
        private var button_easy:PushButton;
        private var button_normal:PushButton;
        private var button_hard:PushButton;
        private var button_very_hard:PushButton;
        
        private var button_give_up:PushButton;
        
        private var scoreDisp:Text;
        private var _score:int = 0;
        
        public function Maze()
        {
            addEventListener(Event.ADDED_TO_STAGE, onAdd);
        }
        
        private function onAdd(e:Event):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAdd);
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.addEventListener(Event.RESIZE, onResize);
            
            stage.frameRate = 25;
            
            button_very_easy = new PushButton(this, 182, 200, "Very Easy", setDifficulty);
            button_easy = new PushButton(this, 182, 230, "Easy", setDifficulty);
            button_normal = new PushButton(this, 182, 260, "Normal", setDifficulty);
            button_hard = new PushButton(this, 182, 290, "Hard", setDifficulty);
            button_very_hard = new PushButton(this, 182, 320, "Very Hard", setDifficulty);
            
            button_give_up = new PushButton(this, 10, 10, "Reset", resetGame);
            scoreDisp = new Text(this, 10, 40, "Score: " + _score);
            scoreDisp.width = 80;
            scoreDisp.height = 20;
            removeChild(button_give_up);
            removeChild(scoreDisp);
        }
        
        private function setDifficulty(event:Event):void
        {
            removeChild(button_very_easy);
            removeChild(button_easy);
            removeChild(button_normal);
            removeChild(button_hard);
            removeChild(button_very_hard);
            
            switch(event.currentTarget)
            {
                case button_very_easy:
                    size = 25;
                    break;
                case button_easy:
                    size = 35;
                    break;
                case button_normal:
                    size = 55;
                    break;
                case button_hard:
                    size = 75;
                    break;
                case button_very_hard:
                    size = 101;
                    break;
            }
            
            //Main drawing surface
            bmd = new BitmapData(size, size, false, Colors.FIELD);
            
            list = new Array();
            bmd = new BitmapData(size, size, false, Colors.FIELD);
            bmd.fillRect(new Rectangle(1, 1, bmd.width - 2, bmd.height - 2), Colors.WALL);
            
            gameBoard = new Sprite();
            addChild(gameBoard);
            drawGameBoard();
            addChild(button_give_up);
//            addChild(scoreDisp);
            
            var px:int = int(Math.random() * (bmd.width - 3) / 2) * 2 + 2;
            var py:int = int(Math.random() * (bmd.width - 3) / 2) * 2 + 2;
            
            bmd.setPixel(px, py, Colors.FIELD);
            
            var random:Array = shakedIntegers(4);
            list.push([px, py], random);
            
            addEventListener(Event.ENTER_FRAME, drawLoop);
        }
        
        private function onResize(e:Event):void 
        {
            drawGameBoard();
        }
        
        /************DRAW LOGIC*****************/
        private function drawLoop(e:Event):void 
        {
            drawGameBoard();
            var date:Date = new Date();
            do
            {
                if (list.length == 0)
                {
                    removeEventListener(Event.ENTER_FRAME, drawLoop);
                    
                    bmd.setPixel(size-2, size-3, Colors.FIELD);
                    
                    beginGame();
                    break;
                }
                _dig1();
            }while (new Date().time - date.time < 40);
        }
        
        private function _dig1():void
        {
            var len:int = list.length;
            var random:int = list[len - 1].pop();
            var _pos:Array = list[len - 2];
            
            if (bmd.getPixel(_pos[0] + DIR[random][0] * 2, _pos[1] + DIR[random][1] * 2) == Colors.WALL)
            {
                bmd.setPixel(_pos[0] + DIR[random][0], _pos[1] + DIR[random][1], Colors.FIELD);
                bmd.setPixel(_pos[0] + DIR[random][0] * 2, _pos[1] + DIR[random][1] * 2, Colors.FIELD);
                
                list.push([_pos[0] + DIR[random][0] * 2, _pos[1] + DIR[random][1] * 2], shakedIntegers(4));
            }
            else if(list[len - 1].length == 0)
            {
                list.pop();
                list.pop();
            }
        }
        
        private function drawGameBoard():void 
        {
            var m:Matrix = new Matrix();
            m.a = m.d = zoom;
            m.tx = -pos.x * zoom + stage.stageWidth * .5;
            m.ty = -pos.y * zoom + stage.stageHeight * .5;
            
            if(gameBoard)
            {
                gameBoard.graphics.clear();
                gameBoard.graphics.beginBitmapFill(bmd, m, false, false);
                gameBoard.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
                gameBoard.graphics.endFill();
            }
            
            if (char)
            {
                char.x = stage.stageWidth * .5;
                char.y = stage.stageHeight * .5;
            }
        }
        
        private function shakedIntegers(len:int):Array
        {
            var arr:Array = new Array(len);
            for ( var i:int = 0; i < len; i++ )
                arr[i] = i;
            
            var temp:int;
            while(--len)
            {
                i = Math.random()*(len+1);
                temp = arr[len];
                arr[len] = arr[i];
                arr[i] = temp;
            }
            return arr;
        }
        
        /*************GAME LOGIC*********************/
        private function beginGame():void
        {
            char = new Bitmap(new Character().bmd);
            TweenLite.to(this, 1, { delay:.5, zoom:10, onUpdate:drawGameBoard, onComplete:startGameLoop } );
        }
        
        private function startGameLoop():void 
        {
            addChild(char);
            stage.focus = stage;
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            addEventListener(Event.ENTER_FRAME, gameLoop);
        }
        
        private function gameLoop(e:Event):void 
        {
            var deadEnd:Boolean = true;
            var optionsAvailable:Boolean = false;
            var tempDir:int = -1;
            
            //Check move options
            if (moveDir != -1)
            {
                if (moving)
                {
                    for (var i:int = 0; i < 4; i++)
                    {
                        if (i == RDIR[moveDir])
                            continue;
                        
                        if (bmd.getPixel(pos.x + DIR[i][0], pos.y + DIR[i][1]) != Colors.WALL)
                        {
                            if (deadEnd)
                            {
                                deadEnd = false;
                                tempDir = i;
                            }
                            else
                                optionsAvailable = true;
                        }
                    }
                    if (!deadEnd && !optionsAvailable)
                    {
                        moveDir = tempDir;
                    }
                    else
                    {
                        moving = false;
                        moveDir = -1;
                    }
                }
                else if (bmd.getPixel(pos.x + DIR[moveDir][0], pos.y + DIR[moveDir][1]) == Colors.WALL)
                {
                    moving = false;
                    moveDir = -1;
                }
                else
                {
                    moving = true;
                }
            }
            
            //Move if direction set
            if (moveDir != -1)
            {
                pos.x += DIR[moveDir][0];
                pos.y += DIR[moveDir][1];
                var px:int = bmd.getPixel(pos.x, pos.y);
                if (px == Colors.FIELD) 
                {
                    score++;
                    bmd.setPixel(pos.x, pos.y, Colors.TRAIL[0]);
                }
                else
                {
                    for (i = 0; i < 6; i++)
                    {
                        if (px == Colors.TRAIL[i]) 
                        {
                            i++;
                            break;
                        }
                    }
                    if (i == 6) i--;
                    score -= i + 1;
                    bmd.setPixel(pos.x, pos.y, Colors.TRAIL[i]);
                }
                drawGameBoard();
            }
            
            if (pos.x == size-1 && pos.y == size-3)
            {
                endGame();
            }
        }
        
        private function endGame():void
        {
            var sw:Number = stage.stageWidth;
            var sh:Number = stage.stageHeight;
            var m:Matrix = new Matrix();
            
            var scale:int = ((sw-100 > sh-70)? sh-70 : sw-100) / size;
            if(scale < 1) scale = 1;
            m.a = m.d = scale;
            m.tx = (sw - 100 - size*scale)*.5 + 100;
            m.ty = (sh - 70 - size*scale)*.5 + 70;
            
            gameBoard.graphics.clear();
            gameBoard.graphics.beginBitmapFill(bmd, m, false, false);
            gameBoard.graphics.drawRect(0, 0, sw, sh);
            gameBoard.graphics.endFill();
            
            char.x = m.tx + pos.x*scale;
            char.y = m.ty + pos.y*scale;
            
            scoreDisp.text = "Score: " + _score;
            addChild(scoreDisp);
        }
        
        private function resetGame(event:Event = null):void
        {
            removeEventListener(Event.ENTER_FRAME, gameLoop);
            
            addChild(button_very_easy);
            addChild(button_easy);
            addChild(button_normal);
            addChild(button_hard);
            addChild(button_very_hard);
            removeChild(gameBoard);
            removeChild(char);
            removeChild(button_give_up);
            if (contains(scoreDisp)) removeChild(scoreDisp);
            
            moveDir = -1;
            moving = false;
            pos.x = pos.y = 2;
            zoom = 1;
            score = 0;
        }
        
        private function onKeyDown(e:KeyboardEvent):void 
        {
            switch(e.keyCode)
            {
                case Keyboard.RIGHT:
                    moveDir = 0;
                    break;
                case Keyboard.LEFT:
                    moveDir = 1;
                    break;
                case Keyboard.DOWN:
                    moveDir = 2;
                    break;
                case Keyboard.UP:
                    moveDir = 3;
                    break;
            }
        }
        
        /*************GETTER SETTERS*****************/
        public function get zoom():Number 
        {
            return _zoom;
        }
        
        public function set zoom(value:Number):void 
        {
            _zoom = value;
        }
        
        public function get score():int 
        {
            return _score;
        }
        
        public function set score(value:int):void 
        {
            _score = value;
        }
    }
}

class Colors
{
    public static const FIELD:int = 0xF3F3F3;
    public static const WALL:int = 0x393939;
    
    public static const TRAIL:Array = [ 0xF339F3, 0x3939F3, 
        0x39F3F3, 0x39F339, 
        0xF3F339, 0xF33939 ];
}

class Character
{
    public var bmd:flash.display.BitmapData;
    // 10x8 shape
    private var data:Array = [0, 0, 1, 0, 0, 0, 0, 1, 0, 0,
        1, 0, 0, 1, 0, 0, 1, 0, 0, 1,
        1, 0, 1, 1, 1, 1, 1, 1, 0, 1,
        1, 1, 1, 0, 1, 1, 0, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        0, 1, 1, 1, 1, 1, 1, 1, 1, 0,
        0, 0, 1, 0, 0, 0, 0, 1, 0, 0,
        0, 1, 0, 0, 0, 0, 0, 0, 1, 0];
    
    public function Character()
    {
        bmd = new flash.display.BitmapData(10, 8, false, 0xFFFFFF);
        for (var i:int = 0; i < data.length; i++)
        {
            if (data[i] == 1)
            {
                bmd.setPixel(i % 10, int(i / 10), 0xFFFF0000);
            }
        }
    }
}