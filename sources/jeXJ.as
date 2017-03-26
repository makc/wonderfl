/**
 * Copyright TakashiMurai ( http://wonderfl.net/user/Murai )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/jeXJ
 */

/**
 * Copyright HaraMakoto ( http://wonderfl.net/user/HaraMakoto )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/sFXf
 */

/**
 * Copyright alumican_net ( http://wonderfl.net/user/alumican_net )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/wM1h
 */

/**
 * Fluid on the Video
 * 
 * @author http://alumican.net
 * 
 * http://www.nicovideo.jp/watch/sm3605606
 */
package {
	import flash.geom.Rectangle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;

	//	import net.hires.debug.Stats;
	[SWF(width="465", height="465", backgroundColor="0x000000", frameRate="30")]
	public class LiquidVideo extends Sprite
	{
		//CLASS CONSTANTS
		private const MAP_WIDTH:Number        = 465;
		private const MAP_HEIGHT:Number       = 465;
		private const MAP_GRID_SIZE:Number    = 20;
		private const MAP_FLOW_SIZE:Number    = 2;
		private const MAP_INTENSITY:Number    = 0.25;
		private const MAP_SCALE:Number        = 150;
		private const MAP_USE_DECAY:Boolean   = true;
		private const MAP_BLUR_INTENSITY:uint = 32;
		private const MAP_BLUR_QUALITY:uint   = 2;
		
		private const ZERO_POINT:Point = new Point(0,0);
		
		//VARIABLES
		private var _container:Sprite;
		
		private var _canvas:BitmapData;
		private var _canvasTone:ColorMatrixFilter;
		
		private var _fluidMap:FluidMap;
		
		private var _mapFilter:DisplacementMapFilter;
		
		private var _oldX:Number = 0;
		private var _oldY:Number = 0;
		private var _isMouseMove:Boolean = false;
		
		
		private var _background:Sprite;
		
//		private var _stats:Stats;
		private var _usage:TextField;
		
		/////////particle
		private var _mirrorBmp:Bitmap = new Bitmap();
        private var _mirrorBmd:BitmapData = new BitmapData(465,465,false,0);
        private var _mirrorMtx:Matrix;
        private var _transPoint:Point = new Point(465/2, 465/2);
        
        private var _particleLayer:Sprite = new Sprite();
        
        private var _particles:Array = [];
        private var _emitter:Emitter;
        
        private const PARTICLE_NUM:uint = 1;
		
		private var _blustLayer:Sprite = new Sprite();
		
		private var _mixPoint:Sprite = new Sprite();
		private var _mixcounter:int = 0;
		
		private var player:Object = new Object();
        private var loader:Loader = new Loader();
		private var bA:ByteArray;
		private var spectrum:Array;
		
		public static var lowVal:Number=0;
		public static var middleVal:Number=0;
		public static var highVal:Number = 0;
		private var sound:Sound;

		//CONSTRUCTOR
		public function LiquidVideo():void
		{
//			Wonderfl.disable_capture();
			addEventListener(Event.ADDED_TO_STAGE, _initialize);
		}
		
		//METHODS
		private function _initialize(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _initialize);
			addChild(_blustLayer);
			
			_background = new Sprite();
			addChild(_background);
			
			_container = new Sprite();
			addChild(_container);
			
			_canvas = new BitmapData(MAP_WIDTH, MAP_HEIGHT, false, 0xffffff);
			_fluidMap = new FluidMap(MAP_WIDTH, MAP_HEIGHT, MAP_GRID_SIZE, MAP_FLOW_SIZE, MAP_INTENSITY, MAP_USE_DECAY, MAP_SCALE, MAP_BLUR_INTENSITY, MAP_BLUR_QUALITY);
			
			_container.addChild(new Bitmap(_canvas));
//			_container.addChild(new Bitmap(_fluidMap._mapBmd));
			
			_mapFilter = _fluidMap.mapFilter;
			
			
			_canvasTone = new ColorMatrixFilter([
				1, 0, 0, 0, 5,
				0, 1, 0, 0, 5,
				0, 0, 1, 0, 5,
				0, 0, 0, 0, 0
			]);
			
//			_stats = new Stats( {
//				bg:0xffffff,
//				fps:0x333333,
//				ms:0x333333,
//				mem:0x333333,
//				memmax:0x333333
//			});
//			_stats.blendMode = BlendMode.DARKEN;
//			addChild(_stats);
			
			_usage = new TextField();
			_usage.defaultTextFormat = new TextFormat("MS Gothic", 11, 0x0);
			_usage.text = "Move mouse on movie";
			_usage.autoSize = TextFieldAutoSize.RIGHT;
			_usage.selectable = false;
			_usage.blendMode = BlendMode.INVERT;
			_usage.visible = false;
			_container.addChild(_usage);
			
			stage.addEventListener(Event.RESIZE, _resizeHandler);
			
			_resizeHandler();
			setup();
			addEventListener(Event.ENTER_FRAME, _update);
			addEventListener(Event.ENTER_FRAME, updateSpectrum);
			
/*
			本当は大好きなsquarepusherのIambic 9 Poetryで調整してたんですが、youtubeさんのSecuritySandboxの関係で断念。残念。。。
            Security.allowDomain("www.youtube.com");
            loader.contentLoaderInfo.addEventListener(Event.INIT, playerLoaded);
            loader.load(new URLRequest("http://www.youtube.com/v/XbbHBvy6GoU?version=3"),new LoaderContext(true));
			 */
			sound = new Sound(new URLRequest("http://level0.kayac.com/images/murai/DJ%20Dolores%20-%20Oslodum%202004.mp3"), new SoundLoaderContext(10000, true));
			sound.play();
            
			bA = new ByteArray();
			stage.quality = StageQuality.LOW;
			stage.fullScreenSourceRect=new Rectangle(0,0,465,465);
		}

		private function updateSpectrum(e:Event):void {
			SoundMixer.computeSpectrum(bA,true,63);
			spectrum = [];
			for (var i:int = 0;i < 4;i++) {
				if((bA.position / bA.length - 1))spectrum[i] = bA.readFloat();
			}
			bA.position=0;
			lowVal = spectrum[0];
			trace('lowVal: ' + (lowVal));
			middleVal = spectrum[1];
			trace('middleVal: ' + (middleVal));
			highVal = spectrum[2];
			trace('highVal: ' + (highVal));
			trace("--");
		}

//		private function playerLoaded(event:Event):void {
//    		loader.content.addEventListener("onReady", playerReady);
//        }
//        
//        private function playerReady(event:Event):void {
//    		player = loader.content;
//    		player.loadVideoById("NitSm_UVIDk", 0, "large");
//        }

//--------------------------------------------------------------------------------//
//		Particles
//--------------------------------------------------------------------------------//	
		
		private function setup():void
        {
           	_mirrorBmp.bitmapData = _mirrorBmd;
           	_blustLayer.addChild(_mirrorBmp);
           
            _emitter = new Emitter();
            _blustLayer.addChild(_particleLayer);
            _particleLayer.addChild(_emitter);
			
            for (var i:uint = 0; i < 100; i++) {
                _particles.push(new Particle());
            }

            addEventListener(Event.ENTER_FRAME, draw);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, _mouseMoveHandler);
		    
//            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            addEventListener(Event.ENTER_FRAME, createParticle);
            _transPoint.x = mouseX;
            _transPoint.y = mouseY;
        }
        
        private function draw(event:Event):void
        {
            _emitter.update();

            for each (var p:Particle in _particles) {
                if (!p.destroy) {
                    if (p.y >= 10) {
//                       	p.vy *= -0.9;
//                        p.vx *= -0.9
                    } 
                    p.update();
                }
            }
            
            _mirrorMtx = new Matrix();
            var ram:Number = 10+2*Math.random();
            _mirrorMtx.translate(-_transPoint.x, -_transPoint.y);
            _mirrorMtx.scale(ram,ram); 
            _mirrorMtx.translate(_transPoint.x, _transPoint.y);
            _mirrorBmd.fillRect(_mirrorBmd.rect, 0x00000000);
            _mirrorBmd.draw( _particleLayer, _mirrorMtx);
            
        }
        
        
        private function createParticle(event:Event):void
        {
            var count:uint = 0;
            for each (var p:Particle in _particles) {
                if (p.destroy) {
                    p.x = _emitter.x;
                    p.y = _emitter.y;
                    p.init();
                    _particleLayer.addChild(p);
                    count++;
                }
                if (count > PARTICLE_NUM) break;
            }
        }

