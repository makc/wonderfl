package
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    
[SWF(width=465, height=465, frameRate=30, backgroundColor=0x000000)]
    public class smoke extends Sprite
    {
        private var _stg:Sprite;
        private var _list:Array = [];

        public function smoke()
        {
            _stg = new Sprite();
            addChild(_stg);
            this.graphics.beginFill(0);
            this.graphics.drawRect(0,0,465,465);
            this.graphics.endFill();
            _stg.filters = [new BlurFilter(20,20,2)];
            
            addEventListener(Event.ENTER_FRAME,loop);
        }
        
        private function loop(e:Event):void
        {
            for(var j:uint=0; j<20; j++)
            {
                var pc:Par = new Par(mouseX,mouseY);
                _stg.addChild(pc);
                _list.push(pc);
            }
            
            var len:int = _list.length-1;
            for (var i:int = len; i>-1; i--)
            {
                if (!_list[i].move())
                {
                    _stg.removeChild(_list[i]);
                    _list[i] = null;
                    _list.splice(i, 1);
                }
            }
        }
    }
}

    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.filters.BlurFilter;

    class Par extends Sprite
    {
        private var _p:Shape;
        private var _vx:Number;
        private var _vy:Number;
        private var _r:Number;
        private var _fric:Number = 0.95;
        
        private var _a:int = 0;
        
        public function Par(sx:Number,sy:Number)
        {
            _p = new Shape();
            addChild(_p);
            
            _p.x = sx;
            _p.y = sy;
            _p.graphics.beginFill(0xffffff);
            _p.graphics.drawCircle(0,0,5);
            _p.graphics.endFill();
            
            var rad:Number = Math.random() * 360 * Math.PI /180;
            _r = Math.random() * 5;
            _vx = Math.cos(rad) * _r;
            _vy = Math.sin(rad) * _r;
        }
        
        public function move():Boolean
        {
            _p.x += _vx;
            _p.y += _vy;
            _vx *= _fric;
            _vy *= _fric;
            
            _p.alpha = 0.8 - (_a/50);
            _a++;
            
            if(_a>40)
            {
                return false;
            }
                return true;
        }    
    }