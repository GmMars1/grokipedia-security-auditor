# Download latest release
curl -L -o GrokiPedia-Security-Auditor-v2.3.1-solidity.zip https://github.com/Gmmars1/grokipedia-security-auditor/releases/download/v2.3.1-solidity/GrokiPedia-Security-Auditor-v2.3.1-solidity.zip

# Verify integrity
chmod +x verify.sh && ./verify.sh  # 15/15 files ✓

# Install & run
unzip GrokiPedia-Security-Auditor-v2.3.1-solidity.zip
cd GrokiPedia-Security-Auditor-v2.3.1
pip install -r requirements.txt
./grokipedia-auditor content-audit https://example.com --report audit.json
