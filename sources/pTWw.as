/*
日経ソフトウエア2010年8月号の記事「スクリプト言語をゼロから作ろう」
で解説されていた「MIL」という言語の処理系をつくってみました。
■使い方
・エディタ部にMILのソースコードを入力
・Runボタンを押して実行
・チェックボックスがRun Bytecodeなら実行、Dump Assembly Code
にするとアセンブリコードを出力
■MILの仕様
・使用できるデータ型: 整数型と文字列型のみ
・制御構造: if文, if-else文, while文, goto文, gosub-return文
            goto, gosubのラベルには「*」をつける
            if文, if-else文, while文は{ }を省略できない
・出力: print文
・1行コメント: #から行末までコメント
・その他: 文の最後はセミコロン「;」が必要
■オリジナルの処理系(C言語)
http://itpro.nikkeibp.co.jp/article/MAG/20091120/340842/?ST=nsw#201008
*/
package {
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import com.bit101.components.*;

  /** MILのIDE */
  [SWF(backgroundColor="#cccccc")] 
  public class Main extends Sprite {
    private const SAMPLE_CODE:String = "# MILのサンプル\na = 10;\nb = (a + 100) * 10 / 2 - 20; # 算術演算は+, -, *, /のみ\nhello = \"Hello, world\"; # 文字列型のデータ\nprint(hello); # print文で文字列を出力\nprint(b);\n\ni = 0;\nwhile (i < 5) { # while文とif~else文は{ }を省略できない\n  if (i <= 2) {\n    print(\"foo\");\n  }\n  else {\n    print(\"bar\");\n  }\n  i = i + 1;\n}\n\ngoto *label; # goto文でラベルへジャンプする\nprint(\"これは出力されない\");\n\n*label\n  print(\"gotoでジャンプ！\");\n  gosub *fib; # gosub文でサブルーチンのラベルへジャンプする\n  print(\"returnで戻ってきました\");\n  goto *end;\n\n*fib # サブルーチン(フィボナッチ数列を計算)\n  f0 = 0;\n  f1 = 1;\n  f2 = 0;\n  print(f1);\n  while (1) {\n    f2 = f1 + f0;\n    if (f2 > 100) {\n      goto *ret;\n    }\n    print(f2);\n    f0 = f1;\n    f1 = f2;\n  }\n  *ret\n    return; # return文でサブルーチンから戻る\n\n*end\n";

    private var editorLabel:com.bit101.components.Label;
    private var stdoutLabel:com.bit101.components.Label;
    private var editor:TextArea;
    private var stdout:TextArea;
    private var button:PushButton;
    private var radio1:RadioButton;
    private var radio2:RadioButton;
    
    /** コンストラクタ */
    public function Main() {
      Style.embedFonts = false;
      Style.fontName = "_typewriter";
      editorLabel = new com.bit101.components.Label(this, 0, 5, "Editor");
      editor = new TextArea(this, 0, editorLabel.y + editorLabel.height);
      editor.width = 350;
      editor.height = 300;
      editor.text = SAMPLE_CODE;
      stdoutLabel = new com.bit101.components.Label(this, 0, editor.y + editor.height + 10, "Output");
      stdout = new TextArea(this, 0, stdoutLabel.y + stdoutLabel.height);
      stdout.width = editor.width;
      stdout.height = 100;
      button = new PushButton(this, editor.x + editor.width + 20, editor.y, "Run",
          function(e:MouseEvent):void {
            stdout.text = "";
            run(editor.text, radio2.selected);
          });
      button.width = 50;

      radio1 = new RadioButton(this, button.x, button.y + button.height + 20)
      radio1.label = "Run Bytecode";
      radio1.selected = true;
      radio2 = new RadioButton(this, radio1.x, radio1.y + radio1.height + 5);
      radio2.label = "Dump Assembly Code";
    }

    /**
    MILのコードを実行
    @param sourceCode ソースコード
    @param dumpAssemblyCodeMode trueならバイトコードを実行するかわりにアセンブリコードを出力
    */
    private function run(sourceCode:String, dumpAssemblyCodeMode:Boolean = false):void {
      try {
    var parser:Parser = new Parser(sourceCode);
    var mvm:Mvm = new Mvm(parser.bytecode, parser.strPool, function(msg:String):void {
        stdout.text += msg + "\n";
      });
    
    if (dumpAssemblyCodeMode) {
      stdout.text = mvm.dumpAsmCode().join("\n");
    }
    else {
      mvm.execute();
    }
      }
      catch (e:Error) {
    stdout.text = e.toString();
      }
    }
  }
}


/** レキシカルアナライザ */
class LexicalAnalyzer {
  private var sourceCodeCharArray:Vector.<String>;
  private var currentLineNumber:int;
  private var operatorTable:Object;
  private var keywordTable:Object;
  public function get lineNumber():int { return currentLineNumber; }

