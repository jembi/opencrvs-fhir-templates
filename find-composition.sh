#!/bin/bash

echo "Finding all Compositions..."

curl -s 'http://46.101.36.211:5001/fhir/Composition?_count=9999' | jq

echo -e "\nDone."
