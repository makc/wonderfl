// forked from cpu_t's MineStepper
/* 
 * MineStepper ver 1.1
 * 
 * マスをクリックすると旗を立てます。
 * 旗は、ここに地雷がありそうだ！という目印です。
 * 
 * マスに書かれている数字は、「そのマスの周囲８マスにある地雷の数」です。
 * 周りに立っている旗の数と見比べて、よしここは安全そうだとわかると、自動的に周囲のマスが開かれます。
 * 
 * 地雷のあるマスを開いてしまうと、ゲームオーバーです。
 * 上にある黄色い丸のボタンを押して、やり直しましょう。
 * 
 * 
 * でも、普通のマインスイーパーより速い記録が出やすいと思います。
 * 
 * 
 * 安全なマスでは無く、常に地雷のありそうなマスをクリックするので、マインステッパー。
 * 
 * 
 * stepper/sweeper Switchを追加しました。
 * これをクリックするとモードが切り替わります。
 * スペースキーを押すことでもモードの切り替えができます。
 * 
 * sTepperモードは旗を立てるモードです。
 * sWeeperモードはマスを開けるモードです。
 */
package
{
    import flash.events.KeyboardEvent;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.GlowFilter;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.escapeMultiByte;
    
    import net.wonderfl.score.basic.BasicScoreForm;
    import net.wonderfl.score.basic.BasicScoreRecordViewer;
    
    public class MineStepper extends Sprite
    {
        private var colNum:int = 30;
        private var rowNum:int = 16;
        private var mineNum:int = 99;
        
        private var isEnd:Boolean;
        private var rightFlagNum:int;
        private var openCellNum:int;
        
        private var mine:Vector.<Boolean>;
        private var cells:Vector.<Cell>;
        
        private var flgNum:int;
        private var header:Sprite;
        private var timer:GameTimer;
        private var mineWatcher:NumberBoard;
        private var message:TextField;
        private var twitter:Sprite;
        
        private var ssSwitch:SSSwitch;
        
        private var _form:BasicScoreForm;
        private var _ranking:BasicScoreRecordViewer
        
        public function MineStepper():void
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            
            var centerX:int = Math.floor(colNum / 2);
            var centerY:int = Math.floor(rowNum / 2);
            
            // create field
            header = new Sprite();
            addChild(header);
            
            var resetBtn:Sprite = new Cell();
            resetBtn.graphics.clear();
            resetBtn.graphics.beginFill(0xCCCCCC);
            resetBtn.graphics.drawRect(0, 0, 20, 20);
            resetBtn.graphics.endFill();
            resetBtn.graphics.beginFill(0xFFFF00);
            resetBtn.graphics.drawCircle(resetBtn.width / 2, resetBtn.height / 2, resetBtn.width / 2 - 1);
            resetBtn.graphics.endFill();
            header.addChild(resetBtn);
            resetBtn.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
            {
                reset();
            });
            
            cells = new Vector.<Cell>();
            for (var i:int = 0; i < rowNum * colNum; i++)
            {
                var cell:Cell = new Cell();
                cells.push(cell);
                addChild(cell);
                cell.x = (i % colNum) * (cell.width+1);
                cell.y = Math.floor(i / colNum) * (cell.height + 1) + header.height;
            }
            
            timer = new GameTimer();
            header.addChild(timer);
            
            mineWatcher = new NumberBoard();
            header.addChild(mineWatcher);
            
            ssSwitch = new SSSwitch();
            header.addChild(ssSwitch);
            ssSwitch.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
            {
                ssSwitch.stepperMode = !ssSwitch.stepperMode;
            });
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):void
            {
                if(e.keyCode == 32)
                    ssSwitch.stepperMode = !ssSwitch.stepperMode;
            });
            
            resetBtn.x = width / 2 - resetBtn.width / 2;
            timer.x = width - timer.width;
            ssSwitch.x = (resetBtn.x + resetBtn.width + timer.x - ssSwitch.width) / 2;
            
            graphics.beginFill(0x999999);
            graphics.drawRect(0, header.height, width, height - header.height);
            graphics.endFill();
            
            // scaling
            var scale:Number = stage.stageWidth / width;
            scale = stage.stageHeight / height > scale ? scale : stage.stageHeight / height;
            scaleX = scaleY = scale;
            
            this.x = stage.stageWidth / 2 - width / 2;
            this.y = stage.stageHeight / 2 - height / 2;
            
            // ui set
            for (i = 0; i < rowNum * colNum; i++)
            {
                cells[i].addEventListener(MouseEvent.MOUSE_DOWN, cellClickHandler);
            }
            
            message = new TextField();
            message.defaultTextFormat = new TextFormat("Arial", 36, 0xFF0000);
            message.autoSize = "left";
            message.text = " ";
            message.filters = [new GlowFilter(0x000000, 1, 4, 4, 255)];
            stage.addChild(message);
            message.y = stage.stageHeight / 2 - message.height / 2;
            
            twitter = new Sprite();
            twitter.buttonMode = true;
            twitter.mouseChildren = false;
            var text:TextField = new TextField();
            text.defaultTextFormat = new TextFormat("Arial", 16, null, true);
            text.autoSize = "left";
            text.text = " Twitterに投稿する ";
            twitter.addChild(text);
            text.x = text.y = 5;
            twitter.graphics.lineStyle(2, 0);
            twitter.graphics.beginFill(0xCCFFFF);
            twitter.graphics.drawRoundRect(0, 0, text.width + 10, text.height + 10, 10, 10);
            twitter.graphics.endFill();
            stage.addChild(twitter);
            twitter.x = stage.stageWidth - twitter.width;
            twitter.y = this.y + height - twitter.height;
            var getDown:Boolean = false;
            twitter.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
            {
                if (!getDown) twitter.y += 2;
                getDown = true;
            });
            twitter.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void
            {
                if (getDown) twitter.y -= 2;
                getDown = false;
            });
            twitter.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
            {
                if (getDown)
                {
                    twitter.y -= 2;
                    var post:String = "MineStepper v1.1を" + timer.time / 1000 + "秒でクリアしました！ #MineStepper http://wonderfl.net/c/to1W/";
                    navigateToURL(new URLRequest("http://twitter.com/home?status=" + escapeMultiByte(post)), "_blank");
                }
                getDown = false;
            });
            twitter.visible = false;
            
            var viewRanking:Sprite = new Sprite();
            viewRanking.buttonMode = true;
            viewRanking.mouseChildren = false;
            text = new TextField();
            text.defaultTextFormat = new TextFormat("Arial", 12);
            text.autoSize = "left";
            text.text = " Ranking ";
            viewRanking.addChild(text);
            viewRanking.graphics.lineStyle(2, 0);
            viewRanking.graphics.beginFill(0xFFFFFF);
            viewRanking.graphics.drawRoundRect(0, 0, text.width, text.height, 10, 10);
            viewRanking.graphics.endFill();
            stage.addChild(viewRanking);
            viewRanking.y = this.y + height + 5;
            viewRanking.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
            {
                _ranking = new BasicScoreRecordViewer(stage, (stage.stageWidth-BasicScoreRecordViewer.WIDTH)/2,(stage.stageHeight-BasicScoreRecordViewer.HEIGHT)/2,'RANKING', 99, false);
            });
            
            // game start
            reset();
        }
        
        private function reset():void
        {
            var centerX:int = Math.floor(colNum / 2);
            var centerY:int = Math.floor(rowNum / 2);
            isEnd = false;
            rightFlagNum = 0;
            openCellNum = 0;
            flgNum = 0;
            
            mineWatcher.show(mineNum);
            message.text = "";
            twitter.visible = false;
            
            ssSwitch.stepperMode = true;
            
            // mine set
            mine = new Vector.<Boolean>();
            var count:int = 0;
            for (var i:int = 0; i < rowNum * colNum; i++)
            {
                if (i / colNum >= centerY - 1 && i / colNum <= centerY + 2 &&
                    i % colNum >= centerX - 1 && i % colNum <= centerX + 1
                    )
                {
                    mine.push(false);
                }
                else if (count++ < mineNum)
                {
                    mine.push(true);
                }
                else
                {
                    mine.push(false);
                }
            }
            
            // shuffle
            for (i = 1; i < rowNum * colNum; i++)
            {
                if (
                    i / colNum >= centerY - 1 && i / colNum <= centerY + 2 &&
                    i % colNum >= centerX - 1 && i % colNum <= centerX + 1
                )
                {
                    continue;
                }
                var swap:int = Math.floor(Math.random() * (i + 1));
                if (
                    swap / colNum >= centerY - 1 && swap / colNum <= centerY + 2 &&
                    swap % colNum >= centerX - 1 && swap % colNum <= centerX + 1
                )
                {
                    continue;
                }
                var w:Boolean = mine[i];
                mine[i] = mine[swap];
                mine[swap] = w;
            }
            
            for each(var cell:Cell in cells)
            {
                cell.reset();
            }
            timer.reset();
            
            openCell(centerX + centerY * colNum);
        }
        
        private function gameEnd():void
        {
            if(isEnd) return;
            isEnd = true;
            timer.stop();
            message.text = "Game Over";
            message.x = stage.stageWidth / 2 - message.width / 2;
        }
        
        private function gameClear():void
        {
            if(isEnd) return;
            isEnd = true;
            timer.stop();
            twitter.visible = true;
            message.text = "Clear!";
            message.x = stage.stageWidth / 2 - message.width / 2;
            _form = new BasicScoreForm(stage, (stage.stageWidth-BasicScoreForm.WIDTH)/2, (stage.stageHeight-BasicScoreForm.HEIGHT)/2, Math.floor(timer.time / 1000), 'SAVE SCORE', showRanking);
        }
        
        private function showRanking($didSavedScore:Boolean):void
        {
            stage.removeChild(_form);
            _ranking = new BasicScoreRecordViewer(stage, (stage.stageWidth-BasicScoreRecordViewer.WIDTH)/2,(stage.stageHeight-BasicScoreRecordViewer.HEIGHT)/2,'RANKING', 99, false);
        }
        
        private function openCell(index:int):void
        {
            var cell:Cell = cells[index];
            
            if (cell.isOpen || cell.isFlag) return;
            
            cell.open();
            openCellNum++;
            
            // bomb
            if (mine[index])
            {
                cell.drawMark( -1);
                gameEnd();
            }
            // safe
            else
            {
                if (openCellNum == colNum * rowNum - mineNum)
                {
                    gameClear();
                }
                
                var num:int = checkAround(index);
                if (num > 0)
                {
                    cell.drawMark(num);
                }
                if (num - checkAround(index, "flag") <= 0)
                {
                    openAround(index);
                }
            }
        }
        
        private function checkAround(index:int, type:String = "mine"):int
        {
            var x:int = index % colNum;
            var y:int = Math.floor(index / colNum);
            var num:int = 0;
            for (var j:int = -1; j <= 1 ; j++)
            for (var i:int = -1; i <= 1; i++)
            {
                if (y + j >= 0 && y + j < rowNum &&
                    x + i >= 0 && x + i < colNum)
                {
                    var w:int = index + j * colNum + i;
                    if (type == "mine")
                    {
                        if (mine[w]) num++;
                    }
                    else if (type == "flag")
                    {
                        if (cells[w].isFlag) num++;
                    }
                }
            }
            return num;
        }
        
        private function openAround(index:int):void
        {
            var x:int = index % colNum;
            var y:int = Math.floor(index / colNum);
            for (var j:int = -1; j <= 1 ; j++)
            for (var i:int = -1; i <= 1; i++)
            {
                if (y + j >= 0 && y + j < rowNum &&
                    x + i >= 0 && x + i < colNum)
                {
                    var w:int = index + j * colNum + i;
                    if (!cells[w].isOpen && !cells[w].isFlag) openCell(w);
                }
            }
        }
        
        private function cellClickHandler(e:MouseEvent):void
        {
            if (isEnd) return;
            if (!timer.isRun) timer.start();
            
            var index:int = cells.indexOf(e.target as Cell);
            if (ssSwitch.stepperMode)
            {
                putFlag(index);
            }
            else
            {
                openCell(index);
            }
        }
        
        private function putFlag(index:int):void
        {
            var cell:Cell = cells[index];
            
            if (!cell.isOpen)
            if (!cell.isFlag)
            {
                cell.putFlag();
                flgNum++;
                if (mine[index]) rightFlagNum++;
                mineWatcher.show(mineNum - flgNum);
            }
            else
            {
                cell.takeFlag();
                flgNum--;
                if (mine[index]) rightFlagNum--;
                mineWatcher.show(mineNum - flgNum);
            }
            
            if (rightFlagNum == mineNum)
            {
                gameClear();
            }
            
            var x:int = index % colNum;
            var y:int = Math.floor(index / colNum);
            for (var j:int = -1; j <= 1 ; j++)
            for (var i:int = -1; i <= 1; i++)
            {
                if (y + j >= 0 && y + j < rowNum &&
                    x + i >= 0 && x + i < colNum)
                {
                    var w:int = index + j * colNum + i;
                    if (cells[w].isOpen)
                    {
                        var num:int = checkAround(w) - checkAround(w, "flag");
                        if (num <= 0)
                        {
                            openAround(w);
                        }
                    }
                }
            }
            
        }
        
    }
    
}

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getTimer;
class Cell extends Sprite
{
    
