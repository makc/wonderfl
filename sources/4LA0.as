package {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    public class Tetris extends Sprite {
        public var frm:Sprite = new Sprite();
        public var bgr:Sprite = new Sprite();
        public var spr:Sprite = new Sprite();
        public var txf:TextField = new TextField();
        public var states:Quantum = new Quantum();
        public var count:int = 0;
        public var motion:Boolean = false;
        public function Tetris(){
            this.addChild(frm);
            this.addChild(bgr);
            this.addChild(spr);
            this.addChild(txf);
            txf.x=txf.y=0;
            txf.width=100,txf.height=100;
            var format:TextFormat = new TextFormat();
            format.size=20;
            txf.setTextFormat(format);
            txf.textColor=0xffffff;
            frm.graphics.beginFill(0);
            frm.graphics.drawRect(0,0,465,465);
            frm.graphics.endFill();
            frm.graphics.beginFill(0);
            frm.graphics.lineStyle(1,0x1f1f1f);
            for(var i:int=-1;i<11;i++){
                for(var j:int=-3;j<21;j++){
                    if(i==-1 || i==10 || j==20){
                        frm.graphics.beginFill(0x3f3f3f);
                        frm.graphics.lineStyle(1,0x7f7f7f);
                    }
                    else if(j<0)frm.graphics.lineStyle(1,0x0f0f0f);
                    frm.graphics.drawRect(20*3+i*20,465-20*21+j*20,20-1,20-1);
                    if(i==-1 || i==10 || j==20){
                        frm.graphics.beginFill(0);
                        frm.graphics.lineStyle(1,0x1f1f1f);
                    }
                    else if(j<0)frm.graphics.lineStyle(1,0x1f1f1f);
                }
            }
            bgr.graphics.clear();
            states.generate();
            states.cache(bgr.graphics);
            stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);
            this.addEventListener(Event.ENTER_FRAME,frame);
        }
        public function keyDown(e:KeyboardEvent):void{
            if(!motion){
                if(e.keyCode==Keyboard.LEFT)states.move(-1,0);
                if(e.keyCode==Keyboard.DOWN){
                    states.freeFall(),count=0;       
                    bgr.graphics.clear();
                    states.cache(bgr.graphics);
                }
                if(e.keyCode==Keyboard.RIGHT)states.move(1,0);
                if(e.keyCode==Keyboard.UP){
                    motion=states.hardDrop();
                    bgr.graphics.clear();
                    states.cache(bgr.graphics);
                    count=0;
                }
                if(e.keyCode==65+25)states.rotate(-1);
                if(e.keyCode==65+23)states.rotate(1);
            }
        }
        public function frame(e:Event):void{
            spr.graphics.clear();
            states.draw(spr.graphics);
            txf.text=new String(states.states.length);
            if(motion){
                if(count>=20){
                    states.erase();
                    states.generate();
                    bgr.graphics.clear();
                    states.cache(bgr.graphics);
                    motion=false;
                }
            }else if(count>=40){
                count=0;
                if(!states.freeFall()){
                    motion=states.hardDrop();
                }
                bgr.graphics.clear();
                states.cache(bgr.graphics);
            }
            count++;
        }
    }
}
import flash.display.*;

var minoes:Array=new Array(0x022232,0x112122,0x112102,0x011122,0x212202,0x010222,0x112202)//IOSZLJT
var colour:Array=new Array(0x00FFFF,0xFFFF00,0x00FF00,0xFF0000,0xFF7F00,0x0000FF,0x7F00FF);
var center:Array=new Array([1.5,2.5],[1.5,1.5],[1,2],[1,2],[1,2],[1,2],[1,2]);
var srs:Array=[[
        [
            [[-1,0],[-1,-1],[0,2],[-1,2]],
            [[1,0],[1,-1],[0,2],[1,2]],
        ],
        [
            [[1,0],[1,1],[0,-2],[1,-2]],
            [[1,0],[1,1],[0,-2],[1,-2]],
        ],
        [
            [[1,0],[1,-1],[0,2],[1,2]],
            [[-1,0],[-1,-1],[0,2],[-1,2]],
        ],
        [
            [[-1,0],[-1,1],[0,-2],[-1,-2]],
            [[-1,0],[-1,1],[0,-2],[-1,-2]],
        ]],[
        [
            [[-2,0],[1,0],[-2,1],[1,-2]],
            [[-1,0],[2,0],[-1,-2],[2,1]],
        ],
        [
            [[-1,0],[2,0],[-1,-2],[2,1]],
            [[2,0],[-1,0],[2,-1],[-1,2]],
        ],
        [
            [[2,0],[-1,0],[2,-1],[-1,2]],
            [[1,0],[-2,0],[1,2],[-2,-1]],
        ],
        [
            [[1,0],[-2,0],[1,2],[-2,-1]],
            [[-2,0],[1,0],[-2,1],[1,-2]],
        ],
    ]];
