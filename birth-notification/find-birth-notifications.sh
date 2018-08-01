#!/bin/bash

echo "Finding all Compositions..."

curl -s 'http://46.101.36.211:5001/fhir/Composition?type=birth-notification' | jq

echo -e "\nDone."