    public var isOpen:Boolean = false;
    public var isFlag:Boolean = false;
    private var frame:Sprite;
    private var cross:Sprite;
    private var flag:Sprite;
    private var text:TextField;
    
    public function Cell()
    {
        mouseChildren = false;
        
        graphics.beginFill(0x666666);
        graphics.drawRect(0, 0, 20, 20);
        graphics.endFill();
        
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(0, 0, 18, 18);
        graphics.endFill();
        
        graphics.beginFill(0xCCCCCC);
        graphics.drawRect(2, 2, 16, 16);
        graphics.endFill();
        
        frame = new Sprite();
        frame.graphics.beginFill(0x999999);
        frame.graphics.drawRect(0, 0, 20, 20);
        frame.graphics.drawRect(2, 2, 16, 16);
        frame.graphics.endFill();
        addChild(frame);
        frame.visible = false;
        
        cross = new Sprite();
        with (cross)
        {
            graphics.lineStyle(2, 0);
            graphics.moveTo(4, 4);
            graphics.lineTo(16, 16);
            graphics.moveTo(4, 16);
            graphics.lineTo(16, 4);
            graphics.endFill();
        }
        addChild(cross);
        cross.visible = false;
        
        flag = new Sprite();
        with (flag)
        {
            graphics.lineStyle(2, 0);
            graphics.moveTo(6, 16);
            graphics.lineTo(6, 4);
            graphics.endFill();
            
            graphics.lineStyle(2, 0);
            graphics.beginFill(0xFF0000);
            graphics.moveTo(6, 4);
            graphics.lineTo(14, 7);
            graphics.lineTo(6, 10);
            graphics.endFill();
        }
        addChild(flag);
        flag.visible = false;
        
        text = new TextField();
        text.defaultTextFormat = new TextFormat("Arial", 16, null, true);
        text.text = "";
        text.autoSize = "left";
        addChild(text);
        
        addEventListener(MouseEvent.MOUSE_OVER, overHandler);
        addEventListener(MouseEvent.MOUSE_OUT, outHandler);
    }
    
