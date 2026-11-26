#!/usr/bin/env bash
# Verify SHA-256 checksums for every tracked file except this manifest.

set -u

CHECKSUM_FILE="checksums.txt"
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

if ! cd "$SCRIPT_DIR"; then
    echo "[ERROR] Cannot access the repository directory." >&2
    exit 1
fi

if [ ! -f "$CHECKSUM_FILE" ]; then
    echo "[ERROR] $CHECKSUM_FILE not found." >&2
    exit 1
fi

if ! command -v git >/dev/null 2>&1 || ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "[ERROR] Verification requires a Git working tree to check manifest coverage." >&2
    exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
    hash_file() {
        sha256sum "$1" | awk '{ print $1 }'
    }
elif command -v shasum >/dev/null 2>&1; then
    hash_file() {
        shasum -a 256 "$1" | awk '{ print $1 }'
    }
else
    echo "[ERROR] No SHA-256 utility found; install coreutils or shasum." >&2
    exit 1
fi

entry_count=0
failed=0
while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
        ""|\#*) continue ;;
    esac

    if [[ ! "$line" =~ ^([[:xdigit:]]{64})\ \ (.+)$ ]]; then
        echo "[FAILED] Invalid checksum entry: $line" >&2
        failed=1
        continue
    fi

    expected_hash="${BASH_REMATCH[1]}"
    file="${BASH_REMATCH[2]}"

    if [ "$file" = "$CHECKSUM_FILE" ]; then
        echo "[FAILED] Manifest cannot verify itself: $file" >&2
        failed=1
        continue
    fi

    case "$file" in
        /*|../*|*/../*|*/..|./*)
            echo "[FAILED] Manifest path escapes the repository: $file" >&2
            failed=1
            continue
            ;;
    esac

    if [ ! -f "$file" ] || [ -L "$file" ]; then
        echo "[FAILED] Missing file: $file" >&2
        failed=1
        continue
    fi

    matches="$(awk -v path="$file" 'substr($0, 67) == path { count++ } END { print count+0 }' "$CHECKSUM_FILE")"
    if [ "$matches" -ne 1 ]; then
        echo "[FAILED] Manifest contains $matches entries for $file; expected exactly one." >&2
        failed=1
        continue
    fi

    actual_hash="$(hash_file "$file")"
    if [ "$actual_hash" != "$expected_hash" ]; then
        echo "[FAILED] Checksum mismatch: $file" >&2
        failed=1
        continue
    fi

    if git ls-files --error-unmatch -- "$file" >/dev/null 2>&1; then
        entry_count=$((entry_count + 1))
    fi
done < "$CHECKSUM_FILE"

expected_count="$(git ls-files | awk -v manifest="$CHECKSUM_FILE" '$0 != manifest { count++ } END { print count+0 }')"

while IFS= read -r file; do
    [ "$file" = "$CHECKSUM_FILE" ] && continue
    matches="$(awk -v path="$file" 'substr($0, 67) == path { count++ } END { print count+0 }' "$CHECKSUM_FILE")"
    if [ "$matches" -ne 1 ]; then
        echo "[FAILED] Tracked file is missing from the manifest or duplicated: $file" >&2
        failed=1
    fi
done < <(git ls-files)

if [ "$failed" -ne 0 ] || [ "$entry_count" -ne "$expected_count" ]; then
    echo "[FAILED] Integrity check failed ($entry_count/$expected_count tracked files verified)." >&2
    exit 1
fi

echo "Integrity checks passed: $entry_count/$expected_count tracked files verified."
echo "Note: checksums.txt is not self-verifying. Its authenticity must be established through a trusted distribution channel."
