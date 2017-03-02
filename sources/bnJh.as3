package {

// ----------------------------------------------------------------------------------------------------
// インポート
//
    import com.adobe.utils.AGALMiniAssembler;
    import com.adobe.utils.PerspectiveMatrix3D;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Shape;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display.TriangleCulling;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DRenderMode;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.external.ExternalInterface;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.getTimer;
    
    import net.hires.debug.Stats;

    [SWF(width="465", height="465", backgroundColor="0xffffff")]
    public class Stage3DGraphicsTest extends Sprite {

// ----------------------------------------------------------------------------------------------------
// メイン処理
//
        private const IMAGE_URL:String = "http://global.yuichiroharai.com/img/GoldenRectangle.png";
        private const FPS:uint = 60; // フレームレート
        private const CANVAS_MINIMUM_SIZE:uint = 465;
        private var _canvasSize:uint;
        private var _bmpd:BitmapData;
        private var _sphericalShader:SphericalShader;
        
        // Stage3D
        private var _stage3DGPU:Stage3D;
        private var _context3DGPU:Context3D;
        private var _stage3DSoftware:Stage3D;
        private var _context3DSoftware:Context3D;
        
        // Graphics
        private var _s:Sprite;
        private var _g:Graphics;
        
        //private var _screenShot:Bitmap;

        public function Stage3DGraphicsTest() {
            Wonderfl.disable_capture();
            //addChild(_screenShot = new Bitmap());
            
            stage.frameRate = FPS;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            _initStats();
            
            // 埋め込みフォントを取得
            FontLoader.loadFont(complete1);
            
            function complete1():void {
                var loader:Loader;
                loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete2);
                loader.load(new URLRequest(IMAGE_URL), new LoaderContext(true));
            }
            

            function complete2(e:Event):void {
                _bmpd = Bitmap(LoaderInfo(e.target).content).bitmapData;

                stage.addEventListener(Event.RESIZE, _onResize);
                stage.addEventListener(Event.FULLSCREEN, _onResize);
                _onResize();
                _initMessage();

                // GPU
                _stage3DGPU = stage.stage3Ds[0];
                _stage3DGPU.addEventListener(Event.CONTEXT3D_CREATE, context3dCreateGPU);
                _stage3DGPU.addEventListener(ErrorEvent.ERROR, error);
                _stage3DGPU.requestContext3D(Context3DRenderMode.AUTO);
            }
            function context3dCreateGPU():void {
                _context3DGPU = _stage3DGPU.context3D;

                // SOFTWARE
                _stage3DSoftware = stage.stage3Ds[1];
                _stage3DSoftware.addEventListener(Event.CONTEXT3D_CREATE, context3dCreateSoftware);
                _stage3DSoftware.addEventListener(ErrorEvent.ERROR, error);
                _stage3DSoftware.requestContext3D(Context3DRenderMode.SOFTWARE);
            }
            
            function context3dCreateSoftware():void {
                _context3DSoftware = _stage3DSoftware.context3D;
                
                _initDraw();
                _initOption();
            }
            
            function error():void {
                _changeMessage("STAGE3D IS NOT ENABLED ON THIS PC...", false);
                _textFieldMessage.visible = true;
            }
        }

        /**
         * ステージリサイズ時の処理
         */
        private function _onResize(e:Event=null):void {
            _canvasSize = (stage.stageWidth > stage.stageHeight) ? int(stage.stageHeight/2)*2 : int(stage.stageWidth/2)*2;
            if (_canvasSize < CANVAS_MINIMUM_SIZE) _canvasSize = CANVAS_MINIMUM_SIZE;
            _resizeStage3D();
            _resizeGraphics();
            _moveOption();
            _moveMessage();
            if (_textMethod != null) _textMethod.text = _canvasSize.toString();
        }

        
// ----------------------------------------------------------------------------------------------------
// 共通処理
//
        private static const DIV_LIST:Vector.<uint> = Vector.<uint>([2, 4, 8, 16, 32]);
        private var _3DRotationY:Number = 0;
        private var _3DRotationX:Number = 0;
        private var _time:uint;
        private var _drawMethod:String = "gpu"; // gpu=Stage3D(GPU), software=Stage3D, graphics=Graphics
        private var _matrix3D:Matrix3D;
        private var _currentDiv:uint = 2;
        
        private function _initDraw():void {
            // 透視投影変換
            _perspectiveMatrix3D = new PerspectiveMatrix3D();
            _perspectiveMatrix3D.perspectiveFieldOfViewLH(45*Math.PI/180, 1, 0.1, 1000);
            
            _changeDraw();
            initStage3D();
            initGraphics();
            addEventListener(Event.ENTER_FRAME, _onDraw);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, _switchDraw);
            _textFieldMessage.visible = true;
        }
        
        private function _switchDraw(e:Event=null):void {
            if (_drawMethod == "gpu") {
                _drawMethod = "software";
                _stage3DGPU.visible = false;
                _stage3DSoftware.visible = true;
                _s.visible = false;
            } else if (_drawMethod == "software") {
                _drawMethod = "graphics";
                _stage3DGPU.visible = false;
                _stage3DSoftware.visible = false;
                _s.visible = true;
            } else {
                _drawMethod = "gpu";
                _stage3DGPU.visible = true;
                _stage3DSoftware.visible = false;
                _s.visible = false;
            }
            _changeOptionMethod();
        }
        
        private function _changeDraw(e:Event=null):void {
            // 頂点情報
            _sphericalShader = new SphericalShader(1, 60, 60, DIV_LIST[_currentDiv], DIV_LIST[_currentDiv]);
            _sphericalShader.setVertex(0, 0);
            _sphericalShader.setVertex(90, 0);
            _sphericalShader.setVertex(180, 0);
            _sphericalShader.setVertex(270, 0);
            _sphericalShader.setVertex(0, 90);
            _sphericalShader.setVertex(0, -90);
            
            _changeStage3D();
            _changeGraphics();
        }
        
        private function _onDraw(e:Event):void {
            var currentTime:uint;
            
            // 球面全体の回転
            _time = (currentTime = getTimer()) - _time;
            if ((_3DRotationY += 0.12*_time) > 360) _3DRotationY -= 360;
            if ((_3DRotationX += 0.09*_time) > 360) _3DRotationX -= 360;
            _time = currentTime;
            
            // matrix3Dを設定
            _matrix3D = new Matrix3D();
            _matrix3D.appendRotation(_3DRotationY, Vector3D.Y_AXIS);
            _matrix3D.appendRotation(_3DRotationX, Vector3D.X_AXIS);
            _matrix3D.appendTranslation(0, 0, 3);
            _matrix3D.append(_perspectiveMatrix3D);
            if (_drawMethod == "gpu") {
                _drawStage3D();
            } else if (_drawMethod == "software") {
                _drawStage3D();
            } else {
                _matrix3D.appendScale(_canvasSize/2, _canvasSize/2, _canvasSize/2);
                _drawGraphics();
            }        
        }
        
        
