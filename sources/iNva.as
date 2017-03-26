//////////////////////////////////////////////////////
//  forked from Takema.Terai's flash on 2012-7-4  ////
//////////////////////////////////////////////////////
//  card_action  /////////////////////////////////////
//////////////////////////////////////////////////////

package {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.display.*;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import caurina.transitions.Tweener;
    import flash.system.LoaderContext;
    //import flash.motion.MatrixTransformer;
    import flash.geom.Matrix;
    import flash.geom.Transform;
    import flash.geom.ColorTransform;
    import flash.utils.*;
    
    [SWF(backGroundColor=0x000000, width=465, height=465, frameRate=30)]    

    public class Main extends Sprite {
        
        //set global property
        private var vy:int = 5;
        private var cardW:int = 255;
        private var color:ColorTransform = new ColorTransform(1.0, 1.0, 1.0, 1.0, cardW, cardW, cardW, 0);
        //timer
        private var delay:uint = 800;
        //const
        private static const MAIN_CARD_WIDTH:uint = 120;
        private static const MAIN_CARD_HEIGHT:uint = 144;
        private static const SUB_CARD_WIDTH:uint = 60;
        private static const SUB_CARD_HEIGHT:uint = 72;        
        private static const SUB_CARD_NUM:uint = 10; 
        
        //bitmap
        private var _bitmap:Bitmap;
        private var _bitmapData:BitmapData;
        private var screenWhite:Bitmap;        
        private var screenWhiteData:BitmapData;

        //maincard preload
        private var urlMainCard:String = "http://assets.wonderfl.net/images/related_images/f/fc/fcfb/fcfb1f18a586ad79fd30a5c08cb4f267e9714530";
        private var urlReqMainCard:URLRequest = new URLRequest(urlMainCard);
        private var main_card:Loader = new Loader();
        //subcard preload
        private var urlSubCard:String = "http://assets.wonderfl.net/images/related_images/c/c3/c3b9/c3b9c082c57786d6d70cd72f342b232942865a1c";
        //<img width="90" src="">
        private var urlReqSubCard:URLRequest = new URLRequest(urlSubCard);
        private var sub_card1:Loader = new Loader();
        private var sub_card2:Loader = new Loader();
        private var sub_card3:Loader = new Loader();
        private var sub_card4:Loader = new Loader();
        private var sub_card5:Loader = new Loader();
        private var sub_card6:Loader = new Loader();
        private var sub_card7:Loader = new Loader();
        private var sub_card8:Loader = new Loader();                        
        private var sub_card9:Loader = new Loader();
        private var sub_card10:Loader = new Loader();
        
        //bg preload
        private var urlBg:String = "http://assets.wonderfl.net/images/related_images/6/6a/6a39/6a39d24903a88ef0e43693fa953fb2aabe242387";
        private var urlReqBg:URLRequest = new URLRequest(urlBg);
        private var bg:Loader = new Loader();
        
        //mahoujin preload
        private var urlMahoujin:String = "http://assets.wonderfl.net/images/related_images/d/d3/d3a6/d3a65301bb89f0e7db4ea5b727224b8b944fba97";
        private var urlReqMahoujin:URLRequest = new URLRequest(urlMahoujin);
        private var mahoujin:Loader = new Loader();

        //lvup preload
        //png24
        //private var urlLvup:String = "http://assets.wonderfl.net/images/related_images/f/f6/f6c8/f6c85328f6e1b053267e07000a93943581d38f69";
        //png32
        private var urlLvup:String = "http://assets.wonderfl.net/images/related_images/e/ef/efdd/efdd32f0082c3456d2268d25c487a3fc1bb12d33";
        private var urlReqLvup:URLRequest = new URLRequest(urlLvup);
        private var lvup:Loader = new Loader();
        
        //kira preload
        //png32
        private var urlKira:String = "http://assets.wonderfl.net/images/related_images/3/31/3167/31679ab5ea5e6b984bd4476ca107be3bf2c37391";
        private var urlReqKira:URLRequest = new URLRequest(urlKira);
        private var kira:Loader = new Loader();
            
        //transform
        private var matMainCard:Matrix = main_card.transform.matrix;
        private var matLvup:Matrix = lvup.transform.matrix;
        private var sub_mat1:Matrix = sub_card1.transform.matrix;
        private var sub_mat2:Matrix = sub_card2.transform.matrix;
        
        
        /*********************************************************************************************************************************
         Main : setup item
        **********************************************************************************************************************************/
        public function Main(){
            //
            setWhiteScreen();
            setScreen();            
            setBg();
            setMahoujin();
            setLvup();
            setKira();
            //
            setupMainCard();
            setupSubCard();
        }
        
        //set White Screen
        private function setWhiteScreen():void{
            screenWhiteData = new BitmapData(465, 465, false, 0xffffff);
            screenWhite = addChild(new Bitmap(screenWhiteData, PixelSnapping.NEVER, false)) as Bitmap;
            //setChildIndex(screenWhite,5);
            removeChild(screenWhite);            
        }
        
        //set Black Screen
        private function setScreen():void{
            _bitmapData = new BitmapData(465, 465, false, 0x000000);
            _bitmap = addChild(new Bitmap(_bitmapData, PixelSnapping.NEVER, false)) as Bitmap;
            _bitmap.x = 0;
            setChildIndex(_bitmap,0);
        }
        
        //set bg
        private function setBg():void{
            bg.load(urlReqBg);
            addChild(bg);
            setChildIndex(bg,1);        
        }
                
        //set Mahoujin
        private function setMahoujin():void{
            mahoujin.contentLoaderInfo.addEventListener(Event.COMPLETE, onSetMahoujinComplete);
            mahoujin.load(urlReqMahoujin);
            addChild(mahoujin);
            setChildIndex(mahoujin,2);        
        }
        
        //init mahoujin property
        private function onSetMahoujinComplete(e:Event):void{
            //adjustment
            mahoujin.x = 24.5;
            mahoujin.y = 27;
            mahoujin.scaleX = 2;
            mahoujin.scaleY = 2;
        }
        
        //set levelup   
        private function setLvup():void{
            lvup.contentLoaderInfo.addEventListener(Event.COMPLETE, onSetLvupComplete);
            lvup.load(urlReqLvup);
            //addChild(lvup);
            lvup.transform.matrix = matLvup;
        }
        
        //init levelup property
        private function onSetLvupComplete(e:Event):void{
            //adjustment
            lvup.x = -7.5;
            lvup.y = 100;
            lvup.scaleX = 2;
            lvup.scaleY = 2;
        }
        
        //set kira
        private function setKira():void{
            kira.load(urlReqKira);
        }
        
        
        /*********************************************************************************************************************************
         1st action : set main card        
        **********************************************************************************************************************************/        
        // set main_card
        private function setupMainCard():void{
            main_card.contentLoaderInfo.addEventListener(Event.COMPLETE, onSetMainCardComplete);
            main_card.load(urlReqMainCard);
            addChild(main_card);
            //set center position
            matMainCard.translate(bg.stage.width/2, bg.stage.height/2);
            main_card.transform.matrix = matMainCard;
            
            // 1st action
            cardAppear(main_card);
        }
        
        // init main_card property
        private function onSetMainCardComplete(e:Event):void{
            main_card.x = bg.stage.width/2;
            main_card.y = bg.stage.height/2;
            main_card.width = 0;
            main_card.height = 0;
        }
        
        private function tweenMainCardCompleteHandler(main_card:Loader):void
        {
            main_card.addEventListener(Event.ENTER_FRAME, color_mUpdate);
        }        
        
        // main_card color update
        private function color_mUpdate(e:Event):void{
            //getting brightness -> 0
            if(color.redOffset > 0){
                color.redOffset-=15;
                color.greenOffset-=15;
                color.blueOffset-=15;
                main_card.transform.colorTransform = color;
            }
            else{
                //adjust////////////////////////////////////////////////////////
                color.redOffset=0;
                color.greenOffset=0;
                color.blueOffset=0;
                main_card.transform.colorTransform = color;
                ////////////////////////////////////////////////////////////////
                main_card.removeEventListener(Event.ENTER_FRAME, color_mUpdate);
                color.redOffset = cardW;
                color.greenOffset = cardW;
                color.blueOffset = cardW;
                main_card.addEventListener(Event.ENTER_FRAME, goto2ndAction);
            }
        }
        
        
        /*********************************************************************************************************************************
         2nd action : set sub_card       
        **********************************************************************************************************************************/        
        //goto2ndAction
        public function goto2ndAction(e:Event):void{
            //2nd action
            for (var i:uint=1; i <= SUB_CARD_NUM; i++){
                addChild(this["sub_card"+i]);
            }
        }

        // set sub_card
        private function setupSubCard():void{
            // sub card load;
            for (var i:uint=1; i <= SUB_CARD_NUM; i++){
                this["sub_card"+i].load(urlReqSubCard);
            }                        
            // card appear
            cardAppear(sub_card1);
        }
        
        // set sub_card finish 
        private function tweenSubCardCompleteHandler(sub_card10:Loader):void
        {
             sub_card10.addEventListener(Event.ENTER_FRAME, color_sUpdate);
        }                
        
        // sub_card color update
        private function color_sUpdate(e:Event):void{
            //getting brightness -> 0
            if(color.redOffset > 0){
                color.redOffset -= 15;
                color.greenOffset -= 15;
                color.blueOffset -= 15;
                for (var i:uint = 1; i <= SUB_CARD_NUM; i++){
                    this["sub_card"+i].transform.colorTransform = color;
                }
            }
            else{
                sub_card10.removeEventListener(Event.ENTER_FRAME, color_sUpdate);
                setTimeout(goto3rdAction, delay);
            }
        }
        
        
        /*********************************************************************************************************************************
         3rd action : sub card move center -> sub card remove -> all flash  
        **********************************************************************************************************************************/
        // goto3rdAction
        private function goto3rdAction():void{
           //sub card move center
           for (var i:uint=1; i <= SUB_CARD_NUM; i++){
               Tweener.addTween(this["sub_card"+i], {
                    //set adjustment
                    x: main_card.x + SUB_CARD_WIDTH/2,
                    y: main_card.y + SUB_CARD_HEIGHT/2,
                    time: 0.5,
                    transition: "easeOutCubic",
                    onComplete: tweenSubCardMovCompleteHandler,
                    onCompleteParams: [this["sub_card"+i]]
                });
           }
        }
        
        private function tweenSubCardMovCompleteHandler(sub_card10:Loader):void{
            for (var i:uint=1; i <= SUB_CARD_NUM; i++){
                (this["sub_card"+i]).visible = false;
            }
            addChild(screenWhite);
            Tweener.addTween(screenWhite, {                   
                    alpha: 0, 
                    time: 0.3, 
                    transition: "linear", 
                    delay: 0.3, 
                    onComplete: go4th//;;goto4thAction
                });
        }
        
        //;;
        private var go4thFlag:Boolean = false;
        private function go4th():void{
            if(!go4thFlag){
                goto4thAction();
                go4thFlag = true;
            }

        }
            
            
        
        
        /*********************************************************************************************************************************
         4th action : main card big -> lvup appear -> kirakira appear  
        **********************************************************************************************************************************/
        // goto4thAction
        private function goto4thAction():void{
            Tweener.addTween(main_card, {
                    x: bg.stage.width/2 - 80,
                    y: bg.stage.height/2 - 92,
                    width: MAIN_CARD_WIDTH + 40,
                    height: MAIN_CARD_HEIGHT + 40,
                    time: 0.5,
                    transition: "easeInOutBack", 
                    delay: 0.2, 
                    onComplete: allFlash
                }); 
        }
        
        //allFlash       
        private function allFlash():void{
            Tweener.addTween(screenWhite, {
                    alpha: 1, 
                    time: 0.1, 
                    transition: "linear"
                    //delay: 0.3
                });
            Tweener.addTween(screenWhite, {
                    alpha: 0, 
                    time: 0.5, 
                    transition: "linear",
                    delay: 0.1,
                    onStart: lvupAppear
                });
        }
        
        // lvup appear
        private function lvupAppear():void{
            addChild(lvup);
            setChildIndex(lvup, numChildren - 4);
            Tweener.addTween(lvup, {
                    scaleX: 2,
                    scaleY: 2,
                    alpha: 0, 
                    time: 1, 
                    transition: "linear",
                    delay: 0.2,
                    onStart: kiraSetProperty
                });
        }
        
        // set kirakira property : random
        private function kiraSetProperty():void{
            var kiraX:uint = Math.floor(Math.random() * (bg.stage.width - kira.width));
            var kiraY:uint = Math.floor(Math.random() * (bg.stage.height - kira.height));
            addChild(kira);
            kira.alpha = 1;
            kiraAppear(kiraX, kiraY);
        }
        
        // kira appear
        private function kiraAppear(kiraX:uint, kiraY:uint):void{
            kira.x = kiraX;
            kira.y = kiraY;
            Tweener.addTween(kira, {
                    x: kiraX,
                    y: kiraY,
                    alpha: 1, 
                    time: 0.3, 
                    transition: "linear"
                });
            Tweener.addTween(kira, {
                    x: kiraX,
                    y: kiraY,
                    alpha: 0, 
                    time: 0.2, 
                    transition: "linear",
                    onComplete: kiraRemove
                });
        }
        
        //kira remove
        private function kiraRemove():void{
            removeChild(kira);
            kiraSetProperty();
        }


        /*********************************************************************************************************************************
         common function        
        **********************************************************************************************************************************/                


        //cardAppear
        public function cardAppear(card:Loader):void{
            //main_card appear
            if(card == main_card){
                Tweener.addTween(card, {
                    //set adjustment
                    x: bg.stage.width/2 - 60,
                    y: bg.stage.height/2 - 72,
                    width: MAIN_CARD_WIDTH,
                    height: MAIN_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                    onComplete: tweenMainCardCompleteHandler,
                    onCompleteParams: [main_card]
                });
            }
            //sub_card appear
            else if(card == sub_card1){
                Tweener.addTween(sub_card1, {
                    //set adjustment
                    x: main_card.x - 27,
                    y: main_card.y - 36 - 180,
                    width: SUB_CARD_WIDTH,
                    height: SUB_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                   // onComplete: tweenSubCardCompleteHandler,
                    onCompleteParams: [sub_card1]
                });
                Tweener.addTween(sub_card2, {
                    //set adjustment
                    x: main_card.x + 80,
                    y: main_card.y - 180,
                    width: SUB_CARD_WIDTH,
                    height: SUB_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                    //onComplete: tweenSubCardCompleteHandler,
                    onCompleteParams: [sub_card2]
                });
                Tweener.addTween(sub_card3, {
                    //set adjustment
                    x: main_card.x + 160,
                    y: main_card.y - 90,
                    width: SUB_CARD_WIDTH,
                    height: SUB_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                    onComplete: tweenSubCardCompleteHandler,
                    onCompleteParams: [sub_card3]
                });
                Tweener.addTween(sub_card4, {
                    //set adjustment
                    x: main_card.x + 160,
                    y: main_card.y + 20,
                    width: SUB_CARD_WIDTH,
                    height: SUB_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                    //onComplete: tweenSubCardCompleteHandler,
                    onCompleteParams: [sub_card4]
                });
                Tweener.addTween(sub_card5, {
                    //set adjustment
                    x: main_card.x + 80,
                    y: main_card.y + main_card.height + (180 - SUB_CARD_HEIGHT),
                    width: SUB_CARD_WIDTH,
                    height: SUB_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                    //onComplete: tweenSubCardCompleteHandler,
                    onCompleteParams: [sub_card5]
                });
                Tweener.addTween(sub_card6, {
                    //set adjustment
                    x: main_card.x - 27,
                    y: main_card.y + main_card.height + (180 - SUB_CARD_HEIGHT) + 36,
                    width: SUB_CARD_WIDTH,
                    height: SUB_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                    //onComplete: tweenSubCardCompleteHandler,
                    onCompleteParams: [sub_card6]
                });
                Tweener.addTween(sub_card7, {
                    //set adjustment
                    x: main_card.x - 80 - SUB_CARD_WIDTH,
                    y: main_card.y + main_card.height + (180 - SUB_CARD_HEIGHT),
                    width: SUB_CARD_WIDTH,
                    height: SUB_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                    //onComplete: tweenSubCardCompleteHandler,
                    onCompleteParams: [sub_card7]
                });
                Tweener.addTween(sub_card8, {
                    //set adjustment
                    x: main_card.x - 160 - SUB_CARD_WIDTH,
                    y: main_card.y + 20,
                    width: SUB_CARD_WIDTH,
                    height: SUB_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                    //onComplete: tweenSubCardCompleteHandler,
                    onCompleteParams: [sub_card8]
                });
                Tweener.addTween(sub_card9, {
                    //set adjustment
                    x: main_card.x - 160 - SUB_CARD_WIDTH,
                    y: main_card.y - 90,
                    width: SUB_CARD_WIDTH,
                    height: SUB_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                    //onComplete: tweenSubCardCompleteHandler,
                    onCompleteParams: [sub_card9]
                });
                Tweener.addTween(sub_card10, {
                    //set adjustment
                    x: main_card.x - 80 - SUB_CARD_WIDTH,
                    y: main_card.y - 180,
                    width: SUB_CARD_WIDTH,
                    height: SUB_CARD_HEIGHT,
                    time: 0.3,
                    transition: "easeInOutSine",
                    onComplete: tweenSubCardCompleteHandler,
                    onCompleteParams: [sub_card10]
                });                
            }
        }        
        
        
        /*********************************************************************************************************************************
         during the adjustment        
        **********************************************************************************************************************************/
        
        
    }
}
// 以下の画像素材は自由に使っていただいて構いません
// http://jsdo.it/img/event/spec/vol5/material_fl/bg.jpg
// http://jsdo.it/img/event/spec/vol5/material_fl/bg02.jpg
// http://jsdo.it/img/event/spec/vol5/material_fl/card01.jpg
// http://jsdo.it/img/event/spec/vol5/material_fl/card02.jpg
// http://jsdo.it/img/event/spec/vol5/material_fl/kira.png
// http://jsdo.it/img/event/spec/vol5/material_fl/kira02.png
// http://jsdo.it/img/event/spec/vol5/material_fl/lvup.png
// http://jsdo.it/img/event/spec/vol5/material_fl/lvup02.png
// http://jsdo.it/img/event/spec/vol5/material_fl/magic.png 