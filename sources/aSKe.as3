package
{
    import flash.events.*;
    import flash.filters.*;
    
    import org.papervision3d.view.BasicView;
    import org.papervision3d.view.*;
    import org.papervision3d.objects.*;
    import org.papervision3d.core.geom.Lines3D;
    import org.papervision3d.core.geom.renderables.Line3D;
    import org.papervision3d.core.geom.renderables.Vertex3D;
    import org.papervision3d.materials.special.LineMaterial;
    import org.papervision3d.core.effects.*;
    import org.papervision3d.view.layer.BitmapEffectLayer;
    import org.papervision3d.core.effects.BitmapLayerEffect;
    
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.easing.*;
    import org.libspark.betweenas3.tweens.ITween;
    import org.libspark.betweenas3.events.TweenEvent;
    
    [SWF(width="465",height="465",backgroundColor="0x000000")]
    public class myLine3D extends BasicView
    {
        static public const OBJ_MAX:int = 300;
        private var lines3Ds:Vector.<DisplayObject3D>;
        private var _bfx:BitmapEffectLayer;
        
        function myLine3D():void
        {
            viewport.opaqueBackground = 0x0;
            var line:Line3D;
            var startV3d:Vertex3D;
            var endV3d:Vertex3D;
            
            //エフェクト
            _bfx = new BitmapEffectLayer(viewport, stage.stageWidth, stage.stageHeight);
            _bfx.addEffect(new BitmapLayerEffect(new BlurFilter(4, 4, 8)));
            viewport.containerSprite.addLayer(_bfx);
            
            lines3Ds =  new Vector.<DisplayObject3D>(OBJ_MAX, true);
            
            var posX:Number;
            var posY:Number;
            var posZ:Number;
            for(var i:uint = 1; i < OBJ_MAX; i++)
            {
                var lines3D:Lines3D;
                lines3D = new Lines3D();
                lines3Ds[i] = scene.addChild(lines3D);
                   _bfx.addDisplayObject3D(lines3Ds[i]);
                
                if(i % 2 == 0){
                    posX = Math.random() * 400;
                    posY = Math.random() * 500;
                    posZ = Math.random() * 500;
                    startV3d = new Vertex3D(posX, posY, posZ);
                    endV3d = new Vertex3D(posX + 100, posY, posZ);
                }else{
                    posX = Math.random() * 500;
                    posY = Math.random() * 400;
                    posZ = Math.random() * 500;
                    startV3d = new Vertex3D(posX, posY, posZ);
                    endV3d = new Vertex3D(posX, posY + 100, posZ);
                }
                lines3Ds[i].rotationY = 90 * Math.floor(Math.random() * 4);
                lines3Ds[i].rotationX = 90 * Math.floor(Math.random() * 4);
                
                var lm:LineMaterial = new LineMaterial(Math.random()*0xff <<16 | Math.random()*0xff << 8 | Math.random()*0xff);
                line = new Line3D(lines3D, lm, 2, startV3d, endV3d);
                lines3D.addLine(line);
                for each(var obj:* in lines3D.geometry.vertices){
                    obj.x -= 200;
                    obj.y -= 200;
                }
                var tw:ITween = setTween(lines3Ds[i]);
                tw.addEventListener(TweenEvent.COMPLETE, evCompTween);
                tw.play();
            }
            
            startRendering();
        }
        
        private function evCompTween(e:TweenEvent):void{
            var tw:ITween = setTween(e.target.target);
            tw.addEventListener(TweenEvent.COMPLETE, evCompTween);
            tw.play();
        }
        
        private function setTween(obj:DisplayObject3D):ITween{
            var delayX:Number = 3;
            switch(Math.floor(Math.random() * 4)){
                case 1:
                return BetweenAS3.tween(obj,{rotationX:obj.rotationX + 90},null,delayX,Quint.easeInOut);
                break;
                case 2:
                return BetweenAS3.tween(obj,{rotationX:obj.rotationX - 90},null,delayX,Quint.easeInOut);
                break;
                case 3:
                return BetweenAS3.tween(obj,{rotationY:obj.rotationY + 90},null,delayX,Quint.easeInOut);
                break;
                default:
                return BetweenAS3.tween(obj,{rotationY:obj.rotationY - 90},null,delayX,Quint.easeInOut);
                break;
            }
        }

        override protected function onRenderTick(event:Event=null):void
        {
            super.onRenderTick(event);  
        }
    }
}