/**
 * Copyright zonnbe ( http://wonderfl.net/user/zonnbe )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/ev9L
 */

/**
 * 
 * 改造 from http://wonderfl.net/c/kwty
 * too many changes are made, i'll say it's more than fork
 * i think i should keep most of the original comments
 *
 * thanks @tail_y @http://wonderfl.net/user/tail_y
 *
 * zonnbe@2010
 */

package 
{
    /*
    PuyoDot
    プヨっとしたドット。 
    下のほうにあるパレットから拾ってきて表示するよ。
    ぐりぐりしたり、引っ張ったり、新しいドット絵を追加して遊んでね。
    (マップが意外と見ずらくなった。wonderflって等倍フォントじゃないんだね
    等倍のテキストエディタか何かで編集すると楽かも)
    
    本当はドットを編集する機能も入れたかったんだけど
    力尽きるどころの話じゃなかったから今回は諦めた。
    でもいつか作りたいね。
     */
     
     /*
    
    ドット状、任意外形の弾性体を表現します。
    こういう、ぐにぐにしたものは、各頂点をテンションで繋ぐfladdict式が一番軽くて綺麗なのですが、
    そうすると自由な形にはしにくいという欠点があります。
    今回の手法では、小さな点が、バネで繋がっているモデルをしており、一部が欠けてもそれらしい動作をします。
    バネは回転方向への力も持ち、隣の点を、距離だけではなく正常な角度に保とうとします。
    欠点として、点の数が多くなるため圧倒的に重いことと
    力の伝わり方が遅いため、伸びやすい物体になってしまうことです。
    前者はリファクタリングしていく必要があります。
    後者は、今回解決のために点を２個先まで接続する手法をとりました。
    
    
    キング・カズマのドットバージョンを入れたかったんだけど
    16x32ドットは重くなりすぎて断念。
    軽量化して、そのくらいは動くようになりたい。
    */
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.StageQuality;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.KeyboardEvent;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.system.LoaderContext;
    import flash.net.URLRequest;
    import flash.utils.*;
    import flash.ui.Keyboard;
    import frocessing.color.ColorHSV;
    import com.bit101.components.PushButton;
    import net.hires.debug.Stats;

    public class PuyoDot3 extends Sprite
    {
        public static const STAGE_W:uint = 465;
        public static const STAGE_H:uint = 465;
        
        private static const _WALL_LEFT:Number = 0;
        private static const _WALL_RIGHT:Number = 465;
        private static const _GROUND_LINE:Number = 350;

        // パーティクル
        //private var _dotMap:DotMap;
        private var _particleList:Array = [];    //:Array :Particle
        private var _particleDistance:int;
        private var _w:int;
        private var _h:int;
        
        // ドラッグ
        private var _dragIdX:int = -1;
        private var _dragIdY:int = -1;
        
        // レイヤー
        private var _bgLayer:Bitmap;
        private var _displayLayer:Bitmap;
        private var _debugLayer:Sprite;
        private var _debugDisplayList:Array = [];
        private var _dragLayer:Sprite;
        private var _dragList:Array = [];
        
        // ビットマップ
        private var _clearBitmap:BitmapData = new BitmapData(STAGE_W, STAGE_H, true, 0x00000000);
        private var _displayBitmap:BitmapData = new BitmapData(STAGE_W, STAGE_H);
        private var _bgBitmap:BitmapData = new BitmapData(STAGE_W, STAGE_H);
        private var _gradiationBitmap:BitmapData = new BitmapData(STAGE_W, STAGE_H);
        private var _reflectAlphaBitmap:BitmapData = new BitmapData(STAGE_W, STAGE_H, true, 0x00000000);
        
        private var _rect:Rectangle = new Rectangle(0, 0, STAGE_W, STAGE_H);
        private var _point:Point = new Point();
        private var _refrectPoint:Point = new Point(0, -2*_GROUND_LINE + STAGE_H);
        
        private var blobPuyos:Vector.<BlobPuyo> = new Vector.<BlobPuyo>(0, false);
        
        //plastic surgery
        public var GRAPHIC_URL:String = "http://nullurban.appspot.com/loco3.png";
        private var loader      :Loader;
        private var bmpd        :BitmapData;
        private var mouth_bmpd  :BitmapData;
        private var mouth2_bmpd :BitmapData;
        private var eyes_bmpd   :BitmapData;
        private var hair_bmpd   :BitmapData;
        
        private var blobsMouth  :Vector.<Bitmap>     = new Vector.<Bitmap>(0, false);
        private var blobsFace   :Vector.<MovieClip>     = new Vector.<MovieClip>(0, false);
        private var blobsEyes   :Vector.<MovieClip>     = new Vector.<MovieClip>(0, false);
        
        private var vcolor:ColorHSV = new ColorHSV(0,0.6,1,0.5);
        private var fps:int = 2;
        
        // improvization
        private var GMAP : GridMap = new GridMap(GB.GRID_WIDTH, GB.GRID_HEIGHT);
        private var GDebugMap:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x0);
        private var date:int = 0;
        private var showGrid:Boolean = false;
        
        public function PuyoDot3()
        {
            addEventListener(Event.ADDED_TO_STAGE, initGRAPHIC);    // flexBuilderとの互換性。
        }
        private function initGRAPHIC(e:Event):void {    // ここから開始
            removeEventListener(Event.ADDED_TO_STAGE, initGRAPHIC);
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, init);
            loader.load(new URLRequest(GRAPHIC_URL), new LoaderContext(true));
        }
        
        private function init(e:Event):void
        {
            //prepare organs
            bmpd = Bitmap(loader.content).bitmapData;
            mouth_bmpd = new BitmapData(7, 7, true, 0x0);
            mouth_bmpd.copyPixels(bmpd, new Rectangle(17,0,7,7), new Point());
            mouth2_bmpd = new BitmapData(7, 7, true, 0x0);
            mouth2_bmpd.copyPixels(bmpd, new Rectangle(24,0,3,7), new Point(3,0));
            eyes_bmpd = new BitmapData(17, 7, true, 0x0);
            eyes_bmpd.copyPixels(bmpd, new Rectangle(0,0,17,7), new Point());
            hair_bmpd = new BitmapData(25, 13, true, 0x0);
            hair_bmpd.copyPixels(bmpd, new Rectangle(0,8,25,14), new Point());
            
            // SWF設定
            stage.frameRate = 60;
////v0.2
            stage.quality = StageQuality.HIGH;  //LOW
            var bg:Sprite = new Sprite();    // wonderflではキャプチャに背景色が反映されないので、背景色Spriteで覆う。
            bg.graphics.beginFill(0xaaaaaa);
            bg.graphics.drawRect(0, 0, STAGE_W, STAGE_H);
            addChild(bg);
            
            addChild(_bgLayer = new Bitmap(_bgBitmap));
            addChild(_displayLayer = new Bitmap(_displayBitmap));
            addChild(_debugLayer = new Sprite());
            addChild(_dragLayer = new Sprite());
            //addChild(_drawShape);
            addChild(new Bitmap(GDebugMap));
            _debugLayer.visible = false;
            _bgLayer.scaleY = -1;
            _bgLayer.y = STAGE_H;

            // spawn 3 blobs
            for(var I:int = 0; I < 3; I++) addBlob(I);

            // デバッグ表示
            //debugInit();
            
            displayInit();
            
            var panel:Sprite = new Sprite();
            addChild(panel);
            new PushButton(panel, stage.stageWidth-85, 5, "add blob", addMoreBlob).setSize(80, 16);
            
            // フレームの処理を登録
            addEventListener(Event.ENTER_FRAME, frame);
            // マウスドラッグ
            //stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpEvent());
////v0.2
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onmouseDown);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onmouseMove);
            stage.addEventListener(MouseEvent.MOUSE_UP  , onmouseUp  );
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onkeyDown);
            addChild(new Stats());
        }
        
        private function onkeyDown(e:KeyboardEvent):void
        {
            switch(e.keyCode)
            {
                case Keyboard.UP:
                    if(++fps>3) fps = 1;
                        stage.frameRate = fps * 30;
                    break;
                case Keyboard.SPACE:
                    showGrid = !showGrid;
                    break;
            }
        }
        
        private function addMoreBlob(...arg):void
        {
            addBlob(blobPuyos.length);
        }
        
        private function addBlob(id:int):void
        {
            vcolor.h = Math.random()*100;
            
            var plastic_organs:Bitmap;
            blobsFace.push(new MovieClip());
            addChild(blobsFace[id]);
            
            // plastic surgery
            plastic_organs = new Bitmap(hair_bmpd.clone());
            transformColor(plastic_organs.bitmapData, vcolor.value);
            plastic_organs.x = -hair_bmpd.width/2; plastic_organs.y = -hair_bmpd.height*0.9;
            blobsFace[id].addChild(plastic_organs);
            //eye
            blobsEyes.push(new MovieClip());
            plastic_organs = new Bitmap(eyes_bmpd);
            blobsEyes[id].addChild(plastic_organs);
            plastic_organs.y = -eyes_bmpd.height/2;
            blobsEyes[id].x = -eyes_bmpd.width/2; blobsEyes[id].y = 3+eyes_bmpd.height/2;
            blobsFace[id].addChild(blobsEyes[id]);
            //mouth
            plastic_organs = new Bitmap(mouth_bmpd);
            plastic_organs.x = -mouth_bmpd.width/2; plastic_organs.y = eyes_bmpd.height+3;
            blobsFace[id].addChild(plastic_organs);
            blobsMouth.push(plastic_organs);
            /**/
            
            blobPuyos.push(new BlobPuyo(id, vcolor.value, 50+Math.random()*365, 50, 30 + Math.random()*5, GMAP));
            blobPuyos[id].blink = Math.random() * 3000;
        }
        
        private function transformColor(bmd:BitmapData, c:uint):void
        {
            var i:int = 0;
            
            var to_R:uint = (c & 0xFF0000);
            var to_G:uint = (c & 0x00FF00);
            var to_B:uint = (c & 0x0000FF);
            var paletteR:Array = [];
            var paletteG:Array = [];
            var paletteB:Array = [];
            var r:Number;
            
            for (i = 0; i < 256; i++) {
                paletteR[i] = (to_R);
                paletteG[i] = (to_G);
                paletteB[i] = (to_B);
            }
            
            bmd.paletteMap(hair_bmpd, hair_bmpd.rect, hair_bmpd.rect.topLeft, paletteR, paletteG, paletteB);
        }
        
        // フレーム挙動
        private function frame(event:Event):void{
            GDebugMap.fillRect(GDebugMap.rect, 0x0);
            
            
            var i:int = 0;
            var j:int = 0;
            var d:int = 0;
            
            
            
            
            //for (var d:int=0; d<GB._DERIVATION; d++){
            for (d=0; d<1; d++){
                //calculate diff
                for(i = 0; i<blobPuyos.length; i++)
                    blobPuyos[i].setup(date);
                
                //check contacts
                /*
                for(i = 0; i<blobPuyos.length; i++)
                    for(j = 0; j <blobPuyos.length; j++)
                        if(i != j)
                            blobPuyos[i].contact(blobPuyos[j]);
                /**/
                
                for(i = 0; i<blobPuyos.length; i++)
                    blobPuyos[i].xcontact();
                /**/
                //response
                for(i = 0; i<blobPuyos.length; i++)
                    blobPuyos[i].update();
            }
            
            if(showGrid)
            for(i = 0; i < GB.GRID_WIDTH; i++)
            {
                for(j = 0; j < GB.GRID_HEIGHT; j++)
                {
                    //if(GMAP.getXY(i,j).length>0)
                    if(GMAP.getXY(i,j).date==date)
                        GDebugMap.fillRect(new Rectangle(i*GB.DIV_WIDTH, j*GB.DIV_HEIGHT, GB.DIV_WIDTH, GB.DIV_HEIGHT), 0x55FF0000);
                }
            }
            /**/
            
            draw();    // 描画処理
            //GMAP.flush();
            date++;
        }
        
        private var _drawShape:Shape = new Shape();
        
        private function displayInit():void{
            var g:Graphics = _drawShape.graphics;
            g.clear();
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(STAGE_W, STAGE_H, Math.PI / 2, 0, 0);
            g.beginGradientFill(GradientType.LINEAR, [0xa3a3a3, 0x676767], [1, 1], [0, 255], matrix);
            g.drawRect(0, 0, STAGE_W, STAGE_H);
            _gradiationBitmap.draw(_drawShape);
            
            g.clear();
            g.beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000], [0, 0.7], [125, 230], matrix);
            g.drawRect(0, 0, STAGE_W, STAGE_H);
            _reflectAlphaBitmap.draw(_drawShape);
        }
        private function draw():void{
            var g:Graphics = _drawShape.graphics;
            var particle:Particle;
            g.clear();
            var I:int = 0;
            var J:int = 0;
            var K:int = 0;
            var BVI:Particle;
            var BPI:Point;
            for(I = 0; I < blobPuyos.length; I++)
            {
                BVI = blobPuyos[I]._VERTS[blobPuyos[I].head];
                BPI = BVI.pv;
                
                blobsFace[I].x = BVI.x;
                blobsFace[I].y = BVI.y;
                blobsFace[I].rotation = Math.atan2(BPI.y, BPI.x)/(Math.PI/180) - 90;
                if(blobPuyos[I]._DRAG_ID!=-1)
                    blobsMouth[I].bitmapData = mouth2_bmpd;
                else 
                    blobsMouth[I].bitmapData = mouth_bmpd;
                
                if(int((blobPuyos[I].blink+getTimer())%3000)<200) blobsEyes[I].scaleY = ((blobPuyos[I].blink+getTimer())%200)/200;
                /**/
                    
                g.beginFill(blobPuyos[I].color);
                g.moveTo(blobPuyos[I]._VERTS[0].mid.x, blobPuyos[I]._VERTS[0].mid.y);
                for(J = 0;J < blobPuyos[I]._VERTS.length; J++)
                {
                    K = (J+1) % blobPuyos[I]._VERTS.length;
                    g.curveTo(blobPuyos[I]._VERTS[K].x, blobPuyos[I]._VERTS[K].y, blobPuyos[I]._VERTS[K].mid.x, blobPuyos[I]._VERTS[K].mid.y);
                }
                
                
                g.endFill();
            }
            
            
            _displayBitmap.copyPixels(_clearBitmap, _rect, _point);
            _displayBitmap.draw(_drawShape);
            
            _bgBitmap.copyPixels(_gradiationBitmap, _rect, _point);
            _bgBitmap.copyPixels(_displayBitmap, _rect, _refrectPoint, _reflectAlphaBitmap, _point, true);
            /**/
        }
        
