/**
 * 3次ベジェ曲線を使って直線を補間するとき、
 * 3点をつなぐ3次ベジェ曲線同士が上手く繋がるようにコントロールポイントを
 * 設定するアルゴリズムを実装してみた。
 * （なまめかしい動きをさせてみた）
 * 
 * Spaceキーでデバッグモードに切り替えると
 * アンカーポイントがドラッグ可能なデバッグモードに切り替わるので、
 * ドラッグするとコントロールポイントが良い感じに勝手に動くのが分かりますよ。
 * 日本語入力だったりswfにフォーカスが当たってないと反応しないよ
 * 
 * スプライン曲線と比べたときの利点としては、
 * 移動したアンカーポイントから2個以上離れたアンカーポイントの描く曲線に
 * 影響を与えないので(スプライン曲線は遠くまで振動する)、
 * うまく曲線情報をキャッシュしていけば
 * 複雑な曲線描画を低負荷に抑えられる、、、かも知れません。
 * 
 * ネタ元は以下のアルゴリズム
 * Anti-Grain Geometry - Interpolation with Bezier Curves
 * http://www.antigrain.com/research/bezier_interpolation/index.html
 * 
 * 思いつくままに書いた超ロングソースなのはご愛敬。
 * 
 * @author alumican.net<Yukiya Okuda>
 */
