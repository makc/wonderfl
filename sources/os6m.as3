/*
    Vectorvision3DがPV3Dに統合されたらしいと。
    ただ、Word3D → text3Dと、VectorShapeMaterial → Letter3DMaterial　となってる。
    ここ以外はたぶん同じ。
*/
package
{
    import caurina.transitions.Tweener;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.BlurFilter;
    import flash.utils.setInterval;
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.materials.special.Letter3DMaterial;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.render.BasicRenderEngine;
    import org.papervision3d.scenes.Scene3D;
    import org.papervision3d.typography.Text3D;
    import org.papervision3d.typography.fonts.HelveticaBold;
    import org.papervision3d.view.Viewport3D;
    import org.papervision3d.view.layer.ViewportLayer;
    
    [SWF(width="465", height="465", backgroundColor="0x000000", frameRate="40")]
    public class Main extends Sprite
    {
        private var viewport:Viewport3D;
        private var scene:Scene3D;
        private var camera:Camera3D;
        private var render:BasicRenderEngine;
        private var rootNode:DisplayObject3D;
        private var words1:Text3D;
        private var words2:Text3D;
        private var words3:Text3D;
        private var theta:Number;
        private var delayTime:Number;
        private var WordMoveType:Number;
        private static const distance:Number=600;
        
        public function Main()
        {
            theta=0;
            WordMoveType=0;
            delayTime=0;
            
            viewport=new Viewport3D(0, 0, true, true);
            scene=new Scene3D();
            camera=new Camera3D();
            render=new BasicRenderEngine();
            rootNode=scene.addChild(new DisplayObject3D("rootNode"));
            addChild(viewport);
            
            camera.target=DisplayObject3D.ZERO;
            camera.zoom=20;
            camera.focus=30;
            
            var mat:Letter3DMaterial=new Letter3DMaterial();
            mat.fillColor=0xFFFFFF;
            mat.doubleSided=true;
            mat.doubleSided=mat.interactive=true;
            words1=new Text3D("Sample of Papervision3D", new HelveticaBold(), mat);
            words2=new Text3D("Welcome to PV3D !!!!!!", new HelveticaBold(), mat);
            words3=new Text3D("YEAAAAAA!!!!HOOOOOOOOO!!!", new HelveticaBold(), mat);
            rootNode.addChild(words1);
            rootNode.addChild(words2);
            rootNode.addChild(words3);
            words1.y=50;
            words2.y=0;
            words3.y=-50;
            words1.scale=words2.scale=words3.scale=0.4;
            
            dispersionWords(words1);
            dispersionWords(words2);
            dispersionWords(words3);
            setInterval(moveWords, 10000);
            addEventListener(Event.ENTER_FRAME, onFrame);
        }
        
        private function dispersionWords(words:Text3D):void
        {
            for each(var word:DisplayObject3D in words.letters)
            {
                word.extra={x:word.x, y:word.y, z:word.z};
                word.x=word.y=word.z=word.scale=0;
                Tweener.addTween(word, {scale:1, x:Math.random() * 2000 - 1000, y:Math.random() * 2000 - 1000, z:Math.random() * 2000 - 1000, rotationX:Math.random() * 360, rotationY:Math.random() * 360, rotationZ:Math.random() * 360, time:3, delay:2 * Math.random() + 1});
            }
        }
        
        private function moveWords():void
        {
            if (WordMoveType % 2 == 0)
            {
                resetWords(words1);
                resetWords(words2);
                resetWords(words3);
                delayTime=0;
                WordMoveType++;
            }
            else
            {
                breakWords(words1);
                breakWords(words2);
                breakWords(words3);
                WordMoveType++;
            }
        }
        
        private function resetWords(words:Text3D):void
        {
            for each(var word:DisplayObject3D in words.letters)
            {
                Tweener.addTween(word, {x:word.extra.x, y:word.extra.y, z:word.extra.z, rotationX:0, rotationY:0, rotationZ:0, time:1, transition:"easeOutBounce", delay:delayTime});
                Tweener.addTween(word, {rotationY:720, time:1, delay:delayTime + 2});
                delayTime+=0.1;
            }
        }
        
        private function breakWords(words:Text3D):void
        {
            for each(var word:DisplayObject3D in words.letters)
            {
                Tweener.addTween(word, {x:Math.random() * 2000 - 1000, y:Math.random() * 2000 - 1000, z:Math.random() * 2000 - 1000, rotationX:Math.random() * 360, rotationY:Math.random() * 360, rotationZ:Math.random() * 360, time:4, delay:3 * Math.random()});
            }
        }
        
        private function onFrame(e:Event):void
        {
            camera.x=distance * Math.sin(theta * Math.PI / 180);
            camera.z=distance * Math.cos(theta * Math.PI / 180);
            theta+=0.2;
            
            setBlur(words1);
            setBlur(words2);
            setBlur(words3);
            render.renderScene(scene, camera, viewport);
        }
        
        private function DistanceFromCamera(obj:DisplayObject3D):Number
        {
            var vecX:Number=obj.sceneX - camera.x;
            var vecY:Number=obj.sceneY - camera.y;
            var vecZ:Number=obj.sceneZ - camera.z;
            return Math.sqrt((vecX * vecX) + (vecY * vecY) + (vecZ * vecZ));
        }
        
        private function setBlur(words:Text3D):void
        {
            for each(var word:DisplayObject3D in words.letters)
            {
                var vpl:ViewportLayer=word.createViewportLayer(viewport, true);
                var d:Number=Math.abs(DistanceFromCamera(word) - distance) / 40;
                vpl.filters=[new BlurFilter(d, d, 1)];
            }
        }
    }
}