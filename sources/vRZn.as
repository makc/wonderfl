package  
{
    import flash.display.GraphicsGradientFill;
    import flash.display.GraphicsSolidFill;
    import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
    import flash.display.IGraphicsFill;
	import flash.display.Sprite;
	import flash.events.Event;
    import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * Voronoi図 + drawGraphicsData()
     * Fortuneのアルゴリズムをフルスクラッチでやってみました。
     * 
     * が、
     * 超速(http://wonderfl.net/code/1b53ccd79d8620d235f03ed4cd9e821912879f9e)には
     * どうやっても勝てる気がしません。
     * 
     * クリックで移動開始
     *
	 * @author @kndys
	 */
	public class Test extends Sprite
	{
		private const FX:Number = 5;
		private const FY:Number = 5;
		private const FW:Number = 455;
		private const FH:Number = 455;
		private const N:int = 100;
		private const V:Number = 2;
		private const MOCCHIRI:Boolean = true; //普通のボロノイ図にもなります
        private var points:Vector.<Point>;
		private var velos:Vector.<Point>;
        private var fills:Vector.<IGraphicsFill>;
        private var strokes:Vector.<GraphicsStroke>;
        private var f:Fortune;
        private var gd:Vector.<IGraphicsData>;
		public function Test() 
		{
            
			points = new Vector.<Point>();
			velos = new Vector.<Point>();
            fills = new Vector.<IGraphicsFill>();
            strokes = new Vector.<GraphicsStroke>();
            gd = new Vector.<IGraphicsData>();
			for (var i:int = 0; i < N; i++) 
			{
				points[i] = new Point(FX + FW * Math.random() , FY + FH * Math.random());
				velos[i] = new Point(V * (1 - 2 * Math.random()) , V * (1 - 2 * Math.random()));
			}
            
			f = new Fortune(points, FX, FY, FX + FW, FY + FH);
            
			for (i = 0; i < N; i++) 
			{
                fills[i] = new GraphicsSolidFill(0x1000000 * Math.random());
                strokes[i] = new GraphicsStroke(0);
                strokes[i].fill = new GraphicsSolidFill(0xffffff^(GraphicsSolidFill(fills[i]).color));
                gd.push(strokes[i], fills[i], f.graphicsPaths[i]);
			}
			
			draw();
            
            stage.addEventListener(MouseEvent.CLICK, function(e:Event):void {
                hasEventListener(Event.ENTER_FRAME)? removeEventListener(Event.ENTER_FRAME, update): addEventListener(Event.ENTER_FRAME, update);;
            });
		}
        
        private function update(e:Event):void 
        {
			draw();
		}
		
		private function draw():void
		{
            f.update(MOCCHIRI);
            
            graphics.clear();
            
			graphics.drawGraphicsData(gd);
			graphics.lineStyle(0);
            var tmp:Number;
            for (var i:int = 0; i < N; i++) 
            {
                graphics.beginFill(0xffffff);
				graphics.drawCircle(points[i].x, points[i].y, 2);
                graphics.endFill();
                
                tmp = points[i].x + velos[i].x - FX + FW;
                tmp %= FW;
				tmp += FX;
                points[i].x = tmp;
                tmp = points[i].y + velos[i].y - FY + FH;
                tmp %= FH;
				tmp += FY;
                points[i].y = tmp;
            }
        }
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
         * @param	y
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
         * @param	cell
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
         * @param	pt
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
         * @param	directrix
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
         * @param	parabolaX
         * @return
         */
        public function getParabolaY(parabolaX:Number):Number
        {
            return (a * parabolaX + 2 * b) * parabolaX + c;
        }
        
        /**
         * 他のセルの放物線との交点を求める
         * @param	fc
         * @return
         */
        public function getIntersectionX(fc:FortuneCell):QuadraticSolution
        {
            return QuadraticSolution.solve(a - fc.a, b - fc.b, c - fc.c);
        }
        
        /**
         * セルの左側にボロノイ点を追加する。
         * 時計回りなので左側ではy降順に並ぶ。
         * @param	vp
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
         * @param	vp
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
         * @param	newCell 新しく追加されたボロノイ点
         * @param	cellX 現時点でbeachlineを作るボロノイ点またはx境界
         * @param	cellY
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
         * @param	cell
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
         * @param	a
         * @param	b
         * @param	c
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

