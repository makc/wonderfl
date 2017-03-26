package  {
    import com.bit101.components.CheckBox;
    import com.bit101.components.HUISlider;
    import com.bit101.components.Label;
    import com.bit101.components.NumericStepper;
    import com.bit101.components.PushButton;
    import com.bit101.components.Style;
    import com.bit101.components.UISlider;
    import flash.display.Sprite;
    import flash.events.Event;
    [SWF(width="465",height="465",frameRate="60",backgroundColor="0")]
    public class SortView extends Sprite {
        public var visualizer:SortVisualizer;
        public var logode:Log;
        public var shuffleButton:PushButton;
        public var randomButton:PushButton;
        public var invertButton:PushButton;
        public var sortButton:PushButton;
        public var stopButton:PushButton;
        public var shuffleStepper:NumericStepper;
        public var sortCombo:ComboBox2;
        public var sizeSlider:HUISlider;
        public var speedSlider:HUISlider;
        public var sortTypes:Array = [ "insertionSort", "dichotomicInsertionSort", "dichotomicInsertionSort2", "selectionSort", "shortSelectionSort", "bubbleSort", "cocktailSort", "combSort", "shellSort", "quickSort", "quickSort2", "margeSort", "inPlaceMargeSort", "heapSort", "easySmoothSort", "oddEvenSort", "bitonicMargeSort", "oddEvenMargeSort", "shellectionSort" ];
        public var sortNames:Array = [ "Insertion", "Dichotomic Insertion", "Dichotomic Insertion2", "Selection", "Short Selection", "Bubble", "Cocktail", "Comb", "Shell", "Quick", "Quick2", "Marge", "In-Place Marge", "Heap", "Easy Smooth", "Odd-Even", "Bitonic Marge", "Odd-Even Marge", "Shellection"];
        public var compareLabel:Label;
        public var moveLabel:Label;
        public function SortView() {
            addChild( visualizer = new SortVisualizer );
            Style.BUTTON_FACE = 0x222222;
            Style.LABEL_TEXT = 0xFFFFFF;
            Style.DROPSHADOW = 0x111111;
            sortCombo = new ComboBox2( this, 5, 5, "SortType", sortNames );
            sortCombo.setSize( 200, 20 );
            sortCombo.listItemHeight = 15;
            sortCombo.selectedIndex = 0;
            sortCombo.addEventListener( "select", sort );
            sizeSlider = new HUISlider( this, 5, 27, "size  :", setSize );
            sizeSlider.setSize( 220, 15 )
            sizeSlider.minimum = 2;
            sizeSlider.maximum = 100;
            sizeSlider.labelPrecision = 0;
            sizeSlider.tick = 1;
            visualizer.setup( sizeSlider.value = 16 );
            speedSlider = new HUISlider( this, 5, 42, "speed:", setSpeed );
            speedSlider.setSize( 220, 15 )
            speedSlider.minimum = 0;
            speedSlider.maximum = SortVisualizer.MAX_SPEED;
            speedSlider.labelPrecision = 0;
            speedSlider.tick = 1;
            visualizer.speed = speedSlider.value =  SortVisualizer.MAX_SPEED - 5;
            sortButton = new PushButton( this, 5, 60, "start", sort );
            stopButton = new PushButton( this, 5, 82, "stop", stop );
            stopButton.enabled = false; 
            shuffleStepper = new NumericStepper( this, 360, 5 );
            shuffleStepper.setSize( 100, 20 );
            shuffleStepper.minimum = 1;    shuffleStepper.value = 5; shuffleStepper.maximum = 99;
            shuffleButton = new PushButton( this, 360, 23, "shuffle", shuffle );  
            randomButton = new PushButton( this, 360, 45, "random", random );  
            invertButton = new PushButton( this, 360, 67, "invert", invert );  
            visualizer.onFinish = onFinish;
            visualizer.onChange = onChange;
            Style.LABEL_TEXT = Color.COLOR5;
            moveLabel  = new Label( this, 85, 430, "move:0" );
            moveLabel.scaleX = moveLabel.scaleY = 2
            compareLabel  = new Label( this, 285, 430, "compare:0" );
            compareLabel.scaleX = compareLabel.scaleY = 2;
            Style.LABEL_TEXT = 0x666666;
        }
        public function sort( e:Event ):void {
            visualizer.play( Sort[ sortTypes[ sortCombo.selectedIndex ] ]( visualizer.getArray() ) );
            onStart();
        }
        public function shuffle( e:Event ):void {
            if(shuffleStepper.maximum < shuffleStepper.value){ shuffleStepper.value = shuffleStepper.value;} 
            visualizer.play( Sort.shuffle( visualizer.getArray(), shuffleStepper.value ) )
            onStart();
        }
        public function random( e:Event ):void {
            visualizer.play( Sort.random( visualizer.getArray() ) )
            onStart();
        }
        public function invert( e:Event ):void {
            visualizer.play( Sort.invert( visualizer.getArray() ) )
            onStart();
        }
        public function stop( e:Event ):void {
            visualizer.running = false;
            onFinish();
        }
        public function setSize( e:Event ):void {
            visualizer.setup( sizeSlider.value );
        }
        public function setSpeed( e:Event ):void {
            visualizer.speed = speedSlider.value;
        }
        public function onStart():void {
            sortCombo.enabled = false;
            sizeSlider.enabled = false;
            stopButton.enabled = true;
            sortButton.enabled = false;
            shuffleStepper.enabled = false;
            shuffleButton.enabled = false;
            randomButton.enabled = false;
            invertButton.enabled = false;
        }
        public function onFinish():void {
            sortCombo.enabled = true;
            sizeSlider.enabled = true;
            stopButton.enabled = false;
            sortButton.enabled = true;
            shuffleStepper.enabled = true;
            shuffleButton.enabled = true;
            randomButton.enabled = true;
            invertButton.enabled = true;
        }
        public function onChange():void {
            compareLabel.text = "compare:" + visualizer.compareCount;
            moveLabel.text = "move:" + visualizer.moveCount;
        }
    }
}
import flash.display.DisplayObjectContainer;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.lights.PointLight3D;
import org.papervision3d.materials.ColorMaterial;
import org.papervision3d.materials.shadematerials.GouraudMaterial;
import org.papervision3d.objects.DisplayObject3D;
class Sort {
    static public function shuffle( arr:Array, count:int ):Log {
        var log:Log = new Log( arr );
        for ( var n:int = 0, s:int = 1, l:int = arr.length; n < count; s = 3 - s, n++, log.next() ) {
            for ( var i:int = s; i < l; i += 2 ){
                if ( Math.random() < 0.5 ) {
                    log.swap( i - 1, i );
                }
            }
        }
        return log;
    }
    static public function random( arr:Array ):Log {
        var log:Log = new Log( arr ); 
        for ( var i:int = 0, a:Array = [], l:int = arr.length; i < l; i++ ){ a.push(i); }
        for ( i = 0; i < l; i++ ) {
            var n:int = a.splice( int( Math.random() * (l-i) ), 1 );
            log.move( i, n );
        }
        return log;
    }
    static public function invert( arr:Array ):Log {
        var log:Log = new Log( arr ); 
        for ( var i:int = 0, a:Array = [], l:int = arr.length; i < l; i++ ){ a.push(i); }
        for ( i = 0; i < l; i++ ) {
            var n:int = a.pop();
            log.move( i, n );
        }
        return log;
    }
    
//==以下、各ソートのコードと解説==========================================================================================
/*
==挿入ソート(Insertion Sort)==========================================================================================
最善計算速度(Best)    :O(n)
平均計算速度(Average)    :O(n^2)
最悪計算速度(Worst)    :O(n^2)
メモリ使用量(Memory)    :O(1)
安定性(stable)        :Yes

各数値を前方の値と比較し、正しい位置に挿入するソート。
ランダムな配列では遅いが、ある程度整理された配列をソートするのはとても速い。
非常に単純なソートだが、使い道はわりとある。
*/
static public function insertionSort( arr:Array ):Log { 
    var log:Log = new Log( arr );
    for ( var l:int = arr.length, j:int = 1, i:int = 0; j < l; log.insert( j, ++i ), log.next(), i = j++ )
        while( i >= 0 && !log.compare( i, j ) ) { i--; }
    return log;
}


/*
==二分挿入ソート(Dichotomic Insertion Sort)==========================================================================================
最善計算速度(Best)    :O(nlogn)
平均計算速度(Average)    :O(n^2) *ただし、挿入がO(1)で行える場合はO(nlogn)
最悪計算速度(Worst)    :O(n^2) *ただし、挿入がO(1)で行える場合はO(nlogn) 
メモリ使用量(Memory)    :O(1)
安定性(stable)        :No

挿入ソートの改良版のソート。
前の数値との比較を、二分探索で行うことで平均の比較回数を減らせる。
ただし、整理された配列のソートは遅くなるので、使い道は、あまり思い浮かばない。
*/
static public function dichotomicInsertionSort( arr:Array ):Log { 
    var log:Log = new Log( arr );
    for ( var l:int = arr.length, j:int = 1, i:int = 0, s:int = 0, e:int = 1; j < l; log.insert( j, i ), log.next(), s = 0, e = ++j, i = e >> 1 )
        while ( s < e ) {
            if ( log.compare( i, j ) ) { s = i + 1; i = (s + e) >> 1 }
            else{ e = i; i = (s + e) >> 1 }
        }
    return log;
}


/*
//==二分挿入ソート2(Dichotomic Insertion Sort2)==========================================================================================
最善計算速度(Best)    :O(n)
平均計算速度(Average)    :O(n^2) *ただし、挿入がO(1)で行える場合はO(nlogn)
最悪計算速度(Worst)    :O(n^2) *ただし、挿入がO(1)で行える場合はO(nlogn)
メモリ使用量(Memory)    :O(1)
安定性(stable)        :No

挿入ソートの改良版のソートpart2。
二分探索で行うこと前に前回挿入を行った値と比較を行う。
ランダムな配列のソートは単純な二分挿入ソートと同程度に速く、整理された配列のソートもわりと速い。
*/
static public function dichotomicInsertionSort2( arr:Array ):Log { 
    var log:Log = new Log( arr );
    for ( var l:int = arr.length, j:int = 1, i:int = 0, s:int = 0, e:int = 1; j < l; j++ ){
        if( log.compare( i, j ) ){ s = i + 1; e = j; }
        else{ s = 0; e = i; }
        i = (s + e >> 1);
        while ( s < e ) {
            if ( log.compare( i, j ) ) { s = i + 1; i = (s + e) >> 1 }
            else{ e = i; i = (s + e) >> 1 }
        }
        log.insert( j, i ); log.next(); 
    }
    return log;
}


/*
//==単純選択ソート(Selection Sort)==========================================================================================
最善計算速度(Best)    :O(n^2)
平均計算速度(Average)    :O(n^2)
最悪計算速度(Worst)    :O(n^2)
メモリ使用量(Memory)    :O(1)
安定性(stable)        :No

配列の中から一番小さい(大きい値)を探す。
↓
配列の先頭(末尾)に持ってくる。
↓
のこりの配列の中から一番小さい(大きい値)を探す。
↓
配列の先頭(末尾)に持ってくる。

を繰り返すソート。

アルゴリズムはすごく簡単、コードも簡単。
比較回数は多いが、要素の交換回数は少ない。
*/
static public function selectionSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    for ( var l:int = arr.length; l > 1; log.swap( k, --l ), log.next() )
        for ( var i:int = 1, k:int = 0; i < l; i++ )
            if ( log.compare( k, i ) ) k = i;
    return log;
}


