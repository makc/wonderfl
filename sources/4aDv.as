// forked from shohei909's NowLoading

//読み込み用のswfとして"Sketch of Voronoi"を使用させていただきました。
//http://wonderfl.net/c/iNy0

 /*
 * 読み込み用の音楽はこちらを使用させていただきました。
 * Free Music Archive: Digi G'Alessio - ekiti son feat valeska - april deegee rmx 
 * http://freemusicarchive.org/music/Digi_GAlessio/Love_Beats_and_Pina_Coladas/phoke56-_-08-_-ekiti_son_feat_valeska_-_april_deegee_rmx
 * license :  http://creativecommons.org/licenses/by-nc-nd/3.0/
 *            http://creativecommons.org/licenses/by-nc-nd/3.0/deed.ja
 */
 
package {
    import flash.media.Sound;
    import flash.system.LoaderContext;
    import flash.text.TextFormat;
    import flash.text.TextField;
    import flash.net.URLRequest;
    import flash.display.Sprite;
    import flash.display.Loader;
    import flash.net.URLLoader;
    import net.wonderfl.utils.FontLoader;
    import caurina.transitions.Tweener;
    //import org.libspark.nowloading;
    
    public class FlashTest extends Sprite {
        private var fontLoader:FontLoader = new FontLoader();
        private var fontLoader2:FontLoader = new FontLoader();
        private var sound:Sound = new Sound();
        private var loader:Loader = new Loader();
        private var TextLoader:URLLoader = new URLLoader();
        
        private var nowLoading:NowLoading = new NowLoading(onLoaded);
         
        public function FlashTest(){
            
            //ロードを開始する
            fontLoader.load( "Azuki" );
            fontLoader2.load( "Sazanami" );
            loader.load( new URLRequest("http://swf.wonderfl.net/swf/usercode/8/83/83c0/83c0fa8eb9e85ce32eccd202190d426f98a22cde.swf") );
            TextLoader.load( new URLRequest("http://spheresofa.net/wonderfl/test.txt") );
            sound.load( new URLRequest("http://level0.kayac.com/images/murai/Digi_GAlessio_-_08_-_ekiti_son_feat_valeska_-_april_deegee_rmx.mp3") );
            
            //ローダーを登録する
            nowLoading.addLoader(fontLoader.loader);
            nowLoading.addLoader(fontLoader2.loader);
            nowLoading.addLoader(loader);
            nowLoading.addURLLoader(TextLoader);
            nowLoading.addSound(sound);
            
            addChild( nowLoading );
        }
        
        //ロードが完了したときに呼び出す
        private function onLoaded():void{
            //ロード画面を消す
            Tweener.addTween( nowLoading,{alpha:0,time:3,onComplete:function():void{removeChild(nowLoading)} });
            
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
            
            sound.play(0, 9999);
        }
    }
}


//NowLoadingライブラリ===============================================================
import flash.display.Loader;
import flash.media.Sound;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.net.URLLoader;
class NowLoading extends Sprite {
    static public const COMPLETE:String = "complete";
    private var loaders:Vector.<Object> = new Vector.<Object>;
    private var sprite:ProgressSprite;
    private var _loaderNum:uint=0, _completedNum:uint=0, _openNum:uint=0;
    private var text:Bitmap;
    private var onLoaded:Function;
    
