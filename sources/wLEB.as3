package
{
    import flash.display.Shape;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.BlurFilter;
    import flash.filters.GlowFilter;
    import flash.filters.GradientGlowFilter;
    import flash.geom.Point;
    
    [SWF(width="300", height="300", frameRate="30", backgroundColor="#000000", pageTitle="Sin")] 
    public class Sin_Demo2 extends Sprite
    {
        //graphics draw toos
        private var _sprite:Sprite;        
        //canvs
        private var _bitmapData:BitmapData;
        private var _bitmap:Bitmap;       
        //bitmapData Size
        private var _mapWidth:Number  = 300;
        private var _mapHeight:Number = 300;        
        //
        private var _x:Number=0;
        private var _y:Number=0;       
        //circle Radius
        private var _radius:Number = 1;
        //
        private var _count:int = 210;
        
        public function Sin_Demo2()
        {
            init();            
        }
        private function init():void
        {
            createMember();
            deployMember();            
           _sprite.addEventListener(Event.ENTER_FRAME , onFrame);            
        }
        private function createMember():void
        {
            _bitmapData = new BitmapData(_mapWidth,_mapHeight,true,0);
            _bitmap = new Bitmap(_bitmapData);
            _sprite = new Sprite();
       
        }
        private function deployMember():void
        {
            this.addChild(_bitmap);             
        }        
        public function drawOneInstance():void
        {
            _x+=5;
            _y = Math.sin(Math.random() )*600;        
            _sprite.graphics.beginFill( Math.round(Math.random()* 0xFFFFFF)); 
            _sprite.graphics.drawCircle(_x , _y , _radius);
            _sprite.graphics.endFill();    
            _bitmapData.draw(_sprite);    
            _bitmapData.draw(_sprite);    
            var c:uint =  Math.round(Math.random()* 0xFFFFFF);            
            _bitmapData.applyFilter(_bitmapData,_bitmapData.rect,new Point(),new GlowFilter(c,0.9,2,2,2,1,false,false));
           ty.HIGH));        
            
        }        
        
        private function onFrame(e:Event):void
        {                
            
            drawOneInstance();
            _count--;
            if(_count <= 0)
            {                
                _sprite.removeEventListener(Event.ENTER_FRAME , onFrame);                
            }
            
        }
    }
}