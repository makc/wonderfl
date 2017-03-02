// forked from phi16's ff: ff: Reflection
// forked from imo_'s ff: Reflection
// forked from phi16's Reflection
package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    public class Fresnel extends Sprite {
        public var bg:Sprite=new Sprite();
        public var spr:Array=new Array();
        public var time:Number=0;
        public var IoR:Number=0;
        public var col:uint=0;
        public var layerN:int=9;
        public var curL:int=0;
        public function Fresnel() {
            addChild(bg);
            for(var i:int=0;i<layerN;i++){
                spr[i]=new Sprite();
                spr[i].blendMode="lighten";
                spr[i].x=465/2.0;
                spr[i].y=465/2.0;
                addChild(spr[i]);
            }
            bg.graphics.beginFill(0);
            bg.graphics.drawRect(0,0,465,465);
            bg.graphics.endFill();
            bg.graphics.lineStyle(2,0xffffff);
            bg.graphics.drawCircle(465/2.0,465/2.0,100);
            addEventListener(MouseEvent.MOUSE_MOVE,step);
        }
        public function step(e:MouseEvent):void{
            for(var i:int=0;i<layerN;i++){
                spr[i].graphics.clear();
                var wl:Number=380+(400/(layerN-1))*i;
                IoR=getIoR(wl);
                col=spectreRGB(wl);
                curL=i;
                rayTrace(mouseX-465/2.0,mouseY-465/2.0,0,-1,1);
            }
            time++;
        }
        public function rayTrace(a:Number,b:Number,c:Number,d:Number,alpha:Number):void{
            if(alpha<0.01)return;
            var lei:Number=Math.sqrt(c*c+d*d);
            c/=lei,d/=lei;
            a+=0.1*c;
            b+=0.1*d;
            spr[curL].graphics.lineStyle(6,col,alpha);
            spr[curL].graphics.moveTo(a,b);
            var f:Boolean=false;
            var D:Number,t:Number,p:Number,q:Number,le:Number,nx:Number,ny:Number,dp:Number,rx:Number,ry:Number,k:Number,sn:Number,fth:Number;
            D=-a*a*d*d+2*a*b*c*d-b*b*c*c+10000;
            if(a*a+b*b<10000){
                if(D>0){
                    t=Math.sqrt(D)-a*c-b*d;
                    if(t>0){
                        p=a+c*t,q=b+d*t;
                        spr[curL].graphics.lineTo(p,q);
                        le=Math.sqrt(p*p+q*q);
                        nx=-p/le,ny=-q/le;
                        dp=c*nx+d*ny;
                        rx=c-2*dp*nx,ry=d-2*dp*ny;                        
                        sn=Math.abs(c*ny-d*nx);                       
                        fth=1/(IoR*IoR)-sn*sn;
                        if(fth<0)fth=1;
                        else fth=Math.pow((-dp-Math.sqrt(fth))/(-dp+Math.sqrt(fth)),2)+Math.pow((IoR*IoR*Math.sqrt(fth)+dp)/(IoR*IoR*Math.sqrt(fth)-dp),2);
                        if(fth<0)fth=0;
                        if(fth>0.9)fth=0.9;
                        
                        rayTrace(p,q,rx,ry,alpha*fth);
                        k=1.0-IoR*IoR*(1.0-dp*dp);
                        if(k>0){  
                            rx=IoR*c-(IoR*dp+Math.sqrt(k))*nx;    
                            ry=IoR*d-(IoR*dp+Math.sqrt(k))*ny;
                            rayTrace(p,q,rx,ry,alpha*(1-fth));
                        }
                        f=true;
                    }
                }
            }else{
                if(D>0){
                    t=-Math.sqrt(D)-a*c-b*d;
                    if(t>0){
                        p=a+c*t,q=b+d*t;
                        spr[curL].graphics.lineTo(p,q);
                        le=Math.sqrt(p*p+q*q);
                        nx=p/le,ny=q/le;
                        dp=c*nx+d*ny;
                        rx=c-2*dp*nx,ry=d-2*dp*ny;
                        sn=Math.abs(c*ny-d*nx);    
                                            
                        fth=IoR*IoR-sn*sn;
                        if(fth<0)fth=1;
                        else fth=Math.pow((-dp-Math.sqrt(fth))/(-dp+Math.sqrt(fth)),2)+Math.pow((1/(IoR*IoR)*Math.sqrt(fth)+dp)/(1/(IoR*IoR)*Math.sqrt(fth)-dp),2);
                        if(fth<0)fth=0;
                        if(fth>0.9)fth=0.9;
                                          
                        rayTrace(p,q,rx,ry,alpha*fth);
                        k=1.0-1/(IoR*IoR)*(1.0-dp*dp);
                        if(k>0){
                            rx=1/IoR*c-(1/IoR*dp+Math.sqrt(k))*nx;
                            ry=1/IoR*d-(1/IoR*dp+Math.sqrt(k))*ny;
                            rayTrace(p,q,rx,ry,alpha*(1-fth));
                        }
                        f=true;
                    }
                }
                if(!f){
                    spr[curL].graphics.lineTo(a+c*1000,b+d*1000);
                }
            }
        }
    }
}

function getIoR(x:Number):Number{ //Glass, BK7(SHOTT)
    var data:Array=[1.73759695,0.013188707,0.313747346,0.0623068142,1.89878101,155.23629];
    x/=1000;
    x*=x;
    var s:Number=0;
    for(var i:int=0;i<3;i++){
        s+=data[2*i]*x/(x-data[2*i+1]);
    }
    return Math.sqrt(s+1);
}

function spectreRGB(x:Number):int{
    if(x<380)return 0;
    else if(x>780)return 0;
    var data:Array=[
      [4.010353218,-80.63249483,631.7030634,-2340.443417,3649.476495,0,-4177.888781],
      [0.277385381,-11.15063994,185.6265588,-1637.093036,8062.307429,-21008.39274,22614.05094],
      [-0.105722006,2.746241678,-27.82592878,133.2858701,-268.2029047,0,505.990267],
      [-8.591709666,229.2801983,-2539.539977,14942.14013,-49253.65203,86238.82071,-62662.66903],
      [-2.50432e-05,0.000231452,0,0,0,0,-1.042682898],
      [0,0,0,0,0,0,0]];
    var ri:uint=x<470?0:x<550?5:1;
    var gi:uint=x<460?5:x<610?2:5;
    var bi:uint=x<520?3:x<760?5:4;
    x/=100;
    var r:Number=0,g:Number=0,b:Number=0;
    for(var i:int=0;i<7;i++){
        r=r*x+data[ri][i];
        g=g*x+data[gi][i];
        b=b*x+data[bi][i];
    }
    r*=255/213.0;
    g*=255/197.0;
    b*=255/184.0;
    var rs:int=Math.floor(Math.max(0,Math.min(1,r))*255);
    var gs:int=Math.floor(Math.max(0,Math.min(1,g))*255);
    var bs:int=Math.floor(Math.max(0,Math.min(1,b))*255);
    return (rs<<16)+(gs<<8)+bs;
}