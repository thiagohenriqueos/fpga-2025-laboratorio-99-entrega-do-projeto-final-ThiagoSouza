// Arquivo: Top.v
//--------------------------------------------------------------------------------
// Módulo principal que integra o leitor de sensor DHT22, o conversor de dados
// e o controlador de display de 7 segmentos.
//--------------------------------------------------------------------------------
module top (
    input  wire        clk,
    input  wire        reset_n,
    inout  wire        dht_pin,

    // Saídas para o display de 7 segmentos
    output wire [3:0]  an,
    output wire        a, b, c, d, e, f, g, dp,

    // Saída para LEDs de depuração
    output wire [7:0]  led
);

    // --- Sinais de Conexão Interna ---
    wire [15:0] umidade_sensor;
    wire [15:0] temperatura_sensor;
    wire        dados_prontos_sensor;
    wire        checksum_ok_sensor;
    wire        gatilho_leitura;
    wire [15:0] dado_para_display;
    wire        seletor_mux;
    wire [3:0]  estado_fsm_dht;

    // --- Instanciação dos Módulos ---

    // Leitor do sensor DHT22 (versão adaptada do VHDL)
    LeitorDHT22 leitor_dht_inst (
        .clk             (clk),
        .reset_n         (reset_n),
        .iniciar_leitura (gatilho_leitura),
        .pino_dht        (dht_pin),
        .umidade         (umidade_sensor),
        .temperatura     (temperatura_sensor),
        .dados_prontos   (dados_prontos_sensor),
        .checksum_ok     (checksum_ok_sensor),
        .estado_depuracao(estado_fsm_dht)
    );

    // Mux que alterna entre temperatura e umidade a cada 1 segundo
    MuxComTimer2s mux_timer_inst (
        .clk           (clk),
        .reset_n       (reset_n),
        .dado_a        (temperatura_sensor),
        .dado_b        (umidade_sensor),
        .saida_mux     (dado_para_display),
        .saida_seletor (seletor_mux)
    );

    // O gatilho para iniciar a leitura é o próprio sinal do seletor do MUX.
    // A FSM do leitor é projetada para lidar com um sinal de nível.
    assign gatilho_leitura = seletor_mux;

    // Controlador que converte os dados e gerencia o display de 7 segmentos
    ControladorDisplay controlador_display_inst (
        .clk                  (clk),
        .reset_n              (reset_n),
        .dado_binario_entrada (dado_para_display),
        .anodos               (an),
        .seg_a                (a),
        .seg_b                (b),
        .seg_c                (c),
        .seg_d                (d),
        .seg_e                (e),
        .seg_f                (f),
        .seg_g                (g),
        .ponto_decimal        (dp)
    );

    // --- Lógica de Depuração dos LEDs ---
    assign led[7] = dados_prontos_sensor;
    assign led[6] = checksum_ok_sensor;
    assign led[5] = seletor_mux;
    assign led[4] = gatilho_leitura;
    assign led[3:0] = estado_fsm_dht;

endmodule