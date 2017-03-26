package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import flash.text.TextFormat;

    /**
     * ...
     * @author umhr
     */
    [SWF(width = 465, height = 465, backgroundColor = 0x000000, frameRate = 30)]
    public class WonderflMain extends Sprite
    {
        private var _xyzData:Vector.<Number> = new Vector.<Number>();
        private var _colorData:Vector.<int> = new Vector.<int>();
        private var _matrix3D:Matrix3D = new Matrix3D();
        private var _canvas:Bitmap = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000), "auto", true);
        private var _vp:Vector3D = new Vector3D(0, 0, -600);
        private var _domeR:Number = 465 * 0.5;
        private var _mode:int = 0;
        private var _line:Vector.<Number> = new Vector.<Number>();
        private var _lineColorData:Vector.<int> = new Vector.<int>();
        public function WonderflMain():void
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }

        private function init(e:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            
                graphics.beginFill(0x000000);
                graphics.drawRect(0, 0, 465, 465);
                graphics.endFill();
                
            var i:int;
            addChild(_canvas);
            
            var map:BitmapData = new BitmapData(101,101);
            var shape:Shape = new Shape();
            shape.graphics.beginFill(0xFFFFFF);
            shape.graphics.drawRect(0, 0, 101, 101);
            
            for (i = 0; i < 11; i++) {
                shape.graphics.beginFill(0xFF0000);
                shape.graphics.drawRect(0, i * 10, 101, 1);
                shape.graphics.beginFill(0xFF0000);
                shape.graphics.drawRect(i * 10, 0, 1, 101);
            }
            shape.graphics.endFill();
            map.draw(shape);
            
            var textField:TextField = new TextField();
            textField.defaultTextFormat = new TextFormat("_sans", 28, 0x00FFFF);
            textField.text = "ミズタマセイサクショ";
            textField.width = 101;
            textField.height = 101;
            textField.wordWrap = true;
            textField.multiline = true;
            map.draw(textField);
            
            var tx:int;
            var ty:int;
            var h:int = map.height;
            var w:int = map.width;
            for (i = 0; i < w * h; i++) {
                tx = i % w;
                ty = int(i / w);
                _colorData.push(map.getPixel32(tx, ty));
                _xyzData.push((tx - w * 0.5) * 14 + 7);
                _xyzData.push((ty - h * 0.5) * 14 + 7);
                _xyzData.push(0);
            }
            
            //線
            var n:int;
            var m:int = 10;
            for (var j:int = 0; j < m; j++) {
                n = (Math.sin(Math.PI * 0.5 * j / (m - 1))) * _domeR + 2;
                for (i = 0; i < n; i++) {
                    _colorData.push(0xFF00FF00);
                    _line.push(Math.cos(Math.PI * 2 * i / (n - 1)) * (Math.sin(Math.PI * 0.5 * j / (m - 1))) * _domeR);
                    _line.push(Math.sin(Math.PI * 2 * i / (n - 1)) * (Math.sin(Math.PI * 0.5 * j / (m - 1))) * _domeR);
                    _line.push((Math.cos(Math.PI * 0.5 * j / (m-1))) * _domeR +_vp.z + 0.5);
                }
            }
            
            addEventListener(Event.ENTER_FRAME, atEnter);
            stage.addEventListener(MouseEvent.CLICK, click);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, stage_mouseWheel);
        }
        
        private function stage_mouseWheel(event:MouseEvent):void 
        {
            var n:int = _xyzData.length / 3;
            for (var i:int = 0; i < n; i++) {
                _xyzData[i * 3 + 2] += event.delta;
            }
        }
        
        private function click(event:MouseEvent):void 
        {
            _mode ++;
            _mode %= 3;
        }
        private function atEnter(event:Event):void {
            
            var mouseVec:Vector3D = new Vector3D(-stage.mouseY + stage.stageWidth / 2, stage.mouseX - stage.stageHeight / 2);
            mouseVec.normalize();
            _matrix3D.appendRotation(0.5, mouseVec);
            _matrix3D.appendRotation(1, Vector3D.Y_AXIS);
            var xyz:Vector.<Number> = new Vector.<Number>();
            _matrix3D.transformVectors(_xyzData, xyz);
            
            xyz = xyz.concat(_line);
            
            _canvas.bitmapData.lock();
            _canvas.bitmapData.fillRect(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 0x00000000);
            var n:int = xyz.length / 3;
            var r:Number = _domeR;
            var d:Number;
            
            for (var i:int = 0; i < n; i++) {
                var tx:Number = xyz[i * 3];
                var ty:Number = xyz[i * 3 + 1];
                var tz:Number = xyz[i * 3 + 2];
                
                var v3d:Vector3D = new Vector3D(tx, ty, tz);
                
                if (_mode == 0) {
                    // ドームマスター
                    v3d.z -= _vp.z;
                    if (v3d.z <= 0) { continue };
                    if (v3d.length < r) { continue };
                    d = r * Vector3D.angleBetween(Vector3D.Z_AXIS, v3d) / ( Math.PI * 0.5);
                    v3d.z = 0;
                    v3d.normalize();
                    v3d.scaleBy(d);
                }else if (_mode == 1) {
                    // 平行投影
                    v3d.z -= _vp.z;
                    if (v3d.z <= 0) { continue };
                    if (v3d.length < r) { continue };
                    v3d.normalize();
                    v3d.scaleBy(r);
                }else {
                    if (v3d.z - _vp.z <= 0) { continue };
                    d = -_vp.z / (-_vp.z + v3d.z);
                    v3d.x *= d;
                    v3d.y *= d;
                }
                
                _canvas.bitmapData.setPixel32(v3d.x + stage.stageWidth * 0.5, v3d.y + stage.stageHeight * 0.5, _colorData[i]);
                
            }
            
            _canvas.bitmapData.unlock();
        }

    }

}
