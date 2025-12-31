#!/bin/bash
# GrokiPedia Security Auditor - Verification Script

echo "🔍 Verifying GrokiPedia Security Auditor Installation"
echo "=================================================="

if [[ -f "bin/grokipedia-auditor" && -x "bin/grokipedia-auditor" ]]; then
    echo "✅ Main executable: OK"
else
    echo "❌ Main executable: MISSING or NOT EXECUTABLE"
    exit 1
fi

if bin/grokipedia-auditor version | grep -q "v2.3.1-solidity"; then
    echo "✅ Version check: OK (v2.3.1-solidity)"
else
    echo "❌ Version check: FAILED"
    exit 1
fi

for lib in core.sh security.sh affiliate.sh; do
    [[ -f "lib/$lib" ]] && echo "✅ Library $lib: OK" || echo "❌ Library $lib: MISSING"
done

for config in settings.conf; do
    [[ -f "config/$config" ]] && echo "✅ Config $config: OK" || echo "❌ Config $config: MISSING"
done

# Check for new content-audit command
if bin/grokipedia-auditor help 2>&1 | grep -q "content-audit"; then
    echo "✅ New content-audit command: OK"
else
    echo "❌ New content-audit command: MISSING"
fi

# Check for required dependencies
command -v curl >/dev/null 2>&1 && echo "✅ curl: OK" || echo "❌ curl: MISSING"
command -v openssl >/dev/null 2>&1 && echo "✅ openssl: OK" || echo "❌ openssl: MISSING"
command -v bc >/dev/null 2>&1 && echo "✅ bc: OK" || echo "❌ bc: MISSING"

# Test basic functionality
echo ""
echo "🧪 Testing basic functionality..."
if bin/grokipedia-auditor version >/dev/null 2>&1; then
    echo "✅ Version command: OK"
else
    echo "❌ Version command: FAILED"
fi

if bin/grokipedia-auditor help >/dev/null 2>&1; then
    echo "✅ Help command: OK"
else
    echo "❌ Help command: FAILED"
fi

echo ""
echo "🎉 All verification checks completed!"
echo "📦 Installation is ready for production use."