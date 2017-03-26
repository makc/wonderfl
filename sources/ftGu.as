/*
Full Screenで見ると見やすいかと思います。
3D酔いには注意！
*/

package {
    import __AS3__.vec.Vector;
    
    import flash.events.Event;
    import flash.filters.*;
    
    import frocessing.color.ColorHSV;
    
    import org.papervision3d.cameras.*;
    import org.papervision3d.core.geom.Lines3D;
    import org.papervision3d.core.geom.renderables.Line3D;
    import org.papervision3d.materials.ColorMaterial;
    import org.papervision3d.materials.special.LineMaterial;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.view.BasicView;

    [SWF(width=465, height=465, backgroundColor=0x000000)]
    public class Papervision_Line3D_rainbow extends BasicView
    {
        
        //カメラが追う球
        private var sphere:Sphere;
        //描く線
        private var line:Lines3D;
        //ここを変更すると描かれる線が変わる
        private const A:Number = 10.0, B:Number = 25.0, C:Number = 8.0/3.0, D:Number = 0.01;
        //向かう座標
        private var xx:Number, yy:Number, zz:Number;
        //HSV->RGB変換用の変数
        private var hsv:ColorHSV;
        private var glow:GlowFilter;
        //Planeを格納するためのVector
        private var particles:Vector.<Plane>;

        public function Papervision_Line3D_rainbow()
        {
            super(465, 465, true, false, CameraType.SPRING);
            
            graphics.beginFill(0);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            
            //初期化
            hsv = new ColorHSV(0, 1, 1);
            glow = new GlowFilter(0, 1, 8, 8, 2);
            particles = new Vector.<Plane>();
            xx = yy = zz = 1;
            
            //球の生成
            sphere = new Sphere(new ColorMaterial(0xffffff), 3);
            sphere.x = sphere.y = sphere.z = 1;
            scene.addChild(sphere);
            //フィルターを有効にする
            sphere.useOwnContainer = true;
            sphere.filters = [new BlurFilter(8,8,4), glow];
            //カメラが追うものを球に設定
            camera.target = sphere;
            //各パラメータの設定
            SpringCamera3D(camera).mass = 20;
            SpringCamera3D(camera).damping = 30;
            SpringCamera3D(camera).stiffness = 8;
            
            line = new Lines3D(null);
            scene.addChild(line);
            startRendering();

            addEventListener(Event.ENTER_FRAME, onFrame);
        }

        private function onFrame(event:Event):void{
            //from
            var preX:Number = sphere.x;
            var preY:Number = sphere.y;
            var preZ:Number = sphere.z;
            //進む距離
            var dx:Number, dy:Number, dz:Number;
            dx = A*(yy-xx);
            dy = xx * (B - zz) - yy;
            dz = xx * yy - C * zz;
            //to
            xx += D*dx;
            yy += D*dy;
            zz += D*dz;
            
            sphere.x = xx*20;
            sphere.y = yy*20;
            sphere.z = zz*20;
            
            //線を描画
            line.addNewLine(2, preX, preY, preZ, sphere.x, sphere.y, sphere.z);
            
            //HSV->RGBの変換
            var color:uint = hsv.toRGB().value;
            //glowフィルターの色変更
            glow.color = color;
            //線の色を変更
            (line.lines[line.lines.length-1] as Line3D).material = new LineMaterial(color);
            
            //球から出るパーティクルの生成
            for(var j:int = 0; j < 3; j++){
                var mat:ColorMaterial = new ColorMaterial(color);
                mat.doubleSided = true;
                var p:Plane = new Plane(mat, 1, 1);
                p.x = sphere.x;
                p.y = sphere.y;
                p.z = sphere.z;
                p.useOwnContainer = true;
                p.filters = [new BlurFilter(4,4,2)];
                p.extra = {vx:Math.random()*6-3, vy:Math.random()*6-3, vz:Math.random()*6-3};
                scene.addChild(p);
                particles.push(p);
            }
            var i:int = particles.length;
            //パーティクルの管理
            while(i--){
                p = particles[i];
                p.x += p.extra.vx;
                p.y += p.extra.vy;
                p.z += p.extra.vz;
                p.material.fillAlpha -= 0.05;
                if(p.material.fillAlpha <= 0){
                    particles.splice(i,1);
                    scene.removeChild(p);
                }
            }
            
            i = line.lines.length;
            //線を徐々に透明にしていく
            while(i--){
                var l:Line3D = line.lines[i];
                l.material.lineAlpha -= 0.001;
                if(l.material.lineAlpha <= 0)
                    line.removeLine(l);
            }
            
            hsv.h += 1;
        }
    }
}
