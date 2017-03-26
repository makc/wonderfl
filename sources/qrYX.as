// forked from sekiryou's 灯籠流し
/**
* R.I.P.W.
* 
* @author Masayuki Komatsu
* http://sekiryou.com/
* http://twitter.com/sekiryou_com
*/
package {
	import flash.system.ApplicationDomain;
    import flash.system.Security;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Utils3D;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.geom.Rectangle;
    import flash.display.GradientType;
    import flash.display.SpreadMethod;
    import flash.display.Shape;
    import flash.display.Loader;
    import flash.system.LoaderContext;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
	import flash.utils.ByteArray;
    import caurina.transitions.Tweener;
    
    [SWF(width = 465, height = 465, backgroundColor = 0x000000, frameRate = 30)]
    
    public class TourouNagashi extends Sprite {
        private const TOTAL_TOUROU:int = 15;
        private var projection:PerspectiveProjection;
        private var projectionMatrix3D:Matrix3D;
        private var mtx3D:Matrix3D = new Matrix3D();
        private var mtx3DIdentity:Vector.<Number> = mtx3D.rawData;
        private var projectedVerts:Vector.<Number> = new Vector.<Number>();
        private var indexList:Vector.<int> = new Vector.<int>();
        private var uvtList:Vector.<Number> = new Vector.<Number>();
        private var mtrx:Matrix = new Matrix();
        private var vf:ViewFrustum;
        private var screen:Sprite = new Sprite();
        private var texture:BitmapData
        
        private var tourouList:Vector.<Tourou> = new Vector.<Tourou>();
        private var tCloneList:Vector.<Tourou> = new Vector.<Tourou>();
        private var kyouzouList:Vector.<Kyouzou> = new Vector.<Kyouzou>();
        private var kCloneList:Vector.<Kyouzou> = new Vector.<Kyouzou>();
        private var minamo:Minamo;
        private var minamoBM:Bitmap;
        
        public function TourouNagashi() {
            addChild(new Bitmap(new BitmapData(465, 465, false, 0x000000)));
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        private function init(e:Event = null):void {
            stage.quality ="medium";
            projection = new PerspectiveProjection();
            //projection.fieldOfView = 40;
            projection.focalLength = 680;
            projectionMatrix3D = projection.toMatrix3D();
            screen = new Sprite();
            addChild(screen);
            screen.x = 232.5;
            screen.y = 232.5;
            
            vf = new ViewFrustum(projection.focalLength, -560, 800, 270, 270);
            
            texturePrepare();
            
            //InitialPosition
            var posMap:Array = [];
            const posMapW:int = 10;
            const posMapH:int = 6;
            for (var i:int = 0; i < posMapW * posMapH; i++ ) {
                posMap.push(i);
            }
            posMap.sort(function():int { return Math.random() > 0.5 ? 1 : -1; } );
            exCdntMapper();
            
            var rate:Number = 100;
            for (i = 0; i < TOTAL_TOUROU; i++ ) {
                var tmp:Tourou = new Tourou(i % 10 * 0.1, (i % 10 + 1) * 0.1, int(i * 0.1) * 0.1, (int(i * 0.1) + 1) * 0.1);        //灯篭
                screen.addChild(tmp);
                tmp.buttonMode = true;
                tmp.mouseChildren = false;
                tmp.addEventListener(MouseEvent.CLICK, tourouClick);
                tourouList.push(tmp);
                tmp.id = i;
                tmp.px = (posMap[i] % posMapW - posMapW * 0.5) * rate + 200;
                tmp.pz = (int(posMap[i] / posMapW) - posMapH * 0.5) * rate;
                tmp.vx = Math.random() * -0.6 - 0.3;
                tmp.vz = Math.random() * 0.6 - 0.3;
                
                var tx:Number = exCdntMapW * 0.5 * exCdntRate + tmp.px;
                var tz:Number = exCdntMapH * 0.5 * exCdntRate - tmp.pz;
                var trn:int = int(tz / exCdntRate) * exCdntMapH + int(tx / exCdntRate);
                
                exCdntMap[trn].push(i);
                tmp.registId = trn;
                tmp.collisionCheck = true;
            }
            //
            for (i = 0; i < TOTAL_TOUROU; i++ ) {
                var tmp2:Kyouzou = new Kyouzou(i % 10 * 0.1, (i % 10 + 1) * 0.1, int(i * 0.1) * 0.1, (int(i * 0.1) + 1) * 0.1);        //灯篭
                kyouzouList.push(tmp2);
                tmp2.collisionCheck = false;
            }
            //
            minamo = new Minamo();
            minamoRender();
            //
            MediaRSSReader();
            thumbContainer = new Sprite();
            thumbContainer.y = -110;
            addChild(thumbContainer);
            //
            controlPanel();
            viewerInit();
            thumbLoadInit();
            //
            back.alpha = backAlpha = 1;
            thumbLoadStart();
            
            var maskSizeX:Number = 2400;
            var maskSizeY:Number = 1200;
            var shape:Sprite = new Sprite();
            shape.graphics.beginFill(0x000000);
            shape.graphics.drawRect(maskSizeX * -0.5 + 465 * 0.5, maskSizeY * -0.5 + 465 * 0.5, maskSizeX, maskSizeY);
            shape.graphics.drawRect(0, 0, 465, 465);
            shape.graphics.endFill();
            shape.mouseEnabled = true;
            addChild(shape);
        }
        private var exCdntMap:Array;
        private var exCdntMapW:int = 20;
        private var exCdntMapH:int = 20;
        private var exCdntRate:int = 100;
        private function exCdntMapper():void {
            exCdntMap = [];
            for (var i:int = 0; i < exCdntMapW * exCdntMapW; i++) {
                exCdntMap.push([]);
            }
        }
        private function texturePrepare():void {
            var tmpShape:Shape = new Shape();
            mtrx.createGradientBox(100, 100, -3.1415926 / 2, 0, 0);
            var spreadMethod:String = SpreadMethod.PAD;
            tmpShape.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000], [0.0, 1.0], [0x00, 0xFF], mtrx);
            tmpShape.graphics.drawRect(0, 0, 500, 100);
            
            var textureSize:Number = 1000;
            texture = new BitmapData(textureSize, textureSize, true, 0x00000000);
            texture.draw(new BitmapData(textureSize, textureSize * 0.5, true, 0xFF996600));
            
            var surface:BitmapData = new BitmapData(textureSize * 0.5, textureSize * 0.5, true, 0x000000);
            surface.perlinNoise(128, 8, 4, Math.floor( Math.random() * 0x0000FF ), false, true, 0 | 0 | 0 | 8);
            mtrx.a = 1;
            mtrx.b = 0;
            mtrx.c = 0;
            mtrx.d = 1;
            mtrx.tx = 0;
            mtrx.ty = textureSize * 0.5;
            texture.fillRect(new Rectangle(0, textureSize * 0.5, textureSize * 0.5, textureSize * 0.5), 0x66003311);
            texture.draw(surface, mtrx, null, "normal");
            texture.draw(tmpShape, mtrx, null, "normal");
            
            mtrx.a = 1;
            mtrx.b = 0;
            mtrx.c = 0;
            mtrx.d = 1;
            mtrx.tx = textureSize * 0.5 - 10;
            mtrx.ty = textureSize * 0.5 - 10;
            texture.draw(new BitmapData(100, 100, false, 0x302000), mtrx);
        }
        private function minamoRender():void {
            var minamoBMD:BitmapData = new BitmapData(465, 465, true, 0x00000000);
            minamoBM = new Bitmap(minamoBMD);
            minamoBM.x = -465 * 0.5;
            minamoBM.y = -465 * 0.5;
            screen.addChild(minamoBM);
            
            mtx3D.rawData = mtx3DIdentity;
            mtx3D.appendTranslation(minamo.px, minamo.py, minamo.pz);
            mtx3D.appendTranslation( -offsetX, -offsetY, -offsetZ);
            mtx3D.appendRotation(-rotX, Vector3D.X_AXIS);
            mtx3D.appendRotation(-rotY, Vector3D.Y_AXIS);
            mtx3D.appendRotation(-rotZ, Vector3D.Z_AXIS);
            mtx3D.transformVectors(minamo.vertices, minamo.cVertices);
            
            tmpUvts = minamo.uvts;
            projectedVerts.length = 0;
            
            mtx3D.rawData = mtx3DIdentity;
            mtx3D.append(projectionMatrix3D);
            Utils3D.projectVectors(mtx3D, minamo.cVertices, projectedVerts, tmpUvts);
            
            var minomoContainer:Shape = new Shape();
            var g:Graphics = minomoContainer.graphics;
            g.beginBitmapFill(texture);
            g.drawTriangles(projectedVerts, null, tmpUvts, "negative");
            g.endFill();
            
            mtrx.a = 1;
            mtrx.b = 0;
            mtrx.c = 0;
            mtrx.d = 1;
            mtrx.tx = 465 * 0.5;
            mtrx.ty = 465 * 0.5;
            minamoBMD.draw(minomoContainer, mtrx);
        }
        private var tmpIndices:Vector.<int> = new Vector.<int>();
        private var tmpUvts:Vector.<Number> = new Vector.<Number>();
        private var offsetX:Number = 0;
        private var offsetY:Number = -180;
        private var offsetZ:Number = -640;
        private var rotX:Number = -14;
        private var rotY:Number = 0;
        private var rotZ:Number = 0;
        private function update(e:Event = null):void {
            var i:int
            var j:int
            var len:int;
            
            tCloneList.length = 0;
            kCloneList.length = 0;
            len = tourouList.length;
            for (i = 0; i < len; i++) {
                tourouList[i].cVertices.length = 0;
                tourouList[i].graphics.clear();
                var virtualPx:Number = tourouList[i].px + tourouList[i].vx;
                var virtualPy:Number = 0;
                var virtualPz:Number = tourouList[i].pz + tourouList[i].vz;
                
                if (tourouList[i].collisionCheck) {
                    tx = exCdntMapW * 0.5 * exCdntRate + virtualPx;
                    tz = exCdntMapH * 0.5 * exCdntRate - virtualPz;
                    trn = int(tz / exCdntRate) * exCdntMapH + int(tx / exCdntRate);
                    
                    var tmpTag:Array = [trn];
                    tmpTag.push(int(tz / exCdntRate) * exCdntMapH + int(tx / exCdntRate) - 1);
                    tmpTag.push(int(tz / exCdntRate - 1) * exCdntMapH + int(tx / exCdntRate) - 1);
                    tmpTag.push(int(tz / exCdntRate + 1) * exCdntMapH + int(tx / exCdntRate) - 1);
                    tmpTag.push(int(tz / exCdntRate) * exCdntMapH + int(tx / exCdntRate) + 1);
                    tmpTag.push(int(tz / exCdntRate - 1) * exCdntMapH + int(tx / exCdntRate) + 1);
                    tmpTag.push(int(tz / exCdntRate + 1) * exCdntMapH + int(tx / exCdntRate) + 1);
                    tmpTag.push(int(tz / exCdntRate - 1) * exCdntMapH + int(tx / exCdntRate));
                    tmpTag.push(int(tz / exCdntRate + 1) * exCdntMapH + int(tx / exCdntRate));
                    
                    if (virtualPz < -455) {
                        tourouList[i].vx  = Math.random() * -0.6 - 0.3;
                        tourouList[i].vz = Math.random() * 0.3;
                        tourouList[i].ty =  Math.random() * 1.6 - 0.8;
                    } else if (virtualPz > 400) {
                        tourouList[i].vx  = Math.random() * -0.6 - 0.3;
                        tourouList[i].vz = Math.random() * -0.3;
                        tourouList[i].ty =  Math.random() * 1.6 - 0.8;
                    }
                    
                    var tagLen:int = tmpTag.length;
                    for (var k:int = 0; k < tagLen; k++) {
                        ecLen = exCdntMap[tmpTag[k]].length;
                        for (j = 0; j < ecLen; j++) {
                            if (exCdntMap[tmpTag[k]][j] != i) {
                                var dx:Number = virtualPx - tourouList[exCdntMap[tmpTag[k]][j]].px;
                                var dz:Number = virtualPz - tourouList[exCdntMap[tmpTag[k]][j]].pz;
                                var dist:Number = Math.sqrt(dx * dx + dz * dz);
                                if (dist < tourouList[i].radius + tourouList[exCdntMap[tmpTag[k]][j]].radius) {
                                    var angle:Number = Math.atan2(dx, dz);
                                    virtualPz += Math.cos(angle) * (tourouList[i].radius + tourouList[exCdntMap[tmpTag[k]][j]].radius - dist) * 1;
                                    virtualPx += Math.sin(angle) * (tourouList[i].radius + tourouList[exCdntMap[tmpTag[k]][j]].radius - dist) * 1;
                                    
                                    tourouList[i].vx  = Math.random() * -0.6 - 0.3;
                                    tourouList[i].vz = Math.random() * 0.6 - 0.3;
                                    tourouList[i].ty =  Math.random() * 1.6 - 0.8;
                                    break;
                                }
                            }
                        }
                    }
                    tourouList[i].px = virtualPx;
                    tourouList[i].pz = virtualPz;
                    tourouList[i].ry += tourouList[i].ty;
                    
                    var tx:Number = exCdntMapW * 0.5 * exCdntRate + tourouList[i].px;
                    var tz:Number = exCdntMapH * 0.5 * exCdntRate - tourouList[i].pz;
                    var tr:Number = 500;
                    if (tx < tr) {
                        tourouList[i].px += -tr * 2 + 2000;
                        trn = int(tz / exCdntRate) * exCdntMapH + int(tourouList[i].px / exCdntRate);
                    } else {
                        var trn:int = int(tz / exCdntRate) * exCdntMapH + int(tx / exCdntRate);
                    }
                    if (tourouList[i].registId != trn) {
                        var ecLen:int = exCdntMap[tourouList[i].registId].length;
                        for (j = 0; j < ecLen; j++) {
                            if (exCdntMap[tourouList[i].registId][j] == i) {
                                exCdntMap[tourouList[i].registId].splice(j, 1);
                                break;
                            }
                        }
                        exCdntMap[trn].push(i);
                        tourouList[i].registId = trn;
                    }
                }
                
                //World
                mtx3D.rawData = mtx3DIdentity;
                mtx3D.appendRotation(tourouList[i].ry, Vector3D.Y_AXIS);
                mtx3D.appendTranslation(virtualPx, virtualPy, virtualPz);
                //Camera
                mtx3D.appendTranslation(-offsetX, -offsetY, -offsetZ);
                mtx3D.appendRotation(-rotX, Vector3D.X_AXIS);
                mtx3D.appendRotation(-rotY, Vector3D.Y_AXIS);
                mtx3D.appendRotation(-rotZ, Vector3D.Z_AXIS);
                mtx3D.transformVectors(tourouList[i].vertices, tourouList[i].cVertices);
                mtx3D.transformVectors(kyouzouList[i].vertices, kyouzouList[i].cVertices);
                //
                kyouzouList[i].px = tourouList[i].px;
                kyouzouList[i].pz = tourouList[i].pz;
                kyouzouList[i].ry = tourouList[i].ry;
                
                if (mtx3D.rawData[0] > 0) {
                    var minX:Number = tourouList[i].cVertices[0] + mtx3D.rawData[0] * tourouList[i].minX;
                    var maxX:Number = tourouList[i].cVertices[0] + mtx3D.rawData[0] * tourouList[i].maxX;
                } else {
                    minX = tourouList[i].cVertices[0] + mtx3D.rawData[0] * tourouList[i].maxX;
                    maxX = tourouList[i].cVertices[0] + mtx3D.rawData[0] * tourouList[i].minX;
                }
                if (mtx3D.rawData[1] > 0) {
                    var minY:Number = tourouList[i].cVertices[1] + mtx3D.rawData[1] * tourouList[i].minX;
                    var maxY:Number = tourouList[i].cVertices[1] + mtx3D.rawData[1] * tourouList[i].maxX;
                } else {
                    minY = tourouList[i].cVertices[1] + mtx3D.rawData[1] * tourouList[i].maxX;
                    maxY = tourouList[i].cVertices[1] + mtx3D.rawData[1] * tourouList[i].minX;
                }
                if (mtx3D.rawData[2] > 0) {
                    var minZ:Number = tourouList[i].cVertices[2] + mtx3D.rawData[2] * tourouList[i].minX;
                    var maxZ:Number = tourouList[i].cVertices[2] + mtx3D.rawData[2] * tourouList[i].maxX;
                } else {
                    minZ = tourouList[i].cVertices[2] + mtx3D.rawData[2] * tourouList[i].maxX;
                    maxZ = tourouList[i].cVertices[2] + mtx3D.rawData[2] * tourouList[i].minX;
                }
                if (mtx3D.rawData[4] > 0) {
                    minX += mtx3D.rawData[4] * tourouList[i].minY;                maxX += mtx3D.rawData[4] * tourouList[i].maxY;
                } else {
                    minX += mtx3D.rawData[4] * tourouList[i].maxY;            maxX += mtx3D.rawData[4] * tourouList[i].minY;
                }
                if (mtx3D.rawData[5] > 0) {
                    minY += mtx3D.rawData[5] * tourouList[i].minY;                maxY += mtx3D.rawData[5] * tourouList[i].maxY;
                } else {
                    minY += mtx3D.rawData[5] * tourouList[i].maxY;            maxY += mtx3D.rawData[5] * tourouList[i].minY;
                }
                if (mtx3D.rawData[6] > 0) {
                    minZ += mtx3D.rawData[6] * tourouList[i].minY;                maxZ += mtx3D.rawData[6] * tourouList[i].maxY;
                } else {
                    minZ += mtx3D.rawData[6] * tourouList[i].maxY;            maxZ += mtx3D.rawData[6] * tourouList[i].minY;
                }
                if (mtx3D.rawData[8] > 0) {
                    minX += mtx3D.rawData[8] * tourouList[i].minZ;                maxX += mtx3D.rawData[8] * tourouList[i].maxZ;
                } else {
                    minX += mtx3D.rawData[8] * tourouList[i].maxZ;            maxX += mtx3D.rawData[8] * tourouList[i].minZ;
                }
                if (mtx3D.rawData[9] > 0) {
                    minY += mtx3D.rawData[9] * tourouList[i].minZ;                maxY += mtx3D.rawData[9] * tourouList[i].maxZ;
                } else {
                    minY += mtx3D.rawData[9] * tourouList[i].maxZ;            maxY += mtx3D.rawData[9] * tourouList[i].minZ;
                }
                if (mtx3D.rawData[10] > 0) {
                    minZ += mtx3D.rawData[10] * tourouList[i].minZ;            maxZ += mtx3D.rawData[10] * tourouList[i].maxZ;
                } else {
                    minZ += mtx3D.rawData[10] * tourouList[i].maxZ;            maxZ += mtx3D.rawData[10] * tourouList[i].minZ;
                }
                //BoundingBoxCheck
                if (
                    vf.nearA * maxX + vf.nearB * maxZ + vf.nearC <= 0 &&
                    vf.farA * maxX + vf.farB * minZ + vf.farC <= 0 &&
                    vf.leftA * maxX + vf.leftB * maxZ + vf.leftC >= 0 &&
                    vf.rightA * minX + vf.rightB * maxZ + vf.rightC <= 0 &&
                    vf.topA * maxY + vf.topB * maxZ + vf.topC >= 0 &&
                    vf.bottomA * minY + vf.bottomB * maxZ + vf.bottomC <= 0
                ) {
                    tCloneList.push(tourouList[i]);
                    kCloneList.push(kyouzouList[i]);
                    if (
                        vf.nearA * minX + vf.nearB * minZ + vf.nearC <= 0 &&
                        vf.farA * maxX + vf.farB * maxZ + vf.farC <= 0 &&
                        vf.leftA * minX + vf.leftB * maxZ + vf.leftC >= 0 &&
                        vf.rightA * maxX + vf.rightB * maxZ + vf.rightC <= 0 &&
                        vf.topA * minY + vf.topB * maxZ + vf.topC >= 0 &&
                        vf.bottomA * maxY + vf.bottomB * maxZ + vf.bottomC <= 0
                    ) {
                        tourouList[i].isAllIn = true;
                        kyouzouList[i].isAllIn = true;
                    } else {
                        tourouList[i].isAllIn = false;
                        kyouzouList[i].isAllIn = false;
                    }
                }
            }
            tCloneList.sort(
                function(p1:Object, p2:Object):Number {
                    return p2.cVertices[2] - p1.cVertices[2];
                }
            );
            kCloneList.sort(
                function(p1:Object, p2:Object):Number {
                    return p2.cVertices[2] - p1.cVertices[2];
                }
            );
            
            var g:Graphics = screen.graphics;
            g.clear();
            //KyouzouRender
            len = kCloneList.length;
            for (i = 0; i < len; i++) {
                tmpIndices.length = 0;
                tmpUvts = kCloneList[i].uvts;
                projectedVerts.length = 0;
                
                len2 = kCloneList[i].mesh.length;
                for (j = 0; j < len2; j++) {
                    kCloneList[i].mesh[j].c = kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 2 >> 0];
                    if (kCloneList[i].mesh[j].c < kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 2 >> 0]) {
                        kCloneList[i].mesh[j].c = kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 2 >> 0];
                    }
                    if (kCloneList[i].mesh[j].c < kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 2 >> 0]) {
                        kCloneList[i].mesh[j].c = kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 2 >> 0];
                    }
                }
                kCloneList[i].mesh.sort(
                    function(p1:Polygon, p2:Polygon):Number {
                        return p2.c - p1.c;
                    }
                );
                
                len2 = kCloneList[i].mesh.length;
                for (j = 0; j < len2; j++) {
                    if (
                        (
                            kCloneList[i].isAllIn
                        ) ||
                        (
                        vf.nearA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 0 >> 0] + vf.nearB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.nearC <= 0 &&
                        vf.farA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 0 >> 0] + vf.farB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.farC <= 0 &&
                        vf.leftA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 0 >> 0] + vf.leftB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.leftC >= 0 &&
                        vf.rightA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 0 >> 0] + vf.rightB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.rightC <= 0 &&
                        vf.topA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 1 >> 0] + vf.topB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.topC >= 0 &&
                        vf.bottomA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 1 >> 0] + vf.bottomB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.bottomC <= 0
                        ) ||
                        (
                        vf.nearA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 0 >> 0] + vf.nearB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.nearC <= 0 &&
                        vf.farA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 0 >> 0] + vf.farB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.farC <= 0 &&
                        vf.leftA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 0 >> 0] + vf.leftB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.leftC >= 0 &&
                        vf.rightA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 0 >> 0] + vf.rightB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.rightC <= 0 &&
                        vf.topA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 1 >> 0] + vf.topB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.topC >= 0 &&
                        vf.bottomA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 1 >> 0] + vf.bottomB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.bottomC <= 0
                        ) ||
                        (
                        vf.nearA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 0 >> 0] + vf.nearB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.nearC <= 0 &&
                        vf.farA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 0 >> 0] + vf.farB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.farC <= 0 &&
                        vf.leftA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 0 >> 0] + vf.leftB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.leftC >= 0 &&
                        vf.rightA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 0 >> 0] + vf.rightB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.rightC <= 0 &&
                        vf.topA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 1 >> 0] + vf.topB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.topC >= 0 &&
                        vf.bottomA * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 1 >> 0] + vf.bottomB * kCloneList[i].cVertices[kCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.bottomC <= 0
                        )
                    ) {
                        tmpIndices.push(
                            kCloneList[i].mesh[j].i0,
                            kCloneList[i].mesh[j].i1,
                            kCloneList[i].mesh[j].i2
                        );
                    }
                }
                if (tmpIndices.length > 0) {
                    mtx3D.rawData = mtx3DIdentity;
                    mtx3D.append(projectionMatrix3D);
                    Utils3D.projectVectors(mtx3D, kCloneList[i].cVertices, projectedVerts, tmpUvts);
                    
                    g.beginBitmapFill(texture);
                    g.drawTriangles(projectedVerts, tmpIndices, tmpUvts, "negative");
                    g.endFill();
                }
            }
            //Minomo
            screen.setChildIndex(minamoBM, 0);
            //TourouRender
            len = tCloneList.length;
            for (i = 0; i < len; i++) {
                tmpIndices.length = 0;
                tmpUvts = tCloneList[i].uvts;
                projectedVerts.length = 0;
                
                var len2:int = tCloneList[i].mesh.length;
                for (j = 0; j < len2; j++) {
                    var i0x:Number = tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 0 >> 0];
                    var i0y:Number = tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 1 >> 0];
                    var i0z:Number = tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 2 >> 0];
                    var i1x:Number = tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 0 >> 0];
                    var i1y:Number = tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 1 >> 0];
                    var i1z:Number = tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 2 >> 0];
                    var i2x:Number = tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 0 >> 0];
                    var i2y:Number = tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 1 >> 0];
                    var i2z:Number = tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 2 >> 0];
                    
                    tCloneList[i].mesh[j].c = i0x * i0x + i0y * i0y + i0z * i0z;
                    var tmp:Number = i1x * i1x + i1y * i1y + i1z * i1z;
                    if (tCloneList[i].mesh[j].c < tmp) {
                        tCloneList[i].mesh[j].c = tmp;
                    }
                    tmp = i2x * i2x + i2y * i2y + i2z * i2z;
                    if (tCloneList[i].mesh[j].c < tmp) {
                        tCloneList[i].mesh[j].c = tmp;
                    }
                }
                tCloneList[i].mesh.sort(
                    function(p1:Polygon, p2:Polygon):Number {
                        return p2.c - p1.c;
                    }
                );
                
                len2 = tCloneList[i].mesh.length;
                for (j = 0; j < len2; j++) {
                    if (
                        (
                            tCloneList[i].isAllIn
                        ) ||
                        (
                        vf.nearA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 0 >> 0] + vf.nearB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.nearC <= 0 &&
                        vf.farA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 0 >> 0] + vf.farB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.farC <= 0 &&
                        vf.leftA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 0 >> 0] + vf.leftB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.leftC >= 0 &&
                        vf.rightA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 0 >> 0] + vf.rightB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.rightC <= 0 &&
                        vf.topA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 1 >> 0] + vf.topB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.topC >= 0 &&
                        vf.bottomA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 1 >> 0] + vf.bottomB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i0 * 3 + 2 >> 0] + vf.bottomC <= 0
                        ) ||
                        (
                        vf.nearA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 0 >> 0] + vf.nearB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.nearC <= 0 &&
                        vf.farA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 0 >> 0] + vf.farB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.farC <= 0 &&
                        vf.leftA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 0 >> 0] + vf.leftB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.leftC >= 0 &&
                        vf.rightA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 0 >> 0] + vf.rightB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.rightC <= 0 &&
                        vf.topA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 1 >> 0] + vf.topB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.topC >= 0 &&
                        vf.bottomA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 1 >> 0] + vf.bottomB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i1 * 3 + 2 >> 0] + vf.bottomC <= 0
                        ) ||
                        (
                        vf.nearA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 0 >> 0] + vf.nearB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.nearC <= 0 &&
                        vf.farA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 0 >> 0] + vf.farB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.farC <= 0 &&
                        vf.leftA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 0 >> 0] + vf.leftB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.leftC >= 0 &&
                        vf.rightA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 0 >> 0] + vf.rightB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.rightC <= 0 &&
                        vf.topA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 1 >> 0] + vf.topB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.topC >= 0 &&
                        vf.bottomA * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 1 >> 0] + vf.bottomB * tCloneList[i].cVertices[tCloneList[i].mesh[j].i2 * 3 + 2 >> 0] + vf.bottomC <= 0
                        )
                    ) {
                        tmpIndices.push(
                            tCloneList[i].mesh[j].i0,
                            tCloneList[i].mesh[j].i1,
                            tCloneList[i].mesh[j].i2
                        );
                    }
                }
                
                if (tmpIndices.length > 0) {
                    mtx3D.rawData = mtx3DIdentity;
                    mtx3D.append(projectionMatrix3D);
                    Utils3D.projectVectors(mtx3D, tCloneList[i].cVertices, projectedVerts, tmpUvts);
                
                    screen.setChildIndex(tCloneList[i], i + 1);
                    g = tCloneList[i].graphics;
                    g.beginBitmapFill(texture);
                    g.drawTriangles(projectedVerts, tmpIndices, tmpUvts, "negative");
                    g.endFill();
                }
            }
        }
        private function bugfix(matrix:Matrix3D):void {
            var m1:Matrix3D = new Matrix3D(Vector.<Number>([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]));
            var m2:Matrix3D = new Matrix3D(Vector.<Number>([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0]));
            m1.append(m2);
            if (m1.rawData[15] == 20) {
                var rawData:Vector.<Number> = matrix.rawData;
                rawData[15] /= 20;
                matrix.rawData = rawData;
            }
        }
        
        //--
        private var urlList:Array;
        private var typeList:Array;
        private var thumbList:Array;
        private var thumbContainer:Sprite;
        private var urlListBackup:Array;
        private var typeListBackup:Array;
        private var _feed:String = "http://api.flickr.com/services/feeds/photos_public.gne?format=rss_200&tags=";
        private var media:Namespace = new Namespace("http://search.yahoo.com/mrss/");
        private function MediaRSSReader():void {
            //Security.loadPolicyFile("http://api.flickr.com/crossdomain.xml");
            //Security.loadPolicyFile("http://farm1.static.flickr.com/crossdomain.xml");
            //Security.loadPolicyFile("http://farm2.static.flickr.com/crossdomain.xml");
            //Security.loadPolicyFile("http://farm3.static.flickr.com/crossdomain.xml");
            //Security.loadPolicyFile("http://farm4.static.flickr.com/crossdomain.xml");
            //Security.loadPolicyFile("http://farm5.static.flickr.com/crossdomain.xml");
            
            var ldr:URLLoader = new URLLoader();
            ldr.dataFormat = "binary";
            ldr.addEventListener(Event.COMPLETE, function _load(e:Event):void {
                ldr.removeEventListener(Event.COMPLETE, _load);
                urlList = [];
                typeList = [];
				var zip:ByteArray = new ByteArray;
				zip.writeBytes (ldr.data, 2045); zip.position = 0;
				var names:Array = FileUtil.AddZip (zip);
				var thumbs:Array = [];
				for (var i:int = 0; i < names.length; i++) {
					if (String (names [i]).indexOf (".jp") < 0) continue;
					if (String (names [i]).match (/^images\/\d{7}\.jpg$/)) {
						// juick
						urlList.push ("http://i.juick.com/p" + String (names [i]).substr (6));
					} else {
						// flickr
						urlList.push ("http:/" + String (names [i]).substr (6, 51) + ".jpg");
					}
					typeList.push ("image/jpeg");
					thumbs.push (names [i]);
				}
				//! thumbs.length => TOTAL_TOUROU
                onImageLoaded(thumbs);
            });
            ldr.load(new URLRequest("http://assets.wonderfl.net/images/related_images/0/06/06b6/06b6aee9aa40bb6b50dc4023ab0f24e110c7a00c"));
            removeEventListener(Event.ENTER_FRAME, update);
        }
        private function onImageLoaded($images:Array):void {
            thumbList = [];
            var ldr:Array = [];
            var compCheck:int = 0;
            var len:int = $images.length;
            //if (len >= 20) { 
//                for (var i:int = 0; i < 20; ++i) {
                for (var i:int = 0; i < TOTAL_TOUROU; ++i) {
                    ldr[i] = new Loader;
                    ldr[i].loadBytes (FileUtil.GetFile ($images[i%len]), new LoaderContext(false, ApplicationDomain.currentDomain));
                    ldr[i].x = i;
                    
                    var thumb:Thumbnail = new Thumbnail(i);
                    thumb.buttonMode = true;
                    thumb.addEventListener(MouseEvent.CLICK, thumbnailClick)
                    thumb.addChild(ldr[i]);
                    thumbList.push(thumb);
                    thumbContainer.addChild(thumb);
                    //ldr[i].contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function _load(e:Event):void {
                        //thumbLoadIOError();
                    //});
                    ldr[i].contentLoaderInfo.addEventListener(Event.COMPLETE, function _load(e:Event):void {
                        e.currentTarget.removeEventListener(Event.COMPLETE, _load);
                        var tag:Loader = e.currentTarget.loader;
                        var tmpID:Number = tag.x;
                        var orgBmd:BitmapData = new BitmapData(tag.width, tag.height, false, 0x000000);
                        orgBmd.draw(tag);
                        
                        tag.y = int(tmpID * 0.1) * 100;
                        tag.x = tmpID % 10 * 100;
                        texture.draw(textureProcess(orgBmd), new Matrix(1, 0, 0, 1, tag.x, tag.y));
                        
                        tag.x = tmpID % 10 * 46.5 + 1.5;
                        tag.y = int(tmpID *0.1) * 46.5 + 1.5;
                        tag.width = 43;
                        tag.height = 43;
                        
                        compCheck += 1;
                    });
                }
                urlListBackup = [];
                typeListBackup = [];
                urlListBackup = urlListBackup.concat(urlList);
                typeListBackup = typeListBackup.concat(typeList);
            //} else {
            //    thumbLoadIOError();
            //}
            
            addEventListener(
                Event.ENTER_FRAME, function _loadObserver(e:Event):void {
                    if ($images.length == compCheck) {
                        e.currentTarget.removeEventListener(Event.ENTER_FRAME, _loadObserver);
                        
                        back.alpha = backAlpha = 1;
                        thumbLoadFinish();
                        addEventListener(Event.ENTER_FRAME, update);
                    }
                }
            );
        }
        private function textureProcess(bmd:BitmapData):BitmapData {
            var processedBmd:BitmapData = new BitmapData(100, 100, false, 0xFFFFFF);
            const REGULAR_SIZE:Number = 90;
            
            mtrx.identity();
            mtrx.scale(REGULAR_SIZE / bmd.width, REGULAR_SIZE / bmd.height);
            mtrx.translate(5, 5);
            processedBmd.draw(bmd, mtrx);
            
            //light
            var width:Number = 100;
            var tmpShape:Shape = new Shape();
            mtrx.createGradientBox(width, width, 0, 0, 20);
            var spreadMethod:String = SpreadMethod.PAD;
            tmpShape.graphics.beginGradientFill(GradientType.RADIAL, [0xFFCC99, 0xCC6600], [0.6, 0.2], [0x00, 0xFF], mtrx);
            tmpShape.graphics.drawRect(0, 0, width, width);
            
            //frame
            processedBmd.fillRect(new Rectangle(0, 0, 100, 5), 0x000000);
            processedBmd.fillRect(new Rectangle(0, 95, 100, 5), 0x000000);
            processedBmd.fillRect(new Rectangle(0, 5, 5, 90), 0x000000);
            processedBmd.fillRect(new Rectangle(95, 5, 5, 90), 0x000000);
            
            processedBmd.draw(tmpShape, null, null, "add");
            
            return processedBmd;
        }
         private function tourouClick(e:MouseEvent):void {
            var thumbID:int = e.currentTarget.id;
            if (typeList[thumbID] == "image/jpeg") {
                imageViewer(urlList[thumbID]);
            } else {
                viewerMsg.text = "contents type : " + typeList[thumbID];
                viewerMsg.appendText("\n イメージファイルではありません。 ");
                
                notImage();
            }
        }
         private function thumbnailClick(e:MouseEvent):void {
            var thumbID:int = e.currentTarget._id;
            if (typeList[thumbID] == "image/jpeg") {
                imageViewer(urlList[thumbID]);
            } else {
                viewerMsg.text = "contents type : " + typeList[thumbID];
                viewerMsg.appendText("\n イメージファイルではありません。 ");
                notImage();
            }
        }
        private var back:Sprite;
        private var backAlpha:Number;
        private var count:int;
        private var circles:Shape;
        private var thumbMsg:TextField;
        private function thumbLoadInit():void {
            back = new Sprite();
            back.graphics.beginFill(0x000000);
            back.graphics.drawRect(0, 0, 465, 465);
            back.mouseEnabled = false;
            addChild(back);
            
            circles = new Shape();
            addChild(circles);
            circles.x = 465 * 0.5;
            circles.y = 465 * 0.5;
            
            thumbMsg = new TextField();
            thumbMsg.mouseEnabled = false;
            var tf:TextFormat = new TextFormat();
            tf.align = "center";
            thumbMsg.defaultTextFormat = tf;
            thumbMsg.text = "";
            thumbMsg.width = 240;
            thumbMsg.height = 120;
            thumbMsg.x = 465 * 0.5 - thumbMsg.width * 0.5;
            thumbMsg.y = 220;
            thumbMsg.textColor = 0xFFFFFF;
            thumbMsg.selectable = false;
            thumbMsg.type = TextFieldType.DYNAMIC;
            back.addChild(thumbMsg);
        }
        private function thumbLoadStart():void {
            circles.visible = true;
            count = 0;
            back.visible = true;
            back.mouseEnabled = true;
            
            removeEventListener(Event.ENTER_FRAME, thumbLoaderFadeOut);
            addEventListener(Event.ENTER_FRAME, thumbLoaderFadeIn);
            addEventListener(Event.ENTER_FRAME, loadingGimmick);
        }
        private function thumbLoadFinish():void {
            circles.visible = false;
            back.mouseEnabled = false;
            
            removeEventListener(Event.ENTER_FRAME, thumbLoaderFadeIn);
            addEventListener(Event.ENTER_FRAME, thumbLoaderFadeOut);
            removeEventListener(Event.ENTER_FRAME, loadingGimmick);
        }
        private function thumbLoaderFadeIn(e:Event = null):void {
            backAlpha += 0.1;
            if (backAlpha > 1) {
                backAlpha = 1;
                removeEventListener(Event.ENTER_FRAME, thumbLoaderFadeIn);
            }
            back.alpha = backAlpha;
        }
        private function thumbLoaderFadeOut(e:Event = null):void {
            backAlpha -= 0.01;
            if (backAlpha < 0) {
                backAlpha = 0;
                back.visible = false;
                removeEventListener(Event.ENTER_FRAME, thumbLoaderFadeOut);
            }
            back.alpha = backAlpha;
        }
        private function thumbLoadIOError():void {
            circles.visible = false;
            thumbMsg.text = "規定数のファイルが見つかりません。\n";
            thumbMsg.appendText("キーワードを変えて検索してください。");
            
            urlList = [];
            typeList = [];
            urlList = urlList.concat(urlListBackup);
            typeList = typeList.concat(typeListBackup);
            
            back.mouseEnabled = true;
            back.buttonMode = true;
            back.addEventListener(MouseEvent.CLICK, thumbIOErrorProcess);
            removeEventListener(Event.ENTER_FRAME, loadingGimmick);
        }
        private function thumbIOErrorProcess(e:MouseEvent):void {
            thumbMsg.text = "";
            back.mouseEnabled = false;
            back.buttonMode = false;
            back.removeEventListener(MouseEvent.CLICK, thumbIOErrorProcess);
            addEventListener(Event.ENTER_FRAME, thumbLoaderFadeOut);
            addEventListener(Event.ENTER_FRAME, update);
        }
        private function loadingGimmick(e:Event = null):void {
            circles.graphics.clear();
            for (var i:int = 0; i < 8; i++) {
                if ( count % 8 == i) {
                    circles.graphics.beginFill(0xDDDDDD);
                } else {
                    circles.graphics.beginFill(0x666666);
                }
                circles.graphics.drawCircle(Math.cos(i * 0.785398) * 12, Math.sin(i * 0.785398) * 12, 2);
            }
            count += 1;
        }
        
        private var viewer:Sprite;
        private var viewerBitmap:Loader;
        private var viewerAlpha:Number;
        private var viewerMsg:TextField;
        private function viewerInit():void {
            viewer = new Sprite();
            viewer.visible = false;
            
            viewer.buttonMode = true;
            viewer.addEventListener(MouseEvent.CLICK, viewerClose);
            
            viewer.addChild(new Bitmap(new BitmapData(465, 465, true, 0x99000000)));
            viewerBitmap = new Loader;
            viewer.addChild(viewerBitmap);
            addChild(viewer);
            
            viewerMsg = new TextField();
            viewerMsg.mouseEnabled = false;
            var tf:TextFormat = new TextFormat();
            tf.align = "center";
            viewerMsg.defaultTextFormat = tf;
            viewerMsg.text = "";
            viewerMsg.width = 240;
            viewerMsg.height = 120;
            viewerMsg.x = 465 * 0.5 - viewerMsg.width * 0.5;
            viewerMsg.y = 220;
            viewerMsg.textColor = 0xFFFFFF;
            viewerMsg.selectable = false;
            viewerMsg.type = TextFieldType.DYNAMIC;
            viewer.addChild(viewerMsg);
        }
        private var imgLoader:Loader;
        private function imageViewer(url:String):void {
            viewerMsg.text = "";
            viewer.buttonMode = true;
            viewer.addEventListener(MouseEvent.CLICK, viewerClose);
            imgLoader = new Loader();
            imgLoader.load(new URLRequest(url + "?=" + Math.random()), new LoaderContext(true));
            imgLoader.contentLoaderInfo.addEventListener(Event.INIT, init);
            imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioerror);
            
            viewer.removeChild(viewerBitmap);
            viewerBitmap.alpha = viewerAlpha = 0;
            viewerLoadStart();
            
            function init(e:Event):void {
                var ratio:Number =  imgLoader.width / imgLoader.height;
                if (ratio >= 1) {
                    var scale:Number = 465 / imgLoader.width;
                } else {
                    scale = 465 / imgLoader.height;
                }
                viewerBitmap = imgLoader;
				viewerBitmap.scaleX = scale;
				viewerBitmap.scaleY = scale;
                
                viewerBitmap.x = (465 * 0.5 - imgLoader.width * 0.5);
                viewerBitmap.y = (465 * 0.5 - imgLoader.height * 0.5);
                
                viewerBitmap.visible = true;
                viewer.addChild(viewerBitmap);
                viewerLoadFinish();
//                imgLoader.unload();
            }
            function ioerror(e:Event):void {
                viewerMsg.text = "読み込みに失敗しました。";
                
                viewerBitmap.visible = true;
//                viewerBitmap = new Bitmap(new BitmapData(1, 1, true, 0x00000000));
                viewerLoadFinish();
                imgLoader.unload();
            }
        }
        private function notImage():void {
            viewer.buttonMode = true;
            viewer.addEventListener(MouseEvent.CLICK, viewerClose);
            
            imgLoader = new Loader();
            viewer.removeChild(viewerBitmap);
            viewerBitmap.alpha = viewerAlpha = 0;
            viewerLoadStart();
            
            viewerBitmap = new Loader;
            viewer.addChild(viewerBitmap);
            
            viewerLoadFinish();
        }
        private function viewLoaderFadeIn(e:Event = null):void {
            viewerAlpha += 0.08;
            if (viewerAlpha > 1) {
                viewerAlpha = 1;
                removeEventListener(Event.ENTER_FRAME, viewLoaderFadeIn);
            }
            viewer.alpha = viewerAlpha;
        }
        private function viewLoaderFadeOut(e:Event = null):void {
            viewerAlpha -= 0.08;
            if (viewerAlpha < 0) {
                viewerAlpha = 0;
                viewer.visible = false;
                removeEventListener(Event.ENTER_FRAME, viewLoaderFadeOut);
            }
            viewer.alpha = viewerAlpha;
        }
        private function viewerLoadStart():void {
            circles.visible = true;
            count = 0;
            viewer.visible = true;
            
            addEventListener(Event.ENTER_FRAME, viewLoaderFadeIn);
            addEventListener(Event.ENTER_FRAME, loadingGimmick);
            removeEventListener(Event.ENTER_FRAME, update);
        }
        private function viewerLoadFinish():void {
            circles.visible = false;
            removeEventListener(Event.ENTER_FRAME, loadingGimmick);
        }
        private function viewerClose(e:Event = null):void {
            imgLoader.unload();
            viewer.buttonMode = false;
            
            if (!viewer.contains(viewerBitmap)) {
                viewerBitmap = new Loader;
                viewer.addChild(viewerBitmap);
            }
            
            viewer.removeEventListener(MouseEvent.CLICK, viewerClose);
            viewer.alpha = viewerAlpha = 1;
            addEventListener(Event.ENTER_FRAME, viewLoaderFadeOut);
            addEventListener(Event.ENTER_FRAME, update);
            circles.visible = false;
            removeEventListener(Event.ENTER_FRAME, loadingGimmick);
        }
        
        private var keyword:String  = "kurashiki";
        private var searchTF:TextField;
        private function controlPanel():void {
            var tf:TextFormat = new TextFormat();
            searchTF = new TextField();
            searchTF.text = keyword;
            searchTF.width = 160;
            searchTF.height = 18;
            searchTF.x = 215;
            searchTF.y = 10;
            searchTF.border = true;
            searchTF.textColor = 0x000000;
            searchTF.borderColor = 0x666666;
            searchTF.background = true;
            searchTF.backgroundColor = 0xFFFFFF
            searchTF.type = TextFieldType.INPUT;
            searchTF.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
//            addChild(searchTF);
            //
            var searchButton:Sprite = new Sprite();
            searchButton.buttonMode = true;
            searchButton.addEventListener(MouseEvent.CLICK, searchButtonClick);
            searchButton.x = 385;
            searchButton.y = 10;
//            addChild(searchButton);
            var searchButtonTF:TextField = new TextField();
            searchButtonTF.mouseEnabled = false;
            tf.align = "center";
            searchButtonTF.defaultTextFormat = tf;
            searchButtonTF.text = "search";
            searchButtonTF.width = 60;
            searchButtonTF.height = 18;
            searchButtonTF.border = true;
            searchButtonTF.textColor = 0xFFFFFF;
            searchButtonTF.borderColor = 0x666666;
            searchButtonTF.background = true;
            searchButtonTF.selectable = false;
            searchButtonTF.backgroundColor = 0x000000;
            searchButtonTF.type = TextFieldType.DYNAMIC;
            searchButton.addChild(searchButtonTF);
            //
            var thumbButton:Sprite = new Sprite();
            thumbButton.addEventListener(MouseEvent.MOUSE_OVER, thumbButtonClick);
            thumbButton.x = 20;
            thumbButton.y = 10;
//            addChild(thumbButton);
            var thumbButtonTF:TextField = new TextField();
            thumbButtonTF.mouseEnabled = false;
            tf.align = "center";
            thumbButtonTF.defaultTextFormat = tf;
            thumbButtonTF.text = "thumbnail";
            thumbButtonTF.width = 80;
            thumbButtonTF.height = 18;
            thumbButtonTF.border = true;
            thumbButtonTF.textColor = 0xFFFFFF;
            thumbButtonTF.borderColor = 0x666666;
            thumbButtonTF.background = true;
            thumbButtonTF.selectable = false;
            thumbButtonTF.backgroundColor = 0x000000;
            thumbButtonTF.type = TextFieldType.DYNAMIC;
            thumbButton.addChild(thumbButtonTF);
        }
        private function searchButtonClick(e:MouseEvent):void {
            if (searchTF.text != "" && searchTF.text != keyword) {
                keyword = searchTF.text;
                MediaRSSReader();
                back.visible = true;
                back.alpha = backAlpha = 0;
                thumbLoadStart();
            }
        }
        private function onKeyUpHandler(e:KeyboardEvent):void {
            if (e.keyCode == 13 && e.currentTarget.text != "" && searchTF.text != keyword) {
                keyword = e.currentTarget.text;
                MediaRSSReader();
                back.visible = true;
                back.alpha = backAlpha = 0;
                thumbLoadStart();
            }
        }
        private var isLock:Boolean = false;
        private function thumbButtonClick(e:MouseEvent):void {
            Tweener.addTween(thumbContainer, { y : 40, time : 0.7, transition : "easeInOutCubic"});
            addEventListener(Event.ENTER_FRAME, mouseObserver);
        }
        private function mouseObserver(e:Event):void {
            if (stage.mouseY > 160) {
                Tweener.addTween(thumbContainer, { y : -110, time : 0.7, transition : "easeInOutCubic"});
                removeEventListener(Event.ENTER_FRAME, mouseObserver);
            }
        }
    }
}

