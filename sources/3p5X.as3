package 
{
	
/**
 * ゲームボーイエミュレータのテスト
 * 32KB 程度のサイズの、初期のゲームしか動きません。
 * 音も出ません。
 * 
 * Load Cartridge ボタンを押して、.gb ファイルをロードしてください。
 * 選択したファイルはサーバにはアップロードされません。
 * Flash 内に読み込まれるだけです。
 * 
 * CPU のコードは TGB Dual のものを使用させていただきました。
 * http://gigo.retrogames.com/
 * ライセンスは GPL です。
  */

	import flash.display.Bitmap;
	import flash.display.BitmapData;
    import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
	import flash.events.TextEvent;
    import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	[SWF(backgroundColor=0xFFFFFF,frameRate=60)]
	public class Main extends Sprite 
	{
		private var data:ByteArray;
		private var textField:TextField;
		private var output:BitmapData;
		private var gb:GB;
        private var fileReference:FileReference;
		
        private var buttonLoad:Button;
        private var buttonReset:Button;
		
		private var stop:Boolean = false;
		
		private var keys:Vector.<Boolean>;
		private var prevKeys:Vector.<Boolean>;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function prepare():void 
		{
			var frame:GbFrame = new GbFrame();
			frame.x = 10;
			frame.y = 10;
			addChild(frame);
			
            // Load ボタンの作成
            buttonLoad = new Button("Load Cartridge");
            buttonLoad.addEventListener(MouseEvent.MOUSE_DOWN, onButtonLoadDown);
            buttonLoad.x = 350;
            buttonLoad.y = 10;
            addChild(buttonLoad);
			
			// Reset ボタンの作成
			buttonReset = new Button("Reset");
            buttonReset.addEventListener(MouseEvent.MOUSE_DOWN, onButtonResetDown);
            buttonReset.x = 350;
            buttonReset.y = 40;
            addChild(buttonReset);
			
			// 画面の準備
			output = new BitmapData(160, 144);
			var bitmap:Bitmap = new Bitmap(output);
			bitmap.x = 85;
			bitmap.y = 48;
			addChild(bitmap);
			
			// GBの準備
			gb = new GB();
			stop = true;
			
			// キー入力情報の初期化
			keys = new Vector.<Boolean>();
			prevKeys = new Vector.<Boolean>();
			
			for (var i:int = 0; i < 230; i++) {
				keys[i] = new Boolean(false);
				prevKeys[i] = new Boolean(false);
			}
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			prepare();
			gb.output = output;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
        private function onButtonResetDown(event:MouseEvent):void 
        {
			if (data == null)
				return;
			
			gb = new GB();
			gb.loadRom(data);
		}
		
        private function onButtonLoadDown(event:MouseEvent):void 
        {
			stop = true;
            fileReference = new FileReference();
            
            // イベントの登録
            fileReference.addEventListener(Event.SELECT, onFileSelect);
            fileReference.addEventListener(Event.CANCEL, onFileCancel);
            fileReference.addEventListener(Event.COMPLETE, onFileLoadComplete);
            
            // ファイル選択ダイアログを表示する
            var fileFilter:FileFilter = new FileFilter("GB Cartridge (gb)", "*.gb");
            fileReference.browse([fileFilter]);
		}
		
        private function onFileSelect(event:Event):void
        {
            fileReference.load();
			stop = false;
        }
		
        private function onFileCancel(event:Event):void
        {
			stop = false;
        }
		
        private function onFileLoadComplete(event:Event):void
        {
			gb = new GB();
			data = fileReference.data;
			gb.loadRom(fileReference.data);
        }
		
		private function onKeyDown(event:KeyboardEvent):void 
		{
			keys[event.keyCode] = true;
		}
		
		private function onKeyUp(event:KeyboardEvent):void 
		{
			keys[event.keyCode] = false;
		}
		
		private function onEnterFrame(e:Event):void 
		{
			if (stop || gb == null || !gb.dataLoaded)
				return;
			gb.setPad(Keyboard.LEFT, keys[Keyboard.LEFT]);
			gb.setPad(Keyboard.RIGHT, keys[Keyboard.RIGHT]);
			gb.setPad(Keyboard.UP, keys[Keyboard.UP]);
			gb.setPad(Keyboard.DOWN, keys[Keyboard.DOWN]);
			gb.setPad(88, keys[88]);
			gb.setPad(90, keys[90]);
			gb.setPad(83, keys[83]);
			gb.setPad(65, keys[65]);
			
			gb.exec();
			gb.render(output);
		}
	}
	
}

import flash.display.Sprite;
class GbFrame extends Sprite
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public function GbFrame() 
	{
		var s:Sprite = new Sprite();
		var g:Graphics = s.graphics;
		
		s.cacheAsBitmap = true;
		
		// 外枠
		g.lineStyle(3, 0x808090, 1.0, true);
		g.beginFill(0xF0F0F0);
		g.drawRoundRect(0, 0, 317, 317, 10, 10);
		g.endFill();
		
		g.lineStyle(3, 0x808090, 1.0, true);
		g.moveTo(1, 15);
		g.lineTo(316, 15);
		g.moveTo(30, 1);
		g.lineTo(30, 15);
		g.moveTo(286, 1);
		g.lineTo(286, 15);
		
		// 中心
		g.lineStyle(3, 0x808090, 1.0, true);
		g.beginFill(0x606066);
		g.drawRoundRect(30, 20, 255, 170, 20, 20);
		g.endFill();
		
		g.lineStyle(1, 0xB08090);
		g.moveTo(40, 26);
		g.lineTo(115, 26);
		g.moveTo(235, 26);
		g.lineTo(275, 26);
		g.lineStyle(0);
		
		g.lineStyle(1, 0x000050);
		g.moveTo(40, 29);
		g.lineTo(115, 29);
		g.moveTo(235, 29);
		g.lineTo(275, 29);
		g.lineStyle(0);
		
		g.lineStyle(0);
		g.beginFill(0xFF0000);
		g.drawCircle(52, 75, 3);
		g.endFill();
		
		g.lineStyle(6, 0x505050);
		g.beginFill(0);
		g.drawRect(75, 38, 160, 144);
		g.endFill();
		
		// ボタン
		g.lineStyle(2, 0x505050);
		g.beginFill(0xC000C0);
		g.drawCircle(230, 250, 13);
		g.drawCircle(270, 250, 13);
		g.endFill();
		
		g.beginFill(0xC0C0C0);
		g.drawRoundRect(160, 245, 30, 8, 5, 5);
		g.drawRoundRect(115, 245, 30, 8, 5, 5);
		g.endFill();
		
		addChild(s);
		
		var text1:TextField;
		text1 = new TextField();
		text1.selectable = false;
		text1.x = 36;
		text1.y = 80;
		text1.htmlText = '<font size="6" color="#FFFFFF">BATTERY</font>';
		addChild(text1);
		
		var text2:TextField;
		text2 = new TextField();
		text2.selectable = false;
		text2.width = 120;
		text2.height = 10;
		text2.x = 118;
		text2.y = 23;
		text2.htmlText = '<font size="6" color="#FFFFFF">DOT MATRIX WITHOUT STEREO SOUND</font>';
		addChild(text2);
		
		var text3:TextField;
		text3 = new TextField();
		text3.selectable = false;
		text3.x = 32;
		text3.y = 193;
		text3.htmlText = '<font size="8" color="#000088"><b>Nintonde</b></font>';
		addChild(text3);
		
		var text4:TextField;
		text4 = new TextField();
		text4.selectable = false;
		text4.x = 70;
		text4.y = 190;
		text4.htmlText = '<font size="12" color="#000088"><b>GAME BOY</b></font>';
		addChild(text4);
		
		var text5:TextField;
		text5 = new TextField();
		text5.selectable = false;
		text5.x = 264;
		text5.y = 270;
		text5.htmlText = '<font size="12" color="#000088"><b>X</b></font>';
		addChild(text5);
		
		var text6:TextField;
		text6 = new TextField();
		text6.selectable = false;
		text6.x = 224;
		text6.y = 270;
		text6.htmlText = '<font size="12" color="#000088"><b>Z</b></font>';
		addChild(text6);
		
		var text7:TextField;
		text7 = new TextField();
		text7.selectable = false;
		text7.x = 169;
		text7.y = 270;
		text7.htmlText = '<font size="12" color="#000088"><b>S</b></font>';
		addChild(text7);
		
		var text8:TextField;
		text8 = new TextField();
		text8.selectable = false;
		text8.x = 124;
		text8.y = 270;
		text8.htmlText = '<font size="12" color="#000088"><b>A</b></font>';
		addChild(text8);
	}
	
}


import flash.display.SimpleButton;
class Button extends SimpleButton
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public function Button(caption:String = "ボタン", width:uint = 100, height:uint = 20) 
	{
        upState = makeButton(0xDDDDDD, width, height, height / 2, caption);
        overState = makeButton(0xEEEEEE, width, height, height / 2, caption);
        downState = makeButton(0xCCCCCC, width, height, height / 2, caption);
        hitTestState = upState;
	}
    
    /**
     * ボタンを作って返す
     * @param    color    色
     * @param    width    幅
     * @param    height    高さ
     * @param    round    角丸の大きさ
     * @param    text    ボタンのテキスト
     * @return    ボタン
     */
    private function makeButton(color:uint, width:int, height:int, round:int, text:String):Sprite
    {
        var t:TextField = new TextField();
        var s:Sprite = new Sprite();
        s.graphics.lineStyle(2);
        s.graphics.beginFill(color);
        s.graphics.drawRoundRect(0, 0, width, height, round);
        s.graphics.endFill();
		
        t.text = text;
        t.selectable = false;
        t.width = width;
        t.autoSize = TextFieldAutoSize.CENTER;
        s.addChild(t);
        
        return s;
    }
	
}



/**
 * ...
 * @author Hikipuro
 */
class GbCart 
{
	import flash.utils.ByteArray;
	
	public var title:String = "";
	public var type:String = "";
	public var typeCode:uint = 0;
	public var romBanks:uint = 0;
	public var ramBanks:uint = 0;
	public var haveSram:Boolean = false;
	public var sram:Vector.<uint>;
	private var rom_bank:uint;
	private var rom:Vector.<uint>;
	
	private var mbc1type:uint = 0;
	private var mbc1_0x2000:uint = 0;
	private var mbc1_0x4000:uint = 0;
	private var mbc1_ram_bank:uint = 0;
	
	public function GbCart(byteArray:ByteArray) 
	{
		if (byteArray.length < 0x150)
			return;
			
		mbc1type = 0;
		mbc1_0x2000 = 0;
		mbc1_0x4000 = 0;
		mbc1_ram_bank = 0;
		
		rom_bank = 0;
		
		rom = new Vector.<uint>();
		rom.fixed = false;
		rom.length = byteArray.length;
		rom.fixed = true;
		
		byteArray.position = 0;
		for (var i:uint = 0; i < byteArray.length; i++)
			rom[i] = (byteArray.readByte() & 0xFF);
		
		sram = new Vector.<uint>();
		sram.fixed = false;
		sram.length = 8192 * 4;
		sram.fixed = true;
		
		byteArray.position = 0x134;
		title = byteArray.readUTFBytes(15);
		
		byteArray.position = 0x147;
		typeCode = byteArray.readByte();
		switch (typeCode) 
		{
			case 0x00: type = "ROM Only"; break;
			case 0x01: type = "ROM+MBC1"; break;
			case 0x02: type = "ROM+MBC1+RAM"; haveSram = true; break;
			case 0x03: type = "ROM+MBC1+RAM+BATTERY"; haveSram = true; break;
			case 0x05: type = "ROM+MBC2"; break;
			case 0x06: type = "ROM+MBC2+BATTERY"; break;
			case 0x08: type = "ROM+RAM"; haveSram = true; break;
			case 0x09: type = "ROM+RAM+BATTERY"; haveSram = true; break;
			case 0x0B: type = "ROM+MMM01"; break;
			case 0x0C: type = "ROM+MMM01+SRAM"; haveSram = true; break;
			case 0x0D: type = "ROM+MMM01+SRAM+BATT"; haveSram = true; break;
			case 0x0F: type = "ROM+MBC3+TIMER+BATT"; break;
			case 0x10: type = "ROM+MBC3+TIMER+RAM+BATT"; haveSram = true; break;
			case 0x11: type = "ROM+MBC3"; break;
			case 0x12: type = "ROM+MBC3+RAM"; haveSram = true; break;
			case 0x13: type = "ROM+MBC3+RAM+BATT"; haveSram = true; break;
			case 0x19: type = "ROM+MBC5"; break;
			case 0x1A: type = "ROM+MBC5+RAM"; haveSram = true; break;
			case 0x1B: type = "ROM+MBC5+RAM+BATT"; haveSram = true; break;
			case 0x1C: type = "ROM+MBC5+RUMBLE"; break;
			case 0x1D: type = "ROM+MBC5+RUMBLE+SRAM"; haveSram = true; break;
			case 0x1E: type = "ROM+MBC5+RUMBLE+SRAM+BATT"; haveSram = true; break;
			case 0x1F: type = "Pocket Camera"; break;
			case 0xFD: type = "Bandai TAMA5"; break;
			case 0xFE: type = "Hudson HuC3"; break;
			case 0xFF: type = "ROM+HuC1+RAM+BATTERY"; haveSram = true; break;
		}
		byteArray.position = 0x148;
		switch (byteArray.readByte())
		{
			case 0x00: romBanks = 2; break;
			case 0x01: romBanks = 4; break;
			case 0x02: romBanks = 8; break;
			case 0x03: romBanks = 16; break;
			case 0x04: romBanks = 32; break;
			case 0x05: romBanks = 64; break;
			case 0x06: romBanks = 128; break;
			case 0x52: romBanks = 72; break;
			case 0x53: romBanks = 80; break;
			case 0x54: romBanks = 96; break;
		}
		byteArray.position = 0x149;
		switch (byteArray.readByte())
		{
			case 0x00: ramBanks = 0; break;
			case 0x01: ramBanks = 1; break;
			case 0x02: ramBanks = 1; break;
			case 0x03: ramBanks = 4; break;
			case 0x04: ramBanks = 16; break;
		}
	}
	
	public function read(adr:uint):uint
	{
		return rom[adr];
	}
	
