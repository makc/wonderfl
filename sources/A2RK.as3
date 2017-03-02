 //Nやwtの値を変えると違う模様ができる。 
//例えば、N=3,wt=0.5のとき、シェルピンスキーの三角形。
//ChaosGameは前に作りましたが、今度はBitmapというものをを使ってみた。
package { 
    import flash.display.*; 
    import flash.text.TextField;  
    
    //[SWF(width="400",height="400",backgroundColor="#ffffff")] 
    public class ChaosGame extends Sprite { 
        private const N:Number = 5; 
        private const wt:Number = 0.6; 
        public function ChaosGame() { 
            // write as3 code here.. 
            var bmp_data : BitmapData = new BitmapData( 400, 400, true, 0xFF000000);
            var bitmap : Bitmap = new Bitmap(bmp_data);
            addChild(bitmap);
            var x:Number = 1; 
            var y:Number = 0; 

            
            for(var i:int = 0;i<100000;i++){ 
                var a:int = Math.random()*N >> 0; 
                var vx:Number = Math.cos(a*2*Math.PI/N); 
                var vy:Number = Math.sin(a*2*Math.PI/N); 
                x = x + (vx - x) * wt; 
                y = y + (vy - y) * wt; 
                bmp_data.setPixel(x*200+200,y*200+200,0xFFFFFF); 
            } 
        } 
    } 
}
