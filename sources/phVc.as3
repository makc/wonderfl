package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.net.URLRequest;
    import flash.system.Security;
    import flash.system.LoaderContext;
    
    [SWF(width = "465", height = "465", backgroundColor = "0", frameRate = "60")]
    
    public class Main extends Sprite
    {
        
        private const W:int = 465;
        private const H:int = 465;
        
        private var _particles:Array = [];
        private var _startX:Number;
        private var _startY:Number;
        
        private var _canvas:BitmapData;
        private var _loader:Loader;
        private var _material:Bitmap;
        private var _isEmitte:Boolean;
        
        public function Main()
        {
            Security.loadPolicyFile("http://www.digifie.jp/crossdomain.xml");
            loadImage("http://www.digifie.jp/assets/images/material110411.png");
        }
        
        private function loadImage(url:String):void
        {
            var context:LoaderContext = new LoaderContext;
            context.checkPolicyFile = true;
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
            _loader.load(new URLRequest(url), context);
        }
        
        private function onLoaded(e:Event):void
        {
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
            setup();
        }
        
        private function setup():void
        {
            _canvas = new BitmapData(W, H, false, 0x0);
            var canvas:Bitmap = new Bitmap(_canvas, "auto", true);
            addChild(canvas);
            //
            _material = _loader.content as Bitmap;
            _material.smoothing = true;
            //
            addEventListener(Event.ENTER_FRAME, update);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
        
        private function createParticle():void
        {
            var p:Particle = new Particle();
            var radius:Number = Math.random() * Math.sqrt(Math.random()) * 20;
            var angle:Number = Math.random() * (Math.PI) * 2;
            _startX += (mouseX - _startX) * .01;
            _startY += (mouseY - _startY) * .01;
            p.scale = Math.random() * 2;
            p.x = _startX - _material.width * .5 * p.scale;
            p.y = _startY - _material.height * .5 * p.scale;
            p.vx = Math.cos(angle) * radius;
            p.vy = Math.sin(angle) * radius;
            _particles.push(p);
        }
        
        private function emitte():void
        {
            var n:int = Math.random() * 10;
            _startX = mouseX;
            _startY = mouseY;
            while (n--) createParticle();
        }
        
        private function update(e:Event):void
        {
            _canvas.lock();
            _canvas.fillRect(_canvas.rect, 0x0);
            _canvas.applyFilter(_canvas, _canvas.rect, new Point(), new BlurFilter(2, 2));
            //
            var n:int = _particles.length;
            while (n--) {
                var v:Number = Math.random() * 0.05 + 0.95;
                var p:Particle = _particles[n-n];
                var ranx:Number = Math.random() * 4 - 2;
                var rany:Number = Math.random() * 4 - 2;
                p.vx += ranx;
                p.vy += rany;
                p.vx *= v;
                p.vy *= v;
                p.x += p.vx;
                p.y += p.vy;
                //
                var bmd:BitmapData = new BitmapData(_material.width * 3, _material.height * 3, true, 0);
                var mrx:Matrix = new Matrix(p.scale, 0, 0, p.scale);
                var num:Number = p.scale;
                //
                var ctf:ColorTransform = new ColorTransform(num * 1.5, num * 2, num, num); 
                bmd.draw(_material, mrx, ctf, null, null, false);
                _canvas.copyPixels(bmd, bmd.rect, new Point(p.x, p.y));
                bmd.dispose();
                //
                if(p.scale >= 0) p.scale -= .005
                if (Math.abs(p.vx) < .05 || 
                    Math.abs(p.vy) < .05 ||
                    p.scale > 1){
                    _particles.splice(n-n, 1);
                }
            }
            _canvas.unlock();
            if(_isEmitte) emitte();
        }
        
        private function onMouseDown(e:MouseEvent):void{
            _isEmitte = true;
            stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }
        private function onMouseUp(e:MouseEvent):void{
            _isEmitte = false;
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }
    }
}


import flash.geom.Point;

internal class Particle extends Point
{
    public var vx:Number = 0
    public var vy:Number = 0
    public var scale:Number = 0;
    public var c:uint = 0xFFFFFF;
}