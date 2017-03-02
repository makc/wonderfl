// forked from greentec's Self Organizing Map
package {
    import com.bit101.components.Label;
    import com.bit101.components.PushButton;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    
    public class FlashTest extends Sprite {
        
        public var outputNeuronWidthNum:int = 20;
        public var outputNeuronHeightNum:int = 20;
        public var outputNeuronNum:int = outputNeuronWidthNum * outputNeuronHeightNum;
        public var inputNeuronNum:int = 10000;
        
        public var _bitmap:Bitmap;
        public var _bitmapData:BitmapData;
        
        public var inputLayer:Layer;
        public var outputLayer:Layer;
        
        public var startLearningRate:Number = 0.05;
        public var learningRate:Number = 0.05;
        public var oneFrameIter:int = 30;
        public var iterMax:int = inputNeuronNum / oneFrameIter - 1;
        public var iter:int = -1;
        
        
        public var screenWidthHalf:int = 465 / 2;
        public var screenHeightHalf:int = 465 / 2;
        //public var startRadius:Number = 465;
        //public var radius:Number = 465;
        public var startRadius:Number = (outputNeuronWidthNum + outputNeuronWidthNum) / 2;
        public var radius:Number = startRadius;
        
        public var proceedNumLabel:Label;
        public var resetButton:PushButton;
        
        public var lineShape:Shape = new Shape();
        public var dotShape:Shape = new Shape();
        
        public var timeConstant:Number = iterMax / Math.log(startRadius); 

        public function FlashTest() {
            // write as3 code here..
            
            stage.scaleMode = "noScale";
            
            _bitmapData = new BitmapData(465, 465, false, 0x292929);
            _bitmap = new Bitmap(_bitmapData);
            addChild(_bitmap);
            
            var i:int;
            var neuron:Neuron;
            
            inputLayer = new Layer();
            for (i = 0; i < inputNeuronNum; i += 1)
            {
                neuron = new Neuron(2);
                inputLayer.neurons.push(neuron);
            }
            
            outputLayer = new Layer();
            
            for (i = 0; i < outputNeuronNum; i += 1)
            {
                neuron = new Neuron(2);
                outputLayer.neurons.push(neuron);
            }
            
            proceedNumLabel = new Label(this, 10, 10, "Proceed #");
            resetButton = new PushButton(this, 10, 465 - 30, "Reset", onReset);
            
            addEventListener(Event.ENTER_FRAME, onLoop);
        }
        
        private function onReset(e:Event):void
        {
            var i:int;
            if (hasEventListener(Event.ENTER_FRAME) == true)
            {
                removeEventListener(Event.ENTER_FRAME, onLoop);
            }
            
            var neuron:Neuron;
            
            for (i = 0; i < inputNeuronNum; i += 1)
            {
                neuron = inputLayer.neurons[i];
                neuron.resetW(2);
            }
            
            for (i = 0; i < outputNeuronNum; i += 1)
            {
                neuron = outputLayer.neurons[i];
                neuron.resetW(2);
            }
            
            iter = 0;
            learningRate = startLearningRate;
            radius = startRadius;
            
            if (hasEventListener(Event.ENTER_FRAME) == false)
            {
                addEventListener(Event.ENTER_FRAME, onLoop);
            }
        }
        
        private function onLoop(e:Event):void
        {
            var i:int;
            var j:int;
            var input:Neuron;
            var neuron:Neuron;
            var bmuNumber:Number;
            var bmuIndex:int;
            var dx:int;
            var dy:int;
            var v:Number;
            var N:Number;
            var dist:Number;
            var influence:Number;
            var bmuNeuron:Neuron;
            
            iter += 1;
            
            if (iter <= iterMax)
            {
                for (i = 0; i < oneFrameIter; i += 1)
                {
                    input = inputLayer.neurons[iter * oneFrameIter + i];
                    bmuNumber = 99999;
                    
                    for (j = 0; j < outputNeuronNum; j += 1)
                    {
                        neuron = outputLayer.neurons[j];
                        neuron.redDist = input.w[0] - neuron.w[0];
                        neuron.greenDist = input.w[1] - neuron.w[1];
                        neuron.euclideanDist = Math.sqrt(neuron.redDist * neuron.redDist + neuron.greenDist * neuron.greenDist);
                        
                        if (bmuNumber > neuron.euclideanDist)
                        {
                            bmuNumber = neuron.euclideanDist;
                            bmuIndex = j;
                        }
                    }
                    
                    bmuNeuron = outputLayer.neurons[bmuIndex];
                    //trace(bmuIndex, bmuNeuron, bmuNeuron.w[0], bmuNeuron.w[1]);
                    //var num:int = 0;
                    for (j = 0; j < outputNeuronNum; j += 1)
                    {
                        if (j != bmuIndex)
                        {
                            neuron = outputLayer.neurons[j];
                            
                            
                            dx = (bmuIndex % outputNeuronWidthNum) - (j % outputNeuronWidthNum);
                            dx = (dx ^ dx >> 31) - (dx >> 31); // == MAth.abs(dx)
                            dy = int(bmuIndex / outputNeuronWidthNum) - int(j / outputNeuronWidthNum);
                            dy = (dy ^ dy >> 31) - (dy >> 31);
                            //dist = Math.sqrt(dx * dx + dy * dy);
                            dist = dx + dy;
                            
                            if (dist < radius)
                            {
                                influence = Math.exp(( -1 * Math.sqrt(dist)) / (2 * radius * iter));
                                neuron.w[0] += learningRate * influence * neuron.redDist;
                                neuron.w[1] += learningRate * influence * neuron.greenDist;
                                //trace(neuron.w[0], neuron.w[1]);
                                //num += 1;
                            }
                        }
                        //neuron.w[0] = neuron.w[0] > 1 ? 1 : (neuron.w[0] < -1 ? -1 : neuron.w[0]);
                        //neuron.w[1] = neuron.w[1] > 1 ? 1 : (neuron.w[1] < -1 ? -1 : neuron.w[1]);
                        
                        //v = (dx + dy) / 18;
                        //N = Math.exp( -v);
                        
                        //neuron.w[0] += learningRate * N * neuron.redDist;
                        //neuron.w[1] += learningRate * N * neuron.greenDist;
                    }
                    //trace(num);
                    //trace(bmuNeuron.w[0], bmuNeuron.w[1]);
                }
                
                drawNodes(i-1, bmuIndex);
                
                learningRate = startLearningRate * Math.exp( -iter / timeConstant); 
                radius = startRadius * Math.exp( -iter / timeConstant);
                
                proceedNumLabel.text = "Proceed #" + String(iter) + "/" + String(iterMax);
            }
            else
            {
                if (hasEventListener(Event.ENTER_FRAME) == true)
                {
                    removeEventListener(Event.ENTER_FRAME, onLoop);
                }
            }
        }
        
        private function drawNodes(inputIndex:int, bmuIndex:int):void
        {
            _bitmapData.fillRect(_bitmapData.rect, 0x292929);
            
            lineShape.graphics.clear();
            dotShape.graphics.clear();
            
            
            //var randIndex:int = Math.random() * oneFrameIter + iter * oneFrameIter;
            var input:Neuron;
            input = inputLayer.neurons[inputIndex + iter * oneFrameIter];
            dotShape.graphics.lineStyle(0, 0xff00ff);
            dotShape.graphics.drawCircle((input.w[0] + 1) * screenWidthHalf, (input.w[1] + 1) * screenHeightHalf, 5);
            
            var neuron:Neuron;
            var endNeuron:Neuron; // for line drawing
            
            dotShape.graphics.lineStyle(0, 0xdddddd);
            lineShape.graphics.lineStyle(0, 0xdddddd);
            
            var i:int;
            var dx:int;
            var dy:int;
            var dist:int;
            
            for (i = 0; i < outputNeuronNum; i += 1)
            {
                neuron = outputLayer.neurons[i];
                
                dx = (bmuIndex % outputNeuronWidthNum) - (i % outputNeuronWidthNum);
                dx = (dx ^ dx >> 31) - (dx >> 31);
                dy = int(bmuIndex / outputNeuronWidthNum) - int(i / outputNeuronWidthNum);
                dy = (dy ^ dy >> 31) - (dy >> 31);
                dist = dx + dy;
                
                if (dist < radius)
                {
                    dotShape.graphics.lineStyle(0, 0xffff00);
                    dotShape.graphics.beginFill(0xffff00);
                }
                else
                {
                    dotShape.graphics.lineStyle(0, 0xdddddd);
                    dotShape.graphics.beginFill(0x808080);
                }
                
                dotShape.graphics.drawCircle((neuron.w[0] + 1) * screenWidthHalf, (neuron.w[1] + 1) * screenHeightHalf, 5);
                dotShape.graphics.endFill();
                
                
                if ( (i % outputNeuronWidthNum) < outputNeuronWidthNum - 1)
                {
                    endNeuron = outputLayer.neurons[i + 1];
                    lineShape.graphics.moveTo((neuron.w[0] + 1) * screenWidthHalf, (neuron.w[1] + 1) * screenHeightHalf);
                    lineShape.graphics.lineTo((endNeuron.w[0] + 1) * screenWidthHalf, (endNeuron.w[1] + 1) * screenHeightHalf);
                }
                
                if ( int(i / outputNeuronWidthNum) < outputNeuronHeightNum - 1)
                {
                    endNeuron = outputLayer.neurons[i + outputNeuronWidthNum];
                    lineShape.graphics.moveTo((neuron.w[0] + 1) * screenWidthHalf, (neuron.w[1] + 1) * screenHeightHalf);
                    lineShape.graphics.lineTo((endNeuron.w[0] + 1) * screenWidthHalf, (endNeuron.w[1] + 1) * screenHeightHalf);
                }
            }
            
            _bitmapData.draw(lineShape);
            _bitmapData.draw(dotShape);
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