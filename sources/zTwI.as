// forked from hyzhaka's Test Sound for SHOUTcast (mp3)
package {
    import flash.display.Sprite;
    import flash.media.Sound;
    import flash.net.URLRequest;
    public class FlashTest extends Sprite {
        public function FlashTest() {
            var url : String;
            url = "http://203.150.225.71:8100/;stream.nsv"; // SHOUTcast Distributed Network Audio Server/Linux v1.9.8
            //url = "http://119.59.98.4:8040/;stream.nsv"; //  SHOUTcast Distributed Network Audio Server/Linux v1.9.8
            //url = "http://streaming205.radionomy.com:80/ABC-Lounge"; //  Icecast 2.3.2-kh31-advert-1
            //url = "http://radio.beotel.net:8008/;stream.nsv"; // SHOUTcast Distributed Network Audio Server/Linux v1.9.8
            //url = "http://94.25.53.133:80/nashe-96"; //  Icecast trunk
            var sound:Sound = new Sound(new URLRequest(url));
            sound.play();
        }
    }
}    