// ----------------------------------------------------------------------------------------------------
// Stage3D
//
        private static const AGAL_VERTEX:String = "m44 op, va0, vc0\n" + "mov v0, va1";
        private static const AGAL_FRAGMENT:String = "tex ft1, v0, fs0 <2d,nomip,linear,clamp>\n" + "mov oc, ft1";
        private static const ANTI_ALIAS:uint = 2;

        private var _perspectiveMatrix3D:PerspectiveMatrix3D;
        
        /**
         * Stage3D関連の初期化
         */
        private function initStage3D():void {
            var vertexAssembler:AGALMiniAssembler, fragmentAssembler:AGALMiniAssembler, program3D:Program3D,
                texture:Texture;

            //_context3DGPU.enableErrorChecking = true;
            //_context3DSoftware.enableErrorChecking = true;
            _resizeStage3D();
            _context3DGPU.setDepthTest(true, Context3DCompareMode.LESS);
            _context3DSoftware.setDepthTest(true, Context3DCompareMode.LESS);
            
            // AGAL
            vertexAssembler = new AGALMiniAssembler();
            vertexAssembler.assemble(Context3DProgramType.VERTEX, AGAL_VERTEX);
            fragmentAssembler = new AGALMiniAssembler();
            fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, AGAL_FRAGMENT);
            program3D = _context3DGPU.createProgram();
            program3D.upload(vertexAssembler.agalcode, fragmentAssembler.agalcode);
            _context3DGPU.setProgram(program3D);
            vertexAssembler = new AGALMiniAssembler();
            vertexAssembler.assemble(Context3DProgramType.VERTEX, AGAL_VERTEX);
            fragmentAssembler = new AGALMiniAssembler();
            fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, AGAL_FRAGMENT);
            program3D = _context3DSoftware.createProgram();
            program3D.upload(vertexAssembler.agalcode, fragmentAssembler.agalcode);
            _context3DSoftware.setProgram(program3D);
            
            // テクスチャ
            texture = _context3DGPU.createTexture(_bmpd.width, _bmpd.height, Context3DTextureFormat.BGRA, false);
            texture.uploadFromBitmapData(_bmpd, 0);
            _context3DGPU.setTextureAt(0, texture);
            texture = _context3DSoftware.createTexture(_bmpd.width, _bmpd.height, Context3DTextureFormat.BGRA, false);
            texture.uploadFromBitmapData(_bmpd, 0);
            _context3DSoftware.setTextureAt(0, texture);
            
            _changeStage3D();
        }
        
        private function _changeStage3D():void {
            var vertexBuffer:VertexBuffer3D;
            
            // 頂点リストのアップロード
            vertexBuffer = _context3DGPU.createVertexBuffer(_sphericalShader.vertexList.length/5, 5);
            vertexBuffer.uploadFromVector(_sphericalShader.vertexList, 0, _sphericalShader.vertexList.length/5);
            _context3DGPU.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            _context3DGPU.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
            
            vertexBuffer = _context3DSoftware.createVertexBuffer(_sphericalShader.vertexList.length/5, 5);
            vertexBuffer.uploadFromVector(_sphericalShader.vertexList, 0, _sphericalShader.vertexList.length/5);
            _context3DSoftware.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            _context3DSoftware.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
        }

        private function _resizeStage3D():void {
            if (_context3DGPU == null || _context3DSoftware == null) return;
            _stage3DGPU.x = _stage3DSoftware.x = int((stage.stageWidth - _canvasSize)/2);
            _stage3DGPU.y = _stage3DSoftware.y = int((stage.stageHeight - _canvasSize)/2);
            _context3DGPU.configureBackBuffer(_canvasSize, _canvasSize, ANTI_ALIAS, true);
            _context3DSoftware.configureBackBuffer(_canvasSize, _canvasSize, ANTI_ALIAS, true);
            
            /*if (_screenShot.bitmapData != null) _screenShot.bitmapData.dispose(); 
            _screenShot.bitmapData = new BitmapData(_canvasSize,　_canvasSize,　false, 0);   
            _screenShot.x = _stage3DGPU.x;
            _screenShot.y = _stage3DGPU.y;*/
        }
        
        private function _drawStage3D():void {
            var indexBuffer:IndexBuffer3D;

            if (_drawMethod == "gpu") {
                // Matrix3Dの適用
                _context3DGPU.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix3D, true);
                // インデックスリストのアップロード
                indexBuffer = _context3DGPU.createIndexBuffer(_sphericalShader.indexList.length);
                indexBuffer.uploadFromVector(_sphericalShader.indexList, 0, _sphericalShader.indexList.length);
                // 描画
                _context3DGPU.clear(0.4, 0.6, 0.8);
                _context3DGPU.drawTriangles(indexBuffer, 0, _sphericalShader.indexList.length/3);
                //_context3DGPU.drawToBitmapData(_screenShot.bitmapData);
                _context3DGPU.present();
            } else {
                // Matrix3Dの適用
                _context3DSoftware.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix3D, true);
                // インデックスリストのアップロード
                indexBuffer = _context3DSoftware.createIndexBuffer(_sphericalShader.indexList.length);
                indexBuffer.uploadFromVector(_sphericalShader.indexList, 0, _sphericalShader.indexList.length);
                // 描画
                _context3DSoftware.clear(0.5, 0.7, 0.3);
                _context3DSoftware.drawTriangles(indexBuffer, 0, _sphericalShader.indexList.length/3);
                _context3DSoftware.present();
            }
        }


