// In addition to HJKL, added WASD and arrows.
package {
    import flash.display.*;
    import flash.events.*;

    public class Sokoban extends Sprite {
        private static const T:int = 16;
        private var s:Array = ["    #####",
                               "    #   #",
                               "    #$  #",
                               "  ###  $##",
                               "  #  $ $ #",
                               "### # ## #   ######",
                               "#   # ## #####  ..#",
                               "# $  $          ..#",
                               "##### ### #@##  ..#",
                               "    #     #########",
                               "    #######"];
        private var b:Array=[],f:Array=[],v:Array;
        private var u:int,w:int;

        public function Sokoban() {
            for (var j:int = 0; j < s.length; ++j) {
                b[j] = [];
                f[j] = [];
                var l:String = s[j];
                for (var i:int = 0; i < l.length; ++i) {
                    switch (l.charAt(i)) {
                    case '#':
                        b[j][i] = 1;
                        break;
                    case '.':
                        b[j][i] = 2;
                        break;
                    case '$':
                        f[j][i] = 3;
                        break;
                    case '@':
                        f[j][i] = 4;
                        u = i;
                        w = j;
                        break;
                    default:
                        b[j][i]=f[j][i]=0;
                    }
                }
            }

            stage.addEventListener(KeyboardEvent.KEY_DOWN,function(e:KeyboardEvent):void {
                v = null;
                switch (e.keyCode) {
                case 72: // H
				case 37: // left
				case 65: // A
                    v = [-1,0];
                    break;
                case 74: // J
				case 40: // down
				case 83: // S
                    v = [0,1];
                    break;
                case 75: // K
				case 38: // up
				case 87: // W
                    v = [0,-1];
                    break;
                case 76: // L
				case 39: // right
				case 68: // D
                    v = [1,0];
                    break;
                }
                if (v) {
                    var s:String="";
                    for(var i:int=u,j:int=w;0<=j&&j<b.length&&0<=i&&i<b[j].length;i+=v[0],j+=v[1])
                        s+=int(f[j][i]?f[j][i]:b[j][i]);
                    if (s.search(/[02]/)==1)
                        move(v);
                    if (s.search(/3[02]/)==1){
                        move(v);
                        f[w + v[1]][u + v[0]] = 3;
                    }
                }
                redraw();
            });
            redraw();
        }

        private function move(v:Array):void {
            f[w][u] = 0;
            u += v[0];
            w += v[1];
            f[w][u] = 4;
        }

        private function redraw():void {
            graphics.clear();
            graphics.lineStyle(1,0);
            for (var j:int = 0; j < b.length; ++j) {
                for (var i:int = 0; i < b[j].length; ++i) {
                    switch (f[j][i]?f[j][i]:b[j][i]) {
                    case 1:
                        graphics.beginFill(0);
                        graphics.drawRect(i*T,j*T,T,T);
                        graphics.endFill();
                        break;
                    case 2:
                        graphics.drawCircle(i*T+T/2,j*T+T/2,T/8);
                        break;
                    case 3:
                        graphics.drawCircle(i*T+T/2,j*T+T/2,T/2);
                        break;
                    case 4:
                        graphics.drawCircle(i*T+T/2,j*T+T/2,T/2);
                        graphics.drawCircle(i*T+T/2,j*T+T/2,T/4);
                        break;
                    }
                }
            }
        }
    }
}
