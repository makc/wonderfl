//
//    謎の発光生物を表現
//
//
package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    
    [SWF(width = "465", height = "465")]
    
    public class Main extends Sprite 
    {
        private static const WIDTH:int = 465;
        private static const HEIGHT:int = 465;
        
        private var _creature:Creature;
        
        private var _sprite:Sprite;
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            graphics.beginFill(0);
            graphics.drawRect(0, 0, WIDTH, HEIGHT);
            graphics.endFill();
            
            _creature = new Creature();
            _creature.Generation(WIDTH / 2, HEIGHT / 2);
            
            _sprite = new Sprite();
            addChild(_sprite);
            
            
            addEventListener(Event.ENTER_FRAME, Update);
        }
        
        private function Update(e:Event) : void
        {
            _creature.Update( stage.mouseX, stage.mouseY );
            
            _sprite.graphics.clear();
            _creature.DrawSprite(_sprite);
            
        }
        
    }
    
}
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;

class Creature
{
    private var _partlist:/*CreaturePart*/Array;
    private var _paths:Vector.<Point>;
    private static const PART_INTERVAL:int = 2;
    private static const PART_NUM:int = 50;
    private static const DEC:Number = 0.1;
    
    private var _tx:Number;
    private var _ty:Number;
    
    private var _step:int;
    
    public function Creature() {
        _step = 0;
    }
    
    public function Generation(startX:Number, startY:Number) : void {
        
        var i:int;
        
        _partlist = new Array();
        _paths = new Vector.<Point>();
        
        for ( i = 0; i < PART_NUM; i++ )
        {
            var type:int = 0;
            var tenR:Number = Math.sin( (i / PART_NUM) * Math.PI ) * 30 + 10;
            if ( i % 2 == 0 ) type = 1;
            var part:CreaturePart = new CreaturePart(type, tenR);
            part.x = startX;
            part.y = startY;
            _partlist.push( part );
        }
        for ( i = 0; i < PART_NUM * PART_INTERVAL; i++ )
        {
            _paths.push( new Point(startX, startY) );
        }
        
        
        for ( i = 0; i < PART_NUM -1; i++ )
        {
            _partlist[i].SetNextPart( _partlist[i + 1] );
        }
        
        
        _tx = startX;
        _ty = startY;
        
    }
    
    public function Update(tx:Number,ty:Number) : void
    {
        var i:int = 0;
        for ( i = 0; i < PART_NUM; i++ )
        {
            _partlist[i].Update( _paths[PART_INTERVAL * (i + 1) - 1] );
        }
        //    
        UpdateTargetPosition(tx, ty);
        
        if ( _step % 20 == 0 )    _partlist[0].StartFlash();
        _step++;
    }
    
    /**
     * 先頭のパーツを一定の法則で移動させてその値を座標リストに追加
     * @param    tx
     * @param    ty
     */
    public function UpdateTargetPosition(tx:Number, ty:Number) : void
    {
        var sub:Number = 0;
        var partTop:CreaturePart = _partlist[0];
        if ( !(Math.abs( tx - partTop.x ) < 3 || Math.abs( ty - partTop.y ) < 3) )
        {
            var vecAngle:Number = Math.atan2(ty - partTop.y, tx - partTop.x) * 180 / Math.PI;     
            //    角度差を丸める
            sub = vecAngle - partTop.angle;
            sub -= Math.floor(sub / 360.0) * 360.0;
            if (sub < -180.0)    sub += 360.0;
            if (sub > 180.0)    sub -= 360.0;
            
            sub = Math.min( 5, sub );
            sub = Math.max( -5, sub );
        }
        
        //    次の移動角度
        var nextAngle:Number = partTop.angle + sub;
        _tx += Math.cos( nextAngle * Math.PI / 180 ) * 3;
        _ty += Math.sin( nextAngle * Math.PI / 180 ) * 3;
        
        
    //    _tx += (tx - _tx) * DEC;
    //    _ty += (ty - _ty) * DEC;
        _paths.unshift(new Point(_tx, _ty));
        _paths.pop();
    }
    
