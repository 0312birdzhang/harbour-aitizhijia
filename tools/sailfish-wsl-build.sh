#!/usr/bin/env bash
# Reusable Windows Git Bash -> WSL -> Sailfish SDK RPM builder.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: tools/sailfish-wsl-build.sh [PROJECT_DIR]

Environment variables:
  WSL_DIST       WSL distribution              (default: Ubuntu-22.04)
  SDK_ROOT       Sailfish SDK root in WSL       (default: /srv/sailfishos/sdks/sfossdk)
  SDK_USER       SDK build user                 (default: current WSL user)
  SDK_ENV        SDK environment file           (default: ~/.hadk.env)
  SFOS_TARGET    mb2 target                     (default: SailfishOS-latest-aarch64)
  WSL_BUILD_ROOT source staging directory       (default: ~/code)
  BUILD_TIMEOUT  build timeout in seconds       (default: 900)
  RPM_OUTPUT     Windows-side RPM output folder (default: PROJECT_DIR/RPMS)

Run this script from Windows Git Bash. PROJECT_DIR defaults to the repository
root containing this script.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

command -v wsl.exe >/dev/null 2>&1 || {
    echo "Error: wsl.exe was not found; run this script from Windows Git Bash." >&2
    exit 1
}

default_project="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -W)"
project_win="${1:-$default_project}"
project_win="$(cd "$project_win" && pwd -W)"
project_name="$(basename "$project_win")"

wsl_dist="${WSL_DIST:-Ubuntu-22.04}"
sdk_root="${SDK_ROOT:-/srv/sailfishos/sdks/sfossdk}"
sdk_user="${SDK_USER:-$(wsl.exe -d "$wsl_dist" -- id -un | tr -d '\r')}"
sdk_env="${SDK_ENV:-/home/$sdk_user/.hadk.env}"
sfos_target="${SFOS_TARGET:-SailfishOS-latest-aarch64}"
wsl_build_root="${WSL_BUILD_ROOT:-/home/$sdk_user/code}"
build_timeout="${BUILD_TIMEOUT:-900}"
rpm_output="${RPM_OUTPUT:-$project_win/RPMS}"

project_wsl="$(wsl.exe -d "$wsl_dist" -- wslpath -a "$project_win" | tr -d '\r')"
wsl_project="$wsl_build_root/$project_name"

if [[ "$wsl_build_root" == "/" || "$wsl_build_root" == "/home" ||
      "$wsl_project" != "$wsl_build_root/"* ]]; then
    echo "Error: unsafe rsync --delete destination: $wsl_project" >&2
    exit 1
fi

printf -v q_project_wsl '%q' "$project_wsl"
printf -v q_build_root '%q' "$wsl_build_root"
printf -v q_project_name '%q' "$project_name"
printf -v q_wsl_project '%q' "$wsl_project"
printf -v q_sdk_root '%q' "$sdk_root"
printf -v q_sdk_user '%q' "$sdk_user"
printf -v q_sdk_env '%q' "$sdk_env"
printf -v q_target '%q' "$sfos_target"
printf -v q_timeout '%q' "$build_timeout"

echo "== [1/4] Sync source to $wsl_dist:$wsl_project =="
wsl.exe -d "$wsl_dist" -- bash -lc "mkdir -p $q_build_root && rsync -a --delete \
  --exclude=.git --exclude=RPMS --exclude=installroot --exclude=Makefile \
  --exclude='*.o' --exclude='*.so' --exclude='moc_*.cpp' \
  --exclude='qrc_*.cpp' --exclude='*.pro.user' \
  $q_project_wsl/ $q_build_root/$q_project_name/"

echo "== [2/4] Build target $sfos_target =="
inner="source $q_sdk_env && cd $q_wsl_project && mb2 -t $q_target build"
printf -v q_inner '%q' "$inner"
wsl.exe -d "$wsl_dist" -u root -- bash -lc \
    "timeout $q_timeout $q_sdk_root/sdk-chroot -u $q_sdk_user -m all -- bash -lc $q_inner"

echo "== [3/4] Export RPM files to $rpm_output =="
mkdir -p "$rpm_output"
rpm_output_wsl="$(wsl.exe -d "$wsl_dist" -- wslpath -a "$rpm_output" | tr -d '\r')"
printf -v q_rpm_output_wsl '%q' "$rpm_output_wsl"
wsl.exe -d "$wsl_dist" -- bash -lc \
    "mkdir -p $q_rpm_output_wsl && cp -f $q_wsl_project/RPMS/*.rpm $q_rpm_output_wsl/"

echo "== [4/4] Result =="
shopt -s nullglob
rpm_files=("$rpm_output"/*.rpm)
if (( ${#rpm_files[@]} == 0 )); then
    echo "Error: the build completed but no RPM was exported to $rpm_output" >&2
    exit 1
fi
printf '%s\n' "${rpm_files[@]}"
