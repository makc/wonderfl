package
{
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Ascii extends Sprite 
	{
		
		private var textfield:TextField;
		private var format:TextFormat;
		
		private var cols:int = 20;
		private var rows:int = 20;
		
		private var grid_width:Number = 500;
		private var grid_height:Number = 500;
		
		private var candidates:Vector.<Candidate>;
		private var strokes:Vector.<Stroke>;
		private var strings:Vector.<String>;
		private var stroke:Stroke;
		private var mouseDown:Boolean;
		private var spriteSheet:BitmapData;
		private var characterRect:Rectangle;
		private var tmp:BitmapData;
		private var canvasBitmapData:BitmapData;
		private var output:BitmapData;
		private var canvas:Shape;
		private var font:Font;
		private var isRenderDebug:Boolean;
		
		
		public function Ascii() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			candidates = new Vector.<Candidate>();
			strokes = new Vector.<Stroke>();
			strings = new Vector.<String>();
			
			textfield = new TextField();
			textfield.autoSize = TextFieldAutoSize.LEFT;
			
			spriteSheet = new BitmapData( grid_width, grid_height, true, 0 );
			canvasBitmapData = new BitmapData( grid_width, grid_height, true, 0 );
			output = new BitmapData( grid_width, grid_height, true, 0 );
			
			var out:Bitmap =  new Bitmap( output );
			addChild( out );
			canvas = new Shape();
			addChild( canvas );
			
			reset();
			
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseHandler );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseHandler );
			
			
			var clear:PushButton = new PushButton( this, 10, stage.stageHeight - 30, 'clear', onClear );
			var grid:PushButton = new PushButton( this, 110, stage.stageHeight - 30, 'grid', onDebug );
			
			render();
			
		}
		
		private function onClear(e:Event):void 
		{
			for each (var item:Stroke  in strokes  ) 
			{
				item.dispose();
			}
			strokes.length = 0;
		}
		
		private function onDebug(e:Event):void 
		{
			isRenderDebug = !isRenderDebug ? true : false;
		}
		
		private function onMouseHandler(e:MouseEvent):void 
		{
			
			switch( e.type )
			{
				case MouseEvent.MOUSE_DOWN:
					mouseDown = true;
					stroke = new Stroke();
					strokes.push( stroke );
					break;
					
				case MouseEvent.MOUSE_MOVE:
					if ( mouseDown )
					{
						stroke.add( new Point( mouseX, mouseY ) );
					}
					render();
					break;
					
				case MouseEvent.MOUSE_UP:
					mouseDown = false;
					break;
			}
			canvas.visible = mouseDown;
		}
		
		public function render():void
		{
			
			graphics.clear();
			graphics.beginFill( 0x101010 );
			graphics.drawRect( 0,0, stage.stageWidth, stage.stageHeight );
			graphics.endFill();
			if( isRenderDebug ) renderGrid();
			
			canvas.graphics.clear();
			renderStrokes();
			
			output.fillRect( output.rect, 0 );
			
			renderASCII( cols, rows );
			
		}
		
		private function reset():void 
		{
			
			tmp = new BitmapData( 100, 100, true, 0 );
			
			var fonts:Array = Font.enumerateFonts( true );
			for each (var item:Font in fonts) 
			{
				if ( item.fontName == 'Courier New' )
				{
					font = item;
					break;
				}
			}
			
			format = new TextFormat( font.fontName, 16, 0xFFFFFF );
			
			var str:String = '!"#$%&\'()*+,-./:;<=>?@[\]^_`{|}~¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿×ǀǁǂǃʻʼʽʾʿˀˁ˂˃˄˅ˆˇˈˉˊˋˌˍˎˏːˑ˒˓˔˕˖˗˘˙˚˛˜˝˞˟ˠˡˢˣˤ˥˦˧˨˩˪˫ˬ˭ˮ˯˰˱˲˳˴˵˶˷˸˹˺˻˼˽˾˿̴̵̶̷̸̡̢̧̨̛̖̗̘̙̜̝̞̟̠̣̤̥̦̩̪̫̬̭̮̯̰̱̲̳̹̺̻̼͇͈͉͍͎̀́̂̃̄̅̆̇̈̉̊̋̌̍̎̏̐̑̒̓̔̽̾̿̀́͂̓̈́͆͊͋͌̕̚ͅ͏͓͔͕͖͙͚͐͑͒͗͛҃҄҅҆҇͘͜͟͢͝͞͠͡ՙ՚՛՜՝՞՟ᅡᅢᅣᅤᅥᅦᅧᅨᅩᅪᅫᅬᅭᅮᅯᅰᅱᅲᅳᅴᅵᅶᅷᅸᅹᅺᅻᅼᅽᅾᅿᆀᆁᆂᆃᆄᆅᆆᆇᆈᆉᆊᆋᆌᆍᆎᆏᆐᆑᆒᆓᆔᆕᆖᆗᆘᆙᆚᆛᆜᆝᆞᆟᆠᆡᆢ‐‑‒–—―‖‗‘’‚‛“”„‟†‡•‣․‥…‧‵‶‷‸‹›※‼‽‾‿⁀⁁⁂⁃⁄⁅⁆−∓∔∕∖∗∘∙√∛∜∝∞∟∠∡∢∣∤∥∦∧∨∩∪∫∬∴∵∶∷∸∹∺∻∼∽∾∿≠≡≤≥≦≧≨≩≪≫≬≭≮≯≰≱≲≳≴≵≶≷≸≹≺≻≼≽≾≿⊀⊁⊂⊃⊄⊅⊆⊇⊈⊉⊊⊋⊹⊺⊻⊼⊽⊾⊿⋀⋢⋣⋤⋥⋦⋧⋨⋩⋪⋫⋬⋭⋮⋯✁✂✃✄✅✆✇✈✉✊✋✌✍✎✏';
			var bits:Array = str.split( '' );
			for each ( str in bits ) 
			{
				textfield.text = str;
				textfield.setTextFormat( format );
				tmp.draw( textfield );
				strings.push( str );
			}
			
			characterRect = tmp.getColorBoundsRect( 0xFFFFFFFF, 0, false );
			
			cols = int( grid_width / characterRect.width );
			rows = int( grid_height / characterRect.height );
			
			tmp = new BitmapData( characterRect.width, characterRect.height, true, 0 );
			
			spriteSheet.fillRect( spriteSheet.rect, 0 );
			
			var w:int = grid_width / cols;
			var h:int = grid_height / rows;
			
			var m:Matrix = new Matrix();
			var cf:int = 0, i:int, j:int;
			
			for each ( str in strings ) 
			{
				
				textfield.text = str;
				textfield.setTextFormat( format );
				
				i = int( cf % cols );
				j = int( cf / cols );
				
				m.tx = i * w;
				m.ty = j * h;
				spriteSheet.draw( textfield, m );
				
				tmp.fillRect( tmp.rect, 0 );
				
				m.tx = 0;
				m.ty = 0;
				tmp.draw( textfield, m );
				
				if ( !isBitmapEmpty( tmp ) )
				{
					var c:Candidate = new Candidate( tmp.getColorBoundsRect( 0xFFFFFFFF, 0, false ), candidates.length, str );
					c.compute( characterRect );
					candidates.push( c );
					spriteSheet.copyPixels( tmp, tmp.rect, new Point( i * w, j * h ), null, null, true );
					cf++;
				}
			}
		}
		
		private function isBitmapEmpty(tmp:BitmapData):Boolean 
		{
			for (var i:int = 0; i < tmp.width; i++) 
			{
				for (var j:int = 0; j < tmp.height; j++) 
				{
					if( tmp.getPixel32( i, j ) != 0 ) return false;
				}
			}
			return true;
		}
		
		private function renderASCII( cols:int, rows:int ):void 
		{
			
			canvasBitmapData.fillRect( canvasBitmapData.rect, 0 );
			canvasBitmapData.draw( canvas );
			
			var w:int = grid_width / cols;
			var h:int = grid_height / rows;
			tmp = new BitmapData( w, h, true, 0 );
			
			var rect:Rectangle = characterRect.clone();
			for (var j:int = 0; j < rows; j++) 
			{
				for (var i:int = 0; i < cols; i++) 
				{
					
					rect.x = i * w;
					rect.y = j * h;
					
					tmp.fillRect( tmp.rect, 0 );
					tmp.copyPixels( canvasBitmapData, rect, new Point(), null, null, true );
					
					if ( tmp.threshold( tmp, tmp.rect, new Point(), ">", 0, 0xFFFFFFFF ) )
					{
						
						var r:Rectangle = tmp.getColorBoundsRect( 0xFFFFFFFF, 0, false );
						var id:uint = getClosestRect( characterRect, r, candidates );
						
						r = characterRect.clone();
						r.x += ( candidates[ id ].id % cols ) * w;
						r.y += int( candidates[ id ].id / cols ) * h;
						output.copyPixels( spriteSheet, r, rect.topLeft, null, null, true );
						
					}
				}
			}
		}
		
		private function getClosestRect( frame:Rectangle, rect:Rectangle, list:Vector.<Candidate> ):uint 
		{
			
			var candidate:Candidate = new Candidate( rect, -1 );
			candidate.compute( frame );
			
			var mini:Number = Number.POSITIVE_INFINITY;
			var id:int = -1;
			var score:Number;
			var tmpCandidates:Vector.<Candidate> = new Vector.<Candidate>();
			for (var i:int = 0; i < list.length; i++) 
			{
				score = list[ i ].compare( candidate );
				if ( score < mini )
				{
					mini = score;
					tmpCandidates.push( list[ i ] );
				}
			}
			
			mini = Number.POSITIVE_INFINITY;
			for ( i = 0; i < tmpCandidates.length; i++) 
			{
				score = tmpCandidates[ i ].shapeMatch( candidate );
				if ( score < mini )
				{
					mini = score;
					id = tmpCandidates[ i ].id;
				}
			}
			
			return id;
			
		}
		
		private function renderStrokes():void 
		{
			
			canvas.graphics.lineStyle( 0, 0xFF0000 );
			for each (var item:Stroke in strokes ) 
			{
				item.render( canvas.graphics );
			}
			
		}
		
		private function renderGrid():void 
		{
			var w:int = grid_width / cols;
			var h:int = grid_height / rows;
			
			graphics.lineStyle( 0, 0x333333 );
			
			for (var i:int = 0; i <= cols; i++) 
			{
				for (var j:int = 0; j <= rows; j++) 
				{
					
					graphics.moveTo( i * w, 0 );
					graphics.lineTo( i * w, j * h );
					
					graphics.moveTo( 0, j * h );
					graphics.lineTo( i * w, j * h );
					
				}
			}
		}
	}
}

