#!/bin/bash

echo "Sending death registration..."

HOST=${1:-http://opencrvs-staging.jembi.org:5001}
DOC=$(strip-json-comments fhir-document.jsonc)

curl -s -X POST -d "${DOC}" -H "Content-Type: application/json" "${HOST}/fhir" | jq

echo -e "\nDone."
