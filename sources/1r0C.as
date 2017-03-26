/*
アルゴリズムの概要


評価方法

12個の要素をつかって盤面に評価値をつけてます。
[相手に取られない駒の数, 打てる手の数, 位置0にあるの駒の数, 1にある駒の数, …, 9にある駒の数 ]

盤面と位置の番号の対応表
0,4,5,6,6,5,4,0
4,1,7,8,8,7,1,4
5,7,2,9,9,2,7,5
6,8,9,3,3,9,8,6
6,8,9,3,3,9,8,6
5,7,2,9,9,2,7,5
4,1,7,8,8,7,1,4
0,4,5,6,6,5,4,0



遺伝的アルゴリズム

(1), 評価する要素のウェイトが異なるAIを30こ作る。
(2), AIどうしを対戦させて、負けたAIは破棄する。
(3), 残ったAIと似たAIを作って、AIを30こに戻す。
(4). 2,3を繰り返す。

学習システムはこれだけです。



先読みのアルゴリズム(モンテカルロ法)
人間との対戦の時には、AIにモンテカルロ法を使わせて手を読んでます。

(1), 1手だけ読んで評価値の高いものをいくつか取り出す。
(2), その手について、ランダム要素を持ったAIで7手先まで対戦シュミレートする。
(3), (2)を手一つについて25回繰り返す。
(4), シュミレーションで最も成績が良かった手を打つ。



*/
package {
    import flash.display.Sprite;
    import flash.display.Graphics;
    import flash.events.Event;
    import flash.filters.DropShadowFilter;
    import flash.utils.getTimer;
    import flash.geom.Matrix;
    import com.bit101.components.InputText;
    import com.bit101.components.Label;
    import com.bit101.components.PushButton;
    import com.bit101.components.RadioButton;
    import com.bit101.components.Style;
    
    [SWF(width="465", height="465", frameRate="60")]
    public class Main extends Sprite {
        public var reversi:Reversi = new Reversi();
        public var viewer:ReversiViewer = new ReversiViewer( reversi );
        public var pool:GenePool = new GenePool( reversi );
        public var input:InputText;
        public var list:List;
        public var message:Label;
        
        public var evolution:PushButton;
        public var blackRadio:RadioButton;
        public var whiteRadio:RadioButton;
        public var startBtn:PushButton;
        public var player:ReversiPlayer;
        
        public var evReversi:Reversi = new Reversi();
        public var gene1:Gene;
        public var gene2:Gene;
        public var evViewer:MiniViewer = new MiniViewer( evReversi );
        public var window:BattleWindow = new BattleWindow( viewer );
        
        private var count:int = 0;
        function Main() {
            //背景
            var g:Graphics = graphics;
            g.beginGradientFill("linear",[5,1578539,4209266,2170428],[1,1,1,1],[2,60,187,255],new Matrix(0.0000,0.2838,-0.2838,0.0000,232.5400,232.5400),"pad","rgb",0.6900000000000001);
            g.drawRect( 0, 0, 465, 465 )
            
            //スタイル
            Style.LABEL_TEXT = 0xAAAAAA;
            Style.BUTTON_FACE = 0xF33300;
            
            //タイトル
            var title:Label = new Label( this, 10, 0, "REVERSI EVOLUTION" );
            title.scaleX = title.scaleY = 2;
            
            new Label( this, 10, 40, "AI POOL" );
            list = new List( this, 10, 155, pool.genes );
            list.setSize( 100, 155 );
            evViewer.x = 10; evViewer.y = 55;
            addChild( evViewer );
            evolution = new PushButton( this, 10, 315, "EVOLUTION", onPush );
            
            new Label( this, 10, 335, "code" );
            input = new InputText( this, 10, 350 );
            input.setSize( 100, 20 );
            
            list.addEventListener( "select", onSelect );
            list.selectedIndex = 0;
            
            
            blackRadio = new RadioButton( this, 10, 400, "black", true  );
            whiteRadio = new RadioButton( this, 60, 400, "white", false );
            startBtn = new PushButton( this, 5, 420, "START", onPush );
            startBtn.setSize( 55, 20 );
            startBtn.scaleX = startBtn.scaleY = 2;
            
            viewer.y = 50;
            viewer.x = 455 - viewer.width;
            addChild( viewer );
            
            window.x = 127; window.y = 385;
            addChild( window );
            
            
            Style.LABEL_TEXT = 0xFF8800;
            message = new Label( this, 130, 330 );
            message.filters = [ new DropShadowFilter() ]
            message.scaleX = message.scaleY = 3;
            
            reset();
            evReversi.onGameOver = evNext;
            evNext();
            
            message.text = "SELECT AI"
        }
        
        private function onPush( e:Event ):void {
            switch( e.target.label ) {
                case "EVOLUTION": startEvolute(); break;
                case "STOP": stopEvolute(); break;
                case "START": start(); break;
                case "GIVE UP": reset(); break;
            }
        }
        private function onSelect( e:Event ):void {
            var index:int = list.selectedIndex;
            var l:int = pool.genes.length;
            if( index < l ){ input.text = "" + pool.genes[ list.selectedIndex ].getCode(); }
        }
        private function start():void {
            count = 0;
            addEventListener( "enterFrame", game );
            
            message.text = "";
            stopEvolute();
            evolution.enabled = false;
            list.enabled = false;
            blackRadio.enabled = false;
            whiteRadio.enabled = false;
            startBtn.label = "GIVE UP";
            
            var arr:Array = input.text.split(",");
            var l:int = reversi.getMaxWeight().length
            if ( arr.length != l ) {
                reset();
                message.text = "ERROR";
            }else{
                var turn:int = blackRadio.selected ? 1 : 2;
                reversi.players[ turn ] = player = new ReversiPlayer( reversi, viewer );
                reversi.players[ 3 - turn ] = new MonteAI( arr );
                window.label[ turn ].text = "YOU";
                window.label[ 3 - turn ].text = "CPU";
                reversi.init();
                reversi.onGameOver = reset;
            }
        }
        
        private function reset():void {
            viewer.draw( null );
            if( reversi.winner == 0 ){ "DRAW" }
            else if( reversi.players[ reversi.winner ] == player ){ message.text = "YOU WIN" }
            else{ message.text = "YOU LOSE" }
            evolution.enabled = true;
            list.enabled = true;
            blackRadio.enabled = true;
            whiteRadio.enabled = true;
            startBtn.label = "START";
            removeEventListener( "enterFrame", game ); 
        }
        
        private function game( e:Event ):void {
            if ( count != 0 ) { reversi.progress(); }
            else{ count++ }
        }
        
        private function stopEvolute():void { 
            if( evolution.label == "STOP" ){
                removeEventListener( "enterFrame", evolute ); 
                evolution.label = "EVOLUTION";
            }
        }
        private function startEvolute():void {
            if( evolution.label == "EVOLUTION" ){
                addEventListener( "enterFrame", evolute );
                evolution.label = "STOP";
            }
        }
        private function evolute( e:Event ):void { 
            var time:int = getTimer();
            do { evReversi.progress(); } while ( 60 > getTimer() - time )
            list.items = pool.genes;
        }
        private function evNext():void {
            if ( gene1 ) { gene1.point = evReversi.black; if(evReversi.winner==Reversi.BLACK){gene1.win++} }
            if ( gene2 ) { gene2.point = evReversi.white; if(evReversi.winner==Reversi.WHITE){gene2.win++} }
            list.selectedIndex = pool.index;
            
            gene1 = pool.getGene();
            pool.next();
            gene2 = pool.getGene();
            pool.next();
            evReversi.init();
            evReversi.players[1] = new NormalAI( gene1.code, 0 );
            evReversi.players[2] = new NormalAI( gene2.code, 0 );
        }
    }
}
import flash.display.*;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.geom.Rectangle;
import flash.utils.getTimer;
import com.bit101.components.Label;
import com.bit101.components.PushButton;

