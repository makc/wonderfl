/**
 * drawTriangles を使用し、各頂点座標をそれぞれ動かすことで
 * ページがめくれるアニメーションを再現しています。
 * 
 * 左右から捲れる2パターンの動きを
 * ローディング時に Tweener で動かし、
 * その間の頂点座標をキャッシュしています。
 * 
 * 実際に動かすときはキャッシュデータを元に
 * 各フレームへの描画を行います。
 * 
 * 画像は YQL を利用し FlickrAPI から取得したものを使用しています。
 * 上にある検索窓から好きなタグのデータを取得することが可能です。
 */
package
{
    import caurina.transitions.properties.CurveModifiers;
    import caurina.transitions.properties.DisplayShortcuts;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.system.Security;
    [SWF(width = "465", height = "465", backgroundColor = "0xFFFFFF", frameRate = "60")]
    public class Main extends Sprite
    {
        public static const WIDTH:uint = 444;
        public static const HEGHT:uint = 398;
        public static const SEGMENT_X:uint = 5;
        public static const SEGMENT_Y:uint = 3;
        public static const TAG:String = 'sunset';
        public static const NUM:uint = 20;
        public function Main():void
        {
            Wonderfl.capture_delay(30);
            if (stage) { _init() } else { addEventListener(Event.ADDED_TO_STAGE, _init) } ;
        }
        private function _init(e:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, _init);
            Security.allowDomain( "*" );
            Security.loadPolicyFile("http://query.yahooapis.com/crossdomain.xml");
            Security.loadPolicyFile("http://api.flickr.com/crossdomain.xml");
            for (var i:int = 1, len:uint = 5; i <= len; i++)
            {
                Security.loadPolicyFile("http://farm" + i + ".static.flickr.com/crossdomain.xml");
            }
            CurveModifiers.init();
            DisplayShortcuts.init();
            new Init(new Context(this), Main.TAG, Main.NUM).start()
        }
    }
}
import __AS3__.vec.Vector;
import caurina.transitions.Tweener;
import com.bit101.components.FPSMeter;
import com.bit101.components.InputText;
import com.bit101.components.Label;
import com.bit101.components.ProgressBar;
import com.bit101.components.PushButton;
import com.bit101.components.ComboBox;
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.net.*;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import jp.progression.commands.lists.LoaderList;
import jp.progression.commands.net.LoadBitmapData;
class Init 
{
    private var _isDebug:Boolean = true;
    
