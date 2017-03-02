package {

    import com.bit101.components.ProgressBar;
    import com.bit101.components.PushButton;
    import com.bit101.components.VBox;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;


    [SWF(backgroundColor="#FFFFFF", frameRate="30", width="465", height="465")]
    
    /**
     * @author Saqoosha
     */
    public class LFPLoader extends Sprite {


        private var _progress:ProgressBar;
        private var _loader:URLLoader;
        private var _lfp:LFP;


        public function LFPLoader() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            _progress = new ProgressBar(this, 182, 222);
            
            _loader = new URLLoader();
            _loader.dataFormat = URLLoaderDataFormat.BINARY;
            _loader.addEventListener(ProgressEvent.PROGRESS, _onProgress);
            _loader.addEventListener(Event.COMPLETE, _onDataLoaded);
//          _loader.load(new URLRequest('http://s3.amazonaws.com/lytro-s3-prod/assets/11b3e750-f927-11e0-9f6c-123139407c18/output.noframes.lfp'));
//          _loader.load(new URLRequest('http://s3.amazonaws.com/lytro-s3-prod/assets/0c0e2cd4-f927-11e0-849a-123139407c18/output.noframes.lfp'));
            _loader.load(new URLRequest('http://s3.amazonaws.com/lytro-s3-prod/assets/1c215a92-f927-11e0-9f6c-123139407c18/output.noframes.lfp'));
        }


        private function _onProgress(e:ProgressEvent):void {
            _progress.value = e.bytesLoaded / e.bytesTotal;
        }


        private function _onDataLoaded(e:Event):void {
            removeChild(_progress);
            _progress = null;
            
            _lfp = new LFP();
            _lfp.addEventListener(Event.COMPLETE, _onImageLoaded);
            _lfp.loadBytes(_loader.data);

            _loader.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
            _loader.removeEventListener(Event.COMPLETE, _onDataLoaded);
            _loader = null;
        }
        
        
        private function _onImageLoaded(e:Event):void {
            _lfp.removeEventListener(Event.COMPLETE, _onImageLoaded);
            
            var vbox:VBox = new VBox(stage, 5, 5);
            for each (var info:Object in _lfp.meta.picture.accelerationArray[0].vendorContent.imageArray) {
                var lfc:LFC = _lfp.getLFC(info.imageRef);
                new PushButton(vbox, 0, 0, info.lambda.toFixed(3), _showImage(lfc.image));
            }
            var dim:Object = _lfp.meta.picture.accelerationArray[0].vendorContent.displayParameters.displayDimensions;
            scaleX = scaleY = 465 / Math.max(dim.value.width, dim.value.height);
            
            new PushButton(vbox, 0, 0, 'DEPTH IMAGE', _showImage(_lfp.depthImage, dim.value.width / _lfp.depthImage.width));
        }


        private function _showImage(image:BitmapData, scale:Number = 1):Function {
            var b:Bitmap = new Bitmap(image);
            b.smoothing = scale == 1;
            b.scaleX = b.scaleY = scale;
            b.visible = numChildren == 0;
            addChild(b);
            return function(e:Event):void {
                addChild(b);
                b.visible = true;
            };
        }
    }
}


import com.adobe.serialization.json.JSON;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Endian;


class LFP extends Sprite {


    private var _lfm:LFM;
    private var _lfc:Dictionary = new Dictionary();
    private var _loading:int = 0;
    
    public var depthImage:BitmapData;
    public function get meta():Object { return _lfm.meta; }
    

    public function LFP() {
    }
    
    
    public function loadBytes(data:ByteArray):void {
        _parse(data);   
    }


