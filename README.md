
# Projeto Final Lab99: Leitor de Sensor DHT22 com Display de 7 segmentos em FPGA

**Autor:** Thiago Henrique Oliveira Souza

## Resumo do Projeto

Este projeto implementa em Verilog um sistema completo para a leitura de dados de temperatura e umidade de um sensor DHT22, com a exibição dos valores em 2 displays de 7 segmentos de 2 dígitos. 

O sistema alterna a exibição entre a temperatura (em graus Celsius) e a umidade relativa (em percentual) a cada segundo. O design é modular e inclui componentes para a comunicação com o sensor, conversão de dados de binário para BCD (Decimal Codificado em Binário) e controle do display por varredura (multiplexação). LEDs auxiliares na placa foram utilizados durante a fase de desenvolvimento para facilitar a depuração.

## Funcionalidades

* **Leitura de Sensor DHT22:** Uma máquina de estados (FSM) implementa o protocolo de comunicação de um fio do sensor DHT22 para ler o pacote de 40 bits de dados.
* **Controle e Temporização:** Um temporizador principal de 2 segundos orquestra o sistema, alternando a exibição e disparando novas leituras do sensor.
* **Conversão Binário para BCD:** Um módulo sequencial (baseado no algoritmo *Double Dabble*) converte os valores binários de 16 bits lidos do sensor para o formato BCD (4 dígitos), que é necessário para a exibição decimal.
* **Subsistema de Display:**
    * Decodificadores convertem cada dígito BCD para os sinais de 7 segmentos correspondentes.
    * Um controlador de varredura gerencia os 4 dígitos do display em alta velocidade, criando o efeito de persistência de visão para que o número completo seja legível.
    * Controle do ponto decimal para indicar a casa decimal.
* **Depuração por LEDs:** 8 LEDs na placa são usados para monitorar em tempo real os sinais críticos do sistema, como o estado da FSM do sensor e o checksum.


## Hardware e Ferramentas

* **Placa FPGA:** Lattice ECP5-45F (Colorlight i9)
* **Sensor:** Sensor de Temperatura e Umidade DHT22
* **Toolchain (Software):** Projeto desenvolvido para o fluxo de ferramentas de código aberto:
    * **Síntese:** Yosys
    * **Place & Route:** nextpnr
    * **Geração de Bitstream:** Project Trellis (ecppack)

## Como Replicar

Para sintetizar, mapear e gerar o bitstream para a placa, execute o arquivo setup.sh localizado na pasta raiz do projeto.

## Pinagem (Arquivo: `constraints/constraints_cli9.lpf`)

A tabela abaixo resume a pinagem utilizada para a placa Colorlight i9.

| Sinal no Verilog | Pino na Placa | Função                        |
| :--------------- | :-----------: | :---------------------------- |
| `clk`            |      P3       | Clock principal de 25 MHz     |
| `reset_n`        |      P17      | Botão de Reset (ativo-baixo)  |
| `dht_pin`        |      J5       | Pino de dados do sensor DHT22 |
|                  |               |                               |
| `led[7:0]`       | Ver abaixo    | LEDs de depuração             |
| `led[7]`         |      G20      | `dados_prontos_sensor`        |
| `led[6]`         |      K20      | `checksum_ok_sensor`          |
| `led[5]`         |      L20      | `seletor_mux`                 |
| `led[4]`         |      N18      | `gatilho_leitura`             |
| `led[3]`         |      J20      | `estado_fsm_dht[3]`           |
| `led[2]`         |      L18      | `estado_fsm_dht[2]`           |
| `led[1]`         |      M18      | `estado_fsm_dht[1]`           |
| `led[0]`         |      N17      | `estado_fsm_dht[0]`           |
|                  |               |                               |
| `a`, `b`, `c`, `d` | G16, H16, H17, J17 | Segmentos do Display 7-Seg |
| `e`, `f`, `g`, `dp` | E18, F18, G18, F16 | Segmentos do Display 7-Seg |
|                  |               |                               |
| `an[3]`          |      F4       | Ânodo do Dígito 4 (Milhar)    |
| `an[2]`          |      E6       | Ânodo do Dígito 3 (Centena)   |
| `an[1]`          |      D16      | Ânodo do Dígito 2 (Dezena)    |
| `an[0]`          |      D17      | Ânodo do Dígito 1 (Unidade)   |
