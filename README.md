<!-- Keywords: security, auditor, verification, integrity, checksum, validation, authentication, framework, solidity, react, python, vulnerability, scanning, compliance, security-auditor, framework-config, security-checks, installation, download, release, integrity-verification -->

# GrokiPedia Security Auditor

A comprehensive security auditing framework with domain trust verification and framework-specific analysis.

## Quick Start

```bash
# Clone repository
git clone https://github.com/GmMars1/grokipedia-security-auditor.git
cd grokipedia-security-auditor

# Verify integrity (run from a Git working tree)
./verify.sh
```

## Repository Structure

- `verify.sh` - Integrity verification script
- `config/` - Configuration files for frameworks and domain trust
- `config.yaml` - Main configuration file
- `checksums.txt` - SHA256 checksums for verification

## Features

- Domain trust verification (42 trusted / 14 flagged domains)
- Framework-specific security checks (Solidity, React, Python)
- Integrity verification with SHA256 checksums
- Comprehensive security scoring system

The checksum manifest covers every tracked file except `checksums.txt` itself.
It detects accidental or unauthorized file changes only when the manifest is
trusted; the manifest is not signed and cannot authenticate itself. Obtain the
manifest through a trusted distribution channel before relying on it.
