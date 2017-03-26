// forked from knd's もっちりボロノイ図
/**
*  画像をボロノイ図で描画
*  画像のエッジ付近は細かく、それ以外の領域は大雑把にボロノイ領域を描画
*  
*  based on もっちりボロノイ図 by knd
*  @see http://wonderfl.net/c/vRZn
*  
*  Fortune's algorithm - Wikipedia, the free encyclopedia
*  @see http://en.wikipedia.org/wiki/Fortune's_algorithm
*  
*  解説：planet-ape|blog - Voronoi Face
*  @see http://www.planet-ape.net/blog/archives/884
*
*  2値化グレースケールエッジ検出
*  @see http://d.hatena.ne.jp/flashrod/20061015
*
*  PsychedelicCam
*  @see http://wonderfl.net/c/12Rl
*
*  Yearbook Photos - Interactive Art by Golan Levin and Collaborators
*  @see http://www.flong.com/projects/yearbook/
**/
package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.GraphicsSolidFill;
    import flash.display.GraphicsStroke;
    import flash.display.IGraphicsData;
    import flash.display.IGraphicsFill;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.ConvolutionFilter;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;

    /**
     * @author fumix
     */
    [SWF(backgroundColor="#FFFFFF", frameRate="31", width="465", height="465")]

    public class VoronoiFace extends Sprite {
        //private static const IMAGE_URL : String = "../images/images002.jpg";
        private static const IMAGE_URL : String = "http://farm4.static.flickr.com/3639/3538831894_cca4aabd68.jpg";
        //private const IMAGE_URL:String = "http://www.planet-ape.net/wonderfl/kuri.jpg";  
        
        //表示領域
        private const FX:Number = 5;
        private const FY:Number = 5;
        private const FW:Number = 455;
        private const FH:Number = 455;
        //もっちりフラグ
        private const MOTTIRI:Boolean = true;
        //ボロノイ母点数
        private const N:int = 1800;

        private var _w : int;
        private var _h : int;
        private var _image : Bitmap;
        private var _imageData : BitmapData;

        //エッジ/エッジ以外の座標点
        private var _blackPoint : Vector.<Number2> = new Vector.<Number2>();
        private var _edgePoint : Vector.<Number2> = new Vector.<Number2>();
        private var _firstBlackPoint : Number2;
        private var _firstEdgePoint : Number2;
        private var _bPoint : Number2;
        private var _ePoint : Number2;
        private var _minDist : Number = 0;

        //ボロノイ母点
        private var _voronoiPoints:Vector.<Point> = new Vector.<Point>();

        private var _count : Number = 0;
        private var _bar : Sprite;
        
        private var _enterFrameStep:int = 0;

        public function VoronoiFace() {
            if(stage) initialize();
            else addEventListener(Event.ADDED_TO_STAGE, initialize);
        }

        /**
         * 初期化
         * @param event
         */
        private function initialize(event : Event = null) : void {
            removeEventListener(Event.ADDED_TO_STAGE, initialize);
            //ステージ設定
            //stage.quality = StageQuality.LOW;
            //背景設定
            _w = stage.stageWidth;
            _h = stage.stageHeight;
            var bmd : BitmapData = new BitmapData(_w, _h, true, 0xFFFFFF);
            addChild(new Bitmap(bmd));
            
            //画像の読み込み
            var req : URLRequest = new URLRequest(IMAGE_URL);
            var loader : Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplate);
            loader.load(req, new LoaderContext(true));
            
            //処理状況バー
            _bar = new Sprite();
            _bar.y = _h / 2;
            _bar.graphics.beginFill(0xCCCCCC);
            _bar.graphics.drawRect(0, -5, _w, 10);
            _bar.graphics.endFill();
        }

        /**
         * 画像ダウンロード完了
         * @param event
         */
        private function loadComplate(event : Event) : void {
            event.target.removeEventListener(Event.COMPLETE, loadComplate);
            _image = event.target.content as Bitmap;
            _imageData = _image.bitmapData;
            var base : BitmapData = new BitmapData(_imageData.width, _imageData.height, false, 0xFF000000);
            var edge : BitmapData;
            var min : int = 15;
            var max : int = 230;
            var step : int = 5;

            //グレースケール化
            var t : Number;
            var g : BitmapData = grayscaleFilter(_imageData);
            //ノイズ除去
            g = medianSmoothFilter(g);
            //ステップ数分閾値を変えてエッジを抽出
            for (var i : int = 0;i < step;i++) {
                t = min + (max - min) / step * i;
                //２値化    
                edge = thresholdFilter(g, t);
                //エッジ検出
                edge = laplacianFilter(edge);
                //描画
                base.draw(edge, null, null, BlendMode.ADD);
            }
            //ビットマップ破棄
            edge.dispose();
            
            //元画像表示
            addChild(_image);
            
            //処理バー表示
            addChild(_bar);

            //エッジとエッジ以外の座標を分ける
            selectEdgePoint(base);
        }

        /**
         * エッジとエッジ以外の座標を分ける
         * @param image
         */
        private function selectEdgePoint(image : BitmapData) : void {
            var dx : int,dy : int;
            var p : Number2;
            var oldBlack : Number2;
            var oldEdge : Number2;
            var skip1 : int = 0;
            var skip2 : int = 0;

            //エッジとそれ以外を分ける
            for (dx = 0;dx <= image.width;dx++) {
                for (dy = 0;dy <= image.height;dy++) {
                    p = new Number2();
                    p.x = dx;
                    p.y = dy;
                    //エッジ以外の座標
                    if(image.getPixel(dx, dy) == 0x000000) {
                        //全座標を取ると多すぎるので間引く
                        if(skip1 > 10) {
                            skip1 = 0;
                            _blackPoint.push(p);
                            //リンクリスト
                            if (_firstBlackPoint == null) {
                                oldBlack = _firstBlackPoint = p;
                            } else {
                                oldBlack.next = p;
                                oldBlack = p;
                            }
                        }
                        skip1++;
                    //エッジ座標
                    } else {
                        //全座標を取ると多すぎるので間引く
                        if(skip2 > 4) {
                            skip2 = 0;
                            _edgePoint.push(p);
                            //リンクリスト
                            if (_firstEdgePoint == null) {
                                oldEdge = _firstEdgePoint = p;
                            } else {
                                oldEdge.next = p;
                                oldEdge = p;
                            }
                        }
                        skip2++;
                    }
                }
            }
            _bPoint = _firstBlackPoint;

            //大量の処理を行うためENTERFRAMEでまわす
            stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(event : Event) : void {
            switch(_enterFrameStep) {
                //エッジ以外の座標からエッジまでの最小距離を計算
                case 0:
                    calcMinimumDistance();
                    break;
                //ボロノイ母点を求める
                case 1:
                    getVoronoiPoint();
                    break;
                //描画処理
                case 2:
                    drawVoronoi();
                default:
            }

        }
        /**
         * ボロノイ図を描画
         */
        private function drawVoronoi() : void {
            var sp : Sprite = new Sprite();
            var fortune : Fortune = new Fortune(_voronoiPoints, FX, FY, FX + FW, FY + FH);
            var fills : Vector.<IGraphicsFill> = new Vector.<IGraphicsFill>();
            var strokes : Vector.<GraphicsStroke> = new Vector.<GraphicsStroke>();
            var gd : Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
            var cc : uint;
                    
            for (var i:int = 0;i < _voronoiPoints.length;i++) {
                //画像から描画する色を取得        
                cc = _imageData.getPixel(_voronoiPoints[i].x, _voronoiPoints[i].y);
                fills[i] = new GraphicsSolidFill(cc);
                strokes[i] = new GraphicsStroke(0);
                strokes[i].fill = new GraphicsSolidFill(0xE0E0E0);
                gd.push(strokes[i], fills[i], fortune.graphicsPaths[i]);
            }
            //アップデート
            fortune.update(MOTTIRI);
            //描画
            sp.graphics.drawGraphicsData(gd);
            //処理バー非表示                    
            removeChild(_bar);
            //ボロノイ図を表示
            addChild(sp);
            stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        /**
         * ボロノイ母点を求める
         */
        private function getVoronoiPoint() : void {
            var p : Point;
            var r : int;
            //処理短縮のため50回分ループ
            for (var i : int = 0;i < 50;i++) {
                //ランダムで座標を取る
                r = Math.floor(Math.random() * _blackPoint.length);
                //エッジまでの距離が近いほど出現確率が高い（ボロノイ母点追加）
                if(Math.random() < (_minDist / _blackPoint[r].dist)*(_minDist / _blackPoint[r].dist)*(_minDist / _blackPoint[r].dist)*(_minDist / _blackPoint[r].dist) && _blackPoint[r].x < 455 && _blackPoint[r].x > 5 ) {
                    p = new Point();
                    p.x = _blackPoint[r].x + Math.random();
                    p.y = _blackPoint[r].y + Math.random();
                    _voronoiPoints.push(p);
                    //処理バー
                    _bar.scaleX = _voronoiPoints.length / N;
                    //ボロノイ母点がN個超えたら次の処理へ
                    if(_voronoiPoints .length >= N) {
                        _enterFrameStep = 2;
                        break;
                    }
                }
            }                
        }
        /**
         * エッジ以外の座標からエッジまでの最小距離を計算
         */
        private function calcMinimumDistance() : void {
            var distance : Number;

            //処理短縮のため50回分ループ
            for (var i : int = 0;i < 50;i++) {
                //処理バー
                _bar.scaleX = _count / _blackPoint.length;
                _count++;
                //エッジ座標群を最初に戻してループ
                _ePoint = _firstEdgePoint;
                do {
                    //エッジ座標までの距離を計算
                    distance = (_ePoint.x - _bPoint.x) * (_ePoint.x - _bPoint.x) + (_ePoint.y - _bPoint.y) * (_ePoint.y - _bPoint.y);
                    if(!(_bPoint.dist)) {
                        _bPoint.dist = distance;
                        _minDist = distance;
                    }
                    //距離が小さければ入れ替え（すべての中での最小距離も入れ替え）
                    if(_bPoint.dist > distance) {
                        _bPoint.dist = distance;
                        if(_minDist > distance) _minDist = distance;
                    }
                }
                while (_ePoint = _ePoint.next);
                //エッジ以外の座標群を進める
                if(_bPoint.next) {
                    _bPoint = _bPoint.next;
                } else {
                    //次の処理へ
                    _enterFrameStep = 1;
                    break;
                }
            }
        }
        /**
         * 2値化処理
         * @param image
         * @param threshold
         * @param color
         * @return BitmapData
         */
        private function thresholdFilter(image : BitmapData,threshold : int,color : uint = 0xFFFFFFFF) : BitmapData {
            var d:BitmapData = new BitmapData(image.width, image.height);
            var r:Rectangle = new Rectangle(0, 0, image.width, image.height);
            d.fillRect(r, 0x00000000); // 不透明黒で塗りつぶす
            // 閾値以下を不透明黒にする
            d.threshold(image, r, new Point(0, 0), ">", threshold, color, 0x000000FF, false);
            return d;
        }
        /**
         * ノイズフィルタ
         * @param image
         * @return BitmapData
         */
        private function medianSmoothFilter(image : BitmapData) : BitmapData {
            var d:BitmapData = new BitmapData(image.width, image.height);
            var a:Array = new Array(9);
            for (var x:int = 0; x < image.width; x++) {
                for (var y:int = 0; y < image.height; y++) {
                    a[0] = image.getPixel(x - 1, y - 1) & 255;
                    a[1] = image.getPixel(x - 1, y) & 255;
                    a[2] = image.getPixel(x - 1, y + 1) & 255;
                    a[3] = image.getPixel(x, y - 1) & 255;
                    a[4] = image.getPixel(x, y) & 255;
                    a[5] = image.getPixel(x, y + 1) & 255;
                    a[6] = image.getPixel(x + 1, y - 1) & 255;
                    a[7] = image.getPixel(x + 1, y) & 255;
                    a[8] = image.getPixel(x + 1, y + 1) & 255;
                    a.sort(Array.NUMERIC); // ソートして
                    var c:int = a[4]; // 真ん中を取る
                    d.setPixel(x, y, (c << 16) | (c << 8) | c); // 中央値による色の設定
                }
            }
            return d;
       }

        private function laplacianFilter(image : BitmapData) : BitmapData {
            var d:BitmapData = new BitmapData(image.width, image.height);
            var rect : Rectangle = new Rectangle(0, 0, image.width, image.height);
            var p : Point = new Point(0, 0);
            var l:Array = [-1, -1, -1,
                           -1, +8, -1,
                           -1, -1, -1]; // ラプラシアンフィルタ
            d.applyFilter(image, rect, p,
                          new ConvolutionFilter(3, 3, l));
            return d;
        }

        /**
         * グレースケールフィルタ
         * @param imageData
         * @return BitmapData
         */
        private function grayscaleFilter(image : BitmapData) : BitmapData {
            var d : BitmapData = new BitmapData(image.width, image.height);
            var rect : Rectangle = new Rectangle(0, 0, image.width, image.height);
            var p : Point = new Point(0, 0);
            var cmatrix:ColorMatrixFilter = new ColorMatrixFilter([
                    1/3,1/3,1/3,0  ,0,                
                    1/3,1/3,1/3,0  ,0,                
                    1/3,1/3,1/3,0  ,0,
                    0  ,0  ,0  ,255,0]);
            
            d.applyFilter(image, rect, p, cmatrix);
            return d;
        }
    }
}

    internal class Number2 {
        public var x : Number;
        public var y : Number;
        public var dist:Number;

        public var next : Number2;
        public function toString () : String
        {
            return 'Number2[ ' + x + ', ' + y + ' ]';
        }
    }

    import flash.display.GraphicsSolidFill;
    import flash.display.GraphicsStroke;
    import flash.display.IGraphicsData;
    import flash.display.GraphicsPath;
    import flash.display.GraphicsPathCommand;
    import flash.geom.Point;
    
    internal class Fortune
    {
        private var _length:int;
        private var _points:Vector.<Point>;
        private var _cells:Vector.<FortuneCell>;
        private var _graphicsPaths:Vector.<IGraphicsData>;
        
        private var _topY:Number;
        private var _leftX:Number;
        private var _rightX:Number;
        private var _bottomY:Number;
        
        private var _topBounds:YBoundaryCell;
        private var _leftBounds:XBoundaryCell;
        private var _rightBounds:XBoundaryCell;
        private var _bottomBounds:YBoundaryCell;
        
        private var _waitCellsHead:FortuneCell;
        private var _activeCellsHead:FortuneCell;
        
        private var _beachLineLeftmost:BeachLine;
        private var _beachLineTop:Number;
        
        private var _sweepLine:Number;
        
        public function Fortune(points:Vector.<Point>, 
            topBoundary:Number, leftBoundary:Number, rightBoundary:Number, bottomBoundary:Number) 
        {
            _length = points.length;
            _points = points;
            _cells = new Vector.<FortuneCell>(_length);
            _graphicsPaths = new Vector.<IGraphicsData>();
            for (var i:int = 0; i< _length; i++) 
            {
                _cells[i] = new FortuneCell(points[i]);
                _graphicsPaths[i] = _cells[i].graphicsPath;
            }
            
            _topBounds = new YBoundaryCell(topBoundary);
            _leftBounds = new XBoundaryCell(leftBoundary);
            _rightBounds = new XBoundaryCell(rightBoundary);
            _bottomBounds = new YBoundaryCell(bottomBoundary);
            
            _topY = topBoundary;
            _leftX = leftBoundary;
            _rightX = rightBoundary;
            _bottomY = bottomBoundary;
        }
        
        public function update(curve:Boolean = false):void
        {
            reset();
            //追加待ちの母点または評価待ちのボロノイ点候補が残っていて、かつ境界内にbeachlineが残っていれば
            while (_waitCellsHead)
            {
                //待ちリストの先頭を取り出して評価
                var newCell:FortuneCell = _waitCellsHead;
                _waitCellsHead = _waitCellsHead.next;
                
                //この時点で評価対象のセルは待ちリストにもアクティブリストにも含まれない
                //sweeplineの移動
                sweepTo(newCell.y);
                //考え得るボロノイ点候補について調査
                checkNewCell(newCell);
                
                //アクティブなセルとしてリストに追加
                newCell.next = _activeCellsHead;
                _activeCellsHead = newCell;
            }
            //最後に各セルで保持しているGraphicsPathを更新する
            for (var i:int = 0; i< _length; i++) 
            {
                _cells[i].updateGraphicsPath(curve);
            }
        }
        
        //新しい母点が関わりうるボロノイ点について調査
        private function checkNewCell(newCell:FortuneCell):void
        {
            var vp:VoronoiPoint;
            var ncx:Number = newCell.x;
            var chkBL:BeachLine = _beachLineLeftmost;
            if (chkBL) do
            {
                if (ncx <= chkBL.rightEndX)
                {
                    break;
                }
            } while (chkBL = chkBL.right);
            checkBeachLine(newCell, chkBL);
        }
        
        // 新しい点をbeachlineに沿って
        // 他のボロノイ母点とボロノイ点を作りうるかどうか評価していく
        private function checkBeachLine(newCell:FortuneCell, centerBL:BeachLine):void
        {
            
            var vp:VoronoiPoint;
            var cell:FortuneCell;
            var leftCell:FortuneCell;
            var rightCell:FortuneCell;
            var cot:Number; // 追加点を中心としたcot(=x/y)の値が右に行くにつれて小さくなっていくように
            var centerCot:Number;
            var leftCot:Number;
            var rightCot:Number;
            var leftBL:BeachLine;
            var rightBL:BeachLine;
            
            // 新しく追加されるセル点の真上の放物線からスタート
            // 左に移動しながらボロノイ点候補を探す
            leftBL = centerBL;
            cell = leftCell = centerBL.cell;
            cot = leftCot = cell.getCot(newCell);
            while (leftBL = leftBL.left)
            {
                leftCell = leftBL.cell;
                leftCot = leftCell.getCot(newCell);
                if (leftCot > cot)
                {
                    vp = new VoronoiPoint(newCell, leftCell, cell);
                    if (testVoronoi(vp))
                    {
                        vp.fix();
                        cell = leftCell;
                        cot = leftCot;
                    }
                }
            }
            //左境界に達したらぐるっと下境界を評価
            leftCell = _leftBounds;
            vp = new VoronoiPoint(newCell, leftCell, cell);
            if (testVoronoi(vp))
            {
                vp.fix();
                cell = leftCell;
            }
            leftCell = _bottomBounds;
            vp = new VoronoiPoint(newCell, leftCell, cell);
            if (testVoronoi(vp))
            {
                vp.fix();
            }
            
            // 右に移動しながらボロノイ点候補を探す
            rightBL = centerBL;
            cell = rightCell = centerBL.cell;
            cot = rightCot = cell.getCot(newCell);
            while (rightBL = rightBL.right)
            {
                rightCell = rightBL.cell;
                rightCot = rightCell.getCot(newCell);
                if (rightCot < cot)
                {
                    vp = new VoronoiPoint(newCell, rightCell, cell);
                    if (testVoronoi(vp))
                    {
                        vp.fix();
                        cell = rightCell;
                        cot = rightCot;
                    }
                }
            } 
            rightCell = _rightBounds
            vp = new VoronoiPoint(newCell, rightCell, cell);
            if (testVoronoi(vp))
            {
                vp.fix();
                cell = rightCell;
            }
            rightCell = _bottomBounds
            vp = new VoronoiPoint(newCell, rightCell, cell);
            if (testVoronoi(vp))
            {
                vp.fix();
            }
        }
        
        /**
         * sweeplineを移動しbeachlineとアクティブなセルを更新する
         * コストがかかるのでこのメソッドの呼び出しを極力少なく
         * @param    y
         */
        private function sweepTo(y:Number):void
        {
            _sweepLine = y;
            
            var cell:FortuneCell = _activeCellsHead;
            var beachLineCell:FortuneCell;
            var lX:Number = _leftX;
            var yVal:Number;
            var leftmostY:Number = - Number.MAX_VALUE;
            //左境界と放物線の交点が最も下にくるセルを探す
            do
            {
                cell.updateParabola(y);
                yVal = cell.getParabolaY(lX);
                if (yVal > leftmostY)
                {
                    leftmostY = yVal;
                    beachLineCell = cell;
                }
            } while ( cell = cell.next);
            _beachLineTop = leftmostY;
            beachLineCell.isBeachLine = true;
            //このセルの放物線からbeachlineが始まる
            var leftCell:FortuneCell = beachLineCell;
            _beachLineLeftmost = new BeachLine(leftCell); 
            var leftBL:BeachLine = _beachLineLeftmost;
            leftBL.left = null; 
            var rightBL:BeachLine;
            
            var solX:QuadraticSolution;
            var xVal:Number;
            var rX:Number;
            //放物線の交点からbeachlineを構成するセルと交点を順に調査
            for (;;)
            {
                cell = _activeCellsHead;
                rX = _rightX;
                do
                {
                    if (cell === leftCell)
                    {
                        continue;
                    }
                    solX = leftCell.getIntersectionX(cell);
                    if (solX)
                    {
                        xVal = solX.xSmaller;
                        if (xVal > lX && xVal < rX)
                        {
                            rX = xVal;
                            beachLineCell = cell;
                        }
                        else
                        {
                            xVal = solX.xBigger;
                            if (xVal > lX && xVal < rX)
                            {
                                rX = xVal;
                                beachLineCell = cell;
                            }
                        }
                    }
                } while (cell = cell.next);
                if (leftCell != beachLineCell && rX < _rightX)
                {
                    yVal = leftCell.getParabolaY(rX);
                    beachLineCell.isBeachLine = true;
                    rightBL = new BeachLine(beachLineCell);
                    rightBL.left = leftBL;
                    leftBL.right = rightBL;
                    leftBL.rightEndX = rX;
                    if (yVal < _beachLineTop)
                    {
                        _beachLineTop = yVal;
                    }
                    lX = rX;
                    leftBL = rightBL;
                    leftCell = beachLineCell;
                }
                else
                {
                    rX = _rightX;
                    yVal = leftCell.getParabolaY(rX);
                    leftBL.right = null;
                    leftBL.rightEndX = rX;
                    if (yVal < _beachLineTop)
                    {
                        _beachLineTop = yVal;
                    }
                    break;
                }
            }
            
            //beachlineを構成しないセルはリストから外す
            while (!_activeCellsHead.isBeachLine)
            {
                _activeCellsHead = _activeCellsHead.next;
            }
            cell = _activeCellsHead;
            var prevCell:FortuneCell = cell;
            while (cell = cell.next)
            {
                if (!cell.isBeachLine)
                {
                    prevCell.next = cell.next;
                }
                else
                {
                    prevCell = cell;
                }
            }
        }
        
        /**
         * 全セルをリセット
         * y昇順にソートし待ちリストに追加しなおす
         */
        private function reset():void
        {
            _sweepLine = _topY;
            _waitCellsHead = null;
            _activeCellsHead = _topBounds;
            _beachLineLeftmost = new BeachLine(_topBounds);
            _beachLineTop = - Number.MAX_VALUE;
            for (var i:int = 0; i< _length; i++) 
            {
                var cell:FortuneCell = _cells[i];
                cell.setPosition(_points[i]);
                addWaitCell(cell);
            }
        }
        
        /**
         * セルの評価待ちリストにy昇順になるように追加
         * @param    cell
         */
        private function addWaitCell(cell:FortuneCell):void
        {
            var cy:Number = cell.y;
            if (cy < _sweepLine)
            {
                return;
            }
            if (!_waitCellsHead || cy < _waitCellsHead.y)
            {
                cell.next = _waitCellsHead;
                _waitCellsHead = cell;
                return;
            }
            var chkCell:FortuneCell = _waitCellsHead;
            var prevCell:FortuneCell = chkCell;
            while (chkCell = chkCell.next)
            {
                if (cy < chkCell.y)
                {
                    prevCell.next = cell;
                    cell.next = chkCell;
                    return;
                }
                prevCell = chkCell;
            }
            prevCell.next = cell;
        }
        
        //ボロノイ点候補を評価して確定してもよければtrue
        private function testVoronoi(vp:VoronoiPoint):Boolean
        {
            return !(isOutBounds(vp) || containsActiveCell(vp) || containsWaitCell(vp))
        }
        
        //ボロノイ点候補の円の中に現在評価待ちのセル点があったら真
        private function containsWaitCell(vp:VoronoiPoint):Boolean
        {
            //trace("containsWaitCell():");
            var cell:FortuneCell = _waitCellsHead;
            var vt:Number = vp.t;
            if (cell && cell.y < vt) do
            {
                if (vp.contains(cell)) 
                { //評価待ちセル母点を1つでも円の中に含めば真を返す
                    return true;
                }
                var tst:uint = 0;
            }while ((cell = cell.next) && cell.y < vt);
            //待ちリストの終端に達するか、追加時期がボロノイ点の評価タイミングを超える場合には
            return false;
        }
        
        // ボロノイ点候補の円の中に現在beachlineを作っているセル点があったら真
        private function containsActiveCell(vp:VoronoiPoint):Boolean
        {
            //trace("containsActiveCell():");
            var cell:FortuneCell = _activeCellsHead;
            var vt:Number = vp.t;
            if (cell) do
            {
                if (cell is YBoundaryCell)
                { //top境界がbeachlineの一部の場合があるので
                    continue;
                }
                if (vp.contains(cell)) 
                { //アクティブなセル母点を1つでも円の中に含めば真を返す
                    return true;
                }
            }while (cell = cell.next);
            //リストの終端に達する場合には偽
            return false;
        }
        
        // ボロノイ点候補が境界の外にあったら真
        private function isOutBounds(vp:VoronoiPoint):Boolean
        {
            //trace("isOuntBounds():");
            var vx:Number = vp.x;
            var vy:Number = vp.y;
            return vx < _leftX || vx > _rightX || vy < _topY || vy > _bottomY;
        }
        
        public function get graphicsPaths():Vector.<IGraphicsData> { return _graphicsPaths; }
        
    }

    internal class FortuneCell
    {
        public var x:Number, y:Number;
        public var a:Number, b:Number, c:Number;
        public var next:FortuneCell;
        public var isBeachLine:Boolean;
        
        private var _graphicsPath:GraphicsPath;
        private var _leftWallStart:CellWallPt;
        private var _rightWallStart:CellWallPt;
        
        public function FortuneCell(position:Point) 
        {
            setPosition(position);
            isBeachLine = false;
            _graphicsPath = new GraphicsPath();
        }
        
        /**
         * 引数のPointオブジェクトで母点位置を更新
         * @param    pt
         */
        public function setPosition(position:Point):void
        {
            x = position.x;
            y = position.y;
            next = null;
            _leftWallStart = null;
            _rightWallStart = null;
        }
        
        /**
         * 母点を焦点とする放物線を指定した準線位置で更新する
         * y = ax^2 + 2bx + c の形式で内部的に保持
         * @param    directrix
         */
        public function updateParabola(directrix:Number):void
        {
            a = - 0.5 / (directrix - y);
            b = - x * a;
            c = 0.5 * (directrix + y) - x * b;
            isBeachLine = false;
        }
        
        /**
         * 現在の放物線についてxに対するyの値を返す
         * @param    parabolaX
         * @return
         */
        public function getParabolaY(parabolaX:Number):Number
        {
            return (a * parabolaX + 2 * b) * parabolaX + c;
        }
        
        /**
         * 他のセルの放物線との交点を求める
         * @param    fc
         * @return
         */
        public function getIntersectionX(fc:FortuneCell):QuadraticSolution
        {
            return QuadraticSolution.solve(a - fc.a, b - fc.b, c - fc.c);
        }
        
        /**
         * セルの左側にボロノイ点を追加する。
         * 時計回りなので左側ではy降順に並ぶ。
         * @param    vp
         */
        public function addLeftWall(vp:VoronoiPoint):void
        {
            //trace(this);
            //trace("add to left ", vp);
            var newPt :CellWallPt = new CellWallPt(vp.x, vp.y);
            var vpy:Number = vp.y;
            if (!_leftWallStart || vpy > _leftWallStart.y)
            {
                newPt.next = _leftWallStart;
                _leftWallStart = newPt;
                return;
            }
            var chkPt:CellWallPt = _leftWallStart;
            var prevPt:CellWallPt = chkPt;
            do 
            {
                if (vpy > chkPt.y)
                {
                    prevPt.next = newPt;
                    newPt.next = chkPt;
                    return;
                }
                prevPt = chkPt;
            } while (chkPt = chkPt.next) ;
            prevPt.next = newPt;
        }
        
        /**
         * セルの右側にボロノイ点を追加する。
         * 時計回りなので右側ではy昇順に並ぶ。
         * @param    vp
         */
        public function addRightWall(vp:VoronoiPoint):void
        {
            var newPt :CellWallPt = new CellWallPt(vp.x, vp.y);
            var vpy:Number = vp.y;
            if (!_rightWallStart || vpy < _rightWallStart.y)
            {
                newPt.next = _rightWallStart;
                _rightWallStart = newPt;
                return;
            }
            var chkPt:CellWallPt = _rightWallStart;
            var prevPt:CellWallPt = chkPt;
            do
            {
                if (vpy < chkPt.y)
                {
                    prevPt.next = newPt;
                    newPt.next = chkPt;
                    return;
                }
                prevPt = chkPt;
            } while (chkPt = chkPt.next) ;
            prevPt.next = newPt;
        }
        
        /**
         * セルの多角形を描く為のGraphicsPathオブジェクトを返す
         */
        public function updateGraphicsPath(curve:Boolean = false):void
        {
            var pathCmds:Vector.<int>, pathData:Vector.<Number>;
            var cmdsL:int, dataL:int;
            var cx:Number, cy:Number;
            var chkPt:CellWallPt;
            if (_leftWallStart || _rightWallStart)
            {
                if (curve)
                {
                    pathCmds = new Vector.<int>();
                    pathData = new Vector.<Number>();
                    _graphicsPath.commands = pathCmds;
                    _graphicsPath.data = pathData;
                    cmdsL = 0;
                    dataL = 0;
                    
                    pathCmds[cmdsL++] = GraphicsPathCommand.MOVE_TO;
                    
                    chkPt = _leftWallStart;
                    if (chkPt)
                    {
                        cx = chkPt.x;
                        cy = chkPt.y;
                        while (chkPt = chkPt.next)
                        {
                            pathData[dataL++] = cx;
                            pathData[dataL++] = cy;
                            pathData[dataL++] = 0.5 * (chkPt.x + cx);
                            pathData[dataL++] = 0.5 * (chkPt.y + cy);
                            cx = chkPt.x;
                            cy = chkPt.y;
                            pathCmds[cmdsL++] = GraphicsPathCommand.CURVE_TO;
                        }
                        chkPt = _rightWallStart;
                    }
                    else
                    {
                        chkPt = _rightWallStart;
                        cx = chkPt.x;
                        cy = chkPt.y;
                    }
                    if (chkPt) do
                    {
                        pathData[dataL++] = cx;
                        pathData[dataL++] = cy;
                        pathData[dataL++] = 0.5 * (chkPt.x + cx);
                        pathData[dataL++] = 0.5 * (chkPt.y + cy);
                        cx = chkPt.x;
                        cy = chkPt.y;
                        pathCmds[cmdsL++] = GraphicsPathCommand.CURVE_TO;
                    }while (chkPt = chkPt.next);
                    
                    pathData[dataL++] = cx;
                    pathData[dataL++] = cy;
                    pathData[dataL++] = 0.5 * (pathData[0] + cx);
                    pathData[dataL++] = 0.5 * (pathData[1] + cy);
                    pathCmds[cmdsL++] = GraphicsPathCommand.CURVE_TO;
                    
                    pathData.reverse();
                    pathData.push(pathData[0], pathData[1]);
                    pathData.reverse();
                }
                else
                {
                    pathCmds = new Vector.<int>();
                    pathData = new Vector.<Number>();
                    _graphicsPath.commands = pathCmds;
                    _graphicsPath.data = pathData;
                    cmdsL = 0;
                    dataL = 0;
                    
                    pathCmds[cmdsL++] = GraphicsPathCommand.MOVE_TO;
                    
                    chkPt = _leftWallStart;
                    if (chkPt) do
                    {
                        pathData[dataL++] = chkPt.x;
                        pathData[dataL++] = chkPt.y;
                        pathCmds[cmdsL++] = GraphicsPathCommand.LINE_TO;
                    }while (chkPt = chkPt.next);
                    
                    chkPt = _rightWallStart;
                    if (chkPt) do
                    {
                        pathData[dataL++] = chkPt.x;
                        pathData[dataL++] = chkPt.y;
                        pathCmds[cmdsL++] = GraphicsPathCommand.LINE_TO;
                    }while (chkPt = chkPt.next);
                    
                    pathData[dataL++] = pathData[0];
                    pathData[dataL++] = pathData[1];
                    //trace(pathCmds.length, pathData.length);
                }
            }
        }
        
        public function getCot(cell:FortuneCell):Number
        {
            return (cell.x - this.x) / (cell.y - this.y);
        }
        
        public function get graphicsPath():GraphicsPath { return _graphicsPath; }
        
    }
    
