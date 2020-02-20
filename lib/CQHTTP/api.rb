# frozen_string_literal: true

module CQHTTP
  # Call API
  #
  # @example
  #   @api = CQHTTP::API.new
  #   @api.send_group_msg(group_id: '123456', message: 'test')
  class API
    # @return [Hash] api list with method as the key and arguments as values
    attr_reader :func_list

    # init
    #
    # @param host [String] API address, like 'http://localhost:5700'
    # @param way [:get, :form, :json, :callback] the way sending request
    # @param token [String] [access token](https://cqhttp.cc/docs/#/API?id=请求方式)
    # @param callback [Proc] only need if `way` is `callback`
    def initialize(host: 'http://localhost:5700', way: :json, token: nil,
                   callback: nil)
      @func_list = File.open(File.join(File.dirname(__FILE__), 'API.json')) do
        JSON.parse(_1.read, symbolize_names: true)
      end.freeze
      if way.to_sym == :callback
        raise 'Not pass callback' if callback.nil?

        @network = callback
      else
        @network = CQHTTP::Network.new(way, host, token)
      end
    end

    def respond_to_missing?(method, include_private = false)
      @func_list.include?(method) || super
    end

    # All API generated form
    #  [API 描述] (https://cqhttp.cc/docs/#/API?id=api-列表)
    # @example
    #   @api.send_group_msg('123456', 'test') # by document order
    #   @api.send_group_msg(group_id: '123456', message: 'test') # use keyword
    def method_missing(name, *user_args)
      return super unless respond_to_missing? name

      args = gen_args name, user_args
      args.freeze
      return super if args.nil?
      return super if args.value? nil

      call_network name, args
    end

    private

    ####################################################################
    #                             api_call                             #
    ####################################################################

    def gen_args(name, user_args)
      args = @func_list[name.to_sym]
      return {} if args == {}
      return hash_to_args(args, user_args) if user_args[0].class == {}.class

      array_to_args(args, user_args)
    end

    def hash_to_args(default, user)
      return unless user.size == 1

      default.merge(user[0].delete_if { |key, _value| !default.key? key })
    end

    def array_to_args(default, user)
      return if user.size > default.size

      it = default.each_key
      args = user.each_with_object({}) { |value, obj| obj[it.next] = value }
      hash_to_args default, [args]
    end

    def call_network(name, args)
      @network.call(name.to_s, args)
    end
  end
end
