package
{
    import flash.display.*;
    import flash.events.Event;
    import flash.text.*;

    [SWF(width="320", height="240", backgroundColor="0x000000", frameRate="30")] 
    public class MegaManTest extends Sprite
    {
        private var megaman:MegaMan;
        private var count:int = 100;
        private var test_col:TestCollision = new TestCollision();

        function MegaManTest()
        {
            var tx:TextField = new TextField();
            tx.width = 320;
            tx.text = " Sprite pattern of MegaMan is distributed under niconi-commons\n"+
                "license by CAPCOM Co., Ltd.\n"+
                "* DO NOT USE FOR COMMERCIAL PURPOSE *";
            tx.textColor = 0xffffff;
            addChild(tx);

            megaman = new MegaMan();
            megaman.collision = test_col;
            megaman.y = -80;
            megaman.x = 160;
            megaman.dir = MegaMan.D_LEFT;
            megaman.jump();
            megaman.run();
            addChild(megaman);

            var preview:Bitmap = new Bitmap(megaman.sprite.pool);
            addChild(preview);
            preview.y = 100;
            preview.x = 20;
            preview.scaleX = 0.3;
            preview.scaleY = 0.3;

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(e:Event):void
        {

            if (count == 50) {
                megaman.dir = MegaMan.D_LEFT;
                megaman.run();
            } else if (count == 200){
                megaman.dir = MegaMan.D_RIGHT;
                megaman.run();
            } else if (count == 0 || count == 150) {
                megaman.stand();
            }

            if (count == 90 || count == 240 || count == 280)
                megaman.jump();

            megaman.tick();
            count = (count+1) % 300;
        }
    }
}

interface ICollision
{
    function checkFloor(x1:Number, y1:Number, x2:Number, y2:Number):CollisionResult;
}

class TestCollision implements ICollision
{
    public function checkFloor(x1:Number, y1:Number, x2:Number, y2:Number):CollisionResult
    {
        if (y1 < y2 && y2 > 100) {
            var r:CollisionResult = new CollisionResult();
            r.py = y2 -= 100;
            return r;
        }

        return null;
    }
}

class CollisionResult
{
    public var px:Number = 0, py:Number = 0;
}

class MegaMan extends flash.display.Sprite
{
    import flash.display.*;
    import flash.geom.*;
    public static const S_STAND:uint = 0x01;
    public static const S_RUN:uint   = 0x02;
    public static const S_JUMP:uint  = 0x04;

    public static const D_LEFT:uint  = 1;
    public static const D_RIGHT:uint = 2;

    private static const RUN_PTN:Array = [20, 21, 22, 23];
    private static const STD_PTN:Array = [0, 0, 0, 1, 0, 0];

    private static const FOOT_Y:int = 33;

    private var mSpr:IndexedSprite;
    private var mState:uint;
    private var mDir:uint;
    private var mV:Point = new Point(0, 0);
    private var mVfix:Point = new Point(0, 0);
    private var mRunSpeed:int = 3;

    private var mAnimationCount:int;
    private var mCollision:ICollision = null;

    function MegaMan()
    {
        mDir = D_RIGHT;
        mState = S_STAND;
        mAnimationCount = 0;

        var pool:SpritePool = new SpritePool(MegaManPatternData);
        mSpr = new IndexedSprite(
                pool,
                MegaManPatternData.CELL_WIDTH,
                MegaManPatternData.CELL_HEIGHT,
                MegaManPatternData.CELL_COLS
        );

        addChild(mSpr);
    }

    public function set collision(c:ICollision):void {
        mCollision = c;
    }

    public function set dir(d:uint):void {
        mDir = d;
    }

    private function ifChangeState(s:uint):void
    {
        if (mState != s) {
            mState = s;
            mAnimationCount = 0;
        }
    }

    public function run():void {
        if (mState != S_JUMP)
            ifChangeState(S_RUN);
        mV.x = mRunSpeed * ((mDir==D_LEFT) ? -1 : 1);
    }

    public function stand():void {
        if (mState != S_JUMP)
            ifChangeState(S_STAND);
        mV.x = 0;
    }

    public function get sprite():IndexedSprite
    {
        return mSpr;
    }

    public function jump():void
    {
        if (mState != S_JUMP) {
            mAnimationCount = 0;
            mV.y = -5;
            mState = S_JUMP;
        }
    }

    private function land():void
    {
        mState = (mV.x!=0) ? S_RUN : S_STAND;
    }

    public function tick():void
    {
        checkFloorCollosion();

        switch(mState) {
        case S_STAND:
            mSpr.index = STD_PTN[ int(mAnimationCount/6)%6 ];
            break; 
        case S_RUN:
            mSpr.index = RUN_PTN[ int(mAnimationCount/4)%4 ];
            break; 
        case S_JUMP:
            if (mAnimationCount > 5) {
                mV.y += 1;
                if (mV.y > 8) mV.y = 8;
            }
            mSpr.index = 10;
            break; 
        }

        mSpr.scaleX = (mDir == D_RIGHT) ? -1 : 1;
        mSpr.x = -32 * mSpr.scaleX;
        mAnimationCount++;

        updatePosition();
    }

    private static const FOOT_W:int = 3;
    private function checkFloorCollosion():void
    {
        if (!mCollision) return;

        var r:CollisionResult;
        if (mState == S_JUMP) {
            r = mCollision.checkFloor(x-FOOT_W, y + FOOT_Y, x-FOOT_W+mV.x, y + FOOT_Y+mV.y);
            if (!r)
                r = mCollision.checkFloor(x+FOOT_W, y + FOOT_Y, x+mV.x+FOOT_W, y + FOOT_Y+mV.y);

            if (r) {
                land();
                mV.y -= r.py;
                mVfix.y = -mV.y;
            }
        }
    }

    private function updatePosition():void
    {
        x += mV.x;
        y += mV.y;

        mV.x += mVfix.x;
        mV.y += mVfix.y;
        mVfix.x = 0;
        mVfix.y = 0;
    }
}

class IndexedSprite extends flash.display.Sprite
{
    import flash.display.*;
    import flash.geom.*;

    private var mPool:BitmapData;
    private var mCellWidth:uint;
    private var mCellHeight:uint;
    private var mCols:uint = 0;

    private var mBmp:Bitmap;
    private var mBuf:BitmapData;
    private var mRc:Rectangle;
    private var mPt:Point = new Point(0, 0);
    function IndexedSprite(pool:BitmapData, cw:uint, ch:uint, cols:uint)
    {
        mPool = pool;
        mCellWidth = cw;
        mCellHeight = ch;
        mCols = cols;

        mBuf = new BitmapData(cw, ch);
        mBmp = new Bitmap(mBuf);
        addChild(mBmp);
        mRc = new Rectangle(0, 0, cw, ch);

        this.index = 0;
    }

    public function set index(i:int):void
    {
        mRc.x = (i%mCols) * mCellWidth;
        mRc.y = int(i/mCols) * mCellHeight;
        mBuf.copyPixels(mPool, mRc, mPt);
    }

    public function get pool():BitmapData
    {
        return mPool;
    }
}

class SpritePool extends flash.display.BitmapData
{
    import flash.utils.ByteArray;

    function SpritePool(src:*)
    {
        var ba:ByteArray = B64.decode(src.DATA);
        ba.uncompress();

        var w:int = ba.readUnsignedShort();
        var h:int = ba.readUnsignedShort();

        super(w, h, true, 0);

        var pal_length:int = ba.readUnsignedByte();
        var pal:Array = new Array(pal_length);
        for (var i:int = 0;i < pal_length;i++) {
            pal[i] = ba.readUnsignedInt();
        }

        lock();
        var x:int, y:int, k:uint;
        for (y = 0;y < h;y++) {
            for (x = 0;x < w;x += 2) {
                k = ba.readUnsignedByte();
                setPixel32(x  , y, uint(pal[k&0x0f]));
                setPixel32(x+1, y, uint(pal[(k&0xf0)>>4]));
            }
        }
        unlock();
    }
}

class B64
{
    import flash.utils.ByteArray;
    public static function decode(raw:String):ByteArray
    {
        var res:ByteArray = new ByteArray();
        
        var d1:int, d2:int, d3:int, d4:int;
        var len:int = raw.length;
        for (var i:int = 0;i < len;i += 4) {
            d1 = v(raw.charCodeAt(i  )); d2 = v(raw.charCodeAt(i+1));
            d3 = v(raw.charCodeAt(i+2)); d4 = v(raw.charCodeAt(i+3));
              
            if (d2 == 64) break;
            res.writeByte( (d1 << 2) + ((d2 & 0x30) >> 4) );

            if (d3 == 64) break;
            res.writeByte( ((d2 & 0x0f) << 4) + ((d3 & 0x3c) >> 2) );

            if (d4 == 64) break;
            res.writeByte( ((d3 & 0x03) << 6) + d4 );
        }
        
        res.position = 0;
        return res;
    }

    public static function v(c:int):int {
        return (c==61) ? 64 : (c>=65 && c<=90) ? (c-65) : (c>=97 && c <= 122) ? (c-71) : (c>=48) ? (c+4) : (c==43) ? 62 : 63;
    }
}

class MegaManPatternData
{
    public static const CELL_WIDTH:int  = 64;
    public static const CELL_HEIGHT:int = 64;
    public static const CELL_COLS:int   = 10;
    public static const DATA:String = 
    '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';
}
