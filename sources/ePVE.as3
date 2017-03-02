/*
Stage3Dでエッジ検出（+ Away3D）
・自作ドット絵エディタにて使用するため、エッジ検出の実装テスト
・深度バッファはStage3Dの標準サポートではないので、Away3Dが独自に計算しているものを使うことにした

アルゴリズム概要
・基本の部分は今給黎さんの「DirectX9 シェーダプログラミングブック」の「輪郭抽出」の項目にあるものと同じ
　・レンダリングの結果を元に、周囲の「深度」「法線」「ID」のいずれかの差が一定以上であればエッジを描く
　・今回は「深度」の差を元に輪郭を表示
　・ドット絵用にサンプリングの位置を少し変更して実装してみる

wonderflに上げる際の注意点
・wmode = directにする
・キャプチャ画像はStageの方しか行われないので、そちらにキャプチャ用の画像を用意
*/



package
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;

    import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.entities.*;
    import away3d.filters.*;
    import away3d.lights.*;
    import away3d.materials.*;
    import away3d.materials.lightpickers.*;
    import away3d.primitives.*;

    [SWF(width="465", height="465", frameRate="60", backgroundColor="0xFFFFFF")]
    public class Test extends View3D
    {
        //==Const==

        //エッジ検出用パラメータ
        //- 深度がこれ以上の差であればエッジを表示する
        static public const DEPTH_THRESHOLD    :Number = 0.009;
        //- エッジの色を本来の色にこれをかけた色にする
        static public const COLOR_SHADE_RATIO    :Number = 0.3;

        //カメラ位置（Rotation考慮）
        static public const CAMERA_DISTANCE_XZ    :Number    = 1000;
        static public const CAMERA_DISTANCE_Y    :Number    = 1000;
        //回転速度
        static public const ROT_VEL                :Number    = 1.0;

        //Util
        static public const POS_ZERO            :Vector3D    = new Vector3D(0,0,0);


        //==Var==

        //Away3D
        private var m_View                :View3D;
        private var m_Scene                :Scene3D;
        private var m_Camera            :Camera3D;

        //Rot
        private var m_RotTheta            :Number = 0;

        //For Wonderfl
//*
        private var source:BitmapData = new BitmapData(465, 465, true, 0x000000);
//*/
        //==Function==

        //Init
        public function Test()
        {
//*
            //For Wonderfl
            {
                Wonderfl.disable_capture();
                addChild(new Bitmap(source));
            }
//*/
            //Away3D Init
            {
                m_View = addChild(new View3D()) as View3D;
                m_View.antiAlias = 4;
                m_View.backgroundColor = 0x888888;
                m_View.backgroundAlpha = 0;

                m_Scene = m_View.scene;
                m_Camera = m_View.camera;
            }

            //Camera
            {
                m_Camera.y = CAMERA_DISTANCE_Y;
                m_Camera.z = CAMERA_DISTANCE_XZ;
                m_Camera.lookAt(POS_ZERO);
            }

            //Light
            var lightPicker:StaticLightPicker;
            {
                var light:DirectionalLight = new DirectionalLight(1, -8, 2);
                light.specular = 0.1;
                light.ambient = 0.7;
                m_Scene.addChild(light);

                lightPicker = new StaticLightPicker([light]);
            }

            //Filter
            {
                var edge_filter:EdgeDetectionFilter3D = new EdgeDetectionFilter3D(DEPTH_THRESHOLD, COLOR_SHADE_RATIO);
                m_View.filters3d = [edge_filter];
            }

            //Cube
            {
                const CUBE_W:int = 256;

                var cube_geometry    :CubeGeometry = new CubeGeometry(CUBE_W, CUBE_W, CUBE_W, 4, 4, 4);
                var material        :ColorMaterial = new ColorMaterial(0x88AAAA);
                material.lightPicker = lightPicker;

                var cube_mesh:Mesh;
                for(var i:int = 0; i < 6; ++i){
                    cube_mesh = new Mesh(cube_geometry, material);

                    switch(i){
                    case 0: cube_mesh.x += CUBE_W; break;
                    case 1: cube_mesh.x -= CUBE_W; break;
                    case 2: cube_mesh.y += CUBE_W; break;
                    case 3: cube_mesh.y -= CUBE_W; break;
                    case 4: cube_mesh.z += CUBE_W; break;
                    case 5: cube_mesh.z -= CUBE_W; break;
                    }

                    m_Scene.addChild(cube_mesh);
                }
            }

            //Update
            {
                addEventListener(Event.ENTER_FRAME, Update);
            }
        }

        private function Update(event:Event = null):void
        {
            var delta_time:Number = 1.0 / stage.frameRate;

            //Rotation
            {
                m_RotTheta += ROT_VEL * delta_time;
                if(2*Math.PI <= m_RotTheta){m_RotTheta -= 2*Math.PI;}

                m_Camera.x = CAMERA_DISTANCE_XZ * Math.sin(m_RotTheta);
                m_Camera.z = CAMERA_DISTANCE_XZ * Math.cos(m_RotTheta);

                m_Camera.lookAt(POS_ZERO);
            }

            //Render
            {
                m_View.render();
            }
//*
            //For Wonderfl
            {
                m_View.renderer.queueSnapshot(source);
            }
//*/
        }
    }
}


import away3d.arcane;
import away3d.cameras.*;
import away3d.core.managers.*;
import away3d.filters.*;
import away3d.filters.tasks.*;

import flash.display3D.*;
import flash.display3D.*;
import flash.display3D.textures.*;


use namespace arcane;

class EdgeDetectionFilter3D extends Filter3DBase
{
    //==Var==

