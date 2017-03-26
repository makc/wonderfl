package {
    import flash.display.*;import flash.events.*;import flash.text.*;
    public class Main extends Sprite {
        public function Main():void {
            var colorV:Vector.<uint> = Vector.<uint>([0xffbb6666, 0xff008800, 0xff5555bb, 0xffdddd00, 0xffcc88cc, 0xff88cccc]);
            var i:int, j:int,clickCnt:int;
            var bmd:BitmapData =new BitmapData(15, 15, true, 0x00000000);
            var bmp:Bitmap = new Bitmap(bmd);
            var tf:TextField = new TextField();
            tf.text = "Start"; tf.selectable = false; tf.x = 220; tf.y = 230;addChild(tf);
            bmp.scaleX = 31; bmp.scaleY = 31;addChild(bmp);
            stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                if (bmd.getPixel32(0, 0) == 0) for (i = 0; i < 15; i++ ) for (j = 0; j < 15; j++ )
                    bmd.setPixel32(i, j, colorV[int(Math.random() * colorV.length)]);
                else {
                    clickCnt++; tf.text = "click : " + clickCnt;
                    bmd.floodFill(0, 0, bmd.getPixel32(int(e.stageX / 31), int(e.stageY / 31)));
                    var cnt:int = 0;
                    for (i = 0; i < colorV.length;i++ )cnt += bmd.getColorBoundsRect(0xffffffff, colorV[i]).isEmpty();
                    if (cnt == 5) {clickCnt = 0;bmp.bitmapData = bmd = new BitmapData(15, 15, true, 0x00000000);}
                }
            });
}   }   }