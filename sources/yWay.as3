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
            var n:int=360;
            while (n--)
            {
                //n++;
                //var point:Point=Point.polar( 200 ,Math.random()*360);
                var point:Point=Point.polar(200 ,Math.random()*2*Math.PI); //随机生成线条
                //pen.graphics.moveTo(250,200);
                pen.graphics.lineTo(250+point.x,200+point.y);
            }
        }
    }
}