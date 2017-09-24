module CQHTTP
  # get, post
  #
  # Example:
  #   get = Network.gen :get, 'http://localhost:5700'
  #   json = get.call '/get_login_info'
  module Network
    # gen lambda
    #
    # type: Symbol or String, 'get', 'form' or 'json;
    # host: String: API address, like 'http://localhost:5700'
    def self.gen(type, host) # => lambda
      case type.to_sym
      when :get then ->(url, param = nil) { Network.get URI(host + url), param }
      when :form then ->(url, body) { Network.post_form URI(host + url), body }
      when :json then ->(url, body) { Network.post_json URI(host + url), body }
      else raise type
      end
    end

    # get url
    #
    # uri: URI
    # params (optional): Hash, url query
    def self.get(uri, params = nil) # => Hash
      puts 'GET URL:', uri if $DEBUG
      uri.query = URI.encode_www_form params if params
      error Net::HTTP.get_response(uri)
    end

    # post to url by form
    #
    # uri: URI
    # body: Hash, post body
    def self.post_form(uri, body) # => Hash
      puts 'POST URL:', uri if $DEBUG
      error Net::HTTP.post_form(uri, body)
    end

    # post to url by json
    #
    # uri: URI
    # body: Hash, post body
    def self.post_json(uri, body)
      puts 'POST URL:', uri if $DEBUG
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
