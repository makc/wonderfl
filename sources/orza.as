package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import com.flashdynamix.utils.SWFProfiler;

    public class Main extends Sprite {
        private const rect   : Rectangle = new Rectangle(0, 0, 465, 465);

        private var   canvas : BitmapData;
        private var   trans  : ColorTransform;
        private var   mat    : Matrix;
        private var   loader : URLLoader;
        
        private var   rim    : Rim;
        private var   pdp1   : PDP1;
        private var   disp   : Display;
        private var   pad    : Gamepad;
		
        [SWF(width="465", height="465", frameRate="15")]
        public function Main() : void
        {
            Wonderfl.disable_capture();
            SWFProfiler.init(this);

            // initialize graphic resource
            canvas = new BitmapData(465, 465, false, 0x000000);
            trans  = new ColorTransform(1, 0.7, 1);
            mat    = new Matrix();
            mat.scale(465 / 1024, 465 / 1024);
            addChild(new Bitmap(canvas));

            // kick rim data loader
            var url : String = "http://wonderfl.toyoshima-house.net/spacewar.rim";
            loader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.load(new URLRequest(url));
            loader.addEventListener(Event.COMPLETE, RimLoad);
        }

        private function RimLoad (event : Event) : void {
            // load rim data
            var rim_file : Array;
            var rim_size : int;
            rim_size = loader.bytesTotal;
            rim_file = new Array(rim_size);
            var i : int;
            for (i = 0; i < rim_size; i++) {
                rim_file[i] = loader.data.readUnsignedByte();
            }

            // initialize PDP-1 memory
            var mem : Array;
            mem = new Array(4096);
            for (i = 0; i < 4096; i++) {
                mem[i] = 0;
            }

            // boot from rim
            rim = new Rim();
            rim.Load(rim_file, rim_size);
            var pc : int = rim.Boot(mem);
            
            // initialize display
            disp = new Display();

            // start keyboard emulation
            pad = new Gamepad();
            stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP  , KeyUp  );

            // reset PDP-1 CPU core
            pdp1 = new PDP1();
            pdp1.Reset(pc, mem, rim, disp, pad);
            
            // start screen emulation
            addEventListener(Event.ENTER_FRAME, Update);
        }
        
        private function KeyDown (e : KeyboardEvent) : void {
            switch (e.charCode) {
                case 0x41: // A
                case 0x61: // a
                    pad.Set(2); // 1: rotate L
                    break;
                case 0x53: // S
                case 0x73: // s
                    pad.Set(3); // 1: rotate R
                    break;
                case 0x44: // D
                case 0x64: // d
                    pad.Set(1); // 1: engines
                    break;
                case 0x46: // F
                case 0x66: // f
                    pad.Set(0); // 1: torpedos
                    break;
                case 0x48: // H
                case 0x68: // h
                    pad.Set(16); // 2: rotate L
                    break;
                case 0x4a: // J
                case 0x6a: // j
                    pad.Set(17); // 2: rotate R
                    break;
                case 0x4b: // k
                case 0x6b: // K
                    pad.Set(15); // 2: engines
                    break;
                case 0x4c: // l
                case 0x6c: // L
                    pad.Set(14); // 2: torpedos
                    break;
            }
        }
        
        private function KeyUp (e : KeyboardEvent) : void {
            switch (e.charCode) {
                case 0x41: // A
                case 0x61: // a
                    pad.Reset(2); // 1: rotate R
                    break;
                case 0x53: // S
                case 0x73: // s
                    pad.Reset(3); // 1: rotate L
                    break;
                case 0x44: // D
                case 0x64: // d
                    pad.Reset(1); // 1: engines
                    break;
                case 0x46: // F
                case 0x66: // f
                    pad.Reset(0); // 1: torpedos
                    break;
                case 0x48: // H
                case 0x68: // h
                    pad.Reset(16); // 2: rotate R
                    break;
                case 0x4a: // J
                case 0x6a: // j
                    pad.Reset(17); // 2: rotate L
                    break;
                case 0x4b: // k
                case 0x6b: // K
                    pad.Reset(15); // 2: engines
                    break;
                case 0x4c: // l
                case 0x6c: // L
                    pad.Reset(14); // 2: torpedos
                    break;
            }
        }
        
        private function Update (e : Event) : void
        {
            disp.Lock();
            
            for (var i : int = 0; i < 10000; i++) {
                pdp1.Step();
            }
            disp.Unlock();
            
            canvas.lock();
            canvas.colorTransform(rect, trans);
            canvas.draw(disp.Bitmap(), mat, null, BlendMode.ADD);
            canvas.unlock();
        }
    }	
}

    import flash.display.BitmapData;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.filters.BlurFilter;


    internal class Rim {
        private var rim : Array;
        private var rim_size : int;
        private var rim_offset : int;
    
        public function Load (_rim : Array, size : int) : void {
            rim = _rim;
            rim_size = size;
            rim_offset = 0;
        }
        
        public function Boot (mem : Array) : int {
            for (;; ) {
                var cmd : int = Get();
                var ins : int = cmd >> 12;
                var adr : int = cmd & 0xfff;
                if (cmd < 0) return -1;
                switch(ins) {
                    case 0x1A: /* 032 */
                        cmd = Get();
                        trace("rim: mem[" + TraceUtil.to06o(adr) + "] := " + TraceUtil.to06o(cmd));
                        mem[adr] = cmd;
                        break;
                    case 0x30: /* 60 */
                        trace("rim: org := " + TraceUtil.to06o(adr));
                        return adr;
                    default:
                        trace("rim: unexpected instruction " + ins + " " + ((cmd >> 6) & 0x3f) + " " + (cmd & 0x3f));
                        return -2;
                }
            }
            return 0;
        }
        
        public function Get () : int {
            var result : int;
            
            for (;; ) {
                if ((rim_offset + 1) >= rim_size) return -1;
                if (0 != (rim[rim_offset] & 0x80)) break;
                rim_offset++;
            }
            if ((rim_offset + 3) >= rim_size) return -1;
            if ((0 == (0x80 & (rim[rim_offset + 0] &
                               rim[rim_offset + 1] &
                               rim[rim_offset + 2]))) ||
                (0 != (0x40 & (rim[rim_offset + 0] |
                               rim[rim_offset + 1] |
                               rim[rim_offset + 2])))) {
                trace("rim error: " + rim[rim_offset + 0].toString(8) + " " +
                                      rim[rim_offset + 1].toString(8) + " " +
                                      rim[rim_offset + 2].toString(8));
                return -2;
            }
            result = ((rim[rim_offset + 0] & 0x3f) << 12) |
                     ((rim[rim_offset + 1] & 0x3f) <<  6) |
                     ((rim[rim_offset + 2] & 0x3f) <<  0);
            rim_offset += 3;
            return result;
        }
    }

    internal class PDP1 {
        private var pc   : int;
        private var ir   : int;
        private var y    : int;
        private var inst : int;
        private var ind  : int;
        private var io   : int;
        private var xct  : int;
        private var ac   : int;
        private var ov   : int;
        private var dump : int;
        private var test : int;
        private var pf   : int;
        private var cm   : Array;
        private var rim  : Rim;
        private var disp : Display;
        private var pad  : Gamepad;
        
        public function Reset(_pc : int, _cm : Array, _rim : Rim, _disp : Display, _pad : Gamepad) : void {
            pc   = _pc;
            ir   = 0;
            y    = 0;
            inst = 0;
            ind  = 0;
            io   = 0;
            xct  = 0;
            ac   = 0;
            ov   = 0;
            dump = 0;
            test = 0;
            pf   = 0;
            cm   = _cm;
            rim  = _rim;
            disp = _disp;
            pad  = _pad;
        }
        
        public function Step() : int {
            var tmp : int;
            
            if (xct == 0) {
                //Trace();
                ir = cm[pc];
                pc = pc + 1;
            } else {
                ir = cm[y];
                xct = 0;
            }
            inst = (ir >> 12) & 0x3e;
            ind  = (ir >> 12) & 1;
            y    = ir & 0x0fff;
            
            switch (inst) {
                case 0x02: // 002 and
                    Op();
                    ac &= cm[y];
                    break;
                case 0x04: // 004 ior
                    Op();
                    ac |= cm[y];
                    break;
                case 0x06: // 006 xor
                    Op();
                    ac ^= cm[y];
                    break;
                case 0x08: // 010 xct
                    Op();
                    xct = 1;
                    break;
                case 0x0e: // 016
                    if (0 == ind) {
                        // cal
                        cm[0x040] = ac;
                        ac = (ov << 17) + pc;
                        pc = 0x41;
                    } else {
                        // jda
                        cm[y] = ac;
                        ac = (ov << 17) + pc;
                        pc = y + 1;
                    }
                    break;
                case 0x10: // 020 lac
                    Op();
                    ac = cm[y];
                    break;
                case 0x12: // 022 lio
                    Op();
                    io = cm[y];
                    break;
                case 0x14: // 024 dac
                    Op();
                    cm[y] = ac;
                    break;
                case 0x16: // 026 dap
                    Op();
                    cm[y] = (cm[y] & 0x3f000) | (ac & 0x00fff);
                    break;
                case 0x1a: // 032 dio
                    Op();
                    cm[y] = io;
                    break;
                case 0x1c: // 034 dzm
                    Op();
                    cm[y] = 0;
                    break;
                case 0x20: // 040 add
                    Op();
                    tmp = ac;
                    ac += cm[y];
                    if (ac > 0x3ffff) ac = (ac + 1) & 0x3ffff;
                    if (0 != ((cm[y] ^ ~tmp) & (ac ^ tmp) & 0x20000)) ov |= 1;
                    if (0x3ffff == ac) ac = 0;
                    break;
                case 0x22: // 042 sub
                    Op();
                    tmp = ac ^ 0x3ffff;
                    ac = tmp + cm[y];
                    if (ac > 0x3ffff) ac = (ac + 1) & 0x3ffff;
                    if (0 != ((cm[y] ^ ~tmp) & (ac ^ tmp) & 0x20000)) ov |= 1;
                    ac ^= 0x3ffff;
                    break;
                case 0x24: // 044 idx
                    Op();
                    ac = cm[y] + 1;
                    if (0x3ffff <= ac) ac = (ac + 1) & 0x3ffff;
                    cm[y] = ac;
                    break;
                case 0x26: // 046 isp
                    Op();
                    ac = cm[y] + 1;
                    if (0x3ffff <= ac) ac = (ac + 1) & 0x3ffff;
                    cm[y] = ac;
                    if (0 == (ac & 0x20000)) pc++;
                    break;
                case 0x28: // 050 sad
                    Op();
                    if (cm[y] != ac) pc++;
                    break;
                case 0x2a: // 052 sas
                    Op();
                    if (cm[y] == ac) pc++;
                    break;
                case 0x2c: // 054 mus
                    Op();
                    if (0 != (io & 1)) {
                        ac += cm[y];
                        ac += (ac >> 18);
                        ac &= 0x3ffff;
                        if (0x3ffff == ac) ac = 0;
                    }
                    io = ((io >> 1) | (ac << 17)) & 0x3ffff;
                    ac >>= 1;
                    break;
                case 0x2e: // 056 div
                    Op();
                    tmp = ac >> 17;
                    ac = ((ac << 1) | (io >> 17)) & 0x3ffff;
                    io = ((io << 1) | (tmp ^ 1)) & 0x3ffff;
                    if (0 != (io & 1)) ac = ac + (cm[y] ^ 0x3ffff);
                    else ac = ac + cm[y] + 1;
                    if (ac > 0x3ffff) ac = (ac + 1) & 0x3ffff;
                    if (0x3ffff == ac) ac = 0;
                    break;
                case 0x30: // 060 jmp
                    Op();
                    pc = y;
                    break;
                case 0x32: // 062 jsp
                    Op();
                    ac = (ov << 17) + pc;
                    pc = y;
                    break;
                case 0x34: // 064 skp
                    return SKP();
                case 0x36: // 066 sft
                    return SFT();
                case 0x38: // 070 law
                    ac = (0 == ind)? y: (y ^ 0x3ffff);
                    break;
                case 0x3a: // 072 iot
                    tmp = IOT();
                    //pc--;
                    //Trace();
                    //pc++;
                    return tmp;
                case 0x3e: // 076 opr
                    return OPR();
                default:
                    trace("!!! error !!! : unknown instruction " + TraceUtil.to02o(inst + ind));
                    return -1;
            }
            return 0;
        }
        
        private function Op () : void {
            while (0 != ind) {
                ir  = cm[y];
                ind = (ir >> 12) & 1;
                y   = ir & 0xfff;
            }
        }
        
        private function SKP () : int {
            var skip : int = 0;
            if (((0 != (y & 0x040)) && (0 ==  ac           )) ||
                ((0 != (y & 0x080)) && (0 == (ac & 0x20000))) ||
                ((0 != (y & 0x100)) && (0 != (ac & 0x20000))) ||
                ((0 != (y & 0x200)) && (0 ==  ov           )) ||
                ((0 != (y & 0x400)) && (0 == (io & 0x20000)))) {
                skip = 1;
            }
            if (0 != (y & 0x038)) {
                //trace("skip on switch");
                skip = 1;
            }
            if (0 != (y & 0x007)) {
                var flags : Array = [ 0x00, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01, 0x3f ];
                if (0 == (pf & flags[y & 007])) skip = 1;
            }
            if (0 != (y & 0x200)) {
                ov = 0;
            }
            if (0 != (skip ^ ind)) {
                pc++;
            }
            if (0 != (y & 0x800)) {
                trace("!!! error !!! : skip on unknown flags");
                return -1;
            }
            return 0;
        }
        
        private function SFT () : int {
            var mode : int = (ind << 3) | (y >> 9);
            var n    : int = PopCount(y & 0x1ff);
            var tmp  : int;
            switch (mode) {
                case 0x01: // 001 ral
                    ac  = ((ac << n) | (ac >> (18 - n))) & 0x3ffff;
                    break;
                case 0x02: // 002 ril
                    io  = ((io << n) | (io >> (18 - n))) & 0x3ffff;
                    break;
                case 0x03: // 003 rcl
                    tmp = ((ac << n) | (io >> (18 - n))) & 0x3ffff;
                    io  = ((io << n) | (ac >> (18 - n))) & 0x3ffff;
                    ac  = tmp;
                    break;
                case 0x05: // 005 sal
                    tmp = (0 != (ac & 0x20000))? 0x3ffff: 0;
                    ac  = (ac & 0x20000) | ((ac << n) & 0x1ffff) | (tmp >> (18 - n));
                    break;
                case 0x06: // 006 sil
                    tmp = (0 != (io & 0x20000))? 0x3ffff: 0;
                    io  = (io & 0x20000) | ((io << n) & 0x1ffff) | (tmp >> (18 - n));
                    break;
                case 0x07: // 007 scl
                    tmp = (0 != (ac & 0x20000))? 0x3ffff: 0;
                    ac  = (ac & 0x20000) | ((ac << n) & 0x1ffff) | (io  >> (18 - n));
                    io  =                  ((io << n) & 0x3ffff) | (tmp >> (18 - n));
                    break;
                case 0x09: // 011 rar
                    ac  = ((ac >> n) | (ac << (18 - n))) & 0x3ffff;
                    break;
                case 0x0a: // 012 rir
                    io  = ((io >> n) | (io << (18 - n))) & 0x3ffff;
                    break;
                case 0x0b: // 013 rcr
                    tmp = ((ac >> n) | (io << (18 - n))) & 0x3ffff;
                    io  = ((io >> n) | (ac << (18 - n))) & 0x3ffff;
                    ac  = tmp;
                    break;
                case 0x0d: // 015 sar
                    tmp = (0 != (ac & 0x20000))? 0x3ffff: 0;
                    ac  = ((ac >> n) | (tmp << (18 - n))) & 0x3ffff;
                    break;
                case 0x0e: // 016 sar
                    tmp = (0 != (io & 0x20000))? 0x3ffff: 0;
                    io  = ((io >> n) | (tmp << (18 - n))) & 0x3ffff;
                    break;
                case 0x0f: // 017 scr
                    tmp = (0 != (ac & 0x20000))? 0x3ffff: 0;
                    io  = ((io >> n) | (ac  << (18 - n))) & 0x3ffff;
                    ac  = ((ac >> n) | (tmp << (18 - n))) & 0x3ffff;
                    break;
                default:
                    trace("!!! error !!! : unknown shift operation: " + TraceUtil.to02o(mode));
                    return -1;
            }
            return 0;
        }
        
        private function OPR () : int {
            var cmd : int = y;
            if (0 != (cmd & 0x080)) {
                // cla
                ac = 0;
                cmd &= ~0x080;
            }
            if (0 != (cmd & 0x100)) {
                // hlt
                trace("hlt");
                cmd &= ~0x100;
            }
            if (0 != (cmd & 0x200)) {
                // cma
                ac = ac ^ 0x3ffff;
                cmd &= ~0x200;
            }
            if (0 != (cmd & 0x400)) {
                // lat
                ac |= test;
                cmd &= ~0x400;
            }
            if (0 != (cmd & 0x800)) {
                // cli
                io = 0;
                cmd &= ~0x800;
            }
            if (0 != (cmd & 0x007)) {
                var flags : Array = [ 0x00, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01, 0x3f ];
                if (0 != (cmd & 0x008)) {
                    pf |= flags[cmd & 0x007];
                } else {
                    pf &= ~flags[cmd & 0x007];
                }
                cmd &= ~0x00f;
            }
            if (0 != cmd) {
                trace("!!! error !!! : unknown operation: " + TraceUtil.to04o(cmd));
                return -1;
            }
            return 0;
        }
        
        private function IOT () : int {
            switch (y & 0x3f) {
                case 0x00: // 000
                    break;
                case 0x02: // 002
                    io = rim.Get();
                    //trace("rpb -> " + TraceUtil.to06o(io));
                    if (io < 0) return -1;
                    break;
                case 0x07: // 007
                    disp.SetPoint(((ac >> 8) + 0x200) & 0x3ff, ((io >> 8) + 0x200) & 0x3ff);
                    //trace("display (" + TraceUtil.tod(ac) + ", " + TraceUtil.tod(io) + ")");
                    break;
                case 0x09: // 011
                    io = pad.Get();
                    //trace("spacewar -> " + TraceUtil.to04o(io));
                    break;
                default:
                    trace("!!! error !!! : unknown io device : " + TraceUtil.to04o(y));
                    return -1;
            }
            return 0;
        }
        
        private function PopCount (n : int) : int {
            var c : int = 0;
            var i : int;
            for (i = 0; i < 9; i++) {
                if (0 != (n & (1 << i))) {
                    c++;
                }
            }
            return c;
        }
        
        private function Trace () : void {
            trace("PC: "   + TraceUtil.to06o(pc)                 + ", " +
                  "IO: "   + TraceUtil.to06o(io)                 + ", " +
                  "AC: "   + TraceUtil.to06o(ac)                 + ", " +
                  "OV: "   + TraceUtil.tod(ov)                   + ", " +
                  "I: "    + TraceUtil.tod((cm[pc] >> 12) & 1)   + ", " +
                  "M[Y]: " + TraceUtil.to06o(cm[y])              + ", " +
                  "PF: "   + TraceUtil.to06o(pf));
        }
    }
    
    internal class Display {
        private const rect : Rectangle = new Rectangle(0, 0, 1024, 1024);
        private const zero : Point     = new Point(0, 0);
        private var   bmp  : BitmapData;
        private var   blur : BlurFilter;

        public function Display () : void {
            bmp  = new BitmapData(1024, 1024, false, 0x000000);
            blur = new BlurFilter(2, 2, 1);
        }

        public function Lock () : void {
            bmp.lock();
            bmp.fillRect(rect, 0x000000);
        }
        
        public function Unlock () : void {
            //bmp.applyFilter(bmp, rect, zero, blur);
            bmp.unlock();
        }
        
        public function Bitmap () : BitmapData {
            return bmp;
        }
        
        public function SetPoint (x : int, y : int) : void {
            bmp.setPixel(x, y, 0x00ff00);
        }
    }
    
    internal class Gamepad {
        private var sw : int = 0;
        
        public function Set (n : int) : void {
            sw |= (1 << n);
        }
        
        public function Reset (n : int) : void {
            sw &= ~(1 << n);    
        }
        
        public function Get () : int {
            return sw;
        }
    }
    
    internal class TraceUtil {
        static public function to02o (n : int) : String {
            return to0o(2, n);
        }
        
        static public function to04o (n : int) : String {
            return to0o(4, n);
        }
        
        static public function to06o (n : int) : String {
            return to0o(6, n);
        }
        
        static public function to0o (width : int, n : int) : String {
            var str : String = "00000000" + n.toString(8);
            return str.substr(str.length - width, width);
        }
        
        static public function tod (n : int) : String {
            return n.toString(10);
        }
    }