//--------------------------------------------------------------------------------//
//		Fluid
//--------------------------------------------------------------------------------//		

		private function _drawCanvas():void
		{
			_canvas.lock();
			_canvas.applyFilter(_canvas, _canvas.rect, ZERO_POINT, _canvasTone);
			_canvas.draw(_blustLayer);
			_canvas.applyFilter(_canvas, _canvas.rect, ZERO_POINT, _mapFilter);
			_canvas.unlock();
		}
		
		private function _refillBackground():void
		{
			var sw:int = stage.stageWidth;
			var sh:int = stage.stageHeight;
			
			var g:Graphics = _background.graphics;
			g.clear();
			g.beginFill(0xffffff);
			g.moveTo(0 , 0 );
			g.lineTo(sw, 0 );
			g.lineTo(sw, sh);
			g.lineTo(0 , sh);
			g.lineTo(0 , 0 );
			g.endFill();
		}
		
		private function _update(e:Event):void
		{
			var speedX:Number = _mixPoint.x - _oldX;
			var speedY:Number = _mixPoint.y - _oldY;
				
			_fluidMap.addOrientedForce(_mixPoint.x, _mixPoint.y, speedX, speedY);
				
			_mixPoint.x = 466/2 + 20 * Math.cos(_mixcounter * Math.PI/180);
			_mixPoint.y = 466/2 + 10*Math.random() + 100 * Math.sin(_mixcounter * Math.PI/180);
			
			_fluidMap.updateMap();
			
			_drawCanvas();
			
			_oldX = _mixPoint.x;
			_oldY = _mixPoint.y;
			
			_mixcounter+=1+20*Math.random();
		}
		
		private function _mouseMoveHandler(e:MouseEvent):void
		{
			_isMouseMove = true;
		}
		
		private function _resizeHandler(e:Event = null):void
		{
			_refillBackground();
			
			_container.x = uint((stage.stageWidth  - MAP_WIDTH ) / 2);
			_container.y = uint((stage.stageHeight - MAP_HEIGHT) / 2);
			
//			_stats.x = 2;
//			_stats.y = stage.stageHeight - 45;
		}
	}
}

