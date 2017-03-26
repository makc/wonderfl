package {
    import flash.system.LoaderContext;
    import flash.events.Event;
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.BevelFilter;
    import flash.filters.BitmapFilterType;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    import flash.utils.Timer;
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;

    /**
     * ...
     * @author
     */
    public class Main extends Sprite {
        //const
        private const NUM_BOMBS:uint = 10;
        private const SEA:uint = 0x1E90FF;
        private const LAND:uint = 0xff228b22;
        private const SCORCHED:uint = 0xff8b4513;
        private const BOMB:uint = 0xffff4500;
        private const FLAG:uint = 0xffffff00;
        //data
        private const X_COORD:Vector.<uint> = Vector.<uint>([1854, 1616, 1684, 1622, 1566, 1535, 1550, 1557, 1495, 1397, 1439, 1540, 1449, 1440, 1396, 1183, 1102, 1061, 1350, 1270, 1153, 1278, 1174, 1076, 1045, 963, 970, 888, 1011, 955, 762, 611, 757, 639, 476, 816, 774, 639, 722, 376, 309, 293, 389, 464, 453, 348, 50]);
        private const Y_COORD:Vector.<uint> = Vector.<uint>([359, 814, 986, 1171, 956, 1153, 1327, 1497, 1443, 1472, 1540, 1635, 1589, 1633, 1315, 1454, 1484, 1550, 1602, 1528, 1584, 1703, 1690, 1774, 1666, 1660, 1752, 1699, 1801, 1854, 1633, 1675, 1718, 1754, 1810, 1863, 1814, 1894, 1898, 1903, 1947, 1988, 2044, 1970, 2107, 2161, 2898]);
        private const NEXT_TO:Vector.<String> = Vector.<String>(["", "2/4", "1/3/4", "2/4/5/6", "1/2/3/5", "3/4/6/14", "3/5/7/8/9/14", "6/8/10/11", "6/7/9/10", "6/8/10/14/19", "7/8/9/11/12/18/19", "7/10/12", "10/11/13/18", "12/18/21", "5/6/9/15/19", "14/16/19/20", "15/17/20", "16/20/24/25", "10/12/13/19/21", "9/10/14/15/18/20/21/22", "15/16/17/19/22/23/24", "13/18/19/22", "19/20/21/23", "20/22/24/25/28/29", "17/20/23/25", "17/23/24/26/27/28", "25/27/28/29", "25/26/30/32", "23/25/26/29", "23/26/28", "27/31/32/33", "30/33/34", "27/30/33", "30/31/32/34", "31/33", "36/37/38", "35/37", "35/36/38", "35/37", "40/42/43", "39/41", "40", "39/43/44/45", "39/42/44", "42/43/45", "42/44", ""]);
        //visual
        private var japan:Sprite;
        private var japanBmp:Bitmap;
        private var japanBd:BitmapData;
        private var wave:Bitmap;
        private var waveTween:ITween;
        //mouse
        private var isMouseDown:Boolean;
        private var oldX:Number;
        private var oldY:Number;
        private const MARGIN:Number = 100.0;
        private var limitX:Number;
        private var limitY:Number;
        //system game
        private var japanHitArea:BitmapData;
        private var numOpened:uint;
        private var numFlaged:int;
        private var isOver:Boolean;
        private var bombs:Vector.<uint> = new Vector.<uint>(NUM_BOMBS);
        private var prefectures:Vector.<Prefecture> = new Vector.<Prefecture>(47);
        //system
        private var time:uint;
        private var timer:Timer;
        private var timeText:TextField;
        private var bombText:TextField;
        //end
        private var gameEndText:TextField;
        private var gameEndMessage:TextField;
        private var japanText:TextField;
        private var retryText:TextField;

        public function Main(){
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,init);
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/3/3b/3b7f/3b7f894588ba110ac82483ed0015a0b5d47dd8f0") , new LoaderContext(true));
        }

        private function init(e:Event):void{
            //main
            var sea:Bitmap = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, SEA));
            addChild(sea);
            japan = new Sprite();
            japan.x = -1200;
            japan.y = -1200;
            addChild(japan);
            var loader:Loader = e.currentTarget.loader;
            japanBd = new BitmapData(loader.width , loader.height, true, 0x0);
            japanBd.draw(loader);
            japanBmp = new Bitmap(japanBd);
            limitX = stage.stageWidth - japanBmp.width - MARGIN;
            limitY = stage.stageHeight - japanBmp.height - MARGIN;
            japan.addChild(japanBmp);
            japanHitArea = japanBd.clone();
            //
            var color:uint = 0xff00ff00;
            for (var i:int = 0; i < 47; i++){
                var pref:Prefecture = new Prefecture(i, X_COORD[i], Y_COORD[i], NEXT_TO[i]);
                prefectures[i] = pref;
                japan.addChild(pref.tf);
                pref.fill(japanHitArea, color);
                color += 0x1;
            }
            //sub
            timer = new Timer(1000);
            timer.addEventListener(TimerEvent.TIMER, onTimer);
            timeText = Util.createTextField(0, 0);
            timeText.defaultTextFormat = new TextFormat(null, 20, 0xf0fff0);
            var bevel:BevelFilter = new BevelFilter(6);
            bevel.highlightAlpha = 0;
            bevel.type = BitmapFilterType.OUTER;
            timeText.filters = [bevel];
            addChild(timeText);
            bombText = Util.createTextField(0, 24);
            bombText.defaultTextFormat = new TextFormat(null, 20, 0xf0fff0);
            bombText.filters = [bevel];
            addChild(bombText);
            //end
            var waveBd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight * 2, true, 0xff000000 | SEA);
            var length:uint = stage.stageWidth;
            var rad:Number = 6 * Math.PI / length;
            for (var j:int = 0; j < length; j++){
                var theta:Number = 100 + 20 * Math.sin(j * rad);
                waveBd.setPixel(j, theta, 0xffffff);
                waveBd.setPixel(j, 50 + theta, 0xffffff);
            }
            waveBd.floodFill(0, 0, 0x0);
            waveBd.floodFill(0, 101, 0xffffffff);
            wave = new Bitmap(waveBd);
            addChild(wave);
            waveTween = BetweenAS3.to(wave, {y: -stage.stageHeight}, 0.6);
            waveTween.onComplete = onJapan;
            japanText = Util.createTextField(120, 180);
            japanText.defaultTextFormat = new TextFormat(null, 50, 0xff8c00);
            japanText.text = "ジャパーン";
            japanText.filters = [bevel];
            japanText.rotationZ = 20;
            addChild(japanText);
            japanText.visible = false;
            gameEndText = Util.createTextField(100, 100);
            gameEndText.defaultTextFormat = new TextFormat(null, 40, BOMB);
            addChild(gameEndText);
            gameEndMessage = Util.createTextField(120, 300);
            gameEndMessage.defaultTextFormat = new TextFormat(null, 36, BOMB);
            addChild(gameEndMessage);
            retryText = Util.createTextField(200, 420);
            retryText.defaultTextFormat = new TextFormat(null, 30, BOMB);
            retryText.text = "リトライ";
            retryText.addEventListener(MouseEvent.CLICK, gameInit);
            addChild(retryText);
            //
            gameInit(null);
            //
            stage.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

        }

        private function onTimer(e:TimerEvent):void {
            timeText.text = "Time : " + (++time);
        }

        //mouse
        private function upHandler(e:MouseEvent):void {
            isMouseDown = false;
        }

        private function downHandler(e:MouseEvent):void {
            isMouseDown = true;
            oldX = e.stageX;
            oldY = e.stageY;
        }

        private function moveHandler(e:MouseEvent):void {
            if (isMouseDown){
                var dx:int = e.stageX - oldX;
                oldX = e.stageX;
                japan.x += dx;
                var dy:int = e.stageY - oldY;
                oldY = e.stageY;
                japan.y += dy;
                //
                if (japan.x < limitX){
                    japan.x = limitX;
                } else if (japan.x > MARGIN){
                    japan.x = MARGIN;
                }
                if (japan.y < limitY){
                    japan.y = limitY;
                } else if (japan.y > MARGIN){
                    japan.y = MARGIN;
                }
            }
        }

        //game
        private function onKeyDown(e:KeyboardEvent):void {
            var index:int = japanHitArea.getPixel(stage.mouseX - japan.x, stage.mouseY - japan.y) - 0xff00;
            if (index < 0 || isOver){
                return;
            }
            switch (e.keyCode){
                case Keyboard.Z:
                    open(prefectures[index]);
                    break;
                case Keyboard.X:
                    flag(prefectures[index]);
                    break;
                default:
                    break;
            }
        }

        private function open(pref:Prefecture):void {
            if (numOpened == NUM_BOMBS){
                createBomb(pref.index);
                calcBomb();
                timer.start();
            }
            if (pref.state == 0){
                if (pref.bomb == -1){
                    timer.reset();
                    isOver = true;
                    gameOver();
                    return;
                } else {
                    pref.state = 1;
                    pref.tf.visible = true;
                    pref.fill(japanBd, SCORCHED);
                    numOpened++;
                    if (pref.bomb == 0){
                        openNext(pref);
                    }
                }
            }
            if (numOpened == 47){
                timer.reset();
                isOver = true;
                gameClear();
                return;
            }
        }

        private function openNext(pref:Prefecture):void {
            var length:uint = pref.numNext;
            for (var i:int = 0; i < length; i++){
                var nextPref:Prefecture = prefectures[pref.nextTo[i]];
                if (nextPref.state != 1){
                    nextPref.state = 1;
                    nextPref.tf.visible = true;
                    nextPref.fill(japanBd, SCORCHED);
                    numOpened++;
                    if (nextPref.bomb == 0){
                        openNext(nextPref);
                    }
                }

            }
        }

        private function flag(pref:Prefecture):void {
            if (pref.state == 0){
                numFlaged--;
                pref.state = 2;
                pref.fill(japanBd, FLAG);
            } else if (pref.state == 2){
                numFlaged++;
                pref.state = 0;
                pref.fill(japanBd, LAND);
            }
            bombText.text = "Bomb : " + numFlaged;
        }

        //init
        private function gameInit(e:MouseEvent):void {
            for (var i:int = 0; i < 47; i++){
                var pref:Prefecture = prefectures[i];
                pref.fill(japanBd, LAND);
                pref.tf.visible = false;
                pref.bomb = 0;
                pref.state = 0;
            }
            numOpened = NUM_BOMBS;
            numFlaged = NUM_BOMBS;
            isOver = false;
            time = 0;
            timeText.text = "Time : 0";
            bombText.text = "Bomb : " + numFlaged;
            wave.y = stage.stageHeight;
            gameEndText.visible = false;
            gameEndMessage.visible = false;
            retryText.visible = false;
        }

        private function createBomb(except:uint):void {
            var bombCreated:uint = 0;
            loop: while (bombCreated < 10){
                var bomb:uint = Math.random() * 47 >> 0;
                if (bomb == except){
                    continue;
                }
                for (var i:int = 0; i < bombCreated; i++){
                    if (bombs[i] == bomb){
                        continue loop;
                    }
                }
                bombs[bombCreated] = bomb;
                prefectures[bomb].bomb = -1;
                bombCreated++;
            }
        }

        private function calcBomb():void {
            for (var j:int = 0; j < 47; j++){
                var pref:Prefecture = prefectures[j];
                var length:uint = pref.numNext;
                if (pref.bomb == -1){
                    continue;
                }
                var numNextBombs:uint = 0;
                for (var i:int = 0; i < length; i++){
                    if (prefectures[pref.nextTo[i]].bomb == -1){
                        numNextBombs++;
                    }
                }
                pref.bomb = numNextBombs;
                if (numNextBombs == 0){
                    pref.tf.text = "";
                } else {
                    pref.tf.text = String(numNextBombs);
                }
            }
        }

        //end
        private function gameOver():void {
            for (var i:int = 0; i < NUM_BOMBS; i++){
                var pref:Prefecture = prefectures[bombs[i]];
                pref.fill(japanBd, BOMB);
            }
            waveTween.play();
        }

        private function onJapan():void {
            japanText.visible = true;
            var japanTimer:Timer = new Timer(700, 1);
            japanTimer.addEventListener(TimerEvent.TIMER, onJapanTimer);
            japanTimer.start();
        }

        private function onJapanTimer(e:TimerEvent):void {
            japanText.visible = false;
            gameEndText.text = "ゲームオーバー";
            gameEndText.visible = true;
            gameEndMessage.text = "日本は沈没した。";
            gameEndMessage.visible = true;
            retryText.visible = true;
        }

        private function gameClear():void {
            gameEndText.text = "ゲームクリアー";
            gameEndText.visible = true;
            gameEndMessage.text = "日本は無事だった。";
            gameEndMessage.visible = true;
            retryText.visible = true;
        }

    }

}
import flash.display.BitmapData;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

