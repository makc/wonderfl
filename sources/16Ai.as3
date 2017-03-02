// forked from sake's ランダムテキストのサンプル
/*
    よく見るランダムテキストの練習。
*/

package
{
    import flash.display.Sprite;

    [SWF(width="465", height="465", backgroundColor="0xffffff", frameRate="60")]
    public class RandomTextSample extends Sprite
    {

        public function RandomTextSample()
        {
                        var i:int = 1
                        
            var rand1:RandomText=new RandomText("Wonderfl build flash online.");
            addChild(rand1);
            rand1.x = 20;
            rand1.y = 24 * i++;
            var rand2:RandomText=new RandomText("ActionScript3.0 and Papervision3D and Tweener.");
            addChild(rand2);
            rand2.x = 20;
            rand2.y = 24 * i++;
            var rand3:RandomText=new RandomText("Progression and Box2DFlashAS3 and Tweensy.");
            addChild(rand3);
            rand3.x = 20;
            rand3.y = 24 * i++;

            var rand4:RandomText=new RandomText("Flex and Mete and yui.");
            addChild(rand4);
            rand4.x = 20;
            rand4.y = 24 * i++;

            var rand5:RandomText=new RandomText("ロールオーバーに座布団つけてみました");
            addChild(rand5);
            rand5.x = 20;
            rand5.y = 24 * i++;

                        var rand6:RandomText=new RandomText("座布団つけるとちょっといい感じ");
            addChild(rand6);
            rand6.x = 20;
            rand6.y = 24 * i++;

                        var rand7:RandomText=new RandomText("メニューバーの演出とかに使えそう");
            addChild(rand7);
            rand7.x = 20;
            rand7.y = 24 * i++;
        }
    }
}

import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.Timer;
import flash.events.MouseEvent;
import caurina.transitions.*

class RandomText extends Sprite
{
    private var RandSource:String="_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    private var MainString:String;
    private var Length:int;
    private var ReplaceCount:int;
    private var ReplaceTimer:Timer;
    private var RandomTimer:Timer;
    public var MainTextField:TextField;

        private var bg:Sprite = new Sprite()

    public function RandomText(main_string:String)
    {
        MainString = main_string;
        Length=MainString.length;
        MainTextField=new TextField();
        MainTextField.defaultTextFormat=new TextFormat(null, 17, 0x000000);
        MainTextField.text=MainString;
        MainTextField.autoSize=TextFieldAutoSize.LEFT;
        MainTextField.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        MainTextField.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
                MainTextField.selectable = false;
        addChild(MainTextField);
        ReplaceTimer=new Timer(10);
        ReplaceTimer.addEventListener(TimerEvent.TIMER, onReplaceTimer);
        
                var padding:int = 3
                bg.graphics.beginFill(0xCCCCCC)
                bg.graphics.drawRect(
                    - padding,
                    - padding,
                    MainTextField.textWidth  + padding * 2,  
                    MainTextField.textHeight + padding * 2)
                bg.scaleX = 0
                bg.alpha = 0
                addChildAt(bg, 0)
                
    }
    
    private function onMouseOver(e:MouseEvent):void
    {
        if (ReplaceTimer.running) ReplaceTimer.stop();
                ReplaceCount = 0
        ReplaceTimer.start();
                Tweener.addTween(bg, {scaleX:1, alpha:1, time:0.5})
    }

    private function onMouseOut(e:MouseEvent):void
    {
                Tweener.addTween(bg, {scaleX:0, alpha:0, time:1.25, transition:"easeInCubic"})
    }

    private function onReplaceTimer(e:TimerEvent):void
    {
        MainTextField.text="";
            var i:int=0;
        for(i=0; i < ReplaceCount; i++) MainTextField.appendText(MainString.charAt(i));
        for(i=0; i < Length - ReplaceCount; i++) MainTextField.appendText(RandSource.charAt(Math.floor(Math.random() * (RandSource.length - 1))));        
        if(ReplaceCount==Length) ReplaceTimer.stop();
        ReplaceCount++;
    }
}