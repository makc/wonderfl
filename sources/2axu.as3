package {
    import flash.net.FileReference;
    import flash.display.Bitmap;
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.display.BitmapData;
    import com.bit101.components.*;
    
    [SWF(width="465",height="465")]
    public class Main extends Sprite {
        public static const IMG_URL:Object = {
            "sample1" : "http://assets.wonderfl.net/images/related_images/3/38/38cf/38cf25451d37d8084facdb4b07dc7dda7c38e52b",
            "sample2" : "http://assets.wonderfl.net/images/related_images/2/2f/2f78/2f78bc94c2a25685fd9bd5bb2fa88ebee089469c"
        };
        public static var imgData:Object;
        public var target:DisplayObject;
        public var result:TextField = new TextField();
        
        function Main():void {
            load();
            addChild( result );
            result.defaultTextFormat = new TextFormat( null, 16, 0xFF3300, true, null, null, null, null, "center" );
            result.text = "loading...";
            result.width = 465;
            result.height = 30;
            result.y = 440;
            
            var g:Graphics = graphics;
            g.beginFill( 0, 1 );
            g.drawRect( 0, 0, 465, 465 );
            
            var combo:ComboBox = new ComboBox( this, 25, 2, "sample1", ["sample1","sample2"]  );
            combo.addEventListener( "select", function _(e:*):void{ analize( imgData[combo.selectedItem] ); } );
            new PushButton( this, 127, 2, "upload", upload );
        }
        
        public function upload( e:Event ):void{
            var ref:FileReference = new FileReference();;
            ref.addEventListener( Event.SELECT, 
                function _(e:*):void {
                    result.text = "loading...";
                    ref.load();
                }
            );
            ref.addEventListener( Event.COMPLETE, 
                function _(e:*):void { 
                    result.text = "";
                    var loader:Loader = new Loader();
                    loader.loadBytes( ref.data, new LoaderContext(false) );
                    loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
                }
            );
            ref.browse();
        }
 
        public function load():void {
            if ( imgData ) { return; }
            imgData = {};
            for ( var name:String in IMG_URL ) {
                var loader:Loader = new Loader();
                loader.load( new URLRequest( IMG_URL[name] ), new LoaderContext(true) );
                imgData[name] = loader;
                if( name == "sample1" ) loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
            }
        }
        
        public function onComplete( e:Event ):void { analize( e.currentTarget.loader ); }
        
        public function analize( d:DisplayObject ):void {
            if (! d ){ return; }
            if ( target ) { removeChild( target ); }
            target = d;
            d.scaleX *= 415 / d.width;
            d.scaleY *= 415 / d.height;
            d.x = d.y = 25;
            addChildAt( target, 0 );
            var w:int = d.width / d.scaleX, h:int = d.height / d.scaleY;
            var bitmapData:BitmapData = new BitmapData( w / 2, h / 2, false, 0 );
            bitmapData.draw( d, new Matrix(1, 0, 0, 1, -w / 4, -h / 4 ) );
            result.text = "Result: " + boke( bitmapData ).toFixed( 3 );
        }
    }
}
import flash.display.BitmapData;
import flash.filters.BlurFilter;
import flash.geom.Point;

//画像のぼやけ度数を出す関数
function boke( target:BitmapData ):Number {
    var value:Number = 0;
    var copy:BitmapData = new BitmapData( target.width, target.height, false ); 
    copy.applyFilter( target, copy.rect, new Point, new BlurFilter( 2 + (target.width / 64), 2 + (target.height / 64) ) );
    copy.draw( target, null, null, "difference" );
    var v:Vector.<uint> = copy.getVector( copy.rect );
    for( var i:int = 0, l:int = v.length; i < l; i++ ) {
        var n1:uint = v[i];
        value += ( ((n1 >>> 16) & 0xFF) >>> 0 ) + ( ((n1 >>>  8) & 0xFF) >>> 0 ) + ( (n1 & 0xFF) >>> 0 );
    }
    return ( l / value ) * 100;
}