module scankeyboard_debounce(clk,rst_n,r,c,keyvalue,keyfinish);
//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input              clk;
input              rst_n; 
input        [4:1] c;                  //列查询输入
output  reg  [4:1] r;                  //行扫描输出 
output  reg  [4:0] keyvalue;           //按键编码输出
output             keyfinish;          //按键锁存标志           
//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		    [25:0]	time_cnt;			//用来计量一行扫描时间的定时计数器
reg		    [25:0]	time_cnt_n;			//time_cnt的下一个状态
reg          [ 1:0]  q;                //行扫描计数器
reg          [ 1:0]  q_n;              //q的下一个状态
reg          [ 4:1]  r_n;              //r的下一个状态
reg          [ 4:1]  c1;               //第一行的列输入
reg          [ 4:1]  c2;               //第二行的列输入
reg          [ 4:1]  c3;               //第三行的列输入
reg          [ 4:1]  c4;               //第四行的列输入
reg          [ 4:1]  c1_n;             //C1的下一个状态
reg          [ 4:1]  c2_n;             //C2的下一个状态
reg          [ 4:1]  c3_n;             //C3的下一个状态
reg          [ 4:1]  c4_n;             //C4的下一个状态
wire         [ 4:1]  c1_tmp;           //第一行的去抖列输入
wire         [ 4:1]  c2_tmp;           //第二行的去抖列输入
wire         [ 4:1]  c3_tmp;           //第三行的去抖列输入
wire         [ 4:1]  c4_tmp;           //第四行的去抖列输入
reg          [ 3:0]  keyflag;          //每行是否有键按下的标志
reg          [ 3:0]  keyflag_n;        //keyflag的下一个状态
reg          [ 4:0]  keyvalue_n;       //keyvalue的下一个状态
//设置定时器的时间默认为5ms,计算方法为(5*10^3)us / (1/50)us 50MHz为开发板晶振
parameter SET_TIME = 26'd250_000;	

//时序电路,用来给time_cnt寄存器赋值
always @ (posedge clk or negedge rst_n)  
begin
	if(!rst_n)									//判断复位
		time_cnt <= 26'h0;					//初始化time_cnt值
	else
		time_cnt <= time_cnt_n;				//用来给time_cnt赋值
end
//组合电路,实现5ms的定时计数器
always @ (*)  
begin
	if(time_cnt == SET_TIME-1)			   //判断5ms时间
		time_cnt_n = 26'h0;					//如果到达5ms,定时计数器将会被清零
	else
		time_cnt_n = time_cnt + 26'h1;	//如果未到5ms,定时计数器将会继续累加
end

//时序电路,用来给q寄存器赋值
always @ (posedge clk or negedge rst_n)  
begin
	if(!rst_n)								   //判断复位
		q <= 2'b0;					         //初始化q值
	else
		q <= q_n;				            //用来给q赋值
end
//组合电路,实现q的定时计数器
always @ (*)  
begin
	if(time_cnt == SET_TIME-1)          //判断是否扫描下一行
		q_n = q+1'b1;                    //行计数器加1
	else
	   q_n = q;                         //行计数器不变
end

//时序电路,用来给r寄存器赋值
always @ (posedge clk or negedge rst_n)  
begin
	if(!rst_n)								   //判断复位
		r <= 4'b1110;					      //初始化r值
	else
		r <= r_n;				            //用来给r赋值
end
//组合电路,实现行扫描输出
always @ (*)  
begin
	case(q)
	  0:r_n=4'b1110;
	  1:r_n=4'b1101;
	  2:r_n=4'b1011;
	  3:r_n=4'b0111;
	endcase                        
end

//c1去抖
always @ (posedge r[1])  //第一行相邻两个扫描时刻采样
begin
	c1 <= c;					
   c1_n <= c1;				
end
assign c1_tmp=c1|c1_n;   //第一行去抖查询输入
//c2去抖
always @ (posedge r[2])  //第二行相邻两个扫描时刻采样
begin
	c2 <= c;					
   c2_n <= c2;				