	public function readBank(adr:uint):uint
	{
		switch (typeCode) 
		{
			case 0x00: // "ROM Only"
				return rom[adr];
			case 0x01: // "ROM+MBC1"
				return readMBC1(adr);
			case 0x02: // "ROM+MBC1+RAM"
				return readMBC1(adr);
				break;
			case 0x03: // "ROM+MBC1+RAM+BATTERY"
				return readMBC1(adr);
				break;
			case 0x05: // "ROM+MBC2"
				return readMBC2(adr);
				break;
			case 0x06: // "ROM+MBC2+BATTERY"
				return readMBC2(adr);
				break;
			case 0x08: // "ROM+RAM"
				break;
			case 0x09: // "ROM+RAM+BATTERY"
				break;
			case 0x0B: // "ROM+MMM01"
				break;
			case 0x0C: // "ROM+MMM01+SRAM"
				break;
			case 0x0D: // "ROM+MMM01+SRAM+BATT"
				break;
			case 0x0F: // "ROM+MBC3+TIMER+BATT"
				break;
			case 0x10: // "ROM+MBC3+TIMER+RAM+BATT"
				break;
			case 0x11: // "ROM+MBC3"
				break;
			case 0x12: // "ROM+MBC3+RAM"
				break;
			case 0x13: // "ROM+MBC3+RAM+BATT"
				break;
			case 0x19: // "ROM+MBC5"
				break;
			case 0x1A: // "ROM+MBC5+RAM"
				break;
			case 0x1B: // "ROM+MBC5+RAM+BATT"
				break;
			case 0x1C: // "ROM+MBC5+RUMBLE"
				break;
			case 0x1D: // "ROM+MBC5+RUMBLE+SRAM"
				break;
			case 0x1E: // "ROM+MBC5+RUMBLE+SRAM+BATT"
				break;
			case 0x1F: // "Pocket Camera"
				break;
			case 0xFD: // "Bandai TAMA5"
				break;
			case 0xFE: // "Hudson HuC3"
				break;
			case 0xFF: // "ROM+HuC1+RAM+BATTERY"
				break;
		}
		return 0;
	}
	
	public function write(adr:uint, dat:uint):void
	{
		switch (typeCode) 
		{
			case 0x00: // "ROM Only"
				break;
			case 0x01: // "ROM+MBC1"
				writeMBC1(adr, dat);
				break;
			case 0x02: // "ROM+MBC1+RAM"
				writeMBC1(adr, dat);
				break;
			case 0x03: // "ROM+MBC1+RAM+BATTERY"
				writeMBC1(adr, dat);
				break;
			case 0x05: // "ROM+MBC2"
				writeMBC2(adr, dat);
				break;
			case 0x06: // "ROM+MBC2+BATTERY"
				writeMBC2(adr, dat);
				break;
			case 0x08: // "ROM+RAM"
				break;
			case 0x09: // "ROM+RAM+BATTERY"
				break;
			case 0x0B: // "ROM+MMM01"
				break;
			case 0x0C: // "ROM+MMM01+SRAM"
				break;
			case 0x0D: // "ROM+MMM01+SRAM+BATT"
				break;
			case 0x0F: // "ROM+MBC3+TIMER+BATT"
				break;
			case 0x10: // "ROM+MBC3+TIMER+RAM+BATT"
				break;
			case 0x11: // "ROM+MBC3"
				break;
			case 0x12: // "ROM+MBC3+RAM"
				break;
			case 0x13: // "ROM+MBC3+RAM+BATT"
				break;
			case 0x19: // "ROM+MBC5"
				break;
			case 0x1A: // "ROM+MBC5+RAM"
				break;
			case 0x1B: // "ROM+MBC5+RAM+BATT"
				break;
			case 0x1C: // "ROM+MBC5+RUMBLE"
				break;
			case 0x1D: // "ROM+MBC5+RUMBLE+SRAM"
				break;
			case 0x1E: // "ROM+MBC5+RUMBLE+SRAM+BATT"
				break;
			case 0x1F: // "Pocket Camera"
				break;
			case 0xFD: // "Bandai TAMA5"
				break;
			case 0xFE: // "Hudson HuC3"
				break;
			case 0xFF: // "ROM+HuC1+RAM+BATTERY"
				break;
		}
	}
	
	public function readSram(adr:uint):uint
	{
		var offset:uint;
		switch (typeCode) 
		{
			case 0x03: // "ROM+MBC1+RAM+BATTERY"
				if (adr < 0x1000)
					return sram[adr];
				offset = mbc1_ram_bank * 0x1000;
				return sram[adr + offset];
				break;
		}
		return sram[adr];
	}
	
	public function writeSram(adr:uint, dat:uint):void
	{
		var offset:uint;
		switch (typeCode) 
		{
			case 0x03: // "ROM+MBC1+RAM+BATTERY"
				if (adr < 0x1000)
					sram[adr] = dat;
				offset = mbc1_ram_bank * 0x1000;
				sram[adr + offset] = dat;
				break;
		}
		sram[adr] = dat;
	}
	
	public function readMBC1(adr:uint):uint
	{
		var offset:uint;
		
		if (mbc1type == 0) {
			offset = mbc1_0x4000 | mbc1_0x2000;
			offset *= 0x4000;
		} else {
			offset = mbc1_0x2000;
			offset *= 0x4000;
		}
		
		adr &= 0x3FFF;
		
		return rom[adr + offset];
	}
	
	public function writeMBC1(adr:uint, dat:uint):void
	{
		if (adr >= 0x6000 && adr <= 0x7FFF) {
			mbc1type = dat & 0x01;
			return;
		}
		
		if (adr >= 0x2000 && adr <= 0x3FFF)
			mbc1_0x2000 = (dat & 0x1F);
		if (adr >= 0x4000 && adr <= 0x5FFF) {
			mbc1_0x4000 = ((dat & 0x03) << 5);
			mbc1_ram_bank = (dat & 0x03);
		}
	}
	
	public function readMBC2(adr:uint):uint
	{
		var offset:uint;
		offset = mbc1_0x4000 | mbc1_0x2000;
		offset *= 0x4000;
		
		adr &= 0x3FFF;
		
		return rom[adr + offset];
	}
	
	public function writeMBC2(adr:uint, dat:uint):void
	{
		if (adr >= 0x6000 && adr <= 0x7FFF) {
			mbc1type = dat & 0x01;
			mbc1_0x2000 = 0;
			mbc1_0x4000 = 0;
			return;
		}
		
		if (mbc1type == 0) {
			if (adr >= 0x2000 && adr <= 0x3FFF)
				mbc1_0x2000 = (dat & 0x1F);
			if (adr >= 0x4000 && adr <= 0x5FFF)
				mbc1_0x4000 = ((dat & 0x03) << 5);
		}
		else {
			if (adr >= 0x2000 && adr <= 0x3FFF)
				mbc1_0x2000 = (dat & 0x1F);
			mbc1_0x4000 = 0;
		}
	}
	
}


/**
 * ...
 */
class GbApu 
{
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.utils.ByteArray;

	private var NR10:uint, NR11:uint, NR12:uint, NR13:uint, NR14:uint;
	private var NR21:uint, NR22:uint, NR23:uint, NR24:uint;
	private var NR30:uint, NR31:uint, NR32:uint, NR33:uint, NR34:uint;
	private var NR41:uint, NR42:uint, NR43:uint, NR44:uint;
	private var NR50:uint, NR51:uint, NR52:uint;
	private var WaveRAM:Vector.<uint>;
	//private var sound:Sound;
	
	private var counter1:int;
	private var length1:uint;
	private var sweep1:uint;
	private var duty1:uint;
	private var volume1:uint;
	private var decay1:uint;
	private var env_counter1:uint;
	
	private var total_clock:int;
	private var div_clock:int;
	private var tick1d256:int;
	
	private var ringBuffer:Vector.<Number>;
	private var pointer:int;
	private var pointerPlay:int;
	
	private const duty12:Array = [0, 15, 15, 15, 15, 15, 15, 15];
	private const duty25:Array = [0, 15, 15, 15];
	private const duty50:Array = [0, 15];
	private const duty75:Array = [0, 0, 0, 15];
	
	public function GbApu() 
	{
		WaveRAM = new Vector.<uint>();
		WaveRAM.length = 0x10;
		WaveRAM.fixed = true;
		
		NR10 = 0x80; NR11 = 0xBF; NR12 = 0xF3; NR14 = 0xBF;
		NR21 = 0x3F; NR22 = 0x00; NR24 = 0xBF;
		NR30 = 0x7F; NR31 = 0xFF; NR32 = 0x9F; NR33 = 0xBF;
		NR41 = 0xFF; NR42 = 0x00; NR43 = 0x00; NR44 = 0xBF;
		NR50 = 0x77; NR51 = 0xF3; NR52 = 0xF1;
		
		counter1 = 0;
		length1 = 0;
		sweep1 = 0;
		volume1 = 0;
		decay1 = 0;
		env_counter1 = 0;
		
		total_clock = 0;
		div_clock = 0;
		tick1d256 = 0;
		
		ringBuffer = new Vector.<Number>();
		ringBuffer.length = 8192 * 4;
		ringBuffer.fixed = true;
		pointer = 0;
		pointerPlay = 0;
		
		//sound = new Sound();
		//sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		//sound.play(0, 1);
	}
	
	public function read(adr:uint):uint 
	{
		adr &= 0x2F;
		switch (adr) 
		{
			case 0x00: return NR10 & 0xFF;
			case 0x01: return NR11 & 0xC0;
			case 0x02: return NR12 & 0xFF;
			case 0x03: return 0;
			case 0x04: return NR14 & 0x40;
			case 0x05: return 0xFF;
			case 0x06: return NR21 & 0xC0;
			case 0x07: return NR22 & 0xFF;
			case 0x08: return NR23 & 0xFF;
			case 0x09: return NR24 & 0x40;
			case 0x0A: return NR30 & 0x80;
			case 0x0B: return NR31 & 0xFF;
			case 0x0C: return NR32 & 0x60;
			case 0x0D: return NR33 & 0xFF;
			case 0x0E: return NR34 & 0x40;
			case 0x0F: return 0xFF;
			case 0x10: return NR41 & 0xFF;
			case 0x11: return NR42 & 0xFF;
			case 0x12: return NR43 & 0xFF;
			case 0x13: return NR44 & 0x40;
			case 0x14: return NR50 & 0xFF;
			case 0x15: return NR51 & 0xFF;
			case 0x16: return NR52 & 0x8F;
			case 0x17: return 0xFF;
			case 0x18: return 0xFF;
			case 0x19: return 0xFF;
			case 0x1A: return 0xFF;
			case 0x1B: return 0xFF;
			case 0x1C: return 0xFF;
			case 0x1D: return 0xFF;
			case 0x1E: return 0xFF;
			case 0x1F: return 0xFF;
			case 0x20: return WaveRAM[0x00] & 0xFF;
			case 0x21: return WaveRAM[0x01] & 0xFF;
			case 0x22: return WaveRAM[0x02] & 0xFF;
			case 0x23: return WaveRAM[0x03] & 0xFF;
			case 0x24: return WaveRAM[0x04] & 0xFF;
			case 0x25: return WaveRAM[0x05] & 0xFF;
			case 0x26: return WaveRAM[0x06] & 0xFF;
			case 0x27: return WaveRAM[0x07] & 0xFF;
			case 0x28: return WaveRAM[0x08] & 0xFF;
			case 0x29: return WaveRAM[0x09] & 0xFF;
			case 0x2A: return WaveRAM[0x0A] & 0xFF;
			case 0x2B: return WaveRAM[0x0B] & 0xFF;
			case 0x2C: return WaveRAM[0x0C] & 0xFF;
			case 0x2D: return WaveRAM[0x0D] & 0xFF;
			case 0x2E: return WaveRAM[0x0E] & 0xFF;
			case 0x2F: return WaveRAM[0x0F] & 0xFF;
		}
		return 0xFF;
	}
	
	public function write(adr:uint, dat:uint):void
	{
		adr &= 0x2F;
		dat &= 0xFF;
		switch (adr) 
		{
			case 0x00:
				NR10 = dat;
				break;
			case 0x01:
				NR11 = dat;
				length1 = soundLength1;
				break;
			case 0x02:
				NR12 = dat;
				decay1 = ((NR12 >> 4) & 0x0F);
				break;
			case 0x03:
				NR13 = dat;
				break;
			case 0x04: 
				NR14 = dat;
				if (NR14 & 0x80)
					counter1 = 0;
				break;
			case 0x05:
				return;
			case 0x06:
				NR21 = dat;
				break;
			case 0x07:
				NR22 = dat;
				break;
			case 0x08:
				NR23 = dat;
				break;
			case 0x09:
				NR24 = dat;
				break;
			case 0x0A:
				NR30 = dat;
				break;
			case 0x0B:
				NR31 = dat;
				break;
			case 0x0C:
				NR32 = dat;
				break;
			case 0x0D:
				NR33 = dat;
				break;
			case 0x0E:
				NR34 = dat;
				break;
			case 0x0F:
				return;
			case 0x10:
				NR41 = dat;
				break;
			case 0x11:
				NR42 = dat;
				break;
			case 0x12:
				NR43 = dat;
				break;
			case 0x13:
				NR44 = dat;
				break;
			case 0x14:
				NR50 = dat;
				break;
			case 0x15:
				NR51 = dat;
				break;
			case 0x16:
				NR52 = dat;
				break;
			case 0x17:
				return;
			case 0x18:
				return;
			case 0x19:
				return;
			case 0x1A:
				return;
			case 0x1B:
				return;
			case 0x1C:
				return;
			case 0x1D:
				return;
			case 0x1E:
				return;
			case 0x1F:
				return;
			case 0x20:
				WaveRAM[0x00] = dat;
				break;
			case 0x21:
				WaveRAM[0x01] = dat;
				break;
			case 0x22:
				WaveRAM[0x02] = dat;
				break;
			case 0x23:
				WaveRAM[0x03] = dat;
				break;
			case 0x24:
				WaveRAM[0x04] = dat;
				break;
			case 0x25:
				WaveRAM[0x05] = dat;
				break;
			case 0x26:
				WaveRAM[0x06] = dat;
				break;
			case 0x27:
				WaveRAM[0x07] = dat;
				break;
			case 0x28:
				WaveRAM[0x08] = dat;
				break;
			case 0x29:
				WaveRAM[0x09] = dat;
				break;
			case 0x2A:
				WaveRAM[0x0A] = dat;
				break;
			case 0x2B:
				WaveRAM[0x0B] = dat;
				break;
			case 0x2C:
				WaveRAM[0x0C] = dat;
				break;
			case 0x2D:
				WaveRAM[0x0D] = dat;
				break;
			case 0x2E:
				WaveRAM[0x0E] = dat;
				break;
			case 0x2F:
				WaveRAM[0x0F] = dat;
				break;
		}
	}
	
	private function get initialEnvelopeVolume1():uint 
	{
		return ((NR12 >> 4) & 0x0F);
	}
	
	private function get envelopeDirection1():int 
	{
		return ((NR12 >> 3) & 0x01) == 1 ? 1 : -1;
	}
	
