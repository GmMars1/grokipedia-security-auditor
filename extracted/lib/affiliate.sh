#!/bin/bash
# GrokiPedia Security Auditor - Affiliate Management Library

readonly WHOP_API_KEY="${WHOP_API_KEY:-}"
readonly AFFILIATE_RATE=0.20
readonly PRODUCT_PRICE=97

handle_affiliate() {
    case "${1:-}" in
        "--generate-link"|"--create-link")
            generate_affiliate_link
            ;;
        "--track-sale"|"--record-sale")
            shift
            track_sale "$@"
            ;;
        "--dashboard"|"--stats")
            show_affiliate_dashboard
            ;;
        "--payouts")
            show_payouts_info
            ;;
        *)
            echo "Unknown affiliate command: ${1:-}"
            echo "Available: --generate-link, --track-sale, --dashboard, --payouts"
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
    echo "Your affiliate ID: $affiliate_id"
}

track_sale() {
    local client_email="$1"
    local sale_amount="${2:-$PRODUCT_PRICE}"
    log_info "Tracking sale for client: $client_email"
    
    # Validate email format
    if [[ ! "$client_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        log_error "Invalid email format: $client_email"
        return 1
    fi
    
    # Create sales tracking file if it doesn't exist
    touch "${SCRIPT_DIR}/config/affiliate_sales.txt"
    
    # Record the sale with timestamp and amount
    echo "$(date -Iseconds): Sale - $client_email - Amount: $$sale_amount - Commission: $$(echo "$sale_amount * $AFFILIATE_RATE" | bc -l)" >> "${SCRIPT_DIR}/config/affiliate_sales.txt"
    
    log_success "Sale tracked successfully for $client_email (Amount: $$sale_amount)"
}

show_affiliate_dashboard() {
    log_info "Loading affiliate dashboard..."
    
    echo "GrokiPedia Security Auditor - Affiliate Dashboard"
    echo "================================================"
    echo "Commission Rate: ${AFFILIATE_RATE}%"
    echo "Product Price: $${PRODUCT_PRICE}/month"
    echo "Commission per sale: $$(echo "$PRODUCT_PRICE * $AFFILIATE_RATE" | bc -l)"
    echo ""
    
    if [[ -f "${SCRIPT_DIR}/config/affiliate_sales.txt" ]]; then
        echo "Sales History:"
        cat "${SCRIPT_DIR}/config/affiliate_sales.txt"
        
        # Calculate total sales and commissions
        local total_sales=$(grep -c "^" "${SCRIPT_DIR}/config/affiliate_sales.txt")
        local total_commission=$(awk -F'Commission: \\$' '{sum += $2} END {print sum+0}' "${SCRIPT_DIR}/config/affiliate_sales.txt")
        
        echo ""
        echo "SUMMARY:"
        echo "Total Sales: $total_sales"
        echo "Total Commission Earned: $$total_commission"
    else
        echo "No sales recorded yet."
    fi
}

show_payouts_info() {
    log_info "Loading payout information..."
    
    echo "GrokiPedia Security Auditor - Payout Information"
    echo "================================================"
    echo "Payout Schedule: Monthly"
    echo "Minimum Payout Threshold: $50"
    echo "Payment Method: Direct deposit or PayPal"
    echo ""
    
    if [[ -f "${SCRIPT_DIR}/config/affiliate_sales.txt" ]]; then
        # Calculate total commission
        local total_commission=$(awk -F'Commission: \\$' '{sum += $2} END {print sum+0}' "${SCRIPT_DIR}/config/affiliate_sales.txt")
        
        echo "Current Balance: $$total_commission"
        if (( $(echo "$total_commission >= 50" | bc -l) )); then
            echo "Status: Eligible for payout"
            echo "Next payout: $(date -d "$(date -d '+1 month' +%Y-%m-01) 15" '+%B %d, %Y')"
        else
            local remaining=$(echo "50 - $total_commission" | bc -l)
            echo "Status: Not eligible for payout (need $$remaining more)"
        fi
    else
        echo "Current Balance: $0.00"
        echo "Status: No sales recorded"
    fi
}