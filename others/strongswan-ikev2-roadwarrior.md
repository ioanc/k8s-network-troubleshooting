# strongSwan 5.9 IKEv2 Road Warrior - Ubuntu 24.04 + Win 11 / Win 10

**Scenario:** VPN server with public IP and DNS name. Road warrior (Bob) on Windows 11
authenticates with username/password (EAP-MSCHAPv2). Test environment.

---

## Step 1 — Install strongSwan

```bash
sudo apt update
sudo apt install charon-systemd strongswan-pki strongswan-swanctl \
     libstrongswan-extra-plugins libstrongswan-standard-plugins
```

> Do **not** install `strongswan` or `strongswan-starter` — they conflict with `charon-systemd`.

---

## Step 2 — Generate Certificates

Replace `vpn.example.com` with your actual public DNS name throughout.

```bash
sudo mkdir -p /etc/swanctl/private /etc/swanctl/x509 /etc/swanctl/x509ca
cd /tmp

# 1. CA key + self-signed cert
pki --gen --type rsa --size 4096 --outform pem > caKey.pem
pki --self --ca --lifetime 3652 --in caKey.pem \
    --dn "C=US, O=TestLab, CN=TestLab Root CA" \
    --outform pem > caCert.pem

# 2. Server key + cert (SAN must match your DNS name)
pki --gen --type rsa --size 2048 --outform pem > serverKey.pem
pki --req --type priv --in serverKey.pem \
    --dn "C=US, O=TestLab, CN=vpn.example.com" \
    --san vpn.example.com --outform pem > serverReq.pem
pki --issue --cacert caCert.pem --cakey caKey.pem \
    --type pkcs10 --in serverReq.pem --serial 01 --lifetime 1826 \
    --flag serverAuth --outform pem > serverCert.pem

# Install
sudo cp caKey.pem      /etc/swanctl/private/
sudo cp serverKey.pem  /etc/swanctl/private/
sudo cp serverCert.pem /etc/swanctl/x509/
sudo cp caCert.pem     /etc/swanctl/x509ca/
sudo chmod 600 /etc/swanctl/private/*
```

**Notes:**
- Use RSA, not Ed25519 — Windows 11 IKEv2 does not support Ed25519.
- The SAN (`--san`) must exactly match the DNS name Bob types in the Windows VPN config.

---

## Step 3 — /etc/swanctl/swanctl.conf

```
connections {
  eap {
    pools = vpn-pool

    local {
      auth = pubkey
      certs = serverCert.pem
      id = vpn.example.com
    }
    remote {
      auth = eap-dynamic
      eap_id = %any
    }
    children {
      eap {
        local_ts = 0.0.0.0/0        # force tunnel: all client traffic goes through VPN
        # local_ts = 192.168.1.0/24 # split tunnel: only this subnet goes through VPN
        # local_ts = 192.168.1.0/24, 10.0.0.0/8  # split tunnel: multiple subnets
        esp_proposals = aes256-sha256, aes256-sha1, aes128-sha256, aes128-sha1
        rekey_time = 0
      }
    }
    version = 2
    # MODP_2048 first (Windows 11), MODP_1024 fallback (Windows 10)
    proposals = aes256-sha256-modp2048, aes128-sha256-modp2048, aes256-sha256-modp1024, aes256-sha1-modp1024
  }
}

pools {
  vpn-pool {
    addrs = 10.10.10.0/24
    dns = 8.8.8.8
  }
}

secrets {
  eap-bob {
    id = bob
    secret = "TestPassword123"
  }
}
```

**Notes:**
- `esp_proposals` must include SHA1 variants — Windows 11 sends `AES_CBC_256/HMAC_SHA1_96`
  for ESP and will fail to establish the CHILD_SA without it.
- `rekey_time = 0` prevents disconnect issues when the client is behind NAT.
- `eap-dynamic` allows Windows to negotiate MSCHAPv2 via EAP-NAK.
- `proposals` lists MODP_2048 first (Windows 11 picks it) with MODP_1024 as fallback —
  Windows 10 ignores the `NegotiateDH2048_AES256` registry key on some builds and only offers MODP_1024.
- MODP_1024 is cryptographically weak — acceptable for a test lab, remove for production.

---

## Step 4 — /etc/strongswan.conf

```
charon-systemd {
  load_modular = yes
  plugins {
    include strongswan.d/charon/*.conf
    eap-dynamic {
      prefer_user = yes
      preferred = mschapv2, tls
    }
  }
}
```

---

## Step 5 — IP forwarding + firewall rules

