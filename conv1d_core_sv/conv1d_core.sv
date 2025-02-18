module conv1d_core (
  /* verilator lint_off UNUSED */
  /* verilator lint_off LATCH */
  /* verilator lint_off BLKSEQ */
  input  logic        clk,
  input  logic        rst_n,
  output logic        ext_mem_gnt,
  //int_mem_req
  output logic        req_i,
  output logic        we_i,
  output logic [ 3:0] be,
  output logic [ 6:0] add_i,
  output logic [31:0] wdata,
  //  writing on memory
  //mem_rsp
  input  logic [31:0] data,
  //  reading from memory
  input  logic        START,
  output logic        DONE_TOT,
  output logic        DONE_OUT_SAMPLE,
  input  logic        ACCEPTED_OUT_SAMPLE,
  input  logic        REPLACED_IN_SAMPLE,
  output logic [ 0:0] REPLACE_FILTER,
  output logic 	 REPLACE_FILTER_REQ,
  input  logic        REPLACED_FILTER,
  output logic [ 4:0] REPLACE_INPUT
);


  //--------------------------------------------------------



  parameter [4:0]
  IDLE = 31,
  S0 = 0,
  S1 = 1,
  S2 = 2,
  S3 = 3,
  S4 = 4,
  S5 = 5,
  S6 = 6,
  S7 = 7,
  S8 = 8,
  S9 = 9,
  S10 = 10,
  S11 = 11,
  S12 = 12,
  S13 = 13,
  S14 = 14,
  S15 = 15,
  S16 = 16,
  S17 = 17,
  S18 = 18,
  S19 = 19,
  S20 = 20,
  S21 = 21,
  S22 = 22,
  S23 = 23,
  S24 = 24,
  S25 = 25,
  S26 = 26,
  S27 = 27,
  S28 = 28,
  S29 = 29;
  logic [ 4:0] P_STATE;
  logic [ 4:0] N_STATE;
  //----------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------
  //----------------------------------------------------------------------------------
  //----------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------
  //------------------------------------------------------------------------------------

