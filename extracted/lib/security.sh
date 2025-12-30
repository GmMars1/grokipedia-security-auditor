#!/bin/bash
# GrokiPedia Security Auditor - Security Analysis Library

analyze_security_posture() {
    local url="$1"
    local output_dir="$2"
    
    log_info "Performing advanced security analysis..."
    check_csp "${url}" > "${output_dir}/csp_analysis.txt" 2>&1
    check_cors "${url}" > "${output_dir}/cors_analysis.txt" 2>&1
    check_authentication "${url}" > "${output_dir}/auth_analysis.txt" 2>&1
    check_data_exposure "${url}" > "${output_dir}/data_exposure.txt" 2>&1
}

check_csp() {
    local url="$1"
    log_info "Analyzing Content Security Policy..."
    local csp_header=$(curl -sI -L "$url" | grep -i "content-security-policy" | head -1)
    
    if [[ -n "$csp_header" ]]; then
        echo "CSP Header Present: $csp_header"
        echo "CSP Strength: STRONG"
    else
        echo "CSP Header: MISSING"
        echo "CSP Strength: NONE"
        echo "Recommendation: Implement Content-Security-Policy header"
    fi
}

check_cors() {
    local url="$1"
    log_info "Checking CORS configuration..."
    local cors_header=$(curl -sI -L "$url" | grep -i "access-control-allow-origin" | head -1)
    
    if [[ -n "$cors_header" ]]; then
        echo "CORS Header: $cors_header"
        [[ "$cors_header" == *"*"* ]] && echo "CORS Risk: HIGH (Wildcard allowed)" || echo "CORS Risk: LOW"
    else
        echo "CORS Configuration: DEFAULT"
        echo "CORS Risk: LOW"
    fi
}

check_authentication() {
    local url="$1"
    log_info "Analyzing authentication mechanisms..."
    local login_forms=$(curl -s "$url" | grep -ci "login\|signin\|password" || echo "0")
    
    if [[ "$login_forms" -gt 0 ]]; then
        echo "Authentication Forms Found: $login_forms"
        echo "Recommendation: Ensure forms use HTTPS and proper validation"
    else
        echo "Authentication Forms: NONE DETECTED"
    fi
}

check_data_exposure() {
    local url="$1"
    log_info "Checking for data exposure risks..."
    local api_endpoints=$(curl -s "$url" | grep -o '/api/[^"]*' | wc -l || echo "0")
    
    if [[ "$api_endpoints" -gt 0 ]]; then
        echo "API Endpoints Found: $api_endpoints"
        echo "Recommendation: Verify API endpoints are properly secured"
    else
        echo "API Endpoints: NONE DETECTED"
    fi
}
