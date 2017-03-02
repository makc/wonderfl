// forked from keim_at_Si's SiON Tenorion
// SiON TENORION_CUBE
package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    
    import org.si.sion.*;
    import org.si.sion.events.*;
    import org.si.sion.sequencer.SiMMLTrack;
    import org.si.sion.utils.SiONPresetVoice;

    import org.papervision3d.events.*;
    import org.papervision3d.view.*;
    import org.papervision3d.core.geom.*;
    import org.papervision3d.core.utils.*;
    import org.papervision3d.core.utils.virtualmouse.*;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.materials.utils.*;
    
    [SWF(width="465", height="465", backgroundColor="#000000", frameRate=30)]
    public class Tenorion extends BasicView
    {
        // driver
        public var driver:SiONDriver = new SiONDriver();

        //custom voice
        public var customVoice:CustomVoice = new CustomVoice();

        // voices, notes and tracks
        private var _effsends:Vector.<Number> = Vector.<Number>([0,0.2,0.3,0.3, 0.2,0.2,0.2,0.2, 0.2,0.2,0.2,0.2, 0.2,0.2,0.2,0.2]);
        private var _voices:Vector.<int> = Vector.<int>([0,1,2,3, 4,4,4,4, 4,4,4,4, 4,4,4,4]);
        private var _notes:Vector.<int> = Vector.<int>([36,36,60,60, 43,48,55,60, 65,67,70,72, 77,79,82,84, 43,46,48,53, 55,58,60,65, 67,70,72,77, 79,82,84,89]);
        private var _rhythmpattern:Vector.<int> = Vector.<int>([0x1111,0x5010,0x6663,0x8884,0,0,0,0,0,0,0,0,0,0,0,0]);
        private var _seqpattern:Vector.<int> = Vector.<int>([0,0,0,0,0,0,0,0x1249,0,0x0082,0x0800,0x4204,0,0x0100,0x0002,0]);

        // beat counter
        public var beatCounter:int;

        // control pad
        public var matrixPad:MatrixPad;
        public var matrixPad2:MatrixPad;
        private var matrixRect:Rectangle;
        private var matrixPoint:Point;
        
        private var vMouse:VirtualMouse;
        private var ism:InteractiveSceneManager;
        private var matrixPads:Dictionary = new Dictionary();

        // constructor
        function Tenorion()
        {
            super (0,0,true,true,"Target");

            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.quality = StageQuality.LOW;
            
            driver.setVoice(0, customVoice["rect.kick"]);
            driver.setVoice(1, customVoice["rect.snare"]);
            driver.setVoice(2, customVoice["rect.hc"]);
            driver.setVoice(3, customVoice["rect.ho"]);
            driver.setVoice(4, customVoice["rect.bass"]);
            driver.setVoice(5, customVoice["rect.sequence2"]);
            driver.setVoice(6, customVoice["rect.sequence"]);
            driver.setVoice(7, customVoice["rect.sequence4"]);
            driver.setVoice(8, customVoice["rect.sequence3"]);
            driver.setVoice(9, customVoice["rect.Pad"]);

            // listen click
            driver.setTimerInterruption(1, _onTimerInterruption);
            driver.setBeatCallbackInterval(1);
            driver.addEventListener(SiONTrackEvent.BEAT, _onBeat);
            driver.addEventListener(SiONEvent.STREAM_START, _onStreamStart);

            init3D();
            startRendering();
            
            
            // start streaming
            driver.play("#EFFECT1{reverb70,40,60,70};t120;");
        }
        
        private var objCube:Cube;
        private function init3D():void
        {
            vMouse = viewport.interactiveSceneManager.virtualMouse;
            Mouse3D.enabled = true;

            camera.fov = 45;
            camera.x = 0;
            camera.y = 0;
            camera.z = camera.focus * camera.zoom + 160;

            matrixRect = new Rectangle(0,0,320,320);
            matrixPoint = new Point(0,0);
            var padColor:Array = [
            {on:0xffcc00,off:0x644f00},{on:0xff3366, off:0x641428},{on:0x99cc00, off:0x3b5000},
            {on:0x00cccc, off:0x005050},{on:0x6666ff, off:0x282864},{on:0xe266ff, off:0x592864}
            ];
            
            var _materials:Array = [];
            for(var i:int = 0; i < 6; i++)
            {
                var matrixPad:MatrixPad = new MatrixPad(padColor[i], (i == 0)? _rhythmpattern:(i == 2)? _seqpattern:null);
                var bmd:BitmapData = new BitmapData(320,320,false);
                var btMat:BitmapMaterial = new BitmapMaterial(bmd);
                btMat.interactive = true;

                for (var j:int = 0; j < 16; j++)
                {
                    matrixPad.effsends[j] = (i == 0)? (_effsends[j]) : 1;
                    matrixPad.voices[j] = (i == 0)? (_voices[j]) : i+4;
                    matrixPad.notes[j] = (i == 0)? (_notes[j]) : (_notes[j+16]);
                }
                
                 matrixPads[btMat] = matrixPad;
                _materials.push(btMat);
            }

            var matList:MaterialsList = new MaterialsList({
                front:_materials[0],
                back:_materials[1],
                top:_materials[2],
                bottom:_materials[3],
                right:_materials[4],
                left:_materials[5]
            });

            objCube = new Cube(matList, 320, 320, 320, 4, 4, 4);
            scene.addChild(objCube);
            objCube.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, _cubeClickHandler);
        }

        override protected function onRenderTick(event:Event = null):void
        {
            if (beatCounter > 16)
            {
                objCube.rotationX += 0.2;
                objCube.rotationY += 0.2;
            }
            for each(var item:BitmapMaterial in objCube.materials.materialsByName)
            {
                item.texture.copyPixels(matrixPads[item].bitmapData, matrixRect, matrixPoint);
            }
            super.onRenderTick(event);
        }

        private function _cubeClickHandler(e:InteractiveScene3DEvent):void
        {
            var axis:Point = new Point(vMouse.x, vMouse.y);
            matrixPads[e.face3d.material]._onClick(axis);
        }

        // _onStreamStart (SiONEvent.STREAM_START) is called back first of all after SiONDriver.play().
        private function _onStreamStart(e:SiONEvent) : void
        {
            for each(var pad:MatrixPad in matrixPads)
            {
                // create new controlable tracks and set voice
                for (var i:int=0; i<16; i++) {
                    pad.tracks[i] = driver.sequencer.newControlableTrack();
                    pad.tracks[i].setChannelModuleType(6, 0, pad.voices[i]);
                    pad.tracks[i].velocity = 64;
                    pad.tracks[i].channel.setStreamSend(1, pad.effsends[i]);
                }
            }
            beatCounter = 0;
        }

        // _onBeat (SiONTrackEvent.BEAT) is called back in each beat at the sound timing.
        private function _onBeat(e:SiONTrackEvent) : void 
        {
            for each(var pad:MatrixPad in matrixPads)
            {
                pad.beat(e.eventTriggerID & 15);
            }
        }

        // _onTimerInterruption (SiONDriver.setTimerInterruption) is called back in each beat at the buffering timing.
        private function _onTimerInterruption() : void
        {
            var beatIndex:int = beatCounter & 15;
            for each(var pad:MatrixPad in matrixPads)
            {
                for (var i:int=0; i<16; i++) {
                    if (pad.sequences[i] & (1<<beatIndex)) pad.tracks[i].keyOn(pad.notes[i]);
                }
            }
            beatCounter++;
        }
    }
}