	private function get envelopeWait1():uint
	{
		return (NR12 & 0x07);
	}
	
	private function get soundLength1():uint
	{
		return 64 - (NR11 & 0x3F);
	}
	
	private function get sweepWait1():uint
	{
		return ((NR10 >> 4) & 0x07);
	}
	
	private function get sweepDirection1():uint
	{
		return ((NR10 >> 3) & 0x01);
	}
	
	private function get sweepShift1():uint
	{
		return (NR10 & 0x07);
	}
	
	private function get wavePatternDuty1():uint
	{
		switch ((NR11 >> 6) & 0x03) {
			case 0: return 2;
			case 1: return 4;
			case 2: return 8;
			case 3: return 12;
		}
		return 0;
	}
	
	public function exec(clock:uint):void 
	{
		if (!(NR52 & 0x80)) // sound off
			return;
		return;
	
		total_clock += clock;
		div_clock += clock;
		
		var count:uint;
		var i:uint;
		
		if (NR52 & 0x01) { // Channel 1 enabled
			counter1 += clock;
			count = NR13 | ((NR14 & 0x07) << 8);
			
			// programable counter & duty cycle
			if (counter1 > count) {
				counter1 -= count;
				duty1++;
				
				if (duty1 == 16)
					duty1 = 0;
			}
			//for (i = 0; i < clock; i++)
			//{
				if (duty1 < wavePatternDuty1) {
					if ((NR12 & 0x07) == 0) { // decay off
						volume1 += (((NR12 >> 4) & 0x0F) * clock);
					} else { // decay on
						volume1 += (decay1 * clock);
					}
				}
			//}
			
		}
			
		// 1/256 second
		if (total_clock > 4096) {
			total_clock -= 4096;
			tick1d256++;
			
			tick256();
			switch (tick1d256) {
				case 2:
					tick128();
					break;
				case 4:
					tick128();
					tick64();
					tick1d256 = 0;
					break;
				
			}
		}
		
		// 1/32768 (32) second
		if (div_clock > 23) {
			var v:Number;
			
			v = 0;
			div_clock -= 23;
			
			// sound 1 enabled
			if (NR52 & 0x01) {
				if (length1 != 0)
					v += volume1;
				volume1 = 0;
			}
			
			v /= (23 * 16);
			ringBuffer[pointer] = v;
			pointer++;
			if (pointer >= ringBuffer.length)
				pointer = 0;
		}
	}
	
	private function tick256():void 
	{
		if (NR52 & 0x01) {
			if (length1 > 0)
				length1--;
			/*if (soundLength1 <= length1) {
				length1 = 0;
				// sound1 off
				if (NR14 & 0x40)
					NR52 &= 0xFE;
			}*/
		}
	}
	
	private function tick128():void 
	{
		var waveLen:int;
		
		if ((NR52 & 0x01) && (length1 != 0) && (sweepShift1 != 0)) {
			sweep1++;
			if (sweep1 >= sweepWait1) {
				sweep1 = 0;
				waveLen = NR13 | ((NR14 & 0x07) << 8);
				
				//if (waveLen <= 8)
				//	return;
				
				switch (sweepDirection1) {
				case 0: // positive
					waveLen = waveLen + (waveLen >> sweepShift1);
					//if (waveLen >= 0x800)
					//	waveLen = 0;
					break;
				case 1: // negative
					waveLen = waveLen - (waveLen >> sweepShift1);
					//if (newWaveLen < 0)
					//	newWaveLen = 0;
					break;
				}
				NR13 = (waveLen & 0xFF);
				NR14 &= 0xF8;
				NR14 |= ((waveLen >> 8) & 0x07);
			}
		}
	}
	
	private function tick64():void 
	{
		if (NR52 & 0x01) {
			env_counter1++;
			
			// decay calc & decay reload
			if (env_counter1 >= envelopeWait1) {
				env_counter1 = 0;
				decay1 += envelopeDirection1;
				//decay1 &= 0x0F;
				if (decay1 <= 0) 
					decay1 = 0;
				if (decay1 >= 16)
					decay1 = 15;
					//if (!(NR14 & 0x40)) {
					//	decay1 = initialEnvelopeVolume1;
					//} else {
					//	;//decay1 = 0;
					//}
				//}
				//}
			}
		}
	}
	
}
	

/**
 * ...
 */
class GB 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;

private const CY:Array =
[
//   0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
	 4,12, 8, 8, 4, 4, 8, 4,20, 8, 8, 8, 4, 4, 8, 4,//0
	 4,12, 8, 8, 4, 4, 8, 4,12, 8, 8, 8, 4, 4, 8, 4,//1
	 8,12, 8, 8, 4, 4, 8, 4, 8, 8, 8, 8, 4, 4, 8, 4,//2
	 8,12, 8, 8,12,12,12, 4, 8, 8, 8, 8, 4, 4, 8, 4,//3
	 4, 4, 4, 4, 4, 4, 8, 4, 4, 4, 4, 4, 4, 4, 8, 4,//4
	 4, 4, 4, 4, 4, 4, 8, 4, 4, 4, 4, 4, 4, 4, 8, 4,//5
	 4, 4, 4, 4, 4, 4, 8, 4, 4, 4, 4, 4, 4, 4, 8, 4,//6
	 8, 8, 8, 8, 8, 8, 4, 8, 4, 4, 4, 4, 4, 4, 8, 4,//7
	 4, 4, 4, 4, 4, 4, 8, 4, 4, 4, 4, 4, 4, 4, 8, 4,//8
	 4, 4, 4, 4, 4, 4, 8, 4, 4, 4, 4, 4, 4, 4, 8, 4,//9
	 4, 4, 4, 4, 4, 4, 8, 4, 4, 4, 4, 4, 4, 4, 8, 4,//A
	 4, 4, 4, 4, 4, 4, 8, 4, 4, 4, 4, 4, 4, 4, 8, 4,//B
	 8,12,12,16,12,16, 8,16, 8,16,12, 0,12,24, 8,16,//C
	 8,12,12, 0,12,16, 8,16, 8,16,12, 0,12, 0, 8,16,//D
	12,12, 8, 0, 0,16, 8,16,16, 4,16, 0, 0, 0, 8,16,//E
	12,12, 8, 4, 0,16, 8,16,12, 8,16, 4, 0, 0, 8,16 //F
];

private const CY_CB:Array =
[
//   0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,12, 8, 8, 8, 8, 8, 8, 8,12, 8,
	 8, 8, 8, 8, 8, 8,12, 8, 8, 8, 8, 8, 8, 8,12, 8,
	 8, 8, 8, 8, 8, 8,12, 8, 8, 8, 8, 8, 8, 8,12, 8,
	 8, 8, 8, 8, 8, 8,12, 8, 8, 8, 8, 8, 8, 8,12, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8,
	 8, 8, 8, 8, 8, 8,16, 8, 8, 8, 8, 8, 8, 8,16, 8
];

private const ZT:Array =
[
	ZF,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
];
private function io_read(adr:uint):uint
{
	adr &= 0xFFFF;
	var ret:uint;
	switch (adr) {
	case 0xFF00://P1(パッド制御)
		if (P1 == 0x03) {
			return 0xFF;
		}
		switch ((P1 >> 4) & 0x3) {
		case 0:
			return 0xC0|((padData&0x81?0:1)|(padData&0x42?0:2)|(padData&0x24?0:4)|(padData&0x18?0:8));
		case 1:
			return 0xD0|((padData&0x01?0:1)|(padData&0x02?0:2)|(padData&0x04?0:4)|(padData&0x08?0:8));
		case 2:
			return 0xE0|((padData&0x80?0:1)|(padData&0x40?0:2)|(padData&0x20?0:4)|(padData&0x10?0:8));
		case 3:
			return 0xFF;
		}
		return 0xDF;
	case 0xFF01://SB(シリアル通信送受信)
		return SB;
	case 0xFF02://SC(シリアルコントロール)
		return (SC & 0x83) | 0x7C;
	case 0xFF03://不明
		return 0xFF;
	case 0xFF04: return DIV; //DIV(ディバイダー?)
	case 0xFF05: return TIMA; //TIMA(タイマカウンタ)
	case 0xFF06: return TMA; //TMA(タイマ調整)
	case 0xFF07: return TAC | 0xF8; //TAC(タイマコントロール)
	case 0xFF08: // 不明
	case 0xFF09:
	case 0xFF0A:
	case 0xFF0B:
	case 0xFF0C:
	case 0xFF0D:
	case 0xFF0E:
		return 0xFF;
	case 0xFF0F: return IF; //IF(割りこみフラグ)
	case 0xFF40: return LCDC; //LCDC(LCDコントロール)
	case 0xFF41: return STAT | 0x80; //STAT(LCDステータス)
	case 0xFF42: return SCY; //SCY(スクロールY)
	case 0xFF43: return SCX; //SCX(スクロールX)
	case 0xFF44: return LY; //LY(LCDC Y座標)
	case 0xFF45: return LYC; //LYC(LY比較)
	case 0xFF46: return 0; //DMA(DMA転送)
	case 0xFF47: return BGP; //BGP(背景パレット)
	case 0xFF48: return OBP1; //OBP1(オブジェクトパレット1)
	case 0xFF49: return OBP2; //OBP2(オブジェクトパレット2)
	case 0xFF4A: return WY; //WY(ウインドウY座標)
	case 0xFF4B: return WX; //WX(ウインドウX座標)
	case 0xFF4C: return 0xFF;
		//以下カラーでの追加
	case 0xFF4D://KEY1システムクロック変更
		return 0;
	case 0xFF4F: return VBK; //VBK(内部VRAMバンク切り替え)
	case 0xFF50: return 0xFF;// 不明
		
	case 0xFF51: return dma_src >> 8; //HDMA1(転送元上位)
	case 0xFF52: return dma_src & 0xff; //HDMA2(転送元下位)
	case 0xFF53: return dma_dest >> 8; //HDMA3(転送先上位)
	case 0xFF54: return dma_dest & 0xff; //HDMA4(転送先下位)
	case 0xFF55://HDMA5(転送実行)
		return 0xFF;
	case 0xFF56://RP(赤外線)
		return 0;
	case 0xFF68: return BCPS; //BCPS(BGパレット書き込み指定)
	case 0xFF69://BCPD(BGパレット書きこみデータ)
		return ret;
	case 0xFF6A: return OCPS; //OCPS(OBJパレット書きこみ指定)
	case 0xFF6B://OCPD(OBJパレット書きこみデータ)
		return ret;
	case 0xFF70: return SVBK; //SVBK(内部RAMバンク切り替え)
	case 0xFFFF: return IE; //IE(割りこみマスク)
	// undocumented register
	case 0xFF6C: return _ff6c & 1;
	case 0xFF72: return _ff72;
	case 0xFF73: return _ff73;
	case 0xFF74: return _ff74;
	case 0xFF75: return _ff75 & 0x70;
	case 0xFF76: return 0;
	case 0xFF77: return 0;
	default:
		if (adr > 0xFF0F && adr < 0xFF40) {
			return apu.read(adr - 0xFF10);
		}
		else if ((adr > 0xff70) && (adr < 0xff80)) {
			return ext_mem[adr - 0xff71] & 0xFF;
		} else
			return 0xFF;
	}
	return 0xFF;
}

private function io_write(adr:uint, dat:uint):void
{
	adr &= 0xFFFF;
	dat &= 0xFF;
	switch(adr){
	case 0xFF00://P1(パッド制御)
		P1 = dat;
		return;
	case 0xFF01://SB(シリアルシリアル通信送受信)
		SB = dat;
		return;
	case 0xFF02://SC(コントロール)
		if (gb_type==1){
			SC = dat & 0x81;
		}
		else{ // GBCでの拡張
			SC = dat & 0x83;
		}
		return;
	case 0xFF04://DIV(ディバイダー)
		DIV = 0;
		return;
	case 0xFF05://TIMA(タイマカウンタ)
		TIMA = dat;
		return;
	case 0xFF06://TMA(タイマ調整)
		TMA = dat;
		return;
	case 0xFF07://TAC(タイマコントロール)
		if ((dat & 0x04) && !(TAC & 0x04))
			sys_clock=0;
		TAC = dat;
		return;
	case 0xFF0F://IF(割りこみフラグ)
		IF = dat;
		return;
	case 0xFF40://LCDC(LCDコントロール)
		if ((dat & 0x80) && (!(LCDC & 0x80))) {
			LY = 0;
			//ref_gb->get_lcd()->clear_win_count();
		}
		LCDC = dat;
		return;
	case 0xFF41://STAT(LCDステータス)
		if (gb_type == 1) // オリジナルGBにおいてこのような現象が起こるらしい
			if (!(STAT & 0x02))
				IF |= INT_LCDC;

		STAT = (STAT & 0x7) | (dat & 0x78);
		return;
	case 0xFF42://SCY(スクロールY)
		SCY = dat;
		return;
	case 0xFF43://SCX(スクロールX)
		SCX = dat;
		return;
	case 0xFF44://LY(LCDC Y座標)
		//ref_gb->get_lcd()->clear_win_count();
		return;
	case 0xFF45://LYC(LY比較)
		LYC = dat;
		return;
	case 0xFF46://DMA(DMA転送)
		if (dat > 0xF1)
			return;
		
		var i:uint;
		dat *= 256;
		for (i = 0; i < 0xA0; i++)
			oam[i] = read(dat + i);
		dma_remain = 167;
		return;
	case 0xFF47://BGP(背景パレット)
		BGP = dat;
		return;
	case 0xFF48://OBP1(オブジェクトパレット1)
		OBP1 = dat;
		return;
	case 0xFF49://OBP2(オブジェクトパレット2)
		OBP2 = dat;
		return;
	case 0xFF4A://WY(ウインドウY座標)
		WY = dat;
		return;
	case 0xFF4B://WX(ウインドウX座標)
		WX = dat;
		return;

		//以下カラーでの追加
	case 0xFF4D://KEY1システムクロック変更
		KEY1 = dat & 1;
		return;
	case 0xFF4F://VBK(内部VRAMバンク切り替え)
		return;
	case 0xFF51://HDMA1(転送元上位)
		dma_src &= 0x00F0;
		dma_src |= (dat << 8);
		return;
	case 0xFF52://HDMA2(転送元下位)
		dma_src &= 0xFF00;
		dma_src |= (dat & 0xF0);
		return;
	case 0xFF53://HDMA3(転送先上位)
		dma_dest &= 0x00F0;
		dma_dest |= ((dat & 0xFF) << 8);
		return;
	case 0xFF54://HDMA4(転送先下位)
		dma_dest &= 0xFF00;
		dma_dest |= (dat & 0xF0);
		return;
	case 0xFF55://HDMA5(転送実行)
		return;
	case 0xFF56://RP(赤外線)
		return;
	case 0xFF68://BCPS(BGパレット書き込み指定)
		BCPS = dat;
		return;
	case 0xFF69://BCPD(BGパレット書きこみデータ xBBBBBGG GGGRRRRR)
		return;
	case 0xFF6A://OCPS(OBJパレット書きこみ指定)
		OCPS = dat;
		return;
	case 0xFF6B://OCPD(OBJパレット書きこみデータ)
		return;
	case 0xFF70://SVBK(内部RAMバンク切り替え)
		return;

	case 0xFFFF://IE(割りこみマスク)
		IE = dat;
		return;

	// undocumented register
	case 0xFF6C: _ff6c = dat & 1; return;
	case 0xFF72: _ff72 = dat; return;
	case 0xFF73: _ff73 = dat; return;
	case 0xFF74: _ff74 = dat; return;
	case 0xff75: _ff75 = dat & 0x70; return;

	default:
		if (adr > 0xFF0F && adr < 0xFF40) {
			apu.write(adr - 0xFF10, dat);
			//apu.write(adr,dat,total_clock);
			return;
		}
		else if ((adr > 0xff70) && (adr < 0xff80))
			ext_mem[adr - 0xff71] = dat;
	}
}


