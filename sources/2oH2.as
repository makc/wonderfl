package{
    import flash.display.Sprite;
    public class MicromaSYN extends Sprite{
        public function MicromaSYN():void{
            graphics.beginFill(0x707070);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            new Synthesizer(this);
        }
    }
}

import flash.display.*;
import flash.events.*;
import flash.text.*;
import flash.media.Sound;
import flash.media.SoundChannel;
import com.bit101.components.*;

const PI:Number = Math.PI;

const SAMPLE_BUFFER_NUM:int = 2048;
const SAMPLE_FREQ:Number = 44100.0;

const WAVEFORM_RECT:int = 0;
const WAVEFORM_SAW:int = 1;
const WAVEFORM_TRI:int = 2;
const WAVEFORM_SINE:int = 3;
const WAVEFORM_NOISE:int = 4;

//modify minimalcomps color style
Style.BACKGROUND = 0xFFFFFF;
Style.BUTTON_FACE = 0x6050F0;
Style.LABEL_TEXT = 0xFFFFFF;        //text color

const STYLE_UI_THEME:uint = 0xFFFFFF;            //knob color
const STYLE_UI_BACKGROUND:uint = 0xFF1040;        //panel color
const STYLE_UI_FRAME:uint = 0xFFFFFF;            //line color

//user interface
var ui_osc1_waveform:WaveformSelector;
var ui_osc1_octave:RotarySelectorEx;
var ui_osc1_volume:Knob;

var ui_osc2_waveform:WaveformSelector;
var ui_osc2_octave:RotarySelectorEx;
var ui_osc2_volume:Knob;

var ui_filter_cutoff:Knob;
var ui_filter_resonance:Knob;

var ui_egf_attack:Knob;
var ui_egf_decay:Knob;
var ui_egf_sustain:Knob;
var ui_egf_release:Knob;

var ui_ega_attack:Knob;
var ui_ega_decay:Knob;
var ui_ega_sustain:Knob;
var ui_ega_release:Knob;

var ui_amp_volume:Knob;
var ui_octave_shift:NumericStepper;


function map(val:Number, smin:Number, smax:Number, dmin:Number, dmax:Number):Number{
    return (val - smin) / (smax - smin) * (dmax - dmin) + dmin;
}

function constrain(val:Number, min:Number, max:Number):int{
    if(val < min) return min;
    else if(val > max) return max;
    else return val;
}


class Tone{
    public var playing:Boolean = false;
    public var key_on:Boolean = false;
    
    public var osc_note_id:int    = 0;    //midi note number
    private var osc1_phase:Number = 0;    //[rad]
    private var osc2_phase:Number = 0;    //[rad]
    private var note_t:Number = 0;        //[sec]
    
    private var egf_level:Number = 0;    //0..1, output control signal of filter EG
    private var ega_level:Number = 0;    //0..1, output control signal of amplifier EG
    
    private var fi:Number = 0.0;        //filter state variable
    private var fy:Number = 0.0;        //
    
    private function midiNoteIdToFreq(note_id:int):Number{
        return 440.0 * Math.pow(2.0, (note_id - 69) / 12.0);
    }
    
    private function incPhase(osc_phase:Number, osc_octave:Number):Number{
        var note_id:int = osc_note_id + (ui_octave_shift.value + osc_octave) * 12;
        note_id = constrain(note_id, 0, 127);
        var freq:Number = midiNoteIdToFreq(note_id);
        
        var phase_delta:Number = 2.0 * PI * freq / SAMPLE_FREQ;
        osc_phase += phase_delta;
        osc_phase %= 2.0 * PI;
        return osc_phase;
    }
    
    private function getWave(waveform:int, r:Number):Number{
        var y:Number;
        
        switch(waveform){
        case WAVEFORM_RECT: y = (r < PI) ? 1.0 : -1.0; break;
        case WAVEFORM_SAW: y = 1.0 - 1.0 / PI * r; break;
        case WAVEFORM_TRI: y = (r < PI) ? (2.0 / PI * r - 1.0) : (-2.0 / PI * r + 3.0); break;
        case WAVEFORM_SINE: y = Math.sin(r); break;
        case WAVEFORM_NOISE: y = Math.random() * 2.0 - 1.0; break;
        deault: y = 0; break;
        }
        
        return y * 0.05;
    }
    
