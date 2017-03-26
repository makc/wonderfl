/*
 * MineSweeper
 * 
 * based on  http://wonderfl.net/c/vRZn
 * 
 * click all safe places !!
 * red flag means dangerous mine. 
 
 *
 * セルのかたちは千変万化、動きを先読みしないとクリックをはずしてイライラすることができる。
 * 
 * 
 * */



package {

import com.greensock.easing.Elastic;
import com.greensock.TweenMax;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;
import flash.display.IGraphicsFill;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getTimer;
import flash.utils.setTimeout;
    import com.bit101.components.Component;
    import com.bit101.components.PushButton;
    import net.wonderfl.score.basic.BasicScoreForm;
    import net.wonderfl.score.basic.BasicScoreRecordViewer;

[SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
public class Main extends Sprite {
    private const FX:Number = 40;
    private const FY:Number = 40;
    private const FW:Number = 385;
    private const FH:Number = 385;
    private const SS:int = 7;
    private const N:int = SS * SS;
    private const V:Number = 2;
    
    private var points:Vector.<BombPoint>;
    private var velos:Vector.<Point>;
    private var fills:Vector.<IGraphicsFill>;
    private var strokes:Vector.<GraphicsStroke>;
    private var f:Fortune;
    private var gd:Vector.<IGraphicsData>;
    private var textArray:Vector.<TextField>;
    
    private var greenMode:Boolean = true;
    private var openedText:TextField;

    private var greenCounter:int;
    private var timerText:TextField;
    
    private var firstTime:int;
    private var openedCounter:int;
    
    public var speed:Number;
    public var speedNum:Number;
    private var speedClickRate:Number;
    
    
    public function Main() {
        
        if (stage) {
            init();
        }else {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }

    }

    private function init(e:Event = null):void {

        createBelowMenu();
        
        reset();
        stage.addEventListener(MouseEvent.CLICK, onCLick);

    }
    private function reset(e:Event = null):void {
        if (f) f.dispose();
        originalSpeed = 0.01;
        greenCounter = 0;
        openedCounter = 0;
        firstTime = getTimer();
        tweened = false;
        speedNum = 0.01;
        speedClickRate = 1.10;
        
        
        if (textArray) {
            for (var k:int = 0; k < textArray.length; k++) 
            {
                if(contains(textArray[k])) removeChild(textArray[k]);
            }            
        }

        textArray = new Vector.<TextField>();
        points = new Vector.<BombPoint>();
        velos = new Vector.<Point>();
        fills = new Vector.<IGraphicsFill>();
        strokes = new Vector.<GraphicsStroke>();
        gd = new Vector.<IGraphicsData>();
        for (var i:int = 0; i < N; i++) {
            var xx:int = i / SS;
            var yy:int = i % SS;
            
            var nnn:int = FW / SS;
            points[i] = new BombPoint(FX + (xx) * nnn + nnn / 2 + Math.random(), FY  + (yy) * nnn + nnn / 2 + Math.random());
           
            velos[i] = new Point(V * (1 - 2 * Math.random()), V * (1 - 2 * Math.random()));
            var tt:TextField = new TextField();
            tt.selectable = false;
            tt.mouseEnabled = false;
            tt.visible = false;
            tt.defaultTextFormat = new TextFormat(null, 20, 0x111111, true);
            addChild(tt);
            textArray[i] = tt;
            tt.text = "test";

        }

        f = new Fortune(points, FY, FX, FX + FW, FY + FH);

        for (i = 0; i < N; i++) {
            fills[i] = new GraphicsSolidFill(0x1000000 * Math.random());
            strokes[i] = new GraphicsStroke(3);
            strokes[i].fill = new GraphicsSolidFill(0x000000);// 0xffffff ^ (GraphicsSolidFill(fills[i]).color));
            gd.push(strokes[i], fills[i], f.graphicsPaths[i]);
            if (f._cells[i].bomb == false) {
                greenCounter += 1;
            }
        }
        
        // slide position just a bit;
        update();
        update();
       
        
    }
    private function createBelowMenu():void {
        var container:Sprite = new Sprite();
        addChild(container);
        container.graphics.beginFill(0xffffff, 0.1);
        container.graphics.drawRect(0, 0, 465, 200);
        container.y = 435
        
        openedText = new TextField();
        var format:TextFormat = new TextFormat(null, 14, 0x000000);
        openedText.defaultTextFormat = format;
        container.addChild(openedText);
        openedText.x = 213;
        openedText.y = 0;
        
        timerText = new TextField();
        timerText.defaultTextFormat = format;
        container.addChild(timerText);
        timerText.text = "time : ";
        timerText.x = 360;
        timerText.y = 0;
        
        var button:* = new PushButton(container,40,0,"reset",reset);

    }

    


    private function onCLick(e:MouseEvent):void {
        if (clickEnable == false) return;
            
        if (stage.hasEventListener(Event.ENTER_FRAME)) {

            } else {
                stage.addEventListener(Event.ENTER_FRAME, update);
            }
            
        var xx:Number = e.stageX;
        var yy:Number = e.stageY;
        if (xx < FX || xx > FX + FW || yy < FY  || yy > FY  + FH) {
            return;
        }
        var min:Number = 9999;
        var minIndex:int = 0;

        var mouse:Point = new Point(e.localX, e.localY);
        
        var i:int = 0;
        for (i = 0; i < N; i++) {
            var pp:Point = points[i].clone();
            pp.x -= (velos[i].x*2);
            pp.y -= (velos[i].y*2);
            
            var len:Number = Point.distance(pp, mouse);
            if (min > len) {
                min = len;
                minIndex = i;
            }
        }

        var cell:FortuneCell = f._cells[minIndex];
        if (cell.clicked) {
            return;
        }
        
        if (true) {
            
            if (cell.bomb) {
                explode();
                return;
            } else {
                fills[minIndex] = new GraphicsSolidFill(0xffffff);
            }
            
            f._cells[minIndex].clicked = true;
            
            var nnn:int = 0;
            for (var ii:int = 0; ii < f._cells.length; ii++) 
            {
                if (f._cells[ii].clicked == true && f._cells[ii].bomb == false) {
                    nnn += 1;
                }
            }
            openedCounter = nnn;
            if (openedCounter == greenCounter) {
                congratu();
            }
            if (openedCounter == 1) {
                firstTime = getTimer();
                
            }
            trace("open : " + openedCounter + "  green : " + greenCounter);
            speedClickRate *= 1.19;
            speed = speedNum * speedClickRate;
            
            gd.length = 0;
            for (i = 0; i < N; i++) {
                gd.push(strokes[i], fills[i], f.graphicsPaths[i]);
            }
            

        }else {
// debug
//if(cell.bomb) {
    //cell.bomb = false;
//}else {
    //cell.bomb = true;
//}
//return;
            f._cells[minIndex].flag = true;
            update();
        }

       
    }

    private var originalSpeed:Number = 0;
    private var tweened:Boolean = false;
    
    private var mytween:TweenMax;
    
    private var clickEnable:Boolean = true;
    
    private function explode():void {
        
        clickEnable = false;
        setTimeout(setclickEnabled, 1500);
        if (openedCounter < 3) openedCounter = 3;
        
        if (tweened == false) {
            tweened = true;
            originalSpeed = speedNum;
            
            mytween = TweenMax.fromTo(this, 3, {speedNum:16/(speedClickRate/2)},{ speedNum:originalSpeed , onComplete: tweenComplete,ease:Elastic.easeInOut} );        
        }else {
            
            mytween.restart();
            
        }
    
    }
    private function setclickEnabled(f:Boolean = true):void {
        clickEnable = f;
    }
    private function tweenComplete():void {
        tweened = false;
    }
    private function pause():void {
        stage.removeEventListener(Event.ENTER_FRAME, update);
    }
    
    private var _form:BasicScoreForm;
    
    private function congratu():void
    {
        Component.initStage(stage);
        var time:Number = (getTimer() - firstTime)/1000;
        var score:int =  int(time*100);
        _form = new BasicScoreForm(this, (465-BasicScoreForm.WIDTH)/2, (465-BasicScoreForm.HEIGHT)/2, score, ' time ', showRanking);
        pause();
        openedCounter = 0;
         stage.removeEventListener(MouseEvent.CLICK, onCLick);
        
    }
    private function showRanking(didSaved:Boolean):void{
                    removeChild(_form);
            
            var ranking:BasicScoreRecordViewer = new BasicScoreRecordViewer(this, (465-BasicScoreRecordViewer.WIDTH)/2,(465-BasicScoreRecordViewer.HEIGHT)/2,'TIME RANKING', 99, false);
        reset();
        stage.addEventListener(MouseEvent.CLICK, onCLick);
        }    
    
    private function calculateTime():void { 
            var time:Number = (getTimer() - firstTime)/1000;
            
            timerText.text = "Time : " + time.toFixed(2);
    }
    
    
    
    
    private function update(e:Event = null):void {
        draw();
    }
    
    
    private var preTime:Number = 0;
    private var elapsed:Number = 0;
    private var current:Number = 0;
    
    private function draw():void {
        var vn:Vector.<Number> = f.update(false);
        
        current = getTimer();
        elapsed = (current - preTime)/33;
        preTime = current;
        
        graphics.clear();
        graphics.beginFill(0xeeeeee, 1);
        graphics.drawRect(0, 0, 465, 465);
        graphics.drawGraphicsData(gd);
        graphics.lineStyle(0);

        graphics.beginFill(0xff000);
        var i:int = 0;

       var tmpX:Number;
        var tmpY:Number;
        
        for (i = 0; i < N; i++) {
            graphics.beginFill(0xffffff);
            // graphics.drawCircle(points[i].x, points[i].y, 2);
            var tar:FortuneCell = f._cells[i];
            
            if (tar.clicked) {
                var tt:TextField = textArray[i];
                tt.text = f._cells[i].NearBombNumber.toString();
                tt.x = points[i].x - tt.textWidth / 2;
                tt.y = points[i].y - tt.textHeight / 2;
                tt.visible = true;

            } else if (tar.bomb) {
                // draw flag
                graphics.lineStyle(0);
                    graphics.beginFill(0xff0000);
                    graphics.moveTo(tar.x-3, tar.y);
                    graphics.lineTo(tar.x + 11, tar.y  -5);
                    graphics.lineTo(tar.x-3, tar.y-10);
                    graphics.lineTo(tar.x - 3, tar.y);
                    graphics.beginFill(0);
                    graphics.drawRect(tar.x , tar.y-1, 2, 11);
                    graphics.drawEllipse(tar.x-6, tar.y+9,14,4);
            }else {
                textArray[i].visible = false;
            }
            graphics.endFill();
            var cc:Boolean = (f._cells[i].clicked == false) && (openedCounter > 2);
            
            speed = speedNum * speedClickRate;
            
            tmpX = points[i].x - FX;
            tmpY = points[i].y - FY ;
            if (cc) {
                //if(Math.random() > 0.92) trace(" -- elapsed : " + elapsed);
                
                tmpX += velos[i].x * speed * elapsed;    
                tmpY += velos[i].y * speed * elapsed;    
            }
            if (tmpX > FW) {
                tmpX = FW - 1;
                velos[i].x *= -1;
            }else if (tmpX < 0) {
                tmpX = 1;
                velos[i].x *= -1;
            }
            
            if (tmpY > FH) {
                tmpY = FH - 1;
                velos[i].y *= -1;
            }else if (tmpY < 0) {
                tmpY = 1;
                velos[i].y *= -1;
            }
            points[i].x = tmpX + FX;
            points[i].y = tmpY + FY;
        }
        

        openedText.text = openedCounter.toString() + " / " + greenCounter;
        if (openedCounter == 0) {
            timerText.text = "time : 0";
        }else{
            calculateTime();
        }
        
    }

}
}


import flash.display.GraphicsPath;
import flash.display.GraphicsPathCommand;
import flash.display.IGraphicsData;
import flash.geom.Point;


internal class BombPoint extends Point {

    public function BombPoint(xx:Number, yy:Number) {
        super(xx, yy);
    }
}

internal class Fortune {
    private var _length:int;
    private var _points:Vector.<BombPoint>;
    public var _cells:Vector.<FortuneCell>;
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

    private var bombRate:Number = 0.25;
    
    public function Fortune(points:Vector.<BombPoint>, topBoundary:Number, leftBoundary:Number, rightBoundary:Number, bottomBoundary:Number) {
        _length = points.length;
        _points = points;
        _cells = new Vector.<FortuneCell>(_length);
        _graphicsPaths = new Vector.<IGraphicsData>();
        for (var i:int = 0; i < _length; i++) {
            _cells[i] = new FortuneCell(points[i]);
            _graphicsPaths[i] = _cells[i].graphicsPath;
        }

        var bombCount:int = 0;
        while (true) {
            var cell:FortuneCell = _cells[Math.floor(Math.random() * _length)];
            if ( cell.bomb == false){
                cell.bomb = true;
                bombCount += 1;
                if (bombCount > _length * bombRate) {
                    trace(" --- bombcount : " +bombCount);
                    break;
                }
            }
            
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

    public function dispose():void {
        _points.length = 0;
        _cells.length = 0;
        _graphicsPaths.length = 0;
        _points = null;
        _cells = null;
        _graphicsPaths = null;
    }
    
    public function update(curve:Boolean = false):Vector.<Number> {
        reset();
        //追加待ちの母点または評価待ちのボロノイ点候補が残っていて、かつ境界内にbeachlineが残っていれば
        while (_waitCellsHead) {
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
        for (var i:int = 0; i < _length; i++) {
            var target:FortuneCell = _cells[i];
            target.updateGraphicsPath(curve);
            //trace("line length : " + _cells[i].lineArray.length);
            if (_cells[i].clicked) {
                _cells[i].NearBombNumber = 0;
                for (var j:int = 0; j < target.lineArray.length; j++) {
                    var line:CellLine = target.lineArray[j];
                    var pp:Point = line.outCenterPoint(new Point(target.x, target.y));

                    var ll:Number = 9999;
                    var minInd:int;
                    for (var kk:int = 0; kk < _length; kk++) {
                        var other:Point = new Point(_cells[kk].x, _cells[kk].y);
                        var dist:Number = Point.distance(other, pp);
                        if (ll > dist) {
                            ll = dist;
                            minInd = kk;
                        }
                    }
                    if (_cells[minInd].bomb) {
                        _cells[i].NearBombNumber += 1;
                    }

                }
            }


        }


        if (Math.random() > 0.9) return _cells[0].graphicsPath.data;

        var len:int = _cells[0].graphicsPath.data.length;
        for (var jj:int = 0; jj < len; jj++) {
            //trace(jj + " : " + _cells[0].graphicsPath.data[jj])
        }
        return _cells[0].graphicsPath.data;
    }

    //新しい母点が関わりうるボロノイ点について調査
    private function checkNewCell(newCell:FortuneCell):void {
        var vp:VoronoiPoint;
        var ncx:Number = newCell.x;
        var chkBL:BeachLine = _beachLineLeftmost;
        if (chkBL) do
        {
            if (ncx <= chkBL.rightEndX) {
                break;
            }
        } while (chkBL = chkBL.right);
        checkBeachLine(newCell, chkBL);
    }

    // 新しい点をbeachlineに沿って
    // 他のボロノイ母点とボロノイ点を作りうるかどうか評価していく
    private function checkBeachLine(newCell:FortuneCell, centerBL:BeachLine):void {

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
        while (leftBL = leftBL.left) {
            leftCell = leftBL.cell;
            leftCot = leftCell.getCot(newCell);
            if (leftCot > cot) {
                vp = new VoronoiPoint(newCell, leftCell, cell);
                if (testVoronoi(vp)) {
                    vp.fix();
                    cell = leftCell;
                    cot = leftCot;
                }
            }
        }
        //左境界に達したらぐるっと下境界を評価
        leftCell = _leftBounds;
        vp = new VoronoiPoint(newCell, leftCell, cell);
        if (testVoronoi(vp)) {
            vp.fix();
            cell = leftCell;
        }
        leftCell = _bottomBounds;
        vp = new VoronoiPoint(newCell, leftCell, cell);
        if (testVoronoi(vp)) {
            vp.fix();
        }

        // 右に移動しながらボロノイ点候補を探す
        rightBL = centerBL;
        cell = rightCell = centerBL.cell;
        cot = rightCot = cell.getCot(newCell);
        while (rightBL = rightBL.right) {
            rightCell = rightBL.cell;
            rightCot = rightCell.getCot(newCell);
            if (rightCot < cot) {
                vp = new VoronoiPoint(newCell, rightCell, cell);
                if (testVoronoi(vp)) {
                    vp.fix();
                    cell = rightCell;
                    cot = rightCot;
                }
            }
        }
        rightCell = _rightBounds
        vp = new VoronoiPoint(newCell, rightCell, cell);
        if (testVoronoi(vp)) {
            vp.fix();
            cell = rightCell;
        }
        rightCell = _bottomBounds
        vp = new VoronoiPoint(newCell, rightCell, cell);
        if (testVoronoi(vp)) {
            vp.fix();
        }
    }

    /**
     * sweeplineを移動しbeachlineとアクティブなセルを更新する
     * コストがかかるのでこのメソッドの呼び出しを極力少なく
     * @param    y
     */
    private function sweepTo(y:Number):void {
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
            if (yVal > leftmostY) {
                leftmostY = yVal;
                beachLineCell = cell;
            }
        } while (cell = cell.next);
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
        for (; ;) {
            cell = _activeCellsHead;
            rX = _rightX;
            do
            {
                if (cell === leftCell) {
                    continue;
                }
                solX = leftCell.getIntersectionX(cell);
                if (solX) {
                    xVal = solX.xSmaller;
                    if (xVal > lX && xVal < rX) {
                        rX = xVal;
                        beachLineCell = cell;
                    }
                    else {
                        xVal = solX.xBigger;
                        if (xVal > lX && xVal < rX) {
                            rX = xVal;
                            beachLineCell = cell;
                        }
                    }
                }
            } while (cell = cell.next);
            if (leftCell != beachLineCell && rX < _rightX) {
                yVal = leftCell.getParabolaY(rX);
                beachLineCell.isBeachLine = true;
                rightBL = new BeachLine(beachLineCell);
                rightBL.left = leftBL;
                leftBL.right = rightBL;
                leftBL.rightEndX = rX;
                if (yVal < _beachLineTop) {
                    _beachLineTop = yVal;
                }
                lX = rX;
                leftBL = rightBL;
                leftCell = beachLineCell;
            }
            else {
                rX = _rightX;
                yVal = leftCell.getParabolaY(rX);
                leftBL.right = null;
                leftBL.rightEndX = rX;
                if (yVal < _beachLineTop) {
                    _beachLineTop = yVal;
                }
                break;
            }
        }

        //beachlineを構成しないセルはリストから外す
        while (!_activeCellsHead.isBeachLine) {
            _activeCellsHead = _activeCellsHead.next;
        }
        cell = _activeCellsHead;
        var prevCell:FortuneCell = cell;
        while (cell = cell.next) {
            if (!cell.isBeachLine) {
                prevCell.next = cell.next;
            }
            else {
                  prevCell = cell;
            }
        }
    }

    /**
     * 全セルをリセット
     * y昇順にソートし待ちリストに追加しなおす
     */
    private function reset():void {
        _sweepLine = _topY;
        _waitCellsHead = null;
        _activeCellsHead = _topBounds;
        _beachLineLeftmost = new BeachLine(_topBounds);
        _beachLineTop = - Number.MAX_VALUE;
        for (var i:int = 0; i < _length; i++) {
            var cell:FortuneCell = _cells[i];
            cell.setPosition(_points[i]);
            addWaitCell(cell);
        }
    }

    /**
     * セルの評価待ちリストにy昇順になるように追加
     * @param    cell
     */
    private function addWaitCell(cell:FortuneCell):void {
        var cy:Number = cell.y;
        if (cy < _sweepLine) {
            return;
        }
        if (!_waitCellsHead || cy < _waitCellsHead.y) {
            cell.next = _waitCellsHead;
            _waitCellsHead = cell;
            return;
        }
        var chkCell:FortuneCell = _waitCellsHead;
        var prevCell:FortuneCell = chkCell;
        while (chkCell = chkCell.next) {
            if (cy < chkCell.y) {
                prevCell.next = cell;
                cell.next = chkCell;
                return;
            }
            prevCell = chkCell;
        }
        prevCell.next = cell;
    }

    //ボロノイ点候補を評価して確定してもよければtrue
    private function testVoronoi(vp:VoronoiPoint):Boolean {
        return !(isOutBounds(vp) || containsActiveCell(vp) || containsWaitCell(vp))
    }

    //ボロノイ点候補の円の中に現在評価待ちのセル点があったら真
    private function containsWaitCell(vp:VoronoiPoint):Boolean {
        //trace("containsWaitCell():");
        var cell:FortuneCell = _waitCellsHead;
        var vt:Number = vp.t;
        if (cell && cell.y < vt) do
        {
            if (vp.contains(cell)) { //評価待ちセル母点を1つでも円の中に含めば真を返す
                return true;
            }
            var tst:uint = 0;
        } while ((cell = cell.next) && cell.y < vt);
        //待ちリストの終端に達するか、追加時期がボロノイ点の評価タイミングを超える場合には
        return false;
    }

    // ボロノイ点候補の円の中に現在beachlineを作っているセル点があったら真
    private function containsActiveCell(vp:VoronoiPoint):Boolean {
        //trace("containsActiveCell():");
        var cell:FortuneCell = _activeCellsHead;
        var vt:Number = vp.t;
        if (cell) do
        {
            if (cell is YBoundaryCell) { //top境界がbeachlineの一部の場合があるので
                continue;
            }
            if (vp.contains(cell)) { //アクティブなセル母点を1つでも円の中に含めば真を返す
                return true;
            }
        } while (cell = cell.next);
        //リストの終端に達する場合には偽
        return false;
    }

    // ボロノイ点候補が境界の外にあったら真
    private function isOutBounds(vp:VoronoiPoint):Boolean {
        //trace("isOuntBounds():");
        var vx:Number = vp.x;
        var vy:Number = vp.y;
        return vx < _leftX || vx > _rightX || vy < _topY || vy > _bottomY;
    }

    public function get graphicsPaths():Vector.<IGraphicsData> {
        return _graphicsPaths;
    }

}


internal class CellLine {
    public var x1:Number;
    public var x2:Number;
    public var y1:Number;
    public var y2:Number;

    public function CellLine(_x1:Number, _y1:Number, _x2:Number, _y2:Number) {
        x1 = _x1;
        x2 = _x2;
        y1 = _y1;
        y2 = _y2;
    }

    public function outCenterPoint(p:Point):Point {
        var centerP:Point = Point.interpolate(new Point(x1, y1), new Point(x2, y2), 0.5);
        var outP:Point = Point.interpolate(centerP, p, 1.03);
        return outP;
    }
    public function toString():String {
        return "x1 : " + x1 + "  y1 : " + y1 + "  x2 : " + x2 + "  y2 : " + y2;
    }

}

internal class FortuneCell {
    public var x:Number, y:Number;
    public var a:Number, b:Number, c:Number;
    public var next:FortuneCell;
    public var isBeachLine:Boolean;

    private var _graphicsPath:GraphicsPath;
    private var _leftWallStart:CellWallPt;
    private var _rightWallStart:CellWallPt;

    public var clicked:Boolean = false;
    public var bomb:Boolean = false;
    public var flag:Boolean = false;
    public var NearBombNumber:int = 0;

    public var lineArray:Vector.<CellLine> = new Vector.<CellLine>();
    
    public function FortuneCell(position:Point) {

        setPosition(position);
        isBeachLine = false;
        _graphicsPath = new GraphicsPath();
    }

    /**
     * 引数のPointオブジェクトで母点位置を更新
     * @param    pt
     */
    public function setPosition(position:Point):void {
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
    public function updateParabola(directrix:Number):void {
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
    public function getParabolaY(parabolaX:Number):Number {
        return (a * parabolaX + 2 * b) * parabolaX + c;
    }

    /**
     * 他のセルの放物線との交点を求める
     * @param    fc
     * @return
     */
    public function getIntersectionX(fc:FortuneCell):QuadraticSolution {
        return QuadraticSolution.solve(a - fc.a, b - fc.b, c - fc.c);
    }

    /**
     * セルの左側にボロノイ点を追加する。
     * 時計回りなので左側ではy降順に並ぶ。
     * @param    vp
     */
    public function addLeftWall(vp:VoronoiPoint):void {
        //trace(this);
        //trace("add to left ", vp);
        var newPt:CellWallPt = new CellWallPt(vp.x, vp.y);
        var vpy:Number = vp.y;
        if (!_leftWallStart || vpy > _leftWallStart.y) {
            newPt.next = _leftWallStart;
            _leftWallStart = newPt;
            return;
        }
        var chkPt:CellWallPt = _leftWallStart;
        var prevPt:CellWallPt = chkPt;
        do
        {
            if (vpy > chkPt.y) {
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
    public function addRightWall(vp:VoronoiPoint):void {
        var newPt:CellWallPt = new CellWallPt(vp.x, vp.y);
        var vpy:Number = vp.y;
        if (!_rightWallStart || vpy < _rightWallStart.y) {
            newPt.next = _rightWallStart;
            _rightWallStart = newPt;
            return;
        }
        var chkPt:CellWallPt = _rightWallStart;
        var prevPt:CellWallPt = chkPt;
        do
        {
            if (vpy < chkPt.y) {
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
    public function updateGraphicsPath(curve:Boolean = false):void {
        var pathCmds:Vector.<int>, pathData:Vector.<Number>;
        var cmdsL:int, dataL:int;
        var cx:Number, cy:Number;
        var chkPt:CellWallPt;

        if (_leftWallStart || _rightWallStart) {
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
            } while (chkPt = chkPt.next);

            chkPt = _rightWallStart;
            if (chkPt) do
            {
                pathData[dataL++] = chkPt.x;
                pathData[dataL++] = chkPt.y;
                pathCmds[cmdsL++] = GraphicsPathCommand.LINE_TO;
            } while (chkPt = chkPt.next);

            pathData[dataL++] = pathData[0];
            pathData[dataL++] = pathData[1];
            //trace(pathCmds.length, pathData.length);
        }

        if (clicked) {
            lineArray.length = 0;
            var len:int = pathData.length - 3;
            for (var i:int = 0; i < len ; i += 2) {
                lineArray.push(new CellLine(pathData[i], pathData[i + 1], pathData[i + 2], pathData[i + 3]));
            }
            
        }

    }

    public function getCot(cell:FortuneCell):Number {
        return (cell.x - this.x) / (cell.y - this.y);
    }

    public function get graphicsPath():GraphicsPath {
        return _graphicsPath;
    }

}

internal class CellWallPt {
    public var x:Number;
    public var y:Number;
    //clockwise next
    public var next:CellWallPt;

    public function CellWallPt(x:Number, y:Number) {
        this.x = x;
        this.y = y;
    }
}

internal class VoronoiPoint {
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
    public function VoronoiPoint(newCell:FortuneCell, cellX:FortuneCell, cellY:FortuneCell) {
        _newCell = newCell;
        if (cellX is YBoundaryCell || cellY is XBoundaryCell) {
            _cellX = cellY;
            _cellY = cellX;
            cellX = _cellX;
            cellY = _cellY;
        }
        else {
            _cellX = cellX;
            _cellY = cellY;
        }

        var isXboundary:Boolean = cellX is XBoundaryCell;
        var isYboundary:Boolean = cellY is YBoundaryCell;

        // Lx+My=N を連立させて解く
        if (!isXboundary) {
            var lX:Number = newCell.x - cellX.x;
            var mX:Number = newCell.y - cellX.y;
            var nX:Number = 0.5 * (lX * (newCell.x + cellX.x) + mX * (newCell.y + cellX.y));
        }
        if (!isYboundary) {
            var lY:Number = newCell.x - cellY.x;
            var mY:Number = newCell.y - cellY.y;
            var nY:Number = 0.5 * (lY * (newCell.x + cellY.x) + mY * (newCell.y + cellY.y));
        }

        if (isXboundary || isYboundary) {
            x = isXboundary ? cellX.x : ((nX - mX * cellY.y) / lX);
            y = isYboundary ? cellY.y : ((nY - lY * cellX.x) / mY);
        }
        else {
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
    public function contains(cell:FortuneCell):Boolean {
        if (cell == _cellX || cell == _cellY || cell == _newCell) {
            return false;
        }
        var dx:Number = cell.x - x;
        if (dx > r) {
            return false;
        }
        var dy:Number = cell.y - y;
        if (dx > r) {
            return false;
        }
        return r2 > dx * dx + dy * dy;
    }

    /**
     * 新しいボロノイ点として確定し、各セルに追加する
     */
    public function fix():void {
        var isXboundary:Boolean = _cellX is XBoundaryCell;
        var isYboundary:Boolean = _cellY is YBoundaryCell;
        var nx:Number = _newCell.x;
        var xx:Number = _cellX.x;
        var yx:Number = _cellY.x;

        if (isYboundary) {
            if (nx > xx) {
                _newCell.addLeftWall(this);
                isXboundary ? null : _cellX.addRightWall(this);
            }
            else {
                _newCell.addRightWall(this);
                isXboundary ? null : _cellX.addLeftWall(this);
            }
        }
        else if (isXboundary) {
            if (nx > xx) {
                _newCell.addLeftWall(this);
                _cellY.addLeftWall(this);
            }
            else {
                _newCell.addRightWall(this);
                _cellY.addRightWall(this);
            }
        }
        else {
            if (nx > xx) {
                _newCell.addLeftWall(this);
                if (xx > yx) {
                    _cellX.addLeftWall(this);
                    _cellY.addRightWall(this);
                }
                else {
                    _cellY.addLeftWall(this);
                    _cellX.addRightWall(this);
                }
            }
            else {
                _cellX.addLeftWall(this);
                if (nx > yx) {
                    _newCell.addLeftWall(this);
                    _cellY.addRightWall(this);
                }
                else {
                    _cellY.addLeftWall(this);
                    _newCell.addRightWall(this);
                }
            }
        }
    }

}

internal class QuadraticSolution {
    public var xSmaller:Number;
    public var xBigger:Number;

    /**
     * 2次方程式 ax^2 + 2bx + c = 0 の解を返す
     * @param    a
     * @param    b
     * @param    c
     */
    public static function solve(a:Number, b:Number, c:Number):QuadraticSolution {
        if (a == 0) {
            return null;
        }
        var det:Number = b * b - a * c;
        if (det < 0) {
            return null;
        }
        var ia:Number = 1.0 / a;
        var p:Number = -b * ia;
        var q:Number = Math.sqrt(det) * (a > 0.0 ? ia : -ia);
        var qs:QuadraticSolution = new QuadraticSolution();
        qs.xSmaller = p - q;
        qs.xBigger = p + q;
        return qs;
    }

}

internal class BoundaryCell extends FortuneCell {

    public function BoundaryCell(x:Number = 0, y:Number = 0) {
        super(new Point(x, y));
    }

    override public function addLeftWall(vp:VoronoiPoint):void {
    }

    override public function addRightWall(vp:VoronoiPoint):void {
    }

    override public function updateParabola(directrix:Number):void {
    }
}

internal class XBoundaryCell extends BoundaryCell {

    public function XBoundaryCell(x:Number) {
        super(x, 0);
        super.a = NaN;
        super.b = NaN;
        super.c = NaN;
    }

    override public function getIntersectionX(fc:FortuneCell):QuadraticSolution {
        var qs:QuadraticSolution = new QuadraticSolution();
        if (fc.x > x) {
            qs.xSmaller = x;
            qs.xBigger = NaN;
        }
        else {
            qs.xSmaller = NaN;
            qs.xBigger = x;
        }
        return qs;
    }

    override public function getParabolaY(parabolaX:Number):Number {
        return NaN;
    }

    override public function getCot(cell:FortuneCell):Number {
        return cell.x > x ? Number.POSITIVE_INFINITY : Number.NEGATIVE_INFINITY;
    }
}

internal class YBoundaryCell extends BoundaryCell {

    public function YBoundaryCell(y:Number) {
        super(0, y);
        super.a = 0;
        super.b = 0;
        super.c = y;
    }

    override public function getIntersectionX(fc:FortuneCell):QuadraticSolution {
        return QuadraticSolution.solve(fc.a, fc.b, fc.c - y);
    }

    override public function getParabolaY(parabolaX:Number):Number {
        return y;
    }

    override public function getCot(cell:FortuneCell):Number {
        return 0.0;
    }
}

internal class BeachLine {
    public var cell:FortuneCell;
    public var right:BeachLine;
    public var left:BeachLine;
    public var rightEndX:Number;

    public function BeachLine(cell:FortuneCell = null) {
        this.cell = cell;
    }
}

