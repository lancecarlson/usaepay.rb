require "test_helper"

class UsaepayTest < Minitest::Test
  def setup
    @wsdl = ENV.fetch("WSDL")
    @source_key = ENV.fetch("SOURCE_KEY")
    @pin = ENV.fetch("PIN")
  end

  def test_that_it_has_a_version_number
    refute_nil ::Usaepay::VERSION
  end

  def test_run_a_test_report
    USAePay::Client.new @wsdl, {
        :source_key => @source_key,
        :pin => @pin
      } do |c|
      body = {
        :search => [
          :item => [
            {:field => 'amount', :type => 'gt', :value => '0.01'},
            {:field => 'amount', :type => 'lt', :value => '100'}
          ]
        ],
        :match_all => false,
        :start => 0,
        :limit => 100,
        :sort => 'created',
        :token => c.token
      }
      response = c.call(:search_transactions, message: body)
      p response.body
    end
  end
end
