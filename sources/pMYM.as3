//まずはClick!
package
{
    import com.actionsnippet.qbox.*;
    
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    
    import org.libspark.betweenas3.*;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.*;
    import org.si.sion.*;
    import org.si.sion.utils.*;
    
    [SWF(backgroundColor=0, width=465, height=465, frameRate=30)]
    public class QBox2D_Sion extends MovieClip
    {
        //SiON
        public var driver:SiONDriver = new SiONDriver();
        public var presetVoice:SiONPresetVoice = new SiONPresetVoice();
        public var voices:Vector.<SiONVoice> = new Vector.<SiONVoice>(16);
        public var notes :Vector.<int> = Vector.<int>([36,48,60,72, 43,48,55,60, 65,67,70,72, 77,79,82,84]);
        //定数
        private const SCALE:int = 30, BALL:int=16, W:int=465, H:int=465, R:int = 3;
        //色
        public static const colorAry:Array = [16711680,16712704,16713728,16715008,16716032,16717056,16718080,16719360,16720384,16721408,16722432,16723712,16724736,16725760,16727040,16728064,16729088,16730112,16731392,16732416,16733440,16734464,16735744,16736768,16737792,16738816,16740096,16741120,16742144,16743168,16744448,16745472,16746496,16747520,16748800,16749824,16750848,16751872,16753152,16754176,16755200,16756224,16757504,16758528,16759552,16760576,16761856,16762880,16763904,16764928,16766208,16767232,16768256,16769280,16770560,16771584,16772608,16773632,16774912,16775936,16776960,16514816,16187136,15924992,15662848,15400704,15073024,14810880,14548736,14286592,13958912,13696768,13434624,13172480,12844800,12582656,12320512,12058368,11796224,11468544,11206400,10944256,10682112,10354432,10092288,9830144,9568000,9240320,8978176,8716032,8453888,8126208,7864064,7601920,7339776,7012096,6749952,6487808,6225664,5897984,5635840,5373696,5111552,4783872,4521728,4259584,3997440,3669760,3407616,3145472,2883328,2555648,2293504,2031360,1769216,1441536,1179392,917248,655104,327424,65280,65284,65288,65293,65297,65301,65306,65310,65314,65318,65322,65327,65331,65335,65340,65344,65348,65352,65356,65361,65365,65369,65374,65378,65382,65386,65390,65395,65399,65403,65408,65412,65416,65420,65425,65429,65433,65437,65442,65446,65450,65454,65459,65463,65467,65471,65475,65480,65484,65488,65493,65497,65501,65505,65509,65514,65518,65522,65527,65531,65535,64511,63487,62207,61183,60159,58879,57855,56831,55807,54783,53503,52479,51455,50175,49151,48127,47103,46079,44799,43775,42751,41727,40447,39423,38399,37375,36095,35071,34047,33023,31743,30719,29695,28415,27391,26367,25343,24319,23039,22015,20991,19711,18687,17663,16639,15615,14335,13311,12287,11007,9983,8959,7935,6911,5631,4607,3583,2303,1279,255,262399,524543,852223,1114367,1376511,1638655,1966335,2228479,2490623,2818303,3080447,3342591,3604735,3932415,4194559,4456703,4718847,4980991,5308671,5570815,5832959,6095103,6422783,6684927,6947071,7274751,7536895,7799039,8061183,8388863,8651007,8913151,9175295,9437439,9765119,10027263,10289407,10617087,10879231,11141375,11403519,11731199,11993343,12255487,12517631,12779775,13107455,13369599,13631743,13893887,14221567,14483711,14745855,15073535,15335679,15597823,15859967,16187647,16449791,16711935,16711931,16711927,16711922,16711918,16711914,16711910,16711905,16711901,16711897,16711892,16711888,16711884,16711880,16711875,16711871,16711867,16711863,16711859,16711854,16711850,16711846,16711842,16711837,16711833,16711829,16711824,16711820,16711816,16711812,16711808,16711803,16711799,16711795,16711791,16711786,16711782,16711778,16711773,16711769,16711765,16711761,16711756,16711752,16711748,16711744,16711740,16711735,16711731,16711727,16711723,16711718,16711714,16711710,16711705,16711701,16711697,16711693,16711688,16711684];
        //QBOX2D
        private var sim:QuickBox2D, contact:QuickContacts;
        //オブジェクト管理用
        private var fixedObjectList:Vector.<QuickObject> = new Vector.<QuickObject>(), moveObjectList:Vector.<QuickObject> = new Vector.<QuickObject>();
        //どの部分の音を鳴らすか。
        private var beatCount:int = 0;
        public function QBox2D_Sion()
        {
            //音の設定
            var percusVoices:Array = presetVoice["valsound.percus"];
            voices[0] = percusVoices[0]; 
            voices[1] = percusVoices[27];
            voices[2] = percusVoices[16];
            voices[3] = percusVoices[22];
            for (i=4; i<16; i++) voices[i] = presetVoice["valsound.bass"+(i*2).toString()]; 
            
            sim = new QuickBox2D(this);
            sim.setDefault({lineColor:0xFFFFFF, fillColor:0xFFFFFF});
            
            //固定オブジェクトの配置
            for(var i:int = 0; i < BALL; i++){
                for(var j:int = 0; j < BALL; j++){
                    var color:uint = colorAry[int(360/BALL)*j];
                    var xx:Number = (i+0.5*j+0.25)*W/SCALE/BALL, yy:Number = (j+0.25)*H/SCALE/BALL;
                    if(xx > W/SCALE) xx=xx-W/SCALE;
                    var obj:QuickObject = sim.addCircle({x:xx, y:yy, radius:R/SCALE, fillColor:color, density:0});
                    createGraphics(obj, color);
                    fixedObjectList.push(obj);
                    obj.userData.alpha=0.5;
                }
            }
            
            //衝突イベントの登録
            contact = sim.addContactListener();
            contact.addEventListener(QuickContacts.ADD, onContact);
            
            //シュミレーションスタート
            sim.start();
            
            driver.setTimerInterruption(1, beat);
            driver.play();
                        
            stage.addEventListener(MouseEvent.CLICK, onClick);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        //音を鳴らす
        private function beat():void{
            for(var i:int = beatCount*BALL; i < (beatCount+1)*BALL; i++)
                if(fixedObjectList[i].userData.alpha == 1){ 
                    driver.noteOn(notes[i%BALL], voices[i%BALL], 1);
                    var t:ITween = BetweenAS3.to(fixedObjectList[i].userData, {scaleX:2, scaleY:2}, 0.25, Sine.easeOut);
                    t.onComplete = tween;
                    t.onCompleteParams = [fixedObjectList[i].userData];
                    t.play();
                }
            beatCount=(beatCount+1)%BALL;
        }
        
        private function tween(sp:Sprite):void{
            BetweenAS3.to(sp, {scaleX:1, scaleY:1}, 0.25, Sine.easeIn).play();
        }
        
        private function createGraphics(obj:Object, color:uint):void{
            obj.userData.graphics.clear();
            obj.userData.graphics.lineStyle(3, 0xFFFFFF);
            obj.userData.graphics.drawCircle(0,0,R);
            obj.userData.filters = [new GlowFilter(color, 1, 16, 16, 4, 2)];
            obj.userData.blendMode = BlendMode.ADD;
        }
        
        //動くオブジェクトの生成
        private function onClick(e:MouseEvent):void{
            var obj:QuickObject = sim.addCircle({x:mouseX/SCALE, y:mouseY/SCALE, radius:R*1.5/SCALE, fillColor:0xFFFFFF});
            createGraphics(obj, 0xFFFFFF);
            moveObjectList.push(obj);
        }
        
        //衝突時の処理
        private function onContact(e:Event):void{
            var obj:Array=[];
            //衝突した物体を取得
            for(var i:int = 0; i < BALL*BALL; i++){
                if(contact.inCurrentContact(fixedObjectList[i])){
                    obj.push(fixedObjectList[i]);
                }
            }
            
            //動くオブジェ同士が衝突した場合
            if(obj.length==0){
                for(i = 0; i < moveObjectList.length; i++)
                    if(contact.inCurrentContact(moveObjectList[i])) obj.push(fixedObjectList[i]);
            }
            //動くオブジェが固定オブジェに衝突
            else{
                //波紋っぽい円の作成
                var sp:Sprite = new Sprite();
                sp.graphics.lineStyle(2, obj[0].params.fillColor);
                sp.graphics.drawCircle(0,0,15);
                sp.x = obj[0].x*SCALE;
                sp.y = obj[0].y*SCALE;
                if(obj[0].userData.alpha == 0.5) obj[0].userData.alpha = 1;
                else obj[0].userData.alpha = 0.5;
                sp.filters = [new BlurFilter()];
                sp.scaleX = sp.scaleY = 0;
                addChild(sp);
                //Scale 0 -> 2
                var t:ITween = BetweenAS3.to(sp, {scaleX:2, scaleY:2, alpha:0}, 0.5);
                t.onComplete = tweenComp;
                t.onCompleteParams = [sp];
                t.play();
            }
        }
        
        //Tween後の削除処理
        private function tweenComp(sp:Sprite):void{
            removeChild(sp); sp = null;
        }
        
        private function onEnterFrame(e:Event):void{
            graphics.clear();
            graphics.beginFill(0);
            graphics.drawRect(0,0,465,465);
            graphics.endFill();
            var obj:QuickObject;
            for(var i:int = 0; i < moveObjectList.length; i++){
                obj = moveObjectList[i];
                //範囲外に出たら反対側へ
                if(obj.x < -R/SCALE) obj.x = W/SCALE;
                else if(obj.x > W/SCALE+R/SCALE) obj.x = 0;
                if(obj.y < -R/SCALE) obj.y = H/SCALE;
                else if(obj.y > H/SCALE+R/SCALE) obj.y = 0;
            }
        }
    }
}
