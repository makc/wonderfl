package {
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    
    import starling.core.Starling;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.Event;
    
    [SWF(backgroundColor="#000000", width="465", height="465", frameRate="60")]
    public class Main extends flash.display.Sprite {
        
        private var mStarling:Starling;
        //private var source:BitmapData = new BitmapData(465, 465, false, 0x000000);

        public function Main() {
            // write as3 code here..
            Wonderfl.disable_capture();
            //addChild(new Bitmap(source));
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            Starling.multitouchEnabled = false;
            
            mStarling = new Starling(Game, stage);
            //mStarling.simulateMultitouch = false;
            mStarling.start();
            mStarling.showStats = true;
            //addEventListener(Event.ENTER_FRAME, ready, false, 0, true);
        }
        /*
        private function ready(evt:Event):void {
            removeEventListener(Event.ENTER_FRAME, ready);
            mStarling.shareContext = true;
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
        }

        private function update(evt:Event):void {
            mStarling.context.clear();
            mStarling.render();
            mStarling.context.drawToBitmapData(source);
            mStarling.context.present();
        }
        */
    }
}

Class  
{
    import starling.display.Image;
    import starling.textures.Texture;
    
    /**
     * ...
     * @author ypc
     */
    class Block extends Image
    {
        public var _id:int;
        
        public function Block(texture:Texture) 
        {
            super(texture);
        }
    }
}

