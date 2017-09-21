require 'test_helper'

class ShibbolethLoginControllerTest < ActionController::TestCase # rubocop:disable Metrics/ClassLength
  test 'should get home' do
    get :home
    assert_response :success
  end

  test 'home should contain an entry for each organization' do
    get :home
    organizations = Rails.configuration.shibboleth_config['organizations']
    org_list = organizations.values.sort_by { |v| v['display_order'] }

    # Number of entries should be the same as number of organizations
    org_count = org_list.size
    assert_select 'ul#organization_list' do
      assert_select 'li', org_count
    end

    org_list.each do |org|
      org_code = org['code']
      org_name = org['name']

      entry_id = "#{org_code}_entry"
      assert_select "ul#organization_list>li##{entry_id}" do
        assert_select 'a', text: org_name
      end
    end
  end

  test 'authenticate should exist for each organization' do
    organizations = Rails.configuration.shibboleth_config['organizations']
    org_list = organizations.values.sort_by { |v| v['display_order'] }
    org_list.each do |lending_org|
      lending_org_code = lending_org['code']
      get :authenticate, lending_org_code: lending_org_code
      assert_response :success

      # authenicate page should contain organization full name
      assert_select '.lending-org-name', text: lending_org['name']
    end
  end

  test 'authenticate should not contain link to lending org in org list' do
    organizations = Rails.configuration.shibboleth_config['organizations']
    org_list = organizations.values.sort_by { |v| v['display_order'] }
    org_list.each do |lending_org|
      lending_org_code = lending_org['code']
      get :authenticate, lending_org_code: lending_org_code
      assert_response :success

      org_list.each do |initiate_org|
        initiate_org_code = initiate_org['code']
        list_id = "#{initiate_org_code}_entry"

        # Make sure each organization has an initiate link, except for the
        # lending organization
        assert_select "ul#organization_list>li##{list_id}" do
          if initiate_org_code == lending_org_code
            assert_select 'a', { count: 0 }, "Link found for #{initiate_org_code}"
          else
            assert_select 'a', count: 1
          end
        end
      end
    end
  end

  test 'authenticate with invalid org code should show 404 error page' do
    get :authenticate, lending_org_code: 'org_does_not_exist'
    assert_redirected_to controller: 'errors', action: 'not_found'
  end

  test 'should get initiator' do
    get :initiator, org_code: 'umd'
    assert_response :redirect
  end

  test 'initiator with invalid org code should show 404 error page' do
    get :initiator, org_code: 'org_does_not_exist'
    assert_redirected_to controller: 'errors', action: 'not_found'
  end

  test 'should get callback' do
    get :callback
    assert_response :success
  end

  test 'callback should show eligible for valid eduPersonScopedAffiliation' do
    session[:lending_org_code] = 'umd'
    session[:auth_org_code] = 'uiowa'
    @request.env['eduPersonScopedAffiliation'] = 'member@uiowa.edu'

    get :callback

    assert_response :success
    assert_select '.user-authorized'
  end

  test 'callback should show eligible for valid eduPersonScopedAffiliation, ignoring case' do
    session[:lending_org_code] = 'umd'
    session[:auth_org_code] = 'uiowa'
    @request.env['eduPersonScopedAffiliation'] = 'Member@uiowa.edu'

    get :callback

    assert_response :success
    assert_select '.user-authorized'
  end

  test 'callback should show not eligible for invalid eduPersonScopedAffiliation' do
    # eduPersonScopedAffiliation is nil
    session[:lending_org_code] = 'umd'
    session[:auth_org_code] = 'uiowa'

    get :callback

    assert_response :success
    assert_select '.user-not-authorized'

    # eduPersonScopedAffiliation is N/A
    session[:lending_org_code] = 'umd'
    session[:auth_org_code] = 'uiowa'
    @request.env['eduPersonScopedAffiliation'] = 'N/A'

    get :callback

    assert_response :success
    assert_select '.user-not-authorized'

    # auth_org code does not match eduPersonScopedAffiliation
    session[:lending_org_code] = 'umd'
    session[:auth_org_code] = 'uiowa'
    @request.env['eduPersonScopedAffiliation'] = 'member@rutgers.edu'

    get :callback

    assert_response :success
    assert_select '.user-not-authorized'
  end
end
