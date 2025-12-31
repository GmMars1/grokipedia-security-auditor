#!/bin/bash
# GrokiPedia Security Auditor - Security Analysis Library

# Enhanced security analysis functions
analyze_security_posture() {
    local url="$1"
    local output_dir="$2"
    
    log_info "Performing advanced security analysis..."
    check_csp "${url}" > "${output_dir}/csp_analysis.txt" 2>&1
    check_cors "${url}" > "${output_dir}/cors_analysis.txt" 2>&1
    check_authentication "${url}" > "${output_dir}/auth_analysis.txt" 2>&1
    check_data_exposure "${url}" > "${output_dir}/data_exposure.txt" 2>&1
    check_malware_indicators "${url}" > "${output_dir}/malware_indicators.txt" 2>&1
}

check_csp() {
    local url="$1"
    log_info "Analyzing Content Security Policy..."
    local csp_header=$(curl -sI -L "$url" 2>/dev/null | grep -i "content-security-policy" | head -1)
    
    if [[ -n "$csp_header" ]]; then
        echo "CSP Header Present: $csp_header"
        echo "CSP Strength: STRONG"
        if [[ "$csp_header" =~ "default-src 'none'" ]]; then
            echo "CSP Policy: Very Strict (Recommended)"
        elif [[ "$csp_header" =~ "default-src 'self'" ]]; then
            echo "CSP Policy: Moderate (Good baseline)"
        else
            echo "CSP Policy: Permissive (Consider tightening)"
        fi
    else
        echo "CSP Header: MISSING"
        echo "CSP Strength: NONE"
        echo "Recommendation: Implement Content-Security-Policy header"
        echo "Suggestion: Add 'Content-Security-Policy: default-src 'self'; script-src 'self'; object-src 'none'"
    fi
}

check_cors() {
    local url="$1"
    log_info "Checking CORS configuration..."
    local cors_header=$(curl -sI -L "$url" 2>/dev/null | grep -i "access-control-allow-origin" | head -1)
    
    if [[ -n "$cors_header" ]]; then
        echo "CORS Header: $cors_header"
        if [[ "$cors_header" == *"*" ]]; then
            echo "CORS Risk: HIGH (Wildcard allowed)"
            echo "Recommendation: Specify exact origins instead of wildcard"
        elif [[ "$cors_header" == *"null"* ]]; then
            echo "CORS Risk: MEDIUM (Null origin allowed)"
            echo "Recommendation: Avoid using null origin"
        else
            echo "CORS Risk: LOW (Specific origin)"
        fi
    else
        echo "CORS Configuration: DEFAULT (Safe for most cases)"
        echo "CORS Risk: LOW"
    fi
}

