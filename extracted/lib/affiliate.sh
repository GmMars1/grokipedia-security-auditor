#!/bin/bash
# GrokiPedia Security Auditor - Affiliate Management Library

readonly WHOP_API_KEY="${WHOP_API_KEY:-}"
readonly AFFILIATE_RATE=0.20
readonly PRODUCT_PRICE=97

handle_affiliate() {
    case "${1:-}" in
        "--generate-link")
            generate_affiliate_link
            ;;
        "--track-sale")
            shift
            track_sale "$@"
            ;;
        "--dashboard")
            show_affiliate_dashboard
            ;;
        *)
            echo "Unknown affiliate command: ${1:-}"
            echo "Available: --generate-link, --track-sale, --dashboard"
            exit 1
            ;;
    esac
}

generate_affiliate_link() {
    log_info "Generating affiliate link..."
    
    if [[ -z "$WHOP_API_KEY" ]]; then
        log_error "WHOP_API_KEY not set. Cannot generate affiliate link."
        return 1
    fi
    
    local affiliate_id=$(openssl rand -hex 16)
    local affiliate_link="https://whop.com/grokipedia-auditor?ref=${affiliate_id}"
    
    echo "$affiliate_link" > "${SCRIPT_DIR}/config/affiliate_link.txt"
    echo "$affiliate_id" > "${SCRIPT_DIR}/config/affiliate_id.txt"
    
    log_success "Affiliate link generated: $affiliate_link"
    echo "Share this link: $affiliate_link"
}

track_sale() {
    local client_email="$1"
    log_info "Tracking sale for client: $client_email"
    echo "$(date): Sale tracked for $client_email" >> "${SCRIPT_DIR}/config/affiliate_sales.txt"
    log_success "Sale tracked successfully"
}

show_affiliate_dashboard() {
    log_info "Loading affiliate dashboard..."
    
    echo "GrokiPedia Security Auditor - Affiliate Dashboard"
    echo "================================================"
    echo "Commission Rate: ${AFFILIATE_RATE}%"
    echo "Product Price: $${PRODUCT_PRICE}/month"
    echo "Commission per sale: $${PRODUCT_PRICE} * ${AFFILIATE_RATE} = $($(echo "$PRODUCT_PRICE * $AFFILIATE_RATE" | bc -l))"
    echo ""
    
    if [[ -f "${SCRIPT_DIR}/config/affiliate_sales.txt" ]]; then
        echo "Sales History:"
        cat "${SCRIPT_DIR}/config/affiliate_sales.txt"
    else
        echo "No sales recorded yet."
    fi
}
