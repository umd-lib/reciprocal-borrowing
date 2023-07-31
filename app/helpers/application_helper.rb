module ApplicationHelper
  def umd_lib_environment_banner
    return unless environment

    content_tag :div, "#{environment} Environment",
                class: 'environment-banner',
                id: "environment-#{environment.downcase}"
  end

  private

    # Returns a string indicating the current local/dev/stage environment,
    # or nil for the production environment.
    def environment
      return 'Local' if Rails.env.development?

      hostname = `hostname -s`
      return 'Development' if hostname =~ /dev$/
      return 'Staging' if hostname =~ /stage$/

      # Otherwise returns nil, indicating production environment
    end
end
