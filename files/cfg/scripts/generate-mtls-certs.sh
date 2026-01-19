#!/usr/bin/env bash
# =============================================================================
# mTLS Certificate Generation Script for NER API
# =============================================================================
# This script generates all certificates needed for mTLS (mutual TLS):
# - CA certificate (Certificate Authority)
# - Server certificate (for NER API)
# - Client certificate (for clients like glchat-be)
#
# Usage:
#   ./generate-mtls-certs.sh [output_dir]
#
# Arguments:
#   output_dir  - Directory to store generated certificates (default: ./certs)
#
# Output files:
#   ca.key      - CA private key
#   ca.crt      - CA certificate
#   server.key  - Server private key
#   server.crt  - Server certificate
#   client.key  - Client private key
#   client.crt  - Client certificate
#
# Authors:
#   GDP Labs Engineering Team
# =============================================================================

set -euo pipefail

# Configuration
OUTPUT_DIR="${1:-./certs}"
DAYS_VALID=365
KEY_SIZE=4096

# Certificate subjects
CA_SUBJECT="/C=ID/ST=Jakarta/L=Jakarta/O=GDP Labs/OU=Engineering/CN=NER-API-CA"
SERVER_SUBJECT="/C=ID/ST=Jakarta/L=Jakarta/O=GDP Labs/OU=Engineering/CN=ner-api.gdplabs.id"
CLIENT_SUBJECT="/C=ID/ST=Jakarta/L=Jakarta/O=GDP Labs/OU=Engineering/CN=glchat-be"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
	echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
	echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
	echo -e "${RED}[ERROR]${NC} $1"
}

# Check if openssl is installed
if ! command -v openssl &>/dev/null; then
	log_error "openssl is required but not installed. Please install openssl first."
	exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
log_info "Output directory: $OUTPUT_DIR"

# =============================================================================
# Step 1: Generate CA (Certificate Authority)
# =============================================================================
log_info "Generating CA private key and certificate..."

# Create CA extensions config for proper X.509 compliance (required for Python 3.13+)
cat >"$OUTPUT_DIR/ca_ext.cnf" <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
prompt = no

[req_distinguished_name]
C = ID
ST = Jakarta
L = Jakarta
O = GDP Labs
OU = Engineering
CN = NER-API-CA

[v3_ca]
basicConstraints = critical, CA:TRUE
keyUsage = critical, keyCertSign, cRLSign
subjectKeyIdentifier = hash
EOF

openssl req -x509 -newkey "rsa:$KEY_SIZE" \
	-keyout "$OUTPUT_DIR/ca.key" \
	-out "$OUTPUT_DIR/ca.crt" \
	-days "$DAYS_VALID" \
	-nodes \
	-config "$OUTPUT_DIR/ca_ext.cnf" \
	-extensions v3_ca \
	2>/dev/null

rm -f "$OUTPUT_DIR/ca_ext.cnf"

log_info "CA certificate generated: $OUTPUT_DIR/ca.crt"

# =============================================================================
# Step 2: Generate Server Certificate
# =============================================================================
log_info "Generating server private key..."

openssl genrsa -out "$OUTPUT_DIR/server.key" "$KEY_SIZE" 2>/dev/null

log_info "Generating server certificate signing request (CSR)..."

openssl req -new \
	-key "$OUTPUT_DIR/server.key" \
	-out "$OUTPUT_DIR/server.csr" \
	-subj "$SERVER_SUBJECT" \
	2>/dev/null

# Create a config file for SAN (Subject Alternative Names)
cat >"$OUTPUT_DIR/server_ext.cnf" <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = ner-api.gdplabs.id
DNS.3 = *.gdplabs.id
IP.1 = 127.0.0.1
IP.2 = 0.0.0.0
EOF

log_info "Signing server certificate with CA..."

openssl x509 -req \
	-in "$OUTPUT_DIR/server.csr" \
	-CA "$OUTPUT_DIR/ca.crt" \
	-CAkey "$OUTPUT_DIR/ca.key" \
	-CAcreateserial \
	-out "$OUTPUT_DIR/server.crt" \
	-days "$DAYS_VALID" \
	-extfile "$OUTPUT_DIR/server_ext.cnf" \
	2>/dev/null

