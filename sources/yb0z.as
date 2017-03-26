package  
{
    import com.adobe.serialization.json.JSON;
    import com.bit101.components.Label;
    import com.bit101.components.List;
    import com.bit101.components.NumericStepper;
    import com.bit101.components.ProgressBar;
    import com.bit101.components.PushButton;
    import com.bit101.components.VBox;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.geom.ColorTransform;
    import flash.net.navigateToURL;
    import flash.net.SharedObject;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.escapeMultiByte;
    import net.wonderfl.data.APICodeData;
    import net.wonderfl.data.APIForksData;
    import net.wonderfl.utils.WonderflAPI;
    
    /**
     * [企画] 皆で一つのものを作ろうぜ！
     * 15パズルを皆で作ろう！
     * 皆が作るのは -> http://wonderfl.net/c/mJwf
     * をフォークして動くムービーを作る。
     * フォークしたら企画に勝手に参加！
     * 難しい絵柄を作ってみよう！
     * 注意：簡単に無理ゲーが作れてしまうので、難しすぎないように工夫してみてくださいｗ
     * (15パズルなのに MovieJigsawPuzzle って名前になっているのは気のせいです。)
     * @author jc at bk-zen.com
     */
    [SWF (backgroundColor = "0xFFFFFF", frameRate = "60", width = "465", height = "465")]
    public class MovieJigsawPuzzle extends Sprite 
    {
        private const MP_URL: String = "http://wonderfl.net/c/mJwf";
        private const NG: Array = [];
        
        public function MovieJigsawPuzzle() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            //
            var obj: Object = loaderInfo.parameters;
            
            api = new WonderflAPI(obj);
            
            var box: VBox = new VBox(this);
            progressTitle = new Label(box, 0, 0, "Loading...");
            progressBar = new ProgressBar(box);
            progressBar.setSize(200, 10);
            box.draw();
            box.move(465 - box.width >> 1, 465 - box.height >> 1);
            
            saveData = SharedObject.getLocal(api.appID);
            dataArray = [];
            cnt = 1;
            loadCode(api.getAppID(MP_URL));
        }
        
        private var api: WonderflAPI;
        private var dataArray: Array;
        private var mpData: Array;
        private var cnt: int;
        private var loadCnt: int;
        private var progressBar:ProgressBar;
        private var progressTitle: Label;
        private var listParent: Sprite;
        private var list: List;
        private var selectData: MPData;
        private var levelStep: NumericStepper;
        private var levelLabel: Label;
        private var playBtn: PushButton;
        private var bestScore: Label;
        private var tweetBtn: PushButton;
        private var game:Game;
        private var codeBtn:PushButton;
        
        private function loadCode(id: String): void
        {
            if (NG.indexOf(id) >= 0) 
            {
                loadCnt++;
                return;
            }
            var urlLoader: URLLoader = new URLLoader();
            urlLoader.addEventListener(Event.COMPLETE, onLoadCode);
            urlLoader.load(api.apiCode(id));
        }
        
        private function onLoadCode(e: Event): void 
        {
            loadCnt++;
            var urlLoader: URLLoader = URLLoader(e.target);
            urlLoader.removeEventListener(Event.COMPLETE, onLoadCode);
            var data: APICodeData = new APICodeData(JSON.decode(urlLoader.data));
            if (!data.isOK) return;
            if (data.code.compileOK) dataArray.push(data);
            if ((cnt += data.code.forked_count) > 0) loadFork(data.code.id);
            onProgress();
            if (cnt == loadCnt) onComp();
        }
        
        private function loadFork(id: String): void
        {
            var urlLoader: URLLoader = new URLLoader();
            urlLoader.addEventListener(Event.COMPLETE, onLoadFork);
            urlLoader.load(api.apiForks(id));
        }
        
        private function onLoadFork(e: Event): void 
        {
            var urlLoader: URLLoader = URLLoader(e.target);
            urlLoader.removeEventListener(Event.COMPLETE, onLoadFork);
            var data: APIForksData = new APIForksData(JSON.decode(urlLoader.data));
            for (var i: int = 0; i < data.length; i++) loadCode(data.forks[i].id);
        }
        
        private function onProgress():void 
        {
            progressBar.maximum = cnt, progressBar.value = loadCnt;
        }
        
        private function onComp():void 
        {
            progressTitle.text = "Initialize...";
            progressBar.maximum = cnt = dataArray.length, progressBar.value = loadCnt = 0, mpData = [];
            for (var i: int = 0; i < cnt; i++) { new MPData(dataArray[i], onCompHandler); }
        }
        
        private function onCompHandler(data: MPData):void 
        {
            if (data.isOK) loadCnt = mpData.push(data);
            else --cnt;
            progressBar.maximum = cnt, progressBar.value = loadCnt;
            if (cnt == loadCnt) onCompInit();
        }
        
        private function onCompInit():void 
        {
            while (numChildren > 0) removeChildAt(0);
            addChild(listParent = new Sprite());
            list = new List(listParent);
            list.listItemClass = MPListItem;
            list.setSize(450, 385);
            list.move(7, 7);
            list.items = mpData;
            list.listItemHeight = 55;
            list.addEventListener(Event.SELECT, onSelect);
            levelLabel        = new Label(listParent, 7, 400, "LEVEL : ");
            levelStep         = new NumericStepper(listParent, 45, 400);
            playBtn           = new PushButton(listParent, 358, 400, "PLAY", onClickStart);
            bestScore         = new Label(listParent, 7, 418, "BEST SCORE : ");
            tweetBtn          = new PushButton(listParent, 358, 418, "TWEET", onClickTweet);
            codeBtn           = new PushButton(listParent, 258, 400, "CODE", onClickCodeBtn);
            levelStep.minimum = 1;
            codeBtn.enabled = levelStep.enabled = playBtn.enabled = tweetBtn.enabled = false;
            playBtn.transform.colorTransform = new ColorTransform(1, 0.8, 0.8);
            
        }
        
        private function onClickCodeBtn(e: Event):void 
        {
            navigateToURL(new URLRequest("http://wonderfl.net/c/" + selectData.id));
        }
        
        private function onSelect(e: Event): void 
        {
            selectData        = MPData(list.selectedItem);
            levelStep.value   = 1;
            levelStep.maximum = selectData.level;
            codeBtn.enabled = levelStep.enabled = playBtn.enabled = true;
            tweetBtn.enabled  = (uint(saveData.data[selectData.id]) > 0);
            bestScore.text    = "BEST SCORE : " + uint(saveData.data[selectData.id]) + " [ms]";
        }
        
        private function onClickStart(e: Event):void 
        {
            removeChild(listParent);
            addChild(game ||= new Game(tweet, showMenu));
            game.x = 12;
            stage.frameRate = selectData.frameRate;
            game.start(selectData, levelStep.value);
        }
        
        private function showMenu():void 
        {
            removeChild(game);
            addChild(listParent);
        }
        
        private function onClickTweet(e: Event):void 
        {
            tweet(selectData.title.substr(0, 50), uint(uint(saveData.data[selectData.id]) / 1000));
        }
        
        private function tweet(title: String, score: uint): void
        {
            navigateToURL(new URLRequest("http://twitter.com/share?" + 
                "text=" + escapeMultiByte("Playing MJP [" + title + "] [score : " + score + " sec] #wonderfl") + 
                "&url=" + escapeMultiByte("http://wonderfl.net/c/" + api.appID)//+ 
                //"&via=" + escapeMultiByte("bkzen")
            ));
        }
    }
}
import com.bit101.components.Component;
import com.bit101.components.HBox;
import com.bit101.components.Label;
import com.bit101.components.ListItem;
import com.bit101.components.Panel;
import com.bit101.components.PushButton;
import com.bit101.components.VBox;
import com.bit101.components.Window;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import flash.net.URLRequest;
import flash.utils.describeType;
import flash.utils.getTimer;
import net.wonderfl.data.APICodeData;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.Cubic;
import org.libspark.betweenas3.tweens.ITween;