import flash.display.Sprite;
class Thumbnail extends Sprite {
    public var _id:int
    public function Thumbnail(id:int) {
        _id = id
    }
}

import flash.geom.Vector3D;
class ViewFrustum {
    public var vertices:Vector.<Number> = new Vector.<Number>();
    public var leftA:Number, leftB:Number, leftC:Number;
    public var rightA:Number, rightB:Number, rightC:Number;
    public var topA:Number, topB:Number, topC:Number;
    public var bottomA:Number, bottomB:Number, bottomC:Number;
    public var nearA:Number, nearB:Number, nearC:Number;
    public var farA:Number, farB:Number, farC:Number;
    public function ViewFrustum(focalLength:Number, near:Number, far:Number, w:Number, h:Number) {
        if (near < -focalLength) near = -focalLength;
        var nearSizeW:Number = (near + focalLength) * Math.tan(w / focalLength);
        var nearSizeH:Number = (near + focalLength) * Math.tan(h / focalLength);
        var farSizeW:Number = (far + focalLength) * Math.tan(w / focalLength);
        var farSizeH:Number = (far + focalLength) * Math.tan(h / focalLength);
        
        vertices.push(0, 0, 0);
        vertices.push( -nearSizeW, -nearSizeH, near + focalLength);
        vertices.push( -nearSizeW, nearSizeH, near + focalLength);
        vertices.push(nearSizeW, -nearSizeH, near + focalLength);
        vertices.push(nearSizeW, nearSizeH, near + focalLength);
        vertices.push( -farSizeW, -farSizeH, far + focalLength);
        vertices.push( -farSizeW, farSizeH, far + focalLength);
        vertices.push(farSizeW, -farSizeH, far + focalLength);
        vertices.push(farSizeW, farSizeH, far + focalLength);
        
        leftA = (far + focalLength) - (near + focalLength);
        leftB = farSizeW - nearSizeW;
        leftC = -leftB * (near + focalLength) + leftA * nearSizeW;
        
        rightA = (far + focalLength) - (near + focalLength);
        rightB = -farSizeW + nearSizeW;
        rightC = -rightB * (near + focalLength) - rightA * nearSizeW;
        
        topA = (far + focalLength) - (near + focalLength);
        topB = farSizeH - nearSizeH;
        topC = -topB * (near + focalLength) + topA * nearSizeH;
        
        bottomA = (far + focalLength) - (near + focalLength);
        bottomB = -farSizeH + nearSizeH;
        bottomC = -bottomB * (near + focalLength) - bottomA * nearSizeH;
        
        nearA = (near + focalLength) - (near + focalLength);
        nearB = -nearSizeW - nearSizeW;
        nearC = -nearB * (near + focalLength) + nearA * nearSizeW;
        
        farA = (far + focalLength) - (far + focalLength);
        farB = farSizeW + farSizeW;
        farC = -farB * (far + focalLength) - farA * farSizeW;
    }
}

