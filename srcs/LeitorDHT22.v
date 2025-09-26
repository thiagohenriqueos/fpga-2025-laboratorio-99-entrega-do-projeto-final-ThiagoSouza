// Arquivo: LeitorDHT22.v
//--------------------------------------------------------------------------------
// Módulo "wrapper" que adapta a interface do CoreLeitorDHT para o projeto,
// adicionando controle por gatilho e saídas de dados formatadas.
//--------------------------------------------------------------------------------
module LeitorDHT22 (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        iniciar_leitura,
    inout  wire        pino_dht,
    output reg [15:0]  umidade,
    output reg [15:0]  temperatura,
    output reg         dados_prontos,
    output reg         checksum_ok,
    output wire [3:0]  estado_depuracao
);

    // --- Sinais de Conexão com o Core ---
    wire        rst_core;
    wire [39:0] dados_brutos_core;
    wire        leitura_concluida_core;

    // O reset do projeto é ativo-baixo, mas o do core é ativo-alto.
    assign rst_core = ~reset_n;

    // Instancia o core de leitura (lógica traduzida do VHDL)
    CoreLeitorDHT #(
        .PERIODO_CLK_NS(40) // 25MHz = 40ns
    ) core_leitor_inst (
        .clk                (clk),
        .reset              (rst_core),
        .pino_dados         (pino_dht),
        .dados_brutos_saida (dados_brutos_core),
        .leitura_concluida  (leitura_concluida_core)
    );

    // --- FSM de Controle ---
    // Controla o core "free-running" para que ele execute apenas uma vez por gatilho.
    reg [1:0] estado;
    localparam S_OCIOSO   = 2'd0,
               S_EXECUTANDO = 2'd1,
               S_CONCLUIDO  = 2'd2;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            estado      <= S_OCIOSO;
            dados_prontos <= 1'b0;
            checksum_ok <= 1'b0;
            temperatura <= 16'd0;
            umidade     <= 16'd0;
        end else begin
            dados_prontos <= 1'b0; // O sinal 'dados_prontos' é um pulso de 1 ciclo.

            case (estado)
                S_OCIOSO: begin
                    if (iniciar_leitura) begin
                        estado <= S_EXECUTANDO;
                    end
                end
                S_EXECUTANDO: begin
                    if (leitura_concluida_core) begin
                        dados_prontos <= 1'b1;
                        estado        <= S_CONCLUIDO;

                        // Captura e separa os dados
                        umidade     <= dados_brutos_core[39:24];
                        temperatura <= dados_brutos_core[23:8];

                        // Calcula o checksum
                        if ({8'h00, dados_brutos_core[39:32] + dados_brutos_core[31:24] + dados_brutos_core[23:16] + dados_brutos_core[15:8]} == dados_brutos_core[7:0]) begin
                            checksum_ok <= 1'b1;
                        end else begin
                            checksum_ok <= 1'b0;
                        end
                    end
                end
                S_CONCLUIDO: begin
                    checksum_ok <= 1'b0; // O sinal de checksum também dura 1 ciclo.
                    if (!iniciar_leitura) begin
                        estado <= S_OCIOSO;
                    end
                end
            endcase
        end
    end

    // Saída de depuração mostra o estado do wrapper
    assign estado_depuracao = {2'b0, estado};
endmodule