package {
	import flash.text.TextFormat;
	import flash.text.TextField;
    import flash.display.Sprite;
    public class Nengafl extends Sprite {
    		    	
        public function Nengafl() {
            /*
              これからActionScript3.0を始める人が、あなたの作品を通してFlashの楽しさを知り
              ASの世界に足を踏み入れるきっかけになるような課題作品をつくってください！

              一番FORKされた方に、wonderflからお年玉、なんと現金10万円を贈呈します！ 

             単純に数字を変えるだけで、面白い動きがでるのもOK! 
             真面目な課題ももちろんOK!
            「面白いAS 」の定義はみなさんにおまかせします！
             Flash仲間が増え、Flash界が盛り上がるような作品の応募をお待ちしております。
            */
            var nengaText:String = "<font color='#FF0000'><b>これからActionScript3.0を始める人が、あなたの作品を通してFlashの楽しさを知り<br>" + 
              "ASの世界に足を踏み入れるきっかけになるような課題作品をつくってください！<br><br>" +
              "一番FORKされた方に、wonderflからお年玉、なんと現金10万円を贈呈します！ <br><br>" +
              "単純に数字を変えるだけで、面白い動きがでるのもOK! <br>" +
              "真面目な課題ももちろんOK! <br>" +
              "「面白いAS 」の定義はみなさんにおまかせします！<br>" +
              "Flash仲間が増え、Flash界が盛り上がるような作品の応募をお待ちしております。</b></font>"; 

			var format:TextFormat = new TextFormat();
			format.size = 12;
			format.color = 0xFF0000;
			
			var nengaTextBox:TextField = new TextField();
			nengaTextBox.width = 465; 
   	        nengaTextBox.height = 200; 
   	        nengaTextBox..y = 100;
            nengaTextBox.multiline = true; 
            nengaTextBox.wordWrap = true; 
            nengaTextBox.border   = false;
            nengaTextBox.defaultTextFormat = format;
            nengaTextBox.htmlText = nengaText;
            
  		   this.addChild(nengaTextBox);
        }
    }
}