// Adobe is being the bitch
// Please support rtmpdump by making creative code with this number
// Since wonderfl is in Japan, Adobe can stick their DMCA up theirs
// @see http://ncannasse.fr/blog/rtmpe_and_dmca?lang=en
package {
    import flash.display.Sprite;
    import flash.text.TextField;
    public class AdobeTheBitch extends Sprite {
        public var poem:Array = [
            0x47, 0x65, 0x6E, 0x75, 0x69, 0x6E, 0x65, 0x20,
            0x41, 0x64, 0x6F, 0x62, 0x65, 0x20, 0x46, 0x6C,
            0x61, 0x73, 0x68, 0x20, 0x50, 0x6C, 0x61, 0x79,
            0x65, 0x72, 0x20, 0x30, 0x30, 0x31, 0xF0, 0xEE,
            0xC2, 0x4A, 0x80, 0x68, 0xBE, 0xE8, 0x2E, 0x00,
            0xD0, 0xD1, 0x02, 0x9E, 0x7E, 0x57, 0x6E, 0xEC,
            0x5D, 0x2D, 0x29, 0x80, 0x6F, 0xAB, 0x93, 0xB8,
            0xE6, 0x36, 0xCF, 0xEB, 0x31, 0xAE
        ];
        public function AdobeTheBitch() {
            var t:TextField = new TextField;
            t.autoSize = "left";
            for (var i:int = 0; i < poem.length; i++) {
                var s:String = int(poem [i]).toString (16) + " ";
                if (s.length < 3)
                    s = "0" + s;
                t.appendText (s);
                if (i % 8 == 7)
                    t.appendText ("\n");
            }
            t.htmlText = "<font face=\"fixedsys\">" +
                t.text + "</font>";
            addChild (t);
        }
    }
}