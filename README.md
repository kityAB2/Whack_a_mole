# Whack_a_mole
VGA显示三个场景
该项目实现了一个基于verilog语言，外设包括矩阵键盘、VGA显示器、动态数码管。
①游戏开始之前进行难度选择，显示【打地鼠游戏难度选择】、【简单】、【进阶】，不同模式对应着地鼠出现的快慢
②游戏开始之后界面划分成4×4棋盘格，地鼠用图片表示，对应着4×4键盘按键，得分在数码管显示
③游戏结束后显示【游戏结束】
④游戏开始播放一种背景音乐，游戏结束播放一种北京音乐。

技术要点：伪随机数生成、VGA信号驱动、矩阵键盘驱动、动态数码管驱动

地鼠出现图片：
<img src="[https://img-blog.csdnimg.cn/2020102116384135.png](https://github.com/kityAB2/Whack_a_mole_game/blob/master/imag/QQ%E5%9B%BE%E7%89%8720230316112301.jpg)" width="100px">

地鼠消失图片
<img src="[[https://img-blog.csdnimg.cn/2020102116384135.png](https://github.com/kityAB2/Whack_a_mole_game/blob/master/imag/QQ%E5%9B%BE%E7%89%8720230316112301.jpg](https://github.com/kityAB2/Whack_a_mole_game/blob/master/imag/QQ%E5%9B%BE%E7%89%8720230316112321.jpg))" width="100px">
