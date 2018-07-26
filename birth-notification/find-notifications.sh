#!/bin/bash

echo "Finding all Compositions..."

curl -s http://46.101.36.211:5001/fhir/Composition | jq
# More specific queries will work after some modification to Hearth
# curl -s 'http://46.101.36.211:5001/fhir/Composition?status=preliminary&entry=Location/123&type=birth-notification' | jq

echo -e "\nDone."
