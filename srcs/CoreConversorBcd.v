// Arquivo: CoreConversorBcd.v
//--------------------------------------------------------------------------------
// Implementa a conversão Binário->BCD de forma sequencial usando uma FSM
// e o algoritmo "Shift-and-Add-3" (Double Dabble).
// Baseado no código de www.nandland.com
//--------------------------------------------------------------------------------
module CoreConversorBcd
  #(parameter LARGURA_ENTRADA = 16,
    parameter DIGITOS_DECIMAIS = 4)
  (
    input  wire                           clk,
    input  wire                           reset_n,
    input  wire [LARGURA_ENTRADA-1:0]     entrada_binaria,
    input  wire                           iniciar,
    output wire [DIGITOS_DECIMAIS*4-1:0]  saida_bcd,
    output wire                           dados_validos
   );

  localparam S_OCIOSO                 = 3'b000;
  localparam S_DESLOCA                = 3'b001;
  localparam S_VERIFICA_INDICE_DESLOC = 3'b010;
  localparam S_SOMA_3                 = 3'b011;
  localparam S_VERIFICA_INDICE_DIGITO = 3'b100;
  localparam S_CONCLUIDO              = 3'b101;

  reg [2:0]  estado_fsm = S_OCIOSO;
  reg [DIGITOS_DECIMAIS*4-1:0] bcd_reg = 0;
  reg [LARGURA_ENTRADA-1:0]      binario_reg = 0;
  integer                        indice_digito = 0;
  integer                        contador_loop = 0;
  reg                            dados_validos_reg = 1'b0;

  wire [3:0] digito_bcd_atual = bcd_reg >> (indice_digito * 4);

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      estado_fsm        <= S_OCIOSO;
      bcd_reg           <= 0;
      binario_reg       <= 0;
      indice_digito     <= 0;
      contador_loop     <= 0;
      dados_validos_reg <= 1'b0;
    end else begin
      case (estado_fsm)
        S_OCIOSO: begin
          dados_validos_reg <= 1'b0;
          if (iniciar) begin
            binario_reg <= entrada_binaria;
            bcd_reg     <= 0;
            estado_fsm  <= S_DESLOCA;
          end
        end
        S_DESLOCA: begin
          bcd_reg     <= {bcd_reg[DIGITOS_DECIMAIS*4-2:0], binario_reg[LARGURA_ENTRADA-1]};
          binario_reg <= binario_reg << 1;
          estado_fsm  <= S_VERIFICA_INDICE_DESLOC;
        end
        S_VERIFICA_INDICE_DESLOC: begin
          if (contador_loop == LARGURA_ENTRADA-1) begin
            contador_loop <= 0;
            estado_fsm    <= S_CONCLUIDO;
          end else begin
            contador_loop <= contador_loop + 1;
            estado_fsm    <= S_SOMA_3;
          end
        end
        S_SOMA_3: begin
          if (digito_bcd_atual > 4) begin
            bcd_reg <= bcd_reg + (3 << (indice_digito*4));
          end
          estado_fsm <= S_VERIFICA_INDICE_DIGITO;
        end
        S_VERIFICA_INDICE_DIGITO: begin
          if (indice_digito == DIGITOS_DECIMAIS-1) begin
            indice_digito <= 0;
            estado_fsm    <= S_DESLOCA;
          end else begin
            indice_digito <= indice_digito + 1;
            estado_fsm    <= S_SOMA_3;
          end
        end
        S_CONCLUIDO: begin
          dados_validos_reg <= 1'b1;
          estado_fsm        <= S_OCIOSO;
        end
        default:
          estado_fsm <= S_OCIOSO;
      endcase
    end
  end

  assign saida_bcd    = bcd_reg;
  assign dados_validos = dados_validos_reg;

endmodule