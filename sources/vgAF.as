package{
    import flash.display.BitmapData;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.*;
    
    public class Main extends Sprite
    {
        public function Main():void{
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void{
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            var speed:int
            var vertices:Vector.<Number> = new Vector.<Number>();
            var uvt:Vector.<Number> = new Vector.<Number>();
            var indices:Vector.<int> = new Vector.<int>();
            var vectorForSort:Vector.<Object> = new Vector.<Object>();
            var projectedPoints:Vector.<Number> = new Vector.<Number>();
            var perspective:PerspectiveProjection = new PerspectiveProjection();
            
            var viewMatrix:Matrix3D = new Matrix3D();
            viewMatrix.appendTranslation(0, 0, 1000);
            viewMatrix.append(perspective.toMatrix3D());
            
            var shape1:Shape = new Shape();
            addChild(shape1);
            shape1.x = stage.stageWidth / 2;
            shape1.y = stage.stageHeight / 2;
            
            var shape2:Shape = new Shape();
            addChild(shape2);
            shape2.x = shape1.x;
            shape2.y = shape1.y;
            shape2.blendMode = "multiply";
            
            var texture:BitmapData = new BitmapData(20, 10, false, 0xFFFFFF);
            texture.fillRect(new Rectangle(0, 0, 10, 10), 0x202020);
            
            var s:Number = (1 + Math.sqrt(5)) / 2;
            var A:Vector3D = new Vector3D( 0, -s, -1);
            var B:Vector3D = new Vector3D( 0, -s,  1);
            var C:Vector3D = new Vector3D( 0,  s,  1);
            var D:Vector3D = new Vector3D( 0,  s, -1);
            var E:Vector3D = new Vector3D(-s,  1,  0);
            var F:Vector3D = new Vector3D(-s, -1,  0);
            var G:Vector3D = new Vector3D( s, -1,  0);
            var H:Vector3D = new Vector3D( s,  1,  0);
            var I:Vector3D = new Vector3D( 1,  0, -s);
            var J:Vector3D = new Vector3D(-1,  0, -s);
            var K:Vector3D = new Vector3D(-1,  0,  s);
            var L:Vector3D = new Vector3D( 1,  0,  s);
            
            var icosahedron:Vector.<Vector3D> = Vector.<Vector3D>([
            A, F, J, A, J, I, A, I, G, A, G, B, A, B, F, 
            F, E, J, J, D, I, I, H, G, G, L, B, B, K, F, 
            E, D, J, D, H, I, H, L, G, L, K, B, K, E, F, 
            C, D, E, C, H, D, C, L, H, C, K, L, C, E, K
            ]);
            
            var soccerBall:Vector.<Vector3D> = new Vector.<Vector3D>();
            for (var i:int = 0; i < 20; i++){
                for (var j:int = 0; j < 3; j++){
                    var index:int = i * 3;
                    soccerBall.push(
                    new Vector3D(icosahedron[index].x, icosahedron[index].y, icosahedron[index].z),
                    new Vector3D((icosahedron[index].x * 2 + icosahedron[index + 1].x) / 3, (icosahedron[index].y * 2 + icosahedron[index + 1].y) / 3,  (icosahedron[index].z * 2 + icosahedron[index + 1].z) / 3), 
                    new Vector3D((icosahedron[index].x * 2 + icosahedron[index + 2].x) / 3, (icosahedron[index].y * 2 + icosahedron[index + 2].y) / 3,  (icosahedron[index].z * 2 + icosahedron[index + 2].z) / 3)
                    );
                    icosahedron.splice(index + 2, 0, icosahedron.splice(index, 1)[0]);
                    uvt.push(0, 0, 0, 0.49, 0.49, 0, 0.49, 0.49, 0);
                    index = i * 10 + j * 3;
                    vectorForSort.push({i1: index, i2: index + 1, i3: index + 2, t: 0});
                }
                index = i * 10;
                soccerBall.push(
                new Vector3D((soccerBall[index].x + soccerBall[index + 3].x + soccerBall[index + 6].x) / 3, (soccerBall[index].y + soccerBall[index + 3].y + soccerBall[index + 6].y) / 3, (soccerBall[index].z + soccerBall[index + 3].z + soccerBall[index + 6].z) / 3)
                );
                uvt.push(1, 1, 0);
                vectorForSort.push({i1: index + 9, i2: index + 2, i3: index + 1, t: 0});
                vectorForSort.push({i1: index + 9, i2: index + 1, i3: index + 5, t: 0});
                vectorForSort.push({i1: index + 9, i2: index + 5, i3: index + 4, t: 0});
                vectorForSort.push({i1: index + 9, i2: index + 4, i3: index + 8, t: 0});
                vectorForSort.push({i1: index + 9, i2: index + 8, i3: index + 7, t: 0});
                vectorForSort.push({i1: index + 9, i2: index + 7, i3: index + 2, t: 0});
            }
            
            for each (var vertex:Vector3D in soccerBall){
                vertex.normalize();
                vertex.scaleBy(220);
                vertices.push(vertex.x, vertex.y, vertex.z);
            }
            
            addEventListener(Event.ENTER_FRAME, function(e:Event):void{
                speed += 3;
                var rotation:Number = Math.atan2(shape1.mouseX, shape1.mouseY) * 180 / Math.PI;
                var modelMatrix:Matrix3D = new Matrix3D();
                modelMatrix.appendRotation(speed, Vector3D.X_AXIS);
                modelMatrix.appendRotation(-rotation, Vector3D.Z_AXIS);
                var concatenatedMatrix:Matrix3D = modelMatrix.clone();
                concatenatedMatrix.append(viewMatrix);
                Utils3D.projectVectors(concatenatedMatrix, vertices, projectedPoints, uvt);
                
                for each (var object:Object in vectorForSort){
                    object.t = Math.min(uvt[object.i1 * 3 + 2], uvt[object.i2 * 3 + 2], uvt[object.i3 * 3 + 2]);
                }
                vectorForSort.sort(function compare(p:Object, n:Object):Number{
                    return (p.t < n.t) ? -1 : 1;
                });
                var indices:Vector.<int> = new Vector.<int>();
                for each (object in vectorForSort){
                    indices.push(object.i1, object.i2, object.i3);
                }
                
                shape1.graphics.clear();
                if (Math.sqrt(shape1.mouseX * shape1.mouseX + shape1.mouseY * shape1.mouseY) < 150){
                    shape1.graphics.lineStyle(1, 0xFF0000, 0.5);
                }
                shape1.graphics.beginBitmapFill(texture, null, false, false);
                shape1.graphics.drawTriangles(projectedPoints, indices, uvt, "positive");
                shape1.graphics.endFill();
                shape1.graphics.lineStyle(1, 0x000000, 1);
                shape1.graphics.drawCircle(0, 0, 106);
                
                shape2.graphics.clear(); 
                for (i = 90; i < 170; i++){
                    index = i * 3;
                    var color:int = Math.round(0xFF / 75 * (vectorForSort[i].t * 100000 - 47));
                    shape2.graphics.beginFill((color << 16) + (color << 8) + (color));
                    shape2.graphics.moveTo(projectedPoints[indices[index] * 2], projectedPoints[indices[index] * 2 + 1]);
                    shape2.graphics.lineTo(projectedPoints[indices[(index + 1)] * 2], projectedPoints[indices[(index + 1)] * 2 + 1]);
                    shape2.graphics.lineTo(projectedPoints[indices[(index + 2)] * 2], projectedPoints[indices[(index + 2)] * 2 + 1]);
                }
            })
        }
    }
}