log_info "Server certificate generated: $OUTPUT_DIR/server.crt"

# =============================================================================
# Step 3: Generate Client Certificate
# =============================================================================
log_info "Generating client private key..."

openssl genrsa -out "$OUTPUT_DIR/client.key" "$KEY_SIZE" 2>/dev/null

log_info "Generating client certificate signing request (CSR)..."

openssl req -new \
	-key "$OUTPUT_DIR/client.key" \
	-out "$OUTPUT_DIR/client.csr" \
	-subj "$CLIENT_SUBJECT" \
	2>/dev/null

# Create a config file for client certificate
cat >"$OUTPUT_DIR/client_ext.cnf" <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
EOF

log_info "Signing client certificate with CA..."

openssl x509 -req \
	-in "$OUTPUT_DIR/client.csr" \
	-CA "$OUTPUT_DIR/ca.crt" \
	-CAkey "$OUTPUT_DIR/ca.key" \
	-CAcreateserial \
	-out "$OUTPUT_DIR/client.crt" \
	-days "$DAYS_VALID" \
	-extfile "$OUTPUT_DIR/client_ext.cnf" \
	2>/dev/null

log_info "Client certificate generated: $OUTPUT_DIR/client.crt"

# =============================================================================
# Step 4: Cleanup temporary files
# =============================================================================
rm -f "$OUTPUT_DIR/server.csr" "$OUTPUT_DIR/client.csr"
rm -f "$OUTPUT_DIR/server_ext.cnf" "$OUTPUT_DIR/client_ext.cnf"
rm -f "$OUTPUT_DIR/ca.srl"

# =============================================================================
# Step 5: Set appropriate permissions
# =============================================================================
log_info "Setting file permissions..."

chmod 600 "$OUTPUT_DIR"/*.key
chmod 644 "$OUTPUT_DIR"/*.crt

# =============================================================================
# Step 6: Verify certificates
# =============================================================================
log_info "Verifying certificates..."

if openssl verify -CAfile "$OUTPUT_DIR/ca.crt" "$OUTPUT_DIR/server.crt" >/dev/null 2>&1; then
	log_info "Server certificate verification: OK"
else
	log_error "Server certificate verification: FAILED"
	exit 1
fi

if openssl verify -CAfile "$OUTPUT_DIR/ca.crt" "$OUTPUT_DIR/client.crt" >/dev/null 2>&1; then
	log_info "Client certificate verification: OK"
else
	log_error "Client certificate verification: FAILED"
	exit 1
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "============================================================================="
echo "                    mTLS Certificates Generated Successfully"
echo "============================================================================="
echo ""
echo "Generated files in $OUTPUT_DIR:"
echo "  - ca.key      : CA private key (keep secure!)"
echo "  - ca.crt      : CA certificate"
echo "  - server.key  : Server private key (keep secure!)"
echo "  - server.crt  : Server certificate"
echo "  - client.key  : Client private key (keep secure!)"
echo "  - client.crt  : Client certificate"
echo ""
echo "Certificate validity: $DAYS_VALID days"
echo ""
echo "============================================================================="
echo "                         Environment Variables"
echo "============================================================================="
echo ""
echo "Add these to your NER API .env file:"
echo ""
echo "  MTLS_ENABLED=true"
echo "  MTLS_CERT_PATH=$OUTPUT_DIR/server.crt"
echo "  MTLS_KEY_PATH=$OUTPUT_DIR/server.key"
echo "  MTLS_CA_CERT_PATH=$OUTPUT_DIR/ca.crt"
echo ""
echo "============================================================================="
echo "                           Testing with curl"
echo "============================================================================="
echo ""
echo "Test the mTLS connection:"
echo ""
echo "  curl --cert $OUTPUT_DIR/client.crt \\"
echo "       --key $OUTPUT_DIR/client.key \\"
echo "       --cacert $OUTPUT_DIR/ca.crt \\"
echo "       https://localhost:8000/health"
echo ""
echo "============================================================================="
