// 1. LOAD で適当な画像をロード。
// 2. みかんをドラッグで移動とか。Shift 押しながらで拡大縮小。
// 3. SAVE で保存。
package {
	
	import flash.display.Sprite;
	
	import org.libspark.thread.EnterFrameThreadExecutor;
	import org.libspark.thread.Thread;

	[SWF(width=465, height=465, backgroundColor=0xffffff, frameRate=60)]

	public class Mikan extends Sprite {
		
		public function Mikan() {
			Thread.initialize(new EnterFrameThreadExecutor());
			new MainThread(this).start();
		}
	}
}


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.FileReference;
import flash.net.FileReferenceList;
import flash.net.URLRequest;
import flash.system.Security;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.ByteArray;

import org.libspark.thread.Thread;

class MainThread extends Thread {
	
	private var _base:Sprite;
	private var _loadButton:Button;
	private var _saveButton:Button;
	private var _mikan:MikanImage;
	private var _original:Loader;
	private var _guide:Guide;
	
	public function MainThread(base:Sprite) {
		this._base = base;
		this._loadButton = this._base.addChild(new Button('LOAD', 60)) as Button;
		this._loadButton.x = this._loadButton.y = 1;
		this._saveButton = this._base.addChild(new Button('SAVE', 60)) as Button;
		this._saveButton.x = 1;
		this._saveButton.y = this._loadButton.height + 2;
		this._guide = this._base.addChild(new Guide()) as Guide;
		this._guide.x = this._guide.y = (465 - 256) >> 1;
	}
	
	protected override function run():void {
		this._mikan = this._base.addChildAt(new MikanImage(), 0) as MikanImage;
		event(this._mikan, Event.COMPLETE, this._mikanLoaded);
		this._mikan.init();
	}
	
	private function _mikanLoaded(e:Event):void {
		this._mikan.scaleX = this._mikan.scaleY = 256 * 0.4 / this._mikan.width;
		this._mikan.x = this._guide.x + 128;
		this._mikan.y = this._guide.y + this._mikan.height / 2 + 10;
		
		this._event();
	}
	
	private function _event():void {
		event(this._loadButton, MouseEvent.CLICK, this._loadImage);
		event(this._saveButton, MouseEvent.CLICK, this._saveImage);
		event(this._mikan, MouseEvent.MOUSE_DOWN, this._dragStart);
	}
	
	
	// load image
	private function _loadImage(e:MouseEvent):void {
		var file:FileReference = new FileReference();
		event(file, Event.SELECT, this._loadFileSelected);
		file.browse();
	}
	
	private function _loadFileSelected(e:Event):void {
		var file:FileReference = FileReference(e.target);
		event(file, Event.COMPLETE, this._fileLoaded);
		file.load();
	}
	
	private function _fileLoaded(e:Event):void {
		if (this._original) {
			this._original.parent.removeChild(this._original);
			this._original.unload();
		}
		this._original = this._base.addChildAt(new Loader(), 0) as Loader;
		this._original.loadBytes(FileReference(e.target).data);
		event(this._original.contentLoaderInfo, Event.COMPLETE, this._imageLoaded);
	}
	
	private function _imageLoaded(e:Event):void {
		var a:Number = 256 / Math.max(this._original.width, this._original.height);
		this._original.scaleX = this._original.scaleY = a;
		this._original.x = this._guide.x + (256 - this._original.width) / 2;
		this._original.y = this._guide.y + (256 - this._original.height) / 2;
		Bitmap(this._original.content).smoothing = true;
		this._event();
	}
	
	
	// manipulate mikan
	private var _startScale:Number;
	private var _startPoint:Point = new Point();
	private function _dragStart(e:MouseEvent):void {
		var sp:Sprite = Sprite(e.target);
		if (e.shiftKey) {
			this._startScale = sp.scaleX;
			this._startPoint.x = this._base.mouseX;
			this._startPoint.y = this._base.mouseY;
			event(this._base.stage, MouseEvent.MOUSE_MOVE, this._scaleObject);
			event(this._base.stage, MouseEvent.MOUSE_UP, this._scaleEnd);
		} else {
			sp.startDrag(false);
			event(sp, MouseEvent.MOUSE_UP, this._dragEnd);
		}
	}
	
	private function _scaleObject(e:MouseEvent):void {
		var newScale:Number = this._startScale * (this._base.mouseX - this._mikan.x) / (this._startPoint.x - this._mikan.x);
		this._mikan.scaleX = this._mikan.scaleY = newScale;
		event(this._base.stage, MouseEvent.MOUSE_MOVE, this._scaleObject);
		event(this._base.stage, MouseEvent.MOUSE_UP, this._scaleEnd);
	}
	
