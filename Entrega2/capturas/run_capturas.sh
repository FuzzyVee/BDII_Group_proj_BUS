#!/usr/bin/env bash
# ===========================================================================================
# Ejecuta el guion de capturas de la P2 y guarda la salida de SQL*Plus.
#
# Uso:
#   ./run_capturas.sh          -> genera .txt y .html en salida/
#   ./run_capturas.sh --png    -> ademas intenta generar .png con wkhtmltoimage/Chromium
#
# Variables opcionales:
#   ORACLE_HOST, ORACLE_PORT, ORACLE_SERVICE
#   ORACLE_SYS_CONNECT, ORACLE_CONNECT
# ===========================================================================================
set -euo pipefail

cd "$(dirname "$0")"

HOST="${ORACLE_HOST:-localhost}"
PORT="${ORACLE_PORT:-15211}"
SERVICE="${ORACLE_SERVICE:-BDII}"

SYS_CONNECT="${ORACLE_SYS_CONNECT:-sys/Oracle12345@//${HOST}:${PORT}/${SERVICE} as sysdba}"
USER_CONNECT="${ORACLE_CONNECT:-ALUMNO/ALUMNO@//${HOST}:${PORT}/${SERVICE}}"

OUT="salida"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"

HACER_PNG="no"
if [[ "${1:-}" == "--png" ]]; then
    HACER_PNG="si"
elif [[ -n "${1:-}" ]]; then
    echo "Uso: $0 [--png]" >&2
    exit 2
fi

if ! command -v sqlplus >/dev/null 2>&1; then
    echo "ERROR: no se encuentra 'sqlplus'. Ejecute el script donde este instalado el cliente Oracle" >&2
    echo "       o use la imagen gvenzl/oracle-free y monte este directorio." >&2
    exit 1
fi

if ! (exec 3<>"/dev/tcp/${HOST}/${PORT}") 2>/dev/null; then
    echo "ERROR: no hay listener Oracle en ${HOST}:${PORT}." >&2
    echo "       Arranque la base con: docker compose up -d" >&2
    exit 1
fi

render_png() {
    local html="$1"
    local png="${html%.html}.png"

    if command -v wkhtmltoimage >/dev/null 2>&1; then
        wkhtmltoimage --quiet --width 1600 "$html" "$png" >/dev/null 2>&1 || true
    elif command -v chromium >/dev/null 2>&1; then
        chromium --headless --disable-gpu --no-sandbox --hide-scrollbars \
            --window-size=1600,1200 --screenshot="$png" "file://${PWD}/${html}" >/dev/null 2>&1 || true
    elif command -v chromium-browser >/dev/null 2>&1; then
        chromium-browser --headless --disable-gpu --no-sandbox --hide-scrollbars \
            --window-size=1600,1200 --screenshot="$png" "file://${PWD}/${html}" >/dev/null 2>&1 || true
    elif command -v google-chrome >/dev/null 2>&1; then
        google-chrome --headless --disable-gpu --no-sandbox --hide-scrollbars \
            --window-size=1600,1200 --screenshot="$png" "file://${PWD}/${html}" >/dev/null 2>&1 || true
    else
        echo "   aviso: no hay wkhtmltoimage ni Chromium; abra $html y capture manualmente."
    fi
}

run_capture() {
    local nombre="$1"
    local conexion="$2"
    local script="$3"
    local txt="${OUT}/${nombre}.txt"
    local html="${OUT}/${nombre}.html"
    local wrapper="${TMP}/${nombre}_html.sql"

    echo "==> ${nombre}"

    if ! sqlplus -L -s "$conexion" "@${PWD}/${script}" > "$txt" 2>&1; then
        echo "   ERROR al ejecutar ${script}. Ultimas lineas:" >&2
        tail -n 20 "$txt" >&2 || true
        return 1
    fi

    {
        echo "SET MARKUP HTML ON SPOOL ON PREFORMAT OFF ENTMAP ON"
        echo "SPOOL ${PWD}/${html}"
        echo "@${PWD}/${script}"
        echo "SPOOL OFF"
        echo "SET MARKUP HTML OFF"
        echo "EXIT"
    } > "$wrapper"

    # La version HTML es auxiliar: si falla, el .txt sigue siendo valido.
    if ! sqlplus -L -s "$conexion" "@${wrapper}" > "${OUT}/${nombre}.html.log" 2>&1; then
        echo "   aviso: no se pudo generar ${html}; se conserva ${txt}." >&2
    fi

    if [[ "$HACER_PNG" == "si" && -f "$html" ]]; then
        render_png "$html"
    fi
}

echo "============================================================"
echo " Capturas P2 - ${SERVICE} en ${HOST}:${PORT}"
echo " Salida: ${PWD}/${OUT}"
echo "============================================================"

run_capture "01_entorno"      "$SYS_CONNECT"  "01_entorno.sql"
run_capture "02_tablespaces"  "$SYS_CONNECT"  "02_tablespaces.sql"
run_capture "03_lobs"         "$USER_CONNECT" "03_lobs.sql"
run_capture "04_carga"        "$USER_CONNECT" "04_carga.sql"
run_capture "05_particionado" "$USER_CONNECT" "05_particionado.sql"
run_capture "06_memoria"      "$SYS_CONNECT"  "06_memoria.sql"
run_capture "07_redo"         "$SYS_CONNECT"  "07_redo.sql"
run_capture "08_cuotas"       "$SYS_CONNECT"  "08_cuotas.sql"

echo "============================================================"
echo " Capturas generadas en ${PWD}/${OUT}"
echo " Revise los .txt, abra los .html y adjunte las imagenes a la memoria."
echo "============================================================"
