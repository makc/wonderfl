package 
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import com.bit101.components.*;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Point;
    
    [SWF(width = "465", height = "465", frameRate = "60")]
    
    /**
     * ...
     * @author okoi
     */
    public class Main extends Sprite 
    {
        public static const WIDTH:int = 465;
        public static const HEIGHT:int = 465;
        
        private var _flower:Flower;
        
        private var _uiWindow:UI;
        
        public static var instance:Main;
        
        private var _back:BitmapData;
        private var _shadow:BitmapData;
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            instance = this;
            
            _back = new BitmapData( WIDTH, HEIGHT, true, 0xffffffff );
            var x:uint, y:uint;
            for ( y = 0; y < HEIGHT; y += 4 ) {
                for ( x = 0; x < WIDTH; x++ ) {
                    _back.setPixel32( x, y, 0xffdcdcdc );
                }
            }
            addChild( new Bitmap( _back ) );
            
            _shadow = new BitmapData( WIDTH, HEIGHT, true, 0 );
            addChild( new Bitmap( _shadow ) );
            
            _flower = new Flower();
            _flower.x = WIDTH / 2;
            _flower.y = HEIGHT / 2;
            addChild( _flower );
                        
            _uiWindow = new UI( _flower );
            addChild( _uiWindow );
            
            addEventListener( Event.ENTER_FRAME, _enterFrameHandler );
        }
        
        private function _enterFrameHandler( e:Event ) : void {
            
            _shadow.lock();
            _shadow.fillRect( _shadow.rect, 0 );
            var mat:Matrix = new Matrix();
            mat.rotate( _flower.rotation * Math.PI / 180 );
            mat.translate( WIDTH / 2, HEIGHT / 2 );
            _shadow.draw( _flower, mat, new ColorTransform(0, 0, 0, 1, 0, 0, 0), null );
            _shadow.applyFilter( _shadow, _shadow.rect, new Point(), new BlurFilter(10,10,3) );
            _shadow.unlock();
        }
        
    }
    
}
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.geom.Point;
    import com.bit101.components.*;
    import flash.display.DisplayObjectContainer;
    import flash.text.TextField;
    import flash.text.TextFormat;

    /**
     * 花クラス
     * @author okoi
     * @see Vector,Petal
     */
    class Flower extends Shape
    {
        private var _petalNum:int = 5;                //    花びらの枚数
        private var _petalList:Vector.<Petal>;
        private var _size:Number = 100;                //    花の大きさの目安
        private var _gamopetalyLength:Number = 20;    //    花びらが合弁する距離
        
        public function Flower() 
        {
        }
        
        public function set petalNum( num:int ) : void { _petalNum = num;    }
        public function set size( val:Number ) : void { _size = val;    }
        public function set gamopetaly( val:Number ) : void { _gamopetalyLength = val;    }
                
        public function create() : void {
            
            var p:int;
            var i:int;
            
            graphics.clear();
            graphics.lineStyle(1, 0);
            graphics.beginFill( 0xffffff );
            
            var first:Point = new Point();    //    最初の位置保存用
            
            //    花びら１枚１枚を描画していく
            for ( p = 0; p < _petalNum; p++ ) {
                
                for ( i = 0; i <= _petalList[p].arcAngle; i++ ) {
                    
                    var rad:Number = (_petalList[p].startAngle + i) * Math.PI / 180;                    
                    var rate:Number = i / _petalList[p].arcAngle;
                            
                    //    SegmentNoを出す
                    var segNo:int = 0;
                    var segEndRate:Number = 0;
                    
                    var segmentList:Vector.<PetalSegment> = _petalList[p].getSegmentList();
                    
                    for ( segNo = 0; segNo < segmentList.length; segNo++ ) {
                        segEndRate = segmentList[segNo].startRate + segmentList[segNo].rate;
                        if ( rate < segEndRate )    break;    
                    }
                    segNo %=  segmentList.length;
                    
                    //    segment内Rate
                    var segStartRate:Number = segmentList[segNo].startRate;
                    var segRate:Number = (rate - segStartRate) / segmentList[segNo].rate;
                    
                    //trace( rate, segNo, segRate );
                    
                    //    現在の角度での中心からの距離計算
                    var r:Number;
                    r = _petalList[p].getSegmentValue( segNo, segRate );
                    
                    //    描画
                    var length:Number = _size * r;
                    if ( length < _gamopetalyLength ) length = _gamopetalyLength;
                    var x:Number = Math.cos( rad ) * length;
                    var y:Number = Math.sin( rad ) * length;
                    
                    if ( p == 0 && i == 0 ) {    graphics.moveTo(x, y);    first.x = x; first.y = y; }
                    else                     graphics.lineTo(x, y);
                }
            }
            
            //    線を最初の地点へ戻す
            graphics.lineTo( first.x, first.y );
            graphics.endFill();
        }
        
        /**
         * 花びら情報を取得する
         * @param    petalNo
         * @return
         */
        public function getPetal( petalNo:int ) : Petal {
            return    _petalList[petalNo];
        }
        
        /**
         * 花びら情報を更新する
         * @param    petalNum
         */
        public function updatePetalList( petalNum:int ) : void {
            _petalNum = petalNum;
            _petalList = new Vector.<Petal>(_petalNum);
            
            //    花びら１枚１枚にパラメータを設定していく
            for ( var p:uint = 0; p < _petalNum; p++ ) {
                _petalList[p] = new Petal();
                _petalList[p].arcAngle = 360 / _petalNum;
                if ( p > 0 ) {
                    _petalList[p].startAngle = _petalList[p - 1].startAngle + _petalList[p].arcAngle;
                }
            }
        }
        
        /**
         * 花びら１枚１枚の切片データを更新する
         * @param    segmentList
         */
        public function updateSegmentList( segmentList:Vector.<PetalSegment> ) : void {
            
            for ( var i:int = 0; i < _petalNum; i++ ) {
                _petalList[i].updateSegmentList( segmentList );
            }
        }
    }

    /**
     * 花びらクラス
     * segmentは花びら１枚をいくつかの切片に分けて個性を出すためのパラメータ
     * @author okoi
     */
    class Petal {
        
        public var startAngle:Number = 0;    //    この花びらの描画を開始する角度
        public var arcAngle:Number;            //    この花びらの円弧角度量
                
        private var _segmentList:Vector.<PetalSegment>;
        
        public function Petal() {            
        }
        
        /**
         * 切片内のRate位置に対する花の中心から花びらの位置までの距離に関するパラメータを取得する処理
         * @param    segNo
         * @param    rate
         * @return
         */
        public function getSegmentValue( segNo:int, rate:Number ) : Number {
                        
            var temp:Number = 0;    //    補正値 segNo>=1 の時前回のsegmentの最後の位置から影響を受ける
            for ( var i:int = 0; i < segNo; i++ ) {
                temp += _segmentList[i].getSegmentValue( 1 );
            }
            return    _segmentList[segNo].getSegmentValue( rate ) + temp;
        }
            
        /**
         * 現在の切片情報を取得する
         * @return
         */
        public function getSegmentList() : Vector.<PetalSegment> {
            return    _segmentList;
        }
                
        public function updateSegmentList( list:Vector.<PetalSegment> ) : void {
            _segmentList = list;
        }
    }

    /**
     * 花びら１枚を更にいくつかの切片で分け、それの制御に使用するクラス
     * 
     */
    class PetalSegment {
        public static const SEGTYPE_SIN_0_90:String = "sin0-90";
        public static const SEGTYPE_SIN_90_180:String = "sin90-180";
        public static const SEGTYPE_SIN_180_270:String = "sin180-270";    
        public static const SEGTYPE_SIN_270_360:String = "sin270-360";
        
        public static const SEGTYPE_SIN_0_90_R:String = "sin0-90-R";
        public static const SEGTYPE_SIN_90_180_R:String = "sin90-180-R";
        public static const SEGTYPE_SIN_180_270_R:String = "sin180-270-R";
        public static const SEGTYPE_SIN_270_360_R:String = "sin270-360-R";
        
        public var type:String;    
        public var rate:Number;
        public var factor:Number = 1;
        public var startRate:Number;
        
        public var label:String = "";
        
        
        public function getSegmentValue( rate:Number ) : Number {
            var length:Number = 0;
            var rad:Number;
            var angle:Number = 90 * rate;
            
            switch(type) {
            case SEGTYPE_SIN_0_90:
                rad = angle * Math.PI / 180;
                length = Math.sin( rad );
                break;
            case SEGTYPE_SIN_90_180:    
                rad = (angle + 90) * Math.PI / 180;
                length = Math.sin( rad );        
                break;
            case SEGTYPE_SIN_180_270:
                rad = (angle + 180) * Math.PI / 180;
                length = Math.sin( rad );
                break;        
            case SEGTYPE_SIN_270_360:
                rad = (angle + 270) * Math.PI / 180;
                length = Math.sin( rad );
                break;            
            case SEGTYPE_SIN_0_90_R:
                rad = angle * Math.PI / 180;
                length = 1 - Math.sin( rad );
                break;
            case SEGTYPE_SIN_90_180_R:
                rad = (angle + 90) * Math.PI / 180;
                length = 1 - Math.sin( rad );
                break;
            case SEGTYPE_SIN_180_270_R:
                rad = (angle + 180) * Math.PI / 180;
                length = -1 * Math.sin( rad ) - 1;        
                break;
            case SEGTYPE_SIN_270_360_R:
                rad = (angle + 270) * Math.PI / 180;
                length = -1 * Math.sin( rad ) - 1;        
                break;
            }
            
            return    length * factor;
        }    
    }

    /**
     * 花の初期情報
     * @author okoi
     */
    class DefaultFlowerData 
    {        
        public static const PRESET_DATA:Object = {
            preset1 : {
                flower_size : 100,
                gamopetalylength : 20,
                petal_num : 5,
                
                segment : {
                    num : 4,
                    rate : [0.25, 0.25, 0.25, 0.25],
                    factor : [1, 0.2, 0.2, 1],
                    type : [PetalSegment.SEGTYPE_SIN_0_90, PetalSegment.SEGTYPE_SIN_90_180_R, PetalSegment.SEGTYPE_SIN_180_270, PetalSegment.SEGTYPE_SIN_270_360_R]
                }
            },
            preset2 : {
                flower_size : 100,
                gamopetalylength : 9.5,
                petal_num : 4,
                
                segment : {
                    num : 4,
                    rate : [0.25, 0.25, 0.25, 0.25],
                    factor : [1, -0.1, -0.1, 1],
                    type : [PetalSegment.SEGTYPE_SIN_0_90, PetalSegment.SEGTYPE_SIN_90_180_R, PetalSegment.SEGTYPE_SIN_180_270, PetalSegment.SEGTYPE_SIN_270_360_R]
                }
            },
            preset3 : {
                flower_size : 110,
                gamopetalylength : 13.2,
                petal_num : 9,
                
                segment : {
                    num : 4,
                    rate : [0.292, 0.212, 0.32, 0.176],
                    factor : [1, 0.2, -0.1, 1],
                    type : [PetalSegment.SEGTYPE_SIN_0_90, PetalSegment.SEGTYPE_SIN_90_180_R, PetalSegment.SEGTYPE_SIN_180_270, PetalSegment.SEGTYPE_SIN_270_360_R]
                }
            },
            preset4 : {
                flower_size : 100,
                gamopetalylength : 20,
                petal_num : 6,
                
                segment : {
                    num : 4,
                    rate : [0.128, 0.224, 0.26, 0.388],
                    factor : [1, 0.5, 0.5, 1],
                    type : [PetalSegment.SEGTYPE_SIN_0_90, PetalSegment.SEGTYPE_SIN_90_180_R, PetalSegment.SEGTYPE_SIN_180_270, PetalSegment.SEGTYPE_SIN_270_360_R]
                }
            },    
            preset5 : {
                flower_size : 100,
                gamopetalylength : 20,
                petal_num : 10,
                
                segment : {
                    num : 4,
                    rate : [0.25, 0.25, 0.25, 0.25],
                    factor : [1, 0, 0, 1],
                    type : [PetalSegment.SEGTYPE_SIN_0_90, PetalSegment.SEGTYPE_SIN_90_180_R, PetalSegment.SEGTYPE_SIN_180_270, PetalSegment.SEGTYPE_SIN_270_360_R]
                }
            },        
            preset6 : {
                flower_size : 140,
                gamopetalylength : 0,
                petal_num : 9,
                
                segment : {
                    num : 4,
                    rate : [0.25, 0.25, 0.25, 0.25],
                    factor : [1, -1, -1, 1],
                    type : [PetalSegment.SEGTYPE_SIN_0_90, PetalSegment.SEGTYPE_SIN_90_180_R, PetalSegment.SEGTYPE_SIN_180_270, PetalSegment.SEGTYPE_SIN_270_360_R]
                }
            },
            preset7 : {
                flower_size : 110,
                gamopetalylength : 10,
                petal_num : 7,
                
                segment : {
                    num : 4,
                    rate : [0.3, 0.2, 0.2, 0.3],
                    factor : [-0.7, 2, 0.6, -0.8],
                    type : [PetalSegment.SEGTYPE_SIN_0_90, PetalSegment.SEGTYPE_SIN_90_180_R, PetalSegment.SEGTYPE_SIN_180_270, PetalSegment.SEGTYPE_SIN_270_360_R]
                }
            },
            preset8 : {
                flower_size : 100,
                gamopetalylength : 15,
                petal_num : 5,
                
                segment : {
                    num : 4,
                    rate : [0.2, 0.3, 0.3, 0.2],
                    factor : [1, 1, 1, 1],
                    type : [PetalSegment.SEGTYPE_SIN_0_90, PetalSegment.SEGTYPE_SIN_90_180_R, PetalSegment.SEGTYPE_SIN_180_270, PetalSegment.SEGTYPE_SIN_270_360_R]
                }
            }                        
        };
                
        public static function getSegmentDataList( presetName:String ) : Vector.<PetalSegment> {
            var presetData:Object = PRESET_DATA[presetName];
            
            var list:Vector.<PetalSegment> = new Vector.<PetalSegment>(presetData.segment.num);
            
            for ( var i:int = 0; i < presetData.segment.num; i++ ) {
                var segment:PetalSegment = new PetalSegment();
                segment.label = "segment" + (i+1);
                segment.type = presetData.segment.type[i];
                segment.rate = presetData.segment.rate[i];
                segment.factor = presetData.segment.factor[i];
                segment.startRate = 0;
                if ( i > 0 ) {
                    segment.startRate = list[i - 1].startRate + list[i - 1].rate;
                }
                list[i] = segment;
                
            }
            return    list;
        }
    }

    /**
     * ...
     * @author okoi
     */
    class FlowerUpdateEvent extends Event
    {
        public static const UPDATE:String = "update";
        
        public function FlowerUpdateEvent( type:String = "") 
        {
            super( type );
        }
        
    }



    /**
     * 花の大きさの目安
     * 花びらの枚数
     * 花びら同士の合弁までの距離
     * 
     * 花びら
     *     切片数
     * 　各切片の割合
     * 　各切片のタイプ
     * 　各切片の係数
     * 
     * @author okoi
     */
    class UI extends Window
    {
        private var _flowerData:Flower;
        public function get flowerdata():Flower { return    _flowerData;    }
        
        //    花の大きさの目安
        private var _flowerSizeSlider:HUISlider;
        
        //    花びらが合弁するまでの距離
        private var _gamopetalySlider:HUISlider;
        
        //    花びら枚数設定カウンター
        private var _petalStepper:NumericStepper;
        private var _petalStepperLabel:Label;
        
        
        //    切片情報設定Window
        private var _segmentDataWindow:SegmentDataUI;
        
        private var _rotation:CheckBox;
        
        //    PreSetボタン
        private var _btn_preset1:PushButton;
        private var _btn_preset2:PushButton;
        private var _btn_preset3:PushButton;
        private var _btn_preset4:PushButton;
        private var _btn_preset5:PushButton;
        private var _btn_preset6:PushButton;
        private var _btn_preset7:PushButton;
        private var _btn_preset8:PushButton;
        
        public function UI( flower:Flower ) 
        {    
            initStyle();
            
            _flowerData = flower;
            
            this.hasMinimizeButton = true;
            title = "FlowerMaker";
            width = Main.WIDTH;
            height = Main.HEIGHT;
            draggable = false;
            alpha = 0.9;
            
            
            _petalStepperLabel = new Label( this.content, 5, 10, "PetalNum" );
            _petalStepper = new NumericStepper( this.content, _petalStepperLabel.width + 10, 10, function( e:Event ) : void {
                updateFlower();
            });
            //_petalStepper.value = DefaultFlowerData.PETAL_NUM;
            _petalStepper.minimum = 1;
            
            //    花びらの大きさの目安
            _flowerSizeSlider = new HUISlider( this.content, 5, 30, "FlowerSize", function( e:Event ) : void {
                
                updateFlower();
            });
            //_flowerSizeSlider.value = DefaultFlowerData.FLOWER_SIZE;
            _flowerSizeSlider.minimum = 30;
            _flowerSizeSlider.maximum = 200;
            
            //    花びらが合弁するまでの距離
            _gamopetalySlider = new HUISlider( this.content, 5, 50, "Gamopetaly", function( e:Event ) : void {
                updateFlower();
            });
            //_gamopetalySlider.value = DefaultFlowerData.GAMOPETALYLENGTH;
            _gamopetalySlider.minimum = 0;
            _gamopetalySlider.maximum = 200;
            
            
            _rotation = new CheckBox( this.content, 5, 75, "rotation" );
            
            //    切片情報UI
            _segmentDataWindow = new SegmentDataUI( this, 5, 100, DefaultFlowerData.getSegmentDataList("preset1") );
            _segmentDataWindow.width = this.width - 10;
            _segmentDataWindow.height = 250;
            
            //    Presetボタン設定
            _btn_preset1 = new PushButton( this.content, 5, 370, "preset1", _pushPresetButton );        
            _btn_preset2 = new PushButton( this.content, 105, 370, "preset2", _pushPresetButton );        
            _btn_preset3 = new PushButton( this.content, 205, 370, "preset3", _pushPresetButton );        
            _btn_preset4 = new PushButton( this.content, 305, 370, "preset4", _pushPresetButton );        
            _btn_preset5 = new PushButton( this.content, 5, 390, "preset5", _pushPresetButton );        
            _btn_preset6 = new PushButton( this.content, 105, 390, "preset6", _pushPresetButton );        
            _btn_preset7 = new PushButton( this.content, 205, 390, "preset7", _pushPresetButton );        
            _btn_preset8 = new PushButton( this.content, 305, 390, "preset8", _pushPresetButton );                    
            
            //    初期データから花を生成
            changePreset( "preset1" );
            updateFlower();
            
            addEventListener( FlowerUpdateEvent.UPDATE, updateFlower );
            addEventListener( Event.ENTER_FRAME, _enterFrameHandler );
        }
        
        /**
         * 花を現在設定されているデータで再構成して表示する
         */
        public function updateFlower( e:FlowerUpdateEvent = null ) : void {

            _flowerData.size = _flowerSizeSlider.value;
            _flowerData.gamopetaly = _gamopetalySlider.value;
            _flowerData.updatePetalList( _petalStepper.value );
            _flowerData.updateSegmentList( _segmentDataWindow.getSegmentList() );
            _flowerData.create();
        }
        
        
        private function _enterFrameHandler( e:Event ) : void {
            
            if ( _rotation.selected ) {
                _flowerData.rotation += 0.5;
            }
        }
        
        private function _pushPresetButton( e:Event ) : void {
            changePreset( (e.currentTarget as PushButton).label );
        }
        
        private function changePreset( presetName:String ) : void {
            
            var presetData:Object = DefaultFlowerData.PRESET_DATA[presetName];
            
            _petalStepper.value = presetData.petal_num;
            _flowerSizeSlider.value = presetData.flower_size;
            _gamopetalySlider.value = presetData.gamopetalylength;
            
            var segmentDataList:Vector.<PetalSegment> = DefaultFlowerData.getSegmentDataList( presetName );
            _segmentDataWindow.resetSegmentDataList( segmentDataList );
            
            updateFlower( null );
        }
        
        public function initStyle() : void {
            
            Style.BACKGROUND = 0x444444;
            Style.BUTTON_FACE = 0x666666;
            Style.INPUT_TEXT = 0xBBBBBB;
            Style.LABEL_TEXT = 0xCCCCCC;
            Style.DROPSHADOW = 0x000000;
            Style.PANEL = 0x666666;
            Style.PROGRESS_BAR = 0x666666;
            
            
        }
    }


    /**
     * ...
     * @author okoi
     */
    class SegmentDataUI extends Window
    {
        private var _selectSegNo:int = -1;
        
        //    切片リスト
        private var _listTitle:Label;
        private var _list:MyList;
        
        //    係数スライダー
        private var _factorSlider:HUISlider;
    
        //    切片割合スライダー    
        private var _rateMultiSlider:MultiRangeSlider;
        
        public function SegmentDataUI( parent:UI = null, xpos:Number = 0, ypos:Number = 0, segmentList:Vector.<PetalSegment> = null ) {
            super( parent.content, xpos, ypos );
        
            this.title = "SegmentData";
            this.draggable = false;
            this.shadow = false;
            
            var i:int;
                    
            //    切片選択用のリスト
            _listTitle = new Label( this.content, 5, 10, "SegmentList" );
            _list = new MyList( this.content, 5, 30 );    
            trace("aaa");
            //    切片が選択された時に呼び出される
            _list.addEventListener( Event.SELECT, function(e:Event) : void {
                var list:List = e.currentTarget as List;
                _selectSegNo = list.selectedIndex;
                var segment:PetalSegment = _list.items[_selectSegNo];
                _factorSlider.value = segment.factor;
                
            });
            
            _factorSlider = new HUISlider( this.content, 130, 25, "factor", function(e:Event) : void {
                if ( _selectSegNo == -1 )    return;
                if ( _selectSegNo >= _list.items.length )    return;
                
                var segment:PetalSegment = _list.items[_selectSegNo];
                segment.factor = _factorSlider.value;
                
                parent.dispatchEvent( new FlowerUpdateEvent( FlowerUpdateEvent.UPDATE ) );
            });
            _factorSlider.minimum = -2;
            _factorSlider.maximum = 2;
            
            _rateMultiSlider = new MultiRangeSlider( this.content, 10, 150, "SegmentRate", function() : void {
                //    切片の割合の更新を行う
                var itemlist:Array/*PetalSegment*/ = _list.items;
                var itemnum:uint = itemlist.length;
                var i:uint;
                for ( i = 0; i < itemnum; i++ ) {
                    itemlist[i].rate = _rateMultiSlider.getRate( i );
                }
                
                parent.dispatchEvent( new FlowerUpdateEvent( FlowerUpdateEvent.UPDATE ) );
            });
        
            resetSegmentDataList( segmentList );
        }
        
        public function getSegmentList() : Vector.<PetalSegment> {
            
            var itemlist:Array = _list.items;
            var itemnum:uint = itemlist.length;
            var ret:Vector.<PetalSegment> = new Vector.<PetalSegment>(itemnum);
            var i:uint;
            for ( i = 0; i < itemnum; i++ ) {
                ret[i] = itemlist[i];
            }
            return    ret;
        }

        public function resetSegmentDataList( list:Vector.<PetalSegment> ) : void {
            
            var i:uint;
            
            //    セグメントの初期化
            _list.removeAll();
            for ( i = 0; i < list.length; i++ ) {
                _list.addItem(list[i]); 
            }
            _factorSlider.value = 0;
            
            _rateMultiSlider.reset();
            for ( i = 0; i < list.length; i++ ) {
                _rateMultiSlider.addItem( list[i].startRate + list[i].rate ); 
            }
        }
    }


    /**
     * リストの色替えのためだけのクラス
     * @author okoi
     */
    class MyList extends com.bit101.components.List
    {
        
        public function MyList(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, items:Array=null) 
        {
            super(parent, xpos, ypos, items);
            
            _defaultColor = 0x444444;
            _alternateColor = 0x393939;
            _selectedColor = 0x666666;
            _rolloverColor = 0x777777;
        }
        override protected function makeListItems():void
        {
            while(_itemHolder.numChildren > 0) _itemHolder.removeChildAt(0);

            var numItems:int = Math.ceil(_height / _listItemHeight);
            for(var i:int = 0; i < numItems; i++)
            {
                trace(i);
                var item:ListItem = new _listItemClass(_itemHolder, 0, i * _listItemHeight);
                item.setSize(width, _listItemHeight);
                item.defaultColor = 0x444444;

                item.selectedColor = 0x666666;
                item.rolloverColor = 0x777777;
                item.addEventListener(MouseEvent.CLICK, onSelect);
            }
        }
    }


    /**
     * 
     * @author okoi
     */
    class MultiRangeSlider extends Component
    {
        protected static const SLIDE_AREA_X:int = 90;
        protected static const SLIDE_WIDTH:int = 250;

        
        protected var _minLabel:Label;
        protected var _maxLabel:Label;
        
        private var _label:Label;
        protected var _back:Sprite;
        protected var _sliderSprite:Sprite;
        
        private var _itemList:Vector.<MultiRangeSliderItem>;
        
        private var _drag:Boolean = false;
        private var _selectItem:MultiRangeSliderItem = null;
        
        private var _updateCallbackFunc:Function = null;
        
        public function MultiRangeSlider( parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, label:String = "", updateCallback:Function = null )
        {
            super( parent, xpos, ypos );            
            
            _updateCallbackFunc = updateCallback;
            
            _label = new Label( this, 0, 0, label );
            
            _minLabel = new Label( this, 75, 0, "0" );
            _maxLabel = new Label( this, SLIDE_AREA_X + SLIDE_WIDTH + 10, 0, "1" );
            
            _back = new Sprite();
            _back.filters = [getShadow(2, true)];
            addChild( _back );
            drawBack();
            
            _sliderSprite = new Sprite();
            _sliderSprite.x = SLIDE_AREA_X;
            _sliderSprite.y = 5;
            addChild( _sliderSprite );
            
            _itemList = new Vector.<MultiRangeSliderItem>();
            
            addEventListener( Event.ENTER_FRAME, _enterFrameHandler );
            Main.instance.stage.addEventListener( MouseEvent.MOUSE_UP, _sliderSpriteMouseUpHandler );
        }
        
        public function reset() : void {
            var i:uint = 0;
            
            for ( i = 0; i < _itemList.length; i++ ) {
                _sliderSprite.removeChild( _itemList[i] );
                _itemList[i] = null;
            }
            _itemList = new Vector.<MultiRangeSliderItem>();
        }
        
        
        /**
         * スライダーの背景部分描画
         */
        protected function drawBack() : void {
            
            _back.graphics.clear();
            _back.graphics.beginFill(Style.BACKGROUND);
            _back.graphics.drawRect(SLIDE_AREA_X, 5, SLIDE_WIDTH, 10);
            _back.graphics.endFill();
            
        }
        
        public function addItem( value:Number ) : void {
            var item:MultiRangeSliderItem = new MultiRangeSliderItem( _sliderSprite, this );
            item.id = _itemList.length;
            item.x = SLIDE_WIDTH * value;
            item.y = 0;
            
            var prevValue:Number = 0;
            
            if ( item.id > 0 ) {    
                prevValue = _itemList[ item.id - 1 ].value;
            }
            item.value = value;
            item.rate = value - prevValue;
            item.reflectionDisplay();
            
            _itemList.push( item );
                
        }
        
        public function selectSlide( item:MultiRangeSliderItem ) : void {
        
            trace("selectSlide", item.id );
            if ( item.id == _itemList.length - 1 )    return;
            _selectItem = item;
            _onDrag();
        }
        
        public function deSelectSlide( e:MouseEvent ) : void {
            
            
        }
        
        private function _sliderSpriteMouseUpHandler( e:MouseEvent ) : void {
            _offDrag();
        }
        
        private function _onDrag() : void {
            _drag = true;
        }
        private function _offDrag() : void {
            _drag = false;
        }
        
        private function _enterFrameHandler( e:Event ) : void {
            
            if ( _drag && _selectItem ) {
                var mx:Number = _sliderSprite.mouseX;
                var bx:Number = _selectItem.x;
                var id:uint = _selectItem.id;
                _selectItem.x = mx;
                
                var left:Number = (SLIDE_WIDTH * 0.1);
                var right:Number = SLIDE_WIDTH;
                if ( id > 0 ) {
                    left = _itemList[id - 1].x + (SLIDE_WIDTH * 0.1);
                }
                if ( id < _itemList.length - 1 ) {
                    right = _itemList[id + 1].x - (SLIDE_WIDTH * 0.1);
                }
                if ( _selectItem.x < left )    _selectItem.x = left;                
                else if ( _selectItem.x > right ) _selectItem.x = right;
                
                
                //_selectItem.setValue( _selectItem.x / SLIDE_WIDTH, 0, true );
                
                updateSlideItemData();
            }
        }
        
        public function updateSlideItemData() : void {
            var num:uint = _itemList.length;
            var i:uint;
            
            var value:Number = 0;
            for ( i = 0; i < num; i++ ) {
                _itemList[i].value = _itemList[i].x / SLIDE_WIDTH;
                _itemList[i].rate = _itemList[i].value - value;
                _itemList[i].reflectionDisplay();
                value = _itemList[i].value;
            }
            
            if( _updateCallbackFunc != null )    _updateCallbackFunc();
        }
        
        public function getValue( id:uint ) : Number {
            return    _itemList[id].value;
        }
        public function getRate( id:uint ) : Number {
            return    _itemList[id].rate;
        }
    }



    class MultiRangeSliderItem extends Component{
        
        private var _indexLabel:Label;
        private var _valuelabel:TextField;
        private var _slide:Sprite;
        private var _line:Shape;
        
        private var _id:uint;
        private var _value:Number;    //    スライダーに対しての絶対位置(0～1)
        private var _rate:Number;    //    直前のポイントからこのポイントまでがスライダー全体に対してどれくらいの割合かどうかの値(0～1)
        
        private var _slider:MultiRangeSlider;
        
        public function MultiRangeSliderItem( parent:DisplayObjectContainer = null, slider:MultiRangeSlider = null, id:uint = 0, rate:Number = 0 ) {
            super( parent );
            _slider = slider;
            _id = id;
            _rate = rate;
            
            _line = new Shape();
            addChild( _line );
            _drawLine();        
            
            _valuelabel = new TextField();
            _valuelabel.y = -30;
            _valuelabel.embedFonts = Style.embedFonts;
            _valuelabel.selectable = false;
            _valuelabel.mouseEnabled = false;
            _valuelabel.height = 30;
            var tf:TextFormat = new TextFormat(Style.fontName, Style.fontSize, Style.LABEL_TEXT);
            tf.align = "center";
            _valuelabel.defaultTextFormat = tf;
            addChild( _valuelabel );
            
            _slide = new Sprite();
            _slide.filters = [getShadow(2, true)];
            _slide.buttonMode = true;
            addChild( _slide );
            _drawSlide();
                    
            addEventListener( Event.ADDED_TO_STAGE, _addToStageHandler );
            addEventListener( Event.REMOVED_FROM_STAGE, _removeFromStageHandler );
            _slide.addEventListener( MouseEvent.MOUSE_DOWN, MouseDownHandler );
        }
        
        private function _addToStageHandler( e:Event ) : void {
            removeEventListener( Event.ADDED_TO_STAGE, _addToStageHandler );
            
            reflectionDisplay();
        }
        
        private function _removeFromStageHandler( e:Event ) : void {
            removeEventListener( Event.REMOVED_FROM_STAGE, _removeFromStageHandler );
            _slide.removeEventListener( MouseEvent.MOUSE_DOWN, MouseDownHandler );
        }
        
        private function _drawSlide() : void {
            
            _slide.graphics.clear();
            _slide.graphics.beginFill( 0xDCDCDC );
            _slide.graphics.moveTo( 0, 10 );
            _slide.graphics.lineTo( 5, 15 );
            _slide.graphics.lineTo( 5,  25 );
            _slide.graphics.lineTo( -5, 25 );
            _slide.graphics.lineTo( -5, 15 );
            _slide.graphics.endFill();
        }
        
        private function _drawLine() : void {
            _line.graphics.clear();
            _line.graphics.lineStyle( 1, 0xFF0000 );
            _line.graphics.moveTo( 0, 0 );
            _line.graphics.lineTo( 0, 10 );
        }
        
        private function MouseDownHandler( e:MouseEvent ) : void {
            e.stopPropagation();
            _slider.selectSlide( this );
        }
        
        public function setValue( value:Number, rate:Number, reflect:Boolean = false ) : void {
            _value = value;
            _rate = rate;
                        
            if ( reflect )    reflectionDisplay();
        }
        
        public function reflectionDisplay() : void {
            _valuelabel.text = (Math.round(_value * 1000) / 1000) + "\n" + "(" + (Math.round(_rate * 1000) / 1000) + ")";
            _valuelabel.x = -_valuelabel.width / 2;    
        }
        
        public function get id() : uint { return    _id;    }
        public function set id( val:uint ) : void { _id = val;    }
        public function get rate() : Number { return    _rate;    }
        public function set rate( rt:Number ) : void { _rate = rt;    }
        public function get value() : Number { return    _value;    }
        public function set value( val:Number ) : void { _value = val;    }
        
    }