    private function outHandler(e:MouseEvent):void 
    {
        frame.visible = false;
    }
    
    private function overHandler(e:MouseEvent):void 
    {
        frame.visible = true;
    }
    
    public function reset():void
    {
        if (isOpen)
        {
            graphics.clear();
            graphics.beginFill(0x666666);
            graphics.drawRect(0, 0, 20, 20);
            graphics.endFill();
            
            graphics.beginFill(0xFFFFFF);
            graphics.drawRect(0, 0, 18, 18);
            graphics.endFill();
            
            graphics.beginFill(0xCCCCCC);
            graphics.drawRect(2, 2, 16, 16);
            graphics.endFill();
            
            addEventListener(MouseEvent.MOUSE_OVER, overHandler);
            addEventListener(MouseEvent.MOUSE_OUT, outHandler);
        }
        isOpen = false;
        cross.visible = false;
        text.text = "";
        isFlag = false;
        flag.visible = false;
    }
    
    public function open():void
    {
        isOpen = true;
        isFlag = false;
        frame.visible = false;
        flag.visible = false;
        
        graphics.clear();
        graphics.beginFill(0xCCCCCC);
        graphics.drawRect(0, 0, 20, 20);
        graphics.endFill();
        
        removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
        removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
    }
    
    public function putFlag():void
    {
        flag.visible = true;
        isFlag = true;
    }
    