////v0.2
        private function onmouseDown(e:MouseEvent):void
        {
            var I:int = 0;
            for(I = 0; I < blobPuyos.length; I++)
            {
                blobPuyos[I].detectDrag(mouseX, mouseY);
            }
        }
        
        private function onmouseMove(e:MouseEvent):void
        {
            var I:int = 0;
            for(I = 0; I < blobPuyos.length; I++)
            {
                blobPuyos[I].moveDrag(mouseX, mouseY);
            }
        }
        
        private function onmouseUp(e:MouseEvent):void
        {
            var I:int = 0;
            for(I = 0; I < blobPuyos.length; I++)
            {
                blobPuyos[I].cancelDrag();
            }
        }
    }
}

class BlobPuyo {
    public var ID:int = 0;

    //EXXXXXTRA!!!!
    private var _OLD_PARTICLE_AREA  :Number            = 0;
    
    private var VERT_COUNT          :int               = 16;
    public var RADIUS               :Number            = 30;
    public var _VERTS              :Vector.<Particle> = new Vector.<Particle>(0, false);
    public var _MIDS               :Vector.<Particle> = new Vector.<Particle>(0, false);
    public var _DRAG_ID            :int               = -1;
    public var CENT_PARTICLE       :Particle          = new Particle();  //SPECIAL, center of blob
    
