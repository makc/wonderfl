package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
        import flash.utils.*;
	
	import gs.TweenMax;
	import gs.easing.Back;
	
	public class tags extends Sprite {
		
		private var tagsString:String ="All Classes Accessibility AccessibilityProperties ActionScriptVersion ActivityEvent AntiAliasType ApplicationDomain ArgumentError arguments Array AsyncErrorEvent AVM1Movie BevelFilter Bitmap BitmapData BitmapDataChannel BitmapFilter BitmapFilterQuality BitmapFilterType BlendMode BlurFilter Boolean BreakOpportunity ByteArray Camera Capabilities CapsStyle CFFHinting Class Clipboard ClipboardFormats ClipboardTransferMode ColorCorrection ColorCorrectionSupport ColorMatrixFilter ColorTransform ContentElement ContextMenu ContextMenuBuiltInItems ContextMenuClipboardItems ContextMenuEvent ContextMenuItem ConvolutionFilter CSMSettings CustomActions DataEvent Date DefinitionError Dictionary DigitCase DigitWidth DisplacementMapFilter DisplacementMapFilterMode DisplayObject DisplayObjectContainer DropShadowFilter EastAsianJustifier ElementFormat Endian EOFError Error ErrorEvent EvalError Event EventDispatcher EventPhase ExternalInterface FileFilter FileReference FileReferenceList FocusEvent Font FontDescription FontLookup FontMetrics FontPosture FontStyle FontType FontWeight FrameLabel FullScreenEvent Function GlowFilter GradientBevelFilter GradientGlowFilter GradientType GraphicElement Graphics GraphicsBitmapFill GraphicsEndFill GraphicsGradientFill GraphicsPath GraphicsPathCommand GraphicsPathWinding GraphicsShaderFill GraphicsSolidFill GraphicsStroke GraphicsTrianglePath GridFitType GroupElement HTTPStatusEvent IBitmapDrawable ID3Info IDataInput IDataOutput IDrawCommand IDynamicPropertyOutput IDynamicPropertyWriter IEventDispatcher IExternalizable IGraphicsData IGraphicsFill IGraphicsPath IGraphicsStroke IllegalOperationError IME IMEConversionMode IMEEvent int InteractiveObject InterpolationMethod InvalidSWFError IOError IOErrorEvent JointStyle JPEGLoaderContext JustificationStyle Kerning Keyboard KeyboardEvent KeyLocation LigatureLevel LineJustification LineScaleMode Loader LoaderContext LoaderInfo LocalConnection Math Matrix Matrix3D MemoryError Microphone MorphShape Mouse MouseCursor MouseEvent MovieClip Namespace NetConnection NetStatusEvent NetStream NetStreamInfo NetStreamPlayOptions NetStreamPlayTransitions Number Object ObjectEncoding Orientation3D PerspectiveProjection PixelSnapping Point PrintJob PrintJobOptions PrintJobOrientation ProgressEvent Proxy QName RangeError Rectangle ReferenceError RegExp RenderingMode Responder SampleDataEvent Scene ScriptTimeoutError Security SecurityDomain SecurityError SecurityErrorEvent SecurityPanel Shader ShaderData ShaderEvent ShaderFilter ShaderInput ShaderJob ShaderParameter ShaderParameterType ShaderPrecision Shape SharedObject SharedObjectFlushStatus SimpleButton Socket Sound SoundChannel SoundCodec SoundLoaderContext SoundMixer SoundTransform SpaceJustifier SpreadMethod Sprite StackOverflowError Stage StageAlign StageDisplayState StageQuality StageScaleMode StaticText StatusEvent String StyleSheet SWFVersion SyncEvent SyntaxError System TabAlignment TabStop TextBaseline TextBlock TextColorType TextDisplayMode TextElement TextEvent TextField TextFieldAutoSize TextFieldType TextFormat TextFormatAlign TextJustifier TextLine TextLineCreationResult TextLineMetrics TextLineMirrorRegion TextLineValidity TextRenderer TextRotation TextSnapshot Timer TimerEvent Transform TriangleCulling TypeError TypographicCase uint URIError URLLoader URLLoaderDataFormat URLRequest URLRequestHeader URLRequestMethod URLStream URLVariables Utils3D Vector Vector3D VerifyError Video XML XMLDocument XMLList XMLNode XMLNodeType XMLSocket XMLUI";
		private var tagNamesArray:Array = tagsString.split(" ");
		private var tagsArray:Array = [];
		private var inputBox:InputBox;
		
		public static var 
			accent:int = 0x0066DD,
			blend:int  = 0x808080,
			bright:int = 0x204060;
		
		public function tags() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, function (e:Event):void {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				
				for each (var tagName:String in tagNamesArray) {
					var tag:Sprite = new Sprite;
					var t:TextField = new TextField;
					t.defaultTextFormat = new TextFormat("Trebuchet MS", 24, blend);
					t.text = tagName;
					t.autoSize = TextFieldAutoSize.LEFT;
					t.selectable = false;
					t.x = -t.width/2;
					t.cacheAsBitmap = true;
					tag.addChild(t)
					addChild(tag)
					tagsArray.push(tag);
					t.alpha = 0.25;
				}
				
				//setTimeout(function():void {for (var i:int = 0; i<30; i++) foolAround()}, 1000);
				
				stage.addEventListener(Event.RESIZE,resize);
				resize();
				stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
					var xx:Number = mouseX/stage.stageWidth -0.5;
					var yy:Number = mouseY/stage.stageHeight-0.5;
					for each (var t:Sprite in tagsArray ) {
						t.rotationY =  -xx*45 + 15*t.getRect(t).x/stage.stageWidth;
						t.rotationX =   yy*45 - 15*t.getRect(t).y/stage.stageHeight;
					}
				});
				
				inputBox = new InputBox;
				inputBox.addEventListener(Event.CHANGE, inputChange);
				addChild(inputBox);

			});

                 // take a capture after 10 sec
                 // Wonderfl.capture_delay( 10 );
                 // setTimeout(function():void{Wonderfl.capture(stage);},10000);
    
		}
		
		public function resize(e:Event = null):void {
			for each (var t:Sprite in tagsArray ) {
				t.x = stage.stageWidth/2;
				t.y = stage.stageHeight/2;
				t.getChildAt(0).x = stage.stageWidth  *(Math.random()-Math.random());
				t.getChildAt(0).y = stage.stageHeight *(Math.random()-Math.random());
				t.getChildAt(0).z = Math.random()*1000;
				//t.getChildAt(0).alpha = 0.5+(1- t.getChildAt(0).z/1000)/2;
			}
		}
		
		public function inputChange(e:Event = null):void {
			for each (var t:Sprite in tagsArray ) {
				var textField:TextField = TextField(t.getChildAt(0));
				hilight(textField, inputBox.text);
			}
		}
		
		
		public function foolAround():void {
			var zz:Number = Math.random()*1000;
			var i:int = Math.floor(Math.random()*tagsArray.length);
			TweenMax.to(
				tagsArray[i].getChildAt(0), 
				Math.random()*15+10,
				{
					ease:Back.easeInOut,
					
					x: stage.stageWidth  *(Math.random()-Math.random()),
					y: stage.stageHeight *(Math.random()-Math.random()),
					z: zz,
					alpha:0.5+(1- zz/1000)/2,
					
//					blur: {blurX: zz/100, blurY: zz/100},
					
					onComplete: foolAround,
					
					onUpdateParams: [i],
					onUpdate: onUpdate
					
				}
			);
		
		}
		
		public function onUpdate(...arguments):void {
			var xx:Number = mouseX/stage.stageWidth -0.5;
			var yy:Number = mouseY/stage.stageHeight-0.5;
			var i:Number = arguments[0];
 			var t:Sprite = Sprite(tagsArray[i]);
 			t.rotationY =  -xx*45 + 15*t.getRect(t).x/stage.stageWidth;
			t.rotationX =   yy*45 - 15*t.getRect(t).y/stage.stageHeight;
		}
		
		public function hilight(textField:TextField, str:String):void {
			
			var i:int;
			str = str.toLocaleLowerCase();
			str = str.replace(/[^\w\u0400-\u0460\s]*/g,"");
			var string:String = textField.text.toLocaleLowerCase();
			if (str=="") {unhilight(textField); return;}
			var pattern:String= ""; for (i = 0; i<str.length;i++) pattern += str.charAt(i)+".*"
			var regexp:RegExp = new RegExp(pattern,"g")
			var p:int = string.search(regexp);
			if (p>=0) {
				textField.alpha = 1;
				textField.textColor = bright;
				var j:int = 0, k:int = 0;
				for (i= 0; i<str.length; i++) {
					j = string.search(str.charAt(i));
					textField.setTextFormat(new TextFormat(null,null,accent), k+j, k+j+1);
					string = string.substr(j+1);
					k += j+1;
				}
			} else {
				unhilight(textField)
			}
		}
		
		public function 
		unhilight(textField:TextField):void {
			textField.textColor = blend;
			textField.alpha = 0.25
		}
	
		
	}
}

