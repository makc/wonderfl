// Tiny Pixel World
// @Hasufel 2013

package {
    import flash.display.*;
    import flash.events.Event;
    
    [SWF(width="465", height="465", frameRate="60")]
     
    public class WorldMap extends Sprite {
        private var _bmd:BitmapData = new BitmapData(465,465,true,0xFF000000);
        private var _bm:Bitmap;
        //to makc3d: held to this 'world' string _w for a long time :)
        private var _w:String = '001F8C0C400031F30E7FE000FF964FFFFF00FFB067FFFE001FF03FFFFA001FF07FFFFC003F806BFFF4001F8020FFF4001D007FFFF4000E80FFE7F0000600FFC6680001E07FC2180001F00FC0780001FC0F81730001FC0F80940000FC0F400F0020780F403F00007006001F00006000000640006000000080006000000000002000000000';
        private var _dots:Vector.<DataSprite>;
        private var _scale:int = 60;
        private var _xm:Number = -50;
        private var _ym:Number = 30;
        private var _earth:Sprite = new Sprite();
        public function WorldMap () {
            _bm = new Bitmap(_bmd);
            addChild(_bm);
            var k:int = 0;
            var o:String;
            var b:String = '';
            for (var i:int=0;i<_w.length;i+=2) {
                o=parseInt(_w.substring(i,i+2),16).toString(2);
                b+="00000000".substring(0,8-o.length)+o;
            }
            _dots = new Vector.<DataSprite>();
            for (i=0;i<22;i++) {
                for (var j:int=0;j<48;j++) {
                    if (b.charAt(k++) == '1') {
                        var dot:DataSprite = createDot(j,i,2,2);
                        _bmd.setPixel(j,i,0xFFFFFF);
                        _dots.push(dot);
                        _earth.addChild(dot);
                    }
                }
            }
            addChild(_earth);
            _earth.x=_earth.y=232;
            addEventListener(Event.ENTER_FRAME, onLoop);
        }
        
        private function onLoop(e:Event=null):void {
            _xm+=.5;
            if (_xm>128) _xm = -50;
            var l:int = _dots.length;
            var d:DataSprite;
            var dx:int,dy:int;
            var dist:int;
            var m:Number;
            for (var i:uint=0;i<l;i++) {
                d = _dots[i];
                dx = _xm-d.x0;
                dy = _ym-d.y0;
                dist = Math.sqrt(dx*dx+dy*dy)/2;
                m = Math.cos(Math.PI*(dist/_scale));
                d.x = Math.round(-_xm+d.x0-dx*m);
                d.y = Math.round(-_ym+d.y0-dy*m);
                d.width = d.height = m*4;
                d.alpha = m;
            }
        }
        
        private function createDot(x:int, y:int, size:int, dim:int):DataSprite {
            var s:DataSprite = new DataSprite();
            s.drawRect(x,y,10,10,0xFFFFFF);
            s.x0 = x*dim;
            s.y0 = y*dim;
            return s;         
        }
    }
}

import flash.display.*;

class DataSprite extends Sprite {
    public var x0:int;
    public var y0:int;
    
    public function drawRect(x:Number, y:Number, w:int, h:int, RGB:uint):void {
        var p:* = this.graphics;
        with (p) {
            p.lineStyle(0,RGB,1,0);
            p.moveTo(x,y);
            p.beginFill(RGB,1);
            p.lineTo(x+w,y);
            p.lineTo(x+w,y+h);
            p.lineTo(x,y+h);
            p.lineTo(x,y);
            p.endFill();
        }
    }
}