    public var d                   :Vector.<Particle> = new Vector.<Particle>(0, false);
    public var disp                :Vector.<Particle> = new Vector.<Particle>(0, false);
    public var cdiv                :int               = 0;
    public var fdiv                :Vector.<int>      = new Vector.<int>(0, false);
    public var pvn                 :Vector.<Particle> = new Vector.<Particle>(0, false);
    public var sd                  :Number            = 0.3;
    
    private var mouse_x:Number = 0;
    private var mouse_y:Number = 0;
    
    public var blink:Number = 0;
    
    public var color:uint = 0;
    
    public var head:int = 0;
    
    // improvization
    public var EDGES : Vector.<Edge> = new Vector.<Edge>(0, false);
    private var AREA:Number = 0;
    public var FIRST_EDGE:Edge;
    public var FIRST_PARTICLE:Particle;
    public var gMap:GridMap;
    
    private var date:int = 0;
    //
    var gx   :Number = 0;
        var gy   :Number = 0;
        var cx   :Number = 0;
        var cy   :Number = 0;
        var dp   :Number = 0;
        var f1   :Number = 0;
        var f2   :Number = 0;
        var vx   :Number = 0;
        var vy   :Number = 0;
        var len  :Number = 0;
        var diff :Number = 0;

        var bvx:Number = 0;
        var bvy:Number = 0;
        var blen:Number = 0;
        var pavn:Particle = new Particle(0, 0);
        
        var VI:Particle;
        var VJ:Particle;
        var VK:Particle;
        var VO:Particle;
        var BV:Particle;
        var PV:Point;
        var DI:Point;
        var BD:Point;
        var BDO:Point;
        var BDK:Point;
        var be:Edge;

