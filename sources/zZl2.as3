//簡単に導入できるロード画面を考える。


//読み込み用のswfとして"Sketch of Voronoi"を使用させていただきました。
//http://wonderfl.net/c/iNy0

//とりあえず完成
//また今度もうちょっと凝ったのを考える。
package {
    import flash.system.LoaderContext;
    import flash.text.TextFormat;
    import flash.text.TextField;
    import flash.net.URLRequest;
    import flash.display.Sprite;
    import flash.display.Loader;
    import flash.net.URLLoader;
    import net.wonderfl.utils.FontLoader;
    import caurina.transitions.Tweener;
    
    public class FlashTest extends Sprite {
        private var fontLoader:FontLoader = new FontLoader();
        private var fontLoader2:FontLoader = new FontLoader();
        private var loader:Loader = new Loader();
        private var TextLoader:URLLoader = new URLLoader();
        public function FlashTest(){
            var nowLoading:NowLoading = new NowLoading(stage,onLoaded);
            
            //ロードを開始する
            fontLoader.load( "Azuki" );
            fontLoader2.load( "Sazanami" );
            loader.load( new URLRequest("http://swf.wonderfl.net/swf/usercode/8/83/83c0/83c0fa8eb9e85ce32eccd202190d426f98a22cde.swf") );
            TextLoader.load( new URLRequest("http://spheresofa.web.fc2.com/wonderfl/test.txt") );
            
            //ローダーを登録する
            nowLoading.addLoader(fontLoader.loader);
            nowLoading.addLoader(fontLoader2.loader);
            nowLoading.addLoader(loader);
            nowLoading.addURLLoader(TextLoader);
        }
        
        //ロードが完了したときに呼び出す
        private function onLoaded():void{
            //ロード画面を消す
            Tweener.addTween(stage.getChildAt(1),{alpha:0,time:3,onComplete:function():void{stage.removeChildAt(1)} });
            
            init();
        }
        
        //初期化
        private function init():void{
            alpha=0;
            Tweener.addTween(this,{delay:2,alpha:1,time:10});
            
            var tf:TextField = new TextField();
            tf.embedFonts=true;tf.blendMode="invert";tf.autoSize="left";
            tf.defaultTextFormat=new TextFormat("Azuki",30);
            tf.htmlText=TextLoader.data;
            
            addChild(loader);
            addChild(tf);
        }
    }
}
import flash.geom.*;
import flash.display.*;
import flash.text.TextField;
import flash.events.Event;
import flash.net.URLLoader;

