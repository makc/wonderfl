package
{
    import caurina.transitions.properties.ColorShortcuts;
    
    import com.adobe.images.PNGEncoder;
    import com.bit101.components.*;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.ProgressEvent;
    import flash.filters.BlurFilter;
    import flash.geom.Matrix;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    import flash.utils.ByteArray;
    
    import jp.progression.commands.*;
    import jp.progression.commands.lists.*;
    import jp.progression.commands.tweens.*;

    [SWF(width=465, height=465, backgroundColor=0xFFFFFF, frameRate=24)]
    public class Main extends Sprite
    {
        
        private const W:Number = 465;
        private  const H:Number = 465;
        
        private var _fr:FileReference = new FileReference();
        
        private var _bmd:BitmapData;
        private var _drawBmd:BitmapData;
        private var _bmUnder:Bitmap;
        private var _bmOver:Bitmap;
        
        private var _mainContainer:Sprite = new Sprite();
        private var _underContainer:Sprite = new Sprite();
        private var _overContainer:Sprite = new Sprite();
        
        private var _loadBtn:PushButton;
        private var _saveBtn:PushButton;
        private var _addeffectBtn:PushButton;
        
        private var _contLabel:Label;
        private var _brtLabel:Label;
        private var _satLabel:Label;
        
        private var _contSlider:Slider;
        private var _brtSlider:Slider;
        private var _satSlider:Slider;
        
        private var _cnt:Number = .2;
        private var _brt:Number = .5;
        private var _sat:Number = .1;
        
        private var _mask:MaskImage;
        
        
        public function Main()
        {
            ColorShortcuts.init();
            
            var label:Label = new Label(this, 180, 200, "Import Your Image!");
            
            _loadBtn = new PushButton(this, 134, 432, "Load Image", fileBrowse);
            _saveBtn = new PushButton(this, 246, 432, "Save Image", saveImage);
            _addeffectBtn = new PushButton(this, 358, 390, "Add Effect", onEffect);
            
            _saveBtn.mouseEnabled = _addeffectBtn.mouseEnabled = false;
            _saveBtn.alpha = _addeffectBtn.alpha = .3;
            
            _contSlider = new Slider("horizontal", this, 10, 400, cntChange);
            _brtSlider = new Slider("horizontal", this, _contSlider.x + 115, _contSlider.y, brtChange);
            _satSlider = new Slider("horizontal", this, _brtSlider.x + 115, _contSlider.y, satChange);
            _contSlider.value = _cnt * 100;
            _brtSlider.value = _brt * 100;
            _satSlider.value = _sat * 100;
            
            _contLabel = new Label(this, _contSlider.x, _contSlider.y - 20, "Contrast");
            _brtLabel = new Label(this, _brtSlider.x, _brtSlider.y - 20, "Brightness");
            _satLabel = new Label(this, _satSlider.x, _satSlider.y - 20, "Saturation");
            
            _mainContainer.cacheAsBitmap = _underContainer.cacheAsBitmap = _overContainer.cacheAsBitmap = true;
            _mainContainer.y = 20;
            addChildAt(_mainContainer, 1);    _mainContainer.addChild(_underContainer);    _mainContainer.addChild(_overContainer);
        }
        
                
        // ------------------ FileBrowse -------------------------------------------------/
        private function fileBrowse(e:MouseEvent):void
        {
            var imagesFilter:FileFilter = new FileFilter("Images", "*.jpg;*.gif;*.png");
            _fr.browse([imagesFilter]);
            _fr.addEventListener(Event.SELECT, fileLoad);
            _fr.addEventListener(Event.CANCEL, cancel);
            //
            disposed();
        }
        
        // ------------------ FileLoad -------------------------------------------------/
        private function fileLoad(e:Event):void
        {
            _fr.removeEventListener(Event.SELECT, fileLoad)
            //
            _fr.load()
            _fr.addEventListener(Event.OPEN, open)
            _fr.addEventListener(ProgressEvent.PROGRESS, progress)
            _fr.addEventListener(Event.COMPLETE, complete)
            _fr.addEventListener(IOErrorEvent.IO_ERROR, ioError)
            //
            function open(e:Event):void{
                //
            }
            function progress(e:ProgressEvent):void{
                //
            }
            function complete(e:Event):void{
                removedEventListener();
                addImage();
            }
            function ioError(e:IOErrorEvent):void{
                removedEventListener();
            }
            //
            function removedEventListener():void{
                _fr.removeEventListener(Event.OPEN, open);
                _fr.removeEventListener(ProgressEvent.PROGRESS, progress);
                _fr.removeEventListener(Event.COMPLETE, complete);
                _fr.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
            }
        }
        
        // ------------------ File Save -------------------------------------------------/
        private function saveImage(e:MouseEvent):void
        {
            _drawBmd.draw(_mainContainer);
            fileSave(_drawBmd);    
            
            //
            _saveBtn.mouseEnabled = _addeffectBtn.mouseEnabled = false;
            _saveBtn.alpha = _addeffectBtn.alpha = .3;
        }
        
        private function fileSave(bmd:BitmapData):void
        {
            var png:ByteArray = PNGEncoder.encode(bmd);
            _fr.addEventListener(Event.COMPLETE, complete);
            _fr.addEventListener(Event.CANCEL, cancel);
            _fr.addEventListener(IOErrorEvent.IO_ERROR, ioError);
            var date:Date = new Date  ;
            _fr.save(png, "image_" + date.getTime() + ".png");
            //
            function complete(e:Event):void
            {
                removedEventListener();
            }
            function cancel(e:Event):void
            {
                removedEventListener();
            }
            function ioError(e:IOErrorEvent):void
            {
                removedEventListener();
            }
            //
            function removedEventListener():void
            {
                _fr.removeEventListener(Event.COMPLETE, complete);
                _fr.removeEventListener(Event.CANCEL, cancel);
                _fr.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
            }
        }
        
        
        // ------------------ Cancel -------------------------------------------------/
        private function cancel(e:Event):void{
            _fr.removeEventListener(Event.SELECT, fileLoad);
            _fr.removeEventListener(Event.CANCEL, cancel);
        }
        
        
        // ------------------ Added Image -------------------------------------------------/
        private function addImage():void
        {
            var loader:Loader = new Loader();
            loader.loadBytes(_fr.data)
            loader.contentLoaderInfo.addEventListener(Event.INIT, init);
            //
            function init(e:Event):void{
                var r:Number = loader.width / loader.height;
                //
                if(r >= 1)
                {
                    var m:Number = W / loader.width;
                    _bmd = new BitmapData(W, H / r , true, 0);
                }else{
                    m = H / loader.height;
                    _bmd = new BitmapData(W * r, H , true, 0);
                }
                //
                _bmd.draw(loader.content, new Matrix(m, 0, 0, m));
                _bmUnder = new Bitmap(_bmd, "auto", false);
                _underContainer.filters = [new BlurFilter(6, 6, 3)];
                _underContainer.addChild(_bmUnder);
                
                _bmOver = new Bitmap(_bmd, "auto", false);
                _overContainer.addChild(_bmOver);
                
                //
                _drawBmd = _bmd.clone();
                
                //
                _saveBtn.mouseEnabled = _addeffectBtn.mouseEnabled = true;
                _saveBtn.alpha = _addeffectBtn.alpha = 1;
            }
        }
        
        // ------------------ Mask -------------------------------------------------/
        private function onMask(px:Number, py:Number):void
        {
            _mask = new MaskImage();
            _mask.x = px;
            _mask.y = py;
            _mainContainer.addChild(_mask);
        }
        
        // ------------------ Slider -------------------------------------------------/
        private function cntChange(e:Event):void
        {
            _cnt = e.target.value * .01;
        }
        private function brtChange(e:Event):void
        {
            _brt = e.target.value * .01;
        }
        private function satChange(e:Event):void
        {
            _sat = e.target.value * .01;
        }
        
        // ------------------ Effect -------------------------------------------------/
        private function onEffect(e:MouseEvent):void
        {
            if(!_mask)
            {
                onMask(_bmUnder.width * .5, _bmUnder.height * .5);
                _overContainer.mask = _mask;
            }
            //
            var plist:ParallelList = new ParallelList();
            plist.addCommand(
                new DoTweener(_overContainer, {_contrast:_cnt, _brightness:_brt - .5, _saturation:_sat + 1, time:.1}),
                new DoTweener(_underContainer, {_contrast:_cnt, _brightness:_brt - .5, _saturation:_sat + 1, time:.1})
            )
            plist.execute();
        }
        
        // ------------------ ImageDisposed -------------------------------------------------/
        private function disposed():void
        {
            if(_bmUnder)
            {
                _underContainer.removeChild(_bmUnder);
                _bmUnder = null;
                _overContainer.removeChild(_bmOver);
                _bmOver = null;
                _overContainer.mask = null;
                _drawBmd.dispose();
                _mainContainer.removeChild(_mask);
                _mask = null;
                //
                var slist:SerialList = new SerialList();
                slist.addCommand(
                    function():void{
                        _cnt = _sat = 0;
                        _brt = .5;
                    },
                    new DoTweener(_overContainer, {_contrast:_cnt, _brightness:_brt, _saturation:_sat + 1, time:.1}),
                    new DoTweener(_underContainer, {_contrast:_cnt, _brightness:_brt, _saturation:_sat + 1, time:.1}),
                    function():void{
                        _contSlider.value = _satSlider.value = 0;
                        _brtSlider.value = .5;
                    }
                )
                slist.execute();
            }
        }
    }
}



import flash.display.Graphics;
import flash.display.Sprite;
import flash.filters.BlurFilter;

internal class MaskImage extends Sprite
{
    public function MaskImage()
    {
        var g:Graphics = this.graphics;
        g.beginFill(0xFFFFFF);
        g.drawCircle(0, 0, 120);
        //
        this.filters = [new BlurFilter(128, 128, 3)];
        this.cacheAsBitmap = true;
    }
}


