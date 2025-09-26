// Arquivo: HexPara7Seg.v
//--------------------------------------------------------------------------------
// Módulo combinacional que converte um valor de 4 bits (nibble) para
// os 7 sinais que controlam um display de 7 segmentos.
//--------------------------------------------------------------------------------
module HexPara7Seg (
    input  wire [3:0] entrada_hex,
    output reg  [6:0] saida_seg
);
    // Tabela de conversão para anodo comum (segmento acende em '1')
    always @* begin
        case (entrada_hex)
            4'h0: saida_seg = 7'b1111110; // 0
            4'h1: saida_seg = 7'b0110000; // 1
            4'h2: saida_seg = 7'b1101101; // 2
            4'h3: saida_seg = 7'b1111001; // 3
            4'h4: saida_seg = 7'b0110011; // 4
            4'h5: saida_seg = 7'b1011011; // 5
            4'h6: saida_seg = 7'b1011111; // 6
            4'h7: saida_seg = 7'b1110000; // 7
            4'h8: saida_seg = 7'b1111111; // 8
            4'h9: saida_seg = 7'b1111011; // 9
            4'hA: saida_seg = 7'b1110111; // A
            4'hB: saida_seg = 7'b0011111; // b
            4'hC: saida_seg = 7'b1001110; // C
            4'hD: saida_seg = 7'b0111101; // d
            4'hE: saida_seg = 7'b1001111; // E
            4'hF: saida_seg = 7'b1000111; // F
            default: saida_seg = 7'b0000000; // Apagado
        endcase
    end
endmodule