    public function BlobPuyo(id:int, c:uint, px:Number, py:Number, ra:Number = 30, gm:GridMap = null, v:int = 16) {
        ID = id;
        color = c;
        VERT_COUNT = v;
        CENT_PARTICLE.x = px;
        CENT_PARTICLE.y = py;
        RADIUS = ra;
        gMap = gm;
        // constructor code
        var D_RAD:Number = GB._RADIAN360 / VERT_COUNT;
        var I:int = 0;
        var J:int = 0;
        var K:int = 0;
        var VX:Number = 0;
        var VY:Number = 0;
        var TRADIUS:Number = 0;
        var CRADIUS:Number = 0;
        
        switch(int(Math.random()*2))
        {
            case 2:
                //ピーナッツ
                head = 4;
                for(I = 0; I < VERT_COUNT; I++)
                {
                    CRADIUS = Math.abs(Math.abs(I*D_RAD)%(Math.PI)-(Math.PI/2));
                    TRADIUS = RADIUS*1/2 + (RADIUS*1/2 * (CRADIUS)/(Math.PI/2));
                    VX = CENT_PARTICLE.x + Math.cos(I*D_RAD) * TRADIUS;
                    VY = CENT_PARTICLE.y + Math.sin(I*D_RAD) * TRADIUS;
                    _VERTS.push(new Particle(VX, VY, I, ID));
                }
                break;
            case 3:
                //三角
                head = 5;
                for(I = 0; I < VERT_COUNT; I++)
                {
                    CRADIUS = Math.abs(Math.abs(I*D_RAD)%(Math.PI*2/3)-(Math.PI/3));
                    TRADIUS = RADIUS*3/4 + (RADIUS*1/4 * (CRADIUS)/(Math.PI/3));
                    VX = CENT_PARTICLE.x + Math.cos(I*D_RAD) * TRADIUS;
                    VY = CENT_PARTICLE.y + Math.sin(I*D_RAD) * TRADIUS;
                    _VERTS.push(new Particle(VX, VY, I, ID));
                }
                break;
            case 0:
                //方
                head = 4;
                for(I = 0; I < VERT_COUNT; I++)
                {
                    CRADIUS = Math.abs(Math.abs(I*D_RAD)%(Math.PI/2)-(Math.PI/4));
                    TRADIUS = RADIUS*3/4 + (RADIUS/4 * (Math.PI/4-CRADIUS)/(Math.PI/4));
                    VX = CENT_PARTICLE.x + Math.cos(I*D_RAD+Math.PI/4) * TRADIUS;
                    VY = CENT_PARTICLE.y + Math.sin(I*D_RAD+Math.PI/4) * TRADIUS;
                    _VERTS.push(new Particle(VX, VY, I, ID));
                }
                break;
            case 1:
                //円
                head = 0;
                for(I = 0; I < VERT_COUNT; I++)
                {
                    VX = CENT_PARTICLE.x + Math.cos(I*D_RAD) * RADIUS;
                    VY = CENT_PARTICLE.y + Math.sin(I*D_RAD) * RADIUS;
                    _VERTS.push(new Particle(VX, VY, I, ID));
                }
                break;
            case 4:
                //星
                head = 0;
                for(I = 0; I < VERT_COUNT; I++)
                {
                    CRADIUS = Math.abs(Math.abs(I*D_RAD)%(Math.PI*2/5)-(Math.PI/5));
                    TRADIUS = RADIUS*1/2 + (RADIUS*1/2 * (CRADIUS)/(Math.PI/5));
                    VX = CENT_PARTICLE.x + Math.cos(I*D_RAD) * TRADIUS;
                    VY = CENT_PARTICLE.y + Math.sin(I*D_RAD) * TRADIUS;
                    _VERTS.push(new Particle(VX, VY, I, ID));
                }
                break;
        }
        _VERTS.fixed = true;
        var NEXT_PARTICLE:Particle;
        var PREV_PARTICLE:Particle;
        var CURR_PARTICLE:Particle;
        var TARR:Array;
        for(I = 0; I < VERT_COUNT; I++)
        {
            J = (VERT_COUNT+I-1)%VERT_COUNT;  //PREV
            K = (I+1)%VERT_COUNT;
            CURR_PARTICLE = _VERTS[I];
            PREV_PARTICLE = _VERTS[J];
            NEXT_PARTICLE = _VERTS[K];
            CURR_PARTICLE.next = NEXT_PARTICLE;
            CURR_PARTICLE.prev = PREV_PARTICLE;
            CURR_PARTICLE.upRADIAN   = calcRADIAN  (CENT_PARTICLE, CURR_PARTICLE);
            CURR_PARTICLE.downRADIAN = calcRADIAN  (CURR_PARTICLE, CENT_PARTICLE);
            CURR_PARTICLE.nextRADIAN = calcRADIAN  (CURR_PARTICLE, NEXT_PARTICLE);
            CURR_PARTICLE.prevRADIAN = calcRADIAN  (CURR_PARTICLE, PREV_PARTICLE);
            CURR_PARTICLE.hDISTANCE  = calcDISTANCE(CURR_PARTICLE, NEXT_PARTICLE);
            CURR_PARTICLE.vDISTANCE  = calcDISTANCE(CURR_PARTICLE, CENT_PARTICLE);
            TARR = [CURR_PARTICLE, NEXT_PARTICLE, CENT_PARTICLE];
            CURR_PARTICLE.AREA = calcAREA(TARR);  //FOR GAS
            EDGES.push(new Edge(CURR_PARTICLE, NEXT_PARTICLE, ID));
        }
        for(I = 0; I < VERT_COUNT-1; I++) EDGES[I].next = EDGES[I+1];
        FIRST_EDGE = EDGES[0];
        FIRST_PARTICLE = _VERTS[0];
        AREA = calcAreaB();
    }
    
    private function   calcRADIAN(PA:*, PB:*):Number { return Math.atan2(PB.y - PA.y, PB.x - PA.x); }
    private function calcDISTANCE(PA:*, PB:*):Number 
    {
        var VX:Number = PB.x - PA.x;
        var VY:Number = PB.y - PA.y;
        return Math.sqrt(VX*VX+VY*VY);
    }
    
    private function calcMID():void
    {
        for ( var e:Edge = FIRST_EDGE; e != null; e = e.next)
        {
            e.A.mid.x = (e.A.x+e.B.x)/2;
            e.A.mid.y = (e.A.y+e.B.y)/2;
        }
    }
    
    private function calcAREA(arr:Array):Number
    {
        var a:Number=0;
        var n1:*;
        var n2:*;
        for (var i:int=0; i<arr.length; i++)
        {
            n1 = arr[i];
            n2 = arr[(i+1)%arr.length];
            a += (n1.x-n2.x)*(n1.y+n2.y);
        }
        return a/2;
    }
    
    private function calcAreaB():Number
    {
        var a:Number = 0;
        for (var e:Edge = FIRST_EDGE; e != null; e = e.next) a += (e.A.x-e.B.x)*(e.A.y+e.B.y);
        return a/2;
    }
    
    // ボーンの向きを決定する
    private function rotate():void{
        var CURR_PARTICLE:Particle;
        var NEXT_PARTICLE:Particle;
        for ( var e:Edge = FIRST_EDGE; e != null; e = e.next)
        {
            CURR_PARTICLE = e.A;
            NEXT_PARTICLE = e.B;
            calcConnectRForce(CURR_PARTICLE, NEXT_PARTICLE, CURR_PARTICLE.nextRADIAN);
            calcConnectRForce(NEXT_PARTICLE, CURR_PARTICLE, NEXT_PARTICLE.prevRADIAN);
            calcConnectRForce(CURR_PARTICLE, CENT_PARTICLE, CURR_PARTICLE.downRADIAN);
            calcConnectRForce(CENT_PARTICLE, CURR_PARTICLE, CURR_PARTICLE.upRADIAN  );
            if (_DRAG_ID == CURR_PARTICLE.ID)
                CURR_PARTICLE.vr *= GB._MOUSE_ROTATE_FRICTION;
            else
                CURR_PARTICLE.vr *= GB._ROTATE_FRICTION;    // 摩擦
            CURR_PARTICLE.radian += CURR_PARTICLE.vr;
        }
        CENT_PARTICLE.vr *= GB._ROTATE_FRICTION;
        CENT_PARTICLE.radian += CENT_PARTICLE.vr;
    }
    // 接続されたパーツの回転方向を計算する
    private function calcConnectRForce(particle:Particle, targetParticle:Particle, connectAngle:Number):void{
        var angle:Number = Math.atan2(targetParticle.y - particle.y, targetParticle.x - particle.x);
        particle.vr += ajustRadian(angle - (connectAngle + particle.radian)) * GB._ROTATION_RATE;
    }

