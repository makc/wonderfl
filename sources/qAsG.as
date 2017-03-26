//モンテカルロ法を使ったTETRIS AI
package {
    import flash.events.Event;
    import flash.display.Sprite;
    import flash.utils.setInterval;
    import com.bit101.components.*;
    
    [SWF(backgroundColor="0x22282F", frameRate="60")]
    public class Main extends Sprite {
        private var tetris1:Tetris = new Tetris();
        static public const W:uint = 465; 
        static public const H:uint = 465; 

        private var line:Label;
        private var point:Label;
        private var state:Label;
        
        private var radio:Array = []
        private var ps:Array = [ "human", "randomCPU", "normalCPU", "MonteCarloCPU" ]
        
        function Main() {
            line = new Label( this, 250, 400, "LINE:" );
            line.scaleX = line.scaleY = 2;
            point = new Label( this, 250, 370, "POINT:" );
            point.scaleX = point.scaleY = 2;
            state = new Label( this, 250, 340, "LIFE:" );
            state.scaleX = state.scaleY = 2;
            var fps:FPSMeter = new FPSMeter( this, 250, 310 )
            fps.scaleX = fps.scaleY = 2;
            
            var lbl:Label = new Label( this, 0, 0, "TETRIS AI" );
            lbl.scaleX = lbl.scaleY = 3;
            
            
            
            for( var i:int=0; i<ps.length; i++ ){
                new RadioButton( this, 270, 90 + 40*i, ps[i], true, start );
            }
            
             
            
            tetris1.player = new MonteCarloCPU( tetris1 );
            var map:TetrisMap = new TetrisMap(tetris1)
            map.x = ( 250 - map.width ) / 2;
            map.y = 35 + ( 430 - map.height ) / 2;
            addChild( map );
            
            tetris1.init()
            addEventListener( "exitFrame", progress );
        }
        
        public function progress( e:Event ):void{ 
            tetris1.progress();
            state.text = "LIFE: " + tetris1.getState();
            point.text = "POINT: " + tetris1.point;
            line.text = "LINE: " + tetris1.line;
        }
        
        public function start( e:Event ):void{
            switch( e.currentTarget.label ){
                case "normalCPU":
                    tetris1.player = new NormalCPU( tetris1 );
                    break;
                case "randomCPU":
                    tetris1.player = new RandomCPU( tetris1 );
                    break;
                case "human":
                    tetris1.player = new Human( tetris1, stage );
                    break;
                case "MonteCarloCPU":
                    tetris1.player = new MonteCarloCPU( tetris1 );
                    break;
            }
            tetris1.init();
        }

    }
}

import flash.events.KeyboardEvent;
import flash.display.Stage;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.display.Bitmap;
import frocessing.color.FColor;

class TetrisMap extends Bitmap{
    public var tetris:Tetris;
    
    static public const CT:ColorTransform = new ColorTransform( 0.5, 0.7, 0.8, 1 ); 
    static public const OUT_CT:ColorTransform = new ColorTransform( 0.2, 0.2, 0.2, 1, 20, 20, 20 ); 
    static public const CELL:uint = 17;
    static private function f( u:int ):uint{ return FColor.HSVtoValue(u,0.5,0.5); }
    static public const BL_C:Array = [ f(0), f(37), f(73), f(110), f(147), f(183), f(220) ];
    
    function TetrisMap( tetris:Tetris ){
        this.tetris = tetris;
        super( new BitmapData( Tetris.W*CELL+1, Tetris.H*CELL+1, false, 0 ) );
        addEventListener( "exitFrame", draw );
    }
    
    public function draw( e:Event ):void{
        var b:BitmapData = bitmapData;
        b.colorTransform( b.rect, CT );
        for( var i:uint = 0; i < Tetris.W; i++ ){
            for( var j:uint = 0; j < Tetris.H; j++ ){ 
                if( tetris.map[i][j] > -1 ){ b.fillRect( new Rectangle(i*CELL+2, j*CELL+2, CELL-3, CELL-3), 0xFF223344 ) }
            }    
        }
        drawGrid(); drawBlock();
        b.colorTransform( new Rectangle( 0,0,Tetris.W*CELL+1,Tetris.OUT*CELL ), OUT_CT );
    }
    private function drawGrid():void{
        var b:BitmapData = bitmapData;
        for( var i:uint = 0; i < Tetris.W+1; i++ ){ b.fillRect( new Rectangle( i*CELL, 0, 1, Tetris.H*CELL+1 ), 0xFF112233 ) }
        for( var j:uint = 0; j < Tetris.H+1; j++ ){ b.fillRect( new Rectangle( 0, j*CELL, Tetris.W*CELL+1, 1 ), 0xFF112233 ) }
    }
    private function drawBlock():void{
        var b:BitmapData = bitmapData;
        var m:Matrix = Tetris.DIR[tetris.dir];
        var c:uint = BL_C[tetris.block];
        var bl:Array = Tetris.BL[tetris.block];
        for( var i:uint = 0; i < 2; i++ ){
            for( var j:uint = 0; j < 4; j++ ){
                if( bl[i][j] == 1 ){
                    var x:int = tetris.bx + j*m.a + i*m.b + m.tx;
                    var y:int = tetris.by + j*m.c + i*m.d + m.ty;
                    b.fillRect( new Rectangle( x*CELL+2, y*CELL+2, CELL-3, CELL-3 ), c )
                }
            }
        }
    }
}