    private function _parse(data:ByteArray):void {
        data.endian = Endian.BIG_ENDIAN;
        var lfp:Chunk = new Chunk(data); // skip LFP
        _lfm = new LFM(data);
        while (data.bytesAvailable) {
            var lfc:LFC = new LFC(data);
            _lfc[lfc.checksum] = lfc;
        }
        
        _createDepthImage(_lfm.meta.picture.accelerationArray[0].vendorContent.depthLut);
        
        for each (var info:Object in _lfm.meta.picture.accelerationArray[0].vendorContent.imageArray) {
            _lfc[info.imageRef].addEventListener(Event.COMPLETE, _onLoaded);
            _lfc[info.imageRef].loadImage();
            _loading++;
        }
    }
    
    
    private function _onLoaded(e:Event):void {
        if (--_loading == 0) {
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }


    private function _createDepthImage(info:Object):void {
        var width:int = info.width,
            height:int = info.height,
            data:LFC = _lfc[info.imageRef],
            pixels:Vector.<uint> = new Vector.<uint>(width * height),
            i:int, n:int = width * height,
            val:Number, c:uint, min:Number, max:Number;
            
        data.data.endian = Endian.LITTLE_ENDIAN;
        min = Number.MAX_VALUE;
        max = Number.MIN_VALUE;
        for (i = 0; i < n; i++) {
            val = data.data.readFloat();
            if (val < min) min = val;
            if (max < val) max = val;
        }
        data.data.position = 0;
        for (i = 0; i < n; i++) {
            val = data.data.readFloat();
            c = 255 - (val - min) / (max - min) * 255;
            c |= c << 16 | c << 8;
            pixels[i] = c;
        }

        depthImage = new BitmapData(width, height, false);
        depthImage.setVector(depthImage.rect, pixels);
    }
    
    
    public function getLFC(refId:String):LFC {
        return _lfc[refId];
    }
}


class Chunk extends EventDispatcher {

    
    public var sig0:uint;
    public var sig1:uint;
    public var len0:uint;
    public var len1:uint;
    public var checksum:String;
    
    
    public function Chunk(data:ByteArray) {
        sig0 = data.readUnsignedInt();
        sig1 = data.readUnsignedInt();
        len0 = data.readUnsignedInt();
        len1 = data.readUnsignedInt();
    }
    
    
    protected function readChecksum(data:ByteArray):String {
        checksum = data.readUTFBytes(45);
        data.position += 35;
        return checksum;
    }
    
    
    override public function toString():String {
        return '[Chunk sig0=' + sig0.toString(16) + ' sig1=' + sig1.toString(16) + ' len0=' + len0.toString(16) + ' len1=' + len1.toString(16) + ']';
    }
}


class LFM extends Chunk {
    
    
    public var meta:Object;
    
    
    public function LFM(data:ByteArray) {
        super(data);
        readChecksum(data);
        var json:String = data.readUTFBytes(len1);
        meta = JSON.decode(json);
        data.position = Math.ceil(data.position / 16) * 16;
    }
    
    
    override public function toString():String {
        return '[LFM sig0=' + sig0.toString(16) + ' sig1=' + sig1.toString(16) + ' len0=' + len0.toString(16) + ' len1=' + len1.toString(16) + ' checksum=' + checksum + ']';
    }
}


class LFC extends Chunk {
    
    
    public var data:ByteArray;
    public var image:BitmapData;
    

    public function LFC(data:ByteArray) {
        super(data);
        readChecksum(data);
        this.data = new ByteArray();
        data.readBytes(this.data, 0, len1);
        data.position = Math.ceil(data.position / 16) * 16;
    }
    
    
    public function loadImage():void {
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLoaded);
        loader.loadBytes(data);
    }


    private function _onLoaded(e:Event):void {
        var loader:Loader = e.target.loader;
        image = Bitmap(loader.content).bitmapData;
        dispatchEvent(new Event(Event.COMPLETE));
    }
    
    
    override public function toString():String {
        return '[LFC sig0=' + sig0.toString(16) + ' sig1=' + sig1.toString(16) + ' len0=' + len0.toString(16) + ' len1=' + len1.toString(16) + ' checksum=' + checksum + ']';
    }
}
