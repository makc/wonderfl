<?xml version="1.0" encoding="utf-8"?>
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" width="465" height="465" creationComplete="atReady(event)">
    <!-- ===============================================
    パターンジェネレーター Patern Generator
    
    [使い方 A]
    ウェブデザインの背景のパターンを作ったりする
    
    [使い方 B]
    CHECKMATEのProfessional問題のパターンに使えます
    http://wonderfl.net/c/dD7k
    ※CHECKMATEの出題問題はパターンのデザインを競い合うものではなくて
    　パターンを駆使してどのような表現をするかが趣旨だと思うので
    　このツールで簡単に投稿できるようになりますが、
    　パターンだけのはあんまり量産しないといいと思います。。たぶん。
    ================================================ -->
    <mx:Script>
        <![CDATA[
            import mx.utils.ColorUtil;
            import mx.graphics.codec.PNGEncoder;
            import mx.events.ListEvent;
            import mx.collections.ArrayCollection;
            
            private var sp:Sprite;
            private var paint:Bitmap;
            
            protected function atReady(event:Event):void
            {
                sp = bg.addChild(new Sprite()) as Sprite;
                
                sizeCombo.dataProvider = new ArrayCollection([
                    {label:"2x2", px:2},
                    {label:"4x4", px:4},
                    {label:"8x8", px:8},
                    {label:"16x16", px:16},
                    {label:"32x32", px:32},
                    {label:"48x48", px:48},
                    {label:"64x64", px:64},
                    {label:"128x128", px:128}
                ]);
                sizeCombo.selectedIndex = 1;
                
                paint = new Bitmap(null);
                patern.addChild(paint);
                
                sizeChange();
                
                paint.bitmapData = build(
                    [
                        [1,0,0,0],
                        [0,1,0,0],
                        [0,0,1,0],
                        [0,0,0,1]
                    ],
                    [0xFFEEEEEE, 0xFF336699]
                );
                
                update();
            }

            protected function onMouseDown(event:MouseEvent):void
            {
                var px:int = sizeCombo.selectedItem.px;
                paint.bitmapData.setPixel(patern.mouseX / (10 * 16 / px), patern.mouseY / (10 * 16 / px), myColor.selectedColor);
                update();
            }
            
            private function update():void
            {
                var g:Graphics = sp.graphics;
                g.beginBitmapFill(paint.bitmapData);
                g.drawRect(0,0,465,465);
                g.endFill();
            }

            protected function sizeChange(event:ListEvent = null):void
            {
                var px:int = sizeCombo.selectedItem.px;
                var bmpdata:BitmapData = new BitmapData(px, px, false, 0xFFCCCCCC);
                paint.bitmapData = bmpdata;
                paint.scaleX = paint.scaleY = 10 * 16 / px;
                update();
            }
            
            protected function saveFile(event:MouseEvent):void
            {
                var f:FileReference = new FileReference();
                f.save(new PNGEncoder().encode(paint.bitmapData), "patern.png");
            }
            
            protected function loadImage(event:MouseEvent):void
            {
                // ローカル画像の読み込み
                var fr:FileReference = new FileReference();
                fr.browse();
                fr.addEventListener("select", function():void { fr.load(); });
                fr.addEventListener("complete", function():void {
                      var loader:Loader = new Loader();
                      loader.contentLoaderInfo.addEventListener("init", function():void {
                          var matrix:Matrix = new Matrix();
                          matrix.scale(sizeCombo.selectedItem.px / loader.content.width, sizeCombo.selectedItem.px / loader.content.height); 
                      paint.bitmapData.draw(loader, matrix, null, null, null, true);
                      loader.unload();
                    });
                    loader.loadBytes(fr.data);
                });
            }
            
            /**
             * creates BitmapData filled with dot pattern.
             * First parameter is 2d array that contains color index for each pixels;
             * Second parameter contains color reference table.
             *
             * @parameter pattern:Array 2d array that contains color index for each pixel.
             * @parameter colors:Array 1d array that contains color table.
             * @returns BitmapData
             */
            public static function build(pattern:Array, colors:Array):BitmapData{
                var bitmapW:int = pattern[0].length;
                var bitmapH:int = pattern.length;
                var bmd:BitmapData = new BitmapData(bitmapW,bitmapH,true,0x000000);
                for(var yy:int=0; yy<bitmapH; yy++){
                    for(var xx:int=0; xx<bitmapW; xx++){
                        var color:int = colors[pattern[yy][xx]];
                        bmd.setPixel32(xx, yy, color);
                    }
                }
                return bmd;
            }

            protected function copyCheckmate(event:MouseEvent):void
            {
                var p:Array = [];
                var c:Array = [];
                var i:int, j:int, k:int;
                for(i=0; i<paint.bitmapData.height; i++)
                {
                    p[i] = [];
                    for(j=0; j<paint.bitmapData.width; j++)
                    {
                        var flag:Boolean = false;
                        for(k=0; k<c.length; k++)
                            if(paint.bitmapData.getPixel32(j,i) == c[k]) {flag = true; break;}
                        if(!flag)
                            c.push(paint.bitmapData.getPixel32(j,i));
                        for(k=0; k<c.length; k++)
                            if(paint.bitmapData.getPixel32(j,i) == c[k]) break;
                        p[i][j] = k;
                    }
                }
                
                // debug
                paint.bitmapData = build(p,c);
                update();
                
                // for text
                var str:String = "[\n";
                for(i=0; i<p.length; i++)
                {
                    str += "    " + "[";
                    for(j=0; j<p[i].length; j++)
                        str += (j==0 ? "" : ",") + p[i][j];
                    str += "]"+ (i==p.length-1 ? "" : ", ") + "\n";
                }
                str += "],\n[";
                for(i=0; i<c.length; i++) str += "0x" + c[i].toString(16) + (i==c.length-1 ? "" : ", ");
                str += "]";
                trace(str)
                System.setClipboard(str);
            }
        ]]>
    </mx:Script>
    
    <mx:UIComponent id="bg" />
    
    <mx:Panel paddingBottom="5" paddingLeft="5" paddingRight="5" paddingTop="5" x="200" y="50">
        <mx:HBox>
            <mx:Label text="Size" width="50" />
            <mx:ComboBox id="sizeCombo" change="sizeChange(event)" />
        </mx:HBox>
        <mx:HBox>
            <mx:Label text="Color" width="50" />
            <mx:ColorPicker id="myColor"/>
        </mx:HBox>
        <mx:Button label="Load Image" click="loadImage(event)" toolTip="ローカルの画像を読み込んでパターンに使用します" />
        <mx:Label text="Please Paint" />
        <mx:UIComponent id="patern" mouseDown="onMouseDown(event)" width="160" height="160" />
        <mx:Button label="Copy checkmate patern" click="copyCheckmate(event)" toolTip="チェックメイト用のパターンJSONをコピーします" />
        <mx:Button label="Save PNG" click="saveFile(event)" toolTip="PNGファイルでパターンを保存します" />
    </mx:Panel>
</mx:Application>
