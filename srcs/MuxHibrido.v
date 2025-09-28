//--------------------------------------------------------------------------------
// Módulo Híbrido:
// 1. Gera um sinal 'saida_seletor_timer' que alterna a cada 1 segundo.
// 2. Controla um MUX 2x1 'saida_mux' pela detecção de borda de descida
//    em 'control_a' e 'control_b'.
// As duas lógicas são independentes.
//--------------------------------------------------------------------------------
module MuxHibrido (
    // --- Sinais Globais ---
    input  wire        clk,
    input  wire        reset_n,

    // --- Entradas do MUX ---
    input  wire [15:0] dado_a,
    input  wire [15:0] dado_b,
    input  wire        control_a, // Borda de descida seleciona dado_a
    input  wire        control_b, // Borda de descida seleciona dado_b

    // --- Saídas ---
    output wire [15:0] saida_mux,           // Saída do MUX (controlado por borda)
    output wire        saida_seletor_timer  // Saída do seletor que alterna a cada 1s
);

    //============================================================================
    // LÓGICA 1: Timer que alterna um sinal a cada segundo
    //============================================================================
    parameter FREQUENCIA_CLK = 25_000_000;
    localparam CONTAGEM_UM_SEGUNDO = FREQUENCIA_CLK;

    reg [24:0] contador_timer;
    reg        seletor_timer_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            contador_timer    <= 0;
            seletor_timer_reg <= 1'b0;
        end else begin
            if (contador_timer == CONTAGEM_UM_SEGUNDO - 1) begin
                contador_timer    <= 0;
                seletor_timer_reg <= ~seletor_timer_reg;
            end else begin
                contador_timer <= contador_timer + 1;
            end
        end
    end

    // Atribui o resultado do timer à sua porta de saída dedicada
    assign saida_seletor_timer = seletor_timer_reg;


    //============================================================================
    // LÓGICA 2: MUX controlado por borda de descida
    //============================================================================
    reg sel_edge_reg;
    reg control_a_prev;
    reg control_b_prev;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Estado inicial no reset
            sel_edge_reg   <= 1'b0;
            control_a_prev <= 1'b0;
            control_b_prev <= 1'b0;
        end else begin
            // Armazena o estado atual para o próximo ciclo
            control_a_prev <= control_a;
            control_b_prev <= control_b;

            // Detecta borda de descida em control_a
            if (control_a_prev && !control_a) begin
                sel_edge_reg <= 1'b0;
            end

            // Detecta borda de descida em control_b
            if (control_b_prev && !control_b) begin
                sel_edge_reg <= 1'b1;
            end
        end
    end

    // Atribui a saída do MUX com base no seletor controlado por borda
    assign saida_mux = sel_edge_reg ? dado_b : dado_a;

endmodule