    public function takeFlag():void
    {
        flag.visible = false;
        isFlag = false;
    }
    
    public function drawMark(x:int):void
    {
        // bomb
        if (x == -1)
        {
            cross.visible = true;
        }
        // number
        else if (x >= 1 && x <= 8)
        {
            var tformat:TextFormat = text.defaultTextFormat;
            switch(x)
            {
            case 1:
                tformat.color = 0x0000FF;
                break;
            case 2:
                tformat.color = 0x008000;
                break;
            case 3:
                tformat.color = 0xFF3000;
                break;
            default:
                tformat.color = 0x000060;
            }
            text.defaultTextFormat = tformat;
            text.text = x + "";
            text.x = width / 2 - text.width / 2;
            text.y = height / 2 - text.height / 2;
        }
    }
}

class NumberBoard extends Sprite
{
    protected var numsrc:Vector.<Sprite>;
    protected var spDigits:Vector.<Sprite>;
    
    public function NumberBoard()
    {
        numsrc = new Vector.<Sprite>();
        for (var i:int = 0; i < 11; i++) 
        {
            numsrc.push(new Sprite());
        }
        
        var sp:Sprite = new Sprite();
        
        // 0
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(2, 4);
        sp.graphics.lineTo(8, 4);
        sp.graphics.lineTo(8, 16);
        sp.graphics.lineTo(2, 16);
        sp.graphics.lineTo(2, 4);
        numsrc[0].graphics.copyFrom(sp.graphics);
        
        // 1
        sp.graphics.clear();
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(2, 4);
        sp.graphics.lineTo(5, 4);
        sp.graphics.lineTo(5, 16);
        numsrc[1].graphics.copyFrom(sp.graphics);
        
        // 2
        sp.graphics.clear();
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(2, 4);
        sp.graphics.lineTo(8, 4);
        sp.graphics.lineTo(8, 10);
        sp.graphics.lineTo(2, 10);
        sp.graphics.lineTo(2, 16);
        sp.graphics.lineTo(8, 16);
        numsrc[2].graphics.copyFrom(sp.graphics);
        
        // 3
        sp.graphics.clear();
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(2, 4);
        sp.graphics.lineTo(8, 4);
        sp.graphics.lineTo(8, 16);
        sp.graphics.lineTo(2, 16);
        sp.graphics.moveTo(2, 10);
        sp.graphics.lineTo(8, 10);
        numsrc[3].graphics.copyFrom(sp.graphics);
        
        // 4
        sp.graphics.clear();
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(2, 4);
        sp.graphics.lineTo(2, 10);
        sp.graphics.lineTo(8, 10);
        sp.graphics.moveTo(8, 4);
        sp.graphics.lineTo(8, 16);
        numsrc[4].graphics.copyFrom(sp.graphics);
        
        // 5
        sp.graphics.clear();
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(8, 4);
        sp.graphics.lineTo(2, 4);
        sp.graphics.lineTo(2, 10);
        sp.graphics.lineTo(8, 10);
        sp.graphics.lineTo(8, 16);
        sp.graphics.lineTo(2, 16);
        numsrc[5].graphics.copyFrom(sp.graphics);
        
        // 6
        sp.graphics.clear();
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(8, 4);
        sp.graphics.lineTo(2, 4);
        sp.graphics.lineTo(2, 16);
        sp.graphics.lineTo(8, 16);
        sp.graphics.lineTo(8, 10);
        sp.graphics.lineTo(2, 10);
        numsrc[6].graphics.copyFrom(sp.graphics);
        
        // 7
        sp.graphics.clear();
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(2, 4);
        sp.graphics.lineTo(8, 4);
        sp.graphics.lineTo(8, 16);
        numsrc[7].graphics.copyFrom(sp.graphics);
        
        // 8
        sp.graphics.clear();
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(2, 4);
        sp.graphics.lineTo(8, 4);
        sp.graphics.lineTo(8, 16);
        sp.graphics.lineTo(2, 16);
        sp.graphics.lineTo(2, 4);
        sp.graphics.moveTo(2, 10);
        sp.graphics.lineTo(8, 10);
        numsrc[8].graphics.copyFrom(sp.graphics);
        
        // 9
        sp.graphics.clear();
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(2, 16);
        sp.graphics.lineTo(8, 16);
        sp.graphics.lineTo(8, 4);
        sp.graphics.lineTo(2, 4);
        sp.graphics.lineTo(2, 10);
        sp.graphics.lineTo(8, 10);
        numsrc[9].graphics.copyFrom(sp.graphics);
        
        // -
        sp.graphics.clear();
        sp.graphics.lineStyle(3, 0xFF0000);
        sp.graphics.moveTo(2, 10);
        sp.graphics.lineTo(8, 10);
        numsrc[10].graphics.copyFrom(sp.graphics);
        
        graphics.beginFill(0);
        graphics.drawRect(0, 0, 50, 20);
        
        spDigits = new Vector.<Sprite>();
        for (i = 0; i < 3; i++) 
        {
            spDigits.push(new Sprite());
            addChild(spDigits[i]);
            spDigits[i].x = 5 + (2 - i) * 15;
        }
        
        show(0);
    }
    
