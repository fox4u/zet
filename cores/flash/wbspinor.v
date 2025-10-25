module wbspinor #(
  parameter [22:0] word_addr_offset = 0
)(
  // Wishbone slave interface
  input         wb_clk_i,
  input         wb_rst_i,
  input  [15:0] wb_dat_i,
  output [15:0] wb_dat_o,
  input         wb_we_i,
  input         wb_adr_i,
  input  [ 1:0] wb_sel_i,
  input         wb_stb_i,
  input         wb_cyc_i,
  output        wb_ack_o,

  output        ck,
  output        cs,
  input         so,
  output        si
);

  // Registers and nets
  wire        op;
  wire        wr_command;
  wire        word;
  wire        read;
  wire        read_word;
  wire        read_done;
  wire        byte_addr_bit;
  wire        read_ack;
  wire [ 7:0] read_data;
  wire        read_start;
  wire        reset_en_start = 1'b0;
  wire        reset_start = 1'b0;
  wire [22:0] word_addr_act;

  reg  [22:0] word_addr;
  reg         st;
  reg  [ 7:0] low_byte;

  // Combinatorial logic
  assign op               = wb_stb_i & wb_cyc_i;
  assign word             = wb_sel_i==2'b11;
  assign read             = op & !wb_we_i;
  assign read_word        = read & word;
  assign wr_command       = op & wb_we_i;  // Wishbone write access Signal
  assign wb_ack_o         = op & (read ? read_ack : 1'b1);
  assign wb_dat_o         = (~read | ~wb_ack_o) ?  16'bz                  : 
                            (wb_sel_i[1])       ? { read_data, low_byte } : 
                                                  { 8'h0, read_data }     ;

  assign byte_addr_bit    = (wb_sel_i==2'b10) | (word & st);       
  assign read_ack         = (read_word) ? (st & read_done) : read_done;
  assign read_start       = read & (~read_done); //wait for st update on read_done
  assign word_addr_act    = word_addr | word_addr_offset;

  spinor u_spinor_0 (
    .clk_100(wb_clk_i),
    .reset(wb_rst_i),

    .reset_en_start(reset_en_start),
    .reset_start(reset_start),
    .read_start(read_start),
    .done(read_done),
    .read_data(read_data),
    .read_addr({ word_addr_act, byte_addr_bit }),
    
    .ck(ck),
    .cs(cs),
    .so(so),
    .si(si)
  );

  always @(posedge wb_clk_i)
    //st <= wb_rst_i ? 1'b0 : ((read_word && read_done) ? ~st : st);
    if (wb_rst_i)
      st <= 1'b0;
    else if (read_word && read_done)
      st <= ~st;

  always @(posedge wb_clk_i)
    low_byte <= wb_rst_i ? 8'h0 : (read ? ((word && read_done)? read_data : low_byte) : 8'h0);

  // --------------------------------------------------------------------
  // Register addresses and defaults
  // --------------------------------------------------------------------
  `define FLASH_ALO   1'h0    // Lower 16 bits of address lines
  `define FLASH_AHI   1'h1    // Upper  6 bits of address lines
  always @(posedge wb_clk_i)  // Synchrounous
    if(wb_rst_i)
      word_addr <= 23'h000000;  // Interupt Enable default
    else
      if(wr_command)          // If a write was requested
        case(wb_adr_i)        // Determine which register was writen to
            `FLASH_ALO: word_addr[15:0] <= wb_dat_i;
            `FLASH_AHI: word_addr[22:16] <= wb_dat_i[6:0];
            default:    ;     // Default
        endcase               // End of case  
endmodule