  /**
  コンストラクタ
  @param sourceCode ソースコード
  */
  public function LexicalAnalyzer(sourceCode:String) {
    currentLineNumber = 1;
    operatorTable = {
      "==" : TokenKind.EQ_TOKEN,
      "!=" : TokenKind.NE_TOKEN,
      ">=" : TokenKind.GE_TOKEN,
      "<=" : TokenKind.LE_TOKEN,
      "+" : TokenKind.ADD_TOKEN,
      "-" : TokenKind.SUB_TOKEN,
      "*" : TokenKind.MUL_TOKEN,
      "/" : TokenKind.DIV_TOKEN,
      "=" : TokenKind.ASSIGN_TOKEN,
      ">" : TokenKind.GT_TOKEN,
      "<" : TokenKind.LT_TOKEN,
      "(" : TokenKind.LEFT_PAREN_TOKEN,
      ")" : TokenKind.RIGHT_PAREN_TOKEN,
      "{" : TokenKind.LEFT_BRACE_TOKEN,
      "}" : TokenKind.RIGHT_BRACE_TOKEN,
      "," : TokenKind.COMMA_TOKEN,
      ";" : TokenKind.SEMICOLON_TOKEN
    };
    
    keywordTable = {
      "if" : TokenKind.IF_TOKEN,
      "else" : TokenKind.ELSE_TOKEN,
      "while" : TokenKind.WHILE_TOKEN,
      "goto" : TokenKind.GOTO_TOKEN,
      "gosub" : TokenKind.GOSUB_TOKEN,
      "return" : TokenKind.RETURN_TOKEN,
      "print" : TokenKind.PRINT_TOKEN
    };

    sourceCode = sourceCode.replace(/\r\n?/g, "\n");
    sourceCodeCharArray = new Vector.<String>();
    for (var i:int = 0; i < sourceCode.length; i++) {
      sourceCodeCharArray.push(sourceCode.charAt(i));
    }
  }
  
  /**
  エラーを発生
  @param エラーメッセージ
  */
  private function lexError(message:String):void {
    throw new Error("lex error: " + message);
  }

  /**
  現在読み込み中のtoken(文字列)にletter(1文字)を追加した文字列(token + letter)が
  演算子の文字列と前方一致でマッチするかどうかを判定
  @param token 読み込み中のトークン
  @param letter 追加する文字
  @return token+letterが演算子の文字列と前方一致でマッチすればtrue, しなければfalse
  */
  private function inOperator(token:String, letter:String):Boolean {
    var newToken:String = token + letter;
    for (var op:String in operatorTable) {
      if (op.length >= newToken.length
    && newToken == op.substring(0, newToken.length)) {
    return true;
      }
    }
    return false;
  }

  /**
  演算子と区切り子を判定
  @param token トークン
  @return トークンの種類(TokenKind)
  */
  private function selectOperator(token:String):int {
    if (operatorTable[token] == null) {
      lexError("Invalid operator " + token);
      return 0;
    }
    return operatorTable[token];
  }

  /**
  与えられた文字が数字(0~9)であるかを判定
  @param ch 判定対象の文字
  @return chが数字であればtrue, 数字でなければfalse
  */
  private function isDigit(ch:String):Boolean {
    var charCode:Number = ch.charCodeAt(0);
    // "0" = 48, "9" = 57
    return charCode >= 48 && charCode <= 57;
  }

  /**
  与えられた文字が英字(A~Z, a~z)であるかを判定
  @param ch 判定対象の文字
  @return chが英字であればtrue, 英字でなければfalse
  */
  private function isAlpha(ch:String):Boolean {
    var charCode:Number = ch.charCodeAt(0);
    // "A" = 65, "Z" = 90, "a" = 97, "z" = 122
    return (charCode >= 65 && charCode <= 90) || (charCode >= 97 && charCode <= 122);
  }

  /**
  与えられた文字が空白文字であるかを判定
  @param ch 判定対象の文字
  @return chが空白文字であればtrue, 英字でなければfalse
  */
  private function isSpace(ch:String):Boolean {
    var charCode:Number = ch.charCodeAt(0);
    // " " = 32, "\f" = 12, "\n" = 10, "\r" = 13, "\t" = 9, "\v" = 11
    return (charCode >= 9 && charCode <= 13) || (charCode == 32);
  }

