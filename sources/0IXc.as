// forked from tencho's moja race
package {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.text.*;
    import flash.net.*;
    import flash.ui.*;
    import flash.utils.*;
    [SWF(width="465",height="465")]
    public class Sunset extends Sprite {
        private var _texture:BitmapData;
        private var _rect:Rectangle;
        private var _textureRoad:BitmapData;
        private var _textureCars:BitmapData;
        private var _matrix:Matrix;
        private var _avatars:Sprite;
        private var _music:Loader;

        public function Sunset() {
            _texture = new BitmapData (1024, 1024, true, 0xFF773311);
            _rect = _texture.rect;

            //テクスチャに雲の影とノイズを焼き込む
            var noise:BitmapData = _texture.clone();
            noise.perlinNoise(150, 150, 5, Math.random() * 300, true, true, 7, true);
            noise.threshold(noise, noise.rect, new Point(), "<=", 0xFF90FFFF, 0x00000000);
            noise.applyFilter(noise, noise.rect, new Point(), new BlurFilter(32, 32, 2));
            noise.colorTransform(noise.rect, new ColorTransform(1, 1, 1, 0.7));
            _texture.draw(noise, null, null, BlendMode.MULTIPLY);
            noise.noise(123, 0x0, 0x30, 7, true);
            _texture.draw(noise, null, null, BlendMode.SUBTRACT);

            _textureRoad = _texture.clone ();
            _textureCars = new BitmapData (1024, 1024, true, 0);

            // burn the road
            var i:int, cmf:ColorMatrixFilter = new ColorMatrixFilter;
            for (i = 0; i < 58; i++) {
                var a:Number = Math.max (0, Math.min (29 / 6 - Math.abs (i - 29) / 6, 1));
                cmf.matrix = [
                    1.0 - 0.7 * a, 0.3 * a, 0.3 * a, 0, 0,
                    0.3 * a, 1.0 - 0.7 * a, 0.3 * a, 0, 0,
                    0.3 * a, 0.3 * a, 1.0 - 0.7 * a, 0, 0,
                    -0.3 * a, 0, 0, 1, 0
                ];
                var j:int = _texture.width / 2 + i - 6;
                _texture.applyFilter (_textureRoad, new Rectangle (j, 0, 1, _texture.height),
                    new Point (j, 0), cmf);
            }

            cmf.matrix = [
                0.2, 0, 0, 0, 90,
                0, 0.2, 0, 0, 70,
                0, 0, 0.2, 0, 0,
                0, 0, 0, 0, 255
            ];
            for (i = 0; i < _texture.height; i += 128) {
                _texture.applyFilter (_textureRoad, new Rectangle (/* whatever */0, i, 1, 37),
                    new Point (23 + _texture.width / 2, i), cmf);
            }

            // https://en.wikipedia.org/wiki/Mode_7
            var road:Shape = new Shape;
            var cars:Shape = new Shape;
            _matrix = new Matrix;
            for (i = 4; i < 200; i++) {
                _matrix.a = _matrix.d = i / 20;
                _matrix.ty = 100 * (i + 200) / i + /* some offset to hide the cars */600;
                _matrix.tx = (465 / 2 * (200 - i) - 10 * _texture.width / 2 * i) / 200;
                road.graphics.beginBitmapFill (_textureRoad, _matrix);
                road.graphics.drawRect (0, i, 465, 1);
                cars.graphics.beginBitmapFill (_textureCars, _matrix);
                cars.graphics.drawRect (0, i, 465, 1);
            }
            road.y = cars.y = 465 - 200;
            addChild (road);
            addChild (cars);

            // sun
            var sun:Shape = new Shape;
            _matrix.createGradientBox (465, 465, Math.PI / 2, 0, -90);
            sun.graphics.beginGradientFill (
                GradientType.RADIAL,
                [0xdddaaa,0xca3526,0xbe1111,0x500000],
                [1,1,1,1], [25,30,50,255], _matrix, 'pad', 'rgb', 0.35
            );
            sun.graphics.drawRect (0, 0, 465, road.y);
            addChild (sun);

            // reflection
            var ref:Shape = new Shape;
            _matrix.createGradientBox (465, 200, 0, 0, 0);
            ref.graphics.beginGradientFill (
                GradientType.LINEAR,
                [0x333333,0xca3526,0xfffccc,0xfffccc,0xca3526,0x333333],
                [1,1,1,1,1,1], [0,110,120,/*116,140,*/136,146,255], _matrix
            );
            ref.graphics.drawRect (0, 0, 465, 200);
            ref.y = 465 - 200;
            addChildAt (ref, 0);

            // fog
            var fog:Shape = new Shape;
            _matrix.createGradientBox (465, 200, Math.PI / 2, 0, 0);
            fog.graphics.beginGradientFill (
                GradientType.LINEAR,
                [0x5a3137,0x500000,0x500000,0x500000,0x500000],
                [0,0.5,1,1,0], [0,20,30,50,255], _matrix
            );
            fog.graphics.drawRect (0, 0, 465, 200);
            fog.y = 465 - 200 - 200 * 30 / 255;
            addChild (fog);


            _avatars = new Sprite;
            _avatars.mouseEnabled = false;
            _avatars.x = 465 / 2;
            _avatars.y = 465 - 200 - /* hack */30;
            addChild (_avatars);


            _matrix = new Matrix;
            addEventListener ('enterFrame', _scroll);

            // sega sunset by lorn (extended)
            _music = new Loader;
            _music.load (new URLRequest ('http://www.youtube.com/v/YBtEFT_uWHA?autoplay=1'));

            _music.contentLoaderInfo.addEventListener (Event.COMPLETE, _next);
            _music.contentLoaderInfo.addEventListener (IOErrorEvent.IO_ERROR, _next);
        }

        private var _last_tx:int = 0;
        private function _scroll (e:*):void {
            _textureRoad.fillRect (_rect, 0);

            // swanging is fun, innit
            var t:Number = getTimer () * 1e-4;
            var swang:Number = 0;
            for (var i:int = 1, c:int = 0; i < 100; i += i, c++) {
                swang += Math.sin (i * t);
            }
            swang /= c; swang = 2 * swang / (1 + Math.abs (swang));
            _matrix.tx = Math.floor (15 * swang);

            var dx:int = _matrix.tx - _last_tx;
            _last_tx = _matrix.tx;

            _matrix.ty = (_matrix.ty + 1011) % 1024;
            _textureRoad.draw (_texture, _matrix);
            _matrix.ty -= 1024;
            _textureRoad.draw (_texture, _matrix);
            _matrix.ty += 1024;

            _textureCars.scroll (dx, -5);

            // the math below is plain wrong, but it's 'close enough'
            var magic:Number = 0.98;
            for (var a:int = _avatars.numChildren -1; a > -1; a--) {
                var avatar:* = _avatars.getChildAt (a);
                avatar.s *= magic;
                avatar.y *= magic;
                if (avatar.y < 60) {
                    _avatars.removeChildAt (a);
                } else {
                    avatar.visible = true;
                    avatar.x = 10 * (avatar.cx + _last_tx) * avatar.s;
                    avatar.alpha = avatar.s;
                    avatar.scaleX = avatar.scaleY = 2 * avatar.s;
                }
            }
        }

        private var _carMatrix:Matrix = new Matrix (2, 0, 0, 4, 0, 980);
        private var _carTint:ColorTransform = new ColorTransform (0.7, 0.5, 0.3, 1);
        private function _placeCar ():Number {
            var n:int = 1 + (getTimer () % 3); if (n == 3) /* too red */n = 4;
            _carMatrix.tx = 530 + _last_tx;

            // the car is now in the middle; but let's make
            // it look like we're swanging around it
            var cx:Number = ((_last_tx > 0) ? 10 : -10) * (1 + Math.random ());
            _carMatrix.tx += cx;

            _textureCars.draw (Dot['car' + n], _carMatrix, _carTint);

            return cx;
        }

        private var _avatarSprite:MovieClip;
        private function _next (event:Event=null):void { if (_users.length > 0) {
            var data:Array = _users.shift ().split ('=');

            // so the avatars were at:
            // http://wonderfl.net/images/icon/2/29/29b9/29b91963d1bb71a93e8c506575a3ad1e1c0182afm
            var path:String = 'http://wonderfl.net/images/icon/' +
                data[1].substr (0, 1) + '/' +
                data[1].substr (0, 2) + '/' +
                data[1].substr (0, 4) + '/' +
                data[1];

            _avatarSprite = new MovieClip;
            _avatarSprite.filters = [new DropShadowFilter(1, 45, 0, 0.5, 5, 5, 4, 1)];

            _avatarSprite.graphics.beginFill (0xdddaaa, 1);
            _avatarSprite.graphics.moveTo (-10, -10);
            _avatarSprite.graphics.lineTo ( 10, -10);
            _avatarSprite.graphics.lineTo (  0,   0);

            var text:TextField = new TextField;
            text.width = 128; text.textColor = 0xdddaaa;
            text.text = data[0];

            var bmp:Bitmap = new Bitmap (new BitmapData (128, 32, true, 0));
            bmp.bitmapData.draw (text); bmp.scaleX = bmp.scaleY = 3; bmp.x = -10; bmp.y = -50;
            _avatarSprite.addChild (bmp);

            var loader:Loader = new Loader;
            loader.contentLoaderInfo.addEventListener (Event.COMPLETE, _nextIsReady);
                // well, shit, lot of 503-s lately
                loader.contentLoaderInfo.addEventListener (IOErrorEvent.IO_ERROR, _nextIsReady);
            loader.scaleX = loader.scaleY = 0.25; loader.x = loader.y = -40;
            _avatarSprite.addChild (loader);

            loader.load (new URLRequest (path));
        }}

        private function _nextIsReady (event:Event):void {
            var avatar:* = _avatarSprite;
            avatar.visible = false;
            avatar.y = 180;
            avatar.s = 1;
            avatar.cx = _placeCar ();
            _avatars.addChild (_avatarSprite);

            setTimeout (_next, 2000 * (1 + Math.random ()));
        }

        // these ~200 users appear in the order of their last code in the list of ~1500 codes they posted
        // (all the users without avatars were excluded - sorry)
        private var _users:Array = ["seagirl=1e8151f9ca4f805d8eec9999f8543390b17bc17cm","szktkhr=852a625b85fa4511bc6c97952e72527e416dfd84m","kojimajunya=04bf98c4e014859731987aa08c76c5779c7896eem","tktr90755=c94bd2ec0f4f1ec21631070981de42cbf5a71485m","Laqu=03aed65c6cb98f04110a2df0db828c1ea6f11118m","gyuque=8aeed91b68f2436ab2bc708c0b47c770bdca204cm","demouth=b3ec71692bab793905093d8e25744a98fdb1bf80m","keiso=017b6770451dc6bfb3bdeb948dfcec72038faaaem","naoto5959=fc7e0ff47efad80742ebf14bf42b7e0d6b587e38m","timknip=3e72a28a26e24ed26b755c354f6c34bf7f531ad7m","y_tti=4db5291aad72f8a4b713877b36b9478f423afce1m","cda244=c4af05ab59e609b24dd27dd9aa8d0e6738ab0e41m","hysysk=7bf49c9c2dc824b3f5fb9cdada0dab11e5f6f615m","inosyan=18db7091b073ea9c82a670572347de7883a1aa30m","cellfusion=82c40cff21d4537afbcbe896a05ed5bcbe44bcefm","Yukulele=bad1c0a69415194cd7b71a9f54bfad60a4157377m","photonstorm=5b80510cd85a3d05a3fe2613684c4b95b1bddb77m","grapefrukt=a7fc0138ea10444b1ee437c49aa9adea5dc6d618m","hikipuro=d000fa8c3527191cac1a308786ca06e7ff6174cbm","sketchbookgames=4de6d5135510e6a8717d371546d336927bee97e0m","nulldesign=5482ca8c0fbba780cf1d7b741e5af10fd41e284bm","alotfuck=333222f94b16eb196b11ba2bfc008852472a4a7am","soundkitchen=03ec458b1f237167938442511f5deb305031be8cm","shaktool=448da28c6652d6c10220b77fcf861f2d489e4999m","ktk=32f70d937149aeb279365d703a163206f492b75am","twistcube=5d9b5438bdb3173ce776868e91b4d97d4f10a073m","northprint=c4b1b26c51adce40ff683b8f51d89fe68e66667bm","ahchang=e551d783ee40c76f99eadf24fe30218723f89059m","chutaicho=cdf31b75dd233cb89d869844a579305797594b10m","yanbaka=0159af12d11fa9891f0365553f80be73007e5199m","watanabe=0e94f26b44267ee246d4544f6e7580a8651d91e2m","kenbu=11de5d86aed21d89a975355643c78f5caa0166d9m","peko=bb8afd7fda9ac5771b305b7b16c4cf0352278875m","chaiyuttochai=8aa3569253d299d1fad65eb8ab27e26d9da2b668m","swingpants=0ce48d3df130dcfd4d86b2341781d79bcc923dbfm","kaikoga=9fbd85e38af3b23f90c9c2ae9f03416ead719f90m","miyaoka=c475c2100684a371e18b18afc96d9f6455df8db4m","KinkumaDesign=7f0fcba2fb4e171dd0611fc099efff4c1926c1bem","keno42=e5ed49ea99725c9877343a6b8fcb1142a0ca3879m","rect=b1a334b047d5e3f2da3d3bbbf954e7b208608c0cm","toyoshim=f820b2bfdec3caf6c13e234e332db51b97524db4m","minon=d02ed349d516c352f0e6adbe0bd3dae781cfc058m","sakef=64e116865a6cc937b33fd28f72e3abf04ff1fc9em","neurofuzzy=71fb01ba907a59fb1e40d614b7aeaada9845d811m","mtok=8131ecc9e8567fd977a7bbc8476a8bf058dee22em","katapad=ad8ee85eadefcc97670258170e1a80bc1da8089dm","ysle=a2445bbe02204a5ec0b85d132fd05729f00222e0m","ll_koba_ll=1289badaa4cb50fd5024dd5aa9a8c7445b26e558m","k0rin=32be63b3ce019a852e86a158df07aa61310f38fem","moringo2=3d7b89ab97d202f9adad44142ca77dbb30b8aafem","beinteractive=d1b500a2ed625315883108a73527eda248cb1e1em","TheCoolMuseum=35d3f74fcfe18c8633fc0915e5585b3da5019226m","enoeno=c07b423c83c66e9ebaf416c36eb0cfa8031df01cm","utabi=b01b34dc08a2814350c51e3ff4207893885cd8b8m","shakespit=002f595a4246cb3f88e15d22ccf3a775a18b1b91m","AndreMichelle=b93e043477928e489bf8dd973f0a1bf6283bebfbm","psyark=6dd9e0c1c792ea24a1f69480e23e22a454833252m","gupon=db27720f39bd0b0a0560e5616c3bb3b7c89da052m","anatolyzenkov=6e105f76bfa7f403acca1532e77ec08dfec9c6e7m","milkmidi=6438c9503675d032919044eea487fab1cfe6c30bm","tristan=0435583d2eeb041ab496033a231564439dbddaa2m","a24=1a398ecd69f80dc0f11fd8b971b1cca128ae03fem","k__=c821c8ff4df8a3d263b9d23623f10b526ace7bc7m","matsumos=c02d4cb53075a1a22172360ac7db967e371589c8m","osamX=7b8ce27520b46529cf8a6354233b47bc42124368m","actionscriptbible=e6d7a533155d4e0f8b793385ec639ae80510b3ecm","miniapp=95e99af3f53636cf8e3e67a589545871e073035dm","umroom=03b847f686b70eb4f696495b7cfa116e889fe738m","aont=45035062abfc61a4c81d08ae0f0d8572a92fdb1bm","Hakuhin=7bc2ab283955c6059476d5d0c8403f9ef3576125m","selflash=87155fa3098a3f871c46a4006d3c85c9e3468522m","178ep3=b0d7bce13a95a19dcd2385a53a8b0ebe15329aafm","Nicolas=8aeb8ab1f0c6de18c9cb1424d5443084458949bfm","meat18=fd6fa1496f5fee8bdb71c5652638732b3aedeaddm","onedayitwillmake=2ab8b34968ab4f5a98ff701c0a0f8402730320d7m","tatsuya=462bfde2b63db02ad80ef9bf4a78b3f75d826987m","poiasd=20e706096dfa9c02418c3def1f7a2fe2a1fe8ca2m","glasses_factory=17df61001d72ba077de01c7ffc8687560acd827fm","whirlpower=c91e7b3087fd965b9d40e025268b2e48d43c2344m","nanlow=318da411b5a73478ae63db0314b117fa5316749am","zahir=a6c3981496eb9d77bd382bf2ba5bd4be27a4b741m","HaraMakoto=e46a71c5910078200319858c3edb4e6cda3cf3d7m","shapevent=ec3c37ba9594a7b47f1126b2561efd35df2251bfm","yd_niku=78f8a9853676486b4bf3777673060f5fdc7ca704m","gbone=7172465e4c706dd8ebae8a9992521496ae4a152fm","coppieee=89da3bdca59210e1e6fb23560d7813e68f3524ccm","hycro=dda6d4106c8f989f1d5c0449f5b6c2156fda63a3m","horned=d180272e9706cbefdd9a79c32c1f5a06b32198d6m","_ueueueueue=1ca2606cc4ec9e3a7d52f42a5de58be11ce687ecm","linktale=106989957e4559067c00f83ecd40caeba09a6b61m","gaina=11267895e907c41edba143d747388c9febad1036m","nemu90kWw=d7f6c4f79aae1cf10775023155fb55ccd37db8fem","dubfrog=a841b2d5170de28d82804de451a2b550bd863e3fm","summerTree=288a032ef7410215fc03e0c08740b8a30592063dm","fumix=065b32f18846d644577e86539c719599cb270e3em","asou_jp=91f2de87c71206cbd5d08c80889069939ee89984m","ser1zw=ced0851543101e9a216e8e72903b2778d610401dm","cpu_t=3aa9c7085312be6e684ffbfc1a7bb8eef9f54852m","kura07=a91710ef812a9be70e80034d9ce3c0319c4b9d76m","kamipoo=10ab17dfd4d897e8efafd978d4ea1ae39afbf0e3m","uwi=6e1a5e2e42203531925ccbb9680bd6a75e8df492m","sekiryou=a602b209005c69f86435e7fd8f19a3160d7c5fe3m","kjkmr=2cf521f3602343b390540832eeb6d4b4c3b51fe3m","facker_b41bqd_u=9dc4b8813aad6b8b80d35b2d3bd29bf1080a43a9m","nackpan=69f6393f1e871ebf303e018d11985837d3fb1350m","Thy=dca878950812eb781193e10c6829c5ec052d0c53m","otherone=b0ec46a5bdebd734f356f1f9e266d060bd8e58ebm","swingpants1=7bf9082c7c94acd5f4ca3af08a59a76db9674af0m","elsassph=b0d79f0c874ddd69454e668f0ccd73944b187deam","hacker_szoe51ih=3910ce105eb5c61679fdfcf2fae4d6ecfa07b204m","undo=d27227407475c342deabdaa7cf5e212074ad9504m","mash=73b56ff18985ef4501c948d2e008594c4ebd2d90m","environmental=3e95432c59ed515bd6d47e0752769a6f8f397c3am","focus=294ee8aaab21536efc03376ade6ab915e34d0408m","daijimachine=d0d74226816bfa404997dd164be9404ab5380ca2m","togagames=76e54fa0fa842ecfa92cc1ce6bcdf83d25c3e761m","ProjectNya=03d22765ccd9749e08db586a701bffdbd554415bm","uranodai=0735622c130af0003418fa119d7a61d85e9dc04dm","zlaper=13bb4caa2ce8de4f2165bb151a8a8d2381e39ff2m","knd=bd5bd786db4210311242e39d5899f6be60158b1em","imajuk=27238318f2b00846008ac98223d3433ba62ae541m","Dorara=c719700a6f152a3e843ba415c37d89ece5eb153em","kuma360=14b692e0adb7f647f27bac7d5f284654b15540d4m","hosepens=21af051fb3079348821e78b8c8c2209a3667c5e2m","wellflat=93756e8e9645ff1a01428c03e628dcd06a36dbd3m","UKI0809=9b225e7be110e7fbcc32d96b23306f1b376cf386m","matsu4512=1a8f320789bc3b9a83fe8af4c2f6e2d5192fe459m","aomoriringo=1b6a83055f42a2652890904d0815069e9b2c889am","Merd=c4b53ce9eeb1ff3b928ec57b516ef3272c4ead8fm","matacat=e1f8c29d86f38fd5ba12986268f42d5f1c49d8d4m","yoambulante.com=dfc4a94a06ee0a4f11d82038e6913f733029653dm","paq=9a3d6f78091dce4ac57ebf3f8d754e6cdeca9013m","Hiiragi=9560824f2ba0b37907a8cc46bd67965d31cb740bm","wonderwhyer=1e52112fe9d40ce5afe5bdf691c357c52f15f96bm","motikawa_rgm=54a65b8181d856e8a4be05bdeddfed84f541d1a0m","xoul=79db12f93a6c695b3f1bdf2657cbcc93e27cccc9m","sacrifs=e773394b7988cebd9b10fd4a2610beeb971beaffm","Akiyah=1d5b16264cae9909c5dfc65273589c0eaf22dda2m","zendenmushi=66f46b65d7d6311f93895e941d961c68b931b208m","Susisu=1fa1dfc7f70d9cbef5f8c180215f82a758021a8bm","mookymook49=2f80034036733d5980476d0fc5245da3b4ed43ecm","Fumio=5f175d6c46674aaced59ffdca8fe53443cb00ac0m","sakusan393=747acc715283df547d22dee770440f3ce6ad715em","tail_y=cb5da3d148c03f9288311c47f46d6263a9d5c548m","k3lab=b6c4c9b282d967d197b7b5e4eae721cfc68e5ff6m","Scmiz=1c7985145546d4cfe4729f4939bd413e1e68e00dm","nitoyon=77a76475044954212b91e579e608cbec55994f99m","Murai=480f876800731772d8e7a547397888a08d8f71bfm","Kaede=15a5f85978f45f0c72164dca1fb9694ab397c35bm","Kay=91d8e3ae3c8bea184103387f146264ea737b3e96m","buccchi=b83a1fc20af27bbbf6eaa053b82022aa7251e3f8m","yuuganisakase=d430e3dbb69b8e0a1f0710592825ea4cfe7539f3m","bongiovi015=f55ff39d0520c1acd15d8ee457d588fa7d427a2dm","AtuyL=e2749a4ba76e9bb581db42fba7ccadd0e803a929m","shihu=6e10d6aa5fd62e446325b9893b9d49a4391b3517m","Nyarineko=18b86934d456953af2743f75ddc4976f3da48b17m","esukei=534549b7bc55f25898e0a62d3d26f851836f2b13m","esimov=a534cfc2c70374dda75ecee32380e4d61007f794m","sugyan=7fee110b688660edd30545a293535d12c6615fb9m","foka=53bae71d6222b41abd8d84c93ebc832338eeca50m","naraba=98b5b12a3ba805dd0c6390bccb51e540e865d588m","Ctrl=07df930f813b7aba109feb64d3f2d0cea63d3961m","tencho=fd12cda35ea75428eb44fa5e1bf91bdbaa585d23m","jozefchutka=6a949f4a34729312bc905c13b04486a7ee82f5cdm","9re=e792bb80614beec2e183bd7d0a43e72da8c4317em","o8que=b7a05cfebe866d83fe5e4395ed53ffa483c28b98m","Qwaz=29fa3cd9cd829cc34a198de9aa6518376161f24em","rettuce=87741567cddb27d078919e1f25927bcf9f93b34em","inu=17fb1fb4d32113f1899b4fdcbbc6e047260e90e9m","civet=94bc0cdb9b187d17f5d9143e537c52b36af566c4m","alumican_net=04b80a906b0de6fab253ccaf4efafdf30b213939m","yuichiroharai=1cb121947ae838bd6c84b2de79597679bfeae0c9m","shohei909=9a6707b9c7f2875aa8843b2255f18b43736eb6f3m","PESakaTFM=6b15677570ade591d5167c90636469d01108f9f9m","keenblaze=eff71125e83151439ba4091e4ba09cce42658ec3m","cjcat2266=d462bbc76af9f25a56bf5cdf4324d19f0141d6f9m","hyzhaka=797cb9305c66b2477ef133d87ca116ca36318b1em","hiloya=cb3231d74325823f11c2ee29f0ccbbb7e4dce590m","0xABCDEF=0cacaabe03463d97513d64e9e4d64f8aa450255fm","Saqoosha=843c39c833373950ceb84fbea431f59bb5e6bec1m","okoi=b84874fd66ad79dc4076eeff05f0a5d93c6bf300m","ton=b043da7f5cefe5bd0ac3095f946b9d72d63782b7m","enecre=b74aa10a8c11a6c2f598c98be3677b3669e26f5bm","codeonwort=71fd8038521af3177894bbaa81a50d5a57f3afb0m","nicoptere=fce4f261de4501e3c43114eb632e82a42bb8f2c2m","keim_at_Si=278afc585a0a283d6e1f13f081cfd9c377ab9db2m","romatica=e0b67e0fa23cc61bd3482ef3ab270b4590d176acm","Loth2012=f1adfd2317a2223457a943edde93811ab45a53dem","narutohyper=2e5f0b25ed94b5c597e4aab7e39034ba4837154dm","bkzen=5cda85d54f9fd460cfbe13de3b91e51e7442e136m","Hasufel=a73efcbab4b1496217af8eed7bfb5daa7b47f63am","o_healer=021ffac0af8e746a99fa208d7fb9dc54bc39ca83m","Jacky.Riawan=fe378b8fb36fae1b5f7a03e59b9203f605044350m","Quasimondo=079b1a1f418a68fffd2d8791c48fae55978fab60m","ChevyRay=2aa463f4ac34459cb442c19a6b1bcebb93ad8b35m","i_ze=c67e13baeda2524335e41cd5ea1299df628cdebfm","mousepancyo=ecff04080a596328c216f05805115743b512a3bem","alexnotkin=77ed5667ffd06c52d45a2b6cc499f03d6bf70665m","FTMSuperfly=9a2190de072da61d419ecfd9ef0d08a6a2d8012cm","ABA=25a1809f22df6323897a6676ca15170104a054f6m","gaurav.rane=e4c14698d5365b3816d8a648beafb491c3b6ed25m","FLASHMAFIA=f9106c24e8e8e74a453f6d03bc5bbae6f6f001e4m","lizhi=cb5fdd0a7df1e149ac50b921191707e472cbc78em","saharan=33ba1d52de9b02b06bdb18e212682a0f72c0a566m","Aquioux=5b67697404a26d1b260787f4cae84a60f0ec71f2m","immune=add7ca1939d1a4890b4c7c2af9f3d8b6bb4cc465m","KBM=d28ee0119340921d5e39d9f20dd182c0ea34898fm","wh0=2a4f89c3bd17f7cd1387299e116a0da70b7c9c98m","umhr=be08eeb5dcba6d01807b2f9ed699a1ddb1903170m","yonatan=dcefd2626b5457f62ee3f6777134c9f028c663c9m","clockmaker=01b79458eb5ee95dfc7b3be443e53fd4db249f78m","devon_o=c4941ee9fba91dc2adf51fb41b2207e3711e33e1m","tepe=a5826aa8fdd57f5757a8253b9b0e0f5dee5624aem","ke.kurono=a6a10de0cd89541b83a9895af235aef6187bdb5em","WLAD=d2474be8b20604f59688e5efcd90ee5b7e9697a2m","phi16=0bb48cd74f2954693526e1c84190638cc1b21ab2m","DLabz=131ea579fc28486b690ad7f5df897673be683c14m","J.J=8a07fd7cb0947b79fe762fbd29dcb03ac009cdb1m","greentec=63cd617ea862e88efe2932dcae82ffb2ddd7abfbm","kawamura=e5f8e6ea3856edc8a701c5ddc7ea4a4c8189e08fm","H.S=7ef2c24ee669ac262d329622a5f9ff86603e9699m","makc3d=29b91963d1bb71a93e8c506575a3ad1e1c0182afm","christian=975abe9c87d462efc97f509b2d6ff84a903d1fcbm","spanvega=59d4cc977f723b77d4a70a6e301e8a0fd038b3f5m"];
    }
}

