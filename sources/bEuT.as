//Wonderflでの画像アップロードテスト

//このあいだ気付いたので試してみた
//サーバいらず，crossdomain.xmlいらず。
//たぶん気付いてない人も多いと思ったので…

/*アップロード方法
 *(1)「タイトル，タグ，ライセンスを編集」をクリック
 *(2)ライセンスの下の「+more」クリック
 *(3)「UPLOAD」クリック→ダイアログから画像を選択してアップロード
 *(4)画像が表示されたら右クリック→「画像のURLをコピー」（FireFoxの場合？）
 *(5)下のコードのようにLoaderで読み込む
 */
 
package {
    import flash.display.Sprite;
    import flash.display.Loader;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    
    public class FlashTest extends Sprite {
        public function FlashTest() {
            //コピーしたURL
            var url:String = "http://wonderfl.net/static/tmp/related_images/7631be20fea2b992f1193ca6319abfc716fe388am"
            
            //後は普通に。
            var urlReq:URLRequest = new URLRequest(url);
            var loader:Loader = new Loader();
            loader.load(urlReq);
            addChild(loader);
            
        }
    }
}