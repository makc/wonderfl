// forked from wanson's 音声合成もどき
package {
import flash.display.*;
import flash.events.*;
import flash.media.*;
public class Voice extends Sprite {
    private var phase:Number = 0, time:Number = 0;
    private var tap:Array = [0., 0., 0., 0., 0., 0., 0., 0., 0., 0.];
    private const FL:Array = [
        [800., 1300., 2500., 3500., 4500., 0.9],
        [250., 2100., 3100., 3500., 4500., 1.3],
        [250., 1400., 2200., 3500., 4500., 1.2],
        [450., 1900., 2400., 3500., 4500., 0.9],
        [450.,  900., 2600., 3500., 4500., 0.8]];
    private var notes:Array = [
        15, 17, 19, 20, 19, 17, 15,  0, 19, 20, 22, 24, 22, 20, 19, 0,
        15,  0, 15,  0, 15,  0, 15,  0, 15, 17, 19, 20, 19, 17, 15, 0,
    ];
    private var n:int = 0;
    private var prevFreq:Number = 0;
    private var freq:Number = 440;
    private var count:int = 0;
    private const speed:Number = 4 / 1.5;
    private const portament:Number = 1000;
    private var vow1:int = 0;
    private var vow2:int = 1;
    private var prevTiming:Number = 0;
    public function Voice() {
        var sound:Sound = new Sound();
        sound.addEventListener(SampleDataEvent.SAMPLE_DATA, function(event:SampleDataEvent):void {
            for (var i:int = 0; i < 8192; i++, phase += freq / 44100, time += 1. / 44100.) {
                const nn:int = notes[Math.floor((time + 0.5)* speed) % notes.length];
                const timing:Number = time * speed;
                if (nn != 0) n = nn;
                const nextFreq:Number = (55 << (n / 12)) * Math.pow(2, (n % 12) / 12);
                if (Math.floor(prevTiming) - Math.floor(timing) < 0) {
                    vow1 = count % 5;
                    if (prevFreq != nextFreq)
                        count++;
                    vow2 = count % 5;
                    prevTiming = timing;
                    prevFreq = nextFreq;
                } 
                const amp:Number = (.65 - .15 * Math.cos(Math.PI * timing));
                const w:Number = 1 / (1 + Math.exp(-30 * (timing - Math.floor(timing) - .5)));
                var s:Number = .4 * Math.sin(phase - Math.floor(phase))
                    * ((1 - w) * FL[vow1][5] + w * FL[vow1][5]) * amp;
                freq += (nextFreq - freq) / portament;
                for (var k:int = 0; k < 5; k++) {
                    const ff:Number = (1 - w) * FL[vow1][k] + w * FL[vow2][k];
                    const r:Number  = Math.exp(-Math.PI * 50. * (1. + ff * ff * 1e-6 / 6.) / 44100.);
                    const a1:Number = 2. * r * Math.cos(2.0 * Math.PI * ff / 44100.);
                    s = (1. - a1 + r * r) * s + (a1 * tap[k]) - (r * r * tap[k + 5]);
                    tap[k + 5] = tap[k]; tap[k] = s;
                }
                event.data.writeFloat(s); event.data.writeFloat(s);
           }
        });
        sound.play();
    }
}}
