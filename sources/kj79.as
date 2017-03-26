/**
 * Stardust Particle Engine
 * 
 * Homepage
 * 	http://code.google.com/p/stardust-particle-engine/
 * 
 * PDF Manual
 * 	http://stardust-particle-engine.googlecode.com/svn/trunk/manual/Stardust%20Particle%20Engine%20Manual.pdf
 */

package {
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import idv.cjcat.stardust.common.clocks.SteadyClock;
	import idv.cjcat.stardust.twoD.renderers.DisplayObjectRenderer;
	
	[SWF(backgroundColor="#000000", frameRate=60)]
	
	public class Main extends Sprite {
		
		public static const RATE:Number = 1;
		
		private var container:Sprite;
		private var emitter:FireflyEmitter;
		
		private var canvasBMP:Bitmap;
		private var canvasBMPD:BitmapData;
		private var glow:GlowFilter = new GlowFilter(0xFFCC00, 1, 8, 8, 5, 2, false, true);
		
		public function Main():void {
			
			//Stardust
			//------------------------------------------------------------------------------------------------
				
				//container
				container = new Sprite();
				addChild(container);
				
				//emitter & renderer
				emitter = new FireflyEmitter(new SteadyClock(RATE));
				var renderer:DisplayObjectRenderer = new DisplayObjectRenderer(container);
				renderer.addEmitter(emitter);
				
			//------------------------------------------------------------------------------------------------
			
			//canvas BMP
			//------------------------------------------------------------------------------------------------
				
				canvasBMPD = new BitmapData(233, 233, false, 0);
				canvasBMP = new Bitmap(canvasBMPD);
				canvasBMP.scaleX = canvasBMP.scaleY = 2;
				addChildAt(canvasBMP, 0);
				
			//------------------------------------------------------------------------------------------------
			
			//UI
			//------------------------------------------------------------------------------------------------
				
				//speed buttons
				new PushButton(this, 10, 10, "0.25X", changeSpeed).setSize(60, 20);
				new PushButton(this, 10, 30, "0.5X", changeSpeed).setSize(60, 20);
				new PushButton(this, 10, 50, "1X", changeSpeed).setSize(60, 20);
				new PushButton(this, 10, 70, "2X", changeSpeed).setSize(60, 20);
				new PushButton(this, 10, 90, "4X", changeSpeed).setSize(60, 20);
				addEventListener(Event.ENTER_FRAME, mainLoop);
				
			//------------------------------------------------------------------------------------------------
		}
		
		private var point:Point = new Point(0, 0);
		private var matrix:Matrix = new Matrix(0.5, 0, 0, 0.5);
		private function mainLoop(e:Event):void {
			container.filters = [glow];
			canvasBMPD.lock();
			canvasBMPD.fillRect(canvasBMPD.rect, 0);
			canvasBMPD.draw(container, matrix);
			canvasBMPD.unlock();
			container.filters = [];
			emitter.step();
		}
		
		private function changeSpeed(e:Event):void {
			var btn:PushButton = e.target as PushButton;
			
			switch (btn.label) {
				case "0.25X":
					emitter.stepTimeInterval = 0.25;
					break;
				case "0.5X":
					emitter.stepTimeInterval = 0.5;
					break;
				case "1X":
					emitter.stepTimeInterval = 1;
					break;
				case "2X":
					emitter.stepTimeInterval = 2;
					break;
				case "4X":
					emitter.stepTimeInterval = 4;
					break;
			}
		}
	}
}

//------------------------------------------------------------------------------------------------

import flash.display.Shape;
import idv.cjcat.stardust.common.actions.Age;
import idv.cjcat.stardust.common.actions.AlphaCurve;
import idv.cjcat.stardust.common.actions.DeathLife;
import idv.cjcat.stardust.common.clocks.Clock;
import idv.cjcat.stardust.common.initializers.Life;
import idv.cjcat.stardust.common.initializers.Scale;
import idv.cjcat.stardust.common.math.UniformRandom;
import idv.cjcat.stardust.twoD.actions.DeathZone;
import idv.cjcat.stardust.twoD.actions.Move;
import idv.cjcat.stardust.twoD.actions.RandomDrift;
import idv.cjcat.stardust.twoD.actions.SpeedLimit;
import idv.cjcat.stardust.twoD.emitters.Emitter2D;
import idv.cjcat.stardust.twoD.initializers.DisplayObjectClass;
import idv.cjcat.stardust.twoD.initializers.Position;
import idv.cjcat.stardust.twoD.initializers.Velocity;
import idv.cjcat.stardust.twoD.zones.LazySectorZone;
import idv.cjcat.stardust.twoD.zones.RectZone;

//------------------------------------------------------------------------------------------------

const FIREFLY_COLOR:uint = 0xFFCC00;
const FIREFLY_SPEED_AVG:Number = 0.7;
const FIREFLY_SPEED_VAR:Number = 0.6;
const FIREFLY_MAX_SPEED:Number = 1.5;
const FIREFLY_RANDOM_DRIFT:Number = 0.2;
const FIREFLY_LIFE_AVG:Number = 150;
const FIREFLY_LIFE_VAR:Number = 30;
const FIREFLY_SCALE_VAR:Number = 0.3;
const FIREFLY_RADIUS_AVG:Number = 2;

//------------------------------------------------------------------------------------------------

class FireflyEmitter extends Emitter2D {
	
	public function FireflyEmitter(clock:Clock) {
		super(clock);
		
		//initializers
		addInitializer(new DisplayObjectClass(Firefly));
		addInitializer(new Life(new UniformRandom(FIREFLY_LIFE_AVG, FIREFLY_LIFE_VAR)));
		addInitializer(new Position(new RectZone(0, 0, 465, 465)));
		addInitializer(new Velocity(new LazySectorZone(FIREFLY_SPEED_AVG, FIREFLY_SPEED_VAR)));
		addInitializer(new Scale(new UniformRandom(1, FIREFLY_SCALE_VAR)));
		
		//actions
		addAction(new Age());
		addAction(new DeathLife());
		addAction(new Move());
		addAction(new AlphaCurve(40, 40));
		addAction(new RandomDrift(FIREFLY_RANDOM_DRIFT, FIREFLY_RANDOM_DRIFT));
		addAction(new SpeedLimit(FIREFLY_MAX_SPEED));
		addAction(new DeathZone(new RectZone( -60, -60, 585, 585), true));
	}
}

//------------------------------------------------------------------------------------------------

class Firefly extends Shape {
	
	public function Firefly() {
		graphics.beginFill(0xFFFFFF);
		graphics.drawCircle(0, 0, FIREFLY_RADIUS_AVG);
	}
}