class NowLoading extends Sprite{
    static public const COMPLETE:String = "complete";
    public var loaders:Vector.<Object> = new Vector.<Object>;
    public var bytesTotal:uint=0,bytesLoaded:uint=0;
    private var _loaderNum:uint=0,_completedNum:uint=0,_openNum:uint=0; //ローダーの数
    private var text:Bitmap, sprite:ProgressSprite;
    private var onLoaded:Function;
    private var LETTER:Object = {
        "1":[[0,1,1],[0,0,1],[0,0,1],[0,0,1],[0,0,1]],"2":[[1,1,1],[0,0,1],[0,1,1],[1,0,0],[1,1,1]],"3":[[1,1,1],[0,0,1],[1,1,1],[0,0,1],[1,1,1]],"4":[[1,0,1],[1,0,1],[1,0,1],[1,1,1],[0,0,1]],"5":[[1,1,1],[1,0,0],[1,1,1],[0,0,1],[1,1,1]],
        "6":[[1,1,1],[1,0,0],[1,1,1],[1,0,1],[1,1,1]],"7":[[1,1,1],[0,0,1],[0,0,1],[0,0,1],[0,0,1]],"8":[[1,1,1],[1,0,1],[1,1,1],[1,0,1],[1,1,1]],"9":[[1,1,1],[1,0,1],[1,1,1],[0,0,1],[0,0,1]],"0":[[1,1,1],[1,0,1],[1,0,1],[1,0,1],[1,1,1]],
        ".":[[0],[0],[0],[0],[1]]," ":[[0],[0],[0],[0],[0]],"n":[[0,0,0],[0,0,0],[1,1,1],[1,0,1],[1,0,1]],"w":[[0,0,0,0,0],[0,0,0,0,0],[1,0,1,0,1],[1,0,1,0,1],[1,1,1,1,1]],"o":[[0,0,0],[0,0,0],[1,1,1],[1,0,1],[1,1,1]],
        "a":[[0,0,0],[0,0,1],[1,1,1],[1,0,1],[1,1,1]],"l":[[1],[1],[1],[1],[1]],"i":[[1],[0],[1],[1],[1]],"d":[[0,0,1],[0,0,1],[1,1,1],[1,0,1],[1,1,1]],"g":[[0,0,0],[0,0,0],[1,1,1],[1,0,1],[1,1,1],[0,0,1],[1,1,1]],
        "C":[[1,1,1],[1,0,0],[1,0,0],[1,0,0],[1,1,1]],"O":[[1,1,1],[1,0,1],[1,0,1],[1,0,1],[1,1,1]],"M":[[1,1,1,1,1],[1,0,1,0,1],[1,0,1,0,1],[1,0,1,0,1],[1,0,1,0,1]],"P":[[1,1,1],[1,0,1],[1,1,1],[1,0,0],[1,0,0]],
        "T":[[1,1,1],[0,1,0],[0,1,0],[0,1,0],[0,1,0]],"L":[[1,0,0],[1,0,0],[1,0,0],[1,0,0],[1,1,1]],"E":[[1,1,1],[1,0,0],[1,1,1],[1,0,0],[1,1,1]]
    }
    //ステージと関数を渡す
    public function NowLoading(stage:Stage, onLoaded:Function = null){
        if(onLoaded == null){ this.onLoaded=nullFunc }else{ this.onLoaded=onLoaded }
        sprite = new ProgressSprite(stage.stageWidth,stage.stageHeight);
        text = new Bitmap( new BitmapData(30*4,8,true,0x00000000 ) ); 
        stage.addChild(this); addChild(sprite); addChild(text);
        with(text){scaleX=scaleY=1; blendMode="invert"; x=stage.stageWidth-text.width; y=stage.stageHeight-text.height;}
    }
    //ローダーの追加
    public function addLoader(loader:Loader):Loader{ setListener(loader.contentLoaderInfo);_loaderNum++;return loader;}
    public function addURLLoader(loader:URLLoader):URLLoader{setListener(loader); _loaderNum++; return loader;}
    
    
    private function nullFunc():void{}
    private function setListener(loader:*):void{
        loader.addEventListener("open", onOpen);
        loader.addEventListener("complete", onComplete);
        loader.addEventListener("progress", update);
    }
    private function update(e:Event=null):void{
        bytesLoaded=0; bytesTotal=0;
        for each(var loadObj:Object in loaders){
            bytesLoaded += loadObj.bytesLoaded;
            bytesTotal += loadObj.bytesTotal;
        };
        sprite.progress(bytesLoaded/bytesTotal * _openNum/_loaderNum);
        if(bytesTotal!=0){ setText( "now loading... "+(bytesLoaded/bytesTotal* _openNum/_loaderNum*100).toFixed(1) ); }
    }
    private function onOpen(e:Event):void{ _openNum++;loaders.push(e.currentTarget); bytesTotal+=e.currentTarget.bytesTotal; }
    private function onComplete(e:Event):void{ _completedNum++;if(_loaderNum == _completedNum){ setText( "COMPLETE" );onLoaded(); } }
    private function setText(str:String):void{
        var b:BitmapData = text.bitmapData; var l:int = str.length; var position:int = b.width;
        b.lock();b.fillRect(b.rect,0x000000);
        for(var i:int=0;i<l;i++){
            var letterData:Array = LETTER[str.substr(l-i-1,1)];position-=letterData[0].length+1;
            for(var n:int=0;n<letterData.length;n++){ for(var m:int=0;m<letterData[n].length;m++){ 
                if(letterData[n][m]==1){b.setPixel32(m+position,n+1,0xFF000000);} 
            } }
        }
        b.unlock();
    }
}
//このスプライトを編集することでロード画面を変えることができる。
class ProgressSprite extends Sprite{
    private var mapData:BitmapData;
    private var sphereData:BitmapData;
    private var noizeData:BitmapData;
    private var bfRate:Number=0; //前の段階での進行度
    private var drawRate:Number=0;
    private var maxLevel:int = 5; 
    private var meter:Array = new Array();
    
    //コンストラクタ
    public function ProgressSprite(width:int,height:int):void{
        mapData = new BitmapData(width,height,true,0x00000000); 
        addChild(new Bitmap(mapData));
        for(var i:int=0;i<maxLevel;i++){
            meter[i]=0;
        }
        addEventListener("enterFrame",onFrame);
    }
    
    //ロードが進行したときに呼び出される。 rateはロードの進行度で0-1
    public function progress(rate:Number):void{
        bfRate = rate;
    }
    
    private function draw(rate:Number, level:int=0):void{
        var thick:int = mapData.height*(0.61803)/1.61803;
        var floor:int = 0;
        for(var i:int=1;i<level+1;i++){
            thick*=(0.61803)/1.61803;
            floor+=thick;
        }
        mapData.fillRect( new Rectangle(0,mapData.height-floor,mapData.width*rate,thick), 0x1000000*int(0xFF*(maxLevel-level+1)/(maxLevel)));
    }
    
    private function onFrame(e:Event):void{
        for(var i:int=0;i<maxLevel;i++){
            var n:int = Math.pow(2,i+2);
            meter[i]=(bfRate+ meter[i]*(n-1))/n;
            draw(meter[i],i);
        }
    }  
}