import flash.display.Sprite;
import flash.geom.Vector3D;
class Tourou  extends Sprite {
    public var id:int;
    public var collisionCheck:Boolean;
    public var registId:int = 0;
    public var isAllIn:Boolean;
    public var px:Number;
    public var py:Number;
    public var pz:Number;
    public var vx:Number;
    public var vy:Number;
    public var vz:Number;
    //public var rx:Number;
    public var ry:Number = Math.random() * 360;
    //public var rz:Number;
    //public var tx:Number = 0;
    public var ty:Number = Math.random() * 1.6 - 0.8;
    //public var tz:Number = 0;
    public var radius:Number;
    public var v3Ds:Vector.<Vector3D> = new Vector.<Vector3D>();
    public var vertices:Vector.<Number> = new Vector.<Number>();
    public var wVertices:Vector.<Number> = new Vector.<Number>();
    public var cVertices:Vector.<Number> = new Vector.<Number>();
    public var indices:Vector.<int> = new Vector.<int>();
    public var uvts:Vector.<Number> = new Vector.<Number>();
    
    public var mesh:Vector.<Polygon> = new Vector.<Polygon>();
    private var _u0:Number;
    private var _u1:Number;
    private var _v0:Number;
    private var _v1:Number;
    
    public var minX:Number = Number.MAX_VALUE;
    public var maxX:Number = Number.MIN_VALUE;
    public var minY:Number = Number.MAX_VALUE;
    public var maxY:Number = Number.MIN_VALUE;
    public var minZ:Number = Number.MAX_VALUE;
    public var maxZ:Number = Number.MIN_VALUE;
    
