<?xml version="1.0" encoding="utf-8"?>
<!--

   This is a quick and dirty AS3 port of Tinic Uro's PBJ assembler
   from http://www.kaourantin.net/2008/09/pixel-bender-pbj-files.html

   Some more info and related projects:
   http://ncannasse.fr/projects/pbj (there's some opcode documentation at the bottom of this page)
   http://www.jamesward.com/2009/04/29/announcing-pbjas-an-actionscript-3-pixel-bender-shader-library/

-->
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" applicationComplete="init()" height="100%" width="100%" styleName="plain" paddingLeft="0" paddingRight="0" paddingTop="0" paddingBottom="0">
  <mx:HDividedBox width="100%" height="100%">
    <mx:VDividedBox width="60%" height="100%">
      <mx:TextArea id="code" change="build()" height="80%" width="100%" fontFamily="Courier New" />
      <mx:TextArea id="status" height="20%" width="100%" editable="false"/>
    </mx:VDividedBox>
    <mx:VDividedBox width="40%" height="100%">
      <mx:VBox width="100%">
	<mx:Button label="Tutorial" click="code.text=tutShader;build()" />
	<mx:Button label="3 Metaballs" click="code.text=ballsShader;build()" />
	<mx:Button label="Doob's hypnotic shader" click="code.text=doobShader;build()" />
	<mx:Button label="Single mandelbrot iteration" click="code.text=brotShader;build()" />
        <mx:TextArea editable="false" id="params" height="20%" width="100%" text="TODO: parameter sliders, upload image button, export bytcode button, disassembler, etc, etc..." />
      </mx:VBox>
      <mx:Box id="shaderOutput" height="80%" width="100%" />
    </mx:VDividedBox>
  </mx:HDividedBox>
  <mx:Script><![CDATA[

public static const pbjNop:uint                  = 0x00;
public static const pbjAdd:uint                  = 0x01;
public static const pbjSubtract:uint             = 0x02;
public static const pbjMultiply:uint             = 0x03;
public static const pbjReciprocal:uint           = 0x04;
public static const pbjDivide:uint               = 0x05;
public static const pbjAtan2:uint                = 0x06;
public static const pbjPow:uint                  = 0x07;
public static const pbjMod:uint                  = 0x08;
public static const pbjMin:uint                  = 0x09;
public static const pbjMax:uint                  = 0x0A;
public static const pbjStep:uint                 = 0x0B;
public static const pbjSin:uint                  = 0x0C;
public static const pbjCos:uint                  = 0x0D;
public static const pbjTan:uint                  = 0x0E;
public static const pbjASin:uint                 = 0x0F;
public static const pbjACos:uint                 = 0x10;
public static const pbjATan:uint                 = 0x11;
public static const pbjExp:uint                  = 0x12;
public static const pbjExp2:uint                 = 0x13;
public static const pbjLog:uint                  = 0x14;
public static const pbjLog2:uint                 = 0x15;
public static const pbjSqrt:uint                 = 0x16;
public static const pbjRSqrt:uint                = 0x17;
public static const pbjAbs:uint                  = 0x18;
public static const pbjSign:uint                 = 0x19;
public static const pbjFloor:uint                = 0x1A;
public static const pbjCeil:uint                 = 0x1B;
public static const pbjFract:uint                = 0x1C;
public static const pbjCopy:uint                 = 0x1D;
public static const pbjFloatToInt:uint           = 0x1E;
public static const pbjIntToFloat:uint           = 0x1F;
public static const pbjMatrixMatrixMultiply:uint = 0x20;
public static const pbjVectorMatrixMultiply:uint = 0x21;
public static const pbjMatrixVectorMultiply:uint = 0x22;
public static const pbjNormalize:uint            = 0x23;
public static const pbjLength:uint               = 0x24;
public static const pbjDistance:uint             = 0x25;
public static const pbjDotProduct:uint           = 0x26;
public static const pbjCrossProduct:uint         = 0x27;
public static const pbjEqual:uint                = 0x28;
public static const pbjNotEqual:uint             = 0x29;
public static const pbjLessThan:uint             = 0x2A;
public static const pbjLessThanEqual:uint        = 0x2B;
public static const pbjLogicalNot:uint           = 0x2C;
public static const pbjLogicalAnd:uint           = 0x2D;
public static const pbjLogicalOr:uint            = 0x2E;
public static const pbjLogicalXor:uint           = 0x2F;
public static const pbjSampleNearest:uint        = 0x30;
public static const pbjSampleBilinear:uint       = 0x31;
public static const pbjLoadConstant:uint         = 0x32;
public static const pbjSelect:uint               = 0x33;
public static const pbjIf:uint                   = 0x34;
public static const pbjElse:uint                 = 0x35;
public static const pbjEndif:uint                = 0x36;
public static const pbjFloatToBool:uint          = 0x37;
public static const pbjBoolToFloat:uint          = 0x38;
public static const pbjIntToBool:uint            = 0x39;
public static const pbjBoolToInt:uint            = 0x3A;
public static const pbjVectorEqual:uint          = 0x3B;
public static const pbjVectorNotEqual:uint       = 0x3C;
public static const pbjAny:uint                  = 0x3D;
public static const pbjAll:uint                  = 0x3E;
public static const pbjKernelMetaData:uint       = 0xa0;
public static const pbjParameterData:uint        = 0xa1;
public static const pbjParameterMetaData:uint    = 0xa2;
public static const pbjTextureData:uint          = 0xa3;
public static const pbjKernelName:uint           = 0xa4;
public static const pbjVersionData:uint          = 0xa5;

public static const pbjTypeFloat:uint            = 0x01;
public static const pbjTypeFloat2:uint           = 0x02;
public static const pbjTypeFloat3:uint           = 0x03;
public static const pbjTypeFloat4:uint           = 0x04;
public static const pbjTypeFloat2x2:uint         = 0x05;
public static const pbjTypeFloat3x3:uint         = 0x06;
public static const pbjTypeFloat4x4:uint         = 0x07;
public static const pbjTypeInt:uint              = 0x08;
public static const pbjTypeInt2:uint             = 0x09;
public static const pbjTypeInt3:uint             = 0x0A;
public static const pbjTypeInt4:uint             = 0x0B;
public static const pbjTypeString:uint           = 0x0C;
public static const pbjTypeBool:uint             = 0x0D;
public static const pbjTypeBool2:uint            = 0x0E;
public static const pbjTypeBool3:uint            = 0x0F;
public static const pbjTypeBool4:uint            = 0x10;

public static const pbjSampleSizeScalar:uint     = 0x01;
public static const pbjSampleSizeVector2:uint    = 0x02;
public static const pbjSampleSizeVector3:uint    = 0x03;
public static const pbjSampleSizeVector4:uint    = 0x04;

private var linen:int = 1;

private var ifile:String;
private var ofile:ByteArray;

private var opcodes:Object = {};
private var types:Object = {};
private var matrices:Object = {};

private static const typeSizes:Array = [
    0,
    1,
    2,
    3,
    4,
    4,
    9,
    16,
    1,
    2,
    3,
    4,
    1,
    1,
    2,
    3,
    4,
];

private function init_map():void {
    opcodes["nop"] = pbjNop;
    opcodes["add"] = pbjAdd;
    opcodes["sub"] = pbjSubtract;
    opcodes["mul"] = pbjMultiply;
    opcodes["div"] = pbjDivide;
    opcodes["atan2"] = pbjAtan2;
    opcodes["pow"] = pbjPow;
    opcodes["mod"] = pbjMod;
    opcodes["min"] = pbjMin;
    opcodes["max"] = pbjMax;
    opcodes["step"] = pbjStep;
    opcodes["rcp"] = pbjReciprocal;
    opcodes["sin"] = pbjSin;
    opcodes["cos"] = pbjCos;
    opcodes["tan"] = pbjTan;
    opcodes["asin"] = pbjASin;
    opcodes["acos"] = pbjACos;
    opcodes["atan"] = pbjATan;
    opcodes["exp"] = pbjExp;
    opcodes["exp2"] = pbjExp2;
    opcodes["log"] = pbjLog;
    opcodes["log2"] = pbjLog2;
    opcodes["sqr"] = pbjSqrt;
    opcodes["rsqr"] = pbjRSqrt;
    opcodes["abs"] = pbjAbs;
    opcodes["sign"] = pbjSign;
    opcodes["floor"] = pbjFloor;
    opcodes["ceil"] = pbjCeil;
    opcodes["fract"] = pbjFract;
    opcodes["mov"] = pbjCopy;
    opcodes["ftoi"] = pbjFloatToInt;
    opcodes["itof"] = pbjIntToFloat;
    opcodes["norm"] = pbjNormalize;
    opcodes["len"] = pbjLength;
    opcodes["dist"] = pbjDistance;
    opcodes["dot"] = pbjDotProduct;
    opcodes["cross"] = pbjCrossProduct;
    opcodes["equ"] = pbjEqual;
    opcodes["neq"] = pbjNotEqual;
    opcodes["ltn"] = pbjLessThan;
    opcodes["lte"] = pbjLessThanEqual;
    opcodes["not"] = pbjLogicalNot;
    opcodes["and"] = pbjLogicalAnd;
    opcodes["or"] = pbjLogicalOr;
    opcodes["xor"] = pbjLogicalXor;
    opcodes["texn"] = pbjSampleNearest;
    opcodes["texb"] = pbjSampleBilinear;
    opcodes["set"] = pbjLoadConstant;
    opcodes["sel"] = pbjSelect;
    opcodes["if"] = pbjIf;
    opcodes["else"] = pbjElse;
    opcodes["end"] = pbjEndif;
    opcodes["ftob"] = pbjFloatToBool;
    opcodes["btof"] = pbjBoolToFloat;
    opcodes["itob"] = pbjIntToBool;
    opcodes["btoi"] = pbjBoolToInt;
    opcodes["vequ"] = pbjVectorEqual;
    opcodes["vneq"] = pbjVectorNotEqual;
    opcodes["any"] = pbjAny;
    opcodes["all"] = pbjAll;
    opcodes["kernel"] = pbjKernelMetaData;
    opcodes["parameter"] = pbjParameterData;
    opcodes["meta"] = pbjParameterMetaData;
    opcodes["texture"] = pbjTextureData;
    opcodes["name"] = pbjKernelName;
    opcodes["version"] = pbjVersionData;    

    opcodes["mov2x2"] = pbjCopy;
    opcodes["mov3x3"] = pbjCopy;
    opcodes["mov4x4"] = pbjCopy;
    opcodes["add2x2"] = pbjAdd;
    opcodes["add3x3"] = pbjAdd;
    opcodes["add4x4"] = pbjAdd;
    opcodes["sub2x2"] = pbjSubtract;
    opcodes["sub3x3"] = pbjSubtract;
    opcodes["sub4x4"] = pbjSubtract;
    opcodes["mul2x2"] = pbjMultiply;
    opcodes["mul3x3"] = pbjMultiply;
    opcodes["mul4x4"] = pbjMultiply;
    opcodes["rcp2x2"] = pbjReciprocal;
    opcodes["rcp3x3"] = pbjReciprocal;
    opcodes["rcp4x4"] = pbjReciprocal;
    opcodes["equ2x2"] = pbjEqual;
    opcodes["equ3x3"] = pbjEqual;
    opcodes["equ4x4"] = pbjEqual;
    opcodes["neq2x2"] = pbjNotEqual;
    opcodes["neq3x3"] = pbjNotEqual;
    opcodes["neq4x4"] = pbjNotEqual;
    opcodes["mmmul2x2"] = pbjMatrixMatrixMultiply;
    opcodes["mmmul3x3"] = pbjMatrixMatrixMultiply;
    opcodes["mmmul4x4"] = pbjMatrixMatrixMultiply;
    opcodes["vmmul2x2"] = pbjVectorMatrixMultiply;
    opcodes["vmmul3x3"] = pbjVectorMatrixMultiply;
    opcodes["vmmul4x4"] = pbjVectorMatrixMultiply;
    opcodes["mvmul2x2"] = pbjMatrixVectorMultiply;
    opcodes["mvmul3x3"] = pbjMatrixVectorMultiply;
    opcodes["mvmul4x4"] = pbjMatrixVectorMultiply;
    opcodes["sel2x2"] = pbjSelect;
    opcodes["sel3x3"] = pbjSelect;
    opcodes["sel4x4"] = pbjSelect;

    types["float"] = 1;
    types["float2"] = 2;
    types["float3"] = 3;
    types["float4"] = 4;
    types["matrix2x2"] = 5;
    types["matrix3x3"] = 6;
    types["matrix4x4"] = 7;
    types["int"] = 8;
    types["int2"] = 9;
    types["int3"] = 10;
    types["int4"] = 11;
    types["bool"] = 12;
    types["bool2"] = 13;
    types["bool3"] = 14;
    types["bool4"] = 15;
    
    matrices["2x2"] = 1;
    matrices["3x3"] = 2;
    matrices["4x4"] = 3;
}

private var error_line:String;

private function write_int16(value:int):void
{
    ofile.writeByte(value&0xFF);
    ofile.writeByte((value>>8)&0xFF);
}

private function write_float(value:Number):void
{
	ofile.writeFloat(value);
    //     union {
    //         float   valuef;
    //         uint8_t valuec[4];
    //     };
    //     valuef = value;
    //     ofile << valuec[3];
    //     ofile << valuec[2];
    //     ofile << valuec[1];
    //     ofile << valuec[0];
}

private function error(str:String):void
{
	var err:String = "";

    err += str;
    err += " Line: ";
    err += linen;
    err += "\n";
    err += error_line;
    err += "\n";
    throw (new Error (err));
}


private function find_first_of(input:String, str:String, pos:uint = 0):int {
	var minPos:int = 0x7FFFFFFF;
	var found:Boolean = false;

	for each(var ch:String in str.split("")) {
		var chPos:int = input.indexOf(ch, pos);
		if(chPos != -1) {
			minPos = Math.min(minPos, chPos);
			found = true;
		}
	}

	return(found ? minPos : -1);
}

private function tokenize(input:String, tokenTypes:Array):Array
{
    var delimiters:String = " \t\n\r,;\"";
    var tokens:Array = [];
    var token:String;
    var last_pos:int = 0;
    var pos:int = 0;
    while(true) {
        pos = find_first_of(input, delimiters, last_pos);
        if( pos == -1 ) {
            token = input.substr(last_pos);
            if ( token.length ) {
                token = token.toLowerCase();
                tokens.push(token);
                tokenTypes.push(0);
            }
            break;
        } else {
            if (input.charAt(pos) == ';' ) {
                break;
            }
            if (input.charAt(pos) == '\"' ) {
                var end_pos:int = find_first_of(input, "\"", pos+1);
                if( pos == -1 ) {
                    error("string not terminated.");
                }
                token = input.substr(pos+1, end_pos - pos - 1);
                tokenTypes.push(1);
                tokens.push(token);
                last_pos = end_pos + 1;
                continue;
            }
            token = input.substr(last_pos, pos - last_pos);
            if ( token.length ) {
                token = token.toLowerCase();
                tokens.push(token);
                tokenTypes.push(0);
            }
            last_pos = pos + 1;
        }
    }
    return tokens;
}

private function parse_register_number(param:String):uint
{
    if ( find_first_of(param,"f",0) == -1 &&
        find_first_of(param,"i",0) == -1) {
        error("invalid register type.");
    }
    var register_n:uint = 0;
    var dot_pos:int = find_first_of(param,".",0);
    if ( dot_pos == -1 ) {
        register_n = parseInt(param.substr(1), 10);
    } else {
        register_n = parseInt(param.substr(1,dot_pos), 10);
    }
    if ( find_first_of(param,"f",0) != -1) {
        return register_n;
    } else {
        return register_n+32768;
    }
}

private static const cnam:String = "rgba";

private function parse_writemask(param:String):uint
{
    var dot_pos:int = find_first_of(param,".");
    if ( dot_pos == -1 ) {
        return 0xF;
    }
    var write_mask:uint = 0;
    for ( var c:uint = dot_pos+1; c<param.length; c++ ) {
        var found:Boolean = false;
        for ( var d:int=0; d<4; d++ ) {
            if ( param.charAt(c) == cnam.charAt(d) ) {
                write_mask |= 1<<(3-d);
                found = true;
                break;
            }
        }
        if (!found) {
            error("invalid write mask.");
        }
    }
    return write_mask;
}

private function parse_sourceselect(param:String):uint
{
    var dot_pos:int = find_first_of(param,".");
    if ( dot_pos == -1 ) {
        return 0x1b;
    }
    var select:uint = 0;
    var count:int = 0;
	var c:int;

    for ( c = dot_pos+1; c<param.length; c++ ) {
        select <<= 2;
        var found:Boolean = false;
        for ( var d:int=0; d<4; d++ ) {
            if ( param.charAt(c) == cnam.charAt(d) ) {
                select  |= d;
                found = true;
                count++;
                break;
            }
        }
        if (!found) {
            error("invalid source select.");
        }
    }
    for ( c=count; c<4; c++ ) {
        select <<= 2;
    }
    return select;
}

private function parse_sourcelen(param:String):uint
{
    var dot_pos:int = find_first_of(param,".");
    if ( dot_pos == -1 ) {
        return 3;
    }
    var size:uint = 0;
    for ( var c:uint = dot_pos+1; c<param.length; c++ ) {
        var found:Boolean = false;
        for ( var d:int=0; d<4; d++ ) {
            if ( param.charAt(c) == cnam.charAt(d) ) {
                size++;
                found = true;
                break;
            }
        }
        if (!found) {
            error("invalid source length.");
        }
    }
    if ( size == 0 ) {
        error("invalid source length.");
    }
    return size-1;
}

private function matrix_type(param:String):uint
{
    var x_pos:int = find_first_of(param,"x");
    if (  x_pos == -1 ) {
        return 0;
    }
    var mtx_str:String = param.substr(x_pos-1,x_pos+1);
    return matrices[mtx_str];
}

private function parse():void
{
    var meta_type:uint = 0;
	var reg:uint;
	var texture_id:int;
	var len:uint;
	var c:uint;

	var lines:Array = ifile.replace(/[\n\r]/g, "\n").split("\n");
    var line:String;
	linen = 1;

    while(lines.length) {
        error_line = line = lines.shift();
        var tokenTypes:Array = [];
        var tokens:Array = tokenize(line, tokenTypes);

        if ( !tokens.length ) {
            continue;
        }
		
		if( opcodes[tokens[0]] === undefined ) error("Unrecognized opcode.");
        var op:int = opcodes[tokens[0]];

        ofile.writeByte(op);
        switch ( op ) {
            case    pbjNop: {
                if ( tokens.length < 1 ) error("missing parameter(s).");
                if ( tokens.length > 1 ) error("too many parameters.");
                write_int16(0);
                ofile.writeByte(0);
                write_int16(0);
                ofile.writeByte(0);
                ofile.writeByte(0);
            } break;
            
            case    pbjAdd:
            case    pbjSubtract:            
            case    pbjMultiply:    
            case    pbjDivide:
            case    pbjAtan2:           
            case    pbjPow:             
            case    pbjMod:             
            case    pbjMin:             
            case    pbjMax:             
            case    pbjStep: 
            case    pbjCopy:                    
            case    pbjFloatToInt:
            case    pbjIntToFloat: 
            case    pbjReciprocal:
            case    pbjSin:                 
            case    pbjCos:                 
            case    pbjTan:                 
            case    pbjASin:                    
            case    pbjACos:                
            case    pbjATan:                    
            case    pbjExp:                 
            case    pbjExp2:                    
            case    pbjLog:                 
            case    pbjLog2:                    
            case    pbjSqrt:                    
            case    pbjRSqrt:               
            case    pbjAbs:                 
            case    pbjSign:                    
            case    pbjFloor:               
            case    pbjCeil:                    
            case    pbjFract:
            case    pbjDistance:
            case    pbjNormalize:
            case    pbjLength:
            case    pbjCrossProduct:
            case    pbjDotProduct:
            case    pbjEqual:               
            case    pbjNotEqual:            
            case    pbjVectorEqual:
            case    pbjVectorNotEqual:
            case    pbjLessThan:                
            case    pbjLessThanEqual: 
            case    pbjAny:
            case    pbjAll:
            case    pbjFloatToBool:
            case    pbjIntToBool:
            case    pbjBoolToInt:
            case    pbjBoolToFloat: 
            case    pbjMatrixMatrixMultiply:
            case    pbjLogicalOr:
            case    pbjLogicalXor:
            case    pbjLogicalAnd:
            case    pbjLogicalNot:  {   
                if ( tokens.length < 3 ) error("missing parameter(s).");
                if ( tokens.length > 3 ) error("too many parameters.");
                if ( matrix_type(tokens[0]) ) {
                    if ( parse_writemask(tokens[1]) != 0xF ||
                        parse_writemask(tokens[2]) != 0xF ) {
                        error("invalid register type.");
                    }
                    write_int16(parse_register_number(tokens[1]));
                    ofile.writeByte(matrix_type(tokens[0])<<2);
                    write_int16(parse_register_number(tokens[2]));
                    write_int16(0);
                } else {
                    var dst:uint = parse_register_number(tokens[1]);
                    var src:uint = parse_register_number(tokens[2]);
                    switch ( op ) {
                        case    pbjCopy:
                        case    pbjAdd:
                        case    pbjSubtract:            
                        case    pbjMultiply:    
                        case    pbjDivide:
                        case    pbjEqual:               
                        case    pbjNotEqual:            
                        case    pbjVectorEqual:
                        case    pbjVectorNotEqual:
                        case    pbjLessThan:                
                        case    pbjLessThanEqual: 
                        if ( ( src >= 32768 && dst < 32768 ) ||
                            ( src < 32768 && dst >= 32768 ) ) {
                            error("register type mismatch.");
                        }
                        break;
                        case    pbjFloatToInt: {
                            if ( src >= 32768 || dst < 32768 ) {
                                error("invalid register type.");
                            }
                        } break;
                        case    pbjIntToFloat: {
                            if ( src < 32768 || dst >= 32768 ) {
                                error("invalid register type.");
                            }
                        } break;
                        case    pbjFloatToBool: {
                            if ( src >= 32768 || dst < 32768 ) {
                                error("invalid register type.");
                            }
                        } break;
                        case    pbjIntToBool: {
                            if ( src < 32768 || dst < 32768 ) {
                                error("invalid register type.");
                            }
                        } break;
                        case    pbjBoolToInt: {
                            if ( src < 32768 || dst < 32768 ) {
                                error("invalid register type.");
                            }
                        } break;
                        case    pbjBoolToFloat: {
                            if ( src < 32768 || dst >= 32768 ) {
                                error("invalid register type.");
                            }
                        } break;
                        case    pbjAny:
                        case    pbjAll:
                        case    pbjLogicalOr:
                        case    pbjLogicalXor:
                        case    pbjLogicalAnd:
                        case    pbjLogicalNot: {
                            if ( src < 32768 || dst < 32768 ) {
                                error("invalid register type.");
                            }
                        } break;
                        default: {
                            if ( src >= 32768 || dst >= 32768 ) {
                                error("invalid register type.");
                            }
                        } break;
                    }
                    write_int16(dst);
                    ofile.writeByte((parse_writemask(tokens[1])<<4)|(parse_sourcelen(tokens[2])));
                    write_int16(src);
                    ofile.writeByte(parse_sourceselect(tokens[2]));
                    ofile.writeByte(0);
                }
            } break;

            case    pbjMatrixVectorMultiply:
            case    pbjVectorMatrixMultiply: {
                if ( tokens.length < 3 ) error("missing parameter(s).");
                if ( tokens.length > 3 ) error("too many parameters.");
                write_int16(parse_register_number(tokens[1]));
                ofile.writeByte((parse_writemask(tokens[1])<<4)|(matrix_type(tokens[0])<<2));
                write_int16(parse_register_number(tokens[2]));
                write_int16(0);
            } break;
            
            case    pbjSampleBilinear:
            case    pbjSampleNearest: {
                if ( tokens.length < 4 ) error("missing parameter(s).");
                if ( tokens.length > 4 ) error("too many parameters.");
                write_int16(parse_register_number(tokens[1]));
                ofile.writeByte((parse_writemask(tokens[1])<<4)|(parse_sourcelen(tokens[2])));
                write_int16(parse_register_number(tokens[2]));
                ofile.writeByte(parse_sourceselect(tokens[2]));
                if ( find_first_of(tokens[3],"t",0) == -1 ) {
                    error("invalid texture type.");
                }
                texture_id = tokens[3].substr(1);
                ofile.writeByte(texture_id);
            } break;

            case    pbjLoadConstant: {
                if ( tokens.length < 3 ) error("missing parameter(s).");
                if ( tokens.length > 3 ) error("too many parameters.");
                reg =  parse_register_number(tokens[1]);
                write_int16(reg);
                ofile.writeByte((parse_writemask(tokens[1])<<4));
                if ( reg < 32768 ) {
                    write_float(tokens[2]);
                } else {
                    write_int16(tokens[2]);
                    write_int16(0);
                }
            } break;
            
            case    pbjSelect: {
                if ( tokens.length < 5 ) error("missing parameter(s).");
                if ( tokens.length > 5 ) error("too many parameters.");
                if ( matrix_type(tokens[0]) ) {
                    if ( find_first_of(tokens[1],".",0) != -1 ||
                        find_first_of(tokens[2],".",0) != -1 ||
                        find_first_of(tokens[3],".",0) != -1 ||
                        find_first_of(tokens[4],".",0) != -1 ) {
                        error("invalid register type.");
                    }
                    write_int16(parse_register_number(tokens[1]));
                    len = parse_sourcelen(tokens[2]);
                    if ( parse_sourcelen(tokens[1]) != len ) {
                        error("invalid dst length, must match src.");
                    }
                    ofile.writeByte(matrix_type(tokens[0])<<2);
                    reg =  parse_register_number(tokens[2]);
                    if ( reg < 32768 ) {
                        error("src must be an integer.");
                    }
                    write_int16(reg);
                    ofile.writeByte(0);
                    ofile.writeByte(0);
                    if ( parse_sourcelen(tokens[2]) != len ) {
                        error("invalid src1 length, must match src.");
                    }
                    write_int16(parse_register_number(tokens[3]));
                    write_int16(0);
                    if ( parse_sourcelen(tokens[2]) != len ) {
                        error("invalid src2 length, must match src.");
                    }
                    write_int16(parse_register_number(tokens[4]));
                    write_int16(0);
                } else {
                    write_int16(parse_register_number(tokens[1]));
                    len = parse_sourcelen(tokens[2]);
                    if ( parse_sourcelen(tokens[1]) != len ) {
                        error("invalid dst length, must match src.");
                    }
                    ofile.writeByte((parse_writemask(tokens[1])<<4)|len);
                    reg =  parse_register_number(tokens[2]);
                    if ( reg < 32768 ) {
                        error("src must be an integer.");
                    }
                    write_int16(reg);
                    ofile.writeByte(parse_sourceselect(tokens[2]));
                    ofile.writeByte(0);
                    if ( parse_sourcelen(tokens[2]) != len ) {
                        error("invalid src1 length, must match src.");
                    }
                    write_int16(parse_register_number(tokens[3]));
                    ofile.writeByte(parse_sourceselect(tokens[3]));
                    ofile.writeByte(parse_sourcelen(tokens[3])<<6);
                    if ( parse_sourcelen(tokens[2]) != len ) {
                        error("invalid src2 length, must match src.");
                    }
                    write_int16(parse_register_number(tokens[4]));
                    ofile.writeByte(parse_sourceselect(tokens[4]));
                    ofile.writeByte(parse_sourcelen(tokens[4])<<6);
                }
            } break;

            case    pbjIf: {
                if ( tokens.length < 2 ) error("missing parameter(s).");
                if ( tokens.length > 2 ) error("too many parameters.");
                write_int16(0);
                len = parse_sourcelen(tokens[1]);
                if ( len != 0 ) {
                    error ("invalid source length.");
                }
                ofile.writeByte(len);
                reg =  parse_register_number(tokens[1]);
                if ( reg < 32768 ) {
                    error ("invalid register type.");
                }
                write_int16(reg);
                ofile.writeByte(parse_sourceselect(tokens[1]));
                ofile.writeByte(0);
            } break;

            case    pbjElse: {
                if ( tokens.length < 1 ) error("missing parameter(s).");
                if ( tokens.length > 1 ) error("too many parameters.");
                write_int16(0);
                ofile.writeByte(0);
                write_int16(0);
                ofile.writeByte(0);
                ofile.writeByte(0);
            } break;

            case    pbjEndif: {
                if ( tokens.length < 1 ) error("missing parameter(s).");
                if ( tokens.length > 1 ) error("too many parameters.");
                write_int16(0);
                ofile.writeByte(0);
                write_int16(0);
                ofile.writeByte(0);
                ofile.writeByte(0);
            } break;
            
            case    pbjParameterMetaData: {
                if ( tokenTypes[2] == 1 ) {
                    if ( tokens.length < 3 ) error("missing parameter(s).");
                    if ( tokens.length > 3 ) error("too many parameters.");
                } else {
                    if ( tokens.length < 2 + typeSizes[meta_type] ) error("missing parameter(s).");
                    if ( tokens.length > 2 + typeSizes[meta_type] ) error("too many parameters.");
                }
                if ( tokenTypes[2] == 1 ) {
                    ofile.writeByte(pbjTypeString);
                    ofile.writeUTFBytes(tokens[1]);
                    ofile.writeByte(0);
                    ofile.writeUTFBytes(tokens[2]);
                    ofile.writeByte(0);
                } else {
                    ofile.writeByte(meta_type);
                    ofile.writeUTFBytes(tokens[1]);
                    ofile.writeByte(0);
                    switch ( meta_type ) {
                        case    pbjTypeFloat4x4:
                        case    pbjTypeFloat3x3:
                        case    pbjTypeFloat2x2:
                        case    pbjTypeFloat4:
                        case    pbjTypeFloat3:
                        case    pbjTypeFloat2:
                        case    pbjTypeFloat: {
                            for ( c=0; c<typeSizes[meta_type] ; c++ ) {
                                write_float(tokens[2+c]);
                            }
                        } break;
                        case    pbjTypeBool4:
                        case    pbjTypeInt4:
                        case    pbjTypeBool3:
                        case    pbjTypeInt3:
                        case    pbjTypeBool2:
                        case    pbjTypeInt2:
                        case    pbjTypeBool:
                        case    pbjTypeInt: {
                            for ( c=0; c<typeSizes[meta_type] ; c++ ) {
                                write_int16(tokens[2+c]);
                            }
                        } break;
                    }
                }
            } break;

            case    pbjKernelMetaData: {
                if ( tokens.length < 3 ) error("missing parameter(s).");
                if ( tokens.length > 3 ) error("too many parameters.");
                if ( tokenTypes[2] == 1 ) {
                    ofile.writeByte(pbjTypeString);
                } else {
                    ofile.writeByte(pbjTypeInt);
                }
                ofile.writeUTFBytes(tokens[1]);
                ofile.writeByte(0);
                if ( tokenTypes[2] == 1 ) {
                    ofile.writeUTFBytes(tokens[2]);
                    ofile.writeByte(0);
                } else {
                    write_int16(tokens[2]);
                }
            } break;

            case    pbjParameterData: {
                if ( tokens.length < 5 ) error("missing parameter(s).");
                if ( tokens.length > 5 ) error("too many parameters.");
                if ( tokens[4] != "in" &&
                    tokens[4] != "out") {
                    error("invalid parameter direction.");
                }
                reg =  parse_register_number(tokens[3]);
                if ( tokens[4] == "in" ) {
                    ofile.writeByte(1);
                } else {
                    if ( reg >= 32768 ) {
                        error("invalid output register type, needs to be float.");
                    }
                    ofile.writeByte(2);
                }
                if ( types[tokens[2]] == 0 ) {
                    error("invalid parameter type.");
                }
                meta_type = types[tokens[2]];
                ofile.writeByte(meta_type);
                write_int16(reg);
                ofile.writeByte(parse_writemask(tokens[3]));
                ofile.writeUTFBytes(tokens[1]);
                ofile.writeByte(0);
            } break;
            
            case    pbjTextureData: {
                if ( tokens.length < 3 ) error("missing parameter(s).");
                if ( tokens.length > 3 ) error("too many parameters.");
                if ( find_first_of(tokens[2],"t",0) == -1 ) {
                    error("invalid texture type.");
                }
                texture_id = 0;
                var channels:int   = parse_sourcelen(tokens[2])+1;
                var dot_pos:int = find_first_of(tokens[2],".",0);
                if ( dot_pos == -1 ) {
                    texture_id = tokens[2].substr(1);
                } else {
                    texture_id = tokens[2].substr(1,dot_pos);
                }
                ofile.writeByte(texture_id);
                ofile.writeByte(channels);
                ofile.writeUTFBytes(tokens[1]);
                ofile.writeByte(0);
            } break;
            
            case    pbjKernelName: {
                if ( tokens.length < 2 ) error("missing parameter(s).");
                if ( tokens.length > 2 ) error("too many parameters.");
                write_int16(tokens[1].length);
                ofile.writeUTFBytes(tokens[1]);
            } break;
            
            case    pbjVersionData: {
                var version:int;
                if ( tokens.length < 2 ) error("missing parameter(s).");
                if ( tokens.length > 2 ) error("too many parameters.");
                version = tokens[1];
                ofile.writeByte(version);
                ofile.writeByte(0);
                ofile.writeByte(0);
                ofile.writeByte(0);
            } break;
            
            default: {
                error("unrecognized keyword.");
            } break;
        }
        linen++;
    }
}

/////// end of apbj port //////////////////////////////////////////////////////////////////////

private var doobShader:String = 'version  1\nname  "NewFilter"\nkernel  "namespace", "Hypnotic"\nkernel  "vendor", "Mr.doob"\nkernel  "version", 1\nkernel  "description", "Hypnotic effect"\n\nparameter "_OutCoord", float2, f0.rg, in\n\ntexture  "src", t0\n\nparameter "dst", float4, f1, out\n\nparameter "imgSize", float2, f0.ba, in\nmeta  "defaultValue", 512, 512\nmeta  "minValue", 0, 0\nmeta  "maxValue", 512, 512\n\nparameter "center", float2, f2.rg, in\nmeta  "defaultValue", 256, 256\nmeta  "minValue", 0, 0\nmeta  "maxValue", 512, 512\n\nparameter "offset", float2, f2.ba, in\n\n;----------------------------------------------------------\n\nmov f3.rg, f0.rg\nsub f3.rg, f2.rg\nrcp f3.ba, f0.ba\nmul f3.ba, f3.rg\nmov f3.rg, f3.ba\nset f3.b, 3.14159\nmov f3.a, f3.g\natan2 f3.a, f3.r\nmov f4.r, f3.a\nset f3.a, 2\nmov f4.g, f3.r\npow f4.g, f3.a\nset f3.a, 2\nmov f4.b, f3.g\npow f4.b, f3.a\nmov f3.a, f4.g\nadd f3.a, f4.b\nsqr f4.g, f3.a\nmov f3.a, f4.g\nset f4.g, 0\nset f4.b, 0\nset f4.a, 0\nadd f4.g, f2.b\nadd f4.b, f2.a\ncos f5.r, f4.r\nrcp f5.g, f3.a\nmul f5.g, f5.r\nadd f4.g, f5.g\nsin f5.r, f4.r\nrcp f5.g, f3.a\nmul f5.g, f5.r\nadd f4.b, f5.g\nset f5.r, 1\nset f5.g, 0.1\nmov f5.b, f3.a\npow f5.b, f5.g\nrcp f5.g, f5.b\nmul f5.g, f5.r\nadd f4.a, f5.g\nmul f4.g, f0.b\nmul f4.b, f0.a\nset f5.r, 0\nltn f4.g, f5.r\nmov i1.r, i0.r\n\nif i1.r\n\nset f5.r, 0\nsub f5.r, f4.g\nrcp f5.g, f0.b\nmul f5.g, f5.r\nceil f5.r, f5.g\nmov f5.g, f0.b\nmul f5.g, f5.r\nadd f4.g, f5.g\n\nend  \n\nset f5.r, 0\nltn f4.b, f5.r\nmov i1.r, i0.r\n\nif i1.r\n\nset f5.r, 0\nsub f5.r, f4.b\nrcp f5.g, f0.a\nmul f5.g, f5.r\nceil f5.r, f5.g\nmov f5.g, f0.a\nmul f5.g, f5.r\nadd f4.b, f5.g\n\nend  \n\nltn f0.b, f4.g\nmov i1.r, i0.r\n\nif i1.r\n\nrcp f5.r, f0.b\nmul f5.r, f4.g\nfloor f5.g, f5.r\nmov f5.r, f0.b\nmul f5.r, f5.g\nsub f4.g, f5.r\n\nend  \n\nltn f0.a, f4.b\nmov i1.r, i0.r\n\nif i1.r\n\nrcp f5.r, f0.a\nmul f5.r, f4.b\nfloor f5.g, f5.r\nmov f5.r, f0.a\nmul f5.r, f5.g\nsub f4.b, f5.r\n\nend  \n\nmov f5.r, f4.g\nmov f5.g, f4.b\ntexn f6, f5.rg, t0\nmov f1, f6\nmul f1.rgb, f4.aaa\n';
private var tutShader:String = '; PBJ Assembly tutorial\n;\n; Disclaimer:\n;   This is undocumented territory, and I\'m making this shit up as I go along. \n;   Expect errors on my part.\n;\n; First off, this is the code window, here you can write your assebmly code. \n; On the right is the preview area which shows your shader applied to a bitmap.\n; The preview will be updated as you type in your code. On the bottom you can \n; see error messages and your shader\'s bytecode in base64 encoding.\n;\n; If your not viewing this in fullscreen mode, click the fullscreen button now, \n; it\'s much easier that way.\n;\n; General syntax:\n;    As you may have guessed, everything after a semicolon is a comment, and is\n;    ignored by the assembler. The first word on a line of code is the name of \n;    the asm instruction, optionally followed by one or more comma separated \n;    arguments.\n; \n; Most pbj files start with something like this:     \n\nversion  1\nname  "Hoge"\nkernel  "namespace", "Foo"\nkernel  "vendor", "yonatan"\nkernel  "version", 1\nkernel  "description", "Tutorial"\n\n; This is just metadata and is not needed for your shader to work. In fact you\n; can delete the instructions above right now. Next is the parameters section:\n\nparameter "_OutCoord", float2, f0.rg, in\ntexture  "src", t0\nparameter "dst", float4, f1, out\n\n; These three are required. The names for "src" and "dst" don\'t matter, but \n; "_OutCoord" must be named "_OutCoord" or it won\'t contain the current\n; pixel\'s position. You\'ll notice there\'s no pixel4 and image4 anywhere in \n; there, just float4.\n;\n; The main difference between this and regular pixel bender code is the register\n; name (f0.rg and f1) which is used instead of a variable name.\n; There seems to be no limit on the number of registers we can use, just \n; remember - don\'t use your input registers as storage for temporary values.  \n; Bender doesn\'t like that.\n\nparameter "center", float2, f2.rg, in\nmeta  "defaultValue", 256, 256\nmeta  "minValue", 0, 0\nmeta  "maxValue", 512, 512\n\n; This is our own parameter, which we can access from Actionscript in the \n; usual fashion (we can have more than one). Since I\'m too lazy to add sliders\n; for them you\'ll need to change their default values by hand if you want to \n; test your shader with more than one input (or fork and add a UI).\n\n; Now that we have our parameters, we can start writing the actual shader code.\n\n; This line of code produces the simplest possible shader. It basically says: \n; get the value of the pixel at f0.rg (our _OutCoords) from texture 0 (t0, \n; our "src" parameter), and put it in f1 (our "dst" register). Or in other words:\n; copy the input bitmap to the output bitmap.\n\ntexn f1, f0.rg, t0 ; texn is sampleNearest, texb is for billinear interpolation\n\n; The set instruction lets us set the value of a register. This is useful since \n; most (all?) other instruction can\'t take numbers as parameters, only registers. \n; Uncomment the next line to see it in action.\n\n; set f1.r, 0.5 ; f1 is our output, remember?\n\n; set, like most instructions takes a dst and a src parameter. dst, the 1st one,\n; is where the result gets stored.\n;\n; Now let\'s say we want our shader to cut out a 100px circle located at the \n; coordinates provided to us in the "center" parameter. So we want to do\n; something like:\n;\n;   x = center.x - pixel.x;\n;   y = center.y - pixel.y;\n;\n;   if( x*x + y*y < 100*100 ) {\n;     output.rgb = 0;\n;   }\n;\n; ok, let\'s uncomment these:\n\n; mov f3.rg, f2.rg ; stores our center coordinates in f3.rg\n; sub f3.rg, f0.rg ; subtracts our outcoords from f3.rg (remeber? the 1st\n;                  ; parameter is where the result gets stored)\n; mul f3.rg, f3.rg ; squares our x and y\n; add f3.r, f3.g   ; adds them up and stores the result in f3.r\n; set f3.g, 10000  ; since we don\'t need f3.g anymore we\'ll put 100*100 there\n\n; So now f3.r is x*x+y*y and f3.g is 100000. We need to compare them. The ltn \n; (less-than) instruction does just that, but it doesn\'t store the result in\n; either of its\' parameters. Instead it puts it in i0 (an integer register).\n\n; ltn f3.r, f3.g   ; will check if f3.r < f3.g\n; if i0.r          ; and you can probably guess what these instructions do...\n; set f1.rgb,0\n; end\n\n; On a side note, decompiled PBJs (at least the one I looked at) don\'t ever do:\n;   if i0.r\n; Instead they do:\n;   mov i1.r, i0.r\n;   if i1.r\n; Don\'t ask me why.\n\n; In conclusion -\n;    So you see, with only 20 lines of assembly code we\'ve managed to build\n;    a fairly ugly and useless shader. Who ever said assembly programming\n;    was hard?\n\n';
private var ballsShader:String = '; 3 Metaballs - this is the shader used in http://wonderfl.net/c/k6FT\n\nparameter "_OutCoord", float2, f0.rg, in\n\ntexture  "src", t0\n\nparameter "dst", float4, f1, out\n\nparameter "size", float2, f2.rg, in\nmeta  "defaultValue", 512, 512\nmeta  "minValue", 0, 0\nmeta  "maxValue", 512, 512\n\nparameter "exponent", float, f4.r, in ; cutoff\nmeta  "defaultValue", 10\nmeta  "minValue", 0\nmeta  "maxValue", 100\n\nparameter "center1", float3, f5.rgb, in ; x, y, size\nmeta  "defaultValue", 150, 160, 10160\nmeta  "minValue", 0, 0, 0\nmeta  "maxValue", 1, 1, 40000\n\nparameter "center2", float3, f6.rgb, in\nmeta  "defaultValue", 100, 400, 11160\nmeta  "minValue", 0, 0, 0\nmeta  "maxValue", 1, 1, 40000\n\nparameter "center3", float3, f7.rgb, in\nmeta  "defaultValue", 400, 50, 11160\nmeta  "minValue", 0, 0, 0\nmeta  "maxValue", 1, 1, 40000\n\n;----------------------------------------------------------\n\nset f1.rgb, 0\n\nmov f3.ba, f5.rg\nsub f3.ba, f0.rg\nmul f3.ba, f3.ba\nadd f3.a, f3.b\nmov f3.b, f5.b\ndiv f3.b, f3.a\nadd f1.r, f3.b\n\nmov f3.ba, f6.rg\nsub f3.ba, f0.rg\nmul f3.ba, f3.ba\nadd f3.a, f3.b\nmov f3.b, f6.b\ndiv f3.b, f3.a\nadd f1.r, f3.b\n\nmov f3.ba, f7.rg\nsub f3.ba, f0.rg\nmul f3.ba, f3.ba\nadd f3.a, f3.b\nmov f3.b, f7.b\ndiv f3.b, f3.a\nadd f1.r, f3.b\n\npow f1.r, f4.r\nmov f1.g, f1.r\nmov f1.b, f1.r\n\nset f1.a, 1\n';
private var brotShader:String = '; This is a single iteration of a mandelbrot generator.\n\n; The code at http://wonderfl.net/c/6GQX duplicates the iteration and endif code at runtime.\n\n; START:\ntexture  "src", t0\nparameter "_OutCoord", float2, f0.rg, in\nparameter "dst", float4, f1, out\nparameter "size", float2, f0.ba, in\nmeta "defaultValue", 512, 512\nmeta "minValue", 100, 100\nmeta "maxValue", 1000, 1000\nparameter "center", float2, f2.rg, in\nmeta "defaultValue", -0.5, 0\nmeta "minValue", -2, -1\nmeta "maxValue", 2, 1\nparameter "zoomMajor", float, f3.r, in\nmeta "defaultValue", 0\nmeta "minValue", 0\nmeta "maxValue", 20\n\nset f1, 0\nset f10.a, 0\nset f10.b, 1\nset f10.g, 2\nset f10.r, 4\ndiv f0.rg, f0.ba ; f0.rg = pos / size\nset f4.rg, 0.5\nsub f0.rg, f4.rg\nset f4.rg, 4\nmul f0.rg, f4.rg\nexp f4.r, f3.r ;zoom\ndiv f0.r, f4.r\ndiv f0.g, f4.r\nadd f0.rg, f2.rg ; centering\nmov f4.rg, f0.rg\n\n; ITERATION:\nmov f4.ba, f4.rg ; f4.ba = old x, old y\nmul f4.rg, f4.rg ;f4.rg = x*x, y*y\nmov f5.b, f4.r\nadd f5.b, f4.g ;f5.b = x*x+y*y\nltn f5.b, f10.r\nif i0.r ;if x*x+y*y < 4\nadd f10.a, f10.b ;iteration_counter++\nmul f4.a, f4.b\nadd f4.a, f4.a ; f4.a = 2xy\nsub f4.r, f4.g ; f4.r = x*x - y*y\nmov f4.g, f4.a\nadd f4.rg, f0.rg ; f4.rg = x*x - y*y + pixel_x, 2xy + pixel_y\n\n; ENDIF:\nend\n\n; FINISH:\ntan f4.r, f4.g\nabs f4.r, f4.r\nmov f1.r, f4.r\nmov f1.g, f4.r\nmov f1.b, f4.r\nset f1.a, 1\n';

private var bmp:Shape;

public function init():void
{
	bmp = new Shape;
	bmp.graphics.beginFill(0);
	bmp.graphics.drawRect(0, 0, 512, 512);
	bmp.graphics.beginFill(0xFFFFFF);
	for(var x:int=0; x<16; x++) {
		for(var y:int=0; y<16; y++) {
			if((x+y)&1) {
				bmp.graphics.drawRect(x*32, y*32, 32, 32);
			}
		}
	}
	
        init_map();
	code.text = doobShader;
	shaderOutput.rawChildren.addChild(bmp);
	build();
}

import mx.utils.Base64Encoder;

public function build():void { 
	ifile = code.text;
	ofile = new ByteArray;
	try {
		parse();
	} catch (e:Error) {
		status.htmlText = e.message;
		status.setStyle("color", 0xAA0000);
		return;
	}

        var enc:Base64Encoder = new Base64Encoder();
	enc.encodeBytes(ofile, 0, ofile.length);
	try {
	var shader:Shader = new Shader(ofile);
	var filter:ShaderFilter = new ShaderFilter(shader);
	bmp.filters = [filter];
	} catch (e:Error) {
		status.text = "Bad bytcode :-(\n" + e.message + "\nShader in base64 encoding:\n\n" + enc.toString();
		status.setStyle("color", 0xAA0000);
		return;
	}

	status.text = "No errors! Shader in base64 encoding:\n\n" + enc.toString();
	status.setStyle("color", 0);
}
]]>
</mx:Script>
</mx:Application>
