//First sharing code from Alexandre Delattre / Grafyweb.com


package {
    import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.filters.BlurFilter;
    import flash.geom.ColorTransform;
    import flash.geom.Rectangle;
    import flash.geom.Transform;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFieldType;
    import flash.text.AntiAliasType;
    import flash.text.TextFormat;
    import flash.events.Event;
    import flash.text.TextFormatAlign;
    import flash.filters.GlowFilter;

    
    [SWF(frameRate = "30", width="465", height="465",backgroundColor="0xffffff")]
    public class Matrixcode extends Sprite {
      
        
        private var _maxLabel:int = 150;
            
            private var _maxWidth:int = 50;
            
            private var vecText:Vector.<lettre> = new Vector.<lettre>();
            
            private var colorT:ColorTransform;
            
            private var canvas:BitmapData;
            
            private var contLabel:Sprite = new Sprite();
            
            

        
        public function Matrixcode() 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        private function init(e:Event = null):void {
            
            this.removeEventListener(Event.ADDED_TO_STAGE, init);
            
            var bg_canvas:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0xff000000);
            var bg_color:Bitmap = new Bitmap(bg_canvas);
            this.addChild(bg_color);
            
            canvas = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000);
            
            var glow:GlowFilter = new GlowFilter(0x00ff00, 1, 8, 8, 2, 1, false, false);
            this.contLabel.filters = [glow];
            this.addChild(this.contLabel);
            
            var fd:Bitmap = new Bitmap(canvas);
            var blur:BlurFilter = new BlurFilter(2, 2, 1);
            fd.filters = [blur];
            this.addChild(fd);            
            
            colorT = new ColorTransform(0.95, 1,0.95, 0.98, 0, 0, 0, -0.2);
            
            
            this.addEventListener(Event.ENTER_FRAME, refresh);
            
        }
        
        private function refresh(e:Event):void {
            canvas.colorTransform(new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), this.colorT);
            for (var i:int = 0; i < this.vecText.length; i++) {
                this.refreshLabel(i);
            }
            
            if (this.vecText.length < this._maxLabel) {
                var label:lettre = new lettre();
                label.x = int(Math.random()*this._maxWidth)*(stage.stageWidth/this._maxWidth);        
                this.contLabel.addChild(label);
                this.vecText.push(label);
            }
            
        }
        
        private function refreshLabel(i:int):void {
            var label:lettre = this.vecText[i];
            
            if (label.y > stage.stageHeight) {
                this.contLabel.removeChild(label);
                this.vecText.splice(i, 1);
            }else{            
            label.refresh();
            }
            
            if ((label.y - label.lastPrint) > label.textHeight) {
                label.lastPrint = label.y;
                this.printLabel(label);
                
            }
            
        }
        
        private function printLabel(label:lettre):void {
            var trans:Transform = label.transform;
            
            this.canvas.draw(label,trans.matrix);
            
        }
        

        
    }
    
    }
    
    import flash.filters.GlowFilter;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormatAlign;
    import flash.text.AntiAliasType;
    /**
     * ...
     * @author grafyweb
     */
     
     
    class lettre extends TextField
    {
        //[Embed(source = "../matrix code nfi.ttf", fontFamily = "foo", embedAsCFF = 'false')]            
         //   public static const FONT_Matrix:String;
            
            private var allowT:Array;
            
            private var vitesse:Number;
            
            public var lastPrint:int = -30;
        
        public function lettre()
        {
            var str:String = new String("abcdefghijklmnopqrstuvwxyz0123456789");            
            
            allowT = str.split("");
            this.creaLabel();
            this.vitesse = 1+Math.random() * 2;
            
        }
        
        public function refresh():void {
                    
            this.text = allowT[int(Math.random() * (allowT.length - 1))];
            this.y += this.vitesse;
            
        }
        
        private function creaLabel():void {
            

            var format1:TextFormat = new TextFormat();
            format1.font = "Arial";
            format1.color = 0xffffff;
            format1.size = 10;
            format1.leading = -4;
            format1.bold = true;
            

            
            //this.embedFonts = true;
            this.width = 15;    
            this.multiline = true;
            this.wordWrap = true;                
            this.autoSize = TextFieldAutoSize.NONE;
            this.antiAliasType = AntiAliasType.ADVANCED;
            this.defaultTextFormat = format1;
            this.text = allowT[int(Math.random()*(allowT.length-1))];
            this.defaultTextFormat = format1;            
        }
        
    }
    

        
    