import org.si.sion.SiONVoice;
dynamic class CustomVoice
{
    function CustomVoice()
    {
        _setOPM("rect.sequence4","Sequence Sound4",4,7,18,16,6,8,4,26,2,2,0,0,0,31,14,8,8,4,0,2,1,-3,0,0,18,16,6,8,4,36,2,4,0,0,0,31,14,8,8,4,0,2,2,7,0,0);
        _setOPM("rect.sequence3","Sequence Sound3",4,7,31,8,6,8,0,20,0,1,0,0,0,31,15,6,8,8,2,0,1,0,0,0,31,5,0,0,0,127,0,4,0,0,0,31,0,0,15,0,127,0,2,0,0,0);
        _setOPM("rect.Pad","Pad",4,5,18,4,8,8,2,37,1,1,2,0,0,10,8,8,8,2,15,2,3,1,0,0,18,4,8,8,2,32,0,1,0,0,0,10,8,8,8,2,15,0,3,-2,0,0);
        _setOPM("rect.sequence2","Sequence Sound2",4,7,28,18,6,8,3,26,1,4,0,0,0,20,18,12,8,1,10,1,2,0,0,0,31,15,6,8,0,127,0,0,0,0,0,31,18,6,8,0,127,0,0,0,0,0);
        _setOPM("rect.sequence","Sequence Sound",6,6, 10,15,14,6,1,40,0,0,1,0,0, 20,10,12,6,6,18,1,1,0,0,0, 24,15,10,12,8,10,0,1,0,0,0, 20,30,20,8,0,0,0,1,3,0,0);
        _setOPM("rect.bass","Bass",4,7,31,11,8,7,2,28,0,0,1,0,0,31,28,8,7,1,0,0,1,0,0,0,31,18,8,7,3,20,0,0,0,0,0,31,12,8,7,1,0,0,0,-1,0,0);
        _setOPM("rect.kick","Bass Drum",5,5, 31,22,10,7,10,12,0,0,0,3,0, 31,15,10,0,10,0,0,0,3,2,0, 31,3,10,0,8,0,0,0,0,1,0, 31,15,9,0,10,10,0,0,0,0,0);
        _setOPM("rect.snare","Snare Drum",4,7,31,2,0,0,5,0,0,15,3,0,0, 31,17,22,10,8,8,0,0,7,0,0,31, 30,0,0,15,3,0,4,0,0,0, 31,14,16,10,1,0,0,2,0,0,0);
        _setOPM("rect.hc","Hihat Close", 0,7, 31,8,10,10,1,38,2,15,0,3,0, 31,8,10,14,1,38,0,11,0,1,0, 31,5,10,14,1,8,1,9,7,1,0, 31,20,10,10,10,5,1,9,3,2,0);
        _setOPM("rect.ho","Hihat Open", 4,7, 20,6,14,7,10,9,0,15,0,7,0, 28,14,14,10,10,10,1,3,3,3,0, 31,12,6,3,3,10,0,15,7,5,0, 24,22,20,7,10,10,0,3,3,1,0);
    }
    
    private function _setOPM(key:String, name:String, ...args) : void
    {
        var voice:SiONVoice = new SiONVoice();
        voice.paramOPM = args;
        voice.name = name;
        this[key] = voice;
    }
}

 import flash.display.*;
 import flash.events.*;
 import flash.geom.*;
 import org.si.sion.sequencer.SiMMLTrack;

 class MatrixPad extends Bitmap {
    public var tracks:Vector.<SiMMLTrack> = new Vector.<SiMMLTrack>(16);
    public var effsends:Vector.<Number> = new Vector.<Number>(16);
    public var voices:Vector.<int> = new Vector.<int>(16);
    public var notes:Vector.<int>  = new Vector.<int>(16);
    public var sequences:Vector.<int> = new Vector.<int>(16);
    private var seqpattern:Vector.<int> = new Vector.<int>(16);
    
    private var canvas:Shape = new Shape();
    private var buffer:BitmapData = new BitmapData(320, 320, true, 0);
    private var padOn:BitmapData;
    private var padOff:BitmapData;
    private var pt:Point = new Point();
    private var colt:ColorTransform = new ColorTransform(1,1,1,0.1);
     
    function MatrixPad(padcolor:Object, seq:Vector.<int>) {
        super(new BitmapData(320, 320, false, 0));
        seqpattern = seq;
        padOn = _pad(padcolor.on);
        padOff = _pad(padcolor.off);
        
        var i:int;
        for (i=0; i<16; i++) sequences[i] = (seqpattern != null)? seqpattern[i] : 0;
        for (i=0; i<256; i++) {
            pt.x = (i&15)*20;
            pt.y = (240 - (i&240))*1.25;
            if (sequences[i>>4] & (1<<(i&15)) ) buffer.copyPixels(padOn, padOn.rect, pt);
            else buffer.copyPixels(padOff, padOff.rect, pt);
            bitmapData.copyPixels(padOff, padOff.rect, pt);
        }
        addEventListener("enterFrame", _onEnterFrame);
     }
     
     private function _pad(face:int) : BitmapData {
        var pix:BitmapData = new BitmapData(20, 20, false, 0);
        canvas.graphics.clear();
        canvas.graphics.beginFill(face);
        canvas.graphics.drawRect(0, 0, 17, 17);
        canvas.graphics.endFill();
        pix.draw(canvas);
        return pix;
     }
     
     private function _onEnterFrame(e:Event) : void {
        bitmapData.draw(buffer, null, colt);
     }
     
     public function _onClick(p:Point) : void {
        var track:int = 15-int(p.y*0.05), beat:int = int(p.x*0.05);
        sequences[track] ^= 1<<beat;
        pt.x = beat*20;
        pt.y = (15-track)*20;
        if (sequences[track] & (1<<beat)) buffer.copyPixels(padOn, padOn.rect, pt);
        else buffer.copyPixels(padOff, padOff.rect, pt);
     }
     
     public function beat(beat16th:int) : void {
         for (pt.x=beat16th*20, pt.y=0; pt.y<320; pt.y+=20) bitmapData.copyPixels(padOn, padOn.rect, pt);
     }
 }

