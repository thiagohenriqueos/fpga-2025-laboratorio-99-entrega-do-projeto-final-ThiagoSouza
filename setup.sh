#!/bin/bash
# ============================================================
# setup.sh - Script de build e gravação para Colorlight i9
# ============================================================

set -e  # para o script se algum comando falhar

# ---- Configurações ----
TOP="top"
SRC_DIR="srcs"                
LPF="constraints/constraints_cli9.lpf"
BUILD_DIR="build"
JSON="$BUILD_DIR/$TOP.json"
CFG="$BUILD_DIR/$TOP.config"
BIT="$BUILD_DIR/$TOP.bit"

DEVICE="--45k"
PACKAGE="CABGA381"
SPEED="6"
FREQ="25"
BOARD="colorlight-i9"

# ---- Preparação ----
mkdir -p "$BUILD_DIR"

echo "[1/4] Síntese com Yosys..."
yosys -p "read_verilog $SRC_DIR/*.v; synth_ecp5 -top $TOP -json $JSON -abc9"

echo "[2/4] Place & Route com nextpnr..."
nextpnr-ecp5 \
    --json "$JSON" \
    --lpf "$LPF" \
    --textcfg "$CFG" \
    --package "$PACKAGE" \
    $DEVICE \
    --speed "$SPEED" \
    --freq "$FREQ"

echo "[3/4] Empacotando bitstream..."
ecppack --input "$CFG" --bit "$BIT" 

echo "[4/4] Gravando na FPGA..."
openFPGALoader -b "$BOARD" "$BIT"

echo "✅ Fluxo completo finalizado com sucesso!"
