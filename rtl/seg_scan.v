module seg_scan
(	
	//输入端口 
	input                   clk,//时钟
    input                   rst_n,//复位
    input                   lk,
    input       [23:0]      din,
    input       [ 5:0]      dpin,
	//输出端口
	output reg 	[ 7:0]      seg_data,
    output reg 	[ 5:0]      seg_en
);


//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg			[15:0]	time_cnt;			//用来控制数码管闪烁频率的定时计数器
reg			[15:0]	time_cnt_n;			//time_cnt的下一个状态
reg			[ 2:0]	led_cnt;				//用来控制数码管亮灭及显示数据的显示计数器
reg			[ 2:0]	led_cnt_n;			//led_cnt的下一个状态
reg         [23:0]   din_tmp;          //DIN的内部锁存数据
reg         [ 3:0]   data_tmp;         //1位数码管的内部锁存数据
reg         [ 5:0]   dpin_tmp;         //DPIN的内部锁存数据
    

parameter SET_TIME_1MS = 32'd50000;//仿真时钟用	

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//显示数据锁存
always @ (posedge lk or negedge rst_n) 
begin
	if(!rst_n)									//判断复位
		begin
		din_tmp <= 24'h0;					   //初始化din_tmp值
		dpin_tmp <= 6'h0;					   //初始化dpin_tmp值
		end
	else
	   begin
		din_tmp <= din;				      //用来给din_tmp赋值
		dpin_tmp <= dpin;				      //用来给dpin_tmp赋值
		end
end

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge clk or negedge rst_n)  
begin
	if(!rst_n)									//判断复位
		time_cnt <= 16'h0;					//初始化time_cnt值
	else
		time_cnt <= time_cnt_n;				//用来给time_cnt赋值
end

//组合电路,实现1ms的定时计数器
always @ (*)  
begin
	if(time_cnt == SET_TIME_1MS-1)		//判断1ms时间
		time_cnt_n = 16'h0;					//如果到达1ms,定时计数器将会被清零
	else
		time_cnt_n = time_cnt + 16'h1;	//如果未到1ms,定时计数器将会继续累加
end

//时序电路,用来给led_cnt寄存器赋值
always @ (posedge clk or negedge rst_n)  
begin
	if(!rst_n)									//判断复位
		led_cnt <= 3'h0;						//初始化led_cnt值
	else
		led_cnt <= led_cnt_n;				//用来给led_cnt赋值
end

//组合电路,判断时间，实现控制显示计数器累加
always @ (*)  
begin
	if(time_cnt == SET_TIME_1MS-1)		//判断1ms时间	
		led_cnt_n = led_cnt + 1'h1;		//如果到达1ms,计数器进行累加
	else
		led_cnt_n = led_cnt;					//如果未到1ms,计数器保持不变
end

//组合电路,实现数码管的数字显示
always @ (*)
begin
	case (led_cnt)  
	  3'b000 : data_tmp = din_tmp[ 3: 0];  //当计数器为0时,分配第0个数码管数据
      3'b001 : data_tmp = din_tmp[ 7: 4];  //当计数器为1时,分配第1个数码管数据
      3'b010 : data_tmp = din_tmp[11: 8];  //当计数器为2时,分配第2个数码管数据
      3'b011 : data_tmp = din_tmp[15:12];  //当计数器为3时,分配第3个数码管数据
      3'b100 : data_tmp = din_tmp[19:16];  //当计数器为4时,分配第4个数码管数据
      3'b101 : data_tmp = din_tmp[23:20];  //当计数器为5时,分配第5个数码管数据	
      default: data_tmp = din_tmp[ 3: 0];	
	endcase 	
end
//组合电路,实现数码管的显示译码
always @ (*)
begin
	case (data_tmp)  
		4'b0000 : seg_data[6:0] = ~(7'b0111111);	//数码管将会显示 "0"
		4'b0001 : seg_data[6:0] = ~(7'b0000110);	//数码管将会显示 "1"
		4'b0010 : seg_data[6:0] = ~(7'b1011011);	//数码管将会显示 "2"
		4'b0011 : seg_data[6:0] = ~(7'b1001111);	//数码管将会显示 "3"
		4'b0100 : seg_data[6:0] = ~(7'b1100110);	//数码管将会显示 "4"
		4'b0101 : seg_data[6:0] = ~(7'b1101101);	//数码管将会显示 "5"	
		4'b0110 : seg_data[6:0] = ~(7'b1111101);	//数码管将会显示 "0"
		4'b0111 : seg_data[6:0] = ~(7'b0000111);	//数码管将会显示 "7"
		4'b1000 : seg_data[6:0] = ~(7'b1111111);	//数码管将会显示 "8"
		4'b1001 : seg_data[6:0] = ~(7'b1101111);	//数码管将会显示 "9"
		4'b1010 : seg_data[6:0] = ~(7'b1110111);	//数码管将会显示 "A"
		4'b1011 : seg_data[6:0] = ~(7'b1111100);	//数码管将会显示 "b"
		4'b1100 : seg_data[6:0] = ~(7'b0111001);	//数码管将会显示 "c"
		4'b1101 : seg_data[6:0] = ~(7'b1011110);	//数码管将会显示 "d"
		4'b1110 : seg_data[6:0] = ~(7'b1111001);	//数码管将会显示 "E"
		4'b1111 : seg_data[6:0] = ~(7'b1110001);	//数码管将会显示 "F"
		default:  seg_data[6:0] = ~(7'b0111111);	
	endcase 	
end

//组合电路,实现数码管的小数点显示
always @ (*)
begin
	case (led_cnt)  
		3'b000 : seg_data[7] = dpin_tmp[0];	//当计数器为0时,分配第0个数码管数据
		3'b001 : seg_data[7] = dpin_tmp[1];	//当计数器为1时,分配第1个数码管数据
		3'b010 : seg_data[7] = dpin_tmp[2];	//当计数器为2时,分配第2个数码管数据
		3'b011 : seg_data[7] = dpin_tmp[3];	//当计数器为3时,分配第3个数码管数据
		3'b100 : seg_data[7] = dpin_tmp[4];	//当计数器为4时,分配第4个数码管数据
		3'b101 : seg_data[7] = dpin_tmp[5];	//当计数器为5时,分配第5个数码管数据	
		default: seg_data[7] = dpin_tmp[0];	
	endcase 	
end
//组合电路,控制数码管亮灭
always @ (*)
begin
	case (led_cnt)  
		3'b000 : seg_en = 6'b111110;		//当计数器为0时,数码管SEG1显示
		3'b001 : seg_en = 6'b111101;		//当计数器为1时,数码管SEG2显示
		3'b010 : seg_en = 6'b111011; 		//当计数器为2时,数码管SEG3显示
		3'b011 : seg_en = 6'b110111;  	//当计数器为3时,数码管SEG4显示
		3'b100 : seg_en = 6'b101111;		//当计数器为4时,数码管SEG5显示
		3'b101 : seg_en = 6'b011111;  	//当计数器为5时,数码管SEG6显示		
		default: seg_en = 6'b111111;			
	endcase 	
end
endmodule