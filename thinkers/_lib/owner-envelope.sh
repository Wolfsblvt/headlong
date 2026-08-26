#!/usr/bin/env bash
# Compatibility source hook for installed and checkout-based thinkers.

_resident_cognition_lib="${RESIDENT_COGNITION_LIB:-}"
if [[ -z "$_resident_cognition_lib" ]]; then
    _resident_cognition_lib=$(command -v resident-cognition 2>/dev/null || true)
fi
if [[ -z "$_resident_cognition_lib" ]]; then
    _resident_owner_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    _resident_cognition_lib="$_resident_owner_dir/../../bin/resident-cognition"
    unset _resident_owner_dir
fi
[[ -f "$_resident_cognition_lib" ]] \
    || { printf 'resident cognition: library not found: %s\n' "$_resident_cognition_lib" >&2; return 1; }
# shellcheck disable=SC1090
source "$_resident_cognition_lib"
unset _resident_cognition_lib