    public function DrawSprite(sp:Sprite):void 
    {
        var g:Graphics = sp.graphics;
        var part:CreaturePart;
        var i:int;
        
        //    胴体
        g.lineStyle(4, 0xAAAAFF,0.5);
        for ( i = 0; i < PART_NUM; i++ )
        {
            part = _partlist[i];
            if ( i == 0 )    g.moveTo( part.x, part.y );
            else             g.lineTo( part.x, part.y );
        }
        
        //    各パーツ
        for ( i = 0; i < PART_NUM; i++ )
        {
            part = _partlist[i];
            if ( part.parttype != 0 )
            {
                g.lineStyle(1, 0xAAAAFF);
                g.moveTo(part.tenLx, part.tenLy);                
                g.lineTo(part.tenRx, part.tenRy);
                
                g.drawCircle(part.tenLx, part.tenLy, 1);
                g.drawCircle(part.tenRx, part.tenRy, 1);
                
                if ( part.ligthrate > 0 )
                {
                    g.beginFill(0xFFFFFF, part.ligthrate);
                    g.drawCircle(part.tenLx, part.tenLy, part.ligthrate*2 + 1);
                    g.drawCircle(part.tenRx, part.tenRy, part.ligthrate*2 + 1);
                    g.endFill();
                }
                
            }
        }
    }
    
}

class CreaturePart
{
    public var x:Number;
    public var y:Number;
    public var angle:Number;
    public var angleRad:Number;
    
    public var parttype:int;
    
    //    触手
    private var tentacleR:Number = 50;
    private var tentacleLPos:Point;
    private var tentacleRPos:Point;
    
    public function get tenLx() : Number { return x + tentacleLPos.x;    }
    public function get tenLy() : Number { return y + tentacleLPos.y;    }
    public function get tenRx() : Number { return x + tentacleRPos.x;    }
    public function get tenRy() : Number { return y + tentacleRPos.y;    }
    
    //    発光
    private var ligthflg:Boolean;
    private var lightStep:int;
    public function get ligthrate() : Number { return    Math.sin( lightStep / 10 * Math.PI );    }
    
    private var _nextPart:CreaturePart;
    
    public function CreaturePart(type:int, tenR:Number) {
        angle = 0;
        angleRad = 0;
        parttype = type;
        tentacleLPos = new Point();
        tentacleRPos = new Point();
        tentacleR = tenR;
        StopFlash();
        _nextPart = null;
    }
        
    public function SetNextPart( part:CreaturePart ) : void
    {
        _nextPart = part;
    }
    
    public function Update(point:Point) : void
    {
        var atan2:Number = Math.atan2( point.y - y, point.x - x );
        angleRad = atan2 + Math.PI/2;
        angle = atan2 * 180 / Math.PI;
        x = point.x;
        y = point.y;
        
        UpdateTentaclePos(atan2);
        
        if ( ligthflg )
        {
            if ( lightStep == 10 )    StopFlash();
            else
            {
                if ( lightStep == 1 && _nextPart != null ) _nextPart.StartFlash();
                lightStep++;    
            }
        }
    }
    
    private function UpdateTentaclePos( rad:Number ) : void
    {
        var rate:Number = 0.1;
        
        var tenx:Number = Math.cos( rad + Math.PI / 2 ) * tentacleR;
        var teny:Number = Math.sin( rad + Math.PI / 2 ) * tentacleR;
        
        tentacleRPos.x += (tenx - tentacleRPos.x) * rate;
        tentacleRPos.y += (teny - tentacleRPos.y) * rate;

        tenx = Math.cos( rad - Math.PI / 2 ) * tentacleR;
        teny = Math.sin( rad - Math.PI / 2 ) * tentacleR;
        
        tentacleLPos.x += (tenx - tentacleLPos.x) * rate;
        tentacleLPos.y += (teny - tentacleLPos.y) * rate;
        
    }
    
    public function StartFlash() : void
    {
        ligthflg = true;
        lightStep = 0;
    }
    
    public function StopFlash() : void
    {
        ligthflg = false;
        lightStep = 0;
    }
    
}