class ReversiViewer extends Sprite{
    static public const CELL:int = 41;
    static public const THICKNESS:int = 3;
    static public const BACKGROUND:uint = 0x006600;
    public var reversi:Reversi;    
    private var shapeMap:Vector.<Vector.<Shape>> = new Vector.<Vector.<Shape>>;
    private var map:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>;
    private var effect:Array = []
    private var turn:uint = 0;
    
    public function ReversiViewer( reversi:Reversi ){
        this.reversi = reversi;
        drawGrid();
        
        map = new Vector.<Vector.<uint>>;
        shapeMap = new Vector.<Vector.<Shape>>;
        for ( var i:uint = 0; i < Reversi.W; i++ ) {
            map[i] = new Vector.<uint>
            shapeMap[i] = new Vector.<Shape>
            for ( var j:uint = 0; j < Reversi.H; j++ ) {
                map[i][j] = 0;
                shapeMap[i][j] = null;
            }
        }
        
        this.addEventListener( "exitFrame",draw )
    }
    
    public function draw(e:Event):void {
        var change:Boolean = false;
        if( turn != reversi.turn ){ turn = reversi.turn; change = true; }
        for ( var i:uint = 0; i < Reversi.W; i++ ) {
            for ( var j:uint = 0; j < Reversi.H; j++ ) {
                if ( reversi.map[i][j] != map[i][j] ) {
                    change = true;
                    var m:int = map[i][j]
                    var s:Shape;
                    if ( m != 0 ) {
                        s = shapeMap[i][j]
                        removeChild( s );
                        shapeMap[i][j] = null
                    }
                    m = map[i][j] = reversi.map[i][j];
                    if ( m != 0 ) {
                        s = new Circle(m)
                        s.x = i * CELL;
                        s.y = j * CELL;
                        addChild( s );
                        shapeMap[i][j] = s;
                    }
                }
            }
        }
        if ( change ) { dispatchEvent( new Event( "change" ) ); }
    }
    
