// forked from summerTree's Hot sun
package 
{
    //author 夏天的树人
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.filters.*;
    import flash.geom.*;
    [SWF(backgroundColor="#000000")]
    public class Main extends Sprite
    {
        private var pen:Shape=new Shape();
        public function Main()
        {
            addChild(pen);
            //创建滤镜组合
            pen.filters=[  
                         new BlurFilter() ,
                         new GlowFilter(),
                         ];
            init();
        }
        //利用黄色线和滤镜组合形状
        private function init():void
        {
            pen.graphics.lineStyle(1,0xFFFF00);
            pen.graphics.moveTo(250,200);
            var n:int=600//360;
            var a:Number = 0;
            while (n--)
            {
                var curve:Boolean, a2:Number;
                if (Math.random()<0.3) {
                    curve = true;
                    a2 = a + Math.random () -Math.random();
                } else {
                    curve = false;
                    a2 = Math.random()*2*Math.PI;
                }
                var point:Point=Point.polar(100 + 600*Math.random()*Math.random()*Math.random() , 0.5*(a + a2)); //随机生成线条
                var point2:Point=Point.polar(100 ,a2); //随机生成线条
                a = a2;
                if (curve)
                pen.graphics.curveTo(250+point.x,200+point.y,250+point2.x,200+point2.y);
                else
                pen.graphics.lineTo(250+point2.x,200+point2.y);
                
            }
        }
    }
}