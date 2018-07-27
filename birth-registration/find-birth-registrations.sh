#!/bin/bash

echo "Finding all birth registrations..."

curl -s 'http://46.101.36.211:5001/fhir/Composition?type=birth-registration' | jq

echo -e "\nDone."
