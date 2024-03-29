# rubocop:disable Style/ClassVars, Rails/HelperInstanceVariable
module UmdLibEnvironmentBannerHelper
  # True if the banner has been initialized, false otherwise
  @@banner_initialized = false
  # Holds the banner object
  @@banner = nil
  # Holds the HTML for the banner (if any)
  @@banner_html = nil

  # Initializes the banner
  def self.initialize # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # Uses @@banner_initialized to skip regenerating banner each time the
    # module is called.
    unless @@banner_initialized
      @@banner_initialized = true
      return if ENV['ENVIRONMENT_BANNER_ENABLED'] == 'false'

      # The EnvVarsEnvironmentBanner banner is used, if enabled, otherwise
      # defaults to the HostEnvironmentBanner implementation
      banner = EnvVarsEnvironmentBanner.new
      banner = DevelopmentEnvironmentBanner.new unless banner.enabled?

      @@banner = banner

      if @@banner.enabled?
        # Configure banner HTML
        css_options = @@banner.css_options

        # Sort to get consistent ordering of keys
        css_string = css_options.sort.to_h.map { |key, value| "#{key}='#{value}'" }.join(' ')
        banner_text = @@banner.text
        @@banner_html = "<div #{css_string}>#{banner_text}</div>".html_safe # rubocop:disable Rails/OutputSafety
        return @@banner_html
      else
        @@banner_html = nil
      end
    end

    @@banner
  end

  # Resets the banner -- intended be used only for testing
  def self.reset
    @@banner_initialized = false
    @@banner = nil
    @@banner_html = nil
  end

  # https://confluence.umd.edu/display/LIB/Create+Environment+Banners
  #
  def umd_lib_environment_banner
    UmdLibEnvironmentBannerHelper.initialize unless @@banner_initialized
    @@banner_html
  end

  # When the banner is visible, add the extra-padding-top class
  # to increase body padding
  def extra_padding_top
    UmdLibEnvironmentBannerHelper.initialize unless @@banner_initialized

    return unless @@banner&.enabled?

    'extra-padding-top'
  end

  # Banner implementation classes -- these are not intended to be called
  # directly

  # Returns an environment banner based on ENV config properties
  class EnvVarsEnvironmentBanner
    attr_accessor :text, :css_options

    def initialize
      @text = banner_text
      @css_options = banner_css_options
      @enabled = banner_enabled(@text)
    end

    # Returns the text to display in the environment banner.
    #
    # Implementation: Returns the value of the ENVIRONMENT_BANNER property, if
    # non-empty.
    #
    # This method may return nil, if there is no ENVIRONMENT_BANNER
    def banner_text
      banner_text = ENV.key?('ENVIRONMENT_BANNER') ? ENV['ENVIRONMENT_BANNER'] : ''
      ENV['ENVIRONMENT_BANNER'].freeze unless banner_text.empty?
    end

    # Returns the CSS options to use with the environment banner.
    #
    # Implementation: Uses the ENVIRONMENT_BANNER_BACKGROUND and
    # ENVIRONMENT_BANNER_FOREGROUND properties, if provided.
    def banner_css_options # rubocop:disable Metrics/MethodLength
      css_options = {}
      css_style = ''

      background_color = ENV.key?('ENVIRONMENT_BANNER_BACKGROUND') ? ENV['ENVIRONMENT_BANNER_BACKGROUND'] : ''
      foreground_color = ENV.key?('ENVIRONMENT_BANNER_FOREGROUND') ? ENV['ENVIRONMENT_BANNER_FOREGROUND'] : ''

      css_style = "background-color: #{background_color};" unless background_color.empty?

      unless foreground_color.empty?
        css_style += " color: #{foreground_color};"
        css_style.strip!
      end

      css_options[:style] = css_style unless css_style.empty?

      css_options[:class] = 'environment-banner'
      css_options
    end

    # Returns true if the banner should be displayed, false otherwise.
    #
    # text - the text (if any) being displayed in the banner
    def banner_enabled(text)
      env_var_enabled = ENV.fetch('ENVIRONMENT_BANNER_ENABLED', '')

      # Don't display the banner if there is no text
      return false if text.blank?

      # Display if ENVIRONMENT_BANNER_ENABLED is not provided or empty
      return true if env_var_enabled.blank?

      # Any value other than "true" is false
      env_var_enabled.strip.downcase == 'true'
    end

    def enabled?
      @enabled
    end
  end

  # Returns a default environment banner for Rails development environment
  class DevelopmentEnvironmentBanner
    attr_accessor :text, :css_options

    def initialize
      environment_name = environment_name()
      if environment_name.nil?
        @enabled = false
        return
      end
      @text = "#{environment_name} Environment"
      @css_options = {}
      @css_options[:id] = "environment-#{environment_name.downcase}"
      @css_options[:class] = 'environment-banner'
      @enabled = !environment_name.empty?
    end

    def enabled?
      @enabled
    end

    private

      def environment_name
        (Rails.env.development? || Rails.env.vagrant?) ? 'Local' : nil # rubocop:disable Style/TernaryParentheses, Rails/UnknownEnv
      end
  end
end

# here we reopen the ApplicationController (after Rails has started)
# and stick in our helper module.
Rails.application.config.after_initialize do
  ApplicationController.class_eval do
    include UmdLibEnvironmentBannerHelper
    helper_method :umd_lib_environment_banner
  end
end
# rubocop:enable Style/ClassVars, Rails/HelperInstanceVariable
