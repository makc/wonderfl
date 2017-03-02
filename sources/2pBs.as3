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
        
        private static const PROXY:String = 'http://p.jsapp.us/proxy/';
        private static const BASE:String = 'http://hg.mozilla.org/tamarin-redux/raw-file/db3ebe261f68/esc/bin/';
        private static const ESC:Array = [
            'debug.es.abc',
            'util.es.abc',
            'bytes-tamarin.es.abc',
            'util-tamarin.es.abc',
            'lex-char.es.abc',
            'lex-token.es.abc',
            'lex-scan.es.abc',
            'ast.es.abc',
            'define.es.abc',
            'parse.es.abc',
            'asm.es.abc',
            'abc.es.abc',
            'emit.es.abc',
            'cogen.es.abc',
            'cogen-stmt.es.abc',
            'cogen-expr.es.abc',
            'esc-core.es.abc',
            'eval-support.es.abc',
            'esc-env.es.abc',
            'main.es.abc'
        ];
        private static const CODE:String =
            "use namespace 'flash.display';\n" +
            "class Movie extends Sprite {\n" +
            "\n" +
            "    public function Movie() {\n" +
            "        // write es4 code here..\n" +
            "        graphics.beginFill(0x000000);\n" +
            "        graphics.drawCircle(20, 20, 16);\n" +
            "    }\n" +
            "\n" +
            "}";
        
        private var progress:ProgressBar;
        private var loading:int = 0;
        private var esc:SWF;
        private var compileStringToBytes:Function;
        private var code:Text;
        private var log:Text;
        private var swf:SWF;
        private var movie:Loader;
        private var data:SWFData;
        
        public function FlashTest() {
            Security.loadPolicyFile('http://p.jsapp.us/crossdomain.xml');
            
            graphics.beginFill(0xf0f0f0);
            graphics.drawRect(0, 0, 465, 465);
            
            progress = new ProgressBar(this, 5, 5);
            progress.width = 455;
            progress.maximum = ESC.length;
            
            log = new Text(this, 260, 235, 'Loading... Please Wait...\n');
            log.editable = false;
            log.width = 200;
            log.height = 225;
            
            esc = new SWF();
            esc.version = 9;
            esc.frameSize.xmax = 0;
            esc.frameSize.ymax = 0;
            esc.frameRate = 0;
            esc.compressed = false;
            esc.tags.push(new TagFileAttributes());
            
            loadESC();
        }
        
        private function trace(...args):void {
            log.textField.appendText(args.join(' ') + '\n');
            log.textField.scrollV = log.textField.maxScrollV;
        }
        
        private function loadESC():void {
            progress.value = loading;
            if (loading >= ESC.length) {
                runESC();
                return;
            }
            var ul:URLLoader = new URLLoader(new URLRequest(PROXY + BASE + ESC[loading]));
            ul.dataFormat = URLLoaderDataFormat.BINARY;
            ul.addEventListener(Event.COMPLETE, function (e:Event):void {
                esc.tags.push(TagDoABC.create(ul.data));
                loading++;
                loadESC();
            });
        }
        
        private function runESC():void {
            esc.tags.push(new TagShowFrame());
            esc.tags.push(new TagEnd());
            var data:SWFData = new SWFData();
            esc.publish(data);
            esc = null;
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