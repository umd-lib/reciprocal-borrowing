class ShibbolethLoginController < ApplicationController
  def home
  end

  def initiator
    @organization = params['org']
    if @organization == 'umd'
      redirect_to 'https://192.168.33.20/Shibboleth.sso/Login?target=https://192.168.33.20/callback'
    end
  end

  def callback
  end
end