    private function drawGrid():void {
        var g:Graphics = this.graphics;
        g.beginFill( BACKGROUND, 1 );
        g.drawRect( 0, 0, Reversi.W * CELL, Reversi.H * CELL );
        g.lineStyle(THICKNESS, 0, 1);
        for ( var i:uint = 0; i < Reversi.W + 1; i++ ) {
            g.moveTo( i * CELL, 0 );
            g.lineTo( i * CELL, Reversi.H * CELL );    
        }
        for ( var j:uint = 0; j < Reversi.H + 1; j++ ) {
            g.moveTo( 0, j * CELL );
            g.lineTo( Reversi.W * CELL, j * CELL );    
        }
    }
}
class BattleWindow extends Sprite {
    public var counter1:Counter = new Counter( 0x000000 );
    public var counter2:Counter = new Counter( 0xFFFFFF );
    public var frame:Shape = new Shape();
    public var count1:int = 0;
    public var count2:int = 0;
    public var label:Array = [];
    public var viewer:ReversiViewer;
    function BattleWindow( viewer:ReversiViewer ):void {
        label[1] = new Label( this, 45, 22, "---" );
        label[2] = new Label( this, 255, 22, "---" );
        
        addChild( counter1 );
        counter1.x = 0; counter1.y = 50;
        addChild( counter2 );
        counter2.x = 320; counter2.y = 50;
        counter2.scaleX = -1;
        this.viewer = viewer;
        viewer.addEventListener( "change", onChange );
        
        var g:Graphics = graphics;
        g.lineStyle( 3, 0x000000 );
        g.beginFill( 0x006600 );
        g.drawRect( 0, 0, 40, 40 );
        g.drawRect( 280, 0, 40, 40 );
        g.beginFill( 0x000000 );
        g.drawCircle( 20, 20, 16 );
        g.beginFill( 0xFFFFFF );
        g.drawCircle( 300, 20, 16 );
        
        g.lineStyle( 0.5, 0x880000, 1 );
        g.moveTo( 32 * 5, 45 );
        g.lineTo( 32 * 5, 75 );
        
        addChild( frame )
        g = frame.graphics;
        g.lineStyle( 3, 0x880000 );
        g.drawRect( -1, -1, 42, 42 );
    }
    private function onChange( e:Event ):void {
        counter1.setCount( viewer.reversi.black );
        counter2.setCount( viewer.reversi.white );
        frame.x = viewer.reversi.turn == 2 ? 280 : 0; 
    }
}
class Counter extends Shape {
    public var color:uint;
    function Counter( color:uint ):void { this.color = color; }
    public function setCount( count:int ):void {
        var g:Graphics = graphics;
        g.clear();
        g.lineStyle( 3, color );
        for( var i:int = 0; i < count; i++ ) {
            g.moveTo( i * 5, 0 );
            g.lineTo( i * 5, 20 );
        }
    }
}
class Circle extends Shape{
    function Circle( turn:int ) {
        var g:Graphics = this.graphics;
        var color:uint = turn == 1 ? 0x000000 : 0xFFFFFF;
        g.lineStyle( ReversiViewer.THICKNESS, 0, 1);
        g.beginFill( color, 1 );
        g.drawCircle( ReversiViewer.CELL / 2, ReversiViewer.CELL / 2, ReversiViewer.CELL/2 - ReversiViewer.THICKNESS );
    }
}
class MiniViewer extends Bitmap {
    private var reversi:Reversi;
    private var map:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
    public static const CELL:int = 12;
    public static const THICKNESS:int = 1;
    public static const COLOR:Array = [0x006600, 0x000000, 0xFFFFFF];
    function MiniViewer( reversi:Reversi ):void {
        super( new BitmapData( CELL * Reversi.W + THICKNESS, CELL * Reversi.H + THICKNESS, false, 0x006600 ) );
        drawGrid()
        this.reversi = reversi;
        for ( var i:int = 0; i < Reversi.W; i++ ) {
            map[i] = new Vector.<int>;
            for ( var j:int = 0; j < Reversi.H; j++ ) {
                map[i][j] = 0;
            }
        }
        addEventListener( "exitFrame", onFrame )
    }
    private function drawGrid():void {
        var b:BitmapData = bitmapData;
        for ( var i:uint = 0; i < Reversi.W + 1; i++ ) { b.fillRect( new Rectangle( i * CELL, 0, THICKNESS, b.height ), 0 ); }
        for ( var j:uint = 0; j < Reversi.H + 1; j++ ) { b.fillRect( new Rectangle( 0, j * CELL, b.width,  THICKNESS ), 0 ); }
    }
    private function onFrame( e:Event ):void {
        if( reversi && visible ){
            var b:BitmapData = bitmapData;
            for ( var i:int = 0; i < Reversi.W; i++ ) {
                for ( var j:int = 0; j < Reversi.H; j++ ) {
                    if ( map[i][j] != reversi.map[i][j] ) { 
                        map[i][j] = reversi.map[i][j]; 
                        b.fillRect( new Rectangle( i * CELL + THICKNESS + 1 , j * CELL + THICKNESS + 1, CELL - THICKNESS - 2, CELL - THICKNESS - 2 ), COLOR[map[i][j]] )
                    }
                }
            }
        }
    }
}
class Reversi implements Game{        
    static public var BLACK:int = 1;
    static public var WHITE:int = 2;
    static public var W:int = 8;
    static public var H:int = 8;
    public var turn:int = 1;
    public var map:Vector.<Vector.<uint>>;
    public var gameOvered:Boolean = false;
    public var passed:Boolean = false;
    public var players:Array = [null,null,null];
    public var white:uint = 2;
    public var black:uint = 2;
    public var onGameOver:Function;
    public var winner:int = -1;
    function Reversi( initialize:Boolean = true ){ if(initialize){ init() } }
    public function init():void {
        white = 2; black = 2; turn = 1; gameOvered = false; passed = false; winner = -1;
        map = new Vector.<Vector.<uint>>(W);
        for ( var i:uint = 0; i < W; i++ ) {
            map[i] = new Vector.<uint>(H)
            for ( var j:uint = 0; j < H; j++ ) { map[i][j] = 0; }
        }
        var cx:int = W / 2; var cy:int = H / 2; map[cx-1][cy-1] = 2; map[cx-1][cy] = 1; map[cx][cy-1] = 1; map[cx][cy] = 2; 
    }
    public function progress():void{
        if (! gameOvered ) {
            var p:Player = players[turn];
            if ( p ){ p.action( this ) }
        }
    }
    
    //評価用の関数1　確定済みの駒の数を数える-------------------------------------------------------------------
    public function fixedNum( turn:uint ):int {
        var c:uint = 0;
        var en:uint = 3 - turn; 
        for ( var i:uint = 0; i < W; i++ ) {
            for ( var j:uint = 0; j < H; j++ ) {
                if( isFixed(i, j, turn) ) { c++ }
                else if( isFixed(i, j, en) ) { c-- }
            }
        }
        return c;
    }
    private function isFixed( tx:uint, ty:uint, turn:uint ):Boolean { 
        var map:Vector.<Vector.<uint>> = this.map; 
        if ( map[tx][ty] != turn ) { return false }
        var en:int = 3 - turn;    
        for ( var i:int = -1, j:int = -1; i < 0 || j < 0; i++) {
            if ( i > 1 ) { i = -1; j++; }
            var x:uint = tx, y:uint = ty, vx:int = i, vy:int = j, f1:Boolean = false, f2:Boolean = false;
            
            do{
                x += vx; y += vy;
                if ( x >= W || y >= H ) {
                    break;
                }else{
                    var m:uint = map[x][y];
                    if ( m == 0 ) { f1 = true; break; }
                    if ( m == en ) { f2 = true; }
                }
            }while(true)
            
            if( f1 || f2 ){
                x = tx; y = ty;
                vx = -vx; vy = -vy;
                
                while(true){
                    x += vx; y += vy;
                    if( x < 0 || x >= W || y < 0 || y >= H ){
                        break;
                    }else{
                        m = map[x][y];
                        if ( m == 0 ) { if (f1 || f2) { return false } }
                        if ( m == en ) { if ( f1 ) { return false; } }
                    }
                }
            }
        }
        return true;
    }
    //----------------------------------------------------------------------------------------
    
    
    
