// ---------------------------
// drag to rip.
// hit any key to clear.
// ---------------------------
package
{
    import com.bit101.components.PushButton;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    import flash.geom.Point;
    import flash.net.FileReference;
    import flash.net.URLRequest;
    
    import flash.system.LoaderContext;
    public class MousatsuMethod extends Sprite
    {
        private static const UPPER_IMAGE_URL:String = "http://assets.wonderfl.net/images/related_images/2/20/203a/203a24ce61d8d1aafaec34f81e4877082a333140";
        private static const LOWER_IMAGE_URL:String = "http://assets.wonderfl.net/images/related_images/c/c0/c00c/c00c78ed8353dfc87c586a0ffd95950be66a6302";
        
        private var _upperImage:Loader;
        private var _lowerImage:Loader;
        private var _edge:Shape;
        private var _mask:Shape;
        private var _shadow:Shape;
        
        public function MousatsuMethod() {
            init();
            loadImages();
        }
        
        // ----------------------------------------
        //  初期処理
        // ----------------------------------------
        private function init():void {
            stage.frameRate = 60;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP;
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            
            _upperImage = new Loader();
            _lowerImage = new Loader();
            _edge = new Shape();
            _mask = new Shape();
            _shadow = new Shape();
            
            _edge.cacheAsBitmap = true;
            _mask.cacheAsBitmap = true;
            _shadow.cacheAsBitmap = true;
            
            _shadow.filters = [new DropShadowFilter(0, 0, 0, 1.0, 8, 8, 1.2, 3, true, false, true)];
            _lowerImage.mask = _mask;
            
            addChild(_upperImage);
            addChild(_edge);
            addChild(_lowerImage);
            addChild(_shadow);
            addChild(_mask);
            
            new PushButton(this, 0, 0, "upper layer", onButtonPush);
            new PushButton(this, 100, 0, "lower layer", onButtonPush);
            
            this.buttonMode = true;
        }
        
        private function loadImages():void {
            _upperImage.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadComplete);
            _lowerImage.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadComplete);
            _upperImage.load(new URLRequest(UPPER_IMAGE_URL), new LoaderContext(true));
            _lowerImage.load(new URLRequest(LOWER_IMAGE_URL), new LoaderContext(true));
        }
        
        private var _loadcount:uint = 0;
        private function onImageLoadComplete(evt:Event):void {
            _loadcount++;
            if (_loadcount == 2) {
                _upperImage.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageLoadComplete);
                _lowerImage.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageLoadComplete);
                start();
            }
        }
        
        private function start():void {
            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
        }
        
        // ----------------------------------------
        //  メイン
        // ----------------------------------------    
        private var _isPressed:Boolean = false; // マウスのボタンが押されているかどうか
        private var _prevX:Number;  // 前回描画時のマウスのX座標値
        private var _prevY:Number;  //                Y座標値
        private var _prevMaskVertex1:Point;  // 前回描画したマスク領域の頂点1
        private var _prevMaskVertex2:Point;  // 前回描画したマスク領域の頂点2
        private var _prevEdgeVertex1:Point; // 前回描画した白い部分の頂点１
        private var _prevEdgeVertex2:Point; // 前回描画した白い部分の頂点2
        
        private function onMouseDown(evt:MouseEvent):void {
            _isPressed = true;
            _prevX = evt.localX;
            _prevY = evt.localY;
            _prevMaskVertex1 = new Point(_prevX, _prevY);
            _prevMaskVertex2 = new Point(_prevX, _prevY);
            _prevEdgeVertex1 = new Point(_prevX, _prevY);
            _prevEdgeVertex2 = new Point(_prevX, _prevY);
        }
        
        private function onMouseMove(evt:MouseEvent):void {
            if (_isPressed) {
                var currX:Number = evt.localX;
                var currY:Number = evt.localY;
                
                // マウスポインタの移動量を計算
                var dx:Number = currX - _prevX;
                var dy:Number = currY - _prevY;
                var d:Number = Math.sqrt(dx * dx + dy * dy);
                
                // 移動量が小さい場合は終了
                if (d < 5) {
                    return
                }
                
                // マウスポインタの移動方向
                var t:Number = Math.atan(dy / dx);
                
                // 移動量から今回描画する領域の幅と頂点を計算
                var w:Number = d + Math.random()*10;
                var currMaskVertex1:Point = new Point(
                    w * Math.cos(Math.PI / 2 + t) + currX,
                    w * Math.sin(Math.PI / 2 + t) + currY);
                var currMaskVertex2:Point = new Point(
                    w * Math.cos(3 * Math.PI / 2 + t) + currX,
                    w * Math.sin(3 * Math.PI / 2 + t) + currY);
                
                // 白い部分の領域の幅と頂点を計算
                var ww:Number = w * 1.15 + 1;
                var currEdgeVertex1:Point = new Point(
                    ww * Math.cos(Math.PI / 2 + t) + currX,
                    ww * Math.sin(Math.PI / 2 + t) + currY);
                var currEdgeVertex2:Point = new Point(
                    ww * Math.cos(3 * Math.PI / 2 + t) + currX,
                    ww * Math.sin(3 * Math.PI / 2 + t) + currY);
                
                if (dx < 0) { // swap
                    var tmp:Point = currMaskVertex1;
                    currMaskVertex1 = currMaskVertex2;
                    currMaskVertex2 = tmp;
                    
                    tmp = currEdgeVertex1;
                    currEdgeVertex1 = currEdgeVertex2;
                    currEdgeVertex2 = tmp;
                }
                
                // 頂点データを作成
                var points1:Vector.<Point> = createPointData(_prevMaskVertex1, currMaskVertex1, Math.floor(d), t);
                var points2:Vector.<Point> = createPointData(_prevMaskVertex2, currMaskVertex2, Math.floor(d), t);
                var points3:Vector.<Point> = createPointData(_prevEdgeVertex1, currEdgeVertex1, Math.floor(d), t);
                var points4:Vector.<Point> = createPointData(_prevEdgeVertex2, currEdgeVertex2, Math.floor(d), t);
                
                var endPoint:Point = new Point(currX + dx, currY + dy);
                points1.push(endPoint);
                points2.push(endPoint);
                points3.push(endPoint);
                points4.push(endPoint);
                
                // 描画
                draw(_mask, points1, points2);
                draw(_shadow, points1, points2);
                draw(_edge, points3, points4);
                
                // マウスの位置と頂点を保存
                _prevX = currX;
                _prevY = currY;
                _prevMaskVertex1 = currMaskVertex1;
                _prevMaskVertex2 = currMaskVertex2;
                _prevEdgeVertex1 = currEdgeVertex1;
                _prevEdgeVertex2 = currEdgeVertex2;
            }
        }
        
        private function createPointData(start:Point, end:Point, d:int, t:Number):Vector.<Point> {
            var points:Vector.<Point> = new Vector.<Point>();
            var cosT:Number = Math.cos(t);
            var sinT:Number = Math.sin(t);
            
            // startとendを結ぶ直線の方程式 y = ax + b を計算
            var a:Number = (start.y - end.y) / (start.x - end.x);
            var b:Number = start.y - a * start.x;
            
            points.push(new Point(start.x, start.y));
            for (var i:uint = 1; i < d; i++) {
                var xx:Number = start.x + i/d * (end.x - start.x);
                var yy:Number = a * xx + b;
                
                xx += Math.random() * 3 * sinT;
                yy += Math.random() * 3 * cosT;
                
                points.push(new Point(xx, yy));
            }
            points.push(new Point(end.x, end.y));
            
            return points
        }
        
        private function draw(target:Shape, 
                              points1:Vector.<Point>, 
                              points2:Vector.<Point>, 
                              color:uint=0xFFFFFF):void {
            var j:int;
            var k:int;
            
            with (target.graphics) {
                beginFill(color);
                moveTo(points1[0].x, points1[0].y);
                for (j=1; j < points1.length; j++) {
                    lineTo(points1[j].x, points1[j].y);
                }
                for (k=points2.length-1; k >= 0; k--) {
                    lineTo(points2[k].x, points2[k].y);
                }
                moveTo(points2[0].x, points2[0].y);
                endFill();
            }
        }
        
        private function onMouseUp(evt:MouseEvent):void {
            _isPressed = false;
        }
        
        private function onMouseOut(evt:MouseEvent):void {
            onMouseUp(evt);
        }
        
        private function onKeyDown(evt:KeyboardEvent):void {
            _edge.graphics.clear();
            _mask.graphics.clear();
            _shadow.graphics.clear();
        }
        
        // ----------------------------------------
        //  画像変更関連
        // ----------------------------------------    
        private var fileRef1:FileReference;
        private var fileRef2:FileReference;
        private function onButtonPush(evt:Event):void {
            if (PushButton(evt.target).label == "upper layer" ) {
                fileRef1 = new FileReference();
                fileRef1.browse();
                fileRef1.addEventListener(Event.SELECT, onSelect);
            } else {
                fileRef2 = new FileReference();
                fileRef2.browse();
                fileRef2.addEventListener(Event.SELECT, onSelect);
            }
        }
        
        private function onSelect(evt:Event):void {
            FileReference(evt.target).addEventListener(Event.COMPLETE, onComplete);
            FileReference(evt.target).load();
        }
        
        private function onComplete(evt:Event):void {
            if (evt.target == fileRef1) {
                _upperImage.loadBytes(fileRef1.data);
            } else {
                _lowerImage.loadBytes(fileRef2.data);
            }
        }
    }
}