import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.GradientType;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.filters.DisplacementMapFilter;
import flash.filters.DisplacementMapFilterMode;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

//--------------------------------------------------------------------------------//
//		Particle Utils
//--------------------------------------------------------------------------------//
class Emitter extends Sprite
{
    public var vx:Number = 0;
    public var vy:Number = 0;

    public function Emitter(){}

    public function update():void
    {
//        var dx:Number = root.mouseX - x;
//        var dy:Number = root.mouseY - y;
        var dx:Number = (465*.5) - x;
        var dy:Number = (465*.8) - y;
        var d:Number = Math.sqrt(dx*dx+dy*dy) * 0.2;
        var rad:Number = Math.atan2(dy, dx);

        vx += Math.cos(rad)*d;
        vy += Math.sin(rad)*d;

        vx *= 0.7;
        vy *= 0.7;

        x += vx;
        y += vy;
	}
}

class Particle extends Sprite
{
    public var vx:Number;
    public var vy:Number;
    public var life:Number;
    public var size:Number;

    private var _count:uint;
    private var _destroy:Boolean;
    
	private var friction:Number = 0.99;
	private var vectx:Number = -0.4;
	private var vecty:Number = -0.8;
	private var xrandom:Number = 0.8;
	private var yrandom:Number = 0.3;

