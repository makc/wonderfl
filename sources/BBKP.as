package 
{
    import flash.system.LoaderContext;
    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.ColorTransform;
    import flash.net.URLRequest;
    
    [SWF(backgroundColor = 0xFFFFFF, frameRate = 60)]
    
    /**
     * ...
     * @author rettuce
     * 
     */
    public class Main extends MovieClip 
    {
        private var _conpane:Conpane;
                
        public function Main()
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init );
        }
        private function init(e:Event = null ):void
        {
            var imgA:Loader = addChild(new Loader()) as Loader;
            imgA.contentLoaderInfo.addEventListener( Event.COMPLETE,function(e:Event):void{
                imgA.content.width = imgA.content.height = 465;
            });
            imgA.load( new URLRequest("http://lab.rettuce.com/common/src/MonaLisa.jpg"), new LoaderContext(true));
            _conpane = addChild(new Conpane(stage)) as Conpane;
            _conpane.addEventListener( Conpane.PARAM_UPDATE, function(e:Event):void{ 
                imgA.filters = [ _conpane.cmf ];
            });
        }
    }
}

    import com.bit101.components.*;
    
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.ColorMatrixFilter;
    import flash.filters.DropShadowFilter;
    
    /**
     * ...
     * @author rettuce
     * 
     * var _conpane:Conpane = addChild(new Conpane(stage)) as Conpane;
     * _conpane.addEventListener( Conpane.PARAM_UPDATE, function(e:Event):void{ img.filters = [ _conpane.cmf ]; });
     * 
     * _conpane.cmf -> return ColorMatrixFilter
     * 
     */
    class Conpane extends Sprite
    {
        public static const PARAM_UPDATE:String = 'param_update';
        
        private var _slider:Vector.<HSlider> = new Vector.<HSlider>;
        private var _cmf:ColorMatrixFilter;
        private var _info:Text;
        private var _conpane:Sprite;
        private var _stage:Stage;        
        public function get cmf():ColorMatrixFilter{ return _cmf };
        
        public function Conpane($stage:Stage)
        {
            _stage = $stage;
            _conpane = addChild( new Sprite() ) as Sprite;
            _conpane.visible = false;
            
            var bg:Sprite = _conpane.addChild(new Sprite()) as Sprite;
            bg.graphics.beginFill( 0xEEEEEE );
            bg.graphics.drawRect(0,0,470,250);
            bg.filters = [new DropShadowFilter(0,0,0,0.7)]
            
            var b:PushButton = new PushButton( _conpane, 10, 10, "close", function(e:Event):void{
                _conpane.visible = false;
                b2.visible = true;
            });
            b.width = 35;
            b.height = 15;
            
            var b2:PushButton = new PushButton( this, 10, 10, "open", function(e:Event):void{
                _conpane.visible = true;
                b2.visible = false;
            });
            b2.width = 35;
            b2.height = 15;
            
            new Label(_conpane, 10, 30, "Red Result");
            new Label(_conpane, 10, 50, "Green Result");
            new Label(_conpane, 10, 70, "Blue Result");
            new Label(_conpane, 10, 90, "Alpha Result");
            new Label(_conpane, 90, 10, "src Red");
            new Label(_conpane, 165, 10, "src Green");            
            new Label(_conpane, 250, 10, "src Blue");
            new Label(_conpane, 325, 10, "src Alpha");
            new Label(_conpane, 410, 10, "ofset");
            _info = new Text(_conpane, 10, 120, "");
            _info.width  = 390;
            _info.height = 120;
            
            new PushButton(_conpane, 410, 120, "Normal", normal ).width = 50;
            new PushButton(_conpane, 410, 145, "Glay", gray ).width = 50;
            new PushButton(_conpane, 410, 170, "Revers", revers ).width = 50;
            new PushButton(_conpane, 410, 195, "Saturation", saturation ).width = 50;
            new PushButton(_conpane, 410, 220, "Contrast", contrast ).width = 50;
            

            
            for (var i:int = 0; i < 20; i++)
            {
                _slider[i] = new HSlider(_conpane, 70+80*(i%5) , 35+20*int(i/5), update);
                _slider[i].width = 70;
                _slider[i].tick = 0.01;
                _slider[i].maximum = 2;
                _slider[i].minimum = -2;                    
                
                if(i%6==0) _slider[i].value = 1;                
                if((i+1)%5==0){
                    _slider[i].maximum = 255;
                    _slider[i].minimum = -255;
                }else if(i==18){
                    _slider[i].maximum = 1;
                    _slider[i].minimum = -1;                    
                }
            }
            
            bg.addEventListener( MouseEvent.MOUSE_DOWN, drugstart );            
            _stage.addEventListener(MouseEvent.MOUSE_UP, drugstop);
        }
        private function drugstart(e:MouseEvent):void{ _conpane.startDrag() }
        private function drugstop(e:MouseEvent):void{ _conpane.stopDrag() }
        
        private function update(e:Event):void
        {
            var matrix:Array = [];
            _info.text = 'var matrix:Array = [';            
            for (var i:int = 0; i < _slider.length; i++) 
            {
                var num:Number = _slider[i].value;
                if(i%5==0) _info.text += '\n    ';
                if(i!=19) _info.text +=  num+ ', ';
                else _info.text += num+'\n];';
                matrix[i] = num;
            }
            _cmf = new ColorMatrixFilter(matrix);
            dispatchEvent( new Event(Conpane.PARAM_UPDATE) );
        }
        
        
        private function normal(e:Event):void
        {
            var matrix:Array = [
                1, 0, 0, 0, 0,
                0, 1, 0, 0, 0,
                0, 0, 1, 0, 0,
                0, 0, 0, 1, 0
            ];
            _info.text = 'var matrix:Array = [\n    1, 0, 0, 0, 0,\n    0, 1, 0, 0, 0,\n    0, 0, 1, 0, 0,\n    0, 0, 0, 1, 0\n];';
            _cmf = new ColorMatrixFilter(matrix);
            dispatchEvent( new Event(Conpane.PARAM_UPDATE) );
        }
        
        private function gray(e:Event):void
        {
            var matrix:Array = [
                1/3, 1/3, 1/3, 0, 0,
                1/3, 1/3, 1/3, 0, 0,
                1/3, 1/3, 1/3, 0, 0,
                0, 0, 0, 1, 0
            ];
            _info.text = 'var matrix:Array = [\n    1/3, 1/3, 1/3, 0, 0,\n    1/3, 1/3, 1/3, 0, 0,\n    1/3, 1/3, 1/3, 0, 0,\n    0, 0, 0, 1, 0\n];';
            _cmf = new ColorMatrixFilter(matrix);
            dispatchEvent( new Event(Conpane.PARAM_UPDATE) );
        }
        
        private function revers(e:Event):void
        {
            var matrix:Array = [
                -1, 0, 0, 0, 255,
                0, -1, 0, 0, 255,
                0, 0, -1, 0, 255,
                0, 0, 0, 1, 0
            ];
            _info.text = 'var matrix:Array = [\n    -1, 0, 0, 0, 255,\n    0, -1, 0, 0, 255,\n    0, 0, -1, 0, 255,\n    0, 0, 0, 1, 0\n];';
            _cmf = new ColorMatrixFilter(matrix);
            dispatchEvent( new Event(Conpane.PARAM_UPDATE) );
        }
        
        private function saturation(e:Event):void
        {
            var sat:Number = 3;
            var n:Number = sat * 2/3 + 1/3;
            var n2:Number = (1 - n) / 2;
            var matrix:Array = [
                n, n2, n2, 0, 0,
                n2, n, n2, 0, 0,
                n2, n2, n, 0, 0,
                0, 0, 0, 1, 0
            ];
            _info.text = 'var sat:Number = 3;  var n:Number = sat * 2/3 + 1/3;  var n2:Number = (1 - n) / 2;\nvar matrix:Array = [\n    n, n2, n2, 0, 0,\n    n2, n, n2, 0, 0,\n    n2, n2, n, 0, 0,\n    0, 0, 0, 1, 0\n];';
            _cmf = new ColorMatrixFilter(matrix);
            dispatchEvent( new Event(Conpane.PARAM_UPDATE) );
        }
        
        private function contrast(e:Event):void
        {
            var cont:Number = 1.2;
            var matrix:Array = [
                cont + 1, 0, 0, 0, -(128*cont),
                0, cont + 1, 0, 0, -(128*cont),
                0, 0, cont + 1, 0, -(128*cont),
                0, 0, 0, 1, 0
            ]; 
            _info.text = 'var cont:Number = 1.2;\nvar matrix:Array = [\n    cont + 1, 0, 0, 0, -(128*cont),\n    0, cont + 1, 0, 0, -(128*cont),\n    0, 0, cont + 1, 0, -(128*cont),\n    0, 0, 0, 1, 0\n];';
            _cmf = new ColorMatrixFilter(matrix);
            dispatchEvent( new Event(Conpane.PARAM_UPDATE) );
        }
        
    }