/*
//==短縮選択ソート(Short　Selection Sort)==========================================================================================
最善計算速度(Best)    :O(n)
平均計算速度(Average)    :O(n^2)
最悪計算速度(Worst)    :O(n^2)
メモリ使用量(Memory)    :O(n)
安定性(stable)        :No

選択ソートの改良版ソート。
前回までに最小値(最大値)の交換を行った位置を記録しておくことで、探索範囲を減らしている。
要素の交換回数はそのまま、比較回数は単純選択ソートの半分程度に減らせることができる。
ある程度整理された配列をすばやくソート出来るという性質がある。
*/
static public function shortSelectionSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    for( var l:int = arr.length, js:Vector.<int> = new Vector.<int>(), jl:int, i:int = 0, j:int = 1; l > 0; l-- ){
        for ( ;j < l; j++ )
            if ( log.compare(i, j) ) js.push(j), i = j;
        log.swap( i, l - 1 ), log.next()
        if ( (jl = js.length) ) {
            j = js.pop();
            if ( jl > 1 ) { i = js[ jl - 2 ]; }
            else{ i = 0 }
        }else { j = 1, i = 0; }
    }
    return log;
}



/*
//==バブルソート(Bubble Sort)==========================================================================================
最善計算速度(Best)    :O(n)
平均計算速度(Average)    :O(n^2)
最悪計算速度(Worst)    :O(n^2)
メモリ使用量(Memory)    :O(1)
安定性(stable)        :Yes

隣合う要素の交換を交換できなくなるまで繰り返す。
挿入ソート、選択ソートと同様、コードが単純で分かりやすいアルゴリズムの一つ。

ただし、ありとあらゆる場面で挿入ソートに劣るので、使い道は無い。
*/
static public function bubbleSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    var l:int = arr.length;
    do {
        for ( var i:int = 1, loop:Boolean = false; i < l; i++ ) {
            if (! log.compare( i-1, i ) )
                log.swap( i - 1, i ) , log.next(), loop = true;
            log.next();
        }
    }while ( --l > 1 && loop );
    return log;
}