    private function oscillator():Number{
        osc1_phase = incPhase(osc1_phase, ui_osc1_octave.choice-3);
        osc2_phase = incPhase(osc2_phase, ui_osc2_octave.choice-3);
        
        var v1:Number = getWave(ui_osc1_waveform.choice, osc1_phase) * ui_osc1_volume.value;
        var v2:Number = getWave(ui_osc2_waveform.choice, osc2_phase) * ui_osc2_volume.value;
        return (v1 + v2) / 2;
    }
    
    private function filter(x:Number):Number{
        //RLC 2nd order butterworth, state variable fitler
        
        var cutoff:Number = map(egf_level, 0.0, 1.0, ui_filter_cutoff.value, 1.0);
        
        var base_note_id:int = constrain(osc_note_id + (ui_octave_shift.value + 
            Math.min(ui_osc1_octave.choice-3, ui_osc2_octave.choice-3)) * 12, 0, 127);    
            
        var base_freq:Number = midiNoteIdToFreq(base_note_id);
        
        var fc:Number = Math.pow(10000 - base_freq*1.2, cutoff) + base_freq*1.2;    //base_freq*1.2..10000
        var Q:Number = Math.pow(40-0.707, ui_filter_resonance.value) + 0.707;        //0.707..40
        var Z:Number = (2.0 * PI * fc) / SAMPLE_FREQ;

        fi += (x - fy - (1/Q) * fi) * Z;
        fy += fi * Z;
        
        return fy;
    }
    
    private function amplifier(x:Number):Number{
        return x * ega_level * ui_amp_volume.value;
    }

    public function processSample():Number{
        var v:Number;
        v = oscillator();
        v = filter(v);
        v = amplifier(v);
        return v;
    }
    
    
    private function adsr(a:Number, d:Number, s:Number, r:Number, t:Number, is_up:Boolean):Number{
        var v:Number;
        if(is_up){
            if(t < a) v = map(t, 0, a, 0.0, 1.0);
            else if(t < a+d) v = map(t, a, a+d, 1.0, s);
            else v = s;
        }else{
            if(t < r) v = map(t, 0, r, s, 0);
            else v = 0;
        }
        return v;
    }
    
    private function amplifier_eg():void{
        var a:Number = ui_ega_attack.value * 1;        //0..1[sec]
        var d:Number = ui_ega_decay.value * 1;        //0..1[sec]
        var s:Number = ui_ega_sustain.value;        //0..1
        var r:Number = ui_ega_release.value * 2;    //0..2[sec]
        
        ega_level = adsr(a, d, s, r, note_t, key_on);
        if(!key_on && ega_level == 0) playing = false;
    }
    
    private function filter_eg():void{
        var a:Number = ui_egf_attack.value * 1;        //0..1[sec]
        var d:Number = ui_egf_decay.value * 1;        //0..1[sec]
        var s:Number = ui_egf_sustain.value;        //0..1
        var r:Number = ui_egf_release.value * 2;    //0..2[sec]
        
        egf_level = adsr(a, d, s, r, note_t, key_on);    
    }
    
    public function processEnvelope():void{
        note_t += SAMPLE_BUFFER_NUM / SAMPLE_FREQ;
        filter_eg();
        amplifier_eg();
    }
    
    
    public function noteOn(note_id:int):void{
        playing = true;
        key_on = true;
        osc_note_id = note_id;
        osc1_phase = 0;
        osc2_phase = 0;
        note_t = 0;
    }
    
    public function noteOff(note_id:int):void{
        key_on = false;
        note_t = 0;
    }

    public function Tone(note_id:int):void{
        noteOn(note_id);
    }
}

class Synthesizer extends Sprite{
    private const FRAME_PADDING:int = 2;
    private const SEPARATOR_SPACE:int = 6;
    
    private var tones:Array = new Array();
    
    public function Synthesizer(parent:Sprite):void{
        makeControlPanel(parent);
        initSoundOutput();
    }
    
    public function drawFrame(x:int, y:int, w:int, h:int):void{
        var p:int = FRAME_PADDING;
        var g:Graphics = this.graphics;
        graphics.lineStyle(1, STYLE_UI_FRAME);
        graphics.drawRect(x+p, y+p, w-p*2, h-p*2);
        graphics.endFill();
    }
    
    private function drawSeparatorH(x:int, y:int, w:int):void{
        x += (FRAME_PADDING + SEPARATOR_SPACE);
        w -= (FRAME_PADDING + SEPARATOR_SPACE) * 2;
        graphics.lineStyle(1, STYLE_UI_FRAME);
        graphics.moveTo(x, y);
        graphics.lineTo(x+w, y);
    }
    
