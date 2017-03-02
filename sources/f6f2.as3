/**
 * Copyright hacker_9vjnvtdz ( http://wonderfl.net/user/hacker_9vjnvtdz )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/f6f2
 */

/*
    attak
*/
package
{
    import com.bit101.components.PushButton;
    
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.Timer;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    [SWF(width="465", height="465", frameRate="30", backgroundColor="#FFFFFF")]

    public class FlashTest extends MovieClip
    {
  
        private var imgUrl:String="http://assets.wonderfl.net/images/related_images/6/6d/6d2a/6d2aac9165308e05d07f52232f99bfe9d52a06fb"; // モンスターURL
//その他のモンスターのパス
//http://assets.wonderfl.net/images/related_images/9/9a/9a67/9a674310835d956620db269594b14241d8c079ba
//http://assets.wonderfl.net/images/related_images/5/57/5728/5728bb5057da70c62a2bff824fac59cf139bcb44
        
        
        
        private var loader:Loader; // モンスター表示用コンテナ
        private var attackButton:PushButton; // 攻撃ボタン
        private var hpView:HpView; // HP表示
        private var blinkTimer:Timer; // 攻撃エフェクト用のタイマー
        private var hp:int=100; // モンスターのHP
        
        public function FlashTest()
        {
            // タイマーを初期化する
            blinkTimer=new Timer(80, 4);
            blinkTimer.addEventListener("timer", timerHandler);

            // 攻撃ボタンを配置する
            attackButton = new PushButton(this, 0, 0, "Attack", atc);
            attackButton.y=(stage.stageHeight - attackButton.height) / 2 + 200;
            attackButton.x=(stage.stageWidth - attackButton.width) / 2;

            // モンスターのHPを表示する
            hpView=new HpView(hp, hp);
            hpView.y=attackButton.y - hpView.height;
            hpView.x=stage.stageWidth/2-hpView.width/2;
            addChild(hpView);

            // モンスターをロードする
            loader=new Loader();
            var context:LoaderContext=new LoaderContext(true);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, picsOnComplete);
            loader.load(new URLRequest(imgUrl), context);
            addChild(loader);
        }
        
        // モンスターのロード完了時の処理
        private function picsOnComplete(eventObj:Event):void
        {
            // モンスターをステージ中央に配置する
            loader.x=stage.stageWidth / 2 - loader.width / 2;
            loader.y=stage.stageHeight / 2 - loader.height / 2;
        }

        // 攻撃処理
        private function atc(e:MouseEvent):void
        {
            // ダメージを計算する
            var r:int=Math.floor(Math.random() * 10) + 10;
            hp-=r;
            // 攻撃エフェクト
            if (hp < 1) // モンスター死亡時
            {
                //win表示
                var winText=new TextField();
               var format:TextFormat=new TextFormat();
               format.size = 100;
                winText.autoSize = TextFieldAutoSize.CENTER;
                winText.defaultTextFormat=format;
                 winText.text="win";
                addChild(winText);
                 winText.x=loader.x;
                 winText.y=loader.y;       
                
                hp=0;
                // モンスターを非表示にする
                loader.visible=false;
            }
            else // 攻撃成功時
            {
                // 攻撃エフェクトを開始する
                blinkTimer.reset();
                blinkTimer.start();
            }
            // HP表示を更新する
            hpView.update(hp);
        }
        
        // タイマー処理
        private function timerHandler(event:TimerEvent):void
        {
            if (blinkTimer.currentCount % 2 == 1)
            {
                loader.visible=false;
            }
            else
            {
                loader.visible=true;
            }
        }
    }
}

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

// HP表示
class HpView extends Sprite
{
    private var _text:TextField;
    private var _hpMax:int;

    function HpView(hp:int, hpMax:int)
    {
        _hpMax=hpMax;
        
        _text=new TextField();
        var format:TextFormat=new TextFormat();
        _text.autoSize = TextFieldAutoSize.LEFT;
        _text.defaultTextFormat=format;
        addChild(_text);

        update(hp);
    }
    
    // HP表示を更新する
    public function update(hp:int):void
    {
        _text.text="HP : " + String(hp) + "/" + _hpMax;
    }
}