    private function force():void{
        var CURR_PARTICLE:Particle;
        var NEXT_PARTICLE:Particle;
        var FCOMP:Number = 0;
        var AREA_DIFF:Number = 0;
        var GAS_PRESSURE:Number = 0;
        var NEW_AREA:Number = calcAreaB();
        for ( var e:Edge = FIRST_EDGE; e != null; e = e.next)
        {
            CURR_PARTICLE = e.A;
            NEXT_PARTICLE = e.B;
            AREA_DIFF = NEW_AREA - AREA;
            FCOMP = (AREA_DIFF>1000 || AREA_DIFF<-1000)?0.00333:GB._COMP;
            GAS_PRESSURE = (AREA_DIFF)*FCOMP/_VERTS.length;
            CURR_PARTICLE.updateNormal();
            CURR_PARTICLE.v.x += CURR_PARTICLE.pv.x*GAS_PRESSURE;
            CURR_PARTICLE.v.y += CURR_PARTICLE.pv.y*GAS_PRESSURE;
            calcConnectFoce(CURR_PARTICLE, NEXT_PARTICLE, CURR_PARTICLE.nextRADIAN, CURR_PARTICLE.hDISTANCE);
            calcConnectFoce(NEXT_PARTICLE, CURR_PARTICLE, NEXT_PARTICLE.prevRADIAN, CURR_PARTICLE.hDISTANCE);
            calcConnectFoce(CURR_PARTICLE, CENT_PARTICLE, CURR_PARTICLE.downRADIAN, CURR_PARTICLE.vDISTANCE, true, false);
            calcConnectFoce(CENT_PARTICLE, CURR_PARTICLE, CURR_PARTICLE.upRADIAN  , CURR_PARTICLE.vDISTANCE, false);
            
            CURR_PARTICLE.a.y += GB._GRAVITY;
            if (_DRAG_ID == e.A.ID){    // マウスで引っ張る
                var point:Particle = pullForce(CURR_PARTICLE.x, CURR_PARTICLE.y, mouse_x, mouse_y, GB._MOUSE_PULL_RATE);
                CURR_PARTICLE.a.x += point.x;
                CURR_PARTICLE.a.y += point.y;
                CURR_PARTICLE.v.x *= GB._MOUSE_MOVE_FRICTION;
                CURR_PARTICLE.v.y *= GB._MOUSE_MOVE_FRICTION;
            }
        }
        CENT_PARTICLE.a.y += GB._GRAVITY;
    }
    // 接続された２パーツの力を計算する
    private function calcConnectFoce(particle:Particle, targetParticle:Particle, connectAngle:Number, distance:Number, cleanA:Boolean = true, cleanB:Boolean = true):void{
        var toAngle:Number = ajustRadian(connectAngle + particle.radian);
        var toX:Number = particle.x + Math.cos(toAngle) * distance;
        var toY:Number = particle.y + Math.sin(toAngle) * distance;
        var ax:Number = (targetParticle.x - toX) * GB._VERTICAL_RATE;
        var ay:Number = (targetParticle.y - toY) * GB._VERTICAL_RATE;
        particle.a.x += ax;
        particle.a.y += ay;
        targetParticle.a.x -= ax;
        targetParticle.a.y -= ay;
        
        if(cleanA) particle.fdiv++;
        if(cleanB) targetParticle.fdiv++;
    }
    
    // radian角度を、-π～πの範囲に修正する
    private function ajustRadian(radian:Number):Number{
        return radian - GB._PI2 * Math.floor( 0.5 + radian / GB._PI2);
    }
    // ポイントx1 y1を、ポイントx2 y2へ、係数rateだけ移動させる場合の、XYの力を返す
    private function pullForce(x1:Number, y1:Number, x2:Number, y2:Number, rate:Number):Particle{
        var point:Particle = new Particle();
        var distance:Number = calcDistance(x1, y1, x2, y2);
        
        var angle:Number = Math.atan2(y2 - y1, x2 - x1);
        point.x = Math.cos(angle) * distance * rate;
        point.y = Math.sin(angle) * distance * rate;
        return point;
    }
    // ポイントx1 y1から、ポイントx2 y2までの距離
    private function calcDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number{
        return Math.sqrt(Math.pow(x2-x1, 2) + Math.pow(y2-y1, 2));
    }
    
    private function updatePARTICLE(CURR_PARTICLE:Particle):void
    {
        CURR_PARTICLE.a.x += -GB._FRICTION * CURR_PARTICLE.v.x;
        CURR_PARTICLE.a.y += -GB._FRICTION * CURR_PARTICLE.v.y;
        
        // 速度、位置への反映
        CURR_PARTICLE.v.x += CURR_PARTICLE.a.x;
        CURR_PARTICLE.v.y += CURR_PARTICLE.a.y;
        CURR_PARTICLE.x += CURR_PARTICLE.v.x;
        CURR_PARTICLE.y += CURR_PARTICLE.v.y;
        CURR_PARTICLE.a.x = 0;
        CURR_PARTICLE.a.y = 0;    // 力をクリア
        
        // 壁チェック
        if (0 < CURR_PARTICLE.v.y && GB._GROUND_LINE < CURR_PARTICLE.y){
            CURR_PARTICLE.y = GB._GROUND_LINE;
            CURR_PARTICLE.v.y *= -0.8;
            if (CURR_PARTICLE.v.y < -50) CURR_PARTICLE.v.y = -50;
            CURR_PARTICLE.v.x *= GB._GROUND_FRICTION;
        }
        if (CURR_PARTICLE.v.x < 0 && CURR_PARTICLE.x < GB._WALL_LEFT){
            CURR_PARTICLE.x = GB._WALL_LEFT;
            CURR_PARTICLE.v.x = 0;
            CURR_PARTICLE.v.y *= GB._GROUND_FRICTION;
        }else if (0 < CURR_PARTICLE.v.x && GB._WALL_RIGHT < CURR_PARTICLE.x){
            CURR_PARTICLE.x = GB._WALL_RIGHT;
            CURR_PARTICLE.v.x = 0;
            CURR_PARTICLE.v.y *= GB._GROUND_FRICTION;
        }
        CURR_PARTICLE.updateGrid();
    }
    
    private function move():void
    {
        for (var e:Edge = FIRST_EDGE; e != null; e = e.next) updatePARTICLE(e.A);
        updatePARTICLE(CENT_PARTICLE);
    }
    