end
assign c2_tmp=c2|c2_n;   //第二行去抖查询输入
//c3去抖
always @ (posedge r[3])  //第三行相邻两个扫描时刻采样
begin
	c3 <= c;					
   c3_n <= c3;				
end
assign c3_tmp=c3|c3_n;   //第三行去抖查询输入
//c4去抖
always @ (posedge r[4])  //第四行相邻两个扫描时刻采样
begin
	c4 <= c;					
   c4_n <= c4;				
end
assign c4_tmp=c4|c4_n;   //第四行去抖查询输入

//时序电路,用来给keyflag寄存器赋值
always @ (posedge clk or negedge rst_n)  
begin
	if(!rst_n)								   //判断复位
		keyflag <= 4'b1111;					//初始化keyflag值
	else
		keyflag <= keyflag_n;				//用来给keyflag赋值
end
//组合电路,实现keyflag标志位
always @ (*)  
begin
	case(r)
	  4'b1110:if (c1_tmp==4'b1111)
					keyflag_n={keyflag[3:1],1'b1};
				 else
					keyflag_n={keyflag[3:1],1'b0};	 
	  4'b1101:if (c2_tmp==4'b1111)
					keyflag_n={keyflag[3:2],1'b1,keyflag[0]};
				 else
					keyflag_n={keyflag[3:2],1'b0,keyflag[0]};
	  4'b1011:if (c3_tmp==4'b1111)
					keyflag_n={keyflag[3],1'b1,keyflag[1:0]};
				 else
					keyflag_n={keyflag[3],1'b0,keyflag[1:0]}; 
	  4'b0111:if (c4_tmp==4'b1111)
					keyflag_n={1'b1,keyflag[2:0]}; 
				 else
					keyflag_n={1'b0,keyflag[2:0]}; 	 
	  default: keyflag_n=keyflag;	
	endcase                         
end

//时序电路,用来给keyvalue寄存器赋值
always @ (posedge clk or negedge rst_n)  
begin
	if(!rst_n)								   //判断复位
		keyvalue <= 5'b10000;				//初始化keyvalue值
	else
		keyvalue <= keyvalue_n;				//用来给keyvalue赋值
end
//组合电路,实现keyvalue的按键编码
always @ (*)  
begin	
   case(keyflag)
	4'b1110:
	  case(c1_tmp)
		  4'b1110:keyvalue_n= 5'b00000;
		  4'b1101:keyvalue_n= 5'b00001;
		  4'b1011:keyvalue_n= 5'b00010;
		  4'b0111:keyvalue_n= 5'b00011;
		  default:keyvalue_n= keyvalue;
	  endcase
	4'b1101:
	  case(c2_tmp)
		  4'b1110:keyvalue_n= 5'b00100;
		  4'b1101:keyvalue_n= 5'b00101;
		  4'b1011:keyvalue_n= 5'b00110;
		  4'b0111:keyvalue_n= 5'b00111;
		  default:keyvalue_n= keyvalue;
	  endcase	
	4'b1011:
	  case(c3_tmp)
		  4'b1110:keyvalue_n= 5'b01000;
		  4'b1101:keyvalue_n= 5'b01001;
		  4'b1011:keyvalue_n= 5'b01010;
		  4'b0111:keyvalue_n= 5'b01011;
		  default:keyvalue_n= keyvalue;
	  endcase
	4'b0111:
	  case(c4_tmp)
		  4'b1110:keyvalue_n= 5'b01100;
		  4'b1101:keyvalue_n= 5'b01101;
		  4'b1011:keyvalue_n= 5'b01110;
		  4'b0111:keyvalue_n= 5'b01111;
		  default:keyvalue_n= keyvalue;
	  endcase
	4'b1111: keyvalue_n= 5'b10000;
	default: keyvalue_n= keyvalue;
	endcase
end
assign keyfinish=&keyflag;     //生成键值锁存标志
endmodule
