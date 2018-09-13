#!/bin/bash

echo "Finding all Compositions..."

HOST=${1:-http://opencrvs-staging.jembi.org:5001}
curl -s "${HOST}/fhir/Composition?_count=9999" | jq

echo -e "\nDone."
