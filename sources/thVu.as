// forked from nutsu's SketchSample6
package  {
    import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.geom.Point;
    import flash.geom.ColorTransform;
    
    [SWF(width=465,height=465,backgroundColor=0x000000,frameRate=60)]
    
    public class Main extends Sprite{
        
        private const WIDTH:Number  = 465;
        private const HEIGHT:Number = 465;
        
        private var _sketch:CurveSketch;
        private var _bmd:BitmapData;
        private var _bm:Bitmap;
        private var _container:Sprite = new Sprite();

        public function Main() {
            graphics.beginFill(0)
            graphics.drawRect(0, 0, WIDTH, HEIGHT)
            graphics.endFill()
            addChild(_container);
            //
            _sketch = new CurveSketch();
            _bmd = new BitmapData(WIDTH, HEIGHT, true, 0);
            _container.addChild(_sketch);
            _container.addChild(_bm = new Bitmap(_bmd) as Bitmap);
            _bm.blendMode = "add";
            //
            addEventListener(Event.ENTER_FRAME, update);
        }
        
        private function update(e:Event):void{
            _bmd.draw(_sketch, null, null, "add");
            _bmd.applyFilter(_bmd, _bmd.rect, new Point(), new BlurFilter(8, 8, 3));
        }
    }
}



//package {
    import frocessing.display.F5MovieClip2D;
    import frocessing.geom.FGradientMatrix;
    import frocessing.color.ColorHSV
    
    class CurveSketch extends F5MovieClip2D
    {
        
        //加速度運動の変数
        //位置
        private var xx:Number;
        private var yy:Number;
        //速度
        private var vx:Number;
        private var vy:Number;
        //加速度の係数
        private var ac:Number;
        //速度の減衰係数
        private var de:Number;
        
        //描画座標
        private var px0:Array;
        private var py0:Array;
        private var px1:Array;
        private var py1:Array;
        
        private var t:Number = 0
        
        //描画グループ
        private var shapes:Array;
        
        public function CurveSketch() 
        {
            
            //初期化
            vx = vy = 0.0;
            xx = mouseX;
            yy = mouseY;
            ac = 0.06;
            de = 0.9;
            px0 = [xx, xx, xx, xx];
            py0 = [yy, yy, yy, yy];
            px1 = [xx, xx, xx, xx];
            py1 = [yy, yy, yy, yy];
                        
            shapes = [];
            
            //線と塗りの色指定
            noStroke();            
        }
        
        public function draw():void
        {
            //加速度運動
            xx += vx += ( mouseX - xx ) * ac;
            yy += vy += ( mouseY - yy ) * ac;
            
            var len:Number = mag( vx, vy );
            
            //新しい描画座標
            var x0:Number = xx + 1 + len * 0.1;
            var y0:Number = yy - 1 - len * 0.1;
            var x1:Number = xx - 1 - len * 0.1;
            var y1:Number = yy + 1 + len * 0.1;
            
            //描画座標
            px0.shift(); px0.push( x0 );
            py0.shift(); py0.push( y0 );
            px1.shift(); px1.push( x1 );
            py1.shift(); py1.push( y1 );
            
            var _px0:Array = [px0[0], px0[1], px0[2], px0[3]];
            var _py0:Array = [py0[0], py0[1], py0[2], py0[3]];
            var _px1:Array = [px1[0], px1[1], px1[2], px1[3]];
            var _py1:Array = [py1[0], py1[1], py1[2], py1[3]];
            
            shapes.push( { px0:_px0, py0:_py0, px1:_px1, py1:_py1, mtx:null} );
            if (shapes.length >= 50) shapes.shift();
            
            var shapesLength:int = shapes.length;
            for (var i:int = shapesLength-1; i >= 0; i--) 
            {
                var sh:Object = shapes[i];
                
                var color:ColorHSV = new ColorHSV(t, 0.8, 1, 0.1)
                t += 0.05;
                
                beginFill(int(color), 0.2)
                beginShape();
                curveVertex( sh.px0[0], sh.py0[0] );
                curveVertex( sh.px0[1], sh.py0[1] );
                curveVertex( sh.px0[2], sh.py0[2] );
                curveVertex( sh.px0[3], sh.py0[3] );
                vertex( sh.px1[2], sh.py1[2] );
                curveVertex( sh.px1[3], sh.py1[3] );
                curveVertex( sh.px1[2], sh.py1[2] );
                curveVertex( sh.px1[1], sh.py1[1] );
                curveVertex( sh.px1[0], sh.py1[0] );
                endShape();
            }
            
            
            //減衰処理
            vx *= de;
            vy *= de;
        }

    }
//}