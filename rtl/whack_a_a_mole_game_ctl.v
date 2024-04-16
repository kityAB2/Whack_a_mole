module whack_a_a_mole_game_ctl
(	
	//输入端口 
	input                   clk,//时钟
    input                   rst_n,//复位
    input      [4:0]        keyvalue,          //按键编码输出
	input             		keyfinish,         //按键锁存标志  
	input      [3:0]  		m,                 //输入的随机数  
	output reg [1:0]        page,//页面
	output reg              mode,//模式
	output reg [3:0]        state,//游戏开始的状态
	output reg [3:0]        m_to_dis,//给显示模块的随机数
	output     [23:0]       din//分数显示
 );
///////////////矩阵键盘转独立按键////////////////////////////////
//矩阵键盘转独立按键
reg  [15:0] key,key_n1,key_n2;
wire [15:0] key_fin;
//游戏相关
reg [31:0] num;
reg [31:0] game_cnt;
reg [31:0] cnt;
parameter MODE1_TIME = 32'd100000000;//模式1时间
parameter MODE2_TIME = 32'd50000000;//模式2时间
parameter TRANSITION_TIME = 32'd5000000;//过渡时间
parameter PIC2_TIME = 32'd50000000;//第三2时间
parameter INIT_ST = 4'd0;//游戏过程中状态机显示格子
parameter PIC1_ST = 4'd1;//游戏过程中状态机显示地鼠
parameter PIC2_ST = 4'd2;//游戏过程中状态机显示地鼠
//对分数取BCD码
assign din[23:20]= num/20'd100000%4'd10;
assign din[19:16]= num/16'd10000%4'd10;
assign din[15:12]= num/12'd1000%4'd10;
assign din[11:8]= num/8'd100%4'd10;
assign din[ 7:4]= num/4'd10%4'd10;
assign din[ 3:0]= num%4'd10;
always @ (posedge clk or negedge rst_n)  
begin
	if(!rst_n) begin						
		key <= 16'b0000000000000000;
	end
	else begin
		case(keyvalue)
			5'b00000:key=16'b0000000000000001;	 
			5'b00001:key=16'b0000000000000010;		
			5'b00010:key=16'b0000000000000100;	
			5'b00011:key=16'b0000000000001000;		
			5'b00100:key=16'b0000000000010000;	
			5'b00101:key=16'b0000000000100000;		
			5'b00110:key=16'b0000000001000000;		
			5'b00111:key=16'b0000000010000000;	
							 
			5'b01000:key=16'b0000000100000000;		
			5'b01001:key=16'b0000001000000000;		
			5'b01010:key=16'b0000010000000000;		
			5'b01011:key=16'b0000100000000000;		
			5'b01100:key=16'b0001000000000000;		
			5'b01101:key=16'b0010000000000000;		
			5'b01110:key=16'b0100000000000000;	
			5'b01111:key=16'b1000000000000000;	
			5'b10000:key=16'b0000000000000000;
			default:key=16'b0000000000000000;	 
		endcase         	 		 
	end	
end
always @ (posedge clk or negedge rst_n)  
begin
	if(!rst_n) begin						
		key_n1<=16'b0000000000000000;
		key_n2<=16'b0000000000000000;
	end
	else begin
		key_n1<=key;
		key_n2<=key_n1;
	end	
end
assign key_fin=key_n1 & (~ key_n2); 
always @ (posedge clk or negedge rst_n)  
begin
	if(!rst_n) begin								
		page <= 2'd0;	//页面为0 即难度选择界面
		mode<=1'b0;		//模式选择
		cnt<=0;
		state<=INIT_ST;
		m_to_dis<=4'd0;//随机数初始化
		num<=0;
	end
	else begin
		if(page==2'd0) begin//如果页面为0 可以进行模式选择和确认进入游戏
			if(key_fin[0]) begin
				mode<=~mode;
			end
			else if(key_fin[1]) begin
				page<=2'd1;
				state<=INIT_ST;
			end
		end
		else if(page==2'd1) begin//游戏模式、
			if(state==INIT_ST) begin
				if(cnt==TRANSITION_TIME) begin
					cnt<=0;
					state<=PIC1_ST;
					m_to_dis<=m;
				end
				else begin
					cnt<=cnt+1'b1;
				end
			end
			else if(state==PIC1_ST)begin
//				if(keyvalue!=5'b10000) begin//说明有按键按下
//					if(keyvalue[3:0]==m) begin
//						num<=num+1;
//						state<=PIC2_ST;
//						cnt<=0;
//					end
//					else begin//说明按错了
//						page <= 2'd2;	//游戏结束界面
//					end
//				end
				if(key_fin[0]) begin
					if(m_to_dis==4'd0) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[1]) begin
					if(m_to_dis==4'd1) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[2]) begin
					if(m_to_dis==4'd2) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[3]) begin
					if(m_to_dis==4'd3) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[4]) begin
					if(m_to_dis==4'd4) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[5]) begin
					if(m_to_dis==4'd5) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[6]) begin
					if(m_to_dis==4'd6) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[7]) begin
					if(m_to_dis==4'd7) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[8]) begin
					if(m_to_dis==4'd8) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[9]) begin
					if(m_to_dis==4'd9) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[10]) begin
					if(m_to_dis==4'd10) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[11]) begin
					if(m_to_dis==4'd11) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[12]) begin
					if(m_to_dis==4'd12) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[13]) begin
					if(m_to_dis==4'd13) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[14]) begin
					if(m_to_dis==4'd14) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(key_fin[15]) begin
					if(m_to_dis==4'd15) begin
						num<=num+1;
						state<=PIC2_ST;
						cnt<=0;
					end
					else begin//说明按错了
						page <= 2'd2;	//游戏结束界面
					end
				end
				else if(cnt==game_cnt) begin//说明时间到了
					page <= 2'd2;	//游戏结束界面
				end
				else begin
					cnt<=cnt+1'b1;
				end
			end
			else if(state==PIC2_ST)begin
				if(cnt==PIC2_TIME) begin
					state<=INIT_ST;
					cnt<=0;
				end
				else begin
					cnt<=cnt+1'b1;
				end
			end
		end
		else if(page==2'd2) begin//显示游戏结束模式
			if(key_fin[1]==1'b1) begin
				page <= 2'd0;	//页面为0 即难度选择界面
				mode<=1'b0;		//模式选择
				cnt<=0;
				state<=INIT_ST;
				m_to_dis<=4'd0;//随机数初始化
				num<=0;
			end
		end
	end		
end
///难度控制
always @ (*)  
begin
	if(mode==1'b0) game_cnt=MODE1_TIME;
	else game_cnt=MODE2_TIME;
end
endmodule