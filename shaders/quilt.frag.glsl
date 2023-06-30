//设置浮点数精度为中等精度。这告诉 GPU 在计算浮点数时使用中等精度，以平衡性能和精度需求
precision mediump float;

//定义一个名为 resolution 的二维向量型【统一变量】（名称是可自定义的，但在着色器代码中需保持一致性）。它表示渲染目标的分辨率，即输出画布的宽度和高度
uniform vec2 resolution;

//定义一个名为 time 的浮点型统一变量。它表示当前的时间，可以用于创建基于时间的动画效果
uniform float time;

//定义一个名为 seed 的浮点型统一变量。它表示一个种子值，可用于产生随机数或其他随机相关的操作
uniform float seed;

//主函数
void main() {
    //计算当前片元的归一化坐标：gl_FragCoord.xy表示当前片元的x和y像素坐标。将其除以 resolution 以将坐标归一化为 0.0 ~ 1.0 的范围
    vec2 coord = gl_FragCoord.xy / resolution;
    /**
    【gl_FragCoord】
    是一个内建变量（变量名不可更改），在片元着色器（Fragment Shader）中用于表示当前片元的像素坐标（屏幕坐标）。它是一个四维向量，包含了当前片元在
    渲染目标上的 x、y、z 和 w 坐标。
    gl_FragCoord.x 表示当前片元在渲染目标上的 x 坐标
    gl_FragCoord.y ... ... y 坐标
    gl_FragCoord.z ... ...深度值（从相机视角到片元的距离）
    gl_FragCoord.w 表示当前片元的透视除法因子

    这些坐标是以像素为单位的，即它们表示屏幕上每个片元的像素位置。片元着色器中可以使用 gl_FragCoord 来执行各种与像素位置相关的操作，
    例如基于坐标创建纹理映射、执行屏幕空间计算或创建特定的效果。
    需要注意的是，gl_FragCoord 是只读变量，无法修改其值。它由渲染管线在执行片元着色器时自动设置，并在每个片元的执行过程中保持不变
    */

    // Output RGB color in range from 0.0 to 1.0
    //创建一个三维向量 color，其中红色分量（R）等于 coord.x，绿色分量（G）等于 coord.y，蓝色分量（B）初始化为 0.0
    vec3 color = vec3(coord.x, coord.y, 0.0);
    //将颜色向量的蓝色分量加上 sin(time) 的绝对值。sin(time) 返回时间的正弦值，可以在时间上创建一个周期性变化的颜色效果
    // color.z += abs(sin(time));

    // 1. Uncomment these lines to draw triangles（画三角形）
    // '20.0 * gl_FragCoord.xy / resolution.y' ：此表达式将屏幕空间坐标 （ gl_FragCoord.xy ） 缩放系数 20.0，然后除以呈现目标
    //                                               的高度 （ resolution.y ）。此缩放和归一化步骤可确保生成的坐标在所需范围内
    // 'vec2(time)'' ：time 通常是一个值，表示自程序或动画启动以来的当前时间（以秒为单位）。这里使用它在计算中引入基于时间的变化
    // 将它们相加是将空间坐标与基于时间的变化相结合，从而可以根据片段的位置和时间创建动态效果或动画
    vec2 squareCoord = 20.0 * gl_FragCoord.xy / resolution.y + vec2(time);
    //'fract() 函数' ：返回向量或标量值的小数部分。
    //'fract(squareCoord)' ：计算squareCoord向量每个分量的分数。这实质上是删除坐标的整数部分，只保留小数部分
    vec2 loc = fract(squareCoord);
    // `loc.y - loc.x `： 计算 loc 向量的 y 分量和 x 分量之间的差值。此差值表示坐标的梯度或坡度
    // `smoothstep()函数`： 在两个阈值之间执行平滑插值
    // `smoothstep(-0.05, 0.05, loc.y - loc.x)`： 在阈值 -0.05 和 0.05 之间执行平滑插值，该插值就是前面计算的坐标的梯度或坡度
    // 前面生成的计算结果用作3D color矢量的红色、绿色和蓝色分量。这将创建灰度颜色，其中强度根据坐标的变化而变化
    color = vec3(smoothstep(-0.05, 0.05, loc.y - loc.x));

    // 2. Uncomment these lines to invert some of the triangles （反转三角形）
    // `squareCoord - loc` ：执行向量减法，从而生成一个新向量 cell 。此计算确定修改后的坐标与这些坐标的小数部分之间的差异
    // vec2 cell = squareCoord - loc;
    // `2.0 * cell.x + cell.y` ：将cell x 分量乘以 2.0（向量乘法），然后添加到cell y 分量中（向量加法）。结果表示的是cell 分量的线性组合
    // `mod() 函数`：取余（模）
    // `mod(2.0 * cell.x + cell.y, 5.0)` ：取前面计算结果除以 5.0 的模（余数），如果等于1.0就执行`1.0 - color`，进行颜色反转
    // if (mod(2.0 * cell.x + cell.y, 5.0) == 1.0) {
    //     color = 1.0 - color;
    // }

    // 3. Uncomment these lines to produce interesting colors（创建有趣的颜色）
    // 将计算结果先取7.0的模再除以7.0，可以有效地将其标准化为 0.0 到 1.0 之间的范围，确保最后的值为分数
    // float c = mod(3.0 * cell.x + 2.0 * cell.y, 7.0) / 7.0;
    // color = 1.0 - (1.0 - color) * vec3(c, c, c);

    // 4. Uncomment to lighten the colors （提亮）
    // sqrt(color) 函数计算 color 向量每个分量的平方根后再将平方根运算的结果将赋回 color 矢量，将原始颜色值替换为其平方根值。这可能会导致外观变浅或变暗，具体取决于原始颜色值
    // color = sqrt(color);

    gl_FragColor = vec4(color, 1.0);
    /**
    【gl_FragColor】
    是 OpenGL ES 着色语言 （GLSL） 中的预定义变量（内置变量是预定义变量的子集，表示 GLSL 语言本身固有的变量）。它表示片段着色器中
    片段的输出颜色，可以直接分配最终的颜色值。
    */
}
