# OpenCRVS FHIR Templates

There are two methods to store a CRVS event. One using the MHD profile for FHIR and simpler method where FHIR documents are posted directly to the FHIR API.

## 1. MHD option

Using this option a new event can be sent by submitting a **[FHIR MHD transaction bundle](mhd-transaction.jsonc)** (this conforms to the Mobile Health Document profile) to Hearth containing 3 things along with some optional resources:

  1. **The document manifest** - describes the purpose of the document and it's context (links to patient, practitioner etc)
  2. **The document reference** (referenced by the document mainfest) - describes where to find the document, the `content.attachment.url` property will reference the binary reference below
  3. **The Binary resource** (referenced by the document reference)
  4. **Any other resources** that are referenced in the bundle link patient

The binary resource will contain a base64 encoded version of the **[fhir-document.jsonc template](fhir-document.jsonc)** depending on the event we are sending. It also contains references to related resources from the document manifest like patient and encounter.

## 2. Direct FHIR document submission

Using this option you can submit the FHIR document (E.g. **[fhir-document.jsonc template](fhir-document.jsonc)**) directly to the `/fhir` endpoint and it will be process in the same way as the above except document manifests and document references aren't created and a full binary copy of the submitted document isn't captured for record keeping. This method is useful for a simpler integration where the additional metadata from the MHD profile isn't necessary.

## Document processing

Hearth will process FHIR document submitted both by the MHD methods and the direct submission method and it will store the individual resources listed in those documents. Those resources are then available using normal FHIR queries and operations.

# Data specification

Below we explore the type of data we need to store for each type of event and how they map to FHIR resources. The templates in this repository then expand on this to show how they may be constructed.

## Birth Notification

Data captured:

* Notification type
* Contact details
* Basic demographics details
* Location

This can be represented in a [FHIR document](https://www.hl7.org/fhir/documents.html) of type Birth Notification with the following sections:
* Patient resource for mother details (minimal)
* Patient resource for father details (optional)
* Location (optional)

See **[fhir-document.jsonc template](fhir-document.jsonc)** for the template. Only the relevent parts of the template apply.

## Birth Declaration

Data captured:

* Declaration type
* All demographics
* Location
* Particular form fields filled out
* Scans of original forms

This can be represented in a [FHIR document](https://www.hl7.org/fhir/documents.html) of type Birth Declaration with the following sections:
* Patient resource for mother details
* Patient resource for father details (optional)
* Patient resource for child/ren details
* Encounter w/ Location and Observations for clinical form fields from the birth encounter
* Binary resources for scanned images/pdfs

See **[fhir-document.jsonc template](fhir-document.jsonc)** for the template. Only the relevent parts of the template apply.

# API details

## Authentication

TODO

## Notification API

* **Submit notification**
  * `POST fhir/`
  * with [FHIR transaction bundle](mhd-transaction.jsonc)
  * returns FHIR operation outcome
* **Query pending notifications at a particular location**
  * `GET fhir/Composition?status=preliminary&entry=Location/<id>&type=birth-notification`
  * return a Bundle of Compositions (This links to the other resources in the notification and those can be fetched using `GET fhir/<resourceType>/<id>`)
* **Update notification resources**
  * `PUT fhir/<resourceType>/<id>`
  * with the updated resource details
  * return 200

## Registration API

* **Submit preliminary registration**
  * `POST /fhir`
  * with [FHIR transaction bundle](mhd-transaction.jsonc)
  * returns FHIR operation outcome
  * Note: This will additionally create a default task resource to track the progress of the registration if one doesn't exist.
* **Query registration list**
  * `GET fhir/Composition?type=birth-registration`
  * return Bundle of Composition (This links to the other resources in the registration and those can be fetched using `GET fhir/<resourceType>/<id>`)
* **Query registration details**
  * `GET fhir/Composition/<id>`
  * return Bundle of Composition (This links to the other resources in the registration and those can be fetched using `GET fhir/<resourceType>/<id>`)
* **Query registration progress**
  * `GET fhir/Task?focus=Composition/<id>`
  * return Task resource
* **Query registration progress full history**
  * `GET fhir/Task?focus=Composition/<id>/_history`
  * return FHIR history bundle resource
* **Update registration resources**
  * `PUT fhir/<resourceType>/<id>`
  * with the updated resource details
  * return 200
* **Transition/Update registration state**
  * `PUT fhir/Task/<id>`
  * with the updated resource details
  * return 200
  * Note: This is to transition tasks between the states 'declared', 'verified' 'registered' and 'certified'.

## Custom API endpoints (TODO: Add to GraphQL)

* **Generate certificate**
  * `GET api/certificate/<compositionId>`
  * return FHIR Binary resource with image or pdf content
* **Check payment received**
  * `GET api/payment/<compositionId>`
  * return payment details, TBD

## GraphQL mapping to FHIR API

* createNotification(details: NotificationInput!): Notification!
  * Submit notification - `POST /fhir`
* voidNotification(id: ID!): Notification
  * `GET fhir/Composition/<id>`
  * `DELETE fhir/<resourceType>/<id>` for all resources referenced in composition
* listNotifications(locationIds: [String], status: String, userId: String, from: Date, to: Date): [Notification]
  * Query pending notifications at a particular location - `GET fhir/Composition?`
* listBirthRegistrations(locationIds: [String], status: String, userId: String, from: Date, to: Date): [BirthRegistration]
  * Query registration list - `GET fhir/Composition?`
* listDeathRegistrations(locationIds: [String], status: String, userId: String, from: Date, to: Date): [BirthRegistration]
  * Query registration list - `GET fhir/Composition?`
* createBirthRegistration(details: BirthRegistrationInput!): ID!
  * Submit preliminary registration - `POST /fhir`
* updateBirthRegistration(id: ID!, details: BirthRegistrationInput!): BirthRegistration!
  * Submit preliminary registration - `PUT fhir/<resourceType>/<id>`
* markBirthAsVerified(id: ID!, location: LocationInput): BirthRegistration
  * Transition registration state - `PUT fhir/Task`
* markBirthAsRegistered(id: ID!, location: LocationInput): BirthRegistration
  * Transition registration state - `PUT fhir/Task`
* markBirthAsCertified(id: ID!, location: LocationInput): BirthRegistration
  * Transition registration state - `PUT fhir/Task`
* markBirthAsVoided(id: ID!, reason: String!, location: LocationInput): BirthRegistration
  * Transition registration state - `PUT fhir/Task`
  * `GET fhir/Composition/<id>`
  * `DELETE fhir/<resourceType>/<id>` for all resources referenced in composition
* createDeathRegistration(details: DeathRegistrationInput!): ID!
  * Submit preliminary registration - `POST /fhir`
* updateDeathRegistration(id: ID!, details: DeathRegistrationInput!): DeathRegistration!
  * Submit preliminary registration - `PUT fhir/<resourceType>/<id>`
* markDeathAsVerified(id: ID!, location: LocationInput): DeathRegistration
  * Transition registration state - `PUT fhir/Task`
* markDeathAsRegistered(id: ID!, location: LocationInput): DeathRegistration
  * Transition registration state - `PUT fhir/Task`
* markDeathAsCertified(id: ID!, location: LocationInput): DeathRegistration
  * Transition registration state - `PUT fhir/Task`
* markDeathAsVoided(id: ID!, reason: String!, location: LocationInput): DeathRegistration
  * Transition registration state - `PUT fhir/Task`
  * `GET fhir/Composition/<id>`
  * `DELETE fhir/<resourceType>/<id>` for all resources referenced in composition
* user(id: Int!): User
* role(id: Int!): [UserRole]