Class  
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.filters.BevelFilter;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import starling.display.Quad;
    import starling.events.Touch;
    
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.utils.Color;
    import starling.textures.Texture;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.events.Event;
    import starling.display.Button;
    import starling.text.TextField;
    
    /**
     * ...
     * @author ypc
     */
    class Game extends Sprite
    {
        
        public var blockArray:Array;
        public var blockNumWidth:int = 10;
        public var blockNumHeight:int = 10;
        
        public var blockWidth:int = 35;
        public var blockHeight:int = 35;
        public var blockTypeNum:int = 5;
        
        public var jewelWidth:int = 16;
        
        public var textureArray:Array;
        public var imageArray:Array;
        
        public var bitmapData:BitmapData;
        public var blockTexture:Texture;
        
        public var colors:Array = [0xD1026C, 0xF2D43F, 0x61C155, 0x048091, 0x492D61];
        public var buttonArray:Array = [];
        
        public var button:Button;
        public var selectedButtonID:int;
        public var previousZeroId:int;
        
        public var turnMax:int = 20;
        public var turnNow:int = 0;
        
        public var turnText:TextField;
        public var restartButton:Button;
        public var gameEnd:Boolean;
        
        public function Game() 
        {
            
            initBlockTexture();
            
            initBlockArray();
            
            initButtons();
            
            previousZeroId = blockArray[0][0]._id;
            buttonArray[previousZeroId].enabled = false;
            
            turnText = new TextField(100, 20, "Turn : " + String(turnNow) + " / " + String(turnMax), "Arial", 12, Color.WHITE);
            turnText.x = 465 - 100;
            turnText.y = 0;
            addChild(turnText);
            
        }
        
        private function initButtons():void
        {
            var i:int;
            var button:Button;
            
            var quad:Quad = new Quad(blockWidth * 5, blockHeight, 0x00ffff);
            quad.x = 465 / 2 - quad.width / 2;
            quad.y = 0;
            addChild(quad);
            
            buttonArray = [];
            
            for (i = 0; i < 5; i += 1)
            {
                button = new Button(Texture.fromTexture(blockTexture, new Rectangle(i * blockWidth, 0, blockWidth, blockWidth)), "");
                button.x = 465 / 2 + (i - int(5 / 2)) * blockWidth - blockWidth / 2;
                button.y = 0;
                button.fontSize = i;
                button.addEventListener(Event.TRIGGERED, onTriggered);
                
                buttonArray.push(button);
                addChild(button);
            }
            
            restartButton = new Button(Texture.fromBitmapData(new BitmapData(200, 50, false, 0x800080), false), "RESTART");
            restartButton.fontSize = 24;
            restartButton.fontColor = Color.WHITE;
            restartButton.addEventListener(Event.TRIGGERED, onRestartButtonTriggered);
            restartButton.x = 465 / 2 - 100;
            restartButton.y = 465 / 2 - 25;
        }
        
        private function onRestartButtonTriggered(e:Event):void
        {
            removeChild(restartButton);
            
            turnNow = 0;
            turnText.text = "Turn : " + String(turnNow) + " / " + String(turnMax);
            
            //reset block
            var i:int, j:int;
            var block:Block;
            for (i = 0; i < blockNumWidth; i += 1)
            {
                for (j = 0; j < blockNumHeight; j += 1)
                {
                    block = blockArray[i][j];
                    block._id = Math.random() * blockTypeNum;
                    block.texture = Texture.fromTexture(blockTexture, new Rectangle(block._id * blockWidth, 0, blockWidth, blockWidth))
                    block.readjustSize();
                }
            }
            
            //reset buttons
            for (i = 0; i < 5; i += 1)
            {
                buttonArray[i].enabled = true;
            }
            
            previousZeroId = blockArray[0][0]._id;
            buttonArray[previousZeroId].enabled = false;
            
        }
        
        private function onTriggered(e:Event):void
        {
            button = e.target as Button;
            
            selectedButtonID = button.fontSize;
            
            //find same color and change them
            dfs(0, 0, blockArray[0][0]._id);
            blockArray[0][0]._id = -1;
            
            //switch block texture
            var i:int, j:int;
            var block:Block;
            for (i = 0; i < blockNumWidth; i += 1)
            {
                for (j = 0; j < blockNumHeight; j += 1)
                {
                    block = blockArray[i][j];
                    if (block._id < 0)
                    {
                        block._id = selectedButtonID;
                        block.texture = Texture.fromTexture(blockTexture, new Rectangle(selectedButtonID * blockWidth, 0, blockWidth, blockWidth))
                        block.readjustSize();
                    }
                }
            }
            
            //end game check
            gameEnd = true;
            
            for (i = 0; i < blockNumWidth; i += 1)
            {
                for (j = 0; j < blockNumHeight; j += 1)
                {
                    block = blockArray[i][j];
                    if (block._id != selectedButtonID)
                    {
                        gameEnd = false;
                        break;
                    }
                }
            }
            
            turnNow += 1;
            turnText.text = "Turn : " + String(turnNow) + " / " + String(turnMax);
            
            if (gameEnd == true || turnNow >= turnMax)
            {
                for (i = 0; i < 5; i += 1)
                {
                    buttonArray[i].enabled = false;
                }
                
                addChild(restartButton);
            }
            else
            {
                //change disable button
                buttonArray[previousZeroId].enabled = true;
                previousZeroId = blockArray[0][0]._id;
                buttonArray[previousZeroId].enabled = false;
            }
            
            
            
        }
        
        private function dfs(_x:int, _y:int, id:int):void
        {
            if (_x > 0)
            {
                if (blockArray[_x - 1][_y]._id == id)
                {
                    blockArray[_x - 1][_y]._id = -1;
                    dfs(_x - 1, _y, id);
                }
            }
            if (_x < blockNumWidth - 1)
            {
                if (blockArray[_x + 1][_y]._id == id)
                {
                    blockArray[_x + 1][_y]._id = -1;
                    dfs(_x + 1, _y, id);
                }
            }
            if (_y > 0)
            {
                if (blockArray[_x][_y - 1]._id == id)
                {
                    blockArray[_x][_y - 1]._id = -1;
                    dfs(_x, _y - 1, id);
                }
            }
            if (_y < blockNumWidth - 1)
            {
                if (blockArray[_x][_y + 1]._id == id)
                {
                    blockArray[_x][_y + 1]._id = -1;
                    dfs(_x, _y + 1, id);
                }
            }
            
        }
        
        private function initBlockTexture():void
        {
            //var bitmapData:BitmapData;
            //bitmapData = new BitmapData(50, 50, true, 0x00ffffff);
            
            
            //textureArray = [];
            
            
            //textureArray.push(drawBlock(0, colors[0], 0));
            //textureArray.push(drawBlock(3, colors[1], 1));
            //textureArray.push(drawBlock(4, colors[2], 2));
            //textureArray.push(drawBlock(5, colors[3], 3));
            //textureArray.push(drawBlock(6, colors[4], 4));
            
            bitmapData = new BitmapData(250, 50, true, 0x00ffffff);
            
            drawBlock(0, colors[0], 0);
            drawBlock(3, colors[1], 1);
            drawBlock(4, colors[2], 2);
            drawBlock(5, colors[3], 3);
            drawBlock(6, colors[4], 4);
            
            blockTexture = Texture.fromBitmapData(bitmapData, false);
            
        }
        
        private function drawBlock(pointNum:int, color:uint, index:int):void
        {
            
            
            var triangle:Shape;
            triangle = new Shape();
            
            
            
            var angle:Number;
            var i:int;
            //var glowFilter:GlowFilter = new GlowFilter(colors[0], 1);
            var bevelFilter:BevelFilter = new BevelFilter();
            bevelFilter.strength = .5;
            
            triangle.graphics.lineStyle(1, color);
            triangle.graphics.beginFill(color);
            
            if (pointNum == 0)
            {
                triangle.graphics.drawCircle(0, 0, jewelWidth);
            }
            else
            {
                
                triangle.graphics.moveTo(0, -jewelWidth);
                
                for (i = 0; i < pointNum; i += 1)
                {
                    angle = 2 * Math.PI / pointNum * i - Math.PI / 2;
                    triangle.graphics.lineTo(Math.cos(angle) * jewelWidth, Math.sin(angle) * jewelWidth);
                }
            }
            triangle.graphics.endFill();
            //triangle.rotation = -90;
            
            triangle.filters = [bevelFilter];
            
            //addChild(triangle);
            
            //bitmapData.draw(triangle, new Matrix(0, -1, 1, 0, 465 / 2, 465 / 2));
            bitmapData.draw(triangle, new Matrix(1, 0, 0, 1, blockWidth / 2 + index * blockWidth, blockWidth / 2));
            
            
            //return Texture.fromBitmapData(bitmapData, false);
        }
        
        private function initBlockArray():void
        {
            var i:int, j:int;
            var block:Block;
            var id:int;
            var color:uint;
            //var arr:Array = printRandomNumber(blockNumWidth * blockNumHeight, blockNumWidth * blockNumHeight);
            
            blockArray = [];
            
            for (i = 0; i < blockNumWidth; i += 1)
            {
                blockArray[i] = [];
                
                for (j = 0; j < blockNumHeight; j += 1)
                {
                    
                    id = int(Math.random() * blockTypeNum);
                    
                    //switch(id)
                    //{
                        //case 0:
                            //color = Color.RED;
                            //break;
                            //
                        //case 1:
                            //color = Color.YELLOW;
                            //break;
                            //
                        //case 2:
                            //color = Color.GREEN;
                            //break;
                            //
                        //case 3:
                            //color = Color.BLUE;
                            //break;
                            //
                        //case 4:
                            //color = Color.PURPLE;
                            //break;
                            //
                    //}
                    
                    block = new Block(Texture.fromTexture(blockTexture, new Rectangle(id*blockWidth, 0, blockWidth, blockWidth)));
                    
                    block._id = id;
                    
                    blockArray[i].push(block);
                    block.x = 465 / 2 + (j - blockNumWidth / 2) * blockWidth;
                    block.y = 465 / 2 + (i - blockNumHeight / 2) * blockHeight;
                    //block.x = (j - blockNumWidth / 2 + 1) * blockWidth;
                    //block.y = (i - blockNumHeight / 2 + 1) * blockHeight;
                    addChild(block);
                    //trace(block.x, block.y);
                }
            }
            
        }
        
        private function printRandomNumber(n:int, k:int) : Array
        {
            var original:Array=[];
            var result:Array=[];
            var i:int;
            var randInt:int;
            var temp:Object;
            
            for(i=0;i<n;i+=1)
            {
                original.push(i);
            }
            
            for(i=0;i<k;i+=1)
            {
                randInt = Math.random()*(n-i) + i;
                temp = original[i];
                original[i] = original[randInt];
                original[randInt] = temp;
                result.push(original[i]);
            }
            
            return result;
        }
        
    }

}