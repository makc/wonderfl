package { 
    
    import flash.display.GraphicsPathCommand;
    import flash.display.SpreadMethod;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Matrix3D;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Point;
    import flash.geom.Utils3D;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.ui.Keyboard;
    
    [SWF(backgroundColor="0xFFFFFF", width="465", height="465", frameRate="60")]
    public class Projection1 extends Sprite {
        
        private static var identityMatrix:Matrix3D = new Matrix3D();
        
        public function Projection1() {
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            
            var tf:TextField = new TextField();
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.text = 'マウスドラッグで空間に絵を描きます。\nshiftキーを押してると回転します。';
            addChild(tf);

                        Wonderfl.capture_delay( 60 );
            
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        
        public var uv:Vector.<Number> = new Vector.<Number>();
        public var verts:Vector.<Number>  = new Vector.<Number>();
        public var projectedVerts:Vector.<Number> = new Vector.<Number>();
        public var commands:Vector.<int> = new Vector.<int>();
        public var matrix:Matrix3D = new Matrix3D();
        public var isMouseDowm:Boolean = false;
        public var shiftkeyIsDown:Boolean = false;
        public var centerX:Number = stage.stageWidth / 2;
        public var centerY:Number = stage.stageHeight / 2;
        public var pmouseX:Number;
        public var pmouseY:Number;
        
        private function keyUpHandler(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.SHIFT) shiftkeyIsDown = false;
        }
        
        private function keyDownHandler(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.SHIFT) shiftkeyIsDown = true;
        }
        
        private function enterFrameHandler(e:Event):void {
            if (isMouseDowm) {                
                commands.push(GraphicsPathCommand.LINE_TO);
                verts.push(mouseX, mouseY, 0);
            }
            
            //1. 行列をリセット
            matrix.identity();
            //2. 回転の中心になる座標を原点に移動
            matrix.appendTranslation( -centerX, -centerY, 0);
            
            if (shiftkeyIsDown) { 
                //一フレーム前のマウス座標との差分を回転角度にする。
                var dx:Number = mouseY - pmouseY;
                var dy:Number = mouseX - pmouseX;
                matrix.appendRotation(-dx, Vector3D.X_AXIS);
                matrix.appendRotation(dy, Vector3D.Y_AXIS);
            }
            
            //3. 2で移動した分だけ元に戻す
            matrix.appendTranslation(centerX, centerY, 0);
            
            //4. 頂点データを回転させる。
            matrix.transformVectors(verts, verts);
            
            //5. ２次元に投影
            Utils3D.projectVectors(identityMatrix, verts, projectedVerts, uv);
            
            graphics.clear();
            graphics.lineStyle(1, 0x0);
            graphics.drawPath(commands, projectedVerts);
            
            pmouseX = mouseX;
            pmouseY = mouseY;
        }
        
        private function mouseDownHandler(e:MouseEvent):void {
            commands.push(GraphicsPathCommand.MOVE_TO);
            verts.push(mouseX, mouseY, 0);
            
            isMouseDowm = true;
        }
        
        private function mouseUpHandler(e:MouseEvent):void {
            isMouseDowm = false;
        }
    }
}