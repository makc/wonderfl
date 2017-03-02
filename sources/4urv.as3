// クリック音メーカー
//  ちょっとFullFlashSiteとか作りたくなったときに，ボタンのクリック音を手軽に作れたらいいな．．．
// 参考URL:
//   SiON使い方-> http://wonderfl.net/c/9Xx7
//   録音の仕方-> http://wonderfl.net/c/yknG
package 
{
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.*;
    import flash.net.FileReference;
    import flash.utils.*;
    import flash.media.*;
    import org.si.sion.*;
    import org.si.sion.events.*;
    import org.si.sion.effector.*;
    import org.si.sound.*;
    import org.si.sound.events.*;
    import org.si.sound.patterns.*;
    import org.si.sound.synthesizers.*;
    import com.bit101.components.*;
    
    public class Main extends Sprite 
    {
        //SiON関係
        private var _driver:SiONDriver;
        private var _eq:SiEffectEqualiser;
        private var _delay:SiEffectStereoDelay;
        private var _chorus:SiEffectStereoChorus;
        private var _reverb:SiEffectStereoReverb;
        
        //wav保存用変数
        private var _rawData:ByteArray;
        private var _wavData:ByteArray;
        private var _filename:InputText;
        private var _saveLabel:Label;
        private var _saveButton:PushButton;
        
        //サウンド設定関係
        private var _mmlLabel:Label;
        private var _mmlData:TextArea;
        
        //エフェクタ関係
        // イコライザ
        private var _eq_low:Number = 1.0;
        private var _eq_mid:Number = 1.0;
        private var _eq_high:Number = 1.0;
        private var _eq_highFreq:int = 5000;
        private var _eq_lowFreq:int = 800;
        // ディレイ
        private var _delay_time:int = 0;
        private var _delay_fb:Number = 0;
        private var _delay_wet:Number = 0.0;
        // コーラス
        private var _chorus_Freq:int = 0;
        private var _chorus_depth:int = 0;
        private var _chorus_wet:Number = 0;
        //リバーブ
        private var _rv_longDelay:Number = 0;
        private var _rv_shortDelay:Number = 0;
        private var _rv_fb:Number = 0;
        private var _rv_wet:Number = 0;
        
        //水平バー
        private var hs1:HSlider;
        private var hs2:HSlider;
        private var hs3:HSlider;
        private var hs4:HSlider;
        private var hs5:HSlider;
        private var hs6:HSlider;
        private var hs7:HSlider;
        private var hs8:HSlider;
        private var hs9:HSlider;
        private var hs10:HSlider;
        private var hs11:HSlider;
        private var hs12:HSlider;
        private var hs13:HSlider;
        private var hs14:HSlider;
        private var hs15:HSlider;
        
        
        //-------------------------------------------------------------------------
        //ここからはじまれ
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        //初期化
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            //SiONDriver初期化
            _driver = new SiONDriver();
            //エフェクタ
            _driver.effector.slot0 = [new SiEffectEqualiser(), new SiEffectStereoDelay(0,0,false,0), new SiEffectStereoChorus(0,0,0,0,0), new SiEffectStereoReverb(0,0,0,0)];
            _eq = _driver.effector.getEffectorList(0)[0] as SiEffectEqualiser;
            _delay = _driver.effector.getEffectorList(0)[1] as SiEffectStereoDelay;
            _chorus = _driver.effector.getEffectorList(0)[2] as SiEffectStereoChorus;
            _reverb = _driver.effector.getEffectorList(0)[3] as SiEffectStereoReverb;
            _driver.addEventListener(SiONEvent.FINISH_SEQUENCE, transToWAV);            
            
            //wav保存用
            _saveLabel = new Label(this, 0, 3, "FileName : ");
            _filename = new InputText(this, 50, 3, "click.wav");
            _filename.width = 150;
            _filename.textField.restrict = "^/\\:\*\?\"<>\|%";
            _saveButton = new PushButton(this, 210, 0, "Save", onSave);
            _saveButton.enabled = false;
            
            //サウンド関係
            _mmlLabel = new Label(this, 0, 30, "MML Data : ");
            _mmlData = new TextArea(this, 55, 30, "%3 @5 o6d32r");
            _mmlData.width = 255;
            _mmlData.height = 50;
            
            //テスト再生用ボタン
            var _testButton:PushButton = new PushButton(this, 210, 85, "Test", createRowData);
            
            //mmlサンプルのリスト
            new Label(this, 0, 205, "[Click Sample]");
            new RadioButton(this, 10, 225, "Sample1", false, onRadioClick);
            new RadioButton(this, 10, 240, "Sample2", false, onRadioClick);
            new RadioButton(this, 10, 255, "Sample3", false, onRadioClick);
            new RadioButton(this, 10, 270, "Sample4", false, onRadioClick);
            new RadioButton(this, 10, 285, "Sample5", false, onRadioClick);
            
            //エフェクタ関係
            //　イコライザ
            new Label(this, 0, 100, "[Equaliser]");
            //_eq_high
            new Label(this, 4, 115, "LowLevel");
            hs1 = new HSlider(this, 50, 120);
            hs1.maximum = 1.0;
            hs1.minimum = 0.0;
            hs1.value = _eq_low;
            hs1.addEventListener(Event.CHANGE, function(e:Event):void { _eq_low = hs1.value; });
            //_eq_mid
            new Label(this, 4, 130, "MidLevel");
            hs2 = new HSlider(this, 50, 135);
            hs2.maximum = 1.0;
            hs2.minimum = 0.0;
            hs2.value = _eq_mid;
            hs2.addEventListener(Event.CHANGE, function(e:Event):void { _eq_mid = hs2.value; });
            //_eq_low
            new Label(this, 4, 145, "HighLevel");
            hs3 = new HSlider(this, 50, 150);
            hs3.maximum = 1.0;
            hs3.minimum = 0.0;
            hs3.value = _eq_high;
            hs3.addEventListener(Event.CHANGE, function(e:Event):void { _eq_high = hs3.value; });
            //_eq_lowFreq
            new Label(this, 4, 165, "LowFreq");
            hs4 = new HSlider(this, 50, 170);
            hs4.maximum = 8000;
            hs4.minimum = 0;
            hs4.value = _eq_lowFreq;
            hs4.addEventListener(Event.CHANGE, function(e:Event):void { _eq_lowFreq = hs4.value; });
            //_eq_highFreq
            new Label(this, 4, 180, "HighFreq");
            hs5 = new HSlider(this, 50, 185);
            hs5.maximum = 8000;
            hs5.minimum = 0;
            hs5.value = _eq_highFreq;
            hs5.addEventListener(Event.CHANGE, function(e:Event):void { _eq_highFreq = hs5.value; });
            // ディレイ            
            new Label(this, 160, 100, "[Delay]");
            //_delay_time
            new Label(this, 164, 115, "delayTime");
            hs6 = new HSlider(this, 210, 120);
            hs6.maximum = 150;
            hs6.minimum = 0;
            hs6.value = _delay_time;
            hs6.addEventListener(Event.CHANGE, function(e:Event):void { _delay_time = hs6.value; } );
            //_delay_fb
            new Label(this, 164, 130, "feedback");
            hs7 = new HSlider(this, 210, 135);
            hs7.maximum = 1;
            hs7.minimum = -1;
            hs7.value = _delay_fb;
            hs7.addEventListener(Event.CHANGE, function(e:Event):void { _delay_fb = hs7.value; } );
            //_delay_wet
            new Label(this, 164, 145, "wet");
            hs8 = new HSlider(this, 210, 150);
            hs8.maximum = 1;
            hs8.minimum = 0;
            hs8.value = _delay_wet;
            hs8.addEventListener(Event.CHANGE, function(e:Event):void { _delay_wet = hs8.value; });
            // コーラス
            new Label(this, 160, 160, "[Chorus]");
            //_chorus_Freq
            new Label(this, 164, 175, "Freq");
            hs9 = new HSlider(this, 210, 180);
            hs9.maximum = 8;
            hs9.minimum = 0;
            hs9.value = _chorus_Freq;
            hs9.addEventListener(Event.CHANGE, function(e:Event):void { _chorus_Freq = hs9.value; });
            //_chorus_depth
            new Label(this, 164, 190, "depth");
            hs10 = new HSlider(this, 210, 195);
            hs10.maximum = 10;
            hs10.minimum = 0;
            hs10.value = _chorus_depth;
            hs10.addEventListener(Event.CHANGE, function(e:Event):void { _chorus_depth = hs10.value; } );
            //_chorus_wet
            new Label(this, 164, 205, "wet");
            hs11 = new HSlider(this, 210, 210);
            hs11.maximum = 10;
            hs11.minimum = 0;
            hs11.value = _chorus_wet;
            hs11.addEventListener(Event.CHANGE, function(e:Event):void { _chorus_wet = hs11.value; } );
            // リバーブ
            new Label(this, 160, 220, "[Reverb]");
            //_rv_longDelay
            new Label(this, 164, 235, "longDly");
            hs12 = new HSlider(this, 210, 240);
            hs12.maximum = 1;
            hs12.minimum = 0;
            hs12.value = _rv_longDelay;
            hs12.addEventListener(Event.CHANGE, function(e:Event):void { _rv_longDelay = hs12.value; } );
            //_rv_shortDelay
            new Label(this, 164, 250, "shortDly");
            hs13 = new HSlider(this, 210, 255);
            hs13.maximum = 1;
            hs13.minimum = 0;
            hs13.value = _rv_shortDelay;
            hs13.addEventListener(Event.CHANGE, function(e:Event):void { _rv_shortDelay = hs13.value; } );
            //_rv_fb
            new Label(this, 164, 265, "feedback");
            hs14 = new HSlider(this, 210, 270);
            hs14.maximum = 1;
            hs14.minimum = -1;
            hs14.value = _rv_fb;
            hs14.addEventListener(Event.CHANGE, function(e:Event):void { _rv_fb = hs14.value; } );
            //_rv_wet
            new Label(this, 164, 280, "wet");
            hs15 = new HSlider(this, 210, 285);
            hs15.maximum = 1;
            hs15.minimum = 0;
            hs15.value = _rv_wet;
            hs15.addEventListener(Event.CHANGE, function(e:Event):void { _rv_wet = hs15.value; } );
        }
        
        //mmlサンプルリストがクリックされた場合の処理
        private function onRadioClick(e:Event): void {
            var radio:RadioButton = e.currentTarget as RadioButton;
            //サンプルリスト
            switch(radio.label) {
                case "Sample1":
                    _mmlData.text = "%3 @0 o6b32o7f+32r";
                    setEq(0,0);
                    setDelay();
                    setChorus();
                    setReverb();
                    break;
                case "Sample2":
                    _mmlData.text = "%1 @8 o6g128r";
                    setEq();
                    setDelay();
                    setChorus();
                    setReverb();
                    break;
                case "Sample3":
                    _mmlData.text = "%3 @0 o3b64r";
                    setEq();
                    setDelay();
                    setChorus();
                    setReverb();
                    break;
                case "Sample4":
                    _mmlData.text = "%3 @4 o3g128r";
                    setEq();
                    setDelay();
                    setChorus();
                    setReverb();
                    break;
                case "Sample5":
                    _mmlData.text = "%3 @5 o6d32r";
                    setEq();
                    setDelay();
                    setChorus();
                    setReverb();
                    break;
            }
        }
        
        //rowDataの作成
        private function createRowData(e:MouseEvent):void {
            _driver.addEventListener(SiONEvent.STREAM, onStream);
            _rawData = new ByteArray();
            _rawData.endian = Endian.LITTLE_ENDIAN;
            testSound();
            _saveButton.enabled = false;
        }
        private function onStream(e:SiONEvent):void {
            e.streamBuffer.position = 0;
            while (e.streamBuffer.bytesAvailable > 0) {
                var d:int = e.streamBuffer.readFloat() * 32767;
                _rawData.writeShort(d);
            }
        }
        
        //WAVデータへの変換
        private function transToWAV(e:SiONEvent):void {
            _driver.removeEventListener(SiONEvent.STREAM, onStream);
            _wavData = new ByteArray();
            _wavData.endian = Endian.LITTLE_ENDIAN;
            //wavのヘッダ情報
            _wavData.writeUTFBytes("RIFF");
            _wavData.writeInt(_rawData.length + 36);
            _wavData.writeUTFBytes("WAVE");
            _wavData.writeUTFBytes("fmt ");
            _wavData.writeInt(16);
            _wavData.writeShort(1);
            _wavData.writeShort(2);
            _wavData.writeInt(44100);
            _wavData.writeInt(176400);
            _wavData.writeShort(4);
            _wavData.writeShort(16);
            //データ本体
            _wavData.writeUTFBytes("data");
            _wavData.writeInt(_rawData.length);
            _rawData.position = 0;
            _wavData.writeBytes(_rawData);
            
            //変換後は保存可能
            _saveButton.enabled = true;
        }
        
        //データの保存
        private function onSave(e:MouseEvent):void {            
            if (_wavData) {
                var fileRef:FileReference = new FileReference();
                fileRef.save(_wavData, _filename.text);
            }
        }
        
        
        //チェック用再生関数
        private function testSound():void {
            _eq.setParameters(_eq_low, _eq_mid, _eq_high);
            _delay.setParameters(_delay_time, _delay_fb, true, _delay_wet);
            _chorus.setParameters(20, 0.2, _chorus_Freq, _chorus_depth, _chorus_wet);
            _reverb.setParameters(_rv_longDelay, _rv_shortDelay, _rv_fb, _rv_wet);
            _driver.play(_mmlData.text, false);
        }
        
        //セット関数
        private function setEq(p1:Number = 1.0, p2:Number = 1.0, p3:Number = 1.0, p4:int = 800, p5:int = 5000):void {
            _eq_low = p1; hs1.value = p1;
            _eq_mid = p2; hs2.value = p2;
            _eq_high = p3; hs3.value = p3;
            _eq_lowFreq = p4; hs4.value = p4;
            _eq_highFreq = p5; hs5.value = p5;
        }
        private function setDelay(p1:int = 0, p2:Number = 0.0, p3:Number = 0.0):void {
            _delay_time = p1; hs6.value = p1;
            _delay_fb = p2; hs7.value = p2;
            _delay_wet = p3; hs8.value = p3;
        }
        private function setChorus(p1:int = 0, p2:int = 0, p3:Number = 0.0):void {
            _chorus_Freq = p1; hs9.value = p1;
            _chorus_depth = p2; hs10.value = p2;
            _chorus_wet = p3; hs11.value = p3;
        }

        private function setReverb(p1:Number = 0.0, p2:Number = 0.0, p3:Number = 0.0, p4:Number = 0.0):void {
            _rv_longDelay = p1; hs12.value = p1;
            _rv_shortDelay = p2; hs13.value = p2;
            _rv_fb= p3; hs14.value = p3;
            _rv_wet = p4; hs15.value = p4;
        }
    }
    
}