// ----------------------------------------------------------------------------------------------------
// Graphics
//
        private var _gVertexList:Vector.<Number>;
        private var _gUvList:Vector.<Number>;
        private var _gIndexList:Vector.<int>;
        private var _gBorder:Boolean = false;
        
        /**
         * Graphics関連の初期化
         */
        private function initGraphics():void {
            _s = new Sprite();
            _g = _s.graphics;
            addChildAt(_s, 0);
            _s.addEventListener(MouseEvent.CLICK, _switchGraphicsBorder);
            
            _changeGraphics();
            _resizeGraphics();
        }
        
        private function _changeGraphics():void {
            var i:uint, j:uint, len:uint;
            
            _gVertexList =  new Vector.<Number>();
            _gUvList = new Vector.<Number>();
            len = _sphericalShader.vertexList.length/5;
            for (i=0;i<len;i++) {
                j = i*5;
                _gVertexList.push(_sphericalShader.vertexList[j], _sphericalShader.vertexList[j+1], _sphericalShader.vertexList[j+2]);
                _gUvList.push(_sphericalShader.vertexList[j+3], _sphericalShader.vertexList[j+4]);
            }
            _gIndexList = Vector.<int>(_sphericalShader.indexList);
        }
        
        private function _switchGraphicsBorder(e:Event=null):void {
            _gBorder = !_gBorder;
        }
        
        private function _resizeGraphics():void {
            if (_s == null || _g == null) return;
            _s.x = int(stage.stageWidth/2);
            _s.y = int(stage.stageHeight/2);
        }
        
        private function _drawGraphics():void {
            var i:uint, j:uint, len:uint, v:Vector3D, vertex2DList:Vector.<Number>;

            vertex2DList = new Vector.<Number>();
            len = _gVertexList.length/3;
            for (i=0;i<len;i++) {
                j = i*3;
                v = _matrix3D.transformVector(new Vector3D(_gVertexList[j], _gVertexList[j+1], _gVertexList[j+2], 1));
                vertex2DList.push(v.x/v.w, -v.y/v.w);
            }
            _g.clear();
            _g.beginFill(0xB380B3, 1);
            _g.drawRect(-_canvasSize/2, -_canvasSize/2, _canvasSize, _canvasSize);
            if (_gBorder) _g.lineStyle(1, 0xffcc33, 1);
            _g.beginBitmapFill(_bmpd, null, false, true);
            _g.drawTriangles(vertex2DList, _gIndexList, _gUvList, TriangleCulling.POSITIVE); // 裏面
            _g.drawTriangles(vertex2DList, _gIndexList, _gUvList, TriangleCulling.NEGATIVE); // 表面
            _g.endFill();
        }

        
