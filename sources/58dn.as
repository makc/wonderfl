/**
 * Fluid \ Learning \ Processing 1.0
 * http://www.processing.org/learning/topics/fluid.html
 * 
 * via [Flash]流体っぽいのを作ろうと思った | blog ViolentCoding
 * http://violentcoding.com/blog/2008/07/26/archives/135
 */
package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;
//    import net.hires.debug.Stats;
    
    [SWF(backgroundColor=0xFFFFFF, width=465, height=465, frameRate=60)]
    public class FluidLine extends Sprite {
        
        public function FluidLine() {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private var canvas:Sprite;
        private var pmouseX:Number;
        private var pmouseY:Number;
        private var canvasWidth:int = 465;
        private var canvasHeight:int = 465;
        private var mousePressed:Boolean;
        private var resolution:int = 10;
        private var penSize:int = 40;
        private var numCols:int = canvasWidth / resolution;;
        private var numRows:int = canvasHeight / resolution;
        private var numParticles:int = 10000;
        private var gridDatasVectors:Vector.<Vector.<GridData>> = new Vector.<Vector.<GridData>>();
        private var particles:Vector.<Particle> = new Vector.<Particle>(numParticles, true);
        private var pcount:int = 0;
        
        private function init(e:Event = null):void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            
            var bg:Bitmap = new Bitmap(new BitmapData(465, 465, false, 0x0));
            addChild(bg);
            
            canvas = new Sprite();
            addChild(canvas);
            
            //Wonderfl.capture_delay(5);
            
            stage.quality = StageQuality.MEDIUM;
            //addChild(new Stats());
            
            for (var i:int = 0; i < numParticles; i++) {
                particles[i] = new Particle(Math.random() * canvasWidth, Math.random() * canvasHeight);
            }
            
            for (var col:int = 0; col < numCols; ++col) { 
                gridDatasVectors[col] = new Vector.<GridData>(numRows, true);
                for (var row:int = 0; row < numRows; ++row) { 
                    var gridData:GridData = new GridData(col * resolution, row * resolution, resolution);
                    gridData.col = col;
                    gridData.row = row;
                    gridDatasVectors[col][row] = gridData;
                }
            }
            
            //隣接するグリッドをセットしていく。
            for (col = 0; col < numCols; ++col) { 
                for (row = 0; row < numRows; ++row) { 
                    gridData = gridDatasVectors[col][row];
                    if (row > 0) {
                        var up:GridData = gridDatasVectors[col][row - 1];//上
                        gridData.up = up;
                        up.low = gridData;//下
                    }
                    
                    if (col > 0) {
                        var left:GridData = gridDatasVectors[col - 1][row];//左
                        gridData.left = left;
                        left.right = gridData;//右
                    }
                    
                    if (row > 0 && col > 0) {
                        var upperLeft:GridData = gridDatasVectors[col - 1][row - 1];
                        gridData.upperLeft = upperLeft;
                        upperLeft.lowerRight = gridData;
                    }
                    
                    if (row > 0 && col < numCols - 1) {
                        var upperRight:GridData = gridDatasVectors[col + 1][row - 1];
                        gridData.upperRight = upperRight;
                        upperRight.lowerLeft = gridData;
                    }
                }
            }
            
            gridDatasVectors.fixed = true;
            addEventListener(Event.ENTER_FRAME, draw);
        }
        
        private function draw(e:Event):void {
            var mouseXvel:Number = mouseX - pmouseX;
            var mouseYvel:Number = mouseY - pmouseY;
            
            for each(var gridDatas:Vector.<GridData> in gridDatasVectors) {
                for each(var gridData:GridData in gridDatas) {
                    if (mousePressed) {
                        updateGridDataVelocity(gridData, mouseXvel, mouseYvel, penSize);
                    }
                    updatePressure(gridData);
                    
                }
            }
            
            canvas.graphics.clear();
            canvas.graphics.lineStyle(1, 0xFFFFFF);
            updateParticle();
            
            for each(gridDatas in gridDatasVectors) {
                for each(gridData in gridDatas) {
                    apdateVelocity(gridData);
                }
            }
            
            pmouseX = mouseX;
            pmouseY = mouseY;
        }
        
        public function updateParticle():void {
            for each(var p:Particle in particles) {
                if (p.x >= 0 && p.x < canvasWidth && p.y >= 0 && p.y < canvasHeight) {
                    var col:int = int(p.x / resolution);//自身が属しているgridDataを見つける
                    var row:int = int(p.y / resolution);
                    
                    if (col > numCols - 1) col = numCols - 1;
                    if (row > numRows - 1) row = numRows - 1;
                    
                    var gridData:GridData = gridDatasVectors[col][row];
                    
                    var ax:Number = (p.x % resolution) / resolution;
                    var ay:Number = (p.y % resolution) / resolution;
                    p.xvel += (1 - ax) * gridData.xvel * 0.05;
                    p.yvel += (1 - ay) * gridData.yvel * 0.05;
                    
                    p.xvel += ax * gridData.right.xvel * 0.05;
                    p.yvel += ax * gridData.right.yvel * 0.05;
                    
                    p.xvel += ay * gridData.low.xvel * 0.05;
                    p.yvel += ay * gridData.low.yvel * 0.05;
                    
                    p.x += p.xvel;
                    p.y += p.yvel;
                    
                    var dx:Number = p.px - p.x;
                    var dy:Number = p.py - p.y;
                    var dist:Number = Math.sqrt(dx * dx + dy * dy);
                    var limit:Number = Math.random() * 0.5;
                    
                    if (dist > limit) {
                        canvas.graphics.moveTo(p.x, p.y);
                        canvas.graphics.lineTo(p.px, p.py);
                    }
                    else {
                        canvas.graphics.moveTo(p.x, p.y);
                        canvas.graphics.lineTo(p.x + limit, p.y + limit);
                    }
                    
                    p.px = p.x;
                    p.py = p.y;
                }
                else {
                    p.x = p.px = Math.random() * canvasWidth;
                    p.y = p.py = Math.random() * canvasHeight;
                    p.xvel = 0;
                    p.yvel = 0;
                }
                
                p.xvel *= 0.5;
                p.yvel *= 0.5;
            }
        }
        
        /**
         * マウスドラッグの処理
         * @param    gridData
         * @param    mvelX
         * @param    mvelY
         * @param    penSize
         */
        public function updateGridDataVelocity(gridData:GridData, mvelX:int, mvelY:int, penSize:Number):void {
            var dx:Number = gridData.x - mouseX;
            var dy:Number = gridData.y - mouseY;
            var dist:Number = Math.sqrt(dy * dy + dx * dx);
            
            if (dist < penSize) { 
                if (dist < 4) {
                    dist = penSize;
                }
                
                //マウスに近いほど力が強くなるように。
                var power:Number = penSize / dist;
                gridData.xvel += mvelX * power;
                gridData.yvel += mvelY * power;
            }
        }
        
        public function updatePressure(gridData:GridData):void {
            var pressureX:Number = (
                gridData.upperLeft.xvel * 0.5 //左上
                + gridData.left.xvel       //左
                + gridData.lowerLeft.xvel * 0.5 //左下
                - gridData.upperRight.xvel * 0.5 //右上
                - gridData.right.xvel       //右
                - gridData.lowerRight.xvel * 0.5 //右下
            );
            
            var pressureY:Number = (
                gridData.upperLeft.yvel * 0.5 //左上
                + gridData.up.yvel       //上
                + gridData.upperRight.yvel * 0.5 //右上
                - gridData.lowerLeft.yvel * 0.5 //左下
                - gridData.low.yvel       //下
                - gridData.lowerRight.yvel * 0.5 //右下
            );
            
            gridData.pressure = (pressureX + pressureY) * 0.25;
        }
        
        public function apdateVelocity(gridData:GridData):void {
            gridData.xvel += (
                gridData.upperLeft.pressure * 0.5 //左上
                + gridData.left.pressure       //左
                + gridData.lowerLeft.pressure * 0.5 //左下
                - gridData.upperRight.pressure * 0.5 //右上
                - gridData.right.pressure       //右
                - gridData.lowerRight.pressure * 0.5 //右下
            ) * 0.25;
            
            gridData.yvel += (
                gridData.upperLeft.pressure * 0.5 //左上
                + gridData.up.pressure       //上
                + gridData.upperRight.pressure * 0.5 //右上
                - gridData.lowerLeft.pressure * 0.5 //左下
                - gridData.low.pressure       //下
                - gridData.lowerRight.pressure * 0.5 //右下
            ) * 0.25;
            
            gridData.xvel *= 0.99;
            gridData.yvel *= 0.99;
        }
        
        private function mouseDownHandler(e:Event):void {
            mousePressed = true;
        }
        
        private function mouseUpHandler(e:Event):void {
            mousePressed = false;
        }
    }    
}