var saveData: SharedObject;

class MPData
{
    private var data: APICodeData;
    private var compHandler: Function;
    private var swf: Loader, thumb: Loader, user: Loader;
    private var _isOK: Boolean;
    private var _disp: DisplayObject;
    private var _color: uint;
    private var _frameRate: uint;
    private var _level: uint;
    private var cnt: uint;
    function MPData(data: APICodeData, compHandler: Function)
    {
        this.data = data, this.compHandler = compHandler;
        swf = new Loader(), thumb = new Loader(), user = new Loader();
        swf.contentLoaderInfo.addEventListener(Event.COMPLETE, onComp);
        thumb.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompThumb);
        user.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompThumb);
        swf.load(new URLRequest(data.code.swf + "?t=" + new Date().getTime()));
        user.load(new URLRequest(data.code.user.icon));
        thumb.load(new URLRequest(data.code.thumbnail));
    }
    
    private function onComp(e: Event): void 
    {
        swf.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComp);
        var obj: Object = Object(swf.content);
        try 
        {
            var o: Object = { };
            obj.initialize(o);
            _disp = o["disp"];
            if (_disp == null) throw new Error("MPError #01");
            _color = (o["color"] == null ? 0x000000 : uint(o["color"]));
            _frameRate = (o["frameRate"] == null ? 60 : uint(o["frameRate"])) || 1;
            _frameRate = _frameRate > 60 ? 60 : _frameRate;
            _level = (o["level"] == null ? 1 : uint(o["level"])) || 1;
            var xml: XML = describeType(obj);
            var start: XML = xml.method.(@name == "start")[0];
            var end: XML = xml.method.(@name == "end")[0];
            _isOK = start.parameter.length() == 1 && start.parameter[0].@type == "uint";
            _isOK = _isOK && end.toXMLString() != "" && end.parameter.length() == 0;
            if (!_isOK) throw new Error("MPError #02");
        }
        catch (err:Error)
        {
            trace("hoge:", err);
            _isOK = false;
            _disp = null;
            swf.unloadAndStop();
            thumb.unloadAndStop();
            user.unloadAndStop();
            thumb.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompThumb);
            user.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompThumb);
            swf = thumb = user = null;
        }
        cnt++;
        check();
    }
    
    private function onCompThumb(e: Event): void 
    {
        var loader: Loader = Loader(e.target.loader);
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompThumb);
        cnt++, loader.width = loader.height = 45;
        check();
    }
    
    private function check():void 
    {
        if (cnt == 3) compHandler(this);
    }
    
    public function unload(): void 
    {
        if (swf) 
        {
            swf.contentLoaderInfo.addEventListener(Event.COMPLETE, onComp);
            swf.unloadAndStop();
        }
        if (user)
        {
            user.unloadAndStop();
            user.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompThumb);
        }
        if (thumb) 
        {
            thumb.unloadAndStop();
            thumb.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCompThumb);
        }
        swf = thumb = user = null;
    }
    
    public function start(level: uint): void
    {
        if (swf && swf.content) Object(swf.content).start(level);
    }
    
    public function end():void 
    {
        if (swf && swf.content) Object(swf.content).end();
    }
    
    public function get isOK(): Boolean { return _isOK; }
    
    public function get disp(): DisplayObject { return _disp; }
    
    public function get color(): uint { return _color; }
    
    public function get frameRate(): uint { return _frameRate; }
    
    public function get level(): uint { return _level; }
    
    public function get title(): String { return data.code.title; }
    
    public function get thumbnail(): DisplayObject { return thumb; }
    
    public function get icon(): DisplayObject { return user; }
    
    public function get name(): String { return data.code.user.name; }
    
    public function get id(): String { return data.code.id; }
}

