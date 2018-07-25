#!/bin/bash

echo "Sending notification..."

DOC=$(cat fhir-document.jsonc | base64 -w 0)
MHD=$(sed -e "s/<base64_encoded_fhir-document.jsonc>/$DOC/" mhd-transaction.jsonc)

curl -s -X POST -d "${MHD}" -H "Content-Type: application/json" http://46.101.36.211:5001/fhir | jq

echo -e "\nDone."