// ----------------------------------------------------------------------------------------------------
// オプション
//
        private const SLIDE_BAR_WIDTH:uint = 80;
        private var _spOption:Sprite;
        private var _textMethod:TextField;
        private var _slideBar:SlideBar;
        private var _textSlideBar:TextField;
        
        /**
         * オプションを初期化
         */
        private function _initOption():void {
            var text:TextField;
            
            _spOption = new Sprite();
            //addChildAt(_spOption, 2);
            addChildAt(_spOption, 1);
            
            // 描画タイプ
            text = new TextField();
            text.defaultTextFormat = new TextFormat(FontLoader.FONT_NAME_KROEGER_0555, 8, 0xcccccc);
            text.embedFonts = true;
            text.autoSize = TextFieldAutoSize.LEFT;
            text.multiline = false;
            text.selectable = false;
            text.text = "METHOD:";
            text.x = -2;
            text.y = 0;
            _spOption.addChild(text);
            _textMethod = new TextField();
            _textMethod.defaultTextFormat = new TextFormat(FontLoader.FONT_NAME_KROEGER_0655, 8, 0xffffff);
            _textMethod.embedFonts = true;
            _textMethod.autoSize = TextFieldAutoSize.LEFT;
            _textMethod.multiline = false;
            _textMethod.selectable = false;
            _textMethod.x = text.width;
            _textMethod.y = -2;
            _spOption.addChild(_textMethod);
            _changeOptionMethod();
            
            // 三角形の数
            text = new TextField();
            text.defaultTextFormat = new TextFormat(FontLoader.FONT_NAME_KROEGER_0555, 8, 0xcccccc);
            text.embedFonts = true;
            text.autoSize = TextFieldAutoSize.LEFT;
            text.multiline = false;
            text.selectable = false;
            text.text = "TRIANGLES:";
            text.x = -2;
            text.y = 15;
            _spOption.addChild(text);
            _textSlideBar = new TextField();
            _textSlideBar.defaultTextFormat = new TextFormat(FontLoader.FONT_NAME_KROEGER_0655, 8, 0xffffff);
            _textSlideBar.embedFonts = true;
            _textSlideBar.autoSize = TextFieldAutoSize.LEFT;
            _textSlideBar.multiline = false;
            _textSlideBar.selectable = false;
            _textSlideBar.text = ((DIV_LIST[_currentDiv])*(DIV_LIST[_currentDiv])*2*6).toString();
            _textSlideBar.x = text.width;
            _textSlideBar.y = 13;
            _spOption.addChild(_textSlideBar);
            _slideBar = new SlideBar(SLIDE_BAR_WIDTH, DIV_LIST.length-1, SlideBar.createBar(7, 15, 0xffffffff), SlideBar.createRail(SLIDE_BAR_WIDTH, 1, 0xa0ffffff));
            _slideBar.value = _currentDiv;
            _slideBar.onChange = onChange;
            _slideBar.y = 40;
            _spOption.addChild(_slideBar);

            _moveOption();
            
            function onChange(value:uint):void {
                _currentDiv = value;
                _changeDraw();
                _textSlideBar.text = ((DIV_LIST[_currentDiv])*(DIV_LIST[_currentDiv])*2*6).toString();
            }
        }
        
        /**
         * 描画方法の表示を更新
         */
        private function _changeOptionMethod():void {
            if (_spOption == null) return;
            if (_drawMethod == "gpu") {
                _textMethod.text = "GPU";
                _changeMessage("PRESS ANY KEY TO SWITCH BETWEEN STAGE3D(GPU), STAGE3D (SOTWARE) AND GRAPHICS.", true);
            } else if (_drawMethod == "software") {
                _textMethod.text = "SOFTWARE";
                _changeMessage("PRESS ANY KEY TO SWITCH BETWEEN STAGE3D(GPU), STAGE3D (SOTWARE) AND GRAPHICS.", true);
            } else {
                _textMethod.text = "GRAPHICS";
                _changeMessage("PRESS ANY KEY TO SWITCH BETWEEN STAGE3D(GPU), STAGE3D (SOTWARE) AND GRAPHICS.\nCLICK THE CANVAS TO SWITCH BORDER VISIBLITY.", true);
            }
        }
        
        /**
         * スライドバーの配置を更新
         */
        private function _moveOption():void {
            if (_spOption == null) return;
            _spOption.x = int(_stage3DGPU.x + _canvasSize - _spOption.width - 20);
            _spOption.y = int(_stage3DGPU.y + 5);
        }

        