/*
//==シェーカーソート(Cocktail Sort)==========================================================================================
最善計算速度(Best)    :O(n)
平均計算速度(Average)    :O(n^2)
最悪計算速度(Worst)    :O(n^2)
メモリ使用量(Memory)    :O(1)
安定性(stable)        :Yes

バブルソートの改良版。
隣接した要素の交換を、配列を往復するように行うソート。

有名なソート法ではあるが、アルゴリズムがまどろっこしい上に、ありととあらゆる場面で挿入ソートに劣る。
実用性は全くない。
*/
static public function cocktailSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    var s:int = 0, e:int = arr.length-1;
    do {
        var loop:Boolean = false, i:int = s;
        while ( ++i <= e )
            if (! log.compare( i - 1, i ) ) 
                log.swap( i - 1, i ), log.next(), loop = true;
        log.next();

        if ( loop == false ) break;
        loop = true, i = --e;
        while( --i >= s )
            if (! log.compare( i, i + 1 ) ) 
                log.swap( i, i+1 ),    log.next(), loop = true;
        s++;
        log.next();
    }while ( loop );
    return log;
}


/*
//==コムソート(Comb Sort)==========================================================================================
最善計算速度(Best)    :O(nlogn)?
平均計算速度(Average)    :O(nlogn)?
最悪計算速度(Worst)    :O(n^2)
メモリ使用量(Memory)    :O(1)
安定性(stable)        :No

バブルソートを土台にした高速なソート。


5,6,9,8,1,0,3,4,7,2という配列の場合、以下のような手順でソートする。

1) 元の間隔5でみて、できる5つの配列に対して、バブルソートのように隣り合う要素の交換を1周だけ行う。
(この操作を「間隔5で櫛をかける」と呼ぶ。)

5,6,9,8,1,0,3,4,7,2
　↓
5,        0
  6,        3
    9,        4
      8,        7
        1,        2
　↓
0,3,4,7,1,5,6,9,8,2


2) 櫛の間隔を 5 -> 3 -> 2　というように減らしていく。

0,3,4,7,1,5,6,9,8,2
　↓
0,    7,    6,    2
  3,    1,    9
    4,    5,    8
　↓
0,1,4,6,3,5,2,9,8,7
　↓
0,  4,  3,  2,  8
  1,  6,  5,  9,  7
　↓
0,1,3,5,2,6,4,7,8,9


3) 櫛の間隔が1になったら、バブルソート、または挿入ソートによって配列を完全にソートする。

0,1,3,5,2,6,4,7,8,9
　↓
0,1,2,3,4,5,6,7,8,9


バブルソートや挿入ソートが大まかに整列された配列を高速でソート出来ることを利用したソート法。
櫛の間隔を調節することで、ランダムな配列に強くしたり、整列された配列に強くしたり、ソートの性質を変えることができる。
実装が楽で、ヒープソートやマージソートと同じレベルの速度が出せる。

なお、3)の段階ではバブルソートを使うのが一般的だが、挿入ソートを使ったほうが速くソート出来るので、下のコードでは挿入ソートを用いている。
*/
static public function combSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    var l:int = arr.length, inc:int = l >> 1, j:int;
    while( (inc = int( inc / 1.3 )) > 1 )
        for(var s:int = 0; s < inc;  s++)
            for ( var i:int = s + inc; i < l;log.next(), i += inc )
                if ( !log.compare( i-inc, i ) ) log.swap( i-inc, i ),log.next();
    for ( j = 1, i = 0; j < l; log.insert( j, ++i ), log.next(), i = j++ )
        while( i >= 0 && !log.compare( i, j ) ) { i--; }
    return log;
}
/*
//==シェルソート(Shell Sort)==========================================================================================
最善計算速度(Best)    :O(n)?
平均計算速度(Average)    :O(n(logn)^2)?
最悪計算速度(Worst)    :O(n^1.25)?
メモリ使用量(Memory)    :O(1)
安定性(stable)        :No

櫛ソートと同様の高速化を挿入ソートを土台にして行ったソート。

櫛ソートでは、間隔を開けてできる配列に対して、隣り合う要素の交換を行ったが、
シェルソートでは、間隔を開けてできる配列を挿入ソートで完全にソートする。

櫛ソートと同じような特徴を持つが、櫛ソートよりやや低速。
*/
static public function shellSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    var l:int = arr.length, inc:int = 1;
    while ( inc < l ) inc = (inc * 3) + 1;
    while ( (inc = (inc - 1) / 3) > 0 ) 
        for ( var i:int = inc; i < l; log.move(i, j), log.next(), i++ ) 
            for ( var j:int = i, b:* = arr[i]; j >= inc && !log.compare( j - inc, j ); ) log.move( j - inc, j ), arr[j] = arr[j -= inc], arr[ j ] = b;
    return log;
}

