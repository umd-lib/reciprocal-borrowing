# Override settings in the "development.rb" configuration file when
# running in development mode and using Passenger Phusion.
Rails.application.configure do
  # Add "borrow-local" (the hostname used by the Docker container) to the list
  # of allowed hosts.
  config.hosts << "borrow-local"

  # The default Rails "config.file_watcher" setting of
  # "ActiveSupport::EventedFileUpdateChecker" does not appear to work when
  # running in a Docker image on M-series (Apple Silicon) laptops, so modifying
  # to use an alternate file watcher
  config.file_watcher = ActiveSupport::FileUpdateChecker

  # .env Environment Variables
  ENV["SECRET_KEY_BASE"] = "449dd5287e47b8bbe4c85bd38424a10a105b1f84ff44ade491c48a791c48ad09dc64c548e7328a04b3634dc4d385bd7e3a7ad3e77d6c65a433f2b27337f3327f"

  ENV["ENVIRONMENT_BANNER_ENABLED"] = "true"
  ENV["ENVIRONMENT_BANNER_BACKGROUND"] = "#008080"
  ENV["ENVIRONMENT_BANNER_FOREGROUND"] = "#ffffff"
  ENV["ENVIRONMENT_BANNER"] = "Docker Development Environment"

  # Override the Shibboleth configuration for each of the organizations to
  # use the local IdP.
  shibboleth_config = config_for(:shibboleth_config)
  orgs = shibboleth_config[:organizations]
  orgs.each do |key, value|
    value[:idp_entity_id] = "https://shib-idp/idp/shibboleth"
  end

  shibboleth_config[:organizations] = orgs
  config.shibboleth_config = shibboleth_config
end
