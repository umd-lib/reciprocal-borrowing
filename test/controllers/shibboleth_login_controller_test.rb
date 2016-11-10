require 'test_helper'

class ShibbolethLoginControllerTest < ActionController::TestCase
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

  test 'should get initiator' do
    get :initiator, org_code: 'maryland'
    assert_response :redirect
  end

  test 'should get callback' do
    get :callback
    assert_response :success
  end
end