class MPListItem extends ListItem
{
    function MPListItem(parent: DisplayObjectContainer = null, xpos: Number = 0, ypos: Number = 0, data: Object = null) { super(parent, xpos, ypos, data); }
    
    protected var thumb: Panel;
    protected var user:  Panel;
    protected var level: Label;
    protected var userName: Label;
    
    override protected function addChildren(): void 
    {
        _label = new Label(this, 55, 2), level = new Label(this, 55, 17), userName = new Label(this, 55, 32);
        thumb = new Panel(this, 5, 5), thumb.setSize(45, 45), user = new Panel(this, 388, 5), user.setSize(45, 45);
    }
    
    override public function draw(): void 
    {
        dispatchEvent(new Event(Component.DRAW));
        graphics.clear();
        graphics.beginFill(_selected ? _selectedColor : (_mouseOver ? _rolloverColor : _defaultColor));
        graphics.drawRect(0, 0, _width, _height);
        if (_data == null) return;
        while (thumb.content.numChildren > 0) thumb.content.removeChildAt(0);
        thumb.content.addChild(_data.thumbnail);
        while (user.content.numChildren > 0) user.content.removeChildAt(0);
        user.content.addChild(_data.icon);
        _label.text   = "TITLE : " + _data.title;
        level.text    = "LEVEL : " + _data.level + "    SCORE : " + uint(saveData.data[_data.id]) + " [ms]";
        userName.text = "USER  : " + _data.name;
    }
}

