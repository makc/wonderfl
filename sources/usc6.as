package 
{
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    /**
     * 若干変な動作するけど、気にしない。
     * 
     * @author paq
     */
    [SWF(width="465", height="465", backgroundColor="0xFFFFFF", frameRate="60")]
    public class IsometricView extends Sprite 
    {
        //--------------------------------------------------------------------------
        //
        // プロパティ
        //
        //--------------------------------------------------------------------------
        
        /**
         * ブロックを表示する Sprite.
         * 
         * <p><code>Block</code> インスタンスを画面上に表示したい場合は、
         * <code>_blockContainer.addMapChip</code> メソッドを使用してください。</p>
         */
        private var _blockContainer:MapChipContainer;
        
        /**
         * ブロックがいくつ積み重なっているかを記録するための 2 次元 Vector です.
         */
        private var _blockTop:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
        
        //--------------------------------------------------------------------------
        //
        // メソッド
        //
        //--------------------------------------------------------------------------
        
        /**
         * コンストラクタ
         */
        public function IsometricView() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        /**
         * @param    event
         */
        private function init(event:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            Wonderfl.disable_capture();            
            
            initStage();
            initEventListeners();
            
            _blockContainer = new MapChipContainer();
            addChild(_blockContainer);
            
            initBlocks(6, 6);
            
            onResize();
        }
        
        /**
         * ステージを最適な設定に変更します.
         */
        private function initStage():void 
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.HIGH;
        }

        /**
         * イベントリスナーを追加します.
         */
        private function initEventListeners():void 
        {
            stage.addEventListener(Event.RESIZE, onResize);
        }
        
        /**
         * ブロックを作成します.
         */
        private function initBlocks(w:int = 5, h:int = 5):void 
        {
            for (var i:int = 0; i < w; i++ )
            {
                _blockTop[i] = new Vector.<int>();
                for (var k:int = 0; k < h; k++ )
                {
                    createBlock(i, k);
                    _blockTop[i][k] = 0;
                }
            }
        }
        
        /**
         * ブロックを作成します.
         * 
         * @param x
         * @param y
         */
        private function createBlock(x:int, y:int, z:int = 0, tween:Boolean = false):void
        {
            var block:Block = new Block(x, y, z);
            block.addEventListener(MouseEvent.MOUSE_DOWN, onBlockMouseDown);
            block.buttonMode = true;
            _blockContainer.addMapChip(block, tween);
        }
        
        //--------------------------------------------------------------------------
        //
        // イベントハンドラー
        //
        //--------------------------------------------------------------------------
        
        /**
         * リサイズ時の処理.
         * 
         * @param    event
         */
        private function onResize(event:Event = null):void 
        {
            _blockContainer.x = stage.stageWidth / 2 - _blockContainer.width / 2;
            _blockContainer.y = stage.stageHeight - 150;
        }
        
        /**
         * ブロック上でマウスダウンした時の処理.
         * 
         * @param    event
         */
        private function onBlockMouseDown(event:MouseEvent):void 
        {
            var target:Block = event.target as Block;
            var xpos:int = target.localX;
            var ypos:int = target.localY;
            //target.removeEventListener(MouseEvent.MOUSE_DOWN, arguments.callee);
            //target.buttonMode = false;
            _blockTop[xpos][ypos] = _blockTop[xpos][ypos] + 1;
            createBlock(xpos, ypos, _blockTop[xpos][ypos], true);
        }
    }
    
}

//--------------------------------------------------------------------------

import flash.display.Graphics;
import flash.display.GraphicsPathCommand;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Dictionary;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.easing.Expo;
import org.libspark.betweenas3.easing.Quart;
import org.libspark.betweenas3.easing.Quint;
import org.libspark.betweenas3.events.TweenEvent;
import org.libspark.betweenas3.tweens.IObjectTween;
import org.libspark.betweenas3.tweens.ITween;
import org.libspark.betweenas3.tweens.ITweenGroup;

