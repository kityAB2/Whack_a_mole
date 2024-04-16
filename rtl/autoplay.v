module autoplay
(
	//输入端口
	clk,rst_n,
    //调号及升降八度
    signature,
    octachord,
    beep_out,
    speed,
    dis
);
//定义的相关参数
parameter  MUSIC_MEM_LONG = 194;
parameter  SYSTEM_OSC = 28'd50_000_000;
//parameter [15:0] FreTab[0:11]  = { 16'd262,16'd277,16'd294,16'd311,16'd330,16'd349,16'd369,16'd392,16'd415,16'd440,16'd466,16'd494 };//原始频率表
//parameter [3:0]  SignTab[0:6]  = { 4'd0,4'd2,4'd4,4'd5,4'd7,4'd9,4'd11 };//1~7在频率表中的位置
//parameter [7:0]  LengthTab[0:6]= { 8'd1,8'd2,8'd4,8'd8,8'd16,8'd32,8'd64 };//计算出是几分音符	

//parameter SOUND_SPACE 	4/5; 	
		
input 						clk;		//时钟的端口,开发板用的50M晶振
input 						rst_n;		//演奏时钟
input   [4:0]               signature;		//自动演奏开关
input 	[1:0] 				octachord; 		//复位的端口,低电平复位
input   [3:0]               speed;
output 	reg 				beep_out;		//输出频率

integer i,j;//变量
output reg [15:0] dis;
reg [7:0] Sound[0:MUSIC_MEM_LONG-1];//申请八个四位的存储单元
reg [3:0] state;//指示状态
reg [15:0] NewFreTab[0:11];		//新的频率表
reg [10:0] Point;  //定位当前的音乐
reg [15:0] Tone,Length;//指向当前音符和时值
reg [31:0] LDiv0,LDiv4,LDiv,LDiv1,LDiv2,LDiv0_Current,LDiv4_Current;
reg [7:0] SL,SM,SH,SLen,XG,FD,SLen1,dis_fre;
reg [15:0] CurrentFre;//当前频率
reg [31:0] cnt,cnt1,fre_cnt,fre_cnt_cur;
wire [15:0] FreTab[0:11];
wire [3:0]  SignTab[0:6];
wire [7:0]  LengthTab[0:6];
assign FreTab[0]=16'd262;assign FreTab[1]=16'd277;assign FreTab[2]=16'd294;
assign FreTab[3]=16'd311;assign FreTab[4]=16'd330;assign FreTab[5]=16'd349;
assign FreTab[6]=16'd369;assign FreTab[7]=16'd392;assign FreTab[8]=16'd415;
assign FreTab[9]=16'd440;assign FreTab[10]=16'd466;assign FreTab[11]=16'd494;
assign SignTab[0]=4'd0;assign SignTab[1]=4'd2;assign SignTab[2]=4'd4;assign SignTab[3]=4'd5;
assign SignTab[4]=4'd7;assign SignTab[5]=4'd9;assign SignTab[6]=4'd11;
assign LengthTab[0]=8'd1;assign LengthTab[1]=8'd2;assign LengthTab[2]=8'd4;assign LengthTab[3]=8'd8;
assign LengthTab[4]=8'd16;assign LengthTab[5]=8'd32;assign LengthTab[6]=8'd64;
initial//用于读取音频表
	begin
		$readmemh("file.txt",Sound); //读取file1.txt中的数字到memory
	end   
always @(*) begin   // 根据调号生成新的频率表 
    if(octachord == 1) begin
		for(i=0;i<12;i=i+1) begin
            if((i + signature) > 11) begin
                NewFreTab[i] = (FreTab[(i + signature)-12]*2)>>2;
            end
            else begin
                NewFreTab[i] = (FreTab[(i + signature)])>>2;
            end
         end  
    end 
	else if(octachord == 3) begin
		for(i=0;i<12;i=i+1) begin
            if((i + signature) > 11) begin
                NewFreTab[i] = (FreTab[(i + signature)-12]*2)<<2;
            end
            else begin
                NewFreTab[i] = (FreTab[(i + signature)])<<2;
            end	
         end 
    end 
    else begin
        for(i=0;i<12;i=i+1) begin
            if((i + signature) > 11) begin
                NewFreTab[i] = (FreTab[(i + signature)-12]*2);
            end
            else begin
                NewFreTab[i] = FreTab[(i + signature)];
            end		
        end 
    end
	
end
always @(*) begin   //根据速度生成一分音符及音符间隔cout 
	case(speed)
	  4'd0:begin
                LDiv0_Current=32'd400000000;//一分音符
                LDiv4_Current=32'd20000000;
              end
	  4'd1:begin
                LDiv0_Current=32'd300000000;
                LDiv4_Current=32'd15000000;
              end
	  4'd2:begin
                LDiv0_Current=32'd200000000;
                LDiv4_Current=32'd10000000;
              end
	  4'd3:begin
                LDiv0_Current=32'd133333333;	
                LDiv4_Current=32'd6666666;
              end
	  4'd4:begin
                LDiv0_Current=32'd100000000;
                LDiv4_Current=32'd5000000;
              end
	  default:begin
                LDiv0_Current=32'd200000000;
                LDiv4_Current=32'd10000000;
              end
	endcase  
