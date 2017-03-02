// forked from 9re's forked from: forked from: forked from: Guess the tag!
// forked from mash's forked from: forked from: Guess the tag!
// forked from 9re's forked from: Guess the tag!
// forked from makc3d's Guess the tag!
package {
    import flash.display.Sprite;
    import com.bit101.components.PushButton;
    import com.actionscriptbible.Example;
    
    public class Main extends Example {
        public function Main() {
           /*
            * I know 'this' differs outside and inside of the closure.
            * But why numChildren and this.numChildren differs inside 
            * the closure?
            * Or why numChildren is same outside and inside?
            */
           
            var _this:Sprite = this;
            trace("[outside]this: " + this);
            trace("[outside]numChildren: " + numChildren);
            trace("[outside]this.numChildren: " + this.numChildren); 
            
            (function ():void {
                trace("[inside]this: " + this);
                trace("[inside]numChildren: " + numChildren);
                trace("[inside]this.numChildren: " + this.numChildren);
                trace(_this.removeChildAt === removeChildAt);
                trace(this.removeChildAt === removeChildAt);
            })();
        }
    }
}