    //評価用関数2 着手可能な手の数を数える。----------------------------------------------------------
    public function enableNum( turn:uint ):int{
        var c:uint = 0;
        var en:uint = 3 - turn;
        for ( var i:uint = 0; i < W; i++ ) {
            for ( var j:uint = 0; j < H; j++ ) {
                if( isEnable(i, j, turn)  ) { c++ }
                if( isEnable(i, j, en)  ) { c-- }
            }
        }
        return c;
    }
    private function isEnable( tx:uint, ty:uint, turn:uint ):Boolean { 
        var map:Vector.<Vector.<uint>> = this.map; 
        if ( map[tx][ty] != 0 ){ return false; }
        for ( var vx:int = -1; vx < 2; vx++ ) {
            for ( var vy:int = -1; vy < 2; vy++ ) {
                if( vx != 0 || vy != 0 ){
                    var x:uint = tx, y:uint = ty, f1:Boolean = false, f2:Boolean = false;
                    do{
                        x += vx; y += vy;
                        if ( x >= W || y >= H ) {
                            break;
                        }else {
                            var m:uint = map[x][y];
                            if (! f1 ) {
                                if( m == 0 || turn == m  ){ break; }
                                f1 = true;
                            }else {
                                if( m == 0 ){ break; }
                                else if( turn == m ){ f2 = true; break; }
                            }
                        }
                    }while(true)
                    if ( f2 ) { return true; }
                }
            }
        }
        return false;
    }
    //-------------------------------------------------------------------------------------
    
    
    
    //評価用関数3　各位置(10通り)にある駒の数を数える------------------------------------------------
    private function positionNums( turn:uint ):Array {
        var arr:Array = [];
        var en:uint = 3 - turn;
        for ( var i:uint = 0; i < 10; i++ ) {
            var line:Array = POSITION[i];
            var l:uint = line.length;
            arr[i] = 0
            for ( var j:uint = 0; j < l; j++ ){
                var p:Array = line[j];
                var m:int = map[ p[0] ][ p[1] ];
                if ( turn == m ) { arr[i]++; }
                else if ( turn == en ) { arr[i]--; }
            }
        }
        return arr;
    }
    private const POSITION:Array = [
        [ [0, 0], [7, 0], [0, 7], [7, 7] ],
        [ [1, 1], [6, 1], [1, 6], [6, 6] ],
        [ [2, 2], [5, 2], [2, 5], [5, 5] ],
        [ [4, 4], [4, 3], [3, 4], [4, 4] ], 
        [ [0, 1], [1, 0], [7, 1], [1, 7], [0, 6], [6, 0], [6, 7], [7, 6] ],
        [ [0, 2], [2, 0], [7, 2], [2, 7], [0, 5], [5, 0], [5, 7], [7, 5] ],
        [ [0, 3], [3, 0], [7, 3], [3, 7], [0, 4], [4, 0], [4, 7], [7, 4] ],
        [ [1, 2], [2, 1], [6, 2], [2, 6], [1, 5], [5, 1], [5, 6], [6, 5] ],
        [ [1, 3], [3, 1], [6, 3], [3, 6], [1, 4], [4, 1], [4, 6], [6, 4] ],
        [ [2, 3], [3, 2], [5, 3], [3, 5], [2, 4], [4, 2], [4, 5], [5, 4] ]
    ];
    //----------------------------------------------------------------------------------------
    
    
    public function clone():Game {
        var cl:Reversi = new Reversi( false );
        if( map ){
            var cmap:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(W);
            for ( var i:uint = 0; i < W; i++ ) {
                var line:Vector.<uint> = new Vector.<uint>(H);
                for ( var j:uint = 0; j < H; j++ ) {
                    line[j] = map[i][j];
                }
                cmap[i] = line
            }
            cl.map = cmap;
        }
        cl.turn = turn;
        for( var str:String in players ){
            cl.players[str] = players[str];
        }
        return cl;
    }
    
    
    //着手---------------------------------------------------------------------------------------
    //(x,y,パス)
    public function action( ...arg ):void {
        if ( arg[2] ) { pass(); return }
        else{ passed = false; }
        var x:int = arg[0]; var y:int = arg[1];
        select(x, y);
    }
    private function select( tx:uint, ty:uint ):void {
        if ( map[tx][ty] != 0 ){ return; }
        var f:Boolean = false;
        for ( var vx:int = -1; vx < 2; vx++ ) {
            for ( var vy:int = -1; vy < 2; vy++ ) {
                if( vx != 0 || vy != 0 ){
                    var x:uint = tx, y:uint = ty, f1:Boolean = false, f2:Boolean = false, count:int = 0;
                    do{
                        x += vx; y += vy;
                        if ( x >= W || y >= H ) {
                            break;
                        }else {
                            var m:uint = map[x][y];
                            if (! f1 ) {
                                if ( turn == m || m == 0 ) { break; }
                                else { f1 = true; } 
                            }else {
                                if ( m == 0 ) { break; }
                                if ( turn == m ) { f2 = true; break; }
                            }
                        }
                        count++;
                    }while(true)
                    
                    if ( f2 ){
                        x = tx; y = ty;
                        for ( var j:uint = 0; j < count; j++ ) {
                            x += vx; y += vy;
                            map[x][y] = turn;
                        }
                        f = true;
                    }
                }
            }
        }
        if ( f ) { map[tx][ty] = turn; setCount(); passed = false; turn = 3 - turn; }
    }
    private function pass():void {            
        if ( passed == true ){ gameOver(); return; }
        passed = true;
        turn = 3 - turn;
    }
    //----------------------------------------------------------------------------------------------
    
    
    //着手可能な手を返す--------------------------------------------------------------------------
    public function getAction():Array {
        if( gameOvered ){ return [] }
        var arr:Array = [];
        for ( var i:uint = 0; i < W; i++ ) {
            for ( var j:uint = 0; j < H; j++ ) {
                if( isEnable(i,j,turn)  ){ arr.push( [i,j] ) }
            }
        }
        if ( arr.length == 0 ){ arr.push( [0, 0, true] ); }
        return arr;
    }
    public function passable():Boolean {
        for ( var i:int = 0; i < W; i++ ) {
            for ( var j:int = 0; j < H; j++ ) {
                if ( isEnable( i, j, turn ) ) { return false; }
            }
        }
        return true;
    }
    //-----------------------------------------------------------------------------------------
    
    
    //評価用の配列に従って評価値を返す
    public function getValue( player:Player, weight:Array ):Number {
        var turn:int = players.indexOf( player );
        var arr:Array = [];
        arr.push( fixedNum( turn ) );
        arr.push( enableNum( turn ) );
        arr.push.apply( null, positionNums( turn ) );
        var l:uint = arr.length
        var p:Number = 0;
        for ( var i:uint = 0; i < l; i++ ) { p += weight[i] * arr[i] }
        if( turn == winner ){ p += 100 }
        return p;
    }
    
