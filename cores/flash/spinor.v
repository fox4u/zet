
module spinor(
  input             clk_100,
  input             reset,

  input             reset_en_start,
  input             reset_start,
  input             read_start,
  output reg        done,
  output reg [ 7:0] read_data,
  input  [23:0]     read_addr,

  output reg        ck,
  output reg        cs,
  input             so,
  output reg        si            
) /* synthesis syn_noprune=1 */;

  reg  [2:0]        en;
  reg               last_bit;
  reg  [ 6:0]       ck_gen_cnt;
  reg  [31:0]       r_cmd_addr;
  reg  [ 7:0]       r_data;

  wire [ 5:0]       real_ck_cnt;
  wire [31:0]       cmd_addr_read = { 8'h03, read_addr }; //cmd 03, addr 3 bytes
  wire [31:0]       cmd_addr_reset_en = { 8'h66, 24'h0};
  wire [31:0]       cmd_addr_reset    = { 8'h99, 24'h0};

  wire [ 6:0]       max_ck_gen_cnt_read = 7'd80;
  wire [ 6:0]       max_ck_gen_cnt_reset = 7'd16;
  wire [ 6:0]       max_ck_gen_cnt;
  
  wire [ 6:0]       max_real_ck_cnt_si_read = 6'd32; //ck negedge output, cnt 1-63
  wire [ 6:0]       max_real_ck_cnt_si_reset = 6'd8;
  wire [ 6:0]       max_real_ck_cnt_si;

  wire [ 6:0]       min_real_ck_cnt_so_read = 6'd33;
  wire [ 6:0]       max_real_ck_cnt_so_read = 6'd41; //ck posedge input, cnt 66-80
  wire [ 6:0]       min_real_ck_cnt_so;
  wire [ 6:0]       max_real_ck_cnt_so;

  assign real_ck_cnt = ck_gen_cnt[6:1];
  assign max_ck_gen_cnt = (en == 3'b001) ? max_ck_gen_cnt_read  :
                          (en == 3'b010) ? max_ck_gen_cnt_reset :
                          (en == 3'b100) ? max_ck_gen_cnt_reset : 0;

  assign max_real_ck_cnt_si = (en == 3'b001) ? max_real_ck_cnt_si_read :
                              (en == 3'b010) ? max_real_ck_cnt_si_reset :
                              (en == 3'b100) ? max_real_ck_cnt_si_reset : 0;

  assign min_real_ck_cnt_so = (en == 3'b001) ? min_real_ck_cnt_so_read : 0;
  assign max_real_ck_cnt_so = (en == 3'b001) ? max_real_ck_cnt_so_read : 0;

  always@(posedge clk_100)
    if(reset) begin
      en <= 3'b0;
      last_bit <= 1'b0;
    end
    else if((~|en) && (~last_bit)) begin
      en <= (read_start)      ? 3'b001 :
            (reset_en_start)  ? 3'b010 :
            (reset_start)     ? 3'b100 : en;
      last_bit <= 1'b0;
    end
    else if((|en) && (ck_gen_cnt == max_ck_gen_cnt)) begin
      en <= 3'b0;
      last_bit <= 1'b1;
    end
    else begin
      en <= en;
      last_bit <= 1'b0;
    end

  always@(posedge clk_100)
    if(reset)
      ck_gen_cnt  <= 7'd0;
    else if(|en) begin
      if(ck_gen_cnt == max_ck_gen_cnt)
        ck_gen_cnt <= 7'd0;
      else
        ck_gen_cnt <= ck_gen_cnt + 1'd1;
    end else
      ck_gen_cnt <= ck_gen_cnt;

  always@(posedge clk_100)
    if(reset)begin
      ck <= 1'b1;
      si <= 1'b1;
      r_cmd_addr <= 32'b0; 
      r_data <= 8'b0;   
    end else begin
      if(|en) begin
        ck <= ~ck_gen_cnt[0]; //even->1, odd->0

        if (ck_gen_cnt[0] && (real_ck_cnt < max_real_ck_cnt_si)) begin 
          si <= r_cmd_addr[31];
          r_cmd_addr <= {r_cmd_addr[30:0], 1'b0}; //shift data aout
        end

        if ((~ck_gen_cnt[0]) && (real_ck_cnt >= min_real_ck_cnt_so) && (real_ck_cnt < max_real_ck_cnt_so)) begin 
          r_data <= {r_data[6:0], so}; //shift data in
        end
      end
      else 
        r_cmd_addr <= (read_start)      ? cmd_addr_read     : 
                      (reset_en_start)  ? cmd_addr_reset_en :
                      (reset_start)     ? cmd_addr_reset    : r_cmd_addr ;
    end

  always@(posedge clk_100)
    if(reset)
      cs <= 1'b1;
    else if(|en) begin
      if (ck_gen_cnt == 7'b0)
        cs <= 1'b0;
      else 
        cs <= cs;
    end
    else
      cs <= 1'b1;
  
  always@(posedge clk_100)
    if(reset)begin
      read_data <= 12'd0; 
      done <= 1'b0;
    end else if(last_bit)begin
      read_data <= r_data; 
      done <= 1'b1;
    end else begin
      read_data <= read_data; 
      done <= 1'b0;
    end
  endmodule