import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;

class InputBox extends Sprite {
		
	private var 
		w:int,
		h:int =  66,
		b:int =  10,
		inputBackground:Sprite = new Sprite,
		inputField:TextField = new TextField,
		labelField:TextField = new TextField;


	public function 
	InputBox(hint:String = "fuzzy search...", width:int = 380) {
		
		//var g:Graphics = graphics; g.lineStyle(0,0,0.1); g.drawCircle(0,0,10);
		
		addChild(inputBackground);
		
		w = width;
		
		inputField.defaultTextFormat = new TextFormat("Trebuchet MS", 30, tags.accent);
		inputField.htmlText = "<font color='#808080'>"+hint+"</font>";
		inputField.width = w - b*2 - (h-b*2);
		inputField.height = h - b*2;
		inputField.x = -inputField.width >>1;
		inputField.y = 4 - (inputField.height>>1);
		inputField.type = TextFieldType.INPUT;
		//inputField.embedFonts = true;
		addChild(inputField);
		
		draw();
		
		inputField.addEventListener(FocusEvent.FOCUS_IN, function (e:Event):void {
			inputField.defaultTextFormat = new TextFormat("Trebuchet MS", 30, tags.accent);
			inputField.text="";
		});
		
		inputField.addEventListener(Event.CHANGE, function (e:Event):void {
			dispatchEvent(new Event(Event.CHANGE));
		});
		
		addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
			stage.addEventListener(Event.RESIZE, resize);
			resize();
		}); 

	}
	
	
	public function get 
	text():String {
		return inputField.text;
	}
	
	
	private function 
	resize(e:Event = null):void {
		x= stage.stageWidth/2;
		y= stage.stageHeight-height;
	}
	
	
	private function draw():void {
		
		var g:Graphics = graphics;
		g.clear();
		var m:Matrix = new Matrix;
		m.createGradientBox(h,h,Math.PI/2,0,0);
		g.beginGradientFill(GradientType.LINEAR, [0xDEDEDE, 0xA5A5A5], [1,1], [0,255], m);
		g.drawRoundRect(-w>>1, -h>>1, w, h, h, h);
		g.endFill()

		g = inputBackground.graphics;
		g.clear();
		m.createGradientBox(h,h,Math.PI/2,0,0);
		g.beginFill(0xFFFFFF);
		var ww:int = w-b*2;
		var hh:int = h-b*2;
		g.drawRoundRect(-ww>>1, -hh>>1, ww, hh, hh, hh);
		g.endFill()
		inputBackground.filters = [new DropShadowFilter(4,45,0,0.4,10,10,1,2,true)];

	}	
}
