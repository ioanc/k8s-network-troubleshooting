# NFT SYN/SYN-ACK Trace Script

A bash script to trace TCP handshake packets (SYN and SYN-ACK) using nftables on Linux hosts.

## Use Case

Trace incoming TCP connection attempts (SYN) and server responses (SYN-ACK) for applications listening on a specific port. Useful for:

- Debugging connection issues
- Verifying firewall rules
- Monitoring TCP handshake flow through netfilter hooks

## Requirements

- Linux with nftables installed
- Root/sudo privileges
- Bash shell

## Usage

```bash
sudo bash nft-syn-synack-trace.sh -p <port> [-i <ip_address>] [-t <timeout>]
```

### Arguments

| Flag | Description | Required | Default |
|------|-------------|----------|---------|
| `-p` | Listening TCP port | Yes | - |
| `-i` | Client IP address to filter | No | All IPs |
| `-t` | Timeout in seconds | No | 60 |
| `-h` | Show help | No | - |

## Examples

### Basic usage - trace all connections to port 12345
```bash
sudo bash nft-syn-synack-trace.sh -p 12345
```

### Filter by client IP
```bash
sudo bash nft-syn-synack-trace.sh -p 8080 -i 10.0.0.1
```

### Extended timeout (2 minutes)
```bash
sudo bash nft-syn-synack-trace.sh -p 443 -i 192.168.1.100 -t 120
```

## What It Traces

| Packet Type | Direction | Hook | Match |
|-------------|-----------|------|-------|
| SYN | Incoming | prerouting | `tcp dport <port> tcp flags == syn` |
| SYN-ACK | Outgoing | output | `tcp sport <port> tcp flags == syn,ack` |

## How It Works

1. Creates an nftables table `css-filter`
2. Adds two chains with tracing rules:
   - `trace_in`: Captures incoming SYN packets (prerouting hook, priority -301)
   - `trace_out`: Captures outgoing SYN-ACK packets (output hook, priority -301)
3. Enables `meta nftrace set 1` to mark packets for tracing
4. Runs `nft monitor trace` to display traced packets
5. Automatically cleans up rules on exit (Ctrl+C or timeout)

## Sample Output

```
trace id 12345 ip css-filter trace_in packet: iif "eth0" ether saddr 00:11:22:33:44:55 ether daddr 66:77:88:99:aa:bb ip saddr 10.0.0.1 ip daddr 10.0.0.2 ip protocol tcp tcp sport 54321 tcp dport 12345 tcp flags == syn
trace id 12346 ip css-filter trace_out packet: oif "eth0" ether saddr 66:77:88:99:aa:bb ether daddr 00:11:22:33:44:55 ip saddr 10.0.0.2 ip daddr 10.0.0.1 ip protocol tcp tcp sport 12345 tcp dport 54321 tcp flags == syn,ack
```

## Cleanup

The script automatically cleans up nftables rules when:
- Timeout expires
- User presses Ctrl+C
- Script exits for any reason

Manual cleanup (if needed):
```bash
sudo nft delete table css-filter
```

## References

- [nftables Wiki - Ruleset debug/tracing](https://wiki.nftables.org/wiki-nftables/index.php/Ruleset_debug/tracing)
- [nftables Wiki - Matching packet headers](https://wiki.nftables.org/wiki-nftables/index.php/Matching_packet_headers)
- [nftables Wiki - Netfilter hooks](https://wiki.nftables.org/wiki-nftables/index.php/Netfilter_hooks)

## License

MIT
