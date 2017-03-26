// forked from mex's 【AS100本ノック】10回目：爆破
/* 
 * AS100本ノック
 * 10回目のお題は「爆破」
 * あなたなりの「爆破」を表現してください。
 * 
 * 左クリックしたまま、画面上を動かしてみてください。
 * トッ○をねらえとかマ○ロスとかガ○ダムとかに出てきそうな爆発をイメージしますた
 * バス○ービームも作りたかった
 */
package {
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;

	public class Explosion extends Sprite {
		
		private const STAGE_WIDTH:uint = 465, STAGE_HEIGHT:uint = 465;
		private var _bg:Sprite, _hitArea:Sprite, _bomb:Bomb, _isFire:Boolean , _time:uint , _prevTime:uint;
		private var _stageWidht:Number , _stageHeight:Number;

		public function Explosion() {
			if ( stage ) init();
			else addEventListener(Event.ADDED_TO_STAGE, init );
		}

		private function init( e:Event = null ):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.BEST;
			_isFire = false;
			_prevTime = 0;
			_stageWidht = stage.stageWidth;
			_stageHeight = stage.stageHeight;
			Wonderfl.capture_delay( 2 );
			
			addBackground();
			addMouseHitArea();
			_bg.addChild( _bomb = new Bomb() );
			setMouseEvent();
		}
		
		private function addBackground():void
		{
			var g:Graphics;
			addChild( _bg = new Sprite() );
			g = _bg.graphics;
			g.beginFill( 0x000000 );
			g.drawRect( 0 , 0 , _stageWidht , _stageHeight );
			g.endFill();
		}
		
		private function addMouseHitArea():void
		{
			var g:Graphics;
			addChild( _hitArea = new Sprite() );
			_hitArea.buttonMode = true;
			g = _hitArea.graphics;
			g.beginFill( 0x000000 , 0 );
			g.drawRect( 0 , 0 , _stageWidht , _stageHeight );
			g.endFill();
		}
		
		private function setMouseEvent():void
		{
			_hitArea.addEventListener( MouseEvent.MOUSE_DOWN , MouseDownHandler , false , 0 , true );
			_hitArea.addEventListener( MouseEvent.MOUSE_UP , MouseUpHandler , false , 0 , true );
			_hitArea.addEventListener( MouseEvent.MOUSE_MOVE , MouseMoveHandler , false , 0 , true );
			_hitArea.addEventListener( MouseEvent.MOUSE_OUT , MouseOutHandler , false , 0 , true );
		}
		
		private function MouseDownHandler( $evt:MouseEvent ):void
		{
			_isFire = true;
			_prevTime = getTimer();
			_bomb.fire( _bg.mouseX , _bg.mouseY );
		}
		private function MouseUpHandler( $evt:MouseEvent ):void
		{
			_isFire = false;
		}
		
		private function MouseOutHandler($evt:MouseEvent):void
		{
			_isFire = false;
		}
		
		
		private function MouseMoveHandler( $evt:MouseEvent ):void
		{
			_time = getTimer();
			if (_isFire &&  _time - _prevTime > 50 )
			{
				_prevTime = _time;
				_bomb.fire( _bg.mouseX , _bg.mouseY );
			}
		}
	}
}



import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import org.libspark.betweenas3.BetweenAS3;
import org.libspark.betweenas3.tweens.IObjectTween;
import org.libspark.betweenas3.events.TweenEvent;
import org.libspark.betweenas3.easing.*;
import org.libspark.betweenas3.tweens.ITween;

class Bomb extends Sprite
{
	private const RADIUS:uint = 40 , SEED_MAX_COUNT:uint = 10, BMP_NAME:String = "SEED";
	private var _seedsData:Array;

	public function Bomb():void
	{
		init();
	}
	
	private function init():void
	{
		makeSeedsData();
	}
	
	private function makeSeedsData():void
	{
		var i:uint;
		
		_seedsData = new Array();

		for ( i = 0; i < SEED_MAX_COUNT; i++ )
		{
			_seedsData.push( makeSeed() );
		}
	}
	
	private function makeSeed():Bitmap
	{
		var seed:Shape, g:Graphics , blur:uint , bd:BitmapData , size:Number, bf:BlurFilter, gf:GlowFilter;

		bf = new BlurFilter( 8 , 8 , 1 );
		blur = 2 << ( Math.round( Math.random() * 7 ) );
		gf = new GlowFilter( 0xFF5555 , 0.9 , blur , blur , 4 , 4 );

		seed = new Shape();
		g = seed.graphics;
		g.beginFill( 0xFFF0FC , 1 );
		g.drawCircle( RADIUS + blur , RADIUS + blur , RADIUS );
		g.endFill();
		seed.filters = [gf , bf];

		size = ( RADIUS << 1 ) + ( blur << 1 );
		bd = new BitmapData( size , size , true , 0x000000 );
		bd.draw( seed );
		return new Bitmap( bd );
	}
	
	public function fire( x:Number , y:Number ):void
	{
		var i:uint , bmp:Bitmap , newBmp:Bitmap , sp:Sprite , angle:Number, baseAngle:uint , r:Number , scale:Number , count:uint;

		count = Math.round( Math.random() * SEED_MAX_COUNT );
		
		baseAngle = Math.round( 360 / count );

		for ( i = 0; i < count; i++ )
		{
			r = ( RADIUS << 1 ) * Math.random();
			scale = Math.random() * 1;

			angle = baseAngle * i;

			newBmp = new Bitmap( Bitmap( _seedsData[i] ).bitmapData.clone() );
			newBmp.x = -newBmp.width >> 1;
			newBmp.y = -newBmp.height >> 1;
			newBmp.name = BMP_NAME;
			sp = new Sprite();
			sp.addChild( newBmp );
			sp.x = r * Math.cos( angle2radian( angle ) ) + x;
			sp.y = r * Math.sin( angle2radian( angle ) ) + y;
			sp.scaleX = sp.scaleY = scale;

			addChild( sp );
			tween( sp , scale * 2 );
		}
	}
	
	private function tween( sp:Sprite , time:Number ):void
	{
		var scale:Number, io:IObjectTween, it:ITween;

		scale = sp.scaleX;
		it = BetweenAS3.serial(
			BetweenAS3.tween( sp , { alpha:1 , scaleX:scale , scaleY:scale } , { scaleX:0 , scaleY:0 } , time , Back.easeInOut )
			, io = BetweenAS3.tween( sp , { alpha:0 } , null , time , Expo.easeOut )
		);
		io.addEventListener( TweenEvent.COMPLETE , tweenEventCompleteHandler , false , 0 , true );
		it.play();
	}
	
	private function tweenEventCompleteHandler( $evt:TweenEvent ):void
	{
		var bmp:Bitmap = Sprite( $evt.target.target ).getChildByName( BMP_NAME ) as Bitmap;
		IObjectTween( $evt.target ).removeEventListener( TweenEvent.COMPLETE , tweenEventCompleteHandler );
		bmp.bitmapData.dispose();
		Sprite( $evt.target.target ).removeChild( bmp );
		removeChild( $evt.target.target );
	}

	private function angle2radian( angle:int ):Number
	{
		return angle * Math.PI / 180;
	}
}
