//-----------------------------------------------
// Collision Performance Test
// - [RECTANGLE] Rectangle.intersects
// - [MY RECT] calc orijinal
// - [HITTEST] Sprite.hitTestObject
// 
// 衝突判定のパフォーマンステスト
// Rectangleにinstersectsという便利メソッドがあるけど
// めっちゃ遅いことが分かった。自力計算するほうが良さそう。
//
// 結果としてはこんな感じ
// 自力計算 >>> Rectangle.intersects > Sprite.hitTestObject
//-----------------------------------------------
package {
    import com.bit101.components.PushButton;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import net.hires.debug.Stats;
    
    [SWF(frameRate=60, width=465, height=465)]
    /**
     * Collision Performance Test
     * @author yasu
     */
    public class Main extends Sprite {
        private static const COLOR_TRANS:ColorTransform = new ColorTransform(0.6, 0.6, 0.6, 1);
        private static const MAX:int = 400;
        private static const RECT_WH:int = 10;
        private static const STAGE_H:int = 465;
        private static const STAGE_W:int = 465;
        
        public function Main() {
            bmd = new BitmapData(STAGE_W, STAGE_H, false, 0xFF000000);
            addChild(new Bitmap(bmd));
            btnA = new PushButton(this, 80, STAGE_H - 50, "RECTANGLE", _onClick);
            btnB = new PushButton(this, 200, STAGE_H - 50, "MY RECT", _onClick);
            btnC = new PushButton(this, 320, STAGE_H - 50, "HITTEST", _onClick);
            addChild(new Stats);
        }
        private var MAX_SPEED:int = 20;
        private const RECT_BMD:BitmapData = new BitmapData(RECT_WH, RECT_WH, false, 0x666666);
        private const RECT_HIT_BMD:BitmapData = new BitmapData(RECT_WH, RECT_WH, false, 0x990000);
        private var bmd:BitmapData;
        private var btnA:PushButton;
        private var btnB:PushButton;
        private var btnC:*;
        private var myrects:Vector.<ObjMyRect>;
        private var objs:Array = [];
        private var rectangles:Vector.<ObjRectangle>;
        private var sprites:Vector.<ObjSprite>;
        
        private function _initMyRects():void {
            myrects = new Vector.<ObjMyRect>(MAX, true);
            for (var i:int = 0; i < MAX; i++) {
                myrects[ i ] = new ObjMyRect();
                var size:int = Math.random() * RECT_WH >> 0
                myrects[ i ].rect = new MyRect(Math.random() * STAGE_W >> 0, Math.random() * STAGE_H >> 0, size, size)
                myrects[ i ].vx = (Math.random() - 0.5) * MAX_SPEED >> 0;
                myrects[ i ].vy = (Math.random() - 0.5) * MAX_SPEED >> 0;
            }
        }
        
        private function _initRectangle():void {
            rectangles = new Vector.<ObjRectangle>(MAX, true);
            for (var i:int = 0; i < MAX; i++) {
                rectangles[ i ] = new ObjRectangle();
                var size:int = Math.random() * RECT_WH >> 0
                rectangles[ i ].rect = new Rectangle(Math.random() * STAGE_W >> 0, Math.random() * STAGE_H >> 0, size, size)
                rectangles[ i ].vx = (Math.random() - 0.5) * MAX_SPEED >> 0;
                rectangles[ i ].vy = (Math.random() - 0.5) * MAX_SPEED >> 0;
            }
        }
        
        private function _initSprites():void {
            sprites = new Vector.<ObjSprite>(MAX, true);
            for (var i:int = 0; i < MAX; i++) {
                sprites[ i ] = new ObjSprite();
                addChildAt(sprites[ i ], 1);
                var size:int = Math.random() * RECT_WH >> 0
                sprites[ i ].width = sprites[ i ].height = size;
                sprites[ i ].x = Math.random() * STAGE_W >> 0;
                sprites[ i ].y = Math.random() * STAGE_H >> 0;
                sprites[ i ].vx = (Math.random() - 0.5) * MAX_SPEED >> 0;
                sprites[ i ].vy = (Math.random() - 0.5) * MAX_SPEED >> 0;
            }
        }
        
        private function _onClick(e:Event):void {
            removeEventListener(Event.ENTER_FRAME, onEnterFrameA);
            removeEventListener(Event.ENTER_FRAME, onEnterFrameB);
            removeEventListener(Event.ENTER_FRAME, onEnterFrameC);
            rectangles = null;
            myrects = null;
            if (sprites) {
                for (var i:int = 0; i < sprites.length; i++) {
                    removeChild(sprites[ i ]);
                }
            }
            sprites = null;
            bmd.fillRect(bmd.rect, 0x0);
            switch (e.currentTarget) {
                case btnA:
                    _initRectangle();
                    addEventListener(Event.ENTER_FRAME, onEnterFrameA);
                    break;
                case btnB:
                    _initMyRects();
                    addEventListener(Event.ENTER_FRAME, onEnterFrameB);
                    break;
                case btnC:
                    _initSprites();
                    addEventListener(Event.ENTER_FRAME, onEnterFrameC);
                    break;
            }
        }
        
        private function onEnterFrameA(event:Event):void {
            var i:int, j:int;
            var elementA:ObjRectangle;
            var elementB:ObjRectangle;
            for (i = 0; i < rectangles.length; i++) {
                elementA = rectangles[ i ] as ObjRectangle;
                elementA.rect.x += elementA.vx;
                elementA.rect.y += elementA.vy;
                if (elementA.rect.x < 0 || elementA.rect.x > STAGE_W)
                    elementA.vx *= -1;
                if (elementA.rect.y < 0 || elementA.rect.y > STAGE_H)
                    elementA.vy *= -1;
                elementA.isHit = false;
            }
            for (i = 0; i < rectangles.length; i++) {
                elementA = rectangles[ i ] as ObjRectangle;
                for (j = 0; j < rectangles.length; j++) {
                    if (j <= i)
                        continue;
                    elementB = rectangles[ j ] as ObjRectangle;
                    if (elementA.rect.intersects(elementB.rect)) {
                        elementA.isHit = elementB.isHit = true;
                    }
                }
            }
            bmd.lock();
            bmd.colorTransform(bmd.rect, COLOR_TRANS);
            for (i = 0; i < rectangles.length; i++) {
                elementA = rectangles[ i ] as ObjRectangle;
                bmd.fillRect(elementA.rect, elementA.isHit ? 0x990000 : 0x666666);
            }
            bmd.unlock();
        }
        
        private function onEnterFrameB(event:Event):void {
            var i:int, j:int;
            var elementA:ObjMyRect;
            var elementB:ObjMyRect;
            for (i = 0; i < myrects.length; i++) {
                elementA = myrects[ i ] as ObjMyRect;
                elementA.rect.x += elementA.vx;
                elementA.rect.y += elementA.vy;
                if (elementA.rect.x < 0 || elementA.rect.x > STAGE_W)
                    elementA.vx *= -1;
                if (elementA.rect.y < 0 || elementA.rect.y > STAGE_H)
                    elementA.vy *= -1;
                elementA.isHit = false;
            }
            for (i = 0; i < myrects.length; i++) {
                elementA = myrects[ i ] as ObjMyRect;
                for (j = 0; j < myrects.length; j++) {
                    if (j <= i)
                        continue;
                    elementB = myrects[ j ] as ObjMyRect;
                    if (elementA.rect.x + elementA.rect.width < elementB.rect.x) {
                    } else if (elementA.rect.x > elementB.rect.x + elementB.rect.width) {
                    } else if (elementA.rect.y + elementA.rect.height < elementB.rect.y) {
                    } else if (elementA.rect.y > elementB.rect.y + elementB.rect.height) {
                    } else {
                        elementA.isHit = elementB.isHit = true;
                    }
                }
            }
            bmd.lock();
            bmd.colorTransform(bmd.rect, COLOR_TRANS);
            for (i = 0; i < myrects.length; i++) {
                elementA = myrects[ i ] as ObjMyRect;
                bmd.fillRect(new Rectangle(elementA.rect.x, elementA.rect.y, elementA.rect.width, elementA.rect.height), elementA.isHit ? 0x990000 : 0x666666);
            }
            bmd.unlock();
        }
        
        private function onEnterFrameC(event:Event):void {
            var i:int, j:int;
            var elementA:ObjSprite;
            var elementB:ObjSprite;
            for (i = 0; i < sprites.length; i++) {
                elementA = sprites[ i ] as ObjSprite;
                elementA.x += elementA.vx;
                elementA.y += elementA.vy;
                if (elementA.x < 0 || elementA.x > STAGE_W)
                    elementA.vx *= -1;
                if (elementA.y < 0 || elementA.y > STAGE_H)
                    elementA.vy *= -1;
                elementA.isHit = false;
            }
            for (i = 0; i < sprites.length; i++) {
                elementA = sprites[ i ] as ObjSprite;
                for (j = 0; j < sprites.length; j++) {
                    if (j <= i)
                        continue;
                    elementB = sprites[ j ] as ObjSprite;
                    if (elementA.hitTestObject(elementB)) {
                        elementA.isHit = elementB.isHit = true;
                    }
                }
            }
        }
    }
}
import flash.display.*;
import flash.geom.*;

class ObjRectangle {
    public var isHit:Boolean;
    public var rect:Rectangle;
    public var vx:Number;
    public var vy:Number;
}

class ObjMyRect {
    public var isHit:Boolean;
    public var rect:MyRect;
    public var vx:Number;
    public var vy:Number;
}

class ObjSprite extends Sprite {
    public function ObjSprite() {
        hitGr = new Shape();
        hitGr.graphics.beginFill(0x990000);
        hitGr.graphics.drawRect(0, 0, 10, 10);
        addChild(hitGr);
        defGr = new Shape();
        defGr.graphics.beginFill(0x666666);
        defGr.graphics.drawRect(0, 0, 10, 10);
        addChild(defGr);
    }
    public var defGr:Shape;
    public var hitGr:Shape;
    private var _isHit:Boolean;
    
    public function get isHit():Boolean {
        return _isHit;
    }
    
    public function set isHit(value:Boolean):void {
        _isHit = value;
        hitGr.visible = _isHit;
        defGr.visible = !_isHit;
    }
    public var vx:Number;
    public var vy:Number;
}

class MyRect {
    public function MyRect(x:Number, y:Number, width:Number, height:Number) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }
    public var height:Number;
    public var width:Number;
    public var x:Number;
    public var y:Number;
}