package 
{
	import com.actionsnippet.qbox.QuickBox2D;
	import com.actionsnippet.qbox.QuickObject;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import frocessing.color.ColorHSV;
	import idv.cjcat.stardust.common.clocks.SteadyClock;
	import idv.cjcat.stardust.twoD.actions.waypoints.Waypoint;
	import idv.cjcat.stardust.twoD.renderers.PixelRenderer;
	import idv.cjcat.stardust.twoD.zones.CircleZone;
	import net.hires.debug.Stats;
	
	/**
	 * Waypointのテスト
	 * @author paq89
	 */
	[SWF(width=465, height=465, backgroundColor=0x000000, frameRate=60)]
	public class Main extends Sprite 
	{
		static private const ZERO_POINT:Point = new Point();
		static private const BLUR:BlurFilter = new BlurFilter();
		static private const WAYPOINT_COUNT:uint = 7;
		private var _emitter:WaypointsEmitter;
		private var _waypoints:/*Waypoint*/Array;
		private var _circles:/*QuickObject*/Array;
		private var _canvas:BitmapData;
		private var _blurEffect:BitmapData;
		private var _hsv:ColorHSV;
		private var _matrix:Matrix;
		private var _kirakira:BitmapData;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// 変数を初期化
			_hsv = new ColorHSV(0, 0.7);
			_waypoints = []
			_circles = [];
			
			// 背景
			graphics.beginFill(0x000000); graphics.drawRect(0, 0, 465, 465);
			
			// パーティクルを表示するビットマップを作成
			_canvas = new BitmapData(465, 465, true, 0x00000000);
			_blurEffect = new BitmapData(465, 465, true, 0x00000000);
			addChild(Bitmap(new Bitmap(_blurEffect)));
			addChild(Bitmap(new Bitmap(_canvas)));
			
			// QuickBox2D
			initQuickBox2D();
			
			// Stardust
			initStardust();
			
			// キラキラエフェクト
			_kirakira = new BitmapData(465 / 4, 465 / 4, false, 0x000000);
			var bmp:Bitmap = new Bitmap(_kirakira, "never", true);
			bmp.scaleX = bmp.scaleY = 4;
			bmp.smoothing = true;
			bmp.blendMode = BlendMode.ADD;
			addChild(bmp);
			_matrix = new Matrix(0.25, 0, 0, 0.25);
			
			// イベントリスナー
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		/*
		 * Stardust
		 */
		private function initStardust():void 
		{
			// パーティクルシステムの構築
			_emitter = new WaypointsEmitter(new SteadyClock(0.7), _waypoints);
			var renderer:PixelRenderer = new PixelRenderer(_canvas);
			renderer.addEmitter(_emitter);
		}
		
		/*
		 * QuickBox2D
		 */
		private function initQuickBox2D():void
		{
			var mc:MovieClip = MovieClip(addChildAt(new MovieClip, 1));
			mc.buttonMode = true;
			var qbox:QuickBox2D = new QuickBox2D(mc, { gravityY:0 } );
			qbox.setDefault( { lineColor:0xFFFFFF, fillAlpha:0 } );
			qbox.addBox( { x:-1.5, y:7.75, width:3, height: 15.5, density:0} );
			qbox.addBox( { x:17, y:7.75, width:3, height: 15.5, density:0 } );
			qbox.addBox( { x:7.75, y:-1.5, width:15.5, height: 3, density:0 } );
			qbox.addBox( { x:7.75, y:17, width:15.5, height: 3, density:0 } );
			qbox.start();
			qbox.mouseDrag();
			
			var hsv:ColorHSV = new ColorHSV(0, 0.7, 1);
			for (var i:int = 0; i < WAYPOINT_COUNT; i++) 
			{
				hsv.h = i * (360 / WAYPOINT_COUNT);
				var x:int = (Math.random() * 465) >> 0;
				var y:int = (Math.random() * 465) >> 0;
				var circle:QuickObject = qbox.addCircle( { x:x / 30, y:y / 30, radius:10 / 30, restitution:0.5, lineColor:hsv.value } );
				_circles.push(circle);
				_waypoints.push(new Waypoint(circle.x*30, circle.y*30));
			}
		}
		
		/*
		 * エンターフレームイベント
		 */
		private function loop(e:Event):void 
		{
			// Waypointの位置を調整
			for (var i:int = 0; i < WAYPOINT_COUNT; i++) 
			{
				_waypoints[i].x = _circles[i].x * 30;
				_waypoints[i].y = _circles[i].y * 30;
			}
			
			CircleZone(_emitter.position.zone).x = _waypoints[0].x;
			CircleZone(_emitter.position.zone).y = _waypoints[0].y;
			CircleZone(_emitter.deathZone.zone).x = _waypoints[WAYPOINT_COUNT-1].x;
			CircleZone(_emitter.deathZone.zone).y = _waypoints[WAYPOINT_COUNT-1].y;
			
			// キラキラエフェクト
			_kirakira.fillRect(_kirakira.rect, 0x00000000);
			_kirakira.draw(_canvas, _matrix);
			
			// 残像エフェクト
			_blurEffect.draw(_canvas);
			_blurEffect.applyFilter(_blurEffect, _canvas.rect, ZERO_POINT, BLUR);
			_canvas.fillRect(_canvas.rect, 0x00000000);
			
			// パーティクルの色相を変更
			_hsv.h++;
			_emitter.color.color = _hsv.value32;
			
			// エミッターを更新
			_emitter.step();
		}
		
	}
	
}
import idv.cjcat.stardust.common.clocks.Clock;
import idv.cjcat.stardust.common.initializers.Color;
import idv.cjcat.stardust.common.initializers.Mass;
import idv.cjcat.stardust.common.math.UniformRandom;
import idv.cjcat.stardust.twoD.actions.DeathZone;
import idv.cjcat.stardust.twoD.actions.FollowWaypoints;
import idv.cjcat.stardust.twoD.actions.Move;
import idv.cjcat.stardust.twoD.actions.SpeedLimit;
import idv.cjcat.stardust.twoD.emitters.Emitter2D;
import idv.cjcat.stardust.twoD.initializers.Position;
import idv.cjcat.stardust.twoD.zones.CircleZone;

class WaypointsEmitter extends Emitter2D 
{
	public var color:Color;
	public var deathZone:DeathZone;
	public var position:Position;
	
	public function WaypointsEmitter(clock:Clock, waypoints:Array)
	{
		super(clock);
		
		color = new Color();
		position = new Position(new CircleZone(0, 0, 20));
		deathZone = new DeathZone(new CircleZone(0, 0, 20));
		
		addInitializer(color);
		addInitializer(position);
		addInitializer(new Mass(new UniformRandom(4, 1)));
		
		addAction(deathZone);
		addAction(new FollowWaypoints(waypoints, false, false));
		addAction(new Move());
		addAction(new SpeedLimit(3));
	}
}