    private function makeControlPanel(parent:Sprite):void{        
        var pane:Sprite = this;
        
        graphics.beginFill(STYLE_UI_BACKGROUND);
        graphics.drawRect(2, 2, 448, 380);        
        graphics.endFill();
        parent.addChild(this);
        this.x = 6;
        this.y = 42;
        
        drawFrame(0 , 0, 452, 384);
        new Label(this, 379, 5, "micromaSYN");

        var x0:int = 36;
        var y0:int = 50;
        var ax:int = 70;
        var ay:int = 65;
        
        var kw:int = 20;
        var kh:int = 32;
        var kh2:int = 20;
        
        ui_osc1_waveform = new WaveformSelector(this, x0, y0, "waveform");
        ui_osc1_octave = new RotarySelectorEx(this, x0, y0+ay, "octave");
        ui_osc1_octave.choiceTexts = ["-3", "-2", "-1", "0", "+1", "+2", "+3"];
        ui_osc1_octave.choice = 3;
        
        ui_osc1_volume = new SynthKnob(this, x0, y0+ay*2, "volume", 1.0);
        drawFrame(x0-kw, y0-kh, ax, ay*3+kh2);
        new Label(this, x0-kw+4, y0-kh, "OSC1");
        
        x0 += ax;
        ui_osc2_waveform = new WaveformSelector(this, x0, y0, "waveform");
        ui_osc2_waveform.choice = 1;
        ui_osc2_octave = new RotarySelectorEx(this, x0, y0+ay, "octave");
        ui_osc2_octave.choiceTexts = ["-3", "-2", "-1", "0", "+1", "+2", "+3"];
        ui_osc2_octave.choice = 4;
        
        ui_osc2_volume = new SynthKnob(this, x0, y0+ay*2, "volume", 1.0);
        drawFrame(x0-kw, y0-kh, ax, ay*3+kh2);
        new Label(this, x0-kw+4, y0-kh, "OSC2");
        
        x0 += ax;
        ui_filter_cutoff = new SynthKnob(this, x0, y0, "cutoff", 0.7);
        ui_filter_resonance = new SynthKnob(this, x0+ax, y0, "resonance", 0.0);
        ui_egf_attack = new SynthKnob(this, x0, y0+ay, "attack", 0.0);
        ui_egf_decay = new SynthKnob(this, x0+ax, y0+ay, "decay", 0.0);
        ui_egf_sustain = new SynthKnob(this, x0, y0+ay*2, "sustain", 0.0);
        ui_egf_release = new SynthKnob(this, x0+ax, y0+ay*2, "release", 0.0);
        drawFrame(x0-kw, y0-kh, ax*2, ay*3+kh2);    
        drawSeparatorH(x0-kw, y0-kh2+ay+7, ax*2);
        new Label(this, x0-kw+4, y0-kh, "FILTER");
        
        x0 += ax * 2;
        ui_amp_volume = new SynthKnob(this, x0+ax, y0, "volume", 0.5);
        ui_ega_attack = new SynthKnob(this, x0, y0+ay, "attack", 0.0);
        ui_ega_decay = new SynthKnob(this, x0+ax, y0+ay, "decay", 0.0);
        ui_ega_sustain = new SynthKnob(this, x0, y0+ay*2, "sustain", 1.0);
        ui_ega_release = new SynthKnob(this, x0+ax, y0+ay*2, "release", 0.5);
        drawFrame(x0-kw, y0-kh, ax*2, ay*3+kh2);
        drawSeparatorH(x0-kw, y0-kh2+ay+7, ax*2);
        new Label(this, x0-kw+4, y0-kh, "AMPILFIER");
        
        x0 -= ax * 4;
        y0 += ax * 3;
        x0 -= 20;
        y0 -= 28;
        
        new Label(this, x0+4, y0+4, "octave shift");
        ui_octave_shift = new NumericStepper(this, x0+60, y0+4);
        ui_octave_shift.minimum = -4;
        ui_octave_shift.maximum = 4;
        drawFrame(x0, y0, ax*6, 24);
        
        y0 += 26;
        var kbd:KeyboardPanel = new KeyboardPanel(parent, this);
        this.addChild(kbd);
        kbd.x = x0;
        kbd.y = y0;
    }
    
