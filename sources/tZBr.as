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
    
    
        A portrait of Ken Perlin, generated entirely from Perlin Noise
        
        Author: Mario Klingemann <mario@quasimondo.com>, Twitter: @quasimondo
        
        License: Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0) 
                 http://creativecommons.org/licenses/by-nc-sa/3.0/
    
    */
    public class PerlinPortrait extends Sprite
    {
        private var dat:String =   "78da93e0e6b4d35f79d292d5c436c7b286d1daeedeb5684619658f1faf99" +
                                   "e584965d38c160c93de7d343267b49bd054f99c40485b62c62b6b6bbbf7b" +
                                   "3fa3b9fd9923f719adec3ad7ac6435d63e2ede09d47b87ef0dd884f94013" +
                                   "bca3ee316898bd55ed61d0b58fb77cc700347f3e334864ae20139f499baa" +
                                   "153bc884f78c26b6d9efa3588ded0e7b6f667430f39ae6c3686caa573f8d" +
                                   "91d3284c2d9ec1d86eff392e165bcb5d399758aded6e85ae6396b7559a38" +
                                   "9745db41588b9d0564fb5e56900931ac40bda71340264cfcc008347f793e" +
                                   "ab988544d87f063bfd15f73599ac94b7f737b06a0bff94f8013441ce7a36" +
                                   "13a751a4a02ea3a5d9bd84ffcc2073ceb042f45ad9667ab330f26a59ef68" +
                                   "63b4b5dc7dd19ed5d2ecbedc7a061d6bc175fb5975edb699dbb30b1b9ae8" +
                                   "150275b56e646086980022cf3383f4ba024d489f5ac468a7cdbf429f51d7" +
                                   "a2f7621b93b1a94ea11da3a53d836e01bbb1a9e6ae036cc606f26afe4c96" +
                                   "f68c4aef196dec6cf3ff83c97f8c4071af3d60f214d89c0446113d23b757" +
                                   "c050bde5f40e18ce271e5b311b6b9f6e886531d63e1bcac06c6cb737c58a" +
                                   "15183e364b5861ec3dabb7835cbeda811118da0209409f86f49c61b034ac" +
                                   "bbc1c16a65d7e6ff022812116ac02c673b37dd98d5d29e43e83f23c4041b" +
                                   "9d0b8737b002c3ffeb44264bc989773e3388098afdba018c8543dbc3980c" +
                                   "948c8a7d1880b166fc8159dc2e6d1e1b8b89585a0e0393bdc8cb295f59cc" +
                                   "150b8efd6201b9c18e1500d36bc1dd"
        
        private const scale:Number = 1.75;
        
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
                    perlinCell.perlinNoise( (baseX + baseOffsetsX[j])*scale,(baseY + baseOffsetsY[j])*scale,(extras >> 1) + 1,seed,false,(extras&1) == 1,1,true, offsets[j++] );
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