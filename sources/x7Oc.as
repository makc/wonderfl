// forked from tepe's 構文解析
//ソースコードの構造を解析する

//ソースコードをStringで受け取り、トークン列として返す
//トークン列をステップ単位で管理する。ステップは「;」と「}」で区切りリストにする
//ステップのツリー構造を抽出する。「{}」内に含まれるステップリストを取得する

//予定
//含まれる要素(クラス、メソッド、変数、定数)を抽出する
//要素への参照箇所、代入箇所を抽出する
//ツリー側で変更した内容をソースコード側に反映する

package {
    import flash.display.*;
    import flash.text.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;
    import net.hires.debug.Stats;
    


    public class FlashTest extends Sprite {
        private var t1:TextField = new TextField();//原文
        private var t2:TextField = new TextField();
        private var t3:TextField = new TextField();
        private var mw:msgWindow = new msgWindow();//メッセージウィンドウ
        
        private var ui:TreeUI = new TreeUI();
        
        private var so : SharedObject;
        public function FlashTest() {
            

            init();
            onChange(null);

        }
        
       private var dic:Dictionary = new Dictionary();
        
        //ステップのツリー構造を視覚化する
        private function f5(b:Block):TreeNode{
            var node:TreeNode = new TreeNode();
            dic[node] = b;
            //表示文字列       
            if(b.head==null){
                //return null;// node.name=b.body;
                
                var t:Token = b.start;
                if(t.text == "public"){
                    t = t.next;
                    t = t.next;
                    t = t.next;
                    t = t.next;
                }
                if(t.text == "private"){
                    t = t.next;
                    t = t.next;
                    t = t.next;
                    t = t.next;
                }

                //node.name=b.head + " ["+b.length.toString()+"]";
                node.name=t.text;
                
            }

            else{ 
                
                var t:Token = b.start;
                if(t.text == "public"){
                    t = t.next;
                    t = t.next;
                    t = t.next;
                    t = t.next;
                }
                if(t.text == "private"){
                    t = t.next;
                    t = t.next;
                    t = t.next;
                    t = t.next;
                }

                //node.name=b.head + " ["+b.length.toString()+"]";
                node.name=t.text + " ["+b.length.toString()+"]";
            }
            
            //さらに下の階層
            for(var i:int=0;i<b.length;i++){ 
                if(b.getStep(i).head==null){ 
                    node.createNode(b.getStep(i).body);
                }
                else{
                    node.addNode( f5(b.getStep(i)) );
                }
            }
            return node;
        }
        
        //キーワードを探す 同じキーワード同士を結ぶ
        private function f6(b:Block,obj:Object=null):Object{
            var result:Object;
            if(obj==null)result = new Object();
            else result=obj;
            var cToken:Token = b.start;
            //t3.appendText("f6----\n");
            while(cToken!=null){
                
                if(cToken.type!=Token.WORD){
                    cToken=cToken.next;
                    if(cToken==b.end)break;
                    continue;
                }
                var str:String = cToken.text;
                //t3.appendText(str+"--\n");
                
                if(!result.hasOwnProperty(str)){//新しく現れたキーワード 
                    var list:Array = new Array();
                    list.push(cToken);
                    result[str] = list;
                }
                else{//１回以上現れたキーワード
                    result[str].push(cToken);//(n+1) as int;
                }


                cToken=cToken.next;
                if(cToken==b.end)break;
            }


            
            return result;
        }
        
        
 
        private function init():void{
            //原文テキスト入力ボックス
            t1.border = true;
            t1.width = 230;
            t1.height = 360;
            t1.y=100;
            t1.type = "input";
            t1.multiline = true;
            so = SharedObject.getLocal("data");
            if(so){ 
                if(so.data.text != null){
                    t1.text = so.data.text;
                }
                else{    
                    t1.text "";
                    so.data.text = t1.text;
                }
            }
            addChild(t1);
            t1.addEventListener(Event.CHANGE,onChange);
            t2.type ="input";
            t2.x = 230;
            t2.width=330;
            t2.height=460;
            t2.wordWrap =true;
            t2.multiline=true;
            t2.border = true;
            //addChild(t2);
            var panel:WindowPanel = new WindowPanel(t2);
            addChild(panel);
            
            t3.border = true;
            t3.multiline= true;
            t3.text = "test\n";
            t3.x = 100;
            addChild(t3);
            addChild(ui);
            
            var node:TreeNode = new TreeNode();
            node.name="test";
            node.createNode("test2");
            ui.node = node;
            ui.render();
            
            mw.x = 0;
            mw.y = 465-128;
            
        }
        
        
        private var tk:Tokenizer;
        private function onChange(e:Event=null):void{//ソースコードに変更が加えられたら
            tk = new Tokenizer();
            tk.addEventListener(Event.COMPLETE,onComplete);
            //進捗率の表示
            tk.addEventListener(ProgressEvent.PROGRESS,function(e:ProgressEvent):void{
                t2.text = Math.round(100*e.bytesLoaded/e.bytesTotal).toString()+"%";
            });

            tk.createToken(t1.text);
            //var cnt:int=0;
            t2.text = "";
        }
        
        
        
        //ステップリストとスコープリストの生成
        private function onComplete(e:Event):void{
            t2.text = "onComplete";
            
            var bList:Vector.<Block> = getTree(tk.getToken());
            var b:Block;
            var i:int;
            var bufStr:String = new String();

            //階層を視覚化
            var tree:TreeNode = new TreeNode();
            
            
            tree.name = "source";
            t3.appendText("blist.length: "+bList.length.toString()+"\n");
            for(i=0;i<bList.length;i++){
                //f4(bList[i]);
                var tree2:TreeNode = f5(bList[i]);
                if(tree2==null)continue;
                tree.addNode(tree2);
            }
            
            //階層の中身表示
            ui.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void{
                if(e.target.parent is TreeNodeUI){
                    
                    var key:* = e.target.parent.node;
                    var tb:* = dic[key];
                    if(tb != null){                                                 
                        t2.text = tb.text;
                    }
                    //else t2.text = e.target.parent.node.name;
                }
                //t2.appendText(e.target.toString());

            });
            //階層の中身表示
            ui.addEventListener(MouseEvent.MOUSE_OVER,function(e:MouseEvent):void{
                if(e.target.parent is TreeNodeUI){
                    
                    var key:* = e.target.parent.node;
                    var tb:* = dic[key];
                    if(tb != null){                                                 
                        mw.text = tb.text;
                        mw.show();
                        
                        if(stage.mouseY<200){//画面下に表示
                            mw.x = 0;
                            mw.y = 465-128;
                        }
                        else{//画面上に表示
                            mw.x = 0;
                            mw.y = 0;
                        }


                        addChild(mw);
                    }
                    //else t2.text = e.target.parent.node.name;
                }
                //t2.appendText(e.target.toString());

            });
            ui.addEventListener(MouseEvent.MOUSE_OUT,function(e:MouseEvent):void{
                if(e.target.parent is TreeNodeUI){
                    
                    var key:* = e.target.parent.node;
                    var tb:* = dic[key];
                    if(tb != null){                                                 
                        mw.hide();
                        removeChild(mw);
                    }
                    //else t2.text = e.target.parent.node.name;
                }
                //t2.appendText(e.target.toString());

            });
            
            ui.node = tree;
            ui.render();
            


            t2.text = bufStr;
            so.data.text = t1.text;
            t3.text = "onComplete---\n";
            
            var obj:Object = new Object();
            for(i=0;i<bList.length;i++){    
                obj = f6(bList[i],obj);
            }
            for(var str:String in obj){
                t3.appendText(str+" @ ");
                t3.appendText(obj[str].length.toString()+"\n");
                /*var ar:Array = obj[str];
                if(ar==null)t3.appendText("\n");
                else t3.appendText(" @ "+ar.length.toString()+"\n");
                */
            }

            
        }//function
        
        //パンくずリスト
        private function f3(block:Block):String{
            var b:Block = block.parent;
            var buf:Vector.<String> = new Vector.<String>;
            while(b != null){
                buf.push(b.head);
                b=b.parent;
            }   
            var treeStr:String = new String();
            for(var i:int=1;i<=buf.length;i++){//階層の表示
                treeStr+=">> "+buf[buf.length-i]+"";
            }
            
            return treeStr;
        }
        

        
        private function f2(b:Block):String{
            var str:String = new String();
            var tab:String = new String();
            for(var j:int=0;j<b.rootsNum;j++)tab+="  ";

            str = tab+"-- "+ b.rootsNum.toString()+"-"+b.stepNum.toString()+"  --\n";
            
            if(b.head==null)str += tab+b.body+"\n";
            else{ 
                str += tab + b.head+"{@\n";
                str += tab + b.length.toString()+"step\n";
                for(var i:int=0;i<b.length;i++){
                    str += tab + f2(b.getStep(i))+"\n";
                }
                str += tab+"@}//"+b.head+"\n\n";
            }
            return str;
        }

        //記号の中から演算子を探す
        //ブロックにスコープ範囲とステップ範囲を割り当てる
        //ブロックに親子関係を割り当てる
        public function getTree(t:Token):Vector.<Block>{
            
            var bStack:Vector.<Block> = new Vector.<Block>;//階層を保持する
            var parent:Block;
            var bList:Vector.<Block> = new Vector.<Block>;
            var start:Token = t;//開始位置のトークン
            var startStack:Vector.<Token> = new Vector.<Token>; 
            
            var errNum:int;
            
            var cToken:Token = t;//tk.getToken();
            while(cToken!=null){//無限ループ注意
                //記号の処理
                if(cToken.type != Token.MARK){//トークンが記号以外なら次のトークンへ
                    cToken = cToken.next;
                    continue;
                }                
                var s:String = cToken.text;//トークンの文字列
                if(s == ";"){ //１ステップ
                    var b1:Block = new Block();
                    b1.setArea(start,cToken);//開始位置と終了位置を登録
                    if(parent!=null){ 
                        errNum = parent.addStep(b1);//ステップ追加
                        //t3.appendText("#errNum:"+errNum.toString()+"\n");
                    }
                    else{
                        b1.stepNum=bList.length;
                        bList.push(b1);
                    }
                    
                    start = cToken.next;//開始位置のトークン更新
                }
                else if(s=="{"){ //スコープ開始 
                    cToken.type = Token.SCOPE;
                    var b2:Block = new Block();
                    b2.setArea(start);//開始位置だけ登録
                    b2.parent = parent;//親を登録
                    if(parent!=null)errNum = parent.addStep(b2);//カレントスコープにステップ追加
                    //t3.appendText("#errNum:"+errNum.toString()+"\n");
                    bStack.push(b2); //階層
                    parent = b2;//カレントスコープ更新
                    
                    start = cToken.next;
                    //t3.appendText(cToken.next.text+"\n");
                }
                else if(s=="}"){//スコープ終了
                    cToken.type = Token.SCOPE;
                    var b3:Block = bStack.pop();
                    b3.setArea(b3.start,cToken);//開始位置と終了位置を登録
                    parent = b3.parent;
                    if(parent==null){ 
                        b3.stepNum = bList.length;
                        bList.push(b3);
                    }
                    else{
                        //bList.push(b3);
                    }

                    start = cToken.next;//スタート位置更新
                }
                else if(s == "("){ 
                    startStack.push(start);
                    start = cToken.next;//開始位置更新
                    cToken.type = Token.SCOPE;
                }
                else if(s == ")"){ 
                    start = startStack.pop();//開始位置更新
                    cToken.type = Token.SCOPE;
                    //if(start.text!="(")return null;//エラー
                }
                else if(s == "="){ //代入
                    //算術演算子
                    if(cToken.prev.text=="+"){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    else if(cToken.prev.text=="-"){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    else if(cToken.prev.text=="*"){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    else if(cToken.prev.text=="/"){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    else if(cToken.prev.text=="%"){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    //比較演算子
                    else if(cToken.prev.text=="="){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    else if(cToken.prev.text=="!"){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    else if(cToken.prev.text=="<"){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    else if(cToken.prev.text==">"){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    //ビット演算子
                    else if(cToken.prev.text=="&"){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    else if(cToken.prev.text=="|"){
                        cToken = cToken.prev.addToken(cToken);
                    }
                    else if(cToken.prev.text=="^"){
                        cToken = cToken.prev.addToken(cToken);
                    }

                    cToken.type = Token.OPERATOR;
                    
                }
                else if(s == "!")cToken.type = Token.OPERATOR;
                else if(s == "+"){ 
                    if(cToken.prev.text=="+"){//インクリメント
                        cToken = cToken.prev.addToken(cToken);
                    }
                    cToken.type = Token.OPERATOR;
                }
                else if(s == "-"){ 
                    if(cToken.prev.text=="-"){//デクリメント
                        cToken = cToken.prev.addToken(cToken);
                    }
                    cToken.type = Token.OPERATOR;
                }
                else if(s == "*")cToken.type = Token.OPERATOR;
                else if(s == "/")cToken.type = Token.OPERATOR;
                else if(s == "%")cToken.type = Token.OPERATOR;
                else if(s == "&"){ 
                    if(cToken.prev.text=="&"){
                        cToken = cToken.prev.addToken(cToken);
                        t3.appendText("addToken &&\n");
                    }
                    cToken.type = Token.OPERATOR;
                }
                else if(s == "|"){ 
                    if(cToken.prev.text=="|"){
                        cToken = cToken.prev.addToken(cToken);
                        t3.appendText("addToken ||\n");
                    }
                    cToken.type = Token.OPERATOR;
                }
                else if(s == "^")cToken.type = Token.OPERATOR;
                else if(s == "~")cToken.type = Token.OPERATOR;
                else if(s == "?")cToken.type = Token.OPERATOR;
                else if(s == "<"){ 
                    while(cToken.next.text=="<"){//シフト演算
                        cToken.addToken(cToken.next);
                    }
                    cToken.type = Token.OPERATOR;
                }
                else if(s == ">"){ 
                    while(cToken.next.text==">"){//シフト演算
                        cToken.addToken(cToken.next);
                    }
                    cToken.type = Token.OPERATOR;
                }
                
                if(cToken.type == Token.OPERATOR){
                    t3.appendText(cToken.text+" "+cToken.id.toString()+"\n");
                }

                cToken = cToken.next;
            }//while
            
            return bList;
        }//function
        
    }//class
}//package


//======== Token ===================================================================

import flash.events.ProgressEvent;

//トークンオブジェクト
class Token{
    private static var idCnt:int;
    private var tokenId:int;
    private var _text:String;//文字列
    public var type:int;//タイプ
    //public var lineNum:int;//属するプロセスライン
    
    //トークンの並びを保持する
    public var next:Token;
    public var prev:Token;
    public static const ERROR:int = -1;//エラー
    public static const SPACE:int = 0;//スペース
    public static const COMMENT:int = 1;//コメント 
    public static const NUMBER:int = 2;//数値
    public static const WORD:int = 3;//識別子
    public static const TEXT:int = 4;//文字列
    public static const MARK:int = 5;//記号
    public static const OTHER:int = 6;//その他（マルチバイトの文字列)
    public static const SCOPE:int = 7;//スコープの置き換え
    public static const OPERATOR:int = 8;//演算子
    public static const EOF:int = 9;//EOF
    
    public function Token(){
        idCnt++;
        tokenId = idCnt;
    }
    public function get id():int{
        return tokenId;
    }
    public function set text(str:String):void{
        _text = new String();
        _text += str;
        
    }
    public function get text():String{
        return _text;
    }
    //トークンを結合する
    public function addToken(t:Token):Token{
        _text+=t.text;
        next = t.next;
        idCnt++;
        tokenId = idCnt;
        return this;
    }


}


//========  TokenPoint  ===============================================================


//トークンの移動操作をする
class TokenPoint{
    private var _current:Token;
    private var _start:Token;
    private var _end:Token;
    public function TokenPoint(t:Token,s:Token=null,e:Token=null){
        _current = t;
        _start = s;
        _end = e;
        
    }
    public function get getPos():Token{
        return _current;
    }

    public function movNext():int{//移動量を返す
        if(_current.next==null)return 0;
        _current = _current.next;
        return 1;
    }
    public function movPrev():int{
        if(_current.prev==null)return 0;
        _current = _current.prev;
        return -1;
    }
    //指定されたタイプの位置まで移動
    public function movNextType(type:int,end:Token=null):int{ 
        var cnt:int=0;
        var t:Token = _current;
        while(t.type!=type){ 
            if(t==null)return 0;
            if(t==end)return 0;
            t=t.next;
            cnt++;
        }
        _current = t;
        return cnt;
    }
    
    public function movPrevType(type:int,end:Token=null):int{
        var cnt:int=0;
        var t:Token = _current;
        while(t.type!=type){
            if(t==null)return 0;
            if(t==end)return 0;
            t=t.prev;
            cnt--;
        }
        _current = t;
        return cnt;

    }
    //指定された文字列の位置まで移動
    public function movNextText(text:String,end:Token=null):int{
        var cnt:int=0;
        var t:Token = _current;
        while(t.text != text){
            if(t==null)return 0;
            if(t==end)return 0;
            t=t.next;
            cnt++;
        }
        _current = t;
        return cnt;

    }
    
    public function movPrevText(text:String,end:Token=null):int{
        var cnt:int=0;
        var t:Token = _current;
        while(t.text != text){
            if(t==null)return 0;
            if(t==end)return 0;
            t=t.prev;
            cnt--;
        }
        _current = t;
        return cnt;
    }
}


//=======  Block  ================================================================


//ステップ、スコープを扱う
class Block{ 
    private static var idCnt:int;
    private var _id:int;//識別値
    private var _stepNum:int = -1;//スコープ内でのステップ番号
    private var _rootsNum:int;//階層の深度
    private var _name:String;
    private var _text:String;//ブロック全体の文字列
    private var _head:String;//スコープ前の要素
    private var _body:String;//スコープの中身
    public var list:Vector.<Block>;
    
    private var _next:Block;
    private var _prev:Block;
    private var _parent:Block;
    private var _child:Block;//スコープ内の先頭ステップ
    
    private var _startToken:Token;
    private var _endToken:Token;
    private var _entryToken:Token;//スコープ入口。ない場合はnull
    public function Block(){
        idCnt++;
        _id=idCnt;
    }
    //ID取得
    public function get id():int{
        return _id;
    }
    //スコープ内のステップ数取得
    public function get length():int{
        if(list==null)return 0;
        return list.length;
    }
    
    //先頭からの順番
    public function get stepNum():int{
        if(_stepNum != -1)return _stepNum;
        var b:Block = this.prev;
        var cnt:int=0;
        while(b!=null){
            cnt++;
            b = b.prev;
        }
        _stepNum=cnt;

        return _stepNum;
    }
    
    public function set stepNum(n:int):void{ 
        if(_stepNum != -1)return;//未設定の場合のみ設定可能
        _stepNum=n;
    }
    
    
    //階層
    public function get rootsNum():int{ 
        return _rootsNum;
    }



    
    //スコープ内の任意のステップ取得
    public function getStep(n:int):Block{ 
        if(list==null)return null;
        return list[n];
    }

    //スコープ内にステップ追加
    public function addStep(block:Block):int{
        if(block==null)return -1;
        if(list == null)list = new Vector.<Block>;
        block.parent = this;
        list.push(block);
        
        var len:int = list.length;
        
        if(1<len){ 
            list[len-1].prev = list[len-2];
            list[len-2].next = list[len-1];
        }
        else _child = list[0];
        
        return len;
    }
    
    public function get start():Token{
        return _startToken;
    }
    public function get end():Token{
        return _endToken;
    }


    public function get next():Block{//次の要素
        return _next;
    }
    public function get prev():Block{//前の要素
        return _prev;
    }
    public function get parent():Block{//上の階層
        return _parent;
    }
    
    public function get stepIn():Block{//下の階層の先頭ステップ
        return _child;
    }
    
    public function get stepOver():Block{//次のステップ
        return _next;
    }
    public function get stepOut():Block{//現在の階層を出て次のステップ
        var p:Block = _parent;
        return p.stepOver;
    }


    
    public function set next(b:Block):void{ 
        if(_next == b)return;
        _next=b;
        if(_next==null)return;
        if(_next.prev.id!=this.id)_next.prev = this;
    }
    
    public function set prev(b:Block):void{ 
        _prev=b;
    }
    
    public function set parent(b:Block):void{
        _parent=b;
        var cnt:int=0;
        var b:Block =this;
        while(b.parent != null){
            b = b.parent;
            cnt++;
        }
        _rootsNum = cnt;
    }
    
    //トークン列の中から開始要素と終了要素を指定
    public function setArea(start:Token,end:Token=null):int{ 
        _text=null;
        _head=null;
        _body=null;
        
        _startToken = start;//開始位置のトークン登録
        //先頭がスペースかコメントなら詰める
        while(_startToken.type == Token.SPACE || _startToken.type == Token.COMMENT)_startToken = _startToken.next;
        
        _endToken = end;//終了位置のトークン登録
        
        if(end==null)return 3;//未完了
        
        /*
        if(_startToken.prev==null){//ルート
            if(_endToken.next==null)return 0;
        }*/

        
        if(_endToken.text ==";")return 1;//ステップ
        
        if(_endToken.text =="}"){ //スコープの有無を確認
            var t:Token = _startToken;
            var tp:TokenPoint = new TokenPoint(_startToken);
            if(tp.movNextText("{")==0)return -1;
            _entryToken = tp.getPos;//スコープ入口
            return 2;
        }
        return -1;

    }
//-------------------------------------------------------------
    //テキスト取得
    public function get text():String{ 
        if(_text!=null)return _text;
        _text = new String();
        var t:Token = _startToken;
        while(t.next != null){
            if(t.type != Token.SPACE)_text += t.text;
            else{
                //改行を探す
                //if(t.text.indexOf("\r") != -1)_text += "\r";//インデント追加処理を入れたい
                //else _text += " ";
                _text += t.text;
            }

            if(t.id == _endToken.id)break;
            t = t.next;
        }
        return _text;
    }
    
    public function get name():String{
        if(_name!=null)return _name;
        if(_entryToken==null)return null;
        
        var t:Token = _entryToken;
        var st:Token = _startToken;
        var cnt:int=0;
        //func(  [)]  :***{　このカッコの位置まで移動
        var tp:TokenPoint = new TokenPoint(_startToken);
        if(tp.movNextText("(")!=0){
            tp.movPrevType(Token.WORD);
        }

        t = _startToken;
        while(t!=null){ 
            if(t.text=="(")break;
            if(t.id==_entryToken.id)break;
            t = t.next;
            cnt++;
        }
        for(var i:int=0;i<cnt;i++){
            t=t.prev;
            if(t.type==Token.WORD)break;
        }
        
        _name=t.text;
        return _name;

    }

    //スコープの前。条件式、クラス名、メソッド名
    public function get head():String{
        if(_entryToken==null)return null;
        if(_head!=null)return _head;
        _head = new String();
        var t:Token = _startToken;
        while(t.type==Token.SPACE || t.type==Token.COMMENT)t = t.next;//スペース、コメント除外
        while(t.next != null){
            _head += t.text;
            if(t.next.id == _entryToken.id)break;
            t = t.next;
        }
        return _head;

    }
    //スコープの中。スコープは含まない
    public function get body():String{ 
        if(_body!=null)return _body;
        _body = new String();
        var t:Token;
        
        if(_entryToken==null){ 
            t = _startToken;
            while(t.type==Token.SPACE || t.type==Token.COMMENT)t = t.next;//スペース、コメント除外
            while(t.next != null){
                _body += t.text;
                if(t.id == _endToken.id)break;
                t = t.next;
            }
            return _body;
        }
        t = _entryToken;
        while(t.next != null){
            _body += t.text;
            if(t.id == _endToken.id)break;
            t = t.next;
        }
        return _body;
    }

    

}




//======= Thread ==========================================================================


import flash.utils.*;
import flash.events.*;
    
class Thread extends Timer{ 
    static public var SPAN:Number = 1000/30; 
    static public var RATE:Number = 0.5;
    public var end:Boolean = false;
    public var currentLoop:Loop = null;
    
    static private var NUM:int = 0;
    private var _limit:Number = 5;
    private var _time:int = 0;
    private var _added:Boolean;
    private var currentLoops:Vector.<Loop>;
    private var loops:Vector.<Loop> = new Vector.<Loop>();
    
    public function Thread(){
        super(SPAN); start(); NUM++;
        addEventListener( "timer", onFrame  );
    }
        
    public function loop( func:Function, onComplete:Function = null):void{
        var loop:Loop = new Loop( func, currentLoop );     
        if( currentLoop == null ){ loops.push( loop );
        }else{ currentLoop.loops.push( loop ); _added = true }
        if( onComplete != null ){
            loop = new Loop( onComplete, currentLoop );   
            if( currentLoop == null ){ loops.push( loop );
            }else{ currentLoop.loops.push( loop ); }
        }
    }
        
    public function remove():void{
        NUM--; stop(); end = true;
        removeEventListener( "timer", onFrame  );
    }
        
    private function onFrame(e:Event):void{
        _time = getTimer(); _limit = (SPAN * RATE) / NUM;
        all: while(true){
            if( currentLoop == null ){
                currentLoops = loops;
                if( loops.length == 0 ){ remove(); break; }
                while( currentLoops[0].loops.length != 0 ){ currentLoops = currentLoops[0].loops;  }
                currentLoop = currentLoops[0];
            }
            do{
                if( _limit < (getTimer() - _time)){ break all; }
                if( _added ){ _added = false; currentLoop = null; continue all;  }
            }while( currentLoop.func() )
            currentLoop = null;
            currentLoops.reverse(); currentLoops.pop(); currentLoops.reverse();
        }
    }
}





//====== Loop ============================================================================


class Loop extends Object{
    
    public var func:Function;
    public var name:String;
    public var parent:Loop;
    public var loops:Vector.<Loop> = new Vector.<Loop>();
    
    function Loop( func:Function, parent:Loop = null, name:String = "" ){  
        this.func = func;
        this.parent = parent;
    }
}


//=======================================================================================



//////////////////////////////////////////////////////////////////////////
//  トークン列取得
//////////////////////////////////////////////////////////////////////////



//テキストからトークンを抽出する
class Tokenizer extends Thread{
    private var blockList:Vector.<Block>;
    private var tokenList:Vector.<Token>;
    //private var scopeList:Array;
    private var _length:int;
    private var source:String;
    private var cansel:Boolean;
    public function Tokenizer(){
        
    }
    //スコープリストを生成する
    public function createScopeList():int{
        return 0;
    }

    public function getEof():Token{
        return getToken(length-1);
    }


    //指定インデクスからmax個までトークン抽出
    //抽出したトークンはlistに追加
    //抽出したところまでのインデクスを返す
    public function createToken(str:String):void{
        
        source = str;
        tokenList = new Vector.<Token>;
        index01 = 0;
         
        var i:int = 0;
        var cnt:int = 0;
        loop( function _while():Boolean{ 
            i= func01();
                
            if(cnt==0){//進捗率
                var e:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS,false,true,i,str.length);
                dispatchEvent(e);
            }
            cnt++;
            cnt%=500;
            if(i<str.length)return true;
            return false;
        },onComplete);
    }

    private function onComplete():void{
        addToken("",Token.EOF);//EOF追加
        _length = tokenList.length;
        var event:Event = new Event(Event.COMPLETE);
        dispatchEvent(event);
    }
    
    public function get length():int{
        return _length;
    }
    //先頭からの順を指定してトークンを取得
    public function getToken(index:int=0):Token{
        if(index<0 && tokenList.length<=index)return null;
        return tokenList[index];
    }
    
    //トークン列に追加
    private function addToken(str:String,type:int):int{
        var obj:Token = new Token();
        obj.text = str;
        obj.type = type;
        obj.next = null;
        tokenList.push(obj);
        if(1<tokenList.length){ 
            tokenList[tokenList.length-1].prev = tokenList[tokenList.length-2];
            tokenList[tokenList.length-2].next = tokenList[tokenList.length-1];
        }
        else tokenList[tokenList.length-1].prev = null;
        return tokenList.length;
    }



//-------------------------------------------------------------
    //開始インデクスを受け取りトークンのタイプを返す
    private var index01:int=0;
    private function func01():int{//
        if(index01 >= source.length)return source.length;
        var index:int = index01;
        var type:int;//トークンタイプ
        var str:String;//トークン文字列
        var reg:RegExp = new RegExp();                
        var result:Object;
        //トークンタイプ：空白か？
        if(    source.charAt(index)== " " ||
               source.charAt(index)=="\t" ||
               source.charAt(index)=="\n" ||
               source.charAt(index)=="\r" ){
                   type = Token.SPACE;
                   reg = /[^\s]/mg;
                   reg.lastIndex = index;
                   result = reg.exec(source);
                   //トークン作成
                   if(result == null){//
                       str = source.substring(index,source.length);
                       index01 = source.length;//次の開始位置
                   }
                   else{//
                       str = source.substring(index,result.index);
                       index01 = result.index;                       
                   }
                   addToken(str,type);
                   return index01;
                                       
               }

        
        //トークンタイプ:文字列定数１
        if(source.charAt(index)== "'"){
            type = Token.TEXT;
            var indexA:int = index;
            reg = /['\n\r]/mg;//改行か次の[']が現れる位置
            do{//エスケープ処理
                reg.lastIndex = indexA+1;
                result = reg.exec(source);
                if(result==null)break;
                else indexA = result.index;
            }while(source.charAt(indexA-1)=="\\");//["]が現れてもその前がエスケープなら再検索
            
            //トークン作成
            if(result == null){//エラー
                str = "'";
                type = Token.ERROR;
                index01 = index+1;//次の開始位置
            }
            else{//
                str = source.substring(index,result.index+1);
                index01 = result.index+1;//次の開始位置
            }
            addToken(str,type);
            return index01;
                
        }
 
        //トークンタイプ:文字列定数2
        if(source.charAt(index)== '"'){
            type = Token.TEXT;
            var indexB:int = index;
            reg = /["\n\r]/mg;//改行か次の["]が現れる位置
            do{//エスケープ処理
                reg.lastIndex = indexB+1;
                result = reg.exec(source);
                if(result==null)break;
                else indexB = result.index;
            }while(source.charAt(indexB-1)=="\\");//["]が現れてもその前がエスケープなら再検索
            
            //トークン作成
            if(result == null){//エラー
                str = '"';
                type = Token.ERROR;
                index01 = index+1;//次の開始位置
                
            }
            else{//
                str = source.substring(index,result.index+1);
                index01 = result.index+1;//次の開始位置
                
            }
            addToken(str,type);
            return index01;
        }
        
        if(source.charAt(index)== "/"){
               //一行コメント
               if(source.charAt(index+1)== "/"){//
                   reg = /[\n\r]/mg;
                   reg.lastIndex = index+2;
                   result = reg.exec(source);
                   //トークン作成
                   type = Token.COMMENT;
                   if(result == null){
                       str = source.substring(index,source.length);
                       index01 = source.length;//次の開始位置                       
                   }
                   else{// 
                       str = source.substring(index,result.index);
                       index01 = result.index;//次の開始位置
                   }
                   addToken(str,type);
                   return index01;
               }
               //複数行コメント
               if(source.charAt(index+1)== "*"){
                   reg = /\*\//mg;
                   reg.lastIndex = index+2;
                   result = reg.exec(source);
                   
                   //トークン作成
                   type = Token.COMMENT;
                   if(result == null){//エラー
                       type = Token.ERROR;
                       str = '/*';
                       index01 = index+2;//次の開始位置
                   }
                   else{//
                       str = source.substring(index,result.index+2);
                       index01 = result.index+2;//次の開始位置                       
                   }
                   addToken(str,type);
                   return index01;
               }
        }

        //英数字
        if((source.charCodeAt(index) > 64 && source.charCodeAt(index) < 91) ||// A-Z
           (source.charCodeAt(index) > 96 && source.charCodeAt(index) < 123)||// a-z
            source.charCodeAt(index) == 95 ){// _
                reg = /[^a-zA-Z0-9_]/mg;//英数字以外が現れる位置
                reg.lastIndex = index+1;
                result = reg.exec(source);
                type = Token.WORD;
                if(result == null){//eof
                    str = source.substring(index,source.length);
                    index01 = source.length;
                }
                else{//
                    str = source.substring(index,result.index);
                    index01 = result.index;//次の開始位置
                }
                addToken(str,type);
                return index01;
                
        }
        
        
        //数値
        if(source.charCodeAt(index) > 47 && source.charCodeAt(index) < 58){
            reg = /[^a-zA-Z0-9_.]/mg;
            reg.lastIndex = index+1;
            result = reg.exec(source);
            type = Token.NUMBER;
            if(result == null){//eof
                str = source.substring(index,source.length);
                index01 = source.length;
            }
            else{// 
                str = source.substring(index,result.index);
                index01 = result.index;//次の開始位置
            }
            //num();//種類判別
            addToken(str,type);
            return index01;

        }
        
        //半角記号
        if(source.charCodeAt(index)<127 && source.charCodeAt(index)>32){
            type = Token.MARK;
            str = source.charAt(index);
            index01 = index+1;
            
            addToken(str,type);
            return index01;
        }
        
    
        //その他文字列　マルチバイト文字等はここに入る
        type = Token.OTHER;
        reg = /[\x01-\x7f]/mg;
        reg.lastIndex = index+1;
        result = reg.exec(source);
        if(result == null){//eof
            str = source.substring(index,source.length);
            index01 = source.length;
        }
        else{// 
            str = source.substring(index,result.index);
            index01 = result.index;//次の開始位置
        }
        
        addToken(str,type);
        return index01;
    }
     
}//class



import flash.display.*;
import flash.events.*;
import flash.text.*;
class WindowPanel extends Sprite{
    private var _title:String = "";
    private var _mx:Number = 20;
    private var _my:Number = 10;
    private var _target:DisplayObject;
    private var _tf:TextField;
    public function WindowPanel(o:DisplayObject=null){
        if(o!=null)target=o;
        draw();
        this.addEventListener(MouseEvent.MOUSE_MOVE,onMove);
        this.addEventListener(MouseEvent.MOUSE_OUT,onOut);
        this.addEventListener(MouseEvent.MOUSE_DOWN,onDrag);
        this.addEventListener(MouseEvent.MOUSE_UP,onDrop);
    }
    public function set target(o:DisplayObject):void{
        _target = o;
        this.addChild(o);
        this.x = o.x;
        this.y = o.y;
        o.x=0;
        o.y=0;
        
        draw();
    }
    
    public function set title(t:String):void{
        _title = t;
        draw();
    }


    //タイトル表示
    private function initTF():void{
        _tf = new TextField();
        _tf.text = _title;
        _tf.y = -_my;
        _tf.selectable = false;
        _tf.width = _tf.textWidth+5;
        _tf.height = _tf.textHeight+5;
        this.addChild(_tf);
    }

    //ウィンドウ更新
    public function draw(c:uint=0xffffff,a:Number=0.8):void{
        initTF();
        var w:Number,h:Number;
        if(_target==null){w=this.width;h=this.height;}
        else{ 
            w=_target.width;h=_target.height;
            this.x += _target.x;
            this.y += _target.y;
            _target.x = 0;
            _target.y = 0;
        }
        
        this.graphics.clear();
        this.graphics.lineStyle(0,0x0,a);
        this.graphics.beginFill(c,a);
        this.graphics.drawRect(-_mx,-_my,w+_mx*2,h+_my*2);
        this.graphics.endFill();
    }
    
    private function onOut(e:MouseEvent):void{
        Mouse.cursor = MouseCursor.AUTO;
    }

    private function onMove(e:MouseEvent):void{
        if(e.target == this)Mouse.cursor = MouseCursor.HAND;
        else Mouse.cursor = MouseCursor.AUTO;
    }

        
    private function onDrag(e:MouseEvent):void{
        e.currentTarget.parent.setChildIndex(e.currentTarget, e.currentTarget.parent.numChildren-1); //並べ替え
        if(e.target == this){
            this.startDrag();
            //var s:DisplayObject = stage.getChildByName(e.currentTarget.name);//ディスプレイオブジェクト取得
            
        }
        draw();
        
        //this.startDrag();
    }
    private function onDrop(e:MouseEvent):void{
        this.stopDrag();
        draw();
    }
}


import flash.events.*;
import flash.text.*;
import flash.display.*;
import flash.geom.*;
import flash.ui.*;

    class TreeUI extends WindowPanel{
        
        
        private var rootTree:TreeNode = new TreeNode();
        private var treeUI:Sprite = new Sprite();
        private var pen:Pen = new Pen(treeUI.graphics,0x444444);
        public function TreeUI(){
            this.target = treeUI;
            rootTree.name="/"
            rootTree.closed = false;
            render();
        }
        
        public function set node(tree:TreeNode):void{
            rootTree = tree;
            render();
            
        }

        
        //描画処理
        public function render():void {
            treeUI.graphics.clear();
            while (treeUI.numChildren > 0) treeUI.removeChildAt(0);
            renderCell(rootTree, 0, 0);//ノード描画
            draw();
        }
        
        private function renderCell(tree:TreeNode, x:Number, y:Number):Number {
            var sy:Number = y;
            var tui:TreeNodeUI = new TreeNodeUI(tree, x, y,this);
            var h:Number = tui.height;
            treeUI.addChild(tui);
            
            y += h+5;
            if (!tree.closed) {//子リストの描画
                var n:Number = 10;
                var vx:Number = x + 7;
                var vy:Number = y;
                
                for each(var child:TreeNode in tree.list) {
                    //pen.moveTo(vx, y+10);
                    pen.moveTo(vx, y+n);
                    pen.lineTo(vx + 10, y + n);//横線
                    //vy = y+10;
                    vy = y+n;
                    y = renderCell(child, x + 20, y);//子リスト
                }
                if(0<tree.list.length){
                    pen.moveTo(vx, sy+15);
                    pen.lineTo(vx, vy);//縦線
                }
            }
            return y;
        }
    }
    



import com.bit101.components.PushButton;

class TreeNodeUI extends Sprite{
    public var node:TreeNode;
    public var treeUI:TreeUI;
    private var _minBtn:PushButton;
    private var tf:TextField;
    
    public function TreeNodeUI(node:TreeNode,x:Number,y:Number,main:TreeUI) {
        this.node = node;
        this.treeUI = main;
        
        
        tf = new TextField();
        tf.autoSize = "left";
        tf.text = node.name;
        tf.backgroundColor = 0xffffff;
        tf.addEventListener(MouseEvent.MOUSE_OVER,function():void{
            tf.border=true;
            tf.background = true;
        });
        tf.addEventListener(MouseEvent.MOUSE_OUT,function():void{
            tf.border=false;
            tf.background = false;
        });

        //tf.background =true;
        //tf.border=true;
        tf.selectable=false;

        addChild(tf);
        if(0<node.length){
            _minBtn = createMinBtn(); 
            addChild(_minBtn);
            tf.x = _minBtn.width+2;
        }
        
        this.x = x;
        this.y = y;
    }
    

    
    //最小化ボタン
    private function createMinBtn():PushButton {
        var result:PushButton = new PushButton(null, 0, 3, "+", minimize);
        result.width = result.height = 14; result.draw();
        result.addEventListener(MouseEvent.CLICK,minimize);
        result.label = (node.closed) ? "+" : "-"; 
        return result;
    }
    
    public function minimize(event:MouseEvent = null):void {
        node.closed = !node.closed;
        treeUI.render();
        if (_minBtn) { 
            _minBtn.label = (node.closed) ? "-" : "+"; 
        }
    }
    
}

class TreeNode {
    
    public static var ID:int = 0;
    public var parent:TreeNode;//親
    public var closed:Boolean = true;//展開状態
    public var name:String = "node" + (ID++);//表示名
    private var _children:Vector.<TreeNode>;//子リスト
    
    public function TreeNode(str:String=null){
        if(str!=null)name=str;
        _children= new Vector.<TreeNode>;
    }

    public function get length():int{
        return _children.length;
    }
    


    
    public function get list():Vector.<TreeNode>{
        //createChild();
        return _children;
    }
    
    //名前を指定してノード取得
    public function getNode(n:String=null):TreeNode{
        for(var i:int=0;i<_children.length;i++){
            if(_children[i].name==n)return _children[i];
        }
        return null;
    }


    //ノードを追加
    public function addNode(t:TreeNode):void{
        _children.push(t);
    }
    //ノード生成
    public function createNode(str:String):void{
        var node:TreeNode = new TreeNode(str);
        _children.push(node);
    }
    //パスを指定して生成する
    public function createPath(path:String):void{
        var ar:Array = path.split("/");
        var node:TreeNode = this;
        for(var i:int=0;i<ar.length;i++){
            
            //指定されたツリーが存在しなければ生成。存在すればそのまま
            if(node.getNode(ar[i])==null)node.createNode(ar[i]);
            node = node.getNode(ar[i]);
        }

    }



}

class Pen{
    
        private var g:Graphics;
        private var sx:Number;
        private var sy:Number;
        private var color:uint;
        public function Pen(g:Graphics,c:uint=0x000000){
            this.g = g;
            this.color = c;
        }
        public function moveTo(x:Number, y:Number):void {
            g.moveTo(x, y);
            sx = x;
            sy = y;
        }
        
        public function lineTo(x:Number, y:Number):void {
            g.lineStyle(0,color);
            g.lineTo(x, y);
            sx = x;
            sy = y;
        }
    }


import flash.display.*;
import flash.text.*;
import flash.events.*;

    class msgWindow extends Sprite{
        private var tf:TextField = new TextField();
        public var gt:int = 0;
     
        public var state:int = 0;
        public var cur:int = 0;//キャレット位置
        public var mt:Number = 0;
        public var msg:String = ""; 
        private var w:int=465;
        private var h:int=128;
        
        public function msgWindow(){
            tf.x = 8; tf.y = 8;
            tf.width = w-12; tf.height= h-8;
            tf.mouseEnabled = false;
            tf.wordWrap=true;
            tf.multiline=true;
            tf.textColor=0xffffff;
            tf.thickness=2;
            addChild(tf);
            addEventListener(Event.ENTER_FRAME,onFrame);
        }
        
        public function show():void{
            state = 1;
            addChild(tf);
            addEventListener(Event.ENTER_FRAME,onFrame);
        }
        public function hide():void{
            state = 0;
        }


        
        public function set text(str:String):void{
            msg = str;
            cur = 0;
        }
        public function get text():String{
            return msg;
        }

        //ウィンドウサイズ設定
        public function setSize(width:int,height:int):void{
            w=width;
            h=height;
            tf.width=w-12;
            tf.height=h-12;
        }


    
        private function onFrame(e:Event):void{
            graphics.clear();
            //状態１
             if (state == 1){
                 mt +=0.1;
                 if (mt > 1) {
                     mt=1;
                 }
                 if(cur<msg.length)cur+=2;//表示文字を進める
             }
             else {
                 mt -=0.1;
                 if (mt < 0){
                     mt=0; cur =0;
                     removeChild(tf);
                     removeEventListener(Event.ENTER_FRAME,onFrame);
                 }
             }             
            
            tf.alpha = mt;
            if (state == 1) {
                
                if(cur<msg.length)tf.text = msg.substr(0, cur) + "|";
                else tf.text = msg.substr(0, cur) + ((gt & 16) > 0 ? "_":"");//キャレット点滅
                tf.scrollV = tf.maxScrollV;
            }
            
            //ウィンドウ
            //graphics.lineStyle(3,0xffffff,mt);//RPG
            graphics.lineStyle();
            graphics.beginFill(0x000000,0.85*mt);
            graphics.drawRect(0,0,w,h);
            graphics.endFill();
            
            gt++;
        }


    }