  /**
  次のトークンを取得
  @return トークン
  */
  public function lexGetToken():Token {
    var ret:Token = new Token();
    var state:int = LexerState.INITIAL_STATE; // 読み取り中のトークンの種別を保持
    var token:String = "";
    var ch:String;
    
    // ソースコードから1文字ずつ読み取る
    LOOP: while ((ch = sourceCodeCharArray.shift()) != null) {
      switch (state) {
    case LexerState.INITIAL_STATE:
    if (isDigit(ch)) {
      token = token.concat(ch);
      state = LexerState.INT_VALUE_STATE;
    }
    else if (isAlpha(ch) || ch == "_") {
      token = token.concat(ch);
      state = LexerState.IDENTIFIER_STATE;
    }
    else if (ch == '"') {
      state = LexerState.STRING_STATE;
    }
    else if (inOperator(token, ch)) {
      token = token.concat(ch);
      state = LexerState.OPERATOR_STATE;
    }
    else if (isSpace(ch)) {
      if (ch == "\n") {
        currentLineNumber++;
      }
    }
    else if (ch == "#") {
      state = LexerState.COMMENT_STATE;
    }
    else {
      lexError("Bad charactor: " + ch);
    }
    break;

    case LexerState.INT_VALUE_STATE:
    if (isDigit(ch)) {
      token = token.concat(ch);
    }
    else {
      ret = Token.getIntToken(parseInt(token));
      sourceCodeCharArray.unshift(ch);
      break LOOP;
    }
    break;

    case LexerState.IDENTIFIER_STATE:
    if (isAlpha(ch) || ch == "_" || isDigit(ch)) {
      token = token.concat(ch);
    }
    else {
      ret = Token.getIdentifierToken(TokenKind.IDENTIFIER_TOKEN, token);
      sourceCodeCharArray.unshift(ch);
      break LOOP;
    }
    break;

    case LexerState.STRING_STATE:
    if (ch == '"') {
      ret = Token.getStringToken(token);
      break LOOP;
    }
    else {
      token = token.concat(ch);
    }
    break;

    case LexerState.OPERATOR_STATE:
    if (inOperator(token, ch)) {
      token = token.concat(ch);
    }
    else {
      sourceCodeCharArray.unshift(ch);
      break LOOP;
    }
    break;

    case LexerState.COMMENT_STATE:
    if (ch == "\n") {
      state = LexerState.INITIAL_STATE;
    }
    break;
    
    default:
    throw new Error("lex error");
    break;
      }
    }
    
    if (ch == null) {
      if (state == LexerState.INITIAL_STATE || state == LexerState.COMMENT_STATE) {
    ret.kind = TokenKind.END_OF_FILE_TOKEN;
    return ret;
      }
    }
    if (state == LexerState.IDENTIFIER_STATE) {
      if (keywordTable[token] == null) {
    ret = Token.getIdentifierToken(TokenKind.IDENTIFIER_TOKEN, token);
      }
      else {
    ret = Token.getIdentifierToken(keywordTable[token], token);
      }
    }
    else if (state == LexerState.OPERATOR_STATE) {
      ret.kind = selectOperator(token);
    }
    
    return ret;
  }
}

/** 読み取っているトークンの種類 */
class LexerState {
  public static const INITIAL_STATE:int = 1;
  public static const INT_VALUE_STATE:int = 2;
  public static const IDENTIFIER_STATE:int = 3;
  public static const STRING_STATE:int = 4;
  public static const OPERATOR_STATE:int = 5;
  public static const COMMENT_STATE:int = 6;
}

/** トークン */
class Token {
  private var _kind:int;
  private var _intValue:int;
  private var _stringValue:String;
  private var _identifier:String;

  /**
  int型の値を表すトークンオブジェクトを作成
  @param intValue 値
  @return tokenKindとintValueがセットされたトークンオブジェクト
  */
  public static function getIntToken(intValue:int):Token {
    var token:Token = new Token();
    token._kind = TokenKind.INT_VALUE_TOKEN;
    token._intValue = intValue;
    return token;
  }

  /**
  String型の値を表すトークンオブジェクトを作成
  @param stringValue 値
  @return tokenKindとstringValueがセットされたトークンオブジェクト
  */
  public static function getStringToken(stringValue:String):Token {
    var token:Token = new Token();
    token._kind = TokenKind.STRING_LITERAL_TOKEN;
    token._stringValue = stringValue;
    return token;
  }

  /**
  識別子を表すトークンオブジェクトを作成
  @param tokenKind トークンの種類(TokenKind)
  @param identifier 値
  @return tokenKindとidentifierがセットされたトークンオブジェクト
  */
  public static function getIdentifierToken(tokenKind:int, identifier:String):Token {
    var token:Token = new Token();
    token._kind = tokenKind;
    token._identifier = identifier
    return token;
  }

  public function get kind():int {
    return _kind;
  }
  public function set kind(kind:int):void {
    _kind = kind;
  }
  public function get intValue():int {
    return _intValue;
  }
  public function get stringValue():String {
    return _stringValue;
  }
  public function get identifier():String {
    return _identifier;
  }

  public function toString():String {
    return _kind + " [" + [_intValue, _stringValue, _identifier].join(", ") + "]";
  }
}

