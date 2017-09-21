class ShibbolethLoginController < ApplicationController
  def home
    organizations = Rails.configuration.shibboleth_config['organizations']
    @org_list = organizations.values.sort_by { |v| v['display_order'] }
  end

  def authenticate # rubocop:disable Metrics/AbcSize
    @lending_org_code = params['lending_org_code']
    organizations = Rails.configuration.shibboleth_config['organizations']

    if organizations.key?(@lending_org_code)
      @org_list = organizations.values.sort_by { |v| v['display_order'] }
      lending_org = organizations[@lending_org_code]
      @lending_org_name = lending_org['name']
      session[:lending_org_code] = @lending_org_code
    else
      # Was not given a valid org_code, treat as 404 error
      redirect_to not_found_url
    end
  end

  def initiator # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    org_code = params['org_code']
    organizations = Rails.configuration.shibboleth_config['organizations']
    sp_login_url = ENV['SP_LOGIN_URL'] || '/Shibboleth.sso/Login'
    callback_url = ENV['CALLBACK_URL'] || '/attributes'

    if organizations.key?(org_code)
      org = organizations[org_code]
      idp_entity_id = org['idp_entity_id']
      session[:auth_org_code] = org_code
      url_encoded_idp_entity_id = ERB::Util.url_encode(idp_entity_id)
      url_with_callback = "#{sp_login_url}?entityID=#{url_encoded_idp_entity_id}&target=#{callback_url}"
      redirect_to url_with_callback
    else
      # Was not given a valid org_code, treat as 404 error
      redirect_to not_found_url
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def callback
    @lending_org_code = session[:lending_org_code]
    @auth_org_code = session[:auth_org_code]

    @env = request.env
    @params = request.params

    @name = @env['displayName'] || "#{@env['givenName']} #{@env['sn']}"
    @name = 'N/A' if @name.strip.empty?
    @affiliation = @env['eduPersonScopedAffiliation'] || 'N/A'
    @principal_name = @env['eduPersonPrincipalName'] || 'N/A'
    @identifier = @env['eduPersonTargetedID'] || 'N/A'
    @entitlement = @env['eduPersonEntitlement'] || 'N/A'

    @user_authorized = user_authorized?(@auth_org_code, @affiliation)

    transaction_entry = "#{@identifier}," \
                        "lending_org_code=#{@lending_org_code || 'N/A'}," \
                        "auth_org_code=#{@auth_org_code || 'N/A'}," \
                        "authorized=#{@user_authorized}"
    TransactionsLogger.info(transaction_entry)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def hosting
  end

  private

    # Returns true is the user is authorized, false otherwise.
    #
    # auth_org_code: The code of the organizaton performing the authorization
    # affiliation: the eduPersonScopedAffiliation parameter from Shibboleth
    def user_authorized?(auth_org_code, affiliation)
      expected_affliation = "member@#{auth_org_code}.edu"
      affiliation.split(';').any? { |a| a.downcase == expected_affliation }
    end
end