```bash
# IP forwarding
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# NAT (replace eth0 with your outbound interface)
sudo iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i ipsec0 -j ACCEPT
sudo iptables -A FORWARD -o ipsec0 -j ACCEPT

# Persist rules across reboots
sudo apt install iptables-persistent
sudo netfilter-persistent save
```

---

## Step 6 — Start and load config

```bash
sudo systemctl enable --now strongswan
sudo swanctl --load-all
sudo swanctl --list-conns      # verify connection is loaded
sudo systemctl status strongswan
```

After any change to `swanctl.conf`:

```bash
sudo swanctl --load-all
```

---

## Step 7 — Windows 11 Client Setup (Bob)

**Install CA certificate:**
1. Copy `caCert.pem` to Bob's machine, rename to `caCert.crt`
2. Double-click → "Install Certificate" → **Local Machine** → "Trusted Root Certification Authorities"

**Add VPN connection** (Settings > VPN > Add a VPN connection):
- VPN provider: **Windows (built-in)**
- Connection name: Work VPN
- Server name or address: `vpn.example.com`
- VPN type: **IKEv2**
- Type of sign-in info: **Username and password**
- Username: `bob`
- Password: `TestPassword123`

**Optional registry tweak** (enable stronger crypto on Windows):
```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Rasman\Parameters
DWORD: NegotiateDH2048_AES256 = 2
```

---

## Debugging the Connection (Server Side)

### Follow logs in real time

```bash
journalctl -fu strongswan
```

### Increase charon log verbosity

Edit `/etc/strongswan.conf` and add a `syslog` section:

```
charon-systemd {
  load_modular = yes
  syslog {
    daemon {
      default = 2      # 0=silent, 1=basic, 2=verbose, 3=debug, 4=max
      ike = 2
      cfg = 2
      knl = 2
      net = 2
      esp = 2
      lib = 2
    }
  }
  plugins {
    include strongswan.d/charon/*.conf
    eap-dynamic {
      prefer_user = yes
      preferred = mschapv2, tls
    }
  }
}
```

Then restart to apply:
```bash
sudo systemctl restart strongswan
journalctl -fu strongswan
```

> Remember to remove or lower the log level after debugging — level 3/4 is very noisy.

### Runtime status commands

```bash
sudo swanctl --list-sas          # active IKE and CHILD SAs
sudo swanctl --list-conns        # loaded connections
sudo swanctl --list-certs        # loaded certificates
sudo swanctl --list-pools --leases  # virtual IP pools and leases
```

### Key log lines to look for

| Log line | Meaning |
|----------|---------|
| `no acceptable proposal found` | Crypto mismatch — compare `received proposals` vs `configured proposals` |
| `no peer config found` | ID mismatch — check `id =` in swanctl.conf vs cert SAN |
| `certificate verification failed` | CA cert not in `/etc/swanctl/x509ca/` or wrong cert |
| `EAP method … succeeded, MSK established` | Authentication passed |
| `failed to establish CHILD_SA` | ESP proposal or traffic selector mismatch |
| `CHILD_SA eap{…} established` | Full success |

### Packet capture (last resort)

```bash
sudo tcpdump -ni eth0 'udp port 500 or udp port 4500' -w /tmp/ike.pcap
```

Open `ike.pcap` in Wireshark — it decodes IKEv2 exchanges and shows exact proposal payloads.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| "Invalid payload received" on Windows | ESP proposal mismatch | Add `aes256-sha1`, `aes128-sha1` to `esp_proposals` |
| "Policy match error" on Windows 10 | IKE DH group mismatch — Win10 offers MODP_1024 only | Add `aes256-sha256-modp1024`, `aes256-sha1-modp1024` to `proposals` |
| Windows 10 still sends MODP_1024 after registry key | `NegotiateDH2048_AES256` key not effective on all Win10 builds | Add MODP_1024 proposals on the server side |
| Auth fails, cert not trusted | CA installed in wrong store | Reinstall in **Local Machine** > Trusted Root CAs |
| Connection drops behind NAT | Server-initiated rekeying | Set `rekey_time = 0` on children |
| `no virtual IP found for %any6` | No IPv6 pool configured | Harmless if IPv6 not needed; add IPv6 pool to silence it |

---

## Key Facts

| Item | Detail |
|------|--------|
| Ubuntu package | `charon-systemd` (not `strongswan-starter`) |
| EAP plugins package | `libstrongswan-extra-plugins` (not `libcharon-extra-plugins`) |
| Server cert key type | RSA only — Windows does not support Ed25519 |
| Cert SAN | Must match DNS name exactly as typed in Windows VPN config |
| systemd unit name | `strongswan` (not `charon-systemd`) |