    private function gameOver():void {
        gameOvered = true;    
        setCount();
        if ( black == white ) { winner = 0; }
        else if ( black > white ){ winner = BLACK }
        else if ( black < white ){ winner = WHITE }
        if ( onGameOver != null ) { onGameOver(); }
    }
    private function setCount():void {
        black = 0; white = 0;
        for ( var i:int = 0; i < W; i++ ) {
            for ( var j:int = 0; j < H; j++ ) {
                if ( map[i][j] == BLACK ){ black++; }
                if ( map[i][j] == WHITE ){ white++; }
            }
        }
    }
    public function getMaxWeight():Array { return [ 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100] }
    public function getMinWeight():Array { return [-100,-100,-100,-100,-100,-100,-100,-100,-100,-100,-100,-100]}
    public function getPoint( player:Player ):Number { 
        var p:int = players.indexOf( player )
        if( p == winner ){ return p == 1 ? (64 - white) : (64 - black); }
        return p == 1 ? white : black;
    }
    public function setCurrentPlayer( player:Player ):void { players[turn] = player; }
    public function getCurrentPlayer():Player { return players[turn]; }
}
interface Game{
    function clone():Game;
    function action( ...arg ):void;
    function getAction():Array;
    function getValue( player:Player, weight:Array ):Number;
    function getPoint( player:Player ):Number;
    function getMaxWeight():Array;
    function getMinWeight():Array;
    function setCurrentPlayer( player:Player ):void
}
class GenePool {
    public const SIZE:int = 30;
    public const VARIATION:int = 30;
    public var game:Game;
    public var genes:Array = [];
    public var generation:int = 0;
    public var index:int = 0;
    public var num:int = 0;
    private var maxWeight:Array;
    private var minWeight:Array;
    private var weightLength:int;
    
    public function GenePool( game:Game ){
        this.game = game;
        maxWeight = game.getMaxWeight(); minWeight = game.getMinWeight();
        weightLength = maxWeight.length;
        
        for ( var i:uint = 0; i < SIZE;  i++ ) {
            var weight:Array = [];
            for ( var j:uint = 0; j < weightLength; j++ ) {
                var max:Number = maxWeight[j], min:Number = minWeight[j];
                weight[j] = min + ( max - min ) * Math.random();
            }
            
            var gene:Gene = new Gene();
            gene.code = weight;
            gene.num = ++num;
            genes.push( gene );
        }
    }
    public function getGene():Gene { return genes[index]; }
    public function next():void { index++; if ( index == SIZE ) { _nextGeneration(); index = 0; } }
    private function _nextGeneration():void{ 
        if ( (!genes) || genes.length == 0 ) { return }
        generation++;
        genes.sort( function _( x:Gene, y:Gene ):Number { return (y.point - x.point); } )
        genes.splice( SIZE / 2, SIZE / 2 );
        var max:Number = genes[0].point;
        while( genes.length < SIZE ){
            var codes:Array = [];
            for ( var i:uint = 0; i < 2; i++  ) {
                do{
                    var rand:int = ( genes.length * Math.random() )>>> 0; 
                    codes[i] = genes[ rand ].code;
                }while( codes[i].point < max * Math.random() )
            }
            var code:Array = [];
            var l:int = codes[0].length;
            for ( var n:uint = 0; n < l; n++ ) {
                var r:Number = Math.random();
                code[n] = codes[ (2*Math.random())>>>0 ][ n ] + (VARIATION * r*r*r*r) * (1 - 2 * Math.random());
            }
            var gene:Gene = new Gene;
            gene.code = code;
            gene.num = ++num;
            genes.push( gene )
        }
        shuffle();
    }
    public function shuffle():void {
        var a:Array = []
        for ( var i:uint = 0; i < SIZE;  i++ ) { genes[i].rand = Math.random(); }
        genes.sortOn( "rand" );

        }
    public function getArray():Array {
        var arr:Array = []
        for ( var i:uint = 0; i < SIZE;  i++ ) { arr[i] = genes[i].toString(); }
        return arr;
    }
}
class Gene {
    public var point:Number = -Infinity;
    public var code:Array;
    public var rand:Number;
    public var num:int = 0;
    public var win:int = 0;
    public function toString():String {
        return "No." +  num + ": " + (point!=-Infinity ?point.toString():"--")+"pt "+ win + "win";
    }
    public function getCode():String {
        var l:int = code.length;
        var abs:Number = Math.abs( code[0] )
        var str:String = "" + (code[0] / abs).toFixed(4);
        for ( var i:int = 1; i < l; i++ ) {
            str +="," + ( code[i] / abs ).toFixed(4);
        }
        return str
    }
}
class Player{
    public function action( game:Game ):void{}
    public function init():void{}
    public function getPoint(target:*):Object { return null; }
}
class ReversiPlayer extends Player {        
    private var arg:Array;
    private var viewer:ReversiViewer;
    private var game:Reversi;
    private var running:Boolean = false;
    
    function ReversiPlayer( game:Reversi, viewer:ReversiViewer ):void {
        this.viewer = viewer;
        this.game = game;
        viewer.stage.addEventListener( "mouseDown", onDown );
    }
    
    override public function init():void {
        arg = null;
    }
    