/** トークンの種類 */
class TokenKind {
  public static const INT_VALUE_TOKEN:int = 1; // 整数
  public static const IDENTIFIER_TOKEN:int = 2; // 識別子
  public static const STRING_LITERAL_TOKEN:int = 3; // 文字列
  public static const EQ_TOKEN:int = 4; // ==
  public static const NE_TOKEN:int = 5; // !=
  public static const GE_TOKEN:int = 6; // >=
  public static const LE_TOKEN:int = 7; // <=
  public static const ADD_TOKEN:int = 8; // +
  public static const SUB_TOKEN:int = 9; // -
  public static const MUL_TOKEN:int = 10; // *
  public static const DIV_TOKEN:int = 11; // /
  public static const ASSIGN_TOKEN:int = 12; // =
  public static const GT_TOKEN:int = 13; // >
  public static const LT_TOKEN:int = 14; // <
  public static const LEFT_PAREN_TOKEN:int = 15; // (
  public static const RIGHT_PAREN_TOKEN:int = 16; // )
  public static const LEFT_BRACE_TOKEN:int = 17; // {
  public static const RIGHT_BRACE_TOKEN:int = 18; //  }
  public static const COMMA_TOKEN:int = 19; // ,
  public static const SEMICOLON_TOKEN:int = 20; // ;
  public static const IF_TOKEN:int = 21; // if
  public static const ELSE_TOKEN:int = 22; // else
  public static const WHILE_TOKEN:int = 23; // while
  public static const GOTO_TOKEN:int = 24; // goto
  public static const GOSUB_TOKEN:int = 25; // gosub
  public static const RETURN_TOKEN:int = 26; // return
  public static const PRINT_TOKEN:int = 27; // print
  public static const END_OF_FILE_TOKEN:int = 28; // EOF
}

/** ラベル */
class Label {
  private var _identifier:String;
  public var address:int;
  public function get identifier():String {
    return _identifier;
  }

  /**
  コンストラクタ
  @param identifier 識別子
  @param address アドレス(default = 0)
  */
  public function Label(identifier:String, address:int = 0) {
    this._identifier = identifier;
    this.address = address;
  }
}

/** オペコード */
class OpCode {
  public static const OP_PUSH_INT:int = 1;
  public static const OP_PUSH_STRING:int = 2;
  public static const OP_ADD:int = 3;
  public static const OP_SUB:int = 4;
  public static const OP_MUL:int = 5;
  public static const OP_DIV:int = 6;
  public static const OP_MINUS:int = 7;
  public static const OP_EQ:int = 8;
  public static const OP_NE:int = 9;
  public static const OP_GT:int = 10;
  public static const OP_GE:int = 11;
  public static const OP_LT:int = 12;
  public static const OP_LE:int = 13;
  public static const OP_PUSH_VAR:int = 14;
  public static const OP_ASSIGN_TO_VAR:int = 15;
  public static const OP_JUMP:int = 16;
  public static const OP_JUMP_IF_ZERO:int = 17;
  public static const OP_GOSUB:int = 18;
  public static const OP_RETURN:int = 19;
  public static const OP_PRINT:int = 20;
}

/** パーサ */
class Parser {
  private var _bytecode:Vector.<int>;
  private var _labelTable:Vector.<Label>;
  private var _varTable:Vector.<String>;
  private var _strPool:Vector.<String>;
  private var lookAheadToken:Token;
  private var lex:LexicalAnalyzer;
  public function get bytecode():Vector.<int> { return _bytecode; }
  public function get labelTable():Vector.<Label> { return _labelTable; }
  public function get varTable():Vector.<String> { return _varTable; }
  public function get strPool():Vector.<String> { return _strPool; }

  /**
  コンストラクタ
  @param sourceCode ソースコード
  */
  public function Parser(sourceCode:String) {
    _bytecode = new Vector.<int>();
    _labelTable = new Vector.<Label>();
    _varTable = new Vector.<String>();
    _strPool = new Vector.<String>();

    lex = new LexicalAnalyzer(sourceCode);
    parse();
    fixLabels();
  }

  /**
  次のトークンを取得
  @return トークン
  */
  private function getToken():Token {
    var ret:Token;
    if (lookAheadToken != null) {
      ret = lookAheadToken;
      lookAheadToken = null;
    }
    else {
      ret = lex.lexGetToken();
    }
    return ret;
  }

  /**
  トークンを押し戻す
  @param token トークン
  */
  private function ungetToken(token:Token):void {
    lookAheadToken = token;
  }

  /**
  バイトコードに追加
  @param bytecode 追加するバイトコード
  */
  private function addBytecode(bytecode:int):void {
    _bytecode.push(bytecode);
  }
  
  /**
  エラーを発生
  @param message エラーメッセージ
  */
  private function parseError(message:String):void {
    throw new Error("Parse error: " + message + " at " + lex.lineNumber);
  }

  /**
  トークンが期待する種類でなければparse errorを発生させる
  @param expected 期待するトークンの種類(TokenKind)
  */
  private function checkExpectedToken(expected:int):void {
    var token:Token = getToken();
    if (token.kind != expected) {
      parseError("parse error - TokenKind " + expected + " is expected, but is " + token.toString());
    }
  }
  
  /**
  変数を検索し、ない場合は新たに登録
  @param identifier 識別子
  @return 変数のインデックス
  */
  private function searchOrNewVar(identifier:String):int {
    var ret:int = _varTable.indexOf(identifier);
    if (ret < 0) {
      _varTable.push(identifier);
      return _varTable.length - 1;
    }
    return ret;
  }