class Tetris implements Game{
    static public const W:uint = 10;
    static public const H:uint = 22;
    static public const OUT:uint = 2;
    static public const BL:Array = [
        /*O*/[[0,1,1,0],[0,1,1,0]],
        /*Z*/[[1,1,0,0],[0,1,1,0]],
        /*S*/[[0,1,1,0],[1,1,0,0]],
        /*I*/[[0,0,0,0],[1,1,1,1]],
        /*L*/[[0,0,1,0],[1,1,1,0]],
        /*Γ*/[[1,0,0,0],[1,1,1,0]],
        /*T*/[[0,1,0,0],[1,1,1,0]]
    ]
    static public const DIR:Array = [
        new Matrix( 1,0,0,1,-1,-1 ),
        new Matrix( 0,-1,1,0,1,-1 ),
        new Matrix( -1,0,0,-1,1,1 ),
        new Matrix( 0,1,-1,0,-1,1 )
    ];
    static public var span:int = 100;
    static public var PT_AR:Array = [1,3,10,20];
    
    public var player:Player;
    
    
    public var map:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
    public var bx:int; 
    public var by:int;
    public var dir:int;
    public var block:uint;
    public var count:int;
    public var gameOver:Boolean = false;
    public var actable:Boolean = false;
    public var point:int;
    public var line:int; 
    
    function Tetris(){}
    public function init():void{
        actable = false;
        gameOver = false;
        count = 0;
        point = 0;
        line = 0;
        for( var i:uint = 0; i < W; i++ ){
            map[i] = new Vector.<int>()
            for( var j:uint = 0; j < H; j++ ){
                map[i][j] = -1;
            }    
        }
        if( player ){ player.init() }
    }
    
    
    private function setBlock( b:uint ):void { bx = 4; by = 1; dir = 0; block = b;  actable = true; }
    
    private function checkLine():void {
        var map:Vector.<Vector.<int>> = this.map;
        var count:int = -1;
        for( var j:uint = 0; j<H; j++ ){
            s:{
                var f:Boolean = true;
                for( var i:uint = 0; i<W; i++ ){
                    if( map[i][j] == -1 ){ f = false; break s; }
                }
                count++; line++; removeLine(j)
            }
        }
        if( count >= 0 ){ point += PT_AR[count] }
    }
    
    private function removeLine( h:uint ):void { 
        var map:Vector.<Vector.<int>> = this.map;
        for( var j:uint = h; j>0; j-- ){
            for( var i:uint = 0; i<W; i++ ){ 
                map[i][j] = map[i][j-1];
            }
        }
        for( var i2:uint = 0; i2<W; i2++ ){ map[i2][0] = -1; }
    }
    
    private function stopBlock():void{
        var m:Matrix = DIR[dir];
        var bl:Array = BL[block];
        var map:Vector.<Vector.<int>> = this.map;
        for( var i:uint = 0; i < 2; i++ ){
            for( var j:uint = 0; j < 4; j++ ){
                if( bl[i][j] == 1 ){
                    var x:int = bx + j*m.a + i*m.b + m.tx;
                    var y:int = by + j*m.c + i*m.d + m.ty;
                    map[x][y] = block;
                    if( y < OUT ){ gameOver = true }
                }
            }
        }
        checkLine();
        actable = false;
    }
    
    public function progress():void{
        if(! gameOver ){
            if(! actable ){ reaction( (Math.random()*7) >>> 0 ); }
            else if( player ){ player.action() }
            if( count++ > span && (!_action(0,1,0)) ){ stopBlock(); }
        }
    }
    
    public function action( ...arg ):void{
        var dx:int = arg[0], dy:int = arg[1], spin:int = arg[2], fall:Boolean = arg[3]; 
        if( spin > 0 ){ _action(0,0,spin%4); spin = 0 }
        while( dx > 0 ){ _action(1,0,0); dx-- }
        while( dx < 0 ){ _action(-1,0,0); dx++ }
        while( dy > 0 ){ _action(0,1,0); dy-- } 
        if( fall ){ while( _action(0,1,0) ){}; }
    }
    
