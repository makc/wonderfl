// forked from greentec's forked from: forked from: Barnsley Fern
// forked from greentec's forked from: Barnsley Fern
// forked from greentec's Barnsley Fern
package {
    import com.bit101.components.ColorChooser;
    import com.bit101.components.ComboBox;
    import com.bit101.components.InputText;
    import com.bit101.components.Label;
    import com.bit101.components.NumericStepper;
    import com.bit101.components.PushButton;
    import com.bit101.components.RadioButton;
    import com.bit101.components.Window;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import com.bit101.components.Style;

    public class FlashTest extends Sprite {
        public var _bitmap:Bitmap;
        public var _bitmapData:BitmapData;
        
        public var _backBitmap:Bitmap;
        public var _backBitmapData:BitmapData;
        
        //public var table:Array = [
            //[0,        0,        0,        0.16,    0,         0,        0.01],
            //[0.85,    0.04,    -0.04,    0.85,    0,        1.6,    0.85],
            //[0.2,    -0.26,    0.23,    0.22,    0,        1.6,    0.07],
            //[-0.15,    0.28,    0.26,    0.24,    0,        0.44,    0.07]
        //];
        
        public var table:Array = [
            [0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0]
        ];
        
        public var cpx:Number;
        public var cpy:Number;
        public var npx:Number;
        public var npy:Number;
        public var mat:Matrix;
        public var iter:int = 100000;
        public var magnitude:int = 120;
        public var oneFrameIter:int = 200;
        public var nowIter:int = 0;
        
        public var points:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(465);
        public var colors:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(465);
        
        public var colorMap:Array = [[0, 0.2298057, 0.298717966, 0.753683153], [0.03125, 0.26623388, 0.353094838, 0.801466763], [0.0625, 0.30386891, 0.406535296, 0.84495867], [0.09375, 0.342804478, 0.458757618, 0.883725899], [0.125, 0.38301334, 0.50941904, 0.917387822], [0.15625, 0.424369608, 0.558148092, 0.945619588], [0.1875, 0.46666708, 0.604562568, 0.968154911], [0.21875, 0.509635204, 0.648280772, 0.98478814], [0.25, 0.552953156, 0.688929332, 0.995375608], [0.28125, 0.596262162, 0.726149107, 0.999836203], [0.3125, 0.639176211, 0.759599947, 0.998151185], [0.34375, 0.681291281, 0.788964712, 0.990363227], [0.375, 0.722193294, 0.813952739, 0.976574709], [0.40625, 0.761464949, 0.834302879, 0.956945269], [0.4375, 0.798691636, 0.849786142, 0.931688648], [0.46875, 0.833466556, 0.860207984, 0.901068838], [0.5, 0.865395197, 0.86541021, 0.865395561], [0.53125, 0.897787179, 0.848937047, 0.820880546], [0.5625, 0.924127593, 0.827384882, 0.774508472], [0.59375, 0.944468518, 0.800927443, 0.726736146], [0.625, 0.958852946, 0.769767752, 0.678007945], [0.65625, 0.96732803, 0.734132809, 0.628751763], [0.6875, 0.969954137, 0.694266682, 0.579375448], [0.71875, 0.966811177, 0.650421156, 0.530263762], [0.75, 0.958003065, 0.602842431, 0.481775914], [0.78125, 0.943660866, 0.551750968, 0.434243684], [0.8125, 0.923944917, 0.49730856, 0.387970225], [0.84375, 0.89904617, 0.439559467, 0.343229596], [0.875, 0.869186849, 0.378313092, 0.300267182], [0.90625, 0.834620542, 0.312874446, 0.259301199], [0.9375, 0.795631745, 0.24128379, 0.220525627], [0.96875, 0.752534934, 0.157246067, 0.184115123], [1, 0.705673158, 0.01555616, 0.150232812]];
        
        public var flameTypeArray:Array = ["Linear", "Sinusoidal", "Spherical", "Swirl", "Horseshoe", "Polar", "Handkerchief", "Heart", "Disc", "Spiral", "Hyperbolic", "Diamond", "Ex", "Julia", "Fisheye", "Eyefish", "Bubble"];
        public var flameType:Array = [0, 0, 0, 0];
        
        public var flameTypeComboBoxArray:Array = [];
        
        public var inputTextArray:Array = [];
        
        public var nowIterLabel:Label;
        public var _shape:Shape;
        public var colT:ColorTransform;
        
        public var gamma:Number = 0.5;
        
        public var antiBitmapData:BitmapData;
        
        public var drawMoreButton:PushButton;
        
        public var colorMapButtonArray:Array = [];
        public var colorMapShapeArray:Array = [];
        
        public var colorSelectShapeYellow:Shape;
        public var colorSelectShapeGreen:Shape;
        public var colorSelectShapeYellowIndex:int = 0;
        public var colorSelectShapeGreenIndex:int = 32;
        public var colorSelectYellowRadioButton:RadioButton;
        public var colorSelectGreenRadioButton:RadioButton;
        public var colorSelectColorChooser:ColorChooser;
        
        public var debugOffset:int = 20;
        
        public var settingsMiniButton:PushButton;
        public var colorMiniButton:PushButton;
        public var triangleMiniButton:PushButton;
        public var flameMiniButton:PushButton;
        
        public var settingWindow:Window;
        public var colorWindow:Window;
        public var flameWindow:Window;
        public var triangleWindow:Window;
        
        //public var triangleHolder:Sprite;
        //public var triangleBitmapData:BitmapData;
        public var triangleSprite1:Sprite;
        public var triangleSprite2:Sprite;
        public var triangleSprite3:Sprite;
        public var triangleSprite4:Sprite;
        
        public var triangleSpriteArray:Array;
        public var trianglePointSpriteArray:Array;
        
        public var triangleColors:Array = [0xFFF001, 0xFD1999, 0x99FC20, 0x00E6FE, 0xA10EEC];
        
        public var isDragging:Boolean = false;
        public var prevDragX:Number;
        public var prevDragY:Number;
        
        public function FlashTest() {
            
            stage.scaleMode = "noScale";
            
            Style.BACKGROUND = 0x444444;
            Style.BUTTON_FACE = 0x666666;
            Style.INPUT_TEXT = 0xBBBBBB;
            Style.LABEL_TEXT = 0xCCCCCC;
            Style.PANEL = 0x666666;
            Style.PROGRESS_BAR = 0x666666;
            
            _bitmapData = new BitmapData(465, 465, true, 0x00ffffff);
            _bitmap = new Bitmap(_bitmapData);
            
            
            _backBitmapData = new BitmapData(465, 465, false, 0x292929);
            _backBitmap = new Bitmap(_backBitmapData);
            addChild(_backBitmap);
            addChild(_bitmap);
            
            antiBitmapData = new BitmapData(465, 465, true, 0x00ffffff);
            
            _shape = new Shape();
            _shape.graphics.beginFill(0x000000);
            _shape.graphics.drawRect(0, 0, 1, 1);
            _shape.graphics.endFill();
            
            colT = new ColorTransform();
            
            settingWindow = new Window(this, 465 - 130, 10, "Settings");
            settingWindow.hasMinimizeButton = true;
            settingWindow.hasCloseButton = true;
            settingWindow.width = 120;
            settingWindow.height = 260;
            settingWindow.alpha = 0.7;
            settingWindow.name = "setting";
            settingWindow.addEventListener(Event.CLOSE, onWindowClose);
            
            drawMoreButton = new PushButton(settingWindow, 10, 10 + debugOffset, "Draw More", onDrawMore);
            drawMoreButton.toggle = true;
            nowIterLabel = new Label(settingWindow, drawMoreButton.x, drawMoreButton.y + drawMoreButton.height, "Now Iter: " + String(iter));
            
            
            var redrawButton:PushButton = new PushButton(settingWindow, nowIterLabel.x, nowIterLabel.y + nowIterLabel.height + 10, "Redraw", onRedraw);
            var resetButton:PushButton = new PushButton(settingWindow, redrawButton.x, redrawButton.y + redrawButton.height, "Reset All", onResetAll);
            var magnitudeLabel:Label = new Label(settingWindow, resetButton.x, resetButton.y + resetButton.height + 10, "Zoom");
            var magnitudeNumericStepper:NumericStepper = new NumericStepper(settingWindow, resetButton.x, magnitudeLabel.y, 
                function(e:Event):void
                {
                    magnitude = e.target.value;
                }
            );
            magnitudeNumericStepper.value = magnitude;
            magnitudeNumericStepper.x = 110 - 60;
            magnitudeNumericStepper.width = 60;
            
            var iterLabel:Label = new Label(settingWindow, magnitudeLabel.x, magnitudeLabel.y + magnitudeLabel.height, "Iter");
            var iterInputText:InputText = new InputText(settingWindow, magnitudeLabel.x, iterLabel.y, String(iter));
            iterInputText.addEventListener(Event.CHANGE, onChangeIter);
            iterInputText.restrict = "0-9";
            iterInputText.width = 60;
            iterInputText.x = 110 - 60;
            
            var gammaLabel:Label = new Label(settingWindow, iterLabel.x, iterLabel.y + iterLabel.height, "Gamma");
            var gammaNumericStepper:NumericStepper = new NumericStepper(settingWindow, 50, gammaLabel.y, 
                function(e:Event):void
                {
                    gamma = e.target.value;
                }
            );
            gammaNumericStepper.width = 60;
            gammaNumericStepper.value = gamma;
            gammaNumericStepper.minimum = 0.1;
            gammaNumericStepper.maximum = 10;
            gammaNumericStepper.step = 0.1;
            
            var backgroundLabel:Label = new Label(settingWindow, gammaLabel.x, gammaLabel.y + gammaLabel.height, "Back");
            var backgroundColorChooser:ColorChooser = new ColorChooser(settingWindow, 50, backgroundLabel.y, 0x292929, 
                function(e:Event):void
                {
                    _backBitmapData.fillRect(_backBitmapData.rect, e.target.value);
                }
            );
            backgroundColorChooser.usePopup = true;
            
            var shapeAlphaLabel:Label = new Label(settingWindow, backgroundLabel.x, backgroundLabel.y + backgroundLabel.height, "Px Alpha");
            var shapeAlphaNumericStepper:NumericStepper = new NumericStepper(settingWindow, 50, shapeAlphaLabel.y,
                function(e:Event):void
                {
                    _shape.graphics.clear();
                    _shape.graphics.beginFill(0x000000, e.target.value);
                    _shape.graphics.drawRect(0, 0, 1, 1);
                    _shape.graphics.endFill();
                }
            );
            shapeAlphaNumericStepper.step = 0.1;
            shapeAlphaNumericStepper.minimum = 0.1;
            shapeAlphaNumericStepper.maximum = 1.0;
            shapeAlphaNumericStepper.value = 1.0;
            shapeAlphaNumericStepper.width = 60;
            
            var antiAliasingButton:PushButton = new PushButton(settingWindow, shapeAlphaLabel.x, shapeAlphaLabel.y + shapeAlphaLabel.height + 10, "Anti-aliasing", onAntiAliasing);
            
            
            flameWindow = new Window(this, 10, 465 - 150, "Flame Editor");
            flameWindow.hasMinimizeButton = true;
            flameWindow.hasCloseButton = true;
            flameWindow.width = 455;
            flameWindow.height = 140;
            flameWindow.alpha = 0.7;
            flameWindow.name = "flame";
            flameWindow.addEventListener(Event.CLOSE, onWindowClose);
            
            var label:Label;
            label = new Label(flameWindow, 10, 30 + debugOffset, "F0");
            label = new Label(flameWindow, 10, 50 + debugOffset, "F1");
            label = new Label(flameWindow, 10, 70 + debugOffset, "F2");
            label = new Label(flameWindow, 10, 90 + debugOffset, "F3");
            
            label = new Label(flameWindow, 50, 10 + debugOffset, "a");
            label = new Label(flameWindow, 100, 10 + debugOffset, "b");
            label = new Label(flameWindow, 150, 10 + debugOffset, "c");
            label = new Label(flameWindow, 200, 10 + debugOffset, "d");
            label = new Label(flameWindow, 250, 10 + debugOffset, "e");
            label = new Label(flameWindow, 300, 10 + debugOffset, "f");
            label = new Label(flameWindow, 340, 10 + debugOffset, "prob");
            
            label = new Label(flameWindow, 400, 10 + debugOffset, "type");
            
            
            var i:int, j:int;
            var inputText:InputText;
            var comboBox:ComboBox;
            
            for (i = 0; i < 4; i += 1)
            {
                for (j = 0; j < 7; j += 1)
                {
                    inputText = new InputText(flameWindow, 30 + j * 50, 30 + debugOffset + i * 20, "");
                    inputText.width = 45;
                    inputTextArray.push(inputText);
                }
                
                comboBox = new ComboBox(flameWindow, 380, 30 + debugOffset + i * 20, "", flameTypeArray);
                comboBox.selectedIndex = 0;
                comboBox.name = String(i);
                comboBox.addEventListener(Event.SELECT, onChangeFlameType);
                comboBox.width = 70;
                flameTypeComboBoxArray.push(comboBox);
            }
            
            colorWindow = new Window(this, 10, 10, "Color Map Editor");
            colorWindow.hasMinimizeButton = true;
            colorWindow.hasCloseButton = true;
            colorWindow.width = 284;
            colorWindow.height = 140;
            colorWindow.alpha = 0.7;
            colorWindow.name = "color";
            colorWindow.addEventListener(Event.CLOSE, onWindowClose);
            
            var button:PushButton;
            var shape:Sprite;
            var color:uint;
            for (i = 0; i < colorMap.length; i += 1)
            {
                button = new PushButton(colorWindow, 10 + i * 8, 10 + debugOffset, "", onColorMapButtonClick);
                button.width = 8;
                button.height = 50;
                button.name = String(i);
                
                //Style.BACKGROUND = int(colorMap[i][1] * 255) << 16 | int(colorMap[i][2] * 255) << 16 | int(colorMap[i][3] * 255);
                //button.draw();
                color = int(colorMap[i][1] * 255) << 16 | int(colorMap[i][2] * 255) << 8 | int(colorMap[i][3] * 255);
                
                shape = new Sprite();
                shape.graphics.beginFill(color);
                shape.graphics.drawRect(0, 0, 8, 50);
                shape.graphics.endFill();
                shape.mouseEnabled = false;
                shape.mouseChildren = false;
                
                button.addChild(shape);
                
                colorMapButtonArray.push(button);
                colorMapShapeArray.push(shape);
            }
            
            colorSelectShapeYellow = new Shape();
            colorSelectShapeYellow.graphics.beginFill(0xffff00);
            colorSelectShapeYellow.graphics.moveTo(4, 0);
            colorSelectShapeYellow.graphics.lineTo(0, 8);
            colorSelectShapeYellow.graphics.lineTo(8, 8);
            colorSelectShapeYellow.graphics.lineTo(4, 0);
            colorSelectShapeYellow.graphics.endFill();
            
            colorSelectShapeYellow.x = 10 + colorSelectShapeYellowIndex * 8;
            colorSelectShapeYellow.y = 55 + debugOffset;
            
            colorWindow.addChild(colorSelectShapeYellow);
            
            
            colorSelectShapeGreen = new Shape();
            colorSelectShapeGreen.graphics.beginFill(0x00ff00);
            colorSelectShapeGreen.graphics.moveTo(4, 0);
            colorSelectShapeGreen.graphics.lineTo(0, 8);
            colorSelectShapeGreen.graphics.lineTo(8, 8);
            colorSelectShapeGreen.graphics.lineTo(4, 0);
            colorSelectShapeGreen.graphics.endFill();
            
            colorSelectShapeGreen.x = 10 + colorSelectShapeGreenIndex * 8;
            colorSelectShapeGreen.y = 55 + debugOffset;
            
            colorWindow.addChild(colorSelectShapeGreen);
            
            colorSelectYellowRadioButton = new RadioButton(colorWindow, 10, 70 + debugOffset, "Yellow", true);
            colorSelectYellowRadioButton.groupName = "ColorSelect";
            colorSelectGreenRadioButton = new RadioButton(colorWindow, colorSelectYellowRadioButton.x + colorSelectYellowRadioButton.width + 10, colorSelectYellowRadioButton.y, "Green", false);
            colorSelectGreenRadioButton.groupName = "ColorSelect";
            
            colorSelectColorChooser = new ColorChooser(colorWindow, colorSelectYellowRadioButton.x, colorSelectYellowRadioButton.y + colorSelectYellowRadioButton.height + 10, 0xff0000, onColorSelectColorChoose);
            colorSelectColorChooser.usePopup = true;
            
            var gradientButton:PushButton = new PushButton(colorWindow, 284 - 110, colorSelectYellowRadioButton.y, "Gradient", onColorGradient);
            var randomizeButton:PushButton = new PushButton(colorWindow, gradientButton.x, gradientButton.y + gradientButton.height, "Randomize", onRandomize);
            
            
            
            triangleWindow = new Window(this, 10, flameWindow.y - 250, "Triangle Editor");
            triangleWindow.hasMinimizeButton = true;
            triangleWindow.hasCloseButton = true;
            triangleWindow.addEventListener(Event.CLOSE, onWindowClose);
            triangleWindow.alpha = 0.7;
            triangleWindow.width = 220;
            triangleWindow.height = 240;
            triangleWindow.name = "triangle";
            
            //draw Coordinates
            var plane:Shape = new Shape();
            plane.graphics.beginFill(0x002900);
            plane.graphics.drawRect(0, debugOffset, 220, 220);
            plane.graphics.endFill();
            
            for (i = 0; i < 21; i += 1)
            {
                if (i % 5 == 0)
                {
                    plane.graphics.lineStyle(2, 0xffffff);
                }
                else
                {
                    plane.graphics.lineStyle(1, 0xcccccc);
                }
                
                plane.graphics.moveTo(10, 10 + i * 10 + debugOffset);
                plane.graphics.lineTo(210, 10 + i * 10 + debugOffset);
                
                plane.graphics.moveTo(10 + i * 10, 10 + debugOffset);
                plane.graphics.lineTo(10 + i * 10, 210 + debugOffset);
            }
            
            var planeBitmapData:BitmapData = new BitmapData(220, 220, false, 0);
            var planeBitmap:Bitmap = new Bitmap(planeBitmapData);
            planeBitmap.y = debugOffset;
            planeBitmapData.draw(plane, new Matrix(1, 0, 0, 1, 0, -debugOffset));
            
            triangleWindow.addChild(planeBitmap);
            
            triangleSpriteArray = [];
            triangleSprite1 = new Sprite();
            triangleSprite1.y = debugOffset;
            triangleSprite1.name = "plane00";
            triangleSprite1.addEventListener(MouseEvent.MOUSE_DOWN, onTriangleMouseDown, true);
            triangleSprite1.addEventListener(MouseEvent.MOUSE_UP, onTriangleMouseUp, true);
            triangleSpriteArray.push(triangleSprite1);
            triangleSprite2 = new Sprite();
            triangleSprite2.y = debugOffset;
            triangleSprite2.name = "plane01";
            triangleSprite2.addEventListener(MouseEvent.MOUSE_DOWN, onTriangleMouseDown, true);
            triangleSprite2.addEventListener(MouseEvent.MOUSE_UP, onTriangleMouseUp, true);
            triangleSpriteArray.push(triangleSprite2);
            triangleSprite3 = new Sprite();
            triangleSprite3.y = debugOffset;
            triangleSprite3.name = "plane02";
            triangleSprite3.addEventListener(MouseEvent.MOUSE_DOWN, onTriangleMouseDown, true);
            triangleSprite3.addEventListener(MouseEvent.MOUSE_UP, onTriangleMouseUp, true);
            triangleSpriteArray.push(triangleSprite3);
            triangleSprite4 = new Sprite();
            triangleSprite4.y = debugOffset;
            triangleSprite4.name = "plane03";
            triangleSprite4.addEventListener(MouseEvent.MOUSE_DOWN, onTriangleMouseDown, true);
            triangleSprite4.addEventListener(MouseEvent.MOUSE_UP, onTriangleMouseUp, true);
            triangleSpriteArray.push(triangleSprite4);
            
            
            //make 12 sprite... for 4 triangle's point
            trianglePointSpriteArray = [];
            var trianglePoint:Sprite = new Sprite();
            triangleSprite1.addChild(trianglePoint);
            trianglePoint.name = "point00";
            //trianglePoint.addEventListener(MouseEvent.MOUSE_DOWN, onTriangleMouseDown);
            //trianglePoint.addEventListener(MouseEvent.MOUSE_UP, onTriangleMouseUp);
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite1.addChild(trianglePoint);
            trianglePoint.name = "point01";
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite1.addChild(trianglePoint);
            trianglePoint.name = "point02";
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite2.addChild(trianglePoint);
            trianglePoint.name = "point03";
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite2.addChild(trianglePoint);
            trianglePoint.name = "point04";
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite2.addChild(trianglePoint);
            trianglePoint.name = "point05";
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite3.addChild(trianglePoint);
            trianglePoint.name = "point06";
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite3.addChild(trianglePoint);
            trianglePoint.name = "point07";
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite3.addChild(trianglePoint);
            trianglePoint.name = "point08";
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite4.addChild(trianglePoint);
            trianglePoint.name = "point09";
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite4.addChild(trianglePoint);
            trianglePoint.name = "point10";
            trianglePointSpriteArray.push(trianglePoint);
            trianglePoint = new Sprite();
            triangleSprite4.addChild(trianglePoint);
            trianglePoint.name = "point11";
            trianglePointSpriteArray.push(trianglePoint);
            
            
            triangleWindow.addChild(triangleSprite1);
            triangleWindow.addChild(triangleSprite2);
            triangleWindow.addChild(triangleSprite3);
            triangleWindow.addChild(triangleSprite4);
            
            
            settingsMiniButton = new PushButton(this, 465 - 20, 0, "S", onMiniButtonClick);
            settingsMiniButton.width = 20;
            settingsMiniButton.height = 20;
            settingsMiniButton.name = "setting";
            settingsMiniButton.alpha = 0.7;
            settingsMiniButton.visible = false;
            colorMiniButton = new PushButton(this, 465 - 20, 20, "C", onMiniButtonClick);
            colorMiniButton.width = 20;
            colorMiniButton.height = 20;
            colorMiniButton.name = "color";
            colorMiniButton.alpha = 0.7;
            colorMiniButton.visible = false;
            triangleMiniButton = new PushButton(this, 465 - 20, 40, "T", onMiniButtonClick);
            triangleMiniButton.width = 20;
            triangleMiniButton.height = 20;
            triangleMiniButton.name = "triangle";
            triangleMiniButton.alpha = 0.7;
            triangleMiniButton.visible = false;
            flameMiniButton = new PushButton(this, 465 - 20, 60, "F", onMiniButtonClick);
            flameMiniButton.width = 20;
            flameMiniButton.height = 20;
            flameMiniButton.name = "flame";
            flameMiniButton.alpha = 0.7;
            flameMiniButton.visible = false;
            
            
            
            onResetAll();
            
            
            
           
        }
        
        private function onTriangleMouseDown(e:MouseEvent):void
        {
            if (isDragging == false)
            {
                isDragging = true;
                prevDragX = triangleWindow.mouseX;
                prevDragY = triangleWindow.mouseY;
                e.target.startDrag();
                
                e.target.parent.setChildIndex(e.target, e.target.parent.numChildren -  1);
                
            }
        }
        
        private function onTriangleMouseUp(e:MouseEvent):void
        {
            if (isDragging == true)
            {
                isDragging = false;
                
                e.target.stopDrag();
                
                var nowX:Number = triangleWindow.mouseX;
                var nowY:Number = triangleWindow.mouseY;
                var index:int = parseInt(e.target.name.substr(5, 2));
                var type:String = e.target.name.substr(0, 5);
                var i:int, j:int;
                
                if (type == "point")
                {
                    i = index / 3;
                    j = (index % 3) * 2;
                    //redraw triangle
                    table[i][j] += (nowX - prevDragX) / 50;
                    table[i][j + 1] += (nowY - prevDragY) / 50;
                    
                    var triangle:Sprite = triangleSpriteArray[i];
                    triangle.graphics.clear();
                    triangle.graphics.lineStyle(0, triangleColors[i]);
                    triangle.graphics.beginFill(triangleColors[i], 0.5);
                    
                    triangle.graphics.moveTo(table[i][0] * 50 + 110, table[i][1] * 50 + 110);
                    triangle.graphics.lineTo(table[i][2] * 50 + 110, table[i][3] * 50 + 110);
                    triangle.graphics.lineTo(table[i][4] * 50 + 110, table[i][5] * 50 + 110);
                    triangle.graphics.lineTo(table[i][0] * 50 + 110, table[i][1] * 50 + 110);
                    
                    inputTextArray[i * 7 + j].text = table[i][j];
                    inputTextArray[i * 7 + j + 1].text = table[i][j + 1];
                    
                }
                else //type == "plane"
                {
                    i = index;
                    
                    for (j = 0; j < 3; j += 1)
                    {
                        table[i][j * 2] += (nowX - prevDragX) / 50;
                        table[i][j * 2 + 1] += (nowY - prevDragY) / 50;
                        
                        inputTextArray[i * 7 + j * 2].text = table[i][j * 2];
                        inputTextArray[i * 7 + j * 2 + 1].text = table[i][j * 2 + 1];
                    }
                    
                    
                }
                
                onRedraw();
            }
        }
        
        private function drawTriangle():void
        {
            var i:int, j:int;
            var triangle:Sprite;
            var trianglePoint:Sprite;
            
            for (i = 0; i < 4; i += 1)
            {
                triangle = triangleSpriteArray[i];
                triangle.x = 0;
                triangle.y = debugOffset;
                triangle.graphics.clear();
                triangle.graphics.lineStyle(0, triangleColors[i]);
                triangle.graphics.beginFill(triangleColors[i], 0.5);
                
                triangle.graphics.moveTo(table[i][0] * 50 + 110, table[i][1] * 50 + 110);
                triangle.graphics.lineTo(table[i][2] * 50 + 110, table[i][3] * 50 + 110);
                triangle.graphics.lineTo(table[i][4] * 50 + 110, table[i][5] * 50 + 110);
                triangle.graphics.lineTo(table[i][0] * 50 + 110, table[i][1] * 50 + 110);
                
                triangle.graphics.endFill();
                
                for (j = 0; j < 3; j += 1)
                {
                    trianglePoint = trianglePointSpriteArray[i * 3 + j];
                    trianglePoint.x = 0;
                    trianglePoint.y = 0;
                    trianglePoint.graphics.clear();
                    trianglePoint.graphics.beginFill(triangleColors[i]);
                    trianglePoint.graphics.drawCircle(table[i][j * 2] * 50 + 110, table[i][j * 2 +1] * 50 + 110, 5);
                    trianglePoint.graphics.endFill();
                }
                
            }
        }
        
        private function onMiniButtonClick(e:Event):void
        {
            switch(e.target.name)
            {
                case "setting":
                    settingsMiniButton.visible = false;
                    settingWindow.visible = true;
                    break;
                    
                case "color":
                    colorMiniButton.visible = false;
                    colorWindow.visible = true;
                    break;
                    
                case "triangle":
                    triangleMiniButton.visible = false;
                    triangleWindow.visible = true;
                    break;
                    
                case "flame":
                    flameMiniButton.visible = false;
                    flameWindow.visible = true;
                    break;
                    
            }
        }
        
        private function onWindowClose(e:Event):void
        {
            switch(e.target.name)
            {
                case "setting":
                    settingsMiniButton.visible = true;
                    settingWindow.visible = false;
                    break;
                    
                case "color":
                    colorMiniButton.visible = true;
                    colorWindow.visible = false;
                    break;
                    
                case "triangle":
                    triangleMiniButton.visible = true;
                    triangleWindow.visible = false;
                    break;
                    
                case "flame":
                    flameMiniButton.visible = true;
                    flameWindow.visible = false;
                    break;
                    
            }
        }
        
        private function onRandomize(e:Event):void
        {
            var min:int, max:int;
            var i:int;
            var color:uint;
            
            if (colorSelectShapeYellowIndex != colorSelectShapeGreenIndex) //index same -> no gradient..
            {
                if (colorSelectShapeYellowIndex < colorSelectShapeGreenIndex)
                {
                    min = colorSelectShapeYellowIndex;
                    max = colorSelectShapeGreenIndex;
                }
                else
                {
                    min = colorSelectShapeGreenIndex;
                    max = colorSelectShapeYellowIndex;
                }
                
                for (i = min; i < max + 1; i += 1)
                {
                    //randomize - max 20%
                    colorMap[i][1] += Math.random() * colorMap[i][1] * 0.2 - colorMap[i][1] * 0.1;
                    colorMap[i][1] = colorMap[i][1] < 0 ? 0 : ( colorMap[i][1] > 1 ? 1 : colorMap[i][1] );
                    colorMap[i][2] += Math.random() * colorMap[i][2] * 0.2 - colorMap[i][2] * 0.1;
                    colorMap[i][2] = colorMap[i][2] < 0 ? 0 : ( colorMap[i][2] > 1 ? 1 : colorMap[i][2] );
                    colorMap[i][3] += Math.random() * colorMap[i][3] * 0.2 - colorMap[i][3] * 0.1;
                    colorMap[i][3] = colorMap[i][3] < 0 ? 0 : ( colorMap[i][3] > 1 ? 1 : colorMap[i][3] );
                    
                    
                    color = int(colorMap[i][1] * 255) << 16 | int(colorMap[i][2] * 255) << 8 | int(colorMap[i][3] * 255);
                    
                    colorMapShapeArray[i].graphics.beginFill(color);
                    colorMapShapeArray[i].graphics.drawRect(0, 0, 8, 50);
                    colorMapShapeArray[i].graphics.endFill();
                }
                
            }
        }
        
        private function onColorGradient(e:Event):void
        {
            var min:int, max:int;
            var i:int;
            var color:uint;
            
            if (colorSelectShapeYellowIndex != colorSelectShapeGreenIndex) //index same -> no gradient..
            {
                if (colorSelectShapeYellowIndex < colorSelectShapeGreenIndex)
                {
                    min = colorSelectShapeYellowIndex;
                    max = colorSelectShapeGreenIndex;
                }
                else
                {
                    min = colorSelectShapeGreenIndex;
                    max = colorSelectShapeYellowIndex;
                }
                
                
                for (i = min + 1; i < max; i += 1)
                {
                    if (colorMap[min][1] < colorMap[max][1])
                    {
                        colorMap[i][1] = colorMap[min][1] + (i - min) / (max - min) * Math.abs(colorMap[max][1] - colorMap[min][1]);
                    }
                    else
                    {
                        colorMap[i][1] = colorMap[min][1] - (i - min) / (max - min) * Math.abs(colorMap[max][1] - colorMap[min][1]);
                    }
                    
                    if (colorMap[min][2] < colorMap[max][2])
                    {
                        colorMap[i][2] = colorMap[min][2] + (i - min) / (max - min) * Math.abs(colorMap[max][2] - colorMap[min][2]);
                    }
                    else
                    {
                        colorMap[i][2] = colorMap[min][2] - (i - min) / (max - min) * Math.abs(colorMap[max][2] - colorMap[min][2]);
                    }
                    
                    if (colorMap[min][3] < colorMap[max][3])
                    {
                        colorMap[i][3] = colorMap[min][3] + (i - min) / (max - min) * Math.abs(colorMap[max][3] - colorMap[min][3]);
                    }
                    else
                    {
                        colorMap[i][3] = colorMap[min][3] - (i - min) / (max - min) * Math.abs(colorMap[max][3] - colorMap[min][3]);
                    }
                    
                    
                    color = int(colorMap[i][1] * 255) << 16 | int(colorMap[i][2] * 255) << 8 | int(colorMap[i][3] * 255);
                   
                    colorMapShapeArray[i].graphics.beginFill(color);
                    colorMapShapeArray[i].graphics.drawRect(0, 0, 8, 50);
                    colorMapShapeArray[i].graphics.endFill();
                }
                
            }
        }
        
        private function onColorSelectColorChoose(e:Event):void
        {
            var index:int;
            var color:uint = e.target.value;
            
            if (colorSelectYellowRadioButton.selected == true)
            {
                index = colorSelectShapeYellowIndex;
            }
            else
            {
                index = colorSelectShapeGreenIndex;
            }
            
            colorMapShapeArray[index].graphics.beginFill(color);
            colorMapShapeArray[index].graphics.drawRect(0, 0, 8, 50);
            colorMapShapeArray[index].graphics.endFill();
            
            colorMap[index][1] = ((color >> 16) & 0xff) / 255.0;
            colorMap[index][2] = ((color >> 8) & 0xff) / 255.0;
            colorMap[index][3] = (color & 0xff) / 255.0;
        }
        
        private function onColorMapButtonClick(e:Event = null):void
        {
            var index:int = parseInt(e.target.name);
            var color:uint;
            
            if (colorSelectYellowRadioButton.selected == true)
            {
                colorSelectShapeYellowIndex = index;
                colorSelectShapeYellow.x = 10 + colorSelectShapeYellowIndex * 8;
            }
            else
            {
                colorSelectShapeGreenIndex = index;
                colorSelectShapeGreen.x = 10 + colorSelectShapeGreenIndex * 8;
            }
            
            color = int(colorMap[index][1] * 255) << 16 | int(colorMap[index][2] * 255) << 8 | int(colorMap[index][3] * 255);
            colorSelectColorChooser.value = color;
        }
        
        private function onAntiAliasing(e:Event = null):void
        {
            if (hasEventListener(Event.ENTER_FRAME) == true)
            {
                removeEventListener(Event.ENTER_FRAME, onLoop);
                drawMoreButton.selected = false;
            }
            
            
            
            var i:int, j:int;
            var r:int, g:int, b:int, a:int;
            var color:uint;
            var colorNum:int;
            
            antiBitmapData.lock();
            _bitmapData.lock();
            
            for (i = 0; i < 465; i += 1)
            {
                for (j = 0; j < 465; j += 1)
                {
                    color = _bitmapData.getPixel32(i, j);
                    
                    a = color >> 24 & 0xff;
                    r = color >> 16 & 0xff;
                    g = color >> 8 & 0xff;
                    b = color & 0xff;
                    colorNum = 1;
                    
                    if (i > 0)
                    {
                        color = _bitmapData.getPixel32(i - 1, j);
                        a += color >> 24 & 0xff;
                        r += color >> 16 & 0xff;
                        g += color >> 8 & 0xff;
                        b += color & 0xff;
                        
                        colorNum += 1;
                    }
                    if (i < 464)
                    {
                        color = _bitmapData.getPixel32(i + 1, j);
                        a += color >> 24 & 0xff;
                        r += color >> 16 & 0xff;
                        g += color >> 8 & 0xff;
                        b += color & 0xff;
                        
                        colorNum += 1;
                    }
                    if (j > 0)
                    {
                        color = _bitmapData.getPixel32(i, j - 1);
                        a += color >> 24 & 0xff;
                        r += color >> 16 & 0xff;
                        g += color >> 8 & 0xff;
                        b += color & 0xff;
                        
                        colorNum += 1;
                    }
                    if (j < 464)
                    {
                        color = _bitmapData.getPixel32(i, j + 1);
                        a += color >> 24 & 0xff;
                        r += color >> 16 & 0xff;
                        g += color >> 8 & 0xff;
                        b += color & 0xff;
                        
                        colorNum += 1;
                    }
                    
                    r /= colorNum;
                    g /= colorNum;
                    b /= colorNum;
                    a /= colorNum;
                    
                    color = a << 24 | r << 16 | g << 8 | b;
                    //color = r << 16 | g << 8 | b;
                    
                    antiBitmapData.setPixel32(i, j, color);
                    //antiBitmapData.setPixel(i, j, color);
                }
            }
            
            _bitmapData.unlock();
            antiBitmapData.unlock();
            
            _bitmapData.draw(antiBitmapData);
            
        }
        
        private function onDrawMore(e:Event):void
        {
            if (e.target.selected == true)
            {
                addEventListener(Event.ENTER_FRAME, onLoop);
            }
            else
            {
                removeEventListener(Event.ENTER_FRAME, onLoop);
            }
        }
        
        private function drawIter(iterFrame:int):void
        {
            var i:int;
            
            var t:int;
            var px:int, py:int;
            var r:Number;
            var theta:Number;
            var color:Number = Math.random();
            var p0:Number, p1:Number; // for 12-Ex
            var omega:Number; // for 13-Julia
            
            for (i = 0; i < iterFrame; i += 1) //note! iter -> oneFrameIter
            {
                t = getRandomTransform();
                
                npx = cpx * table[t][0] + cpy * table[t][1] + table[t][4];
                npy = cpx * table[t][2] + cpy * table[t][3] + table[t][5];
                color = (color * table[t][0] + color * table[t][1] + table[t][4] + color * table[t][2] + color * table[t][3] + table[t][5]) / 2;
                
                
                switch(flameType[t])
                {
                    case 0: //linear
                        cpx = npx;
                        cpy = npy;
                        break;
                        
                    case 1: //sinusoidal
                        cpx = Math.sin(npx);
                        cpy = Math.sin(npy);
                        break;
                        
                    case 2: //spherical
                        r = 1 / (npx * npx + npy * npy);
                        cpx = npx * r;
                        cpy = npy * r;
                        break;
                        
                    case 3: //swirl
                        r = npx * npx + npy * npy;
                        cpx = npx * Math.sin(r) - npy * Math.cos(r);
                        cpy = npx * Math.cos(r) - npy * Math.sin(r);
                        break;
                        
                    case 4: //Horseshoe
                        r = 1 / Math.sqrt(npx * npx + npy * npy);
                        cpx = r * (npx - npy) * (npx + npy);
                        cpy = r * 2 * npx * npy;
                        break;
                        
                    case 5: //Polar
                        r = Math.sqrt(npx * npx + npy * npy);
                        cpx = Math.atan2(npy, npx) / Math.PI;
                        cpy = r - 1;
                        break;
                        
                    case 6: //Handkerchief
                        r = Math.sqrt(npx * npx + npy * npy);
                        theta = Math.atan2(npy, npx);
                        cpx = r * Math.sin(theta + r);
                        cpy = r * Math.cos(theta - r);
                        break;
                        
                    case 7: //Heart
                        r = Math.sqrt(npx * npx + npy * npy);
                        theta = Math.atan2(npy, npx);
                        cpx = r * Math.sin(theta * r);
                        cpy = -1 * r * Math.cos(theta * r);
                        break;
                        
                    case 8: //Disc
                        r = Math.sqrt(npx * npx + npy * npy);
                        theta = Math.atan2(npy, npx) / Math.PI;
                        cpx = theta * Math.sin(Math.PI * r);
                        cpy = theta * Math.cos(Math.PI * r);
                        break;
                        
                    case 9: //Spiral
                        r = Math.sqrt(npx * npx + npy * npy);
                        theta = Math.atan2(npy, npx);
                        cpx = 1 / r * (Math.cos(theta) + Math.sin(r));
                        cpy = 1 / r * (Math.sin(theta) - Math.cos(r));
                        break;
                        
                    case 10: //Hyperbolic
                        r = Math.sqrt(npx * npx + npy * npy);
                        theta = Math.atan2(npy, npx);
                        cpx = 1 / r * Math.sin(theta);
                        cpy = r * Math.cos(theta);
                        break;
                        
                    case 11: //Diamond
                        r = Math.sqrt(npx * npx + npy * npy);
                        theta = Math.atan2(npy, npx);
                        cpx = Math.sin(theta) * Math.cos(r);
                        cpy = Math.cos(theta) * Math.sin(r);
                        break;
                        
                    case 12: //Ex
                        r = Math.sqrt(npx * npx + npy * npy);
                        theta = Math.atan2(npy, npx);
                        p0 = Math.sin(theta + r);
                        p0 = p0 * p0 * p0;
                        p1 = Math.cos(theta - r);
                        p1 = p1 * p1 * p1;
                        cpx = r * (p0 + p1);
                        cpy = r * (p0 - p1);
                        break;
                        
                    case 13: //Julia
                        r = Math.sqrt(Math.sqrt(npx * npx + npy * npy));
                        theta = Math.atan2(npy, npx);
                        omega = Math.random() < 0.5 ? 0 : Math.PI;
                        cpx = r * Math.cos(theta / 2 + omega);
                        cpy = r * Math.sin(theta / 2 + omega);
                        break;
                        
                    case 14: //Fisheye (originally 16)
                        r = 2 / (Math.sqrt(Math.sqrt(npx * npx + npy * npy)) + 1);
                        cpx = r * npy;
                        cpy = r * npx;                        
                        break;
                        
                    case 15: //Eyefish (originally 27)
                        r = 2 / (Math.sqrt(Math.sqrt(npx * npx + npy * npy)) + 1);
                        cpx = r * npx;
                        cpy = r * npy;                        
                        break;
                        
                    case 16: //Bubble (originally 28)
                        r = 4 / (npx * npx + npy * npy + 4);
                        cpx = r * npx;
                        cpy = r * npy;
                        break;
                    
                }
                
                
                
                px = cpx * magnitude + 465 / 2;
                py = cpy * magnitude + 465 / 2;
                
                if (px >= 0 && px < 465 && py >= 0 && py < 465)
                {
                    points[px][py] += 1;
                    colors[px][py] = (colors[px][py] + color) / 2;
                }
               
            }
        }
        
        private function onLoop(e:Event):void
        {
            
            drawIter(oneFrameIter);
            
            
            drawPointVector();
            
            nowIter += oneFrameIter;
            nowIterLabel.text = "Now Iter: " + String(nowIter);
        }
        
        private function onChangeFlameType(e:Event):void
        {
            flameType[parseInt(e.target.name)] = e.target.selectedIndex;
            //trace(flameType);
        }
        
        private function onChangeIter(e:Event = null):void
        {
            iter = parseInt(e.target.text);
        }
        
        private function onRedraw(e:Event = null):void
        {
            _bitmapData.fillRect(_bitmapData.rect, 0x00ffffff);
            
            cpx = Math.random();
            cpy = Math.random();
            
            var i:int;
             //initialize points Vector
            for (i = 0; i < 465; i += 1)
            {
                points[i] = new Vector.<Number>(465);
                colors[i] = new Vector.<Number>(465);
            }
            
            
            var t:int;
            
            for (i = 0; i < 50; i += 1) //first 50 points are discarded
            {
                t = getRandomTransform();
                
                npx = cpx * table[t][0] + cpy * table[t][1] + table[t][4];
                npy = cpx * table[t][2] + cpy * table[t][3] + table[t][5];
                
                cpx = npx;
                cpy = npy;
                
            }
            
            drawIter(iter);
            
            drawPointVector();
            
            nowIter = iter;
            nowIterLabel.text = "Now Iter: " + String(nowIter);
        }
        
        private function resetFlameType():void
        {
            var i:int;
            
            for (i = 0; i < 4; i += 1)
            {
                flameType[i] = Math.random() * flameTypeArray.length;
                flameTypeComboBoxArray[i].selectedIndex = flameType[i];
            }
        }
        
        private function resetTable():void
        {
            // init Table
            var i:int, j:int;
            var sum:Number = 1;
            var rand:Number;
            for (i = 0; i < table.length; i += 1)
            {
                for (j = 0; j < 6; j += 1)
                {
                    table[i][j] = Math.random() * 2 - 1;
                    inputTextArray[i * 7 + j].text = table[i][j];
                }
                
                rand = Math.random() * sum;
                if (sum - rand < 0)
                {
                    table[i][6] = sum;
                    sum = 0;
                }
                else
                {
                    table[i][6] = rand;
                    sum -= rand;
                }
                
                inputTextArray[i * 7 + 6].text = table[i][j];
                
                //trace(table[i]);
            }
        }
        
        private function onResetAll(e:Event = null):void
        {
            
            
            resetFlameType();
            
            resetTable();
            
            onRedraw();
            
            drawTriangle();
            
            nowIter = iter;
            nowIterLabel.text = "Now Iter: " + String(nowIter);
        }
        
        private function drawPointVector():void
        {
            var i:int;
            var j:int;
            
            var max:Number = -int.MAX_VALUE;
            var min:Number = int.MAX_VALUE;
            var color:uint;
            //var oneColor:uint;
            var scalar:Number;
            var s:int;
            var r:uint;
            var g:uint;
            var b:uint;
            var len:int;
            
            for (i = 0; i < 465; i += 1)
            {
                for (j = 0; j < 465; j += 1)
                {
                    //points[i][j] = (points[i][j] != 0 ? Math.log(points[i][j]) : 0);
                    points[i][j] = (points[i][j] > 0 ? Math.log(points[i][j]) : 0);
                    //if (max < points[i][j])
                    //{
                        //max = points[i][j];
                    //}
                    if (max < colors[i][j])
                    {
                        max = colors[i][j];
                    }
                    if (min > colors[i][j])
                    {
                        min = colors[i][j];
                    }
                }
            }
            //trace(max, min);
            _bitmapData.lock();
            
            len = colorMap.length;
            
            for (i = 0; i < 465; i += 1)
            {
                for (j = 0; j < 465; j += 1)
                {
                    if (points[i][j] != 0)
                    {
                        //oneColor = 255 * points[i][j] / max;
                        //color = oneColor << 16 | oneColor << 8 | oneColor;
                        
                        //scalar = points[i][j] / max * 1.0;
                        scalar = (colors[i][j]-min) / (max-min) * 1.0;
                        for (s = 0; s < len; s += 1)
                        {
                            if (colorMap[s][0] > scalar)
                            {
                                break;
                            }
                        }
                        
                        s -= 1;
                        //trace(s);
                        r = Math.pow(colorMap[s][1], 1/gamma) * 255;
                        g = Math.pow(colorMap[s][2], 1/gamma) * 255;
                        b = Math.pow(colorMap[s][3], 1/gamma) * 255;
                        
                        
                        //r = (points[i][j] / max * Math.abs(colorMap[0][0] - colorMap[1][0]) + colorMap[0][0]) * 255;
                        //g = (points[i][j] / max * Math.abs(colorMap[0][1] - colorMap[1][1]) + colorMap[0][1]) * 255;
                        //b = (points[i][j] / max * Math.abs(colorMap[0][2] - colorMap[1][2]) + colorMap[0][2]) * 255;
                        
                        color = r << 16 | g << 8 | b;
                        colT.color = color;
                        
                        mat = new Matrix();
                        mat.translate(i, j);
                        
                        _bitmapData.draw(_shape, mat, colT, "add");
                        
                        
                        //_bitmapData.setPixel(i, j, color);
                    }
                }
            }
            
            _bitmapData.unlock();
            
        }
        
        private function getRandomTransform():int
        {
            var randomNumber:Number = Math.random();
            var i:int;
            var row:Array;
            for (i = 0; i < table.length; i += 1)
            {
                if (randomNumber <= table[i][6])
                {
                    return i;
                }
                
                randomNumber -= table[i][6];
            }
            
            return table.length - 1;
        }
    }
}