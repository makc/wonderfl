package {
    import flash.display.Sprite;
    import org.si.sion.SiONDriver;
    import org.si.sion.effector.SiEffectStereoDelay;
    import org.si.sion.events.SiONTrackEvent;
    import frocessing.color.ColorHSV;

    [SWF(backgroundColor=0, frameRate=60)]

    public class FlashTest extends Sprite {
        public function FlashTest() {
            // NOTE_ON_FRAME won't fire without a %t!!!
            var bwv846:String = "%t t250 l8 [ce[g<ce]2]2> [cd[a<df]2]2> [>b<d[g<df]2]2> [ce[g<ce]2]2> [ce[a<ea]2]2> [cd[f#a<d]2]2> [>b<d[g<dg]2]2> [>b<c[eg<c]2]2> [>a<c[eg<c]2]2> [>da[<df#<c]2]2> [>gb[<dgb]2]2> [gb-[<eg<c#]2]2>> [fa[<da<d]2]2>> [fa-[<dfb]2]2> [eg[<cg<c]2]2>> [ef[a<cf]2]2> [df[a<cf]2]2>> [g<d[gb<f]2]2> [ce[g<ce]2]2> [cg[b-<ce]2]2>> [f<f[a<ce]2]2>> [f#<c[a<ce-]2]2>> [a-<f[b<cd]2]2>> [g<f[gb<d]2]2>> [g<e[g<ce]2]2>> [g<d[g<cf]2]2>> [g<d[gb<f]2]2>> [g<e-[a<cf#]2]2>> [g<e[g<cg]2]2>> [g<d[g<cf]2]2>> [g<d[gb<f]2]2>> [c<c[gb-<e]2]2>> c<cfa<cfc>a<c>afafdfd> cb<<gb<dfd>b<d>bgbdfedc";

            var driver:SiONDriver = new SiONDriver;
            var delay:SiEffectStereoDelay = new SiEffectStereoDelay(200, 0.75, false, 0.3);
            
            driver.addEventListener(SiONTrackEvent.NOTE_ON_FRAME, listener);
            driver.effector.initialize();
            driver.effector.connect(0, delay);
            driver.play(bwv846, false);
        }
        
        private var c:ColorHSV = new ColorHSV();
        private var cnt:int = 0;

        private function listener(e:SiONTrackEvent):void {
            c.h = (e.note % 12) /  12 * 360;
            
            var x:int = cnt % 4;
            var y:int = cnt / 4;

            with(graphics) {
                if(!cnt) clear();
                beginFill(c.value);
                drawRect(465/4 + x * 456/8, 465/4 + y * 456/8, 465/8-4, 465/8-4);
                endFill();
            }
            
            cnt = (cnt + 1) % 16;
        }
    }
}