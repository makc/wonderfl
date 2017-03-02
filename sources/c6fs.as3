// write as3 code here..
package {
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.getTimer;
    
    import frocessing.color.ColorHSV;
    import frocessing.color.ColorRGB;
    
    [SWF(width=465, height=465, backgroundColor=0x000000, frameRate=60)]
    public class Rainbow extends Sprite {
        
        private static const ZERO_POINT:Point = new Point(0, 0);
        
        private static const NUM_OBJECTS:int = 16;
        private static const FORCE:Number = 500.0;
        private static const COLOR_SPEED:Number = 0.05;
        
        private var _center:Sprite;
        private var _images:Array;
        private var _tmp:BitmapData;
        
        private var _mousePressed:Boolean = false;
        private var _prevTime:int = 0;
        private var _colorOffset:Number = 0;
        private var _mousePt:Point = new Point();
        
        public function Rainbow() {
            graphics.beginFill(0);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this._onImageLoaded);
            loader.load(new URLRequest('http://saqoo.sh/a/wordpress/images/booo.jpg'), new LoaderContext(true));
        }
        
        private function _onImageLoaded(e:Event):void {
            var loader:Loader = LoaderInfo(e.target).loader;
            var original:BitmapData = Bitmap(loader.content).bitmapData;
            
            this._center = this.addChild(new Sprite()) as Sprite;
            this._center.x = this.stage.stageWidth / 2;
            this._center.y = this.stage.stageHeight / 2;

            var rs:Number = 0, gs:Number = 0, bs:Number = 0;
            var i:int;
            var c:ColorRGB;
            for (i = 0; i < NUM_OBJECTS; i++) {
                c = new ColorHSV(i / NUM_OBJECTS * 360, 1, 1).toRGB();
                rs += c.r;
                gs += c.g;
                bs += c.b;
            }
            
            this._images = [];
            for (i = 0; i < NUM_OBJECTS; i++) {
                var a:Number = Math.PI * 2 * i / NUM_OBJECTS;
                c = new ColorHSV(i / NUM_OBJECTS * 360, 1, 1).toRGB();
                var img:ColoredImage = this._center.addChild(new ColoredImage(original, c.r / rs, c.g / gs, c.b / bs)) as ColoredImage;
                var px:Number = Math.cos(a) * 30;
                var py:Number = Math.sin(a) * 30;  
                img.init(px, py);
                this._images.push(img);
            }
            
            this.addEventListener(Event.ENTER_FRAME, this._update);
            this.stage.addEventListener(MouseEvent.MOUSE_DOWN, this._onMouseDown);
            this.stage.addEventListener(MouseEvent.MOUSE_UP, this._onMouseUp);
        }
        
        private function _onMouseDown(e:MouseEvent):void {
            this._mousePressed = true;
        }
        
        private function _onMouseUp(e:MouseEvent):void {
            this._mousePressed = false;
        }
        
        private function _update(e:Event):void {
            this._mousePt.x = this._center.mouseX;
            this._mousePt.y = this._center.mouseY
            var img:ColoredImage;
            for each (img in this._images) {
                var dist:Number = Math.max(Point.distance(this._mousePt, img.initPos), 3);
                var lc:Point = img.initPos.subtract(this._mousePt);
                var a:Number = Math.atan2(lc.y, lc.x);
                var f:Number = 1 / dist * FORCE * (this._mousePressed ? 3 : 1);
                img.addForce(Math.cos(a) * f, Math.sin(a) * f);
                img.update();
            }
        }
    }
}



import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.filters.ColorMatrixFilter;
import flash.geom.Point;

import frocessing.color.ColorRGB;

class ColoredImage extends Sprite {
    
    public static var ACC_PARAM:Number = 0.2;
    public static var VELOCITY_PARAM:Number = 0.8;
    
    private var _ix:Number;
    private var _iy:Number;
    private var _vx:Number = 0;
    private var _vy:Number = 0;
    private var _ax:Number = 0;
    private var _ay:Number = 0;
    
    private var _img:Bitmap;
    
    public function ColoredImage(image:BitmapData, r:Number, g:Number, b:Number) {
        this._img = this.addChild(new Bitmap(image)) as Bitmap;
        this._img.x = -this._img.width / 2;
        this._img.y = -this._img.height / 2;
        this._img.filters = [
            new ColorMatrixFilter([
                r, 0, 0, 0, 0,
                0, g, 0, 0, 0,
                0, 0, b, 0, 0,
                0, 0, 0, 1, 0
            ])
        ];
        this._img.blendMode = BlendMode.ADD;
    }
    
    public function init(ix:Number, iy:Number):void {
        this.x = this._ix = ix;
        this.y = this._iy = iy;
        this._img.x -= ix;
        this._img.y -= iy;
    }
    
    public function addForce(ax:Number, ay:Number):void {
        this._ax += ax;
        this._ay += ay;
    }
    
    public function update():void {
        this._ax += (this._ix - this.x) * ACC_PARAM;
        this._ay += (this._iy - this.y) * ACC_PARAM;
        this._vx = (this._vx + this._ax) * VELOCITY_PARAM;
        this._vy = (this._vy + this._ay) * VELOCITY_PARAM;
        this.x += this._vx;
        this.y += this._vy;
        this._ax = this._ay = 0;
    }
    
    public function get ix():Number {
        return this._ix;
    }
    
    public function get iy():Number {
        return this._iy;
    }
    
    public function get initPos():Point {
        return new Point(this._ix, this._iy);
    }
}