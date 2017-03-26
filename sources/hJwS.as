// forked from szbzs2004's swf.hu: 3D forgatás közben startDrag
package {
    import flash.display.Sprite;
    import flash.events.Event;
    
    public class StartDragProblem extends Sprite {
        
        private static const CELL_SIZE:Number = 50;
        private static const CELL_NUM:Number = 7;
        
        public function StartDragProblem() {
            var c:Sprite = makeChild();
            var p:Sprite = makeParent();
            p.x = stage.stageWidth / 2;
            p.y = stage.stageHeight / 2;
            p.addChild(c);
            addChild(p)
        }
        
        private function makeParent():Sprite {
            const X0:Number = -CELL_SIZE * CELL_NUM / 2;
            const Y0:Number = -CELL_SIZE * CELL_NUM / 2;
            var s:Sprite = new Sprite();
            s.graphics.lineStyle(2);
            for (var i:Number = 0; i <= CELL_NUM; ++i) {
                s.graphics.moveTo(X0 + 0,                    Y0 + i * CELL_SIZE);
                s.graphics.lineTo(X0 + CELL_NUM * CELL_SIZE, Y0 + i * CELL_SIZE);
                s.graphics.moveTo(X0 + i * CELL_SIZE, Y0 + 0);
                s.graphics.lineTo(X0 + i * CELL_SIZE, Y0 + CELL_NUM * CELL_SIZE);
            }
            s.addEventListener(Event.ENTER_FRAME,
                function(e:Event):void {
                    var s:Sprite = e.target as Sprite; 
                    s.rotationX = 120 * (mouseY / s.stage.stageHeight - 0.5);
                    s.rotationY = 120 * (mouseX / s.stage.stageWidth - 0.5);
                }
            );
            return s;
        }
        
        private function makeChild():Sprite {
            var s:Sprite = new Sprite();
            s.graphics.beginFill(0xff0000);
            s.graphics.drawRect(-CELL_SIZE / 2, -CELL_SIZE / 2, CELL_SIZE, CELL_SIZE);
            s.graphics.endFill();
            s.startDrag(true);
            s.z = s.z; // the solution, or s.z = 0; if you don't prefer "meaningless" code at first sight             
            return s;
        }

    }
}