  /** 基本式をパース */
  private function parsePrimaryExpression():void {
    var token:Token = getToken();
    switch (token.kind) {
      case TokenKind.INT_VALUE_TOKEN:
      addBytecode(OpCode.OP_PUSH_INT);
      addBytecode(token.intValue);
      break;

      case TokenKind.STRING_LITERAL_TOKEN:
      addBytecode(OpCode.OP_PUSH_STRING);
      _strPool.push(token.stringValue);
      addBytecode(_strPool.length - 1);
      break;

      case TokenKind.LEFT_PAREN_TOKEN:
      parseExpression();
      checkExpectedToken(TokenKind.RIGHT_PAREN_TOKEN);
      break;
      
      case TokenKind.IDENTIFIER_TOKEN:
      var varIndex:int = _varTable.indexOf(token.identifier);
      if (varIndex < 0) {
    parseError(token.identifier + " - identifier not found.");
      }
      addBytecode(OpCode.OP_PUSH_VAR);
      addBytecode(varIndex);
      break;
    }
  }

  /** 負の数のある式をパース */
  private function parseUnaryExpression():void {
    var token:Token = getToken();
    if (token.kind == TokenKind.SUB_TOKEN) {
      parsePrimaryExpression();
      addBytecode(OpCode.OP_MINUS);
    }
    else {
      ungetToken(token);
      parsePrimaryExpression();
    }
  }

  /** *または/からなる式(項)をパース */
  private function parseMultiplicativeExpression():void {
    var token:Token;
    parseUnaryExpression();
    while (true) {
      token = getToken();
      if (token.kind != TokenKind.MUL_TOKEN
    && token.kind != TokenKind.DIV_TOKEN) {
    ungetToken(token);
    break;
      }
      parseUnaryExpression();
      if (token.kind == TokenKind.MUL_TOKEN) {
    addBytecode(OpCode.OP_MUL);
      }
      else {
    addBytecode(OpCode.OP_DIV);
      }
    }
  }

  /** +または-からなる式をパース */
  private function parseAdditiveExpression():void {
    var token:Token;
    parseMultiplicativeExpression();
    while (true) {
      token = getToken();
      if (token.kind != TokenKind.ADD_TOKEN
    && token.kind != TokenKind.SUB_TOKEN) {
    ungetToken(token);
    break;
      }
      parseMultiplicativeExpression();
      if (token.kind == TokenKind.ADD_TOKEN) {
    addBytecode(OpCode.OP_ADD);
      }
      else {
    addBytecode(OpCode.OP_SUB);
      }
    }
  }

  /** 比較演算子からなる式をパース */
  private function parseCompareExpression():void {
    var token:Token;
    parseAdditiveExpression();
    while (true) {
      token = getToken();
      if (token.kind != TokenKind.EQ_TOKEN
    && token.kind != TokenKind.NE_TOKEN
    && token.kind != TokenKind.GT_TOKEN
    && token.kind != TokenKind.GE_TOKEN
    && token.kind != TokenKind.LT_TOKEN
    && token.kind != TokenKind.LE_TOKEN) {
    ungetToken(token);
    break;
      }
      parseAdditiveExpression();

      switch (token.kind) {
    case TokenKind.EQ_TOKEN:
    addBytecode(OpCode.OP_EQ);
    break;

    case TokenKind.NE_TOKEN:
    addBytecode(OpCode.OP_NE);
    break;

    case TokenKind.GT_TOKEN:
    addBytecode(OpCode.OP_GT);
    break;

    case TokenKind.GE_TOKEN:
    addBytecode(OpCode.OP_GE);
    break;

    case TokenKind.LT_TOKEN:
    addBytecode(OpCode.OP_LT);
    break;

    case TokenKind.LE_TOKEN:
    addBytecode(OpCode.OP_LE);
    break;
      }
    }
  }

  /** 式をパース */
  private function parseExpression():void {
    parseCompareExpression();
  }

  /**
  新しいラベルを作成
  @return ラベルのインデックス
  */
  private function getLabel():int {
    _labelTable.push(new Label(null));
    return _labelTable.length - 1;
  }

  /**
  ラベルのアドレスをバイトコードの最後尾+1にセット
  @param labelIndex アドレスをセットするラベルのインデックス
  */
  private function setLabel(labelIndex:int):void {
    _labelTable[labelIndex].address = _bytecode.length;
  }

  /**
  ラベルを検索し、ない場合は新たに登録
  @param label ラベル
  @return ラベルのインデックス
  */
  private function searchOrNewLabel(label:String):int {
    var i:int;
    for (i = 0; i < _labelTable.length; i++) {
      if (_labelTable[i] != null && _labelTable[i].identifier != null
    && _labelTable[i].identifier == label) {
    return i;
      }
    }
    _labelTable.push(new Label(label));
    return _labelTable.length - 1;
  }

  /** if文をパース */
  private function parseIfStatement():void {
    var token:Token;
    var elseLabel:int;
    var endIfLabel:int;

    checkExpectedToken(TokenKind.LEFT_PAREN_TOKEN);
    parseExpression();
    checkExpectedToken(TokenKind.RIGHT_PAREN_TOKEN);

    elseLabel = getLabel();
    addBytecode(OpCode.OP_JUMP_IF_ZERO);
    addBytecode(elseLabel);
    parseBlock();
    token = getToken();
    if (token.kind == TokenKind.ELSE_TOKEN) {
      endIfLabel = getLabel();
      addBytecode(OpCode.OP_JUMP);
      addBytecode(endIfLabel);
      setLabel(elseLabel);
      parseBlock();
      setLabel(endIfLabel);
    }
    else {
      ungetToken(token);
      setLabel(elseLabel);
    }
  }

