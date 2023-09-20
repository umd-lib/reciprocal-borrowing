# reciprocal-borrowing

This Rails application is designed to work with Shibboleth and the
[InCommon][incommon] identity management federation to verify patron eligibility
for [reciprocal borrowing][btaa_reciprocal_borrowing] between members of the
[Big Ten Academic Alliance][btaa].

Reciprocal Borrowing is different from other UMD/SSDR Rails applications:

1) It does not use a database

2) It does not utilize the following Rails components:

* ActiveRecord
* ActiveStorage
* ActionMailer
* ActionMailbox
* ActionText
* ActionCable

3) It does not use the “umd-lib/umd_lib_style”
   (<https://github.com/umd-lib/umd_lib_style>) gem for styling.

4) It uses Sprockets (<https://github.com/rails/sprockets>) for the asset
   pipeline (as opposed to “webpacker")

## Quick Start

For local development, this application can be used in conjunction with a
Docker-based Shibboleth Identity Provider (IdP) and Shibboleth Service Provider
(SP) provided in the [umd-lib/reciprocal-borrowing-dev-env][dev-env] GitHub
repository. Refer to the README.md file in that repository for setup
instructions.

### "development_docker" Environment

An additional "development_docker" environment has been added to the
Rails standard "development", "test", and "production" environments, to support
running in the "umd-lib/reciprocal-borrowing-dev-env" Docker stack.

This environment contains:

* changes to use the "borrow-local" hostname
* changes to the "shibboleth_config.yml" file so that all organizations use the
  Shibboleth IdP in the Docker stack
* modifications to support running on M-series (Apple Silicon) laptops
* Values for the environment variables in the ".env" file

## Application Functionality

This application must be added to a server acting as a Shibboleth Service
Provider (SP). In order to be used in a production environment, the SP must be
registered with [InCommon][incommon]).

The functionality of this application is extremely straightforward:

1) The home page provides a list of organizations participating in reciprocal
   borrowing. On this page, the organization doing the lending is selected.

2) After selecting the lending organization, a second page is shown with a
   list of organizations. The authenticating organization (the organization the
   borrowing patron is a member of) is selected. After selecting the
   organization, the application redirects the browser (via an entityID provided
   to the Shibboleth SP running on the server) to a Shibboleth IdP for the
   selected organization.

3) The borrowing patron authenticates via their organizational authentication
   process.

   **Note:** This step takes place entirely outside of this application, so this
   application never has access to the patron's credentials.

4) After successfully authenticating, the browser is redirected back to this
   application, which indicates whether the patron is eligible to borrow.

**Note:** When running on the dev, stage, or production servers, there is no
known way to show that a user in ineligible for borrow because the UMD server
always seems pass back the expected property.

### Transactions Logging

The "transactions.log" file contains the results of *completed* authentications,
in which the user was successfully authenticated.

Each line in the "transactions.log" file has the following form:

```text
[<TIMESTAMP>] <IDENTIFIER>,lending_org_code=<LENDING_ORG>,auth_org_code=<AUTH_ORG>,authorized=[true|false]
```

where:

* \<TIMESTAMP>: The date/time of the completed authentication
* \<IDENTIFIER>: The "eduPersonTargetedID" attribute returned by Shibboleth, or
  "N/A" if it is not provided. As described in
  <https://wiki.refeds.org/display/STAN/eduPerson+2020-01#eduPerson202001-eduPersonTargetedID>
  it is a "A persistent, non-reassigned, opaque identifier for a principal."
* \<LENDING_ORG>: The code (from "config/shibboleth_config.yml") of the lending
  organization
* \<AUTH_ORG>: The code (from "config/shibboleth_config.yml") of the
  organization used to authenticate the user.

If "authorized" is "true", the user is authorized to borrow, if "false" the
user is not.

## Application Configuration

The config/shibboleth_config.yml file contains the configuration information for
the organizations participating in reciprocal borrowing, and has been
pre-populated with Big Ten Academic Alliance members. The file contains
different sections for the "production", "development", "development_docker",
and "test" environments.

The application should work "out of the box" when used in conjunction with the
[umd-lib/reciprocal-borrowing-dev-env][dev-env] GitHub repository, in a
"development_docker" Rails environment. The "development_docker" section of the
shibboleth_config.yml has been pre-configured so that "idp_entity_id" for all
organizations points to the Docker IdP.

For a "production" environment, the shibboleth_config.yml file has been
pre-populated "idp_entity_id" values derived from the InCommon metadata for
those organizations. Note that these values will only work when running from an
SP registered with InCommon.

## Production Environment Configuration

The application uses the "dotenv" gem to configure the production environment.
The gem expects a ".env" file in the root directory to contain the environment
variables that are provided to Ruby. A sample "env_example" file has been
provided to assist with this process. Simply copy the "env_example" file to
".env" and fill out the parameters as appropriate.

The configured .env file should not be checked into the Git repository, as it
contains credential information.

## Environment Banner

In keeping with SSDR policy, an "environment banner" will be displayed at the
top of each page when running on non-production servers.

By default, in the local development environment (determined by
`Rails.env.development?`returning `true`), a "Local Environment" banner will be
displayed.

On non-production servers, the environment banner can be configured using the
following environment variables:

* ENVIRONMENT_BANNER - the text to display in the banner
* ENVIRONMENT_BANNER_FOREGROUND - the foreground color for the banner, as a CSS color
* ENVIRONMENT_BANNER_BACKGROUND - the background color for the banner, as a CSS color
* ENVIRONMENT_BANNER_ENABLED - (optional) "false" (case-sensitive) disables the
  banner. Anything else (including blank, or not providing the variable) enables
  the banner.

Sample configuration for an environment banner displaying
"Example Banner Environment" on a blue background with orange text:

```text
ENVIRONMENT_BANNER_ENABLED=true
ENVIRONMENT_BANNER_BACKGROUND="#0000ff"
ENVIRONMENT_BANNER_FOREGROUND="#ffa500"
ENVIRONMENT_BANNER=Example Banner Environment
```

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations
(Apache 2.0).

---
[btaa]: https://www.btaa.org/
[btaa_reciprocal_borrowing]: https://www.btaa.org/projects/library/reciprocal-borrowing/
[dev-env]: https://github.com/umd-lib/reciprocal-borrowing-dev-env
[incommon]: https://www.incommon.org/
