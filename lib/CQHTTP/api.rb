# frozen_string_literal: true

module CQHTTP
  # All API generate form https://cqhttp.cc/docs/#/API?id=api-列表
  # Example:
  #   @api.send_group_msg('123456', 'test') # by document order
  #   @api.send_group_msg(group_id: '123456', message: 'test') # or use keyword
  class API
    attr_reader :func_list

    # init
    #
    # @param host [String] API address, like 'http://localhost:5700'
    # @param way [Symbol] 'get', 'form' or 'json'
    def initialize(host: 'http://localhost:5700', way: :json)
      @func_list = File.open(File.join(File.dirname(__FILE__), 'API.json')) do
        JSON.parse(_1.read, symbolize_names: true)
      end.freeze
      @network = CQHTTP::Network.gen way, host
    end

    def respond_to_missing?(method, include_private = false)
      @func_list.include?(method) || super
    end

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
      url = '/' + name.to_s
      @network.call(url, args)
    end
  end
end
