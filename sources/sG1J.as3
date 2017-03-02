// forked from keim_at_Si's SiON Tenorion
// SiON TENORION for v0.57
/**
 * 倉庫番+Tenorion実験
 * 緑:自機
 * 青:箱
 * 黄:箱を置く場所
 * 薄青:箱が目的地にある状態
 *
 * キーの上下左右で移動できます。
 */
package{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;
    
    import org.si.sion.SiONDriver;
    import org.si.sion.SiONVoice;
    import org.si.sion.events.SiONTrackEvent;
    import org.si.sion.utils.SiONPresetVoice;

    public class Tenorioban extends Sprite{
        
        private const CELL_SIZE:int = 20;
        private const CELL_SPACE:int = 2;
        
        private const COL_NUM:int = 18;//外枠を含む
        private const ROW_NUM:int = 18;//外枠を含む
        private const STAGE_SIZE:int = COL_NUM * ROW_NUM;
        private const STAGE_INIT_DATA:Vector.<int> = Vector.<int>([
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 
            1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
            1, 0, 1, 0, 1, 2, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 1, 
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
            1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 
            1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 2, 3, 0, 1, 0, 0, 0, 1, 
            1, 0, 0, 0, 0, 0, 3, 2, 5, 0, 0, 0, 1, 0, 0, 3, 0, 1, 
            1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 
            1, 0, 0, 0, 0, 0, 3, 0, 2, 1, 0, 0, 0, 0, 1, 0, 0, 1, 
            1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 
            1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 
            1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, 0, 0, 1, 0, 0, 1, 
            1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 
            1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 
            1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
        ]);
        
        private const S_ROAD:int = 0;
        private const S_WALL:int = 1;
        private const S_BOX:int = 2;
        private const S_TARGET:int = 3;
        private const S_BOX_ON_TARGET:int = 4;
        private const S_CHARACTOR:int = 5;
        private const S_CHARACTOR_ON_TARGET:int = 6;
        
        private const S_ROAD_COLOR:uint = 0xFFFFFF;
        private const S_WALL_COLOR:int = 0x000000;
        private const S_BOX_COLOR:int = 0x6699FF;
        private const S_TARGET_COLOR:int = 0xFFCC33;
        private const S_BOX_ON_TARGET_COLOR:int = 0x99CCFF;
        private const S_CHARACTOR_COLOR:int = 0x66FF99;
        private const S_CHARACTOR_ON_TARGET_COLOR:int = 0x66FF99;
        
        //private const MAX_BPM:int = 150;
        
        private var _stageGrid:Vector.<int> = new Vector.<int>(STAGE_SIZE);
        private var _stageField:Sprite;
        private var _currentCharactorIndex:int = 0;
        private var _moveTargetIndex:int = 0;
        
        private var _tenorionLineShape:Shape;
        
        private var _driver:SiONDriver;
        private var _presetVoice:SiONPresetVoice;
        
        private var _beatCounter:int;
        private var _beatLevel:int;
        
        private var _voiceList:Vector.<SiONVoice> = new Vector.<SiONVoice>(16);
        private var _noteList:Vector.<int> = Vector.<int>([36, 48, 60, 72,  43, 48, 55, 60,  65, 67, 70, 72,  77, 79, 82, 84]);
        //private var _noteList:Vector.<int> = Vector.<int>([36, 40, 44, 48,  52, 56, 60, 64,  68, 72, 76, 78,  82, 86, 90, 94]);
        //private var _noteList:Vector.<int> = Vector.<int>([96, 92, 88, 84, 80, 76, 72, 68, 64, 60, 56, 52, 48, 44, 40, 36]);
        private var _lengthList:Vector.<int> = Vector.<int>([1, 1, 1, 1,  1, 1, 1, 1,  4, 4, 4, 4,  4, 4, 4, 4]);
        //private var _lengthList:Vector.<int> = Vector.<int>([4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4,  4, 4, 4, 4]);
        
        /**
         * Constracter
         */
        public function Tenorioban(){
            init();
        }
        
        /**
         * init
         */
        private function init():void{
            initStage();
            initKey();
            initSion();
            initLine();
        }
        
        /**
         * ステージの初期化
         */
        private function initStage():void{
            _stageGrid = STAGE_INIT_DATA.concat();
            _stageField = new Sprite();
            this.addChild(_stageField);
            
            setCurrentCharactorPos();
            drawStageGrid();
        }
        
        /**
         * キーボード入力設定
         */
        private function initKey():void{
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyCheck);
            
        }
        
        /**
         * SiON設定
         */
        private function initSion():void{
            _driver = new SiONDriver();
            _presetVoice = new SiONPresetVoice();            
            
            var i:uint = 0;
            var percusVoices:Array = _presetVoice["valsound.percus"];
            _voiceList[0] = percusVoices[0];  // bass drum
            _voiceList[1] = percusVoices[27]; // snare drum
            _voiceList[2] = percusVoices[16]; // close hihat
            _voiceList[3] = percusVoices[22]; // open hihat
            for (i = 4; i < 8;  i++) _voiceList[i] = _presetVoice["valsound.bass18"];  // bass
            for (i = 8; i < 16; i++) _voiceList[i] = _presetVoice["valsound.piano11"]; // e.piano            

            
            _driver.setBeatCallbackInterval(1);
            //_driver.addEventListener(SiONTrackEvent.BEAT, onBeat);
            _driver.setTimerInterruption(1, onTimerInterruption);
            
            _beatCounter = 0;
            _beatLevel = 1;
            
            _driver.bpm = 80;
            _driver.volume = 0.5;
            _driver.play();
        }
        
        /**
         * 上に出すLine
         */
        private function initLine():void{
            
            _tenorionLineShape = new Shape();
            _tenorionLineShape.graphics.beginFill(0xFFFFFF, 0.6);
            _tenorionLineShape.graphics.drawRect(0, 0, CELL_SIZE, (CELL_SIZE + CELL_SPACE) * (ROW_NUM - 2) - CELL_SPACE);
            _tenorionLineShape.graphics.endFill();
            _tenorionLineShape.y = CELL_SIZE + CELL_SPACE;
            
            stage.addChild(_tenorionLineShape);
            
        }
        
        /**
         * ステージ描画
         */
        private function drawStageGrid():void{
            for(var i:uint = 0; i < STAGE_SIZE; i++){
                var cell:Cell;
                
                switch(_stageGrid[i]){
                    case S_BOX:
                        cell = new Cell(S_BOX_COLOR, CELL_SIZE);
                        break;
                    case S_BOX_ON_TARGET:
                        cell = new Cell(S_BOX_ON_TARGET_COLOR, CELL_SIZE);
                        break;
                    case S_ROAD:
                        continue;
                        break;
                    case S_TARGET:
                        cell = new Cell(S_TARGET_COLOR, CELL_SIZE);
                        break;
                    case S_WALL:
                        cell = new Cell(S_WALL_COLOR, CELL_SIZE);
                        break;
                    case S_CHARACTOR:
                        cell = new Cell(S_CHARACTOR_COLOR, CELL_SIZE);
                        break;
                    case S_CHARACTOR_ON_TARGET:
                        cell = new Cell(S_CHARACTOR_ON_TARGET_COLOR, CELL_SIZE);
                        break;
                    default:
                        cell = new Cell(S_ROAD_COLOR, CELL_SIZE);
                        break;
                }
                
                cell.x = getStagePositionX(i);
                cell.y = getStagePositionY(i);
                
                _stageField.addChild(cell);
            }
        }
        
        /**
         * 画面をアップデート
         * @param targetX
         * @param targetY
         */
        private function update(targetX:int = 0, targetY:int = 0):void{
            if(isMovable(targetX, targetY)){
                move(targetX, targetY);
                if(isClear()){
                    clear();
                }
            }
        }
        
        /**
         * 移動
         * @param targetX
         * @param targetY
         */
        private function move(targetX:int, targetY:int):void{
            var nextIndex:int = getNextIndex(_currentCharactorIndex, targetX, targetY);
            var cell:Cell = setPos(_currentCharactorIndex, nextIndex);
            
            _stageGrid[_currentCharactorIndex] = (isTarget(_currentCharactorIndex)) ? S_TARGET : S_ROAD;
            _stageGrid[nextIndex] = (isTarget(nextIndex)) ? S_CHARACTOR_ON_TARGET : S_CHARACTOR;
            
            _currentCharactorIndex = nextIndex;
            
            if(_moveTargetIndex != 0){
                
                var boxNextIndex:int = getNextIndex(_moveTargetIndex, targetX, targetY);
                var bCell:Cell = setPos(_moveTargetIndex, boxNextIndex);
                
                _stageGrid[_moveTargetIndex] = (isTarget(_moveTargetIndex)) ? S_CHARACTOR_ON_TARGET : S_CHARACTOR;
                _stageGrid[boxNextIndex] = (isTarget(boxNextIndex)) ? S_BOX_ON_TARGET : S_BOX;
                
                bCell.color = (isTarget(boxNextIndex)) ? S_BOX_ON_TARGET_COLOR : S_BOX_COLOR;
                _stageField.addChild(bCell);
                
            }
            
            
            
            cell.color = (isTarget(nextIndex)) ? S_CHARACTOR_ON_TARGET_COLOR : S_CHARACTOR_COLOR;
            _stageField.addChild(cell);
        }
        
        /**
         * 移動時の位置再設定
         */
        private function setPos(currentIndex:int, nextIndex:int):Cell{
            var cx:int = getStagePositionX(currentIndex);
            var cy:int = getStagePositionY(currentIndex);
            
            var target:Cell = _stageField.getObjectsUnderPoint(new Point(cx + CELL_SIZE / 2, cy + CELL_SIZE / 2)).pop() as Cell;
            
            var nx:int = getStagePositionX(nextIndex);
            var ny:int = getStagePositionY(nextIndex);
            
            target.x = nx;
            target.y = ny;
            
            return target;
        }
        
        /**
         * クリアした時の処理
         */
        private function clear():void{
            _beatLevel = 0;
        }
        
        
        /**
         * ターゲットの位置取得
         * @param col
         * @param row
         */
        private function getTargetPos(col:int, row:int):int{
            var targetIndex:int = row * COL_NUM + col;
            return _stageGrid[targetIndex];
        }
        
        /**
         * キャラクターの初期位置を設定
         * @throws Error
         */
        private function setCurrentCharactorPos():void{
            for(var i:uint = 0; i < STAGE_SIZE; i++){
                if(_stageGrid[i] == S_CHARACTOR || _stageGrid[i] == S_CHARACTOR_ON_TARGET){
                    _currentCharactorIndex = i;
                } 
            }
            
            if(_currentCharactorIndex == 0){
                throw new Error('キャラクターの位置が設定されていません');
            }
        }
        
        /**
         * index番号からX座標を取得
         */
        private function getStagePositionX(index:int):int{
            var col:int = index % COL_NUM;
            return (CELL_SIZE + CELL_SPACE) * col;
        }
        /**
         * index番号からY座標を取得
         */
        private function getStagePositionY(index:int):int{
            var row:int = int(index / ROW_NUM);
            return (CELL_SIZE + CELL_SPACE) * row;
        }
        
        /**
         * 次のindexを取得
         * @param currentIndex
         * @param targetX
         * @param targetY
         */
        private function getNextIndex(currentIndex:int, targetX:int, targetY:int):int{
            var col:int = currentIndex % COL_NUM;
            var row:int = int(currentIndex / ROW_NUM);
            var nextIndex:int = (row + targetY) * COL_NUM + (col + targetX);
            
            return nextIndex;
        }
        
        /**
         * キー入力チェック
         */
        private function keyCheck(e:KeyboardEvent):void{
            switch(e.keyCode){
                case Keyboard.LEFT:
                    update(-1, 0);
                    break;
                case Keyboard.UP:
                    update(0, -1);
                    break;
                case Keyboard.RIGHT:
                    update(1, 0);
                    break;
                case Keyboard.DOWN:
                    update(0, 1);
                    break;
            }
        }
        
        /**
         * 移動できるか判定
         */
        private function isMovable(targetX:int, targetY:int):Boolean{
            var col:int = _currentCharactorIndex % COL_NUM;
            var row:int = int(_currentCharactorIndex / ROW_NUM);
            var target:int = getTargetPos(col + targetX, row + targetY);
            
            _moveTargetIndex = 0;
            
            switch(target){
                case S_BOX:
                case S_BOX_ON_TARGET:
                    
                    var nextTarget:int = getTargetPos(col + targetX * 2, row + targetY * 2);
                    _moveTargetIndex = (row + targetY) * COL_NUM + col + targetX;
                    
                    switch(nextTarget){
                        case S_ROAD:
                        case S_TARGET:
                            return true;
                        default:
                            return false;
                    }
                case S_ROAD:
                case S_TARGET:
                    return true;
                    
                case S_WALL:
                case S_CHARACTOR:
                case S_CHARACTOR_ON_TARGET:
                default:
                    return false;
                    
            }
        }
        
        /**
         * ターゲットかどうか
         */
        private function isTarget(index:int):Boolean{
            if(STAGE_INIT_DATA[index] == S_TARGET || STAGE_INIT_DATA[index] == S_BOX_ON_TARGET || STAGE_INIT_DATA[index] == S_CHARACTOR_ON_TARGET){
                return true;
            }
            
            return false;
        }
        
        /**
         * クリアしているか
         */
        private function isClear():Boolean{
            var targetNum:int = 0;
            for(var i:uint = 0; i < STAGE_SIZE; i++){
                var cellNum:int = _stageGrid[i];
                if(cellNum == S_TARGET || cellNum == S_CHARACTOR_ON_TARGET){
                    targetNum ++;
                }
            }
            if(targetNum == 0){
                return true;
            }
            return false;
        }
        
        /**
         * SiON
         */
        private function onTimerInterruption():void{
            var beatIndex:int = _beatCounter & 15;
            for(var i:int = 0; i < 16; i++){
                if(_stageGrid[(i + 1) * COL_NUM + (beatIndex + 1)] > _beatLevel){
                    _driver.noteOn(_noteList[15 - i], _voiceList[15 - i], _lengthList[15 - i]);
                }
            }
            _tenorionLineShape.x = (beatIndex + 1) * (CELL_SIZE + CELL_SPACE);
            _beatCounter++;
            /*if(_driver.bpm < MAX_BPM){
                _driver.bpm += 0.1;
            }*/
            
        }
    }
}

/**
 * Cell用のクラス
 */
import flash.display.Graphics;
import flash.display.Sprite;

class Cell extends Sprite{
    private var _color:uint;
    private var _size:int;
    
    public function get color():uint{return _color;}
    public function set color(value:uint):void{
        _color = value;
        draw();
    }
    
    public function Cell(color:uint, size:int){
        _color = color;
        _size = size;
        init();
    }
    
    private function init():void{
        draw();
    }
    
    private function draw():void{
        var g:Graphics = this.graphics;
        g.beginFill(_color);
        g.drawRect(0, 0, _size, _size);
        g.endFill();
    }
}