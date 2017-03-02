// http://linktale.net/

//reference & document
//http://www.libspark.org/wiki/nutsu/Frocessing
//http://www.libspark.org/htdocs/as3/frocessing/
//http://processing.org/reference/


package {
    import flash.events.Event;
    import frocessing.display.F5MovieClip2D;
    import frocessing.display.F5MovieClip2DBmp;
    import com.flashdynamix.utils.SWFProfiler;
        
    [SWF(backgroundColor = "0xffffff", frameRate = "50")] 
    
    public class Frocessing extends F5MovieClip2DBmp {
        
        private var _w:Number = 0;
        private var _h:Number = 0;
        public function Frocessing():void {
            //WFProfiler.init(stage, this);
            //Wonderfl.capture_delay(10);
            Wonderfl.disable_capture();
            size(stage.stageWidth, stage.stageHeight);
        }
        
        public function setup():void {
            background( 0xffffff );
            setPoint(int(stage.stageWidth / 30), int(stage.stageHeight / 30));
            stage.addEventListener(Event.RESIZE,resize);
        }
        
        private function resize(e:Event):void {
            size(stage.stageWidth, stage.stageHeight);
            setup();
        }
        
        private var _radius:Number = 1.0;
        private var _point_array:Array = new Array();
        private function setPoint(seg_w:Number = 8, seg_h:Number = 6):void {
            var w:Number = stage.stageWidth;
            var h:Number = stage.stageHeight;
            w = (w- _radius*2) / seg_w ;
            h = (h - _radius*2) / seg_h;
            
            for (var i:uint=0; i <= seg_h; i++ ) {
                for (var j:uint = 0; j <= seg_w; j++ ) {
                    _point_array.push(new ekPoint( j*w+_radius, i*h+_radius ));
                }
            }
        }
        
        public function draw():void {
            drawPoint();
        }
        
        private var _click_flg:Boolean = false;
        private var _cnt:uint = 0;
        private function drawPoint():void {
            clearPaint();
            
            //値の範囲を, 色相(0～n), 彩度(0～1), 明度(0～1)に指定
            //colorMode( HSV, 1, 1, 1 );
            var n:int = 100;
            colorMode( RGB, n, n*2, n*4 );
            stroke(n, n*2, n*4);
            var c:Number = color( _cnt, _cnt, _cnt );
            fill(c);
            
            var bz_point:Array = new Array();
            for each(var p:ekPoint in _point_array) {
                var theta:Number = Math.atan2(p.y - mouseY, p.x - mouseX);
                var dist:Number = 700 / Math.sqrt( ( mouseX - p.x )*( mouseX - p.x ) + ( mouseY - p.y )*( mouseY - p.y ) );

                p.x += Math.cos(theta) * dist + (p.px - p.x) * 0.05;
                p.y += Math.sin(theta) * dist + (p.py - p.y) * 0.05;
                
                var  _radius_ratio:Number = dist / 1;
                ellipse(p.x, p.y, _radius * 2 + _radius_ratio, _radius * 2 + _radius_ratio);
            }
            _cnt++;
        }
        
        private var _ctn_clear:uint = 0;
        private function clearPaint():void {
            if(_click_flg && _ctn_clear<6){
                colorMode( RGB, 1, 1, 1 );
                fill(1, 1, 1, 0.2);
                rect(0, 0, stage.stageWidth, stage.stageHeight);
            }else {
                _click_flg = false;
                _ctn_clear = 0;;
            }
            _ctn_clear++;
        }
        
        public function mousePressed():void {
            _click_flg = true;
        }
    }
}

class ekPoint {
    public var px:Number;
    public var py:Number;
    public var x:Number;
    public var y:Number;
    public function ekPoint(p_x:Number, p_y:Number):void {
        x = px = p_x;
        y = py = p_y;
    }
}