    private function mapping():void
    {
        for (var e:Edge = FIRST_EDGE; e != null; e = e.next)
        {
            gMap.linePushXY(e, e.A.grid.x, e.A.grid.y, e.B.grid.x, e.B.grid.y);
        }
    }
    
    public function detectDrag(m_x:Number, m_y:Number):void
    {
        var MAX_DISTANCE:Number = 9999;
        var VX:Number = 0;
        var VY:Number = 0;
        var DIST:Number = 0;
        for ( var e:Edge = FIRST_EDGE; e != null; e = e.next)
        {
            VX = m_x - e.A.x;
            VY = m_y - e.A.y;
            DIST = Math.sqrt(VX*VX+VY*VY);
            if(DIST<MAX_DISTANCE && DIST<15)
            {
                MAX_DISTANCE = DIST;
                _DRAG_ID = e.A.ID;
            }
        }
    }
    
    public function moveDrag(m_x:Number, m_y:Number):void
    {
        mouse_x = m_x; mouse_y = m_y;
    }
    
    public function cancelDrag():void
    {
        _DRAG_ID = -1;
    }
    
    public function setup(da:int):void
    {
        var vx   :Number = 0;
        var vy   :Number = 0;
        var len  :Number = 0;
        var diff :Number = 0;
        var nx   :Number = 0;
        var ny   :Number = 0;
        var ux   :Number = 0;
        var uy   :Number = 0;
        var VI   :Particle;
        var VK   :Particle;
        date = da;
        gMap.date = date;
        for ( var e:Edge = FIRST_EDGE; e != null; e = e.next)
        {
            VI = e.A;
            VK = e.B;
            vx = e.vx;
            vy = e.vy;
            len = Math.sqrt(vx * vx + vy * vy);
            diff = VI.nextRADIAN - len;
            nx = vx / len;
            ny = vy / len;
            ux = diff * nx;
            uy = diff * ny;
            VI.d.x = nx;
            VI.d.y = ny;
        }
        mapping();
    }
    
    public function update():void
    {
        response();
        rotate();    // 回転の計算
        force();    // 力の計算
        move();    // 移動処理
        calcMID();
    }
    
    private function response():void
    {
        var gx:Number =0;
        var gy:Number = 0;
        var xlen:Number = 0;
        var VI:Particle;
        var DI:Point;
        for ( var e:Edge = FIRST_EDGE; e != null; e = e.next)
        {
            VI = e.A;
            VI.o.x = VI.x;
            VI.o.y = VI.y;
            if(VI.fdiv > 0)
            {
                DI = VI.disp;
                gx = DI.x / VI.fdiv;
                gy = DI.y / VI.fdiv;
                VI.x = VI.x + gx;
                VI.y = VI.y + gy;
                VI.v.x += gx;
                VI.v.y += gy;
                DI.x = 0.0;
                DI.y = 0.0;
                VI.fdiv = 0;
            }
        }
    }
    
    public function intersected(p1:*, p2:*, p3:*, p4:*):Boolean
    {
        var s1_x:Number, s1_y:Number, s2_x:Number, s2_y:Number;
        s1_x = p2.x - p1.x;     s1_y = p2.y - p1.y;
        s2_x = p4.x - p3.x;     s2_y = p4.y - p3.y;
    
        var s:Number, t:Number;
        s = (-s1_y * (p1.x - p3.x) + s1_x * (p1.y - p3.y)) / (-s2_x * s1_y + s1_x * s2_y);
        t = ( s2_x * (p1.y - p3.y) - s2_y * (p1.x - p3.x)) / (-s2_x * s1_y + s1_x * s2_y);
    
        if (s >= 0 && s <= 1 && t >= 0 && t <= 1) return true;
        return false;
    }
    
    public function xcontact():void
    {
        for ( var e:Edge = FIRST_EDGE; e != null; e = e.next)
        {
            intersectAAline(e.A);
            e.A.hash.flush();
        }
    }
    
    public function solveContact(p:Particle, tx:int, ty:int):void
    {
        if(tx<0 || ty<0) return;
        var elist:Cargo = gMap.getXY(tx,ty);
        if(!elist || elist.length==0 || elist.date != date) return;
        var i:int = 0;
        
        VI = p;
        PV = VI.pv;
        DI = VI.disp;
        for each(be in elist.list)
        {
            VO = be.A;
            VK = be.B;

            pavn.x = VI.x + PV.x * RADIUS;
            pavn.y = VI.y + PV.y * RADIUS;

            if (VI.BID != be.BID && !p.hash.hasInst(be.ID) && intersected(VI, pavn, VK, VO)) {
                p.hash.push(be.ID);
                BD = VO.d;
                BDO = VO.disp;
                BDK = VK.disp;

                vx = VI.x - VO.x;
                vy = VI.y - VO.y;
                
                dp = vx * BD.x + vy * BD.y;
                
                bvx = be.vx;
                bvy = be.vy;
                
                blen = Math.sqrt(bvx*bvx+bvy*bvy);

                cx = VO.x + dp * BD.x;
                cy = VO.y + dp * BD.y;
                
                vx = VI.x - cx;
                vy = VI.y - cy;
                
                diff = 4 /4;
                gx = diff * vx;
                gy = diff * vy;

                DI.x -= gx;
                DI.y -= gy;
                VI.fdiv++;

                f1 = dp / blen;
                f2 = 1.0 - f1;
                
                BDO.x += f2 * gx;
                BDO.y += f2 * gy;
                VO.fdiv++;

                BDK.x += f1 * gx;
                BDK.y += f1 * gy;
                VK.fdiv++;
                
                VI.v.x = 0;
                VI.v.y = 0;
                //break;
            }
        }
    }
    
    //intersection detection with anti-aliasing line
    public function intersectAAline (p:Particle):void
    {    
        var x1:int = CENT_PARTICLE.grid.x;
        var y1:int = CENT_PARTICLE.grid.y;
        var x2:int = p.grid.x;
        var y2:int = p.grid.y;
        var steep:Boolean = (y2 - y1) < 0 ? -(y2 - y1) : (y2 - y1) > (x2 - x1) < 0 ? -(x2 - x1) : (x2 - x1);
        var swap:int;
        if (steep)
        {
            swap=x1; x1=y1; y1=swap;
            swap=x2; x2=y2; y2=swap;
        }
        if (x1 > x2)
        {
            swap=x1; x1=x2; x2=swap;
            swap=y1; y1=y2; y2=swap;
        }
        var dx:int = x2 - x1;
        var dy:int = y2 - y1;
        var gradient:Number = dy / dx;
        var xend:int = x1;
        var yend:Number = y1 + gradient * (xend - x1);
        var xgap:Number = 1-((x1 + 0.5)%1);
        var xpx1:int = xend;
        var ypx1:int = yend;
        var intery:Number = yend + gradient;
        xend = x2;
        yend = y2 + gradient * (xend - x2)
        xgap = (x2 + 0.5)%1;
        var xpx2:int = xend; 
        var ypx2:int = yend;
        if (steep)
            solveContact(p,ypx2,xpx2);
        else
            solveContact(p,xpx2,ypx2);
        if (steep)
            solveContact(p,ypx2 + 1,xpx2);
        else
            solveContact(p,xpx2, ypx2 + 1); 
        var x:int=xpx1;
        while (x++<xpx2)
        {
            if (steep)
                solveContact(p,intery,x);
            else
                solveContact(p,x,intery);
            if (steep)
                solveContact(p,intery+1,x);
            else
                solveContact(p,x,intery+1);
            intery = intery + gradient;
        }
    }
}

