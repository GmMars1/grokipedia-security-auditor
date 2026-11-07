# GrokiPedia Security Auditor

This repository contains domain trust and framework scoring configurations for
security review, plus a Bash script to check file integrity. The quick start
runs the integrity verifier. This checkout does not include a runnable scanner
or a scoring engine.

## Quick start: verify the checkout

Requirements: Git, Bash, and either `sha256sum` (GNU coreutils) or `shasum`
(with SHA-256 support). The commands below were tested on Linux. On macOS or
Windows, use an environment that provides these tools; those platforms were
not tested. On Windows, run the commands in a Bash environment such as WSL.

```bash
git clone https://github.com/GmMars1/grokipedia-security-auditor.git
cd grokipedia-security-auditor
bash verify.sh
```

Expected final line: `SHA-256 checksums match: 6/6 files.` If an entry is missing,
malformed, or mismatched, the command exits with an error. No build, package
installation, API key, or network request is needed after cloning.

The check compares six tracked files, including `verify.sh`, against the
bundled `checksums.txt`. It does not authenticate the publisher, verify a
digital signature, or protect against someone replacing both the files and
the manifest. Use a separately trusted source for the expected hashes when
checking provenance.

## Repository contents

- `verify.sh`: verifies the files listed in the checksum manifest.
- `checksums.txt`: SHA-256 manifest; it does not contain its own hash.
- `config.yaml`: main domain trust and scoring settings.
- `config/`: framework and domain trust configuration.
- `README`: file inventory.
