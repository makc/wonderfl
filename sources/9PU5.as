package {

    import flash.display.Sprite;

    import flash.events.Event;

    public class Fresnel extends Sprite {

        public var bg:Sprite=new Sprite();

        public var spr:Sprite=new Sprite();

        public var IoR:Number=1.5;

        public function Fresnel() {

            addChild(bg);

            addChild(spr);

            bg.graphics.beginFill(0);

            bg.graphics.drawRect(0,0,465,465);

            bg.graphics.endFill();

            bg.graphics.lineStyle(2,0xffffff);

            bg.graphics.drawCircle(465/2.0,465/2.0,100);

            spr.x=465/2.0;

            spr.y=465/2.0;

            addEventListener(Event.ENTER_FRAME,step);

        }

        public function step(e:Event):void{

            spr.graphics.clear();

            rayTrace(mouseX-465/2.0,mouseY-465/2.0,0,-1,1);

        }

        public function rayTrace(a:Number,b:Number,c:Number,d:Number,alpha:Number):void{

            if(alpha<0.01)return;

            var lei:Number=Math.sqrt(c*c+d*d);

            c/=lei,d/=lei;

            a+=0.1*c;

            b+=0.1*d;

            spr.graphics.lineStyle(4,0xffffff,alpha);

            spr.graphics.moveTo(a,b);

            var f:Boolean=false;

            var D:Number,t:Number,p:Number,q:Number,le:Number,nx:Number,ny:Number,dp:Number,rx:Number,ry:Number,k:Number,f0:Number,fth:Number;

            D=-a*a*d*d+2*a*b*c*d-b*b*c*c+10000;

            if(a*a+b*b<10000){

                if(D>0){

                    t=Math.sqrt(D)-a*c-b*d;

                    if(t>0){

                        p=a+c*t,q=b+d*t;

                        spr.graphics.lineTo(p,q);

                        le=Math.sqrt(p*p+q*q);

                        nx=-p/le,ny=-q/le;

                        dp=c*nx+d*ny;

                        rx=c-2*dp*nx,ry=d-2*dp*ny;
                        
                        f0=Math.pow((IoR-1)/(IoR+1),2);
                        
                        fth=f0+(1-f0)*Math.pow((1+dp),5);

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

                        spr.graphics.lineTo(p,q);

                        le=Math.sqrt(p*p+q*q);

                        nx=p/le,ny=q/le;

                        dp=c*nx+d*ny;

                        rx=c-2*dp*nx,ry=d-2*dp*ny;

                        f0=Math.pow((1/IoR-1)/(1/IoR+1),2);

                        fth=f0+(1-f0)*Math.pow((1+dp),5);

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

                    spr.graphics.lineTo(a+c*1000,b+d*1000);

                }

            }

        }

    }

}