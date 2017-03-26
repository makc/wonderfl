package {
    import com.bit101.components.Label;
    import com.bit101.components.PushButton;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import com.bit101.components.RadioButton;
    
    public class FlashTest extends Sprite {
        
        public var outputNeuronWidthNum:int = 100;
        public var outputNeuronHeightNum:int = 100;
        public var outputNeuronNum:int = outputNeuronWidthNum * outputNeuronHeightNum;
        public var inputNeuronNum:int = 3;
        
        public var _bitmap:Bitmap;
        public var _bitmapData:BitmapData;
        
        public var outputCellWidth:int = 4;
        public var outputCellHeight:int = 4;
        
        
        public var inputLayer:Layer;
        public var outputLayer:Layer;
        
        public var indent:int = 10;
        
        public var trainingSet:Array;
        public var trainingSetNum:int = 15;
        
        public var startLearningRate:Number = 0.1;
        public var learningRate:Number = 0.1;
        public var iterMax:int = 150;
        public var iter:int = 0;
        
        public var proceedNumLabel:Label;
        public var resetButton:PushButton;
        
        public var randomRadioButton:RadioButton;
        public var tintRadioButton:RadioButton;        

        public function FlashTest() {
            // write as3 code here..
            
            _bitmapData = new BitmapData(465, 465, false, 0x292929);
            _bitmap = new Bitmap(_bitmapData);
            addChild(_bitmap);
            
            var i:int;
            var neuron:Neuron;
            
            inputLayer = new Layer();
            for (i = 0; i < inputNeuronNum; i += 1)
            {
                neuron = new Neuron(0);
                inputLayer.neurons.push(neuron);
            }
            
            outputLayer = new Layer();
            
            for (i = 0; i < outputNeuronNum; i += 1)
            {
                neuron = new Neuron(inputNeuronNum);
                outputLayer.neurons.push(neuron);
            }
            
            
            //drawMap();
            proceedNumLabel = new Label(this, 10, 10 + outputNeuronHeightNum * outputCellHeight + 5, "Proceed #");
            resetButton = new PushButton(this, proceedNumLabel.x, proceedNumLabel.y + proceedNumLabel.height + 5, "Reset", onReset);

            var _label:Label = new Label(this, resetButton.x + resetButton.width + 20, proceedNumLabel.y, "Training Pattern");
            
            randomRadioButton = new RadioButton(this, _label.x + _label.width + 10, _label.y + 5, "random Color", false);
            randomRadioButton.groupName = "colorSelect";
            tintRadioButton = new RadioButton(this, randomRadioButton.x + randomRadioButton.width + 5, randomRadioButton.y, "tint Color", true);
            tintRadioButton.groupName = "colorSelect";
            
            initTrainingSet();
            
                        
            addEventListener(Event.ENTER_FRAME, onLoop);
        }
        
        private function onReset(e:Event):void
        {
            if (hasEventListener(Event.ENTER_FRAME) == true)
            {
                removeEventListener(Event.ENTER_FRAME, onLoop);
            }
            
            initTrainingSet();
            var i:int;
            var neuron:Neuron;
            
            for (i = 0; i < outputNeuronNum; i += 1)
            {
                neuron = outputLayer.neurons[i];
                neuron.resetW(inputNeuronNum);
            }
            
            iter = 0;
            learningRate = startLearningRate;
            
            if (hasEventListener(Event.ENTER_FRAME) == false)
            {
                addEventListener(Event.ENTER_FRAME, onLoop);
            }
        }
        
        private function hsv(h:Number, s:Number, v:Number):Array
        {
            var r:Number, g:Number, b:Number;
            var i:int;
            var f:Number, p:Number, q:Number, t:Number;
            if (s == 0){
                r = g = b = v;
                return [r * 2 - 1, g * 2 - 1, b * 2 - 1];
            }
            h /= 60;
            i  = Math.floor(h);
            f = h - i;
            p = v *  (1 - s);
            q = v * (1 - s * f);
            t = v * (1 - s * (1 - f));
            switch( i ) {
                case 0:
                    r = v, g = t, b = p;
                    break;
                case 1:
                    r = q, g = v, b = p;
                    break;
                case 2:
                    r = p, g = v, b = t;
                    break;
                case 3:
                    r = p, g = q, b = v;
                    break;
                case 4:
                    r = t, g = p, b = v;
                    break;
                default:        // case 5:
                    r = v, g = p, b = q;
                    break;
            }
            return [r * 2 - 1, g * 2 - 1, b * 2 - 1];
        }
        
        private function initTrainingSet():void
        {
            var i:int;
            var rect:Rectangle;
            var red:Number;
            var green:Number;
            var blue:Number;
            var color:uint;
            var h:Number, s:Number, v:Number;
            var hsvArray:Array;
            
            rect = new Rectangle();
            trainingSet = [];
            for (i = 0; i < trainingSetNum; i += 1)
            {
                if (randomRadioButton.selected == true)
                {
                    red = Math.random() * 2 - 1;
                    green = Math.random() * 2 - 1;
                    blue = Math.random() * 2 - 1;
                }
                else
                {
                    h = Math.random() * 360;
                    s = 1;
                    v = 1;
                    hsvArray = hsv(h, s, v);
                    red = hsvArray[0];
                    green = hsvArray[1];
                    blue = hsvArray[2];
                    
                }
                trainingSet.push([red, green, blue]);
                color = ((red + 1) * 127 << 16) | ((green + 1) * 127 << 8) | ((blue + 1) * 127 & 0xff);
                rect.x = resetButton.x + resetButton.width + 20 + i * 20;
                rect.y = resetButton.y;
                rect.width = 20;
                rect.height = 20;
                _bitmapData.fillRect(rect, color);
                
            }
        }
        
        private function onLoop(e:Event):void
        {
            iter += 1;
            if (iter <= iterMax)
            {
                var i:int;
                var j:int;
                var neuron:Neuron;
                var redDist:Number;
                var greenDist:Number;
                var blueDist:Number;
                var bmuNumber:Number;
                var bmuIndex:int = -1;
                var v:Number;
                var N:Number;
                var dx:int;
                var dy:int;
                
                
                for (i = 0; i < trainingSetNum; i += 1)
                {
                    bmuNumber = 99999;
                    
                    for (j = 0; j < outputNeuronNum; j += 1) //get BMU - Best Matching Unit
                    {
                        neuron = outputLayer.neurons[j];
                        neuron.redDist = trainingSet[i][0] - neuron.w[0];
                        neuron.greenDist = trainingSet[i][1] - neuron.w[1];
                        neuron.blueDist = trainingSet[i][2] -  neuron.w[2];
                        neuron.euclideanDist = Math.sqrt(neuron.redDist * neuron.redDist + neuron.greenDist * neuron.greenDist + neuron.blueDist * neuron.blueDist);
                        //trace(neuron.euclideanDist);
                        
                        if (bmuNumber > neuron.euclideanDist)
                        {
                            bmuNumber = neuron.euclideanDist;
                            bmuIndex = j;
                        }
                    }
                    //trace(bmuNumber, bmuIndex);
                    for (j = 0; j < outputNeuronNum; j += 1)
                    {
                        neuron = outputLayer.neurons[j];
                        
                        dx = (bmuIndex % outputNeuronWidthNum) - (j % outputNeuronWidthNum);
                        dx = (dx ^ dx >> 31) - (dx >> 31); // == MAth.abs(dx)
                        dy = int(bmuIndex / outputNeuronWidthNum) - int(j / outputNeuronWidthNum);
                        dy = (dy ^ dy >> 31) - (dy >> 31);
                        
                        v = (dx + dy) / 18;
                        N = Math.exp( -v);
                        
                        neuron.w[0] += learningRate * N * neuron.redDist;
                        neuron.w[1] += learningRate * N * neuron.greenDist;
                        neuron.w[2] += learningRate * N * neuron.blueDist;
                        
                        //neuron.w[0] = neuron.w[0] > 1 ? 1 : (neuron.w[0] < -1 ? -1 : neuron.w[0]); //for speed.. sacrifice
                        //neuron.w[1] = neuron.w[1] > 1 ? 1 : (neuron.w[1] < -1 ? -1 : neuron.w[1]);
                        //neuron.w[2] = neuron.w[2] > 1 ? 1 : (neuron.w[2] < -1 ? -1 : neuron.w[2]);
                        
                    }
                    
                }
                
                //trace(neuron.w[0], neuron.w[1], neuron.w[2]);
                
                drawMap();
                
                learningRate = startLearningRate * Math.exp( -iter / iterMax); 
                
                proceedNumLabel.text = "Proceed #" + String(iter) + "/" + String(iterMax);
                
                if (iter == iterMax)
                {
                    if (hasEventListener(Event.ENTER_FRAME) == true)
                    {
                        removeEventListener(Event.ENTER_FRAME, onLoop);
                    }
                }
            }
        }
        
        private function drawMap():void
        {
            var i:int;
            var j:int;
            var neuron:Neuron;
            var color:uint;
            var rect:Rectangle = new Rectangle();
            
            rect.x = indent;
            rect.y = indent;
            rect.width = outputCellWidth * outputNeuronWidthNum;
            rect.height = outputCellHeight * outputNeuronHeightNum;
            
            _bitmapData.fillRect(rect, 0x292929);
            
            
            
            for (i = 0; i < outputNeuronWidthNum; i += 1)
            {
                for (j = 0; j < outputNeuronHeightNum; j += 1)
                {
                    neuron = outputLayer.neurons[i + j * outputNeuronWidthNum];
                    color = ((neuron.w[0] + 1) * 127 << 16) | ((neuron.w[1] + 1) * 127 << 8) | ((neuron.w[2] + 1) * 127 & 0xff);
                    rect.x = indent + i * outputCellWidth;
                    rect.y = indent + j * outputCellHeight;
                    rect.width = outputCellWidth;
                    rect.height = outputCellHeight;
                    _bitmapData.fillRect(rect, color);
                    
                }
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
    class Neuron
    {
        public var w:Object;
        public var input:Number;
        public var output:Number;
        public var euclideanDist:Number;
        public var redDist:Number;
        public var greenDist:Number;
        public var blueDist:Number;
        
        public function Neuron(n:int)
        {
            this.w = new Object();
           
            
            if (n > 0)
            {
                var i:int;
                
                for (i = 0; i < n; i += 1)
                {
                    this.w[i] = Math.random() * 2 - 1;
                    
                }
            }
        }
        
        public function resetW(n:int):void
        {
            var i:int;
            
            for (i = 0; i < n; i += 1)
            {
                this.w[i] = Math.random() * 2 - 1;
                
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