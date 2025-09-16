/*
 *  VGA CSR interface for On-chip RAM
 *  Copyright (c) 2009  Zeus Gomez Marmolejo <zeus@opencores.org>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

module csr_ocram (
    input sys_clk,

    // CSR slave interface
    input      [17:1] csr_adr_i,
    input      [ 1:0] csr_sel_i,
    input             csr_we_i,
    input      [15:0] csr_dat_i,
    output reg [15:0] csr_dat_o
  );

  localparam dqbits = 16;
  localparam memdepth = 131071;
  localparam addbits = 17;

  // Registers and nets
  reg  [(dqbits/2 - 1) : 0] bank0 [0 : memdepth];
  reg  [(dqbits/2 - 1) : 0] bank1 [0 : memdepth];

  reg [dqbits - 1:0] ww;
  reg [addbits - 1:0] sram_addr;
  
  reg LB_;
  reg UB_;
  reg WE_;

  wire r_en;
  wire w_en;

  // Continuous assingments
  assign r_en = WE_;   //WE=1,OE=0 Read
  assign w_en = (~WE_) & ((~LB_) | (~UB_)); //WE=0,LB or UB="0",OE=x Write

  // Behaviour
  // ww
  always @(posedge sys_clk) ww <= csr_dat_i;

  // sram_addr
  always @(posedge sys_clk) sram_addr <= csr_adr_i;

  // sram_we_n_
  always @(posedge sys_clk) WE_ <= !csr_we_i;

  // sram_bw_n_
  always @(posedge sys_clk) LB_ <= ~csr_sel_i[0];

  always @(posedge sys_clk) UB_ <= ~csr_sel_i[1];

  always @(posedge sys_clk)
    begin
      csr_dat_o <= 16'bz;
      if (w_en)
        begin
          bank0[sram_addr] <= LB_ ? bank0[sram_addr] : ww [(dqbits/2 - 1) : 0];
          bank1[sram_addr] <= UB_ ? bank1[sram_addr] : ww [(dqbits - 1)   : (dqbits/2)];
        end
      else if (r_en)
        csr_dat_o <= {UB_ ? 8'bz : bank1[sram_addr], LB_ ? 8'bz : bank0[sram_addr]};
    end  

endmodule
