package  {

    import flash.geom.Matrix;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.media.SoundChannel;
    import flash.net.URLRequest;
    import flash.media.Sound;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.display.Sprite;

    public class Rope extends Sprite {
        private var g:Number=0
        private var ropes : Vector.<RRope>;
        private var s : Sound;
        private var sch : SoundChannel;
        private var bmp : Bitmap;
        private var container : Sprite;
        private var w:uint,h:uint
        private var mtrx : Matrix;
        public function Rope() {

            w=stage.stageWidth,h=stage.stageHeight
            stage.frameRate=120
            s=new Sound()
            bmp=new Bitmap()
            bmp.bitmapData=new BitmapData(w, h)
            addChild(bmp)
            container=new Sprite()
            s.load(new URLRequest('http://axima.ir/music/hd.mp3'));
            sch=new SoundChannel()
            sch=s.play()
            ropes=new Vector.<RRope>()
            var max:int=80
            var p:Point=new Point(0,0)
            for (var j : int = 0; j < max; j++) {
                var r:RRope=new RRope()
                r.nodesNum=Math.random()*40+10
                r.lngx=(Math.random()>.5)?Math.random()*3:-Math.random()*3
        
                r.lngy=(Math.random()>.5)?Math.random()*3:-Math.random()*3

                for (var i : int = 0; i < r.nodesNum; i++) {
                    r.nodes.push(p.clone())
                }
                container.addChild(r)
                ropes.push(r)             
            }
            mtrx=new Matrix(.5,0,0,.5,250,230)
            this.addEventListener(Event.ENTER_FRAME, loop)

        }
        private function loop(event : Event) : void {
            g+=.1
            bmp.bitmapData.fillRect(bmp.bitmapData.rect, 0xffffff)
            bmp.bitmapData.draw(container)
            bmp.bitmapData.draw(container,mtrx)
            ropes.forEach(function (el:*):*{el.render(g,sch.leftPeak*50,sch.rightPeak*50)})

        }

    }

}

import flash.geom.Point;
import flash.display.Sprite;
class RRope extends Sprite{
public var nodes : Vector.<Point>;
public var nodesNum : Number = 40;
public var lngy:Number,lngx:Number
private var p:Point
public function RRope(){
nodes=new Vector.<Point>()
p=new Point();
}
public function render(g:Number,lp:Number,rp:Number):void{
    this.graphics.clear()
    p.x=200+Math.cos(g)*lp
    p.y=200+Math.sin(g)*rp
    this.graphics.moveTo(p.x ,p.y)
    this.graphics.lineTo(200, 500)
        for (var i : int =nodesNum-1; i>1 ; i--) {
            var n:Point=nodes[i]
                n.x+=(p.x-n.x)*.5+lngx
                n.y+=(p.y-n.y)*.5+lngy
                p.x=n.x
                p.y=n.y
                this.graphics.lineStyle(i/10,0)
                this.graphics.lineTo(n.x ,(n.y*n.y)/300)
                this.graphics.endFill()

}
}
}