    private var LETTER:Object = {
        "1":[[0,1,1],[0,0,1],[0,0,1],[0,0,1],[0,0,1]],"2":[[1,1,1],[0,0,1],[0,1,1],[1,0,0],[1,1,1]],"3":[[1,1,1],[0,0,1],[1,1,1],[0,0,1],[1,1,1]],"4":[[1,0,1],[1,0,1],[1,0,1],[1,1,1],[0,0,1]],"5":[[1,1,1],[1,0,0],[1,1,1],[0,0,1],[1,1,1]],
        "6":[[1,1,1],[1,0,0],[1,1,1],[1,0,1],[1,1,1]],"7":[[1,1,1],[0,0,1],[0,0,1],[0,0,1],[0,0,1]],"8":[[1,1,1],[1,0,1],[1,1,1],[1,0,1],[1,1,1]],"9":[[1,1,1],[1,0,1],[1,1,1],[0,0,1],[0,0,1]],"0":[[1,1,1],[1,0,1],[1,0,1],[1,0,1],[1,1,1]],
        ".":[[0],[0],[0],[0],[1]]," ":[[0],[0],[0],[0],[0]],"n":[[0,0,0],[0,0,0],[1,1,1],[1,0,1],[1,0,1]],"w":[[0,0,0,0,0],[0,0,0,0,0],[1,0,1,0,1],[1,0,1,0,1],[1,1,1,1,1]],"o":[[0,0,0],[0,0,0],[1,1,1],[1,0,1],[1,1,1]],
        "a":[[0,0,0],[0,0,1],[1,1,1],[1,0,1],[1,1,1]],"l":[[1],[1],[1],[1],[1]],"i":[[1],[0],[1],[1],[1]],"d":[[0,0,1],[0,0,1],[1,1,1],[1,0,1],[1,1,1]],"g":[[0,0,0],[0,0,0],[1,1,1],[1,0,1],[1,1,1],[0,0,1],[1,1,1]],
        "C":[[1,1,1],[1,0,0],[1,0,0],[1,0,0],[1,1,1]],"O":[[1,1,1],[1,0,1],[1,0,1],[1,0,1],[1,1,1]],"M":[[1,1,1,1,1],[1,0,1,0,1],[1,0,1,0,1],[1,0,1,0,1],[1,0,1,0,1]],"P":[[1,1,1],[1,0,1],[1,1,1],[1,0,0],[1,0,0]],
        "T":[[1,1,1],[0,1,0],[0,1,0],[0,1,0],[0,1,0]],"L":[[1,0,0],[1,0,0],[1,0,0],[1,0,0],[1,1,1]],"E":[[1,1,1],[1,0,0],[1,1,1],[1,0,0],[1,1,1]]
    }
    
    public function NowLoading( onLoaded:Function = null, progressSprite:ProgressSprite = null ){
        this.onLoaded = onLoaded;
        if ( progressSprite == null ) {
            sprite = new ProgressSprite();
        }else{
            sprite = progressSprite;
        }
        
        text = new Bitmap( new BitmapData(30 * 4, 8, true, 0x00000000 ) ); 
        
        addChild(sprite).blendMode = "invert"; 
        addChild(text).blendMode = "invert"; 
        
        addEventListener( Event.ADDED_TO_STAGE, init );
    }
    
    private function init(e:Event):void{
        removeEventListener( Event.ADDED_TO_STAGE, init );
        with (text) { 
            scaleX = scaleY = 1; 
            x = stage.stageWidth - text.width;
            y = stage.stageHeight - text.height;
        }
    }
    
    public function addLoader(loader:Loader):Loader{ setListener(loader.contentLoaderInfo);_loaderNum++;return loader;}
    public function addURLLoader(loader:URLLoader):URLLoader{setListener(loader); _loaderNum++; return loader;}
    public function addSound(sound:Sound):Sound{setListener(sound); _loaderNum++; return sound;}
    
    private function setListener(loader:*):void{
        loader.addEventListener("open", onOpen);
        loader.addEventListener("complete", onComplete);
        loader.addEventListener("progress", update);
    }
    
    private function update(e:Event=null):void{
        var rate:Number = 0;
        for each(var loadObj:Object in loaders) {
            if( loadObj.bytesLoaded > 0 ){
                rate += loadObj.bytesLoaded / loadObj.bytesTotal / _loaderNum;
            }
        }
        sprite.progress( rate );
        setText( "now loading... " + ( rate * 100 ).toFixed(1) );
    }
    
    private function onOpen(e:Event):void { 
        e.currentTarget.removeEventListener("open", onOpen); 
        _openNum++;
        loaders.push(e.currentTarget);
    }
    
    private function onComplete(e:Event):void {  
        e.currentTarget.removeEventListener("complete", onComplete);
        e.currentTarget.removeEventListener("progress", update);
        _completedNum++; 
        if (_loaderNum == _completedNum) { 
            setText( "COMPLETE" );
            if ( onLoaded != null ) { onLoaded() } 
        } 
    }
    
    
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
class ProgressSprite extends Sprite{
    public function progress(rate:Number):void {
        if( stage != null ){
            graphics.clear();
            graphics.beginFill( 0x000000, 1 )
            graphics.drawRect( 0, stage.stageHeight - 11, rate * stage.stageWidth, 11);
        }
    }
}
//NowLoadingライブラリここまで==============================================================