var xmin:int=20*3;
var ymin:int=465-20*21;
var nxmin:int=330;
var nymin:int=40;
var trig:Array=[[1,0],[0,1],[-1,0],[0,-1]];

function addColour(m:int,i:int,j:int,r:Array,g:Array,b:Array,c:Array):void{
    r[i][j]+=colour[m]>>16;
    g[i][j]+=(colour[m]>>8)%256;
    b[i][j]+=colour[m]%256;
    c[i][j]++;
}
function rotateP(x:int,y:int,m:int,r:int):Array{
    var p:Number=x-center[m][0],q:Number=y-center[m][1];
    var u:Number=p*trig[r][0]-q*trig[r][1]+center[m][0],v:Number=p*trig[r][1]+q*trig[r][0]+center[m][1];
    return new Array(int(u+0.5),int(v+0.5));
}

function drawPiece(p:int,q:int,rot:int,m:int,r:Array,g:Array,b:Array,c:Array):void{
    for(var i:int=0;i<4;i++){
        var x:int,y:int;
        if(i==3)x=1,y=2;
        else x=(minoes[m]>>(4*2*i+4))%16,y=(minoes[m]>>(4*2*i))%16;
        var a:Array=rotateP(x,y,m,rot);
        x=a[0],y=a[1];
        addColour(m,x+p,y+q,r,g,b,c);
    }
}

class Next {
    public var rest:Array;
    public var count:int;
    public function Next(){
        rest = new Array(1,1,1,1,1,1,1);
        count = 0;
    }
    public function consume(u:int):void{
        rest[u]=0;
        count++;
        if(count>=7){
            rest = new Array(1,1,1,1,1,1,1);
            count-=7;
        }
    }
    public function clone():Next{
        var n:Next=new Next();
        for(var i:int=0;i<7;i++)n.rest[i]=rest[i];
        n.count=count;
        return n;
    }
    public function cache(r:Array,g:Array,b:Array,c:Array):void{
        for(var i:int=0;i<5;i++){
            for(var j:int=0;j<7;j++){
                if(rest[j]==1 || 7-count <= i){
                    drawPiece(0,i*4,0,j,r,g,b,c);
                }
            }
        }
    }
}

