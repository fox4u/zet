/*
 *  Linear mode graphics for VGA
 *  Copyright (C) 2010  Zeus Gomez Marmolejo <zeus@aluzina.org>
 *
 *  VGA FML support
 *  Copyright (C) 2013 Charley Picker <charleypicker@yahoo.com>
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

module vga_linear_fml (
    input clk,
    input rst,
    
    input enable,

    // CSR slave interface for reading
    output [17:1] fml_adr_o,
    input  [15:0] fml_dat_i,
    output        fml_stb_o,

    input [4:0] max_scan_line,
    input [1:0] addressing,

    input [9:0] h_count,
    input [9:0] v_count,
    input       horiz_sync_i,
    input       video_on_h_i,
    output      video_on_h_o,

    output [7:0] color,
    output       horiz_sync_o
  );

  // Registers
  reg [14:0] row_addr;
  reg [ 6:0] col_addr;
  reg [14:0] word_offset;
  reg [ 1:0] plane_addr;
  reg [ 1:0] plane_addr0;
  reg [ 7:0] color_l;
  
  reg  [ 15:8] fml0_dat_h;
  reg  [ 15:8] fml1_dat_h;
  reg  [ 15:0] fml2_dat;
  reg  [ 15:0] fml3_dat;
  reg  [ 15:0] fml4_dat;
  reg  [ 15:0] fml5_dat;
  reg  [ 15:0] fml6_dat;
  reg  [ 15:0] fml7_dat;
  
  reg [4:0] video_on_h;
  reg [4:0] horiz_sync;
  reg [34:0] pipe;  

  reg  [ 9:0] r_v_count;
  wire [ 9:0] w_v_count;

  // Continous assignments  
  assign fml_adr_o = { 1'b0, ((addressing[1]) ? word_offset[13:0] : word_offset[14:1]), plane_addr };
  assign fml_stb_o = pipe[1];
  
  assign color = pipe[4] ? fml_dat_i[7:0] : color_l;    
  
  assign video_on_h_o = video_on_h[4];
  assign horiz_sync_o = horiz_sync[4];

  assign w_v_count = (max_scan_line == 5'b0) ? v_count : {1'b0, v_count[9:1]};

  // Behaviour
  // FML 8x16 pipeline count
  always @(posedge clk)
    if (rst)
      begin
        pipe <= 34'b0;    
      end
    else
      if (enable)
        begin
          pipe <= { pipe[33:0], ((addressing[1]) ? (h_count[3:0]==4'h0) : (h_count[4:0]==5'h0)) };
        end

  // Load FML 8x16 burst
  always @(posedge clk)
    if (enable)
      begin
        fml0_dat_h <= pipe[4]  ? fml_dat_i[15:8] : fml0_dat_h;
        fml1_dat_h <= pipe[5]  ? fml_dat_i[15:8] : fml1_dat_h;
        fml2_dat <= pipe[6]  ? fml_dat_i[15:0] : fml2_dat;
        fml3_dat <= pipe[7]  ? fml_dat_i[15:0] : fml3_dat;
        fml4_dat <= pipe[8]  ? fml_dat_i[15:0] : fml4_dat;
        fml5_dat <= pipe[9]  ? fml_dat_i[15:0] : fml5_dat;
        fml6_dat <= pipe[10] ? fml_dat_i[15:0] : fml6_dat;
        fml7_dat <= pipe[11] ? fml_dat_i[15:0] : fml7_dat;
      end

  // video_on_h
  always @(posedge clk)
    if (rst)
      begin
        video_on_h <= 5'b0;
      end
    else
      if (enable)
        begin
          video_on_h <= { video_on_h[3:0], video_on_h_i };
        end

  // horiz_sync
  always @(posedge clk)
    if (rst)
      begin
        horiz_sync <= 5'b0;
      end
    else
      if (enable)
        begin
          horiz_sync <= { horiz_sync[3:0], horiz_sync_i };
        end

  // Address generation
  always @(posedge clk)
    if (rst)
      begin
        row_addr    <= 15'h0;
        col_addr    <= 7'h0;
        plane_addr0 <= 2'b00;
        word_offset <= 15'h0;
        plane_addr  <= 2'b00;
        r_v_count   <= 9'b0;
      end
    else
      if (enable)
        begin
          // Loading new row_addr and col_addr when h_count[2:0]==3'h0
          // v_count * 80 (bytes)
          if (w_v_count == 9'b0) begin
            row_addr <= 15'h0;
            r_v_count <= w_v_count;
          end
          else if (w_v_count != r_v_count) begin
            row_addr <= row_addr + 80;
            r_v_count <= w_v_count;
          end
          col_addr    <= h_count[9:3];
          plane_addr0 <= h_count[2:1];

          word_offset <= row_addr + col_addr;
          plane_addr  <= plane_addr0;
        end
 
 // color_l
  always @(posedge clk)
    if (rst)
      begin
        color_l <= 8'h0;
      end
    else
      if (enable)
        begin
          if (pipe[4])
            color_l <= fml_dat_i[7:0];
          else
          if (pipe[5])
            color_l <= fml_dat_i[7:0];
          else
          if (pipe[7])
            color_l <= fml2_dat[7:0];
          else
          if (pipe[9])
            color_l <= fml3_dat[7:0];
          else
          if (pipe[11])
            color_l <= (addressing[1]) ? fml4_dat[7:0] : fml0_dat_h;
          else
          if (pipe[13])
            color_l <= (addressing[1]) ? fml5_dat[7:0] : fml1_dat_h;
          else
          if (pipe[15])
            color_l <= (addressing[1]) ? fml6_dat[7:0] : fml2_dat[15:8];
          else
          if (pipe[17])
            color_l <= (addressing[1]) ? fml7_dat[7:0] : fml3_dat[15:8];
          else
          if (~addressing[1]) begin
            if (pipe[19])
              color_l <= fml4_dat[7:0];
            else
            if (pipe[21])
              color_l <= fml5_dat[7:0];
            else
            if (pipe[23])
              color_l <= fml6_dat[7:0];
            else
            if (pipe[25])
              color_l <= fml7_dat[7:0];
            else
            if (pipe[27])
              color_l <= fml4_dat[15:8];
            else
            if (pipe[29])
              color_l <= fml5_dat[15:8];
            else
            if (pipe[31])
              color_l <= fml6_dat[15:8];
            else
            if (pipe[33])
              color_l <= fml7_dat[15:8];
          end    
        end

endmodule