    override public function action( game:Game ):void {
        if( running ){
            if ( arg ) { 
                game.action.apply( null, arg )
                arg = null;
                running = false;
            }
        }else {
            running = true;
            var act:Array = game.getAction()
            if ( act.length == 1 && act[0][2] == true ) { pass(); }
        }
    }
    public function pass():void {
        if( running ){ arg = [0, 0, true]; }
    }
    private function onDown(e:MouseEvent):void {
        if( running ){
            var x:int = viewer.mouseX / ReversiViewer.CELL;
            var y:int = viewer.mouseY / ReversiViewer.CELL;
            if ( x >= 0 && x < Reversi.W && y >= 0 && y < Reversi.H ) {
                arg = [x, y];
            }
        }
    }    
}
class NormalAI extends Player{
    public var tolerance:int = 0;
    public var weight:Array;    
    public function NormalAI( weight:Array, tolerance:int = 0 ) {
        this.tolerance = tolerance;
        this.weight = weight;
    }
    override public function action( game:Game ):void{
        var act:Array = game.getAction();
        var act2:Array = [];
        var act3:Array = [];
        var arg:Array = weight;
        var l2:int = 0;
        var l3:int = 0;
        
        var points:Vector.<Number> = new Vector.<Number>();
        var l:uint = act.length;
        var max:Number = -Infinity;
        
        for( var i:uint = 0; i<l; i++ ){
            var clone:Game = game.clone();
            clone.action.apply( null,act[i] )
            var p:int = clone.getValue( this, arg );
            if( p >= max ){ max = p; points.push( p ); act2.push( act[i] ); l2++; }
        }
        
        for( var j:uint = 0; j<l2; j++ ){
            if( points[j]+tolerance >= max ){
                act3.push( act2[j] ); l3++;
            }
        }
        game.action.apply( null, act3[ (l3 * Math.random()) >>> 0 ] );
        
    }
}

class MonteAI extends Player {
    public var depth:int; //読みの深さ
    public var tolerance:Number; //寛容さ
    public var repeat:int; //シュミレーションの回数
    public var weight:Array;
    public var vartialPlayers:Array;
    
    function MonteAI( weight:Array, tolerance:Number = 2, depth:Number = 9, repeat:Number = 50 ) {
        this.vartialPlayers = [ new NormalAI( weight, 3 ), new NormalAI( weight, 2 ) ];
        this.weight = weight;
        this.tolerance = tolerance;
        this.depth = depth;
        this.repeat = repeat;
    }
    