public function ADD(arg:uint):void 
{
	A &= 0xFF;
	arg &= 0xFF;
	var tmp:uint = A + arg;
	var tmpl:uint = tmp & 0xFF;
	var tmph:uint = (tmp >> 8) & 0x01;
	F = tmph | ZTable[tmpl] | ((A ^ arg ^ tmpl) & HF);
	A = tmpl;
}

private function ADC(arg:uint):void 
{
	A &= 0xFF;
	arg &= 0xFF;
	var tmp:uint = A + arg + (F & CF);
	var tmpl:uint = tmp & 0xFF;
	var tmph:uint = (tmp >> 8) & 0x01;
	F = tmph | ZTable[tmpl] | ((A ^ arg ^ tmpl) & HF);
	A = tmpl;
}

private function SUB(arg:uint):void 
{
	A &= 0xFF;
	arg &= 0xFF;
	var tmp:uint = (A - arg) & 0x1FF;
	var tmpl:uint = tmp & 0xFF;
	var tmph:uint = (tmp >> 8) & 0x01;
	F = NF | tmph | ZTable[tmpl] | ((A ^ arg ^ tmpl) & HF);
	A = tmpl;
}

private function SBC(arg:uint):void 
{
	A &= 0xFF;
	arg &= 0xFF;
	var tmp:uint = (A - arg - (F & CF)) & 0x1FF;
	var tmpl:uint = tmp & 0xFF;
	var tmph:uint = (tmp >> 8) & 0x01;
	F = NF | tmph | ZTable[tmpl] | ((A ^ arg ^ tmpl) & HF);
	A = tmpl;
}

private function CP(arg:uint):void 
{
	A &= 0xFF;
	arg &= 0xFF;
	var tmp:uint = (A - arg) & 0x1FF;
	var tmpl:uint = tmp & 0xFF;
	var tmph:uint = (tmp >> 8) & 0x01;
	F = NF | tmph | ZTable[tmpl] | ((A ^ arg ^ tmpl) & HF);
}

private function AND(arg:uint):void 
{
	A &= arg;
	A &= 0xFF;
	F = HF | ZTable[A];
}

private function OR(arg:uint):void 
{
	A |= arg;
	A &= 0xFF;
	F = ZTable[A];
}

private function XOR(arg:uint):void 
{
	A ^= arg;
	A &= 0xFF;
	F = ZTable[A];
}

private function INC(arg:uint):uint 
{
	arg++;
	arg &= 0xFF;
	F = (F & CF) | ZTable[arg] | ((arg & 0x0F) ? 0 : HF);
	return arg;
}

private function DEC(arg:uint):uint 
{
	arg--;
	arg &= 0xFF;
	F = NF | (F & CF) | ZTable[arg] | (((arg & 0x0F) == 0x0F) ? HF : 0);
	return arg;
}

