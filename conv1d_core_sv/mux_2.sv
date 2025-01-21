module MUX_2 #(
  parameter n_bit = 8
) (
  // Numero di bit dei segnali in ingresso, valore di default 8
  input  logic               sel,
  // Segnale di selezione
  input  logic [n_bit - 1:0] d0,
  // Ingresso 0
  input  logic [n_bit - 1:0] d1,
  // Ingresso 1
  output logic [n_bit - 1:0] y
  // Uscita del multiplexer
);




  always @(sel or d0 or d1) begin
    if (sel == 1'b0) begin
      y = d0;
      // Selezione ingresso 0
    end else begin
      y = d1;
      // Selezione ingresso 1
    end
  end


endmodule
