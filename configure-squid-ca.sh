#!/bin/bash
set -eu -o pipefail

apt-get install -y ca-certificates

mkdir -p /etc/squid

cat <<EOF | tee /etc/squid/CA.pem
-----BEGIN CERTIFICATE-----
MIIDdDCCAlygAwIBAgIUKD0xOqz4SIONv1dFtHIC8xnCzWgwDQYJKoZIhvcNAQEL
BQAwQzEUMBIGA1UEAwwLc3F1aWQubG9jYWwxDjAMBgNVBAoMBXNxdWlkMQ4wDAYD
VQQLDAVzcXVpZDELMAkGA1UEBhMCVVMwHhcNMjIwNzI4MTQ0NDQ1WhcNMzIwNzI1
MTQ0NDQ1WjBDMRQwEgYDVQQDDAtzcXVpZC5sb2NhbDEOMAwGA1UECgwFc3F1aWQx
DjAMBgNVBAsMBXNxdWlkMQswCQYDVQQGEwJVUzCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBAKvB7MZAnGdPEKkcGBY9BzE0SawMms6iJw8Q/+bz6hwhzXya
1dZ2HsCS2TH6HRFwxm+I47DGt8aIob4n8mnC5JC+pee+hxF9HuoLfmsWCvcv565G
wlKx9wT4+biqDbnX7QR+XlzPu/jQDeJa/oIACUifKa3qpTqpnAKw9u6fPPwagbxo
dFaDEQNlGcFTCtcQLbv/MLeUU2n3BV8IwIUdI6//5H6qqoB/VoszaLnZJpnKsVwg
mCNfPg0e4AvNogrN4cxhzFgX1PkVytMTV4NWEo3HogbXYp9kYJUJrQghjsab3Ufi
fiBqggnyD98l8AA4mlviE5aqOqsP4KJNJAjrLu8CAwEAAaNgMF4wHQYDVR0OBBYE
FD7qyGtxEH9VIDuualAGnIBmUhm9MB8GA1UdIwQYMBaAFD7qyGtxEH9VIDuualAG
nIBmUhm9MA8GA1UdEwEB/wQFMAMBAf8wCwYDVR0PBAQDAgEGMA0GCSqGSIb3DQEB
CwUAA4IBAQAo0Cs8GvLRE3i04zsHKmw0GeuZCibA/TjXa1K4AnzunizMxIIITBOa
qXWbkuZFY0NVgZLg5lWyZaRCwcS7cd4RpyeNR1wi5dnK8q39KCiBKmGyvov/5N+K
9o2WZlSaGxbvEzPQ2C1nxYs7acp1UHllKy3OBGhvtAwIDGi0rpnkd6jqk6poyrSd
M52sN9TFZjqlzuVICiMMTQJHtN72BMd87wMgUzRpmtDOpxeWdYsjv6ABSw3vV6vu
x9O/yIOAKr0IR/73ZqHCRxUMl7BCvBi3A84Tpdnrt3qNXUK+rBr8u0TJJNzJMW76
mFvQkZ29mcKWCNQnaUI7heBIe+w5J2YW
-----END CERTIFICATE-----
EOF

cp /etc/squid/CA.pem /usr/local/share/ca-certificates/squid-CA.crt

update-ca-certificates
