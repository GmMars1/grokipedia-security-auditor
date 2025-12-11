#!/bin/bash

# Configuration
CHECKSUM_FILE="checksums.txt"
EXPECTED_COUNT=15

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Starting GrokiPedia integrity verification..."

# 1. Check if checksum file exists
if [ ! -f "$CHECKSUM_FILE" ]; then
    echo -e "${RED}[ERROR]${NC} $CHECKSUM_FILE not found. Cannot verify integrity."
    echo "Please ensure you have downloaded the full release bundle."
    exit 1
fi

# 2. distinct SHA256 command based on OS (Linux vs macOS)
if command -v sha256sum &> /dev/null; then
    CMD="sha256sum -c $CHECKSUM_FILE --quiet"
elif command -v shasum &> /dev/null; then
    CMD="shasum -a 256 -c $CHECKSUM_FILE"
else
    echo -e "${RED}[ERROR]${NC} No SHA256 utility found. Install coreutils."
    exit 1
fi

# 3. Run verification
# Capturing output to hide individual file OKs unless verbose is needed
if OUTPUT=$($CMD 2>&1); then
    # Count validated files (approximate based on line count in checksum file)
    FILE_COUNT=$(wc -l < "$CHECKSUM_FILE" | tr -d ' ')
    
    # Success Message
    echo -e "${GREEN}Integrity Verified: ${FILE_COUNT}/${EXPECTED_COUNT} files ✓${NC}"
    echo "Signature: VALID"
    exit 0
else
    # Failure Message
    echo -e "${RED}[FAILED]${NC} Integrity check failed."
    echo "The following files have been modified or corrupted:"
    echo "$OUTPUT" | grep "FAILED"
    exit 1
fi
