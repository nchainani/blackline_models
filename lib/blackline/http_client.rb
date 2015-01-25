class HttpClient
  def self.wrap_and_delegate(*names)
    names.each do |name|
      define_singleton_method(name) do |url, options = {}, &block|
        client.__send__(name, url, options) do |http_response|
          resp = HttpClient::Response.new http_response
          block.call(resp)
        end
      end
    end
  end

  wrap_and_delegate :get, :post

  def self.getImage(url, options = {}, &block)
    imageClient.get(url, options) do |http_response|
      resp = HttpClient::Response.new http_response
      block.call(resp)
    end
  end

  def self.client
    @klient ||= begin
      klient = AFMotion::Client.build("") do
        header "BLACKLINE_CLIENT_TOKEN", BLACKLINE_CLIENT_TOKEN
        response_serializer :json
      end
      securityPolicy = AFSecurityPolicy.alloc.init
      securityPolicy.allowInvalidCertificates = true
      klient.securityPolicy = securityPolicy
      klient
    end
  end

  def self.imageClient
    @imageKlient ||= begin
      klient = AFMotion::Client.build(BLACKLINE_SERVER) do
        header "BLACKLINE_CLIENT_TOKEN", BLACKLINE_CLIENT_TOKEN
        response_serializer :http
      end
      securityPolicy = AFSecurityPolicy.alloc.init
      securityPolicy.allowInvalidCertificates = true
      klient.securityPolicy = securityPolicy
      klient
    end
  end

  class Response
    attr_accessor :response
    def initialize(response)
      @response = response
    end

    def ok?
      @response.success?
    end

    def body
      @response.object
    end

    def errorString
      return nil if ok? || @response.error.nil?
      str = BW::JSON.parse(@response.body.to_s.dup)['error']['message'] rescue (@response.body || "Something went wrong, error #{@response.error.domain}.")
    end
  end
end