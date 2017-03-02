/*
    よく見るランダムテキストの練習。
*/

package
{
    import flash.display.Sprite;

    [SWF(width="465", height="465", backgroundColor="0xffffff", frameRate="40")]
    public class RandomTextSample extends Sprite
    {

        public function RandomTextSample()
        {
            var rand1:RandomText=new RandomText("Wonderfl build flash online.");
            addChild(rand1);
            rand1.x = 20;
            rand1.y = 20;
            var rand2:RandomText=new RandomText("ActionScript3.0 and Papervision3D and Tweener.");
            addChild(rand2);
            rand2.x = 20;
            rand2.y = 40;
            var rand3:RandomText=new RandomText("Progression and Box2DFlashAS3 and Tweensy.");
            addChild(rand3);
            rand3.x = 20;
            rand3.y = 60;
            var rand4:RandomText=new RandomText("Flex and Mete and yui.");
            addChild(rand4);
            rand4.x = 20;
            rand4.y = 80;
            var rand5:RandomText=new RandomText("日本語はあんまりきれいじゃないですやっぱり");
            addChild(rand5);
            rand5.x = 20;
            rand5.y = 100;
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

class RandomText extends Sprite
{
    private var RandSource:String="_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";
    private var MainString:String;
    private var Length:int;
    private var ReplaceCount:int;
    private var ReplaceTimer:Timer;
    private var RandomTimer:Timer;
    private var MainTextField:TextField;

    public function RandomText(main_string:String)
    {
        MainString=main_string;
        Length=MainString.length;
        MainTextField=new TextField();
        MainTextField.defaultTextFormat=new TextFormat(null, 17, 0x000000);
        MainTextField.text=MainString;
        MainTextField.autoSize=TextFieldAutoSize.LEFT;
        MainTextField.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        MainTextField.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        addChild(MainTextField);
        ReplaceTimer=new Timer(10);
        ReplaceTimer.addEventListener(TimerEvent.TIMER, onReplaceTimer);
        RandomTimer=new Timer(10);
        RandomTimer.addEventListener(TimerEvent.TIMER, onRandomTimer);
        
    }
    
    private function onMouseOver(e:MouseEvent):void
    {
        if (ReplaceTimer.running) ReplaceTimer.stop();
        RandomTimer.start();
    }
    
    private function onRandomTimer(e:TimerEvent):void
    {
        MainTextField.text="";
        for(var i:int=0; i < Length; i++) MainTextField.appendText(RandSource.charAt(Math.floor(Math.random() * (RandSource.length - 1))));
    }

    private function onMouseOut(e:MouseEvent):void
    {
        if(RandomTimer.running) RandomTimer.stop();
        ReplaceCount=0;
        ReplaceTimer.start();
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