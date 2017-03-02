package {
    import com.bit101.components.InputText;
    import com.bit101.components.Label;
    import com.bit101.components.NumericStepper;
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;

    public class FlashTest extends Sprite {
        
        public var colors:Array = [0xea4b35, 0x1aaf5d, 0x217fbc, 0xf3c500, 0x8f3fb0]; //0x1aaf5d];
        
        public var mainBitmap:Bitmap;
        public var mainBitmapData:BitmapData;
        
        public var cells:Vector.<Vector.<int>>;
        
        public var tile_width:int = 8;
        public var tile_height:int = 8;
        public var tileNum_X:int = 58;
        public var tileNum_Y:int = 50;
        
        public var gridSprite:Sprite;
       
        public var PRNG_gen:PM_PRNG;
        public var seed:int = Math.random() * int.MAX_VALUE;
        
        public var eraseCellNum:int = 50;
        public var raceNum:int = 3;
        
        public var emptyArr:Array = [0, tileNum_X - 1, (tileNum_Y - 1) * tileNum_X, tileNum_X * tileNum_Y - 1];
        public var dir:Array = [[ -1, -1], [ -1, 0], [ -1, 1], [0, 1], [1, 1], [1, 0], [1, -1], [0, -1]];
        public var happyNeighborNum:Array = [0, 1, 1, 2, 2, 2, 3, 3, 3];
        public var escapeTryNum:int = 5;
        
        public var _randomSeedInputText:InputText;
        public var happyLabel:Label;

        public function FlashTest() {
            // write as3 code here..
            PRNG_gen = new PM_PRNG();
            PRNG_gen.seed = seed;
            
            mainBitmapData = new BitmapData(465, 465, false, 0x292929);
            mainBitmap = new Bitmap(mainBitmapData);
            addChild(mainBitmap);
            
            var i:int, j:int;

            gridSprite = new Sprite(); //draw Line
            gridSprite.graphics.lineStyle(0, 0x7f7f7f);
           
            for (i = 0; i < tileNum_X + 1; i += 1)
            {
                gridSprite.graphics.moveTo(i * tile_width, 0);
                gridSprite.graphics.lineTo(i * tile_width, tileNum_Y * tile_height);
            }
            for (i = 0; i < tileNum_Y + 1; i += 1)
            {
                gridSprite.graphics.moveTo(0, i * tile_height);
                gridSprite.graphics.lineTo(tileNum_X * tile_width, i * tile_height);
            }
            
            addChild(gridSprite);
            
            cells = new Vector.<Vector.<int>>(tileNum_Y);
            for (i = 0; i < tileNum_Y; i += 1)
            {
                cells[i] = new Vector.<int>(tileNum_X);
                
                for (j = 0; j < tileNum_X; j += 1)
                {
                    //cells[i][j] = (i % 2 == j % 2) ? 1 : 2;
                    cells[i][j] = int(PRNG_gen.nextDouble() * raceNum) + 1;
                }
            }
            
            for (i = 0; i < emptyArr.length; i += 1)
            {
                var tx:int = emptyArr[i] % tileNum_X;
                var ty:int = emptyArr[i] / tileNum_X;
                cells[ty][tx] = 0;
            }
            
            //cells[0][0] = 0;
            //cells[0][tileNum_X - 1] = 0;
            //cells[tileNum_Y - 1][0] = 0;
            //cells[tileNum_Y - 1][tileNum_X - 1] = 0;
            
            var _randomSeedLabel:Label = new Label(this, 10, tile_height * tileNum_Y + 10, "Random Seed");
            _randomSeedInputText = new InputText(this, _randomSeedLabel.x + _randomSeedLabel.width + 5, _randomSeedLabel.y, String(seed));
            _randomSeedInputText.restrict = "0-9";
            var _randomSeedButton:PushButton = new PushButton(this, _randomSeedInputText.x + _randomSeedInputText.width + 5, _randomSeedInputText.y, "Another Seed", 
                function(e:Event):void    
                {
                    _randomSeedInputText.text = String(int(Math.random() * int.MAX_VALUE));
                }
            );
            var _resetButton:PushButton = new PushButton(this, _randomSeedButton.x + _randomSeedButton.width + 5, _randomSeedButton.y, "Reset", onReset);
            
            var _eraseRandomCellButton:PushButton = new PushButton(this, _randomSeedLabel.x, _randomSeedLabel.y + _randomSeedLabel.height + 10, "Erase Cell", eraseRandomCells);
            var _segregateButton:PushButton = new PushButton(this, _eraseRandomCellButton.x + _eraseRandomCellButton.width + 5, _eraseRandomCellButton.y, "Do One Cycle", doSegregateOnce);
            happyLabel = new Label(this, _segregateButton.x + _segregateButton.width + 5, _segregateButton.y, "");
            var _raceLabel:Label = new Label(this, happyLabel.x + 80 + 10, happyLabel.y, "Race Num : ");
            var _raceNumNumericStepper:NumericStepper = new NumericStepper(this, _raceLabel.x + 50 + 5, _raceLabel.y, 
                function(e:Event):void
                {
                    raceNum = e.target.value;
                }
            );
            _raceNumNumericStepper.minimum = 2;
            _raceNumNumericStepper.maximum = 5;
            _raceNumNumericStepper.value = raceNum;
            
            drawCell(cells);
            calcHappyPercent(cells);
       }
       
       private function isHappy(i:int, j:int, color:int):Boolean
        {
            var neighborNum:int = 0;
            var sameNeighbor:int = 0;
            var k:int;
            var tx:int, ty:int;
            
            for (k = 0; k < dir.length; k += 1)
            {
                ty = i + dir[k][0];
                tx = j + dir[k][1];
                
                if (tx >= 0 &&
                    tx <= tileNum_X - 1 &&
                    ty >= 0 &&
                    ty <= tileNum_Y - 1)
                {
                    if (cells[ty][tx] != 0)
                    {
                        neighborNum += 1;
                        if (color == cells[ty][tx])
                        {
                            sameNeighbor += 1;
                        }
                    }
                }
            }
            
            if (happyNeighborNum[neighborNum] > sameNeighbor)
            {

                return false;
            }
            else
            {
                return true;
            }
         }
        
        private function doSegregateOnce(e:Event = null):void
        {
            var i:int, j:int;
            var temp:int;
            var k:int;
            var isMoved:Boolean;
            
            for (i = 0; i < tileNum_Y; i += 1)
            {
                for (j = 0; j < tileNum_X; j += 1)
                {
                    if (isHappy(i, j, cells[i][j]) == false)
                    {
                        isMoved = false;
                        for (k = 0; k < escapeTryNum; k += 1)
                        {
                            temp = emptyArr[int(PRNG_gen.nextDouble() * emptyArr.length)];
                            
                            if (isHappy(int(temp / tileNum_X), temp % tileNum_X, cells[i][j]) == true)
                            {
                                cells[int(temp / tileNum_X)][temp % tileNum_X] = cells[i][j];
                                cells[i][j] = 0;
                                
                                emptyArr.splice(temp, 1);
                                emptyArr.push(i * tileNum_X + j);
                                isMoved = true;
                                break;
                            }
                            
                        }
                        
                        if (isMoved == false)
                        {
                            cells[i][j] = 0; //dead
                        }
                    }
                    
                }
            }
            
            drawCell(cells);
            calcHappyPercent(cells);
        }
        
        private function calcHappyPercent(cells:Vector.<Vector.<int>>):void
        {
            var happyNum:int = 0;
            var allNum:int = 0;
            var i:int, j:int;
            
            for (i = 0; i < tileNum_Y; i += 1)
            {
                for (j = 0; j < tileNum_X; j += 1)
                {
                    if (cells[i][j] > 0)
                    {
                        allNum += 1;
                        if (isHappy(i, j, cells[i][j]) == true)
                        {
                            happyNum += 1;
                        }
                    }
                }
            }
            
            
            happyLabel.text = "Happy : " + String(int(happyNum / allNum * 10000) / 100) + "%";
        }
        
        private function onReset(e:Event = null):void
        {
            var i:int, j:int;
            
            PRNG_gen.seed = parseInt(_randomSeedInputText.text);
            emptyArr = [0, tileNum_X - 1, (tileNum_Y - 1) * tileNum_X, tileNum_X * tileNum_Y - 1];
            
            cells = new Vector.<Vector.<int>>(tileNum_Y);
            for (i = 0; i < tileNum_Y; i += 1)
            {
                cells[i] = new Vector.<int>(tileNum_X);
                
                for (j = 0; j < tileNum_X; j += 1)
                {
                    //cells[i][j] = (i % 2 == j % 2) ? 1 : 2;
                    cells[i][j] = int(PRNG_gen.nextDouble() * raceNum) + 1;
                }
            }
            
            for (i = 0; i < emptyArr.length; i += 1)
            {
                var tx:int = emptyArr[i] % tileNum_X;
                var ty:int = emptyArr[i] / tileNum_X;
                cells[ty][tx] = 0;
            }
            
            drawCell(cells);
            calcHappyPercent(cells);
        }
       
        private function eraseRandomCells(e:Event = null):void
        {
            var i:int;
            emptyArr = emptyArr.concat(printRandomNumber(tileNum_X * tileNum_Y, eraseCellNum));
            var tempX:int, tempY:int;
            
            for (i = 0; i < emptyArr.length; i += 1)
            {
                tempX = emptyArr[i] % tileNum_X;
                tempY = emptyArr[i] / tileNum_X;
                
                cells[tempY][tempX] = 0;
            }
            
            drawCell(cells);
            calcHappyPercent(cells);

           
            //trace(emptyArr);
        }
        
        private function printRandomNumber(n:int, k:int) : Array
        {
            var original:Array=[];
            var result:Array=[];
            var i:int;
            var randInt:int;
            var temp:Object;
            
            for(i=0;i<n;i+=1)
            {
                original.push(i);
            }
            
            for(i=0;i<k;i+=1)
            {
                randInt = PRNG_gen.nextDouble() * (n - i) + i;
                temp = original[i];
                original[i] = original[randInt];
                original[randInt] = temp;
                result.push(original[i]);
            }
            
            return result;
        }
        
        private function drawCell(cells:Vector.<Vector.<int>>):void
        {
            mainBitmapData.fillRect(mainBitmapData.rect, 0x292929);
            
            var i:int, j:int;
           
            for (i = 0; i < tileNum_Y; i += 1)
            {
                for (j = 0; j < tileNum_X; j += 1)
                {
                    mainBitmapData.fillRect(new Rectangle(j * tile_width +1, i * tile_height + 1, tile_width - 2, tile_height - 2), colors[cells[i][j] - 1]);
                }
            }
        }
    }
}

