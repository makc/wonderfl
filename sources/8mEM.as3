package 

{

    import flash.display.Sprite;

    import flash.display.StageQuality;

    import flash.events.Event;

    

    /**

     * ...

     * 参考

     * http://cuaoar.jp/2012/04/flash-player-113-bittmap.html

     * @author umhr

     */

    public class WonderflMain extends Sprite 

    {

        

        public function WonderflMain():void 

        {

            if (stage) init();

            else addEventListener(Event.ADDED_TO_STAGE, init);

        }

        

        private function init(e:Event = null):void 

        {

            removeEventListener(Event.ADDED_TO_STAGE, init);

            // entry point

            stage.scaleMode = "noScale";

            stage.align = "TL";

            addChild(new Canvas());

        }

        

    }

    

}



    

    import com.bit101.components.CheckBox;

    import com.bit101.components.ComboBox;

    import com.bit101.components.Label;

    import com.bit101.components.NumericStepper;

    import com.bit101.components.Style;

    import flash.display.Bitmap;

    import flash.display.BitmapData;

    import flash.display.DisplayObject;

    import flash.display.GraphicsPathCommand;

    import flash.display.PixelSnapping;

    import flash.display.Shape;

    import flash.display.Sprite;

    import flash.display.StageQuality;

    import flash.events.Event;

    import flash.events.MouseEvent;

    import flash.geom.Matrix;

    /**

     * ...

     * @author umhr

     */

     class Canvas extends Sprite 

    {

        private var _masterShape:Shape;

        private var _drawCanvas:Sprite = new Sprite();

        private var _checkBox:CheckBox;

        private var _loupe:Loupe;

        private var _numericStepper:NumericStepper;

        private var _comboBox:ComboBox;

        public function Canvas() 

        {

            init();

        }

        private function init():void 

        {

            if (stage) onInit();

            else addEventListener(Event.ADDED_TO_STAGE, onInit);

        }



        private function onInit(event:Event = null):void 

        {

            removeEventListener(Event.ADDED_TO_STAGE, onInit);

            // entry point

            

            Style.embedFonts = false;

            Style.fontName = "PF Ronda Seven";

            Style.fontSize = 10;

            

            _checkBox = new CheckBox(this, 20, 175, "縮小時に回転", onRadio);

            _checkBox.selected = true;

            _numericStepper = new NumericStepper(this, 20, 150, onRadio);

            _numericStepper.width = 55;

            _numericStepper.value = 0;

            new Label(this, 80, 150, "回転角度（degree）");

            var qualityList:Array/*String*/ = ["StageQuality.LOW", "StageQuality.MEDIUM", "StageQuality.HIGH", "StageQuality.BEST", "StageQuality.HIGH_8X8", "StageQuality.HIGH_8X8_LINEAR", "StageQuality.HIGH_16X16", "StageQuality.HIGH_16X16_LINEAR"];

            _comboBox = new ComboBox(this, 20, 190, "Choose a Quality", qualityList);

            _comboBox.width = 180;

            _comboBox.selectedIndex = 4;

            _comboBox.addEventListener(Event.SELECT, onRadio);

            new Label(this, 20, 5, "元Shape");

            _masterShape = getShape(20, 20,true);

            _numericStepper.value = 1;

            addChild(_masterShape);

            

            addChild(_drawCanvas);

            

            draw();

            

            _loupe = new Loupe();

            _loupe.x = 10;

            _loupe.y = 240;

            addChild(_loupe);

            addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);

        }

        

        private function mouseMove(e:MouseEvent):void 

        {

            _loupe.setZoom(this,stage.mouseX,stage.mouseY);

        }

        private function onRadio(e:Event):void {

            draw();

        }

        

        private function draw():void {

            var selectedItem:String = String(_comboBox.selectedItem);

            if (_comboBox.selectedItem && selectedItem.substr(0,"StageQuality.".length) == "StageQuality.") {

                selectedItem = selectedItem.substr("StageQuality.".length);

                stage.quality = StageQuality[selectedItem];

            }

            

            while (_drawCanvas.numChildren > 0) {

                _drawCanvas.removeChildAt(0);

            }

            _drawCanvas.addChild(new Label(this, 225, 0, "Shape自体を回転"));

            _drawCanvas.addChild(getShape(225,13,false));

            

            _drawCanvas.addChild(getBitmap(_masterShape,2,345,0));

            

            // BitmapData

            _drawCanvas.addChild(getBitmapByBitmapData(_masterShape,2,225,115));

            _drawCanvas.addChild(getBitmapByBitmapData2(_masterShape, 2, 345, 115));

            // Bitmap

            _drawCanvas.addChild(getBitmapByBitmap(_masterShape,2,225,230));

            _drawCanvas.addChild(getBitmapByBitmap2(_masterShape,2,345,230));

            // Shape

            _drawCanvas.addChild(getBitmapByShape(_masterShape,2,225,350));

            _drawCanvas.addChild(getBitmapByShape2(_masterShape,2,345,350));

        }

        private function getBitmap(displayObject:DisplayObject, sampleScale:Number, x:int, y:int):Bitmap {

            var rotation:int = _numericStepper.value;

            _drawCanvas.addChild(new Label(this, x, y, "Bitmap自体を回転"));

            var result:Bitmap = new Bitmap(new BitmapData(displayObject.width, displayObject.height, true, 0x0), PixelSnapping.AUTO, true);

            result.bitmapData.draw(displayObject);

            result.rotation = rotation;

            result.x = x;

            result.y = y+13;

            return result;

        }

        

        private function getShape(x:int, y:int,isMoto:Boolean):Shape {

            var rotation:int = _numericStepper.value;

            var shape:Shape = new Shape();

            shape.graphics.beginFill(0xFFFFFF);

            shape.graphics.drawRect(0, 0, 100, 100);

            

                shape.graphics.beginFill(0x000000);

                shape.graphics.drawRect(2, 2, 96, 96);

                shape.graphics.beginFill(0xFFFFFF);

                shape.graphics.drawRect(4, 4, 92, 92);

                

            for (var i:int = 2; i < 16; i++) 

            {

                shape.graphics.beginFill(0x000000);

                shape.graphics.drawRect(2+i*2, 2+i*2, 96-i*4, 96-i*4);

                shape.graphics.beginFill(0xFFFFFF);

                shape.graphics.drawRect(2+i*2+1, 2+i*2+1, 96-i*4-2, 96-i*4-2);

            }

            shape.graphics.endFill();

            shape.x = x;

            shape.y = y;

            shape.rotation = rotation;

            return shape;

        }

        

        private function getBitmapByBitmapData(displayObject:DisplayObject, sampleScale:Number, x:int, y:int):Bitmap {

            var rotation:int = _numericStepper.value;

            _drawCanvas.addChild(new Label(this, x, y, "BitmapDataにdraw"));

            

            var tempBitmap:BitmapData = new BitmapData(displayObject.width*sampleScale, displayObject.height*sampleScale, true, 0x0);

            var matrix:Matrix = new Matrix();

            matrix.scale(sampleScale, sampleScale);

            if (!_checkBox.selected) {

                matrix.rotate(rotation * Math.PI / 180);

            }

            tempBitmap.draw(displayObject, matrix, null, null, null, true);

            

            matrix.identity();

            if (_checkBox.selected) {

                matrix.rotate(rotation * Math.PI / 180);

            }

            matrix.scale(1 / sampleScale, 1 / sampleScale);

            

            var result:Bitmap = new Bitmap(new BitmapData(displayObject.width, displayObject.height, true, 0x0), PixelSnapping.AUTO, true);

            result.bitmapData.draw(tempBitmap, matrix, null, null, null, true);

            result.smoothing = true;

            result.x = x;

            result.y = y+13;

            return result;

        }

        

        private function getBitmapByBitmap(displayObject:DisplayObject, sampleScale:Number, x:int, y:int):Bitmap {

            var rotation:int = _numericStepper.value;

            _drawCanvas.addChild(new Label(this, x, y, "Bitmapにdraw"));

            

            var tempBitmap:Bitmap = new Bitmap(new BitmapData(displayObject.width*sampleScale, displayObject.height*sampleScale, true, 0x0), PixelSnapping.AUTO, true);

            var matrix:Matrix = new Matrix();

            matrix.scale(sampleScale, sampleScale);

            if (!_checkBox.selected) {

                matrix.rotate(rotation * Math.PI / 180);

            }

            tempBitmap.bitmapData.draw(displayObject, matrix, null, null, null, true);

            

            matrix.identity();

            if (_checkBox.selected) {

                matrix.rotate(rotation * Math.PI / 180);

            }

            matrix.scale(1 / sampleScale, 1 / sampleScale);

            

            var result:Bitmap = new Bitmap(new BitmapData(displayObject.width, displayObject.height, true, 0x0), PixelSnapping.AUTO, true);

            result.bitmapData.draw(tempBitmap, matrix, null, null, null, true);

            result.x = x;

            result.y = y+13;

            return result;

        }

        

        private function getBitmapByBitmapData2(displayObject:DisplayObject, sampleScale:Number, x:int, y:int):Bitmap {

            var rotation:int = _numericStepper.value;

            _drawCanvas.addChild(new Label(this, x, y, "BitmapDataに2回draw"));

            

            var tempBitmap:BitmapData = new BitmapData(displayObject.width*sampleScale, displayObject.height*sampleScale, true, 0x0);

            var matrix:Matrix = new Matrix();

            matrix.scale(sampleScale, sampleScale);

            if (!_checkBox.selected) {

                matrix.rotate(rotation * Math.PI / 180);

            }

            tempBitmap.draw(displayObject, matrix,null,null,null,true);

            

            matrix.identity();

            matrix.scale(1 / Math.sqrt(sampleScale), 1 / Math.sqrt(sampleScale));

            if (_checkBox.selected) {

                matrix.rotate(0.5 * rotation * Math.PI / 180);

            }

            

            var tempBitmap2:BitmapData = new BitmapData(Math.ceil(displayObject.width*Math.sqrt(sampleScale)), Math.ceil(displayObject.height*Math.sqrt(sampleScale)), true, 0x0);

            tempBitmap2.draw(tempBitmap, matrix, null, null, null, true);

            

            var result:Bitmap = new Bitmap(new BitmapData(displayObject.width, displayObject.height, true, 0x0), PixelSnapping.AUTO, true);

            result.bitmapData.draw(tempBitmap2, matrix, null, null, null, true);

            result.x = x;

            result.y = y+13;

            return result;

        }

        private function getBitmapByBitmap2(displayObject:DisplayObject,sampleScale:Number,x:int,y:int):Bitmap {

            var rotation:int = _numericStepper.value;

            _drawCanvas.addChild(new Label(this, x, y, "Bitmapに2回draw"));

            

            var tempBitmap:Bitmap = new Bitmap(new BitmapData(displayObject.width*sampleScale, displayObject.height*sampleScale, true, 0x0), PixelSnapping.AUTO, true);

            var matrix:Matrix = new Matrix();

            matrix.scale(sampleScale, sampleScale);

            if (!_checkBox.selected) {

                matrix.rotate(rotation * Math.PI / 180);

            }

            tempBitmap.bitmapData.draw(displayObject, matrix,null,null,null,true);

            

            matrix.identity();

            matrix.scale(1 / Math.sqrt(sampleScale), 1 / Math.sqrt(sampleScale));

            if (_checkBox.selected) {

                matrix.rotate(0.5 * rotation * Math.PI / 180);

            }

            var tempBitmap2:Bitmap = new Bitmap(new BitmapData(Math.ceil(displayObject.width*Math.sqrt(sampleScale)), Math.ceil(displayObject.height*Math.sqrt(sampleScale)), true, 0x0), PixelSnapping.AUTO, true);

            tempBitmap2.bitmapData.draw(tempBitmap, matrix,null,null,null,true);

            

            var result:Bitmap = new Bitmap(new BitmapData(displayObject.width, displayObject.height, true, 0x0), PixelSnapping.AUTO, true);

            result.bitmapData.draw(tempBitmap2, matrix,null,null,null,true);

            result.x = x;

            result.y = y+13;

            return result;

        }

        

        private function getBitmapByShape(displayObject:DisplayObject, sampleScale:Number, x:int, y:int):Bitmap {

            var rotation:int = _numericStepper.value;

            _drawCanvas.addChild(new Label(this, x, y, "ShapeにbeginBitmapFill"));

            

            var tempBitmap:Bitmap = new Bitmap(new BitmapData(displayObject.width*sampleScale, displayObject.height*sampleScale, true, 0x0), PixelSnapping.AUTO, true);

            var matrix:Matrix = new Matrix();

            matrix.scale(sampleScale, sampleScale);

            if (!_checkBox.selected) {

                matrix.rotate(rotation * Math.PI / 180);

            }

            tempBitmap.bitmapData.draw(displayObject, matrix, null, null, null, true);

            

            matrix.identity();

            if (_checkBox.selected) {

                matrix.rotate(rotation * Math.PI / 180);

            }

            matrix.scale(1 / sampleScale, 1 / sampleScale);

            

            var shape:Shape = new Shape();

            shape.graphics.beginBitmapFill(tempBitmap.bitmapData, matrix, false, true);

            shape.graphics.drawRect(0, 0, Math.ceil(displayObject.width * sampleScale), Math.ceil(displayObject.height * sampleScale));

            shape.graphics.endFill();

            

            var result:Bitmap = new Bitmap(new BitmapData(displayObject.width, displayObject.height, true, 0x0), PixelSnapping.AUTO, true);

            result.bitmapData.draw(shape, null, null, null, null, true);

            result.x = x;

            result.y = y+13;

            return result;

        }

        private function getBitmapByShape2(displayObject:DisplayObject, sampleScale:Number, x:int, y:int):Bitmap {

            var rotation:int = _numericStepper.value;

            _drawCanvas.addChild(new Label(this, x, y, "Shapeに2回beginBitmapFill"));

            

            var tempBitmap:Bitmap = new Bitmap(new BitmapData(displayObject.width*sampleScale, displayObject.height*sampleScale, true, 0x0), PixelSnapping.AUTO, true);

            var matrix:Matrix = new Matrix();

            matrix.scale(sampleScale, sampleScale);

            if (!_checkBox.selected) {

                matrix.rotate(rotation * Math.PI / 180);

            }

            tempBitmap.bitmapData.draw(displayObject, matrix, null, null, null, true);

            

            matrix.identity();

            if (_checkBox.selected) {

                matrix.rotate(0.5 * rotation * Math.PI / 180);

            }

            matrix.scale(1 / Math.sqrt(sampleScale), 1 / Math.sqrt(sampleScale));

            

            var shape:Shape = new Shape();

            shape.graphics.beginBitmapFill(tempBitmap.bitmapData, matrix, false, true);

            shape.graphics.drawRect(0, 0, Math.ceil(displayObject.width * Math.sqrt(sampleScale)), Math.ceil(displayObject.height * Math.sqrt(sampleScale)));

            shape.graphics.endFill();

            var tempBitmapData:BitmapData = new BitmapData(shape.width, shape.height);

            tempBitmapData.draw(shape,null, null, null, null, true);

            

            var shape2:Shape = new Shape();

            shape2.graphics.beginBitmapFill(tempBitmapData, matrix, false, true);

            shape2.graphics.drawRect(0, 0, displayObject.width, displayObject.height);

            shape2.graphics.endFill();

            

            

            var result:Bitmap = new Bitmap(new BitmapData(displayObject.width, displayObject.height, true, 0x0), PixelSnapping.AUTO, true);

            result.bitmapData.draw(shape2, null, null, null, null, true);

            result.x = x;

            result.y = y+13;

            return result;

        }

        

        private function createStarPoints(tx:Number,ty:Number,numVertices:int, longRadius:Number):Array {

            var shortRadius:Number = longRadius * (5 / 13);

            var starPoints:Vector.<Number> = new Vector.<Number>();

            var angle:Number = Math.PI;

            var theta:Number = angle / numVertices;

            angle /= -2;

            for (var i:int = 0; i < numVertices; i++) {

                starPoints.push(longRadius * Math.cos(angle)+tx, longRadius * Math.sin(angle)+ty);

                angle += theta;

                starPoints.push(shortRadius * Math.cos(angle)+tx, shortRadius * Math.sin(angle)+ty);

                angle += theta;

            }

            starPoints.push(longRadius * Math.cos( -Math.PI/2)+tx, longRadius * Math.sin( -Math.PI/2)+ty);

            

            var pathCommand:Vector.<int> = new Vector.<int>();

            var n:int = numVertices * 2 + 1;

            for (i = 0; i < n; i++) 

            {

                pathCommand[i] = i == 0?GraphicsPathCommand.MOVE_TO:GraphicsPathCommand.LINE_TO;

            }

            return [pathCommand, starPoints];

        }

    }

    



    

    import flash.display.Bitmap;

    import flash.display.BitmapData;

    import flash.display.DisplayObject;

    import flash.display.Sprite;

    import flash.events.Event;

    import flash.geom.Matrix;

    import flash.geom.Rectangle;

    /**

     * ...

     * @author umhr

     */

     class Loupe extends Sprite 

    {

        private var _bitmap:Bitmap;

        

        public function Loupe() 

        {

            init();

        }

        private function init():void 

        {

            if (stage) onInit();

            else addEventListener(Event.ADDED_TO_STAGE, onInit);

        }



        private function onInit(event:Event = null):void 

        {

            removeEventListener(Event.ADDED_TO_STAGE, onInit);

            // entry point

            

            _bitmap = new Bitmap(new BitmapData(200, 200, false,0xFF000000));

            addChild(_bitmap);

        }

        public function setZoom(displayObject:DisplayObject, mouseX:int, mouseY:int):void {

            var bitmapData:BitmapData = new BitmapData(40, 40, false);

            bitmapData.draw(displayObject,new Matrix(1,0,0,1,-mouseX+20,-mouseY+20), null, null,new Rectangle(0,0,40,40));

            

            _bitmap.bitmapData.fillRect(new Rectangle(1, 1, 198, 198), 0xFFFFFF);

            _bitmap.bitmapData.draw(bitmapData,new Matrix(5,0,0,5), null, null,new Rectangle(1,1,198,198));

        }

    }

    

