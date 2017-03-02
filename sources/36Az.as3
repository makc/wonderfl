package {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;
    
    import com.adobe.serialization.json.JSON;
    
    public class FlashTest extends Sprite {
        public function FlashTest() {
            var loader:URLLoader = new URLLoader();
            var req:URLRequest = new URLRequest("http://api.face.com/faces/detect.format");
            req.data = new URLVariables();
            req.data.api_key = "55d5d7d310d7cb2b2843e744dcdb58a1";
            req.data.urls = "http://www.100xr.com/100_XR/Artists/B/Bloc_Party/Bloc.Party-band-2005.jpg";
            req.data.api_secret = "2031d04ebb227a11ebf3187379383560";
            loader.addEventListener(Event.COMPLETE,completeHandler );
            loader.load(req);
        }
        
        
        private function completeHandler(e:Event):void{
            var loader:URLLoader = e.target as URLLoader;
            /*
            var text:TextField = new TextField();
            text.width = text.height = 465;
            addChild(text);
            text.text = loader.data.split(",").join(",\n");
            */
            
            data = JSON.decode(loader.data);
            var img:Loader = new Loader();
            img.contentLoaderInfo.addEventListener(Event.COMPLETE, loadedImageHandler );
            img.load(new URLRequest(data.photos[0].url));
            addChild(img);
            
            
            var canvas:Shape = new Shape();
            addChild(canvas);
            
            _photoWidth = data.photos[0].width;
            _photoheight = data.photos[0].height;
            
            var tags:Array = data.photos[0].tags;
            for( var i:int=0; i< tags.length; ++i ){
            var tag:Object= tags[i];
            
            drawPoint( canvas.graphics, getPoint(tag.center), 0xFF0000, 1 );
            drawPoint( canvas.graphics, getPoint(tag.eye_left), 0xFFFFFF, 3 );
            drawPoint( canvas.graphics, getPoint(tag.eye_right), 0xFFFFFF, 3 );
            drawPoint( canvas.graphics, getPoint(tag.eye_left), 0x00, 1 );
            drawPoint( canvas.graphics, getPoint(tag.eye_right), 0x00, 1 );
            drawPoint( canvas.graphics, getPoint(tag.nose), 0xFF0000, 4 );
            
            var mouth:Vector.<Point> = new Vector.<Point>();
            mouth.push( getPoint(tag.mouth_left), getPoint(tag.mouth_center), getPoint(tag.mouth_right) );
            drawLines( canvas.graphics, mouth, 0xFF00 );
            }
        }
        
        private var _photoWidth :Number;
        private var _photoheight:Number;
            
        private function drawPoint(g:Graphics, p:Point, color:uint, radius:Number = 2 ):void{
            g.lineStyle(undefined);
            g.beginFill(color);
            g.drawCircle( p.x, p.y, radius);
            g.endFill();
        }
        
        private function drawLines( g:Graphics, points:Vector.<Point>, color:uint ):void{
            g.lineStyle(0, color );
            g.moveTo(points[0].x, points[0].y);
            for each( var p:Point in points ) {
                g.lineTo(p.x,p.y);
            }
        }
        
        private function getPoint( p:Object ):Point{
            return new Point( p.x*0.01*_photoWidth, p.y*0.01*_photoheight);
        }
        private var data:Object;
        private function loadedImageHandler(e:Event):void{
            
            
        }
    }
}