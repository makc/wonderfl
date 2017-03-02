<?xml version="1.0" encoding="utf-8"?>
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" xmlns="*"
	width="465" height="465">
	
	<mx:VBox width="100%" height="100%">
		<mx:Panel title="DisplacementMapFilter TEST" width="100%" height="165" paddingLeft="4" paddingRight="4">
			<mx:HBox width="100%" height="100%">
				<mx:VBox height="100%" paddingTop="16" verticalGap="4">
					<mx:Label text="type"/>
					<mx:Spacer height="4"/>
					<mx:Label text="speed"/>
					<mx:Label text="rate"/>
					<mx:Label text="depth"/>
				</mx:VBox>
				<mx:VBox width="100%" height="100%" paddingTop="10" verticalGap="4">
					<mx:ComboBox id="list_type" width="80" change="dmf.type=list_type.selectedItem.data;">
						<mx:dataProvider>
							<mx:Array>
								<mx:Object label="横" data="h"/>
								<mx:Object label="縦" data="v"/>
							</mx:Array>
						</mx:dataProvider>
					</mx:ComboBox>
					<mx:Spacer height="4"/>
					<mx:HSlider id="hs_speed" value="2" minimum="0" maximum="20"
						width="100%" change="dmf.speed=hs_speed.value;"/>
					<mx:HSlider id="hs_rate" value="0.1" minimum="0" maximum="1"
						width="100%" change="dmf.rate=hs_rate.value;"/>
					<mx:HSlider id="hs_depth" value="50" minimum="0" maximum="500"
						width="100%" change="dmf.depth=hs_depth.value;"/>
				</mx:VBox>
			</mx:HBox>
		</mx:Panel>
		<mx:Canvas width="100%" height="100%">
			<DMFTest id="dmf" width="100%" height="100%" />
		</mx:Canvas>
	</mx:VBox>
	
	<mx:Component className="DMFTest">
		<mx:UIComponent creationComplete="init();">
			<mx:Script>
				<![CDATA[
		private var filter:DisplacementMapFilter = new DisplacementMapFilter();
		private var map:BitmapData;
		
		public var type:String = "h";
		public var offset:Number = 0;
		public var speed:Number = 2;
		public var rate:Number = 0.1;
		public var depth:Number = 50;
		
		private var source:BitmapData;
		private var buffer:BitmapData;
		
		public function init():void
		{
			map = new BitmapData(465, 300, false);
			filter.mapBitmap = map;
			filter.componentX = BitmapDataChannel.BLUE;
			filter.componentY = BitmapDataChannel.BLUE;
			
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(8, 0x000000);
			shape.graphics.beginFill(0xE06000);
			shape.graphics.drawCircle(465/2, 150, 100);
			shape.graphics.endFill();
			
			source = new BitmapData(465, 300, false, 0xF0FFC0);
			source.draw(shape);
			
			buffer = new BitmapData(465, 300, false);
			addChild(new Bitmap(buffer));
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void
		{
			for(var i:int = 0; i < map.height; i++) {
				map.fillRect(new Rectangle(0, i, map.width, 1), Math.round(Math.sin((i+offset)*rate)*0x7F+0x80));
			}
			
			switch(type)
			{
			case "h":
				filter.scaleX = depth;
				filter.scaleY = 0;
				break;
			case "v":
				filter.scaleX = 0;
				filter.scaleY = depth;
				break;
			}
			
			offset += speed;
			
			buffer.applyFilter(source, source.rect, new Point(0, 0), filter);
		}
				]]>
			</mx:Script>
		</mx:UIComponent>
	</mx:Component>
</mx:Application>
