# OpenCRVS FHIR Templates

To store a CRVS event we send a **FHIR transaction bundle** to Hearth containing 3 things along with some optional resources:

  1. **The document manifest** - describes the purpose of the document and it's context (links to patient, practitioner etc)
  2. **The document reference** (referenced by the document mainfest) - describes where to find the document, the `content.attachment.url` property will reference the binary reference below
  3. **The Binary resource** (referenced by the document reference)
  4. **Any other resources** that are referenced in the bundle link patient

The binary resource will contain a base64 encoded version of the [fhir-document.json template](fhir-document.json) depending on the event we are sending. It also contains references to related resources from the document manifest like patient and encounter.

Hearth can process FHIR transactions and will store the individual resources above. It can also notice FHIR documents being stored in the binary resources if the correct FHIR content-type is used and it will break those resources out and store them individually as well.

Below we explore the type of data we need to store for each type of event and how that maps to FHIR resources. The templates in this repository then expand on those to show how they may be constructed.

## Birth Notification

Data captured:

* Notification type
* Contact details
* Basic demographics details
* Location

This can be represented in a FHIR document of type Birth Notification with the following sections:
* Patient resource for mother details (minimal)
* Patient resource for father details (optional)
* Location (optional)

## Birth Declaration

Data captured:

* Declaration type
* All demographics
* Location
* Particular form fields filled out
* Scans of original forms

This can be represented in a FHIR document of type Birth Declaration with the following sections:
* Patient resource for mother details
* Patient resource for father details (optional)
* Patient resource for child/ren details
* Encounter w/ Location and Observations for clinical form fields from the birth encounter
* Binary resources for scanned images/pdfs