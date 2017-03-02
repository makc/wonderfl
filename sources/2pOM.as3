package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class OpenCVThin extends Sprite
	{
		
		public function OpenCVThin() 
		{
			stage.quality = StageQuality.LOW;
			var tf:TextField = new TextField;
			var tfm:TextFormat = new TextFormat;
			tfm.size = 50;
			tfm.bold = true;
			tf.defaultTextFormat = tfm;
			tf.autoSize = "left";
			tf.text = "OpenCV Thin flash";
			
			var src:BitmapData = new BitmapData(tf.width, tf.height, true, 0);
			src.draw(tf);
			var dst:BitmapData = src.clone();
			addChild(new Bitmap(src));
			cvThin(src, dst, 5);
			var dsti:Bitmap = new Bitmap(dst);
			addChild(dsti);
			dsti.y = src.height;
		}
		public function cvThin(src:BitmapData, dst:BitmapData, iterations:int=1):void
		{
			var  size:Rectangle = src.rect;

			dst.setVector(dst.rect, src.getVector(src.rect));////cvCopy(src, dst);

			for(var n:int=0; n<iterations; n++)
			{
				var t_image:BitmapData = dst.clone();//cvCloneImage(dst);
				for(var i:int=0; i<size.height;  i++)
				{
					for(var j:int=0; j<size.width; j++)
					{
						//if(CV_IMAGE_ELEM(t_image,byte,i,j)==1)
						if(t_image.getPixel32(j,i)>0)
						{
							var ap:int=0;
							var p2:int = (i == 0)?0:Math.min(1,t_image.getPixel32(j,i-1));//CV_IMAGE_ELEM(t_image,byte, i-1, j);
							var p3:int = (i == 0 || j == size.width - 1)?0:Math.min(1,t_image.getPixel32(j+1,i - 1));////CV_IMAGE_ELEM(t_image,byte, i-1, j+1);
							if (p2==0 && p3==1)
							{
								ap++;
							}
							var p4:int = (j == size.width - 1)?0:Math.min(1,t_image.getPixel32(j + 1,i));////CV_IMAGE_ELEM(t_image,byte,i,j+1);
							if(p3==0 && p4==1)
							{
								ap++;
							}
							var p5:int = (i == size.height - 1 || j == size.width - 1)?0:Math.min(1,t_image.getPixel32(j + 1, i + 1));////CV_IMAGE_ELEM(t_image,byte,i+1,j+1);
							if(p4==0 && p5==1)
							{
								ap++;
							}
							var p6:int = (i == size.height - 1)?0:Math.min(1,t_image.getPixel32(j,i + 1));////CV_IMAGE_ELEM(t_image,byte,i+1,j);
							if(p5==0 && p6==1)
							{
								ap++;
							}
							var p7:int = (i == size.height - 1 || j == 0)?0:Math.min(1,t_image.getPixel32(j - 1,i + 1));////CV_IMAGE_ELEM(t_image,byte,i+1,j-1);
							if(p6==0 && p7==1)
							{
								ap++;
							}
							var p8:int = (j == 0)?0:Math.min(1,t_image.getPixel32(j - 1,i));////CV_IMAGE_ELEM(t_image,byte,i,j-1);
							if(p7==0 && p8==1)
							{
								ap++;
							}
							var p9:int = (i == 0 || j == 0)?0:Math.min(1,t_image.getPixel32(j - 1, i - 1));////CV_IMAGE_ELEM(t_image,byte,i-1,j-1);
							if(p8==0 && p9==1)
							{
								ap++;
							}
							if(p9==0 && p2==1)
							{
								ap++;
							}
							if((p2+p3+p4+p5+p6+p7+p8+p9)>1 && (p2+p3+p4+p5+p6+p7+p8+p9)<7)
							{
								if(ap==1)
								{
									if(p2*p4*p6==0)
									{
										if(p4*p6*p8==0)
										{
											dst.setPixel32(j, i, 0);
											//CV_IMAGE_ELEM(dst,byte,i,j)=0;
										}
									}
								}
							}
						
						}
					}
				}
				//cvReleaseImage(&t_image);
				t_image = dst.clone();//cvCloneImage(dst);
				for(i=0; i<size.height;  i++)
				{
					for(j=0; j<size.width; j++)
					{
						//if(CV_IMAGE_ELEM(t_image,byte,i,j)==1)
						if(t_image.getPixel32(j,i)>0)
						{
							ap=0;
							p2 = (i==0)?0:Math.min(1,t_image.getPixel32(j,i-1));//CV_IMAGE_ELEM(t_image,byte, i-1, j);
							p3 = (i == 0 || j == size.width - 1)?0:Math.min(1,t_image.getPixel32(j+1,i-1));//CV_IMAGE_ELEM(t_image,byte, i-1, j+1);
							if (p2==0 && p3==1)
							{
								ap++;
							}
							 p4 = (j==size.width-1)?0:Math.min(1,t_image.getPixel32(j+1,i));//CV_IMAGE_ELEM(t_image,byte,i,j+1);
							if(p3==0 && p4==1)
							{
								ap++;
							}
							 p5 = (i==size.height-1 || j==size.width-1)?0:Math.min(1,t_image.getPixel32(j+1, i+1));//CV_IMAGE_ELEM(t_image,byte,i+1,j+1);
							if(p4==0 && p5==1)
							{
								ap++;
							}
							 p6 = (i==size.height-1)?0:Math.min(1,t_image.getPixel32(j,i+1));//CV_IMAGE_ELEM(t_image,byte,i+1,j);
							if(p5==0 && p6==1)
							{
								ap++;
							}
							 p7 = (i==size.height-1 || j==0)?0:Math.min(1,t_image.getPixel32(j-1,i+1));//CV_IMAGE_ELEM(t_image,byte,i+1,j-1);
							if(p6==0 && p7==1)
							{
								ap++;
							}
							 p8 = (j==0)?0:Math.min(1,t_image.getPixel32(j-1,i));//CV_IMAGE_ELEM(t_image,byte,i,j-1);
							if(p7==0 && p8==1)
							{
								ap++;
							}
							 p9 = (i==0 || j==0)?0:Math.min(1,t_image.getPixel32(j-1, i-1));//CV_IMAGE_ELEM(t_image,byte,i-1,j-1);
							if(p8==0 && p9==1)
							{
								ap++;
							}
							if(p9==0 && p2==1)
							{
								ap++;
							}
							if((p2+p3+p4+p5+p6+p7+p8+p9)>1 && (p2+p3+p4+p5+p6+p7+p8+p9)<7)
							{
								if(ap==1)
								{
									if(p2*p4*p8==0)
									{
										if(p2*p6*p8==0)
										{
											dst.setPixel32(j, i, 0);
											//CV_IMAGE_ELEM(dst, byte,i,j)=0;
										}
									}
								}
							}                    
						}

					}
				   
				}            
				//cvReleaseImage(&t_image);
			}

		}
		
	}

}
