package {
    import com.bit101.components.Label;

    import com.bit101.components.NumericStepper;

    import com.bit101.components.PushButton;

    import com.bit101.components.Window;

    import flash.display.Sprite;

    import flash.events.Event;

    import flash.events.MouseEvent;

    import flash.display.Bitmap;

    import flash.display.BitmapData;

    import flash.geom.ColorTransform;

    import flash.geom.Matrix;

    import com.bit101.charts.LineChart;
    
    public class FlashTest extends Sprite {
        
        public var problemN:int = 12;

        public var fitnessMax:int = problemN * problemN;

        public var prevBestFitness:int = 0;

        public var bestFitness:int = 0;

        

        public var fitnessLineChart:LineChart;

        public var fitnessLineChartLabel:Label;

        public var chartRefreshCycle:int = 50;

        public var bestFitnessLineChart:LineChart;

        public var bestFitnessLineChartLabel:Label;

        public var bestData:Array = [];

        

        public var tile_width:int = 30;

        public var tile_height:int = 30;

        public var board_width:int = tile_width * problemN;

        public var queenSize:int = 30;

        

        public var tileBitmapData:BitmapData;

        public var tileBitmap:Bitmap;

        public var gridSprite:Sprite;

        

        public var queenBitmapData:BitmapData;

        public var queenBitmap:Bitmap;

        public var queenSprite:Sprite;

        

        public var generationNo:int = 0;

        public var endGenerationNo:int = 10000;

        public var populationNum:int = 50;

        public var population:Vector.<Vector.<int>>=new Vector.<Vector.<int>>(populationNum);

        public var populationScore:Vector.<int> = new Vector.<int>(populationNum);

        public var selectionExpect:Vector.<int>;

        

        public var queenGraphic:Sprite;

        

        public var eliteRate:Number = 0.05;

        public var parentRate:Number = 0.4;

        public var mutationRate:Number = 0.03;

        

        public var redQueenColt:ColorTransform;

        

        public var uiWindow:Window;

        public var startButton:PushButton;

        public var stopButton:PushButton;



        public var resetButton:PushButton;

        public var titleLabel:Label;

        public var generationLabel:Label;

        public var fitnessLabel:Label;

        public var nLabel:Label;

        public var nNumericStepper:NumericStepper;

        public var populationLabel:Label;

        public var populationNumericStepper:NumericStepper;

        public var parentLabel:Label;

        public var parentNumericStepper:NumericStepper;

        public var mutationLabel:Label;

        public var mutationNumericStepper:NumericStepper;

        public var boardMaxWidthLabel:Label;

        public var boardMaxWidthNumericStepper:NumericStepper;

        

        public var graphWindow:Window;
        

        public function FlashTest() {
            // write as3 code here..
            if (stage) init();

            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 

        {

            removeEventListener(Event.ADDED_TO_STAGE, init);

            // entry point

            

            stage.scaleMode = "noScale";

            
            tileBitmapData = new BitmapData(465, 465, true, 0x00ffffff);

            gridSprite = new Sprite();

            tileBitmap = new Bitmap(tileBitmapData);

            addChild(tileBitmap);

            

            initTileGrid(problemN, problemN);

            

            initPopulation(populationNum, problemN);

            

            queenBitmapData = new BitmapData(465, 465, true, 0x00ffffff);

            queenBitmap = new Bitmap(queenBitmapData);

            addChild(queenBitmap);

            

            queenGraphic = new Sprite();

            with (queenGraphic.graphics)

            {

                lineStyle(0, 0x000000);

                beginFill(0x000000);

                drawCircle(0, -12, 2);

                drawCircle(5, -10, 2);

                drawCircle(10, -8, 2);

                drawCircle(-5, -10, 2);

                drawCircle(-10, -8, 2);

                moveTo( -8, 0);

                lineTo( -10, -8);

                lineTo( -5, 0);

                lineTo( -5, -10);

                lineTo( -2, 0);

                lineTo( 0, -12);

                lineTo( 2, 0);

                lineTo( 5, -10);

                lineTo( 5, 0);

                lineTo( 10, -8);

                lineTo( 8, 0);

                

                lineTo( 6, 2);

                lineTo( 5, 5);

                lineTo( 8, 10);

                lineTo( -8, 10);

                lineTo( -5, 5);

                lineTo( -6, 2);

                lineTo( -8, 0);

                endFill();

                

                lineStyle(1, 0xffffff);

                moveTo(-4, 5);

                lineTo(4, 5);

                moveTo( -5, 2);

                lineTo(5, 2);

            }

            

            redQueenColt = new ColorTransform(0.5, 0.5, 0.5, 1, 255, 0, 0, 0);

            

            uiWindow = new Window(this, 300, 10, "Control");

            uiWindow.width = 150;

            uiWindow.height = 250;

            uiWindow.hasMinimizeButton = true;
            
            uiWindow.alpha = 0.7;

            startButton = new PushButton(uiWindow, 10, 30, "Start", onStart);

            startButton.width = 43;

            startButton.height = 40;

            stopButton = new PushButton(uiWindow, startButton.x + startButton.width, startButton.y, "Stop", onStop);

            stopButton.width = 43;

            stopButton.height = 40;

            resetButton = new PushButton(uiWindow, stopButton.x + stopButton.width, stopButton.y, "Reset", onReset);

            resetButton.width = 43;

            resetButton.height = 40;

            titleLabel = new Label(uiWindow, 10, startButton.y + startButton.height, "N-Queen Solver - with GA");

            generationLabel = new Label(uiWindow, 10, titleLabel.y + titleLabel.height, "Generation : " + String(generationNo) + " / " + String(endGenerationNo));

            fitnessLabel = new Label(uiWindow, 10, generationLabel.y + generationLabel.height, "Best Fit. : " + String(bestFitness));

            nLabel = new Label(uiWindow, 10, fitnessLabel.y + fitnessLabel.height, "N");

            nNumericStepper = new NumericStepper(uiWindow, uiWindow.width - 90, nLabel.y);

            nNumericStepper.step = 1;

            nNumericStepper.width = 80;

            nNumericStepper.minimum = 2;

            nNumericStepper.maximum = 50;

            nNumericStepper.value = problemN;

            //nNumericStepper.enabled = false;

            populationLabel = new Label(uiWindow, 10, nLabel.y + nLabel.height, "Population");

            populationNumericStepper = new NumericStepper(uiWindow, uiWindow.width - 90, populationLabel.y);

            populationNumericStepper.width = 80;

            populationNumericStepper.value = populationNum;

            populationNumericStepper.step = 50;

            populationNumericStepper.minimum = 50;

            parentLabel = new Label(uiWindow, 10, populationLabel.y + populationLabel.height, "Parent %");

            parentNumericStepper = new NumericStepper(uiWindow, uiWindow.width - 90, parentLabel.y);

            parentNumericStepper.width = 80;

            parentNumericStepper.value = parentRate * 100;

            parentNumericStepper.step = 5;

            parentNumericStepper.minimum = 10;

            mutationLabel = new Label(uiWindow, 10, parentLabel.y + parentLabel.height, "Mutation %");

            mutationNumericStepper = new NumericStepper(uiWindow, uiWindow.width - 90, mutationLabel.y, onChangeValue);

            mutationNumericStepper.name = "mu";

            mutationNumericStepper.width = 80;

            mutationNumericStepper.value = mutationRate * 100;

            mutationNumericStepper.step = 0.5;

            mutationNumericStepper.minimum = 0;

            boardMaxWidthLabel = new Label(uiWindow, 10, mutationLabel.y + mutationLabel.height, "Board Max");

            boardMaxWidthNumericStepper = new NumericStepper(uiWindow, uiWindow.width - 90, boardMaxWidthLabel.y);

            boardMaxWidthNumericStepper.width = 80;

            boardMaxWidthNumericStepper.value = problemN * tile_width;

            boardMaxWidthNumericStepper.step = 20;

            boardMaxWidthNumericStepper.minimum = 200;

            boardMaxWidthNumericStepper.maximum = 460;

            

            graphWindow = new Window(this, 5, 300, "Graph");

            graphWindow.width = 455;

            graphWindow.height = 150;

            graphWindow.hasMinimizeButton = true;
            
            graphWindow.alpha = 0.7;

            

            fitnessLineChart = new LineChart(graphWindow, 40, 40, null);

            fitnessLineChart.showGrid = true;

            fitnessLineChart.showScaleLabels = true;

            fitnessLineChart.lineColor = 0xff0080;

            fitnessLineChart.width = 170;

            fitnessLineChartLabel = new Label(graphWindow, 10, fitnessLineChart.y - 20, "All Population Fitness");

            fitnessLineChartLabel.x = fitnessLineChart.x;

            fitnessLineChart.autoScale = false;

            fitnessLineChart.maximum = fitnessMax;

            fitnessLineChart.minimum = -1 * fitnessMax;

            

            bestFitnessLineChart = new LineChart(graphWindow, fitnessLineChart.x + fitnessLineChart.width + 50 + 5, fitnessLineChart.y, null);

            bestFitnessLineChart.showGrid = true;

            bestFitnessLineChart.showScaleLabels = true;

            bestFitnessLineChart.lineColor = 0x00ff00;

            bestFitnessLineChart.width = 170;

            bestFitnessLineChartLabel = new Label(graphWindow, 10, bestFitnessLineChart.y - 20, "Best Population Fitness");

            bestFitnessLineChartLabel.x = bestFitnessLineChart.x;

            bestFitnessLineChart.autoScale = false;

            bestFitnessLineChart.maximum = fitnessMax;

            bestFitnessLineChart.minimum = 0;

            

            

        }

        

        private function onChangeValue(e:Event):void

        {

            switch(e.target.name)

            {

                case "mu": //mutation

                    mutationRate = e.target.value / 100;

                    

                    break;

            }

        }

        

        private function onStart(e:Event):void

        {

            addEventListener(Event.ENTER_FRAME, onLoop);

            startButton.enabled = false;

            stopButton.enabled = true;

            resetButton.enabled = false;

            

            nNumericStepper.enabled = false;

            populationNumericStepper.enabled = false;

            parentNumericStepper.enabled = false;

        }

        

        private function onStop(e:Event):void

        {

            removeEventListener(Event.ENTER_FRAME, onLoop);

            stopButton.enabled = false;

            startButton.enabled = true;

            resetButton.enabled = true;

            

            nNumericStepper.enabled = true;

            populationNumericStepper.enabled = true;

            parentNumericStepper.enabled = true;

        }

        

        private function onReset(e:Event):void

        {

            problemN = nNumericStepper.value;

            fitnessMax = problemN * problemN;

            board_width = boardMaxWidthNumericStepper.value;

            tile_width = board_width / problemN;

            tile_height = tile_width;

            

            initTileGrid(problemN, problemN);

            

            generationNo = 0;

            populationNum = populationNumericStepper.value;

            initPopulation(populationNum, problemN);

            

            drawBestPosition(population[0]);

            bestFitness = evalPopulation(population[0]);

            

            drawUI();

            

            fitnessLineChart.maximum = fitnessMax;

            fitnessLineChart.minimum = -1 * fitnessMax;

            bestFitnessLineChart.maximum = fitnessMax;

            bestFitnessLineChart.minimum = 0;

            

            bestData = [];

        }

        

        private function onLoop(e:Event):void

        {

            var i:int;

            var j:int;

            var temp:int;

            

            //select

            sortDescending();

            

            var selectionSum:int = 0;

            selectionExpect = new Vector.<int>(populationNum * parentRate);

            for (i = 0; i < populationNum * parentRate ; i += 1)

            {

                selectionExpect[i] = Math.max(1, populationScore[i]);

                selectionSum += selectionExpect[i];

                //trace(selectionExpect[i]);

            }

            

            

            

            //crossover

            for (i = populationNum * eliteRate; i < populationNum; i += 1) //i = pop * elite => elite preserve; not elite => new pop

            {

                var firstParent:int = Math.random() * selectionSum;

                var secondParent:int = Math.random() * selectionSum;

                

                for (j = 0; j < selectionExpect.length; j += 1)

                {

                    if (firstParent < selectionExpect[j])

                    {

                        firstParent = j;

                        break;

                    }

                    

                    firstParent -= selectionExpect[j];

                }

                

                for (j = 0; j < selectionExpect.length; j += 1)

                {

                    if (secondParent < selectionExpect[j])

                    {

                        secondParent = j;

                        break;

                    }

                    

                    secondParent -= selectionExpect[j];

                }

                

                if (firstParent == secondParent) //same parent - reSelect

                {

                    i -= 1;

                    continue;

                    //trace("HI");

                }

                else //find crossover point

                {

                    for (var k:int = 0; k < problemN; k += 1)

                    {

                        population[i][k] = population[firstParent][k];

                    }

                    

                    var crossOverPoint1:int = Math.random() * (problemN - 1);

                    var crossOverPoint2:int = int( Math.random() * (problemN - crossOverPoint1) ) + crossOverPoint1;

                    //trace(crossOverPoint1, crossOverPoint2);

                    

                    for (k = crossOverPoint1; k < crossOverPoint2; k += 1)

                    {

                        if (population[i][k] != population[secondParent][k])

                        {

                            for (var l:int = 0; l < problemN; l += 1)

                            {

                                if (population[i][l] == population[secondParent][k] && l != k) 

                                {

                                    temp = population[i][l];

                                    population[i][l] = population[i][k];

                                    population[i][k] = temp;

                                    break;

                                }

                            }

                        }

                        else

                        {

                            population[i][k] = population[secondParent][k];

                        }

                        

                    }

                    

                }

            }

            

            //mutate

            for (i = populationNum * eliteRate; i < populationNum; i += 1) //not elite => mutation

            {

                for (j = 0; j < problemN; j += 1)

                {

                    if (Math.random() < mutationRate)

                    {

                        var second:int = Math.random() * problemN;

                        while (second == j)

                        {

                            second = Math.random() * problemN; //trace("HI" + j);

                        }                        

                        

                        temp = population[i][j];

                        population[i][j] = population[i][second];

                        population[i][second] = temp;

                    }

                }

            }

            

            prevBestFitness = bestFitness;

            var bestPopulationIndex:int = 0;

            

            for (i = 0; i < populationNum; i += 1)

            {

                populationScore[i] = evalPopulation(population[i]);

                if (Math.max(bestFitness, populationScore[i]) != bestFitness)

                {

                    bestFitness = Math.max(bestFitness, populationScore[i]);

                    bestPopulationIndex = i;

                }

            }

            

            generationNo += 1;

            

            //draw Route & bestChart

            bestData.push(bestFitness);

            

            if(prevBestFitness != bestFitness)

            {

                drawBestPosition(population[bestPopulationIndex]);

                drawBestChart();

            }

            

            drawUI();

            

            if (generationNo >= endGenerationNo || evalPopulation(population[bestPopulationIndex]) == fitnessMax)

            {

                sortDescending();

                

                drawChart(true);

                

                onStop(new Event(MouseEvent.CLICK));

                //removeEventListener(Event.ENTER_FRAME, onLoop);

            }

            

        }

        

        private function drawBestChart():void

        {

            bestFitnessLineChart.data = bestData;

            

            bestFitnessLineChart.draw();

        }

        

        private function drawChart(sw:Boolean):void

        {

            if (generationNo % chartRefreshCycle == 2 || sw == true)

            {

                var dataArray:Array = [];

                for (var i:int = 0; i < populationScore.length; i += 1)

                {

                    dataArray.push(populationScore[i]);

                }

                fitnessLineChart.data = dataArray;

                fitnessLineChart.minimum = 0;

                fitnessLineChart.draw();

                //trace(dataArray);

            }

        }

        

        private function drawUI():void

        {

            generationLabel.text = "Generation : " + String(generationNo) + " / " + String(endGenerationNo);

            fitnessLabel.text = "Best Fit. : " + String(bestFitness);

        }

        

        private function drawBestPosition(pop:Vector.<int>):void

        {

            queenBitmapData.fillRect(queenBitmapData.rect, 0x00ffffff);

            var mat:Matrix;

            var redArray:Array = [];

            for (var j:int = 0; j < pop.length; j += 1)

            {

                redArray.push(0);

            }

            

            for (var i:int = 0; i < pop.length - 1; i += 1) //diagonal check - left down, right down

            {

                for (j = i + 1; j < pop.length; j += 1)

                {

                    if (Math.abs(pop[i] - pop[j]) == Math.abs(i - j))

                    {

                        redArray[i] = 1;

                        redArray[j] = 1;

                    }

                }

            }

            

            for (i = 0; i < pop.length; i += 1)

            {

                mat = new Matrix();

                if (tile_width < queenSize)

                {

                    mat.scale(tile_width / queenSize, tile_width / queenSize);

                }

                

                mat.translate((pop[i]+1) * tile_width, (i+1) * tile_height);

                mat.translate( -1 * tile_width / 2, -1 * tile_height / 2);

                

                

                if (redArray[i] == 0)

                {

                    queenBitmapData.draw(queenGraphic, mat);

                }

                else //draw Red Queen

                {

                    queenBitmapData.draw(queenGraphic, mat, redQueenColt);

                }

                

            }

            

            

        }

        

        private function sortDescending():void

        {

            var temp:Array = [];

            var obj:Object;

            

            for (var i:int = 0; i < population.length; i += 1)

            {

                obj = new Object();

                obj.population = population[i];

                obj.score = populationScore[i];

                temp.push(obj);

            }

            

            temp.sortOn("score", Array.NUMERIC | Array.DESCENDING);

            

            for (i = 0; i < population.length; i += 1)

            {

                population[i] = temp[i].population;

                populationScore[i] = temp[i].score;

            }

            

            drawChart(false);

            

        }

        

        private function initTileGrid(tileNum_X:int, tileNum_Y:int):void

        {

            tileBitmapData.fillRect(tileBitmapData.rect, 0x00ffffff);

            

            //print Tile Grid

            gridSprite.graphics.clear();

            gridSprite.graphics.lineStyle(1, 0xffffff, 1);

            gridSprite.graphics.beginFill(0xc0c0c0, 1);

            gridSprite.graphics.drawRect(0, 0, tileNum_X * tile_width, tileNum_Y * tile_height);

            gridSprite.graphics.endFill();

            for (var i:int = 0; i < tileNum_X; i += 1)

            {

                gridSprite.graphics.moveTo(i * tile_width, 0);

                gridSprite.graphics.lineTo(i * tile_width, tileNum_Y * tile_height);

            }

            for (i = 0; i < tileNum_Y; i += 1)

            {

                gridSprite.graphics.moveTo(0, i * tile_height);

                gridSprite.graphics.lineTo(tileNum_X * tile_width, i * tile_height);

            }

            

            tileBitmapData.draw(gridSprite);

            

            

        }

        

        private function initPopulation(populationNum:int, randomNum:int):void

        {

            for (var i:int = 0; i < populationNum; i += 1)

            {

                var onePopulation:Array = printRandomNumber(randomNum, randomNum);

                population[i] = new Vector.<int>(randomNum);

                

                for (var j:int = 0; j < randomNum; j += 1)

                {

                    population[i][j] = onePopulation[j];

                }

                //trace(population[i]);

                

                //init Score

                populationScore[i] = evalPopulation(population[i]);

                //trace("population: ", population[i], "score: ", populationScore[i]);

            }

            

            generationNo += 1;

        }

        

        private function evalPopulation(pop:Vector.<int>):int

        {

            var score:int = problemN * problemN;

            

            for (var i:int = 0; i < pop.length - 1; i += 1) //diagonal check - left down, right down

            {

                for (var j:int = i + 1; j < pop.length; j += 1)

                {

                    if (Math.abs(pop[i] - pop[j]) == Math.abs(i - j))

                    {

                        score -= problemN;

                    }

                }

            }

            

            return score;

            

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