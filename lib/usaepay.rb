require 'savon'
require 'forwardable'
require 'net/https'

require "usaepay/version"

module USAePay
  class Client
    extend Forwardable
    def_delegator :@savon, :call
    def initialize(wsdl, opts={})
      @wsdl = wsdl
      @source_key = opts[:source_key] || raise('Missing source_key')
      @pin = opts[:pin]
      @savon = Savon.client(wsdl: @wsdl) do
        convert_request_keys_to :camelcase
        namespace_identifier :ns1
      end
      yield self if block_given?
    end

    def sha1
      Digest::SHA1.hexdigest(@source_key.to_s + seed.to_s + @pin.to_s)
    end

    def seed
      @seed ||= Time.now.to_i.to_s + rand(32768).to_s
    end

    def token
      {
        :source_key => @source_key,
        :pin_hash => {
          :type => "sha1",
          :seed => seed,
          :hash_value => sha1
        },
        :client_ip => "127.0.0.1"
      }
    end
  end
end