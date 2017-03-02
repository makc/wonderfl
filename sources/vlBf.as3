package
{
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.text.*;
    import flash.utils.*;
    
    public class FlashTest extends MovieClip
    {

        var imgUrl:String = "http://wonderfl.net/static/tmp/related_images/be0e41638d4c32df322e8db66d346cbdfad011b8m";
        var urlReq:URLRequest = new URLRequest(imgUrl);
        var loader:Loader = new Loader();
        var hp:int=100;
        var hpMax:String=String(hp);
        var format:TextFormat=new TextFormat();
        var a_mc:MovieClip = new MovieClip();
        var text_hp = new TextField();
        var hp_mc:MovieClip = new MovieClip();
        var blinkTimer:Timer = new Timer(80,4);
            [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#00FFFF")]
        
        public function FlashTest()
        {
            //super();
            var text_atc:TextField = new TextField();
            
            blinkTimer.addEventListener("timer", timerHandler);
            format.align=TextFormatAlign.CENTER;
            
            // テキストフィールドの設定
            text_atc.border = true;
            text_atc.mouseEnabled = false;
            text_atc.width  = 50;
            text_atc.height = 20;
            text_atc.defaultTextFormat = format;
            text_atc.text = "攻撃";
            
            a_mc.addChild(text_atc);
            
            a_mc.buttonMode=true;
            addChild(a_mc);
            a_mc.addEventListener(MouseEvent.CLICK, atc);


            
            a_mc.y = (stage.stageHeight-a_mc.height)/2+200;
            a_mc.x = (stage.stageWidth-a_mc.width)/2;
            


            
            
            
            
            text_hp.width  = 60;
            text_hp.height = 20;
            text_hp.text ="HP"+ String(hp)+"/"+hpMax;
            text_hp.defaultTextFormat = format;
            hp_mc.addChild(text_hp);
            addChild(hp_mc);

            
            
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, picsOnComplete);
            loader.load(urlReq);
            addChild(loader);
            
        }
        
        
        private function picsOnComplete(eventObj:Event):void{
            
            loader.x = loader.content.width/2;
            loader.y = (stage.stageHeight-loader.content.height)/2;
            hp_mc.y =  a_mc.y-hp_mc.height;
            hp_mc.x = a_mc.x+a_mc.width-hp_mc.width;
            
        }
        
        
        
        private function timerHandler(event:TimerEvent):void {
            // ここに必要な処理を記述
            if(blinkTimer.currentCount%2==1){
                loader.visible=false;
            }else{
                loader.visible=true;
            }
    
        }
        
        private function atc(e:MouseEvent):void {
            var r:int = Math.floor(Math.random() * 10)+10;
            hp-=r;
            if(hp<0){
                hp=0;
                loader.visible=false;
            }else{
               blinkTimer.reset();
                blinkTimer.start();
            }
            text_hp.text= "HP"+String(hp)+"/"+hpMax;
        }
    }
}