import flash.geom.Point;

class Particle
{
    public var BID:int = 0;
    public var ID:int = 0;
    public var x:Number = 0;    // 位置
    public var y:Number = 0;
    public var v:Point = new Point();    // 速度
    public var a:Point = new Point();    // 加速度=力    TOTO:最後まで意味無かったら消す
    public var pv:Point = new Point();
    public var d:Point = new Point();
    public var mid:Point = new Point();
    public var disp:Point = new Point();
    public var o:Point = new Point();
    public var fdiv:int = 0;
    
    public var radian:Number = 0;    // 向き
    public var vr:Number = 0;    // 向き速度

    public var   upRADIAN :Number = 0;
    public var downRADIAN :Number = 0;
    public var prevRADIAN :Number = 0;
    public var nextRADIAN :Number = 0;
    public var       AREA :Number = 0;
    public var  vDISTANCE :Number = 0;
    public var  hDISTANCE :Number = 0;
    
    public var next :Particle;
    public var prev :Particle;
    
    public var grid:GridInfo = new GridInfo();
    public var hash:Hash = new Hash(true);
    
    public function Particle(px:Number = 0, py:Number = 0, id:int = 0, bid:int = 0) { x = px; y = py; ID = id; BID = bid; o.x = x; o.y = y; }
    public function updateNormal():void
    {
        var dpx:Number=prev.x-x;
        var dpy:Number=prev.y-y;
        var dnx:Number=next.x-x;
        var dny:Number=next.y-y;

        var nx:Number=-dny;
        var ny:Number=dnx;
        var na:Number=Math.sqrt(nx*nx+ny*ny);
        if (na==0)
        {
            nx=1; ny=0;
        } else {
            nx/=na; ny/=na;
        }

        //rotate dp anti-clockwise by 90C
        var px:Number=dpy;
        var py:Number=-dpx;
        var pa:Number=Math.sqrt(px*px+py*py);
        if (pa==0)
        {
            px=1; py=0;
        } else {
            px/=pa; py/=pa;
        }

        var fx:Number=nx+px;
        var fy:Number=ny+py;
        var fa:Number=Math.sqrt(fx*fx+fy*fy);
        if (fa==0)
        {
            fx=1; fy=0;
        } else {
            fx/=fa; fy/=fa;
        }

        pv.x = fx;
        pv.y = fy;
    }
    public function updateGrid():void
    {
        grid.setGridV(x,y);
        grid.setGridOV(o.x,o.y);
    }
}

class GB {
    public static const _WALL_LEFT             :Number = 0;
    public static const _WALL_RIGHT            :Number = 465;
    public static const _GROUND_LINE           :Number = 350;
    
    public static const _DOT_CONNECT_MAX       :int    = 4;
    public static const _DERIVATION            :int    = 3;    // 計算の分割数。  //3
    public static const _MAP_SIZE              :Number = 400;
    
    public static const _PI                    :Number = Math.PI;
    public static const _PI2                   :Number = 2.0 * _PI;
    public static const _RADIAN90              :Number = _PI * 0.5;
    public static const _RADIAN180             :Number = _PI * 1.0;
    public static const _RADIAN270             :Number = _PI * -0.5;
////v0.2
    public static const _RADIAN360             :Number = _PI * 2;
    public static const _TO_DEGREE             :Number = 180 / _PI;
    
    //public static const _COMP                  :Number = 0.0133;  //0.1
    public static const _COMP                  :Number = 0.133;  //0.1
    public static const _GRAVITY               :Number = 0.6 / _DERIVATION;  //0.3  //0.6
    public static const _ROTATION_RATE         :Number = 0.05 / _DERIVATION;    // 自身バネ（根元） //0.05
    public static const _VERTICAL_RATE         :Number = 0.166 / _DERIVATION;    // ターゲットバネ（さきっぽ） //0.2  //0.133
    public static const _MOUSE_PULL_RATE       :Number = 2.0 / _DERIVATION;
    
    public static const _FRICTION              :Number = 0.1 / _DERIVATION;
    public static const _ROTATE_FRICTION       :Number = 1 - 0.2 / _DERIVATION;
    public static const _MOUSE_ROTATE_FRICTION :Number = 1 - 0.8 / _DERIVATION;
    public static const _MOUSE_MOVE_FRICTION   :Number = 1 - 0.5 / _DERIVATION;
    public static const _GROUND_FRICTION       :Number = 1 - 0.5 / _DERIVATION;  // 1 - 0.2  // 1 - 0.5
    
    public static const MAP_WIDTH              :Number = 465;
    public static const MAP_HEIGHT             :Number = 465;
    public static const GRID_WIDTH             :int = 100;
    public static const GRID_HEIGHT            :int = 100;
    public static const DIV_WIDTH              :Number = MAP_WIDTH/GRID_WIDTH;
    public static const DIV_HEIGHT             :Number = MAP_HEIGHT/GRID_HEIGHT;
    
