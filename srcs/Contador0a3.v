// Arquivo: Contador0a3.v
//--------------------------------------------------------------------------------
// Um contador simples de 2 bits que conta de 0 a 3.
// Usado para selecionar o dígito do display a ser ativado.
//--------------------------------------------------------------------------------
module Contador0a3 (
    input  wire       clk,
    input  wire       reset_n,
    output reg  [1:0] contagem
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            contagem <= 2'b00;
        end else begin
            // O contador incrementa e volta a 0 naturalmente
            contagem <= contagem + 1;
        end
    end

endmodule