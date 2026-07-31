#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
bin_home=${XDG_BIN_HOME:-"$HOME/.local/bin"}
desktop_file="$data_home/kio/servicemenus/org.fhroland.dolphin-image2pdf.desktop"
helper_file="$bin_home/dolphin-image2pdf"

rm -f -- "$desktop_file" "$helper_file"

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 >/dev/null 2>&1 || true
fi

printf 'Dolphin Image2PDF was uninstalled.\n'