	private function _scaleEnd(e:MouseEvent):void {
		this._event();
	}
	
	private function _dragEnd(e:MouseEvent):void {
		Sprite(e.target).stopDrag();
		this._event();
	}
	
	
	// save image
	private function _saveImage(e:Event):void {
		var raw:BitmapData = new BitmapData(256, 256, true, 0x0);
		this._guide.visible = false;
		raw.draw(this._base, new Matrix(1, 0, 0, 1, -this._guide.x, -this._guide.y), null, null, null, true);
		this._guide.visible = true;
		var png:ByteArray = PNGEnc.encode(raw);
		raw.dispose();
		var file:FileReference = new FileReference();
		event(file, Event.SELECT, this._saveFileSelected);
		file.save(png, 'mikaned.png');
	}
	
	private function _saveFileSelected(e:Event):void {
		this._event();
	}
}


class MikanImage extends Sprite {
	
	private var _mikan:Loader;
	
	public function MikanImage() {
		this.buttonMode = true;
		this.useHandCursor = true;
		this.mouseChildren = false;
	}
	
	public function init():void {
		this._mikan = this.addChild(new Loader()) as Loader;
		this._mikan.contentLoaderInfo.addEventListener(Event.COMPLETE, this._mikanLoaded);
		this._mikan.load(new URLRequest('http://saqoo.sh/a/labs/wonderfl/mikan.png'), new LoaderContext(true));
	}
	
	private function _mikanLoaded(e:Event):void {
		this._mikan.x = -this._mikan.width / 2;
		this._mikan.y = -this._mikan.height / 2;
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}


class Button extends SimpleButton {
	
	public function Button(label:String, width:int = 0):void {
		var up:Sprite = _buildImage(label, 0x0, width);
		var over:Sprite = _buildImage(label, 0x333333, width);
		var down:Sprite = _buildImage(label, 0x333333, width);
		down.y = 1;
		super(up, over, down, up);
	}
	
	private static function _buildImage(label:String, color:int, width:int = 0):Sprite {
		var text:TextField = new TextField();
		text.defaultTextFormat = new TextFormat('Verdana', 10, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
		text.autoSize = TextFieldAutoSize.LEFT
		text.selectable = false;
		text.text = label;
		text.x = (width - text.width) >> 1;
		text.y = 5;
		var base:Shape = new Shape();
		var g:Graphics = base.graphics;
		g.beginFill(color);
		g.drawRect(0, 0, width, text.height + 10);
		g.endFill();
		var sp:Sprite = new Sprite();
		sp.addChild(base);
		sp.addChild(text);
		return sp;
	}
}


class Guide extends Shape {
	
	public function Guide() {
		var g:Graphics = this.graphics;
		g.lineStyle(1, 0x0, 0.3, true);
		g.drawRect(0, 0, 255, 255);
	}
}




// http://www.5etdemi.com/blog/archives/2006/12/as3-png-encoder-faster-better/

class PNGEnc {
	
    public static function encode(img:BitmapData, type:uint = 0):ByteArray {
    	
        // Create output byte array
        var png:ByteArray = new ByteArray();
        // Write PNG signature
        png.writeUnsignedInt(0x89504e47);
        png.writeUnsignedInt(0x0D0A1A0A);
        // Build IHDR chunk
        var IHDR:ByteArray = new ByteArray();
        IHDR.writeInt(img.width);
        IHDR.writeInt(img.height);
        if(img.transparent || type == 0)
        {
        	IHDR.writeUnsignedInt(0x08060000); // 32bit RGBA
        }
        else
        {
        	IHDR.writeUnsignedInt(0x08020000); //24bit RGB
        }
        IHDR.writeByte(0);
        writeChunk(png,0x49484452,IHDR);
        // Build IDAT chunk
        var IDAT:ByteArray= new ByteArray();
        
        switch(type)
        {
        	case 0:
        		writeRaw(img, IDAT);
        		break;
        	case 1:
        		writeSub(img, IDAT);
        		break;
        }
        
        IDAT.compress();
        writeChunk(png,0x49444154,IDAT);
        // Build IEND chunk
        writeChunk(png,0x49454E44,null);
        // return PNG
        
        
        
        return png;
    }
    
