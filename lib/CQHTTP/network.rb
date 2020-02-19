# frozen_string_literal: true

module CQHTTP
  # get, post
  #
  # Example:
  #   network = Network.new :get, 'http://localhost:5700'
  #   json = network.send '/get_login_info'
  class Network
    # @param type [Symbol] 'get', 'form' or 'json'
    # @param host [String] API address, like 'http://localhost:5700'
    # @param token [String] access_token
    def initialize(type, host, token = nil)
      @host = host
      @token = token
      @type = type.to_sym
      raise @type unless %i[get form json].include? @type
      raise 'Not supporting auth for form' if @type == :form && !token.nil?
    end

    # send api request
    #
    # @param url [String] api path
    # @param body [Hash] api argument
    # @param type [Symbol] override default type
    def send(url, body, type: nil)
      type = type&.to_sym || @type
      raise type unless %i[get form json].include? type

      method(type).call(url, body)
    end

    # get url
    #
    # @param uri [URI]
    # @param params [Hash] url query
    # @return Hash
    def get(uri, params = nil)
      uri = full_uri(uri)
      params = (params || {}).merge(access_token: @token) unless @token.nil?
      uri.query = URI.encode_www_form params if params
      puts 'GET URL:', uri if $DEBUG
      error Net::HTTP.get_response(uri)
    end

    # post to url by form
    #
    # @param uri [URI]
    # @param body [Hash] post body
    # @return Hash
    def post_form(uri, body)
      raise 'Not supporting auth for form' unless @token.nil?

      uri = full_uri(uri)
      puts 'POST URL:', uri if $DEBUG
      error Net::HTTP.post_form(uri, body)
    end
    alias form post_form

    # post to url by json
    #
    # @param uri [URI]
    # @param body [Hash] post body
    # @return Hash
    def post_json(uri, body)
      uri = full_uri(uri)
      puts 'POST URL:', uri if $DEBUG
      puts 'POST JSON:', JSON.pretty_generate(body) if $DEBUG
      error Net::HTTP.post(
        uri,
        body.to_json,
        { 'Content-Type' => 'application/json' }.merge(
          @token&.then { { 'Authorization' => "Bearer #{_1}" } } || {},
        ),
      )
    end
    alias json post_json

    private

    def full_uri(uri)
      URI(@host + uri)
    end

    # handle result error
    #
    # @param res [Net::HTTPResponse]
    # @return Hash
    def error(res)
      coolq_error http_error res
    end

    # unwrap http response
    #
    # @param res [Net::HTTPResponse]
    # @return Hash
    def http_error(res)
      case res.code.to_i
      when 200 then return JSON.parse res.body
      when 405 then raise '请求方式不支持'
      when 401 then raise 'token 不符合'
      when 400 then raise 'POST 请求的 Content-Type 不正确'
      when 404 then raise 'API 不存在'
      end
      raise res.code.to_s
    end

    # handle coolq error
    #
    # @param json [Hash]
    # @return Hash
    def coolq_error(json)
      case json['retcode'].to_i
      when 0 then return json
      when 1 then return json
      when 100 then raise '参数错误'
      when 102 then raise '没有权限'
      end
      raise json['retcode'].to_s
    end
  end
end
