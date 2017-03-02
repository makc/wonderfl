// forked from FTMSuperfly's Random Grid Cell Sizing

package
{
    import flash.text.*;
    import com.greensock.TweenMax;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.MouseEvent;

    

    /**

     * ...

     * @author J

     */

    public class DaGrid extends Sprite 
    {
        public var stageWidth:int;
        public var stageHeight:int;
        public var gridWidth:Number;//All the dimensions of your pictures must be factors of gridWidth
        public var gridColumns:int;
        public var gridRows:int;
        public var numVariants:int; // How many different sizes of square?
        

        public var container:Sprite;

        public var pictureGrid:Array;//keeps track of what grid cells are taken by previous placement of pictures

        public var arrayOfPictures:Array; // this just creates some random pictures and adds them to the array. In reality you would create your own array of pictures.

        

        

        public function DaGrid()

        {
            /*This picture placement is an original work and protected under creative commons license
            *All use of this work including forks, edits, changes or derivitives must be credited to:
            *
            *    www.shaedo.com
            *
            */

            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.addEventListener(Event.RESIZE, onResizeHandler, false, 0, true);
            stage.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);

            

            stageWidth = stage.stageWidth;
            stageHeight = stage.stageHeight;

            gridWidth = 25;//All the dimensions of your pictures must be factors of gridWidth

            gridColumns = stageWidth / gridWidth;

            gridRows = stageHeight / gridWidth;

            numVariants = 3; // How many different sizes of square?

            StartTheThing();
        }

        

        private function onMouseClick(e:MouseEvent):void 
        {
            StartTheThing();
        }

        public function StartTheThing():void 
        {
            if (container) removeChild(container);
            container = new Sprite();
            addChild(container);

            pictureGrid = createGrid();//keeps track of what grid cells are taken by previous placement of pictures

            //draw a grid to demonstrate how the pictures will be layed down.

            //each grid square is gridWidth * gridWidth 

            //The grid of course is just so you can see visually as it happens.

            drawGrid(false);

            // Matt: Made the number of pictures created a function of the grid size - approx!

            // this just creates some random pictures and adds them to the array. In reality you would create your own array of pictures.

            arrayOfPictures = createPictures(gridColumns * gridRows); 

            addPictures(arrayOfPictures);

            var m:MovieClip;
            var text:TextField;
            var tf:TextFormat;
            var i:int;

            for (i = 0; i < arrayOfPictures.length; i++)
            {
                text= new TextField();
                tf = new TextFormat(i as String, 8, 0xFFFFFF, true);
                text.x = 2;
                m = arrayOfPictures[i];
                m.x = m.targetX;
                m.y = m.targetY;
                m.buttonMode = true;
                m.addChild(text);
            }

            stage.dispatchEvent(new Event(Event.RESIZE));

            for (i = 0; i < arrayOfPictures.length; i++)
            {
                TweenMax.from( arrayOfPictures[i], 1, { alpha:0, delay:Math.random() } );
            }

        }

        

        private function onResizeHandler(e:Event):void 

        {
            if (container) 
            {
                container.x = (stage.stageWidth * 0.5) - (container.width * 0.5);
                container.y = (stage.stageHeight * 0.5) - (container.height * 0.5);
            }

        }

        

        

        

        public function createGrid():Array // this creates a grid that keeps track of what cells have been already occupied by previous pictures

        {

            var a:Array = new Array();

            var b:Array;

            for (var i:int = 0; i < gridColumns; i++)

            {

                b = new Array();

                for (var j:int = 0; j < gridRows; j++)

                {

                    b.push(false);//false indicates that the grid square is not yet taken

                }

                b.push(true);// This creates a cap at the end of the COLUMN to prevent pictures being placed off the edge

                a.push(b);

            }

            

            b = new Array();// This creates a cap at the end of the ROW to prevent pictures being placed off the edge

            for (var k:int = 0; k < gridRows; k++)

            {

                b.push(true);//false indicates that the grid square is not yet taken

            }

            a.push(b);

            

            return(a);

        }

        

        // iterate through the grid, check for an empty grid square, check if adjacent grid squares for size of picture are unoccupied, set the pictures target coordinates

        public function addPictures(picArray:Array):void 

        {

            for(var i:int=0;i<picArray.length;i++)

            //run through each picture

            {

                var m:MovieClip = picArray[i];

                

                searchLoop: for (var r:int = 0; r < gridRows; r++)

                //run through each row

                {

                    for (var c:int = 0; c < gridColumns; c++)

                    //run through each column

                    {

                        if (pictureGrid[c][r] == false)

                        //if the current square is unoccupied

                        {

                            // Matt: iterate through adjacent grid squares and check if available

                            var safe:Boolean = true;

                            for (var x:int = 0; x < m.gridSquares * 3; x++)

                            {

                                for (var y:int = 0; y < m.gridSquares * 2; y++)

                                {

                                    if (pictureGrid[c + x][r + y] == true)

                                    {

                                        safe = false;

                                        break; // from the "for y" loop

                                    }

                                }

                                if (safe==false) {break} // from the "for x" loop

                            }

                            

                            if (safe==true) // Matt: Probably a better way to pass the exit status of the for loops than this, but since I don't know AS...

                            {

                                m.targetX = c * gridWidth;

                                m.targetY = r * gridWidth;

                                container.addChild(m);

                                

                                for (x = 0; x < m.gridSquares * 3; x++)

                                {

                                    for (y = 0; y < m.gridSquares * 2; y++)

                                    {

                                        pictureGrid[c + x][r + y] = true; //Mark grid squares as occupied.

                                    }

                                }

                                

                                break searchLoop;//from the switch statement

                            }

                        }

                    }

                }

            }

        }

        

        public function createPictures(n:int=30):Array

        {

            var a:Array = new Array();

            for (var i:int = 0; i < n; i++)

            {

                var r:int = Math.random() * numVariants + 1; // random

                var c:int = Math.random() * numVariants + 1; // control

                var d:int = Math.random() * 1 + 1; // horizonal or vertical

                if (r <= c)

                // make less squares the bigger they are.

                {

                    var rectX:int = gridWidth * r * 3 - 1;

                    var rectY:int = gridWidth * r * 2 - 1;

                    var m:MovieClip = new MovieClip();

                    m.graphics.beginFill(Math.random() * 0xFFFFFF);

                    m.graphics.drawRect(0, 0, rectX, rectY);

                    m.gridSquares = r;

                    a.push(m);

                }

            }

            return(a);

        }

        

        public function drawGrid(value:Boolean = true):void

        {

        // Matt: Removed: var columns:int = 11; var rows:int = 8; var sizeParam:Number = 50;

        // Matt: Using gridColumns; gridRows; gridWidth; instead.



            if (value) 

            {

                var i:int;

                var _grid:Sprite = new Sprite();

                container.addChild(_grid);

                _grid.graphics.lineStyle(2,0xDDDDDD);//what ever colour you want

                

                for (i = 0; i < gridColumns+1; i ++)//draws columns

                {

                    _grid.graphics.moveTo(i * gridWidth, 0);

                    _grid.graphics.lineTo(i * gridWidth, gridRows * gridWidth);

                }

                for (i= 0; i < gridRows +1; i ++)//draws rows

                {

                    _grid.graphics.moveTo(0, i * gridWidth);

                    _grid.graphics.lineTo(gridColumns * gridWidth, i * gridWidth);

                }

            

            }

        }    

        

        

        

        

        

    }

    

}















