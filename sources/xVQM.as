/**
 * @author shujita
 */
package  {
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.utils.getTimer;
    public class TileClone extends Sprite{
        //------- CONST ------------------------------------------------------------
        //------- MEMBER -----------------------------------------------------------
        private var _bmdSource:BitmapData;
        private var _bmdTarget:BitmapData;
        private var _bmWidth:int;
        private var _bmHeight:int;
        //------- PUBLIC -----------------------------------------------------------
        public function TileClone() {
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener( Event.COMPLETE, _onLoader1Complete, false, 0, true );
            loader.load( new URLRequest( "http://farm5.static.flickr.com/4042/5075118395_56a727ec1c_z.jpg" ), new LoaderContext( true ) );
        }
        //--------------------------------------
        //  
        //--------------------------------------
        //------- PRIVATE ----------------------------------------------------------
        private function _onLoader1Complete( event:Event ):void {
            var bm:Bitmap = Bitmap( LoaderInfo( event.currentTarget ).content );
            
            _bmWidth = bm.width;
            _bmHeight = bm.height;
            
            _bmdSource = new BitmapData( _bmWidth, _bmHeight );
            _bmdSource.draw( bm );
            
            addChild( new Bitmap( _bmdSource ) );
            
            addEventListener( Event.ENTER_FRAME, _onEnterFrame );
        }
        
        private function _onEnterFrame( event:Event ):void {
            _bmdSource.lock();
            _bmdTarget = _bmdSource.clone()
            const LENGTH:uint = 10;
            for ( var idx:int = 0; idx < LENGTH; idx++ ) {
                var sizeX:int = 10 + 400 * Math.random();
                var sizeY:int = 10 + 400 * Math.random();
                var diff:int = 2 + 40 * Math.random();
                
                var targetX:int = Math.random() * ( _bmWidth -  sizeX );
                var targetY:int = Math.random() * ( _bmHeight -  sizeY );
                var nextX:int = targetX + Math.random() * diff - ( diff / 2 );
                var nextY:int = targetY + Math.random() * diff - ( diff / 2 );
                
                _bmdSource.copyPixels( _bmdTarget, new Rectangle( targetX, targetY,  sizeX, sizeY ), new Point( nextX, nextY ) );
            }
            _bmdSource.unlock();
        }
        //------- PROTECTED --------------------------------------------------------
        //------- INTERNAL ---------------------------------------------------------
        
    }
}