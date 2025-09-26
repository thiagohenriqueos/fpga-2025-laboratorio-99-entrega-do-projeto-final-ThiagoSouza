// Arquivo: MuxComTimer2s.v
//--------------------------------------------------------------------------------
// Combina um contador de período de 2s com um multiplexador 2x1.
// A saída 'saida_seletor' alterna entre 0 e 1 a cada segundo.
//--------------------------------------------------------------------------------
module MuxComTimer2s (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [15:0] dado_a,
    input  wire [15:0] dado_b,
    output wire [15:0] saida_mux,
    output wire        saida_seletor
);

    parameter FREQUENCIA_CLK = 25_000_000;
    localparam CONTAGEM_UM_SEGUNDO = FREQUENCIA_CLK;

    reg [24:0] contador_timer;
    reg        seletor_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            contador_timer <= 0;
            seletor_reg    <= 1'b0;
        end else begin
            if (contador_timer == CONTAGEM_UM_SEGUNDO - 1) begin
                contador_timer <= 0;
                seletor_reg    <= ~seletor_reg;
            end else begin
                contador_timer <= contador_timer + 1;
            end
        end
    end

    assign saida_mux     = seletor_reg ? dado_b : dado_a;
    assign saida_seletor = seletor_reg;

endmodule