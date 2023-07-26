# reciprocal-borrowing

This Rails application is designed to work with Shibboleth and the
[InCommon](https://www.incommon.org/) identity management federation to verify
patron eligibility for
[reciprocal borrowing](https://www.btaa.org/projects/library/reciprocal-borrowing/introduction)
between members of the [Big Ten Academic Alliance](https://www.btaa.org/).

## Quick Start

This application must be added to a server acting as a Shibboleth Service
Provider (SP). In order to be used in a production environment, the SP must be
registered with [InCommon](https://www.incommon.org/)).

For local development, this application can be used in conjunction with the
Vagrant-based Shibboleth Identity Provider (IdP) and SP provided in the
[umd-lib/reciprocal-borrowing-vagrant](https://github.com/umd-lib/reciprocal-borrowing-vagrant)
GitHub repository. Refer to the README.md file in that repository for setup
instructions.

## Application Functionality

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

**Note:** The local development environment (when used in conjunction with the
"reciprocal-borrowing-vagrant" as the Shibboleth SP and IdP) *cannot* show that
a user is eligible to borrow because the IdP is not currently configured to pass
the correct "eduPersonEntitlement" attribute back to the application.
Conversely, when running on the dev, stage, or production servers, there is no
known way to show that a user in ineligible for borrow because the UMD server
always seems pass back the expected property.

## Application Configuration

The config/shibboleth_config.yml file contains the configuration information for
he organizations participating in reciprocal borrowing, and has been
pre-populated with Big Ten Academic Alliance members. The file contains
different sections for the "production", "development", and "test" environments.

The application should work "out of the box" when used in conjunction with the
[umd-lib/reciprocal-borrowing-vagrant](https://github.com/umd-lib/reciprocal-borrowing-vagrant)
GitHub repository, in a "development" Rails environment. The "development"
section of the shibboleth_config.yml has been pre-configured so that
"idp_entity_id" for all organizations points to the Vagrant IdP.

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

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations
(Apache 2.0).