/*
 * Copyright (c) 2009 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/**
 * Implementation of the Park Miller (1988) "minimal standard" linear 
 * congruential pseudo-random number generator.
 * 
 * For a full explanation visit: http://www.firstpr.com.au/dsp/rand31/
 * 
 * The generator uses a modulus constant (m) of 2^31 - 1 which is a
 * Mersenne Prime number and a full-period-multiplier of 16807.
 * Output is a 31 bit unsigned integer. The range of values output is
 * 1 to 2,147,483,646 (2^31-1) and the seed must be in this range too.
 * 
 * David G. Carta's optimisation which needs only 32 bit integer math,
 * and no division is actually *slower* in flash (both AS2 & AS3) so
 * it's better to use the double-precision floating point version.
 * 
 * @author Michael Baczynski, www.polygonal.de
 */
Class
{
    class PM_PRNG
    {
        /**
         * set seed with a 31 bit unsigned integer
         * between 1 and 0X7FFFFFFE inclusive. don't use 0!
         */
        public var seed:uint;
        
        public function PM_PRNG()
        {
            seed = 1;
        }

       
        /**
         * provides the next pseudorandom number
         * as an unsigned integer (31 bits)
         */
        public function nextInt():uint
        {
            return gen();
        }
        
        /**
         * provides the next pseudorandom number
         * as a float between nearly 0 and nearly 1.0.
         */
        public function nextDouble():Number
        {
           return (gen() / 2147483647);
        }
       
        /**
         * provides the next pseudorandom number
         * as an unsigned integer (31 bits) betweeen
         * a given range.
         */
        public function nextIntRange(min:Number, max:Number):uint
        {
            min -= .4999;
            max += .4999;
            return Math.round(min + ((max - min) * nextDouble()));
        }
        
        /**
         * provides the next pseudorandom number
         * as a float between a given range.
         */
        public function nextDoubleRange(min:Number, max:Number):Number
        {
            return min + ((max - min) * nextDouble());
        }

       

       /**
         * generator:
         * new-value = (old-value * 16807) mod (2^31 - 1)
         */
        private function gen():uint
        {
            //integer version 1, for max int 2^46 - 1 or larger.
            return seed = (seed * 16807) % 2147483647;
            

           /**
            * integer version 2, for max int 2^31 - 1 (slowest)
            */
           //var test:int = 16807 * (seed % 127773 >> 0) - 2836 * (seed / 127773 >> 0);
           //return seed = (test > 0 ? test : test + 2147483647);
           
           /**
             * david g. carta's optimisation is 15% slower than integer version 1
             */
            //var hi:uint = 16807 * (seed >> 16);
            //var lo:uint = 16807 * (seed & 0xFFFF) + ((hi & 0x7FFF) << 16) + (hi >> 15);
            //return seed = (lo > 0x7FFFFFFF ? lo - 0x7FFFFFFF : lo);
        }
    }
}