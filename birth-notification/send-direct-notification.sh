#!/bin/bash

echo "Sending notification..."

DOC=$(strip-json-comments fhir-document.jsonc)

curl -s -X POST -d "${DOC}" -H "Content-Type: application/json" http://46.101.36.211:5001/fhir | jq

echo -e "\nDone."
