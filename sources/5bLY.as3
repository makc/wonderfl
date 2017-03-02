<?xml version="1.0" encoding="utf-8"?>
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml">
    <mx:Script>
        <![CDATA[
        
        // forked from ton's forked from: Adobe is being the bitch
        // forked from makc3d's Adobe is being the bitch
        
        /**
         * Poem Reader
         * @see http://wonderfl.kayac.com/code/152b9ab3b9d58cece9ce00966dd4ab248d3317aa
         */
            
        private const POEM:String = "47 65 6e 75 69 6e 65 20 41 64 6f 62 65 20 46 6c 61 73 68 20 50 6c 61 79 65 72 20 30 30 31 f0 ee c2 4a 80 68 be e8 2e 00 d0 d1 02 9e 7e 57 6e ec 5d 2d 29 80 6f ab 93 b8 e6 36 cf eb 31 ae "
            
        private function decode():void
        {
            var poemArr:Array = poem.text.split(" ");
            var result:String = "" 
            
            for (var i:int = 0; i < poemArr.length; i++) {
                var s:String = unescape("%" + Number("0x" + poemArr[i]).toString(16)) + " ";
                result += s;

                if (i % 8 == 7)
                    result += "\n";
            }
            
            orijinal.text = result
        }
        
        private function encode():void
        {
            // escapeしたらうまくいくと思ったのですが、
            // アルファベットはescapeできないのですね。無念。
        }
            
        ]]>
    </mx:Script>
    <mx:HBox width="100%" height="100%">
        
        <mx:Panel title="Poem" width="100%" height="100%">
            <mx:TextArea id="poem" width="100%" height="100%" text="{POEM}" />
        </mx:Panel>
        
        <mx:VBox height="100%">
            <mx:Button label="&gt;" click="decode()" toolTip="decode" />
            <mx:Button label="&lt;" click="encode()" toolTip="encode" enabled="false" />
        </mx:VBox>
        
        <mx:Panel title="Orijinal" width="100%" height="100%">
            <mx:TextArea id="orijinal" width="100%" height="100%" />
        </mx:Panel>
        
    </mx:HBox>
</mx:Application>