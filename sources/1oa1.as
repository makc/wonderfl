package
{
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;

    public class Math2 extends Sprite
    {
        private var maxNum:uint = 500;
        private var angle:Number = 0;
        private var radian:Number = 0;
		
        public function Math2() 
        {
            init();           
        }  

        private function init():void
        {
            stage.frameRate=30;
            stage.scaleMode=StageScaleMode.NO_SCALE;
            stage.align=StageAlign.TOP_LEFT;
            stage.quality=StageQuality.LOW;

            var radius:Number = 100;
            var v:Number = 0;
	    var sw:Number = stage.stageWidth;
	    var sh:Number = stage.stageHeight;
			
	    for (var i:uint = 0; i < maxNum; i++)
	    {
		v += 5;
		radian = v * Math.PI / 180;
		setCircle((5* radian) * Math.cos(radian)+240, (5* radian) * Math.sin(radian)+240,Math.random()*5+5 );
	    }
        }

        private function setCircle(x:Number,y:Number,radius:Number):void
        {
            var _x:Number = x;
	    var _y:Number = y;
	    var _radius:Number = radius;
	    var s:Sprite = new Sprite();
	    addChild(s);
	    s.x=_x;
            s.y=_y;
            var sp:Sprite=new Sprite();
            sp.graphics.beginFill(Math.random()*0xFFFFFF);
            sp.graphics.drawCircle(0,0,_radius);
            s.addChild(sp);
            sp.alpha=Math.random();
            sp.blendMode=BlendMode.MULTIPLY;
            sp.addEventListener(Event.ENTER_FRAME,enterFrame);
	}
		
		
	private function enterFrame(e:Event):void
	{
	    e.target.x = Math.cos(angle) * 5;
	    e.target.y = Math.sin(angle) * 5;
	    angle += 5;
	}
    }
}