class Game extends Sprite
{
    private var bmd: BitmapData, rect: Rectangle, time: Label, blank: Piece, id: String, title: String;
    private var disp: DisplayObject, color: uint, startTime: int, isClear: Boolean = false, clearTime: uint;
    private var pieces: Vector.<Piece> = new Vector.<Piece>(16, true);
    private var clearWindow: Window, scoreLabel: Label;
    private var retryBtn: PushButton, menuBtn: PushButton, tweetBtn: PushButton;
    private var _tweetHandler:Function;
    private var _selectData:MPData;
    private var _level:int;
    private var _showMenu:Function;
    function Game(tweetHandler: Function, showMenu: Function) 
    {
        _showMenu = showMenu;
        _tweetHandler = tweetHandler;
        bmd = new BitmapData(440, 440, false, 0), rect = bmd.rect;
        time = new Label(this);
        time.x = 12, time.y = 440;
        time.text = "TIME : ";
        for (var i: int = 0; i < 16; i++) addChild(pieces[i] = new Piece(bmd, i)).addEventListener(MouseEvent.CLICK, onClick);
        //
        blank       = pieces[15];
        clearWindow = new Window(null, 0, 0, "PUZZLE CLEAR");
        scoreLabel  = new Label(clearWindow.content);
        retryBtn    = new PushButton(clearWindow.content, 0, 20, "RETRY", onClickRetry);
        menuBtn     = new PushButton(clearWindow.content, 0, 40, "RETURN TO MENU", onClickMenu);
        tweetBtn    = new PushButton(clearWindow.content, 0, 60, "TWEET", onClickTweet);
    }
    
    private function onClickTweet(e: Event):void 
    {
        _tweetHandler(title.substr(0, 50), clearTime / 1000);
    }
    
    private function onClickRetry(e: Event):void 
    {
        removeChild(clearWindow);
        _selectData.end();
        start(_selectData, _level);
    }
    
    private function onClickMenu(e: Event):void 
    {
        removeChild(clearWindow);
        removeEventListener(Event.ENTER_FRAME, loop);
        isClear = false;
        clearTime = startTime = 0;
        _showMenu();
    }
    
    public function start(selectData:MPData, level: int):void 
    {
        _level = level;
        _selectData = selectData;
        _selectData.start(level);
        isClear = false;
        clearTime = 0;
        shuffle();
        disp = selectData.disp, color = selectData.color, startTime = getTimer(), id = selectData.id, title = selectData.title;
        addEventListener(Event.ENTER_FRAME, loop);
        for (var i: int = 0; i < 16; i++) pieces[i].move(i);
    }
    