/*
//==クイックソート(Quick Sort)==========================================================================================
最善計算速度(Best)    :O(nlogn)
平均計算速度(Average)    :O(nlogn)
最悪計算速度(Worst)    :O(n^2)
メモリ使用量(Memory)    :O(logn)
安定性(stable)        :No

単純かつ高速なソート。

配列から適当な値を取り出し、その値(ピボットと呼ぶ)より大きいか小さいかでその他の要素を2分していく。
このコードは、ピボットとして先頭にある要素を選択するという、もっとも単純なもの。
ランダムな配列をソートするのは高速だが、整列された配列のソートは非常に遅いという欠点がある。
*/
static public function quickSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    for ( var jobs:Array = [ [0, arr.length] ], job:Array, s:int, e:int; job = jobs.pop(); ) {
        if ( ( e = job[1]) - (s = job[0] ) < 2 ) continue;
        for ( var i:int = s, j:int = e; ++i < j; ) if (! log.compare( i, s ) ) while ( i < --j ) if ( ! log.compare( s, j ) ) { 
            log.swap( i, j ); break;
        }
        log.next();    log.swap( --j, s ); log.next();    jobs.push( [ j + 1, e ], [ s, j ] );
    }
    return log;
}

/*
//==クイックソート2(Quick Sort2)==========================================================================================
最善計算速度(Best)    :O(nlogn)
平均計算速度(Average)    :O(nlogn)
最悪計算速度(Worst)    :O(n^2)
メモリ使用量(Memory)    :O(logn)
安定性(stable)        :No

クイックソートの別バリエーション。
配列の先頭、最後尾、中央の値の中央値となる位置をピボットにすることで高速化している。
これなら整列された配列も問題ない速度でソート出来る。
ただし、特定の並びの配列に対してはやはり遅い。
*/
public static function quickSort2( arr:Array ):Log {
    var log:Log = new Log( arr );
    for ( var jobs:Array = [ [0, arr.length] ], job:Array, s:int, e:int,  l:int; job = jobs.pop(); ) {
        if ( (l = (e = job[1]) - (s = job[0] )) == 2 ) {
            if (! log.compare( s, s + 1 ) ) log.swap( s, s + 1 );
            log.next();
        }else if( l > 2 ){
            var x:int = s, y:int = s + ((l + 1) >> 1) - 1, z:int = e - 1;
            var a:*;
            if ( log.compare( x, y ) ) {
                if (! log.compare( y, z ) ) {
                    if ( log.compare( x, z ) ){ log.swap( y, z ); }
                    else{ log.rotate(x,y,z); }
                }
            }else{
                if ( log.compare( y, z ) ) {
                    if ( log.compare( x, z ) ){ log.swap( y, x ); }
                    else{ log.rotate(z,y,x); }
                }else log.swap(x, z);
            }
            log.next();
            if ( l > 3 ) {
                var p:int;
                log.swap( y, p = s + 1 ); log.next();
                for ( var i:int = p, j:int = e - 1; ++i < j; ) if (! log.compare( i, p ) ) while ( i < --j ) if ( !log.compare( p, j ) ) { 
                    log.swap( i, j );
                    break;
                }
                log.next(); log.swap( --j, p ); log.next(); jobs.push( [ j + 1, e ], [ s, j ] );
            }
        }
    }
    return log;
}


/*
//==マージソート(Marge Sort)==========================================================================================
最善計算速度(Best)    :O(nlogn)
平均計算速度(Average)    :O(nlogn)
最悪計算速度(Worst)    :O(nlogn)
メモリ使用量(Memory)    :O(n)
安定性(stable)        :Yes


配列を分割して、併合を繰り返していくソート。


例えば、43567218と並んでいる配列では、

4|3|5|6|7|2|1|8　と区画を分けて考えて、
隣あった区画が正しく並ぶように併合していく。

4|3|5|6|7|2|1|8
↓　
34|56|27|18
↓　
3456|1278
↓　
12345678


ランダムな配列のソートではクイックソートにやや劣るが、十分速い。
また、配列の並びによる計算速度の変化が小さいという特徴がある。

等価な要素が元の順番を保ったままになるソート(=安定ソート)。
アルゴリズムの理解もしやすく、実用性の高いソート。
*/
static public function margeSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    for( var l:int = arr.length, w:int = 1; w < l; w <<= 1 ){
        for( var c:int = w; c < l; c += (w << 1) ){
            var s:int = c - w, e:int = c + w;
            if( e > l ){ e = l }
            for ( var i:int = e - 1, temp:Array = []; i >= s; i-- ) { temp.push( arr[i] ); }
            i = s;
            for( var j:int = c, x:int = s, a:* = temp.pop(), b:* = arr[j];; ){
                log.compare( i, j )
                if( a <= b ){
                    log.move( i, x ), arr[x++] = a;
                    if( ++i == c ){ break; }
                    a = temp.pop();
                }else{
                    log.move( j, x ), arr[x++] = b;
                    if( ++j == e ){ 
                        while ( i < c ) { log.move( i, x ), arr[x++] = a, a = temp.pop(); i++ }
                        break; 
                    }
                    b = arr[j]
                }
            }
            log.next();
        }
    }
    return log;
}

