// forked from greentec's HexCell Mine Sweeper
package 
{
    import com.bit101.components.Label;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import com.bit101.components.Style;
    import com.bit101.components.PushButton;
    import flash.display.Shape;
    import flash.filters.GlowFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.display.BlendMode;
    import flash.geom.Rectangle;
    
    /**
     * ...
     * @author ypc
     */
    
    [SWF(width = "465", height = "465")]
    public class Main extends Sprite 
    {
        public var _width:int = 465;
        public var _height:int = 465;
        
        public var mapSerialArray:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(); //for performance
        public var neighbors:Array = [];
        
        public var mapSize:int = 10;
        public var map:Vector.<Vector.<Vector.<HexCell>>> = new Vector.<Vector.<Vector.<HexCell>>>(2 * mapSize + 1);
        public var edgeLength:int = 13;
        public var edgeW:int;
        public var edgeH:int;
        
        public var cellSprite:Sprite;
        public var objectSprite:Sprite;
        public var objectBitmapData:BitmapData;
        
        
        public var mineProb:Number = 0.15;
        
        public var gameOverLabel:Label;
        public var gameWinLabel:Label;
        
        public var mineShape:Shape;
        public var flagShape:Shape;
        
        public var restartButton:PushButton;
        
        public var totalMineNumber:int = 0;
        public var totalNormalNumber:int = 0;
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            
            
            
            Style.BACKGROUND = 0x444444;
            //Style.BUTTON_FACE = 0x666666;
            //Style.INPUT_TEXT = 0xBBBBBB;
            //Style.LABEL_TEXT = 0xCCCCCC;
            Style.PANEL = 0x666666;
            Style.PROGRESS_BAR = 0x666666;
            
            var i:int;
            for (i = 0; i < 6; i += 1)
            {
                neighbors[i] = [];
            }
            neighbors[0] = [+1, -1, 0];
            neighbors[1] = [+1, 0, -1];
            neighbors[2] = [0, +1, -1];
            neighbors[3] = [-1, +1, 0];
            neighbors[4] = [-1, 0, +1];
            neighbors[5] = [0, -1, +1];
            
            edgeW = edgeLength * 3 / 2;
            edgeH = edgeLength * Math.sqrt(3) / 2;
            
            cellSprite = new Sprite();
            addChild(cellSprite);
            
            objectSprite = new Sprite();
            objectSprite.mouseEnabled = false;
            objectBitmapData = new BitmapData(_width, _height, true, 0x00ffffff);
            objectSprite.addChild(new Bitmap(objectBitmapData));
            
            addChild(objectSprite);
            
            gameOverLabel = new Label(this, _width / 2, _height / 2, "Game Over");
            gameOverLabel.visible = false;
            gameOverLabel.scaleX = 6;
            gameOverLabel.scaleY = 6;
            gameOverLabel.x -= gameOverLabel.width * 3; 
            gameOverLabel.y -= gameOverLabel.height * 3;
            gameOverLabel.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 0, 0, 0, 0);
            gameOverLabel.filters = [new GlowFilter()];
            
            
            
            mineShape = new Shape();
            mineShape.graphics.beginFill(0x0);
            mineShape.graphics.drawCircle(0, 0, 6);
            mineShape.graphics.endFill();
            mineShape.graphics.lineStyle(1, 0);
            mineShape.graphics.moveTo(0, 0);
            mineShape.graphics.lineTo(0, 8);
            mineShape.graphics.moveTo(0, 0);
            mineShape.graphics.lineTo(8, 0);
            mineShape.graphics.moveTo(0, 0);
            mineShape.graphics.lineTo(0, -8);
            mineShape.graphics.moveTo(0, 0);
            mineShape.graphics.lineTo(-8, 0);
            mineShape.graphics.moveTo(0, 0);
            mineShape.graphics.lineTo(6, 6);
            mineShape.graphics.moveTo(0, 0);
            mineShape.graphics.lineTo(-6, -6);
            mineShape.graphics.moveTo(0, 0);
            mineShape.graphics.lineTo(6, -6);
            mineShape.graphics.moveTo(0, 0);
            mineShape.graphics.lineTo(-6, 6);
            
            
            flagShape = new Shape();
            flagShape.graphics.beginFill(0x0);
            flagShape.graphics.drawRect(0, 0, 3, 16);
            flagShape.graphics.endFill();
            flagShape.graphics.lineStyle(0, 0xcccccc);
            flagShape.graphics.beginFill(0xff0000);
            flagShape.graphics.moveTo(3, 0);
            flagShape.graphics.lineTo(12, 3);
            flagShape.graphics.lineTo(3, 8);
            flagShape.graphics.lineTo(3, 0);
            flagShape.graphics.endFill();
            
            
            restartButton = new PushButton(this, _width - 110, _height - 50, "Restart", onRestart);
            restartButton.height = 40;
            
            initMap(map);
            drawMap(map);
            
            initGame();
        }
        
        private function onRestart(e:Event):void
        {
            var i:int;
            var hexCell:HexCell;
            
            for (i = 0; i < mapSerialArray.length; i += 1)
            {
                hexCell = map[mapSerialArray[i][0] + mapSize][mapSerialArray[i][1] + mapSize][mapSerialArray[i][2] + mapSize];
                hexCell._visited = false;
                hexCell.number = 0;
                hexCell.mine = false;
                hexCell.onFlag = false;
                hexCell.numberLabel.text = "";
                hexCell.alpha = 1;
                hexCell.drawCell(hexCell._G.graphics, (0x20 + (10 + hexCell._y) * 0x08) << 16 | (0x20 + (10 + hexCell._x) * 0x08) << 8 | 0x20 + (10 + hexCell._z) * 0x08, true);
            }
            
            if (cellSprite.hasEventListener(MouseEvent.CLICK) == false)
            {
                cellSprite.addEventListener(MouseEvent.CLICK, onHexCellClick, true);
                cellSprite.addEventListener(MouseEvent.RIGHT_CLICK, onHexCellRightClick, true);
                cellSprite.addEventListener(MouseEvent.MOUSE_OVER, onHexCellMouseOver, true);
                cellSprite.addEventListener(MouseEvent.MOUSE_OUT, onHexCellMouseOut, true);
                
            }
            
            gameOverLabel.visible = false;
            
            objectBitmapData.fillRect(objectBitmapData.rect, 0x00ffffff);
            
            initGame();
            
        }
        
        private function initGame():void
        {
            var i:int;
            var j:int;
            var hexCell:HexCell;
            var x:int;
            var y:int;
            var z:int;
            var mineNum:int;
            var hexCellNeighbor:HexCell;
            
            totalMineNumber = 0;
            totalNormalNumber = 0;
            
            for (i = 0; i < mapSerialArray.length; i += 1)
            {
                hexCell = map[mapSerialArray[i][0] + mapSize][mapSerialArray[i][1] + mapSize][mapSerialArray[i][2] + mapSize];
                if (Math.random() < mineProb)
                {
                    hexCell.mine = true;
                    //hexCell.drawCell(hexCell._G.graphics, 0x000000);
                    //hexCell.numberLabel.text = "1";
                    
                    totalMineNumber += 1;
                }
                else
                {
                    totalNormalNumber += 1;
                }
            }
            
            for (i = 0; i < mapSerialArray.length; i += 1)
            {
                hexCell = map[mapSerialArray[i][0] + mapSize][mapSerialArray[i][1] + mapSize][mapSerialArray[i][2] + mapSize];
                if (hexCell.mine == false)
                {
                    mineNum = 0;
                    
                    for (j = 0; j < 6; j += 1)
                    {
                        x = hexCell._x + neighbors[j][0];
                        y = hexCell._y + neighbors[j][1];
                        z = hexCell._z + neighbors[j][2];
                        
                        if (calcBoundary(x, y, z))
                        {
                            hexCellNeighbor = map[x + mapSize][y + mapSize][z + mapSize];
                            if (hexCellNeighbor.mine)
                            {
                                mineNum += 1;
                            }
                        }
                        
                    }
                    
                    hexCell.number = mineNum;
                    
                }
                
            }
            
            
        }
        
        private function initMap(map:Vector.<Vector.<Vector.<HexCell>>>):void
        {
            var i:int, j:int, k:int;
            var hexCell:HexCell;
            var serialIndex:int = 0;
            
            for (i = -1 * mapSize; i < mapSize + 1; i += 1)
            {
                map[i + mapSize] = new Vector.<Vector.<HexCell>>(2 * mapSize + 1);
                for (j = -1 * mapSize; j < mapSize + 1; j += 1)
                {
                    map[i + mapSize][j + mapSize] = new Vector.<HexCell>(2 * mapSize + 1);
                    for (k = -1 * mapSize; k < mapSize + 1; k += 1)
                    {
                        if (i + j + k == 0)
                        {
                            hexCell = new HexCell(i, j, k, edgeLength);
                            cellSprite.addChild(hexCell);
                            
                            map[i + mapSize][j + mapSize][k + mapSize] = hexCell;
                            
                            mapSerialArray[serialIndex] = new Vector.<int>(3);
                            mapSerialArray[serialIndex][0] = i;
                            mapSerialArray[serialIndex][1] = j;
                            mapSerialArray[serialIndex][2] = k;
                            serialIndex += 1;
                        }
                        
                    }
                }
            }
            
        }
        
        private function drawMap(map:Vector.<Vector.<Vector.<HexCell>>>):void
        {
            var i:int;
            var hexCell:HexCell;
            
            for (i = 0; i < mapSerialArray.length; i += 1)
            {
                hexCell = map[mapSerialArray[i][0] + mapSize][mapSerialArray[i][1] + mapSize][mapSerialArray[i][2] + mapSize];
                //hexCell.drawCell(hexCell._G.graphics, (0x40 + Math.random() * 0x80) << 16 | (0x40 + Math.random() * 0x80) << 8, true);
                hexCell.drawCell(hexCell._G.graphics, (0x20 + (10 + hexCell._y) * 0x08) << 16 | (0x20 + (10 + hexCell._x) * 0x08) << 8 | 0x20 + (10 + hexCell._z) * 0x08, true);
                //hexCell.drawCell(hexCell._G.graphics, 0, true);
                hexCell.drawCell(hexCell._GLine.graphics, 0xffffff, false);
                
                hexCell.x = _width / 2 + hexCell._x * edgeW;
                hexCell.y = _height / 2 + (0 - hexCell._y + hexCell._z) * edgeH;
            }
            
            cellSprite.addEventListener(MouseEvent.CLICK, onHexCellClick, true);
            cellSprite.addEventListener(MouseEvent.RIGHT_CLICK, onHexCellRightClick, true);
            cellSprite.addEventListener(MouseEvent.MOUSE_OVER, onHexCellMouseOver, true);
            cellSprite.addEventListener(MouseEvent.MOUSE_OUT, onHexCellMouseOut, true);
            
            
            
            
        }
        
        private function onHexCellClick(e:MouseEvent):void
        {
            var hexCell:HexCell = e.target as HexCell;
            
            if (hexCell.onFlag == false)
            {
                if (hexCell.mine == false && hexCell._visited == false)
                {
                    hexCell.drawCell(hexCell._G.graphics, 0);
                    hexCell._visited = true;
                    totalNormalNumber -= 1;
                    
                    
                    if (hexCell.number > 0)
                    {
                        hexCell.numberLabel.text = String(hexCell.number);
                    }
                    else //0 - dfs search
                    {
                        hexCell.drawCell(hexCell._G.graphics, 0);
                        //totalNormalNumber -= 1;
                        dfsSearch(hexCell._x, hexCell._y, hexCell._z);
                    }
                    
                    
                    //win check
                    if (totalNormalNumber <= 0)
                    {
                        cellSprite.removeEventListener(MouseEvent.CLICK, onHexCellClick, true);
                        cellSprite.removeEventListener(MouseEvent.RIGHT_CLICK, onHexCellRightClick, true);
                        cellSprite.removeEventListener(MouseEvent.MOUSE_OVER, onHexCellMouseOver, true);
                        cellSprite.removeEventListener(MouseEvent.MOUSE_OUT, onHexCellMouseOut, true);
                        
                        gameOverLabel.text = "You Win!!!";
                        gameOverLabel.visible = true;
                    }
                    
                }
                else if (hexCell.mine == true && hexCell._visited == false) // mine - bomb!!  ~~ GAME OVER ~~
                {
                    objectBitmapData.draw(mineShape, new Matrix(1, 0, 0, 1, hexCell.x, hexCell.y));
                    
                    var i:int;
                    var hexCellOtherMine:HexCell;
                    
                    for (i = 0; i < mapSerialArray.length; i += 1)
                    {
                        hexCellOtherMine = map[mapSerialArray[i][0] + mapSize][mapSerialArray[i][1] + mapSize][mapSerialArray[i][2] + mapSize];
                        
                        if (hexCellOtherMine.mine == true && hexCellOtherMine.onFlag == false)
                        {
                            objectBitmapData.draw(mineShape, new Matrix(1, 0, 0, 1, hexCellOtherMine.x, hexCellOtherMine.y));
                        }
                    }
                    
                    cellSprite.removeEventListener(MouseEvent.CLICK, onHexCellClick, true);
                    cellSprite.removeEventListener(MouseEvent.RIGHT_CLICK, onHexCellRightClick, true);
                    cellSprite.removeEventListener(MouseEvent.MOUSE_OVER, onHexCellMouseOver, true);
                    cellSprite.removeEventListener(MouseEvent.MOUSE_OUT, onHexCellMouseOut, true);
                    
                    gameOverLabel.text = "Game Over";
                    gameOverLabel.visible = true;
                }
            }
            
        }
        
        private function dfsSearch(_x:int, _y:int, _z:int):void
        {
            var hexCell:HexCell;
            var i:int;
            var idX:int;
            var idY:int;
            var idZ:int;
            
            for (i = 0; i < 6; i += 1)
            {
                idX = _x + neighbors[i][0];
                idY = _y + neighbors[i][1];
                idZ = _z + neighbors[i][2];
                
                if (calcBoundary(idX, idY, idZ))
                {
                    hexCell = map[idX + mapSize][idY + mapSize][idZ + mapSize];
                    if (hexCell._visited == false)
                    {
                        hexCell._visited = true;
                        if (hexCell.mine == false)
                        {
                            hexCell.drawCell(hexCell._G.graphics, 0);
                            totalNormalNumber -= 1;
                            
                            if (hexCell.onFlag == true)
                            {
                                objectBitmapData.fillRect(new Rectangle(hexCell.x - edgeLength / 2 - 1, hexCell.y - edgeLength / 2 - 1, 14, 18), 0x00ffffff);
                                hexCell.onFlag = false;
                            }
                            
                            
                            if (hexCell.number > 0)
                            {
                                hexCell.numberLabel.text = String(hexCell.number);
                            }
                            else // 0 - dfs again
                            {
                                dfsSearch(hexCell._x, hexCell._y, hexCell._z);
                            }
                        }
                    }
                }
                
                
            }
            
            
        }
        
        private function onHexCellRightClick(e:MouseEvent):void
        {
            var hexCell:HexCell = e.target as HexCell;
            
            if (hexCell._visited == false)
            {
                if (hexCell.onFlag)
                {
                    //objectBitmapData.draw(flagShape, new Matrix(1, 0, 0, 1, hexCell.x - edgeLength / 2, hexCell.y - edgeLength / 2), null, BlendMode.ERASE);
                    objectBitmapData.fillRect(new Rectangle(hexCell.x - edgeLength / 2 - 1, hexCell.y - edgeLength / 2 - 1, 14, 18), 0x00ffffff);
                    hexCell.onFlag = false;
                    
                    if (hexCell.mine == true)
                    {
                        totalMineNumber += 1;
                    }
                }
                else
                {
                    objectBitmapData.draw(flagShape, new Matrix(1, 0, 0, 1, hexCell.x - edgeLength / 2, hexCell.y - edgeLength / 2));
                    hexCell.onFlag = true;
                    
                    if (hexCell.mine == true)
                    {
                        totalMineNumber -= 1;
                    }
                }
            }
            
        }
        
        private function onHexCellMouseOver(e:MouseEvent):void
        {
            var hexCell:HexCell = e.target as HexCell;
            hexCell.alpha = 0.5;
            
            var _x:int = hexCell._x;
            var _y:int = hexCell._y;
            var _z:int = hexCell._z;
            var i:int;
            var idX:int;
            var idY:int;
            var idZ:int;
            
            for (i = 0; i < 6; i += 1)
            {
                idX = _x + neighbors[i][0];
                idY = _y + neighbors[i][1];
                idZ = _z + neighbors[i][2];
                
                if (calcBoundary(idX, idY, idZ))
                {
                    hexCell = map[idX + mapSize][idY + mapSize][idZ + mapSize];
                    hexCell.alpha = 0.5;
                }
            }
        }
        
        private function onHexCellMouseOut(e:MouseEvent):void
        {
            var hexCell:HexCell = e.target as HexCell;
            hexCell.alpha = 1;
            
            var _x:int = hexCell._x;
            var _y:int = hexCell._y;
            var _z:int = hexCell._z;
            var i:int;
            var idX:int;
            var idY:int;
            var idZ:int;
            
            for (i = 0; i < 6; i += 1)
            {
                idX = _x + neighbors[i][0];
                idY = _y + neighbors[i][1];
                idZ = _z + neighbors[i][2];
                
                if (calcBoundary(idX, idY, idZ))
                {
                    hexCell = map[idX + mapSize][idY + mapSize][idZ + mapSize];
                    hexCell.alpha = 1;
                }
            }
        }
        
        private function calcBoundary(x:int, y:int, z:int):Boolean
        {
            if (x <= mapSize && x >= -mapSize &&
                y <= mapSize && y >= -mapSize &&
                z <= mapSize && z >= -mapSize) //걍 정육각형 범위 안에 있는지 확인
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        
    }
    
}
Class  
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Graphics;
    import com.bit101.components.Label;
    
    /**
     * ...
     * @author ypc
     */
    class HexCell extends Sprite
    {
        public var _x:int;
        public var _y:int;
        public var _z:int;
        public var edgeLength:int;
        
        public var _G:Shape;
        public var _GLine:Shape;
        
        public var mine:Boolean = false;
        public var number:int = 0;
        public var onFlag:Boolean = false;

        public var _enable:Boolean = false;
        public var _visited:Boolean = false; //for dfs search
        
        public var numberLabel:Label;

        
        public function HexCell(_x:int, _y:int, _z:int, edgeLength:int) 
        {
            this._x = _x;
            this._y = _y;
            this._z = _z;
            this.edgeLength = edgeLength;
            
            _G = new Shape();
            addChild(_G);
            _GLine = new Shape();
            addChild(_GLine);
            
            numberLabel = new Label(this, -edgeLength / 2, -edgeLength, "");
            numberLabel.mouseEnabled = false;
            numberLabel.scaleX = numberLabel.scaleY = 1.5;
        }
        
        public function drawCell(_G:Graphics, color:uint = 0xcccccc, fill:Boolean = false):void
        {
            _G.clear();
            
            if (fill == true)
            {
                _G.beginFill(color);
            }
            else
            {
                _G.lineStyle(1, color);
            }
            
            _G.moveTo(edgeLength, 0);
            
            var i:int;
            var angle:Number;
            
            for (i = 1; i <= 6; i += 1)
            {
                angle = 2 * Math.PI / 6 * i;
                _G.lineTo(edgeLength * Math.cos(angle), edgeLength * Math.sin(angle));
            }
            _G.endFill();
        }
        
    }

}