    public function Tourou(u0:Number = 0.0, u1:Number = 0.0, v0:Number = 0.1, v1:Number = 0.1) {
        _u0 = u0;
        _u1 = u1;
        _v0 = v0;
        _v1 = v1;
        init();
    }
    private function init():void {
        const w:int = 20;
        const h:int = -40;
        const tw:int = 26;
        const uw:int = 23;
        const h2:int = -4;
        //Center
        v3Ds.push(new Vector3D(0, 0, 0));
        uvts.push(null, null, null);
        //BoundingBox
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        //Object
        v3Ds.push(new Vector3D( -w, h + h2, -w));
        v3Ds.push(new Vector3D( -w, 0 + h2, -w));
        v3Ds.push(new Vector3D(w, h + h2, -w));
        v3Ds.push(new Vector3D(w, 0 + h2, -w));
        v3Ds.push(new Vector3D(w, h + h2, w));
        v3Ds.push(new Vector3D(w, 0 + h2, w));
        v3Ds.push(new Vector3D(-w, h + h2, w));
        v3Ds.push(new Vector3D( -w, 0 + h2, w));
        v3Ds.push(new Vector3D(0, 0 + h2, -w));
        v3Ds.push(new Vector3D(0, 0 + h2, w));
        v3Ds.push(new Vector3D( -w, h + h2, -w));
        v3Ds.push(new Vector3D( -w, 0 + h2, -w));
        //
        var _um:Number = _u0 + (_u1 - _u0) * 0.5;
        uvts.push(_u0, _v0, null);
        uvts.push(_u0, _v1, null);
        uvts.push(_u1, _v0, null);
        uvts.push(_u1, _v1, null);
        uvts.push(_u0, _v0, null);
        uvts.push(_u0, _v1, null);
        uvts.push(_u1, _v0, null);
        uvts.push(_u1, _v1, null);
        uvts.push(_um, _v1, null);
        uvts.push(_um, _v1, null);
        uvts.push(_u0, _v0, null);
        uvts.push(_u0, _v1, null);
        //表面
        var startIndex:int = 8;
        indices.push(startIndex + 1, startIndex + 9, startIndex + 2);
        indices.push(startIndex + 1, startIndex + 3, startIndex + 9);
        indices.push(startIndex + 3, startIndex + 4, startIndex + 9);
        indices.push(startIndex + 3, startIndex + 5, startIndex + 6);
        indices.push(startIndex + 3, startIndex + 6, startIndex + 4);
        indices.push(startIndex + 5, startIndex + 10, startIndex + 6);
        indices.push(startIndex + 5, startIndex + 7, startIndex + 10);
        indices.push(startIndex + 7, startIndex + 8, startIndex + 10);
        indices.push(startIndex + 7, startIndex + 11, startIndex + 12);
        indices.push(startIndex + 7, startIndex + 12, startIndex + 8);
        //
        indices.push(startIndex + 1, startIndex + 4, startIndex + 3);
        indices.push(startIndex + 1, startIndex + 2, startIndex + 4);
        indices.push(startIndex + 3, startIndex + 6, startIndex + 5);
        indices.push(startIndex + 3, startIndex + 4, startIndex + 6);
        indices.push(startIndex + 5, startIndex + 8, startIndex + 7);
        indices.push(startIndex + 5, startIndex + 6, startIndex + 8);
        indices.push(startIndex + 7, startIndex + 2, startIndex + 11);
        indices.push(startIndex + 7, startIndex + 8, startIndex + 12);
        //
        v3Ds.push(new Vector3D( -tw, h2, -tw));
        v3Ds.push(new Vector3D( -uw, 0, -uw));
        v3Ds.push(new Vector3D(tw, h2, -tw));
        v3Ds.push(new Vector3D(uw, 0, -uw));
        v3Ds.push(new Vector3D(tw, h2, tw));
        v3Ds.push(new Vector3D(uw, 0, uw));
        v3Ds.push(new Vector3D(-tw, h2, tw));
        v3Ds.push(new Vector3D( -uw, 0, uw));
        v3Ds.push(new Vector3D( -tw, h2, -tw));
        v3Ds.push(new Vector3D( -uw, 0, -uw));
        v3Ds.push(new Vector3D(tw, h2, tw));
        v3Ds.push(new Vector3D(-tw, h2, tw));
        //
        var du0:Number = 0.52;
        var du1:Number = 0.58;
        var dv0:Number = 0.52;
        var dv1:Number = 0.58;
        uvts.push(du0, dv0, null);
        uvts.push(du0, dv1, null);
        uvts.push(du1, dv0, null);
        uvts.push(du1, dv1, null);
        uvts.push(du0, dv0, null);
        uvts.push(du0, dv1, null);
        uvts.push(du1, dv0, null);
        uvts.push(du1, dv1, null);
        uvts.push(du0, dv0, null);
        uvts.push(du0, dv1, null);
        uvts.push(du0, dv1, null);
        uvts.push(du1, dv1, null);
        //
        startIndex = 21;
        indices.push(startIndex + 0, startIndex + 2, startIndex + 3);
        indices.push(startIndex + 0, startIndex + 3, startIndex + 1);
        indices.push(startIndex + 2, startIndex + 4, startIndex + 5);
        indices.push(startIndex + 2, startIndex + 5, startIndex + 3);
        indices.push(startIndex + 4, startIndex + 6, startIndex + 7);
        indices.push(startIndex + 4, startIndex + 7, startIndex + 5);
        indices.push(startIndex + 6, startIndex + 8, startIndex + 9);
        indices.push(startIndex + 6, startIndex + 9, startIndex + 7);
        indices.push(startIndex + 0, startIndex + 10, startIndex + 2);
        indices.push(startIndex + 0, startIndex + 11, startIndex + 10);
        
        //BoundingBox
        var len:int = v3Ds.length;
        for (var i:int = 9; i < len; i++) {
            if (minX > v3Ds[i].x) {
                minX = v3Ds[i].x;
            } else if (maxX < v3Ds[i].x) {
                maxX = v3Ds[i].x;
            }
            if (minY > v3Ds[i].y) {
                minY = v3Ds[i].y;
            } else if (maxY < v3Ds[i].y) {
                maxY = v3Ds[i].y;
            }
            if (minZ > v3Ds[i].z) {
                minZ = v3Ds[i].z;
            } else if (maxZ < v3Ds[i].z) {
                maxZ = v3Ds[i].z;
            }
        }
        v3Ds[1] = new Vector3D(minX, minY, minZ);
        v3Ds[2] = new Vector3D(minX, maxY, minZ);
        v3Ds[3] = new Vector3D(maxX, minY, minZ);
        v3Ds[4] = new Vector3D(maxX, maxY, minZ);
        v3Ds[5] = new Vector3D(minX, minY, maxZ);
        v3Ds[6] = new Vector3D(minX, maxY, maxZ);
        v3Ds[7] = new Vector3D(maxX, minY, maxZ);
        v3Ds[8] = new Vector3D(maxX, maxY, maxZ);
        
        len = v3Ds.length;
        for (i = 0; i < len; i++) {
            vertices.push(v3Ds[i].x);
            vertices.push(v3Ds[i].y);
            vertices.push(v3Ds[i].z);
        }
        
        radius = Math.sqrt((w * w) * 2);
        
        len = indices.length;
        for (i = 0; i < len; i++) {
            if (i % 3 == 0) {
                var tmp:Polygon = new Polygon(
                    indices[i],
                    indices[i + 1 >> 0],
                    indices[i + 2 >> 0]
                );
                mesh.push(tmp);
            }
        }
    }
}

