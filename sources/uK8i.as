/*
   Spriteを球状に配置しただけです。
   Z-sortはclockmakerさんのものを利用させてもらってます（http://wonderfl.net/c/7fZn)
*/
package
{
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.Matrix3D;
    
    [SWF(width="465", height="465", backgroundColor="0xFFFFFF", frameRate="40")]
    public class Main extends Sprite
    {
        private static const PLANE_WIDTH:Number=70;
        private static const PLANE_HEIGHT:Number=70;
        private static const RADIUS:Number=150;
        
        private var container:Sprite;
        private var planes:Array;
        private var planeN:int;
        
        public function Main()
        {
            // ShapeをaddChildするコンテナ
            container=new Sprite();
            container.x=465 / 2;
            container.y=465 / 2;
            addChild(container);
            
            // 球面に並べる
            planeN=0;
            planes =[];
            var H:int=(2 * RADIUS * Math.PI) / 2 / PLANE_HEIGHT;
            var theta1:Number;
            var theta2:Number=90;
            for(var i:int=0; i < H; i++)
            {
                theta1=0;
                var pn:int=Math.floor((2 * RADIUS * Math.cos(theta2 * Math.PI / 180) * Math.PI) / PLANE_WIDTH);
                for(var j:int=0; j < pn; j++)
                {
                    var plane:Shape = container.addChild(new Shape) as Shape;
                    planes.push(plane);
                    
                    // 円をかく
                    var g:Graphics = plane.graphics;
                    g.beginFill(Math.random() * 0xffffff, 0.7);
                    g.drawEllipse(-PLANE_WIDTH / 2, -PLANE_HEIGHT / 2, PLANE_WIDTH, PLANE_HEIGHT);
                    g.endFill();
                    
                    // 座標計算
                    plane.rotationX=-theta2;
                    plane.rotationY=theta1;
                    plane.x=RADIUS * Math.cos(theta2 * Math.PI / 180) * Math.sin(theta1 * Math.PI / 180);
                    plane.y=RADIUS * Math.sin(theta2 * Math.PI / 180);
                    plane.z=RADIUS * Math.cos(theta2 * Math.PI / 180) * Math.cos(theta1 * Math.PI / 180);
                    theta1+=360 / pn;
                    planeN++;
                }
                theta2-=180 / H;
            }
            
            // イベントの追加
            addEventListener(Event.ENTER_FRAME, onFrame);
        }
        
        // フレームイベント
        private function onFrame(e:Event):void
        {
            container.rotationY++;
            var array:Array=[];
            
            // ソートの準備
            for(var i:int=0; i < planeN; i++)
            {
                var plane:Shape = planes[i];
                var mat:Matrix3D=plane.transform.getRelativeMatrix3D(this);
                array.push({sp:plane, z:mat.position.z});
            }
            
            // ソート
            array.sortOn("z", Array.NUMERIC | Array.DESCENDING);
            
            // ソートを適用
            for(i=0; i < planeN; i++)
            {
                plane = array[i].sp as Shape;
                container.setChildIndex(plane, i);
                
                var blur:Number=(array[i].z as Number) / 20;
                plane.filters=(blur > 4) ? [new BlurFilter(blur, blur, 1)] : [];
            }
        }
    }
}