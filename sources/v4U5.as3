package {
    import flash.display.Sprite;
    
    public class main extends Sprite {
        public function foo(a:Number = 0, b:Number = 0, c:Number = 0):void {
            var x:Number;
            x * x;
        }
        
        public function main() {
            foo();
        }
    }
}

/* This is the output from 'swfdump -abc main.swf' after compiling on my box.
 * Wonderfl uses a different version of mxmlc but the result is the same.
 * Run this in a debug player to get: VerifyError: Error #1023: Stack overflow occurred. at main()
 *
 * I think the overflow happens at the second dup in foo() when the stack contains 3 items while
 * foo's maxStack limit is 2, but I'm not 100% sure about that.

<!-- Parsing swf file:/home/yonatan/src/play/wh0-heisenbug/small/main.swf -->
<!-- ?xml version="1.0" encoding="UTF-8"? -->
<swf xmlns='http://macromedia/2003/swfx' version='11' framerate='24' size='10000x7500' compressed='true' >
  <!-- framecount=1 length=893 -->
  <FileAttributes useDirectBlit='false' useGPU='false' hasMetadata='true' actionScript3='true' suppressCrossDomainCaching='false' swfRelativeUrls='false' useNetwork='true'/>
  <Metadata>
    <rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'><rdf:Description rdf:about='' xmlns:dc='http://purl.org/dc/elements/1.1'><dc:format>application/x-shockwave-flash</dc:format><dc:title>Adobe Flex 4 Application</dc:title><dc:description>http://www.adobe.com/products/flex</dc:description><dc:publisher>unknown</dc:publisher><dc:creator>unknown</dc:creator><dc:language>EN</dc:language><dc:date>Oct 7, 2012</dc:date></rdf:Description></rdf:RDF>
  </Metadata>
  <ScriptLimits scriptRecursionLimit='1000' scriptTimeLimit='60'/>
  <SetBackgroundColor color='#FFFFFF'/>
  <ProductInfo product='Adobe Flex' edition='' version='4.5' build='21328' compileDate='10/7/12 1:50 PM'/>
  <FrameLabel label='main'/>
  <DoABC2>
    16 0 minor version
    46 0 major version
    2 Integer Constant Pool Entries
    0
    0 Unsigned Integer Constant Pool Entries
    0 Floating Point Constant Pool Entries
    14 String Constant Pool Entries
     
     void
     Number
     main
     flash.display
     Sprite
     foo
     Object
     flash.events
     EventDispatcher
     DisplayObject
     InteractiveObject
     DisplayObjectContainer
    5 Namespace Constant Pool Entries
     
     flash.display
     main
     flash.events
    0 Namespace Set Constant Pool Entries
    11 MultiName Constant Pool Entries
    :void
    :Number
    :main
    flash.display:Sprite
    :foo
    :Object
    flash.events:EventDispatcher
    flash.display:DisplayObject
    flash.display:InteractiveObject
    flash.display:DisplayObjectContainer
    4 Method Entries
    no name(): 
    no name(:Number,:Number,:Number)::void 
    no name(): 
    no name(): 
    0 Metadata Entries
    1 Instance Entries
    :main extends flash.display:Sprite 
    1 Traits Entries
    :foo
    1 Class Entries
    :main extends Class 
    0 Traits Entries
    1 Script Entries
    script0 
    1 Traits Entries
    :main
    4 Method Bodies
    function :main:::main$cinit():
    maxStack:1 localCount:1 initScopeDepth:8 maxScopeDepth:9
        getlocal0     	
        pushscope     	
        returnvoid    	
    0 Extras
    0 Traits Entries

    function :main:::foo(:Number, :Number, :Number)::void
    maxStack:2 localCount:5 initScopeDepth:9 maxScopeDepth:10
        getlocal0     	
        pushscope     	
        pushnan       	
        dup           	
        dup           	
        setlocal      	4
        multiply      	
        pop           	
        returnvoid    	
    0 Extras
    0 Traits Entries

    function :main:::main():
    maxStack:1 localCount:1 initScopeDepth:9 maxScopeDepth:10
        getlocal0     	
        pushscope     	
        getlocal0     	
        constructsuper	(0)
        getlocal0     	
        callpropvoid  	:foo (0)
        returnvoid    	
    0 Extras
    0 Traits Entries

    function script0::script0$init():
    maxStack:2 localCount:1 initScopeDepth:1 maxScopeDepth:8
        getlocal0     	
        pushscope     	
        getscopeobject	0
        getlex        	:Object
        pushscope     	
        getlex        	flash.events:EventDispatcher
        pushscope     	
        getlex        	flash.display:DisplayObject
        pushscope     	
        getlex        	flash.display:InteractiveObject
        pushscope     	
        getlex        	flash.display:DisplayObjectContainer
        pushscope     	
        getlex        	flash.display:Sprite
        pushscope     	
        getlex        	flash.display:Sprite
        newclass      	:main
        popscope      	
        popscope      	
        popscope      	
        popscope      	
        popscope      	
        popscope      	
        initproperty  	:main
        returnvoid    	
    0 Extras
    0 Traits Entries

  </DoABC2>
  <SymbolClass>
    <Symbol idref='0' className='main' />
  </SymbolClass>
  <ShowFrame/>
</swf>

*/