import flash.geom.Vector3D;
class Kyouzou {
    public var collisionCheck:Boolean;
    public var registId:int = 0;
    public var isAllIn:Boolean;
    public var px:Number;
    public var py:Number;
    public var pz:Number;
    public var vx:Number;
    //public var vy:Number;
    public var vz:Number;
    //public var rx:Number;
    public var ry:Number = Math.random() * 360;
    //public var rz:Number;
    //public var tx:Number = Math.random() * 2 - 1;
    public var ty:Number = Math.random() * 2 - 1;
    //public var tz:Number = Math.random() * 2 - 1;
    public var hitArea:Number;
    public var v3Ds:Vector.<Vector3D> = new Vector.<Vector3D>();
    public var vertices:Vector.<Number> = new Vector.<Number>();
    public var wVertices:Vector.<Number> = new Vector.<Number>();
    public var cVertices:Vector.<Number> = new Vector.<Number>();
    public var indices:Vector.<int> = new Vector.<int>();
    public var uvts:Vector.<Number> = new Vector.<Number>();
    
    public var mesh:Vector.<Polygon> = new Vector.<Polygon>();
    private var _u0:Number;
    private var _u1:Number;
    private var _v0:Number;
    private var _v1:Number;
    
    public var minX:Number = Number.MAX_VALUE;
    public var maxX:Number = Number.MIN_VALUE;
    public var minY:Number = Number.MAX_VALUE;
    public var maxY:Number = Number.MIN_VALUE;
    public var minZ:Number = Number.MAX_VALUE;
    public var maxZ:Number = Number.MIN_VALUE;
    
