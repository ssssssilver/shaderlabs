展示地址  
WebGL
http://117.48.208.243/done/Shaderlabs/index.html
  
# shaderlabs  
Unity版本5.3.6p7  
只要版本比这个高基本不会出太大问题  
使用shaderlab制作的着色器案例  
=============================================================  
1.模拟草随风飘动着色器 通过顶点着色器修改模型顶点 模拟风吹的效果  
![风吹草动](https://github.com/ssssssilver/shaderlabs/blob/master/preview/1.grass.gif)

2.背景滚动着色器 通过改变uv的偏移速度来让图片产生滚动效果 通过插值的方法 能让背景与多个透明的前景混合  
![背景滚动](https://github.com/ssssssilver/shaderlabs/blob/master/preview/scroll.gif)

3.边缘检测着色器 通过对每个顶点的八个方向的透明度进行检测从而求出透明图片的边缘  
![边缘检测](https://github.com/ssssssilver/shaderlabs/blob/master/preview/edge.gif)

4.遮罩着色器 通过利用遮罩图的a通道 如果没有遮罩图 也可以使用着色器创建一个圆来进行蒙版  
![遮罩模拟器](https://github.com/ssssssilver/shaderlabs/blob/master/preview/mask.gif)

5.边缘高光着色器 根据世界法线与视角的点积来求出边缘 进行着色  
![边缘高光](https://github.com/ssssssilver/shaderlabs/blob/master/preview/specular.gif)

6.渐变着色器 根据世界位置的y轴来改变模型的颜色 并用插值来产生渐变效果  
![渐变](https://github.com/ssssssilver/shaderlabs/blob/master/preview/ychange.gif)

7.卡通着色器 第一层Pass只渲染背部，用于显示模型的轮廓 第二层通道的漫反射用渐变纹理采样代替 高光部分用Step方法让边界部分变得尖锐    
![卡通着色](https://github.com/ssssssilver/shaderlabs/blob/master/preview/cartoon.jpg)

8.旗子飘动着色器 通过sin函数与_Time方法来改变模型坐标顶点z的位置 并与uv的X轴相乘 让波动幅度在x轴上递增 从而模拟旗子效果  
![旗子飘动](https://github.com/ssssssilver/shaderlabs/blob/master/preview/flag.gif)

9.过场着色器 或者叫黑场、转场着色器 通过改变遮罩图的tiling跟offset 让贴图产生缩放与旋转的效果 利用此遮罩图的a值 可以控制材质的显示或者隐藏从中心扩散到四周  
![过场](https://github.com/ssssssilver/shaderlabs/blob/master/preview/maskfading.gif)

10.水着色器 使用GrabPass获取屏幕图像作为折射采样 cubemap作为反射采样  
![水](https://github.com/ssssssilver/shaderlabs/blob/master/preview/water.gif)

11.线框着色器 将面的颜色设置成通明 并且分别用宽度截取uv的开始与结束位置作为边框 最后用插值方法让面中心位置透明
![线框](https://github.com/ssssssilver/shaderlabs/blob/master/preview/line.gif)
