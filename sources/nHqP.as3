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
    public function Voice() {
        var sound:Sound = new Sound();
        sound.addEventListener(SampleDataEvent.SAMPLE_DATA, function(event:SampleDataEvent):void {
            for (var i:int = 0; i < 8192; i++, phase += freq / 44100, time += 1. / 44100.) {
                const vow1:int = Math.floor(time / 1.5 * 5) % 5;
                const vow2:int = (vow1 + 1) % 5;
                const amp:Number = (.65 - .15 * Math.cos(time * Math.PI / 1.5 * 5));
                const freq:Number = 160 + 50 * Math.sin(2 * Math.PI * time * 1.7)
                    + 40 + 70 * Math.sin(2 * Math.PI * time / 23 +  2 * Math.cos(time));
                const w:Number = 1 / (1 + Math.exp(-30 * (5 * time / 1.5 - Math.floor(5 * time / 1.5) - .5)));
                var s:Number = .4 * Math.sin(phase - Math.floor(phase))
                    * ((1 - w) * FL[vow1][5] + w * FL[vow1][5]) * amp;
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
