<?xml version="1.0" encoding="utf-8"?>
<s:Application xmlns:fx="http://ns.adobe.com/mxml/2009" 
               xmlns:s="library://ns.adobe.com/flex/spark" 
               xmlns:mx="library://ns.adobe.com/flex/mx"
               width="465" height="465">
    <s:VGroup left="10" top="10" right="10" bottom="10">
        <s:Button click="onClick();" label="load" />
        <s:TextArea id="t" width="100%" height="100%"/>
    </s:VGroup>
    <fx:Script>
        <![CDATA[
            /*
                ライブラリは開発中。
                しかし、デコードしたデータの文法が分からない…
             * */
            import mx.utils.Base64Decoder;
            
            private const pbj_tutorial:String = ""+
                "pQEAAACkCwBDaGVja2VyRmlsbKAMbmFtZXNwYWNlAGNvbS5hZG9iZS5leGFtcGxlAKAMdmVuZG9y" +
                "AEFkb2JlIFN5c3RlbXMgSW5jLgCgCHZlcnNpb24AAQCgDGRlc2NyaXB0aW9uAEEgY2hlY2tlcmVk" +
                "IGZpZWxkIGdlbmVyYXRvcgChAQIAAAxfT3V0Q29vcmQAoQIEAQAPZHN0AKEBAQAAAmNoZWNrZXJT" +
                "aXplAKIBZGVmYXVsdFZhbHVlAEEgAACiAW1pblZhbHVlAD+AAACiAW1heFZhbHVlAEKWAAChAQQC" +
                "AA9jb2xvckEAogRkZWZhdWx0VmFsdWUAAAAAAD+AAAA/gAAAP4AAAKEBBAMAD2NvbG9yQgCiBGRl" +
                "ZmF1bHRWYWx1ZQAAAAAAAAAAAAAAAAA/gAAAHQQAwQAAEAAyAAAQQAAAAB0EACAAAIAAAwQAIAAA" +
                "wAAdAAAQBAAAAAgAABAEAIAAHQQAIAAAwAAyAAAQQAAAAB0EABAAAIAAAwQAEAAAwAAdAAAQBABA" +
                "AAgAABAEAMAAHQQAEAAAwAAqBAAgAACAAB0BgIAAgAAAKgQAEAAAgAAdAYBAAIAAAB0BgCABgAAA" +
                "LwGAIAGAQAAzBQDwAYCAAAIAG8ADABvAHQEA8wUAGwA=" ;
            private const pbj_myCode:String = ""+
                "pQEAAACkDQBkZWZhdWx0RmlsdGVyoAxuYW1lc3BhY2UAemFoaXIxOTI5AKAMdmVuZG9yAHphaGly" +
                "AKAIdmVyc2lvbgABAKAMZGVzY3JpcHRpb24AUGl4ZWxCZW5kZXIgZGVmYXVsdCAnbmV3IGtlcm5l" +
                "bCcgAKEBAgAADF9PdXRDb29yZACjAARzcmMAoQIEAQAPZHN0ADACAPEAABAAHQEA8wIAGwA=";
            //
            
            private var fr:FileReference;
            private function onClick():void{
                fr = new FileReference();
                fr.addEventListener(Event.SELECT, onSelect);
                fr.browse([new FileFilter("Load PBJ File","*.pbj")]);
            }
            private function onSelect(e:Event):void{
                fr.removeEventListener(Event.SELECT, onSelect);
                fr.addEventListener(Event.COMPLETE, onLoadComp);
                fr.load();
            }
            private function onLoadComp(e:Event):void{
                t.text="";
                decompile(fr.data);
            }
            
            private function init():void{
                var dec:Base64Decoder = new Base64Decoder();
                //dec.decode( pbj_tutorial );
                dec.decode( pbj_myCode );
                decompile( dec.toByteArray() );
            }
            private function littleToBig32( value:uint ):uint{
                var a:int = value & 0xFF;
                var b:int = (value >> 8) & 0xFF;
                var c:int = (value >> 16) & 0xFF;
                var d:int = (value >> 24) & 0xFF;
                return (a <<24) | (b<<16) | (c<<8) | d;
            }
            private function littleToBig16(value:uint):uint{
                return ((value>>8) & 0xFF) | ((value<<8) & 0xFF00);
            }
            private function readFloat( bytes:ByteArray ):Number{
                var n:Number = 0;
                bytes.endian = "bigEndian";
                n = bytes.readFloat();
                bytes.endian = "littleEndian";
                return n;
            }
            private function isIntReg( value:uint ):Boolean{
                return (value & 0x8000) ? true : false;
            }
            private function Swizzle( index:int, swizzle:int):int{
                return (swizzle>>(6-index*2)) & 3;
            }
            private function BitCount( value:uint ):int{
                value = (value & 0x55555555) + (value >> 1 & 0x55555555);
                value = (value & 0x33333333) + (value >> 2 & 0x33333333);
                value = (value & 0x0f0f0f0f) + (value >> 4 & 0x0f0f0f0f);
                value = (value & 0x00ff00ff) + (value >> 8 & 0x00ff00ff);
                return (value & 0x0000ffff) + (value >>16 & 0x0000ffff);
            }
            private function IndexToDstWithMask( index:int, mask:int):int{
                return map[(mask<<2|index)];
            }
            private function printMask(mask:int, type:int):void{
                if(mask != 0xF){
                    var str:String = ".";
                    for( var i:int = 0, len:int =typeSize[type]; i<len; i++){
                        _trace(str, channelName[IndexToDstWithMask(i,mask)]);
                    }
                }
            }
            private function printDst(index:uint, mask:int, size:int):void{
                var str:String = "";
                if( index >= 32768){
                    str += String(index - 32768);
                }else{
                    str += String(index);
                }
                if(mask != 0xF){
                    str += ".";
                    for( var i:int = 0; i< size; i++){
                        _trace(str, channelName[IndexToDstWithMask(i,mask)]);
                    }
                }
            }
            private function printSrc( index:int, swizzle:int, size:int):void{
                var str:String = "";
                if( index >= 32768){
                    str += String(index - 32768);
                }else{
                    str += String(index);
                }
                if(swizzle != 0x1B){
                    str += ".";
                    for( var i:int = 0; i< size; i++){
                        _trace(str, channelName[Swizzle(i,swizzle)]);
                    }
                }
            }
            
            private function readString( bytes:ByteArray ):String{
                var pos:int = bytes.position;
                var len:int = 0;
                while( bytes.readUnsignedByte() > 0 ) len++;
                bytes.position = pos;
                var str:String = bytes.readUTFBytes(len);
                bytes.position++;
                return str;
            }
            
            private function readMetaData( bytes:ByteArray, op:int ):void{
                var type:int = bytes.readUnsignedByte();
                var _name:String;
                var _meta:String;
                if( type == pbjTypeString ){
                    _name = readString( bytes );
                    _meta = readString( bytes );
                    if( op == pbjParameterMetaData){
                        _trace( "Param " + _name, _meta);
                    }else{
                        _trace( "Kernel " + _name, _meta);
                    }
                }else{
                    _name = readString( bytes );
                    if( op == pbjParameterMetaData ){
                        
                        var elm:int = 0;
                        var i:int;
                        switch(type){
                            case pbjTypeFloat4x4: elm +=7;
                            case pbjTypeFloat3x3: elm +=5;
                            case pbjTypeFloat2x2: case pbjTypeFloat4:
                                elm ++;
                            case pbjTypeFloat3:
                                elm ++;
                            case pbjTypeFloat2:
                                elm ++;
                            case pbjTypeFloat:
                                elm ++;
                                for(i=0; i<elm; i++)_trace("    " + _name, readFloat( bytes ));
                                break;
                            case pbjTypeBool4: case pbjTypeInt4:
                                elm++;
                            case pbjTypeBool3: case pbjTypeInt3:
                                elm++;
                            case pbjTypeBool2: case pbjTypeInt2:
                                elm++;
                            case pbjTypeBool: case pbjTypeInt:
                                elm++;
                                for(i=0; i<elm; i++)_trace("\t" + _name,bytes.readShort());
                                break;
                        }
                    }else{
                        switch(type){
                            case pbjTypeInt:
                                _trace("Kernel "+_name, bytes.readUnsignedShort());
                                break;
                            default : err(); break;
                        }
                    }
                }
            }
            private function readParameter( bytes:ByteArray ):void{
                var _qualifier:int = bytes.readUnsignedByte();
                var _type:int = bytes.readUnsignedByte();
                if( _type == pbjTypeString || _qualifier > 2 || _qualifier < 1){
                    err();
                }else{
                    var dst:uint = bytes.readUnsignedShort();
                    var writeMask:int = bytes.readUnsignedByte();
                    var paramName:String = readString( bytes );
                    _trace("\nParameter", paramName )
                    _trace("    type ( " + _type +")", typeNames[ _type ]);
                    _trace("    dst",dst);
                    _trace("    writeMask",writeMask);
                    _trace("    size", typeSize[ _type ]);
                    _trace("    qualifier", qualifierName[_qualifier]);
                }
            }
            private function readTexture( bytes:ByteArray ):void{
                var _index:int = bytes.readUnsignedByte();
                var _channels:int = bytes.readUnsignedByte();
                _trace("\n" + "Input", readString(bytes) );
                _trace("    index", _index);
                _trace("    channel", _channels);
            }
            private function readArithmetic(    bytes:ByteArray, op:int, matrixSize:int,
                                                writeMask:int, readSize:int, dst:uint, src:uint, readSwizzle:int):void{
                //
                if(matrixSize){
                    if(writeMask != 0){
                        err();
                    }
                    switch( op ){
                        case pbjCopy: case pbjAdd: case pbjSubtract: case pbjMultiply:
                        case pbjReciprocal: case pbjMatrixMatrixMultiply:
                            _trace(namesLo[op], namesMatrix[matrixSize] );
                            _trace("dst",dst);
                            _trace("src",src);
                            break;
                        default:
                            _trace(namesLo[op],"operation now allowed on matrices");
                            err();
                            break;
                    }
                }else{
                    var dstInt:Boolean = false;
                    var srcInt:Boolean = false;
                    switch( op ){
                        case pbjAdd: case pbjSubtract:
                        case pbjMultiply: case pbjDivide:
                            _dst();
                            break;
                    }if( op == pbjCopy ){
                        if( isIntReg(dst) != isIntReg(src) ){
                            err();
                        }
                    }else{
                        if( isIntReg(dst) != dstInt ){
                            err();
                        }
                        if( isIntReg(src) != srcInt ){
                            err();
                        }
                        _trace("", namesLo[op] );
                        if( String(namesLo[op]).length < 4 ){
                        }else{
                        }
                        printDst( dst, writeMask, readSize );
                        printSrc( src, readSwizzle, readSize);
                    }
                }
                function _dst():void{
                    if(isIntReg( dst ) ){
                        dstInt = true;
                        srcInt = true;
                    }
                }
            }
            
            private function readBoolTo(op:int,mask:int, swizzle:int, size:int, src:uint, dst:uint):void{
                if( !isIntReg(src) ){
                    err();
                }
                if( !isIntReg(dst) ){
                    err();
                }
                _trace(namesLo[op],"");
                printDst(dst,mask,size);
                printSrc(src,swizzle,size);
            }
            
            private function readAnyAll(op:int,mask:int, swizzle:int, size:int, src:uint, dst:uint):void{
                if( !isIntReg(src) ){
                    err();
                }
                if( !isIntReg(dst) ){
                    err();
                }
                _trace(namesLo[op],"");
                printDst(dst,mask,size);
                printSrc(src,swizzle,size);
            }
            
            private function readVMM(op:int, m_size:int,mask:int, size:int, src:uint, dst:uint):void{
                if(BitCount(mask) != (m_size + 1)){
                    err("readVMM");
                }
                _trace(namesLo[op],namesMatrix[m_size]);
                printDst(dst,mask,size);
            }
            
            private function readMVM(op:int, m_size:int,mask:int, size:int, src:uint, dst:uint):void{
                if(BitCount(mask) != (m_size + 1)){
                    err("readMVM");
                }
                _trace(namesLo[op],namesMatrix[m_size]);
                printDst(dst,mask,size);
            }
            
            private function readNormalize(op:int,mask:int, swizzle:int, size:int, src:uint, dst:uint):void{
                if( isIntReg(src) || isIntReg(dst) ){
                    err("readNormalize");
                }
                if(size == pbjSampleSizeScalar){
                    err("readNormalize :: scalar");
                }else{
                    _trace(namesLo[op],"");
                    printDst(dst,mask,size);
                    printSrc(src,swizzle,size);
                }
            }
            
            private function readDistans(op:int, m_size:int,mask:int,swizzle:int,size:int, src:uint, dst:uint):void{
                if(m_size){
                    err("readDistans");
                }
                if( isIntReg(src) || isIntReg(dst) ){
                    err("readDistans");
                }
                if(size == pbjSampleSizeScalar){
                    err("readDistans :: scalar");
                }else{
                    _trace(namesLo[op],"");
                    printDst(dst,mask,1);
                    printSrc(src,swizzle,size);
                }
            }
            
            private function readDotProduct(op:int, m_size:int,mask:int,swizzle:int,size:int, src:uint, dst:uint):void{
                if(m_size){
                    err("readDotProduct");
                }
                if( isIntReg(src) || isIntReg(dst) ){
                    err("readDotProduct");
                }
                _trace(namesLo[op],"");
                printDst(dst,mask,1);
                printSrc(src,swizzle,size);
            }
            
            private function readCrossProduct(op:int, m_size:int,mask:int, swizzle:int, size:int, src:uint, dst:uint):void{
                if(m_size){
                    err();
                }
                if( isIntReg(src) || isIntReg(dst)){
                    err();
                }
                if(size != 3){
                    err();
                }
                
                _trace(namesLo[op],"");
                printDst(dst,mask,size);
                printSrc(src,swizzle,size);
                
            }
            
            private function readEqual(op:int, m_size:int,mask:int, swizzle:int, size:int, src:uint, dst:uint):void{
                if(m_size){
                    _trace(namesLo[op],"mtr : " + namesMatrix[m_size] + "\ndst : " + dst + "\nsrc : " + src);
                }else{
                    _trace(namesLo[op],"");
                    printDst(dst,mask,size);
                    printSrc(src,swizzle,size);
                }
            }
            private function readEqual2(op:int, m_size:int,mask:int, swizzle:int, size:int, src:uint, dst:uint):void{
                if(m_size){
                    err();
                }
                if( isIntReg(src) != isIntReg(dst)){
                    err();
                }
                _trace(namesLo[op],"");
                if( String(namesLo[op]).length < 4){
                }
                printDst(dst,mask,size);
                printSrc(src,swizzle,size);
            }
            
            private function readLogical(op:int, m_size:int,mask:int, swizzle:int, size:int, src:uint, dst:uint):void{
                if(m_size) err();
                if( !isIntReg(src) || !isIntReg(dst)) err();
                if( size != pbjSampleSizeScalar ) err();
                
                _trace(namesLo[op],"");
                printDst(dst,mask,size);
                printSrc(src,swizzle,size);
            }
            
            private function readSampling(op:int, op1:uint, mask:int, swizzle:int, size:int, src:uint, dst:uint):void{
                if(isIntReg(dst)){
                    err();
                }
                _trace(namesLo[op],"");
                printDst(dst,mask,size);
                printSrc(src,swizzle,size);
                _trace("id", op1 & 0xFF);
            }
            
            private function readLoadConstant( op1:uint, mask:int, size:int, dst:uint):void{
                var valuei:uint = op1;
                if( isIntReg(dst) ){
                }else{
                }
            }
            
            private function readSelect( bytes:ByteArray, op:uint, m_size:int, mask:int, swizzle:int, size:int,
                                            src:uint, dst:uint ):void{
                var op2:uint = littleToBig32( bytes.readUnsignedInt() );
                var op3:uint = littleToBig32( bytes.readUnsignedInt() );
                
                var src0:uint = Math.floor(op2 >> 16);
                var src1:uint = Math.floor(op3 >> 16);
                
                var size0:int = ((op2 >> 6 ) & 0x3) +1;
                var swizzle0:int = (op2>>8) & 0xFF;
                var size1:int = ((op3 >> 6 ) & 0x3) +1;
                var swizzle1:int = (op3>>8) & 0xFF;
                
                src0 = littleToBig16( src0 );
                src1 = littleToBig16( src1 );
                
                
                if(!isIntReg( src )){
                    err();
                }
                if( size0 != size1 ){
                    err();
                }
                if(m_size){
                    if( !isIntReg( src0 ) || !isIntReg( src1 ) ){
                        err();
                    }
                    // to do
                }else{
                    if( !isIntReg( src0 ) != !isIntReg( src1 ) || isIntReg( src0 ) != isIntReg( dst ) ){
                        err();
                    }
                    //to do
                }
            }
            private function decompile( input:IDataInput ):void{
                var ba:ByteArray = new ByteArray();
                input.readBytes(ba);
                ba.position = 0;
                ba.endian = "littleEndian"; // pbjはLittleEndian?
                
                var firstins:Boolean = true;
                
                while( ba.bytesAvailable ){
                    var op0:uint = littleToBig32( ba.readUnsignedInt() );
                    var op1:uint = littleToBig32( ba.readUnsignedInt() );
                    
                    var op:int = (op0 >> 24) & 0xFF;            
                    var dst:uint = (op0>>8) & 0xFFFF;
                    var mask:int =(op0 >> 4) & 0xF;
                    var matrixSize:int = (op0 >> 2) & 0x3;
                    var readSize:int = (op0 & 3) + 1;
                    var src:uint = (op1>>16) & 0xFFFF;
                    var swizzle:int = (op1 >> 8) & 0xFF;
                    
                    var str:String = "";
                    
                    dst = littleToBig16( dst );
                    src = littleToBig16( src );
                    //*
                    if(op <= pbjSelect){
                        if(matrixSize == 0){
                            if(op == pbjLoadConstant){
                                // ?
                            }else if(op == pbjLength){
                            }else if( op == pbjSampleNearest || op == pbjSampleBilinear){
                                if(readSize != pbjSampleSizeVector2){
                                    err("readSize != pbjSampleSizeVector2");
                                }
                            }else if( op == pbjSelect){
                                if(readSize != 1){
                                    err("readSize != 1");
                                }
                            }else{
                                if(BitCount(mask) != readSize){
                                    str += "decmpl :: " + "(" + to16(op) + ")" + " -> "  + BitCount(mask) + "!=" + readSize;
                                    str += "\n" + "pos :: "+(ba.position-8)+ " / "+ba.length;
                                    err(str);
                                }
                            }
                        }else{
                            if( isIntReg(src) || isIntReg(dst) ){
                                err(" isIntReg(src) || isIntReg(dst)");
                            }
                        }
                    }//*/
                    switch( op ){
                        case pbjNop:
                            _check();
                            _trace(namesLo[op],"");
                            break;
                        case pbjAdd: case pbjSubtract: case pbjMultiply:
                        case pbjDivide: case pbjMatrixMatrixMultiply: case pbjAtan2:
                        case pbjPow: case pbjMod: case pbjMin: case pbjMax:
                        case pbjStep: case pbjCopy: case pbjFloatToInt:
                        case pbjIntToFloat: case pbjReciprocal: case pbjSin:
                        case pbjCos: case pbjTan: case pbjASin: case pbjACos:
                        case pbjATan: case pbjExp: case pbjExp2: case pbjLog:
                        case pbjLog2: case pbjSqrt: case pbjRSqrt: case pbjAbs:
                        case pbjSign: case pbjFloor: case pbjCeil: case pbjFract:
                        case pbjFloatToBool: case pbjIntToBool:
                            _check();
                            readArithmetic( ba, op, matrixSize, mask, readSize, dst, src, swizzle);
                            break;
                        case pbjBoolToInt: case pbjBoolToFloat:
                            _check();
                            readBoolTo(op, mask, readSize, dst, src, swizzle);
                            break;
                        case pbjAny: case pbjAll:
                            _check();
                            readAnyAll(op, mask, readSize, dst, src, swizzle);
                            break;
                        case pbjVectorMatrixMultiply:
                            _check();
                            readVMM(op, matrixSize, mask, readSize, src, dst);
                            break;
                        case pbjMatrixVectorMultiply:
                            _check();
                            readVMM(op, matrixSize, mask, readSize, src, dst);
                            break;
                        case pbjNormalize:
                            _check();
                            readNormalize( op, mask, swizzle, readSize, src, dst );
                            break;
                        case pbjDistance: case pbjLength:
                            _check();
                            readDistans(op, matrixSize, mask, swizzle, readSize, src, dst);
                            break;
                        case pbjDotProduct:
                            _check();
                            readDotProduct(op, matrixSize, mask, swizzle, readSize, src, dst);
                            break;
                        case pbjCrossProduct:
                            _check();
                            readCrossProduct( op, matrixSize, mask, swizzle, readSize, src, dst);
                            break;
                        case pbjEqual: case pbjNotEqual:
                            _check();
                            readEqual( op, matrixSize, mask, swizzle, readSize, src, dst );
                            break;
                        case pbjVectorEqual: case pbjVectorNotEqual:
                        case pbjLessThan: case pbjLessThanEqual:
                            _check();
                            readEqual2( op, matrixSize, mask, swizzle, readSize, src, dst );
                            break;
                        case pbjLogicalOr: case pbjLogicalXor:
                        case pbjLogicalAnd: case pbjLogicalNot:
                            _check();
                            readLogical( op, matrixSize, mask, swizzle, readSize, src, dst );
                            break;
                        case pbjSampleBilinear: case pbjSampleNearest:
                            _check();
                            readSampling(op, op1, mask, swizzle, readSize, src, dst );
                            break;
                        case pbjLoadConstant:
                            _check();
                            readLoadConstant( op1, mask, readSize, dst );
                            break;
                        case pbjSelect:
                            _check();
                            readSelect(ba, op, matrixSize, mask, swizzle, readSize, src, dst);
                            break;
                        case pbjIf:
                            _check();
                            if( isIntReg(src)){
                                _trace(namesLo[op & 0x07], "source to be of type int");
                                err();
                            }
                            _trace("",namesLo[op]);
                            printSrc(src,swizzle,readSize);
                            break;
                        case pbjElse:
                            _check();
                            _trace("",namesLo[op]);
                            break;
                        case pbjEndif:
                            _check();
                            _trace("",namesLo[op]);
                            break;
                        case pbjKernelMetaData: case pbjParameterMetaData :
                            ba.position -= 7;
                            readMetaData( ba, op);
                            break;
                        case pbjParameterData:
                            ba.position -= 7;
                            readParameter( ba );
                            break;
                        case pbjTextureData:
                            ba.position -= 7;
                            readTexture( ba );
                            break;
                        case pbjKernelName:
                            ba.position -= 7;
                            _trace("Kernel Name", ba.readUTFBytes( ba.readUnsignedShort() ) );
                            break;
                        case pbjVersionData:
                            ba.position -= 7;
                            var _version:int = ba.readUnsignedInt();
                            if( _version != 1){
                                _trace("unsupport pbj byte code version", _version);
                            }else _trace("Kernel Version", _version);
                            break;
                        default:
                            err();
                            ba.position = ba.length;
                            break;
                    }
                }
                function _check():void{
                    if(firstins){
                        firstins = false;
                        comm();
                    }
                }
            }
            private function _trace(type:String, value:* ):void{
                t.text += type + "  ::  " + String( value ) + "\n";
            }
            private function comm( type:String = ""):void{
                _trace("\n; " + type,"-----------------------------------------------------\n\n");
            }
            private function err( msg:String ="" ):void{
                _trace("\n何これ","www\n" + msg);
            }
            private function to16( value:uint ):String{
                var str:String = "0" + value.toString( 16 ).toLocaleUpperCase();
                str = "0x" + str.substr(str.length-2,2);
                return str;
            }
            
            // pbjEnum data
            public const pbjNop:int                 = 0x00;
            public const pbjAdd:int                 = 0x01;
            public const pbjSubtract:int             = 0x02;
            public const pbjMultiply:int             = 0x03;
            public const pbjReciprocal:int             = 0x04;
            public const pbjDivide:int                 = 0x05;
            public const pbjAtan2:int                 = 0x06;
            public const pbjPow:int                 = 0x07;
            public const pbjMod:int                 = 0x08;
            public const pbjMin:int                 = 0x09;
            public const pbjMax:int                 = 0x0A;
            public const pbjStep:int                 = 0x0B;
            public const pbjSin:int                 = 0x0C;
            public const pbjCos:int                 = 0x0D;
            public const pbjTan:int                 = 0x0E;
            public const pbjASin:int                 = 0x0F;
            
            public const pbjACos:int                 = 0x10;
            public const pbjATan:int                 = 0x11;
            public const pbjExp:int                 = 0x12;
            public const pbjExp2:int                 = 0x13;
            public const pbjLog:int                 = 0x14;
            public const pbjLog2:int                 = 0x15;
            public const pbjSqrt:int                 = 0x16;
            public const pbjRSqrt:int                 = 0x17;
            public const pbjAbs:int                 = 0x18;
            public const pbjSign:int                 = 0x19;
            public const pbjFloor:int                 = 0x1A;
            public const pbjCeil:int                 = 0x1B;
            public const pbjFract:int                 = 0x1C;
            public const pbjCopy:int                 = 0x1D;
            public const pbjFloatToInt:int             = 0x1E;
            public const pbjIntToFloat:int             = 0x1F;
            
            public const pbjMatrixMatrixMultiply:int = 0x20;
            public const pbjVectorMatrixMultiply:int = 0x21;
            public const pbjMatrixVectorMultiply:int = 0x22;
            public const pbjNormalize:int             = 0x23;
            public const pbjLength:int                 = 0x24;
            public const pbjDistance:int             = 0x25;
            public const pbjDotProduct:int             = 0x26;
            public const pbjCrossProduct:int         = 0x27;
            public const pbjEqual:int                 = 0x28;
            public const pbjNotEqual:int             = 0x29;
            public const pbjLessThan:int             = 0x2A;
            public const pbjLessThanEqual:int         = 0x2B;
            public const pbjLogicalNot:int             = 0x2C;
            public const pbjLogicalAnd:int             = 0x2D;
            public const pbjLogicalOr:int             = 0x2E;
            public const pbjLogicalXor:int             = 0x2F;
            
            public const pbjSampleNearest:int         = 0x30;
            public const pbjSampleBilinear:int         = 0x31;
            public const pbjLoadConstant:int         = 0x32;
            public const pbjSelect:int                 = 0x33;
            public const pbjIf:int                     = 0x34;
            public const pbjElse:int                 = 0x35;
            public const pbjEndif:int                 = 0x36;
            public const pbjFloatToBool:int         = 0x37;
            public const pbjBoolToFloat:int         = 0x38;
            public const pbjIntToBool:int             = 0x39;
            public const pbjBoolToInt:int             = 0x3A;
            public const pbjVectorEqual:int         = 0x3B;
            public const pbjVectorNotEqual:int         = 0x3C;
            public const pbjAny:int                 = 0x3D;
            public const pbjAll:int                 = 0x3E;
            
            public const pbjKernelMetaData:int         = 0xA0;
            public const pbjParameterData:int         = 0xA1;
            public const pbjParameterMetaData:int     = 0xA2;
            public const pbjTextureData:int         = 0xA3;
            public const pbjKernelName:int             = 0xA4;
            public const pbjVersionData:int         = 0xA5;
            
            //
            public const pbjTypeFloat:int                 = 0x01;
            public const pbjTypeFloat2:int                 = 0x02;
            public const pbjTypeFloat3:int                 = 0x03;
            public const pbjTypeFloat4:int                 = 0x04;
            
            public const pbjTypeFloat2x2:int             = 0x05;
            public const pbjTypeFloat3x3:int             = 0x06;
            public const pbjTypeFloat4x4:int             = 0x07;
            
            public const pbjTypeInt:int                 = 0x08;
            public const pbjTypeInt2:int                 = 0x09;
            public const pbjTypeInt3:int                 = 0x0A;
            public const pbjTypeInt4:int                 = 0x0B;
            
            public const pbjTypeString:int             = 0x0C;
            
            public const pbjTypeBool:int             = 0x0D;
            public const pbjTypeBool2:int             = 0x0E;
            public const pbjTypeBool3:int             = 0x0F;
            public const pbjTypeBool4:int             = 0x10;
            
            //
            public const pbjSampleSizeScalar:int     = 0x01;
            public const pbjSampleSizeVector2:int     = 0x02;
            public const pbjSampleSizeVector3:int     = 0x03;
            public const pbjSampleSizeVector4:int     = 0x04;
            
            public const namesLo:Array = [
                "nop", 
                "add", 
                "sub", 
                "mul", 
                "rcp", 
                "div", 
                "atan2", 
                "pow", 
                "mod", 
                "min", 
                "max", 
                "step", 
                "sin", 
                "cos", 
                "tan", 
                "asin", 
                "acos", 
                "atan", 
                "exp", 
                "exp2", 
                "log", 
                "log2", 
                "sqr", 
                "rsqr", 
                "abs", 
                "sign", 
                "floor", 
                "ceil", 
                "fract", 
                "mov", 
                "ftoi", 
                "itof", 
                "mmmul", 
                "vmmul", 
                "mvmul", 
                "norm", 
                "len", 
                "dist", 
                "dot", 
                "cross", 
                "equ", 
                "neq", 
                "ltn", 
                "lte", 
                "not", 
                "and", 
                "or", 
                "xor", 
                "texn", 
                "texb", 
                "set", 
                "sel", 
                "if", 
                "else", 
                "end", 
                "ftob", 
                "btof", 
                "itob", 
                "btoi", 
                "vequ", 
                "vneq",  
                "any", 
                "all"
            ];// end namesLo
            
            public const namesHi:Array = [
                "kernel",
                "parameter",
                "meta",
                "texture",
                "name",
                "version"
            ];// end namesHi
            
            public const namesMatrix:Array = [
                "",
                "2x2",
                "3x3",
                "4x4"
            ];// end namesMatrix
            
            public const typeSize:Array = [
                0,1,2,3,4,4,9,16,1,2,3,4,0,1,2,3,4
            ];// end typeSize
            
            public const typeNames:Array = [
                "",
                "float","float2","float3","float4",
                "matrix2x2", "matrix3x3", "matrix4x4",
                "int", "int2", "int3", "int4",
                "bool", "bool2", "bool3", "bool4"
            ];// end namesLo
            
            public const qualifierName:Array = [
                "","in","out"
            ];// end qualifierName
            public const channelName:Array = ["r","g","b","a"];
            public const map:Array= [
                0x00, 0x00, 0x00, 0x00,
                0x03, 0x00, 0x00, 0x00,
                0x02, 0x00, 0x00, 0x00,
                0x02, 0x03, 0x00, 0x00,
                0x01, 0x00, 0x00, 0x00,
                0x01, 0x03, 0x00, 0x00,
                0x01, 0x02, 0x00, 0x00,
                0x01, 0x02, 0x03, 0x00,
                
                0x00, 0x00, 0x00, 0x00,
                0x00, 0x03, 0x00, 0x00,
                0x00, 0x02, 0x00, 0x00,
                0x00, 0x02, 0x03, 0x00,
                0x00, 0x01, 0x00, 0x00,
                0x00, 0x01, 0x03, 0x00,
                0x00, 0x01, 0x02, 0x00,
                0x00, 0x01, 0x02, 0x03,
            ];
        ]]>
    </fx:Script>
</s:Application>
