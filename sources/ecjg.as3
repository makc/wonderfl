package {
    import flash.display.Sprite;
    import org.si.sion.*;
    import org.si.sion.utils.SiONPresetVoice;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import com.bit101.components.*;
    [SWF(width = "370", height = "210", backgroundColor = "#ffffff")]
    
    public class main extends Sprite {
        public var driver:SiONDriver = new SiONDriver();
        public var music:SiONData;
        public var presetVoice:SiONPresetVoice = new SiONPresetVoice();
        public var voiceList:Array = presetVoice.categolies[0];
        
        public const BAR:int = 100;
        public var chords:Array = new Array();
        public var updown:Array = new Array();
        
        public var character:int = 6;
        public var density:int = 6;
        public var entropy:int = 3;
        public var melody:String = "明るめ / major";
        public var arrange:String = "ピコピコ / chip";
        public var chaos:Boolean = false;
        public var sound:String = "ステレオ / stereo";
        public var hattori:Boolean = false;
        
        public function main() {
            Style.embedFonts = false;
            
            var label1:Label = new Label(this, 10, 5, "楽器の数 / instruments");
            var characterstepper:NumericStepper = new NumericStepper(this, 10, 20, characterChange);
            characterstepper.addEventListener(Event.CHANGE, characterChange);
            characterstepper.value = 6;
            characterstepper.minimum = 1;
            characterstepper.maximum = 10;
            
            var label2:Label = new Label(this, 120, 5, "密度 / density");
            var densitystepper:NumericStepper = new NumericStepper(this, 120, 20, densityChange);
            densitystepper.addEventListener(Event.CHANGE, densityChange);
            densitystepper.value = 6;
            densitystepper.minimum = 1;
            densitystepper.maximum = 10;
            
            var label3:Label = new Label(this, 230, 5, "乱雑さ / disorderliness");
            var entropystepper:NumericStepper = new NumericStepper(this, 230, 20, entropyChange);
            entropystepper.addEventListener(Event.CHANGE, entropyChange);
            entropystepper.value = 3;
            entropystepper.minimum = 1;
            entropystepper.maximum = 10;
            
            var label4:Label = new Label(this, 10, 45, "メロディ / melody");
            var melodybox:ComboBox = new ComboBox(this, 10, 60, "明るめ / major", ["明るめ / major", "暗め / minor", "和風 / Miyakobushi",　"沖縄風 / Ryukyu",　"ジプシー風 / Gypsy",　"現代音楽風 / atonality"]);
            melodybox.addEventListener(Event.SELECT, melodySelect);
            
            var label5:Label = new Label(this, 120, 45, "アレンジ / arrangement");
            var arrangebox:ComboBox = new ComboBox(this, 120, 60, "ピコピコ / chip", ["柔らかめ / soft", "硬め / hard", "ピコピコ / chip", "闇鍋 / chaos"]);
            arrangebox.addEventListener(Event.SELECT, arrangeSelect);
            
            var label6:Label = new Label(this, 230, 45, "音響 / sound");
            var soundbox:ComboBox = new ComboBox(this, 230, 60, "ステレオ / stereo", ["モノラル / mono", "ステレオ / stereo"]);
            soundbox.addEventListener(Event.SELECT, soundSelect);
            
            var hattoricheck:CheckBox = new CheckBox(this, 10, 90, "揺らす / swing", hattoriMouseClick);
            
            new PushButton(this,  10, 110, "生成 / generate", make);
            
            driver.play("");
        }
        
        public function make(e:MouseEvent):void {
            var mml:String = "";
            var center:Boolean;
            new PushButton(this, 120, 110, "一時停止 / pause", pause);
            
            chords = chordget(melody);
            trace(chords);
            
            updown = updownget();
            updown[0] = 2;
            updown[1] = 2;
            updown[2] = 2;
            trace(updown);
            
            for (var i:int = 0; i < character; i++) {
                mml += headerget(i);
                var x:int = int( Math.random() * 2 );
                switch (x) {
                    case 0:center = false; break;
                    case 1:center = true; break;
                }
                for (var j:int = 0; j < BAR; j++) {
                        for (var k:int = 0; k < density * entropy; k++) {
                            x = int( Math.random() * entropy * updown[j] / 2 );
                            switch (x) {
                                case 0:
                                    if (sound == "ステレオ / stereo") { if (center == false) { mml += panget() } }
                                    if (hattori == true) { mml += hattoriget() }
                                    mml += noteget(j);
                                    break;
                                default:mml += "r";
                                    break;
                            }
                        }
                    if (j == BAR - 1) { mml += ";\n" }
                }
            }
            
            trace(mml);
            music = driver.compile(mml)
            driver.play(music);
        }
        
        public function chordget(melody:String):Array {
            for (var i:int = 0; i < BAR; i++) {
                var x:int;
                if (melody == "明るめ / major") { x = int( Math.random() * 7 ) }
                if (melody == "暗め / minor") { x = int( Math.random() * 7 + 7 ) }
                if (melody == "ジプシー風 / Gypsy") { x = int( Math.random() * 7 + 14 ) }
                switch (x) {
                    case 0:chords[i] = "C"; break;
                    case 1:chords[i] = "D"; break;
                    case 2:chords[i] = "E"; break;
                    case 3:chords[i] = "F"; break;
                    case 4:chords[i] = "G"; break;
                    case 5:chords[i] = "A"; break;
                    case 6:chords[i] = "B"; break;
                    case 7:chords[i] = "Cm"; break;
                    case 8:chords[i] = "Dm"; break;
                    case 9:chords[i] = "Em"; break;
                    case 10:chords[i] = "Fm"; break;
                    case 11:chords[i] = "Gm"; break;
                    case 12:chords[i] = "Am"; break;
                    case 13:chords[i] = "Bm"; break;
                    case 14:chords[i] = "C"; break;
                    case 15:chords[i] = "Cmaj7"; break;
                    case 16:chords[i] = "Em"; break;
                    case 17:chords[i] = "Fdim"; break;
                    case 18:chords[i] = "Fmaj7b3"; break;
                    case 19:chords[i] = "G7b5"; break;
                    case 20:chords[i] = "Abaug"; break;
                }
                if (melody == "和風 / Miyakobushi") { chords[i] = "和風 / Miyakobushi" }
                if (melody == "沖縄風 / Ryukyu") { chords[i] = "沖縄風 / Ryukyu" }
                if (melody == "現代音楽風 / atonality") { chords[i] = "現代音楽風 / atonality" }
            }
            return chords;
        }
        
        public function updownget():Array {
            for (var i:int = 0; i < BAR; i++) {
                updown[i] = int( Math.random() * 4 + 1 );
                }
            return updown;
        }
        
        public function headerget(i:int):String {
            var header:String;
            var x:int;
            var y:int = 0;
            
            if (arrange == "柔らかめ / soft") {
                x = int( Math.random() * 2 );
                switch (x) {
                    case 0:
                        voiceList = presetVoice.categolies[2];
                        while (y == 0) {
                            y++;
                            x = int( Math.random() * 18 );
                            if (x == 2 || x == 3) { y = 0 }
                        }
                        break;
                    case 1:
                        voiceList = presetVoice.categolies[11];
                        x = int( Math.random() * 8 );
                        break;
                }
            }
            
            if (arrange == "硬め / hard") {
                x = int( Math.random() * 2 );
                switch (x) {
                    case 0:
                        voiceList = presetVoice.categolies[6];
                        while (y == 0) {
                            y++;
                            x = int( Math.random() * 38 );
                            if (x == 8 || x == 9) { y = 0 }
                        }
                        break;
                    case 1:
                        voiceList = presetVoice.categolies[14];
                        while (y == 0) {
                            y++;
                            x = int( Math.random() * 61 );
                            if (x == 2 || x == 4 || x == 5 || x == 33) { y = 0 }
                        }
                        break;
                }
            }
            
            if (arrange == "ピコピコ / chip") {
                voiceList = presetVoice.categolies[0];
                while (y == 0) {
                    y++;
                    x = int( Math.random() * 18 );
                    if (x == 5 || x == 15) { y = 0 }
                }
            }
            
            if (chaos == true) {
                x = int( Math.random() * 17 );
                switch (x) {
                    case 0:arrange = "default"; break;
                    case 1:arrange = "bass"; break;
                    case 2:arrange = "bell"; break;
                    case 3:arrange = "brass"; break;
                    case 4:arrange = "guitar"; break;
                    case 5:arrange = "lead"; break;
                    case 6:arrange = "percus"; break;
                    case 7:arrange = "piano"; break;
                    case 8:arrange = "se"; break;
                    case 9:arrange = "special"; break;
                    case 10:arrange = "strpad"; break;
                    case 11:arrange = "wind"; break;
                    case 12:arrange = "world"; break;
                    case 13:arrange = "midi"; break;
                    case 14:arrange = "midi.drum"; break;
                    case 15:arrange = "svmidi"; break;
                    case 16:arrange = "svmidi.drum"; break;
                }
            }
            
            if (arrange == "default") {
                voiceList = presetVoice.categolies[0];
                x = int( Math.random() * 18 );
            }
            
            if (arrange == "bass") {
                voiceList = presetVoice.categolies[1];
                x = int( Math.random() * 54 );
            }
            
            if (arrange == "bell") {
                voiceList = presetVoice.categolies[2];
                x = int( Math.random() * 18 );
            }
            
            if (arrange == "brass") {
                voiceList = presetVoice.categolies[3];
                x = int( Math.random() * 20 );
            }
            
            if (arrange == "guitar") {
                voiceList = presetVoice.categolies[4];
                x = int( Math.random() * 18 );
            }
            
            if (arrange == "lead") {
                voiceList = presetVoice.categolies[5];
                x = int( Math.random() * 42 );
            }
            
            if (arrange == "percus") {
                voiceList = presetVoice.categolies[6];
                x = int( Math.random() * 38 );
            }
            
            if (arrange == "piano") {
                voiceList = presetVoice.categolies[7];
                x = int( Math.random() * 20 );
            }
            
            if (arrange == "se") {
                voiceList = presetVoice.categolies[8];
                x = int( Math.random() * 3 );
            }
            
            if (arrange == "special") {
                voiceList = presetVoice.categolies[9];
                x = int( Math.random() * 5 );
            }
            
            if (arrange == "strpad") {
                voiceList = presetVoice.categolies[10];
                x = int( Math.random() * 25 );
            }
            
            if (arrange == "wind") {
                voiceList = presetVoice.categolies[11];
                x = int( Math.random() * 8 );
            }
            
            if (arrange == "world") {
                voiceList = presetVoice.categolies[12];
                x = int( Math.random() * 7 );
            }
            
            if (arrange == "midi") {
                voiceList = presetVoice.categolies[13];
                x = int( Math.random() * 128 );
            }
            
            if (arrange == "midi.drum") {
                voiceList = presetVoice.categolies[14];
                x = int( Math.random() * 61 );
            }
            
            if (arrange == "svmidi") {
                voiceList = presetVoice.categolies[15];
                x = int( Math.random() * 128 );
            }
            
            if (arrange == "svmidi.drum") {
                voiceList = presetVoice.categolies[16];
                x = int( Math.random() * 61 );
            }
            
            header = voiceList[x].getMML(i);
            header += "$l" + density * entropy + "%6@" + i;
            var volume:int = int( Math.random() * 5 + 12 );
            var octave:int = int( Math.random() * 4 + 3 );
            header += "v" + volume + "o" + octave + "\n";
            return header;
        }
        
        public function panget():String {
            var pan:String;
            var x:int = int( Math.random() * 129 );
            x -= 64;
            pan = "@p" + x;
            return pan;
        }
        
        public function hattoriget():String {
            var hat:String;
            var x:int = int( Math.random() * 300);
            var y:int = int( Math.random() * 300);
            var z:int = int( Math.random() * 2 );
            switch (z) {
                case 0:hat = "@lfo" + x + "mp" + y;
                break;
                case 1:hat += "@lfo" + x + ",6mp" + y;
                break;
            }
            return hat;
        }
        
        public function noteget(j:int):String {
            var note:String;
            var x:int = int( Math.random() * 3 );
            var y:int = int( Math.random() * 4 );
            var z:int = int( Math.random() * 5 );
            var all:int = int( Math.random() * 12 );
            if (chords[j] == "現代音楽風 / atonality") {
                switch (all) {
                case 0:note = "c"; break;
                case 1:note = "c+"; break;
                case 2:note = "d"; break;
                case 3:note = "d+"; break;
                case 4:note = "e"; break;
                case 5:note = "f"; break;
                case 6:note = "f+"; break;
                case 7:note = "g"; break;
                case 8:note = "g+"; break;
                case 9:note = "a"; break;
                case 10:note = "a+"; break;
                case 11:note = "b"; break;
                }
            }
            if (chords[j] == "C") {
                switch (x) {
                case 0:note = "c"; break;
                case 1:note = "e"; break;
                case 2:note = "g"; break;
                }
            }
            if (chords[j] == "D") {
                switch (x) {
                case 0:note = "d"; break;
                case 1:note = "f+"; break;
                case 2:note = "a"; break;
                }
            }
            if (chords[j] == "E") {
                switch (x) {
                case 0:note = "e"; break;
                case 1:note = "g+"; break;
                case 2:note = "b"; break;
                }
            }
            if (chords[j] == "F") {
                switch (x) {
                case 0:note = "f"; break;
                case 1:note = "a"; break;
                case 2:note = "<c>"; break;
                }
            }
            if (chords[j] == "G") {
                switch (x) {
                case 0:note = "g"; break;
                case 1:note = "b"; break;
                case 2:note = "<d>"; break;
                }
            }
            if (chords[j] == "A") {
                switch (x) {
                case 0:note = ">a<"; break;
                case 1:note = "c+"; break;
                case 2:note = "e"; break;
                }
            }
            if (chords[j] == "B") {
                switch (x) {
                case 0:note = ">b<"; break;
                case 1:note = "d+"; break;
                case 2:note = "f+"; break;
                }
            }
            if (chords[j] == "Cm") {
                switch (x) {
                case 0:note = "c"; break;
                case 1:note = "e-"; break;
                case 2:note = "g"; break;
                }
            }
            if (chords[j] == "Dm") {
                switch (x) {
                case 0:note = "d"; break;
                case 1:note = "f"; break;
                case 2:note = "a"; break;
                }
            }
            if (chords[j] == "Em") {
                switch (x) {
                case 0:note = "e"; break;
                case 1:note = "g"; break;
                case 2:note = "b"; break;
                }
            }
            if (chords[j] == "Fm") {
                switch (x) {
                case 0:note = "f"; break;
                case 1:note = "a-"; break;
                case 2:note = "<c>"; break;
                }
            }
            if (chords[j] == "Gm") {
                switch (x) {
                case 0:note = "g"; break;
                case 1:note = "b-"; break;
                case 2:note = "<d>"; break;
                }
            }
            if (chords[j] == "Am") {
                switch (x) {
                case 0:note = ">a<"; break;
                case 1:note = "c"; break;
                case 2:note = "e"; break;
                }
            }
            if (chords[j] == "Bm") {
                switch (x) {
                case 0:note = ">b<"; break;
                case 1:note = "d"; break;
                case 2:note = "f+"; break;
                }
            }
            if (chords[j] == "Cmaj7") {
                switch (y) {
                case 0:note = "c"; break;
                case 1:note = "e"; break;
                case 2:note = "g"; break;
                case 3:note = "b"; break;
                }
            }
            if (chords[j] == "Fdim") {
                switch (x) {
                case 0:note = "f"; break;
                case 1:note = "a-"; break;
                case 2:note = "b"; break;
                }
            }
            if (chords[j] == "Fmaj7b3") {
                switch (y) {
                case 0:note = "f"; break;
                case 1:note = "a-"; break;
                case 2:note = "<c>"; break;
                case 3:note = "<e>"; break;
                }
            }
            if (chords[j] == "G7b5") {
                switch (y) {
                case 0:note = "g"; break;
                case 1:note = "b"; break;
                case 2:note = "<d->"; break;
                case 3:note = "<f>"; break;
                }
            }
            if (chords[j] == "Abaug") {
                switch (x) {
                case 0:note = ">a-<"; break;
                case 1:note = "c"; break;
                case 2:note = "e"; break;
                }
            }
            if (chords[j] == "和風 / Miyakobushi") {
                switch (z) {
                case 0:note = "c"; break;
                case 1:note = "d-"; break;
                case 2:note = "f"; break;
                case 3:note = "g"; break;
                case 4:note = "a-"; break;
                }
            }
            if (chords[j] == "沖縄風 / Ryukyu") {
                switch (z) {
                case 0:note = "c"; break;
                case 1:note = "e"; break;
                case 2:note = "f"; break;
                case 3:note = "g"; break;
                case 4:note = "b"; break;
                }
            }
            
            return note;
        }
        
        private function characterChange(event:Event):void {
            var stepper:NumericStepper = event.currentTarget as NumericStepper;
            character = int(stepper.value);
        }
        
        private function densityChange(event:Event):void {
            var stepper:NumericStepper = event.currentTarget as NumericStepper;
            density = int(stepper.value);
        }
        
        private function entropyChange(event:Event):void {
            var stepper:NumericStepper = event.currentTarget as NumericStepper;
            entropy = int(stepper.value);
        }
        
        private function melodySelect(event:Event):void {
            var melodybox:ComboBox = event.currentTarget as ComboBox;
            melody = String(melodybox.selectedItem);
        }
        
        private function arrangeSelect(event:Event):void {
            var arrangebox:ComboBox = event.currentTarget as ComboBox;
            arrange = String(arrangebox.selectedItem);
            if (arrange == "闇鍋 / chaos") { chaos = true }
            else { chaos = false }
        }
        
        private function soundSelect(event:Event):void {
            var soundbox:ComboBox = event.currentTarget as ComboBox;
            sound = String(soundbox.selectedItem);
        }
       
        private function hattoriMouseClick(event:MouseEvent):void {
            hattori = Boolean(event.currentTarget.selected);
        }
       
        public function pause(e:MouseEvent):void {
            new PushButton(this,  120, 110, "再生 / play", play);
            driver.pause();
        }

        public function play(e:MouseEvent):void {
            new PushButton(this,  120, 110, "一時停止 / pause", pause);
            driver.play();
        }
        
    }
}