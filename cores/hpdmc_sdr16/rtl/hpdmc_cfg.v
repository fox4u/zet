module hpdmc_cfg #(
  parameter AW = 3,
  parameter DW = 16,
  parameter DELAYW = 3,
  localparam W_INIT_DATA = AW + DW + DELAYW,

  parameter NUM_INIT_DATA = 0,
  parameter [NUM_INIT_DATA * W_INIT_DATA-1:0] INIT_DATA = {1'b0}
)(
  input             clk,
  input             rst,

  output reg [AW-1:0] csr_a,
  output reg          csr_we,
  output reg [DW-1:0] csr_dw,

  output              init_done
);

  reg  [ 3:0] sdram_init_cnt;
  reg  [DELAYW-1:0] sdram_init_delay_stb;
  reg  [ 1:0] sdram_init_ready_r;

  wire init_ready = (sdram_init_ready_r == 2'd2);

  assign init_done = (sdram_init_cnt == NUM_INIT_DATA);

  always @(posedge clk) 
    sdram_init_ready_r <= rst ? 2'b0 : (sdram_init_ready_r == 2'd2) ? sdram_init_ready_r : sdram_init_ready_r + 1;

  always @(posedge clk) begin
    if(rst) begin
      csr_a   <= {AW{1'b0}};
      csr_we   <= 1'b0;
      csr_dw    <= {DW{1'b0}};  

      sdram_init_cnt        <= 4'd0;
      sdram_init_delay_stb  <= {DELAYW{1'b0}};
    end
    else if (init_ready & ~init_done & ~csr_we & (sdram_init_delay_stb == {DELAYW{1'b0}})) begin 
      csr_we     <= 1'b1;
      { csr_a, csr_dw, sdram_init_delay_stb } <= INIT_DATA[sdram_init_cnt * W_INIT_DATA +: W_INIT_DATA];
    end
    else if (csr_we) begin                
      sdram_init_cnt <= sdram_init_cnt + 1;
      csr_we <= 1'b0;
    end
    else if (sdram_init_delay_stb != {DELAYW{1'b0}}) begin //read stb
      sdram_init_delay_stb <= sdram_init_delay_stb - 1;
    end
  end

endmodule