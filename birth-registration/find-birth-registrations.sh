#!/bin/bash

echo "Finding all birth registrations..."

HOST=${1:-http://opencrvs-staging.jembi.org:5001}
curl -s "${HOST}/fhir/Composition?type=birth-registration" | jq

echo -e "\nDone."
