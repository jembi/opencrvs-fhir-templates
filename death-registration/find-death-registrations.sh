#!/bin/bash

echo "Finding all death registrations..."

HOST=${1:-http://opencrvs-staging.jembi.org:5001}
curl -s "${HOST}/fhir/Composition?type=death-registration" | jq

echo -e "\nDone."
