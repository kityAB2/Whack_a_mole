module whack_a_a_mole_game
(	
	//输入端口 
	input                   clk,//时钟
    input                   rst_n,//复位
	input                   sw,//复位
	input        [4:1] 		c,                  //列查询输入
	output       [4:1] 		r,                  //行扫描输出 
	output       [6:0] 		seg_data1,
	output       [6:0] 		seg_data2,
	output       [6:0] 		seg_data3,
	output       [6:0] 		seg_data4,
	output       [6:0] 		seg_data5,
	output       [6:0] 		seg_data6,
	    //VGA接口                          
    output          vga_hs,       //行同步信号
    output          vga_vs,       //场同步信号
    output  [23:0]  vga_rgb,      //红绿蓝三原色输出
	output          vga_clk_o,     // VGA时钟输出
	output          vga_blank,     // VGA时钟输出
	output          vga_sync,          // VGA时钟输出
	output          beep
 );
wire      	[4:0]       keyvalue;          //按键编码输出
wire             		keyfinish;         //按键锁存标志 
wire 		[3:0]  		m;//随机数

wire [1:0]        page;//页面
wire              mode;//模式
wire [3:0]        state;//游戏开始的状态
wire [3:0]        m_to_dis;//给显示模块的随机数
wire [1:0]        music_ctl;//音乐控制模块
wire     [23:0]       din;//分数显示

wire   [23:0]  pixel_data;   //像素点数据
wire   [10:0]  pixel_xpos;   //像素点横坐标
wire   [10:0]  pixel_ypos;    //像素点纵坐标

wire [15:0] dis;
scankeyboard_debounce scankeyboard_debounce_inst(
	.clk(clk),
	.rst_n(rst_n),
	.r(r),
	.c(c),
	.keyvalue(keyvalue),
	.keyfinish(keyfinish)
	);
radom radom_inst(
    .clk(clk),        // 时钟信号用50M
    .rst_n(rst_n),        // 复位信号  
    .m(m)               // 返回的随机数 
    );
whack_a_a_mole_game_ctl whack_a_a_mole_game_ctl_inst(	
	//输入端口 
	.clk(clk),//时钟
    .rst_n(rst_n),//复位
    .keyvalue(keyvalue),          //按键编码输出
	.keyfinish(keyfinish),         //按键锁存标志  
	.m(m),                 //输入的随机数  
	.page(page),//页面
	.mode(mode),//模式
	.state(state),//游戏开始的状态
	.m_to_dis(m_to_dis),//给显示模块的随机数
	.din(din)//分数显示
 );
 vga_display vga_display_inst(
    .vga_clk(clk),                  //VGA驱动时钟
    .sys_rst_n(rst_n),                //复位信号
    .page(page),                     //指示当前需要显示的页面
	.mode(mode),                     //指示当前显示的模式
	.state(state),                     //指示当前需要显示的页面
	.m(m_to_dis),				//给显示模块的随机数
    .pixel_xpos(pixel_xpos),               //像素点横坐标
    .pixel_ypos(pixel_ypos),               //像素点纵坐标    
    .pixel_data(pixel_data)                //像素点数据,
    );
vga_driver vga_driver_inst(
    .vga_clk(clk),      //VGA驱动时钟
    .sys_rst_n(rst_n),    //复位信号
    //VGA接口                          
    .vga_hs(vga_hs),       //行同步信号
    .vga_vs(vga_vs),       //场同步信号
    .vga_rgb(vga_rgb),      //红绿蓝三原色输出
    .vga_clk_o(vga_clk_o),     // VGA时钟输出
	.vga_blank(vga_blank),     // VGA时钟输出
	.vga_sync(vga_sync),          // VGA时钟输出
    .pixel_data(pixel_data),   //像素点数据
    .pixel_xpos(pixel_xpos),   //像素点横坐标
    .pixel_ypos(pixel_ypos)    //像素点纵坐标    
    );  
seg7 seg7_inst1(
    .d(din[3:0])    ,          // 数据输入
    .rst_n(rst_n)   ,       // 使能信号  低电平使能
    .seg_data(seg_data1)        // 
    );    
seg7 seg7_inst2(
    .d(din[7:4])    ,          // 数据输入
    .rst_n(rst_n)   ,       // 使能信号  低电平使能
    .seg_data(seg_data2)        // 
    ); 
seg7 seg7_inst3(
    .d(din[11:8])    ,          // 数据输入
    .rst_n(rst_n)   ,       // 使能信号  低电平使能
    .seg_data(seg_data3)        // 
    ); 
seg7 seg7_inst4(
    .d(din[15:12])    ,          // 数据输入
    .rst_n(rst_n)   ,       // 使能信号  低电平使能
    .seg_data(seg_data4)        // 
    ); 
seg7 seg7_inst5(
    .d(din[19:16])    ,          // 数据输入
    .rst_n(rst_n)   ,       // 使能信号  低电平使能
    .seg_data(seg_data5)        // 
    ); 
seg7 seg7_inst6(
    .d(din[23:20])    ,          // 数据输入
    .rst_n(rst_n)   ,       // 使能信号  低电平使能
    .seg_data(seg_data6)        // 
    ); 
autoplay autoplay_inst(
	//输入端口
	.clk(clk),
	.rst_n(rst_n&sw),
    //调号及升降八度
    .signature(5'd0),
    .octachord(2'd2),
    .beep_out(beep),
    .speed(4'd2),
    .dis(dis)
);	
endmodule