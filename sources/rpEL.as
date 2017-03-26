package {
    
   	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
    public class VoxelPlay1 extends Sprite {
		
		public static const LEVELS:int = 5;
		public static const STEPS:int = 3;
		public static const RES:int = 40;
		public static const SCALE:Number = 8;
		public static const VIEWSCALE:int = 2;
		public static const PER:Number = 0.02;
		
		public static const BEVELDIST:int = 2;
		public static const BEVELBLUR:int = 1;
		public static const SHADOWCOLOR:Number = 0xff666666;
		public static const SHADOWBLUR:int = 4;
		public static const SMOOTH:Boolean = false;
		
		public static const WATER:Number = 0xff0066ff;
		public static const LAND1:Number = 0xff006600;
		public static const LAND2:Number = 0xff33ff66;
		public static const SAND:Number = 0xff887733;
		
		public static const COLORTRANS:ColorTransform = new ColorTransform(1, 1, 1, 1, 0);
		public static const EQUALIZE:ColorTransform = new ColorTransform(0.8, 0.8, 0.8, 1, 120, 120, 120);
		
		public var pt:Point = new Point(0, 0);
		public var rect:Rectangle = new Rectangle(0, 0, RES, RES);
		
		protected var _bms:Array;
		protected var _bds:Array;
		
		protected var _container:Sprite;
		
		protected var _render:BitmapData;
		protected var _renderMatrix:Matrix;
		protected var _renderRect:Rectangle;
		protected var _view:Bitmap;
		
		protected var _hm:BitmapData;
		protected var _hm2:BitmapData;
		protected var _sm:BitmapData;
		protected var _nm:BitmapData;
		protected var _bf:BitmapFilter;
		protected var _sf:BitmapFilter;
		protected var _gf:BitmapFilter;
		protected var _sandf:BitmapFilter;
		
		public var first:Boolean = true;
		public var offs:Array;
		public var noiseOffset:Array;
		
		public function VoxelPlay1 () {
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		
		private function init(e:Event = null):void {
			
			_render = new BitmapData(RES * SCALE, RES * SCALE, false, 0);
			_renderMatrix = new Matrix();
			_renderMatrix.createBox(SCALE, SCALE, 0, 0, 0);
			_renderRect = new Rectangle(0, 0, RES * SCALE, RES * SCALE);
			
			_view = new Bitmap(_render, PixelSnapping.NEVER, false);
			_view.scaleX = _view.scaleY = VIEWSCALE;
			_view.x = stage.stageWidth / 2 - (RES) / 2 * VIEWSCALE * SCALE;
			_view.y = stage.stageHeight / 2 - (RES) / 2 * VIEWSCALE * SCALE;
			addChild(_view);
			
			_bms = [];
			_bds = [];
			offs = [new Point(0, 0), new Point(0, 0), new Point(0, 0), new Point(0, 0)];
			noiseOffset = [new Point(0, 0)];
			
			offs[0].x=offs[1].x=offs[2].x=offs[3].x=offs[0].x-(256-mouseX)/20;
			offs[0].y=offs[1].y=offs[2].y=offs[3].y=offs[0].y+(200-mouseY)/20;
			
			_hm = new BitmapData(RES, RES, false);
			_hm2 = new BitmapData(RES, RES, false);
			
			var px:Sprite = new Sprite();
			var g:Graphics = px.graphics;
			var m:Matrix = new Matrix();
			m.createGradientBox(RES * SCALE * 2, RES * SCALE * 2, 0, 0 - RES * SCALE / 2, 0 - RES * SCALE / 2);
			g.beginGradientFill(GradientType.RADIAL, [0xcccccc, 0x333333], [1, 1], [0, 255], m, SpreadMethod.PAD);
			g.drawRect(0, 0, RES * SCALE, RES * SCALE);
			
			_sm = new BitmapData(RES * SCALE, RES * SCALE, false);
			_sm.draw(px);
			
			_nm = new BitmapData(RES * SCALE, RES * SCALE, false);
			_nm.perlinNoise(1, 1, 1, 5, false, true, 7, true);
			
			_bf = new BlurFilter(SHADOWBLUR, SHADOWBLUR, 2);
			_sf = new DropShadowFilter(BEVELDIST, 225, 0x000000, 1, 1, BEVELBLUR, BEVELBLUR, 1, true);
			_gf = new BevelFilter(2, 90, 0xffffff, 0.7, 0, 0.3, 4, 4, 0.5, 3);
			_sandf = new GlowFilter(SAND, 1, 4, 4, 3, 2, true);
			
			_container = new Sprite();

			var i:int, j:int;
			
			var bd:BitmapData;
			
			for (j = 0; j < LEVELS; j++) {
				
				for (i = 0; i < STEPS; i++) {
					
					if (i == 0 || i == STEPS - 1) bd = new BitmapData(RES, RES, true, 0);
					var bm:Bitmap = new Bitmap(bd, PixelSnapping.NEVER, SMOOTH);
					
					_bds.push(bd);
					_bms.push(bm);

					_container.addChild(bm);
					
					bm.scaleX = bm.scaleY = (1 + (j * STEPS + i) * PER);
					bm.x = RES / 2 - bm.width / 2;
					bm.y = RES / 2 - bm.height / 2;

				}
				
			}
			
			stage.addEventListener(Event.ENTER_FRAME, update);
		
			//var tb:Bitmap = new Bitmap(_hm);
			//addChild(tb);
	
		}
		
		protected function draw ():void {
			
			var i:int, j:int;
			
			var step:Number = 0xcc / LEVELS;
			var shade:Number = 0xcc / LEVELS;
			var colstep:Number = step << 16 | step << 8 | step;
			var shadestep:Number = shade << 16 | shade << 8 | shade;
			var thresh:Number;
			var col:Number;
			var undercol:Number;
			var pbd:BitmapData;
			var nbd:BitmapData;
			
			for (j = 0; j < LEVELS; j++) {
				
				thresh = Math.min(0xffffffff, 0xff000000 + colstep * j);
				if (j <= 0) col = WATER;
				else col = getTintedColor(LAND1, LAND2, j / LEVELS);
				
				undercol = getTintedColor(col, 0xff000000, 0.25);
				
				if (j < LEVELS - 1) {
					nbd = _bds[(j + 1) * STEPS];
					nbd.fillRect(rect, 0);
					nbd.threshold(_hm, rect, pt, ">", 0xff000000 + colstep * (j + 1), SHADOWCOLOR, 0x00ffffff, false);
					nbd.applyFilter(nbd, rect, pt, _bf);
				}
					
				for (i = 0; i < STEPS; i++) {
					
					var bd:BitmapData = _bds[j * STEPS + i];
					
					if (i == STEPS - 1) {
						
						if (j > 0) {
							bd.fillRect(rect, 0);
							bd.threshold(_hm, rect, pt, ">", thresh, col, 0x00ffffff, false);
						} else {
							bd.fillRect(rect, WATER - 0x66000000);
						}
						
						if (j == 1) bd.applyFilter(bd, rect, pt, _sandf);
						
						if (j < LEVELS - 1) bd.draw(nbd, null, null, BlendMode.MULTIPLY, rect);
						
						bd.applyFilter(bd, rect, pt, _gf); 
						
					} else if (j > 0 && i == 0) {
						
						bd.fillRect(rect, 0);
						bd.threshold(_hm, rect, pt, ">", thresh, undercol, 0x00ffffff, false);

					}
					
					if (i == 0) {
						bd.applyFilter(bd, rect, pt, _sf); 
					}
					
				}
				
			}

			
		}
		
		protected function update (e:Event):void {
			
			if (first || (mouseX > 50 && mouseY > 50 && mouseX < stage.stageWidth - 50 && mouseY < stage.stageHeight - 50)) {
		    
		            first = false;
			    offs[0].x = offs[1].x = offs[2].x = offs[3].x = offs[0].x - Math.round((stage.stageWidth / 2 - mouseX) / 60);
			    offs[0].y = offs[1].y = offs[2].y = offs[3].y = offs[0].y - Math.round((stage.stageHeight / 2 - mouseY) / 60);

				_hm.perlinNoise(RES / 2, RES / 2, 1, 5, false, true, 7, true, offs);
				_hm2.perlinNoise(RES / 2, RES / 2, 1, 25, false, true, 7, true, offs);
				_hm.draw(_hm2, null, EQUALIZE, BlendMode.DIFFERENCE, rect);
				_hm2.perlinNoise(RES / 2, RES / 2, 1, 45, false, false, 7, true, offs);
				_hm.draw(_hm2, null, EQUALIZE, BlendMode.DIFFERENCE, rect);
				noiseOffset[0].x = offs[0].x * SCALE;
				noiseOffset[0].y = offs[0].y * SCALE;
				_nm.perlinNoise(1, 1, 1, 5, false, true, 7, true, noiseOffset);
				_nm.threshold(_nm, _renderRect, pt, "<", 0x666666, 0x666666, 0xffffff, false);
				_nm.threshold(_nm, _renderRect, pt, ">", 0x999999, 0x999999, 0xffffff, false);
				draw();
				
				_render.fillRect(_renderRect, 0);
				_render.draw(_container, _renderMatrix, COLORTRANS, null, null);
				_render.draw(_nm, null, null, BlendMode.OVERLAY, _renderRect);
				_render.draw(_sm, null, null, BlendMode.OVERLAY, _renderRect);
				
			}	
			
			
		}
        
        //
        public static function getRedComponent (color:Number):Number {
            return color >> 16;
        }
        
        //
        public static function getGreenComponent (color:Number):Number {
            return color >> 8 & 0xff;
        }
        
        //  
        public static function getBlueComponent (color:Number):Number {
            return color & 0xff;
        }

    
        public static function getTintedColor (baseColor:Number, tintColor:Number, amount:Number):Number {
        
            var red:Number = getRedComponent(baseColor);
            var green:Number = getGreenComponent(baseColor);
            var blue:Number = getBlueComponent(baseColor);
            
            var tintRed:Number= getRedComponent(tintColor);
            var tintGreen:Number = getGreenComponent(tintColor);
            var tintBlue:Number = getBlueComponent(tintColor);
            
            return (red + (tintRed - red) * amount) << 16 | (green + (tintGreen - green) * amount) << 8 | (blue + (tintBlue - blue) * amount);
            
        }
    
    }	
	
}