// ----------------------------------------------------------------------------------------------------
// 画面にメッセージを表示
//
        private var _textFieldMessage:TextField;
        private var _messageTime:uint;
        private var _messageBottom:Boolean=false;

        /**
         * メッセージ表示を初期化
         */
        private function _initMessage():void {
            _textFieldMessage = new TextField;
            _textFieldMessage.defaultTextFormat = new TextFormat(FontLoader.FONT_NAME_KROEGER_0655, 8, 0xffffff);
            _textFieldMessage.embedFonts = true;
            _textFieldMessage.autoSize = TextFieldAutoSize.LEFT;
            _textFieldMessage.multiline = true;
            _textFieldMessage.selectable = false;
            _textFieldMessage.visible = false;
            addChild(_textFieldMessage);
            _moveMessage();
        }
        /**
         * メッセージ表示のテキストを変更
         * 
         * @param    text    表示メッセージ
         * @param    bottom    画面の下にメッセージを表示するかどうか
         */
        private function _changeMessage(text:String, bottom:Boolean=false):void {
            _messageBottom = bottom;
            _textFieldMessage.text = text;
            _moveMessage();
        }
        /**
         * メッセージ表示の配置を更新
         */
        private function _moveMessage():void {
            if (_textFieldMessage == null) return;
            _textFieldMessage.x = int((stage.stageWidth - _textFieldMessage.width)/2);
            _textFieldMessage.y = (_messageBottom) ? int(_stage3DGPU.y + _canvasSize - _textFieldMessage.height/2 - 15) : int((stage.stageHeight - _textFieldMessage.height)/2);
        }
        /**
         * メッセージ表示の点滅を開始
         */
        private function _showMessage():void {
            addEventListener(Event.ENTER_FRAME, _blinkMessage);
            _textFieldMessage.visible = true;
        }
        /**
         * メッセージ表示の点滅を終了
         */
        private function _hideMessage():void {
            removeEventListener(Event.ENTER_FRAME, _blinkMessage);
            _textFieldMessage.visible = false;
        }
        /**
         * メッセージ表示を一定間隔で点滅
         * 
         * @param    e    イベント
         */
        private function _blinkMessage(e:Event):void {
            var timer:uint;

            if ((timer = getTimer()) - _messageTime > 25) {
                _messageTime = timer;
                _textFieldMessage.visible = !_textFieldMessage.visible;
            }
        }


