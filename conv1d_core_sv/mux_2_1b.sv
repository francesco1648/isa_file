module mux_2_1b (
  input  wire sel,
  // Segnale di selezione
  input  logic d0,
  // Ingresso 0
  input  logic d1,
  // Ingresso 1
  output logic y
  // Uscita del multiplexer
);



  always @(sel or d0 or d1) begin
    if (sel == 1'b0) begin
      y <= d0;
      // Selezione ingresso 0
    end else begin
      y <= d1;
      // Selezione ingresso 1
    end
  end


endmodule
