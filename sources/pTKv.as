package {
    import flash.system.LoaderContext;
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import net.hires.debug.*;

    [SWF(frameRate = "30", width="465", height="465")]

    /**
     * Water 3D
     *
     * ・解説コメントをちょっと入れました
     * 
     * Click&Drag:Make wave
     * 
     * @author saharan
     */
    public class Water3D extends Sprite {
        private const NUM_DETAILS:int = 48;
        private const INV_NUM_DETAILS:Number = 1 / NUM_DETAILS;
        private const MESH_SIZE:Number = 100;
        private var count:uint;
        private var bmd:BitmapData;
        private var loader:Loader;
        private var vertices:Vector.<Vertex>;
        private var transformedVertices:Vector.<Number>;
        private var indices:Vector.<int>;
        private var uvt:Vector.<Number>;
        private var width2:Number;
        private var height2:Number;
        private var heights:Vector.<Vector.<Number>>;
        private var velocity:Vector.<Vector.<Number>>;
        private var press:Boolean;

        public function Water3D():void {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.quality = StageQuality.LOW;
            width2 = 465 / 2;
            height2 = 465 / 2;
            // var s:Stats = new Stats();
            // s.alpha = 0.8;
            // addChild(s);
            count = 0;
            loader = new Loader();
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/b/b2/b217/b2177f87d979a28b9bcbb6e0b89370e77ce22337"), new LoaderContext(true));
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,
                function(e:Event = null):void {
                    bmd = Bitmap(loader.content).bitmapData;
                    addEventListener(Event.ENTER_FRAME, frame);
                });
            stage.addEventListener(MouseEvent.MOUSE_DOWN,
                function(e:Event = null):void {
                    drag();
                    press = true;
                });
            stage.addEventListener(MouseEvent.MOUSE_UP,
                function(e:Event = null):void {
                    press = false;
                });
            stage.addEventListener(MouseEvent.MOUSE_MOVE,
                function(e:Event = null):void {
                    if (press) drag();
                });
            vertices = new Vector.<Vertex>(NUM_DETAILS * NUM_DETAILS, true);
            transformedVertices = new Vector.<Number>(NUM_DETAILS * NUM_DETAILS * 2, true);
            indices = new Vector.<int>();
            uvt = new Vector.<Number>(NUM_DETAILS * NUM_DETAILS * 2, true);
            var i:int;
            var j:int;
            // 頂点初期化。外側2つ分は表示しないので無駄な処理＆メモリに・・・
            for (i = 2; i < NUM_DETAILS - 2; i++) {
                for (j = 2; j < NUM_DETAILS - 2; j++) {
                    vertices[getIndex(j, i)] = new Vertex(
                        (j - (NUM_DETAILS - 1) * 0.5) / NUM_DETAILS * MESH_SIZE, 0,
                        (i - (NUM_DETAILS - 1) * 0.5) / NUM_DETAILS * MESH_SIZE);
                    if (i != 2 && j != 2) {
                        indices.push(getIndex(i - 1, j - 1), getIndex(i, j - 1), getIndex(i, j));
                        indices.push(getIndex(i - 1, j - 1), getIndex(i, j), getIndex(i - 1, j));
                    }
                }
            }
            // 水面関係初期化
            heights = new Vector.<Vector.<Number>>(NUM_DETAILS, true);
            velocity = new Vector.<Vector.<Number>>(NUM_DETAILS, true);
            for (i = 0; i < NUM_DETAILS; i++) {
                heights[i] = new Vector.<Number>(NUM_DETAILS, true);
                velocity[i] = new Vector.<Number>(NUM_DETAILS, true);
                for (j = 0; j < NUM_DETAILS; j++) {
                    heights[i][j] = 0;
                    velocity[i][j] = 0;
                }
            }
        }

        private function frame(e:Event = null):void {
            count++;
            move();
            setMesh();
            transformVertices();
            draw();
        }

        private function setMesh():void {
            for (var i:int = 2; i < NUM_DETAILS - 2; i++) {
                for (var j:int = 2; j < NUM_DETAILS - 2; j++) {
                    const index:int = getIndex(i, j);
                    vertices[index].y = heights[i][j] * 0.15;
                    
                    // ---Sphere map---
                    
                    var nx:Number;
                    var ny:Number;
                    // nz is 1
                    nx = (heights[i][j] - heights[i - 1][j]) * 0.15;
                    ny = (heights[i][j] - heights[i][j - 1]) * 0.15;
                    var len:Number = 1 / Math.sqrt(nx * nx + ny * ny + 1);
                    nx *= len;
                    ny *= len;
                    // ちょっと式を変更して平面でもテクスチャが見えるように
                    uvt[index * 2] = nx * 0.5 + 0.5 + ((i - NUM_DETAILS * 0.5) * INV_NUM_DETAILS * 0.25);
                    uvt[index * 2 + 1] = ny * 0.5 + 0.5 + ((NUM_DETAILS * 0.5 - j) * INV_NUM_DETAILS * 0.25);
                }
            }
        }

        public function move():void {
            
            // ---Water simulation---
            
            var i:int;
            var j:int;
            var mx:Number = mouseX / 465 * NUM_DETAILS;
            var my:Number = (1 - mouseY / 465) * NUM_DETAILS;
            for (i = 1; i < NUM_DETAILS - 1; i++) {
                for (j = 1; j < NUM_DETAILS - 1; j++) {
                    heights[i][j] += velocity[i][j];
                    if (heights[i][j] > 100) heights[i][j] = 100;
                    else if (heights[i][j] < -100) heights[i][j] = -100;
                }
            }
            for (i = 1; i < NUM_DETAILS - 1; i++) {
                for (j = 1; j < NUM_DETAILS - 1; j++) {
                    velocity[i][j] = (velocity[i][j] +
                        (heights[i - 1][j] + heights[i][j - 1] + heights[i + 1][j] +
                        heights[i][j + 1] - heights[i][j] * 4) * 0.5) * 0.95;
                }
            }
        }

        public function drag():void {
            var i:int;
            var j:int;
            var mx:Number = mouseX / 465 * NUM_DETAILS;
            var my:Number = (1 - mouseY / 465) * NUM_DETAILS;
            for (i = mx - 3; i < NUM_DETAILS - 1 && mx + 3; i++) {
                for (j = my - 3; j < NUM_DETAILS - 1 && my + 3; j++) {
                    if (i > 1 && j > 1 && i < NUM_DETAILS - 1 && j < NUM_DETAILS - 1) {
                        var len:Number = 3 - Math.sqrt((mx - i) * (mx - i) + (my - j) * (my - j));
                        if (len < 0) len = 0;
                        velocity[i][j] -= len * (press ? 1 : 5);
                    }
                }
            }
        }

        private function draw():void {
            graphics.clear();
            graphics.beginFill(0x202020);
            graphics.drawRect(0, 0, 465, 465);
            graphics.endFill();
            graphics.beginBitmapFill(bmd);
            graphics.drawTriangles(transformedVertices, indices, uvt, TriangleCulling.POSITIVE);
            graphics.endFill();
        }

        private function getIndex(x:int, y:int):int {
            return y * NUM_DETAILS + x;
        }

        private function transformVertices():void {
            
            // x軸回転とビュー変換・プロジェクション変換を実行
            
            var angle:Number = 70 * Math.PI / 180;
            var sin:Number = Math.sin(angle);
            var cos:Number = Math.cos(angle);
            for (var i:int = 0; i < vertices.length; i++) {
                var v:Vertex = vertices[i];
                if(v != null) {
                    var x:Number = v.x;
                    // x軸回転行列もどき
                    var y:Number = cos * v.y - sin * v.z;
                    var z:Number = sin * v.y + cos * v.z;
                    // ちょこっとビュー変換っぽいことをする(カメラから離す)
                    z = 1 / (z + 60);
                    // 簡易プロジェクション変換
                    x *= z;
                    y *= z;
                    // スクリーン座標を求める
                    x = x * 232.5 + 232.5;
                    y = y * 232.5 + 182.5;
                    transformedVertices[i * 2] = x;
                    transformedVertices[i * 2 + 1] = y;
                }
            }
        }
    }
}

class Vertex {
    public var x:Number;
    public var y:Number;
    public var z:Number;

    public function Vertex(x:Number, y:Number,z:Number) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}