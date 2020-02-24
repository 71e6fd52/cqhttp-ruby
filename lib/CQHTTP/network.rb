# frozen_string_literal: true

module CQHTTP
  # get, post
  #
  # Example:
  #   network = Network.new :get, 'http://localhost:5700'
  #   json = network.send_req '/get_login_info'
  class Network
    # @param type [:get, :form, :json] the way sending request
    # @param host [String] API address, like 'http://localhost:5700'
    # @param token [String] access_token
    def initialize(type, host, token = nil)
      host += '/' unless host.end_with? '/'
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
    # @param result [Boolean] return result
    def send_req(url, body, type: nil, result: true)
      type = type&.to_sym || @type
      raise type unless %i[get form json].include? type

      method(type).call(url, body, result: result)
    end
    alias call send_req

    # get url
    #
    # @param uri [URI]
    # @param params [Hash] url query
    # @param result [Boolean] return result
    # @return [Hash]
    def get(uri, params = nil, result: true)
      uri = full_uri(uri)
      params = (params || {}).merge(access_token: @token) unless @token.nil?
      uri.query = URI.encode_www_form params if params
      puts 'GET URL:', uri if $DEBUG
      error Net::HTTP.get_response(uri), result
    end

    # post to url by form
    #
    # @note not supporting access_token
    # @param uri [URI]
    # @param body [Hash] post body
    # @param result [Boolean] return result
    # @return [Hash]
    def post_form(uri, body, result: true)
      raise 'Not supporting auth for form' unless @token.nil?

      uri = full_uri(uri)
      puts 'POST URL:', uri if $DEBUG
      error Net::HTTP.post_form(uri, body), result
    end
    alias form post_form

    # post to url by json
    #
    # @param uri [URI]
    # @param body [Hash] post body
    # @param result [Boolean] return result
    # @return [Hash]
    def post_json(uri, body, result: true)
      uri = full_uri(uri)
      puts 'POST URL:', uri if $DEBUG
      puts 'POST JSON:', JSON.pretty_generate(body) if $DEBUG
      error Net::HTTP.post(
        uri,
        body.to_json,
        { 'Content-Type' => 'application/json' }.merge(
          @token&.then { { 'Authorization' => "Bearer #{_1}" } } || {},
        ),
      ), result
    end
    alias json post_json

    private

    def full_uri(uri)
      URI(@host + uri)
    end

    # handle result error
    #
    # @param res [Net::HTTPResponse]
    # @param result [Boolean] return result
    # @return Hash
    def error(res, result = true)
      http_error res
      return unless result

      coolq_error JSON.parse res.body
    end

    # handle http response
    #
    # @param res [Net::HTTPResponse]
    def http_error(res)
      case res.code.to_i
      when 200 then return
      when 400 then raise 'POST 请求的 Content-Type 不正确'
      when 401 then raise 'token 不符合'
      when 404 then raise 'API 不存在'
      when 405 then raise '请求方式不支持'
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
