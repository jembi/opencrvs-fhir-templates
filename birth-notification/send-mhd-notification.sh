#!/bin/bash

echo "Sending notification..."

HOST=${1:-http://opencrvs-staging.jembi.org:5001}
DOC=$(strip-json-comments fhir-document.jsonc | base64 -w 0)
MHD=$(strip-json-comments mhd-transaction.jsonc | sed -e "s/<base64_encoded_fhir-document.jsonc>/$DOC/")

curl -s -X POST -d "${MHD}" -H "Content-Type: application/json" "${HOST}/fhir" | jq

echo -e "\nDone."
