#!/bin/bash

echo "Sending notification..."

DOC=$(cat fhir-document.json | base64 -w 0)
MHD=$(sed -e "s/<base64_encoded_fhir-document.json>/$DOC/" mhd-transaction.json)

curl -s -X POST -d "${MHD}" -H "Content-Type: application/json" http://46.101.36.211:5001/fhir | jq

echo -e "\nDone."
