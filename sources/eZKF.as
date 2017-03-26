// forked from takuya1021's Chaos Game
 //Nやwtの値を変えると違う模様ができる。 
//例えば、N=3,wt=0.5のとき、シェルピンスキーの三角形。
//ChaosGameは前に作りましたが、今度はBitmapというものをを使ってみた。
package { 
    import flash.display.*; 
    import flash.filters.*; 
    import flash.geom.*; 
    import flash.text.TextField;  
    
    //[SWF(width="400",height="400",backgroundColor="#ffffff")] 
    public class ChaosGame extends Sprite { 
        private const bf:BlurFilter = new BlurFilter;
        private const ct:ColorTransform =
            new ColorTransform (0.9, 0.7, 0.5);
        private var N:Number = 5; 
        private var wt:Number = 0.6; 
        private var bmp_data:BitmapData;
        public function ChaosGame() { 
            // write as3 code here.. 
            bmp_data = new BitmapData( 465, 465, true, 0xFF000000);
            var bitmap : Bitmap = new Bitmap(bmp_data);
            addChild(bitmap);
            addEventListener ("enterFrame", loop);
        }
        private function loop (e:*):void {
            var x:Number = 1; 
            var y:Number = 0;
            N = 3 + 5 * mouseY / 465;
            wt = mouseX / 465;
            //bmp_data.fillRect (bmp_data.rect, 0xFF000000);
            bmp_data.colorTransform (bmp_data.rect, ct);
            bmp_data.applyFilter (bmp_data, bmp_data.rect, bmp_data.rect.topLeft, bf);
            bmp_data.lock ();
            for(var i:int = 0;i<10000/*0*/;i++){ 
                var a:int = Math.random()*N >> 0; 
                var vx:Number = Math.cos(a*2*Math.PI/N); 
                var vy:Number = Math.sin(a*2*Math.PI/N); 
                x = x + (vx - x) * wt; 
                y = y + (vy - y) * wt; 
                bmp_data.setPixel((x+1)*456*0.5,(y+1)*465*0.5,0xFFFFFF); 
            }
            bmp_data.unlock ();
        } 
    } 
}