package
{
    import com.flashdynamix.utils.SWFProfiler;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filters.BevelFilter;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    
    public class FlashTest extends Sprite
    {
        //----------------------------------------
        //今回のキモ
        
        /**
         * 3点を3次ベジェ曲線で滑らかにつなぐためのコントロールポイントを取得する
         * @param    p0    前の点
         * @param    p1    注目点
         * @param    p2    次の点
         * @param    k    係数
         * @return    p1のコントロールポイントを格納した配列[p0側, p2側]
         */
        private function _getAGGControlPoints(p0:Point, p1:Point, p2:Point, k:Number = 0.6667):Array
        {
            var d0x:Number = p0.x - p1.x;
            var d0y:Number = p0.y - p1.y;
            
            var d2x:Number = p2.x - p1.x;
            var d2y:Number = p2.y - p1.y;
            
            var l0:Number = Math.sqrt(d0x * d0x + d0y * d0y);
            var l2:Number = Math.sqrt(d2x * d2x + d2y * d2y);
            
            var a0:Number = k * l0 / (l0 + l2);
            var a2:Number = k * l2 / (l0 + l2);
            
            var bx:Number = (p0.x - p2.x) / 2;
            var by:Number = (p0.y - p2.y) / 2;
            
            return [
                new Point(p1.x + a0 * bx, p1.y + a0 * by),
                new Point(p1.x - a2 * bx, p1.y - a2 * by)
            ];
        }
        
        
        
        
        
        //----------------------------------------
        //3次のベジェを描くために使う関数色々
        
        /**
         * 2点間をつなぐ3次ベジェ曲線線上の1点を取得
         * @param    p0    始点
         * @param    p1    制御点1
         * @param    p2    制御点2
         * @param    p3    終点
         * @param    t    始点からの比率(0, 1)
         * @return    tにおけるベジェ3次ベジェ曲線上の点
         */
        private function _getCubicBezierPoint(p0:Point, p1:Point, p2:Point, p3:Point, t:Number):Point
        {
            var u:Number = 1 - t;
            
            var a0:Number = u * u * u;
            var a1:Number = 3 * t * u * u;
            var a2:Number = 3 * t * t * u;
            var a3:Number = t * t * t;
            
            return new Point(
                a0 * p0.x + a1 * p1.x + a2 * p2.x + a3 * p3.x,
                a0 * p0.y + a1 * p1.y + a2 * p2.y + a3 * p3.y
            );
        }
        
        /**
         * 2点間をつなぐ3次ベジェ曲線上の点をまとめて取得
         * @param    p0    始点
         * @param    p1    制御点1
         * @param    p2    制御点2
         * @param    p3    終点
         * @param    seg    分割数
         * @return    p0からp3における3次ベジェ曲線上の点を格納した配列
         */
        private function _getCubicBezierPoints(p0:Point, p1:Point, p2:Point, p3:Point, seg:uint = 10):Array
        {
            var f:Function = _getCubicBezierPoint;
            
            var o:Array = [p0];
            var dt:Number = 1 / seg;
            for (var t:Number = dt; t < 1; t += dt) 
            {
                o.push( f(p0, p1, p2, p3, t) );
            }
            o.push(p3);
            
            return o;
        }
        
        
        
        
        
        //----------------------------------------
        //VARIABLES
        
        private var _anchors:Array;
        
        private var _canvas0:Sprite;
        private var _canvas1:Sprite;
        private var _canvas2:Sprite;
        
        private var _ox:Number;
        private var _oy:Number;
        
        private var _debugMode:Boolean;
        
        private var _bmd:BitmapData;
        
        
        
        
        
        //----------------------------------------
        //METHODS
        
        /**
         * Constructor.
         */
        public function FlashTest():void 
        {
            //Wonderfl.capture_delay( 10 );
            Wonderfl.disable_capture();
            
            stage.frameRate = 60;
            
            var sw:uint = stage.stageWidth;
            var sh:uint = stage.stageHeight;
            
            _bmd = new BitmapData(sw, sh, false, 0x0);
            addChild(new Bitmap(_bmd));
            
            _canvas0 = addChild(new Sprite()) as Sprite; //直線
            _canvas1 = addChild(new Sprite()) as Sprite; //曲線
            _canvas2 = addChild(new Sprite()) as Sprite; //コントロールポイント
            
            var i:uint = 0;
            var n:uint = 10;
            _anchors = new Array(n);
            
            for (i = 0; i < n; ++i) 
            {
                var anchor:Anchor = new Anchor();
                
                var angle:Number = i / n * Math.PI * 2;
                anchor.x = anchor.initX = 200 * Math.cos(angle) + sw / 2;
                anchor.y = anchor.initY = 200 * Math.sin(angle) + sh / 2;
                
                _canvas2.addChild(anchor);
                
                _anchors[i] = anchor;
            }
            
            _ox = mouseX;
            _oy = mouseY;
            
            _debugMode = false;
            _canvas0.visible = false;
            _canvas2.visible = false;
            
            _canvas1.filters = [new BevelFilter(2)];
            
            addEventListener(Event.ENTER_FRAME, _update);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyDownHandler);
            
            //プロファイラの表示
            SWFProfiler.init(this);
        }
        
        /**
         * 毎フレーム実行
         */
        private function _update(e:Event):void
        {
            
            var i:uint, p0:Point, p1:Point, p2:Point, p3:Point, anchor:Anchor;
            var n:uint = _anchors.length;
            var g0:Graphics = _canvas0.graphics;
            var g1:Graphics = _canvas1.graphics;
            var g2:Graphics = _canvas2.graphics;
            g0.clear();
            g1.clear();
            g2.clear();
            
            _moveAnchor();
            
            //draw straight lines
            g0.lineStyle(1, 0x555555, 1);
            g0.moveTo(_anchors[0].x, _anchors[0].y);
            for (i = 1; i < n; ++i) 
            {
                anchor = _anchors[i];
                g0.lineTo(anchor.x, anchor.y);
            }
            g0.lineTo(_anchors[0].x, _anchors[0].y);
            
            //draw control point
            var ca:Array, c0:Point, c1:Point;
            for (i = 0; i < n; ++i) 
            {
                anchor = _anchors[i];
                
                p0 = (i > 0    ) ? _anchors[i - 1].p : _anchors[n - 1].p;
                p1 = anchor.p;
                p2 = (i < n - 1) ? _anchors[i + 1].p : _anchors[0    ].p;
                
                ca = _getAGGControlPoints(p0, p1, p2);
                
                anchor.c1 = c0 = ca[0];
                anchor.c0 = c1 = ca[1];
                
                g2.lineStyle(0, 0x000000, 0);
                g2.beginFill(0x7FE57F);
                g2.drawCircle(c0.x, c0.y, 2);
                g2.drawCircle(c1.x, c1.y, 2);
                g2.endFill();
                
                g2.lineStyle(0, 0x7FE57F, 1);
                g2.beginFill(0x000000, 0);
                g2.moveTo(c0.x, c0.y);
                g2.lineTo(c1.x, c1.y);
                g2.endFill();
            }
            
            //draw curved line
            var seg:uint = 10;
            var cx:Number, cy:Number;
            var pa:Array = new Array();
            for (i = 0; i < n; ++i) 
            {
                anchor = _anchors[i];
                
                p0 = anchor.p;
                p1 = anchor.c0;
                p2 = (i < n - 1) ? _anchors[i + 1].c1 : _anchors[0].c1;
                p3 = (i < n - 1) ? _anchors[i + 1].p  : _anchors[0].p;
                
                pa = pa.concat( _getCubicBezierPoints(p0, p1, p2, p3, seg) );
            }
            
            g1.lineStyle(5, 0xFE5487, 1);
            g1.moveTo(pa[0].x, pa[0].y);
            n = pa.length;
            for (i = 0; i < n; i += 2) 
            {
                p0 = pa[i];
                p1 = (i < n - 1) ? pa[i + 1] : pa[0];
                p2 = (i < n - 2) ? pa[i + 2] : 
                     (i < n - 1) ? pa[0]     : pa[1];
                
                cx = 2 * p1.x - (p0.x + p2.x) * 0.5;
                cy = 2 * p1.y - (p0.y + p2.y) * 0.5;
                
                g1.curveTo(cx, cy, p2.x, p2.y);
            }
            g1.endFill();
            
            _bmd.colorTransform(_bmd.rect, new ColorTransform(0.99, 0.99, 0.99));
            _bmd.applyFilter(_bmd, _bmd.rect, new Point(), new BlurFilter(2, 2));
            
            if (!_debugMode) _bmd.draw(_canvas1);
        }
        
        /**
         * マウスインタラクション
         */
        private function _moveAnchor():void
        {
            var sw:Number = stage.stageWidth;
            var sh:Number = stage.stageHeight;
            
            var anchor:Anchor;
            var n:uint = _anchors.length;
            for (var i:uint = 0; i < n; ++i) 
            {
                anchor = _anchors[i];
                
                if (anchor.isDragging)
                {
                    anchor.ox = anchor.x;
                    anchor.oy = anchor.y;
                    continue;
                }
                
                var dx:Number = mouseX - _ox;
                var dy:Number = mouseY - _oy;
                
                var dax:Number = anchor.x - mouseX;
                var day:Number = anchor.y - mouseY;
                
                if (!_debugMode)
                {
                    //慣性
                    var dist:Number = Math.sqrt(dax * dax + day * day);
                    if (dist < 100)
                    {
                        anchor.vx += dx * 0.05 * (100 - dist) / 100;
                        anchor.vy += dy * 0.05 * (100 - dist) / 100;
                    }
                    anchor.x += anchor.vx;
                    anchor.y += anchor.vy;
                    anchor.vx *= 0.99;
                    anchor.vy *= 0.99;
                    
                    //壁反射
                    if (anchor.x < 0 ) { anchor.x = 0;  anchor.vx *= -1 };
                    if (anchor.x > sw) { anchor.x = sw; anchor.vx *= -1 };
                    if (anchor.y < 0 ) { anchor.y = 0;  anchor.vy *= -1 };
                    if (anchor.y > sh) { anchor.y = sh; anchor.vy *= -1 };
                    
                    //元の位置へ
                    anchor.x += (anchor.initX - anchor.x) * 0.01;
                    anchor.y += (anchor.initY - anchor.y) * 0.01;
                    
                    //前後に引っ張られる
                    //var prev:Anchor = (i > 0    ) ? _anchors[i - 1] : _anchors[n - 1];
                    //var next:Anchor = (i < n - 1) ? _anchors[i + 1] : _anchors[0    ];
                    //anchor.x += ((prev.x + next.x) / 2 - anchor.x) * 0.01;
                    //anchor.y += ((prev.y + next.y) / 2 - anchor.y) * 0.01;
                }
            }
            
            _ox = mouseX;
            _oy = mouseY;
        }
        
        /**
         * デバッグ表示切替
         */
        private function _keyDownHandler(e:KeyboardEvent):void 
        {
            if (e.keyCode == 32) _debugMode = !_debugMode;
            
            _canvas0.visible = _debugMode;
            _canvas2.visible = _debugMode;
        }
    }
}

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

