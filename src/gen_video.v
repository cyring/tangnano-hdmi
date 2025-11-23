import configPackage::*;
/* *******************************************************************
 * Generate RGB color for pixel at position (pixX,pixY).
 * RGB data must be ready and stable in 1 clock cycle (!)
*/
module gen_video(
  input wire I_clk_pixel,
  input wire I_reset_n,
  input [VIDEO_X_BITWIDTH-1:0] pixX,
  input [VIDEO_Y_BITWIDTH-1:0] pixY,
  input [VIDEO_X_BITWIDTH-1:0] screenWidth,
  input [VIDEO_Y_BITWIDTH-1:0] screenHeight,
  output wire [23:0] rgb
);

wire border = (pixX == 'd0) || (pixX == screenWidth-1'b1) || (pixY == 'd0) || (pixY == screenHeight-1'b1)  ? 1'b1 : 1'b0;
reg [23:0] rgb_r = 24'd0;

// =======================================
// Rainbow background rotator
// =======================================
reg [2:0] color_idx;
reg [24:0] slowcnt;
localparam [24:0] SLOW_THRESHOLD = 25'b1111111111111111111111111;

always @(posedge I_clk_pixel or negedge I_reset_n) begin
  if (!I_reset_n) begin
    slowcnt   <= 25'd0;
    color_idx <= 3'd0;
  end else begin
    slowcnt <= slowcnt + 25'd1;
    if (slowcnt == SLOW_THRESHOLD) begin
      slowcnt <= 25'd0;
      if (color_idx == 3'd7)
        color_idx <= 3'd0;
      else
        color_idx <= color_idx + 3'd1;
    end
  end
end

wire [23:0] rainbow_color =
    (color_idx == 3'd0) ? 24'hff0000 : // Red
    (color_idx == 3'd1) ? 24'h00ff00 : // Green
    (color_idx == 3'd2) ? 24'hffff00 : // Yellow
    (color_idx == 3'd3) ? 24'h0000ff : // Blue
    (color_idx == 3'd4) ? 24'hff00ff : // Magenta
    (color_idx == 3'd5) ? 24'h00ffff : // Cyan
    (color_idx == 3'd6) ? 24'hffffff : // White
    (color_idx == 3'd7) ? 24'hff9900 : // Orange
                          24'h000000 ; // Black [Default]
// =======================================

// Video generation
always@(posedge I_clk_pixel, negedge I_reset_n) begin
  if (!I_reset_n)
    rgb_r <= 24'd0;
  else if (border) begin
    rgb_r <= 24'h0000ff;
  end else begin
    rgb_r <= rainbow_color;
  end
end

assign rgb = rgb_r;

endmodule
