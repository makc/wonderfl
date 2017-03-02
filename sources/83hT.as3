// forked from makc3d's forked from: forked from: Box2D test
// forked from shaktool's forked from: Box2D test
// forked from mash's Box2D test
// via http://gihyo.jp/dev/feature/01/box2d/0002
// slightly modified by mash
// * don't use CreateStatic..., nor CreateDynamic...
// click to start.
package  {
    import Box2D.Collision.b2AABB;
    import Box2D.Collision.Shapes.b2PolygonDef;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2DebugDraw;
    import Box2D.Dynamics.b2World;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    /**
     * 床の上に箱を落とすFlash
     */
    public class DropBox extends Sprite {
        private var world:b2World;
        private var _mouseIsDown:Boolean=false;
        public function DropBox():void {
            // イベントハンドラを登録する
            //stage.addEventListener(MouseEvent.CLICK, clickHandler);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, MouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, MouseUp);
            stage.addEventListener(Event.ENTER_FRAME, EnterFrame);
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            ////////////////////////////////////////
            // 物理エンジンのセットアップ
            
            // 外枠を定義する
            var worldAABB:b2AABB = new b2AABB();
            worldAABB.lowerBound.Set(-100, -100);
            worldAABB.upperBound.Set(100, 100);
            
            // 重力を下方向に10m/s^2とする
            var gravity:b2Vec2 = new b2Vec2(0, 10);
            
            // 外枠と重力を指定して、物理エンジン全体をセットアップする
            world = new b2World(worldAABB, gravity, true);
            
            ////////////////////////////////////////
            // 床の設置
            // 床は画面の下のほうに設置します
            
            // 床の位置を左から2.5m、上から3mとする
            var floorBodyDef:b2BodyDef = new b2BodyDef();
            floorBodyDef.position.Set(2.5, 3);
            
            // 床の形を、幅4m、厚さ20cmとする
            // 指定するのはその半分の値
            var floorShapeDef:b2PolygonDef = new b2PolygonDef();
            floorShapeDef.SetAsBox(2, 0.1);
            
            // 床を動かない物体として作る
            var floor:b2Body = world.CreateBody(floorBodyDef);
            floor.CreateShape(floorShapeDef);
            
            ////////////////////////////////////////
            // 描画設定
            
            var debugDraw:b2DebugDraw = new b2DebugDraw();
            debugDraw.m_sprite = this;
            debugDraw.m_drawScale = 100; // 1mを100ピクセルにする
            debugDraw.m_fillAlpha = 1; // 不透明度
            debugDraw.m_lineThickness = 1; // 線の太さ
            debugDraw.m_drawFlags = b2DebugDraw.e_shapeBit;
            world.SetDebugDraw(debugDraw);
        }
        private function MouseDown(me:MouseEvent):void{
            _mouseIsDown=true;
        }
        private function MouseUp(me:MouseEvent):void{
            _mouseIsDown=false;
        }
        private function EnterFrame(e:Event):void {
            if(_mouseIsDown){
               var boxBodyDef:b2BodyDef = new b2BodyDef();
                boxBodyDef.position.Set(mouseX / 100, mouseY / 100);
                var boxShapeDef:b2PolygonDef= new b2PolygonDef();
                boxShapeDef.SetAsOrientedBox(
                    0.1 * (1 + 2*Math.random ()),
                    0.1 * (1 + 2*Math.random ()), new b2Vec2(0, 0),
                    2 * Math.PI * Math.random ());
                boxShapeDef.density = 1;        // 密度 [kg/m^2]
                boxShapeDef.restitution = 0.4;  // 反発係数、通常は0～1
            
                var boxBody:b2Body = world.CreateBody(boxBodyDef);
                boxBody.CreateShape(boxShapeDef);
                boxBody.SetMassFromShapes(); 
            }
        }
        
        private function enterFrameHandler(event:Event):void {
            if (world == null) {
                return;
            }
            // Flashはデフォルトで秒間24フレームなので、
            // 物理シミュレーションを1/24秒進める
            world.Step(1 / 24, 10);
        }
    }
}