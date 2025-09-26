// Arquivo: ConversorBcd.v
//--------------------------------------------------------------------------------
// Módulo "wrapper" que gerencia o CoreConversorBcd.
// Ele inicia a conversão automaticamente quando a entrada muda e
// fornece as saídas BCD em 4 portas separadas.
//--------------------------------------------------------------------------------
module ConversorBcd (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [15:0] entrada_binaria,
    output wire [3:0]  milhar,
    output wire [3:0]  centena,
    output wire [3:0]  dezena,
    output wire [3:0]  unidade
);

    reg         iniciar_conversao;
    wire        dados_validos;
    wire [15:0] bcd_agrupado;
    reg [15:0]  entrada_binaria_reg;

    always @(posedge clk) begin
        if (!reset_n) begin
            entrada_binaria_reg <= 16'd0;
            iniciar_conversao   <= 1'b0;
        end else begin
            iniciar_conversao <= 1'b0; // Pulso dura 1 ciclo
            if (entrada_binaria_reg != entrada_binaria) begin
                iniciar_conversao   <= 1'b1;
                entrada_binaria_reg <= entrada_binaria;
            end
        end
    end

    CoreConversorBcd #(
        .LARGURA_ENTRADA(16),
        .DIGITOS_DECIMAIS(4)
    ) core_conversor_inst (
        .clk             (clk),
        .reset_n         (reset_n),
        .entrada_binaria (entrada_binaria_reg),
        .iniciar         (iniciar_conversao),
        .saida_bcd       (bcd_agrupado),
        .dados_validos   (dados_validos)
    );

    reg [15:0] bcd_saida_reg;
    always @(posedge clk) begin
        if (!reset_n) begin
            bcd_saida_reg <= 16'd0;
        end else if (dados_validos) begin
            bcd_saida_reg <= bcd_agrupado;
        end
    end

    assign milhar  = bcd_saida_reg[15:12];
    assign centena = bcd_saida_reg[11:8];
    assign dezena  = bcd_saida_reg[7:4];
    assign unidade = bcd_saida_reg[3:0];
endmodule