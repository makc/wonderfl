package
{
    import flash.filters.GlowFilter;

    import org.papervision3d.cameras.CameraType;
    import org.papervision3d.core.geom.Particles;
    import org.papervision3d.core.geom.renderables.Particle;
    import org.papervision3d.materials.special.ParticleMaterial;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.view.BasicView;

    [SWF (width=465, height=465, backgroundColor=0x0, frameRate=20)]
    public class Galaxy extends BasicView
    {
        private var particles:Particles;

        public function Galaxy()
        {
            super(0,0,true,false,CameraType.TARGET);
            camera.z = -150;

            particles = new Particles();
            scene.addChild (particles);

            var stars:Array = [];
            generate (stars);
            generate (stars);

            for each (var obj:Object in stars) {
                var m:ParticleMaterial = new ParticleMaterial (obj.c, obj.a / 255.0,
                    ParticleMaterial.SHAPE_SQUARE);
                var p:Particle = new Particle (m, 3 * Math.random (), obj.x, obj.y, obj.z);
                particles.addParticle (p);
            }

            startRendering();
            addEventListener("enterFrame", onEnterFrame);

            filters = [ new GlowFilter (0x007fff, 0.5, 20, 20, 2) ];
        }

        private function onEnterFrame(e:*):void {
            particles.yaw (2); particles.pitch (1);
        }

        private function generate (stars:Array):void {
            // I wrote this code back in late '90s in TurboPascal
            // By now, I have no idea how it works, and what those magic numbers are :)

            var I:Number, J:Number, K:Number,
            s:Number, L:Number, d:Number, R:Number,
            dX:Number, dY:Number, dZ:Number,
            c2:Number;
            var Rm:Number = 20, A:Number = 0.3;

            var clr:Array = [0x0080FF, 0x8080E4, 0xB0B0FF];

            for (I = 0; I < 101; I++)
            {
                A = A + 0.03;
                R = A * Rm;
                for (J = 0; J < 5 - Math.floor(I / 20); J++)
                {
                    for (K = 0; K < 5; K++)
                    {
                        L = clr[(R > 3 * Rm * Math.random()) ? 0 : 1];
                        c2 = (R > 2 * Rm * Math.random()) ? 1 : 2;
                        if (A < 0.6) L = clr[2];
                        s = Math.max (2, Rm - R / 3);

                        dX = R * Math.cos(A + K * 2 * Math.PI / 5) +
                            0.2 * ((100 - I) * Math.random() + I / 2);
                        dY = R * Math.sin(A + K * 2 * Math.PI / 5) +
                            0.2 * ((100 - I) * Math.random() + I / 2);
                        dZ = s * (Math.random() - Math.random());

                        stars.push ({ x: dX, y: dY, z: dZ, c: L, a: (255 - 120 * c2) });
                    }
                }
            }
        }
    }
}