// ----------------------------------------------------------------------------------------------------
// スタッツ
//
        /**
         * スタッツを表示
         */
        public function _initStats():void {
            addChild(new Stats());
        }

    }
}


// ----------------------------------------------------------------------------------------------------
// 3Dの球面の頂点情報を管理するクラス
//    
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

class SphericalShader {

    private static const PI2:Number = Math.PI*2;
    
    private var _radius:Number;
    private var _width:Number;
    private var _height:Number;
    private var _segmentX:uint = 2;
    private var _segmentY:uint = 2;
    public var segmentXP:uint;
    public var segmentYP:uint;
    private var _vertexLength:uint;
    private var _surfaceNum:uint=0;
    
    private var _textureDivX:uint = 1;
    private var _textureDivY:uint = 1;

    public var vertexList:Vector.<Number>;
    public var indexList:Vector.<uint>;

    /**
     * 球体の半径、球面のX軸とY軸方向の長さ、断面の数を指定してインスタンスを生成します。
     * 
     * @param    radius        球面の半径 - 球座標の半径
     * @param    width        球面のX軸方向(Y軸周り)の長さを表す回転角度
     * @param    height        球面のY軸方向(X軸周り)の長さを表す回転角度
     * @param    segmentX    球面上のX軸方向(Y軸周り)の断面(四角形)の数
     * @param    segmentY    球面上のY軸方向(X軸周り)の断面(四角形)の数
     */
    public function SphericalShader(radius:Number, width:Number, height:Number, segmentX:uint=2, segmentY:uint=2) {
        _radius = (radius > 0 && radius < 1) ? radius : 1;
        _width =  (width > 0) ? width : PI2;
        _height =  (height > 0) ? height : PI2;
        if (segmentX > 1) _segmentX = segmentX;
        if (segmentY > 1) _segmentY = segmentY;
        segmentXP = _segmentX + 1;
        segmentYP = _segmentY + 1;
        _vertexLength = segmentXP*segmentYP;        
        vertexList = new Vector.<Number>();
        indexList = new Vector.<uint>();
    }