import flash.display.*;

class Dot {
    static public var tree:BitmapData = image([5, 9, "01110,11222,12233,22332,23434,04440,00500,00500,00500", [0x70E000, 0x40B913, 0x009933, 0x506418, 0xCC6600]]);
    static public var car1:BitmapData = image([6, 9, "011110,332233,321123,021120,023320,021120,331133,332233,022220", [0xFF9900, 0xFFFF00, 0x333333]]);
    static public var car2:BitmapData = image([6, 9, "011110,332233,321123,021120,023320,021120,331133,332233,022220", [0x0052EA, 0x00B0EA, 0x333333]]);
    static public var car3:BitmapData = image([6, 9, "011110,332233,321123,021120,023320,021120,331133,332233,022220", [0x6D0402, 0xED0B0B, 0x333333]]);
    static public var car4:BitmapData = image([6, 9, "011110,332233,321123,021120,023320,021120,331133,332233,022220", [0xCFDDEC, 0xECF1F7, 0x333333]]);
    static public var drum:BitmapData = image([6, 8, "011110,211112,322221,334111,134112,344221,334111,034110", [0x5A7A85, 0x415C5D, 0x91B7CC, 0x7497A6]]);
    static public var cone:BitmapData = image([5, 7, "00300,00100,03340,01120,03440,31224,33444", [0xFFFF00, 0xCC9900, 0xFF3333, 0x990000]]);
    static public var startingLine:BitmapData = image([14, 4, "11111111111111,01010101010101,10101010101010,11111111111111", [0xFFFFFF]]);
    static public var ps:BitmapData = image([8, 8, "3111111032222222321112233212121332111133321233133213313302333333", [0x6DC8F0, 0x2075B9, 0x054680]]);
    static public var fl:BitmapData = image([8, 8, "41111110,42222222,42111213,42122213,42111313,42123313,42133313,02333333", [0xF59234, 0xD42F40, 0x9E222D, 0x801220]]);
    static public function image(data:Array):BitmapData {
        var bmd:BitmapData = new BitmapData(data[0], data[1], true, 0);
        var list:Array = String(data[2]).replace(/,/g, "").split("");
        for (var i:int = 0; i < list.length; i++) bmd.setPixel32(i % bmd.width, int(i / bmd.width), (list[i]=="0")? 0 : 0xFF << 24 | data[3][int(list[i]) - 1]);
        return bmd;
    }
}