  /** while文をパース */
  private function parseWhileStatement():void {
    var loopLabel:int;
    var endWhileLabel:int;

    loopLabel = getLabel();
    setLabel(loopLabel);
    checkExpectedToken(TokenKind.LEFT_PAREN_TOKEN);
    parseExpression();
    checkExpectedToken(TokenKind.RIGHT_PAREN_TOKEN);

    endWhileLabel = getLabel();
    addBytecode(OpCode.OP_JUMP_IF_ZERO);
    addBytecode(endWhileLabel);
    parseBlock();
    addBytecode(OpCode.OP_JUMP);
    addBytecode(loopLabel);
    setLabel(endWhileLabel);
  }

  /** print文をパース */
  private function parsePrintStatement():void {
    checkExpectedToken(TokenKind.LEFT_PAREN_TOKEN);
    parseExpression();
    checkExpectedToken(TokenKind.RIGHT_PAREN_TOKEN);
    addBytecode(OpCode.OP_PRINT);
    checkExpectedToken(TokenKind.SEMICOLON_TOKEN);
  }

  /**
  代入文をパース
  @param identifier 識別子
  */
  private function parseAssignStatement(identifier:String):void {
    var varIndex:int = searchOrNewVar(identifier);
    checkExpectedToken(TokenKind.ASSIGN_TOKEN);
    parseExpression();
    addBytecode(OpCode.OP_ASSIGN_TO_VAR);
    addBytecode(varIndex);
    checkExpectedToken(TokenKind.SEMICOLON_TOKEN);
  }

  /** goto文をパース */
  private function parseGotoStatement():void {
    var token:Token;
    var label:int;

    checkExpectedToken(TokenKind.MUL_TOKEN);
    token = getToken();
    if (token.kind != TokenKind.IDENTIFIER_TOKEN) {
      parseError("label identifier expected");
    }
    label = searchOrNewLabel(token.identifier);
    addBytecode(OpCode.OP_JUMP);
    addBytecode(label);
    checkExpectedToken(TokenKind.SEMICOLON_TOKEN);
  }

  /** gosub文をパース */
  private function parseGosubStatement():void {
    var token:Token;
    var label:int;

    checkExpectedToken(TokenKind.MUL_TOKEN);
    token = getToken();
    if (token.kind != TokenKind.IDENTIFIER_TOKEN) {
      parseError("label identifier expected");
    }
    label = searchOrNewLabel(token.identifier);
    addBytecode(OpCode.OP_GOSUB);
    addBytecode(label);
    checkExpectedToken(TokenKind.SEMICOLON_TOKEN);
  }

  /** ラベル文をパース */
  private function parseLabelStatement():void {
    var token:Token;
    var label:int;

    token = getToken();
    if (token.kind != TokenKind.IDENTIFIER_TOKEN) {
      parseError("label identifier expected");
    }
    label = searchOrNewLabel(token.identifier);
    setLabel(label);
  }

  /** return文をパース */
  private function parseReturnStatement():void {
    addBytecode(OpCode.OP_RETURN);
    checkExpectedToken(TokenKind.SEMICOLON_TOKEN);
  }

  /** トークンを読み取り種別ごとに分岐 */
  private function parseStatement():void {
    var token:Token = getToken();
    
    switch (token.kind) {
      case TokenKind.IF_TOKEN:
      parseIfStatement();
      break;

      case TokenKind.WHILE_TOKEN:
      parseWhileStatement();
      break;

      case TokenKind.PRINT_TOKEN:
      parsePrintStatement();
      break;

      case TokenKind.GOTO_TOKEN:
      parseGotoStatement();
      break;

      case TokenKind.GOSUB_TOKEN:
      parseGosubStatement();
      break;

      case TokenKind.RETURN_TOKEN:
      parseReturnStatement();
      break;

      case TokenKind.MUL_TOKEN:
      parseLabelStatement();
      break;

      case TokenKind.IDENTIFIER_TOKEN:
      parseAssignStatement(token.identifier);
      break;

      default:
      parseError("bad statement.");
      break;
    }
  }
  
  /** { }のブロックをパース */
  private function parseBlock():void {
    var token:Token;
    checkExpectedToken(TokenKind.LEFT_BRACE_TOKEN);
    while (true) {
      token = getToken();
      if (token.kind == TokenKind.RIGHT_BRACE_TOKEN) {
    break;
      }
      ungetToken(token);
      parseStatement();
    }
  }

