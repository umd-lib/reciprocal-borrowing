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
registered with [InCommon][incommon].

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
known way to show that a user in ineligible for borrowing because the UMD server
always seems pass back the expected property.

## Application Configuration

The "config/shibboleth_config.yml" file contains the configuration information
for the organizations participating in reciprocal borrowing, and has been
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

## Dockerfile

The "Dockerfile" (and associated "docker_config" directory) for creating the
Docker image are intended for use with the
[umd-lib/k8s-reciprocal-borrowing][k8s-rb] Kubernetes configuration.

The Dockerfile combines the following applications into a single Docker image:

* Apache HTTPD web server
* Shibboleth Service Provider (Shibboleth SP)
* Passenger Phusion app server
* The Reciprocal Borrowing Rails application

Combining all these applications is necessary because:

* The Shibboleth Service Provider runs as a separate process, but communicates
  with Apache via an Apache module (see
  <https://shibboleth.atlassian.net/wiki/spaces/SP3/pages/2065335062/Apache>)

* Phusion Passenger is integrated with Apache as a module
  (see “Apache integration mode” in
  <https://www.phusionpassenger.com/docs/advanced_guides/in_depth/ruby/integration_modes.html>).
  This is necessary because the Shibboleth Service Provider stores the
  Shibboleth attributes received from the Shibboleth IdP as Apache “per-request”
  environment variables (see <https://httpd.apache.org/docs/2.4/env.html>) and
  the only way that the Reciprocal Borrowing application can access them is via
  environment variables set by Phusion Passenger (which as a module, has access
  to the Apache “per-request” environment variables).

* Phusion Passenger is responsible for starting the Reciprocal Borrowing
  application, so it is not necessary to start it as a separate process.

**Note:** Shibboleth attributes could be passed to the Reciprocal Borrowing
application from Apache via HTTP request headers, which would remove the need for
Phusion Passenger, and allow the Reciprocal Borrowing application to run in
a separate container. This method, however, appears to be strongly discouraged
by Shibboleth (see <https://shibboleth.atlassian.net/wiki/spaces/SP3/pages/2065335257/AttributeAccess>).

## Building the Docker Image for K8s Deployment

The following procedure uses the Docker "buildx" functionality and the
Kubernetes "build" namespace to build the Docker image. This procedure should
work on both "arm64" and "amd64" MacBooks.

The image will be automatically pushed to the Nexus.

### Local Machine Setup

See <https://github.com/umd-lib/k8s/blob/main/docs/DockerBuilds.md> in
GitHub for information about setting up a MacBook to use the Kubernetes
"build" namespace.

### Creating the Docker image

1) In an empty directory, checkout the Git repository and switch into the
   directory:

    ```bash
    $ git clone git@github.com:umd-lib/reciprocal-borrowing.git
    $ cd reciprocal-borrowing
    ```

2) Checkout the appropriate Git tag, branch, or commit for the Docker image.

3) Set up an "APP_TAG" environment variable:

    ```bash
    $ export APP_TAG=<DOCKER_IMAGE_TAG>
    ```

   where \<DOCKER_IMAGE_TAG> is the Docker image tag to associate with the
   Docker image. This will typically be the Git tag for the application version,
   or some other identifier, such as a Git commit hash. For example, using the
   Git tag of "1.2.0":

    ```bash
    $ export APP_TAG=1.2.0
    ```

4) Switch to the Kubernetes "build" namespace:

    ```bash
    $ kubectl config use-context build
    ```

5) Create the "docker.lib.umd.edu/reciprocal-borrowing" Docker image:

    ```bash
    $ docker buildx build --no-cache --platform linux/amd64 --push --no-cache \
        --builder=kube  -f Dockerfile -t docker.lib.umd.edu/reciprocal-borrowing:$APP_TAG .
    ```

   The Docker image will be automatically pushed to the Nexus.

## Environment Configuration (Local Development)

The application uses the "dotenv" gem to configure the application environment.
A sample "env_example" file has been provided to assist with this process.

The "env_example" file is mainly for documenting the necessary and optional
environment variables. Creating a ".env" file when using the
"umd-lib/reciprocal-borrowing-dev-env" GitHub repository is not necessary
as the relevant configuration is already in place in the
`config/environments/development_docker.rb` file.

In the production environment, the appropriate environment variables are
provided in the container environment by the "umd-lib/k8s-reciprocal-borrowing"
Kubernetes configuration.

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
[btaa_reciprocal_borrowing]: https://btaa.org/library/programs-and-services/reciprocal-borrowing
[dev-env]: https://github.com/umd-lib/reciprocal-borrowing-dev-env
[k8s-rb]: https://github.com/umd-lib/k8s-reciprocal-borrowing
[incommon]: https://www.incommon.org/