/*
//==内部マージソート(Marge Sort)==========================================================================================
最善計算速度(Best)    :O(n^2) *ただし、挿入がO(1)で行える場合はO(nlogn) 
平均計算速度(Average)    :O(n^2) *ただし、挿入がO(1)で行える場合はO(nlogn) 
最悪計算速度(Worst)    :O(n^2) *ただし、挿入がO(1)で行える場合はO(nlogn) 
メモリ使用量(Memory)    :O(1)
安定性(stable)        :Yes

マージソートの変形。
併合の時に挿入を用いることで、メモリの使用量を押さえたもの。
通常の配列のソートでは、普通のマージソートの方が圧倒的に速い。
安定な内部ソートが必要になった時に用いるのがよい。

リンクリストのソートなら高速で行えそう。
*/
static public function inPlaceMargeSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    for( var l:int = arr.length, w:int = 1; w < l; w <<= 1 ){
        for( var c:int = w; c < l; c += (w << 1) ){
            var s:int = c - w, e:int = c + w;
            if( e > l ){ e = l }
            for( var i:int = s, j:int = c;; ){
                if( log.compare( i, j ) ){
                    if( ++i == j ){ break }
                }else{
                    log.insert( j, i++ ); log.next();
                    if( ++j == e ){ break }
                }
            }
            log.next();
        }
    }
    return log;
}

/*
//==ヒープソート(Heap Sort)==========================================================================================
最善計算速度(Best)    :O(nlogn)
平均計算速度(Average)    :O(nlogn)
最悪計算速度(Worst)    :O(nlogn)
メモリ使用量(Memory)    :O(1)
安定性(stable)        :No

擬似的に木構造を作成して、その木構造を使ってソートする。
たとえば、
5,7,3,2,9,8,1,6,4 という配列なら
　　　　　　　６４
　　　┌───┴┘
　　　２９８１
　┌─┴┘││
　７３──┴┘
┌┴┘
５
という木構造とみなせる。

配列の位置が木構造の位置になってるので、実際に木構造を作る必要はない。


ソートのアルゴリズムは以下のとおりである。

1) 交換を行い、親より大きい子がなくす。
　　　　　　　６４
　　　┌───┴┘
　　　２９８１
　┌─┴┘││
　７３──┴┘
┌┴┘
５
　　　　　　　２４
　　　┌───┴┘
　　　６５３１
　┌─┴┘││
　７８──┴┘
┌┴┘
９
2) 木の頭と末尾を交換し、木を1つ小さくする。
　　　　　　　２９
　　　┌───┘
　　　６５３１
　┌─┴┘││
　７８──┴┘
┌┴┘
４
3) 先頭に持っていった数字を、親より大きい子がなくなるなるまで、移動する。
　　　　　　　２９
　　　┌───┘
　　　６５３１
　┌─┴┘││
　７４──┴┘
┌┴┘　　　　　　　　　　　※子二つのうち大きい方と比較し、子の方が大きければ交換していく。
８
4) 2),3)を繰り返す。
　　　６５３１８９
　┌─┴┘││
　７４──┴┘
┌┴┘
２
　　　２５３７８９
　┌─┴┘│
　６４──┘
┌┴┘
１
　　　２１６７８９
　┌─┴┘
　５４
┌┴┘
３
・・・
１２３４５６７８９

アルゴリズムを理解するのはやや難しいが、思いのほかコンパクトなコードにまとまる。
配列を逆向き並べているように見えるので効率が悪そうだが、マージソートと同程度に高速。
*/
static public function heapSort( arr:Array ): Log {
    var log:Log = new Log( arr );
    for ( var l:int = arr.length, j:int = 1, i:int = 1, a:* = arr[j]; i < l; log.move( j, i ), log.next(), a = arr[ i = ++j] )
        while ( i > 0 && !log.compare( i, (i - 1) >> 1 ) ) log.move( (i - 1) >> 1, i ), arr[i] = arr[i = (i - 1) >> 1], arr[i] = a;
    p:for ( ;l-- > 0; log.move( l, i ), arr[i] = a, log.next() ) {
        for ( log.move( 0, l ), a = arr[l], arr[l] = arr[0], arr[0] = a, i = 0, j = 2; j < l;  ) {
            if ( log.compare( j, j - 1 ) ) j--;
            if ( log.compare( j, i ) ) continue p;
            else log.move( j, i ), arr[i] = arr[i = j], arr[i] = a, j = ( j << 1 ) + 2;
        }
        if ( --j < l && !log.compare( j, i ) ) log.move( j, i ), arr[i] = arr[i = j], arr[i] = a;
    }
    return log;
}

/*
//==スムースソート(Smooth Sort)==========================================================================================
最高速度: O(n)
平均速度: O(nlogn)
最低速度: O(nlogn)
使用メモリ: O(1)
安定性:No

ヒープソート同様の擬似的な木構造を用いたソートだが、配列と木構造の対応がヒープソートとは異なる。

たとえば、
5,7,3,2,9,8,1,6,4,0 という配列なら
５７
└┴３２　８１　　０
　　└┴９└┴６
　　　　└──┴４
という木構造とみなす。この場合、要素9と要素1の二つの木ができる。

ヒープソートとは異なり木の数は複数にもなる。
また、各木の要素数は必ずレオナルド数になる。


ランダムな配列も、整列された配列も高速にソートできるらしいがアルゴリズムがわりと難しい。

勉強してみたけど挫折したのでコードは無し。
*/

