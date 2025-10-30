module rst_gen #(
    parameter               CNTW    = 15,
    parameter [CNTW-1:0]    CNTMAX  = 15'h2710
)(
    input 			clk_i,
    input           rstn_i,
    output			rst_o
);

/* try to generate a reset */
reg [CNTW-1:0]	rst_cpt;
reg             rst_r;

always @(posedge clk_i or negedge rstn_i) begin
    if (~rstn_i) begin
        rst_cpt <= CNTMAX;
        rst_r   <= 1'b1;
    end
    else if (rst_cpt != 0)
        rst_cpt <= rst_cpt - 1;
    else
        rst_r <= 1'b0;
end

assign rst_o = rst_r;

endmodule