check_authentication() {
    local url="$1"
    log_info "Analyzing authentication mechanisms..."
    local login_forms=$(curl -s "$url" 2>/dev/null | grep -ci "login|signin|password|auth" || echo "0")
    
    if [[ "$login_forms" -gt 0 ]]; then
        echo "Authentication Forms Found: $login_forms"
        echo "Recommendation: Ensure forms use HTTPS and proper validation"
        # Check if login forms are using HTTPS
        if [[ "$url" =~ ^https:// ]]; then
            echo "Form Transport Security: HTTPS (Good)"
        else
            echo "Form Transport Security: HTTP (Vulnerable!)"
        fi
    else
        echo "Authentication Forms: NONE DETECTED"
    fi
}

check_data_exposure() {
    local url="$1"
    log_info "Checking for data exposure risks..."
    local api_endpoints=$(curl -s "$url" 2>/dev/null | grep -o '/api/[^"]*' | sort -u | wc -l || echo "0")
    local email_patterns=$(curl -s "$url" 2>/dev/null | grep -oE '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b' | sort -u | wc -l || echo "0")
    local phone_patterns=$(curl -s "$url" 2>/dev/null | grep -oE '\b(\+?[1-9]\d{1,14}|(\d{3})\s?\d{3}-\d{4}|\d{3}-\d{3}-\d{4})\b' | sort -u | wc -l || echo "0")
    
    if [[ "$api_endpoints" -gt 0 ]]; then
        echo "API Endpoints Found: $api_endpoints"
        echo "Recommendation: Verify API endpoints are properly secured"
    else
        echo "API Endpoints: NONE DETECTED"
    fi
    
    if [[ "$email_patterns" -gt 0 ]]; then
        echo "Potential email addresses exposed: $email_patterns"
        echo "Recommendation: Consider obfuscating email addresses"
    fi
    
    if [[ "$phone_patterns" -gt 0 ]]; then
        echo "Potential phone numbers exposed: $phone_patterns"
        echo "Recommendation: Consider obfuscating phone numbers"
    fi
}

# New function to check for potential malware indicators
check_malware_indicators() {
    local url="$1"
    log_info "Checking for potential malware indicators..."
    
    local content
    content=$(curl -s "$url" 2>/dev/null)
    
    echo "Malware Indicators Check:"
    
    # Check for suspicious JavaScript
    local suspicious_js=$(echo "$content" | grep -i -c "eval|document\.write|innerHTML|outerHTML|unescape|fromCharCode|execScript|Function|atob|btoa" || echo "0")
    echo "Suspicious JavaScript patterns: $suspicious_js"
    
    # Check for suspicious iframes
    local suspicious_iframes=$(echo "$content" | grep -i -c "iframe[^>]*src.*http" || echo "0")
    echo "External iframes: $suspicious_iframes"
    
    # Check for suspicious links
    local suspicious_links=$(echo "$content" | grep -o 'href=["'"'][^"'"']*["'"']' | grep -i -c "javascript:|vbscript:|data:text/html" || echo "0")
    echo "Suspicious links: $suspicious_links"
    
    # Check for known malicious domains in resources
    local malicious_domains=$(echo "$content" | grep -o 'https*://[^/"]*' | grep -i -E "(malware|phishing|scam|fake|counterfeit|pirate|pirated)" | wc -l || echo "0")
    echo "Potentially malicious domains: $malicious_domains"
    
    if [[ "$suspicious_js" -gt 0 ]] || [[ "$suspicious_iframes" -gt 0 ]] || [[ "$suspicious_links" -gt 0 ]]; then
        echo "ALERT: Potential security risks detected!"
    else
        echo "No obvious malware indicators found."
    fi
}

# Enhanced function to check for common vulnerabilities
check_common_vulnerabilities() {
    local url="$1"
    local output_dir="$2"
    
    log_info "Checking for common vulnerabilities..."
    
    # Check for SQL injection vulnerabilities
    check_sql_injection "$url" > "${output_dir}/sql_injection_check.txt" 2>&1
    
    # Check for XSS vulnerabilities
    check_xss_vulnerabilities "$url" > "${output_dir}/xss_check.txt" 2>&1
    
    # Check for security misconfigurations
    check_security_misconfigurations "$url" > "${output_dir}/misconfigurations.txt" 2>&1
}

# Check for potential SQL injection vulnerabilities
check_sql_injection() {
    local url="$1"
    echo "SQL Injection Check:"
    
    # This is a basic check - in a real implementation, you'd want more sophisticated testing
    if [[ "$url" =~ \?id=|\?page=|\?category=|\?search= ]]; then
        echo "URL has parameters that might be vulnerable to SQL injection"
        echo "Recommendation: Ensure proper input validation and parameterized queries"
    else
        echo "No obvious parameterized URLs detected"
    fi
}

# Check for potential XSS vulnerabilities
check_xss_vulnerabilities() {
    local url="$1"
    echo "XSS Vulnerability Check:"
    
    # Basic check for reflected XSS in URL parameters
    if [[ "$url" =~ \? ]]; then
        echo "URL has parameters that might be vulnerable to XSS"
        echo "Recommendation: Ensure proper output encoding and input validation"
    fi
    
    # Check for inline JavaScript in content
    local content
    content=$(curl -s "$url" 2>/dev/null)
    local inline_scripts=$(echo "$content" | grep -c "script[^>]*>" || echo "0")
    echo "Inline script tags found: $inline_scripts"
}

# Check for security misconfigurations
check_security_misconfigurations() {
    local url="$1"
    echo "Security Misconfiguration Check:"
    
    # Check server headers
    local server_header=$(curl -sI -L "$url" 2>/dev/null | grep -i "server:" | head -1)
    if [[ -n "$server_header" ]]; then
        echo "Server header: $server_header"
        echo "Recommendation: Consider removing or obfuscating server header"
    fi
    
    # Check for X-Powered-By header
    local powered_by=$(curl -sI -L "$url" 2>/dev/null | grep -i "x-powered-by" | head -1)
    if [[ -n "$powered_by" ]]; then
        echo "X-Powered-By header: $powered_by"
        echo "Recommendation: Remove X-Powered-By header to avoid revealing technology stack"
    fi
    
    # Check for robots.txt
    if curl -sf "${url}/robots.txt" >/dev/null 2>&1; then
        echo "Robots.txt: EXISTS"
        echo "Recommendation: Review robots.txt to ensure sensitive paths are not exposed"
    else
        echo "Robots.txt: NOT FOUND"
    fi
}