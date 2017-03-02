// write as3 code here..
package{

    import frocessing.display.F5MovieClip3D;
    
    [SWF(frameRate="60", backgroundColor="#000000")] 
    public class CurveTest extends F5MovieClip3D
    {
        
        private var num:int = 100;
        private var a:Number = 0;
        private var ss:Number = 100;
        private var vsa:Number = 0;
        
        public function CurveTest()
        {
            super();
            colorMode( RGB, num*2 );
            noFill();
            perspective(PI/2);
        }
        
        public function draw():void
        {
            translate( fg.width/2, fg.height/2, -100 + mouseY );
            rotateY(a);
            rotateX(a/3);
            
            vsa+=(mouseX*0.1*PI - vsa)*0.05;
            
            beginShape();
            for( var i:int=0;i<num;i++)
            {
                stroke( i + num );
                var vy:Number = ss - ss*2*i/num;
                var vs:Number = cos(vsa*vy/ss);
                var vx:Number = ss*cos(i*0.8)*vs;
                var vz:Number = ss*sin(i*0.8)*vs;
                moveToLast();
                curveVertex3d( vx, vy, vz );
            }
            endShape();
            a += 0.01;
        }
    }
}