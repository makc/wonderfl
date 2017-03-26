package
{
    import flash.display.Sprite;

    [SWF(backgroundColor=0xffffff, width=465, height=465, frameRate=60)]
    public class jit_test extends Sprite
    {

        public function jit_test()
        {
            var tester:Tester = new Tester("JITの効果について比較します。", this);
            var count:uint = 1000;

            //テストの登録
            tester.register(test1, "通常処理", [count]);
            tester.register(test2, "インラインでtry/catch", [count]);
            tester.register(test3, "インラインでtry/catch(try/catchは通らないケース)", [count]);
            tester.register(test4, "try/catchを外部化", [count]);
            tester.register(test5, "try/catchを外部化(try/catchは通らないケース)", [count]);
        }

        //通常処理だけ
        public function test1(count:uint):void
        {
            for (var i:int = 0; i < count; i++)
            {
                test1_1();
            }
        }

        public function test1_1():void
        {
            var n:Number = 0;
            for (var i:int = 0; i < 10000; i++)
            {
                n += i;
            }

            var n2:Number = 0;
            for (var j:int = 0; j < 10000; j++)
            {
                n2 += j;
            }

            var n3:Number = 0;
            for (var k:int = 0; k < 10000; k++)
            {
                n3 += k;
            }
        }

        //try/catchが含まれるケース
        public function test2(count:uint):void
        {
            for (var i:int = 0; i < count; i++)
            {
                test2_1();
            }
        }

        public function test2_1():void
        {
            var n:Number = 0;
            for (var i:int = 0; i < 10000; i++)
            {
                n += i;
            }

            try
            {
                var n2:Number = 0;
                for (var j:int = 0; j < 10000; j++)
                {
                    n2 += j;
                }
            }
            catch (e:Error)
            {
            }

            var n3:Number = 0;
            for (var k:int = 0; k < 10000; k++)
            {
                n3 += k;
            }
        }

        //try/catchは含まれているが、実際にはそこを通らないケース
        public function test3(count:uint):void
        {
            for (var i:int = 0; i < count; i++)
            {
                test3_1();
            }
        }

        public function test3_1():void
        {
            var n:Number = 0;
            for (var i:int = 0; i < 10000; i++)
            {
                n += i;
            }

            var handleFlag:Boolean = false; //強制でfalse
            if (handleFlag)
            {
                try
                {
                    var n2:Number = 0;
                    for (var j:int = 0; j < 10000; j++)
                    {
                        n2 += j;
                    }
                }
                catch (e:Error)
                {
                }
            }
            else
            {
                var n2:Number = 0;
                for (var j:int = 0; j < 10000; j++)
                {
                    n2 += j;
                }
            }

            var n3:Number = 0;
            for (var k:int = 0; k < 10000; k++)
            {
                n3 += k;
            }
        }

        //try/catchを外部化
        public function test4(count:uint):void
        {
            for (var i:int = 0; i < count; i++)
            {
                test4_1();
            }
        }

        public function test4_1():void
        {
            var n:Number = 0;
            for (var i:int = 0; i < 10000; i++)
            {
                n += i;
            }

            test4_2();

            var n3:Number = 0;
            for (var k:int = 0; k < 10000; k++)
            {
                n3 += k;
            }
        }

        public function test4_2():void
        {
            try
            {
                var n2:Number = 0;
                for (var j:int = 0; j < 10000; j++)
                {
                    n2 += j;
                }
            }
            catch (e:Error)
            {
            }
        }

        
        //try/catchを外部化(try/catchは通らないケース)
        public function test5(count:uint):void
        {
            for (var i:int = 0; i < count; i++)
            {
                test5_1();
            }
        }
        
        public function test5_1():void
        {
            var n:Number = 0;
            for (var i:int = 0; i < 10000; i++)
            {
                n += i;
            }
            
            var handleFlag:Boolean = false; //強制でfalse
            if (handleFlag)
            {
                test5_2();
            }
            else
            {
                var n2:Number = 0;
                for (var j:int = 0; j < 10000; j++)
                {
                    n2 += j;
                }
            }
            
            var n3:Number = 0;
            for (var k:int = 0; k < 10000; k++)
            {
                n3 += k;
            }
        }
        
        public function test5_2():void
        {
            try
            {
                var n2:Number = 0;
                for (var j:int = 0; j < 10000; j++)
                {
                    n2 += j;
                }
            }
            catch (e:Error)
            {
            }
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////
//以下テストツール
//////////////////////////////////////////////////////////////////////////////////////////////
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.utils.getTimer;

class Tester extends Sprite
{

    private var _console:TextField;

    private var _tests:Array = [];

    public function Tester(caption:String, parent:Sprite)
    {
        parent.addChild(this);

        var label:TextField = new TextField();
        with (label)
        {
            defaultTextFormat = new TextFormat(null, 14);
            text = "Start";
            border = true;
            mouseEnabled = false;
            height = textHeight + 6;
            width = textWidth + 16;
        }

        with (addChild(new Sprite))
        {
            addChild(label);
            buttonMode = true;
            useHandCursor = true;
            addEventListener(MouseEvent.CLICK, start);
        }

        with (addChild(_console = new TextField))
        {
            defaultTextFormat = new TextFormat(null, 14);
            multiline = true;
            type = TextFieldType.INPUT;
            width = 460;
            height = 430;
            y = 30;
            border = true;
        }

        _console.text = caption;
    }

    public function register(test:Function, title:String, args:Array = null):void
    {
        _tests[_tests.length] = {test: test, title: title, args: args};
    }

    private function callLater(fn:Function, args:Array = null):void
    {
        addEventListener(Event.ENTER_FRAME, function(e:Event):void
            {
                removeEventListener(Event.ENTER_FRAME, arguments.callee);
                addEventListener(Event.ENTER_FRAME, function(e:Event):void
                    {
                        removeEventListener(Event.ENTER_FRAME, arguments.callee);
                        fn.apply(null, args);
                    });
            });
    }

    private function doTest(tests:Array):void
    {

        var test:Object = tests.shift();
        if (test === null)
        {
            mouseEnabled = true;
            mouseChildren = true;
            alpha = 1;
            return;
        }

        _console.appendText("[" + test.title + "]を引数[" + test.args + "]で実行...");
        _console.scrollV = _console.maxScrollV;

        callLater(function():void
            {
                var t:uint = getTimer();
                test.test.apply(null, test.args);
                t = getTimer() - t;

                callLater(function():void
                    {
                        _console.appendText(" " + t + "ms\n");
                        _console.scrollV = _console.maxScrollV;
                        callLater(doTest, [tests]);
                    });
            });
    }

    private function start(e:MouseEvent):void
    {
        _console.text = "";
        mouseEnabled = false;
        mouseChildren = false;
        alpha = 0.6;
        doTest(_tests.concat());
    }
}
