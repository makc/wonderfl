package {
    import flash.text.*;
    import flash.filters.GlowFilter;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    public class FlashTest extends Sprite {
        var coord:Array = new Array();
        var face:Array = new Array(1,0,3,2, 4,5,6,7, 0,4,7,3, 2,6,5,1, 3,7,6,2, 1,5,4,0);
        var z_ar:Array = new Array();
        //
        var tex:BitmapData;
        //
        var tri:Shape = new Shape();
        var point:Shape = new Shape();
        //
        var st:Number = 5;
        var w:Number = 16 * st;
        var rotX:int;
        var rotY:int;
        var speed:Number = 3;
        var Yx:Number = stage.stageWidth /2;
        var Yy:Number = stage.stageHeight /2;
        //
        var colF:uint = 0xffffff;
        //
        var line_:Boolean = false;
        var glow:GlowFilter = new GlowFilter(0xfd2e7e,1,30,30,1.5);
        //
        var colCode:Array = new Array(
        2,2,2,2,3,3,1,2,2,1,3,3,2,2,2,2, 
        2,1,1,1,2,3,1,1,1,1,3,2,1,1,1,2, 
        2,1,1,2,3,3,3,4,4,3,3,3,2,1,1,2, 
        2,1,2,3,3,3,3,4,4,3,3,3,3,2,1,2, 
        3,2,3,3,3,3,3,4,4,3,3,3,3,3,2,3, 
        3,3,3,3,3,3,2,2,2,2,3,3,3,3,3,3, 
        1,1,3,3,3,2,5,1,1,5,2,3,3,3,1,1, 
        2,1,4,4,4,2,5,5,5,5,2,4,4,4,1,2, 
        2,1,4,4,4,2,5,5,5,5,2,4,4,4,1,2, 
        1,1,3,3,3,2,1,5,5,1,2,3,3,3,1,1, 
        3,3,3,3,3,3,2,2,2,2,3,3,3,3,3,3,  
        3,2,3,3,3,3,3,4,4,3,3,3,3,3,2,3, 
        2,1,2,3,3,3,3,4,4,3,3,3,3,2,1,2, 
        2,1,1,2,3,3,3,4,4,3,3,3,2,1,1,2, 
        2,1,1,1,2,3,1,1,1,1,3,2,1,1,1,2, 
        2,2,2,2,3,3,1,2,2,1,3,3,2,2,2,2);
        public function FlashTest() {
            // write as3 code here..
            for(var i:int = 0; i < 8; i ++){
                    var x_:int = (i == 0 || i == 1 || i == 4 || i == 5) ? (-w + Yx) : (w + Yx);
                    var y_:int = (i == 0 || i == 1 || i == 2 || i == 3) ? (-w + Yy) : (w + Yy);
                    var z_:int = (i == 0 || i == 3 || i == 4 || i == 7) ? -w : w;
                    //
                    coord.push(x_,y_);
                    z_ar.push(z_);
            }
            //
            addChild(point);
            addChild(tri);
            //
            BMD();
            addEventListener(Event.ENTER_FRAME,fr);
            stage.addEventListener(MouseEvent.CLICK,cl);
            //
        }
        function cl(event:MouseEvent){
            line_ = (line_) ? false : true;
        }
        function fr(event:Event){
            rotX = (mouseY < Yy) ? -speed : speed;
            rotY = (mouseX < Yx) ? -speed : speed;
            //
            draw();
        }
        function draw(){
            for(var i:int = 0; i < 8; i ++){
                point.x = coord[(i * 2) + 0];
                point.y = coord[(i * 2) + 1];
                point.z = z_ar[i];
                //
                point.transform.matrix3D.appendTranslation(-Yx,-Yy,0);
                point.transform.matrix3D.appendRotation(rotX,Vector3D.X_AXIS);
                point.transform.matrix3D.appendRotation(rotY,Vector3D.Y_AXIS);
                point.transform.matrix3D.appendTranslation(Yx,Yy,0);
                //
                coord[(i * 2) + 0] = point.x;
                coord[(i * 2) + 1] = point.y;
                z_ar[i] = point.z;
            }
            //
            tri.graphics.clear();
            if(line_) tri.graphics.lineStyle(3,0x000000);
            //
            for(i = 0; i < 6; i ++){
                tri.graphics.beginBitmapFill(tex);
                tri.graphics.drawTriangles( 
                Vector.<Number>([
                //
                coord[ (face[(i * 4) + 0] * 2) + 0 ], coord[ (face[(i * 4) + 0] * 2) + 1 ],
                coord[ (face[(i * 4) + 1] * 2) + 0 ], coord[ (face[(i * 4) + 1] * 2) + 1 ],
                coord[ (face[(i * 4) + 2] * 2) + 0 ], coord[ (face[(i * 4) + 2] * 2) + 1 ],
                coord[ (face[(i * 4) + 3] * 2) + 0 ], coord[ (face[(i * 4) + 3] * 2) + 1 ] ]),
                //
                Vector.<int>([1,0,3, 3,2,1]),
                Vector.<Number>([0,0, 0,1, 1,1, 1,0]),
                TriangleCulling.NEGATIVE);
                tri.graphics.endFill();  
                tri.filters = [glow];  
            }
        }
        function BMD(){
            var g:int = 0;
            tex = new BitmapData(w,w,false);
            //
            for(var y_:int = 0; y_ < 16; y_ ++){
                    for(var x_:int = 0; x_ < 16; x_ ++){
                        tex.fillRect(new Rectangle( (st * x_), (st * y_), st, st),
                        (colCode[g] == 1) ? 0xacacac :
                        (colCode[g] == 2) ? 0x909090 :
                        (colCode[g] == 3) ? 0x6a6a6a :
                        (colCode[g] == 4) ? 0x626262 :
                        (colCode[g] == 5) ? 0xfd2e7e : colF);
                        //
                        g ++;
                    }    
            }
            //
            var bitM:Bitmap = new Bitmap(tex);
            addChild(bitM);
            //         
        }
    }
}