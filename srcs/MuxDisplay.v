// Arquivo: MuxDisplay.v
//--------------------------------------------------------------------------------
// Multiplexador 4 para 1 para os displays de 7 segmentos.
// Seleciona qual dos 4 dígitos será exibido e ativa o ânodo correspondente.
//--------------------------------------------------------------------------------
module MuxDisplay (
    input  wire [6:0] digito4,      // Dados do dígito de milhares
    input  wire [6:0] digito3,      // Dados do dígito de centenas
    input  wire [6:0] digito2,      // Dados do dígito de dezenas
    input  wire [6:0] digito1,      // Dados do dígito de unidades
    input  wire [1:0] sel,          // Sinal de seleção (0 a 3)
    output reg  [6:0] saida_seg,    // Saída para os segmentos a-g
    output reg  [3:0] saida_anodos, // Saída para os ânodos (ativo em baixo)
    output reg        saida_dp      // Saída para o ponto decimal
);

    always @* begin
        case (sel)
            2'd0: begin // Seleciona digito4 (Milhares)
                saida_seg    = digito4;
                saida_anodos = 4'b0111;
                saida_dp     = 1'b0;
            end
            2'd1: begin // Seleciona digito3 (Centenas)
                saida_seg    = digito3;
                saida_anodos = 4'b1011;
                saida_dp     = 1'b0;
            end
            2'd2: begin // Seleciona digito2 (Dezenas)
                saida_seg    = digito2;
                saida_anodos = 4'b1101;
                saida_dp     = 1'b1;
            end
            2'd3: begin // Seleciona digito1 (Unidades)
                saida_seg    = digito1;
                saida_anodos = 4'b1110;
                saida_dp     = 1'b0;
            end
            default: begin
                saida_seg    = 7'b0000000;
                saida_anodos = 4'b1111;
                saida_dp     = 1'b0;
            end
        endcase
    end

endmodule