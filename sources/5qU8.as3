package
{
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    /**
     * ...
     * @author narutohyper
     */
    
    
    [SWF(width = 465, height = 465, frameRate = 60,backgroundColor=0xFFFFFF)]
    public class Main extends Sprite {
        
        private var movers:Vector.<Mover> = new Vector.<Mover>(4)
        private var mover:Sprite = new Sprite();
        private var transformer:Transformer = new Transformer()
        
        private var bmd:BitmapData
        
        public function Main():void {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.HIGH;
            
            //サンプルテキスト
            var label:TextField=new TextField()
            label.autoSize=TextFieldAutoSize.LEFT
            var format:TextFormat=new TextFormat();
            format.color=0x0
            format.size=50;
            format.font = "_ゴシック";
            format.align = "center"
            label.defaultTextFormat=format
            label.text="HELLO\n WONDERFL\nWORLD"
            
            //BitmapData化
            bmd = new BitmapData(label.width, label.height, true, 0x0);
            bmd.draw(label,null,null,null,null,true)
            
            //controlPoint
            var i:int = 0;
            for (i = 0; i < 4; i++) {
                movers[i] = new Mover()
                movers[i].addEventListener(Mover.MOVE, onVertexMove);
                mover.addChild(movers[i]);
            }

            movers[1].x = bmd.width;
            movers[2].x = bmd.width;
            movers[2].y = bmd.height;
            movers[3].y = bmd.height;
            
            mover.x = (stage.stageWidth-bmd.width)/2;
            mover.y = (stage.stageWidth - bmd.height) / 2;
            transformer.x = mover.x
            transformer.y = mover.y
            
            //Transformer
            addChild(transformer);
            addChild(mover);
            draw();
            
        }
        
        private function onVertexMove(e:MouseEvent):void
        {
            e.target.x += e.target.mouseX
            e.target.y += e.target.mouseY
            draw(e.shiftKey)
            e.updateAfterEvent();
        }
        
        
        private function draw(shift:Boolean=false):void {
            transformer.draw(bmd,movers,shift)
        }
        
        
        
        
    }
    
}


import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;


class Transformer extends Sprite {

    public var polygons:Vector.<Polygon>
    public var vertices:Vector.<Vertex>
    public function Transformer() {
    }

        
    public function draw(base:BitmapData, mp:Vector.<Mover>,shift:Boolean=false):void {
        
        var gPoint:Point
        var uv:Array=[]
        
        uv[0] = new Point(0, 0);
        uv[1] = new Point(1, 0);
        uv[2] = new Point(1, 1);
        uv[3] = new Point(0, 1);

    
        vertices = new Vector.<Vertex>();
        polygons = new Vector.<Polygon>();
        
        //20×20の頂点を用意する
        var vCounter:uint = 0
        var pCounter:uint = 0
        var leftPt:Point
        var rightPt:Point
        var leftUv:Point
        var rightUv:Point
        var tempUv:Point
        var tempPt:Point
        var vy:int
        var vx:int
            

        for (vy = 0; vy < 21; vy++) {
            //左辺のPoint
            //右辺のPoint
            //左辺のUv
            //右辺のUv
            leftPt = Point.interpolate(new Point(mp[1].x, mp[1].y), new Point(mp[2].x, mp[2].y), (1 / 20 * vy));
            rightPt = Point.interpolate(new Point(mp[0].x, mp[0].y), new Point(mp[3].x, mp[3].y), (1 / 20 * vy));
            
            leftUv =Point.interpolate(uv[1],uv[2], (1/20*vy));
            rightUv=Point.interpolate(uv[0],uv[3], (1/20*vy));
            
            for (vx = 0; vx < 21; vx++) {
                tempUv=Point.interpolate(leftUv,rightUv, 1-(1/20*vx));
                tempPt=Point.interpolate(leftPt,rightPt, 1-(1/20*vx));
                vertices[vCounter] = new Vertex(tempPt.x, tempPt.y, tempUv.x, tempUv.y)
                if (vx < 20 && vy < 20) {
                    polygons[pCounter] = new Polygon(vCounter, vCounter+1, vCounter+22, vCounter+21)
                    pCounter++
                }
                vCounter++
            }
        }

        
        var points:Vector.<Number> = new Vector.<Number>()
        var indices:Vector.<int> =    new Vector.<int>()
        var uvtData:Vector.<Number> =  new Vector.<Number>
        var count:uint = vertices.length
        
        var i:uint;
        for (i = 0; i < count; i++) {
            points[i * 2] = vertices[i].x;
            points[i * 2 + 1] = vertices[i].y;
            uvtData[i * 2] = vertices[i].u;
            uvtData[i * 2 + 1] = vertices[i].v;
        }
        count = polygons.length
        for (i = 0; i < count; i++) {
            indices=indices.concat(polygons[i].indices)
        }

        graphics.clear();
        if (shift) {
            graphics.lineStyle(0,0x009900)
        }
        graphics.beginBitmapFill(base,null,false,true);
        graphics.drawTriangles(points,indices,uvtData)
        graphics.endFill();
    }


}



class Polygon {
    private var _indices:Vector.<uint>
    private var _id:uint
    public function Polygon(v0:uint,v1:uint,v2:uint,v3:uint) {
        _indices = new Vector.<uint>(4)
        _indices[0]=v0
        _indices[1]=v1
        _indices[2]=v2
        _indices[3]=v3
    }
    
    public function get id():uint {
        return _id;
    }
    
    public function set id(value:uint):void {
        _id = value;
    }
    
    public function get indices():Vector.<int> {
        var result:Vector.<int> = new Vector.<int>();
        result[0] = _indices[0];
        result[1] = _indices[1];
        result[2] = _indices[2];
        result[3] = _indices[0];
        result[4] = _indices[2];
        result[5] = _indices[3];
        
        return result;
    }
    
}



class Vertex    extends Point{
    private var _u:Number;
    private var _v:Number;
    private var _id:uint;
    private var _next:Vertex;
    public function Vertex(x:Number = 0, y:Number = 0, u:Number = 0, v:Number = 0) {
        super(x,y)
        _u = u;
        _v = v;
    }
    
    public function get u():Number { return _u; }
    
    public function set u(value:Number):void {
        _u = value;
    }
    
    public function get v():Number { return _v; }
    
    public function set v(value:Number):void {
        _v = value;
    }
    
}




class Mover extends Sprite {
    public static const MOVE:String = 'string';
    
    
    public function Mover() {
        graphics.lineStyle(0, 0xFFFFFF);
        graphics.beginFill(0x0000CC)
        graphics.drawRect( -5, -5, 10, 10)
        graphics.endFill();
        
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
    }
    
    
    private function mouseDown(e:MouseEvent):void {
        removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
    }
    
    
    private function mouseUp(e:MouseEvent):void {
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
    }
    
    
    private function mouseMove(e:MouseEvent):void {
        dispatchEvent(
            new MouseEvent(MOVE,
            e.bubbles,
            e.cancelable,
            e.localX,
            e.localY,
            e.relatedObject,
            e.ctrlKey,
            e.altKey,
            e.shiftKey,
            e.buttonDown,
            e.delta));
    }
        
    public function destroy():void {
        removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
    }
    
        
}