    //Task
    private var m_Task_EdgeDetection : Filter3DEdgeDetectionTask;


    //==Function==

    //Init
    public function EdgeDetectionFilter3D(depth_threshold:Number = 100, color_shade_ratio:Number = 0.0)
    {
        super();
        m_Task_EdgeDetection = new Filter3DEdgeDetectionTask(depth_threshold, color_shade_ratio);
        addTask(m_Task_EdgeDetection);
    }
}


class Filter3DEdgeDetectionTask extends Filter3DTaskBase
{
    //==Var==

    //Shader Const
    private var _data : Vector.<Number>;


    //==Function==

    //Init
    public function Filter3DEdgeDetectionTask(depth_threshold:Number, color_shade_ratio:Number)
    {
        super(true);

        _data = Vector.<Number>([
            0, 0, 0, 0,//offsetA
            0, 0, 0, 0,//offsetB
            depth_threshold, 1 - color_shade_ratio, 0, 0,//[depth_threshold, 1 - color_shade_ratio, 0, ??]
            1.0, 1 / 255.0, 1 / 65025.0, 1 / 16581375.0//深度バッファのRGBとの内積をとることで深度を求める
        ]);
    }

    //Shader : Pixel
    override protected function getFragmentCode() : String
    {
        var code:String;

        //「左上と右下」「右上と左下」のDepthの差（絶対値）の合計を求める
        //- ft0 : posA0,    ft1 : posA1,    ft2 : posB0,    ft3 : posB1
        //- ft4 : depthA0,    ft5 : depthA1,    ft6 : depthB0,    ft7 : depthB1,
        //- ft4 : AbsGapA,    ft6 : AbsGapB
        //- ft4 : TotalGap
        code =    "sub ft0, v0, fc0    \n" +//ft0 = v0 - fc0
                "add ft1, v0, fc0    \n" +//ft1 = v0 + fc0
                "sub ft2, v0, fc1    \n" +//ft2 = v0 - fc1
                "add ft3, v0, fc1    \n" +//ft3 = v0 + fc1
                "tex ft4, ft0, fs1 <2d, nearest>    \n" +//ft4 = fs1.get(ft0)
                "tex ft5, ft1, fs1 <2d, nearest>    \n" +//ft5 = fs1.get(ft1)
                "tex ft6, ft2, fs1 <2d, nearest>    \n" +//ft6 = fs1.get(ft2)
                "tex ft7, ft3, fs1 <2d, nearest>    \n" +//ft7 = fs1.get(ft3)
                "dp4 ft4.z, ft4, fc3        \n" +//ft4.z = rgb_to_depth(ft4)
                "dp4 ft5.z, ft5, fc3        \n" +//ft5.z = rgb_to_depth(ft5)
                "dp4 ft6.z, ft6, fc3        \n" +//ft6.z = rgb_to_depth(ft6)
                "dp4 ft7.z, ft7, fc3        \n" +//ft7.z = rgb_to_depth(ft7)
                "sub ft4.z, ft4.z, ft5.z    \n" +//ft4.z -= ft5.z
                "abs ft4.z, ft4.z            \n" +//ft4.z = abs(ft4.z)
                "sub ft6.z, ft6.z, ft7.z    \n" +//ft6.z -= ft7.z
                "abs ft6.z, ft6.z            \n" +//ft6.z = abs(ft6.z)
                "add ft4.z, ft4.z, ft6.z    \n";//ft4.z += ft6.z

        //Depthの差の合計が閾値以下なら普通の描画、閾値以上なら暗くして描画する
        //- ft0 : Color (Ori => Ori-Dec)
        //- ft1 : 
        //- ft2 : DecColor
        code += "tex ft0, v0, fs0 <2d,linear,clamp>    \n" +//ft0 = fs0.get(v0)
                "slt ft1.x, fc2.x, ft4.z    \n" +//ft1.x = (threshold < depth) // 0:通常描画, 1:陰描画
                "mul ft1.x, ft1.x, fc2.y    \n" +//ft1.x *= ft3.y // 0:通常描画, dec_color_shade_ratio:陰描画
                "mul ft2, ft1.x, ft0        \n" +//ft2 = ft1.x * ft0 // ori*0:通常描画, ori*dec_color_shade_ratio:陰描画
                "mov ft2.w, fc2.z            \n" +//ft2.a = 0
                "sub oc, ft0, ft2            \n";//output = ft0 - ft2 // ori:通常描画, ori*color_shade_ratio:陰描画

        return code;
    }

    //Activate : on
    override public function activate(stage3DProxy : Stage3DProxy, camera : Camera3D, depthTexture : Texture) : void
    {
        var context : Context3D = stage3DProxy._context3D;

        //fs1 = depthTexture
        stage3DProxy.setTextureAt(1, depthTexture);

        //fc0 = _data[0～3]
        //fc1 = _data[4～7]
        //fc2 = _data[8～11]
        //fc3 = _data[12～15]
        context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _data, 4);
    }

    //Activate : off
    override public function deactivate(stage3DProxy : Stage3DProxy) : void
    {
        stage3DProxy.setTextureAt(1, null);
    }

    //Update : textures
    override protected function updateTextures(stage : Stage3DProxy) : void
    {
        super.updateTextures(stage);

        updateData();
    }

    //Update : data
    private function updateData() : void
    {
        var invW : Number = 1 / _textureWidth;

        //OffsetA
        //fc0 = [-invW, -invW, 0, 0]
        _data[0] = -invW;
        _data[1] = -invW;

        //OffsetB
        //fc1 = [ invW, -invW, 0, 0]
        _data[4] =  invW;
        _data[5] = -invW;
    }
}
