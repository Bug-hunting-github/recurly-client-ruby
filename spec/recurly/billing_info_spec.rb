require 'spec_helper'

describe BillingInfo do

  let(:binfo) {
    BillingInfo.new(
      :first_name     => "Larry",
      :last_name      => "David",
      :card_type      => "Visa",
      :last_four      => "1111",
      :city           => "Los Angeles",
      :state          => "CA",
    )
  }

  it "must serialize" do
    binfo.gateway_token = "gatewaytoken123"
    binfo.gateway_code = "gatewaycode123"
    binfo.to_xml.must_equal <<XML.chomp
<billing_info>\
<card_type>Visa</card_type>\
<city>Los Angeles</city>\
<first_name>Larry</first_name>\
<gateway_code>gatewaycode123</gateway_code>\
<gateway_token>gatewaytoken123</gateway_token>\
<last_four>1111</last_four>\
<last_name>David</last_name>\
<state>CA</state>\
</billing_info>
XML
  end

  describe ".find" do
    it "must return an account's billing info when available" do
      stub_api_request(
        :get, 'accounts/abcdef1234567890/billing_info', 'billing_info/show-200'
      )
      billing_info = BillingInfo.find 'abcdef1234567890'
      billing_info.must_be_instance_of BillingInfo
      billing_info.first_name.must_equal 'Larry'
      billing_info.last_name.must_equal 'David'
      billing_info.card_type.must_equal 'Visa'
      billing_info.last_four.must_equal '1111'
      billing_info.city.must_equal 'Los Angeles'
      billing_info.state.must_equal 'CA'
    end

    it "must return an accounts billing info as a bank account when available" do
      stub_api_request(
        :get, 'accounts/abcdef1234567890/billing_info', 'billing_info/show-200-bank-account'
      )
      billing_info = BillingInfo.find 'abcdef1234567890'
      billing_info.name_on_account.must_equal 'Larry David'
      billing_info.account_type.must_equal 'checking'
      billing_info.last_four.must_equal '3123'
      billing_info.routing_number.must_equal '12309812'
    end

    it "must raise an exception when unavailable" do
      stub_api_request(
        :get, 'accounts/abcdef1234567890/billing_info', 'accounts/show-404'
      )
      proc { BillingInfo.find 'abcdef1234567890' }.must_raise Resource::NotFound
    end
  end

  describe 'marshal methods' do
    it 'must return the same instance variables' do
      stub_api_request(
        :get, 'accounts/abcdef1234567890/billing_info', 'billing_info/show-200-bank-account'
      )
      billing_info = BillingInfo.find 'abcdef1234567890'
      billing_info_from_dump = Marshal.load(Marshal.dump(billing_info))

      billing_info.instance_variables.must_equal billing_info_from_dump.instance_variables
    end

    it 'must return the same values' do
      stub_api_request(
        :get, 'accounts/abcdef1234567890/billing_info', 'billing_info/show-200-bank-account'
      )
      billing_info = BillingInfo.find 'abcdef1234567890'
      billing_info_from_dump = Marshal.load(Marshal.dump(billing_info))

      billing_info.type.must_equal billing_info_from_dump.type
    end
  end
end
