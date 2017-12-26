module CQHTTP
  # get, post
  #
  # Example:
  #   get = Network.gen :get, 'http://localhost:5700'
  #   json = get.call '/get_login_info'
  module Network
    # gen lambda
    #
    # @param [Symbol or String] type 'get', 'form' or 'json
    # @param [String] host API address, like 'http://localhost:5700'
    #
    # @return [lambda]
    def self.gen(type, host)
      case type.to_sym
      when :get then ->(url, param = nil) { Network.get URI(host + url), param }
      when :post then ->(url, body) { Network.post URI(host + url), body }
      else raise type
      end
    end

    # get url
    #
    # @param [URI] uri
    # @param [Hash] params (optional) url query
    #
    # @return [Hash]
    def self.get(uri, params = nil)
      uri.query = URI.encode_www_form params if params
      puts 'GET URL:', uri if $DEBUG
      error Net::HTTP.get_response(uri)
    end

    # post to url by json
    #
    # @param [URI] uri
    # @param [Hash] body post body
    #
    # @return Hash
    def self.post(uri, body)
      puts 'POST URL:', uri if $DEBUG
      puts 'POST JSON:', JSON.pretty_generate(body) if $DEBUG
      error Net::HTTP.post(
        uri,
        body.to_json,
        'Content-Type' => 'application/json'
      )
    end

    private_class_method

    def self.error(res)
      coolq_error http_error res
    end

    def self.http_error(res)
      case res.code.to_i
      when 200 then return JSON.parse res.body
      when 405 then raise '请求方式不支持'
      when 401 then raise 'token 不符合'
      when 400 then raise 'POST 请求的 Content-Type 不正确'
      when 404 then raise 'API 不存在'
      end
      raise res.code.to_s
    end

    def self.coolq_error(json)
      case json['retcode'].to_i
      when 0 then return json
      when 100 then raise '参数错误'
      when 102 then raise '没有权限'
      end
      raise json['retcode'].to_s
    end
  end
end
