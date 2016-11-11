class ShibbolethLoginController < ApplicationController
  def home
    organizations = Rails.configuration.shibboleth_config['organizations']
    @org_list = organizations.values.sort_by { |v| v['display_order'] }
  end

  def initiator # rubocop:disable Metrics/MethodLength
    org_code = params['org_code']
    organizations = Rails.configuration.shibboleth_config['organizations']
    sp_login_url = 'https://192.168.33.20/Shibboleth.sso/Login'
    callback_url = 'https://192.168.33.20/callback'

    if organizations.key?(org_code)
      org = organizations[org_code]
      idp_entity_id = org['idp_entity_id']
      url_encoded_idp_entity_id = ERB::Util.url_encode(idp_entity_id)
      url_with_callback = "#{sp_login_url}?entityID=#{url_encoded_idp_entity_id}&target=#{callback_url}"
      redirect_to url_with_callback
    else
      # Was not given a valid org_code, treat as 404 error
      redirect_to not_found_url
    end
  end

  def callback
    @env = request.env
    @params = request.params
  end
end
