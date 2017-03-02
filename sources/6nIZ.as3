package {
    import flash.display.CapsStyle;
    import flash.display.GradientType;
    import flash.display.LineScaleMode;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;

    [SWF(width = '465', height = '465', backgroundColor = '0x0', frameRate = '64')]
    /* */
    public class NoodlElectric extends Sprite {
        /* */
        private const NUM_BITS : uint = 1024;
        private const GURF_START : Number = 22;
        private const GURF_DECAY : Number = 0.995;
        /* */
        private var _nodes : Node;
        private var _mtx : Matrix;
        private var sw : int;
        private var sh : int;

        public function NoodlElectric() {
            sw = stage.stageWidth;
            sh = stage.stageHeight;

            stage.stageFocusRect = mouseEnabled = mouseChildren = tabEnabled = tabChildren = false;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.MEDIUM;
            stage.fullScreenSourceRect = new Rectangle(0, 0, sw, sh);
            opaqueBackground = 0x0;

            var node : Node = _nodes = new Node();
            var i : uint = NUM_BITS;
            while (i-- != 0) {
                node.x = sw * Math.random();
                node.y = sh * Math.random();
                node.next = new Node();
                node.next.prev = node;
                node = node.next;
            }

            _mtx = new Matrix();
            _mtx.createGradientBox(sw, sh, Math.PI);

            addEventListener(Event.ENTER_FRAME, oef);
        }

        private function oef(e : Event) : void {
            var gurf : Number = GURF_START;
            var gdecay : Number = GURF_DECAY;
            var pi : Number = Math.PI;
            var tx : Number = stage.mouseX + Math.random();
            var ty : Number = stage.mouseY + Math.random();

            var node : Node = _nodes;
            node.a = pi + Math.atan2(ty - node.y, tx - node.x);
            node.x += (tx - node.x) * 0.11;
            node.y += (ty - node.y) * 0.11;

            graphics.clear();
            graphics.beginGradientFill(GradientType.RADIAL, [0x777777, 0x555555], [1.0, 1.0], [0, 255], _mtx);
            graphics.drawRect(0, 0, sw, sh);
            graphics.endFill();

            graphics.moveTo(node.x, node.y);

            node = node.next;
            while (node != null) {
                var pnode : Node = node.prev;
                node.a = pi + Math.atan2(pnode.y - node.y, pnode.x - node.x);
                node.x = pnode.x + 8 * Math.cos(pnode.a);
                node.y = pnode.y + 8 * Math.sin(pnode.a);

                graphics.lineStyle(gurf *= gdecay, 0xEFEFEF, 1.0, false, LineScaleMode.NONE, CapsStyle.SQUARE);
                graphics.lineTo(node.x, node.y);

                node = node.next;
            }
        }
    }
}
import flash.display.GradientType;
import flash.display.Shape;
import flash.events.Event;
import flash.geom.Matrix;

internal class Node {
    public var next : Node;
    public var prev : Node;
    public var x : Number;
    public var y : Number;
    public var a : Number;
}