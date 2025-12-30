# GrokiPedia Security Auditor - Usage Guide

## Quick Start

1. **Installation**
   ```bash
   curl -sL https://github.com/Gmmars1/grokipedia-security-auditor/releases/latest/download/deploy.sh | bash -s yourdomain.com
   ```

2. **Run Security Audit**
   ```bash
   grokipedia-auditor audit https://example.com
   ```

3. **Generate Affiliate Link**
   ```bash
   grokipedia-auditor affiliate --generate-link
   ```

## Commands

### Security Audit
```bash
grokipedia-auditor audit <url>
```
Performs comprehensive security analysis including:
- SSL/TLS certificate validation
- Security headers analysis
- Dependency vulnerability scanning
- Common security misconfigurations

### Affiliate Management
```bash
grokipedia-auditor affiliate --generate-link    # Generate affiliate link
grokipedia-auditor affiliate --dashboard        # Show affiliate dashboard
grokipedia-auditor affiliate --track-sale <email> # Track a sale
```

### Deployment
```bash
grokipedia-auditor deploy <domain>
```
Deploys the auditor to production with:
- Nginx configuration
- SSL certificate setup
- Systemd service
- Health monitoring

## Configuration

Edit `config/settings.conf` to customize:
- API keys
- Audit settings
- Notification preferences
- Affiliate settings

## Reports

Audit reports are saved to `reports/YYYYMMDD_HHMMSS/`:
- `ssl_report.txt` - SSL/TLS analysis
- `headers_report.txt` - Security headers
- `dependencies_report.txt` - Dependency analysis
- `vulnerabilities_report.txt` - Vulnerability scan
- `audit_summary.txt` - Executive summary
