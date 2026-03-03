#!/bin/bash
set -euo pipefail

# ===== CONFIG via env var (con fallback) =====
GSEA_CLI_PATH="${GSEA_CLI_PATH:-/path/to/gsea-cli.sh}"
GMT_FILE="${GMT_FILE:-/path/to/geneset.gmt}"
REPORTS_DIR="${REPORTS_DIR:-results/gsea}"

# ===== INPUT =====
RNK_DIR="${1:-.}"

mkdir -p "$REPORTS_DIR"
# ===== GSEA parameters (with defaults) =====
SET_MIN="${SET_MIN:-10}"
SET_MAX="${SET_MAX:-5000}"
PLOT_TOP_X="${PLOT_TOP_X:-2000}"



for RNK_FILE in "$RNK_DIR"/*.rnk; do
    [ -e "$RNK_FILE" ] || continue

    BASENAME=$(basename "$RNK_FILE" .rnk)
    OUTDIR="$REPORTS_DIR/$BASENAME"

    mkdir -p "$OUTDIR"

    echo "Running GSEA on $RNK_FILE"
	
   "$GSEA_CLI_PATH" GSEAPreranked \
    -rnk "$RNK_FILE" \
    -gmx "$GMT_FILE" \
    -set_min "$SET_MIN" \
    -set_max "$SET_MAX" \
    -plot_top_x "$PLOT_TOP_X" \
    -out "$OUTDIR"


done

