package {
    
    import com.bit101.charts.LineChart;
    import com.bit101.components.Label;
    import com.bit101.components.PushButton;
    import com.bit101.components.TextArea;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.display.Sprite;

    public class FlashTest extends Sprite {
        
        public var learnObject:Array = [ 
            "00", "0",
            "01", "1",
            "10", "1",
            "11", "0" 
            //"10": 1,
            //"01": 0
        ];
        
        public var i:int = 0;
        public var oneIter:int = 1000;
        public var iter:int = 30000;
        public var learnRate:Number = 0.25;
        
        public var inputLayer:Layer;
        public var hiddenLayer:Layer;
        public var outputLayer:Layer;
        
        public var errorChart:LineChart;
        public var proceedNumLabel:Label;
        public var debugLabel:Label;
        public var testButton:PushButton;
        public var testTextArea:TextArea;
        public var resetButton:PushButton;
        
        public var proceedEnd:Boolean = false;
        
        public var in0w0:PushButton;
        public var in0w1:PushButton;
        public var in1w0:PushButton;
        public var in1w1:PushButton;
        public var in2w0:PushButton;
        public var in2w1:PushButton;
        public var hn0w0:PushButton;
        public var hn1w0:PushButton;
        public var hn2w0:PushButton;
        
        public var input0Label:Label;
        public var input1Label:Label;
        public var biase1Label:Label;
        public var hidden0Label:Label;
        public var hidden1Label:Label;
        public var biase2Label:Label;

        public function FlashTest() {
            // write as3 code here..
            
            this.graphics.beginFill(0xdddddd);
            this.graphics.drawRect(0,0,465,465);
            this.graphics.endFill();
            
            var neuron:Neuron;
            inputLayer = new Layer();
            
            neuron = new Neuron(2);
            inputLayer.neurons.push(neuron);
            neuron = new Neuron(2);
            inputLayer.neurons.push(neuron);
            neuron = new Neuron(2); //biased One
            inputLayer.neurons.push(neuron);
            
            hiddenLayer = new Layer();
            
            neuron = new Neuron(1);
            hiddenLayer.neurons.push(neuron);
            neuron = new Neuron(1);
            hiddenLayer.neurons.push(neuron);
            neuron = new Neuron(1); //another biased One
            hiddenLayer.neurons.push(neuron);
            
            outputLayer = new Layer();
            neuron = new Neuron(0);
            outputLayer.neurons.push(neuron);
            
            // Nguyen-Widrow Initialization - for all Input to Hidden w
            
            var beta:Number;
            var normHidden1:Number;
            var normHidden2:Number;
            
            beta = 0.7 * Math.pow(hiddenLayer.neurons.length - 1, (1 / (inputLayer.neurons.length - 1)));
            normHidden1 = Math.sqrt(inputLayer.neurons[0].w[0] * inputLayer.neurons[0].w[0] + inputLayer.neurons[1].w[0] * inputLayer.neurons[1].w[0] + inputLayer.neurons[2].w[0] * inputLayer.neurons[2].w[0]);
            normHidden2 = Math.sqrt(inputLayer.neurons[0].w[1] * inputLayer.neurons[0].w[1] + inputLayer.neurons[1].w[1] * inputLayer.neurons[1].w[1] + inputLayer.neurons[2].w[1] * inputLayer.neurons[2].w[1]);
            
            inputLayer.neurons[0].w[0] *= beta / normHidden1;
            inputLayer.neurons[1].w[0] *= beta / normHidden1;
            inputLayer.neurons[2].w[0] *= beta / normHidden1;
            inputLayer.neurons[0].w[1] *= beta / normHidden2;
            inputLayer.neurons[1].w[1] *= beta / normHidden2;
            inputLayer.neurons[2].w[1] *= beta / normHidden2;
            
            proceedNumLabel = new Label(this, 10, 10, "Proceed #0");
            errorChart = new LineChart(this, 10, proceedNumLabel.y + proceedNumLabel.height + 5);
            errorChart.data = [];
            
            in0w0 = new PushButton(this, 465 / 2, errorChart.y, "");
            in0w0.width = 50;
            in0w1 = new PushButton(this, in0w0.x, in0w0.y + in0w0.height, "");
            in0w1.width = 50;
            in1w0 = new PushButton(this, in0w0.x + in0w0.width + 30, in0w0.y, "");
            in1w0.width = 50;
            in1w1 = new PushButton(this, in1w0.x, in1w0.y + in1w0.height, "");
            in1w1.width = 50;
            in2w0 = new PushButton(this, in1w0.x + in1w0.width + 30, in1w0.y, "");
            in2w0.width = 50;
            in2w1 = new PushButton(this, in2w0.x, in2w0.y + in2w0.height, "");
            in2w1.width = 50;
            
            hn0w0 = new PushButton(this, in0w0.x, in0w0.y + in0w0.height + 60, "");
            hn0w0.width = 50;
            hn1w0 = new PushButton(this, in1w0.x, hn0w0.y, "");
            hn1w0.width = 50;
            hn2w0 = new PushButton(this, in2w0.x, hn1w0.y, "");
            hn2w0.width = 50;
            
            input0Label = new Label(this, in0w0.x + in0w0.width / 2, in0w0.y - 20, "input 0");
            input0Label.x -= input0Label.width / 2;
            input1Label = new Label(this, in1w0.x + in1w0.width / 2, in1w0.y - 20, "input 1");
            input1Label.x -= input1Label.width / 2;
            biase1Label = new Label(this, in2w0.x + in2w0.width / 2, in2w0.y - 20, "biase 1");
            biase1Label.x -= biase1Label.width / 2;
            
            hidden0Label = new Label(this, hn0w0.x + hn0w0.width / 2, hn0w0.y - 20, "hidden 0");
            hidden0Label.x -= hidden0Label.width / 2;
            hidden1Label = new Label(this, hn1w0.x + hn1w0.width / 2, hn1w0.y - 20, "hidden 1");
            hidden1Label.x -= hidden1Label.width / 2;
            biase2Label = new Label(this, hn2w0.x + hn2w0.width / 2, hn2w0.y - 20, "biase 2");
            biase2Label.x -= biase2Label.width / 2;
            
            
            
            debugLabel = new Label(this, 10, errorChart.y + errorChart.height + 5, "");
            
            testButton = new PushButton(this, 10, debugLabel.y + debugLabel.height + 20, "Test", onTest);
            testTextArea = new TextArea(this, 10, testButton.y + testButton.height + 5, "");
            testTextArea.width = 465 - 20;
            testTextArea.height = 465 - 10 - testTextArea.y;
            
            resetButton = new PushButton(this, testButton.x + testButton.width + 10, testButton.y, "Reset", onReset);
            
            addEventListener(Event.ENTER_FRAME, onLoop);
        }
        
        public function onReset(e:Event):void
        {
            if (hasEventListener(Event.ENTER_FRAME))
            {
                removeEventListener(Event.ENTER_FRAME, onLoop);
            }
            
            inputLayer.neurons[0].resetW(2);
            inputLayer.neurons[1].resetW(2);
            inputLayer.neurons[2].resetW(2);
            
            hiddenLayer.neurons[0].resetW(1);
            hiddenLayer.neurons[1].resetW(1);
            hiddenLayer.neurons[2].resetW(1);
            
            i = 0;
            proceedEnd = false;
            
            errorChart.data = [];
            
            addEventListener(Event.ENTER_FRAME, onLoop);
        }
        
        public function onTest(e:Event):void
        {
            var input:String;
            var input_0:int;
            var input_1:int;
            var s:int;
            var ideal:int;

            var arr:Array = printRandomNumber(learnObject.length / 2, learnObject.length / 2);
            
            for (s = 0; s < arr.length; s += 1)
            {
                input_0 = parseInt(learnObject[arr[s] * 2].substr(0, 1));
                input_1 = parseInt(learnObject[arr[s] * 2].substr(1, 1));
                
                inputLayer.neurons[0].output = sigmoid(input_0);
                inputLayer.neurons[1].output = sigmoid(input_1);
                inputLayer.neurons[2].output = 1; //biased
                
                hiddenLayer.neurons[0].input = inputLayer.neurons[0].output * inputLayer.neurons[0].w[0] + inputLayer.neurons[1].output * inputLayer.neurons[1].w[0] + inputLayer.neurons[2].output * inputLayer.neurons[2].w[0];
                hiddenLayer.neurons[1].input = inputLayer.neurons[0].output * inputLayer.neurons[0].w[1] + inputLayer.neurons[1].output * inputLayer.neurons[1].w[1] + inputLayer.neurons[2].output * inputLayer.neurons[2].w[1];
                
                hiddenLayer.neurons[0].output = sigmoid(hiddenLayer.neurons[0].input);
                hiddenLayer.neurons[1].output = sigmoid(hiddenLayer.neurons[1].input);
                hiddenLayer.neurons[2].output = 1; //biased
               
                outputLayer.neurons[0].input = hiddenLayer.neurons[0].output * hiddenLayer.neurons[0].w[0] + hiddenLayer.neurons[1].output * hiddenLayer.neurons[1].w[0] + hiddenLayer.neurons[1].output * hiddenLayer.neurons[2].w[0];
                outputLayer.neurons[0].output = sigmoid(outputLayer.neurons[0].input);
                
                ideal = parseInt(learnObject[arr[s] * 2 + 1]);
                
                if (ideal == 0)
                {
                    testTextArea.text += "Input : " + learnObject[arr[s] * 2] + "\t Output : " + String(outputLayer.neurons[0].output) + "\t Ideal : " + learnObject[arr[s] * 2 + 1] + "\t Error : " + String(int(outputLayer.neurons[0].output * 10000) / 100) + " % \n";
                }
                else
                {
                    testTextArea.text += "Input : " + learnObject[arr[s] * 2] + "\t Output : " + String(outputLayer.neurons[0].output) + "\t Ideal : " + learnObject[arr[s] * 2 + 1] + "\t Error : " + String(int((ideal - outputLayer.neurons[0].output)/ideal * 10000) / 100) + " % \n";
                }                    
            }
        }
        
        public function onLoop(e:Event):void
        {
            var input:String;
            var sum:Number;
            var error:Number;
            var sumError:Number = 0;
            var input_0:int;
            var input_1:int;
            var j:int;
            var sigmaOutput:Number;
            var s:int;
            var arr:Array;
            var ideal:int;
            
            if (true)
            {
                for (j = 0; j < oneIter; j += 1)
                {
                    sumError = 0;
                    
                    arr = printRandomNumber(learnObject.length / 2 , learnObject.length / 2);
                    
                    i += 1;

                    for (s = 0; s < arr.length; s += 1)
                    {
                        input_0 = parseInt(learnObject[arr[s] * 2].substr(0, 1));
                        input_1 = parseInt(learnObject[arr[s] * 2].substr(1, 1));
                        
                        inputLayer.neurons[0].output = sigmoid(input_0);
                        inputLayer.neurons[1].output = sigmoid(input_1);
                        inputLayer.neurons[2].output = 1; //biased
                        
                        hiddenLayer.neurons[0].input = inputLayer.neurons[0].output * inputLayer.neurons[0].w[0] + inputLayer.neurons[1].output * inputLayer.neurons[1].w[0] + inputLayer.neurons[2].output * inputLayer.neurons[2].w[0];
                        hiddenLayer.neurons[1].input = inputLayer.neurons[0].output * inputLayer.neurons[0].w[1] + inputLayer.neurons[1].output * inputLayer.neurons[1].w[1] + inputLayer.neurons[2].output * inputLayer.neurons[2].w[1];
                        
                        hiddenLayer.neurons[0].output = sigmoid(hiddenLayer.neurons[0].input);
                        hiddenLayer.neurons[1].output = sigmoid(hiddenLayer.neurons[1].input);
                        hiddenLayer.neurons[2].output = 1; //biased
                        
                        outputLayer.neurons[0].input = hiddenLayer.neurons[0].output * hiddenLayer.neurons[0].w[0] + hiddenLayer.neurons[1].output * hiddenLayer.neurons[1].w[0] + hiddenLayer.neurons[1].output * hiddenLayer.neurons[2].w[0];
                        outputLayer.neurons[0].output = sigmoid(outputLayer.neurons[0].input);
                        
                        error = parseInt(learnObject[arr[s] * 2 + 1]) - outputLayer.neurons[0].output;
                        sumError += error * error;
                        
                        sigmaOutput = error * outputLayer.neurons[0].output * (1 - outputLayer.neurons[0].output);
                        
                        //back-propagation Algorithm
                        
                        hiddenLayer.neurons[0].w[0] += learnRate * hiddenLayer.neurons[0].output * sigmaOutput;
                        hiddenLayer.neurons[1].w[0] += learnRate * hiddenLayer.neurons[1].output * sigmaOutput;
                        hiddenLayer.neurons[2].w[0] += learnRate * hiddenLayer.neurons[2].output * sigmaOutput;
                        
                        //inputLayer.neurons[0].w[0] += learnRate * error * inputLayer.neurons[0].output * hiddenLayer.neurons[0].output * (1 - hiddenLayer.neurons[0].output);
                        //inputLayer.neurons[0].w[1] += learnRate * error * inputLayer.neurons[0].output * hiddenLayer.neurons[1].output * (1 - hiddenLayer.neurons[1].output);
                        //inputLayer.neurons[1].w[0] += learnRate * error * inputLayer.neurons[1].output * hiddenLayer.neurons[0].output * (1 - hiddenLayer.neurons[0].output);
                        //inputLayer.neurons[1].w[1] += learnRate * error * inputLayer.neurons[1].output * hiddenLayer.neurons[1].output * (1 - hiddenLayer.neurons[1].output);
                        //inputLayer.neurons[2].w[0] += learnRate * error * inputLayer.neurons[2].output * hiddenLayer.neurons[0].output * (1 - hiddenLayer.neurons[0].output);
                        //inputLayer.neurons[2].w[1] += learnRate * error * inputLayer.neurons[2].output * hiddenLayer.neurons[1].output * (1 - hiddenLayer.neurons[1].output);
                        
                        
                        inputLayer.neurons[0].w[0] += learnRate * sigmaOutput * hiddenLayer.neurons[0].w[0] * inputLayer.neurons[0].output * hiddenLayer.neurons[0].output * (1 - hiddenLayer.neurons[0].output);
                        inputLayer.neurons[0].w[1] += learnRate * sigmaOutput * hiddenLayer.neurons[1].w[0] * inputLayer.neurons[0].output * hiddenLayer.neurons[1].output * (1 - hiddenLayer.neurons[1].output);
                        inputLayer.neurons[1].w[0] += learnRate * sigmaOutput * hiddenLayer.neurons[0].w[0] * inputLayer.neurons[1].output * hiddenLayer.neurons[0].output * (1 - hiddenLayer.neurons[0].output);
                        inputLayer.neurons[1].w[1] += learnRate * sigmaOutput * hiddenLayer.neurons[1].w[0] * inputLayer.neurons[1].output * hiddenLayer.neurons[1].output * (1 - hiddenLayer.neurons[1].output);
                        inputLayer.neurons[2].w[0] += learnRate * sigmaOutput * hiddenLayer.neurons[0].w[0] * inputLayer.neurons[2].output * hiddenLayer.neurons[0].output * (1 - hiddenLayer.neurons[0].output);
                        inputLayer.neurons[2].w[1] += learnRate * sigmaOutput * hiddenLayer.neurons[1].w[0] * inputLayer.neurons[2].output * hiddenLayer.neurons[1].output * (1 - hiddenLayer.neurons[1].output);
                        
                        
                    }
                    
                    if (sumError < 0.001)

                  {
                        //i = iter + 1;
                        proceedEnd = true;
                        break;
                    }
                }
                
                proceedNumLabel.text = "Proceed #" + String(i);
                
                errorChart.data.push(sumError);
                errorChart.draw();
                
                debugLabel.text = "Sum of Error : " + String(sumError);
                
                in0w0.label = String(int(inputLayer.neurons[0].w[0] * 10000) / 10000);
                in0w1.label = String(int(inputLayer.neurons[0].w[1] * 10000) / 10000);
                in1w0.label = String(int(inputLayer.neurons[1].w[0] * 10000) / 10000);
                in1w1.label = String(int(inputLayer.neurons[1].w[1] * 10000) / 10000);
                in2w0.label = String(int(inputLayer.neurons[2].w[0] * 10000) / 10000);
                in2w1.label = String(int(inputLayer.neurons[2].w[1] * 10000) / 10000);
                hn0w0.label = String(int(hiddenLayer.neurons[0].w[0] * 10000) / 10000);
                hn1w0.label = String(int(hiddenLayer.neurons[1].w[0] * 10000) / 10000);
                hn2w0.label = String(int(hiddenLayer.neurons[2].w[0] * 10000) / 10000);
                
                //trace("Proceed #" + String(i) + ", Sum of Error : " + String(sumError));
                
            }

           
            
            if (proceedEnd == true)
            {
                testTextArea.text += "Proceed End.\n";
                
                arr = [0, 1, 2, 3];
                
                for (s = 0; s < arr.length; s+=1)
                {
                    input_0 = parseInt(learnObject[arr[s] * 2].substr(0, 1));
                    input_1 = parseInt(learnObject[arr[s] * 2].substr(1, 1));
                    
                    inputLayer.neurons[0].output = sigmoid(input_0);
                    inputLayer.neurons[1].output = sigmoid(input_1);
                    inputLayer.neurons[2].output = 1; //biased
                    
                    hiddenLayer.neurons[0].input = inputLayer.neurons[0].output * inputLayer.neurons[0].w[0] + inputLayer.neurons[1].output * inputLayer.neurons[1].w[0] + inputLayer.neurons[2].output * inputLayer.neurons[2].w[0];
                    hiddenLayer.neurons[1].input = inputLayer.neurons[0].output * inputLayer.neurons[0].w[1] + inputLayer.neurons[1].output * inputLayer.neurons[1].w[1] + inputLayer.neurons[2].output * inputLayer.neurons[2].w[1];
                    
                    hiddenLayer.neurons[0].output = sigmoid(hiddenLayer.neurons[0].input);
                    hiddenLayer.neurons[1].output = sigmoid(hiddenLayer.neurons[1].input);
                    hiddenLayer.neurons[2].output = 1; //biased
                    
                    outputLayer.neurons[0].input = hiddenLayer.neurons[0].output * hiddenLayer.neurons[0].w[0] + hiddenLayer.neurons[1].output * hiddenLayer.neurons[1].w[0] + hiddenLayer.neurons[1].output * hiddenLayer.neurons[2].w[0];
                    outputLayer.neurons[0].output = sigmoid(outputLayer.neurons[0].input);
                    
                    
                    ideal = parseInt(learnObject[arr[s] * 2 + 1]);

                    if (ideal == 0)
                    {
                        testTextArea.text += "Input : " + learnObject[arr[s] * 2] + "\t Output : " + String(outputLayer.neurons[0].output) + "\t Ideal : " + learnObject[arr[s] * 2 + 1] + "\t Error : " + String(int(outputLayer.neurons[0].output * 10000) / 100) + " % \n";
                    }
                    else
                    {
                        testTextArea.text += "Input : " + learnObject[arr[s] * 2] + "\t Output : " + String(outputLayer.neurons[0].output) + "\t Ideal : " + learnObject[arr[s] * 2 + 1] + "\t Error : " + String(int((ideal - outputLayer.neurons[0].output)/ideal * 10000) / 100) + " % \n";
                    }
                    
                }
                removeEventListener(Event.ENTER_FRAME, onLoop);
            }
            
        }
        
        public function sigmoid(n:Number):Number
        {
            return 1 / (1 + 1 / Math.exp(n));
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

Class
{
    /**
     * ...
     * @author ypc
     */
    class Neuron 
   {
       public var w:Object;
        public var deltaW:Object;
        public var updateValue:Object;
        public var prevGradient:Object;
        public var input:Number;
        public var output:Number;
        public var gradient:Object;
        public var gradientChanged:Object;
        
        public function Neuron(n:int)
        {
            this.w = new Object();
           this.deltaW = new Object();
           this.updateValue = new Object();
           this.prevGradient = new Object();
           this.gradient = new Object();
            this.gradientChanged = new Object();
            
            if (n > 0)
            {
                var i:int;
                
                for (i = 0; i < n; i += 1)
                {
                    this.w[i] = Math.random() * 2 - 1;
                    this.deltaW[i] = 0;
                    this.updateValue[i] = 0.01;
                    
                    this.gradient[i] = 0;
                    this.prevGradient[i] = 0;
                    this.gradientChanged[i] = 0;
                }
            }
        }
        
        public function resetW(n:int):void
       {
            var i:int;
            
           for (i = 0; i < n; i += 1)
            {
                this.w[i] = Math.random() * 2 - 1;
                this.deltaW[i] = 0;
                this.updateValue[i] = 0.01;
                
                this.gradient[i] = 0;
                this.prevGradient[i] = 0;
                this.gradientChanged[i] = 0;
            }
        }
        
    }

}

Class
{
    /**
     * ...
     * @author ypc
     */
    class Layer 
    {
        public var neurons:Array;
       
        public function Layer() 
        {
            this.neurons = [];
        }
        
    }

}