    private var _context:Context, _controller:Controller, _graSh:Shape, _saveTurnOver:MotionSave;
    private var _imgPathList:Vector.<String>;
    private var _loaderList:LoaderList;
    private var _apiLoader:URLLoader = new URLLoader();
    private var _isBuilding:Boolean, _isInit:Boolean = true, _isLoaderListExecuting:Boolean;
    private var _progress:ProgressBar, _comboBox:ComboBox, _tagInput:InputText, _errorLabel:Label, _tagApi:String, _numApi:uint, _header:Sprite;
    public function Init(context:Context, tag:String, num:uint)
    {
        _context = context;
        _tagApi = tag;
        _numApi = num;
        _progress = new ProgressBar(_context.container, 182, 220);
        _graSh = _createGradationShape();
        _errorLabel = new Label(_context.container, 210, 222, "Not Found");
        _errorLabel.visible = false;
    }
    private function _createGradationShape():Shape
    {
        var result:Shape = new Shape();
        var mtx:Matrix = new Matrix()
        mtx.createGradientBox( Main.WIDTH, 0, 0, 0, 0);
        result.graphics.beginGradientFill(GradientType.LINEAR, [0x0, 0x0, 0x0, 0x0, 0x0], [0.0, 0.3, 0.6, 0.3, 0.0], [77, 112, 127, 142, 177], mtx);
        result.graphics.drawRect(0, 0, Main.WIDTH, Main.HEGHT );
        return result;
    }
    private function _resizeBmd(source:BitmapData):BitmapData
    {
        var result:BitmapData = new BitmapData(Main.WIDTH, Main.HEGHT);
        var n:Number = Math.max(Main.WIDTH / source.width , Main.HEGHT / source.height);
        var mtx:Matrix = new Matrix();
        mtx.createBox(n, n, 0, (Main.WIDTH - source.width * n) * 0.5, (Main.HEGHT - source.height * n) * 0.5);
        result.draw(source, mtx, null, null, null, true);
        result.draw(_graSh)
        return result;
    }
    private function _reset():void
    {
        _context.reset();
        _errorLabel.visible = false;
        if (_apiLoader.hasEventListener(Event.COMPLETE)) { _apiLoader.removeEventListener(Event.COMPLETE, _connectAPIComplete) };
        if (_apiLoader.hasEventListener(IOErrorEvent.IO_ERROR)) { _apiLoader.removeEventListener(IOErrorEvent.IO_ERROR, _error) };
    }
    public function start():void
    {
        _build()
        connect();
    }
    public function connect():void
    {
        Tweener.addTween(_progress, { _autoAlpha:1.0, transition:'linear', time:0.2 } );
        _connectAPI();
    }
    //load images
    private function _connectAPI():void
    {
        var request:URLRequest = new URLRequest('http://query.yahooapis.com/v1/public/yql');
        var variables:URLVariables = new URLVariables();
        variables = new URLVariables();
        variables['q'] = "SELECT * FROM flickr.photos.search(" + _numApi + ") WHERE tags='" + _tagApi + "'";
        variables['format'] = 'xml';
        request.data = variables;
        _apiLoader.load(request);
        _apiLoader.addEventListener(Event.COMPLETE, _connectAPIComplete);
        _apiLoader.addEventListener(IOErrorEvent.IO_ERROR, _error);
    }
    private function _connectAPIComplete(e:Event):void
    {
        _header.visible = true;
        _apiLoader.removeEventListener(Event.COMPLETE, _connectAPIComplete);
        _apiLoader.removeEventListener(IOErrorEvent.IO_ERROR, _error);
        var xml:XML = new XML(_apiLoader.data);
        _imgPathList = new Vector.<String>();
        for (var i:int = 0, len:uint = xml.results.photo.length(); i < len; i++)
        {
            var node:XML = xml.results.photo[i] as XML;
            _imgPathList.push("http://farm" + node.@farm + ".static.flickr.com/" + node.@server + "/" + node.@id + "_" + node.@secret + ".jpg");
        }
        _progress.value += 0.025;
        len = _imgPathList.length;
        if (len < 1)
        {
            _error();
            return
        }
        _loaderList = new LoaderList();
        for ( i = 0; i < _imgPathList.length; i++ )
        {
            var loadBmdData:LoadBitmapData = new LoadBitmapData(new URLRequest(_imgPathList[i]), { cacheAsResource:false } );
            loadBmdData.context = new LoaderContext(true);
            _loaderList.addCommand(loadBmdData);
        }            
        _loaderList.onProgress = function():void 
        {
            _progress.value = this.percent * 0.01 * ((_isInit) ? 0.9 : 0.95) + 0.045;
        }
        _loaderList.onComplete = function():void
        {
            for ( var i:int = 0, len:uint = this.data.length; i < len; i++ )
            {
                _context.bmdList.push(_resizeBmd(this.data[i]));
            }
            _isLoaderListExecuting = false;
            _progress.value += 0.025;
            _isInit ? _motionSaveStart() : _finish()
        }
        _loaderList.execute();
        _isLoaderListExecuting = true;
    }
    private function _error(e:* = null):void
    {
        _header.visible = true;
        if (_apiLoader.hasEventListener(Event.COMPLETE)) { _apiLoader.removeEventListener(Event.COMPLETE, _connectAPIComplete) };
        if (_apiLoader.hasEventListener(IOErrorEvent.IO_ERROR)) { _apiLoader.removeEventListener(IOErrorEvent.IO_ERROR, _error) };
        _errorLabel.visible = true;
        Tweener.addTween(_progress, { _autoAlpha:0.0 } );
    }
    //save motion
    private function _motionSaveStart():void
    {
        _isBuilding = true;
        var dammyBmd:BitmapData = new BitmapData(1, 1, false);
        _saveTurnOver = new MotionSave(dammyBmd, dammyBmd, Main.SEGMENT_X, Main.SEGMENT_Y);
        _saveTurnOver.addEventListener(Event.COMPLETE, _fromLeftMotionComplete);
        _saveTurnOver.turn(MotionSave.LEFT);
    }
    private function _fromLeftMotionComplete(e:Event):void
    {
        _saveTurnOver.removeEventListener(Event.COMPLETE, _fromLeftMotionComplete);
        _context.fromLeft = _saveTurnOver.data.clone();
        _progress.value += 0.025;
        _saveTurnOver.addEventListener(Event.COMPLETE, _fromRightMotionComplete);
        _saveTurnOver.turn(MotionSave.RIGHT);
    }
    private function _fromRightMotionComplete(e:Event):void
    {
        _saveTurnOver.removeEventListener(Event.COMPLETE, _fromRightMotionComplete);
        _context.fromRight = _saveTurnOver.data.clone();
        _progress.value += 0.025;
        _saveTurnOver = null;
        _isBuilding = false;
        _finish();
    }
    private function _build():void
    {
        _header = new Sprite();
        _context.container.addChild(_header).visible = false;;
        new FPSMeter(_header, 10, 7);
        new Label(_header, 124, 7, 'num : ');
        _comboBox = new ComboBox(_header, 154, 7);
        _comboBox.width = 50;
        for (var i:int = 1; i <= 10; i++)
        {
            _comboBox.addItem( { label:String(i * 10), data:i * 10 } );
        }
        _comboBox.selectedIndex = Math.floor(_numApi / 10) - 1;
        new Label(_header, 215, 7, 'tag : ');
        _tagInput = new InputText(_header, 242, 9, _tagApi);
        _tagInput.width = 100;
        new PushButton(_header, 355, 7, 'search', function():void
            {
                if (_isBuilding) return;
                if (_controller) { _controller.close() };
                _tagApi = _tagInput.text;
                _numApi = _comboBox.selectedItem.data;
                _reset();
                _progress.value = 0;
                if(_isLoaderListExecuting)
                    _loaderList.interrupt();
                connect();
            });
    }
    private function _finish():void
    {
        _progress.value = 1;
        if (_isInit)
        {
            _controller = new Controller(_context);
            _isInit = false;
        }
        _controller.build(_context.bmdList);
        _controller.start();
        Tweener.addTween(_progress, { _autoAlpha:0.0, transition:'linear', time:0.2 } );
    }
}
//Initクラス内でデータを持ち回す為のクラス
class Context 
{
    public var fromLeft:PointListData, fromRight:PointListData, container:DisplayObjectContainer
    public var bmdList:Vector.<BitmapData>;
    public function Context(container:DisplayObjectContainer)
    {
        this.container = container;
        reset()
    }
    public function reset():void
    {
        bmdList = new Vector.<BitmapData>();
    }
}
//本の作成を行うクラス
class Controller 
{
    private var _context:Context, _book:Book;
    public function Controller(context:Context)
    {
        _context = context;
        _book = new Book(Main.WIDTH, Main.HEGHT, _context.fromLeft, _context.fromRight);
        _context.container.addChild(_book);
    }
    public function build(list:Vector.<BitmapData>):void
    {
        var dammy:BitmapData = new BitmapData(1,1, false, 0x0);
        _book.addPage(dammy);
        for (var i:int = 0, len:uint = list.length; i < len; i++)
        {
            _book.addDoublePage(list[i]);
        }
        _book.addPage(dammy);
        _book.build();
    }
    public function start():void
    {
        _book.open(0);
        Tweener.addTween(_book, { _autoAlpha:1.0, transition:'easeOutCubic', time:0.6, delay:0.2 } );
    }
    public function close():void
    {
        Tweener.addTween(_book, { _autoAlpha:0.0 } );
        _book.reset();
    }
}
//本クラス
class Book extends Sprite
{
    private var  _pageWidth:uint, _pageHeight:uint, _fromLeftData:PointListData, _fromRightData:PointListData, _viewCount:int = -1, _isNextTurning:Boolean, _isPrevTurning:Boolean, _isLock:Boolean;
    private var _bmdList:Vector.<BitmapData> = new Vector.<BitmapData>(), _motionList:Vector.<Piece> = new Vector.<Piece>();
    public function Book(pageWidth:uint, pageHeight:uint, fromLeftData:PointListData, fromRightData:PointListData)
    {
        _pageWidth = pageWidth;
        _pageHeight = pageHeight;
        _fromLeftData = fromLeftData;
        _fromRightData = fromRightData;
        alpha = 0;
        x = 10;
        y = 34;
        new PushButton(this,    0, 405, 'prev', function():void { prev() } );
        new PushButton(this, 345, 405, 'next', function():void { next() } );
        _bmdList = new Vector.<BitmapData>();
        _motionList = new Vector.<Piece>();
    }
    public function reset():void
    {
        if (_viewCount + 1 <= _motionList.length - 1)
        {
            Piece(_motionList[_viewCount + 1]).hide();
            Piece(_motionList[_viewCount]).hide();
        }
        _bmdList = new Vector.<BitmapData>();
        _motionList = new Vector.<Piece>();
        _viewCount = 0;
    }
    private function _divisionBmd(src:BitmapData, rect:Rectangle):BitmapData
    {
        var result:BitmapData = new BitmapData(rect.width, rect.height, true, 0xFF000000);
        result.draw(src, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
        return result;
    }
    public function addPage(bmd:BitmapData):void
    {
        _bmdList.push(bmd);
    }
    public function addDoublePage(bmd:BitmapData):void
    {
        var w:Number = bmd.width * 0.5, h:Number = bmd.height;
        _bmdList.push(_divisionBmd(bmd, new Rectangle(0, 0, w, h)), _divisionBmd(bmd, new Rectangle(w, 0, w, h)));
    }
    public function build():void
    {
        for (var i:int = 0, len:uint = (_bmdList.length>>1); i < len; i++)
        {
            _motionList.push(new Piece(this, i, _bmdList[i * 2], _bmdList[i * 2 + 1], _fromLeftData, _fromRightData))
        }
    }
    public function next():void
    {
        if (_isLock || _isPrevTurning || _viewCount >= _motionList.length -2) { return };
        _viewCount++    
        var waitPiece:Piece = _motionList[_viewCount + 1];
        var turnPiece:Piece = _motionList[_viewCount];
        waitPiece.frontWait();
        turnPiece.next();
        turnPiece.addEventListener(Event.COMPLETE, _onNextCompleteHandler);
        turnPiece.addEventListener(Event.CHANGE, _onHalfTurnHandler);
        _isNextTurning = true;
        _isLock = true;
    }
    public function prev():void
    {
        if (_isLock || _isNextTurning || _viewCount <= 0) { return };
        _viewCount--;
        var waitPiece:Piece = _motionList[_viewCount];
        var turnPiece:Piece = _motionList[_viewCount + 1];
        waitPiece.backWait();
        turnPiece.prev();
        turnPiece.addEventListener(Event.COMPLETE, _onPrevCompleteHandler);
        turnPiece.addEventListener(Event.CHANGE, _onHalfTurnHandler);
        _isPrevTurning = true;
        _isLock = true;
    }
    private function _onHalfTurnHandler(e:Event):void 
    {
        e.target.removeEventListener(Event.CHANGE, _onHalfTurnHandler);
        _isLock = false;
    }
    public function open(num:uint):void
    {
        _motionList[num].backWait();
        _motionList[num + 1].frontWait();
        _viewCount = num;
    }
    private function _onNextCompleteHandler(e:Event):void 
    {
        _isNextTurning = false;
        Piece(e.target).removeEventListener(Event.COMPLETE, _onNextCompleteHandler);
        var target:Piece = _motionList[Piece(e.target).id - 1];
        if (target != null) { target.hide() };
    }
    private function _onPrevCompleteHandler(e:Event):void 
    {
        _isPrevTurning = false;
        Piece(e.target).removeEventListener(Event.COMPLETE, _onPrevCompleteHandler);
        var target:Piece = _motionList[Piece(e.target).id + 1];
        if (target != null) { target.hide() };
    }
}
//両面表示のページクラス
class Piece extends EventDispatcher
{
    private var _id:uint, _fromLeft:MotionLoad, _fromRight:MotionLoad, _container:DisplayObjectContainer;
    public function Piece(container:DisplayObjectContainer, id:uint, frontBmd:BitmapData, backBmd:BitmapData, fromLeftData:PointListData, fromRightData:PointListData)
    {
        _id = id;
        _fromLeft = new MotionLoad(container, frontBmd, _reverse(backBmd), fromLeftData);
        _fromRight = new MotionLoad(container, backBmd, _reverse(frontBmd), fromRightData);
        _fromLeft.x = (Main.WIDTH>>1);
    }
    private function _reverse(source:BitmapData):BitmapData
    {
        var result:BitmapData = new BitmapData(source.width, source.height, true, 0);
        result.draw(source, new Matrix( -1, 0, 0, 1, source.width, 0));
        return result;
    }
    private function _removeListener():void
    {
        if (_fromLeft.hasEventListener(Event.COMPLETE)) { _fromLeft.removeEventListener(Event.COMPLETE, _onLeftCompleteHandler) };
        if (_fromRight.hasEventListener(Event.COMPLETE)) { _fromRight.removeEventListener(Event.COMPLETE, _onRightCompleteHandler) };
    }
    public function next(delayTime:Number = 0.0):void
    {
        _removeListener();
        _fromLeft.hide();
        _fromRight.show();
        _fromRight.addEventListener(Event.CHANGE, _onHalfTurnHandler);
        _fromRight.move();
        _fromRight.addEventListener(Event.COMPLETE, _onRightCompleteHandler);
    }
    public function prev(delayTime:Number = 0.0):void
    {
        _removeListener();
        _fromRight.hide();
        _fromLeft.show();
        _fromLeft.addEventListener(Event.CHANGE, _onHalfTurnHandler);
        _fromLeft.move();
        _fromLeft.addEventListener(Event.COMPLETE, _onLeftCompleteHandler);
    }
    private function _onHalfTurnHandler(e:Event):void 
    {
        e.target.removeEventListener(Event.CHANGE, _onHalfTurnHandler);
        dispatchEvent(e);
    }
    public function backWait():void
    {
        _removeListener();
        _fromLeft.hide();
        _fromRight.show(0);
        _fromRight.wait();
    }
    public function frontWait():void
    {
        _removeListener();
        _fromLeft.show(0);
        _fromRight.hide();
        _fromLeft.wait();
    }
    public function hide():void
    {
        _fromLeft.hide();
        _fromRight.hide();
    }
    private function _onLeftCompleteHandler(e:Event):void 
    {
        _fromLeft.removeEventListener(Event.COMPLETE, _onLeftCompleteHandler)
        dispatchEvent(e);
    }
    private function _onRightCompleteHandler(e:Event):void 
    {
        _fromRight.removeEventListener(Event.COMPLETE,_onRightCompleteHandler)
        dispatchEvent(e);
    }
    public function get id():uint { return _id };
}
//アニメーションのキャッシュ化クラス
class MotionSave extends Shape
{
    public static const LEFT:String = 'left';
    public static const RIGHT:String = 'right';
    private var _isLayout:Boolean = false;
    private var _angle:String;;
    private var _speed:Number =  0.0035;
    private var _delay:Number = 0.001;
    private var _gap:Number = 0.05;
    private var _turnTransition:String = 'easeInOutSine';
    private var _gapTransition:String = 'easeInOutSine';
    private var _sp:SegmentPoint, _sourceW:uint, _sourceH:uint, _isRendering:Boolean = false;
    private var _data:PointListData, _count:uint, _isHalfTurn:Boolean;
    public function MotionSave(flontSource:BitmapData, backSource:BitmapData = null, segmentX:uint = 1, segmentY:uint = 1)
    {
        _sp = new SegmentPoint(false, graphics, flontSource, backSource, segmentX, segmentY);
        _sourceW = flontSource.width;
        _sourceH = flontSource.height;
        _data = new PointListData(segmentX, segmentY);
    }
    private function _layout(angle:String):void
    {
        _angle = angle;
        for (var i:int = 0, len:uint = _sp.points.length; i < len; i++)
        {
            _setPosition(_sp.points[i], _sp.defaultPoints[i], angle);
        }
    }
    private function _setPosition(pt:Point, defPt:Point, angle:String):void
    {
        if (angle == MotionSave.RIGHT)
        {
            pt.x = _sourceW * 2 - defPt.x;
            pt.y = defPt.y;
        }else if (angle == MotionSave.LEFT)
        {
            pt.x = -defPt.x;
            pt.y = defPt.y;
        }
    }
    private function _setTween(pt:Point, defPt:Point, angle:String):Number
    {
        var time:Number, curvePath:Array = [];
        if (angle == MotionSave.RIGHT)
        {
            time = ((1 - defPt.x / _sourceW) * _speed +defPt.y / _sourceH * _delay) * 100;
            curvePath = [ { y:(defPt.y/_sourceH + _gap)* _sourceH } ];
            Tweener.addTween(pt, { x:defPt.x,                                    time:time,    transition:_turnTransition } );
            Tweener.addTween(pt, { y:defPt.y, _bezier:curvePath,        time:time,    transition:_gapTransition } );
        }else if (angle == MotionSave.LEFT)
        {
            time = (defPt.x / _sourceW * _speed + defPt.y / _sourceH * _delay) * 100;
            curvePath = [ { y:(defPt.y / _sourceH - _gap) * _sourceH } ];
            Tweener.addTween(pt, { x:defPt.x,                                    time:time,    transition:_turnTransition } );
            Tweener.addTween(pt, { y:defPt.y, _bezier:curvePath,        time:time,    transition:_gapTransition } );
        }
        return time;
    }
    private function _changeAngle(angle:String):void
    {
        _sp.ascent = (angle == MotionSave.RIGHT) ? false : true;
        _angle = angle;
    }
    private function _removeTweens():void
    {
        for (var i:int = 0, len:uint = _sp.points.length; i < len; i++)
        {
            Tweener.removeTweens(_sp.points[i]);
        }
        Tweener.removeTweens(this);
    }
    private function _startRendering():void
    {
        _count = 0;
        if (_isRendering) { return };
        addEventListener(Event.ENTER_FRAME, _onEnterFrameHandler);
        _isRendering = true;
    }
    private function _stopRendering():void
    {
        if (!_isRendering) { return };
        removeEventListener(Event.ENTER_FRAME, _onEnterFrameHandler);
        _isRendering = false;
    }
    public function initLayout(angle:String):void
    {
        if (_isRendering) { _removeTweens() };
        _layout(angle);
        _sp.saveDraw();
        _isLayout = true;    
    }
    public function turn(angle:String):void
    {
        if (angle != null) { _changeAngle(angle) };
        if (_isRendering) { _removeTweens() };
        if (!_isLayout || _angle != angle) { _layout(angle) };
        var maxTime:Number = 0, time:Number;
        _isHalfTurn = false;
        for (var i:int = 0, len:uint = _sp.points.length; i < len; i++)
        {
            time = _setTween(_sp.points[i], _sp.defaultPoints[i], angle);
            if (time > maxTime) { maxTime = time };
        }
        Tweener.addTween(this, { delay:maxTime, onComplete:_onCompleteTween } );
        _startRendering();
        _isLayout = false;
    }
    private function _onCompleteTween():void
    {
        _stopRendering();
        _onEnterFrameHandler()
        dispatchEvent(new Event(Event.COMPLETE));
    }
    private function _onEnterFrameHandler(e:Event = null):void 
    {
        _sp.saveDraw();
        _data.frontIndices[_count] = _sp.indicesFront;
        _data.backIndices[_count] = _sp.indicesBack;
        _data.vertices[_count] = _sp.vertices;
        if (!_isHalfTurn) { _checkHalfTurn() };
        _count++;
    }
    private function _checkHalfTurn():void
    {
        for (var i:int = 0, len:uint = _sp.points.length; i < len; i++)
        {
            if ((_angle == MotionSave.LEFT && _sp.points[i].x < 0) || (_angle == MotionSave.RIGHT && _sourceW < _sp.points[i].x)) { return };
        }
        _isHalfTurn = true;
        _data.halfTurnId = _count;
    }
    public function get data():PointListData { return _data };
}
//キャッシュを元にBitmapDataに対してアニメーションを再現するクラス
class MotionLoad extends Shape
{
    private var _isRendering:Boolean = false, _isShow:Boolean = false, _container:DisplayObjectContainer, _count:uint, _maxCount:uint, _sp:SegmentPoint, _data:PointListData;
    public function MotionLoad(container:DisplayObjectContainer, flontSource:BitmapData, backSource:BitmapData, data:PointListData)
    {
        _container = container;
        _data = data.clone();
        _data.vertices = _adjustVertices(_data.vertices, flontSource.width, flontSource.height);
        _maxCount = _data.frontIndices.length;
        _sp = new SegmentPoint(true, graphics, flontSource, backSource, _data.segmentX, _data.segmentY);
    }
    private function _startRendering():void
    {
        if (_isRendering) { return };
        addEventListener(Event.ENTER_FRAME, _onEnterFrameHandler);
        _isRendering = true;
    }
    private function _stopRendering():void
    {
        if (!_isRendering) { return };
        removeEventListener(Event.ENTER_FRAME, _onEnterFrameHandler);
        dispatchEvent(new Event(Event.COMPLETE));
        _container.setChildIndex(this, 0);
        _isRendering = false;
    }
    private function _adjustVertices(vertices:Vector.<Vector.<Number>>, w:Number, h:Number):Vector.<Vector.<Number>>
    {
        var num:Number, result:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
        for (var j:int = 0; j < vertices.length; j++)
        {
            var list:Vector.<Number> = new Vector.<Number>();
            for (var i:int = 0; i < vertices[j].length; i++)
            {
                num = vertices[j][i];
                list[i] = (i % 2 == 0) ? num * w : num * h;
            }
            result[j] = list;
        }
        return result;
    }
    public function move(delayTime:Number = 0.0):void
    {
        _count = 0;
        if (_isRendering) { Tweener.removeTweens(this) };
        if (0 < delayTime) { _onEnterFrameHandler() };
        Tweener.addTween(this, { delay:delayTime, onComplete:_startRendering } );
    }
    public function wait():void
    {
        _count = _maxCount -1;
        _onEnterFrameHandler();
    }
    public function show(depth:Number = NaN):void
    {
        if (_isShow) { return };
        if (isNaN(depth))
        {
            _container.addChild(this);
        }else
        {
            _container.addChildAt(this, depth);
        }
        _isShow = true;
    }
    public function hide():void
    {
        if (!_isShow) { return };
        this.visible
        _container.removeChild(this);
        _isShow = false;
    }
    public function setDepth(num:uint):void
    {
        _container.setChildIndex(this, num);
    }
    private function _onEnterFrameHandler(e:Event = null):void 
    {
        if (_count < _maxCount)
        {
            _sp.loadDraw(_data.vertices[_count], _data.frontIndices[_count], _data.backIndices[_count]);
            if (_count == (_data.halfTurnId -4))
            {
                dispatchEvent(new Event(Event.CHANGE));
            }
            _count++;
        }else
        {
            _stopRendering();
        }
    }
}
//キャッシュデータの保存クラス
 class PointListData 
{
    public var segmentX:uint, segmentY:uint, halfTurnId:uint;
    public var frontIndices:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
    public var backIndices:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
    public var vertices:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
    public function PointListData(segmentX:uint, segmentY:uint):void
    {
        this.segmentX = segmentX
        this.segmentY = segmentY;
    }
    private function _deepCopy(list:*):*
    {
        var result:ByteArray = new ByteArray();
        result.writeObject(list);
        result.position = 0;
        return(result.readObject());
    }
    public function clone():PointListData
    {
        var result:PointListData = new PointListData(segmentX, segmentY);
        result.frontIndices = Vector.<Vector.<int>>(_deepCopy(frontIndices));
        result.backIndices = Vector.<Vector.<int>>(_deepCopy(backIndices));
        result.vertices = Vector.<Vector.<Number>>(_deepCopy(vertices));
        result.halfTurnId = halfTurnId;
        return result
    }
}
//DrawTrianglesによってBitmapDataを分割・描画するクラス
class SegmentPoint
{        
    protected var _frontSource:BitmapData, _backSource:BitmapData;
    private var _graphics:Graphics, _divisionW:Number, _divisionH:Number, _sourceW:Number, _sourceH:Number, _loadMode:Boolean, _isAscent:Boolean = true;
    private var _points:Vector.<Point>, _defaultPoints:Vector.<Point>, _indices:Vector.<int>, _uvtData:Vector.<Number>, _vertices:Vector.<Number>, _indicesFront:Vector.<int>, _indicesBack:Vector.<int>;
    public function SegmentPoint(loadMode:Boolean, graphics:Graphics = null, flontSource:BitmapData = null, backSource:BitmapData = null, segmentX:uint = 1, segmentY:uint = 1 )
    {
        _loadMode = loadMode;
        _graphics = graphics;
        _frontSource = flontSource;
        _backSource = backSource;
        _sourceW = _frontSource.width;
        _sourceH = _frontSource.height;
        _divisionW = _frontSource.width / segmentX;
        _divisionH = _frontSource.height / segmentY;
        
        if (_loadMode)
        {
            _uvtData = new Vector.<Number>((segmentX + 1) * (segmentY + 1) * 2, true);
        }else
        {
            var baseCount:uint = (segmentX + 1) * (segmentY + 1);
            _uvtData = new Vector.<Number>(baseCount * 2, true);
            _points = new Vector.<Point>(baseCount, true);
        }
        for (var yy:int = 0; yy <= segmentY; yy++)
        {
            for (var xx:int = 0; xx <= segmentX; xx++)
            {
                _uvSave(xx, yy, segmentX, segmentY);
                if (!_loadMode)
                {
                    var id:uint = xx + yy * (segmentX + 1);
                    _points[id] = new Point(xx * _divisionW, yy * _divisionH);
                }
            }
        }
        if (!_loadMode)
        {
            baseCount = (segmentX + 1) * (segmentY + 1);
            _defaultPoints = new Vector.<Point>(baseCount, true);
            
            _indices  = new Vector.<int>(baseCount * 6, true);    
            for (yy = 0; yy < segmentY; yy++)
            {
                for (xx = 0; xx <= segmentX; xx++)
                {
                    _indicesSave(xx, yy, segmentX, segmentY);
                }
            }
            _defaultPoints = _pointlistCopy(_points);        
        }
    }
    public function saveDraw():void
    {
        var len:uint = _points.length;
        var trianglePointList:Vector.<Point>;
        _vertices = new Vector.<Number>(len * 2, true);
        _indicesFront = new Vector.<int>();
        _indicesBack = new Vector.<int>();
        for (var k:int = 0; k < len; k++)
        {
            var pt:Point = _points[k] as Point;
            _vertices[k * 2] = pt.x;
            _vertices[k * 2 + 1] = pt.y;
        }            
        if (!_backSource)
        {
            _indicesFront = _indices;
        }else
        {
            len = _indices.length / 3;
            for (var i:int = 0; i < len; i++)
            {
                trianglePointList = new Vector.<Point>(3, true);
                for (var j:int = 0; j < 3; j++)
                {
                    var id:uint = _indices[ i * 3 + j];
                    trianglePointList[j] = new Point(_vertices[id * 2], _vertices[id * 2 + 1]);
                }
                var flag:Boolean = _frontCheck(trianglePointList);
                if ((_isAscent) ? flag : !flag)
                {
                    _indicesFront.push(_indices[i*3], _indices[i*3 + 1], _indices[i*3 + 2]);
                }else
                {
                    _indicesBack.push(_indices[i*3], _indices[i*3 + 1], _indices[i*3 + 2]);
                }
            }
        }
    }
    public function loadDraw(vertices:Vector.<Number>, frontIndices:Vector.<int>, backIndices:Vector.<int>):void
    {
        _graphics.clear();
        if (frontIndices.length)
        {
            _graphics.beginBitmapFill(_frontSource, null, false, true);
            _graphics.drawTriangles(vertices, frontIndices, _uvtData);
        }
        if (backIndices.length)
        {
            _graphics.beginBitmapFill(_backSource, null, false, true);
            _graphics.drawTriangles(vertices, backIndices, _uvtData);
        }
        _graphics.endFill();
    }
    private function _uvSave(xx:uint, yy:uint, segmentX:uint, segmentY:uint):void
    {
        var id:uint = xx + yy * (segmentX + 1);
        _uvtData[id * 2] = xx / segmentX;
        _uvtData[id * 2 + 1] = yy / segmentY;
    }
    private function _conversionToUnitVector(vertices:Vector.<Number>):Vector.<Number>
    {
        var len:uint = vertices.length;
        var num:Number;
        var result:Vector.<Number> = new Vector.<Number>(len, true);
        for (var i:int = 0; i < len; i++)
        {
            num = vertices[i];
            result[i] = (i % 2 == 0) ? num / _sourceW : num / _sourceH;
        }
        return result;
    }
    private function _indicesSave(xx:uint, yy:uint, segmentX:uint, segmentY:uint):void
    {
        if (xx < segmentX)
        {
            var i:uint = xx + yy * (segmentX + 1);
            var id:uint = (i - yy) * 6;
            _indices[id] = i;
            _indices[id + 1] = i + 1;
            _indices[id + 2] = i + segmentX + 1;
            _indices[id + 3] = i + 1;
            _indices[id + 4] = i + segmentX + 2;
            _indices[id + 5] = i + segmentX + 1;
        }
    }
    private function _pointlistCopy(list:Vector.<Point>):Vector.<Point>
    {
        var result:Vector.<Point> = new Vector.<Point>();
        var len:uint = list.length;
        for (var i:int = 0; i < len; i++)
        {
            result[i] = Point(list[i]).clone();
        }
        return result
    }
    private function _frontCheck(list:Vector.<Point>):Boolean
    {
        var num:Number = (list[0].x - list[2].x) * (list[1].y - list[2].y) - (list[0].y - list[2].y) * (list[1].x - list[2].x);
        return (0 < num) ? true : false;
    }
    public function get points():Vector.<Point> { return _points };
    public function get defaultPoints():Vector.<Point> { return _defaultPoints };
    public function get ascent():Boolean { return _isAscent };
    public function set ascent(value:Boolean):void
    {
        if (_isAscent == value) { return };
        _indices.reverse();
        _isAscent = value;
    }
    public function get vertices():Vector.<Number> { return _conversionToUnitVector(_vertices) };
    public function get indicesFront():Vector.<int> { return _indicesFront };
    public function get indicesBack():Vector.<int> { return _indicesBack };
}