import flash.geom.Rectangle;
class BaseGridData {
    
    public var col:int = 0;
    public var row:int = 0;
    
    public var x:int = 0;
    public var y:int = 0;
    
    public var xvel:Number = 0;
    public var yvel:Number = 0;
    
    public var pressure:Number = 0;
    
    public var color:Number = 0;
    public var rgb:uint;
    public var rectangle:Rectangle;
}

class GridData extends BaseGridData{
    
    public function GridData(x:int, y:int, resolution:Number) {
        this.x = x;
        this.y = y;
        rectangle = new Rectangle(x, y, resolution, resolution)
    }
    
    //すべてのグリッドが8方向に隣接したグリッドを持つわけではないので、
    //空のデータをセットしておく。
    public var upperLeft:BaseGridData = new NullGridData();//左上
    public var up:BaseGridData = new NullGridData();//上
    public var upperRight:BaseGridData = new NullGridData();//右上
    
    public var left:BaseGridData = new NullGridData();//左
    public var right:BaseGridData = new NullGridData();//右
    
    public var lowerLeft:BaseGridData = new NullGridData();//左下
    public var low:BaseGridData = new NullGridData();//下
    public var lowerRight:BaseGridData = new NullGridData();//右下    
}

class NullGridData extends BaseGridData{
}

class Particle {    
    
    public function Particle(x:Number, y:Number) {
        this.x = px = x;
        this.y = py = y;
    }
    
    public var x:Number;
    public var y:Number;
    
    public var px:Number;
    public var py:Number;
    public var xvel:Number = 0;
    public var yvel:Number = 0;
    
}