	public function Particle() {
		setup();
	}

	private function setup():void {
		size = (LiquidVideo.lowVal) * 60;
        
		//White
		var red:uint = (Math.random() * 115 + (50 * LiquidVideo.highVal)) >> 0;
		var blue:uint = (Math.random() * 100 + 140) >> 0;
		var green:uint = (Math.random() * 10 + 0 + (140 * LiquidVideo.lowVal)) >> 0;
		//Rainbow
//		var red:uint = Math.floor(Math.random()*100+126);
//        var blue:uint = Math.floor(Math.random()*100+124);
//        var green:uint = Math.floor(Math.random()*246+10);
        
        var color:Number = (red << 16) | (green << 8) | (blue);
        
        var fillType:String = GradientType.RADIAL;
        var colors:Array = [color , 0x000000];
        var alphas:Array = [100, 100];
        var ratios:Array = [0x00, 0xFF];
        var mat:Matrix = new Matrix();
        mat.createGradientBox(size * 2, size * 2, 0, -size, -size);
        var spreadMethod:String = SpreadMethod.PAD;

		graphics.clear();
        graphics.beginGradientFill(fillType, colors, alphas, ratios, mat, spreadMethod);
        graphics.drawCircle(0, 0, size);
        graphics.endFill();
        
        blendMode = "add";

        _destroy = true;
	}

	public function init():void
    {
    	setup();
		var vel:Number = LiquidVideo.lowVal*50;
        vx = (Math.random() * vel -vel/2);
        vy = (Math.random() * vel - vel/2);
        life = 80 * (LiquidVideo.highVal);
        _count = 0;
        _destroy = false;
    }

    
    public function update():void
    {
        vx += Math.random()*xrandom + vectx;
		vy += Math.random()*yrandom + vecty;
		vx *= friction;
		vy *= friction;
		
        x += vx;
        y += vy;

        _count++;
        
        if (life < _count) {
            _destroy = true;
            parent.removeChild(this);
        }
    }

    public function get destroy():Boolean
    {
        return _destroy;
    }
}

//--------------------------------------------------------------------------------//
//		FluidMapUtils
//--------------------------------------------------------------------------------//
internal class FluidMap
{
	//CLASS CONSTANTS
	private static const ZERO_POINT:Point = new Point(0, 0);
	
	//VARIABLES
	private var _cells:Array;
	private var _cellCount:uint;
	
	private var _allCells:Array;
	private var _allCellCount:uint;
	
	private var _width:uint;
	private var _height:uint;
	
	private var _widthCount:uint;
	private var _heightCount:uint;
	
	private var _gridSize:uint;
	private var _flowSize:Number;
	private var _intensity:Number;
	private var _useDecay:Boolean;
	
	public var _mapBmd:BitmapData;
	private var _mapFilter:DisplacementMapFilter;
	private var _mapScale:Number;
	private var _mapBlurIntensity:uint;
	private var _mapBlurQuality:uint;
	private var _blurFilter:BlurFilter;
	
	private var _calculator:FluidCalculator;
	
	private var _colorAdjust:Number;
	private var _distMin2:Number;
	private var _flowSize2:Number;
	
	public function get mapFilter():DisplacementMapFilter { return _mapFilter; }
	
