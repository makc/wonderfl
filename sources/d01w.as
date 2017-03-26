/**
 * BitmapData.perlinNoise()でランダムシードに特定の数を指定した時に起こる現象
 * これって有名な現象だったりするんでしょうか・・・それとも使い方が間違ってる？
 * 
 * （調べてみたので追記）
 * ランダムシードを7185とかの数値にするとどこかのチャンネルに穴があくよって現象で、
 * ここに長々と発生する番号とか条件を羅列してたんですが・・・・
 * どうもこの結果はperlinNoise()のノイズの細かさを決める第三引数の数値にも影響されるみたいです。
 * このサンプルは最初7を指定していたんですが(って無駄に多すぎたね・・・)減らしていくと穴の数も減っていきます。
 * でも4まで減らしてもまだ残ってる画像がありました。
 * 
 * 一応穴が発生する可能性のあるランダムシード値を書いておきます（0～10000の間）
 * ※更新しました。多分これで全部。
 * 346,514,1155,1519,1690,1977,2327,2337,2399,2860,2999,3099,4777,4952,5673,6265,
 * 7185,7259,7371,7383,7717,7847,8032,8350,8676,8963,8997,9080,9403,9615,9685
 * 
 * 赤、緑、青、アルファのどれかに穴があきます。青とアルファは安全かと思ったら違った・・・
 * グレースケール化するとアルファ以外の全チャンネルに穴があくことが多いですがたまに穴が消えるケースもあるみたい。
 * とりあえずこの数値にならないようにしておけば問題ないかな？
 * 
 */
package  {
	import com.bit101.components.CheckBox;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	public class PerlinNoiseTest extends Sprite {
		private var checkBoxes:Vector.<CheckBox>;
		private var channels:Vector.<Bitmap>;
		private var totalBmp:Bitmap;
		private var numstep:NumericStepper;
		private var numOctaves:NumericStepper;
		public function PerlinNoiseTest() {
			checkBoxes = new Vector.<CheckBox>();
			channels = new Vector.<Bitmap>();
			totalBmp = addChild(new Bitmap(new BitmapData(120, 120, true, 0xFF000000))) as Bitmap;
			totalBmp.x = totalBmp.y = 10;
			new Label(this, 150, 6, "Random Seed");
			new Label(this, 250, 6, "ERROR Number(0 - 10000)\n346,514,\n1155,1519,1690,1977,\n2327,2337,2399,2860,2999,\n3099,\n4777,4952,\n5673,\n6265,\n7185,7259,7371,7383,7717,7847,\n8032,8350,8676,8963,8997,\n9080,9403,9615,9685");
			numstep = new NumericStepper(this, 150, 21, refreshImage);
			numstep.value = 7185;
			numstep.min = -100000;
			numstep.max = 100000;
			new Label(this, 150, 34, "numOctaves");
			numOctaves = new NumericStepper(this, 150, 49, refreshImage);
			numOctaves.value = 7;
			numOctaves.min = 1;
			numOctaves.max = 100;
			var labels:Array = ["RED", "GREEN", "BLUE", "ALPHA", "GRAYSCALE"];
			for (var i:int = 0; i < labels.length; i++) {
				var chbx:CheckBox = new CheckBox(this, 150, 13 * i + 69, labels[i], refreshImage);
				chbx.selected = (i <= 2);
				checkBoxes.push(chbx);
			}
			for (var n:int = 0; n < 4; n++) {
				var sp:Sprite = addChild(new Sprite()) as Sprite;
				var bmp:Bitmap = sp.addChild(new Bitmap(new BitmapData(120, 120, true, 0xFF000000))) as Bitmap;
				new Label(sp, 0, -20, labels[n]);
				sp.x = (n%2) * 140 + 10;
				sp.y = int(n/2) * 140 + 190;
				channels.push(bmp);
			}
			refreshImage();
		}
		private function refreshImage(...arg):void {
			var ch:int = int(checkBoxes[0].selected) + int(checkBoxes[1].selected) * 2 + int(checkBoxes[2].selected) * 4 + int(checkBoxes[3].selected) * 8;
			totalBmp.bitmapData.perlinNoise(100, 100, numOctaves.value, numstep.value, false, true, ch, checkBoxes[4].selected);
			for (var n:int = 0; n < 4; n++) {
				var channel:int = Math.pow(2, n);
				channels[n].bitmapData.fillRect(channels[n].bitmapData.rect, 0xFF000000);
				channels[n].bitmapData.copyChannel(totalBmp.bitmapData, totalBmp.bitmapData.rect, new Point(), channel, channel);
			}
		}
	}
}