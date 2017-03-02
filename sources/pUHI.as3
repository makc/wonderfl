package { // Piclens type thing in 30 lines author - Liam O'Donnell - spikything.com
    import flash.display.Sprite;
    import flash.events.Event;
    public class Main extends Sprite {
        private var container :Sprite;
        private var imageGrid :Sprite;
        private var images :Array = [];
        public function Main():void {
            container = addChild(new Sprite()) as Sprite;
            imageGrid = container.addChild(new Sprite()) as Sprite;
            for (var i:uint = 0; i <200; i++) images.push(getItem(i));
            images.sortOn("z", Array.NUMERIC | Array.DESCENDING);
            for each (var item:Sprite in images) imageGrid.addChild(item);
            addEventListener(Event.ENTER_FRAME, update);
        }
        private function getItem(index:uint):Sprite {
            var item:Sprite = new Sprite();
            item.x = -(200 / 3) * 210 / 2 + (index / 3) * 210;
            item.y = (index % 3) * 160 - 40;
            item.z = 100 + Math.random() * 2000;
            item.graphics.beginFill(Math.random() * 0xffffff);
            item.graphics.drawRect(0, 0, 200, 150);
            return item;
        }
        private function update(e:Event):void {
            imageGrid.x += ((stage.stageWidth / 2) - mouseX) * .2;
            container.rotationY = ((stage.stageWidth / 2) - mouseX) * .2;
        }
    }
}