// forked from Quasimondo's Ken Perlin generated from Perlin Noise
package
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    /*
    
    
        The Mona Lisa generated entirely from Perlin Noise
        
        Author: Mario Klingemann <mario@quasimondo.com>, Twitter: @quasimondo
        
        License: Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0) 
                 http://creativecommons.org/licenses/by-nc-sa/3.0/
    
    */
    public class PerlinPortrait extends Sprite
    {
                private var dat:String =   "78da4d525b48545114dd73e6dc7bf3915e65ae3a937ae7aaf3ba33cebb996b33ce8c56" +
                                   "9a15951f16e98745f420fac822c8ded9d31e204450595891108454441415d90ba20833" +
                                   "0b3f0aa108a19fc832e84146771f27ea6771d867edb5d7596767678901ebfc827346ad" +
                                   "a4fef041211e9fd9f480c3f3b080f8388d581fe710cf71ffea3718ee175061dc188e64" +
                                   "d5ed64b8c3a859e7aefa8a181c21e5d97ccd0049e6847cb368b512950e70c899c7982d" +
                                   "46d4ece57c41d3b89d4692b0bb01675d18e3146789618c625da1ced0d457b7f8b85ab3" +
                                   "f327912b2daf675397bd41d8c869b2faea265368e7629e453786f880755eff205f1a10" +
                                   "5fdce52517d97e95f7da555f0b1f95ac4d133433967bfd2d246cb0d440756f0fba8965" +
                                   "9a333f25d86d72af863ab7f79180ec79de4f428af3d335a2c9eebc5cd05f671ee67db6" +
                                   "82ae4754506ad71f019db9d402819ce96df504d5ce52afecddbf90c77a338413d2cb01" +
                                   "8855555faa24de2adf899360f7664d29e367287ef34762519d9d9f410d0a5d141ce169" +
                                   "8149fe1df07bb3369d810aad62284051b39d96883cb70cc45263df04986ca6c67b9028" +
                                   "ca7bb2972f0f0a9ddb08a6f183c8627d060f6e537c642de0ac2360d32a36ad42875d39" +
                                   "e04af8bbd7912275fef96cc024cba86af17fef303ab4d2e36e21bf30b9f53909a9f9bf" +
                                   "44a2a7b4729ce445c96f3f712444cb5ea2e73930c84f4ecfb5ce6e3f4ab077b5315229" +
                                   "d6f4739229f5e614afcf1dcdc0e9a3cfc0ed9e4e16815c5c376705f116967734134989" +
                                   "edee22bea0b4e417d82cda53155d1d980059acbbdfc9ba46201ab7649c06fd2fb6b5c1" +
                                   "0cd9f3a80d148fbbf71ee3d8a150928a3e41b8bae0e80528737306c2f84970398b3b65" +
                                   "c65fce345b419f757b38cd41853d0c3bc09fca7c18c64c6a0fa56f110dac773dc3c6b4" +
                                   "0ed6c5ffce068600514ddee0a7987033e0165969d851d00724153747bffca7d0c8f80a" +
                                   "3bd7303480c76e1835e2265c6c02cca4983894484f8ce22e7da3916a21994bf42d6abf" +
                                   "029a58b936057ae6ef627f7b7d532ef6a43d4ca22b52bcb890c85ae8fd0782f96c6619" +
                                   "ae4927369967954d39b1922904d0b97901382399c7244c608b9960563ec61f63de28e0" +
                                   "ef4ca45f5de5714477b1aed6f42bd0c365f803fae103ae";
        
        private const scale:Number = 1;
        
        private var displayMap:BitmapData;
        private var perlinCell:BitmapData;
        private var offsets:Vector.<Array>;
        private var baseOffsetsX:Vector.<Number>;
        private var baseOffsetsY:Vector.<Number>;
        private var p:Point;

        private var cellSize:int;
        private var cols:int;
        private var rows:int;
        private var d:Array;
        private var r:Rectangle;
        private var ba:ByteArray;
        
        public function PerlinPortrait()
        {
            stage.scaleMode = "noScale";
            stage.align = "TL";
            scaleX = scaleY = 2;
            init();
        }
        
        private function init():void
        {
            parseData();
            
            ba.position = 0;
            cellSize = ba.readUnsignedByte();
            cols = ba.readUnsignedByte();
            rows = ba.readUnsignedByte();
            
            displayMap = new BitmapData( cellSize * cols * scale, cellSize * rows * scale, false, 0 );
            addChild( new Bitmap(displayMap) );
            
            perlinCell = new BitmapData( (cellSize + 15) * scale, (cellSize + 15) * scale, false, 0 ); 
            offsets = new Vector.<Array>( cols*rows,true);
            baseOffsetsX = new Vector.<Number>(cols*rows,true);
            baseOffsetsY = new Vector.<Number>(cols*rows,true);
            
            for ( var i:int = 0; i < cols*rows; i++ )
            {
                var a:Array = [];
                for ( var j:int = 0; j < 4; j++ )
                {
                    a.push( new Point(1000*(Math.random()-Math.random()),1000*(Math.random()-Math.random())));
                }
                baseOffsetsX[i] = 64;
                baseOffsetsY[i] = 64;
                offsets[i] = a;
            }
            
            p = new Point(0,0);
            r = new Rectangle(0,0,cellSize * scale,cellSize * scale);
            
            stage.addEventListener(Event.ENTER_FRAME, render );
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown );
            
        }
        
        protected function parseData():void
        {
            ba = new ByteArray();
            for ( var i:int = 0; i < dat.length - (dat.length % 8); i+=8 )
            {
                ba.writeInt( parseInt( dat.substr(i,8), 16 ) );
            }
            
            while ( i < dat.length )
            {
                ba.writeByte( parseInt( dat.substr(i,2), 16 ) );
                i+=2;
            }
            
            ba.position = 0;
            ba.uncompress();
            
        }
        
        protected function onKeyDown(event:KeyboardEvent):void
        {
            for ( var i:int = 0; i < cols*rows; i++ )
            {
                baseOffsetsX[i] = 64;
                baseOffsetsY[i] = 64;
                for ( var j:int = 0; j < 4; j++ )
                {
                    offsets[i][j].x = 1000*(Math.random()-Math.random());
                    offsets[i][j].y = 1000*(Math.random()-Math.random());
                }
            }
        }
        
        protected function render(event:Event):void
        {
            displayMap.lock();
            p.x = p.y = 0;
            var j:int = 0;
            ba.position = 3;
            for ( var row:int = 0; row < rows; row++ )
            {
                p.y = row * cellSize * scale;
                for ( var col:int = 0; col < cols; col++ )
                {
                    p.x = col * cellSize * scale;
                    var baseX:int = ba.readUnsignedByte();
                    var baseY:int = ba.readUnsignedByte();
                    var seed:uint = (ba.readUnsignedByte() << 8) | ba.readUnsignedByte();
                    var xyoffsets:int = ba.readUnsignedByte();
                    var extras:int = ba.readUnsignedByte();
                    
                     //###################
                    // Here is where it happens:
                    perlinCell.perlinNoise( (baseX + baseOffsetsX[j])*scale,(baseY + baseOffsetsY[j])*scale,(extras >> 1) + 1,seed,false,(extras&1) == 1,7,false, offsets[j++] );
                    //###################
                    
                    r.x = (xyoffsets >> 4) * scale;
                    r.y = (xyoffsets & 15) * scale;
                    displayMap.copyPixels( perlinCell,r, p );
                }
            }
            
            for ( var i:int = 0; i < cols*rows; i++ )
            {
                baseOffsetsX[i] *= 0.94;
                baseOffsetsY[i] *= 0.94;
                
                for ( j = 0; j < 4; j++ )
                {
                    offsets[i][j].x *= 0.94;
                    offsets[i][j].y *= 0.94;
                }
            }
            displayMap.unlock();
        }
    }
}