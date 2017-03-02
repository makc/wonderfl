//see http://gihyo.jp/design/feature/01/frocessing/0001
package {
    import frocessing.display.*;
    
    [SWF(width="465", height="465", frameRate="60")]
    public class FrocessingSample extends F5MovieClip2DBmp
    {
        private var stage_width:Number  = 465;
        private var stage_height:Number = 465;
        private var n:int    = 5;
        private var t:Number = 0;
        
        public function FrocessingSample ()
        {
            super();
        }
        
        public function setup():void
        {
            size( stage_width, stage_height );
            background( 0 );
            noFill();
            stroke( 255, 0.1 );
        }
        
        public function draw():void
        {
            if( isMousePressed )
                background( 0 );
            
            translate( 0, stage_height/2 );
            
            beginShape();
            curveVertex( -100, 0 );
            for( var i:int=0; i<=n; i++ ) {
                var xx:Number = i * stage_width / n;
                var yy:Number = noise( i * 0.25, t ) * 300 - 150;
                curveVertex( xx, yy );
            }
            curveVertex( stage_width+100, 0 );
            endShape();
            
            t+=0.01;
        }
    }
}