    private function shuffle(): void 
    {
        for (var i: int = 0, to: int ; i < 200; i++ ) { for (var j: int = 0; j < 2; j++ ) { // 0 - 15 で偶数回シャッフルすれば解けない問題は作られない。
            var from: int = Math.random() * 15;
            do { to = Math.random() * 15; } while (from == to);
            swap(from, to);
        }}
    }
    private function swap(from: int, to: int, slideX: int = 0, slideY: int = 0): void
    {
        var p: Piece = pieces[from];
        pieces[from] = pieces[to];
        pieces[to] = p;
        if (slideX != 0)
        {
            pieces[from].slideX(slideX);
            pieces[to].slideX(- slideX);
        }
        if (slideY != 0)
        {
            pieces[from].slideY(slideY);
            pieces[to].slideY(- slideY);
        }
    }
    
    private function onClick(e: MouseEvent): void 
    {
        if (isClear) return;
        var b: int = blank.point, c: int = Piece(e.target).point, i: int, n: int, m: int, j: int, k: int;
        if ((b % 4) == (c % 4)) 
        {
            m = (b - c) / 4 | 0, n = (m < 0 ? - m : m), j = m < 0 ? -1 : 1;
            for (i = 0; i < n; i++) swap(k = b - i * j * 4, k - j * 4, 0, j);
        }
        else if ((b / 4 | 0) == (c / 4 | 0))
        {
            m = (b - c) % 4, n = (m < 0 ? - m : m), j = m < 0 ? -1 : 1;
            for (i = 0; i < n; i++) swap(k = b - i * j, k - j, j);
        }
        var check: Boolean = true;
        for (i = 0; i < 16; i++) 
        {
            if (!pieces[i].check()) check = false;
        }
        if (check)
        {
            for (i = 0; i < 16; i++) pieces[i].clear();
            clearTime = (getTimer() - startTime);
            scoreLabel.text = time.text = "TIME : " + clearTime + " [ms]";
            if ((uint(saveData.data[id]) == 0) || uint(saveData.data[id]) > clearTime) 
            {
                saveData.data[id] = clearTime;
                saveData.flush();
            }
            isClear = true;
            clearWindow.x = stage.stageWidth  - clearWindow.width  >> 1;
            clearWindow.y = stage.stageHeight - clearWindow.height >> 1;
            addChild(clearWindow);
        }
    }
    
    private function loop(e: Event): void 
    {
        bmd.lock();
        bmd.fillRect(rect, color);
        bmd.draw(disp);
        bmd.unlock();
        if (!isClear) time.text = "TIME : " + (getTimer() - startTime) + " [ms]";
    }
}

class Piece extends Sprite
{
    private var bmp: Bitmap, sh: Shape, index: int;
    public var point: int;
    private var tw:ITween;
    function Piece(bmd: BitmapData, index: int)
    {
        addChild(bmp = new Bitmap(bmd));
        bmp.mask = addChild(sh = new Shape());
        sh.graphics.beginFill(0);
        sh.graphics.drawRect(1, 1, 108, 108);
        bmp.x = - (x = (index % 4)     * 110);
        bmp.y = - (y = (index / 4 | 0) * 110);
        this.index = index;
    }
    public function move(index: int): void
    {
        point = index;
        x = (index % 4)     * 110;
        y = (index / 4 | 0) * 110;
        if (index == 15) visible = false;
    }
    public function slideX(i: int): void
    {
        tw = BetweenAS3.tween(this, { x: ((point % 4) + i) * 110 }, { x: (point % 4) * 110 }, 0.2, Cubic.easeInOut);
        tw.play();
        point += i;
    }
    public function slideY(i: int): void
    {
        tw = BetweenAS3.tween(this, { y: ((point / 4 | 0) + i) * 110 }, { y: (point / 4 | 0) * 110 }, 0.2, Cubic.easeInOut);
        tw.play();
        point += i * 4;
    }
    
    public function check(): Boolean
    {
        return index == point;
    }
    
    public function clear():void 
    {
        if (tw && tw.isPlaying) tw.onComplete = onComp;
        else onComp();
    }
    
    private function onComp():void 
    {
        tw = null;
        sh.graphics.clear();
        sh.graphics.beginFill(0);
        sh.graphics.drawRect(0, 0, 110, 110);
        visible = true;
    }
}