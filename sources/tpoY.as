/**
 * http://www.flickr.com/photos/40441900@N08/
 * Blenderでモデリング
 */
package {
    import flash.events.Event;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.render.BasicRenderEngine;
    //import org.papervision3d.objects.parsers.Collada;
    import org.papervision3d.objects.parsers.DAE;
    import org.papervision3d.core.render.filter.FogFilter;
    import org.papervision3d.materials.BitmapFileMaterial;
    import org.papervision3d.materials.special.FogMaterial;
    import net.hires.debug.Stats;
    
    public class FlashTest extends BasicView {
            private var rot:Number = 0;
        private var camY:Number = 0;
        private var camD:Number = 0;
        private var mountains:Array;
        
        public function FlashTest():void {
            addChild( new Stats() );
            
            var roku:DAE = new DAE();
            roku.load("http://buccchi.jp/wonderfl/201002/roku.dae");
            scene.addChild(roku);
            roku.scale = 100;
            roku.y = -200;
            
            mountains = new Array();
            for(var i:uint=0; i<10; i++){
                var mountain:DAE = new DAE();
                mountain.load("http://buccchi.jp/wonderfl/201002/mountain.dae");
                scene.addChild(mountain);
                mountain.x = i*2300;
                resetMountain(mountain);
                mountains.push(mountain);
            }
            
            // レンダリング
            var fg:FogMaterial = new FogMaterial(0xFFFFFF);
            renderer.filter = new FogFilter(fg, 50, 5000, 20000);
            startRendering();
            addEventListener(Event.ENTER_FRAME, loop);
        }
        
        private function loop(e:Event):void {
            //カメラを移動
            rot -= .5;
            camY += .01;
            camD += .007;
            var h:Number =  Math.sin(camD)*500+1500;
            camera.x = h * Math.sin(rot * Math.PI / 180);
            camera.z = h * Math.cos(rot * Math.PI / 180);
            camera.y = Math.cos(camY)*600 + 100;
            //山を移動
            for(var i:uint=0; i<mountains.length; i++){
                if(mountains[i].x > 12000){
                    mountains[i].x -= 24000;
                    resetMountain(mountains[i]);
                }else{
                    mountains[i].x += 60;
                }
            }
        }
        
        private function resetMountain(dae:DAE):void {
            dae.y = -Math.random()*400-1800;
            dae.z = (Math.random()<.5)? Math.random()*5000+1000 : Math.random()*-5000-1000;
            dae.scale = Math.random()*40+150;
            dae.scaleY = Math.random()*120+80;
            dae.rotationY = Math.random()*360;
        }
    }
}