/*
//==簡易版スムースソート(Easy Smooth Sort)==========================================================================================
最高速度: O(n)
平均速度: O(nlogn)
最低速度: O(nlogn)
使用メモリ: O(1)
安定性:No

スムースソートの良さをのこして、実装を少し簡単にしたソート法。

たとえば、
5,7,3,2,9,8,1,6,4,0 という配列なら
５７　２９　　　６４
└┴３└┴８　　└┴０
　　└──┴１
という2つの木構造とみなす。

スムースソートと同様、木の数は複数にもなる。


ソートのアルゴリズムは以下のとおりである。


1) 親より大きい子がなくなるよう交換を行う。
５７　２９　　　６４
└┴３└┴８　　└┴０
　　└──┴１
　↓
５３　２１　　　０４
└┴７└┴８　　└┴６
　　└──┴９

2) 木の頭の中で最も大きいものを末尾に配置して木を小さくする。
５３　２１　　　０４
└┴７└┴８　　└┴６
　　└──┴９
　↓
５３　２１　　　０　４　（９）
└┴７└┴８　　
　　└──┴６
※もっとも大きい値を選択する際に短縮選択ソートで使った高速化を行っている。

3) 交換を行った場合、子が親より小さくなるよう移動をする
５３　２１　　　０　４　（９）
└┴７└┴８　　
　　└──┴６
　↓　
５３　２１　　　０　４　（９）
└┴７└┴６　　
　　└──┴８
※子二つのうち大きい方と比較し子の方が大きければ交換、を繰り返す。

4) 2),3)を繰り返す。
５３　２１　　　０　４　（９）
└┴７└┴６　　
　　└──┴８
　↓　
４３　２１　　　０　（８、９）
└┴５└┴６　　
　　└──┴７
　↓　
４３　０１　　　（７、８、９）
└┴５└┴２　　
　　└──┴６
　↓　
４３　０１　　　（６、７、８、９）
└┴５└┴２　
　↓　
２３　０　１　　（５、６、７、８、９）
└┴４　
　↓　
２１　０　（４、５、６、７、８、９）
└┴３
　↓　
０１　（３、４、５、６、７、８、９）
└┴２
　↓　
０　１　（２、３、４、５、６、７、８、９）
　↓　
０、１、２、３、４、５、６、７、８、９
*/
static public function easySmoothSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    for ( var i:int = 2, depth:int = 0, count:int = 0, n:int, l:int = arr.length; i < l;  log.next() ) {
        for ( var d:int = depth, j:int = i, c:* = arr[i]; d >= 0; d-- )
            if ( log.compare( j - (2 << d), j - 1 ) )
                if ( log.compare( j - 1, j ) ) break;
                else{ log.move(j - 1, j), arr[j] = arr[j = j - 1], arr[j] = c;}
            else
                if ( log.compare( j - (2 << d), j ) ) break;
                else log.move(j - (2 << d), j), arr[j] = arr[j = j - (2 << d)], arr[j] = c;
        log.move( i, j ), log.next();
        if ( 1 & ( count >> depth ) ) { depth++, i++; }
        else { depth = 0, i += 3, count++; }
    }
    var rs:Vector.<int> = new Vector.<int>(), ds:Vector.<int> = new Vector.<int>();
    for ( count = l + 1, i = -1, j = l - 1; count > 1; ) {
        for ( var ex:int = 1; (count >> ex) != 1; ex++ ) { }
        n = ( 1 << ex ) - 1; count -= n; i += n; rs.push(i); ds.push(ex - 2);
    }
    for ( var x:int = 0, y:int = 1, ys:Vector.<int> = new Vector.<int>(), yl:int; --l > 0; ) {
        j = rs[x]; d = ds[x];
        for ( var rl:int = rs.length; y < rl; y++ ) {    if ( log.compare( j, i = rs[y] ) ) { ys.push(y), d = ds[y]; x = y; j = i; } }
        log.move( j, l ), c = arr[l], arr[l] = arr[j], arr[j] = c;
        if ( (yl = ys.length) ) {
            y = ys.pop();
            if ( yl > 1 ) x = ys[ yl - 2 ];
            else x = 0;
        }else{ y = 1, x = 0;}
        if ( j != l ) {
            for ( ; d >= 0; d-- ) {
                if ( log.compare( j - (2 << d), j - 1 ) ){
                    if ( log.compare( j - 1, j ) ) { break; }
                    else log.move( j - 1, j ), arr[j] = arr[j = j - 1], arr[j] = c;
                }else{
                    if ( log.compare( j - (2 << d), j ) ) { break; }
                    else log.move( j - (2 << d), j), arr[j] = arr[j = j - (2 << d)], arr[j] = c;
                }
            }
        }
        log.move( l, j ); log.next();
        i = rs.pop(); rl--; depth = ds.pop();
        if ( depth >= 0 ) { i -= (n = (rl?rs[rl-1]:-1)) + 1; rs.push( n += ( i >>= 1 ), n + i ); ds.push( depth - 1, depth - 1 ); }
    }
    return log;
}

//並列処理向けソート
/*
==奇遇転地ソート(Odd-Even Sort)==========================================================================================
最善計算速度(Best)    :O(n)
平均計算速度(Average)    :O(n^2)
最悪計算速度(Worst)    :O(n^2)
メモリ使用量(Memory)    :O(1)
安定性(stable)        :Yes

バブルソートの改良ソート。

奇数番目とその次の偶数番目の比較／交換、偶数番目とその次の奇数番目の比較／交換を繰り返すアルゴリズム。
並列化が簡単で、並列化すると最悪でもn回の段階でソートできる。
*/
static public function oddEvenSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    for (var c:int = 1, s:int = 1, l:int = arr.length; c >= 0 ; c--, s = 3 - s ) {
        for ( var i:int = s; i < l; i += 2 )
            if (! log.compare( i - 1, i ) )
                log.swap( i - 1, i ), c = 1;
        log.next();
    }
    return log;
}


