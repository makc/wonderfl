// forked from wh0's esc
package {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;
    import flash.utils.*;
    import com.codeazur.as3swf.*;
    import com.codeazur.as3swf.data.*;
    import com.codeazur.as3swf.tags.*;
    import com.bit101.components.*;
    public class FlashTest extends Sprite {
        
        private static const CODE:String =
            "use namespace 'flash.display';\n" +
            "class Movie extends Sprite {\n" +
            "\n" +
            "    public function Movie() {\n" +
            "        // write es4 code here..\n" +
			"        for (var i:int = 1; i < 6; i++) {\n" +
            "            graphics.beginFill(0x102030 * i);\n" +
            "            graphics.drawCircle(20 * i, 20, 16);\n" +
			"            graphics.endFill();\n" +
			"        }\n" +
            "    }\n" +
            "\n" +
            "}";
        
        private var progress:ProgressBar;
        private var compileStringToBytes:Function;
        private var code:Text;
        private var log:Text;
        private var swf:SWF;
        private var movie:Loader;
        private var data:SWFData;
        
        public function FlashTest() {
            graphics.beginFill(0xf0f0f0);
            graphics.drawRect(0, 0, 465, 465);
            
            progress = new ProgressBar(this, 5, 5);
            progress.width = 455;
            progress.maximum = 104439;
            
            log = new Text(this, 260, 235, 'Loading... Please Wait...\n');
            log.editable = false;
            log.width = 200;
            log.height = 225;
            
            var ul:URLLoader = new URLLoader;
            ul.dataFormat = URLLoaderDataFormat.BINARY;
			ul.addEventListener(ProgressEvent.PROGRESS, onProgress);
			ul.addEventListener(Event.COMPLETE, loadESC);
			ul.load(new URLRequest(/*"1.gif"*/"http://assets.wonderfl.net/images/related_images/3/3d/3d72/3d721c692ee6ca816bac3cb996e82a2329c725a2"));
        }
		
		private function onProgress(e:ProgressEvent):void {
			progress.value = e.bytesLoaded;
		}
        
        private function trace(...args):void {
            log.textField.appendText(args.join(' ') + '\n');
            log.textField.scrollV = log.textField.maxScrollV;
        }
        
        private function loadESC(e:Event):void {
            var ul:URLLoader = e.target as URLLoader;
			ul.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            ul.removeEventListener(Event.COMPLETE, loadESC);
			var data:ByteArray = new ByteArray;
			data.writeBytes (ul.data, 42, ul.data.length - 42);
            var l:Loader = new Loader();
            l.contentLoaderInfo.addEventListener(Event.COMPLETE, completeESC);
            l.loadBytes(data, new LoaderContext(false, ApplicationDomain.currentDomain));
        }
        
        private function completeESC(e:Event):void {
            compileStringToBytes = ApplicationDomain.currentDomain.getDefinition('ESC.compileStringToBytes') as Function;
            
            swf = new SWF();
            swf.version = 9;
            swf.frameSize.xmax = 4000;
            swf.frameSize.ymax = 4000;
            swf.frameRate = 30;
            swf.compressed = false;
            swf.tags.push(new TagFileAttributes());
            swf.tags.push(null);
            var tsc:TagSymbolClass = new TagSymbolClass();
            tsc.symbols.push(SWFSymbol.create(0, 'Movie'));
            swf.tags.push(tsc);
            swf.tags.push(new TagShowFrame());
            swf.tags.push(new TagEnd());
            
            // clear();
            trace('ESC Compiler Boot Complete');
            
            var p:Panel = new Panel(this, 260, 5);
            p.width = 200;
            p.height = 200;
            
            removeChild(progress);
            progress = null;
            
            code = new Text(this, 5, 5, CODE);
            code.width = 250;
            code.height = 455;
            
            new PushButton(this, 260, 210, 'compile', compile);
            new PushButton(this, 360, 210, 'save', save);
            
            movie = new Loader();
            movie.x = 260;
            movie.y = 5;
            addChild(movie);
            
            compile(null);
        }
        
        private function compile(e:MouseEvent):void {
            // clear();
            trace('Compiling...');
            try {
                var abc:ByteArray = compileStringToBytes(code.text, 'Movie.as');
            } catch (e:Error) {
                trace(e);
            }
            
            swf.tags[1] = TagDoABC.create(abc, '', false);
            data = new SWFData();
            swf.publish(data);
            trace('Compile Complete (' + data.length + ' bytes)');
            
            trace('Reloading swf');
            movie.unloadAndStop();
            movie.loadBytes(data);
        }
        
        private function save(e:MouseEvent):void {
            if (!data) return;
            new FileReference().save(data, 'movie.swf');
        }
        
    }
}