    private static function writeRaw(img:BitmapData, IDAT:ByteArray):void
    {
        var h:int = img.height;
        var w:int = img.width;
        var transparent:Boolean = img.transparent;
        
        for(var i:int=0;i < h;i++) {
            // no filter
            if ( !transparent ) {
            	var subImage:ByteArray = img.getPixels(
            		new Rectangle(0, i, w, 1));
            	//Here we overwrite the alpha value of the first pixel
            	//to be the filter 0 flag
            	subImage[0] = 0;
				IDAT.writeBytes(subImage);
				//And we add a byte at the end to wrap the alpha values
				IDAT.writeByte(0xff);
            } else {
            	IDAT.writeByte(0);
            	var p:uint;
                for(var j:int=0;j < w;j++) {
                    p = img.getPixel32(j,i);
                    IDAT.writeUnsignedInt(
                        uint(((p&0xFFFFFF) << 8)|
                        (p>>>24)));
                }
            }
        }
    }
    
    private static function writeSub(img:BitmapData, IDAT:ByteArray):void
    {
        var r1:uint;
        var g1:uint;
        var b1:uint;
        var a1:uint;
        
        var r2:uint;
        var g2:uint;
        var b2:uint;
        var a2:uint;
        
        var r3:uint;
        var g3:uint;
        var b3:uint;
        var a3:uint;
        
        var p:uint;
        var h:int = img.height;
        var w:int = img.width;
        
        for(var i:int=0;i < h;i++) {
            // no filter
            IDAT.writeByte(1);
            if ( !img.transparent ) {
				r1 = 0;
				g1 = 0;
				b1 = 0;
				a1 = 0xff;
                for(var j:int=0;j < w;j++) {
                    p = img.getPixel(j,i);
                    
                    r2 = p >> 16 & 0xff;
                    g2 = p >> 8  & 0xff;
                    b2 = p & 0xff;
                    
                    r3 = (r2 - r1 + 256) & 0xff;
                    g3 = (g2 - g1 + 256) & 0xff;
                    b3 = (b2 - b1 + 256) & 0xff;
                    
                    IDAT.writeByte(r3);
                    IDAT.writeByte(g3);
                    IDAT.writeByte(b3);
                    
                    r1 = r2;
                    g1 = g2;
                    b1 = b2;
                    a1 = 0;
                }
            } else {
				r1 = 0;
				g1 = 0;
				b1 = 0;
				a1 = 0;
                for(j=0;j < w;j++) {
                    p = img.getPixel32(j,i);
                    
                    a2 = p >> 24 & 0xff;
                    r2 = p >> 16 & 0xff;
                    g2 = p >> 8  & 0xff;
                    b2 = p & 0xff;
                    
                    r3 = (r2 - r1 + 256) & 0xff;
                    g3 = (g2 - g1 + 256) & 0xff;
                    b3 = (b2 - b1 + 256) & 0xff;
                    a3 = (a2 - a1 + 256) & 0xff;
                    
                    IDAT.writeByte(r3);
                    IDAT.writeByte(g3);
                    IDAT.writeByte(b3);
                    IDAT.writeByte(a3);
                    
                    r1 = r2;
                    g1 = g2;
                    b1 = b2;
                    a1 = a2;
                }
            }
        }
    }

    private static var crcTable:Array;
    private static var crcTableComputed:Boolean = false;

    private static function writeChunk(png:ByteArray, 
            type:uint, data:ByteArray):void {
		var c:uint;
        if (!crcTableComputed) {
            crcTableComputed = true;
            crcTable = [];
            for (var n:uint = 0; n < 256; n++) {
                c = n;
                for (var k:uint = 0; k < 8; k++) {
                    if (c & 1) {
                        c = uint(uint(0xedb88320) ^ 
                            uint(c >>> 1));
                    } else {
                        c = uint(c >>> 1);
                    }
                }
                crcTable[n] = c;
            }
        }
        var len:uint = 0;
        if (data != null) {
            len = data.length;
        }
        png.writeUnsignedInt(len);
        var p:uint = png.position;
        png.writeUnsignedInt(type);
        if ( data != null ) {
            png.writeBytes(data);
        }
        var e:uint = png.position;
        png.position = p;
        c = 0xffffffff;
        for (var i:int = 0; i < (e-p); i++) {
            c = uint(crcTable[
                (c ^ png.readUnsignedByte()) & 
                0xff] ^ (c >>> 8));
        }
        c = uint(c^uint(0xffffffff));
        png.position = e;
        png.writeUnsignedInt(c);
    }
}