/**
 * MapChipContainer クラス
 */
class MapChipContainer extends Sprite
{
    //--------------------------------------------------------------------------
    //
    // プロパティ
    //
    //--------------------------------------------------------------------------
    
    private var _chips:Vector.<Block> = new Vector.<Block>();
    private var _tween:Dictionary = new Dictionary(true);
    
    //--------------------------------------------------------------------------
    //
    // メソッド
    //
    //--------------------------------------------------------------------------
    
    /**
     * 新しい MapChipContainer クラスのインスタンスを作成します.
     */
    public function MapChipContainer() 
    {
        super();
    }
    
    /**
     * 指定したマップチップを追加します.
     * 
     * @param    chip
     * @param    tween 値が真の場合はトゥイーンして表示します.
     */
    public function addMapChip(chip:Block, tween:Boolean = false):void
    {
        _chips.push(chip);
        addChild(chip);
        
        setChildIndex(chip, numChildren - 1);
        if (tween)
        {
            var t:IObjectTween = BetweenAS3.tween(chip, { y: chip.y + Block.TWEEN_DISTANCE }, null, 0.4, Quint.easeIn);
            _tween[chip] = t;
            trace(_tween[chip])
            t.onComplete = sort;
            t.play();
        }
        else
        {
            chip.y += Block.TWEEN_DISTANCE;
            sort();
        }
    }
    
    /**
     * マップチップを正しい表示順にソートします.
     */
    public function sort():void
    {
        _chips.sort(function(a:Block, b:Block):int {
            if (_tween[a] && _tween[a].isPlaying) return 1;
            if (a.localZ > b.localZ) return 1;
            if (a.localZ < b.localZ) return -1;
            if (a.y == b.y) return 0;
            if (a.y > b.y) return 1;
            return -1;
        })
        var n:int = numChildren;
        for (var i:int; i < n; i++ )
        {
            setChildIndex(_chips[i], i);
        }
    }
    
}

//--------------------------------------------------------------------------

/**
 * Block クラス
 */
class Block extends Sprite
{
    //--------------------------------------------------------------------------
    //
    // プロパティ
    //
    //--------------------------------------------------------------------------
    
    // 色を格納する Array
    public static const COLORS:Array = [0xB5CC7A, 0x728D6C, 0xEDC06B, 0xF48D3E, 0xFF614E, 0xBC554E, 0x47ACBC, 0x4773A4];
    
    // Tween の距離 値を大きくするほど上の方から落ちてきます。
    public static const TWEEN_DISTANCE:Number = 200;
    
    // 幅の初期値
    public static const DEFAULT_WIDTH:Number = 60;
    
    // 奥行きの初期値
    public static const DEFAULT_DEPTH:Number = 40;
    
    // 高さの初期値
    public static const DEFAULT_HEIGHT:Number = 13;
    
    // 幅
    private var _width:Number = DEFAULT_WIDTH;
    
    // 奥行き
    private var _depth:Number = DEFAULT_DEPTH;
    
    // 高さ
    private var _height:Number = DEFAULT_HEIGHT;
    
    // 面
    private var _faces:Vector.<Shape> = new Vector.<Shape>();
    
    // ローカル座標 X
    private var _localX:int;
    
    // ローカル座標 Y
    private var _localY:int;
    
    // ローカル座標 Z
    private var _localZ:int;
    
    //--------------------------------------------------------------------------
    //
    // メソッド
    //
    //--------------------------------------------------------------------------
    
    /**
     * 新しい Block インスタンスを作成します.
     */
    public function Block(x:int, y:int, z:int)
    {
        super();
        
        _localX = x;
        _localY = y;
        _localZ = z;
        move(_localX, _localY, _localZ);
        
        this.y -= TWEEN_DISTANCE;
        
        createFaces();
        drawFaces();
    }
    
