#!/bin/sh
echo "Waiting to Vault..."

until curl -s http://vault-custom:8200/v1/sys/health | grep -q '"sealed":true'; do
  echo "Vault not ready yet..."
  sleep 2
done

echo "Unsealing Vault"

vault operator unseal 2dKGGT9ZP0Iqms6X2EwtpDnGCpHNBN2T7CXZymWk9sb/
vault operator unseal ZoCU0ipcvAXnaDV0x4M6Rpd5CQRqHfjWYWrg6vLkgXDK
vault operator unseal lZ/Xzq28s4pQ7dQ0GlkRAT8jl/BkKPJ6TGovsgOw/+ql

echo "Vault unsealed!"
