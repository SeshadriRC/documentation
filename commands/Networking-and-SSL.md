# Networking & SSL/TLS Commands for DevOps Engineers

A comprehensive reference for network diagnostics, SSL/TLS certificate management with OpenSSL, Let's Encrypt / Certbot, and Nginx reverse proxy administration.

---

## 1. OpenSSL Certificate Inspection & Validation

```bash
# Check certificate expiration date and validity of a remote endpoint
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -dates

# Check subject, issuer, and Subject Alternative Names (SANs) of remote endpoint
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -subject -issuer -ext subjectAltName

# Inspect full details of a local certificate file
openssl x509 -in /etc/ssl/certs/tls.crt -text -noout

# Verify if a Private Key matches a Certificate (MD5 hashes must be identical)
openssl x509 -noout -modulus -in tls.crt | openssl md5
openssl rsa -noout -modulus -in tls.key | openssl md5

# Verify certificate chain against a CA bundle
openssl verify -CAfile ca-bundle.crt tls.crt

# Test specific TLS protocol support (TLS 1.2 vs TLS 1.3)
openssl s_client -connect example.com:443 -tls1_2
openssl s_client -connect example.com:443 -tls1_3
```

---

## 2. Certificate Generation & Key Creation

```bash
# Generate a modern 2048-bit RSA Private Key and Self-Signed Certificate in one command
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/C=US/ST=California/L=SanFrancisco/O=DevOps/CN=app.internal"

# Generate a Private Key and a Certificate Signing Request (CSR)
openssl req -new -newkey rsa:2048 -nodes \
  -keyout app.key \
  -out app.csr \
  -subj "/C=US/ST=California/L=SanFrancisco/O=DevOps/CN=api.company.com"

# View contents and requested extensions of a CSR
openssl req -text -noout -verify -in app.csr

# Remove passphrase from a private key (for automated services)
openssl rsa -in encrypted.key -out decrypted.key

# Convert PEM certificate to PKCS#12 (.pfx / .p12) for Java / Windows
openssl pkcs12 -export -out bundle.pfx -inkey tls.key -in tls.crt -certfile ca.crt
```

---

## 3. Let's Encrypt & Certbot

```bash
# Obtain certificate using standalone mode (requires port 80 to be free)
sudo certbot certonly --standalone -d mydomain.com -d www.mydomain.com

# Obtain and automatically configure certificate in Nginx
sudo certbot --nginx -d mydomain.com

# Obtain wildcard certificate using DNS validation
sudo certbot certonly --manual --preferred-challenges dns -d "*.company.com" -d "company.com"

# Test certificate renewal without making actual changes (Dry Run)
sudo certbot renew --dry-run

# List installed certificates and expiration dates
sudo certbot certificates

# Revoke a compromised certificate
sudo certbot revoke --cert-path /etc/letsencrypt/live/mydomain.com/cert.pem
```

---

## 4. Nginx Reverse Proxy Administration

```bash
# Validate Nginx configuration syntax (ALWAYS run before reloading in production)
sudo nginx -t

# Gracefully reload Nginx configuration without downtime or dropping active connections
sudo nginx -s reload

# Stop, start, and restart Nginx via systemd
sudo systemctl status nginx
sudo systemctl restart nginx

# View compiled-in Nginx modules and version
nginx -V

# Tail access logs filtering only HTTP 4xx and 5xx errors
tail -f /var/log/nginx/access.log | grep -E " (4[0-9]{2}|5[0-9]{2}) "
```

---

## 5. Network Diagnostics & Packet Sniffing

```bash
# Sniff DNS queries on eth0 interface
sudo tcpdump -i eth0 -n "udp port 53"

# Capture all TCP SYN and RST packets (diagnosing connection refusal / drops)
sudo tcpdump -i any -nn "tcp[tcpflags] & (tcp-syn|tcp-rst) != 0"

# Scan open ports and detect service versions on a target host using Nmap
nmap -sV -p 22,80,443,5432,6443,8080 192.168.1.50

# Fast SYN scan across common top 100 ports
sudo nmap -sS -F 192.168.1.50

# Test TCP port connectivity with Netcat
nc -zv 10.0.0.15 6443

# Start a temporary TCP listener to verify firewall passage
# On receiver machine:
nc -l -p 9999
# On sender machine:
echo "Firewall test" | nc <receiver-ip> 9999

# Trace DNS resolution path from root servers (+trace)
dig @8.8.8.8 company.com +trace

# Inspect all DNS records (A, CNAME, MX, TXT)
dig company.com ANY
dig company.com TXT
```
