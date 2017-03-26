package {

    //*********************************************************************************
    //WonderShmup
    //@by Hasufel 2010 for Wonderfl
    //A two nights exercise with Vectors, SetPixels, and Particles
    //Who said Flash shmups can't be played on netbooks?
    //**********************************************************************************

    import flash.display.StageQuality;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.BitmapData;
    import flash.display.Bitmap;
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.geom.Matrix;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import flash.utils.getTimer;

[SWF(width="240", height="320", frameRate="60", backgroundColor="0")]
    
        
    public class WonderShmup extends Sprite {

        private const stageH:int = stage.stageHeight;
        private const stageW:int = stage.stageWidth;
        private const stageH2:int = Math.round(stage.stageHeight/2);
        private const stageW2:int = Math.round(stage.stageWidth/2);

        private const point:Point = new Point();
        private const stageRect:Rectangle = new Rectangle(0, 0, stageW, stageH);
        private const blurFilter:BlurFilter = new BlurFilter(2,2,2);
        
        private const graphicsData:Array = ["47494638396108000800a20700ff0077ffeeffff77ccffaaeeff2288ff55aaffbbffffffff21f90401000007002c000000000800080000031b780aa03b218c064c102218000b2185d47de164611a955d8dc33809003b",
        "4749463839611e002200c41700170d11690710ff0825785b6a8a0506b29da9503441f20204a90404ff0853c7030b627f1dfdb31ffdcf67e7e4eaa8c459fde292fdaa00482d2d0e0504715556dfffa0af9a9cffffff00000000000000000000000000000000000000000000000021f90401000017002c000000001e0022000005ffe0258e24c94465aaae17d334282ba70c04c5737e0d4531e8bac262f103ca0405c763a030b2048bca63d174aa128be9e2604d21b0890335d0dd39060884a26008b87906271b900020d80800d250040e1c07750a090a047a0105007206097507150b8602040671460681750f610b7a0401967e8d010081850001a74e070209a0ac696d079f4e15020288b300040501b30b40800fb78888030003a9040b017d2c0602c3adc90e89d004cb9439ac0fc38e8d0a9e43b42bb7acb7dd15a9090208015ad8866a260d02070a8ce8ea0ab7ee53d879762168c0a0450308f77c1460d72a553f5f0007f009800002418309253aa856ed409a350ef81c9b38b0e0887b8600731850e9c3d78166bd5001984900410a010a0e2824700ccd4c043d41ad0c5033852f003e1cdc99c99469019e12779131ba03d346640e70cea9464991221616285c983041828583162950207b216c0e0923244ca861030283b271ad4888801606dc32222c18bc2816f088080c4e184e1101c78c10003b",
        "4749463839610c000c00d52500ffeed1ffd2a2fffaf2ffde92ffc879ff9c48ffecbcf79e94ffecbbfd8f1ffd901fff9146ffa248ff9847ffa028f96015ffd644f67440ffc581fff1b6ffef6fff9b49f77742fe6d2bfff9a7ffb134ffc436ffe280ff8b1bff9e23ffc883f97b1cfff88ff94e21ffa24dfff1a3fa9f94ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021f90401000025002c000000000c000c0000064ec01281502a1a87c5c1c068549604088380099502262300f39a0d803001a617eca16c24ccf25904d154986c3723e32830e7f54687b360eaf9160a09114c8183070f1f244c888a2521174c45902541003b",
        "4749463839611c001f00b30f0000204a615f5a1038634882ad39383168a1cea1a19c205784f1f0ef91c1ef810100b9e9ffd95700101119f99a00ffffff21f9040100000f002c000000001c001f000004fff0c949a73135eb8dd0fe5b401001684ec47110e73924c9d082c1b02c43396b42a10e821de5f238000201c0e141dc5d084098604068b60297802021d80ab006dd29d0d126545c3242bc39148e8063215198179270dfe60520001804090b750b09040c7d00311b5d037d045f1d6502230040411a07830b00770871716b6f9b4b19036e744606a0a0aba83e3212050f03b5a08e49080aa0498e71b53205c1036f1771490abbc771c6c2b3c404755f234901ca710ad5d43d05d1945b726eaac9c9ae3e778adf70027d029fb80c0e0e0cbd00089400ecd57049ee53062490883000e41e1c3f221e30cb87e0408e5eb86a1c30b80ac0031628183aacd885d929831841351870e72685428b2b7cdcc3f0014a8c376c92088b115243a75b35a1807a03221f800bec28e4331614c497060dd848088054cb097695323ccad702d406ab192200003b",
        "47494638396120010800a20700133d4cffffffa1c4c953939cd9e7e975a9b036818cffffff21f90401000007002c00000000200108000003ff780aa0cecdadf8983c906278f95bddf549918689540a92a6c77616acb9ebbc9e7879e7328cb6b14a6b97f1b14c9b5f271048319b24a653fa784231d6e915d0e43a91de2ae38a9d41c3def082ba66b7b56636d79dde76cff771595d8757c9586473824f5f7c597f7e895182040c8e0b8e0090189294938f2592299b0f9d91999e6094959824a4958e049093aa9aa1a5a6b19796af41a5a7b098a6bb96b3b6a8bab5b947a410b4c22ebb30c6c3bf0b02d10225d229d33818d300d7d9d1d6de0fd3e0dde3d960dcdd2de8e6e20ddbdbdcefefd0e5f2f1d524e5e6f90cf7fdeeda02d29b812f9cb57ffcf2d52b086f5cc36febf6855bf770410106172d622c7111d640460c1d3f7a54d69144488e1b1f7cacb072e44a904146a69429f2a4c61936618e14d2f2254d943b7f7ad4d932e54d95463522bd05a1e8ce094f7f2235997483c8010cb02e18c07546d7075cb56e0d5b422c09b25bb3a6308be12b58b560dd02d03ad71dd6ba71d78271db166e5bbe7d3ba01dbb16ebd7ba78ffb29dcb97710bb38ce50e3e5b16b063ca82175b26726b428f2336446c083dc408891da34fdfd0f142f50f032ab0a50ef103888f989cc174ee8cba8810d1b26978a66dba02f0e3c8932b5fcebcb9f3e7c991409f4ebdbaf5ebd80f2400003b",
        "89504e470d0a1a0a0000000d49484452000000c50000001408060000003d5af97a0000001974455874536f6674776172650041646f626520496d616765526561647971c9653c000013c04944415478daec5b7b505bd799ff842424814002832060236ce2103bc452b2f1b38945124749274db0773be974d31acffee3c8bb19c7bbd9064fb3637bdb9d3871da2493d9c86e6767f0a6d95d3c6983dbb513e44d034e629be0c4c2c131606383c104842d090448e8b9dfb92f9d7bb97af8d1e9ccce9e993be29efb7dbff3fb1ee7792f8ab6b6b67700c001c9e2c46b1b88cb2b9c8c8192790baf3e4a662b2763a16476e03547c9d4e3b5052f2b25c7970ebcdc9c5e1fcc2f529e0739d94e902f6578eda2743a38f916192cb9d2c1fdb6e3d58cd760169c3215deb7526e726592f3c720d77e7b0ab96abc367297958a118de1e6f45b53f0968b395f7ec0c9dab2f063a698dc0c26a9df83d7f82de2c89521cebfc4374ebbddceb4a1c04e9178fd959f275b79f6c7b0a8cafcb02408feb77fb9cf3037c7e6f7fd2b57c1231beca453bcc0ebbeb8f365f7c17ffbb565c2c3727f78831dfe62e5aa1df8fc4d7cf63821387c65a8a1e76c3778c6c78197e30bb609a5656544070c0623e308d415841043c4f39e7b57c077bff73409c256ac9f935a8bf2bb4f7c7a7cd789cf8e0bf8685b07cad64bb1e40a91e77fef59b182e7f416eaf5a5e294a950beada7b9c9158d4603a6b272283418a06e8585e839b1ad6d121bdf999cf43b2ef6f7c3c5fe3ef4eb18f031a231885fabd08e3befaa6530a4bc795e58d72ee3c7f696f7deb561ec32fa918f09d66d49e7871bc15cf7e07a58f7d07a920bbb6f0547ae10df625c193d92771aadf639ec180754e4a1279c141c1c1d274256aa536c3cd7db67180e249dddd9d3473a0519995ea0742de74692896e2c258321b891dcd66028b4ff50ebefe15c5f7f4a829e8b68185e1f7dfe053c665bef78ac7e3d31faad9fec492621cdd3f3e559d09794373eb466d52cd6cb8e7233b1a48e3e22c6a0b152f2c1f225feb6fef1383cb87a95e3e927ec79c8c9899c3ae538652ae1b83c3779e139180eb01c3e415b9f6978ca816d03b6cdd8fadaae97df39edee761c3afc87cc18c416f42bea38785fd16df3bc52f1f145b2f3e314e645fd865023f27c0979ca8dec84c3ead1b171db979c7f3361123fdd0e6eb2319ec089142fc2a5f35c1f3cb7e5c7fb5d2e572be9141d65e6e5b6fea1ab8ce0b7fe103f25f3656357ef30cec3c9597912b186c726cc8bca4bad58ef3eb0ebf9fafec1ab22999a6a66a43d3f1b9afbe417cd1fc0c8f835c9cc9ebabcdfd10dbe10389e79623dc1dc965c0b88f57fd3d609d5d58b1de8e8c9ad7bdede29c5098146d099817c11c664965cf872a4b30fbca19cc62d1b3710ddce549cd29518a864b965537e7df8382c666d7d0d6f57bb7b2f39481ddca01d72f6f3bc52f121becbc68f93386efecfa96e78aa7eb503eb77a7a0e0709dfa5aa4970e93f8e97670cbe897f190c09d786330af74a16d6a3cca3cecf5325dd3ca0ff8b37391c6b63e2f80b64c04f2c9b911d85c5eba654a5bf602911fb83603539c4c49611ebf5e7be1e8e98bf0cda452d0cfd3a861f3a3f7c1cabb2a99bf4999989c818eaf07e1b79f9f13f03fe81e83bae51e0776b8c33f7cf5501b3312493890b2fbbf3e83b71ddf6b423937cab5d0cfe6547a416726b708680c1aeb9f7e580fcbab4cc23dda0c83e33e86d3f19ee45682f861f1d7838dd8d6496ceb40261cb93d05eab5ffe74bcfd4d3dc48c13af162d7e387a35dfda2f67b86bd60331632fbb2df7f3524d2ffabefdc03b67baba1d4903fcf8e6fae4cc0e90bcca0d72d677f34470da9fccbfb6e4a1bcde847525ce72730b180e4c5bc4e81365663ace7e5533a4ce2a7dbc14d2e36c427ce235f307e22e5cce82c3c854b5ba653184a2b605acfcea15d3ee687dfb86c3c79d98fcfaa989bc5257970f9da2cf3f7d14b514c6ed882cf984ed18789cfcbdd6366c8b967e6a24def9f9f8519ae3e3f57093fddb41c9694e4efc5db579ffad7537e52ff87bf5d53fdfd07eff9495189c9f1e6c70302e9dff5f888210ec4653a058f4f9769bc7e76f402bcb269b9039dee464c61b915ce35083a415d21d01834564ca965b641a8dbcef13162bb56bcb6dcb7eccec67ff930b9ecfbed3753987c40381dc884235b38799a1b5f504fc1ff8d1c566fde70ffa9a383c935d7d5a08a9fc56d5d3e9d80f5b4a51cbeff6035d9f3bc86188314066f473dfa972c779d69ec97f52febbb327ca6cbe847e61ee97edc3b61c6586c452e0724505b8ff5f9e6e9a4c3247eba1ddce46283fe6937996b6d3da353227de2e5f63ab36957b83f39b50fe042ada6484d668b8d9f8eab206c6057533f7db2141c47aec14c240164b9766238644060e6d4a32f6440397694322f647ab7bbdb136df0e91601b09ce1f9b506ec10babd8fff668c5dea70b8784f02b9aded47e5cb3f1a56dace8eb38bc14fbdcc4f03df3eff4bca9222155cf2b123c4573300fb4f4fd99e7ba0703bca08cbad98d6883aac5d517dae0883c64aa8b4a23ae4e3e7f654edc8096cf72d6b3c7629c83cebc341653a1cb79084cb849376294571131240ac679c8e284475bac202e6d0432a5b52c2d4f7337ea4ea693bc8a44afbfc467847f5e5f8ac38a31f85e5ef80021ebd1b1cf84cda291cef5f56cfd3498719d3ea6f0b37a98d18d7d564801981d279facc4c515688ebb6a224c0384e273510abc6a0349c9cbe039f61121626a04c3fd7bdeeee859663234a46ee042eb5d62d8a904e61b9040b193966c75d49923a0e034134a8c8983c49a8229bf5c4ab745b925d40f363cb4a6d67c36aa1e6ecf53031a09eb9a1f41c6bc2e0fc460d97a6d8c1f503dcd6ad188b385076f2f123da9d64350a98785054c22a14901137cc61844458a062f9caf30a35db6b8b1a8ff99253f1a54018562c885ba59c389c4f48474a71c4eb446e2df3b871ab6782d5f664c8c81f6f3b7b7522fc7566c67fe45875777e69b56126ca2d592612f82cfc06b6fb86ccb12e73148bed364bdbca9237fa0eebc33919fd487284c4e3121b370be2fd80b517885d2fb9469486193d7baa87fe4399cc98c02c8da2a9629335373ec6c88939bec6dc6edcff8d0a3cb93868e772fbe04ab27588b8d94ea14be0b8b428395384bdb00eae5b8f4d18c8311253b76929394c9873ae5ba8d97f8c7414d2298284c4c0c6b393183ce3c2e40b02fd209b645aa25f9c5c39a82fc0e39f2ff58331d5f87961b0bc20578405aa1132b17163e72251fdbeb573b0f9f4629889b14e791d971afb0a469a3000ec12826e5f4f3046388c0bf3b09836e8ba2427f71203c8cb4b38fd636fea9961852168db57c7b4dfc2b42ff10da943deef4c47731c27bc7a78f7ca02f0cc6178385f6daaf043992ee444ff0db67de742ebba2586c6631e76ba2749b8f9abf96de62be3066cb761dd82e986b627a7ea994ef9f9d24ea9fde97827e72dc8e8479223bfb8c00e1eef7e1b847d0b461cacbd8c7d8e77c77039636467c7c7968cc3d95859e6d868c972e17aaad8a02eee1362ba6c636c3c715dffc1096f3ee02f9b3746c157b0a9e60aff5e04127f8aabadad6df76dc4aabf4d38ed8944e2966ddef7bb5337c5896fff567cc3e9afbe45fddbe2c75bc5f95360de2a0ed155a132597f34fff25a5de3c7d3154caf31a982b0b7fc34fccdc843ccfda3fa51f8fb929e83dcdbe8377fe5bd7bfbe1a92ae11929bceebd5a1fea76316f8337b75c84fff0d7b03d31270a87aafe38f9e4a03de53c71a4da55ff75a8f893a6b107843ac203c04b8c04d415d5dfabf5921761cfbce7af71f0edd07cb1be91af27bc00ba40fd2b48898575ed329cac97c205679e1f5d2bd42994a7d975a904275da1db3f522df60dd70e205f511df1d98e921e589be761de14635b9d441fc0de896def1d8fea9a88cea95913ccc4551939102c97cbc5bc58531d48c0cd14a91d340eb101f348c8052a6f8c3ff3581b084f525e36b9418fb6f1714e87f9d7c60178d638b0076ddf2d139bf6a6b195b6af43451971b818ef417fed92e60ae243992ab8d76eb7efe4f714cc3b3bb32e08460e238c3be3cfe62ac0c89deead2ff000f58940f3e38557b777c4d84e711e4c50a20c0ab22bf3bcfca711a0c5ad8151382154c16c426540438ccf4ed8fda926e939858ad2412d25f550be7e0f1ab5fc3214dbce4758e77c99a8808f828146ba7dbd5a8c218745d7d19f5178133ad1b3425544d8f0d2f52f1b4fc332b537dd67234e5e5eec1bb6d80b46a13d6a267e628faf71b8aac865966927d1679db43cdeef7cafd4d58a49e7e03ef1101dca4fe092e2cbb009de9dae15ea2e268a61038cd6df206ff8b97f25f0be4de747e668d838c4f89f8fc36ca2b77126ae865e858991cd534449279f3c1f293664131bad3a6d6c408ffb67a332eb18b7df9fefdb15508ec272b47799da07a5cae041ee138fce64a672dff758b4be5d9f2992209fe156db84a0458a203ca0f10c519dc26d5605866af541b32fa16320425000260df779041b44b2a61f9462f6c44cb04a35ba15715f4de1ff8dfde83c13654cb58a392e7333331855afe6f6563b66ede36fe4b99cff603863fbe7d07a087109d596a8853a9547d03172f2fcbd1c96293f3b4e683f69d78dedcae13c8ccf521ec9f2f2f9b8753229c4cf30407b7f641c686a0dd70ae13914ad83bf5376edc70ed08eb8a26fc2f0be33d57746c8adfa09ddd09b57738a1a88dfd9f7113ae1c56cb6bc11a7dda8059b2937b31f39df745b0b0296d138732206c7b193934185975baf625616cdd8e6f66c6293af4e1b1b406ec073bb43c90e56e9628c9dff61bcb6f0a772d81906a598c24c8101814afdfc46ef4f4c90d556aba4baf5c1bc89ed5f29e69f1d57c7034c12bf9e6377bf08aec925faa8618e6bc68d1dcd12f7ec4547fbf1b9e8b8eec5b8eb150f14348e6a2ba0924f1208802e1eed46593f3e17f1d370ab4052f73ad85bf0b97587aeabe9df7392cb1c1fce62492c76efcf60f0bf3258141fb2cc7b6958512ce27467c243640f678b235b50af100359a911d79153259b6a68ed58aec936cc1fe5e180733271273c92e8dd8eb8db287e566e866825be9669e35b664cd1e9e6f98094ac79a37c691e739693d18f1cb6f3bbbaa1fd1f29eab8ad307bdac4737824ce7cded1aa51c1f64ab52c66c71abd4fb0ff0ae0ac131fd88239f321dad949d9bf751274b6505e9180bd2c112076b8d3c50631daa94f98406ef12b740a0304a14ac629aba78708985352dd7c7fced5edd7f2e7770ad354000e15daddcc9329703ea21e6a3aa7e1d7703ae888ad8455a19efd2fc65c3b21f9e5a9d5a32a367caeb34215357aae0a0e11e39c0c2f9c30687e9a59f6a48eaf3b04f69dcf4cb90c4fabfa1c6e6ded3c5ea531e63b004883b59b743c7e008a285496cbea4a20dc694eeb66af1059679638d2d28cbe69267a06ec145574a7c03a7c36873638ff3271c6f6dffaf5801c9847d7a00aaece7a1d2f465d932843ecb4fa950567aeaab0d3473dbbd097ccdb6a7e49c7fbb43fd76cd0690b808fd2d270806437e940b674be1415e465d2917d54663f02fb0eaca5163cfb2fe44739fe2a2a063e30cc0499fda606f1aaf26431dbebd45e9b425324e4cc17913af37da1de53e857fecb65e34c8eced249f2855a5e2f9ff1906f565ab3c9977485de9d75dc9bebb34de5160915799100e44f0589b3a59f72bb8db140f7324dc032ab2e48aeb5c3ccebf00eb35e70d29b7747869ae2852648ca15409f612d686241b32616628691195501c4725450413540b0aaa7463b3a2bec07cc9cc3cd9441da39d648b338283bee0a0f5580bea8c1a715bfd22f0cb38e37ebe7638d6b6ae17a226a135e08613079be34a792d9513045bd0791539b1c27298eb494cc5eb56142b3efd072e77167ee3bf5f696d5a32e6b7da4a7a9bfd82a3cfe36af0e4a264e36a13e1948fa72546a985e508381a9e163655125a2c9cf1f389f9aa9266a27984f3dc8fb8aed197d49f12ac74e91979bd98fe41e7de347fe0757283d8dd7f22a44504bfc42fba055267525984ecc995dc12233c39f3d2aac80aff0c29cb0d1f131501b29922fc6a900c91777d6f99245a718ac54066dc5f9c94e51383e249cdbca8d7a3591d13702c6e4a8ac8bb1fb896a6e2d37bed43e5e76c1f55cddf5aefdde852b21aa29a0d475c0bfea2e9600e706d140ef19a6ed6a7a7f416fc07cf3ebb0bd396ccfb9d4dfd370ddbc16622a5d1233472c5f2d5aa316647494064721c3546f5a4e99707409dcccceb26b7a2326995ab24ea6fcb613edb863596cb431585821846a3ad70a9a2b27c9c6fa056d4efab6a53e2d1cef015d24e0446c376267f4255dca71dd5eaccbc68fc2bdd31c1c6ad497263b85221e859231e1c0c64af3a731b99cd96bf57535919c49e450294ae5a62889e702503c76e3f99255a7209bea923ceab38319c6889614baadf9b39e378c79c94e11f30770f602f7220a032cf603e16e172cc060e614575894256650e8e4932731ed8398ef2ac4bda3cc494daec5dec2bf7e2183098d1b55b24b58515b6c7b6dd85e53e9987baffaaee4fe2281c2114e3e2ca727fb2d4614e2d35e885fbb427e0f739c3a5371ca081720b33b5b0cb89e2ea67d2dc1c27b67e1b5dec605c545a0c8e532320f47ff708d253636508f332d54864641a1a79ecb6d09263d3c7fc27ddba21bf125274b0e51147999fd28dca38fa0dbd5bd5011b0f0b18e7b3d108d470f22073fc90732532c92c1e462b813f5a16cf86493b2ac06720c38eb2be71f3927c24188fb4621364196d9d1e76e2a5f32740a273adb8497f4bf9e521d9f0e2229271a289577564a63b486d9541fb87ccab515139ef9ef3c6d61722c8bc722d80103fcb165f3e235f6666963971157da16cac99ff2acb1bf8a6d9925f21d3c3719ac5485ff4c82b4d59605a74cc5c9cfbc72be16f96d8dbd136d688a9cff94c898a518e8fb0fa3c3cc712c396235e7e617408e522de7d3c352fe37e24b221b19e8227fdab2f0a36003a3d77f92fe4fcc83c2736c0b6da3753b64ecdf8932ad8c8dc3b051a5d119f04a76c0d929ec07d1216e3946f88fdf74be480af9cf3bf833957aea6f3f7fecfaffe5a68b95fa18e3ffa24fab41fc7f3eee340376d6c56e9f7ffef4bf020c00362b5c228de1cf660000000049454e44ae426082"];
        private const backgroundBmd:BitmapData = new BitmapData(stageW,stageH,true,0x0FFFFFF);
        private const bmd:BitmapData = new BitmapData(stageW,stageH,true,0x00FFFFFF);
        private const bmdShip:BitmapData = new BitmapData(stageW,stageH,true,0x00FFFFFF);
        private const shipBmd:BitmapData = new BitmapData(stageW,stageH,true,0x00FFFFFF);
        private const shipBmp:BitmapData = new BitmapData(30,34,true,0x00FFFFFF);
        private const shipRect:Rectangle = new Rectangle(0, 0, 30, 34);
        private const ennemyBmd:BitmapData = new BitmapData(stageW,stageH,true,0x00FFFFFF);
        private const effectsBmd:BitmapData = new BitmapData(stageW,stageH,true,0x00FFFFFF);
        private const ennemyBmp:BitmapData = new BitmapData(28,31,true,0x00FFFFFF);
        private const ennemyRect:Rectangle = new Rectangle(0, 0, 28, 31);
        private const shipBulBmp:BitmapData = new BitmapData(12,12,true,0x00FFFFFF);
        private const shipBulRect:Rectangle = new Rectangle(0, 0, 12, 12);
        private const bulBmp:BitmapData = new BitmapData(8,8,true,0x00FFFFFF);
        private const bulRect:Rectangle = new Rectangle(0, 0, 8, 8);
        private const fontBmp:BitmapData = new BitmapData(288,8,true,0x00FFFFFF);
        private const infosBmd:BitmapData = new BitmapData(stageW,stageH,true,0x00FFFFFF);
        private const titleScreenBmp:BitmapData = new BitmapData(197,19,true,0x00FFFFFF);
        private const titleScreenRect:Rectangle = new Rectangle(0, 0, 197, 20);

        private const starsCols:Array = [0xffffffff,0xffffcdff,0xffbebebe,0xffc7c7c7,0xffaaaaaa];
        private const stagesDescription:Array = [[3,0,"testing ground"],[10,0,"warm up"],[30,0,"you will slalom"],[3,1,"wtf shields"],[10,1,"round and round"],[20,1,"life aint easy"],[40,1,"dodge this human"]];
        private const starsNum:int = 100; //can be pushed up to 10000 on a 1ghz cpu without slowdown
        private const spd:int = 10; //speed of player bullets in pixels/move
        private const bulletFrequence:int = 70; //frequency of bullets in ms

        private const kd:Object = {37:goLeft,39:goRight,38:goUp,40:goDown,32:goFire};
        private const ko:Object = {37:unlockHorizontal,39:unlockHorizontal,38:unlockVertical,40:unlockVertical,32:unlockFire};

        private const friction:Number = .9; //friction of ship
        
        private var stars:Vector.<Particle> = new Vector.<Particle>(starsNum, true);
        private var ennemyBullets:Vector.<Particle>;
        private var shipBullets:Vector.<Particle>;
        private var impactParticles:Vector.<Particle>;
        private var ennemies:Vector.<Particle>;

        private var angle:int;
        private var lockVertical:Boolean;
        private var keyVertical:int;
        private var lockHorizontal:Boolean;
        private var keyHorizontal:int;
        private var lockFire:Boolean;
        private var bulletTimer:uint;
        private var titleTimer:uint;
        private var titleDisplay:int;
        private var titleBlinkDelay:int = 1000;
        private var stageInfosTimer:uint;
        private var stageTimer:uint;
        private var stageTimeBonus:int;
        private var stageInfosDelay:int = 3000;
        private var gameFinishedTimer:uint;
        private var gameFinishedDelay:int = 10000;

        private var currentStage:int;
        private var score:int;
        private var shipVx:Number;
        private var shipVy:Number;
        private var shipX:Number;
        private var shipY:Number;
        private var shipLife:int;
        private var shipVel:int = 3;

        private var loader:Loader;
        private var assetsMemoryBank:Array = [];
        private var assetsNum:int = 0;
    
        public function WonderShmup() {
             Wonderfl.capture_delay(20);
            setProps(stage, {quality:StageQuality.LOW,scaleMode:StageScaleMode.NO_SCALE,align:StageAlign.TOP_LEFT});
            var blackBg:Bitmap = new Bitmap(new BitmapData(465,465,false,0x000000));
            addChild(blackBg);
            prepareAsset(0);
        }

        private function prepareAsset(n:int):void{
            var bytes:ByteArray = new ByteArray();
            var data1:Array=graphicsData[n>>0].split("");
            var data2:Array=[];
            var d1l:int = data1.length;
            for (var i:int=0;i<d1l;i+=2){
                data2.push("0x"+data1[i>>0]+data1[(i+1)>>0]);
            }
            var d2l:int = data2.length;
            for (var j:int=0;j<d2l;++j){
                bytes[j>>0] = data2[j>>0];
            }
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE,assetsLoaded);
            loader.loadBytes(bytes);
        }

        private function assetsLoaded(event:Event):void {
            assetsMemoryBank.push(loader.content);
            assetsNum++;
            if (assetsNum<graphicsData.length) {prepareAsset(assetsNum);}
            else {initGame();}
        }

        private function initGame():void{
            //prepare bitmapdatas
            bulBmp.draw(assetsMemoryBank[0].bitmapData,new Matrix());
            shipBmp.draw(assetsMemoryBank[1].bitmapData,new Matrix());
            shipBulBmp.draw(assetsMemoryBank[2].bitmapData,new Matrix());
            ennemyBmp.draw(assetsMemoryBank[3].bitmapData,new Matrix());
            fontBmp.draw(assetsMemoryBank[4].bitmapData,new Matrix());
            titleScreenBmp.draw(assetsMemoryBank[5].bitmapData,new Matrix());
            //stars/background layer
            addChild(new Bitmap(backgroundBmd)) as Bitmap;
            //ship layer
            addChild(new Bitmap(shipBmd)) as Bitmap;
            //ennemies layer
            addChild(new Bitmap(ennemyBmd)) as Bitmap;
            //effects layer
            addChild(new Bitmap(effectsBmd)) as Bitmap;
            //ennemy bullets layer
            addChild(new Bitmap(bmd)) as Bitmap;
            //ship bullets layer
            addChild(new Bitmap(bmdShip)) as Bitmap;
            //infos layer
            addChild(new Bitmap(infosBmd)) as Bitmap;
            //prepare stars/background
            for (var i:int=0;i<starsNum;++i){
                createStar(randomNumber(0,stageW),randomNumber(0,stageH),0,randomNumber(1,5),i);
            }
            titleScreen();
        }

        private function titleScreen():void{
            titleTimer = getTimer();
            titleDisplay = 1;
            currentStage = -1;
            shipLife = 10;
            score = 0;
            stageTimeBonus = 0;
            stage.addEventListener(MouseEvent.CLICK,startGame);
            addEventListener(Event.ENTER_FRAME,titleLoop);
        }

        private function backToTitleScreen(e:Event):void{
            removeEventListener(Event.ENTER_FRAME,gameLoop);
            stage.removeEventListener(MouseEvent.CLICK, backToTitleScreen);
            clearGameStage();
            titleScreen();
        }

        private function titleLoop(e:Event):void{
            infosBmd.lock();
            infosBmd.fillRect(stageRect,0x00000000);
            infosBmd.copyPixels(titleScreenBmp,titleScreenRect,new Point(Math.round(stageW2-titleScreenBmp.width/2),30));
            var z:BitmapData = displayText("dodge da bullet human");
            var zRect:Rectangle = new Rectangle(0, 0, z.width, z.height);
            infosBmd.copyPixels(z,zRect,new Point(Math.round(stageW2-z.width/2),50));
            if (titleDisplay == 1){
                var a:BitmapData = displayText("click to start");
                var aRect:Rectangle = new Rectangle(0, 0, a.width, a.height);
                infosBmd.copyPixels(a,aRect,new Point(Math.round(stageW2-a.width/2),Math.round(stageH2-a.height/2)));
                a.dispose();
            }
            if (getTimer() - titleTimer > titleBlinkDelay){
                titleTimer = getTimer();
                titleDisplay = -titleDisplay;
            }
            var b:BitmapData = displayText("arrows to move space to fire");
            var bRect:Rectangle = new Rectangle(0, 0, b.width, b.height);
            infosBmd.copyPixels(b,bRect,new Point(Math.round(stageW2-b.width/2),stageH-b.height-1));
            b.dispose();
            infosBmd.unlock();
            starsScroll();
        }

        private function startGame(e:Event):void{
            stage.removeEventListener(MouseEvent.CLICK, startGame);
            removeEventListener(Event.ENTER_FRAME,titleLoop);
            nextStage();
        }

        private function stageInfosLoop(e:Event):void{
            if (getTimer() - stageInfosTimer > stageInfosDelay){
                removeEventListener(Event.ENTER_FRAME,stageInfosLoop);
                initKeys();
                addEventListener(Event.ENTER_FRAME,gameLoop);
            }
            else {
            infosBmd.lock();
            infosBmd.fillRect(stageRect,0x00000000);
            
                var textInfos:Array = ["stage " + (currentStage+1), stagesDescription[currentStage][2], stagesDescription[currentStage][0] + " targets to destroy", "targets shield is " + (stagesDescription[currentStage][1] == 0 ? "inactive" : "active"), "get ready"];
                for (var i:int=0;i<textInfos.length;++i){
                    if (i == 0 && stageTimeBonus>0){
                        var z:BitmapData = displayText("time bonus " + stageTimeBonus + " points");
                        var zRect:Rectangle = new Rectangle(0, 0, z.width, z.height);
                        infosBmd.copyPixels(z,zRect,new Point(Math.round(stageW2-z.width/2),Math.round(stageH2-z.height/2)-120));
                        z.dispose();
                    }
                    var a:BitmapData = displayText(textInfos[i>>0]);
                    var aRect:Rectangle = new Rectangle(0, 0, a.width, a.height);
                    infosBmd.copyPixels(a,aRect,new Point(Math.round(stageW2-a.width/2),Math.round(stageH2-a.height/2)-100+30*i));
                    a.dispose();
                }
            infosBmd.unlock();
            starsScroll();
            }
        }

        private function gameFinishedLoop(e:Event):void{
            infosBmd.lock();
            infosBmd.fillRect(stageRect,0x00000000);
            if (getTimer() - gameFinishedTimer > gameFinishedDelay){
                removeEventListener(Event.ENTER_FRAME,gameFinishedLoop);
                clearGameStage();
                titleScreen();
            }
            else {
                var textInfos:Array = ["congratulations", "your score is " + score, " ", "wondershmup", "a game by hasufel", "for wonderfl community", " ", "thank you for playing", "thank you for sharing", "dodge da bullet human"];
                for (var i:int=0;i<textInfos.length;++i){
                    var a:BitmapData = displayText(textInfos[i>>0]);
                    var aRect:Rectangle = new Rectangle(0, 0, a.width, a.height);
                    infosBmd.copyPixels(a,aRect,new Point(Math.round(stageW2-a.width/2),Math.round(stageH2-a.height/2)-140+30*i));
                }
            }
            infosBmd.unlock();
            starsScroll();
        }

        private function nextStage():void{
            removeKeys();
            removeEventListener(Event.ENTER_FRAME,gameLoop);
            //time bonus calculation
            if (currentStage>-1){
                stageTimeBonus = getTimer()-stageTimer<30000?Math.abs(Math.round((30000-(getTimer()-stageTimer))/100)):0;
                score+=stageTimeBonus;
            }
            initShip();
            clearGameStage();
            currentStage++;
            if (currentStage>stagesDescription.length-1){gameFinishedTimer = getTimer(); addEventListener(Event.ENTER_FRAME,gameFinishedLoop);}
            else {
            //prepare ennemies
            for (var i:int=0;i<stagesDescription[currentStage>>0][0];++i){
                createParticle(randomNumber(0,stageW-31),0,0,randomNumber(1,3),4);
            }
            stageInfosTimer = getTimer();
            addEventListener(Event.ENTER_FRAME,stageInfosLoop);
            }
        }

        private function clearGameStage():void{
            var layers:Array = [effectsBmd,bmdShip,shipBmd,ennemyBmd,bmd];
            for (var i:int;i<layers.length;++i){
                layers[i>>0].lock();
                layers[i>>0].fillRect(stageRect, 0x00000000);
                layers[i>>0].unlock();
            }
            ennemyBullets = new Vector.<Particle>();
            shipBullets = new Vector.<Particle>();
            impactParticles = new Vector.<Particle>();
            ennemies = new Vector.<Particle>();
        }

        private function initShip():void{
            shipVx = 0;
            shipVy = 0;
            shipX = stageW2;
            shipY = stageH-40;
        }

        private function gameLoop(e:Event):void{
            starsScroll();
            //ennemies
            var g:int = ennemies.length;
            if (g==0 && shipLife){nextStage();return;}
            if (stagesDescription[currentStage>>0][1]){
                ennemyBmd.applyFilter(ennemyBmd,stageRect,new Point(0,0),blurFilter);
            }
            ennemyBmd.lock();
            if (stagesDescription[currentStage>>0][1]==0){ennemyBmd.fillRect(stageRect,0x00000000);}
            var R:Number = .2;
            while(g--) {
                var l:Particle=ennemies[g>>0];
                l.clock = (++l.clock)%200;
                l.x = (.5 + R*Math.cos(l.clock*Math.PI/100*3))*stageW;
                l.y = (.5 + R*Math.sin(l.clock*Math.PI/100*2))*stageH2;
                ennemyBmd.copyPixels(ennemyBmp,ennemyRect,new Point(l.x,l.y), null, null, true); //mergealpha false in default
                var dx:int = (shipX+15) - (l.x+10);
                var dy:int = shipY - (l.y+20);
                var d:Number = Math.sqrt(dx * dx + dy * dy);
                if (shipLife && d < 160 && getTimer() - l.t > bulletFrequence/3) {l.t = getTimer(); d/=3; createParticle(l.x+10,l.y+20,dx/d,dy/d,2);}
                if (l.x>stageW || l.x<0 || l.y>stageH){
                    l.y = -30;
                    l.x = randomNumber(1,stageW-30);
                    l.vy = randomNumber(1,3);
                }
                if (l.y>0 && l.y<stageH-31 && testVector(bmdShip.getVector(new Rectangle(l.x,l.y,28,28)))){
                    l.power--;
                    if (l.power==0){particlesExplosion(ennemyBmp,5,l.x,l.y,5); ennemies.splice(g,1); score+=100;}
                }
            }
            ennemyBmd.unlock();

            //player fires
            if (lockFire && (getTimer() - bulletTimer > bulletFrequence)){
                bulletTimer = getTimer();
                createParticle(shipX+9,shipY,0,-spd*2,1);
            }
            var q:int = shipBullets.length;
            if (q){
            bmdShip.lock();
            bmdShip.fillRect(stageRect, 0x00000000);
            while(q--) {
                var s:Particle=shipBullets[q>>0];
                //if bullet hits something remove it
                if (s.y>0 && testVector(ennemyBmd.getVector(new Rectangle(s.x,s.y,12,12)))){
                    shipBullets.splice(q,1);
                }
                else {
                    s.x+=s.vx;
                    s.y+=s.vy;
                    point.x = s.x;
                    point.y = s.y;
                    bmdShip.copyPixels(shipBulBmp,shipBulRect,point);
                    if (s.x>stageW || s.x<0 || s.y>stageH || s.y<-12){shipBullets.splice(q,1);}
                }
            }
            bmdShip.unlock();
            }
            

            //ship handling
            if (shipLife) {
                shipX+=shipVx;
                shipY+=shipVy;
                if (shipX+30>stageW){shipVx = 0; shipX=stageW-31;}
                if (shipX<0){shipVx = 0; shipX=1;}
                
                if (shipY+35>stageH){shipVy = 0; shipY=stageH-35;}
                if (shipY<0){shipVy = 0; shipY=1;}

                
                if (!lockHorizontal){
                    if (shipVx>-.1 && shipVx<.1){
                        shipVx = 0;
                    }
                    else {
                        shipVx*=friction;
                    }
                }
                if (!lockVertical){
                    if (shipVy>-.1 && shipVy<.1){
                        shipVy = 0;
                    }
                    else {
                        shipVy*=friction;
                    }
                }
                shipBmd.applyFilter(shipBmd,stageRect,new Point(0,0),blurFilter);
                shipBmd.lock();
                shipBmd.copyPixels(shipBmp,shipRect,new Point(shipX,shipY)); //mergealpha false in default will help us create effect of ship's thrusters. User will notice from time to time black "square" around ship tho.
                shipBmd.unlock();

                //hit ennemy bullets
                if (testVector(bmd.getVector(new Rectangle(shipX+14,shipY+2,2,2)))){
                    particlesExplosion(bulBmp,5,shipX+14,shipY,2);
                    shipLife--;
                }
                //hit ennemy ship
                if (testVector(ennemyBmd.getVector(new Rectangle(shipX+14,shipY+2,2,2)))){
                    shipLife--;
                }
                if (shipLife<=0){playerDies();return;}
            }

            
            var f:int = impactParticles.length;
            effectsBmd.lock();
            effectsBmd.fillRect(stageRect, 0x00000000);
            while(f--) {
                var n:Particle=impactParticles[f>>0];
                n.x+=n.vx;
                n.y+=n.vy;
                n.vx*=.95;
                n.vy*=.95;
                effectsBmd.setPixel32(n.x,n.y,n.col);
                if (n.vx+n.vy>-.1 && n.vx+n.vy<.1){impactParticles.splice(f,1);}
            }
            effectsBmd.unlock();
            
            var o:int = ennemyBullets.length;
            bmd.lock();
            bmd.fillRect(stageRect, 0x00000000);
            while(o--) {
                var p:Particle=ennemyBullets[o>>0];
                p.x+=p.vx;
                p.y+=p.vy;
                point.x = p.x;
                point.y = p.y;
                bmd.copyPixels(bulBmp,bulRect,point,null,null,true);
                if (p.x>stageW || p.x<0 || p.y>stageH || p.y<0){ennemyBullets.splice(o,1);}
            }
            bmd.unlock();
            displayInfos();
            
        }
        
        private function starsScroll():void{
            //background stars
            var r:int = starsNum;
            backgroundBmd.lock();
            backgroundBmd.fillRect(stageRect,0x00000000);
            while(r--) {
                var v:Particle=stars[r>>0];
                v.y+=v.vy;
                backgroundBmd.setPixel32(v.x,v.y,v.c);
                if (v.y>stageH){v.y=0;v.x=randomNumber(0,stageW);}
            }
            backgroundBmd.unlock();
        }

        private function displayInfos():void{
            var a:BitmapData = displayText("energy "+shipLife);
            var aRect:Rectangle = new Rectangle(0, 0, a.width, a.height);
            if(ennemies){var b:BitmapData = displayText(ennemies.length + " targets remaining");}
            var bRect:Rectangle = new Rectangle(0, 0, b.width, b.height);
            var c:BitmapData = displayText("stage " + (currentStage+1));
            var cRect:Rectangle = new Rectangle(0, 0, c.width, c.height);
            var d:BitmapData = displayText("score " + score);
            var dRect:Rectangle = new Rectangle(0, 0, d.width, d.height);

            infosBmd.lock();
            infosBmd.fillRect(stageRect,0x00000000);
            infosBmd.copyPixels(a,aRect,new Point(0,stageH-a.height));
            infosBmd.copyPixels(b,bRect,new Point(Math.round(stageW2 - b.width/2),0));
            infosBmd.copyPixels(c,cRect,new Point(Math.round(stageW - c.width),stageH-c.height));
            infosBmd.copyPixels(d,dRect,new Point(0,stageH-d.height*2));
            if (shipLife==0){
                var z:BitmapData = displayText("game over");
                var zRect:Rectangle = new Rectangle(0, 0, z.width, z.height);
                infosBmd.copyPixels(z,zRect,new Point(Math.round(stageW2-z.width/2),Math.round(stageH2-z.height/2)-10));
                var y:BitmapData = displayText("click to continue");
                var yRect:Rectangle = new Rectangle(0, 0, y.width, y.height);
                infosBmd.copyPixels(y,yRect,new Point(Math.round(stageW2-y.width/2),Math.round(stageH2-y.height/2)+10));
            }
            infosBmd.unlock();
        }

        private function playerDies():void{
            removeKeys();
            shipLife=0;
            shipBmd.fillRect(stageRect,0x00000000);
            particlesExplosion(shipBmp,5,shipX,shipY,5);
            stage.addEventListener(MouseEvent.CLICK,backToTitleScreen);
        }

        private function testVector(a:Vector.<uint>):Boolean{
            var i:uint = a.length;
            while(i--) {if (a[i]){return true;}}
            return false;
        }

        private function particlesExplosion(bd:BitmapData,t:int,xx:int,yy:int,r:int):void{
            var a:Vector.<uint> = bd.getVector(new Rectangle(0,0,bd.width,bd.height));
            var i:uint = a.length;
            while(i--) {
                var pval:int = a[int(i)];
                var aa:int = pval >> 24;
                if (aa < 100) {
                    var dx:int = xx;
                    var dy:int = yy;
                    var px:int = int(i % bd.width)+dx;
                    var py:int = int(i / bd.height)+dy;
                    angle=Math.round(Math.random()*360);
                    createParticle(px,py,Math.cos(angle/180*Math.PI)*Math.random()*r,Math.sin(angle/180*Math.PI)*Math.random()*r,t,pval);
                }
            }
        }

        private function initKeys():void{
            lockVertical = false;
            keyVertical = 0;
            lockHorizontal = false;
            keyHorizontal = 0;
            lockFire = false;
            bulletTimer = getTimer();
            stageTimer = getTimer();
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
        }

        private function removeKeys():void{
            lockFire=false;
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
        }
        
        private function goLeft():void {
            if (!lockHorizontal || keyHorizontal != 37){keyHorizontal = 37; lockHorizontal = true; shipVx = -shipVel;}
        }
        
        private function goRight():void {
            if (!lockHorizontal || keyHorizontal != 39){keyHorizontal = 39; lockHorizontal = true; shipVx = shipVel;}
        }

        private function goUp():void {
            if (!lockVertical || keyVertical != 38){keyVertical = 38; lockVertical = true; shipVy = -shipVel;}
        }
        
        private function goDown():void {
            if (!lockVertical|| keyVertical != 40){keyVertical = 40; lockVertical = true; shipVy = shipVel;}
        }

        private function goFire():void {
            if (!lockFire){lockFire = true;}
        }

        private function unlockVertical():void {
            lockVertical = false;
        }

        private function unlockHorizontal():void {
            lockHorizontal = false;
        }

        private function unlockFire():void {
            lockFire = false;
        }

        private function keyDownHandler(e:KeyboardEvent):void {
            var a:int = e.keyCode;
            if (kd[a>>0]) {kd[a>>0]();} 
            //39 is right
            //37 is left
            //40 is down
            //38 is up
            //32 is space
        }

        private function keyUpHandler(e:KeyboardEvent):void {
            var a:int = e.keyCode;
            if (ko[a>>0]) {ko[a>>0]();}
        }

        private function displayText(s:String):BitmapData{
            var dictionnary:Object = {a:0,b:1,c:2,d:3,e:4,f:5,g:6,h:7,i:8,j:9,k:10,l:11,m:12,n:13,o:14,p:15,q:16,r:17,s:18,t:19,u:20,v:21,w:22,x:23,y:24,z:25,0:26,1:27,2:28,3:29,4:30,5:31,6:32,7:33,8:34,9:35};
            var dt:Array = s.split("");
            var dl:int = dt.length;
            var tBmd:BitmapData = new BitmapData(dl*8,8,true,0x00000000);
            tBmd.lock();
            for (var i:int=0;i<dl;++i){
                if (dt[i]== " "){}
                else {
                    tBmd.copyPixels(fontBmp,new Rectangle(dictionnary[dt[i>>0]]*8, 0, 8,8),new Point(i*8,0));                }
            }
            tBmd.unlock();
            return (tBmd);
        }

        private function createParticle(xx:Number,yy:Number,vx:Number,vy:Number,t:int,col:uint=0):void {
            var p:Particle=new Particle();
            setProps(p, {x:xx,y:yy,vx:vx,vy:vy});
            if (t==1){shipBullets.push(p);}
            else if (t==2){ennemyBullets.push(p);}
            else if (t==4){setProps(p, {t:getTimer(),power:2,clock:randomNumber(0,200)}); ennemies.push(p);}
            else if (t==5){p.col = col; impactParticles.push(p);}
        }

        private function createStar(xx:Number,yy:Number,vx:Number,vy:Number,num:int):void {
            var p:Particle=new Particle();
            setProps(p, {x:xx,y:yy,vx:vx,vy:vy,c:starsCols[randomNumber(0,4)]});
            stars[num>>0] = p;
        }

        private function setProps(o:*,p:Object):void {
            for (var k:String in p) {o[k]=p[k];}
        }
        
        private function randomNumber(low:int, high:int):int{
            return Math.round(Math.random() * (high - low) + low);
        }

    }
}

class Particle {
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var c:uint;
    public var t:uint;
    public var power:int;
    public var clock:int=0;
    public var col:uint;
}