private function ADDW(arg:uint):void 
{
	arg &= 0xFFFF;
	var hl:uint = (HL & 0xFFFF);
	var tmp:uint = hl + arg;
	F = (F & ZF) | (((hl ^ arg ^ tmp) & 0x1000) ? HF : 0) | ((tmp & 0x10000) ? CF : 0);
	H = (tmp >> 8) & 0xFF;
	L = (tmp & 0xFF);
}

	public var dataLoaded:Boolean = false;
	public var output:BitmapData;
	
	public var cart:GbCart;
	private var apu:GbApu = new GbApu();
	
	// VRAM のタイルを入れる
	private var tile:Vector.<BitmapData>;
	
	private var gb_type:uint = 1;
	public var padData:uint;
	public var stopPC:uint = 0;
	public var stepFlag:Boolean = false;
	public var A:uint, B:uint, C:uint, D:uint, E:uint, F:uint;
	public var H:uint, L:uint, SP:uint, PC:uint, cycles:uint, I:uint;
	private var int_desable:Boolean, halt:Boolean, tmp_clocks:uint;
	private var last_int:uint;
	public var count:uint = 0;
	
	private var sys_clock:uint, rest_clock:int, div_clock:uint, total_clock:uint;
	
	private var P1:uint, SB:uint, SC:uint, DIV:uint, TIMA:uint, TMA:uint, TAC:uint;
	private var IF:uint, LCDC:uint, STAT:uint, SCY:uint, SCX:uint, LY:uint, LYC:uint;
	private var DMA:uint, BGP:uint, OBP1:uint, OBP2:uint, WY:uint, WX:uint, IE:uint;
	
	private var KEY1:uint, VBK:uint, HDMA1:uint, HDMA2:uint, HDMA3:uint, HDMA4:uint;
	private var HDMA5:uint, RP:uint, BCPS:uint, BCPD:uint, OCPS:uint, OCPD:uint, SVBK:uint;
	
	private var _ff6c:uint, _ff72:uint, _ff73:uint, _ff74:uint, _ff75:uint;
	private var ext_mem:Vector.<uint>;
	
	private var dma_src:uint, dma_dest:uint;
	private var dma_remain:uint;
	
	private var z802gb:Vector.<uint>, gb2z80:Vector.<uint>;

	private var ram:Vector.<uint>;
	private var vram:Vector.<uint>;
	private var stack:Vector.<uint>;
	private var oam:Vector.<uint>;
	private var spare_oam:Vector.<uint>;
	
	public const ZF:uint = 0x40;
	public const HF:uint = 0x10;
	public const NF:uint = 0x02;
	public const CF:uint = 0x01;
	
	public const INT_VBLANK:uint = 1;
	public const INT_LCDC:uint = 2;
	public const INT_TIMER:uint = 4;
	public const INT_SERIAL:uint = 8;
	public const INT_PAD:uint = 16;
	
	private var cys:Vector.<uint>;
	private var cys_cb:Vector.<uint>;
	private var ZTable:Vector.<uint>;
	
	public function GB() 
	{
		initTables();
		initRegisters();
		initRam();
		initRom();
	}
	
	private function get2digit(n:uint):String 
	{
		var s:String = n.toString(16).toUpperCase();
		if (s.length == 1)
			s = "0" + s;
		return s;
	}
	
	private function get4digit(n:uint):String 
	{
		var s:String = n.toString(16).toUpperCase();
		for (var i:uint = 4; i > s.length; i--)
			s = "0" + s;
		return s;
	}
	
	public function setPad(key:uint, value:Boolean):void 
	{
		var padOld:uint;
		padOld = padData;
		switch (key) {
			case Keyboard.RIGHT:
				if (value) padData |= 0x80; else padData &= 0x7F;
				break;
			case Keyboard.LEFT:
				if (value) padData |= 0x40; else padData &= 0xBF;
				break;
			case Keyboard.UP:
				if (value) padData |= 0x20; else padData &= 0xDF;
				break;
			case Keyboard.DOWN:
				if (value) padData |= 0x10; else padData &= 0xEF;
				break;
			case 88: // X (A Button)
				if (value) padData |= 0x01; else padData &= 0xFE;
				break;
			case 90: // Z (B Button)
				if (value) padData |= 0x02; else padData &= 0xFD;
				break;
			case 83: // S (Start Button)
				if (value) padData |= 0x08; else padData &= 0xF7;
				break;
			case 65: // A (Select Button)
				if (value) padData |= 0x04; else padData &= 0xFB;
				break;
		}
		if ((padOld & 0x80) != (padData & 0x80))
			irq(INT_PAD);
	}
	
	private function initRegisters():void 
	{
		A = 0x01; B = 0x00; C = 0x13; D = 0x00;
		E = 0xD8; F = 0xB0; H = 0x01; L = 0x4D;
		SP = 0xFFFE; PC = 0x100; cycles = 0;
		I = 0;
		IF = 0;
		int_desable = false;
		halt = false;
		tmp_clocks = 0;
		sys_clock = 0;
		rest_clock = 0;
		div_clock = 0;
		total_clock = 0;
		
		DIV = 0x72;
		TIMA = 0x00; TMA = 0x00; TAC = 0x00;
		LCDC = 0x91; SCY = 0x00; SCX = 0x00; LYC = 0x00;
		BGP = 0xFC; OBP1 = 0xFF; OBP2 = 0xFF;
		WY = 0x00; WX = 0x00; IE = 0x00;
		P1 = 0x00;
	}
	
	/**
	 * 配列になっているデータの初期化
	 */
	private function initTables():void 
	{
		var i:uint;
		z802gb = new Vector.<uint>();
		gb2z80 = new Vector.<uint>();
		
		z802gb.length = 256;
		z802gb.fixed = true;
		gb2z80.length = 256;
		gb2z80.fixed = true;
		
		for (i = 0; i < 256; i++) {
			z802gb[i] = ((i & 0x40)?0x80:0) | ((i & 0x10)?0x20:0) | ((i & 0x02)?0x40:0) | ((i & 0x01)?0x10:0);
			gb2z80[i] = ((i & 0x80)?0x40:0) | ((i & 0x40)?0x02:0) | ((i & 0x20)?0x10:0) | ((i & 0x10)?0x01:0);
		}
		
		ext_mem = new Vector.<uint>();
		ext_mem.length = 0x10;
		ext_mem.fixed = true;
		
		cys = new Vector.<uint>();
		cys.length = 0x102;
		cys.fixed = true;
		
		cys_cb = new Vector.<uint>();
		cys_cb.length = 0x101;
		cys_cb.fixed = true;
		
		ZTable = new Vector.<uint>();
		ZTable.length = 0x104;
		ZTable.fixed = true;
		
		for (i = 0; i < 256; i++) {
			cys[i] = CY[i];
			cys_cb[i] = CY_CB[i];
			ZTable[i] = ZT[i];
		}
		
		tile = new Vector.<BitmapData>();
		tile.length = 384;
		tile.fixed = true;
		
		for (i = 0; i < 384; i++) {
			tile[i] = new BitmapData(8, 8);
		}
	}
	
	public function read_debug_memory(adr:uint):String 
	{
		var s:String = "";
		adr &= 0xFFF0;
		
		for (var j:uint = 0; j < 16; j++)
		{
			s += get4digit(adr + j * 16) + ":";
			for (var i:uint = 0; i < 16; i++)
				s += get2digit(read(adr + i + j * 16));
			s += "\n";
		}
		return s;
	}
	
	private function writeVram(adr:uint, dat:uint):void 
	{
		var i:uint = adr >> 4;
		
		if (i >= 384)
			return;
		
		tile[i].lock();
		
		var x:uint;
		var y:uint = adr & 0x0F;
		var dat2:uint;
		var color:uint;
		
		if (y % 2 == 0) {
			dat2 = vram[i * 16 + y + 1];
			for (x = 0; x < 8; x++)
			{
				color = 0;
				if (dat & (0x80 >> x))
					color = 0x555555;
				if (dat2 & (0x80 >> x))
					color |= 0xAAAAAA;
				tile[i].setPixel(x, y / 2, 0xFFFFFF - color);
			}
		} else {
			dat2 = vram[i * 16 + y - 1];
			for (x = 0; x < 8; x++)
			{
				color = 0;
				if (dat2 & (0x80 >> x))
					color = 0x555555;
				if (dat & (0x80 >> x))
					color |= 0xAAAAAA;
				tile[i].setPixel(x, y / 2, 0xFFFFFF - color);
			}
		}
		tile[i].unlock();
	}
	
	public function render(output:BitmapData):void 
	{
		if (!(LCDC & 0x80))
			return;
			
		var rect:Rectangle = new Rectangle(0, 0, 8, 8);
		output.lock();
		
		// 背景の転送
		var x1:int;
		var y1:int;
		var dx:int;
		var dy:int;
		var ti:uint;
		var ti2:uint;
		
		if (LCDC & 0x01) { // 背景表示
			for (y1 = 0; y1 < 32; y1++)
			{
				if (LCDC & 0x08)
					ti = 0x1C00 + y1 * 32;
				else 
					ti = 0x1800 + y1 * 32;
				
				dy = y1 * 8 - SCY;
				if (dy < -8)
					dy += 256;
				if (dy >= 144)
					continue;
				for (x1 = 0; x1 < 32; x1++)
				{
					dx = x1 * 8 - SCX;
					if (dx < -8)
						dx += 256;
					if (dx >= 160)
						continue;
					if (LCDC & 0x10) {
						ti2 = vram[ti + x1];
					} else {
						if (vram[ti + x1] < 128)
							ti2 = vram[ti + x1] + 256;
						else
							ti2 = vram[ti + x1];
					}
					output.copyPixels(tile[ti2], rect, new Point(dx, dy));
				}
			}
		}
		
		if (LCDC & 0x20 && WX >= 0 && WX <= 166 && WY >= 0 && WY <= 143) { // ウインドウ表示
			for (y1 = 0; y1 < 32; y1++)
			{
				if (LCDC & 0x40)
					ti = 0x1C00 + y1 * 32;
				else 
					ti = 0x1800 + y1 * 32;
				
				dy = y1 * 8 + WY;
				if (dy <= -8 || dy >= 144)
					continue;
				for (x1 = 0; x1 < 32; x1++)
				{
					dx = x1 * 8 + WX - 7;
					if (dx <= -8 || dx >= 160)
						continue;
					if (LCDC & 0x10) {
						ti2 = vram[ti + x1];
					} else {
						if (vram[ti + x1] < 128)
							ti2 = vram[ti + x1] + 256;
						else
							ti2 = vram[ti + x1];
					}
					//copyPixel(output, tile[ti2], dx, dy, false, false);
					output.copyPixels(tile[ti2], rect, new Point(dx, dy));
				}
			}
		}
		
		// スプライトの転送
		if (LCDC & 0x02) { // スプライト表示
			var y:int;
			var x:int;
			var p:uint;
			var rx:Boolean;
			var ry:Boolean;
			if (LCDC & 0x04) { // 8x16
				for (x1 = 0; x1 < 20; x1++)
				{
					y = oam[x1 * 8] - 16;
					x = oam[x1 * 8 + 1] - 8;
					p = oam[x1 * 8 + 2];
					rx = (oam[x1 * 8 + 3] & 0x20) ? true : false;
					ry = (oam[x1 * 8 + 3] & 0x40) ? true : false;
					
					if (x <= -8 || y <= -8 || x >= 160 || y >= 144)
						continue;
					copyPixel(output, tile[p], x, y, rx, ry);
					
					p = oam[x1 * 8 + 4 + 2];
					copyPixel(output, tile[p], x, y + 8, rx, ry);
					//output.copyPixels(tile[p], rect, new Point(x, y));
				}
			} else {
				for (x1 = 0; x1 < 40; x1++)
				{
					y = oam[x1 * 4] - 16;
					x = oam[x1 * 4 + 1] - 8;
					p = oam[x1 * 4 + 2];
					rx = (oam[x1 * 4 + 3] & 0x20) ? true : false;
					ry = (oam[x1 * 4 + 3] & 0x40) ? true : false;
					
					if (x <= -8 || y <= -8 || x >= 160 || y >= 144)
						continue;
					copyPixel(output, tile[p], x, y, rx, ry);
					//output.copyPixels(tile[p], rect, new Point(x, y));
				}
			}
		}
		
		output.unlock();
	}
	
	private function copyPixel(dest:BitmapData, source:BitmapData, dx:int, dy:int, rx:Boolean, ry:Boolean):void 
	{
		dest.lock();
		//source.lock();
		var y:int;
		var x:int;
		var color:uint;
		for (y = 0; y < 8; y++)
		{
			for (x = 0; x < 8; x++)
			{
				var drx:int = x;
				var dry:int = y;
				if (rx)
					drx = 7 - x;
				if (ry)
					dry = 7 - y;
				color = source.getPixel(x, y);
				if (color == 0xFFFFFF)
					continue;
				dest.setPixel(drx + dx, dry + dy, color);
			}				
		}
		//source.unlock();
		dest.unlock();
	}
	
	private function initRam():void 
	{
		ram = new Vector.<uint>();
		ram.length = 0x2000; // 8KB
		ram.fixed = true;
		vram = new Vector.<uint>();
		vram.length = 0x2000; // 8KB
		vram.fixed = true;
		stack = new Vector.<uint>();
		stack.length = 0x80;
		stack.fixed = true;
		oam = new Vector.<uint>();
		oam.length = 0xA0;
		oam.fixed = true;
		spare_oam = new Vector.<uint>();
		spare_oam.length = 0xA0;
		spare_oam.fixed = true;
	}
	
	private function initRom():void 
	{
	}
	
	public function loadRom(byteArray:ByteArray):void 
	{
		cart = new GbCart(byteArray);
		dataLoaded = true;
		//trace("Title : " + cart.title);
		//trace("Type : " + cart.type);
		//trace("typeCode : " + cart.typeCode);
	}
	
	public function get AF():uint
	{
		A = (A & 0xFF);
		F = (F & 0xFF);
		return (A << 8) | z802gb[F];			
	}
	
	public function set AF(arg:uint):void
	{
		A = ((arg >> 8) & 0xFF);
		F = gb2z80[arg & 0xFF];			
	}
	
	public function get BC():uint
	{
		B = (B & 0xFF);
		C = (C & 0xFF);
		return (B << 8) | C;			
	}
	
	public function set BC(arg:uint):void
	{
		B = ((arg >> 8) & 0xFF);
		C = (arg & 0xFF);			
	}
	
	public function get DE():uint
	{
		D = (D & 0xFF);
		E = (E & 0xFF);
		return (D << 8) | E;			
	}
	
	public function set DE(arg:uint):void
	{
		D = ((arg >> 8) & 0xFF);
		E = (arg & 0xFF);			
	}
	
	public function get HL():uint
	{
		H = (H & 0xFF);
		L = (L & 0xFF);
		return (H << 8) | L;			
	}
	
	public function set HL(arg:uint):void
	{
		H = ((arg >> 8) & 0xFF);
		L = (arg & 0xFF);			
	}
	
	public function read(adr:uint):uint 
	{
		//adr = (adr & 0xFFFF);
		switch (adr >> 13)
		{
		case 0:
		case 1:
			return cart.read(adr);//ROM領域
		case 2:
		case 3:
			return cart.readBank(adr);//バンク可能ROM
		case 4:
			return vram[adr & 0x1FFF];//8KBVRAM
		case 5:
			return cart.readSram(adr & 0x1FFF) & 0xFF;
			break;
		case 6:
				return ram[adr & 0x1fff];// & 0xFF;
		case 7:
			if (adr < 0xFE00){
					return ram[adr & 0x1fff];// & 0xFF; // ram_bank
			}
			else if (adr < 0xFEA0)
				return oam[adr - 0xFE00];// & 0xFF;//object attribute memory
			else if (adr < 0xFF00) {
				var index:uint;
				index = (adr - 0xFEA0) >> 5;
				index <<= 3;
				index |= (adr & 7);
				return spare_oam[index];// & 0xFF;
			}
			else if (adr < 0xFF80)
				return io_read(adr) & 0xFF;//I/O
			else if (adr < 0xFFFF)
				return stack[adr - 0xFF80];// & 0xFF;//stack
			else
				return IE;// & 0xFF;//I/O
		}
		return 0;
	}

	private function write(adr:uint, dat:uint):void
	{
		//adr = (adr & 0xFFFF);
		dat = (dat & 0xFF);
		
		switch ( adr >> 13 )
		{
		case 0: // ROMバンク 0
		case 1: // ROMバンク 0
		case 2: // ROMバンク 1
		case 3: // ROMバンク 1
			cart.write(adr, dat);
			break;
		case 4: // VRAM
			vram[adr & 0x1FFF] = dat;
			writeVram(adr & 0x1FFF, dat);
			break;
		case 5: // RAM バンク
			cart.writeSram(adr & 0x1FFF, dat);
			//if (ref_gb->get_mbc()->is_ext_ram())
			//	ref_gb->get_mbc()->get_sram()[adr&0x1FFF]=dat;//カートリッジRAM
			//else
			//	ref_gb->get_mbc()->ext_write(adr,dat);
			break;
		case 6: // 内部 RAM
			//if (adr&0x1000)
			//	ram_bank[adr&0x0fff]=dat;
			//else
				ram[adr & 0x1fff] = dat;
			break;
		case 7:
			if (adr < 0xFE00) {
			//	if (adr&0x1000)
			//		ram_bank[adr&0x0fff]=dat;
			//	else
					ram[adr & 0x1fff] = dat;
			}
			else if (adr < 0xFEA0)
				oam[adr - 0xFE00] = dat;
			else if (adr < 0xFF00) {
				var index:uint;
				index = (adr - 0xFEA0) >> 5;
				index <<= 3;
				index |= (adr & 7);
				spare_oam[index] = dat;
			} else if (adr < 0xFF80)
				io_write(adr,dat);//I/O
			else if (adr < 0xFFFF) {
				//if (adr == 0xFF8F)
				//	stopPC = PC;
				stack[adr - 0xFF80] = dat;//stack
			} else
				IE = dat;//I/O
			break;
		}
	}
	
	public function readw(adr:uint):uint
	{
		return read(adr) | (read(adr + 1) << 8);
	}
	
	public function writew(adr:uint, dat:uint):void
	{
		write(adr, dat);
		write(adr + 1, dat >> 8);
	}
	
	private function op_read():uint 
	{
		return read(PC++);
	}
	
	private function op_read_s():int 
	{
		var dat:uint = read(PC++);
		if (dat & 0x80)
			return (dat | 0xFFFFFF00);
		return dat;
	}
	
	private function op_readw():uint 
	{
		PC += 2; return readw(PC - 2);
	}
	
	public function irq(irq_type:uint):void 
	{
		if (!((irq_type == INT_VBLANK || irq_type == INT_LCDC) && (!(LCDC & 0x80))))
			IF |= irq_type;
	}
	
	public function irq_process():void
	{
		if (int_desable) {
			int_desable=false;
			return;
		}

		if ((IF & IE) && (I || halt)) {//割りこみがかかる時
			if (halt)
				PC++;
			write(SP - 2, PC & 0xFF);
			write(SP - 1, (PC >> 8));
			SP -= 2;
			
			if (IF & IE & INT_VBLANK) {//VBlank
				PC = 0x40;
				IF &= 0xFE;
				last_int = INT_VBLANK;
			}
			else if (IF & IE & INT_LCDC) {//LCDC
				PC = 0x48;
				IF &= 0xFD;
				last_int = INT_LCDC;
			}
			else if (IF & IE & INT_TIMER) {//Timer
				PC = 0x50;
				IF &= 0xFB;
				last_int = INT_TIMER;
			}
			else if (IF & IE & INT_SERIAL) {//Serial
				PC = 0x58;
				IF &= 0xF7;
				last_int = INT_SERIAL;
			}
			else if (IF & IE & INT_PAD) {//Pad
				PC = 0x60;
				IF &= 0xEF;
				last_int = INT_PAD;
			}
			else {}

			halt = false;
			I = 0;
		}
	}
	
	public function ex(clocks:uint):void 
	{
		var timer_clocks:Array = [1024, 16, 64, 256];
		var opcode:uint;
		var tmpb:uint = 0;
		var tmps:int = 0;
		
		rest_clock += clocks;
		
		if (dma_remain > 0) {
			rest_clock -= dma_remain;
			dma_remain = 0;
		}
		
		while (rest_clock > 0)
		{
			if (stopPC == PC)
				return;
			irq_process();
			opcode = read(PC++);
			tmp_clocks = cys[opcode];
			
// 0x00-0x0F
	switch (opcode) 
	{
case 0x00: break; // NOP
case 0x01: BC = op_readw(); break; //LD BC,(mn)
case 0x02: write(BC, A); break; // LD (BC),A : 00 000 010 :state 7
case 0x03: BC++; break; //INC BC
case 0x04: B = INC(B); break; //INC B
case 0x05: B = DEC(B); break; //DEC B
case 0x06: B = op_read(); break; // LD B,n
case 0x07: F = (A >> 7) & 0x01; A = ((A << 1) & 0xFE) | ((A >> 7) & 1); A &= 0xFF; break; //RLCA :state 4
case 0x08: writew(op_readw(), SP); break; //LD (mn),SP
case 0x09: ADDW(BC); break; //ADD HL,BC
case 0x0A: A = read(BC); break; // LD A,(BC) :00 001 010 :state 7
case 0x0B: BC--; break; //DEC BC
case 0x0C: C = INC(C); break; //INC C
case 0x0D: C = DEC(C); break; //DEC C
case 0x0E: C = op_read(); break; // LD C,n
case 0x0F: F = (A & 1); A = ((A >> 1) & 0x7F) | ((A << 7) & 0x80); A &= 0xFF; break; //RRCA :state 4
// 0x10-0x1F
case 0x10: halt=true;PC--;break; //STOP(HALT?)
case 0x11: DE = op_readw(); break; //LD DE,(mn)
case 0x12: write(DE, A); break; // LD (DE),A : 00 010 010 :state 7
case 0x13: DE++; break; //INC DE
case 0x14: D = INC(D); break; //INC D
case 0x15: D = DEC(D); break; //DEC D
case 0x16: D = op_read(); break; // LD D,n
case 0x17: tmpb = (A >> 7) & 0x01; A = ((A << 1) & 0xFE) | (F & CF); A &= 0xFF; F = tmpb; break; //RLA :state 4
case 0x18: {tmps=op_read_s();PC+=tmps;} break;//JR e : state 12
case 0x19: ADDW(DE); break; //ADD HL,DE
case 0x1A: A = read(DE); break; // LD A,(DE) :00 011 010 : state 7
case 0x1B: DE--; break; //DEC DE
case 0x1C: E = INC(E); break; //INC E
case 0x1D: E = DEC(E); break; //DEC E
case 0x1E: E = op_read(); break; // LD E,n
case 0x1F: tmpb = A & 1; A = ((A >> 1) & 0x7F) | ((F << 7) & 0x80); A &= 0xFF; F = tmpb; break; //RRA :state 4
// 0x20-0x2F
case 0x20: if (F & ZF) PC += 1; else {tmps=op_read_s();PC+=tmps; tmp_clocks = 12; } break;// JRNZ
case 0x21: HL = op_readw(); break; //LD HL,(mn)
case 0x22: write(HL, A); HL++; break; // LD (HLI),A : 00 110 010 :state 13
case 0x23: HL++; break; //INC HL
case 0x24: H = INC(H); break; //INC H
case 0x25: H = DEC(H); break; //DEC H
case 0x26: H = op_read(); break; // LD H,n
case 0x27://DAA :state 4
{
  var tmp:uint = (A & 0x0F);
  tmp = (F & NF)?
  (
    (F & CF)?
      (((F & HF)? 0x9A00:0xA000) + CF):
      ((F & HF)? 0xFA00:0x0000)
  )
  :
  (
    (F & CF)?
      (((F & HF)? 0x6600:((tmp < 0x0A)? 0x6000:0x6600)) + CF):
      (
        (F & HF)?
          ((A < 0xA0)? 0x0600:(0x6600 + CF)):
          (
            (tmp < 0x0A)? 
              ((A < 0xA0)? 0x0000:(0x6000 + CF)): 
	      ((A < 0x90)? 0x0600:(0x6600 + CF))
          )
      )
  );
  A += (tmp >> 8);
  A = (A & 0xFF);
  F = ZTable[A] | ((tmp & 0xFF) | (F & NF));
}
break;
case 0x28: if (F & ZF) {tmps=op_read_s();PC+=tmps; tmp_clocks = 12;} else PC += 1; break;// JRZ
case 0x29: ADDW(HL); break; //ADD HL,HL
case 0x2A: A = read(HL); HL++; break; // LD A,(HLI) : 00 111 010 :state 13
case 0x2B: HL--; break; //DEC HL
case 0x2C: L = INC(L); break; //INC L
case 0x2D: L = DEC(L); break; //DEC L
case 0x2E: L = op_read(); break; // LD L,n
case 0x2F: //CPL(1の補数) :state4
	A = ~A;
	A &= 0xFF;
	F |= (NF | HF);
	break;
// 0x30-0x3F
case 0x30: if (F & CF) PC += 1; else {tmps=op_read_s();PC+=tmps;tmp_clocks = 12;} break;// JRNC
case 0x31: SP = op_readw(); break; //LD SP,(mn)
case 0x32: write(HL, A); HL--; break; // LD (HLD),A : 00 110 010 :state 13
case 0x33: SP++; break; //INC SP
case 0x34: tmpb = read(HL); tmpb = INC(tmpb); write(HL, tmpb); break; //INC (HL) : 00 110 100 : state 11
case 0x35: tmpb = read(HL); tmpb = DEC(tmpb); write(HL, tmpb); break; //DEC (HL) : 00 110 101 : state 11
case 0x36: write(HL, op_read()); break; // LD (HL),n :00 110 110 :state 10
case 0x37: //SCF(set carry) :state 4
	F = (F & ~(NF | HF)) | CF;
	break;
case 0x38: if (F & CF) {tmps=op_read_s();PC+=tmps; tmp_clocks = 12;} else PC += 1; break;// JRC
case 0x39: ADDW(SP); break; //ADD HL,SP
case 0x3A: A = read(HL); HL--; break; // LD A,(HLD) : 00 111 010 :state 13
case 0x3B: SP--; break; //DEC SP
case 0x3C: A = INC(A); break; //INC A
case 0x3D: A = DEC(A); break; //DEC A
case 0x3E: A = op_read(); break; // LD A,n
case 0x3F: //CCF(not carry) :state 4
	F ^= 0x01;
	F = F & ~(NF | HF);
	break;
// 0x40-0x4F
case 0x40: break; // LD B,B
case 0x41: B = C; break; // LD B,C
case 0x42: B = D; break; // LD B,D
case 0x43: B = E; break; // LD B,E
case 0x44: B = H; break; // LD B,H
case 0x45: B = L; break; // LD B,L
case 0x46: B = read(HL); break; // LD B,(HL)
case 0x66: H = read(HL); break; // LD H,(HL)
case 0x47: B = A; break; // LD B,A
case 0x48: C = B; break; // LD C,B
case 0x49: break; // LD C,C
case 0x4A: C = D; break; // LD C,D
case 0x4B: C = E; break; // LD C,E
case 0x4C: C = H; break; // LD C,H
case 0x4D: C = L; break; // LD C,L
case 0x4E: C = read(HL); break; // LD C,(HL)
case 0x4F: C = A; break; // LD C,A
// 0x50-0x5F
case 0x50: D = B;break; // LD D,B
case 0x51: D = C;break; // LD D,C
case 0x52: break; // LD D,D
case 0x53: D = E; break; // LD D,E
case 0x54: D = H; break; // LD D,H
case 0x55: D = L; break; // LD D,L
case 0x56: D = read(HL); break; // LD D,(HL)
case 0x57: D = A; break; // LD D,A
case 0x58: E = B;break; // LD E,B
case 0x59: E = C;break; // LD E,C
case 0x5A: E = D;break; // LD E,D
case 0x5B: break; // LD E,E
case 0x5C: E = H;break; // LD E,H
case 0x5D: E = L;break; // LD E,L
case 0x5E: E = read(HL); break; // LD E,(HL)
case 0x5F: E = A;break; // LD E,A
// 0x60-0x6F
case 0x60: H = B; break; // LD H,B
case 0x61: H = C; break; // LD H,C
case 0x62: H = D; break; // LD H,D
case 0x63: H = E; break; // LD H,E
case 0x64: break; // LD H,H
case 0x65: H = L; break; // LD H,L
case 0x67: H = A; break; // LD H,A
case 0x68: L = B; break; // LD L,B
case 0x69: L = C; break; // LD L,C
case 0x6A: L = D; break; // LD L,D
case 0x6B: L = E; break; // LD L,E
case 0x6C: L = H; break; // LD L,H
case 0x6D: break; // LD L,L
case 0x6E: L = read(HL); break; // LD L,(HL)
case 0x6F: L = A; break; // LD L,A
// 0x70-0x7F
case 0x70: write(HL, B); break; // LD (HL),B
case 0x71: write(HL, C); break; // LD (HL),C
case 0x72: write(HL, D); break; // LD (HL),D
case 0x73: write(HL, E); break; // LD (HL),E
case 0x74: write(HL, H); break; // LD (HL),H
case 0x75: write(HL, L); break; // LD (HL),L
case 0x76:
	if (TAC & 0x04) {//タイマ割りこみ
		//var tmp:uint;
		tmpb = TIMA + (sys_clock + rest_clock) / timer_clocks[TAC & 0x03];

		if (tmpb & 0xFF00) {//HALT中に割りこみがかかる場合
			//total_clock += (256 - TIMA) * timer_clocks[TAC & 0x03] - sys_clock;
			rest_clock -= (256 - TIMA) * timer_clocks[TAC & 0x03] - sys_clock;
			TIMA = TMA;
			halt = true;
			PC--;
			irq(INT_TIMER);
			sys_clock = (sys_clock + rest_clock) & (timer_clocks[TAC & 0x03] - 1);
		}
		else{
			TIMA = tmpb & 0xFF;
			sys_clock = (sys_clock + rest_clock) & (timer_clocks[TAC & 0x03] - 1);
			halt = true;
			//total_clock += rest_clock;
			rest_clock = 0;
			PC--;
		}
	}
	else{
		halt = true;
		//total_clock += rest_clock;
		div_clock += rest_clock;
		rest_clock = 0;
		PC--;
	}
	tmp_clocks = 0;
	break; //HALT : state 4
case 0x77: write(HL, A); break; // LD (HL),A
case 0x78: A = B; break; // LD A,B
case 0x79: A = C; break; // LD A,C
case 0x7A: A = D; break; // LD A,D
case 0x7B: A = E; break; // LD A,E
case 0x7C: A = H; break; // LD A,H
case 0x7D: A = L; break; // LD A,L
case 0x7E: A = read(HL); break; // LD A,(HL)
case 0x7F: break; // LD A,A
// 0x80-0x8F
case 0x80: ADD(B); break; //ADD A,B
case 0x81: ADD(C); break; //ADD A,C
case 0x82: ADD(D); break; //ADD A,D
case 0x83: ADD(E); break; //ADD A,E
case 0x84: ADD(H); break; //ADD A,H
case 0x85: ADD(L); break; //ADD A,L
case 0x86: tmpb = read(HL); ADD(tmpb); break; //ADD A,(HL) : 10 000 110 :state 7
case 0x87: ADD(A); break; //ADD A,A
case 0x88: ADC(B); break; //ADC A,B
case 0x89: ADC(C); break; //ADC A,C
case 0x8A: ADC(D); break; //ADC A,D
case 0x8B: ADC(E); break; //ADC A,E
case 0x8C: ADC(H); break; //ADC A,H
case 0x8D: ADC(L); break; //ADC A,L
case 0x8E: tmpb = read(HL); ADC(tmpb); break; //ADC A,(HL) : 10 001 110 :state 7
case 0x8F: ADC(A); break; //ADC A,A
// 0x90-0x9F
case 0x90: SUB(B); break; //SUB A,B
case 0x91: SUB(C); break; //SUB A,C
case 0x92: SUB(D); break; //SUB A,D
case 0x93: SUB(E); break; //SUB A,E
case 0x94: SUB(H); break; //SUB A,H
case 0x95: SUB(L); break; //SUB A,L
case 0x96: tmpb = read(HL); SUB(tmpb); break; //SUB A,(HL) : 10 010 110 :state 7
case 0x97: SUB(A); break; //SUB A,A
case 0x98: SBC(B); break; //SBC A,B
case 0x99: SBC(C); break; //SBC A,C
case 0x9A: SBC(D); break; //SBC A,D
case 0x9B: SBC(E); break; //SBC A,E
case 0x9C: SBC(H); break; //SBC A,H
case 0x9D: SBC(L); break; //SBC A,L
case 0x9E: tmpb = read(HL); SBC(tmpb); break; //SBC A,(HL) : 10 011 110 :state 7
case 0x9F: SBC(A); break; //SBC A,A
// 0xA0-0xAF
case 0xA0: AND(B); break; //AND A,B
case 0xA1: AND(C); break; //AND A,C
case 0xA2: AND(D); break; //AND A,D
case 0xA3: AND(E); break; //AND A,E
case 0xA4: AND(H); break; //AND A,H
case 0xA5: AND(L); break; //AND A,L
case 0xA6: tmpb = read(HL); AND(tmpb); break; //AND A,(HL) : 10 100 110 :state 7
case 0xA7: AND(A); break; //AND A,A
case 0xA8: XOR(B); break; //XOR A,B
case 0xA9: XOR(C); break; //XOR A,C
case 0xAA: XOR(D); break; //XOR A,D
case 0xAB: XOR(E); break; //XOR A,E
case 0xAC: XOR(H); break; //XOR A,H
case 0xAD: XOR(L); break; //XOR A,L
case 0xAE: tmpb = read(HL); XOR(tmpb); break; //XOR A,(HL) : 10 101 110 :state 7
case 0xAF: XOR(A); break; //XOR A,A
// 0xB0-0xBF
case 0xB0: OR(B); break; //OR A,B
case 0xB1: OR(C); break; //OR A,C
case 0xB2: OR(D); break; //OR A,D
case 0xB3: OR(E); break; //OR A,E
case 0xB4: OR(H); break; //OR A,H
case 0xB5: OR(L); break; //OR A,L
case 0xB6: tmpb = read(HL); OR(tmpb); break; //OR A,(HL) : 10 110 110 :state 7
case 0xB7: OR(A); break; //OR A,A
case 0xB8: CP(B); break; //CP A,B
case 0xB9: CP(C); break; //CP A,C
case 0xBA: CP(D); break; //CP A,D
case 0xBB: CP(E); break; //CP A,E
case 0xBC: CP(H); break; //CP A,H
case 0xBD: CP(L); break; //CP A,L
case 0xBE: tmpb = read(HL); CP(tmpb); break; //CP A,(HL) : 10 111 110 :state 7
case 0xBF: CP(A); break; //CP A,A
// 0xC0-0xCF
case 0xC0: if (!(F & ZF)) {PC = readw(SP); SP += 2; tmp_clocks = 20;} break; //RETNZ
case 0xC1: B = read(SP + 1); C = read(SP); SP += 2; break; //POP BC
case 0xC2: if (F & ZF) PC += 2; else { PC = op_readw(); tmp_clocks=16; }; break; // JPNZ mn
case 0xC3: PC = op_readw(); break;//JP mn : state 10 (16?)
case 0xC4: if (F & ZF) PC += 2; else {SP -= 2; writew(SP, PC + 2); PC = op_readw(); tmp_clocks = 24;} break; //CALLNZ mn
case 0xC5: SP -= 2; writew(SP, BC); break; //PUSH BC
case 0xC6: tmpb = op_read(); ADD(tmpb); break; //ADD A,n : 11 000 110 :state 7
case 0xC7: SP -= 2; writew(SP, PC); PC = 0x00;break; //RST 0x00
case 0xC8: if (F & ZF) {PC = readw(SP);SP += 2; tmp_clocks = 20;} break; //RETZ
case 0xC9: PC = readw(SP); SP += 2; break; //RET state 16
case 0xCA: if (F & ZF) { PC = op_readw(); tmp_clocks=16; } else PC += 2; break; // JPZ mn
case 0xCB:
	exec_0xCB();
	break;
case 0xCC: if (F & ZF) {SP -= 2; writew(SP, PC + 2); PC = op_readw(); tmp_clocks = 24;} else PC += 2; break; //CALLZ mn
case 0xCD: SP -= 2; writew(SP, PC + 2); PC = op_readw(); break; //CALL mn :state 24
case 0xCE: tmpb = op_read(); ADC(tmpb); break; //ADC A,n : 11 001 110 :state 7
case 0xCF: SP -= 2; writew(SP, PC); PC = 0x08;break; //RST 0x08
// 0xD0-0xDF
case 0xD0: if (!(F & CF)) {PC = readw(SP); SP += 2; tmp_clocks = 20;} break; //RETNC
case 0xD1: D = read(SP + 1); E = read(SP); SP += 2; break; //POP DE
case 0xD2: if (F & CF) PC += 2; else { PC = op_readw(); tmp_clocks=16; }; break; // JPNC mn
case 0xD4: if (F & CF) PC += 2; else {SP -= 2; writew(SP, PC + 2); PC = op_readw(); tmp_clocks = 24;} break; //CALLNC mn
case 0xD5: SP -= 2; writew(SP, DE); break; //PUSH DE
case 0xD6: tmpb = op_read(); SUB(tmpb); break; //SUB A,n : 11 010 110 :state 7
case 0xD7: SP -= 2; writew(SP, PC); PC = 0x10;break; //RST 0x10
case 0xD8: if (F & CF) {PC = readw(SP); SP += 2; tmp_clocks = 20;} break; //RETC
case 0xD9: I = 1; PC = readw(SP); SP += 2; int_desable = true; break;//RETI state 16
case 0xDA: if (F & CF) { PC = op_readw(); tmp_clocks=16; } else PC += 2; break; // JPC mn
case 0xDC: if (F & CF) {SP -= 2; writew(SP, PC + 2); PC = op_readw(); tmp_clocks = 24;} else PC += 2; break; //CALLC mn
case 0xDE: tmpb = op_read(); SBC(tmpb); break; //SBC A,n : 11 011 110 :state 7
case 0xDF: SP -= 2; writew(SP, PC); PC = 0x18;break; //RST 0x18
// 0xE0-0xEF
case 0xE0: write(0xFF00 + op_read(), A); break;//LDH (n),A
case 0xE1: H = read(SP + 1); L = read(SP); SP += 2; break; //POP HL
case 0xE2: write(0xFF00 + C, A); break;//LDH (C),A
case 0xE5: SP -= 2; writew(SP, HL); break; //PUSH HL
case 0xE6: tmpb = op_read(); AND(tmpb); break; //AND A,n : 11 100 110 :state 7
case 0xE7: SP -= 2; writew(SP, PC); PC = 0x20;break; //RST 0x20
case 0xE8: SP += op_read_s(); break;//ADD SP,n
case 0xE9: PC = HL; break; //JP HL : state 4 
case 0xEA: write(op_readw(), A); break;//LD (mn),A
case 0xEE: tmpb = op_read(); XOR(tmpb); break; //XOR A,n : 11 101 110 :state 7
case 0xEF: SP -= 2; writew(SP, PC); PC = 0x28;break; //RST 0x28
// 0xF0-0xFF
case 0xF0: A = read(0xFF00 + op_read()); break;//LDH A,(n)
case 0xF1: A = read(SP + 1); F = gb2z80[read(SP) & 0xF0]; SP += 2; break; //POP AF
case 0xF2: A = read(0xFF00 + C); break;//LDH A,(c)
case 0xF3: I = 0; break; //DI : state 4
case 0xF5: write(SP - 2, z802gb[F] | 0xE); write(SP - 1, A); SP -= 2; break; //PUSH AF
case 0xF6: tmpb = op_read(); OR(tmpb); break; //OR A,n : 11 110 110 :state 7
case 0xF7: SP -= 2; writew(SP, PC); PC = 0x30;break; //RST 0x30
case 0xF8: HL = SP + op_read_s(); break;//LD HL,SP+n 
case 0xF9: SP = HL; break; //LD SP,HL : 11 111 001 :state 6
case 0xFA: A = read(op_readw()); break;//LD A,(mn);
case 0xFB: I = 1; int_desable = true; break; //EI : state 4
case 0xFE: tmpb = op_read(); CP(tmpb); break; //CP A,n : 11 111 110 :state 7
case 0xFF: SP -= 2; writew(SP, PC); PC = 0x38;break; //RST 0x38
}

			
			rest_clock -= tmp_clocks;
			div_clock += tmp_clocks;
			total_clock += tmp_clocks;
			
			if (TAC & 0x04) { //タイマ割りこみ
				sys_clock += tmp_clocks;
				if (sys_clock > timer_clocks[TAC & 0x03]) {
					sys_clock &= timer_clocks[TAC & 0x03] - 1;
					TIMA++;
					if (!TIMA) {
						irq(INT_TIMER);
						TIMA= TMA;
					}
				}
			}
			if (div_clock >= 0x100) {
				DIV -= div_clock >> 8;
				div_clock &= 0xff;
			}
		}
	}
	
	public function exec():void 
	{

for (var line:uint = 0; line < 154; line++) {
	if (LCDC & 0x80) { // LCDC 起動時
		LY = (LY + 1) % 154;

		STAT &= 0xF8;
		if (LYC == LY) {
			STAT |= 4;
			if (STAT & 0x40)
				irq(INT_LCDC);
		}
		if (LY == 0) {
			return;
		}
		if (LY >= 144) { // VBlank 期間中
			STAT |= 1;
			if (LY == 144) {
				ex(72);
				irq(INT_VBLANK);
				if (STAT & 0x10)
					irq(INT_LCDC);
				ex(456 - 80);
			}
			else if (LY == 153) {
				ex(80);
				LY = 0;
				ex(456 - 80);
				LY = 153;
			}
			else
				ex(456);
		}
		else{ // VBlank 期間外
			STAT |= 2;
			if (STAT & 0x20)
				irq(INT_LCDC);
			ex(80); // state=2
			STAT |= 3;
			ex(169); // state=3
			STAT &= 0xfc;
			if (STAT & 0x08)
				irq(INT_LCDC);
			ex(207); // state=0
		}
	}
	else{ // LCDC 停止時
		LY = 0;
		STAT &= 0xF8;
		ex(456);
	}
}
	}

	private function exec_0xCB():void 
	{
		var opcode:uint;
		var tmpb:uint = 0;
		
		opcode = read(PC++);
		tmp_clocks = cys_cb[opcode];
		switch (opcode)
{
case 0x40: F=((F&CF)|HF)|(((B<<6)&0x40)^0x40);break; //BIT 0,B
case 0x41: F=((F&CF)|HF)|(((C<<6)&0x40)^0x40);break; //BIT 0,C
case 0x42: F=((F&CF)|HF)|(((D<<6)&0x40)^0x40);break; //BIT 0,D
case 0x43: F=((F&CF)|HF)|(((E<<6)&0x40)^0x40);break; //BIT 0,E
case 0x44: F=((F&CF)|HF)|(((H<<6)&0x40)^0x40);break; //BIT 0,H
case 0x45: F=((F&CF)|HF)|(((L<<6)&0x40)^0x40);break; //BIT 0,L
case 0x47: F=((F&CF)|HF)|(((A<<6)&0x40)^0x40);break; //BIT 0,A

case 0x48: F=((F&CF)|HF)|(((B<<5)&0x40)^0x40);break; //BIT 1,B
case 0x49: F=((F&CF)|HF)|(((C<<5)&0x40)^0x40);break; //BIT 1,C
case 0x4A: F=((F&CF)|HF)|(((D<<5)&0x40)^0x40);break; //BIT 1,D
case 0x4B: F=((F&CF)|HF)|(((E<<5)&0x40)^0x40);break; //BIT 1,E
case 0x4C: F=((F&CF)|HF)|(((H<<5)&0x40)^0x40);break; //BIT 1,H
case 0x4D: F=((F&CF)|HF)|(((L<<5)&0x40)^0x40);break; //BIT 1,L
case 0x4F: F=((F&CF)|HF)|(((A<<5)&0x40)^0x40);break; //BIT 1,A

case 0x50: F=((F&CF)|HF)|(((B<<4)&0x40)^0x40);break; //BIT 2,B
case 0x51: F=((F&CF)|HF)|(((C<<4)&0x40)^0x40);break; //BIT 2,C
case 0x52: F=((F&CF)|HF)|(((D<<4)&0x40)^0x40);break; //BIT 2,D
case 0x53: F=((F&CF)|HF)|(((E<<4)&0x40)^0x40);break; //BIT 2,E
case 0x54: F=((F&CF)|HF)|(((H<<4)&0x40)^0x40);break; //BIT 2,H
case 0x55: F=((F&CF)|HF)|(((L<<4)&0x40)^0x40);break; //BIT 2,L
case 0x57: F=((F&CF)|HF)|(((A<<4)&0x40)^0x40);break; //BIT 2,A

case 0x58: F=((F&CF)|HF)|(((B<<3)&0x40)^0x40);break; //BIT 3,B
case 0x59: F=((F&CF)|HF)|(((C<<3)&0x40)^0x40);break; //BIT 3,C
case 0x5A: F=((F&CF)|HF)|(((D<<3)&0x40)^0x40);break; //BIT 3,D
case 0x5B: F=((F&CF)|HF)|(((E<<3)&0x40)^0x40);break; //BIT 3,E
case 0x5C: F=((F&CF)|HF)|(((H<<3)&0x40)^0x40);break; //BIT 3,H
case 0x5D: F=((F&CF)|HF)|(((L<<3)&0x40)^0x40);break; //BIT 3,L
case 0x5F: F=((F&CF)|HF)|(((A<<3)&0x40)^0x40);break; //BIT 3,A

case 0x60: F=((F&CF)|HF)|(((B<<2)&0x40)^0x40);break; //BIT 4,B
case 0x61: F=((F&CF)|HF)|(((C<<2)&0x40)^0x40);break; //BIT 4,C
case 0x62: F=((F&CF)|HF)|(((D<<2)&0x40)^0x40);break; //BIT 4,D
case 0x63: F=((F&CF)|HF)|(((E<<2)&0x40)^0x40);break; //BIT 4,E
case 0x64: F=((F&CF)|HF)|(((H<<2)&0x40)^0x40);break; //BIT 4,H
case 0x65: F=((F&CF)|HF)|(((L<<2)&0x40)^0x40);break; //BIT 4,L
case 0x67: F=((F&CF)|HF)|(((A<<2)&0x40)^0x40);break; //BIT 4,A

case 0x68: F=((F&CF)|HF)|(((B<<1)&0x40)^0x40);break; //BIT 5,B
case 0x69: F=((F&CF)|HF)|(((C<<1)&0x40)^0x40);break; //BIT 5,C
case 0x6A: F=((F&CF)|HF)|(((D<<1)&0x40)^0x40);break; //BIT 5,D
case 0x6B: F=((F&CF)|HF)|(((E<<1)&0x40)^0x40);break; //BIT 5,E
case 0x6C: F=((F&CF)|HF)|(((H<<1)&0x40)^0x40);break; //BIT 5,H
case 0x6D: F=((F&CF)|HF)|(((L<<1)&0x40)^0x40);break; //BIT 5,L
case 0x6F: F=((F&CF)|HF)|(((A<<1)&0x40)^0x40);break; //BIT 5,A

case 0x70: F=((F&CF)|HF)|(((B)&0x40)^0x40);break; //BIT 6,B
case 0x71: F=((F&CF)|HF)|(((C)&0x40)^0x40);break; //BIT 6,C
case 0x72: F=((F&CF)|HF)|(((D)&0x40)^0x40);break; //BIT 6,D
case 0x73: F=((F&CF)|HF)|(((E)&0x40)^0x40);break; //BIT 6,E
case 0x74: F=((F&CF)|HF)|(((H)&0x40)^0x40);break; //BIT 6,H
case 0x75: F=((F&CF)|HF)|(((L)&0x40)^0x40);break; //BIT 6,L
case 0x77: F=((F&CF)|HF)|(((A)&0x40)^0x40);break; //BIT 6,A

case 0x78: F=((F&CF)|HF)|(((B>>1)&0x40)^0x40);break; //BIT 7,B
case 0x79: F=((F&CF)|HF)|(((C>>1)&0x40)^0x40);break; //BIT 7,C
case 0x7A: F=((F&CF)|HF)|(((D>>1)&0x40)^0x40);break; //BIT 7,D
case 0x7B: F=((F&CF)|HF)|(((E>>1)&0x40)^0x40);break; //BIT 7,E
case 0x7C: F=((F&CF)|HF)|(((H>>1)&0x40)^0x40);break; //BIT 7,H
case 0x7D: F=((F&CF)|HF)|(((L>>1)&0x40)^0x40);break; //BIT 7,L
case 0x7F: F=((F&CF)|HF)|(((A>>1)&0x40)^0x40);break; //BIT 7,A

//state 12
case 0x46: tmpb=read(HL);F=((F&CF)|HF)|(((tmpb<<6)&0x40)^0x40);break; //BIT 0,(HL)
case 0x4E: tmpb=read(HL);F=((F&CF)|HF)|(((tmpb<<5)&0x40)^0x40);break; //BIT 1,(HL)
case 0x56: tmpb=read(HL);F=((F&CF)|HF)|(((tmpb<<4)&0x40)^0x40);break; //BIT 2,(HL)
case 0x5E: tmpb=read(HL);F=((F&CF)|HF)|(((tmpb<<3)&0x40)^0x40);break; //BIT 3,(HL)
case 0x66: tmpb=read(HL);F=((F&CF)|HF)|(((tmpb<<2)&0x40)^0x40);break; //BIT 4,(HL)
case 0x6E: tmpb=read(HL);F=((F&CF)|HF)|(((tmpb<<1)&0x40)^0x40);break; //BIT 5,(HL)
case 0x76: tmpb=read(HL);F=((F&CF)|HF)|(((tmpb)&0x40)^0x40);break; //BIT 6,(HL)
case 0x7E: tmpb=read(HL);F=((F&CF)|HF)|(((tmpb>>1)&0x40)^0x40);break; //BIT 7,(HL)

//bit set opcode
//SET b,r :11 b r : state 8

case 0xC0: B|=0x01;break; //SET 0,B
case 0xC1: C|=0x01;break; //SET 0,C
case 0xC2: D|=0x01;break; //SET 0,D
case 0xC3: E|=0x01;break; //SET 0,E
case 0xC4: H|=0x01;break; //SET 0,H
case 0xC5: L|=0x01;break; //SET 0,L
case 0xC7: A|=0x01;break; //SET 0,A

case 0xC8: B|=0x02;break; //SET 1,B
case 0xC9: C|=0x02;break; //SET 1,C
case 0xCA: D|=0x02;break; //SET 1,D
case 0xCB: E|=0x02;break; //SET 1,E
case 0xCC: H|=0x02;break; //SET 1,H
case 0xCD: L|=0x02;break; //SET 1,L
case 0xCF: A|=0x02;break; //SET 1,A

case 0xD0: B|=0x04;break; //SET 2,B
case 0xD1: C|=0x04;break; //SET 2,C
case 0xD2: D|=0x04;break; //SET 2,D
case 0xD3: E|=0x04;break; //SET 2,E
case 0xD4: H|=0x04;break; //SET 2,H
case 0xD5: L|=0x04;break; //SET 2,L
case 0xD7: A|=0x04;break; //SET 2,A

case 0xD8: B|=0x08;break; //SET 3,B
case 0xD9: C|=0x08;break; //SET 3,C
case 0xDA: D|=0x08;break; //SET 3,D
case 0xDB: E|=0x08;break; //SET 3,E
case 0xDC: H|=0x08;break; //SET 3,H
case 0xDD: L|=0x08;break; //SET 3,L
case 0xDF: A|=0x08;break; //SET 3,A

case 0xE0: B|=0x10;break; //SET 4,B
case 0xE1: C|=0x10;break; //SET 4,C
case 0xE2: D|=0x10;break; //SET 4,D
case 0xE3: E|=0x10;break; //SET 4,E
case 0xE4: H|=0x10;break; //SET 4,H
case 0xE5: L|=0x10;break; //SET 4,L
case 0xE7: A|=0x10;break; //SET 4,A

case 0xE8: B|=0x20;break; //SET 5,B
case 0xE9: C|=0x20;break; //SET 5,C
case 0xEA: D|=0x20;break; //SET 5,D
case 0xEB: E|=0x20;break; //SET 5,E
case 0xEC: H|=0x20;break; //SET 5,H
case 0xED: L|=0x20;break; //SET 5,L
case 0xEF: A|=0x20;break; //SET 5,A

case 0xF0: B|=0x40;break; //SET 6,B
case 0xF1: C|=0x40;break; //SET 6,C
case 0xF2: D|=0x40;break; //SET 6,D
case 0xF3: E|=0x40;break; //SET 6,E
case 0xF4: H|=0x40;break; //SET 6,H
case 0xF5: L|=0x40;break; //SET 6,L
case 0xF7: A|=0x40;break; //SET 6,A

case 0xF8: B|=0x80;break; //SET 7,B
case 0xF9: C|=0x80;break; //SET 7,C
case 0xFA: D|=0x80;break; //SET 7,D
case 0xFB: E|=0x80;break; //SET 7,E
case 0xFC: H|=0x80;break; //SET 7,H
case 0xFD: L|=0x80;break; //SET 7,L
case 0xFF: A|=0x80;break; //SET 7,A

//state 16
case 0xC6: tmpb=read(HL);tmpb|=0x01;write(HL,tmpb);break; //SET 0,(HL)
case 0xCE: tmpb=read(HL);tmpb|=0x02;write(HL,tmpb);break; //SET 1,(HL)
case 0xD6: tmpb=read(HL);tmpb|=0x04;write(HL,tmpb);break; //SET 2,(HL)
case 0xDE: tmpb=read(HL);tmpb|=0x08;write(HL,tmpb);break; //SET 3,(HL)
case 0xE6: tmpb=read(HL);tmpb|=0x10;write(HL,tmpb);break; //SET 4,(HL)
case 0xEE: tmpb=read(HL);tmpb|=0x20;write(HL,tmpb);break; //SET 5,(HL)
case 0xF6: tmpb=read(HL);tmpb|=0x40;write(HL,tmpb);break; //SET 6,(HL)
case 0xFE: tmpb=read(HL);tmpb|=0x80;write(HL,tmpb);break; //SET 7,(HL)

//bit reset opcode
//RES b,r : 10 b r : state 8
case 0x80: B&=0xFE;break; //RES 0,B
case 0x81: C&=0xFE;break; //RES 0,C
case 0x82: D&=0xFE;break; //RES 0,D
case 0x83: E&=0xFE;break; //RES 0,E
case 0x84: H&=0xFE;break; //RES 0,H
case 0x85: L&=0xFE;break; //RES 0,L
case 0x87: A&=0xFE;break; //RES 0,A

case 0x88: B&=0xFD;break; //RES 1,B
case 0x89: C&=0xFD;break; //RES 1,C
case 0x8A: D&=0xFD;break; //RES 1,D
case 0x8B: E&=0xFD;break; //RES 1,E
case 0x8C: H&=0xFD;break; //RES 1,H
case 0x8D: L&=0xFD;break; //RES 1,L
case 0x8F: A&=0xFD;break; //RES 1,A

case 0x90: B&=0xFB;break; //RES 2,B
case 0x91: C&=0xFB;break; //RES 2,C
case 0x92: D&=0xFB;break; //RES 2,D
case 0x93: E&=0xFB;break; //RES 2,E
case 0x94: H&=0xFB;break; //RES 2,H
case 0x95: L&=0xFB;break; //RES 2,L
case 0x97: A&=0xFB;break; //RES 2,A

case 0x98: B&=0xF7;break; //RES 3,B
case 0x99: C&=0xF7;break; //RES 3,C
case 0x9A: D&=0xF7;break; //RES 3,D
case 0x9B: E&=0xF7;break; //RES 3,E
case 0x9C: H&=0xF7;break; //RES 3,H
case 0x9D: L&=0xF7;break; //RES 3,L
case 0x9F: A&=0xF7;break; //RES 3,A

case 0xA0: B&=0xEF;break; //RES 4,B
case 0xA1: C&=0xEF;break; //RES 4,C
case 0xA2: D&=0xEF;break; //RES 4,D
case 0xA3: E&=0xEF;break; //RES 4,E
case 0xA4: H&=0xEF;break; //RES 4,H
case 0xA5: L&=0xEF;break; //RES 4,L
case 0xA7: A&=0xEF;break; //RES 4,A

case 0xA8: B&=0xDF;break; //RES 5,B
case 0xA9: C&=0xDF;break; //RES 5,C
case 0xAA: D&=0xDF;break; //RES 5,D
case 0xAB: E&=0xDF;break; //RES 5,E
case 0xAC: H&=0xDF;break; //RES 5,H
case 0xAD: L&=0xDF;break; //RES 5,L
case 0xAF: A&=0xDF;break; //RES 5,A

case 0xB0: B&=0xBF;break; //RES 6,B
case 0xB1: C&=0xBF;break; //RES 6,C
case 0xB2: D&=0xBF;break; //RES 6,D
case 0xB3: E&=0xBF;break; //RES 6,E
case 0xB4: H&=0xBF;break; //RES 6,H
case 0xB5: L&=0xBF;break; //RES 6,L
case 0xB7: A&=0xBF;break; //RES 6,A

case 0xB8: B&=0x7F;break; //RES 7,B
case 0xB9: C&=0x7F;break; //RES 7,C
case 0xBA: D&=0x7F;break; //RES 7,D
case 0xBB: E&=0x7F;break; //RES 7,E
case 0xBC: H&=0x7F;break; //RES 7,H
case 0xBD: L&=0x7F;break; //RES 7,L
case 0xBF: A&=0x7F;break; //RES 7,A

//state 16
case 0x86: tmpb=read(HL);tmpb&=0xFE;write(HL,tmpb);break; //RES 0,(HL)
case 0x8E: tmpb=read(HL);tmpb&=0xFD;write(HL,tmpb);break; //RES 1,(HL)
case 0x96: tmpb=read(HL);tmpb&=0xFB;write(HL,tmpb);break; //RES 2,(HL)
case 0x9E: tmpb=read(HL);tmpb&=0xF7;write(HL,tmpb);break; //RES 3,(HL)
case 0xA6: tmpb=read(HL);tmpb&=0xEF;write(HL,tmpb);break; //RES 4,(HL)
case 0xAE: tmpb=read(HL);tmpb&=0xDF;write(HL,tmpb);break; //RES 5,(HL)
case 0xB6: tmpb=read(HL);tmpb&=0xBF;write(HL,tmpb);break; //RES 6,(HL)
case 0xBE: tmpb=read(HL);tmpb&=0x7F;write(HL,tmpb);break; //RES 7,(HL)

//shift rotate opcode
//RLC s : 00 000 r : state 8
case 0x00: F = (B >> 7); B = (B << 1) | (F); B &= 0xFF; F |= ZTable[B]; break;//RLC B
case 0x01: F = (C >> 7); C = (C << 1) | (F); C &= 0xFF; F |= ZTable[C]; break;//RLC C
case 0x02: F = (D >> 7); D = (D << 1) | (F); D &= 0xFF; F |= ZTable[D]; break;//RLC D
case 0x03: F = (E >> 7); E = (E << 1) | (F); E &= 0xFF; F |= ZTable[E]; break;//RLC E
case 0x04: F = (H >> 7); H = (H << 1) | (F); H &= 0xFF; F |= ZTable[H]; break;//RLC H
case 0x05: F = (L >> 7); L = (L << 1) | (F); L &= 0xFF; F |= ZTable[L]; break;//RLC L
case 0x07: F = (A >> 7); A = (A << 1) | (F); A &= 0xFF; F |= ZTable[A]; break;//RLC A

case 0x06: tmpb = read(HL); F = (tmpb >> 7); tmpb = (tmpb << 1) | (F); tmpb &= 0xFF; F |= ZTable[tmpb]; write(HL, tmpb); break;//RLC (HL) : state 16

//RRC s : 00 001 r : state 8
case 0x08: F=(B&0x01);B=(B>>1)|(F<<7);B &= 0xFF;F|=ZTable[B];break;//RRC B
case 0x09: F=(C&0x01);C=(C>>1)|(F<<7);C &= 0xFF;F|=ZTable[C];break;//RRC C
case 0x0A: F=(D&0x01);D=(D>>1)|(F<<7);D &= 0xFF;F|=ZTable[D];break;//RRC D
case 0x0B: F=(E&0x01);E=(E>>1)|(F<<7);E &= 0xFF;F|=ZTable[E];break;//RRC E
case 0x0C: F=(H&0x01);H=(H>>1)|(F<<7);H &= 0xFF;F|=ZTable[H];break;//RRC H
case 0x0D: F=(L&0x01);L=(L>>1)|(F<<7);L &= 0xFF;F|=ZTable[L];break;//RRC L
case 0x0F: F=(A&0x01);A=(A>>1)|(F<<7);A &= 0xFF;F|=ZTable[A];break;//RRC A

case 0x0E: tmpb=read(HL);F=(tmpb&0x01);tmpb=(tmpb>>1)|(F<<7);tmpb &= 0xFF;F|=ZTable[tmpb];write(HL,tmpb);break;//RRC (HL) :state 16

//RL s : 00 010 r : state 8
case 0x10: tmpb = F & 0x01; F = (B >> 7); B = (B << 1) | tmpb; B &= 0xFF; F |= ZTable[B]; break;//RL B
case 0x11: tmpb = F & 0x01; F = (C >> 7); C = (C << 1) | tmpb; C &= 0xFF; F |= ZTable[C]; break;//RL C
case 0x12: tmpb = F & 0x01; F = (D >> 7); D = (D << 1) | tmpb; D &= 0xFF; F |= ZTable[D]; break;//RL D
case 0x13: tmpb = F & 0x01; F = (E >> 7); E = (E << 1) | tmpb; E &= 0xFF; F |= ZTable[E]; break;//RL E
case 0x14: tmpb = F & 0x01; F = (H >> 7); H = (H << 1) | tmpb; H &= 0xFF; F |= ZTable[H]; break;//RL H
case 0x15: tmpb = F & 0x01; F = (L >> 7); L = (L << 1) | tmpb; L &= 0xFF; F |= ZTable[L]; break;//RL L
case 0x17: tmpb = F & 0x01; F = (A >> 7); A = (A << 1) | tmpb; A &= 0xFF; F |= ZTable[A]; break;//RL A

case 0x16:  //RL (HL) :state 16
	tmpb = read(HL);
	tmpb |= ((F & 0x01) << 8);
	F = ((tmpb >> 7) & 0x01);
	tmpb = ((tmpb << 1) & 0xFE) | ((tmpb >> 8) & 0x01);
	tmpb &= 0xFF;
	F |= ZTable[tmpb];
	write(HL, tmpb);
	break;

//RR s : 00 011 r : state 8
case 0x18: tmpb=F&0x01;F=(B&0x01);B=(B>>1)|(tmpb<<7);F|=ZTable[B];break;//RR B
case 0x19: tmpb=F&0x01;F=(C&0x01);C=(C>>1)|(tmpb<<7);F|=ZTable[C];break;//RR C
case 0x1A: tmpb=F&0x01;F=(D&0x01);D=(D>>1)|(tmpb<<7);F|=ZTable[D];break;//RR D
case 0x1B: tmpb=F&0x01;F=(E&0x01);E=(E>>1)|(tmpb<<7);F|=ZTable[E];break;//RR E
case 0x1C: tmpb=F&0x01;F=(H&0x01);H=(H>>1)|(tmpb<<7);F|=ZTable[H];break;//RR H
case 0x1D: tmpb=F&0x01;F=(L&0x01);L=(L>>1)|(tmpb<<7);F|=ZTable[L];break;//RR L
case 0x1F: tmpb=F&0x01;F=(A&0x01);A=(A>>1)|(tmpb<<7);F|=ZTable[A];break;//RR A

case 0x1E:  //RR (HL) :state 16
	tmpb = read(HL);
	tmpb |= ((F & 0x01) << 8);
	F = (tmpb & 0x01);
	tmpb = ((tmpb >> 1) & 0xFF);
	F |= ZTable[tmpb];
	write(HL, tmpb);
	break;

//SLA s : 00 100 r : state 8
case 0x20: F = B >> 7; B <<= 1; B &= 0xFF; F |= ZTable[B]; break;//SLA B
case 0x21: F = C >> 7; C <<= 1; C &= 0xFF; F |= ZTable[C]; break;//SLA C
case 0x22: F = D >> 7; D <<= 1; D &= 0xFF; F |= ZTable[D]; break;//SLA D
case 0x23: F = E >> 7; E <<= 1; E &= 0xFF; F |= ZTable[E]; break;//SLA E
case 0x24: F = H >> 7; H <<= 1; H &= 0xFF; F |= ZTable[H]; break;//SLA H
case 0x25: F = L >> 7; L <<= 1; L &= 0xFF; F |= ZTable[L]; break;//SLA L
case 0x27: F = A >> 7; A <<= 1; A &= 0xFF; F |= ZTable[A]; break;//SLA A

case 0x26: tmpb = read(HL); F = tmpb >> 7; tmpb <<= 1; tmpb &= 0xFF; F |= ZTable[tmpb]; write(HL, tmpb); break;//SLA (HL) :state 16

//SRA s : 00 101 r : state 8
case 0x28: F=B&0x01;B=(B>>1)|(B&0x80);F|=ZTable[B];break;//SRA B
case 0x29: F=C&0x01;C=(C>>1)|(C&0x80);F|=ZTable[C];break;//SRA C
case 0x2A: F=D&0x01;D=(D>>1)|(D&0x80);F|=ZTable[D];break;//SRA D
case 0x2B: F=E&0x01;E=(E>>1)|(E&0x80);F|=ZTable[E];break;//SRA E
case 0x2C: F=H&0x01;H=(H>>1)|(H&0x80);F|=ZTable[H];break;//SRA H
case 0x2D: F=L&0x01;L=(L>>1)|(L&0x80);F|=ZTable[L];break;//SRA L
case 0x2F: F=A&0x01;A=(A>>1)|(A&0x80);F|=ZTable[A];break;//SRA A

case 0x2E: tmpb=read(HL);F=tmpb&0x01;tmpb>>=1;tmpb|=(tmpb<<1)&0x80;F|=ZTable[tmpb];write(HL,tmpb);break;//SRA (HL) :state 16

//SRL s : 00 111 r : state 8
case 0x38: F=B&0x01;B>>=1;F|=ZTable[B];break;//SRL B
case 0x39: F=C&0x01;C>>=1;F|=ZTable[C];break;//SRL C
case 0x3A: F=D&0x01;D>>=1;F|=ZTable[D];break;//SRL D
case 0x3B: F=E&0x01;E>>=1;F|=ZTable[E];break;//SRL E
case 0x3C: F=H&0x01;H>>=1;F|=ZTable[H];break;//SRL H
case 0x3D: F=L&0x01;L>>=1;F|=ZTable[L];break;//SRL L
case 0x3F: F=A&0x01;A>>=1;F|=ZTable[A];break;//SRL A

case 0x3E: tmpb=read(HL);F=tmpb&0x01;tmpb>>=1;F|=ZTable[tmpb];write(HL,tmpb);break;//SRL (HL) :state 16

//swap opcode
//SWAP n : 00 110 r :state 8
case 0x30: B = (B >> 4) | (B << 4); B &= 0xFF; F = ZTable[B]; break;//SWAP B
case 0x31: C = (C >> 4) | (C << 4); C &= 0xFF; F = ZTable[C]; break;//SWAP C
case 0x32: D = (D >> 4) | (D << 4); D &= 0xFF; F = ZTable[D]; break;//SWAP D
case 0x33: E = (E >> 4) | (E << 4); E &= 0xFF; F = ZTable[E]; break;//SWAP E
case 0x34: H = (H >> 4) | (H << 4); H &= 0xFF; F = ZTable[H]; break;//SWAP H
case 0x35: L = (L >> 4) | (L << 4); L &= 0xFF; F = ZTable[L]; break;//SWAP L
case 0x37: A = (A >> 4) | (A << 4); A &= 0xFF; F = ZTable[A]; break;//SWAP A

case 0x36: tmpb = read(HL); tmpb = (tmpb >> 4) | (tmpb << 4); tmpb &= 0xFF; F = ZTable[tmpb]; write(HL, tmpb); break;//SWAP (HL) : state 16

}

	}
}
