#!/bin/bash

echo "Sending notification..."

DOC=$(strip-json-comments fhir-document.jsonc | base64 -w 0)
MHD=$(strip-json-comments mhd-transaction.jsonc | sed -e "s/<base64_encoded_fhir-document.jsonc>/$DOC/")

curl -s -X POST -d "${MHD}" -H "Content-Type: application/json" http://46.101.36.211:5001/fhir | jq

echo -e "\nDone."
