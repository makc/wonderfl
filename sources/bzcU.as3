package

{

	import flash.display.Bitmap;

	import flash.display.BitmapData;

	import flash.display.PixelSnapping;

	import flash.display.Sprite;

	import flash.display.StageAlign;

	import flash.display.StageQuality;

	import flash.display.StageScaleMode;
	import flash.display.Graphics;

	import flash.events.Event;
	import flash.events.KeyboardEvent;

	import flash.geom.ColorTransform;

	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import com.bit101.components.Label;

	

	public class KatamaruOrNot extends Sprite

	{
		private static const ZERO:Point = new Point(0, 0);
		
		private static const STATE_INPUT:uint = 0;
		private static const STATE_SHOT:uint = 1;
		private static const STATE_GAMEOVER:uint = 2;
		
		public function KatamaruOrNot()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.LOW;
			
			var sw:Number = stage.stageWidth;
			var sh:Number = stage.stageHeight;
			
			_ballBackground = new Sprite();
			
			_ballBackground.x = sw / 2;
			_ballBackground.y = sh / 2 - 80;
			
			_ballBackground.graphics.clear();
			_ballBackground.graphics.lineStyle(0, 0xcccccc);
			_ballBackground.graphics.drawCircle(0, 0, 100);
			
			addChild(_ballBackground);
			
			_ballLayer = new Sprite();
			_ballLayer.x = sw / 2;
			_ballLayer.y = sh / 2 - 80;
			
			addChild(_ballLayer);
			
			_shotLayer = new Sprite();
			
			addChild(_shotLayer);
			
			_particleLayer = new Sprite();
			
			addChild(_particleLayer);
			
			_ballsBitmapData = new BitmapData(sw, sh, true, 0x00000000);
			_ballsBitmapData.lock();
			
			_shotBitmapData = new BitmapData(sw, sh, true, 0x00000000);
			_shotBitmapData.lock();
			
			_ballsBitmapDataMatrix = new Matrix();
			
			_scoreField = new Label(this, 5, 3);
			
			_titleField = new Label(this, 0, 3, 'KATAMARU? OR NOT');
			_titleField.autoSize = true;
			
			new Label(this, 5, (sh - (21 + 14 * 3)), '[SPACEKEY]: SHOOT');
			new Label(this, 5, (sh - (21 + 14 * 2)), 'KATAMATTA: +20');
			new Label(this, 5, (sh - (21 + 14 * 1)), 'KATAMARANAI: -10');
			new Label(this, 5, (sh - (21 + 14 * 0)), 'HAMIDETA: GAMEOVER');
			
			startGame();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			addEventListener(Event.ENTER_FRAME, initialEnterFrameHandler);
		}
		
		private var _ballBackground:Sprite;
		private var _ballLayer:Sprite;
		private var _shotLayer:Sprite;
		private var _particleLayer:Sprite;
		
		private var _scoreField:Label;
		private var _titleField:Label;
		
		private var _shotBall:KatamariBall;
		
		private var _ballsBitmapData:BitmapData;
		private var _shotBitmapData:BitmapData;
		
		private var _ballsBitmapDataMatrix:Matrix;
		
		private var _shotAngle:Number;
		private var _shotAngleCounter:Number;
		
		private var _particles:Array = [];
		
		private var _isSpaceDown:Boolean = false;
		
		private var _nowState:uint;
		
		private var _score:int;
		
		private function initialEnterFrameHandler(e:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, initialEnterFrameHandler);
			
			_titleField.x = stage.stageWidth - (_titleField.width + 5);
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function startGame():void
		{
			while (_ballLayer.numChildren > 0) {
				_ballLayer.removeChild(_ballLayer.getChildAt(0));
			}
			
			_ballLayer.addChild(new KatamariBall(40));
			
			_shotBall = null;
			
			_score = 0;
			
			startInput();
		}
		
		private function startInput():void
		{
			_nowState = STATE_INPUT;
			
			_shotAngleCounter = 0;
			
			_shotBall = new KatamariBall();
			_shotBall.x = stage.stageWidth / 2;
			_shotBall.y = stage.stageHeight - 30;
			
			_shotLayer.addChild(_shotBall);
		}
		
		private function keyDownHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.SPACE) {
				_isSpaceDown = true;
			}
		}
		
		private function keyUpHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.SPACE) {
				_isSpaceDown = false;
			}
		}
		
		private function enterFrameHandler(e:Event):void
		{
			updateParticles();
			
			if (_nowState == STATE_GAMEOVER) {
				
				_scoreField.text = 'GAMEOVER: ' + _score;
				
				if (_isSpaceDown) {
					_isSpaceDown = false;
					startGame();
				}
				return;
			}
			
			_ballLayer.rotation += 2;
			_ballBackground.rotation = _ballLayer.rotation;
			
			if (_nowState == STATE_INPUT) {
				
				var bx:Number = stage.stageWidth / 2;
				var by:Number = stage.stageHeight;
				
				_shotAngle = (150 - Math.sin(_shotAngleCounter) * 120) / 360 * Math.PI;
				_shotAngleCounter += Math.PI / 60;
				
				_shotBall.x = bx + Math.cos(_shotAngle) * 50;
				_shotBall.y = by - Math.sin(_shotAngle) * 50;
				
				_shotLayer.graphics.clear();
				_shotLayer.graphics.lineStyle(0, 0xcccccc);
				_shotLayer.graphics.drawCircle(bx, by, 50);
				_shotLayer.graphics.lineStyle(0, 0x333333);
				_shotLayer.graphics.moveTo(bx, by);
				_shotLayer.graphics.lineTo(_shotBall.x, _shotBall.y);
				
				if (_isSpaceDown) {
					_nowState = STATE_SHOT;
					
					_shotBall.positionX = _shotBall.x;
					_shotBall.positionY = _shotBall.y;
					_shotBall.velocityX = Math.cos(_shotAngle) * 18;
					_shotBall.velocityY = Math.sin(_shotAngle) * -18;
				}
			}
			if (_nowState == STATE_SHOT) {
				
				moveBall(_shotBall);
				
				_ballsBitmapDataMatrix.identity();
				_ballsBitmapDataMatrix.rotate(_ballLayer.rotation / 360 * Math.PI * 2);
				_ballsBitmapDataMatrix.translate(_ballLayer.x, _ballLayer.y);
				
				_ballsBitmapData.fillRect(_ballsBitmapData.rect, 0x00000000);
				_ballsBitmapData.draw(_ballLayer, _ballsBitmapDataMatrix);
				
				_shotBitmapData.fillRect(_shotBitmapData.rect, 0x00000000);
				_shotBitmapData.draw(_shotLayer);
				
				if (_ballsBitmapData.hitTest(ZERO, 128, _shotBitmapData, ZERO, 128)) {
					
					_shotLayer.removeChild(_shotBall);
					
					var p:Point = _ballLayer.globalToLocal(new Point(_shotBall.x, _shotBall.y));
					_shotBall.x = p.x;
					_shotBall.y = p.y;
					_ballLayer.addChild(_shotBall);
					
					var l:Number = Math.sqrt(p.x * p.x + p.y * p.y);
					
					for (var i:uint = 0; i < 4; ++i) {
						var particle:KatamariBall = new KatamariBall(2 + Math.random() * 3, _shotBall.color + 30 + 360 / 4 * i);
						var ppos:Point = _ballLayer.localToGlobal(new Point(p.x * ((l - 10) / l), p.y * ((l - 10) / l)));
						particle.positionX = ppos.x;
						particle.positionY = ppos.y;
						particle.velocityX = (Math.random() * 16 + 2) - 9;
						particle.velocityY = Math.random() * -9 - 4;
						_particleLayer.addChild(particle);
						_particles.push(particle);
					}
					
					_score += 20;
					
					if (l > 90) {
						_nowState = STATE_GAMEOVER;
						_isSpaceDown = false;
					}
					else {
						startInput();
					}
				}
				if (_shotBall != null && isOut(_shotBall)) {
					_shotLayer.removeChild(_shotBall);
					_shotBall = null;
					
					_score -= 10;
					
					startInput();
				}
			}
			
			_scoreField.text = 'SCORE: ' + _score;
		}
		
		private function updateParticles():void
		{
			for (var i:int = 0; i < _particles.length; ++i) {
				var particle:KatamariBall = _particles[i] as KatamariBall;
				moveBall(particle);
				if (isOut(particle)) {
					_particleLayer.removeChild(particle);
					_particles.splice(i, 1);
					--i;
				}
			}
		}
		
		private function moveBall(ball:KatamariBall):void
		{
			ball.positionX += ball.velocityX;
			ball.positionY += ball.velocityY;
			ball.velocityY += 0.45;
			
			ball.x = ball.positionX;
			ball.y = ball.positionY;
		} 
		
		private function isOut(ball:KatamariBall):Boolean
		{
			return ball.positionX < -30 || ball.positionX > stage.stageWidth + 30 || ball.positionY < -30 || ball.positionY > stage.stageHeight + 30;
		}
	}

}

import flash.display.Sprite;
import flash.display.Graphics;
import frocessing.color.ColorHSV;



class KatamariBall extends Sprite
{
	public function KatamariBall(size:Number = 20, color:Number = NaN)
	{
		var g:Graphics = graphics;
		var radius:Number = size;
		var d:Number = size / 5;
		var resolution:Number = 10;
		
		if (isNaN(color)) {
			color = Math.random() * 360;
		}
		
		_color = color;
		
		g.clear();
		g.beginFill(new ColorHSV(color, 0.8, 1.0).value);
		g.moveTo(Math.cos(0) * radius, Math.sin(0) * radius);
		for (var i:uint = 1; i < resolution; ++i) {
			var angle:Number = Math.PI * 2 / resolution * i;
			var r:Number = radius + (Math.random() * d - d / 2);
			g.lineTo(Math.cos(angle) * r, Math.sin(angle) * r);
		}
		g.endFill();
		
		cacheAsBitmap = true;
		blendMode = 'multiply';
	}
	
	private var _color:Number;
	
	public var positionX:Number = 0;
	public var positionY:Number = 0;
	public var velocityX:Number = 0;
	public var velocityY:Number = 0;
	
	public function get color():uint
	{
		return _color;
	}
}