import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;

class Candidate
{
	public var char:String;
	public var id:int;
	public var r:Rectangle;
	public var indices:Vector.<int>;
	
	public function Candidate( r:Rectangle, id:int, char:String = '' )
	{
		this.r = r;
		this.id = id;
		this.char = char;
	}
	
	public function compute( frame:Rectangle ):void
	{
		var frameCenter:Point = new Point( frame.x + frame.width * .5, frame.y + frame.height * .5 );
		var frameRadius:Number = Math.sqrt( Math.pow( frame.width * .5, 2 ) + Math.pow( frame.height * .5 , 2 ) );
		
		var tl:Point = r.topLeft;
		var tr:Point = new Point( r.right, r.top );
		var br:Point = r.bottomRight;
		var bl:Point = new Point( r.left, r.bottom );
	 
		var corners:Array = [ tl, tr, br, bl ];
		indices = new Vector.<int>();
		for each( var p:Point in corners )
		{
			indices.push( int( map( getAngle( frameCenter, p ), -Math.PI, Math.PI, 0, 360 ) ) );
		}
	}
	
	private function getAngle( p0:Point, p1:Point ):Number
	{
		return Math.atan2( p1.y - p0.y, p1.x - p0.x );
	}
	
	public function compare( other:Candidate ):Number
	{
		var score:Number = 0;
		
		score += Math.abs( indices[ 0 ] - other.indices[ 0 ] );
		score += Math.abs( indices[ 1 ] - other.indices[ 1 ] );
		score += Math.abs( indices[ 2 ] - other.indices[ 2 ] );
		score += Math.abs( indices[ 3 ] - other.indices[ 3 ] );
		
		return score;
	}
	
