module REG1 #(
  parameter n_bit = 8  // Numero di bit del registro, valore di default 8
) (
  input  logic                 clk,    // Segnale di clock
  input  logic                 rst_n,  // Segnale di reset asincrono attivo basso
  input  logic                 load,   // Segnale di abilitazione del caricamento
  input  logic [n_bit - 1 : 0] d_in,   // Dato di input
  output reg   [n_bit - 1 : 0] q_out   // Dato di output
);

  // Registro interno
  reg [n_bit - 1 : 0] reg1;

  // Logica del registro
  always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
      reg1 <= {n_bit{1'b0}};  // Reset asincrono del registro
    end else if (load) begin
      reg1 <= d_in;  // Caricamento del valore di input
    end
  end

  // Output del registro
  assign q_out = reg1;

endmodule