logic  RESET_BLK_FILTER;
  logic [ 0:0] LR_BLK_FILTER;
  logic [ 0:0] BLK_FILTER;
  logic [ 7:0] M0_A;
  logic [ 7:0] M0_B;
  logic [ 7:0] M1_A;
  logic [ 7:0] M1_B;
  logic [ 7:0] M2_A;
  logic [ 7:0] M2_B;
  logic [ 7:0] M3_A;
  logic [ 7:0] M3_B;
  logic [31:0] M0_O;
  logic [31:0] M1_O;
  logic [31:0] M2_O;
  logic [31:0] M3_O;
  logic [15:0] M0_O_SHORT;
  logic [15:0] M1_O_SHORT;
  logic [15:0] M2_O_SHORT;
  logic [15:0] M3_O_SHORT;
  logic [31:0] ADD0_A;
  logic [31:0] ADD0_B;
  logic [31:0] ADD1_A;
  logic [31:0] ADD1_B;
  logic [31:0] ADD2_A;
  logic [31:0] ADD2_B;
  logic [31:0] ADD3_A;
  logic [31:0] ADD3_B;
  logic [31:0] ADD4_A;
  logic [31:0] ADD4_B;
  logic [31:0] ADD0_O;
  logic [31:0] ADD1_O;
  logic [31:0] ADD2_O;
  logic [31:0] ADD3_O;
  logic [31:0] ADD4_O;
  logic        LR_ADD_CH;
  logic        LR_ADD_FIL;
  logic        LR_FILTER;
  logic        LR_APP;
  logic        LR_R0;
  logic        LR_R1;
  logic        LR_R2;
  logic        LR_R3;
  logic        lr_ACC_0;
  logic        lr_ACC_1;
  logic        LR_ACC_2;
  logic        lr_ACC_3;
  logic        LR_ADD_M_O;
  logic        LR_OUT_MAT;
  logic [31:0] REG_ADD_CH;
  logic [31:0] REG_ADD_FIL;
  logic [31:0] REG_FILTER;
  logic [31:0] REG_APP_O;
  logic [31:0] REG_OUT_MAT;
  logic [31:0] REG_ACC_O;
  logic [31:0] REG_ACC_0;
  logic [31:0] REG_ACC_1;
  logic [31:0] REG_ACC_2;
  logic [31:0] REG_ACC_3;
  logic [31:0] REG_ADD_M_O;
  logic [31:0] REG_OUT_MEM;
  logic [31:0] REG_R0_O;
  logic [31:0] REG_R1_O;
  logic [31:0] REG_R2_O;
  logic [31:0] REG_R3_O;
  logic        SEL_ADD4_A;
  logic [ 1:0] SEL_ADD1_B;
  logic [ 1:0] SEL_ADD1_A;
  logic [ 1:0] SEL_ADD2_A;
  logic [ 1:0] SEL_ADD2_B;
  logic [ 1:0] SEL_ADD3_A;
  logic [ 1:0] SEL_ADD3_B;
  logic [ 1:0] SEL_ADD0_A;
  logic [ 1:0] SEL_ADD0_B;
  logic [ 1:0] SEL_ADD4_B;
  logic        SEL_M0_A;
  logic        SEL_M0_B;
  logic        SEL_M1_A;
  logic        SEL_M1_B;
  logic        SEL_M2_A;
  logic        SEL_M2_B;
  logic        SEL_M3_A;
  logic        SEL_M3_B;
  logic        RESET_CNT_I;
  logic        EN_CNT_I;
  logic        TC_I;
  logic [ 2:0] CNT_I;
  logic [ 7:0] CNT_I_8;
  //------------------------------------------------
  logic        RESET_CNT_J;
  logic        EN_CNT_J;
  logic        TC_J;
  logic [ 2:0] CNT_J;
  logic [31:0] CNT_J_32;
  //------------------------------------------------
  logic        RESET_CNT_M;
  logic        EN_CNT_M;
  logic        TC_M;
  logic [ 2:0] CNT_M;
  logic [31:0] CNT_M_32;
  logic [ 7:0] CNT_M_8;
  //------------------------------------------------
  logic        RESET_CNT_S;
  logic        EN_CNT_S;
  logic        TC_S;
  logic [ 2:0] CNT_S;
  logic [31:0] CNT_S_32;
  //------------------------------------------------
  logic        RESET_CNT_FG;
  logic        EN_CNT_FG;
  logic        TC_FG;
  logic [ 1:0] CNT_FG;
  logic [31:0] CNT_FG_SHIFT;
  //-------------------------------------------------
  logic        RESET_CNT_Z;
  logic        EN_CNT_Z;
  logic        TC_Z;
  logic [ 4:0] CNT_Z;
  //-------------------------------------------------
  logic [31:0] zeri;
  logic [31:0] VAL_120;
  logic [31:0] VAL_80;
  logic [ 7:0] VAL_5;
  logic [ 7:0] VAL_20;
  logic [ 7:0] VAL_9;

  //---------------------------------------------------------------------------------DP
  // Processo per ADD0
  always @(ADD0_A or ADD0_B) begin
    ADD0_O = ADD0_A + ADD0_B;
  end

  // Processo per ADD1
  always @(ADD1_A or ADD1_B) begin
    ADD1_O = ADD1_A + ADD1_B;
  end

  // Processo per ADD2
  always @(ADD2_A or ADD2_B) begin
    ADD2_O = ADD2_A + ADD2_B;
  end

  // Processo per ADD3
  always @(ADD3_A or ADD3_B) begin
    ADD3_O = ADD3_A + ADD3_B;
  end

  // Processo per ADD4
  always @(ADD4_A or ADD4_B) begin
    ADD4_O = ADD4_A + ADD4_B;
  end

  // Processo per M0
  always @(M0_A or M0_B) begin
    M0_O_SHORT = M0_A * M0_B;
  end

  // Processo per M1
  always @(M1_A or M1_B) begin
    M1_O_SHORT = M1_A * M1_B;
  end

  // Processo per M2
  always @(M2_A or M2_B) begin
    M2_O_SHORT = M2_A * M2_B;
  end

  // Processo per M3
  always @(M3_A or M3_B) begin
    M3_O_SHORT = M3_A * M3_B;
  end
  //-------------------

  assign be   = 4'b1111;

  //--------------------
  assign M0_O = {(16'b0000000000000000), M0_O_SHORT};
  assign M1_O = {(16'b0000000000000000), M1_O_SHORT};
  assign M2_O = {(16'b0000000000000000), M2_O_SHORT};
  assign M3_O = {(16'b0000000000000000), M3_O_SHORT};
  REG1 #(
    .n_bit(32)
  ) R_ADD_CH (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_ADD_CH),
    .d_in (ADD4_O),
    .q_out(REG_ADD_CH)
  );

  REG1 #(
    .n_bit(32)
  ) R_ADD_FIL (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_ADD_FIL),
    .d_in (ADD1_O),
    .q_out(REG_ADD_FIL)
  );

  REG1 #(
    .n_bit(32)
  ) R_FILTER (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_FILTER),
    .d_in (data),
    .q_out(REG_FILTER)
  );

  REG1 #(
    .n_bit(32)
  ) REGISTER_ACC_0 (
    .clk  (clk),
    .rst_n(rst_n),
    .load (lr_ACC_0),
    .d_in (ADD4_O),
    .q_out(REG_ACC_0)
  );

  REG1 #(
    .n_bit(32)
  ) REGISTER_ACC_1 (
    .clk  (clk),
    .rst_n(rst_n),
    .load (lr_ACC_1),
    .d_in (REG_ACC_0),
    .q_out(REG_ACC_1)
  );

  REG1 #(
    .n_bit(32)
  ) REGISTER_ACC_2 (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_ACC_2),
    .d_in (REG_ACC_1),
    .q_out(REG_ACC_2)
  );

  REG1 #(
    .n_bit(32)
  ) REGISTER_ACC_3 (
    .clk  (clk),
    .rst_n(rst_n),
    .load (lr_ACC_3),
    .d_in (REG_ACC_2),
    .q_out(REG_ACC_3)
  );

  REG1 #(
    .n_bit(32)
  ) R_APP (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_APP),
    .d_in (ADD4_O),
    .q_out(REG_APP_O)
  );

  REG1 #(
    .n_bit(32)
  ) R_ADD_M_O (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_ADD_M_O),
    .d_in (ADD1_O),
    .q_out(REG_ADD_M_O)
  );

  REG1 #(
    .n_bit(32)
  ) R_OUT_MAT (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_OUT_MAT),
    .d_in (data),
    .q_out(REG_OUT_MAT)
  );

  REG1 #(
    .n_bit(1)
  ) R_BLK_FILTER (
    .clk  (clk),
    .rst_n(RESET_BLK_FILTER),
    .load (LR_BLK_FILTER),
    .d_in (1'b1),
    .q_out(BLK_FILTER)
  );

  REG1 #(
    .n_bit(32)
  ) R_R0 (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_R0),
    .d_in (M0_O),
    .q_out(REG_R0_O)
  );

  REG1 #(
    .n_bit(32)
  ) R_R1 (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_R1),
    .d_in (M1_O),
    .q_out(REG_R1_O)
  );

  REG1 #(
    .n_bit(32)
  ) R_R2 (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_R2),
    .d_in (M2_O),
    .q_out(REG_R2_O)
  );

  REG1 #(
    .n_bit(32)
  ) R_R3 (
    .clk  (clk),
    .rst_n(rst_n),
    .load (LR_R3),
    .d_in (M3_O),
    .q_out(REG_R3_O)
  );

  MUX_4 #(
    .N(32)
  ) MUX0 (
    .sel(SEL_ADD0_A),
    .in0(M0_O),
    .in1(REG_APP_O),
    .in2(REG_ACC_1),
    .in3(zeri),
    .y  (ADD0_A)
  );

  MUX_4 #(
    .N(32)
  ) MUX1 (
    .sel(SEL_ADD0_B),
    .in0(M1_O),
    .in1(REG_OUT_MAT),
    .in2(REG_ACC_0),
    .in3(zeri),
    .y  (ADD0_B)
  );

  MUX_4 #(
    .N(32)
  ) MUX2 (
    .sel(SEL_ADD1_A),
    .in0(ADD0_O),
    .in1(M2_O),
    .in2(ADD2_O),
    .in3(zeri),
    .y  (ADD1_A)
  );

  MUX_4 #(
    .N(32)
  ) MUX3 (
    .sel(SEL_ADD1_B),
    .in0(CNT_J_32),
    .in1(M3_O),
    .in2(VAL_120),
    .in3(zeri),
    .y  (ADD1_B)
  );

  MUX_4 #(
    .N(32)
  ) MUX4 (
    .sel(SEL_ADD2_A),
    .in0(M2_O),
    .in1(REG_R2_O),
    .in2(CNT_M_32),
    .in3(zeri),
    .y  (ADD2_A)
  );

  MUX_4 #(
    .N(32)
  ) MUX5 (
    .sel(SEL_ADD2_B),
    .in0(VAL_80),
    .in1(REG_R3_O),
    .in2(CNT_FG_SHIFT),
    .in3(zeri),
    .y  (ADD2_B)
  );

  MUX_4 #(
    .N(32)
  ) MUX6 (
    .sel(SEL_ADD3_A),
    .in0(CNT_J_32),
    .in1(REG_ACC_2),
    .in2(REG_R0_O),
    .in3(zeri),
    .y  (ADD3_A)
  );

  MUX_4 #(
    .N(32)
  ) MUX7 (
    .sel(SEL_ADD3_B),
    .in0(CNT_S_32),
    .in1(REG_ACC_3),
    .in2(REG_R1_O),
    .in3(zeri),
    .y  (ADD3_B)
  );

  MUX_2 #(
    .n_bit(32)
  ) MUX8 (
    .sel(SEL_ADD4_A),
    .d0 (ADD0_O),
    .d1 (ADD2_O),
    .y  (ADD4_A)
  );

  MUX_4 #(
    .N(32)
  ) MUX9 (
    .sel(SEL_ADD4_B),
    .in0(ADD1_O),
    .in1(ADD3_O),
    .in2(zeri),
    .in3(zeri),
    .y  (ADD4_B)
  );

  MUX_2 #(
    .n_bit(8)
  ) MUX10 (
    .sel(SEL_M0_A),
    .d0 (CNT_I_8),
    .d1 (data[31:24]),
    .y  (M0_A)
  );

  MUX_2 #(
    .n_bit(8)
  ) MUX11 (
    .sel(SEL_M0_B),
    .d0 (VAL_5),
    .d1 (REG_FILTER[31:24]),
    .y  (M0_B)
  );

  MUX_2 #(
    .n_bit(8)
  ) MUX12 (
    .sel(SEL_M1_A),
    .d0 (CNT_M_8),
    .d1 (data[23:16]),
    .y  (M1_A)
  );

  MUX_2 #(
    .n_bit(8)
  ) MUX13 (
    .sel(SEL_M1_B),
    .d0 (VAL_20),
    .d1 (REG_FILTER[23:16]),
    .y  (M1_B)
  );

  MUX_2 #(
    .n_bit(8)
  ) MUX14 (
    .sel(SEL_M2_A),
    .d0 (CNT_I_8),
    .d1 (data[15:8]),
    .y  (M2_A)
  );

  MUX_2 #(
    .n_bit(8)
  ) MUX15 (
    .sel(SEL_M2_B),
    .d0 (VAL_9),
    .d1 (REG_FILTER[15:8]),
    .y  (M2_B)
  );

  assign M3_A = data[7:0];
  assign M3_B = REG_FILTER[7:0];
  COUNTER #(
    .N(3)
  ) COUNTER_I (
    .clk           (clk),
    .reset         (RESET_CNT_I),
    .enable        (EN_CNT_I),
    .terminal_count(TC_I),
    .count         (CNT_I)
  );

  COUNTER #(
    .N(3)
  ) COUNTER_J (
    .clk           (clk),
    .reset         (RESET_CNT_J),
    .enable        (EN_CNT_J),
    .terminal_count(TC_J),
    .count         (CNT_J)
  );

  COUNTER #(
    .N(3)
  ) COUNTER_M (
    .clk           (clk),
    .reset         (RESET_CNT_M),
    .enable        (EN_CNT_M),
    .terminal_count(TC_M),
    .count         (CNT_M)
  );

  COUNTER #(
    .N(3)
  ) COUNTER_S (
    .clk           (clk),
    .reset         (RESET_CNT_S),
    .enable        (EN_CNT_S),
    .terminal_count(TC_S),
    .count         (CNT_S)
  );

  COUNTER #(
    .N(5)
  ) COUNTER_Z (
    .clk           (clk),
    .reset         (RESET_CNT_Z),
    .enable        (EN_CNT_Z),
    .terminal_count(TC_Z),
    .count         (CNT_Z)
  );

  COUNTER #(
    .N(2)
  ) COUNTER_FG (
    .clk           (clk),
    .reset         (RESET_CNT_FG),
    .enable        (EN_CNT_FG),
    .terminal_count(TC_FG),
    .count         (CNT_FG)
  );

  assign wdata          = ADD0_O;
  //wdata=REG_APP_O;
  assign REPLACE_INPUT  = CNT_Z;
  assign CNT_FG_SHIFT   = {(28'b0000000000000000000000000000), CNT_FG, 2'b00};
  assign CNT_I_8        = {(5'b00000), CNT_I};
  assign CNT_J_32       = {(29'b00000000000000000000000000000), CNT_J};
  assign CNT_M_32       = {(29'b00000000000000000000000000000), CNT_M};
  assign CNT_M_8        = {(5'b00000), CNT_M};
  assign CNT_S_32       = {(29'b00000000000000000000000000000), CNT_S};
 
  assign REPLACE_FILTER = BLK_FILTER;



  assign zeri           = 32'b00000000000000000000000000000000;
  assign VAL_120        = 32'b00000000000000000000000001111000;
  assign VAL_80         = 32'b00000000000000000000000001010000;
  assign VAL_5          = 8'b00000101;
  assign VAL_20         = 8'b00010100;
  assign VAL_9          = 8'b00001001;
  //---------------------------------------------------------------------------------
  //---------------------------------------------------------------------------------CU
  always @(posedge clk or posedge rst_n) begin
    if (rst_n == 1'b1) begin
      P_STATE <= S0;
    end else begin
      P_STATE <= N_STATE;
    end
  end

  always @(P_STATE or START or CNT_Z or CNT_S or CNT_FG or CNT_I or CNT_J or ACCEPTED_OUT_SAMPLE or REPLACED_IN_SAMPLE or REPLACED_FILTER) begin
    case (P_STATE)
      IDLE: begin
        if ((START == 1'b1)) begin
          N_STATE = S0;
        end else begin
          N_STATE = IDLE;
        end
      end
      S0: begin
        if ((CNT_Z == 5'b01000)) begin
          N_STATE = S19;
        end else begin
          N_STATE = S1;
        end
      end
      S1: begin
        if ((CNT_S == 3'b101)) begin
          N_STATE = S21;
        end else begin
          N_STATE = S2;
        end
      end
      S2: begin
        if ((CNT_FG == 2'b10)) begin
          N_STATE = S17;
        end else begin
          N_STATE = S3;
        end
      end
      S3: begin
        if ((CNT_M == 3'b100)) begin
          N_STATE = S20;
        end else begin
          N_STATE = S4;
        end
      end
      S4: begin
        if ((CNT_J == 3'b101)) begin
          N_STATE = S12;
        end else begin
          N_STATE = S5;
        end
      end
      S5: begin
        if ((CNT_I == 3'b100)) begin
          N_STATE = S10;
        end else begin
          N_STATE = S6;
        end
      end
      S6: begin
        N_STATE = S25;
      end
      S25: begin
        N_STATE = S7;
      end
      S7: begin
        N_STATE = S22;
      end
      S22: begin
        N_STATE = S8;
      end
      S8: begin
        N_STATE = S9;
      end
      S9: begin
        N_STATE = S5;
      end
      S10: begin
        N_STATE = S26;
      end
      S26: begin
        N_STATE = S11;
      end
      S11: begin
        N_STATE = S23;
      end
      S23: begin
        N_STATE = S27;
      end
      S27: begin
        N_STATE = S4;
      end
      S12: begin
        N_STATE = S28;
      end
      S28: begin
        N_STATE = S3;
      end
      S13: begin
        N_STATE = S15;
      end
      S14: begin
        N_STATE = S15;
      end
      S15: begin
        N_STATE = S16;
      end
      S24: begin
        N_STATE = S1;
      end
      S16: begin
        if ((REPLACED_FILTER == 1'b1)) begin
          N_STATE = S2;
        end else begin
          N_STATE = S16;
        end
      end
      S17: begin
        if ((ACCEPTED_OUT_SAMPLE == 1'b1)) begin
          N_STATE = S24;
        end else begin
          N_STATE = S17;
        end
      end
      S18: begin
        if ((REPLACED_IN_SAMPLE == 1'b1)) begin
          N_STATE = S0;
        end else begin
          N_STATE = S18;
        end
      end
      S19: begin
        N_STATE = IDLE;
      end
      S20: begin
        if ((BLK_FILTER == 1'b0)) begin
          N_STATE = S13;
        end else begin
          N_STATE = S14;
        end
      end
      S21: begin
        N_STATE = S29;
      end
      S29: begin
        N_STATE = S18;
      end
      default: begin
        N_STATE = IDLE;
      end
    endcase
  end

  always @(P_STATE) begin
    we_i          = 1'b0;
    SEL_M0_A      = 1'b0;
    SEL_M0_B      = 1'b0;
    SEL_M1_A      = 1'b0;
    SEL_M1_B      = 1'b0;
    SEL_M2_A      = 1'b0;
    SEL_M2_B      = 1'b0;
    SEL_ADD0_A    = 2'b00;
    SEL_ADD0_B    = 2'b00;
    SEL_ADD1_A    = 2'b00;
    SEL_ADD1_B    = 2'b00;
    SEL_ADD2_A    = 2'b00;
    SEL_ADD2_B    = 2'b00;
    SEL_ADD3_A    = 2'b00;
    SEL_ADD3_B    = 2'b00;
    SEL_ADD4_A    = 1'b0;
    SEL_ADD4_B    = 2'b00;
    ext_mem_gnt   = 1'b0;
    EN_CNT_I      = 1'b0;
    EN_CNT_J      = 1'b0;
    EN_CNT_S      = 1'b0;
    EN_CNT_M      = 1'b0;
    EN_CNT_FG     = 1'b0;
    EN_CNT_Z      = 1'b0;
     RESET_CNT_I   = 1'b0;
     RESET_CNT_J   = 1'b0;
     RESET_CNT_S   = 1'b0;
     RESET_CNT_M   = 1'b0;
     RESET_CNT_FG  = 1'b0;
    RESET_CNT_Z   = 1'b0;
    LR_R0         = 1'b0;
    LR_R1         = 1'b0;
    LR_R2         = 1'b0;
    LR_R3         = 1'b0;
    lr_ACC_0      = 1'b0;
    lr_ACC_1      = 1'b0;
    LR_ACC_2      = 1'b0;
    lr_ACC_3      = 1'b0;
    LR_ADD_CH     = 1'b0;
    LR_ADD_FIL    = 1'b0;
    LR_FILTER     = 1'b0;
    LR_APP        = 1'b0;
    LR_ADD_M_O    = 1'b0;
    LR_OUT_MAT    = 1'b0;
    LR_OUT_MAT    = 1'b0;
    LR_BLK_FILTER = 1'b0;
 RESET_BLK_FILTER = 1'b0;
REPLACE_FILTER_REQ =1'b0;
    case (P_STATE)
      IDLE: begin
 RESET_BLK_FILTER = 1'b1;
    we_i          = 1'b0;
    SEL_M0_A      = 1'b0;
    SEL_M0_B      = 1'b0;
    SEL_M1_A      = 1'b0;
    SEL_M1_B      = 1'b0;
    SEL_M2_A      = 1'b0;
    SEL_M2_B      = 1'b0;
    SEL_ADD0_A    = 2'b00;
    SEL_ADD0_B    = 2'b00;
    SEL_ADD1_A    = 2'b00;
    SEL_ADD1_B    = 2'b00;
    SEL_ADD2_A    = 2'b00;
    SEL_ADD2_B    = 2'b00;
    SEL_ADD3_A    = 2'b00;
    SEL_ADD3_B    = 2'b00;
    SEL_ADD4_A    = 1'b0;
    SEL_ADD4_B    = 2'b00;
    ext_mem_gnt   = 1'b0;
    EN_CNT_I      = 1'b0;
    EN_CNT_J      = 1'b0;
    EN_CNT_S      = 1'b0;
    EN_CNT_M      = 1'b0;
    EN_CNT_FG     = 1'b0;
    EN_CNT_Z      = 1'b0;
    RESET_CNT_I   = 1'b1;
    RESET_CNT_J   = 1'b1;
    RESET_CNT_S   = 1'b1;
    RESET_CNT_M   = 1'b1;
    RESET_CNT_FG  = 1'b1;
    RESET_CNT_Z   = 1'b1;
    LR_R0         = 1'b0;
    LR_R1         = 1'b0;
    LR_R2         = 1'b0;
    LR_R3         = 1'b0;
    lr_ACC_0      = 1'b0;
    lr_ACC_1      = 1'b0;
    LR_ACC_2      = 1'b0;
    lr_ACC_3      = 1'b0;
    LR_ADD_CH     = 1'b0;
    LR_ADD_FIL    = 1'b0;
    LR_FILTER     = 1'b0;
    LR_APP        = 1'b0;
    LR_ADD_M_O    = 1'b0;
    LR_OUT_MAT    = 1'b0;
    LR_OUT_MAT    = 1'b0;
    LR_BLK_FILTER = 1'b0;
	REPLACE_FILTER_REQ =1'b0;
      end
      S6: begin
        SEL_M0_A   = 1'b0;
        SEL_M0_B   = 1'b0;
        SEL_M1_A   = 1'b0;
        SEL_M1_B   = 1'b0;
        SEL_ADD0_A = 2'b00;
        SEL_ADD0_B = 2'b00;
        SEL_ADD1_A = 2'b00;
        SEL_ADD1_B = 2'b00;
        LR_ADD_CH  = 1'b1;
        LR_ADD_FIL = 1'b1;
        SEL_M2_A   = 1'b0;
        SEL_M2_B   = 1'b0;
        SEL_ADD2_A = 2'b00;
        SEL_ADD2_B = 2'b00;
        SEL_ADD3_A = 2'b00;
        SEL_ADD3_B = 2'b00;
        SEL_ADD4_A = 1'b1;
        SEL_ADD4_B = 2'b01;
      end
      S7: begin
        we_i        = 1'b0;
        req_i       = 1'b1;
        add_i       = REG_ADD_FIL[6:0];
        ext_mem_gnt = 1'b1;
      end
      S22: begin
        we_i        = 1'b0;
        req_i       = 1'b1;
        add_i       = REG_ADD_CH[6:0];
        ext_mem_gnt = 1'b1;
        LR_FILTER   = 1'b1;
      end
      S8: begin
        SEL_M0_A = 1'b1;
        SEL_M0_B = 1'b1;
        SEL_M1_A = 1'b1;
        SEL_M1_B = 1'b1;
        SEL_M2_A = 1'b1;
        SEL_M2_B = 1'b1;
        LR_R0    = 1'b1;
        LR_R1    = 1'b1;
        LR_R2    = 1'b1;
        LR_R3    = 1'b1;
      end
      S9: begin
        EN_CNT_I   = 1'b1;
        SEL_ADD2_A = 2'b01;
        SEL_ADD2_B = 2'b01;
        SEL_ADD3_A = 2'b10;
        SEL_ADD3_B = 2'b10;
        SEL_ADD4_A = 1'b1;
        SEL_ADD4_B = 2'b01;
        lr_ACC_0   = 1'b1;
        lr_ACC_1   = 1'b1;
        LR_ACC_2   = 1'b1;
        lr_ACC_3   = 1'b1;
      end
      S10: begin
        SEL_ADD2_A = 2'b10;
        SEL_ADD2_B = 2'b10;
        SEL_ADD4_A = 1'b0;
        SEL_ADD4_B = 2'b01;
        LR_ADD_M_O = 1'b1;
        SEL_ADD0_A = 2'b10;
        SEL_ADD0_B = 2'b10;
        SEL_ADD3_A = 2'b01;
        SEL_ADD3_B = 2'b01;
        SEL_ADD1_A = 2'b10;
        SEL_ADD1_B = 2'b10;
        LR_APP     = 1'b1;
      end
      S26: begin
        we_i        = 1'b0;
        req_i       = 1'b1;
        RESET_CNT_I = 1'b1;
        EN_CNT_J    = 1'b1;
      end
      S11: begin
        add_i       = REG_ADD_M_O[6:0];
        ext_mem_gnt = 1'b1;
      end

	S16: begin
	REPLACE_FILTER_REQ =1'b0;
      	end
      S23: begin
        LR_OUT_MAT  = 1'b1;
        add_i       = REG_ADD_M_O[6:0];
        ext_mem_gnt = 1'b1;
      end
      S27: begin
        SEL_ADD0_A = 2'b01;
        SEL_ADD0_B = 2'b01;
        we_i       = 1'b1;
        req_i      = 1'b1;
      end
      S12: begin
        EN_CNT_M    = 1'b1;
        RESET_CNT_I = 1'b1;
        RESET_CNT_J = 1'b1;
      end
      S13: begin
        LR_BLK_FILTER = 1'b1;
      end
      S14: begin
        RESET_BLK_FILTER = 1'b1;
      end
      S15: begin
        RESET_CNT_M = 1'b1;
        EN_CNT_FG   = 1'b1;
      end
      S17: begin
        RESET_CNT_FG    = 1'b1;
        DONE_OUT_SAMPLE = 1'b1;
      end
      S24: begin
        EN_CNT_S        = 1'b1;
        DONE_OUT_SAMPLE = 1'b0;
      end
      S21: begin
        EN_CNT_Z = 1'b1;
      end
      S18: begin
        RESET_CNT_S = 1'b1;
      end
      S19: begin
        DONE_TOT = 1'b1;
      end
      default: begin
      end
    endcase
  end

  //--------------------------------------------------------------------------------

endmodule