  /**
  ジャンプ先の実アドレスを書き込む
  (パース時にバイトコードに入れたアドレスは_labelTableのインデックス)
  */
  private function fixLabels():void {
    var i:int;
    for (i = 0; i < _bytecode.length; i++) {
      if (_bytecode[i] == OpCode.OP_PUSH_INT
    || _bytecode[i] == OpCode.OP_PUSH_STRING
    || _bytecode[i] == OpCode.OP_PUSH_VAR
    || _bytecode[i] == OpCode.OP_ASSIGN_TO_VAR) {
    i++;
      }
      else if (_bytecode[i] == OpCode.OP_JUMP
    || _bytecode[i] == OpCode.OP_JUMP_IF_ZERO
    || _bytecode[i] == OpCode.OP_GOSUB) {
    _bytecode[i + 1] = _labelTable[_bytecode[i + 1]].address;
    i++; // オリジナルにはないが、たぶん必要
      }
    }
  }

  /** パース */
  private function parse():void {
    var token:Token;
    while (true) {
      token = getToken();
      if (token.kind == TokenKind.END_OF_FILE_TOKEN) {
    break;
      }
      else {
    ungetToken(token);
    parseStatement();
      }
    }
  }
}

/** MILの仮想マシン */
class Mvm {
  private var _stack:Vector.<Value>;
  private var _variable:Vector.<Value>;
  private var _bytecode:Vector.<int>;
  private var _strPool:Vector.<String>;
  private var stdout:Function;
  
  /**
  コンストラクタ
  @param bytecode バイトコード(Vector.<int>)
  @param strPool 文字列プール(Vector.<String>)
  */
  public function Mvm(bytecode:Vector.<int>, strPool:Vector.<String>,
    stdout:Function = null) {
    _stack = new Vector.<Value>();
    _variable = new Vector.<Value>();
    this._bytecode = bytecode;
    this._strPool = strPool;
    this.stdout = stdout;
  }
  
  /** バイトコードを実行 */
  public function execute():void {
    var value:Value;
    var n:int, m:int
    var str:String;
    var bool:Boolean;
    var pc:int = 0;
    
    while (pc < _bytecode.length) {
      switch (_bytecode[pc]) {
    case OpCode.OP_PUSH_INT:
    value = Value.createIntValue(_bytecode[pc + 1]);
    _stack.push(value);
    pc += 2;
    break;

    case OpCode.OP_PUSH_STRING:
    str = _strPool[_bytecode[pc + 1]];
    value = Value.createStringValue(str);
    _stack.push(value);
    pc += 2;
    break;

    case OpCode.OP_ADD:
    n = _stack.pop().intValue + _stack.pop().intValue;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_SUB:
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    _stack.push(Value.createIntValue(n - m));
    pc++;
    break;

    case OpCode.OP_MUL:
    n = _stack.pop().intValue * _stack.pop().intValue;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_DIV:
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    _stack.push(Value.createIntValue(n / m));
    pc++;
    break;

    case OpCode.OP_MINUS:
    n = _stack.pop().intValue * -1;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_EQ:
    n = (_stack.pop().intValue == _stack.pop().intValue) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_NE:
    n = (_stack.pop().intValue != _stack.pop().intValue) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_GT:
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    n = (n > m) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_GE:
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    n = (n >= m) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_LT:
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    n = (n < m) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_LE:
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    n = (n <= m) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_PUSH_VAR:
    value = _variable[_bytecode[pc + 1]];
    _stack.push(value);
    pc += 2;
    break;

    case OpCode.OP_ASSIGN_TO_VAR:
    _variable[_bytecode[pc + 1]] = _stack.pop();
    pc += 2;
    break;

    case OpCode.OP_JUMP:
    pc = _bytecode[pc + 1];
    break;

    case OpCode.OP_JUMP_IF_ZERO:
    if (_stack.pop().intValue == 0) {
      pc = _bytecode[pc + 1];
    }
    else {
      pc += 2;
    }
    break;

    case OpCode.OP_GOSUB:
    _stack.push(Value.createIntValue(pc + 2));
    pc = _bytecode[pc + 1];
    break;

    case OpCode.OP_RETURN:
    pc = _stack.pop().intValue;
    break;

    case OpCode.OP_PRINT:
    
    value = _stack.pop();
    if (stdout != null) {
      if (value.type == ValueType.INT_VALUE_TYPE) {
        stdout(value.intValue);
      }
      else {
        stdout(value.stringValue);
      }
    }
    pc++;
    break;

    default:
    pc++;
    throw new Error("MVM Error");
    break;
      }
    }
  }