class Prefecture {
    public var index:uint;
    public var x:uint;
    public var y:uint;
    public var nextTo:Vector.<uint>;
    public var numNext:uint
    public var bomb:int = 0;
    public var state:uint = 0;
    public var tf:TextField;
    public var isLand:Island;

    public function Prefecture(index:uint, x:uint, y:uint, next:String){
        this.index = index;
        if (index == 14){
            isLand = new Island(1320, 1238);
        } else if (index == 27){
            isLand = new Island(881, 1798);
        } else if (index == 42){
            isLand = new Island(303, 2081);
        }
        this.x = x;
        this.y = y;
        if (next == ""){
            nextTo = null;
            numNext = 0;
        } else {
            var nexts:Array = next.split("/");
            numNext = nexts.length;
            nextTo = new Vector.<uint>(numNext);
            for (var i:int = 0; i < numNext; i++){
                nextTo[i] = uint(nexts[i]);
            }
        }
        tf = Util.createTextField(x - 8, y - 10);
        tf.defaultTextFormat = new TextFormat(null, 24, 0xf0f8ff);
    }

    public function fill(sorce:BitmapData, color:uint):void {
        sorce.floodFill(x, y, color);
        if (isLand){
            sorce.floodFill(isLand.x, isLand.y, color);
        }
    }

}

class Island {
    public var x:uint;
    public var y:uint;

    public function Island(x:uint, y:uint){
        this.x = x;
        this.y = y;
    }
}

class Util {

    public function Util(){
    }

    public static function createTextField(x:Number, y:Number):TextField {
        var tf:TextField = new TextField();
        tf.x = x;
        tf.y = y;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.selectable = false;
        return tf;
    }
}