    public function noteOn(note_id:int):void{
        for(var i:int = 0; i< tones.length; i++){
            if(tones[i] && tones[i].key_on && tones[i].osc_note_id == note_id) return;
        }
    
        tones.push(new Tone(note_id));
    }
    
    public function noteOff(note_id:int):void{
        for(var i:int = 0; i< tones.length; i++){
            if(tones[i] && tones[i].key_on && tones[i].osc_note_id == note_id){
                tones[i].noteOff(note_id);
            }
        }
        
        for(i = 0; i< tones.length; i++){
            if(tones[i] && !tones[i].playing){
                tones[i] = null;
                tones.slice(i);
                continue;
            }
        }
    }
    
    private function initSoundOutput():void{
        var sound:Sound = new Sound();
        sound.addEventListener(SampleDataEvent.SAMPLE_DATA, 
            this.processSoundBuffer);
        sound.play();
    }
    
    //sample data event handler
    private function processSoundBuffer(event:SampleDataEvent):void{
        for(var i:int = 0; i<SAMPLE_BUFFER_NUM; i++){
            var v:Number = 0;
            for(var k:int =0; k< tones.length; k++){
                if(tones[k] && tones[k].playing){
                    v += tones[k].processSample();
                }
            }
            
            event.data.writeFloat(v);
            event.data.writeFloat(v);
        }
        
        for(k = 0; k< tones.length; k++){
            if(tones[k]){
                tones[k].processEnvelope();
            }
        }
    }
}

class KeyboardPanel extends Sprite{
    private const KBD_W:int = 420;
    private const KBD_H:int = 100;
    
    private const KEY_WHT_W:int = 28;
    private const KEY_BLK_W:int = 20;
    private const KEY_WHT_H:int = 90;
    private const KEY_BLK_H:int = 55;
    
    private const KEY_ON_COLOR:uint = 0xFF0000;
    private const KEY_ON_ALPHA:Number = 0.7;
    private const KEY_LINE_COLOR:uint = 0x303030;
    
    private const KEY_NUM:int = 25;
    private const keyNames:String = "ZSXDCVGBHNJMQ2W3ER5T6Y7UI";
    private const keycolors:Array = [0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0];
    private const BASE_NOTE:int = 48;
    
    private var synth:Synthesizer;
    private var keys:Array = new Array();
    private var keys_is_on:Array = new Array();
    
    public function makeRectSprite(x:int, y:int, w:int, h:int, fill_color:int, line_color:int):Sprite{
        var sp:Sprite = new Sprite();
        sp.x = x;
        sp.y = y;
        sp.graphics.beginFill(fill_color);
        sp.graphics.lineStyle(1, line_color);
        sp.graphics.drawRect(0, 0, w, h);
        sp.graphics.endFill();
        return sp;
    }
    
    private function makeKey(x:int, y:int, idx:int, keycolor:int, keyName:String):void{    
        var w:int, h:int;
        var c:uint, text_c:uint;
        
        if(keycolor== 0){
            w = KEY_WHT_W;
            h = KEY_WHT_H;
            c = 0xFFFFFF;
            text_c = 0x606060;
        }else{
            w = KEY_BLK_W;
            h = KEY_BLK_H;
            x += 4;
            c = 0x404040;
            text_c = 0xC0C0C0;
        }
        
        //under sprite, non transparent, solid color
        var sp0:Sprite = makeRectSprite(x, y, w, h, KEY_ON_COLOR, KEY_LINE_COLOR);
        
        //top sprite, semi transparent when key is on
        var sp:Sprite = makeRectSprite(x, y, w, h, c, KEY_LINE_COLOR);
        
        var tf:TextField = new TextField();
        tf.text = keyName;
        tf.autoSize = TextFieldAutoSize.CENTER;
        tf.selectable = false;
        tf.x = (keycolor == 0) ? 7 : 4;
        tf.y = h - 20;
        
        var fm:TextFormat = new TextFormat();
        fm.color = text_c;
        fm.font = "_sans";
        fm.size = 12;
        
        tf.setTextFormat(fm);
        sp.addChild(tf);
        
        sp.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void{ noteOn(idx); });
        sp.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void{ noteOff(idx); });
        sp.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void{ noteOff(idx); });
        
        if(keycolor == 0){
            addChildAt(sp, 0);
            addChildAt(sp0, 0);
        }else{
            addChild(sp0);
            addChild(sp);
        }
        
        keys.push(sp);
        keys_is_on.push(false);
    }
    
    public function KeyboardPanel(parent:Sprite, synth:Synthesizer):void{
        this.synth = synth;        

        parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        parent.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        
        var x0:int = 0;
        var y0:int = 3;
        
        for(var i:int = 0; i< KEY_NUM; i++){
            makeKey(x0, y0, i, keycolors[i%12], keyNames.charAt(i));
            x0 += KEY_WHT_W/2;
            if(i % 12 == 4 || i % 12 == 11) x0 += KEY_WHT_W/2;
        }
    }
    
    private function noteOn(i:int):void{
        if(!keys_is_on[i]){
            synth.noteOn(BASE_NOTE + i);
            keys[i].alpha = KEY_ON_ALPHA;
            keys_is_on[i] = true;
        }
    }
    
    private function noteOff(i:int):void{
        if(keys_is_on[i]){
            synth.noteOff(BASE_NOTE + i);
            keys[i].alpha = 1.0;
            keys_is_on[i] = false;
        }
    }
    
    private function onKeyDown(e:KeyboardEvent):void{
        var c:String = String.fromCharCode(e.charCode).toUpperCase();
        var i:int = keyNames.indexOf(c);
        if(i != -1) noteOn(i);
    }
    
    private function onKeyUp(e:KeyboardEvent):void{
        var c:String = String.fromCharCode(e.charCode).toUpperCase();
        var i:int = keyNames.indexOf(c);
        if(i != -1) noteOff(i);
    }
}

