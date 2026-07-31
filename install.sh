#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
bin_home=${XDG_BIN_HOME:-"$HOME/.local/bin"}
service_dir="$data_home/kio/servicemenus"
helper_dest="$bin_home/dolphin-image2pdf"
desktop_dest="$service_dir/org.fhroland.dolphin-image2pdf.desktop"
helper_source="$project_dir/src/dolphin-image2pdf"
desktop_template="$project_dir/src/org.fhroland.dolphin-image2pdf.desktop.in"
legacy_desktop="$service_dir/image2pdf.desktop"

for required in install sed img2pdf kdialog; do
    if ! command -v "$required" >/dev/null 2>&1; then
        printf 'Error: required command not found: %s\n' "$required" >&2
        if [[ "$required" == "img2pdf" ]]; then
            printf 'Install the img2pdf package with your distribution package manager.\n' >&2
        fi
        exit 1
    fi
done

if [[ ! -f "$helper_source" || ! -f "$desktop_template" ]]; then
    printf 'Error: installation files are missing. Run install.sh from a complete checkout.\n' >&2
    exit 1
fi

install -d -m 0755 "$bin_home" "$service_dir"
install -m 0755 "$helper_source" "$helper_dest"

escaped_helper=${helper_dest//\\/\\\\}
escaped_helper=${escaped_helper//&/\\&}
escaped_helper=${escaped_helper//|/\\|}

temporary_desktop=$(mktemp "$service_dir/.dolphin-image2pdf.XXXXXX.desktop")
trap 'rm -f -- "$temporary_desktop"' EXIT
sed "s|@EXEC_PATH@|$escaped_helper|g" "$desktop_template" >"$temporary_desktop"
install -m 0755 "$temporary_desktop" "$desktop_dest"

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 >/dev/null 2>&1 || true
fi

printf 'Dolphin Image2PDF was installed successfully.\n'
printf 'Service menu: %s\n' "$desktop_dest"
printf 'Helper:       %s\n' "$helper_dest"

if [[ -e "$legacy_desktop" ]]; then
    printf '\nWarning: another Image2PDF service menu exists at:\n%s\n' "$legacy_desktop" >&2
    printf 'Disable or uninstall the old entry in Dolphin to avoid duplicate menu actions.\n' >&2
fi
