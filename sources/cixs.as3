/**
 * フルスクリーン再生のビロビロ具合も是非お楽しみください。
 */
package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import com.flashdynamix.utils.SWFProfiler;
    
    [SWF(width = 465, height = 465, backgroundColor = 0x0, frameRate = 60)]
    
    public class Main extends Sprite
    {
        //----------------------------------------
        //CLASS CONSTANTS
        
        private const W:uint = 465;
        private const H:uint = 465;
        
        private const DIVIDE_X:uint = 40;
        private const DIVIDE_Y:uint = 40;
        
        private const SPRING:Number   = 0.3;
        private const FRICTION:Number = 0.9;
        
        //----------------------------------------
        //VARIABLES
        
        //nodes[idy][idx]
        private var _nodes:Vector.<Vector.<Node>>;
        
        //head node of linked list
        private var _first:Node;
        
        //drawing canvas
        private var _canvas:Sprite;
        
        //background
        private var _background:BitmapData;
        
        private var _isOnStage:Boolean;
        
        //----------------------------------------
        //METHODS
        
        public function Main():void
        {
            Wonderfl.disable_capture();
            //Wonderfl.capture_delay(10);
            
            addEventListener(Event.ADDED_TO_STAGE, _initialize);
        }
        
        /**
         * entry point
         */
        private function _initialize(e:Event):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, _initialize);
            
            SWFProfiler.init(this);
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality   = StageQuality.LOW;
            
            var i:uint, j:uint, node:Node, old:Node;
            var nx:uint = DIVIDE_X + 1;
            var ny:uint = DIVIDE_Y + 1;
            
            _isOnStage = false;
            
            //背景カラー
            _background = new BitmapData(W, H, false, 0x0);
            addChild(new Bitmap(_background));
            
            //ドロー用
            _canvas = addChild(new Sprite()) as Sprite;
            
            //ネットワーク生成
            _nodes = new Vector.<Vector.<Node>>(ny);
            for (i = 0; i < ny; ++i) 
            {
                _nodes[i] = new Vector.<Node>(ny);
                for (j = 0; j < ny; ++j) 
                {
                    _nodes[i][j] = node = new Node();
                    node.ox = node.x = j * W / DIVIDE_X;
                    node.oy = node.y = i * H / DIVIDE_Y;
                }
            }
            
            var bounds:Vector.<Boolean> = new Vector.<Boolean>(4);
            
            //コネクション生成
            for (i = 0; i < ny; ++i) 
            {
                for (j = 0; j < nx; ++j) 
                {
                    node = _nodes[i][j];
                    
                    //隣接ノード
                    bounds[0] = (i == 0     ) ? true : false;
                    bounds[1] = (j == nx - 1) ? true : false;
                    bounds[2] = (i == ny - 1) ? true : false;
                    bounds[3] = (j == 0     ) ? true : false;
                    
                    node.nn[0] = (bounds[0]             ) ? null : _nodes[i - 1][j    ]; //top    - center
                    node.nn[1] = (bounds[0] || bounds[1]) ? null : _nodes[i - 1][j + 1]; //top    - right
                    node.nn[2] = (bounds[1]             ) ? null : _nodes[i    ][j + 1]; //middle - right
                    node.nn[3] = (bounds[1] || bounds[2]) ? null : _nodes[i + 1][j + 1]; //bottom - right
                    node.nn[4] = (bounds[2]             ) ? null : _nodes[i + 1][j    ]; //bottom - center
                    node.nn[5] = (bounds[2] || bounds[3]) ? null : _nodes[i + 1][j - 1]; //bottom - left
                    node.nn[6] = (bounds[3]             ) ? null : _nodes[i    ][j - 1]; //middle - left
                    node.nn[7] = (bounds[3] || bounds[0]) ? null : _nodes[i - 1][j - 1]; //top    - left
                    
                    //リンクリスト
                    if (_first == null)
                    {
                        old = _first = node;
                    }
                    else
                    {
                        old.next = node;
                        old = node;
                    }
                }
            }
            
            addEventListener(Event.ENTER_FRAME, _updateHandler);
            
            stage.addEventListener(MouseEvent.MOUSE_OVER, _stageMouseOverHandler);
            stage.addEventListener(Event.MOUSE_LEAVE, _stageMouseLeaveHandler);
        }
        
        /**
         * アップデート
         */
        private function _updateHandler(e:Event):void
        {
            _interaction();
            _draw();
        }
        
        /**
         * マウスインタラクションの反映
         */
        private function _interaction():void
        {
            var tx:Number, ty:Number, dx:Number, dy:Number, dist:Number,
                spring:Number   = SPRING,
                friction:Number = FRICTION,
                node:Node       = _first;
            
            do {
                if (_isOnStage)
                {
                    dx = node.ox - mouseX;
                    dy = node.oy - mouseY;
                    
                    dist = Math.sqrt(dx * dx + dy * dy) + 1;
                    
                    tx = node.ox + dx / dist * 100;
                    ty = node.oy + dy / dist * 100;
                }
                else
                {
                    tx = node.ox;
                    ty = node.oy;
                }
                node.vx += (tx - node.x) * spring;
                node.vy += (ty - node.y) * spring;
                node.x  += node.vx *= friction;
                node.y  += node.vy *= friction;
            }
            while (node = node.next);
        }
        
        /**
         * 描画
         */
        private function _draw():void
        {
            var n1:Node, n2:Node, n3:Node, n4:Node,
                px:Number, py:Number,
                g:Graphics = _canvas.graphics;
            
            g.clear();
            g.lineStyle(1, 0xffffff);
            
            var node:Node = _first;
            do {
                px = node.x;
                py = node.y;
                
                if ((n1 = node.nn[1]))
                {
                    g.moveTo(px, py);
                    g.lineTo(n1.x, n1.y);
                }
                if ((n2 = node.nn[2]))
                {
                    g.moveTo(px, py);
                    g.lineTo(n2.x, n2.y);
                }
                if ((n3 = node.nn[3]))
                {
                    g.moveTo(px, py);
                    g.lineTo(n3.x, n3.y);
                }
                if ((n4 = node.nn[4]))
                {
                    g.moveTo(px, py);
                    g.lineTo(n4.x, n4.y);
                }
            }
            while (node = node.next);
        }
        
        /**
         * マウスがステージ内へ入ったとき
         */
        private function _stageMouseOverHandler(e:MouseEvent):void 
        {
            _isOnStage = true;
        }
        
        /**
         * マウスがステージ外へ出たとき
         */
        private function _stageMouseLeaveHandler(e:Event):void 
        {
            _isOnStage = false;
        }
    }
}

internal class Node
{
    //----------------------------------------
    //VARIABLES
    
    public var vx:Number;
    public var vy:Number;
    
    public var x:Number;
    public var y:Number;
    
    public var ox:Number;
    public var oy:Number;
    
    public var nn:Vector.<Node>;
    
    public var next:Node;
    
    //----------------------------------------
    //METHODS
    
    public function Node():void
    {
        vx = vy = x = y = ox = oy = 0;
        nn = new Vector.<Node>(8);
    }
}