	//CONSTRUCTOR
	public function FluidMap(
		width:uint,
		height:uint,
		gridSize:uint         = 20,
		flowSize:Number       = 2,
		intensity:Number      = 0.25,
		useDecay:Boolean      = true,
		mapScale:Number       = 100,
		mapBlurIntensity:uint = 4,
		mapBlurQuality:uint   = 2
	):void
	{
		_width            = width;
		_height           = height;
		_gridSize         = gridSize;
		_flowSize         = flowSize;
		_useDecay         = useDecay;
		_intensity        = intensity;
		_mapScale         = mapScale;
		_mapBlurIntensity = mapBlurIntensity;
		_mapBlurQuality   = mapBlurQuality;
		
		_widthCount  = uint( Math.ceil(width  / gridSize) );
		_heightCount = uint( Math.ceil(height / gridSize) );
		
		_allCellCount = _widthCount * _heightCount;
		_allCells = new Array(_allCellCount);
		var p:uint = 0;
		
                var i:uint;
                var j:uint;
                var data:FluidMapData;
                
		var cells2d:Array = new Array(_widthCount);
		for (i = 0; i < _widthCount; ++i)
		{
			cells2d[i] = new Array(_heightCount);
			for (j = 0; j < _heightCount; ++j)
			{
				data = new FluidMapData(i, j);
				cells2d[i][j] = data;
				_allCells[p] = data;
				
				++p;
			}
		}
		
		_cells = new Array();
		
		var w:uint = _widthCount  - 1;
		var h:uint = _heightCount - 1;
		var pi:uint = 0;
		var pj:uint = 0;
		for (i = 1; i < w; ++i)
		{
			for (j = 1; j < h; ++j)
			{
				data = cells2d[i][j] as FluidMapData;
				
				data.n00 = cells2d[i - 1][j - 1] as FluidMapData;
				data.n10 = cells2d[i    ][j - 1] as FluidMapData;
				data.n20 = cells2d[i + 1][j - 1] as FluidMapData;
				
				data.n01 = cells2d[i - 1][j    ] as FluidMapData;
				data.n21 = cells2d[i + 1][j    ] as FluidMapData;
				
				data.n02 = cells2d[i - 1][j + 1] as FluidMapData;
				data.n12 = cells2d[i    ][j + 1] as FluidMapData;
				data.n22 = cells2d[i + 1][j + 1] as FluidMapData;
				
				if (pi != 0)
				{
					data.prev = cells2d[pi][pj] as FluidMapData;
					data.prev.next = data;
				}
				
				_cells.push(data);
				
				pi = i;
				pj = j;
			}
		}
		_cellCount = _cells.length;
		
		_mapBmd = new BitmapData(_width, _height, false, 0x008080);
		
		_mapFilter = new DisplacementMapFilter();
		_mapFilter.mapBitmap  = _mapBmd;
		_mapFilter.mapPoint   = ZERO_POINT;
		_mapFilter.componentX = BitmapDataChannel.GREEN;
		_mapFilter.componentY = BitmapDataChannel.BLUE;
		_mapFilter.mode       = DisplacementMapFilterMode.CLAMP;
		_mapFilter.scaleX     = _mapScale;
		_mapFilter.scaleY     = _mapScale;
		
		_blurFilter = new BlurFilter(_mapBlurIntensity, _mapBlurIntensity, _mapBlurQuality);
		
		_colorAdjust = -128 * _intensity;
		_distMin2    = 4 * _gridSize * _gridSize;
		_flowSize2   = _flowSize * _flowSize;
		
		_calculator = new FluidCalculator();
	}
	
	//METHODS
	public function addOrientedForce(x:uint, y:uint, forceX:Number = 0, forceY:Number = 0):void
	{
		var s:uint = _gridSize;
		var n:uint = _cellCount;
		var cell:FluidMapData = _cells[0] as FluidMapData;
		
		for (var i:uint = 0; i < n; ++i)
		{
			_calcOrientedForce(cell, x / s, y / s, forceX, forceY);
			cell = cell.next;
		}
	}
	