internal class CellWallPt
{
    public var x:Number;
    public var y:Number;
    //clockwise next
    public var next:CellWallPt;
    
    public function CellWallPt(x:Number, y:Number)
    {
        this.x = x;
        this.y = y;
    }
}

    internal class VoronoiPoint
    {
        private var _newCell:FortuneCell, _cellX:FortuneCell, _cellY:FortuneCell;
        public var x:Number, y:Number;
        public var r2:Number, r:Number;
        public var t:Number;
        public var next:VoronoiPoint;
        
        /**
         * ボロノイ点を作る母点または境界を指定してボロノイ点を求める
         * @param    newCell 新しく追加されたボロノイ点
         * @param    cellX 現時点でbeachlineを作るボロノイ点またはx境界
         * @param    cellY
         */
        public function VoronoiPoint(newCell:FortuneCell, cellX:FortuneCell, cellY:FortuneCell) 
        {
            _newCell = newCell;
            if (cellX is YBoundaryCell || cellY is XBoundaryCell)
            {
                _cellX = cellY;
                _cellY = cellX;
                cellX = _cellX;
                cellY = _cellY;
            }
            else
            {
                _cellX = cellX;
                _cellY = cellY;
            }
            
            var isXboundary:Boolean = cellX is XBoundaryCell;
            var isYboundary:Boolean = cellY is YBoundaryCell;
            
            // Lx+My=N を連立させて解く
            if (!isXboundary)
            {
                var lX:Number = newCell.x - cellX.x;
                var mX:Number = newCell.y - cellX.y;
                var nX:Number = 0.5 * (lX * (newCell.x + cellX.x) + mX * (newCell.y + cellX.y));
            }
            if (!isYboundary)
            {
                var lY:Number = newCell.x - cellY.x;
                var mY:Number = newCell.y - cellY.y;
                var nY:Number = 0.5 * (lY * (newCell.x + cellY.x) + mY * (newCell.y + cellY.y));
            }
            
            if (isXboundary || isYboundary)
            {
                x = isXboundary? cellX.x: ((nX - mX * cellY.y) / lX);
                y = isYboundary? cellY.y: ((nY - lY * cellX.x) / mY);
            }
            else
            {
                var lm:Number = lX * mY - lY * mX;
                var nm:Number = nX * mY - nY * mX;            
                var ml:Number = mX * lY - mY * lX;
                var nl:Number = nX * lY - nY * lX;
                x = nm / lm;                    
                y = nl / ml;
            }
            var dx:Number = newCell.x - x;
            var dy:Number = newCell.y - y;
            
            r2 = dx * dx + dy * dy;
            r = Math.sqrt(r2);
            t = y + r;
            
        }
        
        /**
         * ある母点を円中に含むかどうか
         * @param    cell
         * @return
         */
        public function contains(cell:FortuneCell):Boolean
        {
            if (cell == _cellX || cell == _cellY || cell == _newCell)
            {
                return false;
            }
            var dx:Number = cell.x - x;
            if (dx > r)
            {
                return false;
            }
            var dy:Number = cell.y - y;
            if (dx > r) 
            {
                return false;
            }
            return r2 > dx * dx + dy * dy;
        }
        /**
         * 新しいボロノイ点として確定し、各セルに追加する
         */
        public function fix():void
        {
            var isXboundary:Boolean = _cellX is XBoundaryCell;
            var isYboundary:Boolean = _cellY is YBoundaryCell;
            var nx:Number = _newCell.x;
            var xx:Number = _cellX.x;
            var yx:Number = _cellY.x;
            
            if (isYboundary)
            {
                if (nx > xx)
                {
                    _newCell.addLeftWall(this);
                    isXboundary? null: _cellX.addRightWall(this);
                }
                else
                {
                    _newCell.addRightWall(this);
                    isXboundary? null: _cellX.addLeftWall(this);
                }
            }
            else if(isXboundary)
            {
                if (nx > xx)
                {
                    _newCell.addLeftWall(this);
                    _cellY.addLeftWall(this);
                }
                else
                {
                    _newCell.addRightWall(this);
                    _cellY.addRightWall(this);
                }
            }
            else
            {
                if (nx > xx)
                {
                    _newCell.addLeftWall(this);
                    if (xx > yx)
                    {
                        _cellX.addLeftWall(this);
                        _cellY.addRightWall(this);
                    }
                    else
                    {
                        _cellY.addLeftWall(this);
                        _cellX.addRightWall(this);
                    }
                }
                else
                {
                    _cellX.addLeftWall(this);
                    if (nx > yx)
                    {
                        _newCell.addLeftWall(this);
                        _cellY.addRightWall(this);
                    }
                    else
                    {
                        _cellY.addLeftWall(this);
                        _newCell.addRightWall(this);
                    }
                }
            }
        }
        
    }
    
    internal class QuadraticSolution
    {
        public var xSmaller:Number;
        public var xBigger:Number;
        
        /**
         * 2次方程式 ax^2 + 2bx + c = 0 の解を返す
         * @param    a
         * @param    b
         * @param    c
         */
        public static function solve(a:Number, b:Number, c:Number):QuadraticSolution 
        {
            if (a == 0)
            {
                return null;
            }
            var det:Number = b * b - a * c;
            if (det < 0)
            {
                return null;
            }
            var ia:Number = 1.0 / a;
            var p:Number = -b * ia;
            var q:Number = Math.sqrt(det) * (a > 0.0?ia: -ia);
            var qs:QuadraticSolution = new QuadraticSolution();
            qs.xSmaller = p - q;
            qs.xBigger = p + q;
            return qs;
        }
        
    }
    
    internal class BoundaryCell extends FortuneCell
    {
        
        public function BoundaryCell(x:Number = 0, y:Number = 0) 
        {
            super(new Point(x, y));
        }
        
        override public function addLeftWall(vp:VoronoiPoint):void { }
        override public function addRightWall(vp:VoronoiPoint):void { }
        override public function updateParabola(directrix:Number):void { }
    }
    
    internal class XBoundaryCell extends BoundaryCell
    {
        
        public function XBoundaryCell(x:Number) 
        {
            super(x, 0);
            super.a = NaN;
            super.b = NaN;
            super.c = NaN;
        }
        
        override public function getIntersectionX(fc:FortuneCell):QuadraticSolution 
        {
            var qs:QuadraticSolution = new QuadraticSolution();
            if (fc.x > x)
            {
                qs.xSmaller = x;
                qs.xBigger = NaN;
            }
            else
            {
                qs.xSmaller = NaN;
                qs.xBigger = x;
            }
            return qs;
        }
        
        override public function getParabolaY(parabolaX:Number):Number 
        {
            return NaN;
        }
        
        override public function getCot(cell:FortuneCell):Number 
        {
            return cell.x > x? Number.POSITIVE_INFINITY: Number.NEGATIVE_INFINITY;
        }
    }
    
    internal class YBoundaryCell extends BoundaryCell
    {
        
        public function YBoundaryCell(y:Number) 
        {
            super(0, y);
            super.a = 0;
            super.b = 0;
            super.c = y;
        }
        
        override public function getIntersectionX(fc:FortuneCell):QuadraticSolution 
        {
            return QuadraticSolution.solve(fc.a, fc.b, fc.c - y);
        }
        
        override public function getParabolaY(parabolaX:Number):Number 
        {
            return y;
        }
        
        override public function getCot(cell:FortuneCell):Number 
        {
            return 0.0;
        }
    }
    
    internal class BeachLine
    {
        public var cell:FortuneCell;
        public var right:BeachLine;
        public var left:BeachLine;
        public var rightEndX:Number;
        
        public function BeachLine(cell:FortuneCell = null) 
        {
            this.cell = cell;
        }
    }