    override public function action( game:Game ):void{
        var act:Vector.<Array> = Vector.<Array>( game.getAction() );
        
        var points:Vector.<Number> = new Vector.<Number>;
        var clones:Vector.<Game> = new Vector.<Game>;     
        var l:uint = act.length;
        var max:Number = -Infinity;
        var arg:Array = weight;    
        
        //1手読む
        function _1():void{
            var g:Game;
            var player:Player = vartialPlayers[0];
            for ( var i:uint = 0; i < l; i++ ) {
                g = game.clone();
                g.setCurrentPlayer( player );
                g.action.apply( null, act[i] );
                var p:Number = g.getValue( player, arg );        
                
                if ( p > max ) { max = p }
                
                points.push( p );
                clones.push( g );
            }
        }
        
        //点の高いものを選び出す。
        function _2():void{   
            var act2:Vector.<Array> = new Vector.<Array>;
            var points2:Vector.<Number> = new Vector.<Number>;
            var clones2:Vector.<Game> = new Vector.<Game>;  
            var l2:int = 0;
            
            for( var i:uint = 0; i<l; i++ ){
                var pt:Number = points[i];
                if( pt + tolerance >= max ){
                    points2.push( pt );
                    clones2.push( clones[i] );
                    act2.push( act[i] );
                    l2++;
                }
            }
            act=act2; points=points2; clones=clones2;
            l = l2;
        }
        
        //各手を深読み
        function _3():void {
            var g:Game;
            for( var i:uint = 0; i < l; i++ ){
                for( var j:uint = 0; j < repeat; j++ ){
                    g = clones[i].clone();
                    var index:int = 0;
                    for( var k:uint = 0; k<depth; k++ ){
                        index++;
                        if ( index == vartialPlayers.length ) { index = 0 }
                        var player:Player = vartialPlayers[index];
                        g.setCurrentPlayer( player );
                        player.action( g );
                        var p:Number = g.getValue( vartialPlayers[0], arg ); 
                    }
                    points[i] += g.getValue( vartialPlayers[0], arg ); 
                }
            }
        }
        
        //もっとも点の高い手を実行する。
        function _4():void {
            max = -Infinity;
            
            for( var i:uint = 0; i<l; i++ ){
                var p:Number = points[i];
                if( p > max ){ max = p }
                points.push( p )
            }
            
            for( var j:uint = 0; j < l; j++ ){
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

/**
 * Style.as
 * Keith Peters
 * version 0.9.10
 * 
 * A collection of style variables used by the components.
 * If you want to customize the colors of your components, change these values BEFORE instantiating any components.
 * 
 * Copyright (c) 2011 Keith Peters
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
 
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
        import com.bit101.components.*;
	class Style
	{
		public static var TEXT_BACKGROUND:uint = 0xFFFFFF;
		public static var BACKGROUND:uint = 0xCCCCCC;
		public static var BUTTON_FACE:uint = 0xFFFFFF;
		public static var BUTTON_DOWN:uint = 0xEEEEEE;
		public static var INPUT_TEXT:uint = 0x333333;
		public static var LABEL_TEXT:uint = 0x666666;
		public static var DROPSHADOW:uint = 0x000000;
		public static var PANEL:uint = 0xF3F3F3;
		public static var PROGRESS_BAR:uint = 0xFFFFFF;
		public static var LIST_DEFAULT:uint = 0xFFFFFF;
		public static var LIST_ALTERNATE:uint = 0xF3F3F3;
		public static var LIST_SELECTED:uint = 0xCCCCCC;
		public static var LIST_ROLLOVER:uint = 0XDDDDDD;
		
		public static var embedFonts:Boolean = true;
		public static var fontName:String = "PF Ronda Seven";
		public static var fontSize:Number = 8;
		
		public static const DARK:String = "dark";
		public static const LIGHT:String = "light";
		
		/**
		 * Applies a preset style as a list of color values. Should be called before creating any components.
		 */
		public static function setStyle(style:String):void
		{
			switch(style)
			{
				case DARK:
					Style.BACKGROUND = 0x444444;
					Style.BUTTON_FACE = 0x666666;
					Style.BUTTON_DOWN = 0x222222;
					Style.INPUT_TEXT = 0xBBBBBB;
					Style.LABEL_TEXT = 0xCCCCCC;
					Style.PANEL = 0x666666;
					Style.PROGRESS_BAR = 0x666666;
					Style.TEXT_BACKGROUND = 0x555555;
					Style.LIST_DEFAULT = 0x444444;
					Style.LIST_ALTERNATE = 0x393939;
					Style.LIST_SELECTED = 0x666666;
					Style.LIST_ROLLOVER = 0x777777;
					break;
				case LIGHT:
				default:
					Style.BACKGROUND = 0xCCCCCC;
					Style.BUTTON_FACE = 0xFFFFFF;
					Style.BUTTON_DOWN = 0xEEEEEE;
					Style.INPUT_TEXT = 0x333333;
					Style.LABEL_TEXT = 0x666666;
					Style.PANEL = 0xF3F3F3;
					Style.PROGRESS_BAR = 0xFFFFFF;
					Style.TEXT_BACKGROUND = 0xFFFFFF;
					Style.LIST_DEFAULT = 0xFFFFFF;
					Style.LIST_ALTERNATE = 0xF3F3F3;
					Style.LIST_SELECTED = 0xCCCCCC;
					Style.LIST_ROLLOVER = 0xDDDDDD;
					break;
			}
		}
	}

/**
 * List.as
 * Keith Peters
 * version 0.9.10
 * 
 * A scrolling list of selectable items. 
 * 
 * Copyright (c) 2011 Keith Peters
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */



	[Event(name="select", type="flash.events.Event")]
	class List extends Component
	{
		protected var _items:Array;
		protected var _itemHolder:Sprite;
		protected var _panel:Panel;
		protected var _listItemHeight:Number = 20;
		protected var _listItemClass:Class =ListItem;
		protected var _scrollbar:VScrollBar;
		protected var _selectedIndex:int = -1;
		protected var _defaultColor:uint = Style.LIST_DEFAULT;
		protected var _alternateColor:uint = Style.LIST_ALTERNATE;
		protected var _selectedColor:uint = Style.LIST_SELECTED;
		protected var _rolloverColor:uint = Style.LIST_ROLLOVER;
		protected var _alternateRows:Boolean = false;
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this List.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param items An array of items to display in the list. Either strings or objects with label property.
		 */
		public function List(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, items:Array=null)
		{
			if(items != null)
			{
				_items = items;
			}
			else
			{
				_items = new Array();
			}
			super(parent, xpos, ypos);
		}
		
		/**
		 * Initilizes the component.
		 */
		protected override function init() : void
		{
			super.init();
			setSize(100, 100);
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
            addEventListener(Event.RESIZE, onResize);
            makeListItems();
            fillItems();
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		protected override function addChildren() : void
		{
			super.addChildren();
			_panel = new Panel(this, 0, 0);
			_panel.color = _defaultColor;
			_itemHolder = new Sprite();
			_panel.content.addChild(_itemHolder);
			_scrollbar = new VScrollBar(this, 0, 0, onScroll);
            _scrollbar.setSliderParams(0, 0, 0);
		}
		
		/**
		 * Creates all the list items based on data.
		 */
		protected function makeListItems():void
		{
			var item:ListItem;
			while(_itemHolder.numChildren > 0)
			{
				item = ListItem(_itemHolder.getChildAt(0));
				item.removeEventListener(MouseEvent.CLICK, onSelect);
				_itemHolder.removeChildAt(0);
			}

            var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems, _items.length);
            numItems = Math.max(numItems, 1);
			for(var i:int = 0; i < numItems; i++)
			{

				item = new _listItemClass(_itemHolder, 0, i * _listItemHeight);
				item.setSize(width, _listItemHeight);
				item.defaultColor = _defaultColor;

				item.selectedColor = _selectedColor;
				item.rolloverColor = _rolloverColor;
				item.addEventListener(MouseEvent.CLICK, onSelect);
			}
		}

        protected function fillItems():void
        {
            var offset:int = _scrollbar.value;
            var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems, _items.length);
            for(var i:int = 0; i < numItems; i++)
            {
                var item:ListItem = _itemHolder.getChildAt(i) as ListItem;
				if(offset + i < _items.length)
				{
	                item.data = _items[offset + i];
				}
				else
				{
					item.data = "";
				}
				if(_alternateRows)
				{
					item.defaultColor = ((offset + i) % 2 == 0) ? _defaultColor : _alternateColor;
				}
				else
				{
					item.defaultColor = _defaultColor;
				}
                if(offset + i == _selectedIndex)
                {
                    item.selected = true;
                }
                else
                {
                    item.selected = false;
                }
            }
        }
		
		/**
		 * If the selected item is not in view, scrolls the list to make the selected item appear in the view.
		 */
		protected function scrollToSelection():void
		{
            var numItems:int = Math.ceil(_height / _listItemHeight);
			if(_selectedIndex != -1)
			{
				if(_scrollbar.value > _selectedIndex)
				{
//                    _scrollbar.value = _selectedIndex;
				}
				else if(_scrollbar.value + numItems < _selectedIndex)
				{
                    _scrollbar.value = _selectedIndex - numItems + 1;
				}
			}
			else
			{
				_scrollbar.value = 0;
			}
            fillItems();
		}
		
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Draws the visual ui of the component.
		 */
		public override function draw() : void
		{
			super.draw();
			
			_selectedIndex = Math.min(_selectedIndex, _items.length - 1);


			// panel
			_panel.setSize(_width, _height);
			_panel.color = _defaultColor;
			_panel.draw();
			
			// scrollbar
			_scrollbar.x = _width - 10;
			var contentHeight:Number = _items.length * _listItemHeight;
			_scrollbar.setThumbPercent(_height / contentHeight); 
			var pageSize:Number = Math.floor(_height / _listItemHeight);
            _scrollbar.maximum = Math.max(0, _items.length - pageSize);
			_scrollbar.pageSize = pageSize;
			_scrollbar.height = _height;
			_scrollbar.draw();
            scrollToSelection();
		}
		
		/**
		 * Adds an item to the list.
		 * @param item The item to add. Can be a string or an object containing a string property named label.
		 */
		public function addItem(item:Object):void
		{
			_items.push(item);
			invalidate();
			makeListItems();
      fillItems();
		}
		
		/**
		 * Adds an item to the list at the specified index.
		 * @param item The item to add. Can be a string or an object containing a string property named label.
		 * @param index The index at which to add the item.
		 */
		public function addItemAt(item:Object, index:int):void
		{
			index = Math.max(0, index);
			index = Math.min(_items.length, index);
			_items.splice(index, 0, item);
			invalidate();
      makeListItems();
      fillItems();
		}
		
		/**
		 * Removes the referenced item from the list.
		 * @param item The item to remove. If a string, must match the item containing that string. If an object, must be a reference to the exact same object.
		 */
		public function removeItem(item:Object):void
		{
			var index:int = _items.indexOf(item);
			removeItemAt(index);
		}
		
		/**
		 * Removes the item from the list at the specified index
		 * @param index The index of the item to remove.
		 */
		public function removeItemAt(index:int):void
		{
			if(index < 0 || index >= _items.length) return;
			_items.splice(index, 1);
			invalidate();
      makeListItems();
      fillItems();
		}
		
		/**
		 * Removes all items from the list.
		 */
		public function removeAll():void
		{
			_items.length = 0;
			invalidate();
      makeListItems();
      fillItems();
		}
		
		
		
		
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		/**
		 * Called when a user selects an item in the list.
		 */
		protected function onSelect(event:Event):void
		{
			if(! (event.target is ListItem)) return;
			
			var offset:int = _scrollbar.value;
			
			for(var i:int = 0; i < _itemHolder.numChildren; i++)
			{
				if(_itemHolder.getChildAt(i) == event.target) _selectedIndex = i + offset;
				ListItem(_itemHolder.getChildAt(i)).selected = false;
			}
			ListItem(event.target).selected = true;
			dispatchEvent(new Event(Event.SELECT));
		}
		
		/**
		 * Called when the user scrolls the scroll bar.
		 */
		protected function onScroll(event:Event):void
		{
            fillItems();
		}
		
		/**
		 * Called when the mouse wheel is scrolled over the component.
		 */
		protected function onMouseWheel(event:MouseEvent):void
		{
			_scrollbar.value -= event.delta;
            fillItems();
		}

        protected function onResize(event:Event):void
        {
            makeListItems();
            fillItems();
        }
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////
		
		/**
		 * Sets / gets the index of the selected list item.
		 */
		public function set selectedIndex(value:int):void
		{
			if(value >= 0 && value < _items.length)
			{
				_selectedIndex = value;
//				_scrollbar.value = _selectedIndex;
			}
			else
			{
				_selectedIndex = -1;
			}
			invalidate();
			dispatchEvent(new Event(Event.SELECT));
		}
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		
		/**
		 * Sets / gets the item in the list, if it exists.
		 */
		public function set selectedItem(item:Object):void
		{
			var index:int = _items.indexOf(item);
//			if(index != -1)
//			{
				selectedIndex = index;
				invalidate();
				dispatchEvent(new Event(Event.SELECT));
//			}
		}
		public function get selectedItem():Object
		{
			if(_selectedIndex >= 0 && _selectedIndex < _items.length)
			{
				return _items[_selectedIndex];
			}
			return null;
		}

		/**
		 * Sets/gets the default background color of list items.
		 */
		public function set defaultColor(value:uint):void
		{
			_defaultColor = value;
			invalidate();
		}
		public function get defaultColor():uint
		{
			return _defaultColor;
		}

		/**
		 * Sets/gets the selected background color of list items.
		 */
		public function set selectedColor(value:uint):void
		{
			_selectedColor = value;
			invalidate();
		}
		public function get selectedColor():uint
		{
			return _selectedColor;
		}

		/**
		 * Sets/gets the rollover background color of list items.
		 */
		public function set rolloverColor(value:uint):void
		{
			_rolloverColor = value;
			invalidate();
		}
		public function get rolloverColor():uint
		{
			return _rolloverColor;
		}

		/**
		 * Sets the height of each list item.
		 */
		public function set listItemHeight(value:Number):void
		{
			_listItemHeight = value;
            makeListItems();
			invalidate();
		}
		public function get listItemHeight():Number
		{
			return _listItemHeight;
		}

		/**
		 * Sets / gets the list of items to be shown.
		 */
		public function set items(value:Array):void
		{
			_items = value;
			invalidate();
		}
		public function get items():Array
		{
			return _items;
		}

		/**
		 * Sets / gets the class used to render list items. Must extend ListItem.
		 */
		public function set listItemClass(value:Class):void
		{
			_listItemClass = value;
			makeListItems();
			invalidate();
		}
		public function get listItemClass():Class
		{
			return _listItemClass;
		}

		/**
		 * Sets / gets the color for alternate rows if alternateRows is set to true.
		 */
		public function set alternateColor(value:uint):void
		{
			_alternateColor = value;
			invalidate();
		}
		public function get alternateColor():uint
		{
			return _alternateColor;
		}
		
		/**
		 * Sets / gets whether or not every other row will be colored with the alternate color.
		 */
		public function set alternateRows(value:Boolean):void
		{
			_alternateRows = value;
			invalidate();
		}
		public function get alternateRows():Boolean
		{
			return _alternateRows;
		}

        /**
         * Sets / gets whether the scrollbar will auto hide when there is nothing to scroll.
         */
        public function set autoHideScrollBar(value:Boolean):void
        {
            _scrollbar.autoHide = value;
        }
        public function get autoHideScrollBar():Boolean
        {
            return _scrollbar.autoHide;
        }

	}