<?xml version="1.0" encoding="utf-8"?>
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" 
	layout="absolute" 
	xmlns:view="org.papervision3d.view.*" 
	xmlns:scenes="org.papervision3d.scenes.*" 
	xmlns:primitives="org.papervision3d.objects.primitives.*" 
	xmlns:materials="org.papervision3d.materials.*" 
	opaqueBackground="#ffffff"
	creationComplete="onRendering()">
	<mx:Script>
		<![CDATA[
			import mx.containers.Canvas;
			import mx.controls.Button;
			import mx.core.UIComponent;
			private function onRendering():void {
				bv.startRendering();
				var ui:UIComponent = new UIComponent();
				ui.addChild(bv);
				addChild(ui);
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			
			private function onEnterFrame(event:Event):void {
				ballWf.rotationX++;
				ballWf.rotationY++;
				ballWf.rotationZ++;
			}
		]]>
	</mx:Script>
	<mx:VBox id="vbx"  x="184" y="40" verticalScrollPolicy="on"/>
	<mx:Button id="add" label="追加" y="10" x="171"/>
	
	<view:BasicView id="bv">
	  <view:scene>
	    <scenes:Scene3D>
	      <scenes:objects>
		    <primitives:Cylinder id="ballWf" x="100" y="200" scaleX="2" scaleY="2" scaleZ="2">
		      <primitives:material>
			    <materials:ColorMaterial
			    	 fillColor="#ff0000" fillAlpha=".5" interactive="true"/>
			    
			  </primitives:material>
	       </primitives:Cylinder>
		  </scenes:objects>
		</scenes:Scene3D>
	  </view:scene>
	</view:BasicView>
</mx:Application>