    public function show(num:int):void
    {
        if (num < 0)
        {
            spDigits[2].graphics.copyFrom(numsrc[10].graphics);
            num *= -1;
        }
        else
        {
            spDigits[2].graphics.copyFrom(numsrc[Math.floor(num / 100) % 10].graphics);
        }
        if (num > 999) num = 999;
        spDigits[0].graphics.copyFrom(numsrc[num % 10].graphics);
        spDigits[1].graphics.copyFrom(numsrc[Math.floor(num / 10) % 10].graphics);
    }
}

class GameTimer extends NumberBoard
{
    public var isRun:Boolean;
    
    private var startTime:Number;
    public var time:Number;
    
    public function GameTimer()
    {
        isRun = false;
        
        startTime = 0;
        time = 0;
        reset();
    }
    
    public function reset():void
    {
        if (isRun)
        {
            removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        isRun = false;
        
        show(0);
    }
    
    public function start():void
    {
        isRun = true;
        startTime = getTimer();
        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }
    
    public function stop():void
    {
        isRun = false;
        time = getTimer() - startTime;
        removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }
    
    private function enterFrameHandler(e:Event):void
    {
        time = getTimer() - startTime;
        
        show(Math.floor(time / 1000));
    }
    
}

class SSSwitch extends Sprite
{
    private var _stepperMode:Boolean = true;
    
