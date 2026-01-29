#!/bin/bash
# NFT tracing for incoming SYN and outgoing SYN-ACK on a listening TCP port
# Use case: Trace TCP handshake for a server application listening on a specific port
# Usage: sudo bash nft-syn-synack-trace.sh -p <port> [-i <ip_address>] [-t <timeout>]

usage() {
    echo "Usage: $0 -p <port> [-i <ip_address>] [-t <timeout>]"
    echo "  -p  Listening port (required)"
    echo "  -i  Client IP address to filter (optional, traces all IPs if not specified)"
    echo "  -t  Timeout in seconds (default: 60)"
    echo ""
    echo "Example: $0 -p 12345 -i 10.0.0.1 -t 120"
    echo "Example: $0 -p 8080"
    exit 1
}

# Parse arguments
PORT=""
IP=""
TIMEOUT=60

while getopts "p:i:t:h" opt; do
    case $opt in
        p) PORT="$OPTARG" ;;
        i) IP="$OPTARG" ;;
        t) TIMEOUT="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Validate required arguments
if [[ -z "$PORT" ]]; then
    echo "Error: Port is required"
    usage
fi

# Cleanup function
cleanup() {
    echo "Cleaning up nft rules..."
    nft delete table css-filter 2>/dev/null
}

# Set trap for cleanup on exit
trap cleanup EXIT

echo "Starting NFT trace for server listening on TCP port $PORT"
echo "  Listening port: $PORT"
echo "  Client IP: ${IP:-all}"
echo "  Timeout: ${TIMEOUT}s"
echo ""

# Create the trace table
nft add table css-filter

# Chain for incoming SYN (prerouting hook)
nft add chain css-filter trace_in { type filter hook prerouting priority -301\; }

# Chain for outgoing SYN-ACK (output hook)
nft add chain css-filter trace_out { type filter hook output priority -301\; }

# Build IP filter if specified
IP_FILTER_IN=""
IP_FILTER_OUT=""
if [[ -n "$IP" ]]; then
    IP_FILTER_IN="ip saddr $IP"
    IP_FILTER_OUT="ip daddr $IP"
fi

# Trace incoming SYN to listening port
nft add rule css-filter trace_in $IP_FILTER_IN tcp dport $PORT tcp flags == syn meta nftrace set 1

# Trace outgoing SYN-ACK from listening port
nft add rule css-filter trace_out $IP_FILTER_OUT tcp sport $PORT tcp flags == syn,ack meta nftrace set 1

echo "NFT trace rules installed. Monitoring TCP SYN/SYN-ACK on port $PORT..."
echo "Press Ctrl+C to stop"

# Start monitoring
timeout $TIMEOUT nft monitor trace

echo "Trace complete."
