package {
    //******************************************************
    //PerlinParticles (10K)
    //PerlinNoise is generated with blue and red channels only.
    //Blue and red channels influence the x and y of particles. 
    //@by Hasufel 2010
    //*****************************************************/
        
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    [SWF(width=465, height=465, backgroundColor=0,frameRate=60)]

    public class PerlinParticles extends Sprite {
        private const _stageW:uint = stage.stageWidth;
        private const _stageH:uint = stage.stageHeight;
        private const _point:Point = new Point(0,0);
        private const _particlesNum:uint = 10000;
        private const _particlesCols:Array = [0xff00ff,0xcc00ff,0x0099cc,0xcc6666,0xcccccc,0xff55AA];
        private const _blurFilter:BlurFilter = new BlurFilter(16,16,4);
        private const _numOct:uint = 4;
        private const _perlinSize:uint = 32;
        private const _ratioX:Number = (_stageW/_perlinSize)/_stageW;
        private const _ratioY:Number = (_stageH/_perlinSize)/_stageH;
        private var _perlinData:BitmapData = new BitmapData(_perlinSize,_perlinSize,false,0x000000);
        private var _perlinBitmap:Bitmap = new Bitmap(_perlinData);
        private var _renderData:BitmapData = new BitmapData(_stageW,_stageH,false,0x000000);
        private var _renderRect:Rectangle = new Rectangle(0,0,_stageW,_stageH);
        private var _renderBitmap:Bitmap = new Bitmap(_renderData);
        private var _offsets:Array = new Array;
        private var _freq:Vector.<uint> = new Vector.<uint>(_numOct*2,true);
        private var _phase:Vector.<uint> = new Vector.<uint>(_numOct*2,true);        
        private var _particles:Vector.<Particle> = new Vector.<Particle>(_particlesNum,true);
    
        public function PerlinParticles(){
            addChild(_renderBitmap);
            for (var i:uint=0;i<_numOct;i++) {
                _offsets.push(new Point());
                _freq[i] = Math.round(5*Math.random()+1);
                _freq[i+1] = Math.round(6*Math.random()+1);
                _phase[i] = Math.round(2*Math.PI*Math.random());
                _phase[i+1] = Math.round(2*Math.PI*Math.random());
            }
            for (i=0;i<_particlesNum;i++){
                createParticle(randomNumber(0,stage.stageWidth),randomNumber(0,stage.stageHeight),0,0,_particlesCols[randomNumber(0,_particlesCols.length-1)],i);
            }
            _perlinData.perlinNoise(_perlinSize,_perlinSize,4,128,true,false,7,false,_offsets);
            _perlinBitmap.transform.colorTransform = new ColorTransform(1,0,1,1); //remove green channel
            addEventListener(Event.ENTER_FRAME, renderDisplay);
        }

        private function renderDisplay(e:Event):void {
            var t:Number = getTimer()*.0001;
            for (var i:uint=0;i<_numOct;i++) {
                _offsets[i].x = _perlinSize*Math.cos(_freq[i]*t+_phase[i]);
                _offsets[i].y = _perlinSize*Math.sin(_freq[i+1]*t+_phase[i+1]);
            }
            _perlinData.perlinNoise(_perlinSize,_perlinSize,_numOct,128,true,false,7,false,_offsets);
            var r:uint = _particlesNum;
            _renderData.applyFilter(_renderData,_renderRect,_point,_blurFilter);
            _renderData.lock();
            while(r--) {
                var v:Particle=_particles[r];
                if (v.y>_stageH || v.y<0 || v.x>_stageW || v.x<0){
                    v.x=randomNumber(0,_stageW);
                    v.y=randomNumber(0,_stageH);
                    v.vx=0;
                    v.vy=0;
                }    
                var c:uint = _perlinData.getPixel(v.x*_ratioX,v.y*_ratioY);
                var red:uint = Number(c>>16);
                var blue:uint = Number(c&0xFF);
                v.vx += 48-red;
                v.vy += 48-blue;
                v.x+= v.vx *.005;
                v.y+= v.vy *.005;
                _renderData.setPixel(v.x,v.y,v.c);
            }
            _renderData.unlock();        
        }

        private function createParticle(xx:uint,yy:uint,vx:Number,vy:Number,c:uint, i:uint):void {
            var p:Particle=new Particle();
            setProps(p, {x:xx,y:yy,vx:vx,vy:vy,c:c});
            _particles[i] = p;
        }

        private function setProps(o:*,p:Object):void {
            for (var k:String in p) {o[k]=p[k];}
        }
        private function randomNumber(low:int, high:int):int{
            return Math.round(Math.random() * (high - low) + low);
        }
    }
}

class Particle {
    public var x:uint;
    public var y:uint;
    public var vx:int;
    public var vy:int;
    public var c:uint;
}