/*
//==バイトニックマージソート(Bitonic Marge Sort)==========================================================================================
最善計算速度(Best)    :O(n(logn)^2)
平均計算速度(Average)    :O(n(logn)^2)
最悪計算速度(Worst)    :O(n(logn)^2)
メモリ使用量(Memory)    :O(1)
安定性(stable)        :No

マージソートを並列処理向けに改良したソート。

要素数8のときのソーティングネットワーク以下の通り。
┬┬─┬┬───┬─┬
┴┼┬┴┼┬──┼┬┴
┬┼┴┬┼┼┬─┴┼┬
┴┴─┴┼┼┼┬─┴┴
┬┬─┬┼┼┼┴┬─┬
┴┼┬┴┼┼┴─┼┬┴
┬┼┴┬┼┴──┴┼┬
┴┴─┴┴────┴┴

たった、O(logn)回の段階で終わる高速な並列ソート。
*/
static public function bitonicMargeSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    for( var l:int = arr.length, w0:int = 1; w0 < l; w0 <<= 1 ){
        for ( var c:int = w0; c < l; c += (w0 << 1) ) {
            var e:int = c + w0;
            if ( e > l ) { e = l; }
            for ( var j:int = c, i:int; j < e; j++ )
                if (! log.compare( i = c - (j - c) - 1, j ) ) log.swap( i, j );
        }
        log.next();
        for ( var w1:int = (w0 >> 1); w1 > 0; w1 >>= 1, log.next() )
            for ( c = w1; c < l; c += (w1 << 1) ) {
                if ( (e = c + w1) > l ) e = l;
                for ( j = c; j < e; j++ )
                    if (! log.compare( i = j - w1, j ) ) log.swap( i, j );
            }
    }
    return log;
}

/*
//==奇遇転地マージソート(Odd-Even Marge Sort)==========================================================================================
最善計算速度(Best)    :O(n(logn)^2)
平均計算速度(Average)    :O(n(logn)^2)
最悪計算速度(Worst)    :O(n(logn)^2)
メモリ使用量(Memory)    :O(1)
安定性(stable)        :No

バイトニックマージソートよりさらに速い並列マージソート


要素数8のときのソーティングネットワーク以下の通り。
┬┬──┬──────
┴┼┬┬┼┬────┬
┬┴┼┴┼┼┬─┬─┴
┴─┴─┼┼┼┬┼┬┬
┬┬──┴┼┼┼┴┼┴
┴┼┬┬─┴┼┼─┴┬
┬┴┼┴──┴┼──┴
┴─┴────┴───

必要な段階は、バイトニックマージソートと同じO(logn)回だが、より少ない比較回数でソートできる。
*/
static public function oddEvenMargeSort( arr:Array ):Log {
    var log:Log = new Log( arr );
    for( var l:int = arr.length, w0:int = 1; w0 < l; w0 <<= 1 ){
        for ( var c:int = w0; c < l; c += (w0 << 1) ) {
            var e:int = c + w0;
            if ( e > l ) { e = l; }
            for ( var j:int = c, i:int; j < e; j++ )
                if (! log.compare( i = j - w0, j ) ) log.swap( i, j );
        }
        log.next();
        for ( var w1:int = (w0 >> 1); w1 > 0; w1 >>= 1, log.next() ){
            for ( var s:int = 0; s < l; s += (w0 << 1) ){
                var e0:int = s + (w0 << 1);
                if ( e0 > l ) e0 = l;
                for ( c = s + (w1 << 1); c < e0; c += (w1 << 1) ) {
                    if ( (e = c + w1) > l ) e = l;
                    for ( j = c; j < e; j++ ){
                        if (! log.compare( i = j - w1, j ) ) log.swap( i, j );
                    }
                }
            }
        }
    }
    return log;
}

//おまけ
/*
==シェレクションソート(Shellection Sort)========================================================================
最善計算速度(Best)    :?
平均計算速度(Average)    :?
最悪計算速度(Worst)    :?
メモリ使用量(Memory)    :O(n)
安定性(stable)        :No

シェルソートの変形版。
挿入ソートの代わりに、短縮選択ソートを使う。

Shell SortとSelection SortのマッシュアップでShellection Sort
っていうダジャレがやりたかったので作ったソート。
シェルソートの方が速いので、使い道はほぼ無い。
*/
static public function shellectionSort( arr:Array ):Log{
    var log:Log = new Log( arr );
    var l:int = arr.length, inc:int = 1;
    while ( inc < (l) ) inc = (inc * 3) + 1;
    while ( (inc = (inc - 1) / 3) > 0 ) 
        for ( var s:int = 0, js:Vector.<int> = new <int>[]; s < inc; s++ ) 
            for ( var l2:int = l,  jl:int, i:int = s, j:int = s + inc; l2 > 0; l2 -= inc ){
                for ( ; j < l2; j += inc )
                    if ( log.compare(i, j) ) { js.push(j), i = j; }
                log.swap( i, j - inc ), log.next();
                if ( (jl = js.length) ) {
                    j = js.pop();
                    if ( jl > 1 ) { i = js[ jl - 2 ]; }
                    else{ i = s }
                }else { j = s + inc, i = s; }
            }
    return log;
}
//==解説終わり==================================================================================
}





class ArrayUtil {
    static public function copy( arr:Array ):Array {
        var a:Array = [];
        for ( var i:String in arr ) { a[i] = arr[i]; }
        return a;
    }
}

class Log {
    public var step:int = 0;
    public var last:int = 0;
    public var compareLog:Array = [ [] ];
    public var moveLog:Array = [ [] ];
    private var arr:Array; 
    function Log( arr:Array ):void { this.arr = arr; }
    public function compare( a:int, b:int ):Boolean {
        compareLog[ step ].push( [ a, b ] );
        return arr[a] <= arr[b]
    }
    public function swap(  a:int, b:int  ):void {
        if ( a == b ) { return; }
        move( a, b );
        move( b, a );
        var temp:* = arr[a];
        arr[a] = arr[b]; 
        arr[b] = temp;
    }
    public function insert( a:int, b:int ):void {
        if ( a == b ) { return; }
        var e:* = arr[a];
        for (var k:int = a; k > b; k-- ) { move( k - 1, k ); arr[k] = arr[k - 1]; }
        move( a, b ); 
        arr[b] = e;
    }
    public function move( a:int, b:int ):void {
        if ( a == b ) { return; }
        moveLog[ step ].push( [ a, b ] );
    }
    public function rotate( ...nums ):void {
        var l:int = nums.length; 
        if ( l < 2 ) { return; }
        var e:* = arr[ nums[l-1] ];
        for (var k:int = l - 1; k > 0; k-- ) { move( nums[k-1], nums[k] ); arr[nums[k]] = arr[nums[k-1]]; }
        move( nums[l-1], nums[0] ); 
        arr[nums[0]] = e;
    }
    public function next():void {
        step++;
        last++;
        moveLog.push([]);
        compareLog.push([]);
    }
}

