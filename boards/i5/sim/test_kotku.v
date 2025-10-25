/*
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

`timescale 1ns/10ps

module test_kotku;

  // Registers and nets
  reg        clk_25;
  wire       led;



  wire [10:0] sdram_addr;
  wire [31:0] sdram_data;
  wire [ 1:0] sdram_ba;
  wire        sdram_ras_n;
  wire        sdram_cas_n;
  wire        sdram_clk;
  wire        sdram_we_n;
  wire        ck;
  wire        cs;
  wire        so;
  wire        si;
  wire        flash_wp_n;
  wire        flash_hold_n;
  reg         dir;
  reg         so2;
  reg         so3;

  assign flash_wp_n = dir ? so2 : 1'bz;
  assign flash_hold_n = dir ? so3 : 1'bz;  

  GSR GSR_INST(.GSR(1'b1));
  PUR PUR_INST(.PUR(1'b1));  

  // Module instantiations
  kotku kotku (
    .clk_25_ (clk_25),

    // flash signals
    .spinor_clk_  (ck),
    .spinor_cs_   (cs),
    .spinor_so_   (so),
    .spinor_si_   (si),

    // sdram signals
    .sdram_addr_  (sdram_addr),
    .sdram_data_  (sdram_data),
    .sdram_ba_    (sdram_ba),
    .sdram_ras_n_ (sdram_ras_n),
    .sdram_cas_n_ (sdram_cas_n),
    .sdram_clk_   (sdram_clk),
    .sdram_we_n_  (sdram_we_n),

    // sd card signals
    .sd_miso_ (1'b1)
  );


  mt48lc2m32b2 sdram (
    .Dq    (sdram_data),
    .Addr  (sdram_addr),
    .Ba    (sdram_ba),
    .Clk   (sdram_clk),
    .Cke   (1'b1),
    .Cs_n  (1'b0),
    .Ras_n (sdram_ras_n),
    .Cas_n (sdram_cas_n),
    .We_n  (sdram_we_n),
    .Dqm   (4'b0)
  );

  MX25V1635F #(
  //  .Init_File("bios.dat"),
    .tVSL(101)
  ) u_flash_0 (
    .SCLK(ck),
    .CS(cs),
    .SI(si),
    .SO(so),
    .WP(flash_wp_n),
    .SIO3(flash_hold_n)
  );  

  // Behaviour
  // Clock generation
  always #20 clk_25 <= !clk_25;

  initial
    begin
      $readmemh("../../../cores/flash/bios.dat",u_flash_0.ARRAY,'h1c0000);
      $readmemb("../../../cores/zet/rtl/micro_rom.dat",
        kotku.zet.core.micro_data.micro_rom.rom);
      $readmemh("../../../cores/vga/rtl/char_rom.dat",
        kotku.vga.lcd.sequencer.text_mode.char_rom.rom);
      $readmemh("../../../cores/flash/bootrom.dat",
        kotku.bootrom.rom);

      clk_25 <= 1'b0;
    end

endmodule
