Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'shibboleth_login#home'

  get 'authenticate/:lending_org_code' => 'shibboleth_login#authenticate', as: :authenticator
  get 'initiate/:org_code' => 'shibboleth_login#initiator', as: :initiator

  get 'attributes' => 'shibboleth_login#callback'

  get 'hosting' => 'shibboleth_login#hosting'

  # Reconfigure error routes to point to dynamic error pages
  match '/404', to: 'errors#not_found', via: :all, as: :not_found
  match '/500', to: 'errors#internal_server_error', via: :all, as: :server_error
end