//Knob, design modified
class SynthKnob extends Knob{
    public function SynthKnob(parent:DisplayObjectContainer = null, 
        xpos:Number = 0, ypos:Number =  0, label:String = "", 
        defaultValue:Number = 0.0, defaultHandler:Function = null):void{
        super(parent, xpos, ypos, label, defaultHandler);
        
        minimum = 0.0;
        maximum = 1.0;
        showValue = false;
        
        radius = 16;
        y -= 20;            //adjust to same y position as RotarySelector
        value = defaultValue;
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    override protected function drawKnob():void{
        _knob.graphics.clear();
        _knob.graphics.beginFill(STYLE_UI_THEME);
        _knob.graphics.drawCircle(0, 0, _radius);
        _knob.graphics.endFill();
        
        _knob.graphics.beginFill(STYLE_UI_BACKGROUND);
        _knob.graphics.drawCircle(0, 0, _radius - 3);
        _knob.graphics.endFill();
        
        //inner marker
        _knob.graphics.lineStyle(4, STYLE_UI_THEME, 1.0, false,
            LineScaleMode.NORMAL, CapsStyle.NONE);
        _knob.graphics.moveTo(_radius*0.3, 0);
        _knob.graphics.lineTo(_radius-2, 0);
        
        _knob.x = _radius;
        _knob.y = _radius + 20;
        updateKnob();
    }
        
    override public function draw():void{
        super.draw();
        _label.y = _radius * 2 + 20 - 1;    //show label under knob
    }
}

//RotarySelecter, modified for drawing custom choice symbol
class RotarySelectorEx extends RotarySelector{
    public function RotarySelectorEx(parent:DisplayObjectContainer = null,
        xpos:Number = 0, ypos:Number =  0, label:String = "", 
        defaultHandler:Function = null){
        super(parent, xpos, ypos, label, defaultHandler);
        
        setSize(32, 32);    //same radius as Knob
    }
    
    //choice label texts
    protected var _choiceTexts:Array;
    public function set choiceTexts(texts:Array):void{
        _choiceTexts = texts;
        numChoices = texts.length;
        draw();
    }
    public function get choiceTexts():Array{
        return _choiceTexts;
    }
    
    override protected function drawKnob(radius:Number):void{
        _knob.graphics.clear();
        _knob.graphics.beginFill(STYLE_UI_THEME);
        _knob.graphics.drawCircle(0, 0, radius);
        _knob.graphics.endFill();
        
        _knob.graphics.beginFill(STYLE_UI_BACKGROUND);
        _knob.graphics.drawCircle(0, 0, radius - 3);
        
        _knob.x = _width / 2;
        _knob.y = _height / 2;
    }
    