/**
 * アンカーポイント
 */
internal class Anchor extends Sprite
{
    public function get p():Point { return _p; }
    private var _p:Point;
    
    public var c0:Point;
    public var c1:Point;
    
    public var vx:Number;
    public var vy:Number;
    
    public var ox:Number;
    public var oy:Number;
    
    public var initX:Number;
    public var initY:Number;
    
    public function get isDragging():Boolean { return _isDragging; }
    private var _isDragging:Boolean;
    
    override public function get x():Number { return super.x; }
    override public function set x(value:Number):void { _p.x = super.x = value; }
    
    override public function get y():Number { return super.y; }
    override public function set y(value:Number):void { _p.y = super.y = value; }
    
    /**
     * Constructor.
     */
    public function Anchor():void
    {
        //draw shape
        var g:Graphics = graphics;
        g.lineStyle(1, 0x7FE57F, 1);
        g.beginFill(0x000000, 0);
        g.drawRect(-2, -2 , 5, 5);
        g.endFill();
        
        g.lineStyle(0, 0x000000, 0);
        g.beginFill(0x000000, 0);
        g.drawCircle(0, 0, 10);
        g.endFill();
        
        _p = new Point();
        
        vx = 0;
        vy = 0;
        
        _isDragging = false;
        
        addEventListener(Event.ADDED_TO_STAGE, _addedToStageHandler);
    }
    
    private function _addedToStageHandler(e:Event):void 
    {
        addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler);
        buttonMode = true;
    }
    
    /**
     * ドラッグ開始
     */
    private function _mouseDownHandler(e:MouseEvent):void 
    {
        stage.addEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveHandler);
        stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler);
        removeEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler);
        
        _isDragging = true;
    }
    
    /**
     * ドラッグ中
     */
    private function _mouseMoveHandler(e:MouseEvent):void 
    {
        x = parent.mouseX;
        y = parent.mouseY;
    }
    
    /**
     * ドラッグ終了
     */
    private function _mouseUpHandler(e:MouseEvent):void 
    {
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveHandler);
        stage.removeEventListener(MouseEvent.MOUSE_UP, _mouseUpHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, _mouseDownHandler);
        
        vx = x - ox;
        vy = y - oy;
        
        _isDragging = false;
    }
}