    /**
     * 球面の中心点を指定して頂点の位置を計算し、内部データに頂点情報を追加します。
     * 球面の中心点は、真正面(x=0, y=0, z=-1)を基準点とし、画面の右側がX軸の正方向、上側がY軸の正方向です。
     * 
     * @param    rotationX        球面の中心点のX軸方向(Y軸周り)の回転角度
     * @param    rotationY        球面の中心点のY軸方向(X軸周り)の回転角度
     */
    public function setVertex(rotationX:Number, rotationY:Number):void {
        var i:uint, j:uint, angleX:Number, angleY:Number, offset:uint, m:Matrix3D, v:Vector3D;

        m = new Matrix3D();
        // 頂点リストにデータを追加
        for (j=0;j<segmentYP;j++) {
            angleY = _height*j/_segmentY - _height/2;
            
            for (i=0;i<segmentXP;i++) {
                angleX = _width*i/_segmentX - _width/2;
                
                // 真正面(x=0, y=0, z=-1)を基準点として球面の頂点を生成
                v = new Vector3D(0, 0, -_radius, 0);
                m.identity();
                m.appendRotation(-angleX, Vector3D.Y_AXIS);
                m.appendRotation(-angleY, Vector3D.X_AXIS);
                v = m.deltaTransformVector(v);
                
                // 球面の中心点を指定角度分ずらす
                v = new Vector3D(v.x, v.y, v.z, 0);
                m.identity();
                m.appendRotation(-rotationX, Vector3D.Y_AXIS);
                m.appendRotation(rotationY, Vector3D.X_AXIS);
                v = m.deltaTransformVector(v);
                
                vertexList.push(v.x, v.y, v.z, i/_segmentX, j/_segmentY);
            }
        }
        
        // インデックスリストにデータを追加
        offset = _surfaceNum*_vertexLength;
        for (j=0;j<_segmentY;j++) {
            for (i=0;i<_segmentX;i++) {            
                indexList.push(j*segmentXP + i + offset, (j+1)*segmentXP + i+1 + offset, (j+1)*segmentXP + i + offset);
                indexList.push(j*segmentXP + i + offset, j*segmentXP + i+1 + offset, (j+1)*segmentXP + i+1 + offset);
            }
        }
        
        // 面の数をインクリメント
        _surfaceNum++;
    }
}


// ----------------------------------------------------------------------------------------------------
// スライドバー
//
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * スライドバー(X軸)を構成するクラスです。
 */
class SlideBar extends Sprite {

    private var _bar:SimpleButton;
    private var _rail:Sprite;    
    private var _width:uint;
    private var _range:uint;
    
    /**
     * バーの値です。
     */
    public function get value():uint {
        return _value;
    }
    public function set value(v:uint):void {
        _value = (v > _range) ? _range : v;
        _barMoveJust();
        if (onChange is Function) onChange.apply(null, [_value]);
    }
    private var _value:uint = 0;
    
    /**
     * バーの移動係数です。
     */
    public function get moveFactor():Number {
        return _moveFactor;
    }
    public function set moveFactor(v:Number):void {
        _moveFactor = (v >= 0 && v <= 1) ? v : 0.5;
    }
    private var _moveFactor:Number = 0.5;

    private var _x:Number=0;
    private var _moving:Boolean=false;
    
    /**
     * SlideBarの値が変更された時に呼び出されるコールバック関数です。
     */
    public var onChange:Function;
    
// ----------------------------------------------------------------------------------------------------
// コンストラクタ
//
    /**
     * スライドバーを作成します。
     *
     * @param    width    スライドバーの幅
     * @param    range    スライドバーの値の数
     * @param    bar        スライドバーのバーを表すSimpleButtonです。
     * @param    rail    スライドバーのレールを表すSpriteです。
     */
    public function SlideBar(width:uint, range:uint, bar:SimpleButton, rail:Sprite) {
        _width = (width < 2) ? 2 : width;
        _range = (range < 2 || range > width) ? width : range;
        addChildAt(_rail = rail, 0);
        addChild(_bar = bar);
        
        _bar.addEventListener(MouseEvent.MOUSE_DOWN, _barMouseDown, false, 0, true);
    }
    

// ----------------------------------------------------------------------------------------------------
// スライドバーの操作
//
    // バーのドラッグ開始
    private function _barMouseDown(e:Event):void {
        if (stage == null) return;
        stage.addEventListener(MouseEvent.MOUSE_MOVE, _mouseMove);
        stage.addEventListener(MouseEvent.MOUSE_UP, _mouseUp);
    }
    