    override public function draw():void{
        super.draw();
        
        var radius:Number = Math.min(_width, _height) / 2;
        drawKnob(radius);
        resetLabels();
        
        var arc:Number = Math.PI * 1.5 / _numChoices;
        var start:Number = - Math.PI / 2 - arc * (_numChoices - 1) / 2;
        
        graphics.clear();
        for(var i:int = 0; i < _numChoices; i++){
            var angle:Number = start + arc * i;
            var sin:Number = Math.sin(angle);
            var cos:Number = Math.cos(angle);
            
            graphics.lineStyle(4, STYLE_UI_THEME, 0.3, false,
                LineScaleMode.NORMAL, CapsStyle.SQUARE);    
            
            graphics.moveTo(_knob.x, _knob.y);
            graphics.lineTo(_knob.x + cos * (radius + 2), _knob.y + sin * (radius + 2));
            
            var lab:Label = new Label(_labels, cos * (radius + 7), sin * (radius + 7));
            lab.mouseEnabled = true;
            lab.buttonMode = true;
            lab.useHandCursor = true;
            lab.addEventListener(MouseEvent.CLICK, onLabelClick);
            
            //choice labels
            lab.text = (choiceTexts && i < choiceTexts.length) ? choiceTexts[i] : " ";
            
            //custom choice symbol draw
            customChoiceDraw(i, _knob.x + cos * (radius + 7),  _knob.y + sin * (radius + 7));
        }
        
        angle = start + arc * _choice;

        //knob, inner marker
        _knob.graphics.lineStyle(4, STYLE_UI_THEME, 1.0, false,
            LineScaleMode.NORMAL, CapsStyle.NONE);
        _knob.graphics.moveTo(Math.cos(angle) * radius * 0.4, Math.sin(angle) * radius*0.4);
        _knob.graphics.lineTo(Math.cos(angle) * radius * 0.9, Math.sin(angle) * radius*0.9);
        
        _label.text = _labelText;
        _label.draw();
        _label.x = _width / 2 - _label.width / 2;
        _label.y = _height-1;
    }
    
    protected function customChoiceDraw(i:int, x:int, y:int):void{
        //if required, override this and draw custom choice symbol here
    }
}

//osc waveform selector
class WaveformSelector extends RotarySelectorEx{
    private const RECTWAVE_LINES:Array =[[-4, 3], [0, -6], [4, 0], [0, 6], [4, 0], [0, -6]];
    private const SAWWAVE_LINES:Array = [[-4, 3], [0, -6], [8, 6], [0, -6]];
    private const TRIWAVE_LINES:Array = [[-1, 0], [3, -4], [4, 5], [3, -4]];
    private const NOISEWAVE_LINES:Array = [
        [4, 4], [0, -6], [2, 0], [0, 4], [2, 0], [0, -2], [2, 0], [0, 4], [2, 0], [0, -6]];
    
    public function WaveformSelector(parent:DisplayObjectContainer = null,
        xpos:Number = 0, ypos:Number =  0, label:String = "",
        defaultHandler:Function = null){
        super(parent, xpos, ypos, label, defaultHandler);
        numChoices = 5;
    }
    
    private function drawPolyLines(x:int, y:int, p:Array):void{
        var px:int = x - 4;
        var py:int = y;
        
        for(var i:int = 0; i< p.length; i++){
            px += p[i][0];
            py += p[i][1];
                
            if(i == 0) graphics.moveTo(px, py);
            else graphics.lineTo(px, py);
        }
    }
    
    private function drawSineSymbol(x:int, y:int):void{
        graphics.moveTo(x, y);
        for(var ix:int = -1; ix<=9; ix++){
            var iy:int = -Math.sin(2.0 * PI * ix / 8.0) * 3;
            graphics.lineTo(x + ix, y + iy);
        }
    }
    
    override protected function customChoiceDraw(i:int, x:int, y:int):void{
        graphics.lineStyle(1, Style.LABEL_TEXT, 1.0, false,
            LineScaleMode.NORMAL, CapsStyle.SQUARE);
        switch(i){
        case WAVEFORM_RECT: drawPolyLines(x, y, RECTWAVE_LINES); break;
        case WAVEFORM_SAW: drawPolyLines(x, y, SAWWAVE_LINES); break;
        case WAVEFORM_TRI: drawPolyLines(x, y, TRIWAVE_LINES); break;
        case WAVEFORM_SINE: drawSineSymbol(x, y); break;
        case WAVEFORM_NOISE: drawPolyLines(x, y, NOISEWAVE_LINES); break;
        default: break;
        }
    }
}