	public function updateMap():BitmapData
	{
		var s:uint            = _gridSize;
		var n:uint            = _cellCount;
		var cell:FluidMapData = _cells[0] as FluidMapData;
		var map:BitmapData    = _mapBmd;
		
		_decay();
		_updatePressure();
		_updateVelocity();
		
		map.lock();
		map.fillRect(map.rect, 0x008080);
		for (var i:uint = 0; i < n; ++i)
		{
			map.fillRect(
				new Rectangle(cell.x * s, cell.y * s, s, s),
				_calcMapColor(cell)
			);
			cell = cell.next;
		}
		map.applyFilter(map, map.rect, ZERO_POINT, _blurFilter);
		map.unlock();
		
		return map;
	}
	
	private function _decay():void
	{
		if (_useDecay)
		{	
			var n:uint = _allCellCount;
			var cell:FluidMapData = _allCells[0] as FluidMapData;
			
			for (var i:uint = 0; i < n; ++i)
			{
				_calcDecay(_allCells[i]);
				//cell = cell.next;
			}
		}
	}
	
	private function _updatePressure():void
	{
		var n:uint = _cellCount;
		var cell:FluidMapData = _cells[0] as FluidMapData;
		
		for (var i:uint = 0; i < n; ++i)
		{
			_calcPressure(cell);
			cell = cell.next;
		}
	}
	
	private function _updateVelocity():void
	{
		var n:uint = _cellCount;
		var cell:FluidMapData = _cells[0] as FluidMapData;
		
		for (var i:uint = 0; i < n; ++i)
		{
			_calcVelocity(cell);
			cell = cell.next;
		}
	}
	
	private function _calcDecay(data:FluidMapData):void
	{
		var r:Number = data.colorX;
		var b:Number = data.colorY;
		
		if (r != 128) data.colorX += (r < 128) ? 1 : -1;
		if (b != 128) data.colorY += (b < 128) ? 1 : -1;
	}
	
	private function _calcPressure(data:FluidMapData):void
	{ 
		data.pressure += _calculator.calcPressure(data);
		data.pressure *= 0.7;
	}
	
	private function _calcVelocity(data:FluidMapData):void
	{
		data.vx += _calculator.calcVelocityX(data);
		data.vy += _calculator.calcVelocityY(data);
		data.vx *= 0.7;
		data.vy *= 0.7;
	}
	
	private function _calcOrientedForce(data:FluidMapData, x:uint, y:uint, forceX:Number = 0, forceY:Number = 0):void
	{
		var dx:int       = data.x - x;
		var dy:int       = data.y - y;
		var dist2:Number = dx * dx + dy * dy;
		
		if (dist2 < _flowSize2)
		{
			var f:Number = (dist2 < _distMin2) ? 1.0 : (_flowSize / Math.sqrt(dist2));
			
//			data.vx += forceX * f;
//			data.vy += forceY * f;
			data.vx += 20*dx * f;
			data.vy += 20*dy * f;
		}
	}
	
	private function _calcMapColor(data:FluidMapData):uint
	{
		var vx:Number = data.vx;
		var vy:Number = data.vy;
		var g:int  = data.colorX;
		var b:int  = data.colorY;
		
		g = Math.round( _colorAdjust * vx + g );
		b = Math.round( _colorAdjust * vy + b );
		
		g = (g < 0) ? 0 : (g > 255) ? 255 : g;
		b = (b < 0) ? 0 : (b > 255) ? 255 : b;
		
		data.colorX = g;
		data.colorY = b;
		
		return data.color = g << 8 | b;
	}
}

internal class FluidCalculator
{
	//CONSTRUCTOR
	public function FluidCalculator():void
	{
	}
	
	//METHODS
	public function calcVelocityX(data:FluidMapData):Number
	{
		return (  data.n00.pressure * 0.5
				+ data.n01.pressure
				+ data.n02.pressure * 0.5
				
				- data.n20.pressure * 0.5
				- data.n21.pressure
				- data.n22.pressure * 0.5
				
				) * 0.25;
	}
	