    public function GB() {}
}
// improvization
class Edge
{
    public var BID:int = 0;
    public var ID:String = "";
    public var A:Particle; // B.index > A.index
    public var B:Particle;
    public var next:Edge;
    public function Edge(a:Particle, b:Particle, bid:int = 0) {A=a; B=b; ID=""+bid+"-"+a.ID+"-"+b.ID; BID = bid;}
    public function get vx():Number { return B.x - A.x; }
    public function get vy():Number { return B.y - A.y; }
}
import flash.utils.Dictionary;
dynamic class Hash extends Dictionary
{
    public function Hash(weak:Boolean = false) { super(weak); }
    public function push(inst:*, prop:Boolean = true):void { this[inst] = prop; }
    public function destroy(inst:*):void { delete this[inst]; }
    public function flush():void { for (var item:* in this) { delete this[item]; } }
    public function concat(h:Hash):void { for (var item:* in h) { this[item] = h[item]; } }
    public function hasInst(inst):Boolean { if (this[inst]) { return true; } return false; }
    public function empty():Boolean { for (var item:* in this) { return false; } return true; }
    public function hasProp(inst:*):Boolean { for (var item:* in this) { if (this[item] === inst) return true; } return false; }
    public function get size():int { var count:int; for (var item:* in this) { count++; } return count; }
}
class GridMap
{
    public var date:int = 0;
    private var MAP:Vector.<Cargo>;
    private var WIDTH:int = 0;
    private var HEIGHT:int = 0;
    public function GridMap(w:int,h:int)
    {
        WIDTH = w; HEIGHT = h;
        MAP = new Vector.<Cargo>(w*h, true);
        for(var i:* in MAP) MAP[i] = new Cargo();
    }
    public function push(e:Edge, at:int):void { MAP[at].push(e,date); }
    public function pushXY(e:Edge, x:int, y:int):void { MAP[y*WIDTH+x].push(e,date); }
    public function get(at:int):Cargo { return MAP[at]; }
    public function getXY(x:int, y:int):Cargo {
        if(y>=HEIGHT || x>=WIDTH ) return null;
        return MAP[y*WIDTH+x];
    }
    public function flush():void { for each(var ve:Cargo in MAP) ve.clean(); }
    public function linePush(e:Edge, from:int, to:int):void
    {
        lineFast(e, from%WIDTH, int(from/HEIGHT), to%WIDTH, int(to/HEIGHT));
    }
    public function linePushXY(e:Edge, fromX:int, fromY:int, toX:int, toY:int):void
    {
        lineFast(e, fromX, fromY, toX, toY);
    }
    /*
    public function lineFast(e:Edge, x0:int, y0:int, x1:int, y1:int):void
    {    
        var dy       :int = y1 - y0;
        var dx       :int = x1 - x0;
        var stepx    :int;
        var stepy    :int;
        var fraction :int;
        
        if (dy < 0) { dy = -dy;  stepy = -1; } else { stepy = 1; }
        if (dx < 0) { dx = -dx;  stepx = -1; } else { stepx = 1; }
        dy <<= 1;
        dx <<= 1;
        instill(e, x0, y0);
        if (dx > dy)
        {
            fraction = dy - (dx >> 1);
            while (x0 != x1)
            {
                if (fraction >= 0)
                {
                    y0 += stepy;
                    fraction -= dx;
                }
                x0 += stepx;
                fraction += dy;
                instill(e, x0, y0);
            }
        } else {
            fraction = dx - (dy >> 1);
            while (y0 != y1)
            {
                if (fraction >= 0)
                {
                    x0 += stepx;
                    fraction -= dy;
                }
                y0 += stepy;
                fraction += dx;
                instill(e, x0, y0);
            }
        }
    }
    /**/
    public function instill(e:Edge, px:int, py:int):void
    {
        if(px>=0 && py>=0 && py<HEIGHT && px<WIDTH) MAP[py * WIDTH + px].push(e,date);
    }
    public function lineFast(e:Edge, x1:int, y1:int, x2:int, y2:int):void {
        var shortLen:int = y2 - y1;
        var longLen:int = x2 - x1;
        if (!longLen) if (!shortLen) return;
        var i:int, id:int, inc:int;
        var multDiff:Number;
        
        // TODO: check for this above, swap x/y/len and optimize loops to ++ and -- (operators twice as fast, still only 2 loops)
        if ((shortLen ^ (shortLen >> 31)) - (shortLen >> 31) > (longLen ^ (longLen >> 31)) - (longLen >> 31)) {
            if (shortLen < 0) {
                inc = -1;
                id = -shortLen % 4;
            } else {
                inc = 1;
                id = shortLen % 4;
            }
            multDiff = !shortLen ? longLen : longLen / shortLen;

            if (id) {
                instill(e, x1, y1);
                i += inc;
                if (--id) {
                    instill(e, x1 + i * multDiff, y1 + i);
                    i += inc;
                    if (--id) {
                        instill(e, x1 + i * multDiff, y1 + i);
                        i += inc;
                    }
                }
            }
            while (i != shortLen) {
                instill(e, x1 + i * multDiff, y1 + i);
                i += inc;
                instill(e, x1 + i * multDiff, y1 + i);
                i += inc;
                instill(e, x1 + i * multDiff, y1 + i);
                i += inc;
                instill(e, x1 + i * multDiff, y1 + i);
                i += inc;
            }
        } else {
            if (longLen < 0) {
                inc = -1;
                id = -longLen % 4;
            } else {
                inc = 1;
                id = longLen % 4;
            }
            multDiff = !longLen ? shortLen : shortLen / longLen;

            if (id) {
                instill(e, x1, y1);
                i += inc;
                if (--id) {
                    instill(e, x1 + i, y1 + i * multDiff);
                    i += inc;
                    if (--id) {
                        instill(e, x1 + i, y1 + i * multDiff);
                        i += inc;
                    }
                }
            }
            while (i != longLen) {
                instill(e, x1 + i, y1 + i * multDiff);
                i += inc;
                instill(e, x1 + i, y1 + i * multDiff);
                i += inc;
                instill(e, x1 + i, y1 + i * multDiff);
                i += inc;
                instill(e, x1 + i, y1 + i * multDiff);
                i += inc;
            }
        }
    }
}
class GridInfo
{
    public var x:int = 0;
    public var y:int = 0;
    public var ox:int = 0;
    public var oy:int = 0;
    public var i:int = 0;
    public var oi:int = 0;
    public function GridInfo() {}
    public function setGrid(px:int, py:int):void {x=px; y=py; i=x+y*GB.GRID_WIDTH;}
    public function setGridV(px:Number, py:Number):void {x=int(px/GB.DIV_WIDTH); y=int(py/GB.DIV_HEIGHT); i=x+y*GB.GRID_WIDTH;}
    public function setGridOV(px:Number, py:Number):void {ox=int(px/GB.DIV_WIDTH); oy=int(py/GB.DIV_HEIGHT); oi=ox+oy*GB.GRID_WIDTH;}
}
class Cargo
{
    public var date:int = 0;
    private var container:Vector.<Edge> = new Vector.<Edge>(0, false);
    public function Cargo() {}
    public function clean():void {container.splice(0,container.length);}
    public function push(e:Edge,d:int=0):void {if(date!=d) {clean(); date=d;} container.push(e);} // if cargo is expired, we should clean it!
    public function get length():int {return container.length;}
    public function get list():Vector.<Edge> {return container;}
}