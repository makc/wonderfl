// forked from minon's 漫画っぽい集中線
/**
 * ジョジョのディオのあれ
 * @author minon
 */

package {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.getTimer;
    
    [SWF(width="465",height="465",frameRate="60",backgroundColor="0xffffff")]
	
    public class LineTest extends Sprite
    {
        private var _canvas:BitmapData;
        public function LineTest()
        { 
            var loader:Loader = new Loader();
            loader.x = 30;
            loader.y = 30;
            loader.contentLoaderInfo.addEventListener( Event.COMPLETE, _render );
            loader.load( new URLRequest('http://tirirenge.undo.jp/img/zukyun.png'), new LoaderContext(true));
            addChild(loader);
            
            _canvas = new BitmapData( 465, 465, true, 0 );
            addChild( new Bitmap( _canvas ) );
            _drawLine( _canvas );
            
            stage.addEventListener( Event.ENTER_FRAME, _render );
        }
            
        private function _render(e:Event):void
        {
            _canvas.fillRect( new Rectangle( 0, 0, 465, 465 ), 0 );
            _drawLine( _canvas );
        }
            
        public function _drawLine( bmp:BitmapData ):void
        {
            var line:Sprite = new Sprite();
            var g:Graphics = line.graphics
            drawTriangle( g );
            var a:int = 2;
            var len:int = stage.width / 2 * Math.sqrt(2);
            var d:int = 360;
             
            while ( 0 < d )
            {
                var x:Number = Math.sin( d * Math.PI / 180 ) * len + stage.width / 2;
                var y:Number = Math.cos( d * Math.PI / 180 ) * len + stage.height / 2;
                var mtx:Matrix = new Matrix();
                mtx.scale( 5, Math.random() * len + len/2 );
                mtx.rotate( ( -d ) * Math.PI / 180 );
                mtx.translate( x, y );
                bmp.draw( line, mtx );
                d -= Math.round( Math.random() * a );
            }
        }
        public function drawTriangle( g:Graphics ):void
        {
            g.beginFill( 0 );
            g.moveTo( -0.5, 0 );
            g.lineTo( 0.5, 0 );
            g.lineTo( 0, -0.5 );
            g.lineTo( -0.5, 0 );
        }
    }
}