    public function Kyouzou(u0:Number = 0.0, u1:Number = 0.0, v0:Number = 0.1, v1:Number = 0.1) {
        _u0 = u0;
        _u1 = u1;
        _v0 = v0;
        _v1 = v1;
        init();
    }
    private function init():void {
        const w:int = 20;
        const h:int = 32;
        const tw:int = 26;
        const uw:int = 23;
        const h2:int = 4;
        //Center
        v3Ds.push(new Vector3D(0, 0, 0));
        uvts.push(null, null, null);
        //BoundingBox
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        v3Ds.push(new Vector3D(0, 0, 0));
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        uvts.push(null, null, null);
        //Object
        v3Ds.push(new Vector3D( -w, h + h2, -w));
        v3Ds.push(new Vector3D( -w, 0 + h2, -w));
        v3Ds.push(new Vector3D(w, h + h2, -w));
        v3Ds.push(new Vector3D(w, 0 + h2, -w));
        v3Ds.push(new Vector3D(w, h + h2, w));
        v3Ds.push(new Vector3D(w, 0 + h2, w));
        v3Ds.push(new Vector3D(-w, h + h2, w));
        v3Ds.push(new Vector3D( -w, 0 + h2, w));
        v3Ds.push(new Vector3D(0, 0 + h2, -w));
        v3Ds.push(new Vector3D(0, 0 + h2, w));
        v3Ds.push(new Vector3D( -w, h + h2, -w));
        v3Ds.push(new Vector3D( -w, 0 + h2, -w));
        //
        var _um:Number = _u0 + (_u1 - _u0) * 0.5;
        uvts.push(_u0, _v0, null);
        uvts.push(_u0, _v1, null);
        uvts.push(_u1, _v0, null);
        uvts.push(_u1, _v1, null);
        uvts.push(_u0, _v0, null);
        uvts.push(_u0, _v1, null);
        uvts.push(_u1, _v0, null);
        uvts.push(_u1, _v1, null);
        uvts.push(_um, _v1, null);
        uvts.push(_um, _v1, null);
        uvts.push(_u0, _v0, null);
        uvts.push(_u0, _v1, null);
        //
        var startIndex:int = 8;
        indices.push(startIndex + 1, startIndex + 2, startIndex + 9);
        indices.push(startIndex + 1, startIndex + 9, startIndex + 3);
        indices.push(startIndex + 3, startIndex + 9, startIndex + 4);
        indices.push(startIndex + 3, startIndex + 6, startIndex + 5);
        indices.push(startIndex + 3, startIndex + 4, startIndex + 6);
        indices.push(startIndex + 5, startIndex + 6, startIndex + 10);
        indices.push(startIndex + 5, startIndex + 10, startIndex + 7);
        indices.push(startIndex + 7, startIndex + 10, startIndex + 8);
        indices.push(startIndex + 7, startIndex + 12, startIndex + 11);
        indices.push(startIndex + 7, startIndex + 8, startIndex + 12);
        //
        v3Ds.push(new Vector3D( -tw, h2, -tw));
        v3Ds.push(new Vector3D( -uw, 0, -uw));
        v3Ds.push(new Vector3D(tw, h2, -tw));
        v3Ds.push(new Vector3D(uw, 0, -uw));
        v3Ds.push(new Vector3D(tw, h2, tw));
        v3Ds.push(new Vector3D(uw, 0, uw));
        v3Ds.push(new Vector3D(-tw, h2, tw));
        v3Ds.push(new Vector3D( -uw, 0, uw));
        v3Ds.push(new Vector3D( -tw, h2, -tw));
        v3Ds.push(new Vector3D( -uw, 0, -uw));
        v3Ds.push(new Vector3D(tw, h2, tw));
        v3Ds.push(new Vector3D( -tw, h2, tw));
        v3Ds.push(new Vector3D(0, h2, -uw));
        v3Ds.push(new Vector3D(uw, h2, 0));
        v3Ds.push(new Vector3D(0, h2, uw));
        v3Ds.push(new Vector3D( -uw, h2, 0));
        
        var du0:Number = 0.52;
        var du1:Number = 0.58;
        var dv0:Number = 0.52;
        var dv1:Number = 0.58;
        var tu0:Number = 0.55;
        var tv0:Number = 0.55;
        uvts.push(du0, dv0, null);
        uvts.push(du0, dv1, null);
        uvts.push(du1, dv0, null);
        uvts.push(du1, dv1, null);
        uvts.push(du0, dv0, null);
        uvts.push(du0, dv1, null);
        uvts.push(du1, dv0, null);
        uvts.push(du1, dv1, null);
        uvts.push(du0, dv0, null);
        uvts.push(du0, dv1, null);
        uvts.push(du0, dv1, null);
        uvts.push(du1, dv1, null);
        uvts.push(tu0, dv1, null);
        uvts.push(tu0, dv1, null);
        uvts.push(tu0, dv1, null);
        uvts.push(tu0, dv1, null);
        //
        startIndex = 21;
        indices.push(startIndex + 0, startIndex + 1, startIndex + 12);
        indices.push(startIndex + 1, startIndex + 3, startIndex + 12);
        indices.push(startIndex + 12, startIndex + 3, startIndex + 2);
        indices.push(startIndex + 3, startIndex + 13, startIndex + 2);
        indices.push(startIndex + 3, startIndex + 5, startIndex + 13);
        indices.push(startIndex + 13, startIndex + 5, startIndex + 4);
        indices.push(startIndex + 4, startIndex + 5, startIndex + 14);
        indices.push(startIndex + 5, startIndex + 7, startIndex + 14);
        indices.push(startIndex + 14, startIndex + 7, startIndex + 6);
        indices.push(startIndex + 6, startIndex + 7, startIndex + 15);
        indices.push(startIndex + 7, startIndex + 9, startIndex + 15);
        indices.push(startIndex + 8, startIndex + 15, startIndex + 9);
        indices.push(startIndex + 0, startIndex + 10, startIndex + 2);
        indices.push(startIndex + 0, startIndex + 11, startIndex + 10);
        //BoundingBox
        var len:int = v3Ds.length;
        for (var i:int = 9; i < len; i++) {
            if (minX > v3Ds[i].x) {
                minX = v3Ds[i].x;
            } else if (maxX < v3Ds[i].x) {
                maxX = v3Ds[i].x;
            }
            if (minY > v3Ds[i].y) {
                minY = v3Ds[i].y;
            } else if (maxY < v3Ds[i].y) {
                maxY = v3Ds[i].y;
            }
            if (minZ > v3Ds[i].z) {
                minZ = v3Ds[i].z;
            } else if (maxZ < v3Ds[i].z) {
                maxZ = v3Ds[i].z;
            }
        }
        v3Ds[1] = new Vector3D(minX, minY, minZ);
        v3Ds[2] = new Vector3D(minX, maxY, minZ);
        v3Ds[3] = new Vector3D(maxX, minY, minZ);
        v3Ds[4] = new Vector3D(maxX, maxY, minZ);
        v3Ds[5] = new Vector3D(minX, minY, maxZ);
        v3Ds[6] = new Vector3D(minX, maxY, maxZ);
        v3Ds[7] = new Vector3D(maxX, minY, maxZ);
        v3Ds[8] = new Vector3D(maxX, maxY, maxZ);
        
        len = v3Ds.length;
        for (i = 0; i < len; i++) {
            vertices.push(v3Ds[i].x);
            vertices.push(v3Ds[i].y);
            vertices.push(v3Ds[i].z);
        }
        
        len = indices.length;
        for (i = 0; i < len; i++) {
            if (i % 3 == 0) {
                var tmp:Polygon = new Polygon(
                    indices[i],
                    indices[i + 1 >> 0],
                    indices[i + 2 >> 0]
                );
                mesh.push(tmp);
            }
        }
    }
}

