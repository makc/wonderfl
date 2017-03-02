package
{
    import flash.display.*;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.*;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.system.Security;
    import flash.system.System;
    import flash.text.*;
    import flash.utils.*;
    import net.wonderfl.utils.SequentialLoader;
    
    [SWF(width=465, height=465, frameRate=30)]
    public class Delaunay4 extends Sprite
    {
        private var E:Vector.<IntSet>, S:Vector.<Pair>, em:Vector.<Vector.<int>>, P:Vector.<Point>;
        private var bmp:Bitmap, bmpData:BitmapData;
        private var pieceList:Vector.<Piece> = new Vector.<Piece>(), C:int=0;
        private var N:int = 500, W:int = 465, H:int = 465;
        private var imageArray:Array=[];
        
        public function Delaunay4()
        {
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, comp);
            loader.load(new URLRequest("http://assets.wonderfl.net/images/related_images/f/fe/fe83/fe83b8caeed3458725d7d8726117c3737f78dd41"), new LoaderContext(true));
        }
        
        private function comp(e:Event):void{
            e.target.loader.removeEventListener(Event.COMPLETE, comp);
            bmpData = new BitmapData(W, H, false);  
            bmp = e.target.loader.content as Bitmap;
            bmpData.draw(bmp, new Matrix(W/bmp.width, 0, 0, H/bmp.height));
            bmp.width = W;
            bmp.height = H;
            addChild(bmp);
            exe();
        }
        
        private function exe():void{
            var dic:Dictionary = new Dictionary();
            P = new Vector.<Point>();
            P.push(new Point(0, 0));
            P.push(new Point(W, 0));
            P.push(new Point(W, H));
            P.push(new Point(0, H));
            
            for(var i:int = 1; i < 10; i++){
                P.push(new Point(W/10*i, 0));
                P.push(new Point(W/10*i, H));
                P.push(new Point(W, H/10*i));
                P.push(new Point(0, H/10*i));
            }
            
            for(i = 0; i < N-40; i++){
                var xx:int = W*Math.random(), yy:int = H*Math.random();
                //近すぎる点が存在しないようにする。
                if(dic[xx+yy*W] == 1) i--;
                else {
                    P.push(new Point(xx, yy));
                    dic[xx+yy*W] = 1;
                    dic[xx+yy*W+1] = 1;
                    dic[xx+yy*W-1] = 1;
                    dic[xx+yy*W-W] = 1;
                    dic[xx+yy*W+W] = 1;
                    dic[xx+yy*W+1+W] = 1;
                    dic[xx+yy*W-1+W] = 1;
                    dic[xx+yy*W-W+1] = 1;
                    dic[xx+yy*W-W-1] = 1;
                }
            }
            
            if(delaunay() == -1){
                exe();
                return;
            }
            else{
                for(i = 0; i < N; i++){
                    for(var j:int = i+1; j < N; j++){
                        if(em[i][j] >= 0 && em[i][j] < N){
                            var centerX:Number = (P[i].x+P[j].x+P[em[i][j]].x)/3;
                            var centerY:Number = (P[i].y+P[j].y+P[em[i][j]].y)/3;
                            var sp:Piece = new Piece(centerX, centerY, Math.random()*10-5, Math.random()*20-10, (W/2-centerX)*(W/2-centerX)+(H/2-centerY)*(H/2-centerY));
                            sp.graphics.beginFill(bmpData.getPixel(centerX, centerY));
                            sp.graphics.moveTo(P[i].x-centerX, P[i].y-centerY);
                            sp.graphics.lineTo(P[j].x-centerX, P[j].y-centerY);
                            sp.graphics.lineTo(P[em[i][j]].x-centerX, P[em[i][j]].y-centerY);
                            sp.graphics.lineTo(P[i].x-centerX, P[i].y-centerY);
                            sp.x = centerX;
                            sp.y = centerY;
                            sp.visible = false;
                            pieceList.push(sp);
                            addChild(sp);
                        }
                    }
                }
            }
            pieceList.sort(order);
            stage.addEventListener(MouseEvent.CLICK, onClick);
        }
        
        private function onClick(e:MouseEvent):void{
            stage.removeEventListener(MouseEvent.CLICK, onClick);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function onClick2(e:MouseEvent):void{
            removeChild(bmp);
            stage.removeEventListener(MouseEvent.CLICK, onClick2);
            addEventListener(Event.ENTER_FRAME, onEnterFrame2);
        }
        
        private function onEnterFrame(e:Event):void{
            for(var i:int = 0; i < 200 && C < pieceList.length; i++){
                pieceList[C].visible = true;
                C++;
            }
            if(C == pieceList.length){
                stage.addEventListener(MouseEvent.CLICK, onClick2);
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            }
        }
        
        private function onEnterFrame2(e:Event):void{
            var i:int = pieceList.length;
            while(i--){
                var p:Piece = pieceList[i];
                p.update();
                if(p.x < -20 || p.x > W+20 || p.y > H+20){
                    pieceList.splice(i,1);
                    removeChild(p);
                }
            }
        }
        
        private function order(A:Piece, B:Piece):int{
            if(A.order < B.order) return -1;
            else return 1;
        }
        
        private function set_triangle(i:int, j:int, r:int):void{
            E[i].push(j);
            E[j].push(r);
            E[r].push(i);
            em[i][j] = r;
            em[j][r] = i;
            em[r][i] = j;
            S.push(new Pair(i, j));
        }
        
        private function remove_edge(i:int, j:int):void{
            E[i].erase(j);
            em[i][j] = -1;
            E[j].erase(i);
            em[j][i] = -1;
        }
        
        private function decompose_on(i:int, j:int, k:int, r:int):void{
            var m:int = em[j][i]; 
            remove_edge(j,i);
            set_triangle(i,m,r); 
            set_triangle(m,j,r);
            set_triangle(j,k,r); 
            set_triangle(k,i,r);
        }
        
        private function decompose_in(i:int, j:int, k:int, r:int):void{
            set_triangle(i, j, r);
            set_triangle(j, k, r);
            set_triangle(k, i, r);
        }
        
        private function flip_edge(i:int, j:int, r:int):void{
            var k:int = em[j][i];
            remove_edge(i, j);
            set_triangle(i, k, r);
            set_triangle(k, j, r);
        }
        
        private function is_legal(i:int, j:int):Boolean{
            return em[i][j] < 0 || em[j][i] < 0 || !MMath.incircle(P[i], P[j], P[em[i][j]], P[em[j][i]]);
        }
        
        private function ccw(a:Point, b:Point, c:Point):int{
            b = b.subtract(a); c = c.subtract(a);
            if (MMath.cross(b, c) > 0)   return 1;
            if (MMath.cross(b, c) < 0)   return -1;
            if (MMath.dot(b, c) < 0)     return 2;
            if (MMath.norm(b) < MMath.norm(c)) return -2;
            return 0;
        }
        
        
        private function delaunay():Number{
            const n:int = P.length;
            P.push(new Point(-int.MAX_VALUE,-int.MAX_VALUE));
            P.push(new Point(int.MAX_VALUE,-int.MAX_VALUE));
            P.push(new Point(0,int.MAX_VALUE));
            
            E = new Vector.<IntSet>();
            S = new Vector.<Pair>();
            em = new Vector.<Vector.<int>>();
            for(var i:int = 0; i < n+3; i++){
                em[i] = new Vector.<int>();
                for(var j:int = 0; j < n+3; j++) em[i][j] = -1;
                E[i] = new IntSet();
            }
            set_triangle(n, n+1, n+2);
            for (var r:int = 0; r < n; ++r){
                var k:int;
                i = n;
                j = n+1;
                var cnt:int = 0;
                while(1){
                    cnt++;
                    if(cnt > 1000) return -1;
                    k = em[i][j];
                    if      (ccw(P[i], P[em[i][j]], P[r]) == 1) j = k;
                    else if (ccw(P[j], P[em[i][j]], P[r]) == -1) i = k;
                    else break;
                }
                if      (ccw(P[i], P[j], P[r]) != 1) { decompose_on(i,j,k,r); }
                else if (ccw(P[j], P[k], P[r]) != 1) { decompose_on(j,k,i,r); }
                else if (ccw(P[k], P[i], P[r]) != 1) { decompose_on(k,i,j,r); }
                else                                  { decompose_in(i,j,k,r); }
                while (S.length != 0) {
                    if(S.length > 100) return -1;
                    var pair:Pair = S.pop();
                    var u:int = pair.first, v:int = pair.second; 
                    if (!is_legal(u, v)) flip_edge(u, v, r);
                }
            }
            var minarg:Number = 1e5;
            for (var a:int = 0; a < n; ++a) {
                for (i = 0; i < E[a].length; i++) {
                    var b:int = E[a].get_element(i), c:int = em[a][b];
                    if (b < n && c < n) {
                        var p:Point = P[a].subtract(P[b]), q:Point = P[c].subtract(P[b]);
                        minarg = Math.min(minarg, Math.acos(MMath.dot(p,q)/p.length/q.length));
                    }
                }
            }
            return minarg;
        }
    }
}