	public function calcVelocityY(data:FluidMapData):Number
	{
		return (  data.n00.pressure * 0.5
				+ data.n10.pressure
				+ data.n20.pressure * 0.5
				
				- data.n02.pressure * 0.5
				- data.n12.pressure
				- data.n22.pressure * 0.5
				
				) * 0.25;
	}
	
	public function calcPressure(data:FluidMapData):Number
	{
		return (  data.n00.vx * 0.5
				+ data.n01.vx
				+ data.n02.vx * 0.5
				- data.n20.vx * 0.5
				- data.n21.vx
				- data.n22.vx * 0.5
				
				+ data.n00.vy * 0.5
				+ data.n10.vy
				+ data.n20.vy * 0.5
				- data.n02.vy * 0.5
				- data.n12.vy
				- data.n22.vy * 0.5
				
				) * 0.20;
	}
}

internal class FluidMapData
{
	//VARIABLES
	public function get x():uint { return _x; }
	public function set x(value:uint):void { _x = value; }
	private var _x:uint;
	
	public function get y():uint { return _y; }
	public function set y(value:uint):void { _y = value; }
	private var _y:uint;
	
	public function get vx():Number { return _vx; }
	public function set vx(value:Number):void { _vx = value; }
	private var _vx:Number;
	
	public function get vy():Number { return _vy; }
	public function set vy(value:Number):void { _vy = value; }
	private var _vy:Number;
	
	public function get pressure():Number { return _pressure; }
	public function set pressure(value:Number):void { _pressure = value; }
	private var _pressure:Number;
	
	public function get color():uint { return _color; }
	public function set color(value:uint):void { _color = value; }
	private var _color:uint;
	
	public function get colorX():uint { return _colorX; }
	public function set colorX(value:uint):void { _colorX = value; }
	private var _colorX:uint;
	
	public function get colorY():uint { return _colorY; }
	public function set colorY(value:uint):void { _colorY = value; }
	private var _colorY:uint;
	
	public function get next():FluidMapData { return _next; }
	public function set next(value:FluidMapData):void { _next = value; }
	private var _next:FluidMapData;
	
	public function get prev():FluidMapData { return _prev; }
	public function set prev(value:FluidMapData):void { _prev = value; }
	private var _prev:FluidMapData;
	
	private var _n00:FluidMapData;
	private var _n01:FluidMapData;
	private var _n02:FluidMapData;
	private var _n10:FluidMapData;
	private var _n12:FluidMapData;
	private var _n20:FluidMapData;
	private var _n21:FluidMapData;
	private var _n22:FluidMapData;
	
	public function get n00():FluidMapData { return _n00; }
	public function get n01():FluidMapData { return _n01; }
	public function get n02():FluidMapData { return _n02; }
	public function get n10():FluidMapData { return _n10; }
	public function get n12():FluidMapData { return _n12; }
	public function get n20():FluidMapData { return _n20; }
	public function get n21():FluidMapData { return _n21; }
	public function get n22():FluidMapData { return _n22; }
	
	public function set n00(value:FluidMapData):void { _n00 = value; }
	public function set n01(value:FluidMapData):void { _n01 = value; }
	public function set n02(value:FluidMapData):void { _n02 = value; }
	public function set n10(value:FluidMapData):void { _n10 = value; }
	public function set n12(value:FluidMapData):void { _n12 = value; }
	public function set n20(value:FluidMapData):void { _n20 = value; }
	public function set n21(value:FluidMapData):void { _n21 = value; }
	public function set n22(value:FluidMapData):void { _n22 = value; }
	
	//CONSTRUCTOR
	public function FluidMapData(x:uint, y:uint):void
	{
		_x        = x;
		_y        = y;
		_vx       = 0;
		_vy       = 0;
		_pressure = 0;
		_color    = 0x008080;
		_colorX   = 128;
		_colorY   = 128;
	}
}