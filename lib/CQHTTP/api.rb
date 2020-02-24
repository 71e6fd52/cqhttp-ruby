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
      @func_list.include?(method.to_sym) ||
        method.to_s.then { _1.end_with?('_async') &&
          respond_to_missing?(_1[..-7]) } ||
        super
    end

    # All API generated form
    #  [API 描述] (https://cqhttp.cc/docs/#/API?id=api-列表)
    # @note Don't pass argument by both argument and keyword
    # @param args [Array<Object>]
    # @param args_kw [Hash<Symbol, Object>]
    # @return [Hash]
    # @example
    #   @api.send_group_msg('123456', 'test') # by document order
    #   @api.send_group_msg(group_id: '123456', message: 'test') # use keyword
    def method_missing(name, *args, **args_kw)
      return super unless respond_to_missing? name

      (name_base, sync) = name.to_s.match(/^(.+?)(_async)?$/)
                              .then { |m| [m[1].to_sym, m[2].nil?] }
      args = gen_args name_base, args, args_kw
      args.freeze
      raise ArgumentError, 'not privide enough argument' if args.value? nil

      @network.call(name.to_s, args, result: sync)
    end

    private

    ####################################################################
    #                             api_call                             #
    ####################################################################

    def gen_args(name, args_arr, args_kw)
      args = @func_list[name.to_sym]
      if args_arr.empty?
        if args_kw.empty?
          {}
        else
          hash_to_args(args, args_kw)
        end
      else
        array_to_args(args, args_arr)
      end
    end

    def hash_to_args(default, user)
      default.merge(user.delete_if { |key, _value| !default.key? key })
    end

    def array_to_args(default, user)
      default.zip(user).map { |(k, d), v| [k, v || d] }.to_h
    end
  end
end
