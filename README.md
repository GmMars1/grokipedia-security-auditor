<!-- Keywords: security, auditor, verification, integrity, checksum, validation, authentication, framework, solidity, react, python, vulnerability, scanning, compliance, security-auditor, framework-config, security-checks, installation, download, release, integrity-verification -->

# GrokiPedia Security Auditor

A comprehensive security auditing framework with domain trust verification and framework-specific analysis.

## Quick Start

```bash
# Clone repository
git clone https://github.com/GmMars1/grokipedia-security-auditor.git
cd grokipedia-security-auditor

# Verify integrity
chmod +x verify.sh && ./verify.sh  # 5/5 files ✓
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


## HVAC Receptionist Flow Assets

This repository now includes structured receptionist flow artifacts for an HVAC service assistant:

- `config/hvac-receptionist-policy.yaml` - identity, tone, business rules, emergency criteria, and conversation phases
- `schemas/hvac-tools.schema.json` - `check_availability` and `create_booking` contracts with required fields and triggers
- `src/hvac_receptionist_engine.py` - flow helpers for triage, emergency detection, service-area checks, scheduling constraints, and guardrail enforcement
- `tests/test_hvac_receptionist_engine.py` - tests for normal booking readiness, emergency escalation logic, out-of-area checks, after-hours fee behavior, and guardrails
