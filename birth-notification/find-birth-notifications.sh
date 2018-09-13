#!/bin/bash

echo "Finding all Compositions..."

HOST=${1:-http://opencrvs-staging.jembi.org:5001}
curl -s "${HOST}/fhir/Composition?type=birth-notification" | jq

echo -e "\nDone."
