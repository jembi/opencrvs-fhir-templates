# OpenCRVS FHIR API and Templates

This repository contains the proposed FHIR API for use in the OpenCRVS system. It is a work in progress and will continue to evolve, however, it has reached a level of maturity.

It describes both the sub-set of the FHIR RESTful API that is used (along with a few custom endpoint) as ell as the some FHIR templates that map out the data needed for CRVS birth and death events.

## Submitting CRVS events

There are two methods to submit a CRVS event to the system. One using the MHD profile for FHIR and simpler method where FHIR documents are posted directly to the FHIR API.

### 1. Direct FHIR document submission

Using this option you can submit the FHIR document (E.g. **[fhir-document.jsonc template](birth-registration/fhir-document.jsonc)**) directly to the `/fhir` endpoint and it will be processed in the same way as the MHD document below, except document manifests and document references aren't created and a full binary copy of the submitted document isn't captured for record keeping. This method is useful for a simpler integration where the additional metadata and standardization that the MHD profile provides isn't necessary.

### 2. MHD option

Using this option a new event can be sent by submitting a **[FHIR MHD transaction bundle](birth-registration/mhd-transaction.jsonc)** (this conforms to the Mobile Health Document profile by IHE) to Hearth containing 3 things along with some optional resources:

  1. **The document manifest** - describes the purpose of the document and it's context (links to patient, practitioner etc)
  2. **The document reference** (referenced by the document mainfest) - describes where to find the document, the `content.attachment.url` property will reference the binary reference below
  3. **The Binary resource** (referenced by the document reference)
  4. **Any other resources** that are referenced in the bundle link patient

The binary resource will contain a base64 encoded version of the **[fhir-document.jsonc template](birth-registration/fhir-document.jsonc)** depending on the event we are sending. It also contains references to related resources from the document manifest like patient and encounter.

## Document processing

Hearth will process FHIR document submitted both by the MHD methods and the direct submission method and it will store the individual resources listed in those documents induvidually. Those resources are then available using normal FHIR queries and update operations.

# Data specification

Below we explore the type of data we need to store for each type of event and how they map to FHIR resources. The templates in this repository then expand on this to show how they may be constructed.

## Birth Notification

This is used to notify the OpenCRVS system that a birth (or death) has occurred somewhere and it should followed up on. This information is not considered formal and is just used so that system can report enough information (such as contact details and location) so they event can be followed up by a CRVS official.

Data captured:

* Notification type
* Contact details
* Basic demographics details
* Location

This is represented as a [FHIR document](https://www.hl7.org/fhir/documents.html) of type Birth Notification with the following sections:
* Patient resource for mother details (minimal)
* Patient resource for father details (optional)
* Location (optional)

See **[fhir-document.jsonc template](birth-notification/fhir-document.jsonc)** for a template.

## Birth Registration

This is used to formally declare that a birth event has taken place and is used by certified applications thata re allowed to submit such declaration. This starts the process for formal registration of the event. The event will move through a few stages being being fully registered and certified. There stages are declaration, verification, registration and certification. Certification is where the physical certificate is actually produced.

Data captured:

* Registration type
* All demographics of the child
* Location
* Particular form fields and observation about the event
* Scans of original forms necessary for registration

This is represented as a [FHIR document](https://www.hl7.org/fhir/documents.html) of type Birth Registration with the following sections:
* Patient resource for mother details
* Patient resource for father details (optional)
* Patient resource for child/ren details
* Encounter w/ Location and Observations for clinical form fields from the birth encounter
* DocumentReference resources for scanned images/pdfs

See **[fhir-document.jsonc template](birth-registration/fhir-document.jsonc)** for the template.

# API details

## Authentication (Disabled for HacKonnect-a-thon)

Authentication and Authorization for the API is done via JWTs. For external system interfacing with OpenCRVS a JWT token will be issued manually for your application. To use the token each HTTP request made to the API must include the in it's `Authorization` header along with the prefix `bearer` for token type:

```
Authorization: bearer <token>
```

## Notification API

* **Submit notification**
  * `POST fhir/`
  * with a direct [FHIR Document](birth-notification/fhir-document.jsonc) or a [FHIR MHD transaction bundle](birth-notification/mhd-transaction.jsonc)
  * returns FHIR operation outcome
* **Query pending notifications at a particular location**
  * `GET fhir/Composition?entry=Location/<id>&type=birth-notification`
  * return a Bundle of Compositions (This links to the other resources in the notification and those can be fetched using `GET fhir/<resourceType>/<id>`)
* **Update notification resources**
  * `PUT fhir/<resourceType>/<id>`
  * with the updated resource details
  * return 200

## Registration API

* **Submit preliminary registration**
  * `POST /fhir`
  * with a direct [FHIR Document](birth-registration/fhir-document.jsonc) or a [FHIR MHD transaction bundle](birth-registration/mhd-transaction.jsonc)
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

## Custom API endpoints

**TODO:** Add to GraphQL

* **Generate certificate**
  * `GET api/certificate/<compositionId>`
  * return FHIR Binary resource with image or pdf content
* **Check payment received**
  * `GET api/payment/<compositionId>`
  * return payment details, TBD

## GraphQL mapping to FHIR API

OpenCRVS uses a GraphQL API to make calling these FHIR endpoint easier for the frontend web app. This is only to be used by the official OpenCRVS we app. The following is a mapping between the GraphQL queries and mutation from the frontend webapp to corresponding FHIR endpoints.

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
  * Update registration resources - For each resource updated: `PUT fhir/<resourceType>/<id>`
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
  * Update registration resources - For each resource updated: `PUT fhir/<resourceType>/<id>`
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

## Test scripts

There are a few bash scripts to demonstrate the sending some of the templates. To run these you need to have node installed and have installed this global dependency: `npm install --global strip-json-comments-cli`
