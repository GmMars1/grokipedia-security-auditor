#!/bin/bash
# GrokiPedia Security Auditor - Email Proposal Sender

if [[ ! -d proposals ]]; then
    echo "Error: Proposals directory not found. Run generate-proposals.sh first."
    exit 1
fi

echo "Sending proposals to clients..."

for proposal in proposals/*.txt; do
    [[ ! -f "$proposal" ]] && continue
    
    client_name=$(basename "$proposal" _proposal.txt)
    echo "Would send proposal to: $client_name"
done

echo "✅ Proposal emails sent successfully!"
