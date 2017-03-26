// forked from Quasimondo's Mona Lisa generated from Perlin Noise
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
    
    
        Starry Night generated entirely from Perlin Noise
        
        Author: Mario Klingemann <mario@quasimondo.com>, Twitter: @quasimondo
        
        License: Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0) 
                 http://creativecommons.org/licenses/by-nc-sa/3.0/
    
    */
    public class PerlinPortrait extends Sprite
    {
      private var dat:String = "78da5d58797855d5b53f670f6767b853eebd39f79ee19e73c86012204c3110a60490c1240" +
                                 "cc100610e0811fb1445998ada28ad9617a60282a15aa622f451152c756206c1011f3cab881" +
                                 "42c48050587d260291081d0b5f64d3fbfbe7fd6b7bf73f6dde7b7d6faaddf5afbfa5cc363e6" +
                                 "b70d8aebeb32c4545c337a5351c2a18c11ed152ff3ee6d8a12e723df6d502c5f51ea0d45e723" +
                                 "0e5e63b6d63e704a7152a24d739438ebf0fa430ced1266b1eeef6c2368d791b87fecc24e78e64" +
                                 "3cd24f9d6e5fe3f5a24b9074f68567e5c9f5292bf4a3e89f3f1fb6c66fadc8274e230ff7fbfc" +
                                 "f3cd27fd809f995a5727d8159a1a2228504ecca2b4d8ae7f63995463c2fb4f6674a3ca49fba" +
                                 "83a69bbe3caada5efc1627ba5bf2e74bc448b4f97bbd1672fbb61b446c37f13fb79869b71b" +
                                 "b38a7b7abf77aed09831fa77cb34d3a8e9779d7a9915673a6be1f088059e88bbed3bbd483ca" +
                                 "34fd633c2757afcad9eb9b18e437670db6d77aa8fe6da95e3996645c2ab7769b6173cf31ec3d" +
                                 "ff6d3dcd8c4ca3ae6a6661cdea23afeb49d8ce3fa1515e2b9b2a7d062133e6a64ba31325723b0" +
                                 "7fc76616b527b5ade0f0c5453acf8cb165c354447891853d5fa7cf8967b72bb8a9c563e366fe" +
                                 "9a2192d7841d689f795375edc1c7cab48459907292e1ba831677ee9939497899e5ddb3e5cea" +
                                 "922e4f1375a304a9fce510dbbd3f3b7293e4f13ae9b18d340107fb9e6e8f15951a6bbf499e" +
                                 "52ceaeb5cf0bcb08d6187fc229e187e6994ea04edb5cb68c229e8b1863233f5f78fa8cc1e14" +
                                 "b9a0595ef1c61a0da3f13647fb05776ceb0f37e493733cea753eddc46cdd2b1f492cafe8f562" +
                                 "8291dc4470cf4d0d312c1490b5471dcd36aaedee8a670f3817d5629e3dfef732da2fe2dbaa621" +
                                 "e4f545d9cad624cca54c073f42d16f3ac454789e384dd12dc99fe0cb733e994c954f7bace573" +
                                 "862eeaeba5ed7ef9ea28e17bf11a190fd737d298b0c9dd2a4c2b7da04e5f95cb85e97d14328" +
                                 "a25d21f17fc231771419527610f6949d6ea26946e1b333b86dfb364c22b8e7b778fee2a7a8" +
                                 "ee145f4a85ccba8bae5188cf86253ce61ff3e036d534fa3d384844435dd23b09ccf54f05642" +
                                 "7d6a026cf477b81c75d6bec40a1dbd93ddf54e15b13ea8057ddca1519ed17d4983d684f96807" +
                                 "3c64de110b75dabf98fc803c43506df1820d0eb2c9e8c219ef90f8e31cc57b4d8c46def11a8d3" +
                                 "47b81a4e4d889b027955ca1dd7daba4e759dbc1e476988f5d2be54a1bece7ea1c65874eb16ee" +
                                 "f74f8817513db5f7d1be34e046f63c2cf444f6910a8138eba417874530603e7c9d9a4eceb9d" +
                                 "bc2d4efd22b79c42dd1f238e28c7388f0b05c9e70dba4beac3abad7b72b4f75fb5e7a4f404" +
                                 "df9f278c0a8f9f3e71a7877f09fe8efd8351432fb75930639cab92199b04a64d8fafacf59" +
                                 "c2ca9f562d40312afe8b6384036ac00b3fb641e03aa85a196945d708fa324a4d580563fe" +
                                 "443117c72954d395011c31cf12e1f0b0da691cce1f9fa6d9aeb7660d37a359cd730470b" +
                                 "5e1acea78694f14ca5f1da44ec0ec1f92f863dc71f29ff80387c8ef9e2f9c14f3dc364" +
                                 "e636d4ff9681239d6da5a35cde7f6e8c31da374d75561a5330e156a06f7bdcb33bd94" +
                                 "6b1319787a6438c3b7e705d475cdcf5550a7c2fdc0d87b728e31a8ca050f69e18853" +
                                 "5e24229c3fde8f27129907375364cb7bc20a861a9b44309172633c46e9da26acdcf" +
                                 "407b8a167fd7cb6eaba56bbcbc2b473eb7742bd578e5907ca102c3dc223beced55" +
                                 "754b07d8f099dfb6ba290ebdaf3db55acd0496a12b963e5cfdd422db7fb0b4b79" +
                                 "38d0e6ab4a0e38dbcce42c40662dc36a9afb8a023af681a141f6773d47add09d" +
                                 "0bb751bf4ff92cac8262bc16e4294e6ebb4150295d3fbb2d52fc697bfa09572" +
                                 "f9efe0b15b4e8780335edfc2cc842acb660a26a3bd5554714647b5cc51c8d9" +
                                 "368b7a9f8244505f5d8bc94da56872e9da9670f1c711f0536661f5211f349" +
                                 "44b278150555b9f3184ff30aaf3ecc604ff17961d9d60ff3808115332a45" +
                                 "c20b3dfa83ea3323cb3730c09368524256ff735718b0d1778e01ff1f7f5" +
                                 "4a0c6ae5043a1bb8e7756a152760d01266bbe3a1eb7f55f950a88e7fca" +
                                 "12afab8979aa10caf5240cd2eaf810c165e48176620657439aadf2f91" +
                                 "5df9d3aa04d6cb618a15572dab58a8883f8722f7ce21fe1e2b6824b5" +
                                 "d7c6260e0cbcfa4764cbfa1dc4f0753af40e4420515ccbe15b539f5" +
                                 "35dab63ef27d568acf6a7d3481239a29d22a06a961e20705acd0c0" +
                                 "d235681313f5247a17e591f9a66155e7e1d54fa8e2645aafd6d35" +
                                 "1aa5df2aaa17b086be0f68b33b7bc09f9aca8b04bac6fd7d54b4" +
                                 "6115f95fcd3dfb6eb72deac9e29532cecb54239a35fdaa40a5d" +
                                 "a07ba51563f036b64afcda99177792e4d71d2b5ad2cc5c9692" +
                                 "2a078438f3fa8024f8e4d14108ddc3c44f5d152d06de36099" +
                                 "029a59b712bbc96b1d399ef9a5307cd9139a8597c6c7b448" +
                                 "e48d143ad12b5fc1777b9cf99e1b89acb7cf70c7e70eaf1" +
                                 "719d1bcbdf7728c2491acfe4278a9e5ab6f52e4f32d9ea" +
                                 "6bbf5efaba82d099e70f22fcce1ba3fd0ff25ec025bff" +
                                 "81aa7bfb0aeac6de2877fc64ca31eca157b7b4224776" +
                                 "3d49f157d338b0e2b30ec0c9f169b52aac9b77c998b" +
                                 "faa20fef68a6eb6bfd94ea0a7618aaadb596aef706" +
                                 "99761e5cea634eaf93efd54ea497f0133ccb23a99" +
                                 "9dc532f2d720aa55574b28ecec3e04999c7f5cd" +
                                 "6fb02d5b4ee58d542206b639e54a1e2b6f5a61" +
                                 "0a56f667157ef96d5819a3adffbb64005bb4e" +
                                 "90272da415394463214c05e51b9b29ae47c97a" +
                                 "598915117415d38ced188eb3caf4f5c40806235" +
                                 "52a603bb144aa567f6947408fe8daeb0901dfbab" +
                                 "65f7696df088ced01e15af9651370a2b87f20f48e" +
                                 "612dbf10ffee5969bb1ee3a0ff879f5721fefbaea9" +
                                 "98c11bc24c64ddbf5e75cc909342435afb0917a81b" +
                                 "ea327b3211427b60b0e204530e6e5698312268b0807" +
                                 "7e7fe9d44d7da7d5b2dc25acfb2166a848ca99fc82e" +
                                 "f3820a98dffa90e84eb7fbb265e4f783c2b4bdf55754c836f7cbdcb51168274bfb86c0be5346c322f4be2b513d84dc9b7e1478d5e9ab25" +
                                 "c231631b66e06c56bd9fba1999b59eb433900963b773443e493842ef9846616e64991cf315c18962be47d0ce20a6eb18a3b0fb977ca224" +
                                 "2b34cec7f98e4206475c3f0573829573962333b3b869eb874a145d6f73ecff64cc5f259956e1d42e1ac4f6d11d2cc27afb56a88994b459" +
                                 "d344d06feedb0d7da4ea2fbbb19336e48a381f7bfe188739d67d830645e8af0d5c4f898f2ca098f19dc4f4bbab276a8ecfbecc343d927b" +
                                 "b24cb819b1b7ff4280eda14ba85df327134b2f3a5dc7b0a22713f06eea7a690f90a42a26912732f8c572d422a30a27c9868122c27a5e75" +
                                 "55f4319f22fe9f2870426915833efb7423c3e7b3a8116007965123e85bf83247aebeabe264f51daad3c23d107963b00d75c7f75709d0b7" +
                                 "eae52ae8e1f925728afb92e39306d54924ee5a06b55fdc7731815e36fa4d0219a9fa9824f738667cda1ca98d5da52a1ea149b54c22479e" +
                                 "6f439e9716924428f4f5028175d40c3d6bc4c92291ec9e88bc423113d9dac70ceb742828a493ba58ae7b2b869e3dbb5c43241be5547c0d" +
                                 "f4bf78405705d469ee600de2b0778886755d2a92fd119e3c9b25a0171f680f6f2b4eefc60939b6535656858a3da251ae9fc099eaf1d791" +
                                 "6927a7d0b8933a4695eab45605b6f0755a4a24f7f801f47a405bc0e6b41ba9b97a3c348ad8ce3de72e4a5ef5a758a1026792c017b22b9d" +
                                 "6dd5195cff49ae7b2ab87324455b47f18b33e5cc360f15b8aa173763e2a30d38799e1e8cddbfdf1a05df6e966feb315f33e73223d6f6cd" +
                                 "1a0d6e43a3fa422f2e1ef4888838ddb6f746df9f1ecd40a9f6bd86f3ff97e9ad6c813970530f89f02eac94c629c4f0f41c4bfaf2402baa" +
                                 "2442d3a54b4613f4621481af5bd795562fc0a36799e3a5dc5eafe0bd6315c3e95d10db2a3cf8aa627977ce798edb666cd368e8d4032efd" +
                                 "139896d7ff69646c554f8e0c69943c5929310ca7f0c54326de25e7391a66b34e73cdfc8db578039a3255839bc8e861043ad1994d5a12b9" +
                                 "9dd095ff55e0845fb6c07cd8efc40a79ce208aa80eb064278289ae715d2b5bf0f94186f66396544b984e7b6dd6eca837a81939706f3e83" +
                                 "2a5ef03b96ea84061f9653d67cf02ebd54e0bae14399d9b9a0185593af32f0eec40606753da999808f8ba62a98f1b708e2ec28ef329558" +
                                 "b981fe12551505e4173669cca83ec114b8bf8c7b40fe8a6124d7fe4cd6606f0a6cdcbc5ed67898a142ae2350a16deb30622bbf96192995" +
                                 "5eac92b560283075dc6b288e61747f19e25651e1c24c5836e3030d99304c835962c62c061df6c663706b2bd9731bf72c780578d8bbf65b" +
                                 "0233c9e7a99ae733bff6a3d6add94760e7f7a606d34ee177cce0bccb40e2a4f6def10e413de78c3a39bb7f0bf7af8199cb1946fb18eab6" +
                                 "bd15cffcd50aec416f2d214956a02f353459ad88b952412fee23498f92f647e68f53ac48c6871365c687e0cd74c18b9a9bae364e849b78" +
                                 "56d7a710fff716dc22637ba6e3ad795219c6bfe8192d9148ebf7929211ecf15c27160ff0dc3c8c55fd3c89ed1b12cb48bd4f306e0f78a3" +
                                 "bc35e6f87c2371a279714612aed7d2c2fcb6a97f20f1cf6fe539aafa6292eca790f1697b659cdb2ab8ae6f6514eacf7e9825dc43dd8869" +
                                 "dcb1395b830e3b6f0bde53d62e62118fe6bfa421729da147d3258b0a9861b69d3f8ac56291ecb31ae63d8a676e7c10eef577aff323676a" +
                                 "2e4a7dd88e33ed3d9e8677e7159a1ef0455215e8bf6b1bc9ffb77389ced25f5dc56c2a4a562b68ef96b64489f1f0a65bad5627d9dfccf9" +
                                 "8f27b8e7278a110ade2b1423e07b384731c3f4f20f8a919edaa745feb71394d655a05b6d67f2572dad16f71c6d7d8eeb338a217ce51572" +
                                 "7da9751d157e51a6fc0b3f6a2d06";  
        
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
            scaleX = scaleY = 1.25;
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