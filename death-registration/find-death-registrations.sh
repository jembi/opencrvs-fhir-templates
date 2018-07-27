#!/bin/bash

echo "Finding all death registrations..."

curl -s 'http://46.101.36.211:5001/fhir/Composition?type=death-registration' | jq

echo -e "\nDone."