    private function _action( dx:int, dy:int, ddir:int ):Boolean{
        if( block == 0 ){ ddir = 0 }
        var m:Matrix = DIR[ (dir + ddir)%4 ];
        var bl:Array = BL[ block ];
        for( var i:uint = 0; i < 2; i++ ){
            for( var j:uint = 0; j < 4; j++ ){
                if( bl[i][j] == 1 ){
                    var x:int = bx + j*m.a + i*m.b + m.tx + dx;
                    var y:int = by + j*m.c + i*m.d + m.ty + dy;
                    if( x < 0 || x >= W || y < 0 || y >= H ){ if(dy>0){stopBlock()}; return false; }
                    if( map[x][y] > -1 ){ if(dy>0){stopBlock()}; return false; }
                }
            }
        }
        bx+=dx; by+=dy; dir=(dir+ddir)%4;
        if( dy > 0 ){ count = 0 }
        return true;
    }
    
    public function reaction( ...arg ):void{ setBlock( arg[0] ); }
    
    public function clone():Game{ 
        var c:Tetris = new Tetris();
        var map:Vector.<Vector.<int>> = this.map;
        c.bx = bx; c.by = by; c.dir = dir; c.block = block; c.actable = true;
        for( var i:uint = 0; i < W; i++ ){
            c.map[i] = new Vector.<int>()
            for( var j:uint = 0; j < H; j++ ){ c.map[i][j] = map[i][j] }
        }
        return c;
    }
    
    public function getState():Number{ 
        var arr:Vector.<Number> = _getStateArray(2);
        return arr[0] + arr[1]*0.5;
    }
    
    public function _getStateArray( l:uint ):Vector.<Number>  {  
        var array:Vector.<Number> = new Vector.<Number>();
        var map:Vector.<Vector.<int>> = this.map;
        for( var s:uint = 0; s<l; s++ ){
            var p:int = 0;
            l1:{
                var ll:int = W-s; 
                for( var i:uint = 0; i<ll; i++ ){
                    l2:{
                        for( var j:uint = 0; j<H; j++ ){
                            var f:Boolean = false;
                            for( var k:uint = 0; k<=s; k++ ){ if( map[i+k][j] > -1 ){f=true} }
                            if( f ){
                                if( j < OUT ){ p = 0; break l1; } 
                                p += j; break l2; 
                            }
                        }           
                        if(!f){ p += j }; 
                    }
                }
            }
            array.push(p);
        }
        return array;
    }
    
    public function getAction():Array{
        var arr:Array = []; 
            var l:uint = block == 0 ? 1 : ( block < 4 ? 2 : 4);
        for( var s:uint = 0; s < l; s++ ){
            for( var j:uint = 0; j < W; j++ ){
                arr.push( [j-bx,0,s,true] )
            }
        }
        return arr; 
    }
    public function getReaction():Array{
        return [ [0],[1],[2],[3],[4],[5],[6] ]; 
    }
}

interface Game{
    function action( ...arg ):void
    function reaction( ...arg ):void
    function clone():Game;
    function getAction():Array;
    function getReaction():Array;
    function getState():Number;
}

class Player{
    public var game:Game;
    function Player( game:Game ){
        this.game = game; 
    }
    public function action():void{} 
    public function init():void{}
    public function getPoint(target:*):Object{ return null }
}

class Human extends Player{
    public var dx:int = 0;
    public var dy:int = 0;
    public var fall:Boolean = false;
    public var spin:int = 0;
    
    function Human( game:Game, stage:Stage ){
        super( game );
        stage.addEventListener( KeyboardEvent.KEY_DOWN, onKey )
    }
    
    
    override public function action():void{
        game.action( dx, dy, spin, fall );
        dx = 0; dy = 0; spin = 0; fall = false;
    }
    
    private function onKey( e:KeyboardEvent ):void{
        switch( e.keyCode ){
            case 90: spin++; break;
            case 88: spin+=3; break;
            case 38: fall=true; break;
            case 39: dx++; break;
            case 37: dx--; break;
            case 40: dy++; break;
        }
    }
    
}

class RandomCPU extends Player{
    function RandomCPU( game:Game){ super(game); }
    override public function action():void{
        var act:Array = game.getAction();
        game.action.apply( null, act[ (act.length*Math.random()) >>> 0 ] );
    }
}

class NormalCPU extends Player{
    function NormalCPU( game:Game){ super(game); }
    override public function action():void{
        actionAt( game )
    }
    static public function actionAt( game:Game ):void{ 
        var act:Array = game.getAction();
        var act2:Array = [];
        var act3:Array = [];
        var l2:int = 0;
        var l3:int = 0;
        
        var points:Vector.<Number> = new Vector.<Number>();
        var l:uint = act.length;
        var max:int = 0;
        for( var i:uint = 0; i<l; i++ ){
            var clone:Game = game.clone();
            clone.action.apply( null, act[ i ] );
            var p:int = clone.getState();
            if( p >= max ){ max = p; points.push( p ); act2.push( act[i] ); l2++; }
        }
        
        for( var j:uint = 0; j<l2; j++ ){
            if( points[j] == max ){
                act3.push( act2[j] ); l3++;
            }
        }
        game.action.apply( null, act3[ (l3*Math.random()) >>> 0 ] );
        
    }
}

