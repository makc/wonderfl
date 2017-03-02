package {

    import flash.events.MouseEvent;
    import flash.display.Graphics;
    import flash.display.Sprite;
    
    public class Fractal extends Sprite {

        private var g:Graphics;
        private const dopi : Number = 6.283185307179586;
        private var si : Number;
        private var co : Number;
        private var cent : Vct;

        public function Fractal() {

            g=this.graphics;
            cent=new Vct(stage.stageWidth/2, stage.stageHeight/1.5);       
            var omega:Number=Math.PI/8;
            si=Math.sin(omega);
            co=Math.cos(omega);
            drawSemiCircle(60, 15, cent);
            stage.addEventListener(MouseEvent.CLICK, click);
            

        }


        private function click(event : MouseEvent) : void {

            g.clear();
            drawSemiCircle(60, 15, cent);

        }

        private function drawTree(a:Vct,b:Vct,mag:Number,si:Number,co:Number,cnt:int,th:Number):void{

            if(cnt<0) return;

            var ab:Vct=new Vct();
            ab.x=b.x-a.x;
            ab.y=b.y-a.y;
            var l:Number=Math.sqrt(ab.x*ab.x+ab.y*ab.y);
            var n:Vct=new Vct();
            var f:Number=((.9+Math.random()/7)*mag / l);
            n.x=ab.x*f;
            n.y=ab.y*f;
             var c:Vct=new Vct();
             var d:Vct=new Vct();
             var rand:Number=Math.random();
             c.x=(n.x*co+n.y*si);
             c.y=(-n.x*si+n.y*co);
             d.x=(2*n.x-c.x)*rand+b.x;
             d.y=(2*n.y-c.y)*rand+b.y;
             rand=Math.random();
             c.x=c.x*rand+b.x;
             c.y=c.y*rand+b.y;
             mag*=.8;
             dwc(a, b,0,th);
             dwc(b, c,0,th*.9);
             dwc(b, d, 0, th * .9);
             th*=.7;
             cnt--;
             drawTree(b, c, mag,si,co,cnt,th);
             drawTree(b, d, mag,si,co,cnt,th);
                                
        }

        

        private function dwc(a:Vct, b:Vct,c:uint = 0,th:Number=1):void {

            if (a == null || b == null) return;
            g.lineStyle(th,0,th);
            g.moveTo(a.x, a.y);
            g.cubicCurveTo((b.x - a.x) * Math.random() + a.x, (b.y - a.y) * Math.random() + a.y, 
            (b.x - a.x) * Math.random() + a.x, (b.y - a.y) * Math.random() + a.y, b.x, b.y);
            g.endFill();

            }

        private function drawSemiCircle(r:Number,n:int,cent:Vct):void{

            var w:Number=-Math.PI/n;
            var s:Number=Math.sin(w);
            var c:Number=Math.cos(w);
            drawCirc(c, s,c,s, n, cent,r);        

        }

        private function drawCirc(c:Number,s:Number,x:Number,y:Number,n:Number,cent:Vct,r:Number):void{

                if(n<2) return;
                var u:Vct=new Vct();
                u.x=x*r+cent.x;
                u.y=y*r+cent.y;
                var k:Number=cent.x-u.x;
                var l:Number=cent.y-u.y;
                drawTree(cent, u, Math.sqrt(k*k+l*l), si, co, 10, 3) ;   
                n--;
                drawCirc(c, s, c*x-s*y, s*x+c*y, n, cent,r)

        }
        
    }

}

class Vct{
    public var x:Number;
    public var y:Number;
    public function Vct(x:Number=0,
                        y:Number=0):void{
       
    this.x=x;
    this.y=y;
    }

}