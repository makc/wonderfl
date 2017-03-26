/**
 * 3D の練習 大量のオブジェクトを動かすのに手抜きした結果がコレだよ。
 * もっと効率がいい方法があったらおしえてください。
 * @author bkzen
 */
package {
    import flash.display.GradientType;
    import flash.display.Sprite;
    import flash.display.Shape;
    import flash.events.Event;
    import flash.geom.Matrix;
    import com.flashdynamix.motion.TweensyGroup;
    import net.hires.debug.Stats;
    import fl.motion.easing.Cubic;
    import fl.motion.easing.Quartic;
    
    [SWF(width = "500", height = "500", frameRate = "30", backgroundColor = "0x000000")]
    public class FlashTest extends Sprite 
    {
        
        private var particles: Array = [];
        private var sp: Sprite;
        private var frame: Sprite;
        
        public function FlashTest() 
        {
            // write as3 code here..
            super();
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e: Event = null): void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // 
            addChild( new Stats() );
            // sp : particle を含む オブジェクト。
            sp = new Sprite();
            // frame : 背景とか
            frame = new Sprite();
            frame.addChild(sp);
            addChild(frame);
            frame.x = (stage.stageWidth) / 2;
            frame.y = (stage.stageHeight) / 2;
            
            // 背景を描く
            var m: Matrix = new Matrix();
            m.createGradientBox(300, 200, -30 * Math.PI / 180, -150, -100);
            frame.graphics.beginGradientFill(GradientType.LINEAR, [0x330000, 0xCC3333], [1.0, 1.0], [0x00, 0xFF], m);
            frame.graphics.drawRect(-150, -100, 300, 200);
            
            sp.z = 400;
            sp.rotationZ = -120;
            sp.rotationX = 30;
            sp.rotationY = -40;
            // particle を動かすための TweenｓｙGroup
            var pt: TweensyGroup = new TweensyGroup();
            
            for (var x: int = 0; x < 30; x ++)
            {
                for (var y: int = 0; y < 20; y ++)
                {
                    // particle を 生成
                    var sh: Shape = new Shape();
                    sh.graphics.beginFill(0xFFFFFF);
                    sh.graphics.drawRect(0, 0, 10, 10);
                    sh.x = x * 10 - (300+ (Math.random() * 20));
                    sh.y = y * 10 - 100;
                    sh.z = -500;
                    particles.push(sh);
                    sp.addChild(sh);
                    var func: Function;
                    var rand: Number = Math.random();
                    /*
                    // イージング の設定 (没)
                    if (rand < 0.3) 
                    {
                        func = Cubic.easeIn;
                    }
                    else 
                    {
                        func = Quartic.easeIn;
                    }
                    */
                    sh.alpha = 0;
                    // TweensyGroup に追加
                    pt.to(sh, {alpha: 1, z: 0, x: x * 10 - 150}, 3, func, x / 10 + Math.random());
                }
            }
            // 全体の動き (sp を動かす)
            var tween: TweensyGroup = new TweensyGroup();
            // sp の Tween を追加
            tween.to(sp, {z: -100, rotationZ: 0, rotationY: 0, rotationX: -50}, 10);
        }
    }
}