class State {
    public var field:Array;
    public var next:Next;
    public var x:int;
    public var y:int;
    public var rot:int;
    public var curB:int;
    public var falling:Boolean;
    public function State(){
        field = new Array();
        for(var i:int=0;i<10;i++){
            field[i]=new Array();
            for(var j:int=0;j<20;j++){
                field[i][j]=7;
            }
        }
        next = new Next();
        falling = false;
    }
    public function generate():Array{
        x=3,y=-2,rot=0;
        var arr:Array=new Array();
        var j:int=0;
        for(var i:int=0;i<7;i++){
            if(next.rest[i]==1){
                arr[j]=this.clone();
                arr[j].curB=i;
                arr[j].next.consume(i);
                arr[j].falling=true;
                j++;
            }
        }
        return arr;
    }
    public function clone():State{
        var s:State=new State();
        for(var i:int=0;i<10;i++){
            for(var j:int=0;j<20;j++){
                s.field[i][j]=field[i][j];
            }
        }
        s.next=next.clone();
        s.x=x;
        s.y=y;
        s.rot=rot;
        s.curB=curB;
        s.falling=falling;
        return s;
    }
    public function draw(r:Array,g:Array,b:Array,c:Array):void{
        if(falling)drawPiece(x,y+3,rot,curB,r,g,b,c);
    }
    public function cache(r:Array,g:Array,b:Array,c:Array):void{
        for(var i:int=0;i<10;i++){
            for(var j:int=0;j<20;j++){
                if(field[i][j]!=7){
                    addColour(field[i][j],i,j,r,g,b,c);
                }
            }
        }
    }
    public function invalid():Boolean{
        for(var i:int=0;i<4;i++){
            var p:int,q:int;
            if(i==3)p=1,q=2;
            else p=(minoes[curB]>>(4*2*i+4))%16,q=(minoes[curB]>>(4*2*i))%16;
            var a:Array=rotateP(p,q,curB,rot);
            p=x+a[0],q=y+a[1];
            if(p<0 || p>9 || q>19)return true;
            if(q>=0 && field[p][q]!=7)return true;
        }
        return false;
    }
    public function move(i:int,j:int):Boolean{
        x+=i,y+=j;
        if(invalid()){
            x-=i,y-=j;
            return false;
        }
        return true;
    }
    public function rotate(r:int):void{
        var oRot:int=rot;
        rot+=r+4;
        rot%=4;
        var a:int=curB!=0?0:1;
        var b:int=r!=1?1:0;
        for(var i:int=0;i<5;i++){
            var p:int,q:int;
            if(i>0){
                p=srs[a][oRot][b][i-1][0];
                q=srs[a][oRot][b][i-1][1];
            }else p=q=0;
            x+=p,y+=q;
            if(!invalid())return;
            x-=p,y-=q;
        }
        rot+=4-r;
        rot%=4;
    }
    public function fix():void{
        for(var i:int=0;i<4;i++){
            var p:int,q:int;
            if(i==3)p=1,q=2;
            else p=(minoes[curB]>>(4*2*i+4))%16,q=(minoes[curB]>>(4*2*i))%16;
            var a:Array=rotateP(p,q,curB,rot);
            p=x+a[0],q=y+a[1];
            if(q>=0)field[p][q]=curB;
            falling=false;
        }
    }
    public function erase():int{
        var ls:int=0;
        for(var j:int=19;j>-1;j--){
            var p:Boolean=true;
            for(var i:int=0;i<10;i++){
                if(field[i][j]==7)p=false;
            }
            if(p){
                for(var k:int=j;k>0;k--){
                    for(var u:int=0;u<10;u++){
                        field[u][k]=field[u][k-1];
                    }
                }
                for(u=0;u<10;u++){
                    field[u][0]=7;
                }
                j++;
                ls++;
            }
        }
        return ls;
    } 
    public function eraseLine():int{
        var ls:int=0;
        for(var j:int=19;j>-1;j--){
            var u:Boolean=true;
            for(var i:int=0;i<10;i++){
                if(field[i][j]==7)u=false;
            }
            if(u)ls++;
        }
        return ls;
    }
}

