package {
    import flash.display.*;
    import flash.text.*;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            // write as3 code here..
            var s:Sprite = new Sprite;
            
            var tf:TextField = new TextField();
            tf.selectable = false;
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.defaultTextFormat = new TextFormat('Verdana', 80, 0, true);
            tf.text = 'Wonderfl';
            tf.x = (465 - tf.width) / 2;
            tf.y = (465 - tf.height) / 2;
            s.addChild (tf);
            
            var wooden:WoodTexture = new WoodTexture (s);
            wooden.generate ();
            addChild (wooden);
        }
    }
}

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.filters.BlurFilter;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.display.BitmapDataChannel;
	
	/**
	 * Stolen from http://www.flashandmath.com/flashcs5/wood/
	 */
	class WoodTexture extends Sprite {
				
		private var perlinData:BitmapData;
		private var displayWidth:Number;
		private var displayHeight:Number;
		private var displayData:BitmapData;
		private var displayBitmap:Bitmap;
		private var origin:Point;
		private var blur:BlurFilter;
		private var colors:Vector.<uint>;
		private var rArray:Array;
		private var gArray:Array;
		private var bArray:Array;
		private var sourceSprite:Sprite;
		private var sourceBitmapData:BitmapData;
		private var sourceBitmap:Bitmap;
		private var woodPatternData:BitmapData;
		private var scale:Number;
		private var inGlow:GlowFilter;
		
		public var colorList:Vector.<uint>;
		public var perlinBaseX:int;
		public var perlinBaseY:int;
		public var roundingAmount:Number;
		public var roundingSize:Number;
		
		function WoodTexture(inputSprite:Sprite):void {
			
			sourceSprite = inputSprite;
			
			//We need to know the bounds for the graphics of the sprite, so we can create a bitmap overlay that is of the right size and position.
			var boundsRect:Rectangle = sourceSprite.getBounds(sourceSprite);
			displayWidth = boundsRect.width;
			displayHeight = boundsRect.height;

			//we first draw the source sprite to a bitmap. This will be used to set the alpha of the pixels in the texture.
			sourceBitmapData = new BitmapData(displayWidth, displayHeight, true, 0x00000000);
			sourceBitmap = new Bitmap(sourceBitmapData);
			sourceBitmapData.draw(sourceSprite,new Matrix(1,0,0,1,-boundsRect.x,-boundsRect.y),null,null,null,true);
			
			//So that this will be an interactive sprite of the same shape as the input sprite, we will add the
			//input Sprite as a child of the textured sprite created here, and then set the hit area of
			//this sprite to be the input sprite. But we will make this child invisible (alpha = 0) to ensure
			//that only the texture will be visible.			
			this.addChild(sourceSprite);
			sourceSprite.alpha = 0;
			this.hitArea = sourceSprite;
						
			roundingAmount = 0.4;
			roundingSize = 6;
			
			//The variable 'scale' is an "oversampling" factor that provides a smoother texture. The texture bitmap
			//will be created twice as wide and high as the sprite, and then scaled down by a factor of 2 to match
			//the dimensions of the sprite.
			scale = 2;
			
			perlinBaseX = 50;
			perlinBaseY = 600;
			
			woodPatternData  = new BitmapData(scale*displayWidth, scale*displayHeight, true, 0x00000000);
			
			perlinData = new BitmapData(scale*displayWidth, scale*displayHeight, false, 0x000000);
			displayData = new BitmapData(displayWidth, displayHeight, true, 0x00000000);
			displayBitmap = new Bitmap(displayData, "auto", true);
				
			displayBitmap.x = boundsRect.x;
			displayBitmap.y = boundsRect.y;
			
			this.addChild(displayBitmap);
						
			origin = new Point(0,0);
			blur = new BlurFilter(2,2);
			
			colorList = new <uint>[0xd78e41,0xd8994a, 0xcc7d38, 0xb86a2c, 0xae531c];
		}
						
		public function generate():void {
			setColorThresholds();
			fillPerlinNoise();
			makeRegularColorBands();
			mapWoodToDisplay();
			setFilter();
		}
		
		private function setFilter():void {
			if (roundingAmount != 0) {
				inGlow = new GlowFilter(0x000000,roundingAmount,roundingSize,roundingSize,2,3,true,false);
				displayBitmap.filters = [inGlow];
			}
			else {
				displayBitmap.filters = [];
			}
		}
		
		private function mapWoodToDisplay():void {
			displayData.draw(woodPatternData, new Matrix(1/scale, 0, 0, 1/scale), null, null, null, true);
			//manual masking done by copying the alpha of the source sprite to the display bitmap:
			displayData.copyChannel(sourceBitmapData, sourceBitmapData.rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		}
		
		private function setColorThresholds():void {
			var numBands:int = 80;
			var r:uint;
			var g:uint;
			var b:uint;
			var i:int;
			var index:int;
			var color:uint;
			var rInitArray:Array = new Array();
			var gInitArray:Array = new Array();
			var bInitArray:Array = new Array();
			rArray = new Array();
			gArray = new Array();
			bArray = new Array();
			
			//we have to reset the color choice list:
			var colorChoices:Vector.<uint> = new Vector.<uint>();
			var len:int = colorList.length
			for (i = 0; i < len; i++) {
				var thisColor:uint = colorList[i];
				colorChoices.push(thisColor);
			}
			
			//in the loop below, we are choosing colors randomly from our color list, but in such a way as 
			//to avoid the same color being selected twice in sequence. This is accomplished by always removing the 
			//last chosen color from the color list before making the next choice.
			var choiceIndex:int;
			var lastChoice:uint = colorChoices.splice(0,1)[0];
			
			for (i = 0; i <= numBands; i++) {
				choiceIndex = Math.floor(Math.random()*colorChoices.length)
				color = colorChoices[choiceIndex];
				
				r = color & 0xFF0000;
				g = color & 0xFF00;
				b = color & 0xFF;
				
				rInitArray.push(r);
				gInitArray.push(g);
				bInitArray.push(b);
				
				//remove this chosen color:
				colorChoices.splice(choiceIndex,1);
				//put last choice back in:
				colorChoices.push(lastChoice);
				//set last choice to one chosen in this loop:
				lastChoice = color;
			}
			
			for (i = 0; i <= 255; i++) {
				index = int(i/255*(numBands-1));
				rArray.push(rInitArray[index]);
				gArray.push(gInitArray[index]);
				bArray.push(bInitArray[index]);
			}
			
		}
		
		private function makeRegularColorBands():void {
			woodPatternData.paletteMap(perlinData, perlinData.rect, origin, rArray, gArray, bArray);
		}
				
		private function fillPerlinNoise():void {
			perlinData.perlinNoise(perlinBaseX, perlinBaseY, 4, Math.random()*0xFFFFFF, false, true, 7, true);
			perlinData.applyFilter(perlinData, perlinData.rect, new Point(), new BlurFilter(6,6));
		}

	}