import flash.geom.Vector3D;
class Minamo {
    public var px:Number = 0;
    public var py:Number = 0;
    public var pz:Number = 0;
    public var v3Ds:Vector.<Vector3D> = new Vector.<Vector3D>();
    public var vertices:Vector.<Number> = new Vector.<Number>();
    //public var wVertices:Vector.<Number> = new Vector.<Number>();
    public var cVertices:Vector.<Number> = new Vector.<Number>();
    public var indices:Vector.<int> = new Vector.<int>();
    public var uvts:Vector.<Number> = new Vector.<Number>();
    
    public var mesh:Vector.<Polygon> = new Vector.<Polygon>();
    public function Minamo() {
        init();
    }
    private function init():void {
        const r:int = 1200;
        const l:int = -1200;
        const c:int = 0;
        const t:int = 1200;
        const u:int = -600;
        const z:int = 0;
        
        indices.push(0, 1, 2);
        v3Ds.push(new Vector3D(l, 0, t));
        v3Ds.push(new Vector3D(c, 0, t));
        v3Ds.push(new Vector3D(c, 0, z));
        indices.push(3, 4, 5);
        v3Ds.push(new Vector3D(l, 0, t));
        v3Ds.push(new Vector3D(c, 0, z));
        v3Ds.push(new Vector3D(l, 0, z));
        indices.push(6, 7, 8);
        v3Ds.push(new Vector3D(c, 0, t));
        v3Ds.push(new Vector3D(r, 0, t));
        v3Ds.push(new Vector3D(r, 0, z));
        indices.push(9, 10, 11);
        v3Ds.push(new Vector3D(c, 0, t));
        v3Ds.push(new Vector3D(r, 0, z));
        v3Ds.push(new Vector3D(c, 0, z));
        indices.push(12, 13, 14);
        v3Ds.push(new Vector3D(l, 0, z));
        v3Ds.push(new Vector3D(c, 0, z));
        v3Ds.push(new Vector3D(c, 0, u));
        indices.push(15, 16, 17);
        v3Ds.push(new Vector3D(l, 0, z));
        v3Ds.push(new Vector3D(c, 0, u));
        v3Ds.push(new Vector3D(l, 0, u));
        indices.push(18, 19, 20);
        v3Ds.push(new Vector3D(c, 0, z));
        v3Ds.push(new Vector3D(r, 0, z));
        v3Ds.push(new Vector3D(r, 0, u));
        indices.push(0, 1, 4);
        v3Ds.push(new Vector3D(c, 0, z));
        v3Ds.push(new Vector3D(r, 0, u));
        v3Ds.push(new Vector3D(c, 0, u));
        
        var u0:Number = 0.0;
        var u1:Number = 0.25;
        var u2:Number = 0.5;
        var v0:Number = 0.51;
        var v1:Number = 0.75;
        var v2:Number = 1.0;
        uvts.push(u0, v0, null, u1, v0, null, u1, v1, null);
        uvts.push(u0, v0, null, u1, v1, null, u0, v1, null);
        uvts.push(u1, v0, null, u2, v0, null, u2, v1, null);
        uvts.push(u1, v0, null, u2, v1, null, u1, v1, null);
        uvts.push(u0, v1, null, u1, v1, null, u1, v2, null);
        uvts.push(u0, v1, null, u1, v2, null, u0, v2, null);
        uvts.push(u1, v1, null, u2, v1, null, u2, v2, null);
        uvts.push(u1, v1, null, u2, v2, null, u1, v2, null);
        
        var len:int = v3Ds.length;
        for (var i:int = 0; i < len; i++) {
            vertices.push(v3Ds[i].x);
            vertices.push(v3Ds[i].y);
            vertices.push(v3Ds[i].z);
        }
        
        len = indices.length;
        for (i = 0; i < len; i++) {
            if (i % 3 == 0) {
                var tmp:Polygon = new Polygon(
                    indices[i],
                    indices[i + 1 >> 0],
                    indices[i + 2 >> 0]
                );
                mesh.push(tmp);
            }
        }
    }
}

