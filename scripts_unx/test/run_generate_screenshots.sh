#!/usr/bin/env bash
set -euo pipefail

# Optional: set DEVICE_ID to force a specific device.
# Example:
# DEVICE_ID=emulator-5554 ./scripts_unx/test/run_generate_screenshots.sh
DEVICE_ID="${DEVICE_ID:-}"

log() {
  printf '[%s] %s
' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*"
}

log_error() {
  log "$*" >&2
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "${SCRIPT_DIR}/../../example" >/dev/null
OUTPUT_DIR="${SCREENSHOT_OUTPUT_DIR:-screenshots_patrol}"
mkdir -p "${OUTPUT_DIR}"
find "${OUTPUT_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
MARKER_FILE="$(mktemp)"
cleanup_marker() {
  rm -f "${MARKER_FILE}"
}
trap cleanup_marker EXIT

select_preferred_flutter_device_id() {
  local devices_json
  if [[ -n "${FLUTTER_DEVICES_JSON:-}" ]]; then
    devices_json="${FLUTTER_DEVICES_JSON}"
  else
    devices_json="$(flutter --no-version-check --suppress-analytics devices --machine)"
  fi
  FLUTTER_DEVICES_JSON="${devices_json}" AUTO_TEST_DEVICE_PLATFORM="${AUTO_TEST_DEVICE_PLATFORM:-android}" python3 - <<'PY'
import json
import os

devices = json.loads(os.environ.get('FLUTTER_DEVICES_JSON', '[]') or '[]')
preferred = os.environ.get('AUTO_TEST_DEVICE_PLATFORM', 'android').strip().lower()

def haystack(device):
    fields = (
        'id',
        'name',
        'targetPlatform',
        'targetPlatformDisplayName',
        'platform',
        'platformType',
        'category',
    )
    return ' '.join(str(device.get(field) or '') for field in fields).lower()

def is_android(device):
    text = haystack(device)
    return 'android' in text or str(device.get('id') or '').startswith('emulator-')

def is_ios(device):
    text = haystack(device)
    name = str(device.get('name') or '')
    return 'ios' in text or name.startswith(('iPhone', 'iPad'))

def is_web(device):
    text = haystack(device)
    return 'web' in text or 'chrome' in text

def is_emulator(device):
    text = haystack(device)
    return bool(device.get('emulator')) or str(device.get('id') or '').startswith('emulator-') or 'simulator' in text

def score(device):
    text = haystack(device)
    if preferred in ('android', 'emulator') and is_android(device):
        return 0 if is_emulator(device) else 1
    if preferred in ('ios', 'iphone', 'ipad', 'simulator') and is_ios(device):
        return 0 if is_emulator(device) else 1
    if preferred and preferred not in ('android', 'emulator', 'ios', 'iphone', 'ipad', 'simulator') and preferred in text:
        return 0
    if is_android(device):
        return 10 if is_emulator(device) else 11
    if is_ios(device):
        return 20 if is_emulator(device) else 21
    if is_web(device):
        return 90
    return 50

eligible = []
for index, device in enumerate(devices):
    device_id = str(device.get('id') or '').strip()
    if not device_id:
        continue
    eligible.append((score(device), index, device_id))

if eligible:
    eligible.sort()
    print(eligible[0][2])
PY
}

resolve_android_package_name() {
  python3 - <<'PY'
from pathlib import Path
import re

for relative in ('android/app/build.gradle.kts', 'android/app/build.gradle'):
    path = Path(relative)
    if not path.exists():
        continue
    text = path.read_text(errors='ignore')
    for pattern in (
        r'\bapplicationId\s*=\s*["\']([^"\']+)["\']',
        r'\bapplicationId\s+["\']([^"\']+)["\']',
        r'\bnamespace\s*=\s*["\']([^"\']+)["\']',
        r'\bnamespace\s+["\']([^"\']+)["\']',
    ):
        match = re.search(pattern, text)
        if match:
            print(match.group(1))
            raise SystemExit(0)
PY
}

resolve_adb() {
  if command -v adb >/dev/null 2>&1; then
    command -v adb
  elif [[ -n "${ANDROID_HOME:-}" && -x "${ANDROID_HOME}/platform-tools/adb" ]]; then
    printf '%s\n' "${ANDROID_HOME}/platform-tools/adb"
  elif [[ -n "${ANDROID_SDK_ROOT:-}" && -x "${ANDROID_SDK_ROOT}/platform-tools/adb" ]]; then
    printf '%s\n' "${ANDROID_SDK_ROOT}/platform-tools/adb"
  fi
}

is_android_device() {
  local adb_bin
  adb_bin="$(resolve_adb || true)"
  [[ -n "${adb_bin}" && -n "${DEVICE_ID}" ]] &&
    "${adb_bin}" -s "${DEVICE_ID}" shell getprop ro.build.version.sdk >/dev/null 2>&1
}

collect_android_patrol_screenshots() {
  local package_name
  package_name="$(resolve_android_package_name || true)"
  if [[ -z "${package_name}" ]]; then
    return 0
  fi

  local adb_bin
  adb_bin="$(resolve_adb || true)"
  if [[ -z "${adb_bin}" ]]; then
    return 0
  fi

  local -a adb_device_args=()
  if [[ -n "${DEVICE_ID}" ]]; then
    adb_device_args=(-s "${DEVICE_ID}")
  fi

  local external_dir="/sdcard/Android/media/${package_name}/patrol_screenshots"
  if "${adb_bin}" "${adb_device_args[@]}" shell "[ -d '${external_dir}' ]" >/dev/null 2>&1; then
    local before_count
    before_count="$(find "${OUTPUT_DIR}" -type f | wc -l | tr -d ' ')"
    if "${adb_bin}" "${adb_device_args[@]}" pull "${external_dir}/." "${OUTPUT_DIR}/" >/dev/null 2>&1; then
      local after_count
      after_count="$(find "${OUTPUT_DIR}" -type f | wc -l | tr -d ' ')"
      local pulled=$((after_count - before_count))
      if (( pulled > 0 )); then
        log "Collected ${pulled} Android external Patrol screenshot file(s)."
        copied=$((copied + pulled))
        return 0
      fi
    fi
  fi

  if ! "${adb_bin}" "${adb_device_args[@]}" shell run-as "${package_name}" sh -c 'pwd' >/dev/null 2>&1; then
    log "Skipping Android sandbox screenshot collection for ${package_name} (run-as unavailable)."
    return 0
  fi

  local file_list
  file_list="$("${adb_bin}" "${adb_device_args[@]}" shell run-as "${package_name}" sh -c 'find cache files code_cache -type f -path "*/patrol_screenshots/*" 2>/dev/null' 2>/dev/null || true)"
  local copied_android=0
  while IFS= read -r device_file; do
    [[ -n "${device_file}" ]] || continue
    local base_name
    base_name="$(basename "${device_file}")"
    if "${adb_bin}" "${adb_device_args[@]}" exec-out run-as "${package_name}" cat "${device_file}" > "${OUTPUT_DIR}/${base_name}"; then
      copied_android=$((copied_android + 1))
    else
      rm -f "${OUTPUT_DIR}/${base_name}"
    fi
  done <<< "${file_list}"

  if (( copied_android > 0 )); then
    log "Collected ${copied_android} Android sandboxed Patrol screenshot file(s)."
    copied=$((copied + copied_android))
  fi
}

PATROL_ARGS=(test --target=integration_test/screenshot_patrol_test_generated_test.dart --verbose)
if [[ -z "${DEVICE_ID}" ]]; then
  DEVICE_ID="$(select_preferred_flutter_device_id)"
fi
if [[ -n "${DEVICE_ID}" ]]; then
  log "Using Patrol device id: ${DEVICE_ID}"
  PATROL_ARGS+=(--device "${DEVICE_ID}")
fi
SCREENSHOT_DART_DEFINE="${PWD}/${OUTPUT_DIR}"
if is_android_device; then
  package_name="$(resolve_android_package_name || true)"
  adb_bin="$(resolve_adb || true)"
  if [[ -n "${package_name}" && -n "${adb_bin}" ]]; then
    SCREENSHOT_DART_DEFINE="/sdcard/Android/media/${package_name}/patrol_screenshots"
    "${adb_bin}" -s "${DEVICE_ID}" shell "rm -rf '${SCREENSHOT_DART_DEFINE}' && mkdir -p '${SCREENSHOT_DART_DEFINE}'" >/dev/null 2>&1 || true
  fi
fi
PATROL_ARGS+=(--dart-define "PATROL_SCREENSHOT_DIR=${SCREENSHOT_DART_DEFINE}")

patrol "${PATROL_ARGS[@]}"

copied=0
collect_android_patrol_screenshots
if ! is_android_device; then
  SEARCH_ROOTS=()
  if [[ -n "${DEVICE_ID}" && -d "${HOME}/Library/Developer/CoreSimulator/Devices/${DEVICE_ID}" ]]; then
    SEARCH_ROOTS+=("${HOME}/Library/Developer/CoreSimulator/Devices/${DEVICE_ID}")
  else
    SEARCH_ROOTS+=("${HOME}/Library/Developer/CoreSimulator/Devices")
  fi
  SEARCH_ROOTS+=("${HOME}/Library/Containers")
  for root in "${SEARCH_ROOTS[@]}"; do
    [[ -d "${root}" ]] || continue
    while IFS= read -r -d '' file; do
      cp "${file}" "${OUTPUT_DIR}/$(basename "${file}")"
      copied=$((copied + 1))
    done < <(find "${root}" -type f -path "*/patrol_screenshots/*" -newer "${MARKER_FILE}" -print0 2>/dev/null || true)
  done
fi
if (( copied > 0 )); then
  log "Collected ${copied} sandboxed Patrol screenshot file(s)."
fi

log "Screenshot folder contents (${PWD}/${OUTPUT_DIR}):"
ls -lah "${OUTPUT_DIR}"

popd >/dev/null
