package {
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Vector3D;
    import flash.geom.Point;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.events.ProgressEvent;
    import flash.system.LoaderContext;
    import flash.system.ApplicationDomain;
    import flash.system.SecurityDomain;
    import flash.system.Security;
    import com.bit101.components.*;

    [SWF(width = 465,height = 465,backgroundColor = 0,frameRate = "30")]
    public class Main extends Sprite {
        
        private const POLICY_FILE:String = "http://www.digifie.jp/crossdomain.xml"
        private const SWF_PATH:String = "http://www.digifie.jp/assets/imgset.swf"
        private var _loader:Loader;
        
        private var _container:Sprite;
        private var _items:Array;
        private var _radius:Number = 160;
        private var _numItems:int = 24;
        private var _v:Number = 0;
        
        private var _bar:ProgressBar;
        private var _label:Label;
        
        public var Img1:Class;
        public var Img2:Class;
        public var Img3:Class;
        
        public function Main() {
            graphics.beginFill(0);
            graphics.drawRect(0, 0, 465, 465);           
            graphics.endFill();
            //
            _label = new Label(this, 180, 200, "Loading Wait...");
            _bar = new ProgressBar(this, 180, 220);
            _bar.maximum = 100;
            swfLoad(SWF_PATH)
        }
        
        private function init():void{
            root.transform.perspectiveProjection.fieldOfView = 100;
            _container = new Sprite();
            _container.x = stage.stageWidth * .5;
            _container.y = stage.stageHeight * .5;
            _container.z = 0;
            addChild(_container);
            //
            _items = new Array();
            for (var i:int = 0; i < _numItems; i++) {
                var img:BitmapData;
                if (i % 3 == 0) {
                    img = new Img3();
                }
                else if (i%2 == 0) {
                    img = new Img2();
                }
                else {
                    img = new Img1();
                }

                var angle:Number = Math.PI * 2 / _numItems * i;
                var item:Item = new Item(40,40,0x303030,img);
                _container.addChild(item);
                item.x = Math.cos(angle) * _radius;
                item.z = Math.sin(angle) * _radius;
                item.rotationY = -360 / _numItems * i + 90;
                _items.push(item);
            }
            sortItems();
            //
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        
        //Load Swf
        private function swfLoad(swfPath:String):void{
            var context:LoaderContext = new LoaderContext(); 
            context.checkPolicyFile = true;
            context.securityDomain = SecurityDomain.currentDomain; 
            context.applicationDomain = ApplicationDomain.currentDomain;
            var req:URLRequest = new URLRequest(swfPath);
            _loader = new Loader()
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoadComplete);
            _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,onProgressListener);
            _loader.load(req, context);
        }
        
        //Progress
        private function onProgressListener(e:ProgressEvent):void {
            var progress:int = e.bytesLoaded/e.bytesTotal*100;
            _label.text = "Loading : " + progress + " %";
            //
            if(progress >= 100){
                removeChild(_bar);
                removeChild(_label);
            }else{
                _bar.value = progress;
            }
        }
        
        //Load Complete
        private function swfLoadComplete(e:Event):void {
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,swfLoadComplete);
            _loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,onProgressListener);
            //
            Img1 = _loader.contentLoaderInfo.applicationDomain.getDefinition("Img1") as Class;
            Img2 = _loader.contentLoaderInfo.applicationDomain.getDefinition("Img2") as Class;
            Img3 = _loader.contentLoaderInfo.applicationDomain.getDefinition("Img3") as Class;
            //
            init();
        }

        private function sortItems():void {
            _items.sort(depthSort);
            for (var i:int = 0; i < _items.length; i++) {
                _container.addChildAt(_items[i] as Sprite, i);
            }
        }

        private function depthSort(objA:DisplayObject, objB:DisplayObject):int {
            var posA:Vector3D = objA.transform.matrix3D.position;
            posA = _container.transform.matrix3D.deltaTransformVector(posA);
            var posB:Vector3D = objB.transform.matrix3D.position;
            posB = _container.transform.matrix3D.deltaTransformVector(posB);
            return posB.z - posA.z;
        }

        private function update(e:Event):void {
            
            if(_v < 360 / 50){
                _v += .05
            }else{
                _v = 360 / 50
            }
            _container.y += (mouseY - _container.y) * .01;
            _container.rotationY += _v;
            sortItems();
        }
    }
}


import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class Item extends Sprite{;

private var _bmd:BitmapData;

private var _refbmd:BitmapData;
    private var _refraction:Bitmap;
    private var _mask:Mask;

    public function Item(w:int, h:int, color:int, img:BitmapData) {
        _bmd = new BitmapData(w,h,false,color);
        var bm:Bitmap = new Bitmap(_bmd);
        var image:Bitmap = new Bitmap(img);
        bm.x = image.x =  -  w * .5;
        bm.y = image.y =  -  h * .5;
        addChild(bm);
        addChild(image);
        this.cacheAsBitmap = true;
        doReflection()
    }
    
private function doReflection():void{
        _refbmd = new BitmapData(this.width, this.height, false, 0);
        _refbmd.draw(this, new Matrix(1,0,0,1,20,20));
        _mask = new Mask(this.width, this.height);
        _mask.rotation = 90;
        _mask.x = this.width * .5;
        _mask.y = this.height * .5;
        _refraction = new Bitmap(_refbmd);
        _refraction.scaleY = -1;
        _refraction.x = - this.width * .5;
        _refraction.y = this.height * 1.5;
        addChild(_refraction);
        addChild(_mask);
        _refraction.cacheAsBitmap = _mask.cacheAsBitmap = true;
        _refraction.mask = _mask;
    }
}


//
import flash.display.Sprite;
import flash.display.Graphics;

class Mask extends Sprite{
    public function Mask(w:int, h:int){
        var g:Graphics = this.graphics;
        g.beginGradientFill("linear", [0xFFFFFF, 0xFFFFFF], [1, 0], [30, 200]);
        g.drawRect(0, 0, h, w);
        g.endFill();
    }
}