end
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        state <= 4'd0;
        Point <= 11'b0;
        Tone <= 8'd0;
        Length <= 8'd0;
        LDiv0 <= 32'd0;
        LDiv4 <= 32'd0;
        LDiv <= 32'd0;
        LDiv1 <= 32'd0;
        LDiv2 <= 32'd0;
        SL<=8'd0;
        SM<=8'd0;
        SH<=8'd0;
        SLen <= 8'd0;
        XG <= 8'd0;
        FD <= 8'd0;
        cnt1 <= 32'd0;
        dis<=16'd0;
        CurrentFre<=16'd0;
        fre_cnt_cur<=32'd0;
        dis_fre<=16'd0;
        //fre_cnt<=32'd0;
    end
    else begin
        if(state==0) begin 
            Tone<= Sound[Point];	
            Length <= Sound[Point+1]; 			// 读出第一个音符和它时时值
            LDiv0 <= LDiv0_Current;	 
            LDiv4 <= LDiv4_Current; 					// 算出间隔
            state <= 4'd1;
         end
         else if(state==1) begin         
            SL<=(Tone%8'd10); 								//计算出音符 
            SM<=((Tone/8'd10)%8'd10); 								//计算出高低音 
            SH<=(Tone/8'd100); 								//计算出是否升半 
            SLen1<=LengthTab[Length%10]; 	//算出是几分音符 指数
            SLen<=Length%10;                //底数
            XG<=Length/10%10; 			//算出音符类型(0普通1连音2顿音) 
            FD<=Length/100;        //算出是否连音
            //SL<={4'b0000,Tone[3:0]};
            //SM<={4'b0000,Tone[7:4]};
            //SH<={4'b0000,Tone[11:8]};
            //SLen<={4'b0000,Length[3:0]};                //底数
            //XG<={4'b0000,Length[7:4]};
            //FD<={4'b0000,Length[11:8]};        //算出是否连音
            //SLen1<=LengthTab[Length[3:0]]; 	//算出是几分音符 指数
            state <= 4'd2;
         end
         else if(state==2) begin          
            CurrentFre <= NewFreTab[SignTab[SL-1]+SH]; 	//查出对应音符的频率 
            dis_fre<=SignTab[SL-1]+SH;
            LDiv<=(LDiv0>>SLen);//计算出是几分音符
            state <= 4'd3;
         end
         else if(state==3) begin 
            fre_cnt_cur<=fre_cnt;
           
            state <= 4'd4;         
         end
         else if(state==4) begin 
            if(SL!=0) begin
                if (SM==1) begin
                    //CurrentFre <= CurrentFre >> 2; 		//低音 
                    fre_cnt_cur<=fre_cnt_cur<<2;
                    dis<={8'd0,4'd3,dis_fre[3:0]};//更新频率及调性
                end
                else if (SM==3) begin 
                    //CurrentFre <=CurrentFre << 2; 		//高音
                    fre_cnt_cur<=fre_cnt_cur>>2;
                    dis<={8'd0,4'd1,dis_fre[3:0]};//更新频率及调性
                end
                else begin
                    //CurrentFre <= CurrentFre;
                    fre_cnt_cur<=fre_cnt_cur;
                    dis<={8'd0,4'd2,dis_fre[3:0]};//更新频率及调性
                end
            end
            else begin
                CurrentFre <= CurrentFre;
                fre_cnt_cur<=fre_cnt_cur;
            end
            if(FD==1) LDiv<=LDiv+LDiv>>1;  
            else LDiv<=LDiv;   
            state <= 4'd5;
         end
         else if(state==5) begin
            
            if(SL==0) LDiv1<=0;
            else if(XG!=1) begin	
                if(XG==0) begin				//算出普通音符的演奏长度 
                    if (SLen1<=4) LDiv1<=LDiv-LDiv4;
                    else LDiv1<=LDiv*4/5;
                end
                else LDiv1<=LDiv>>1; 		//算出顿音的演奏长度 
            end
            else LDiv1<=LDiv;
            state <= 4'd6;            
         end
         else if(state==6) begin
              LDiv2<=LDiv-LDiv1; 		//算出不发音的长度 
              if(SL!=0) begin 
                state<=4'd7;
                cnt1<=LDiv1;
              end
              else if(LDiv2!=0) begin 
                state<=4'd8;
                cnt1<=LDiv2;
              end
              else state<=4'd9;
         end
         else if(state==7) begin
          
              if(cnt1!=0) cnt1<=cnt1-1;
              else begin
                  if(LDiv2!=0) begin
                    state<=4'd8;
                    cnt1<=LDiv2;
                  end
                  else state<=4'd9;
              end
         end
         else if(state==8) begin
              if(cnt1!=0) cnt1<=cnt1-1;
              else state<=4'd9;
               
         end
         else if(state==9) begin
            if(Point==MUSIC_MEM_LONG-2) Point<=0;
            else Point<=Point+2;
            state <= 4'd0;
            Tone <= 8'd0;
            Length <= 8'd0;

            LDiv <= 0;
            SLen <= 0;
            XG <= 0;
            FD <= 0;
            cnt1 <= 0;
         end          
    end   
end

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
        beep_out<=1'b0;
        cnt<=32'd0;
    end
    else if(state == 4'd7) begin
        if(cnt < fre_cnt_cur) cnt <= cnt+1;
        else cnt <= 0;
        if(cnt <= (fre_cnt_cur/2-1)) beep_out<=1'b0;
        else beep_out<=1'b1;
    end
    else begin
        beep_out<=1'b0;
        cnt<=0;
    end
end	
always @(*) begin 
    case(CurrentFre)
       16'd262:fre_cnt=32'd190839;
       16'd277:fre_cnt=32'd180505;
       16'd294:fre_cnt=32'd170068;
       16'd311:fre_cnt=32'd160771;
       16'd330:fre_cnt=32'd151515;
       16'd349:fre_cnt=32'd143266;
       16'd369:fre_cnt=32'd135501;
       16'd392:fre_cnt=32'd127551;
       16'd415:fre_cnt=32'd120481;
       16'd440:fre_cnt=32'd113636;
       16'd466:fre_cnt=32'd107296;
       16'd494:fre_cnt=32'd101214;  
       
       16'd524:fre_cnt=32'd095419;
       16'd554:fre_cnt=32'd090252;
       16'd588:fre_cnt=32'd085034;
       16'd622:fre_cnt=32'd080385;
       16'd660:fre_cnt=32'd075757;
       16'd698:fre_cnt=32'd071633;
       16'd738:fre_cnt=32'd067567;
       16'd784:fre_cnt=32'd063775;
       16'd830:fre_cnt=32'd060240;
       16'd880:fre_cnt=32'd056818;
       16'd932:fre_cnt=32'd053648;
       16'd988:fre_cnt=32'd050607;


       16'd065:fre_cnt=32'd769230;
       16'd069:fre_cnt=32'd724637;
       16'd073:fre_cnt=32'd684931;
       16'd077:fre_cnt=32'd649350;
       16'd082:fre_cnt=32'd609756;
       16'd087:fre_cnt=32'd574712;
       16'd092:fre_cnt=32'd543478;
       16'd098:fre_cnt=32'd510204;
       16'd103:fre_cnt=32'd485436;
       16'd110:fre_cnt=32'd454545;
       16'd116:fre_cnt=32'd431034;
       16'd123:fre_cnt=32'd406504;
       16'd131:fre_cnt=32'd381679;
       16'd138:fre_cnt=32'd362318;
       16'd147:fre_cnt=32'd340136;
       16'd155:fre_cnt=32'd322580;
       16'd165:fre_cnt=32'd303030;
       16'd174:fre_cnt=32'd287356;
       16'd184:fre_cnt=32'd271739;
       16'd196:fre_cnt=32'd255102;
       16'd207:fre_cnt=32'd241545;
       16'd220:fre_cnt=32'd227272;
       16'd233:fre_cnt=32'd214592;
       16'd247:fre_cnt=32'd202429;


       16'd1048:fre_cnt=32'd47709;
       16'd1108:fre_cnt=32'd45126;
       16'd1176:fre_cnt=32'd42517;
       16'd1244:fre_cnt=32'd40192;
       16'd1320:fre_cnt=32'd37878;
       16'd1396:fre_cnt=32'd35816;
       16'd1476:fre_cnt=32'd33875;
       16'd1568:fre_cnt=32'd31887;
       16'd1660:fre_cnt=32'd30120;
       16'd1760:fre_cnt=32'd28409;
       16'd1864:fre_cnt=32'd26824;
       16'd1976:fre_cnt=32'd25303;
       16'd2096:fre_cnt=32'd23854;
       16'd2216:fre_cnt=32'd22563;
       16'd2352:fre_cnt=32'd21258;
       16'd2488:fre_cnt=32'd20096;
       16'd2640:fre_cnt=32'd18939;
       16'd2792:fre_cnt=32'd17908;
       16'd2952:fre_cnt=32'd16937;
       16'd3136:fre_cnt=32'd15943;
       16'd3320:fre_cnt=32'd15060;
       16'd3520:fre_cnt=32'd14204;
       16'd3728:fre_cnt=32'd13412;
       16'd3952:fre_cnt=32'd12651; 
        default:begin
            fre_cnt=32'd0; 
              end   
	endcase  
end	
endmodule