import flash.display.*;
import flash.geom.*;

class Piece extends Sprite{
    private var vx:Number, vy:Number
    public var order:int;
    public function Piece(x:Number ,y:Number, vx:Number, vy:Number, order:int){
        this.x = x; this.y = y; this.vx = vx; this.vy = vy; this.order = order;
    }
    
    public function update():void{
        this.x += vx;
        this.y += vy;
        this.vy += 0.6;
    }
}

class MMath{
    //外積
    public static function cross(a:Point, b:Point):Number {
        return a.x*b.y-b.x*a.y;
    }
    
    //内積
    public static function dot(a:Point, b:Point):Number {
        return a.x*b.x+a.y*b.y;
    }
    
    //ノルム
    public static function norm(a:Point):Number{
        return a.x*a.x+a.y*a.y;
    }
    
    //3点 a,b,cを通る円に点pが内包されるかどうか
    public static function incircle(a:Point, b:Point, c:Point, p:Point):Boolean {
        a = a.subtract(p); 
        b = b.subtract(p);
        c = c.subtract(p);
        return norm(a) * cross(b, c) + norm(b) * cross(c, a) + norm(c) * cross(a, b) >= 0;
    }
}

class IntSet{
    private var array:Array = [];
    
    public function push(n:int):void{
        for(var i:int = 0; i < array.length; i++) if(array[i] == n) return;
        array.push(n);
    }
    
    public function erase(n:int):void{
        for(var i:int = 0; i < array.length; i++) 
            if(array[i] == n){
                array.splice(i, 1);
                return;
            }
    }
    
    public function get_element(index:int):int{
        return array[index];
    }
    
    public function get length():uint{ return array.length };
}

class Pair{
    public var first:int, second:int;
    public function Pair(first:int, second:int){ this.first = first; this.second = second; }
}