class Quantum {
    public var states:Array;
    public function Quantum(){
        states=new Array(new State());
    }
    public function generate():void{
        var ss:Array=new Array();
        for each(var s:State in states){
            ss=ss.concat(s.generate());
        }
        states=ss;
    }
    public function hardDrop():Boolean{
        for each(var s:State in states){
            while(s.move(0,1)){};
            s.fix();
        }
        return collapse();
    }
    public function move(x:int,y:int):void{
        for each(var s:State in states){
            s.move(x,y);
        }
    }
    public function rotate(x:int):void{
        for each(var s:State in states){
            s.rotate(x);
        }
    }
    public function freeFall():Boolean{
        var f:Boolean=false;
        var g:Boolean=false;
        var e:Array=new Array();
        var r:Array=new Array();
        var p:int=0;
        for(var i:int=0;i<states.length;i++){
            e[i]=states[i].move(0,1);
            r[i]=states[i].eraseLine()*(e[i]?0:1);
            if(r[i]>p)p=r[i];
            if(e[i])f=true;
            if(!e[i])g=true;
        }
        if(p > 0 && false){
            for(i=0;i<states.length;i++){
                if(r[i]!=p){
                    states.splice(i,1);
                    r.splice(i,1);
                    i--;
                }
            }
            return false;
        }else if(f && g){
            for(i=0;i<states.length;i++){
                if(!e[i]){
                    states.splice(i,1);
                    e.splice(i,1);
                    i--;
                }
            }
            return true;
        }
        return f;
    }
    public function erase():void{
        var lns:int=0;
        var e:Array=new Array();
        for(var i:int=0;i<states.length;i++){
            e[i]=states[i].erase();
            if(e[i]>lns)lns=e[i];
        }
        for(i=0;i<states.length;i++){
            if(e[i]!=lns){
                states.splice(i,1);
                e.splice(i,1);
                i--;
            }
        }
    }
    public function collapse():Boolean{
        var lns:int=0;
        var e:Array=new Array();
        for(var i:int=0;i<states.length;i++){
            e[i]=states[i].eraseLine();
            if(e[i]>lns)lns=e[i];
        }
        if(lns==0 || states.length==1){
            erase();
            generate();      
            return false;
        }
        for(i=0;i<states.length;i++){
            if(e[i]!=lns){
                states.splice(i,1);
                e.splice(i,1);
                i--;
            }
        }
        return true;
    }
    public function draw(g:Graphics):void{
        var n:Number=states.length;
        var rs:Array=new Array();
        var gs:Array=new Array();
        var bs:Array=new Array();
        var cs:Array=new Array();
        for(var i:int=0;i<10;i++){
            rs[i]=new Array();
            gs[i]=new Array();
            bs[i]=new Array();
            cs[i]=new Array();
            for(var j:int=0;j<23;j++)rs[i][j]=gs[i][j]=bs[i][j]=cs[i][j]=0;
        }
        for each(var s:State in states){
            s.draw(rs,gs,bs,cs);
        }
        for(i=0;i<10;i++){
            for(j=-3;j<20;j++){
                if(cs[i][j+3]>0){
                    var rc:int=rs[i][j+3]/cs[i][j+3],gc:int=gs[i][j+3]/cs[i][j+3],bc:int=bs[i][j+3]/cs[i][j+3];
                    var c:int=(rc<<16)+(gc<<8)+bc;
                    g.beginFill(c,0.5);
                    g.lineStyle(2,c,1);
                    g.drawRect(xmin+i*20,ymin+j*20,20-1,20-1);
                    g.endFill();
                }
            }
        }
    }
    public function cache(g:Graphics):void{
        var n:Number=states.length;
        var rs:Array=new Array();
        var gs:Array=new Array();
        var bs:Array=new Array();
        var cs:Array=new Array();
        for(var i:int=0;i<10;i++){
            rs[i]=new Array();
            gs[i]=new Array();
            bs[i]=new Array();
            cs[i]=new Array();
            for(var j:int=0;j<20;j++)rs[i][j]=gs[i][j]=bs[i][j]=cs[i][j]=0;
        }
        for each(var s:State in states){
            s.cache(rs,gs,bs,cs);
        }
        for(i=0;i<10;i++){
            for(j=0;j<20;j++){
                if(cs[i][j]>0){
                    var rc:int=rs[i][j]/n,gc:int=gs[i][j]/n,bc:int=bs[i][j]/n;
                    var c:int=(rc<<16)+(gc<<8)+bc;
                    g.beginFill(c,0.5);
                    g.lineStyle(1,c,1);
                    g.drawRect(xmin+i*20,ymin+j*20,20-1,20-1);
                    g.endFill();
                }
            }
        }
        for(i=0;i<4;i++)for(j=0;j<20;j++)rs[i][j]=gs[i][j]=bs[i][j]=cs[i][j]=0;
        for each(s in states){
            s.next.cache(rs,gs,bs,cs);
        }
        for(var k:int=0;k<5;k++){
            for(i=0;i<4;i++){
                for(j=0;j<4;j++){
                    if(cs[i][j+k*4]>0){
                        rc=rs[i][j+k*4]/cs[i][j+k*4],gc=gs[i][j+k*4]/cs[i][j+k*4],bc=bs[i][j+k*4]/cs[i][j+k*4];
                        c=(rc<<16)+(gc<<8)+bc;
                        g.beginFill(c,0.5);
                        g.lineStyle(1,c,1);
                        g.drawRect(nxmin+i*20,nymin+j*20+k*80,20-1,20-1);
                        g.endFill();
                    }
                }
            }
        }
    }
}
