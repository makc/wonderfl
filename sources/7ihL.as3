//Tweenで画像変形をして、画像をぼよんぼよんさせる。

//ぼよよんビューア
//http://wonderfl.net/c/8ngA

//参考
//drawTriangles for Flash Player 9
//http://wonderfl.net/c/vBEV


package {
    import flash.geom.Matrix;
    import flash.system.LoaderContext;
    import flash.net.URLRequest;
    import flash.events.Event;
    import flash.display.*;
    import caurina.transitions.Tweener;
    import net.hires.debug.Stats;
    
    
    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
    public class Reader extends Sprite {
        private var url:String = "http://farm3.static.flickr.com/2012/2123413733_2180bc2160_o.jpg";
        private var w:uint = 465;
        private var h:uint = 465;
        private var loader:Loader = new Loader;
        private var image:BoyoyonMap;
        public function Reader() {
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
            loader.load(new URLRequest(url),new LoaderContext(true));
        }
        private function onImageLoaded(e:Event):void {
            loader.removeEventListener(Event.COMPLETE, onImageLoaded);
            image = new BoyoyonMap(w,h,loader);
            addChild(image);
            addChild(new Stats())
            for(var i:int=0;i<image.cutW+1;i++){
                for(var j:int=0;j<image.cutH+1;j++){
                    image.points[i][j].x -= w;
                }
            }
            move();
            stage.addEventListener("mouseDown",onDown);
            stage.addEventListener("mouseUp",onUp);
        }
        private function move(x:int=0,y:int=0):void{
            var mw:int = w/image.cutW; 
            var mh:int = h/image.cutH; 
            for(var i:int=0;i<image.cutW+1;i++){
                for(var j:int=0;j<image.cutH+1;j++){
                    var t:TweenPoint = image.points[i][j];
                    Tweener.addTween(t,{delay:t.delay, time:t.time, x:mw*+i+x, y:mh*j+y,transition:"easeOutElastic"});
                }
            }
        }
        private function onDown(e:Event=null):void{
            var mx:int = mouseX; 
            var my:int = mouseY; 
            for(var i:int=0;i<image.cutW+1;i++){
                for(var j:int=0;j<image.cutH+1;j++){
                    var t:TweenPoint = image.points[i][j];
                    Tweener.addTween(t,{delay:t.delay, time:t.time, x:(mx+t.x)>>1, y:(my+t.y)>>1,transition:"easeOutElastic"});
                }
            }
        }
        private function onUp(e:Event=null):void{
            move();
        }
    }
    
}
//import flash.geom.Point;
import flash.filters.BlurFilter;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.display.*;
class BoyoyonMap extends Shape{
    public var cutW:int = 20,cutH:int = 20;
    public var center:Point;
    public var dPoints:Vector.<Vector.<Point>> = new Vector.<Vector.<Point>>();
    public var points:Vector.<Vector.<TweenPoint>> = new Vector.<Vector.<TweenPoint>>();
    public var imageMap:BitmapData;
    private var softData:BitmapData;
    function BoyoyonMap(w:int,h:int,spr:DisplayObject=null):void{
        imageMap = new BitmapData(w,h,true,0);
        softData = new BitmapData(w,h);
        if(spr != null){ 
            var r:Rectangle = spr.getRect(spr);       
            var rate:Number = 1;
            var tw:int = r.width*rate;
            var th:int = r.height*rate;
            if(tw > w){
                rate *= (w / tw);
                th = r.height * rate;
                tw = r.width * rate;
            }
            if(th> h){
                rate *= (h / th);
                th = r.height * rate;
                tw = r.width * rate;
            }
            imageMap.draw(spr, new Matrix(rate,0,0,rate, (w-tw)/2 , (h-th)/2 ));
            softData.applyFilter(imageMap,imageMap.rect,new flash.geom.Point(),new BlurFilter(cutW*7,cutH*7,2));
        }
        var mw:int = w/cutW; 
        var mh:int = h/cutH;
        var center:Point = new Point(w/2,h/2);
        for(var i:int=0;i<cutW+1;i++){
            points[i] = new Vector.<TweenPoint>;
            dPoints[i] = new Vector.<Point>;
            for(var j:int=0;j<cutH+1;j++){ 
                dPoints[i][j] = new Point( i*mw, j*mh );
                /*
                var dx:int = center.x-dPoints[i][j].x;
                var dy:int = center.y-dPoints[i][j].y;
                var d:int = dx*dx+dy*dy;
                points[i][j] = new TweenPoint( i*mw, j*mh, (1-d/(w*h))*1, (d/(w*h))>>1 );
                */
                var sof:Number = 1.2*(1-softData.getPixel(i*mw, j*mh)/0x1000000); 
                points[i][j] = new TweenPoint( i*mw, j*mh, sof, 0 );
            }
        }
        
        this.addEventListener( "enterFrame", onFrame );
    }
    
    private function onFrame(e:Event=null):void{
        graphics.clear();
        for(var i:int=0;i<cutW;i++){
            for(var j:int=0;j<cutH;j++){
                GraphicUtil.drawTriangle(graphics,imageMap,points[i][j],points[i][j+1],points[i+1][j],dPoints[i][j],dPoints[i][j+1],dPoints[i+1][j] )
                GraphicUtil.drawTriangle(graphics,imageMap,points[i+1][j+1],points[i][j+1],points[i+1][j],dPoints[i+1][j+1],dPoints[i][j+1],dPoints[i+1][j] )           
            }
        }
    }
}

class Point{
    public var x:int = 1;
    public var y:int = 1;
    function Point(x:int,y:int){
        this.x=x; this.y=y;
    }
}
class TweenPoint extends Point{
    public var delay:Number = 1;
    public var time:Number = 1;
    function TweenPoint(x:int,y:int,time:Number=1,delay:Number=0){
        super(x,y);
        this.delay = delay;
        this.time = time;
    }
}

class GraphicUtil {    
    public static function drawTriangle(
        g:Graphics, bitmapData:BitmapData, 
        a0:Point, a1:Point, a2:Point,
        p0:Point, p1:Point, p2:Point):void{
            
        var matrix:Matrix = _buildTransformMatrix(p0, p1, p2, a0, a1, a2);
        g.beginBitmapFill(bitmapData, matrix, false, true);
        _drawTriangle(g, a0, a1, a2, matrix);
        g.endFill();
    }
    private static function _buildTransformMatrix(
        a0:Point, a1:Point, a2:Point,
        b0:Point, b1:Point, b2:Point):Matrix {
        var matrixA:Matrix = new Matrix(
            a1.x - a0.x, a1.y - a0.y,
            a2.x - a0.x, a2.y - a0.y);
        matrixA.invert();
        var matrixB:Matrix = new Matrix(
            b1.x - b0.x, b1.y - b0.y,
            b2.x - b0.x, b2.y - b0.y);
        var matrix:Matrix = new Matrix();
        matrix.translate(-a0.x, -a0.y); // (原点)へ移動 
        matrix.concat(matrixA); // 単位行列に変換(aの座標系の逆行列)
        matrix.concat(matrixB); // bの座標系に変換 
        matrix.translate(b0.x, b0.y); // b0へ移動 
        return matrix;
    }
    private static function _drawTriangle(g:Graphics, p0:Point, p1:Point, p2:Point, matrix:Matrix):void {
        //g.lineStyle(1, 0x808080); // debug
        g.moveTo(p0.x, p0.y);
        g.lineTo(p1.x, p1.y);
        g.lineTo(p2.x, p2.y);
        g.lineTo(p0.x, p0.y);
    }
}