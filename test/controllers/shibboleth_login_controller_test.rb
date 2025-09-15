require 'test_helper'

class ShibbolethLoginControllerTest < ActionController::TestCase
  test 'should get home' do
    get :home
    assert_response :success
  end

  test 'home should contain an entry for each organization' do
    get :home
    organizations = Rails.configuration.shibboleth_config['organizations']
    org_list = organizations.values.sort_by { |v| v[:display_order] }

    # Number of entries should be the same as number of organizations
    org_count = org_list.size
    assert_select 'ul#organization_list' do
      assert_select 'li', org_count
    end

    org_list.each do |org|
      org_code = org[:code]
      org_name = org[:name]

      entry_id = "#{org_code}_entry"
      assert_select "ul#organization_list>li##{entry_id}" do
        assert_select 'a', text: org_name
      end
    end
  end

  test 'should get initiator' do
    get :initiator, params: { org_code: 'umd' }
    assert_response :redirect
  end

  test 'initiator with invalid org code should show 404 error page' do
    get :initiator, params: { org_code: 'org_does_not_exist' }
    assert_redirected_to controller: 'errors', action: 'not_found'
  end

  test 'should get callback' do
    get :callback
    assert_response :success
  end

  test 'callback should show eligible for valid eduPersonEntitlement' do
    @request.env['eduPersonEntitlement'] = 'https://borrow.btaa.org/reciprocalborrower'

    get :callback

    assert_response :success
    assert_select '.user-authorized'
  end

  test 'callback should show eligible for valid eduPersonEntitlement, ignoring case' do
    @request.env['eduPersonEntitlement'] = 'HTTPS://borrow.BTAA.org/reciprocalBorrower'

    get :callback

    assert_response :success
    assert_select '.user-authorized'
  end

  test 'callback should show not eligible for invalid eduPersonEntitlement' do
    # eduPersonEntitlement is nil

    get :callback

    assert_response :success
    assert_select '.user-not-authorized'

    # eduPersonEntitlement is N/A
    @request.env['eduPersonEntitlement'] = 'N/A'

    get :callback

    assert_response :success
    assert_select '.user-not-authorized'

    # eduPersonEntitlement is some other string
    @request.env['eduPersonEntitlement'] = 'not_a_reciprocal_borrower'

    get :callback

    assert_response :success
    assert_select '.user-not-authorized'
  end
end
