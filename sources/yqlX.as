package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import gs.TweenMax;
	import gs.easing.Back;
	
	[SWF(width="465", height="465")]
	public class tags extends Sprite {
		
		private var tagsString:String ="All Classes Accessibility AccessibilityProperties ActionScriptVersion ActivityEvent AntiAliasType ApplicationDomain ArgumentError arguments Array AsyncErrorEvent AVM1Movie BevelFilter Bitmap BitmapData BitmapDataChannel BitmapFilter BitmapFilterQuality BitmapFilterType BlendMode BlurFilter Boolean BreakOpportunity ByteArray Camera Capabilities CapsStyle CFFHinting Class Clipboard ClipboardFormats ClipboardTransferMode ColorCorrection ColorCorrectionSupport ColorMatrixFilter ColorTransform ContentElement ContextMenu ContextMenuBuiltInItems ContextMenuClipboardItems ContextMenuEvent ContextMenuItem ConvolutionFilter CSMSettings CustomActions DataEvent Date DefinitionError Dictionary DigitCase DigitWidth DisplacementMapFilter DisplacementMapFilterMode DisplayObject DisplayObjectContainer DropShadowFilter EastAsianJustifier ElementFormat Endian EOFError Error ErrorEvent EvalError Event EventDispatcher EventPhase ExternalInterface FileFilter FileReference FileReferenceList FocusEvent Font FontDescription FontLookup FontMetrics FontPosture FontStyle FontType FontWeight FrameLabel FullScreenEvent Function GlowFilter GradientBevelFilter GradientGlowFilter GradientType GraphicElement Graphics GraphicsBitmapFill GraphicsEndFill GraphicsGradientFill GraphicsPath GraphicsPathCommand GraphicsPathWinding GraphicsShaderFill GraphicsSolidFill GraphicsStroke GraphicsTrianglePath GridFitType GroupElement HTTPStatusEvent IBitmapDrawable ID3Info IDataInput IDataOutput IDrawCommand IDynamicPropertyOutput IDynamicPropertyWriter IEventDispatcher IExternalizable IGraphicsData IGraphicsFill IGraphicsPath IGraphicsStroke IllegalOperationError IME IMEConversionMode IMEEvent int InteractiveObject InterpolationMethod InvalidSWFError IOError IOErrorEvent JointStyle JPEGLoaderContext JustificationStyle Kerning Keyboard KeyboardEvent KeyLocation LigatureLevel LineJustification LineScaleMode Loader LoaderContext LoaderInfo LocalConnection Math Matrix Matrix3D MemoryError Microphone MorphShape Mouse MouseCursor MouseEvent MovieClip Namespace NetConnection NetStatusEvent NetStream NetStreamInfo NetStreamPlayOptions NetStreamPlayTransitions Number Object ObjectEncoding Orientation3D PerspectiveProjection PixelSnapping Point PrintJob PrintJobOptions PrintJobOrientation ProgressEvent Proxy QName RangeError Rectangle ReferenceError RegExp RenderingMode Responder SampleDataEvent Scene ScriptTimeoutError Security SecurityDomain SecurityError SecurityErrorEvent SecurityPanel Shader ShaderData ShaderEvent ShaderFilter ShaderInput ShaderJob ShaderParameter ShaderParameterType ShaderPrecision Shape SharedObject SharedObjectFlushStatus SimpleButton Socket Sound SoundChannel SoundCodec SoundLoaderContext SoundMixer SoundTransform SpaceJustifier SpreadMethod Sprite StackOverflowError Stage StageAlign StageDisplayState StageQuality StageScaleMode StaticText StatusEvent String StyleSheet SWFVersion SyncEvent SyntaxError System TabAlignment TabStop TextBaseline TextBlock TextColorType TextDisplayMode TextElement TextEvent TextField TextFieldAutoSize TextFieldType TextFormat TextFormatAlign TextJustifier TextLine TextLineCreationResult TextLineMetrics TextLineMirrorRegion TextLineValidity TextRenderer TextRotation TextSnapshot Timer TimerEvent Transform TriangleCulling TypeError TypographicCase uint URIError URLLoader URLLoaderDataFormat URLRequest URLRequestHeader URLRequestMethod URLStream URLVariables Utils3D Vector Vector3D VerifyError Video XML XMLDocument XMLList XMLNode XMLNodeType XMLSocket XMLUI";
		private var tagNamesArray:Array = tagsString.split(" ");
		private var tagsArray:Array = []
		
		
		public function tags() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, function (e:Event):void {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				
				for each (var tagName:String in tagNamesArray) {
					var tag:Sprite = new Sprite;
					var t:TextField = new TextField;
					t.defaultTextFormat = new TextFormat("Trebuchet MS", 20, 0x888888);
					t.text = tagName;
					t.autoSize = TextFieldAutoSize.LEFT;
					t.selectable = false;
					t.x = -t.width/2;
					t.cacheAsBitmap = true;
					tag.addChild(t)
					addChild(tag)
					tagsArray.push(tag);
				}
				
				setTimeout(function():void {for (var i:int = 0; i<30; i++) foolAround()}, 1000);
				//setTimeout(function():void {Wonderfl.capture(stage)}, 30000);
				stage.addEventListener(Event.RESIZE,resize);
				resize();
				stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
					var xx:Number = mouseX/stage.stageWidth -0.5;
					var yy:Number = mouseY/stage.stageHeight-0.5;
					for each (var t:Sprite in tagsArray ) {
						t.rotationY =  -xx*45 + 30*t.getRect(t).x/stage.stageWidth;
						t.rotationX =   yy*45 - 30*t.getRect(t).y/stage.stageHeight;
					}
				});
			});
		}
		
		public function resize(e:Event = null):void {
			for each (var t:Sprite in tagsArray ) {
				t.x = stage.stageWidth/2;
				t.y = stage.stageHeight/2;
				t.getChildAt(0).x = stage.stageWidth  *(Math.random()-Math.random());
				t.getChildAt(0).y = stage.stageHeight *(Math.random()-Math.random());
				t.getChildAt(0).z = Math.random()*1000;
				t.getChildAt(0).alpha = 0.5+(1- t.getChildAt(0).z/1000)/2;
			}
		}
		
		public function foolAround():void {
			var zz:Number = Math.random()*1000;
			var i:int = Math.floor(Math.random()*tagsArray.length);
			TweenMax.to(
				tagsArray[i].getChildAt(0), 
				Math.random()*5+2,
				{
					ease:Back.easeInOut,
					
					x: stage.stageWidth  *(Math.random()-Math.random()),
					y: stage.stageHeight *(Math.random()-Math.random()),
					z: zz,
					alpha:0.5+(1- zz/1000)/2,
					
//					blur: {blurX: zz/100, blurY: zz/100},
					
					onComplete: foolAround
					
//					onUpdateParams: [i],
//					onUpdate: onUpdate
					
				}
			);
		
		}
		
		public function onUpdate(...arguments):void {
			var i:Number = arguments[0];
 			var r:Rectangle = tagsArray[(i+1) < tagsArray.length ? i+1 : 0].getChildAt(0).getBounds(tagsArray[i]);
 			var g:Graphics = tagsArray[i].graphics;
 			g.clear();
 			g.lineStyle(1,0,0.5);
 			g.lineTo(r.x, r.y);
		}
		
	}
}