	public function shapeMatch( other:Candidate ):Number
    {
        
		// contributed by Makc
		// http://wonderfl.net/c/wEW9
		var dx:Number = r.width  - other.r.width;
		var dy:Number = r.height - other.r.height;
		var dd:Number = Point.distance (r.topLeft, r.bottomRight) - Point.distance (other.r.topLeft, other.r.bottomRight);
		return dx * dx + dy * dy + 2 * dd * dd;
		
    }
	
	private function normalize(value:Number, minimum:Number, maximum:Number):Number
	{
		return (value - minimum) / (maximum - minimum);
	}
	private function lerp(normValue:Number, minimum:Number, maximum:Number):Number
	{
		return minimum + (maximum - minimum) * normValue;
	}
	private function map(value:Number, min1:Number, max1:Number, min2:Number, max2:Number):Number
	{
		return lerp( normalize(value, min1, max1), min2, max2);
	}
}
internal class Stroke
{
	private var _points:Vector.<Point>;
	
	public function Stroke()
	{
		points = new Vector.<Point>();
	}
	
	public function add( p:Point ):void
	{
		points.push( p );
	}
	
	public function render( g:Graphics ):void
	{
		if ( points.length == 0 ) return;
		g.moveTo( points[ 0 ].x, points[ 0 ].y );
		for each (var item:Point in points ) 
		{
			g.lineTo( item.x, item.y );
		}
	}
	
	public function dispose():void
	{
		for each (var item:Point in points ) 
		{
			item = null;
		}
		points.length = 0;
		points = null;
	}
	
	public function get points():Vector.<Point>{	return _points;		}
	public function set points(value:Vector.<Point>):void {		_points = value;	}
	
}