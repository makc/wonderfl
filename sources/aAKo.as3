package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    
    
    /**
     * 色の帯2
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
     public class Main2 extends Sprite 
    {
        private var _colorDataList:Array/*ColorData*/ = [];
        public function Main2()
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

            var url:String = "http://kuler-api.adobe.com//feeds/rss/get.cfm?listType=rating&timeSpan=30";
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
            addChild(new Canvas(_colorDataList));
            
        }
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
///
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import org.libspark.betweenas3.tweens.ITween;
    import flash.filters.GlowFilter;
    /**
     * ...
     * @author umhr
     */
    class Canvas extends Sprite
    {
        private var _axis:Sprite = new Sprite();
        private var _positionList:Vector.<Vertices> = new Vector.<Vertices>();
        
        private var _canvas:Sprite = new Sprite();
        private var _lavelCanvas:Sprite = new Sprite();
        private var _background:Shape = new Shape();
        private var _colorDataList:Array/*ColorData*/;
        private var _colorSet:int = 1;
        public function Canvas(_colorDataList:Array/*ColorData*/) 
        {
            this._colorDataList = _colorDataList;
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
            
            addChild(_background);
            _colorSet = int(Math.random()*_colorDataList.length);
            
            _canvas.x = stage.stageWidth * 0.5;
            _canvas.y = stage.stageHeight * 0.5;
            addChild(_canvas);
            
            var w:Number = Math.sqrt(stage.stageWidth * stage.stageWidth + stage.stageHeight * stage.stageHeight);
            var sp:Sprite = new Sprite();
            sp.graphics.beginFill(0xFF0000, 1);
            sp.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            sp.graphics.endFill();
            sp.filters = [new GlowFilter(0x000000, 0.5, w * 0.2, w * 0.2, 1, 4, true, true)];
            addChild(sp);
            
            addChild(_lavelCanvas);
            
            
            var modelData:Vector.<Point> = new Vector.<Point>();
            
            var r:Number;
            var n:int = 24;
            for (var i:int = 0; i < n; i++) 
            {
                r = (i % 2) * 120 + 50 + i * 8;
                modelData.push(new Point( Math.cos(Math.PI * 4 * (i / n)) * r, Math.sin(Math.PI * 4 * (i / n)) * r));
            }
            vertices(modelData);
            
            onClick(null);
            addEventListener(MouseEvent.CLICK, onClick);
        }
        
        private function onClick(event:MouseEvent):void 
        {
            _colorSet ++;
            _colorSet = _colorSet % _colorDataList.length;
            
            _background.graphics.clear();
            _background.graphics.beginFill(_colorDataList[_colorSet].list[0], 1);
            _background.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            _background.graphics.endFill();
            
            while (_lavelCanvas.numChildren > 0) {
                _lavelCanvas.removeChildAt(0);
            }
            
            
            _lavelCanvas.addChild(new NameLabel(_colorDataList[_colorSet].themeTitle, _colorDataList[_colorSet].authorLabel));
        }
        private function vertices(modelData:Vector.<Point>):void {
            
            var colorList:Array/*uint*/ = [0xCC3333, 0x33CC33, 0x3333CC, 0xCCCC33, 0x33CCCC, 0xCC33CC];
            
            colorList = _colorDataList[_colorSet].list;
            
            var dy:Number = 50;
            var ty:Number;
            var n:int = 4;
            for (var i:int = 0; i < n; i++) 
            {
                var verticesIn:Vertices = new Vertices();
                verticesIn.colorIndex = i+1;
                ty = i * dy - n * dy * 0.5;
                
                verticesIn.unshift(new Vertex(modelData[0].x, ty, modelData[0].y, NaN, false, true));
                verticesIn.unshift(new Vertex((modelData[0].x + modelData[1].x) * 0.5, ty, (modelData[0].y + modelData[1].y) * 0.5, NaN, false, true));
                verticesIn.push(new Vertex(modelData[0].x, ty + dy, modelData[0].y, NaN, false, true));
                verticesIn.push(new Vertex((modelData[0].x + modelData[1].x) * 0.5, ty + dy, (modelData[0].y + modelData[1].y) * 0.5, NaN, false, true));
                _positionList.push(verticesIn);
            }
            
            var m:int = modelData.length - 1;
            for (var j:int = 1; j < m; j++) 
            {
                for (i = 0; i < n; i++) 
                {
                    ty = i * dy - n * dy * 0.5;
                    var vertices:Vertices = new Vertices();
                    vertices.colorIndex = i+1;
                    vertices.unshift(new Vertex((modelData[j - 1].x + modelData[j].x) * 0.5, ty, (modelData[j - 1].y + modelData[j].y) * 0.5, 0, false, true));
                    vertices.unshift(new Vertex(modelData[j].x, ty, modelData[j].y, NaN, false, false));
                    vertices.unshift(new Vertex((modelData[j].x + modelData[j + 1].x) * 0.5, ty, (modelData[j].y + modelData[j + 1].y) * 0.5, 0, false, true));
                    
                    vertices.push(new Vertex((modelData[j - 1].x + modelData[j].x) * 0.5, ty + dy, (modelData[j - 1].y + modelData[j].y) * 0.5, 0, false, true));
                    vertices.push(new Vertex(modelData[j].x, ty + dy, modelData[j].y, NaN, false, false));
                    vertices.push(new Vertex((modelData[j].x + modelData[j + 1].x) * 0.5, ty + dy, (modelData[j].y + modelData[j + 1].y) * 0.5, 0, false, true));
                    _positionList.push(vertices);
                }
            }
            for (i = 0; i < n; i++) 
            {
                ty = i * dy - n * dy * 0.5;
                var verticesOut:Vertices = new Vertices();
                verticesOut.colorIndex = i+1;
                verticesOut.unshift(new Vertex((modelData[m-1].x + modelData[m].x) * 0.5, ty, (modelData[m-1].y + modelData[m].y) * 0.5, NaN, false, true));
                verticesOut.unshift(new Vertex(modelData[m].x, ty, modelData[m].y, NaN, false, true));
                verticesOut.push(new Vertex((modelData[m-1].x + modelData[m].x) * 0.5, ty + dy, (modelData[m-1].y + modelData[m].y) * 0.5, NaN, false, true));
                verticesOut.push(new Vertex(modelData[m].x, ty + dy, modelData[m].y, NaN, false, true));
                _positionList.push(verticesOut);
            }
            
            animete();
        }
        
        private function animete():void {
            _axis.z = 0;
            
            addChild(_axis);
            
            addEventListener(Event.ENTER_FRAME, onEnter);
        }
        
        private function onEnter(event:Event):void 
        {
            _axis.rotationX += (mouseX - stage.width * 0.5) * 0.0001;
            _axis.rotationY ++;
            
            var trancePosition:Vector.<Vertices> = new Vector.<Vertices>();
            
            var n:int = _positionList.length;
            for (var i:int = 0; i < n; i++) 
            {
                trancePosition[i] = new Vertices();
                trancePosition[i].rgb = _positionList[i].rgb;
                trancePosition[i].colorIndex = _positionList[i].colorIndex;
                var m:int = _positionList[i].length;
                for (var j:int = 0; j < m; j++) 
                {
                    var poz:Vertex = new Vertex();
                    poz.castByVector3D(_axis.transform.matrix3D.transformVector(_positionList[i][j]));
                    poz.isCorner = _positionList[i][j].isCorner;
                    trancePosition[i].push(poz);
                }
            }
            
            
            draw(Calc.pertrans(Calc.clipping(trancePosition)));
        }
        
        private function draw(trancePosition:Vector.<Vertices>):void {
            
            _canvas.graphics.clear();
            
            var n:int = trancePosition.length;
            
            var zArray:Array = [];
            for (var i:int = 0; i < n; i++) 
            {
                zArray.push(trancePosition[i].distance(0, 0, -100000));
            }
            var sortter:Array = zArray.sort(Array.NUMERIC | Array.RETURNINDEXEDARRAY);
            
            
            //for (var i:int = 0; i < n; i++) 
            //{
            for (var k:int = 0; k < n; k++) 
            {
                i = sortter[k];
                
                var m:int = trancePosition[i].length;
                _canvas.graphics.beginFill(_colorDataList[_colorSet].list[trancePosition[i].colorIndex], 0.9);
                //_canvas.graphics.lineStyle(1, trancePosition[i].rgb, 1);
                if (m == 0) {
                    continue;
                }
                _canvas.graphics.moveTo(trancePosition[i][0].x, trancePosition[i][0].y);
                for (var j:int = 0; j < m; j++) 
                {
                    var i0:int = j;
                    var i1:int = (j + 1) % m;
                    var i2:int = (j + 2) % m;
                    var v0:Vector3D = interpolate(trancePosition[i][i0], trancePosition[i][i1]);
                    var v1:Vector3D = interpolate(trancePosition[i][i1], trancePosition[i][i2]);
                    
                    if(j == 0 && !trancePosition[i][j].isCorner){
                        _canvas.graphics.moveTo(v0.x, v0.y);
                    }
                    if (trancePosition[i][i1].isCorner) {
                        //_canvas.graphics.lineStyle(1, 0x00FF00, 0.5);
                        _canvas.graphics.lineTo(trancePosition[i][i1].x, trancePosition[i][i1].y);
                    }else if(trancePosition[i][i0].isCliped && trancePosition[i][i1].isCliped){
                        _canvas.graphics.lineStyle(1, 0x00FFFF, 0.5);
                        _canvas.graphics.lineTo(trancePosition[i][i1].x, trancePosition[i][i1].y);
                        _canvas.graphics.lineTo(v1.x, v1.y);
                    }else if (trancePosition[i][i1].isCliped && trancePosition[i][i2].isCliped) {
                        _canvas.graphics.lineStyle(1, 0xFFFF00, 0.5);
                        _canvas.graphics.lineTo(trancePosition[i][i1].x, trancePosition[i][i1].y);
                        _canvas.graphics.lineTo(v1.x, v1.y);
                    }else {
                        //_canvas.graphics.lineStyle(3, 0x0000FF, 0.5);
                        _canvas.graphics.lineTo(v0.x, v0.y);
                        //_canvas.graphics.lineStyle(3, 0xFF00FF, 0.5);
                        //_canvas.graphics.moveTo(v0.x, v0.y);
                        _canvas.graphics.curveTo(trancePosition[i][i1].x, trancePosition[i][i1].y, v1.x, v1.y);
                    }
                    
                    
                }
                _canvas.graphics.endFill();
            }
            //trace(poz);
            
            //stage.transform.concatenatedMatrix.deltaTransformPoint(_dot)
            //trace(stage.transform.concatenatedMatrix.deltaTransformPoint(new Point(_dot.x,_dot.y)))
            //_axis.transform.
            //trace(_axis.transform.concatenatedMatrix.deltaTransformPoint(new Point(_dot.x, _dot.y)));
        }
        
        private function interpolate(a:Vertex, b:Vertex):Vertex {
            return new Vertex(a.x + (b.x - a.x) * 0.5, a.y + (b.y - a.y) * 0.5, a.z + (b.z - a.z) * 0.5);
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
        
        var t:ITween;
        t = BetweenAS3.delay(BetweenAS3.tween(this, { alpha:0 }, null, 3 ), 5);
        t.onComplete = onComplete;
        t.play();
    }
    private function onComplete():void {
        while (this.numChildren > 0) {
            this.removeChildAt(0);
        }
        if(parent){
            parent.removeChild(this);
        }
    }

}

    import flash.geom.Vector3D;
    /**
     * ...
     * @author umhr
     */
    class Calc
    {
        
        public function Calc() 
        {
            
        }
        //視点より手前の座標をクリップするための関数
        static public function clipping(trancePosition:Vector.<Vertices>):Vector.<Vertices> {
            var result:Vector.<Vertices> = new Vector.<Vertices>();
            var n:int = trancePosition.length;
            for (var i:int = 0; i < n; i++) {
                result[i] = new Vertices();
                result[i].rgb = trancePosition[i].rgb;
                result[i].colorIndex = trancePosition[i].colorIndex;
                var m:int = trancePosition[i].length;
                var d:int = -500;
                for (var j:int = 0; j < m; j++) {
                    var prev:int = (j + m - 1) % m;
                    var next:int = (j + m + 1) % m;
                    var w:Number;
                    var x:Number;
                    var y:Number;
                    if (trancePosition[i][j].z < d) {
                        if(trancePosition[i][prev].z > d){
                            w = ( d - trancePosition[i][j].z) / (trancePosition[i][prev].z - trancePosition[i][j].z);
                            x = (trancePosition[i][prev].x - trancePosition[i][j].x) * w + trancePosition[i][j].x;
                            y = (trancePosition[i][prev].y - trancePosition[i][j].y) * w + trancePosition[i][j].y;
                            result[i].push(new Vertex(x, y, d, 0, true, trancePosition[i][j].isCorner));
                        }
                        if(trancePosition[i][next].z > d){
                            w = ( d - trancePosition[i][j].z) / (trancePosition[i][next].z - trancePosition[i][j].z);
                            x = (trancePosition[i][next].x - trancePosition[i][j].x) * w + trancePosition[i][j].x;
                            y = (trancePosition[i][next].y - trancePosition[i][j].y) * w + trancePosition[i][j].y;
                            result[i].push(new Vertex(x, y, d, 0, true, trancePosition[i][j].isCorner));
                        }
                    }else{
                        result[i].push(trancePosition[i][j]);
                    }
                };
            }
            return result;
            
        }
        //ペアトランスのための関数
        static public function pertrans(trancePosition:Vector.<Vertices>):Vector.<Vertices> {
            var result:Vector.<Vertices> = new Vector.<Vertices>();
            var n:int = trancePosition.length;
            for (var i:int = 0; i < n; i++) {
                result[i] = new Vertices();
                result[i].rgb = trancePosition[i].rgb;
                result[i].colorIndex = trancePosition[i].colorIndex;
                var m:int = trancePosition[i].length;
                for (var j:int = 0; j < m; j++) {
                    var per:Number = 400/(400 + trancePosition[i][j].z);
                    result[i][j] = new Vertex(trancePosition[i][j].x * per, trancePosition[i][j].y * per, per, 0, false, trancePosition[i][j].isCorner);
                }
            }
            return result;
        }
        
    }


    dynamic class Vertices extends Array
    {
        public var colorIndex:int;
        public function Vertices() 
        {
            
        }
        public function get center():Vertex {
            var result:Vertex = new Vertex();
            var n:int = this.length;
            for (var i:int = 0; i < n; i++) 
            {
                result.x += this[i].x / n;
                result.y += this[i].y / n;
                result.z += this[i].z / n;
            }
            return result;
        }
        public function distance(x:Number, y:Number, z:Number):Number {
            var cent:Vertex = this.center;
            var dx:Number = x - cent.x;
            var dy:Number = y - cent.y;
            var dz:Number = z - cent.z;
            
            return Math.sqrt(dx * dx + dy * dy + dz * dz);
            
        }
        
    }

    import flash.geom.Vector3D;
    class Vertex extends Vector3D
    {
        public var isCliped:Boolean;
        public var isCorner:Boolean;
        public function Vertex(x:Number = 0, y:Number = 0, z:Number = 0, w:Number = 0, isCliped:Boolean = false, isCorner:Boolean = false) 
        {
            super(x, y, z, w);
            this.isCliped = isCliped;
            this.isCorner = isCorner;
        }
        public function castByVector3D(vector3D:Vector3D):void {
            x = vector3D.x;
            y = vector3D.y;
            z = vector3D.z;
        }
        
    }

