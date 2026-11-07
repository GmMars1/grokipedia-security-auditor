#!/bin/bash
set -eu
export LC_ALL=C

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

manifest=checksums.txt
expected=(verify.sh README.md README config/framework-v2.3.1.yaml config/domains-trust-v2.4.yaml config.yaml)
row_pattern='^[0-9a-f]{64}  (.+)$'
count=0

fail() {
    printf 'Integrity check failed: %s\n' "$1" >&2
    exit 1
}

[[ -f "$manifest" && -r "$manifest" ]] || fail "cannot read $manifest"
while IFS= read -r row || [[ -n "$row" ]]; do
    if [[ ! "$row" =~ $row_pattern ]]; then
        fail "malformed checksum entry at line $((count + 1))"
    fi
    if (( count >= ${#expected[@]} )) || [[ "${BASH_REMATCH[1]}" != "${expected[count]}" ]]; then
        fail "unexpected file entry at line $((count + 1))"
    fi
    count=$((count + 1))
done < "$manifest"
(( count == ${#expected[@]} )) || fail "manifest must list ${#expected[@]} files"

if command -v sha256sum >/dev/null 2>&1; then
    sha256sum --strict -c "$manifest" || fail "SHA-256 verification did not pass"
elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 -c "$manifest" || fail "SHA-256 verification did not pass"
else
    fail "install a SHA-256 utility (sha256sum or shasum)"
fi

printf 'SHA-256 checksums match: %s/%s files.\n' "$count" "${#expected[@]}"
