require 'rest_client'
require 'base64'
require 'json'

module Iugu
  class APIRequest
    def self.request(method, url, data = {}, options = {})
      api_key = options[:api_key] || Iugu.api_key || Iugu::Utils.auth_from_env
      raise Iugu::AuthenticationException, "Chave de API não configurada. Utilize Iugu.api_key = ... para configurar." if api_key.nil?

      rsa_key = options[:rsa_key]

      data.merge!('api_token' => api_key) unless rsa_key.to_s.empty?

      handle_response(self.send_request(api_key, method, url, data, rsa_key))
    end

    private

    def self.send_request(api_key, method, url, data, rsa_key = nil)
      RestClient::Request.execute(build_request(api_key, method, url, data, rsa_key))
    rescue RestClient::ResourceNotFound
      raise ObjectNotFound
    rescue RestClient::UnprocessableEntity => ex
      raise RequestWithErrors.new JSON.parse(ex.response)['errors']
    rescue RestClient::BadRequest => ex
      raise RequestWithErrors.new JSON.parse(ex.response)['errors']
    end

    def self.build_request(api_key, method, url, data, rsa_key)
      request_time = Time.now.iso8601
      signature = build_signature(api_key, method, url, request_time, data.to_json, rsa_key) unless rsa_key.to_s.empty?

      {
        verify_ssl: true,
        headers: default_headers(api_key, rsa_key, request_time, signature),
        method: method,
        payload: data.to_json,
        url: url,
        timeout: 30
      }
    end

    def self.build_signature(api_key, method, url, request_time, data, rsa_key)
      path = URI.parse(url).path

      ret_sign = "";
      pattern = "#{method}|#{path}\n#{api_key}|#{request_time}\n#{data}"
      signature = rsa_key.sign(OpenSSL::Digest::SHA256.new, pattern)
      ret_sign = Base64.strict_encode64(signature)
      return ret_sign
    end

    def self.handle_response(response)
      response_json = JSON.parse(response.body)
      raise ObjectNotFound if response_json.is_a?(Hash) && response_json['errors'] == 'Not Found'
      raise RequestWithErrors, response_json['errors'] if response_json.is_a?(Hash) && response_json['errors'] && response_json['errors'].length > 0
      response_json
    rescue JSON::ParserError
      raise RequestFailed
    end

    def self.default_headers(api_key, rsa_key = nil, request_time = nil, signature = nil)
      default_headers = {
        authorization: 'Basic ' + Base64.strict_encode64(api_key + ":"),
        accept: 'application/json',
        accept_charset: 'utf-8',
        user_agent: 'Iugu RubyLibrary',
        accept_language: 'pt-br;q=0.9,pt-BR',
        content_type: 'application/json; charset=utf-8'
      }

      unless rsa_key.to_s.empty?
        default_headers['Request-Time'] = request_time
        default_headers["Signature"] = "signature=#{signature}"
      end

      default_headers
    end
  end
end
