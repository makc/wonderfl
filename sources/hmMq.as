// それ Flash でできるよシリーズ。
// http://toffy.exblog.jp/9193407/
// 画面を適当にドラッグ。
package {
    
    import com.bit101.components.HUISlider;
    
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.NetStatusEvent;
    import flash.geom.Point;
    import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.cameras.CameraType;
    import org.papervision3d.materials.VideoStreamMaterial;
    import org.papervision3d.objects.primitives.Sphere;
    import org.papervision3d.view.BasicView;
    
    [SWF(width=465, height=465, backgroundColor=0x0, frameRate=30)]

    public class VRMovie extends BasicView {
        
        private var _video:Video;
        private var _conn:NetConnection;
        private var _stream:NetStream;
        private var _mat:VideoStreamMaterial;
        
        private var _rotX:Number = 0;
        private var _rotY:Number = -90;
        private var _mousePressed:Boolean = false;
        private var _origin:Point = new Point();
        
        public function VRMovie() {
            super(465, 465, false, false, CameraType.FREE);
            var cam:Camera3D = cameraAsCamera3D;
            cam.z = 0;
            cam.fov = 65;
            
            _conn = new NetConnection();
            _conn.connect(null);
            _stream = new NetStream(_conn);
            _stream.client = {};
            _stream.checkPolicyFile = true;
            _stream.addEventListener(NetStatusEvent.NET_STATUS, _onStreamStatus, false, int.MIN_VALUE);
            _video = new Video(320, 240);
            _video.attachNetStream(_stream);
            _stream.play('http://saqoo.sh/a/labs/wonderfl/building.flv');
            _mat = new VideoStreamMaterial(_video, _stream);
            _mat.doubleSided = true;
            _mat.smooth = true;
            var sphere:Sphere = new Sphere(_mat, 100, 32, 16);
            scene.addChild(sphere);
            
            startRendering();
            
            addEventListener(Event.ENTER_FRAME, _update);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
            
            var fov:HUISlider = new HUISlider(this, 5, 0, 'FOV', _onChangeFOV);
            fov.minimum = 10;
            fov.maximum = 180;
            fov.value = camera.fov;
        }
        
        private function _update(e:Event):void {
            if (_mousePressed) {
                _rotX -= (_origin.y - stage.mouseY) * 0.02;
                _rotX = _rotX > 80 ? 80 : (_rotX < -80 ? -80 : _rotX);
                _rotY -= (_origin.x - stage.mouseX) * 0.02;
            }
            
            var cam:Camera3D = cameraAsCamera3D;
            cam.rotationX += (_rotX - cam.rotationX) * 0.3;
            cam.rotationY += (_rotY - cam.rotationY) * 0.3
        }
        
        private function _onMouseDown(e:MouseEvent):void {
            _origin.x = stage.mouseX;
            _origin.y = stage.mouseY;
            _mousePressed = true;
        }
        
        private function _onMouseUp(e:MouseEvent):void {
            _mousePressed = false;
        }
        
        private function _onStreamStatus(e:NetStatusEvent):void {
            if (e.info.code == 'NetStream.Play.Stop') {
                _stream.seek(0);
                _mat.animated = true;
            }
        }
        
        private function _onChangeFOV(e:Event):void {
            cameraAsCamera3D.fov = HUISlider(e.target).value;
        }
    }
}