class MonteCarloCPU extends Player{
    public var depth:int = 3; //読みの深さ
    public var thickness:int = 1; //読みの太さ
    public var fork:int = 8; //分岐の数
    
    function MonteCarloCPU( game:Game ){ super(game); }
    
    override public function action():void{
        var act:Vector.<Array> = Vector.<Array>( game.getAction() );
        var points:Vector.<Number> = new Vector.<Number>;
        var clones:Vector.<Game> = new Vector.<Game>;     
        var l:uint = act.length;
        var max:uint = 0;
        
        //1手読む
        function _1():void{ 
            for( var i:uint = 0; i<l; i++ ){
                var clone:Game = game.clone();
                clone.action.apply( null, act[ i ] );
                var p:int = clone.getState();
                if( p > max ){ max = p }
                points.push( p );
                clones.push( clone );
            }
        }
        
        //点の高いものを選び出す。
        function _2():void{
            if( l > thickness ){    
                var act2:Vector.<Array> = new Vector.<Array>;
                var points2:Vector.<Number> = new Vector.<Number>;
                var clones2:Vector.<Game> = new Vector.<Game>;  
                var l2:int = 0;
                while( l2 < thickness ){
                    var max2:int = 0;
                    for( var i:uint = 0; i<l; i++ ){
                        var pt:int = points[i]
                        if( pt == max ){
                            points2.push( 0 ); points.splice( i, 1 );
                            clones2.push( clones[i] ); clones.splice( i, 1 );
                            act2.push( act[i] ); act.splice( i, 1 )
                            i--; l--; l2++;
                        }else{
                            if( pt > max2 ){ max2 = pt; }
                        }   
                    } 
                    max = max2;
                }
                act=act2; points=points2; clones=clones2;
                l = l2;
            }
        }
        
        //各手を深読み
        function _3():void {
            for( var i:uint = 0; i<l; i++ ){
                for( var j:uint = 0; j<fork; j++ ){
                    var g:Game = clones[i].clone();
                    for( var k:uint = 0; k<depth; k++ ){
                        var re:Array = g.getReaction(); 
                        g.reaction.apply( null, re[ (re.length * Math.random()) >>> 0 ] )
                        NormalCPU.actionAt( g );
                        points[i] += g.getState();
                    }
                }
            }
        }
        
        //もっとも点の高い手を実行する。
        function _4():void {
            for( var i:uint = 0; i<l; i++ ){
                var p:int = points[i];
                if( p > max ){ max = p }
                points.push( p )
            }
            for( var j:uint = 0; j<l; j++ ){
                if( points[j] < max ){
                    points.splice( j, 1 );
                    act.splice( j, 1 );
                    j--; l--;
                }
            }
            game.action.apply( null, act[ (l*Math.random()) >>> 0 ] );
        }

        _1(); _2(); _3(); _4();
    }
    
}


import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Loader;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import net.wonderfl.utils.WonderflAPI;

class ScoreWindowLoader
{
    private static var _top: DisplayObjectContainer;
    private static var _api: WonderflAPI;
    private static var _content: Object;
    //private static const URL: String = "wonderflScore.swf";
    private static const URL: String = "http://swf.wonderfl.net/swf/usercode/5/57/579a/579a46e1306b5770d429a3738349291f05fec4f3.swf";
    private static const TWEET: String = "Playing What the Hex [score: %SCORE%] #wonderfl";
    
    public static function init(top: DisplayObjectContainer, api: WonderflAPI, handler: Function): void 
    {
        _top = top, _api = api;
        var loader: Loader = new Loader();
        var comp: Function = function(e: Event): void
        {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, comp);
            _content = loader.content;
            handler();
        }
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, comp);
        loader.load(new URLRequest(URL), new LoaderContext(true));
    }
    
    /**
     * Wonderfl の Score API 用
     * ランキング表示から Tweet までをひとまとめにしたSWF素材を使う
     * @param    score            : 取得スコア
     * @param    closeHandler    : Window が閉じるイベントハンドら
     */
    public static function show( score: int, closeHandler: Function): void
    {
        var window: DisplayObject = _content.makeScoreWindow(_api, score, "What the Hex", 1, TWEET);
        var close: Function = function(e: Event): void
        {
            window.removeEventListener(Event.CLOSE, close);
            closeHandler();
        }
        window.addEventListener(Event.CLOSE, close);
        _top.addChild(window);
    }
    
}