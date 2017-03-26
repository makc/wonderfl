package 
{
	
	/**
	 * 
	 * @author Takashi Murai(KAYAC)
	 */
	 
	import flash.display.*
	import flash.events.*
	import flash.text.*
	import flash.filters.*;
	import flash.geom.*;
	import flash.utils.*
	
	public class WonderFL extends MovieClip
	{
		//
		var Layer:Sprite=new Sprite()
		var drawPos:Sprite=new Sprite()
		var textPos:Sprite=new Sprite()
		
		var txtFmt:TextFormat = new TextFormat();
		var textFields:TextField=new TextField()
		
		//message
		var mes1="hello world"
		var mes2="it's wonderFL world."
		
		//lleasures
		var posX:Number = stage.stageWidth / 2;  
		var posY:Number = stage.stageHeight /2;  
		var disX:Number = Math.random()*30  
		var disY:Number = Math.random()*20
		var deg:Number = Math.random()*360  
		var count:Number = 0;  
		var step:Number =64
		var cx:Number = stage.stageWidth /2;  
		var cy:Number = stage.stageHeight /2;   
		var xPos:Number = posX * Math.sin(disX * count + deg) + cx;  
		var yPos:Number = posY * Math.sin(disY * count) + cy; 
		
		//gladationLine
		var mtx:Matrix = new Matrix();
		var gradCount=1
		var gradDir=1
		var life=0
		var lifeLmt=200
		
		//fader
		var blurVall=4
		var _bd:BitmapData
		var _bmp:Bitmap
		var _blurF:BlurFilter
		
		public function WonderFL() { 
			initFader()
			setMessage(mes1,"normal",0xFF0000)
			
			var phase1:Timer = new Timer(3000, 1);
			phase1.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:Event){
																				
			 	setMessage("","normal",0xFFFFFF)
			});
			phase1.start(); 
			
			var phase2:Timer = new Timer(6000, 1);
			phase2.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:Event){
				setMessage(mes2,"screen",0xFFFFFF)
				initLissajous()
			});
			phase2.start(); 
			
			this.addChild(_bmp)
			Layer.addChild(drawPos)
			Layer.addChild(textPos)
			textPos.addChild(textFields)
		}
		
		function setMessage(mes:String,blend:String,hex:Number){
			txtFmt.size = 40
			txtFmt.font="Arial"
			txtFmt.align = TextFormatAlign.CENTER;
			txtFmt.color=hex
			
			textFields.defaultTextFormat = txtFmt;
			textFields.autoSize=TextFieldAutoSize.LEFT
			textFields.x =0
			textFields.y = 0
			textFields.text=mes
			
			textPos.alpha=0.5
			textPos.blendMode=blend
			
			textPos.x=stage.stageWidth/2-textFields.width/2
			textPos.y=stage.stageHeight/2-textFields.height/2
		}

		function initFader(){
			_bd=new BitmapData(stage.stageWidth,stage.stageHeight,true,0x000000);
			_bmp=new  Bitmap(_bd);
			_blurF=new BlurFilter(blurVall,blurVall,3);
			
			 stage.addEventListener(Event.ENTER_FRAME, function(e:Event){
				render()
			});  
		}
		
		function render():void {
			_bd.colorTransform(_bd.rect, new ColorTransform(1, 1, 1,0.999, 0, 0, 0, 0));
			_bd.applyFilter(_bd,_bd.rect,new Point(0,0),_blurF);
			_bd.draw(Layer);
		}
		
		function initLissajous(){
			mtx.createGradientBox(400, 400, 0, 0, 0);
			drawPos.graphics.lineStyle(1);  
		 	drawPos.graphics.lineGradientStyle(GradientType.LINEAR,  [0xFF0000, 0x0000FF], [0.5,0.5],[gradCount,255-gradCount], mtx, SpreadMethod.REFLECT);
			drawPos.graphics.moveTo(xPos,yPos);  
			 
			 stage.addEventListener(Event.ENTER_FRAME, function(e:Event){
				drawLissajous()
			});  
		}
		
		 function drawLissajous():void {
			 count+= step;  
			 xPos = posX * Math.sin(disX * count + deg) + cx;  
			 yPos = posY * Math.sin(disY * count) + cy;  
			 if(gradCount>=255 || 0>=gradCount){
				gradDir*=-1
			}
			gradCount+=gradDir
			life=life>lifeLmt?0:life+1
			if (life>lifeLmt) {
				drawPos.graphics.clear()
				drawPos.graphics.lineStyle(0.5);  
				drawPos.graphics.moveTo(xPos,yPos)
			}

			drawPos.graphics.lineGradientStyle(GradientType.LINEAR,  [0xFF0000, 0xFF0000], [(gradCount/255),((255-gradCount)/255)],[0,255], mtx, SpreadMethod.REFLECT);
			drawPos.graphics.lineTo(xPos,yPos);  
		}
	}
}

