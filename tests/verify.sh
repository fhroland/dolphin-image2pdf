#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT

fake_bin="$test_root/fake-bin"
fake_home="$test_root/home"
fake_data="$test_root/data"
fake_output="$test_root/output"
mkdir -p "$fake_bin" "$fake_home" "$fake_data" "$fake_output"

for command_name in kdialog dolphin kbuildsycoca6; do
    printf '#!/usr/bin/env bash\nexit 0\n' >"$fake_bin/$command_name"
    chmod 0755 "$fake_bin/$command_name"
done

cat >"$fake_bin/kdialog" <<'EOF'
#!/usr/bin/env bash
if [[ " $* " == *" --getsavefilename "* ]]; then
    printf '%s\n' "$TEST_SAVE_PATH"
fi
exit 0
EOF
chmod 0755 "$fake_bin/kdialog"

cat >"$fake_bin/img2pdf" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
output=""
inputs=()
while (($#)); do
    case "$1" in
        -o|--output)
            output=$2
            shift 2
            ;;
        *)
            inputs+=("$1")
            shift
            ;;
    esac
done
[[ -n "$output" ]]
printf '%s\n' "${inputs[@]}" >"$output"
EOF
chmod 0755 "$fake_bin/img2pdf"

export HOME="$fake_home"
export XDG_DATA_HOME="$fake_data"
export XDG_BIN_HOME="$fake_home/.local/bin"
export PATH="$fake_bin:$PATH"

bash -n "$project_dir/install.sh"
bash -n "$project_dir/uninstall.sh"
bash -n "$project_dir/src/dolphin-image2pdf"

"$project_dir/install.sh"

installed_helper="$XDG_BIN_HOME/dolphin-image2pdf"
installed_desktop="$XDG_DATA_HOME/kio/servicemenus/org.fhroland.dolphin-image2pdf.desktop"

[[ -x "$installed_helper" ]]
[[ -x "$installed_desktop" ]]
! grep -q '@EXEC_PATH@' "$installed_desktop"
grep -Fq "Exec=\"$installed_helper\" combine %F" "$installed_desktop"

image_one="$fake_output/one image.jpg"
image_two="$fake_output/two image.png"
image_special="$fake_output/cash \$ and [brackets].jpg"
: >"$image_one"
: >"$image_two"
: >"$image_special"

"$installed_helper" separate "$image_one" "$image_two" "$image_special"
[[ -f "$fake_output/one image.pdf" ]]
[[ -f "$fake_output/two image.pdf" ]]
[[ -f "$fake_output/cash \$ and [brackets].pdf" ]]

printf 'do not overwrite\n' >"$fake_output/one image.pdf"
"$installed_helper" separate "$image_one"
grep -Fxq 'do not overwrite' "$fake_output/one image.pdf"

combined="$fake_output/combined document.pdf"
export TEST_SAVE_PATH="$combined"
"$installed_helper" combine "$image_one" "$image_two"
[[ -f "$combined" ]]
mapfile -t combined_inputs <"$combined"
[[ "${combined_inputs[0]}" == "$image_one" ]]
[[ "${combined_inputs[1]}" == "$image_two" ]]

"$project_dir/uninstall.sh"
[[ ! -e "$installed_helper" ]]
[[ ! -e "$installed_desktop" ]]

printf 'All tests passed.\n'