    // バーのドラッグ終了
    private function _mouseUp(e:Event):void {
        if (stage == null) return;
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, _mouseMove);
        stage.removeEventListener(MouseEvent.MOUSE_UP, _mouseUp);
    }
    
    // バーのドラッグ
    private function _mouseMove(e:Event):void {
        var temp:uint = _value;
        
        if (stage == null) return;
        
        if (!_moving) {
            stage.addEventListener(Event.ENTER_FRAME, _barMove);
            _moving = true;
        }
        
        if (mouseX < 0) {
            _value = 0;
            _x = 0;
        } else if (mouseX > _width) {
            _value = _range;
            _x = _width;
        } else {
            _value = uint(mouseX/_width*_range + 0.5);
            _x = uint(_width*_value/_range);
        }
        
        if (temp != _value && onChange is Function) onChange.apply(null, [_value]);
    }
    
    // バーの移動
    private function _barMove(e:Event):void {
        var diff:Number, abs:Number;
        
        diff = _x - _bar.x;
        abs = (diff < 0) ? -diff : diff;
        if (abs*_moveFactor < 0.05) {
            _bar.x = _x;
            if (_moving) {
                stage.removeEventListener(Event.ENTER_FRAME, _barMove);
                _moving = false;
            }
        } else {
            _bar.x += diff*_moveFactor;
        }
    }
    
    // バーの強制移動
    private function _barMoveJust():void {
        _bar.x = _x = uint(_width*_value/_range);
        if (_moving) {
            stage.removeEventListener(Event.ENTER_FRAME, _barMove);
            _moving = false;
        }
    }
    
    /**
     * バーを作成
     *
     * @param    width    バーの幅
     * @param    range    バーの高さ
     * @param    argb    バーのARGBカラー
     */
    public static function createBar(width:uint, height:uint, argb:uint):SimpleButton {
        var bmp:Bitmap;
        
        bmp = new Bitmap(new BitmapData(width, height, true, argb));
        bmp.x =  - uint(width/2);
        bmp.y =  - uint(height/2);
        return new SimpleButton(bmp, bmp, bmp, bmp);
    }
    
    /**
     * レールを作成
     *
     * @param    width    バーの幅
     * @param    range    バーの高さ
     * @param    argb    バーのARGBカラー
     */
    public static function createRail(width:uint, height:uint, argb:uint):Sprite {
        var bmp:Bitmap, sprite:Sprite;
        
        bmp = new Bitmap(new BitmapData(width, height, true, argb));
        bmp.x =  0;
        bmp.y =  - uint(height/2);
        sprite = new Sprite();
        sprite.addChild(bmp);
        return sprite;
    }
}


// ----------------------------------------------------------------------------------------------------
// フォントのロード用クラス
//    
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;
import flash.text.Font;

class FontLoader {

    public static const FONT_CLASS_KROEGER_0555:String = "Kroeger0555";
    public static const FONT_NAME_KROEGER_0555:String = "kroeger 05_55";
    public static const FONT_CLASS_KROEGER_0655:String = "Kroeger0655";
    public static const FONT_NAME_KROEGER_0655:String = "kroeger 06_55";
    //public static const FONT_CLASS_KROEGER_0665:String = "Kroeger0665";
    //public static const FONT_NAME_KROEGER_0665:String = "kroeger 06_65";
    private static const FONT_SWF_URL:String = "http://global.yuichiroharai.com/swf/FontKroeger.swf";
    
    /**
     * フォント内蔵のSWFをロード
     * 
     * @param    callback    ロード完了時のコールバック関数
     */
    public static function loadFont(callBack:Function):void {
        var loader:Loader;

        loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
        loader.load(new URLRequest(FONT_SWF_URL), new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain));

        function complete(e:Event):void {
            try {
                Font.registerFont(loader.contentLoaderInfo.applicationDomain.getDefinition(FONT_CLASS_KROEGER_0555) as Class);
                Font.registerFont(loader.contentLoaderInfo.applicationDomain.getDefinition(FONT_CLASS_KROEGER_0655) as Class);
            } catch (e:Error) { return; }
            
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, complete);
            loader = null;
            if (callBack is Function) callBack.apply();
        }
    }
}









