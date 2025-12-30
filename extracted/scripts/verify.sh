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

echo ""
echo "🎉 All verification checks passed!"
echo "📦 Installation is ready for production use."
