// Arquivo: DivisorClock.v
//--------------------------------------------------------------------------------
// Gera um clock mais lento a partir de um clock de entrada mais rápido.
// Usado para a varredura do display de 7 segmentos (~240 Hz).
//--------------------------------------------------------------------------------
module DivisorClock (
    input  wire clk_entrada,
    input  wire reset_n,
    output reg  clk_saida
);
    // Fator de divisão para ~240 Hz a partir de 25 MHz
    // Fator = 25_000_000 / (2 * 240) = 52083
    parameter FATOR_DIVISAO = 52083;
    
    // Contador para a divisão
    reg [15:0] contador = 0;

    always @(posedge clk_entrada or negedge reset_n) begin
        if (!reset_n) begin
            contador  <= 0;
            clk_saida <= 1'b0;
        end else begin
            if (contador == FATOR_DIVISAO - 1) begin
                contador  <= 0;
                clk_saida <= ~clk_saida;
            end else begin
                contador <= contador + 1;
            end
        end
    end

endmodule