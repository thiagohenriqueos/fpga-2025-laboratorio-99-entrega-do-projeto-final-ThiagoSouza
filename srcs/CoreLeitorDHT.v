// Arquivo: CoreLeitorDHT.v (VERSÃO CORRIGIDA)
//--------------------------------------------------------------------------------
// Lógica principal de leitura do sensor DHT22.
// Esta é uma tradução direta da FSM originalmente em VHDL.
// O módulo opera de forma "free-running", iniciando uma nova leitura
// automaticamente após a outra.
//--------------------------------------------------------------------------------
module CoreLeitorDHT (
    // Portas
    input  wire                       clk,
    input  wire                       reset, // Reset síncrono, ATIVO EM ALTO
    inout  wire                       pino_dados,
    output reg [39:0]                 dados_brutos_saida,
    output reg                        leitura_concluida
);

    // --- Parâmetros (movidos para a posição correta) ---
    parameter PERIODO_CLK_NS = 40;
    parameter LARGURA_DADOS  = 40;

    // --- Constantes de Tempo ---
    localparam ATRASO_1MS  = (1000 * 1000) / PERIODO_CLK_NS + 1;
    localparam ATRASO_40US = (40 * 1000)   / PERIODO_CLK_NS + 1;
    localparam ATRASO_80US = (80 * 1000)   / PERIODO_CLK_NS + 1;
    localparam ATRASO_50US = (50 * 1000)   / PERIODO_CLK_NS + 1;
    localparam LIMITE_BIT1 = (70 * 1000)   / PERIODO_CLK_NS + 1;
    localparam LIMITE_BIT0 = (28 * 1000)   / PERIODO_CLK_NS + 1;
    localparam ATRASO_MAX  = (5000 * 1000) / PERIODO_CLK_NS + 1;

    // --- Estados da FSM ---
    localparam S_REINICIO         = 4'd0,
               S_INICIO_MESTRE      = 4'd1,
               S_ESPERA_RESPOSTA  = 4'd2,
               S_RESPOSTA_ESCRAVO   = 4'd3,
               S_ATRASO_ESCRAVO     = 4'd4,
               S_INICIO_BIT         = 4'd5,
               S_MEDE_BIT           = 4'd6,
               S_FIM_LEITURA        = 4'd7;

    // --- Sinais Internos ---
    reg [2:0]  sincronizador_entrada;
    wire       borda_subida;
    wire       borda_descida;
    reg [3:0]  estado;
    reg [16:0] contador_atraso;
    reg [5:0]  contador_bits;
    reg        habilita_saida;

    // --- Lógica de Hardware ---
    assign pino_dados = (habilita_saida) ? 1'b0 : 1'bz;

    always @(posedge clk) begin
        sincronizador_entrada <= {sincronizador_entrada[1:0], pino_dados};
    end

    assign borda_subida  = (sincronizador_entrada[2:1] == 2'b01);
    assign borda_descida = (sincronizador_entrada[2:1] == 2'b10);

    // Máquina de Estados Principal
    always @(posedge clk) begin
        if (reset) begin
            contador_bits      <= 0;
            dados_brutos_saida <= 0;
            contador_atraso    <= ATRASO_MAX;
            estado             <= S_REINICIO;
            leitura_concluida  <= 1'b0;
            habilita_saida     <= 1'b0;
        end else begin
            leitura_concluida <= 1'b0;

            case (estado)
                S_REINICIO: begin
                    if (contador_atraso == 0) begin
                        contador_bits   <= LARGURA_DADOS;
                        habilita_saida  <= 1'b1;
                        contador_atraso <= ATRASO_1MS;
                        estado          <= S_INICIO_MESTRE;
                    end else begin
                        contador_atraso <= contador_atraso - 1;
                    end
                end
                S_INICIO_MESTRE: begin
                    if (contador_atraso == 0) begin
                        habilita_saida  <= 1'b0;
                        contador_atraso <= ATRASO_40US;
                        estado          <= S_ESPERA_RESPOSTA;
                    end else begin
                        contador_atraso <= contador_atraso - 1;
                    end
                end
                S_ESPERA_RESPOSTA: begin
                    if (borda_descida) begin
                        estado <= S_RESPOSTA_ESCRAVO;
                    end
                end
                S_RESPOSTA_ESCRAVO: begin
                    if (borda_subida) begin
                        estado <= S_ATRASO_ESCRAVO;
                    end
                end
                S_ATRASO_ESCRAVO: begin
                    if (borda_descida) begin
                        estado <= S_INICIO_BIT;
                    end
                end
                S_INICIO_BIT: begin
                    if (borda_subida) begin
                        contador_atraso <= 0;
                        estado          <= S_MEDE_BIT;
                    end else if (contador_bits == 0) begin
                        contador_atraso <= ATRASO_50US;
                        estado          <= S_FIM_LEITURA;
                    end
                end
                S_MEDE_BIT: begin
                    if (borda_descida) begin
                        contador_bits <= contador_bits - 1;
                        if (contador_atraso > LIMITE_BIT0) begin // Bit '1'
                            dados_brutos_saida <= {dados_brutos_saida[LARGURA_DADOS-2:0], 1'b1};
                        end else begin // Bit '0'
                            dados_brutos_saida <= {dados_brutos_saida[LARGURA_DADOS-2:0], 1'b0};
                        end
                        estado <= S_INICIO_BIT;
                    end else begin
                       contador_atraso <= contador_atraso + 1;
                    end
                end
                S_FIM_LEITURA: begin
                    if (contador_atraso == 0) begin
                        contador_atraso <= ATRASO_MAX;
                        estado          <= S_REINICIO;
                    end else begin
                        leitura_concluida <= 1'b1;
                        contador_atraso   <= contador_atraso - 1;
                    end
                end
                default: estado <= S_REINICIO;
            endcase
        end
    end

endmodule