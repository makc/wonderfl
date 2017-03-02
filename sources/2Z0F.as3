// forked from Kwoon's ActionPainting
// 2011-03-17 14:17:27
package {
    import flash.filters.DisplacementMapFilterMode;
    import flash.filters.DisplacementMapFilter;
    import flash.filters.BlurFilter;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    
    public class ActionPainting extends Sprite {
        private const WIDTH:int = 465;
        private const HEIGHT:int = 465;
        
        private var pArr:Array = [];
        private var container:Sprite = new Sprite();
        private var bmpd:BitmapData = new BitmapData(WIDTH, HEIGHT, true, 0x0);
        private var bmp:Bitmap = new Bitmap(bmpd);
        private var blurFilter:BlurFilter = new BlurFilter(2.2, 2.2, 2);
        private var rect:Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
        private var point:Point = new Point();
        
        private var redOffset:int = Math.random()*300 - 100;
        private var greenOffset:int = Math.random()*300 - 100;
        private var blueOffset:int = Math.random()*300 - 100;
        
        private var cTr:ColorTransform = new ColorTransform(1, 1, 1, 1, redOffset, greenOffset, blueOffset);
        
        private var snd:C3_C = new C3_C();
        
        public function ActionPainting() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            this.graphics.beginFill(0xfffffff);
            this.graphics.drawRect(0, 0, WIDTH, HEIGHT);
            this.graphics.endFill();
            
            addPtc();
            
            var map:BitmapData = new BitmapData(WIDTH, HEIGHT);
            map.perlinNoise(84, 84, 5, Math.random()*100, false, true, 1, true);
            bmp.filters = [new DisplacementMapFilter(map, point, 1, 1, 64, 64, DisplacementMapFilterMode.CLAMP)];
            
            addEventListener(Event.ENTER_FRAME, enterFrame);
            stage.addEventListener(MouseEvent.CLICK, mouseClick);
        }

        private function addPtc():void{
            var pCount:uint = 8;
            while(pCount--){
                var p:Ptc = new Ptc(6+Math.random()*14);
                p.x = int(Math.random()*WIDTH);
                p.y = int(Math.random()*HEIGHT);
                container.addChild(p);
                pArr.push(p);
            }
            addChild(bmp);
        }

        private function enterFrame(evt:Event):void
        {
            var mx:Number=0, my:Number=0;
            
            var num:uint = pArr.length;
            for(var i:int =0 ; i < num; ++i){
                var p:Ptc = pArr[i];
                p.process();
                
                mx += p.x / WIDTH;
                my += p.y / HEIGHT;
            }
            snd.r0 = mx/8;
            snd.r1 = my/8;
               
            /*
            if(redOffset !== cTr.redOffset){
                (redOffset>cTr.redOffset)?(cTr.redOffset++):(cTr.redOffset--);
            }else{
                redOffset = Math.random()*300 - 100;
            }
            if(greenOffset !== cTr.greenOffset){
                (greenOffset>cTr.greenOffset)?(cTr.greenOffset++):(cTr.greenOffset--);
            }else{
                greenOffset = Math.random()*300 - 100;
            }
            if(blueOffset !== cTr.blueOffset){
                (blueOffset>cTr.blueOffset)?(cTr.blueOffset++):(cTr.blueOffset--);
            }else{
                blueOffset = Math.random()*300 - 100;
            }*/
            
            bmpd.draw(container);
            bmpd.applyFilter(bmpd, rect, point, blurFilter);
            //bmp.transform.colorTransform = cTr;
        }
        
        private function mouseClick(evt:MouseEvent):void{
            for(var i:String in pArr){
                pArr[i].stopFlag = false;
                pArr[i].destPoint.x = evt.stageX;
                pArr[i].destPoint.y = evt.stageY;
            }

        }

    }
}

import flash.events.Event;
import flash.display.BlendMode;
import flash.geom.Point;
import flash.display.Shape;

class Ptc extends Shape{
    public var destPoint:Point = new Point();
    private var vx:Number = 0;
    private var vy:Number = 0;
    private var easing:Number = 0.02 + Math.random()*0.03;
    private var rNum:int;
    public var stopFlag:Boolean = false;

    public function Ptc(radius:Number){
        this.graphics.beginFill(0x0);
        this.graphics.drawCircle(0, 0, radius);
        this.graphics.endFill();
        this.blendMode = BlendMode.LIGHTEN;
    }

    public function process():void{
        if(stopFlag){
            rNum = Math.random()*20;
            if(rNum == 0){
                destPoint.x = Math.random()*553 - 20;
                destPoint.y = Math.random()*553 - 20;
                stopFlag = false;
            }
        }else{
            movePtc();
            if(Math.round(vx)==0 && Math.round(vy)==0){
            stopFlag = true;
            }
        }
    }

    private function movePtc():void{
        vx = (destPoint.x - this.x)*easing;
        vy = (destPoint.y - this.y)*easing;
        this.x += vx;
        this.y += vy;
    }
}


//forked from ll_koba_ll's SiONでジェネレイティブミュージックを奏でる！ サンプルコード
//see: http://wonderfl.net/c/9oRI

import flash.display.Sprite;
import org.si.sion.SiONData;
import org.si.sion.SiONDriver;
import org.si.sion.events.SiONEvent;
import org.si.sion.utils.SiONPresetVoice;
import org.si.sion.utils.Scale;
import org.si.sound.Arpeggiator;

class C3_C extends Sprite {
    //ドライバ
    public var _driver:SiONDriver;
    //アルペジェータ
    public var _arpeggiator:Arpeggiator;
    
    function C3_C() {
        //ドライバーの生成
        _driver = new SiONDriver();
        //イベントハンドラメソッドを登録
        _driver.addEventListener(SiONEvent.STREAM, streamhandler);
        
        //アルペジェーターの生成　及び　スケールの設定
        _arpeggiator = new Arpeggiator(new Scale("o1Ajap"));
        /*アルペジェーターのパラメーターを設定*/
        //音色を設定
        var voice:SiONPresetVoice = new SiONPresetVoice();
        _arpeggiator.voice = voice["valsound.bell1"];
        //パターンの設定
        _arpeggiator.pattern = [0, 1, 5, 2, 4, 3];

        /*MMLを定義*/
        //テンポを設定
        var mml:String = "t80;";
        //リバーブエフェクトをかける
        mml += "#EFFECT0{reverb 70,40,70}";
        //MMLをコンパイル
        var data:SiONData = _driver.compile(mml);            
        //再生
        _driver.play(data);
        _arpeggiator.play();
    }
    
    private function streamhandler(e:SiONEvent) : void {
        //スケールをランダムに変更
        _arpeggiator.scaleIndex = r0 * 16 + 8;
        _arpeggiator.noteLength = [1,0.5,1,2,4][int(r1 * 4 + 0.99)];
    }
    
    public var r0:Number = 0; 
    public var r1:Number = 0;
}