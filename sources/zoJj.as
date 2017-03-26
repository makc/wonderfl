// forked from aont's Double Pendulum
package {
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    public class DoublePendulum extends Sprite
    {
        private var line_1:Sprite;
        private var line_2:Sprite;
        private var line_ratio:Number;
        private var length_1:Number = 0.5;
        private var length_2:Number = 0.25;
        
        private var mass_1:Number = 0.05;
        private var mass_2:Number = 0.01;
        
        private var color_1:Number = 0xff0000;
        private var color_2:Number = 0x0000ff;
        
        private var theta:Number = 0;
        private var phi:Number = 0;
        
        private var d_theta:Number = 0;
        private var d_phi:Number = 0;
        
        private var center:Number;
        private var center_y:Number;
        
        private var dt:Number = 1.0/60;
        private var g:Number = 9.8;
        
        private var myTimer:Timer;
        
        private var gamma1:Number = 0;
        private var gamma2:Number = 0;
        public function DoublePendulum()
        {
            this.parent.addEventListener(MouseEvent.CLICK, MouseClick);
                        
            this.center = 230;
            this.line_ratio = center /  (this.length_1+this.length_2);

            line_1 = CreateLine(this.length_1*line_ratio,color_1)
            line_2 = CreateLine(this.length_2*line_ratio,color_2);
            this.line_1.x = center;
            this.line_1.y = center;
            this.ReDraw();
            
            this.myTimer = new Timer(this.dt * 1000,0);
            this.myTimer.addEventListener(TimerEvent.TIMER,Tick);
            this.myTimer.start();
        }
        private function MouseClick(event:MouseEvent):void
        {
            theta = Math.atan2(center-event.localY,event.localX-center) + Math.PI /2;
            d_theta = 0;
            //d_phi = 0;
            this.ReDraw();
        }
        private function ReDraw():void
        {
            this.line_1.rotation = 90 - this.theta * 180 / Math.PI;

            
            this.line_2.rotation = 90 - this.phi * 180 / Math.PI;            
            this.line_2.x = center + this.length_1*line_ratio * Math.sin(this.theta) ;
            this.line_2.y = center + this.length_1*line_ratio * Math.cos(this.theta) ;
        }
        private function CreateLine(length:Number,color:uint):Sprite
        {
            var line:Sprite = new Sprite();
            with(line.graphics)
            {
                lineStyle(1, color);
                moveTo(0,0);
                lineTo(length,0);                
            }
            this.addChild(line);
            return line;
        }
        private function Advance():void
        {
            //var theta_new:Number
            //var phi_new:Number;
            d_theta += dt*
                (
                    -(mass_1+mass_2)*g*Math.sin(theta)/length_1
                    +mass_2*g*Math.cos(theta-phi)*Math.sin(phi)/length_1
                    -mass_2*Math.pow(d_theta,2)*Math.sin(2*(theta-phi))/2
                    -mass_2*Math.sin(theta-phi)*Math.pow(d_phi,2)*length_2/length_1
                ) / (mass_1 + mass_2 * Math.pow(Math.sin(theta-phi),2))
                -gamma1 * d_theta
                ;
            d_phi += dt*
                (
                    (mass_1+mass_2)*g*Math.cos(theta)*Math.sin(theta-phi)/length_2
                    +(mass_1+mass_2)*Math.sin(theta-phi)*Math.pow(d_theta,2)*length_1/length_2
                    +mass_2*Math.pow(d_phi,2)*Math.sin(2*(theta-phi))/2
                ) / (mass_1 + mass_2 * Math.pow(Math.sin(theta-phi),2))
                -gamma2 * d_phi
                ;
            
            
            theta = ModRadian(theta + d_theta * dt);
            phi = ModRadian(phi + d_phi * dt);            
        }
        
        private function ModRadian(rad:Number):Number
        {
            while(rad > Math.PI)
            {
                rad -= 2*Math.PI;
            }
            while(rad <= -Math.PI)
            {
                rad += 2*Math.PI;
            }
            return rad;
        }

        
        private function Tick(event:TimerEvent):void
        {            
            this.Advance();
            this.ReDraw();
        }
    }
}
