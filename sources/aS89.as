/**
 * 3Dのイコライザー。
 * Zソートだとポリゴン欠けが目立ったので、インデックスソートに変更。
 * カメラとの距離で毎フレームインデックスを変更してます。
 * 
 * BGMは http://creativecommons.org/wired/ を使用させていただきました。
 **/
package
{
    import com.bit101.components.Label;
    
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.media.Sound;
    import flash.media.SoundLoaderContext;
    import flash.media.SoundMixer;
    import flash.net.FileReference;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.utils.ByteArray;
    
    import org.libspark.betweenas3.BetweenAS3;
    import org.libspark.betweenas3.tweens.ITween;
    import org.papervision3d.materials.ColorMaterial;
    import org.papervision3d.materials.utils.MaterialsList;
    import org.papervision3d.objects.DisplayObject3D;
    import org.papervision3d.objects.primitives.Cube;
    import org.papervision3d.view.BasicView;
    import org.papervision3d.view.layer.util.ViewportLayerSortMode;
    
    [SWF(frameRate="60")]
    
    public class Equalizer3D extends BasicView
    {
        
        public static const FILE:String = "http://loftimg.jp/wonderfl/files/sound/bgm.mp3";
        
        public static const WIDTH:int = 10;
        public static const HEIGHT:int = 10;
        public static const CHANNEL_LENGTH:int = 512;
        
        public var world:DisplayObject3D = new DisplayObject3D();
        
        private var _bars:Array;
        
        private var _ba:ByteArray;
        private var _colorBar:BitmapData;
        private var _counter:int = 0;
        
        private var _reference:FileReference;
        
        public function Equalizer3D()
        {
            super();
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            //stage.quality = StageQuality.LOW;
            //stage.addChild(new Stats());
            
            var sound:Sound = new Sound();
            sound.addEventListener(Event.COMPLETE, _soundCompleteHandler);
            sound.load(new URLRequest(FILE), new SoundLoaderContext(10000, true));
            
            var label:Label = new Label(stage, 10, stage.stageHeight - 25, "BGM by http://creativecommons.org/wired/");
            label.buttonMode = true;
            label.mouseEnabled = true;
            label.addEventListener(MouseEvent.CLICK, _BGMClickHandler);
            
            _init();
        }
        
        private function _soundCompleteHandler(e:Event):void
        {
            e.target.play(0, int.MAX_VALUE);
        }
        
        private function _init():void
        {
            scene.addChild(world);
            _initEqualizer();
            
            camera.y = 250;
            camera.zoom = 50;
            camera.z = -_camera.focus * _camera.zoom;
            camera.lookAt(DisplayObject3D.ZERO);
            camera.zoom *= 2;
            
            viewport.containerSprite.sortMode = ViewportLayerSortMode.INDEX_SORT;
            
            var t:ITween = BetweenAS3.to(world, {rotationY: 360}, 30);
            t.stopOnComplete = false;
            t.play();
            
            _ba = new ByteArray();
            
            _colorBar = new BitmapData(1, 200, false, 0x0);
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(_colorBar.width, _colorBar.height, 90*Math.PI/180);
            graphics.beginGradientFill(GradientType.LINEAR, [0xe5f5ff, 0x0099ff], [1, 1], [0, 255], matrix);
            graphics.drawRect(0, 0, _colorBar.width, _colorBar.height);
            graphics.endFill();
            _colorBar.draw(this, null, null, null, new Rectangle(0, 0, _colorBar.width, _colorBar.height), false);
            graphics.clear();
            
            startRendering();
            addEventListener(Event.ENTER_FRAME, _enterframeHandler);
        }
        
        private function _initEqualizer():void
        {
            _bars = [];
            var w:Number = 15;
            var d:Number = 15;
            var margin:Number = 5;
            var x:int = 0;
            var z:int = 0;
            var sZ:int = 0;
            var sX:int = 0;
            for(var i:int=0, l:int = WIDTH*HEIGHT; i < l; i++) {
                var h:Number = w*10;
                var material:ColorMaterial = new ColorMaterial(0xCCCCCC, 1, false);
                var materials:MaterialsList = new MaterialsList({all: material});
                var cube:Cube = new Cube(materials, w, d, h, 1, 1, 1, 0, 0);
                var container:DisplayObject3D = new DisplayObject3D();
                container.addChild(cube);
                cube.y = h/2;
                container.x = x * (w+margin) - ((WIDTH-1)*(w+margin))/2;
                container.z = z * (d+margin) - ((HEIGHT-1)*(d+margin))/2;
                world.addChild(container);
                
                _bars[_bars.length] = {do3d: container, material: material};
                
                if(z<=0 || x >= WIDTH-1) {
                    if(sZ < HEIGHT-1) sZ++;
                    else sX++;
                    x = sX;
                    z = sZ;
                } else {
                    x++;
                    z--;
                }
            }
        }
        
        
        private function _enterframeHandler(e:Event):void
        {
            if(!((_counter++)%2)) {
                SoundMixer.computeSpectrum(_ba, true, 0);
                _counter = 1;
            }
            var smooth:Number = 10;
            
            var l:int = WIDTH * HEIGHT;
            var position:Number = 0;
            var step:Number = CHANNEL_LENGTH/(l-1);
            for(var i:int = 0; i < l; i++) {
                var data:Object = _bars[i];
                _ba.position = int(position);
                var value:Number = _ba.readFloat();
                position += step;
                if(isNaN(value)) value = 0;
                else if(value > 1) value = 1;
                else if(value < 0) value = 0;
                var now:Number = data.do3d.scaleY;
                now += (value - now) / smooth;
                data.do3d.scaleY = now;
                var color:Number = _colorBar.getPixel(0,int(now*(_colorBar.height-1)));
                ColorMaterial(data.material).fillColor = color;
                
                viewport.getChildLayer(data.do3d).layerIndex = -calcDistanceFromCamera(data.do3d);//-camera.distanceTo(data.do3d) * 1000;
            }
            _ba.position = 0;
        }
        
        private function calcDistanceFromCamera(obj:DisplayObject3D):Number {
            var dx:Number = obj.sceneX - camera.x;
            var dy:Number = obj.sceneY - camera.y;
            var dz:Number = obj.sceneZ - camera.z;
            return Math.abs(Math.sqrt(dx * dx + dy * dy + dz * dz));
        }
        
        private function _BGMClickHandler(e:Event):void
        {
            navigateToURL(new URLRequest("http://creativecommons.org/wired/"), "_blank");
        }
    }
}