`timescale 1ns/1ps

module tb_csr_ocram;
  // 时钟参数
  parameter CLK_PERIOD = 10;  // 100MHz
  
  // DUT 接口信号
  reg sys_clk;
  
  // CSR slave interface
  reg  [17:1] csr_adr_i;
  reg  [ 1:0] csr_sel_i;
  reg         csr_we_i;
  reg  [15:0] csr_dat_i;
  wire [15:0] csr_dat_o;
  
  // 测试控制
  integer error_count;
  integer test_count;
  
  // 实例化被测模块
  csr_ocram dut (
    .sys_clk   (sys_clk),
    .csr_adr_i (csr_adr_i),
    .csr_sel_i (csr_sel_i),
    .csr_we_i  (csr_we_i),
    .csr_dat_i (csr_dat_i),
    .csr_dat_o (csr_dat_o)
  );
  
  // 时钟生成
  initial begin
    sys_clk = 0;
    forever #(CLK_PERIOD/2) sys_clk = ~sys_clk;
  end
  
  // 测试任务：写入数据
  task write_csr;
    input [17:1] address;
    input [ 1:0] sel;
    input [15:0] data;
    begin
      @(posedge sys_clk);
      csr_adr_i = address;
      csr_sel_i = sel;
      csr_we_i  = 1'b1;  // 写使能
      csr_dat_i = data;
      @(posedge sys_clk);
      csr_we_i  = 1'b0;  // 释放写使能
      $display("[WRITE] Time=%0t, Addr=0x%h, Sel=%b, Data=0x%h", 
               $time, address, sel, data);
    end
  endtask
  
  // 测试任务：读取数据并验证
  task read_csr;
    input [17:1] address;
    input [ 1:0] sel;
    input [15:0] expected_data;
    reg   [15:0] read_data;
    begin
      @(posedge sys_clk);
      csr_adr_i = address;
      csr_sel_i = sel;
      csr_we_i  = 1'b0;  // 读使能
      csr_dat_i = 16'h0; // 读时数据输入无关
      @(posedge sys_clk);
      @(posedge sys_clk);
      #1; // 等待输出稳定
      read_data = csr_dat_o;
      
      if (!sel[0]) begin
        expected_data[7:0] = 8'bz;
      end
      if (!sel[1]) begin
        expected_data[15:8] = 8'bz;
      end
      if (read_data === expected_data) begin
        $display("[READ]  Time=%0t, Addr=0x%h, Sel=%b, Data=0x%h (PASS)", 
                 $time, address, sel, read_data);
      end else begin
        $display("[READ]  Time=%0t, Addr=0x%h, Sel=%b, Data=0x%h (FAIL) Expected=0x%h", 
                 $time, address, sel, read_data, expected_data);
        error_count = error_count + 1;
      end
      test_count = test_count + 1;
    end
  endtask
  
  // 主测试程序
  initial begin
    // 初始化
    error_count = 0;
    test_count = 0;
    csr_adr_i = 0;
    csr_sel_i = 2'b00;
    csr_we_i  = 0;
    csr_dat_i = 0;
    
    // 等待复位完成（如果有的话）
    #(CLK_PERIOD * 2);
    
    $display("Starting CSR OCRAM test...");
    
    // 测试1：基本读写测试
    $display("\\n=== Test 1: Basic Read/Write ===");
    write_csr(17'h0000, 2'b11, 16'h1234);
    read_csr(17'h0000, 2'b11, 16'h1234);
    
    write_csr(17'h1234, 2'b01, 16'h5678);
    read_csr(17'h1234, 2'b01, 16'h5678);
    
    write_csr(17'h5678, 2'b10, 16'h9ABC);
    read_csr(17'h5678, 2'b10, 16'h9ABC);
    
    // 测试2：字节选择测试
    $display("\\n=== Test 2: Byte Select Tests ===");
    write_csr(17'h1000, 2'b11, 16'hA5A5);
    read_csr(17'h1000, 2'b11, 16'hA5A5);
    
    write_csr(17'h1000, 2'b01, 16'h00B1);  // 只写低字节
    read_csr(17'h1000, 2'b11, 16'hA5B1);
    
    write_csr(17'h1000, 2'b10, 16'hC200);  // 只写高字节
    read_csr(17'h1000, 2'b11, 16'hC2B1);
    
    // 测试3：地址边界测试
    $display("\\n=== Test 3: Address Boundary Tests ===");
    write_csr(17'h1FFFF, 2'b11, 16'hFFFF);
    read_csr(17'h1FFFF, 2'b11, 16'hFFFF);
    
    write_csr(17'h00001, 2'b11, 16'h1111);
    read_csr(17'h00001, 2'b11, 16'h1111);
    
    // 测试4：随机读写测试
    $display("\\n=== Test 4: Random Read/Write Tests ===");
    begin: random_test
      integer i;
      reg [17:1] addr;
      reg [15:0] data;
      reg [1:0]  sel;
      
      for (i = 0; i < 10; i = i + 1) begin
        addr = $random;
        data = $random;
        sel  = $random & 2'b11;
        
        write_csr(addr, sel, data);
        read_csr(addr, sel, data);
      end
    end
    
    // 测试完成
    #(CLK_PERIOD * 2);
    $display("\\n=== Test Summary ===");
    $display("Total tests: %0d", test_count);
    $display("Errors: %0d", error_count);
    
    if (error_count == 0) begin
      $display("All tests PASSED!");
    end else begin
      $display("Some tests FAILED!");
    end
    
    $finish;
  end
  
  // 仿真时间控制
  initial begin
    #100000; // 100us 超时保护
    $display("Simulation timeout!");
    $finish;
  end
  
  // 波形导出（可选）
  initial begin
    $dumpfile("tb_csr_ocram.vcd");
    $dumpvars(0, tb_csr_ocram);
  end
endmodule