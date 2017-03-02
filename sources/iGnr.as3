package {
    import flash.text.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.events.*;
    import flash.display.*;
    import net.hires.debug.Stats;
    import com.bit101.components.Label;
    [SWF(frameRate = 60)]
    final public class Main extends Sprite {
        public static const MAX:Number = 1000;
        public static const RANGE:Number = 50;//影響半径
        public static const V_DIV:uint = Math.ceil(465 / RANGE); //横方向の分割数
        public static const H_DIV:uint = Math.ceil(465 / RANGE); //縦方向の分割数
        
        private var map:Vector.<Vector.<Vector.<Particle>>>;
        private var particles:Vector.<Particle>;
        private var img:BitmapData; 
        
        private var numParticles:uint;
        private var color:ColorTransform;
        private var count:int;
        private var press:Boolean;
        private var text:Label;
        
        public function Main() {
            addEventListener( Event.ADDED_TO_STAGE, initialize );
        }
        
        
        private function initialize( e:Event ):void {
            color = new ColorTransform( 0.80, 0.80, 0.85, 1, -3,-2,-2 );
            particles = new Vector.<Particle>();
            numParticles = 0;
            count = 0;
            img = new BitmapData(465, 465, false, 0);
            addEventListener(Event.EXIT_FRAME, frame);
            addChild( new Bitmap(img) );
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { press = true; });
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void { press = false; } );
            stage.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:MouseEvent):void { addShark() } );

            stage.quality = "low";
            stage.doubleClickEnabled = true;
            stage.addChild( new Stats ).alpha = 0.5;
            text = new Label( stage, 75, 0, "numParticles: " + numParticles );
            
            
            map = new Vector.< Vector.< Vector.<Particle> > >(H_DIV);
            map.fixed = true;
            for(var i:uint = 0; i<H_DIV; i++ ){
                map[i] = new Vector.< Vector.<Particle> >(V_DIV);
                map[i].fixed = true;
                for(var j:uint = 0; j<H_DIV; j++ ){
                    map[i][j] = new Vector.< Particle >; 
                }
            }
        }

        private function frame(e:Event):void {
            if(press)
                addSardine();
            img.lock();            
            img.colorTransform(img.rect, color);
            setNeighbors();
            move();
            img.unlock();
            text.text = "numParticles: " + numParticles;
        }
       
        
        private function addSardine():void {
            if( numParticles < MAX ){
                 const p:Particle = particles[numParticles++] = new Sardine( mouseX, mouseY );
                 p.move();
            }
        }
        
        private function addShark():void {
            const p:Particle = particles[numParticles++] = new Shark( mouseX, mouseY );
            p.move();
        }

        private function setNeighbors():void {
            var dx:Number, dy:Number;
            const particles:Vector.<Particle> = this.particles;
            
            //分割された各領域ごとで近くのパーティクルをさがす。
            for(var i:uint= 0; i < H_DIV; i++) {
                const mapi:Vector.<Vector.<Particle>> = map[i];
                for(var j:uint = 0; j < V_DIV; j++){
                    var mapij:Vector.<Particle> = mapi[j];
                    var minN:int = i-1; if( minN < 0 ){ minN = 0 }
                    var minM:int = j-1; if( minM < 0 ){ minM = 0 }
                    var maxN:int = i+2; if( maxN > H_DIV ){ maxN = H_DIV }
                    var maxM:int = j+2; if( maxM > V_DIV ){ maxM = V_DIV }
                    for each( var pi:Particle in mapij ){
                        l:{
                            for(var n:uint = minN; n < maxN; n++ ){
                                const mapn:Vector.<Vector.<Particle>> = map[n];
                                for(var m:uint = minM; m < maxM; m++ ){
                                    const mapnm:Vector.<Particle> = mapn[m];
                                    for each(var pj:Particle in mapnm ){
                                        //piと同じパーティクルが現れたら終了
                                        if ( pi == pj ) { break l; }
                                        pi.lookAt( pj );
                                        pj.lookAt( pi );
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        private function move():void {
            count++;
            const img:BitmapData = this.img;
            const particles:Vector.<Particle> = this.particles;
            
            for(var i:uint = 0; i < numParticles; i++) {
                const pi:Particle = particles[i];
                if ( pi.life <= 0 ) {
                    particles.splice( i, 1 );
                    pi.moveMap( map );
                    numParticles--;
                    i--;
                }else{
                    pi.move();
                    pi.moveMap( map );
                    pi.draw( img );
                }
            }
        }        
    }
}
import flash.display.*;
import flash.geom.*;

class Particle {
    public var x:Number;    //x方向の位置
    public var y:Number;    //y方向の位置
    public var mapX:uint;    
    public var mapY:uint;    
    public var vx:Number;   //vx方向の位置
    public var vy:Number;   //vy方向の位置
    public var fx:Number;   //x方向の加速度
    public var fy:Number;   //y方向の加速度
    public static const DF:Number = 0.96; //抵抗係数
    public var color:uint = 0xFFFFFF;
    public var life:int = 1;
    
    public function Particle(x:Number, y:Number) {
        this.x = x;
        this.y = y;
        vx = vy = 0;
        fx = fy = 0;
    }
    
    public function move():void {
        x += vx += fx;
        y += vy += fy;
        vx *= DF;
        vy *= DF;
        fx = 0;
        fy = 0;
        
        if (x < 1 ) { vy = 0; vx = 0; x = 1; }
        else if(x > 464 ){ vy = 0; vx = 0; x = 464 }
        if(y < 1 ){ vy = 0; vx = 0; y = 1; }
        else if(y > 464 ){ vy = 0; vx = 0; y = 464 }   
    }
    
    public function lookAt( p:Particle ):void {}
    
    public function moveMap( map:Vector.<Vector.<Vector.<Particle>>> ):void {
        const mx:int = this.x / Main.RANGE;
        const my:int = this.y / Main.RANGE;
        const pmx:int = this.mapX;
        const pmy:int = this.mapY;
        if( life == 0 || mx != pmx || my != pmy ){
            const mp:Vector.<Particle> = map[ pmx ][ pmy ]
            const index:int = mp.indexOf( this );
            if ( index != -1) {
                mp.splice( index, 1 );
            }
            if( life != 0 ){
                map[ mx ][ my ].push( this );
                this.mapY = my; this.mapX = mx;
            }
        }
    }
    
    public function draw( img:BitmapData ):void{
        img.setPixel( x, y, color )
    }
}

class Fish extends Particle {
    public var neighbor:Particle;
    public var d2:Number;
    public var dx:Number;
    public var dy:Number;
    
    function Fish( x:Number, y:Number ){
        super( x, y );
    }
    
    //壁際の処理
    protected function wall( push:Number, r:Number ):void{
        if ( x < r ) { fx += push / x; }
        else if ( x > 465 - r ) { fx -= push / (465 - x); }
        if ( y < r ) { fy += push / y; }
        else if ( y > 465 - r ) { fy -= push / (465 - y); }
    }
    
    //前方に加速
    protected function thrust( f:Number, r:Number ):void {
        var vx2:Number = r * ( 1 - 2 * Math.random() ) + vx;
        var vy2:Number = r * ( 1 - 2 * Math.random() ) + vy;
        var v:Number = f * Math.random() / Math.sqrt( vx2 * vx2 + vy2 * vy2 );
        fx += vx2 * v;
        fy += vy2 * v;
    }
    
    protected function guide( pull:Number, push:Number ):void {
        var d:Number = Math.sqrt( d2 );
        var f:Number = -push/(d*d) + pull;
        fx += dx * f;
        fy += dy * f;
    }
    protected function escape( f:Number ):void {
        var r:Number = f / Math.sqrt( dx*dx + dy*dy );
        fx -= dx * r;
        fy -= dy * r;
    }
    protected function chase( f:Number ):void {
        var r:Number = f// / Math.sqrt( dx*dx + dy*dy );
        fx += dx * r;
        fy += dy * r;
    }
    
    //速度を丸める
    protected function round( min:Number, max:Number ):void{
        var f2:Number = fx * fx + fy * fy;
        var r:Number;
        if ( f2 == 0 ) {
        }else{
            if ( f2 < min*min ) {
                r = min / Math.sqrt( f2 );
                fx *= r;
                fy *= r;
            }else if( f2 > max*max ){
                r = max / Math.sqrt( f2 );
                fx *= r;
                fy *= r;
            }
        }
    }
}

class Sardine extends Fish {
    private static const MAX:Number = 0.08;    //最大の加速度
    private static const MIN:Number = 0;        //最小の加速度
    private static const RANGE:Number = 40;    //視界半径
    private static const PULL:Number = 0.01; //引き寄せる力
    private static const PUSH:Number = 0.5; //離れる力
    private static const WALL:Number = 0.8; //壁から離れる力
    private static const THRUST:Number = 0.05; //前方へ進む力
    private static const RAND:Number = 0.2; //気まぐれの大きさ
    private static const RAND2:Number = 0.5; //気まぐれの大きさ2
    
    function Sardine( x:Number, y:Number ){
        super( x, y );
        vx = ( 1 - 2 * Math.random() ) * .5;
        vy = ( 1 - 2 * Math.random() ) * .5;
    }
    
    override public function move():void {
        var f:Number, d:Number, dx:Number, dy:Number;
        if( neighbor is Shark ){
            escape( MAX );
        }else{
            thrust( THRUST, RAND );
            if ( neighbor is Fish ) {
                guide( PULL, PUSH );
            }
        }
        neighbor = null;
        d2 = RANGE * RANGE;
        wall( WALL, RANGE );
        round( MIN, MAX );
        super.move();
    }
    
    override public function lookAt( p:Particle ):void {
        var dx:Number, dy:Number, d2:Number;
        if( p is Shark ){
            if ( neighbor is Sardine ) {             
                this.dx = p.x - x;
                this.dy = p.y - y;
                this.d2 = dx * dx + dy * dy;
                neighbor = p;
                return;
            }
            dx = p.x - x;
            dy = p.y - y;
            d2 = dx * dx + dy * dy;
            if ( d2 < this.d2 ) {
                this.d2 = d2;
                this.dx = dx;
                this.dy = dy;
                neighbor = p;
            }
        }else if( p is Sardine ){
            if ( neighbor is Shark ) { return; }
            if( Math.random() < RAND2 ){ return; } //時々一番近い魚の以外にも注目する。
            dx = p.x - x;
            dy = p.y - y;
            d2 = dx * dx + dy * dy;
            if ( d2 < this.d2 ) {
                this.d2 = d2;
                this.dx = dx;
                this.dy = dy;
                neighbor = p;
            }
        }
    }
}

class Shark extends Fish {
    private static const MAX:Number = 0.1;    //最大の加速度
    private static const MIN:Number = 0.06;        //最小の加速度
    private static const RANGE:Number = 50;    //視界半径
    private static const PUSH:Number = 0.5; //離れる力
    private static const WALL:Number = 1; //壁から離れる力
    private static const THRUST:Number = 0.08; //前方へ進む力
    private static const RAND:Number = 1; //気まぐれの大きさ
    private static const SIZE:Number = 2;
    private var shape:Shape = new Shape;
    
    function Shark( x:Number, y:Number ){
        super( x, y );
        vx = ( 1 - 2 * Math.random() ) * .5;
        vy = ( 1 - 2 * Math.random() ) * .5;
        with ( shape.graphics ) {
            beginFill( 0x6688FF, 1 );
            drawCircle( 0, 0, SIZE );
        }
    }
    
    override public function move():void {
        var f:Number, d:Number, dx:Number, dy:Number;
        if ( neighbor is Sardine ) {
            chase( MAX );
        }else {
            thrust( THRUST, RAND );
            if( neighbor is Shark ){
                guide( 0, PUSH )
            }
        }
        neighbor = null;
        d2 = RANGE * RANGE;
        wall( WALL, RANGE );
        round( MIN, MAX );
        super.move();
    }
    
    override public function lookAt( p:Particle ):void {
        var dx:Number, dy:Number, d2:Number;
        if( p is Sardine ){
            if ( neighbor is Shark ) {             
                this.dx = p.x - x;
                this.dy = p.y - y;
                this.d2 = dx * dx + dy * dy;
                neighbor = p;
                return;
            }
            dx = p.x - x;
            dy = p.y - y;
            d2 = dx * dx + dy * dy;
            if ( d2 < this.d2 ) {
                this.d2 = d2;
                this.dx = dx;
                this.dy = dy;
                neighbor = p;
            }
            if( d2 < SIZE*SIZE ){ p.life = 0; }
        }else if( p is Shark ){
            if ( neighbor is Sardine ) { return; }
            dx = p.x - x;
            dy = p.y - y;
            d2 = dx * dx + dy * dy;
            if ( d2 < this.d2 ) {
                this.d2 = d2;
                this.dx = dx;
                this.dy = dy;
                neighbor = p;
            }
        }
    }
    override public function draw(img:BitmapData):void {
        img.draw( shape, new Matrix(1,0,0,1,x,y) );
    }
}