import org.papervision3d.view.BasicView;
import org.papervision3d.objects.primitives.Cylinder;
import org.libspark.ukiuki.Ukiuki;
import org.libspark.ukiuki.ease.Sine;
import org.libspark.ukiuki.ease.Back;
class SortVisualizer extends BasicView{
    public var running:Boolean = false;
    public var speed:int = 0;
    public var tween:int = 0;
    public var bars:Array = [];
    public var xs:Array = [];
    public var log:Log;
    public var onFinish:Function;
    public var onChange:Function;
    public var compareCount:int;
    public var moveCount:int;
    private    var light:PointLight3D = new PointLight3D();
    static public const WIDTH:int = 1400;
    static public const HEIGHT:int = 1200;
    static public const MAX_SPEED:int = 40;
    function SortVisualizer() {
        super( 465, 465, false );
        camera.z = -2500;
        camera.y = 2000;
        camera.zoom = 100;
        light.y = 10;
        light.z = -500; 
        opaqueBackground = false;
        scene.addChild( light )
        addEventListener( Event.ENTER_FRAME, enterFrame );
    }
    public function setup( count:int ):void{
        Ukiuki.synchro = this.stage;
        var bar:Bar;
        while( bars.length > 0 ) { 
            bar = bars.pop();
            scene.removeChild( bar.object );
        }
        var w:int = WIDTH / (count);
        var h:int = HEIGHT / (count);
        xs = [];
        for ( var i:int = 0; i < count; i++ ) {
            bar = new Bar;
            bar.value = i;
            bar.color = Color.COLOR1;
            bar.object = new Cylinder( new GouraudMaterial( light, bar.color, 0, 0  ), w *0.45, (i+1) * h, 4, 1, -1, true, false );
            bar.object.y = (i * h - HEIGHT) / 2 - 200;
            xs[i] = bar.object.x = (i*w) - ((WIDTH-w) / 2);
            bars.push( bar );
            scene.addChild( bar.object );
        }
        singleRender();
    }
    public function play( log:Log ):void {
        running = true;
        moveCount = 0;
        compareCount = 0;
        this.log = log;
        this.log.step = 0;
        if ( onChange != null ) { onChange(); }
    }
    public function enterFrame( e:Event ):void {
        if( !tween && speed > 0 ){
            if ( running ) {
                var time:int = MAX_SPEED - speed;
                if ( log.step > log.last ) { 
                    running = false;
                    _draw();
                    if (onFinish != null ) { onFinish(); }
                }else{
                    var comp:Array = log.compareLog[log.step];
                    var c:Array = comp.shift();
                    if ( c ) {
                        this.compareCount++;
                        for ( var i:int = 0; i < 2; i++ ){
                            bar = bars[ c[i] ]
                            bar.color = Color[ "COLOR" + (3+i) ];
                            if ( time ) {
                                if ( bar.selected ) {
                                    Ukiuki.yoyo( bar.object, { y:bar.object.y + 20 }, { time:time, ease:Sine.OUT, onRemove:_onRemove } );
                                }else{
                                    bar.selected = true;
                                    Ukiuki.tween( bar.object, { y:bar.object.y + 40 }, { time:2*time, ease:Back.OUT, onRemove:_onRemove } );
                                }
                                tween++;
                            }
                        }
                        _draw();
                        singleRender();
                        return;
                    }
                    
                    var move:Array = log.moveLog[log.step];
                    var m:Array = move.pop();
                    var to:Array = [];
                    if( m ){    
                        do{
                            this.moveCount++;
                            bar = bars[ m[0] ]
                            bar.color = Color.COLOR2;
                            if (! time ) {
                                bar.object.x = xs[ m[1] ];
                            }else {
                                var r:int = bar.object.x - xs[ m[1] ];
                                Ukiuki.tween( bar.object, { x:xs[ m[1] ] }, { time:time * 4, ease:Sine.IN_OUT, onRemove:_onRemove } );
                                Ukiuki.yoyo( bar.object, { z: -r }, { time:time * 2, ease:Sine.OUT } );
                                tween++;
                            }
                            to[ m[1] ] = bar;
                        }while( m = move.pop() ) 
                        for ( var str:String in to ) { bars[str] = to[ str ]; }
                        _draw();
                        singleRender();
                        return;
                    }
                    log.step++;
                    _draw();
                }
            }            
            for each( var bar:Bar in bars ) {
                if ( bar.selected == true ) {
                    bar.selected = false;
                    Ukiuki.tween( bar.object, { y:bar.object.y - 40 }, { time:time*2, ease:Sine.OUT, onRemove:_onRemove } );
                    tween++;
                }
                bar.color = Color.COLOR1;
            }
        }
        singleRender();
    }
    private function _draw():void { 
        for each( var bar:Bar in bars ) bar.object.material = new GouraudMaterial( light, bar.color );
        if ( onChange != null ) { onChange(); }
    }
    private function _onRemove():void { tween-- }
    public function getArray():Array {
        var a:Array = [];
        for ( var i:int = 0, l:int = bars.length; i < l;  i++ ) {　a[i] = bars[i].value;　}
        return a;
    }
}

class Bar {
    public var object:DisplayObject3D;
    public var value:int;
    public var color:uint;
    public var selected:Boolean = false;
}

//コンボボックスのバグ対策
import com.bit101.components.ComboBox;
class ComboBox2 extends ComboBox{
    function ComboBox2( parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, defaultLabel:String = "", items:Array = null ){ 
        super( parent, xpos, ypos, defaultLabel, items)
        _numVisibleItems = 19;
    }
}
class Color {
    //Quick colors
    static public const COLOR1:uint = 0x399977;
    static public const COLOR2:uint = 0xE5A51B;
    static public const COLOR3:uint = 0xF27B29;
    static public const COLOR4:uint = 0xE8574C;
    static public const COLOR5:uint = 0xD9CC3C;
}