import flash.geom.Vector3D;
class Polygon {
    public var c:Number = 0;
    public var x:Number = 0;
    public var y:Number = 0;
    public var z:Number = 0;
    public var i0:int = 0;
    public var i1:int = 0;
    public var i2:int = 0;
    public function Polygon(i0:int, i1:int, i2:int) {
        this.i0 = i0;
        this.i1 = i1;
        this.i2 = i2;
    }
}

import flash.utils.*;
import nochump.util.zip.*;
class FileUtil {
	public static var Zips:Dictionary = new Dictionary;
	public static function AddZip (data:ByteArray):Array {
		var names:Array = [];
		var zip:ZipFile = new ZipFile (data);
		for (var i:int = 0; i < zip.entries.length; i++) {
			var entry:ZipEntry = zip.entries [i];
			var finfo:FileInfo = new FileInfo;
			finfo.zip = zip;
			finfo.entry = entry;
			Zips [entry.name] = finfo;
			names.push (entry.name);
		}
		return names;
	}
	public static function GetFile (name:String):ByteArray {
		var finfo:FileInfo = FileInfo (Zips [name]);
		if (finfo == null) return null;
		return finfo.zip.getInput (finfo.entry);
	}
}

import nochump.util.zip.*;
class FileInfo {
	public var zip:ZipFile;
	public var entry:ZipEntry;
}