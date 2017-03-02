package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    /**
     * 色の帯
     * ライフハッカー
     * http://www.lifehacker.jp/
     * の画面キャプチャで時たま出てくる壁紙が素敵だなと思ったので、それっぽいのを作ってみた。
     * 
     * Adobe kuler
     * http://kuler.adobe.com
     * から取得した色から帯を作る。
     * 一番明るい色が地の色。
     * クリックする度に、変わります。
     * 
     * 壁紙クリエイターとして、jpg/pngをダウンロードできるようにしても良いのかも。
     * 
     * @author umhr
     */
    public class Main extends Sprite 
    {
        private var _colorDataList:Array/*ColorData*/ = [];
        public function Main() 
        {
            stage.scaleMode = "noScale";
            stage.align = "TL";
            init();
        }
        private function init():void 
        {
            if (stage) onInit();
            else addEventListener(Event.ADDED_TO_STAGE, onInit);
        }
        
        private function onInit(event:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, onInit);
            // entry point
            
            var url:String = "http://kuler-api.adobe.com//feeds/rss/get.cfm?listType=popular&timeSpan=30";
            var load:URLLoader = new URLLoader(new URLRequest(url));
            load.addEventListener(Event.COMPLETE, onComplete);
        }
        
        private function onComplete(e:Event):void 
        {
            
            default xml namespace = new Namespace("http://kuler.adobe.com/kuler/API/rss/"); 
            var dataXML:XML = XML(e.target.data);
            var n:int = dataXML.channel.item.length();
            for (var i:int = 0; i < n; i++) 
            {
                var colorData:ColorData = new ColorData();
                colorData.themeTitle = dataXML.channel.item[i].themeItem.themeTitle;
                colorData.authorLabel = dataXML.channel.item[i].themeItem.themeAuthor.authorLabel;
                for (var j:int = 0; j < 5; j++) 
                {
                    colorData.addColor(dataXML.channel.item[i].themeItem.themeSwatches.swatch.swatchHexColor[j]);
                }
                colorData.sort();
                _colorDataList.push(colorData);
                
            }
            //trace(dataXML.channel.item[0].themeItem);
            stage.addEventListener(MouseEvent.CLICK, onClick);
            
            makeImage();
        }
        
        private function onClick(e:MouseEvent):void 
        {
            makeImage();
        }
        
        public function makeImage():void {
            while (this.numChildren > 0) {
                this.removeChildAt(0);
            }
            var select:int = Math.floor(Math.random() * _colorDataList.length);
            var colorData:ColorData = _colorDataList[select];
            
            this.addChild(new Image(stage.stageWidth, stage.stageHeight, colorData.list));
            
            this.addChild(new NameLabel(colorData.themeTitle, colorData.authorLabel));
        }
    }
}

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import org.libspark.betweenas3.BetweenAS3;
class NameLabel extends Sprite {
    private var _title:TextField = new TextField();
    public function NameLabel(themeTitle:String, authorLabel:String) {
        var text:String = "";
        text += "" + themeTitle + "\n";
        text += "by " + authorLabel;
        _title.defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFF);
        _title.width = 400;
        _title.wordWrap = true;
        _title.selectable = false;
        _title.multiline = true;
        _title.autoSize = "left";
        _title.text = text;
        _title.width = _title.textWidth+8;
        this.addChild(_title);
        
        this.graphics.beginFill(0x000000, 0.5);
        this.graphics.drawRoundRect(0, 0, _title.width, _title.height, 8, 8);
        this.graphics.endFill();        
        
        BetweenAS3.delay(BetweenAS3.tween(this, { alpha:0 }, null, 3 ), 5).play();
    }
    
}

class ColorData {
    /**
     * タイトル
     */
    public var themeTitle:String;
    /**
     * 作者
     */
    public var authorLabel:String;
    public var list:Array = [];
    public var tempList:Array = [];
    private var brightnessList:Array = [];
    
    public function ColorData() {
        
    }
    public function addColor(rgb:String):void {
        tempList.push(int("0x" + rgb));
        
        //trace(rgb,rgb.substr(0, 2),rgb.substr(2, 2),rgb.substr(4, 2))
        
        var r:int = int("0x" + rgb.substr(0, 2));
        var g:int = int("0x" + rgb.substr(2, 2));
        var b:int = int("0x" + rgb.substr(4, 2));
        brightnessList.push(r + g + b);
    }
    public function sort():void {
        var sortedList:Array = brightnessList.sort(Array.RETURNINDEXEDARRAY,Array.NUMERIC);
        sortedList.reverse();
        var first:int = sortedList[0];
        list.push(tempList[first]);
        
        for (var i:int = 0; i < 5; i++) 
        {
            var j:int = sortedList[i];
            if (i == first) {
                continue;
            }
            list.push(tempList[i]);
            
        }
        
    }
    
}



import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;

class Image extends Sprite {
    public function Image(width:int, height:int, colorList:Array) {
        init(width, height, colorList);
    }
    private function init(width:int, height:int, colorList:Array):void {
        
        this.graphics.beginFill(colorList[0], 1);
        this.graphics.drawRect(0, 0, width, height);
        this.graphics.endFill();
        
        var w:Number = Math.sqrt(width * width + height * height);
        var h:Number = w * 0.06;
        
        var anchor:Sprite = new Sprite();
        anchor.x = width * 0.5;
        anchor.y = height * 0.5;
        anchor.rotation = int(36 * Math.random()) * 10;
        this.addChild(anchor);
        
        var n:int = colorList.length-1;
        for (var i:int = 0; i < n; i++) 
        {
            var j:int = i - 2;
            var shape:Shape = new Shape();
            shape.graphics.beginFill(colorList[i + 1], 1);
            
            shape.graphics.drawRect(-w*0.5, j * h, w, h);
            shape.graphics.endFill();
            anchor.addChild(shape);
            
        }
        
        var sp:Sprite = new Sprite();
        sp.graphics.beginFill(0xFF0000, 1);
        sp.graphics.drawRect(0, 0, width, height);
        sp.graphics.endFill();
        sp.filters = [new GlowFilter(0x000000, 0.5, w * 0.2, w * 0.2, 1, 4, true, true)];
        this.addChild(sp);
        
    }
}