  /**
  バイトコードをアセンブリコードに変換
  @return アセンブリコード
  */
  public function dumpAsmCode():Array {
    var value:Value;
    var n:int, m:int
    var str:String;
    var bool:Boolean;
    var pc:int = 0;
    var asm:Array = [];
    if (_strPool.length > 0) {
      asm.push(".STRING_POOL");
      for each (str in _strPool) {
    asm.push(str);
      }
    }
    asm.push(".BYTECODE");
    
    while (pc < _bytecode.length) {
      switch (_bytecode[pc]) {
    case OpCode.OP_PUSH_INT:
    asm.push("OP_PUSH_INT");
    asm.push(_bytecode[pc + 1]);
    value = Value.createIntValue(_bytecode[pc + 1]);
    _stack.push(value);
    pc += 2;
    break;

    case OpCode.OP_PUSH_STRING:
    asm.push("OP_PUSH_STRING");
    asm.push(_bytecode[pc + 1]);
    str = _strPool[_bytecode[pc + 1]];
    value = Value.createStringValue(str);
    _stack.push(value);
    pc += 2;
    break;

    case OpCode.OP_ADD:
    asm.push("OP_ADD " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
    n = _stack.pop().intValue + _stack.pop().intValue;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_SUB:
    asm.push("OP_SUB " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    _stack.push(Value.createIntValue(n - m));
    pc++;
    break;

    case OpCode.OP_MUL:
    asm.push("OP_MUL " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
    n = _stack.pop().intValue * _stack.pop().intValue;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_DIV:
    asm.push("OP_DIV " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    _stack.push(Value.createIntValue(n / m));
    pc++;
    break;

    case OpCode.OP_MINUS:
    asm.push("OP_MINUS " + _stack[_stack.length - 1].intValue);
    n = _stack.pop().intValue * -1;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_EQ:
    asm.push("OP_EQ " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
    n = (_stack.pop().intValue == _stack.pop().intValue) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_NE:
    asm.push("OP_NE " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
    n = (_stack.pop().intValue != _stack.pop().intValue) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_GT:
    asm.push("OP_GT " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    n = (n > m) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_GE:
    asm.push("OP_GE " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    n = (n >= m) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_LT:
    asm.push("OP_LT " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    n = (n < m) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_LE:
    asm.push("OP_LE " + _stack[_stack.length - 2].intValue + " " + _stack[_stack.length - 1].intValue);
    m = _stack.pop().intValue;
    n = _stack.pop().intValue;
    n = (n <= m) ? 1 : 0;
    _stack.push(Value.createIntValue(n));
    pc++;
    break;

    case OpCode.OP_PUSH_VAR:
    asm.push("OP_PUSH_VAR");
    asm.push(_bytecode[pc + 1]);
    value = _variable[_bytecode[pc + 1]];
    _stack.push(value);
    pc += 2;
    break;

    case OpCode.OP_ASSIGN_TO_VAR:
    if (_stack[_stack.length - 1].type == ValueType.INT_VALUE_TYPE) {
      str = _stack[_stack.length - 1].intValue.toString();
    }
    else {
      str = _stack[_stack.length - 1].stringValue;
    }
    asm.push("OP_ASSIGN_TO_VAR " + str);
    asm.push(_bytecode[pc + 1]);
    _variable[_bytecode[pc + 1]] = _stack.pop();
    pc += 2;
    break;

    case OpCode.OP_JUMP:
    asm.push("OP_JUMP");
    asm.push(_bytecode[pc + 1]);
    pc += 2;
    break;
    
    case OpCode.OP_JUMP_IF_ZERO:
    asm.push("OP_JUMP_IF_ZERO " + _stack[_stack.length - 1].intValue);
    asm.push(_bytecode[pc + 1]);
    pc += 2;
    break;

    case OpCode.OP_GOSUB:
    asm.push("OP_GOSUB");
    asm.push(_bytecode[pc + 1]);
    _stack.push(Value.createIntValue(pc + 2));
    pc += 2;
    break;

    case OpCode.OP_RETURN:
    asm.push("OP_RETURN " + _stack.pop().intValue);
    pc++;
    break;

    case OpCode.OP_PRINT:
    value = _stack.pop();
    if (stdout != null) {
      if (value.type == ValueType.INT_VALUE_TYPE) {
        asm.push("OP_PRINT " + value.intValue);
      }
      else {
        asm.push("OP_PRINT " + value.stringValue);
      }
    }
    pc++;
    break;

    default:
    asm.push(_bytecode[pc] + " << ERROR");
    pc++;
    break;
      }
    }
    return asm;
  }
}

/** MVMで扱うデータ */
class Value {
  private var _type:int;
  private var _intValue:int;
  private var _stringValue:String;

  public function get type():int { return _type; }

  public function get intValue():int {
    if (_type == ValueType.INT_VALUE_TYPE) {
      return _intValue;
    }
    else {
      throw new Error("This is INT_VALUE.");
    }
  }

  public function get stringValue():String {
    if (_type == ValueType.STRING_VALUE_TYPE) {
      return _stringValue;
    }
    else {
      throw new Error("This is STRING_VALUE.");
    }
  }

  /**
  int型の値を表す値を作成
  @param intValue 値
  @return Valueオブジェクト
  */
  public static function createIntValue(intValue:int):Value {
    var value:Value = new Value();
    value._type = ValueType.INT_VALUE_TYPE;
    value._intValue = intValue;
    value._stringValue = null;
    return value;
  }

  /**
  String型の値を表す値を作成
  @param stringValue 値
  @return Valueオブジェクト
  */
  public static function createStringValue(stringValue:String):Value {
    var value:Value = new Value();
    value._type = ValueType.STRING_VALUE_TYPE;
    value._intValue = 0;
    value._stringValue = stringValue;
    return value;
  }
}

/** MVMで扱うデータ型の種類 */
class ValueType {
  public static const INT_VALUE_TYPE:int = 1;
  public static const STRING_VALUE_TYPE:int = 2;
}