    /**
     * オブジェクトを移動します.
     */
    public function move(x:int, y:int, z:int):void
    {
        var xpos:int = x * Block.DEFAULT_WIDTH / 2 + y * Block.DEFAULT_WIDTH / 2;
        var ypos:int = y * Block.DEFAULT_DEPTH / 2 + -x * Block.DEFAULT_DEPTH / 2 - z * Block.DEFAULT_HEIGHT;
        
        this.x = xpos;
        this.y = ypos;
    }
    
    /**
     * 各面を作成します.
     */
    private function createFaces():void
    {        
        // top
        var top:Shape = new Shape();
        addChild(top);
        _faces.push(top);
        
        // left
        var left:Shape = new Shape();
        addChild(left);
        _faces.push(left);
        
        // right
        var right:Shape = new Shape();
        addChild(right);
        _faces.push(right);
    }
    
    /**
     * 各面を描画します.
     */
    private function drawFaces():void 
    {
        var g:Graphics;
        var commands:Vector.<int>;
        var path:Vector.<Number>;
        
        // 色
        var rand:int = (Math.random() * (COLORS.length/2) >> 0) * 2;
        var color:uint = COLORS[rand];
        var darkColor:uint = COLORS[rand+1];
        
        // コマンド
        commands = Vector.<int>([GraphicsPathCommand.MOVE_TO,
                                 GraphicsPathCommand.LINE_TO,
                                 GraphicsPathCommand.LINE_TO,
                                 GraphicsPathCommand.LINE_TO,
                                 GraphicsPathCommand.LINE_TO]);
        
        //{{ top
        
        // パス
        path = Vector.<Number>([_width / 2, 0, // top
                                0, _depth / 2, // left
                                _width / 2, _depth, // bottom
                                _width, _depth / 2, // right
                                _width / 2, 0]); // top
        
        g = _faces[0].graphics;
        g.clear();
        g.beginFill(color);
        g.drawPath(commands, path);
        g.endFill();
        
        //}} end of top
        
        //{{ left
        
        // パス
        path = Vector.<Number>([0, _depth / 2,
                                0, _height + _depth / 2,
                                _width / 2, _height + _depth, // center
                                _width / 2, _depth,
                                0, _depth / 2]);
        
        g = _faces[1].graphics;
        g.clear();
        g.beginFill(darkColor);
        g.drawPath(commands, path);
        g.endFill();
        
        //}} end of left
        
        //{{ right
        
        // パス
        path = Vector.<Number>([_width, _depth / 2,
                                _width, _height + _depth / 2,
                                _width / 2, _height + _depth,
                                _width / 2, _depth,
                                _width, _depth / 2]);
        
        g = _faces[2].graphics;
        g.clear();
        g.beginFill(darkColor);
        g.drawPath(commands, path);
        g.endFill();
        
        //}} end of right
    }
    
    //--------------------------------------------------------------------------
    // 
    // Getter / Setter
    //
    //--------------------------------------------------------------------------
    
    // width
    
    override public function get width():Number 
    {
        return _width;
    }
    
    override public function set width(value:Number):void 
    {
        _width = value;
        dispatchEvent(new Event(Event.RESIZE));
    }
    
    // height
    
    override public function get height():Number 
    {
        return _height;
    }
    
    override public function set height(value:Number):void 
    {
        _height = value;
        dispatchEvent(new Event(Event.RESIZE));
    }
    
    // faces
    
    public function get faces():Vector.<Shape> 
    {
        return _faces;
    }
    
    // localX
    
    public function get localX():int 
    {
        return _localX;
    }
    
    public function set localX(value:int):void 
    {
        _localX = value;
        move(_localX, _localY, _localZ);
    }
    
    // localY
    
    public function get localY():int 
    {
        return _localY;
    }
    
    public function set localY(value:int):void 
    {
        _localY = value;
        move(_localX, _localY, _localZ);
    }
    
    // localY
    
    public function get localZ():int 
    {
        return _localZ;
    }
    
    public function set localZ(value:int):void 
    {
        _localZ = value;
        move(_localX, _localY, _localZ);
    }
}

//--------------------------------------------------------------------------