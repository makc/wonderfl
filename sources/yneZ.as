package {
    import flash.display.Graphics;
    import flash.display.Sprite;
    public class SunflowerSpiral extends Sprite {
        public function SunflowerSpiral() {
           
            
            renderSpiral( 300, 7, 4, 0);
            //renderSpiral( 120, 10, 5, 1);
        }
        
        
        private function renderSpiral( count:int, radius:int, padding:int, magicAngleIndex:uint = 0 ):void
        {
        
            var g:Graphics = graphics;
            g.lineStyle(0,0);
            
            var x:Number = 200;
            var y:Number = 200;
            
            var divergence:Number = [137.50776,99.50078,222.492][magicAngleIndex % 3] / 180 * Math.PI;
           
             for ( var i:int = 1; i <= count; i++ )
            {
                var r:Number = (radius + padding) * Math.sqrt( i ) - radius * 0.3;
                var a:Number = divergence * i;
                g.drawCircle( x + Math.cos( a ) * r, y + Math.sin( a ) * r, radius);
             }
            
            
        }

    }
}