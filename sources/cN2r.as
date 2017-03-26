// forked from Event's Simple MediaRSS Viewer
/*
　「Flickr × 弾幕」

　・MediaRSSに慣れるための習作
　・弾幕の色で画像を再現
　　・今はFlickrから「flower」タグで画像を取得している
　　・写真よりもイラスト系の方が再現性が高かったかも

　・アルゴリズムとしては、N秒後の弾の位置のピクセルを弾の色にして使ってるだけ
　
　・クリックしてる間はスロー化（デバッグ用）
*/


package
{
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.*;
    import flash.text.*;

    public class Flickr_x_Bullet extends Sprite
    {
        //==Const==

        //画像の元
/*
        [Embed(source='Foo.png')]
         private static var Bitmap_Image: Class;
        static public var m_Bitmap_Image:Bitmap = new Bitmap_Image();
/*/
        static public const FEED:String = "http://api.flickr.com/services/feeds/photos_public.gne?tags=flower&format=rss_200";
        static public const MEDIA:Namespace = new Namespace("http://search.yahoo.com/mrss/");

        static public var m_Bitmap_Image_List:Array;
        static public var m_Bitmap_Image_Iter:int = 0;
//*/
        //一回あたりの弾の数
        static public const BULLET_NUM:int = 32;//16;

        //弾の発射方向は何秒で一周するか
        static public const BULLET_ROT_TIME:Number = 2.0;

        //弾速
        static public const BULLET_VEL:Number = 70.0;

        //弾の発射間隔
        static public const INTERVAL:Number = 0.1;


        //何秒ごとに「絵」が表示されるか
        static public const TARGET_TIME:Number = 4.0;


        //==Var==

        //弾発射用のタイマー
        public var m_BulletTimer:Number = 0.0;

        //弾の発射方向（の起点）
        public var m_InitTheta:Number = 0.0;


        //あと何秒後に絵が完成するか
        public var m_TargetRestTimer:Number = TARGET_TIME;


        //弾用のレイヤー
        public var m_Layer_Bullet:Sprite = new Sprite();

        //表示画像
        public var m_BitmapData_View:BitmapData;

        //前回からの（擬似）経過時間
        public var m_DeltaTime:Number = 1/24.0;


        //==Function==

        //Init
        public function Flickr_x_Bullet(){
/*
            //Init Later
            addEventListener(Event.ADDED_TO_STAGE, Init);
/*/
            //Load
            var ldr:URLLoader = new URLLoader;
            ldr.addEventListener(Event.COMPLETE, function _load(e:Event):void {
                //Load Once
                ldr.removeEventListener(Event.COMPLETE, _load);

                //画像のURLをリスト化
                var img_url_list:Array = XML(ldr.data)..MEDIA::thumbnail.@url.toXMLString().split('\n');

                //画像のロード先の初期化
                m_Bitmap_Image_List = new Array(img_url_list.length);
                for(var i:int = 0; i < m_Bitmap_Image_List.length; i++){
                    m_Bitmap_Image_List[i] = new Bitmap();
                }

                //画像のロードを開始
                   var count:int = 0;
                img_url_list.forEach(function(img_url:*, index:int, arr:Array):void{
                    count++;

                    var ldr_img:Loader = new Loader;
                    ldr_img.load(new URLRequest(img_url), new LoaderContext(true));
                    ldr_img.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                        m_Bitmap_Image_List[index].bitmapData = new BitmapData(ldr_img.content.width, ldr_img.content.height, false, 0x000000);
                        m_Bitmap_Image_List[index].bitmapData.draw(ldr_img.content);

                        //全てのロードが完了したら初期化開始
                        count--;
                        if(count <= 0){
                            Init();
                        }
                    });
//                        addChild(ldr_img);
                });
            });
            ldr.load(new URLRequest(FEED));
//*/
            //キャプチャのタイミング指定
            Wonderfl.capture_delay( 10 );
        }
        public function Init(e:Event=null):void{
            //Init Once
            {
                removeEventListener(Event.ADDED_TO_STAGE, Init);
            }

            //表示画像
            {
                m_BitmapData_View = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000);
                var bitmap_view:Bitmap = new Bitmap(m_BitmapData_View);

                //弾幕用にちょっとブラーをかける
                //bitmap_view.filters = [new BlurFilter(2,2)];//薄くなってしまう

                addChild(bitmap_view);
            }

            //レイヤー
            {
                addChild(m_Layer_Bullet);
            }

            //Update
            {
                addEventListener(Event.ENTER_FRAME, Update);
            }

            //Debug
            {
                //クリックしてる間はスロー
                stage.addEventListener(
                    MouseEvent.MOUSE_DOWN,
                    function(event:MouseEvent):void{
                        m_DeltaTime = 1/24.0 * 0.1;
                    }
                );
                stage.addEventListener(
                    MouseEvent.MOUSE_UP,
                    function(event:MouseEvent):void{
                        m_DeltaTime = 1/24.0;
                    }
                );
            }
        }

        //Update
        public function Update(e:Event = null):void{
            //弾の発射チェック
            Update_Bullet_Shot(m_DeltaTime);

            //弾の移動管理
            Update_Bullet_Move(m_DeltaTime);
        }

        //Update : Bullet : Shot
        public function Update_Bullet_Shot(in_DeltaTime:Number):void{
            var bulletParent:DisplayObjectContainer = m_Layer_Bullet;

            //Pos
            var PosX:int;
            var PosY:int;
            {
                PosX = stage.stageWidth  * 1/2;
                PosY = stage.stageHeight * 1/2;
            }

            //m_TargetRestTimer
            {
                m_TargetRestTimer -= in_DeltaTime;
                if(m_TargetRestTimer < 0){
                    m_TargetRestTimer += TARGET_TIME;

                    m_Bitmap_Image_Iter++;
                    if(m_Bitmap_Image_List.length <= m_Bitmap_Image_Iter){
                        m_Bitmap_Image_Iter = 0;
                    }
                }
            }

            //
            {
                m_BulletTimer -= in_DeltaTime;

                while(m_BulletTimer <= 0){
                    //発射のタイミングから過ぎてしまった時間（あとで補正するため）
                    var InitTime:Number;
                    {
                        InitTime = -m_BulletTimer;
                    }

                    //次までのタイマーをセット
                    {
                        m_BulletTimer += INTERVAL;
                    }

                    //発射の起点を回転
                    {
                        m_InitTheta += INTERVAL / BULLET_ROT_TIME;
                    }

                    //円状に弾を発射
                    for(var i:int = 0; i < BULLET_NUM; i++){
                        //発射方向
                        var theta:Number;
                        {
                            theta = m_InitTheta + 2*Math.PI * i/BULLET_NUM;
                        }

                        //さらに対称に生成
                        for(var j:int = 0; j < 2; j++){
                            //Param
                            var VX:Number;
                            var VY:Number;
                            var color:uint;
                            {
                                //Vel
                                {
                                    VX = BULLET_VEL * Math.sin(theta);
                                    VY = BULLET_VEL * Math.cos(theta);
                                }

                                //Color
                                {
                                    var TrgX:int = PosX + VX * m_TargetRestTimer;
                                    var TrgY:int = PosY + VY * m_TargetRestTimer;

                                    color = GetColor(TrgX, TrgY);
                                }
                            }

                            //弾の生成
                            var bullet:Bullet;
                            {
                                bullet = new Bullet(PosX, PosY, VX, VY, color);
                            }

                            //弾の登録
                            {
                                bulletParent.addChild(bullet);
                            }

                            //補正
                            {
                                //過ぎた時間の分だけ、弾を進めておく
                                bullet.m_Timer = InitTime;
                            }

                            theta = -theta;//対称
                        }
                    }
                }
            }
        }

        //Update : Bullet : Move
        public function Update_Bullet_Move(in_DeltaTime:Number):void{
            var bulletParent:DisplayObjectContainer = m_Layer_Bullet;

            const w:int = 5;
            const h:int = 5;
            const OffsetX:int = (w-1)/2;
            const OffsetY:int = (h-1)/2;
            var rect:Rectangle = new Rectangle(0,0, w,h);

            //Draw Init
            {
                m_BitmapData_View.lock();
/*
                //黒でクリア
                m_BitmapData_View.fillRect(m_BitmapData_View.rect, 0x000000);
/*/
                //前回のをぼかしつつ採用
                //const filter:BlurFilter = new BlurFilter(8,8);
                const ratio:Number = 0.6;
                const filter:ColorMatrixFilter = new ColorMatrixFilter([ratio,0,0,0,0, 0,ratio,0,0,0, 0,0,ratio,0,0, 0,0,0,1,0]);
                const POS_ZERO:Point = new Point(0,0);
                m_BitmapData_View.applyFilter(m_BitmapData_View, m_BitmapData_View.rect, POS_ZERO, filter);
//*/
            }

            //Move & Draw
            for(var i:int = 0; i < bulletParent.numChildren; i++){
                var bullet:Bullet = bulletParent.getChildAt(i) as Bullet;

                //Time
                bullet.m_Timer += in_DeltaTime;

                //Pos
                bullet.x = bullet.m_SrcX + bullet.m_VX * bullet.m_Timer;
                bullet.y = bullet.m_SrcY + bullet.m_VY * bullet.m_Timer;

                //Check : Range
                var IsRangeOut:Boolean =
                    (bullet.x < 0) ||
                    (bullet.x > stage.stageWidth) ||
                    (bullet.y < 0) ||
                    (bullet.y > stage.stageHeight);
                if(IsRangeOut){
                    bulletParent.removeChildAt(i--);
                    continue;
                }

                //Draw
/*
                //ドット
                m_BitmapData_View.setPixel(bullet.x, bullet.y, bullet.m_Color);
//*/
/*
                //十字
                m_BitmapData_View.setPixel(bullet.x, bullet.y, bullet.m_Color);
                m_BitmapData_View.setPixel(bullet.x-1, bullet.y+0, bullet.m_Color);
                m_BitmapData_View.setPixel(bullet.x+1, bullet.y+0, bullet.m_Color);
                m_BitmapData_View.setPixel(bullet.x+0, bullet.y-1, bullet.m_Color);
                m_BitmapData_View.setPixel(bullet.x+0, bullet.y+1, bullet.m_Color);
//*/
/*
                //四角
                rect.x = bullet.x - OffsetX;
                rect.y = bullet.y - OffsetY;
                m_BitmapData_View.fillRect(rect, bullet.m_Color);
//*/
//*
                //擬似角丸四角
                rect.x = bullet.x - OffsetX + 1;
                rect.y = bullet.y - OffsetY;
                rect.width = w-2;
                rect.height = h;
                m_BitmapData_View.fillRect(rect, bullet.m_Color);

                rect.x = bullet.x - OffsetX;
                rect.y = bullet.y - OffsetY + 1;
                rect.width = w;
                rect.height = h-2;
                m_BitmapData_View.fillRect(rect, bullet.m_Color);
//*/
            }

            //Draw Fin
            {
                m_BitmapData_View.unlock();
            }
        }


        //#Image

        //Bullet Color
        public function  GetColor(in_X:int, in_Y:int):uint{
/*
            var TrgX:int = in_X * m_Bitmap_Image.width/stage.stageWidth;
            var TrgY:int = in_Y * m_Bitmap_Image.height/stage.stageHeight;
            return m_Bitmap_Image.bitmapData.getPixel(TrgX, TrgY);
/*/
            var bmp:Bitmap = m_Bitmap_Image_List[m_Bitmap_Image_Iter];
            var TrgX:int = in_X * bmp.width/stage.stageWidth;
            var TrgY:int = in_Y * bmp.height/stage.stageHeight;
            return bmp.bitmapData.getPixel(TrgX, TrgY);
//*/
        }
    }
}


//Local Class

import flash.display.*;

//#Bullet
class Bullet extends Shape
{
    //==Const==

    //弾の大きさ
    static public const RAD:int = 2;


    //==Var==

    //始点
    public var m_SrcX:int;
    public var m_SrcY:int;

    //速度
    public var m_VX:Number;
    public var m_VY:Number;

    //タイマー
    public var m_Timer:Number = 0.0;

    //色
    public var m_Color:uint;


    //==Func==

    //Init
    public function Bullet(in_X:int, in_Y:int, in_VX:Number, in_VY:Number, in_Color:uint){
        //Param
        {
            m_SrcX = in_X;
            m_SrcY = in_Y;
            m_VX = in_VX;
            m_VY = in_VY;
            m_Color = in_Color;
        }

/*
        //Graphic
        {
            var g:Graphics = this.graphics;

            g.lineStyle(0, 0x000000, 0.0);
            g.beginFill(in_Color, 1.0);
            g.drawCircle(0,0, RAD);
            g.endFill();
        }
        //→重いのでSetPixelとかで描くことにした
//*/
    }
}

