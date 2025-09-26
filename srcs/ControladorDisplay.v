// Arquivo: ControladorDisplay.v
//--------------------------------------------------------------------------------
// Módulo completo para o display. Recebe um número binário de 16 bits,
// converte para BCD e o exibe nos 4 displays de 7 segmentos usando
// multiplexação por varredura.
//--------------------------------------------------------------------------------
module ControladorDisplay (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [15:0] dado_binario_entrada,
    output wire [3:0]  anodos,
    output wire        seg_a,
    output wire        seg_b,
    output wire        seg_c,
    output wire        seg_d,
    output wire        seg_e,
    output wire        seg_f,
    output wire        seg_g,
    output wire        ponto_decimal
);

    // --- Sinais Internos ---
    wire [3:0] bcd_milhar, bcd_centena, bcd_dezena, bcd_unidade;
    wire [6:0] seg_milhar, seg_centena, seg_dezena, seg_unidade;
    wire       clk_varredura;
    wire [1:0] sel_digito;
    wire [6:0] seg_atual;
    wire       dp_atual;

    // --- Lógica de Conversão e Display ---

    // 1. Instancia o conversor de Binário para BCD.
    ConversorBcd conversor_bcd_inst (
        .clk        (clk),
        .reset_n    (reset_n),
        .entrada_binaria (dado_binario_entrada),
        .milhar     (bcd_milhar),
        .centena    (bcd_centena),
        .dezena     (bcd_dezena),
        .unidade    (bcd_unidade)
    );

    // 2. Converte cada dígito BCD para o formato de 7 segmentos.
    HexPara7Seg decodificador_milhar_inst (.entrada_hex(bcd_milhar),  .saida_seg(seg_milhar));
    HexPara7Seg decodificador_centena_inst(.entrada_hex(bcd_centena), .saida_seg(seg_centena));
    HexPara7Seg decodificador_dezena_inst (.entrada_hex(bcd_dezena),  .saida_seg(seg_dezena));
    HexPara7Seg decodificador_unidade_inst(.entrada_hex(bcd_unidade), .saida_seg(seg_unidade));

    // 3. Lógica de multiplexação do display (varredura).
    DivisorClock divisor_clk_display_inst (
        .clk_entrada (clk),
        .reset_n     (reset_n),
        .clk_saida   (clk_varredura)
    );

    Contador0a3 contador_digito_inst (
        .clk      (clk_varredura),
        .reset_n  (reset_n),
        .contagem (sel_digito)
    );

    MuxDisplay mux_digito_inst (
        .digito4      (seg_milhar),
        .digito3      (seg_centena),
        .digito2      (seg_dezena),
        .digito1      (seg_unidade),
        .sel          (sel_digito),
        .saida_seg    (seg_atual),
        .saida_anodos (anodos),
        .saida_dp     (dp_atual)
    );

    // --- Atribuições Finais de Saída ---
    assign {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = seg_atual;
    assign ponto_decimal = dp_atual;

endmodule