    private var text:TextField;
    private var stepper:Sprite;
    private var sweeper:Sprite;
    
    public function SSSwitch()
    {
        mouseChildren = false;
        buttonMode = true;
        
        text = new TextField();
        text.defaultTextFormat = new TextFormat("Arial", 16);
        text.autoSize = "left";
        text.text = _stepperMode ? "mode:sTepper" : "mode:sWeeper";
        addChild(text);
        text.x = 20;
        text.y = (20 - text.height) / 2;
        
        var back:Sprite = new Sprite();
        back.graphics.beginFill(0xCCCCCC);
        back.graphics.drawRect(0, 0, 20, 20);
        back.graphics.endFill();
        addChild(back);
        
        stepper = new Sprite();
        with (stepper)
        {
            graphics.lineStyle(2, 0);
            graphics.moveTo(6, 16);
            graphics.lineTo(6, 4);
            graphics.endFill();
            
            graphics.lineStyle(2, 0);
            graphics.beginFill(0xFF0000);
            graphics.moveTo(6, 4);
            graphics.lineTo(14, 7);
            graphics.lineTo(6, 10);
            graphics.endFill();
        }
        addChild(stepper);
        stepper.visible = _stepperMode;
        
        sweeper = new Sprite();
        with (sweeper)
        {
            graphics.lineStyle(2, 0);
            graphics.moveTo(4, 4);
            graphics.lineTo(16, 16);
            graphics.moveTo(4, 16);
            graphics.lineTo(16, 4);
            graphics.endFill();
        }
        addChild(sweeper);
        sweeper.visible = !_stepperMode;
        
        graphics.beginFill(0, 0);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
    }
    
    public function get stepperMode():Boolean { return _stepperMode; }
    public function set stepperMode(value:Boolean):void 
    {
        _stepperMode = value;
        text.text = _stepperMode ? "mode:sTepper" : "mode:sWeeper";
        stepper.visible = _stepperMode;
        sweeper.visible = !_stepperMode;
    }
}