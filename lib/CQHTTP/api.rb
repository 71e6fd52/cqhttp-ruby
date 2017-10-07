module CQHTTP
  # All API
  class API
    attr_reader :func_list

    # init
    #
    # host: String: API address, like 'http://localhost:5700'
    # type: Symbol or String, 'get', 'form' or 'json;
    def initialize(host: 'http://localhost:5700', way: :form)
      @func_list = {}
      gen
      @func_list.freeze
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

    ####################################################################
    #                               gen                                #
    ####################################################################

    def skip_head(file)
      until file.gets.chomp == '## API 列表'; end
    end

    def skip_to_next_api(file)
      while (line = file.gets)
        return nil if line =~ /^## /
        return line.gsub(%r{^### `\/(.+)`.*$}, '\1').chomp if line =~ /^### /
      end
    end

    def skip_to_args(file)
      until file.gets.chomp == '#### 参数'; end
      file.gets
      file.gets.chomp
    end

    def skip_to_table_head(file)
      until file.gets =~ /^\|\s*-+\s*\|\s*-+\s*\|\s*-+\s*\|\s*-+\s*\|$/; end
    end

    def non_arg_check(name, line)
      return unless line == '无'
      @func_list[name.to_sym] = {}
      true
    end

    def get_default(str)
      str.sub!(/^`(.+)`$/, '\1')
      return str.to_i if str =~ /^[+-]?\d+$/
      return true if str == 'true'
      return false if str == 'false'
      m = str.match(/^\s*(\d+)\s*\*\s*(\d+)\s*/)
      return m[1].to_i * m[2].to_i if m
      str
    end

    def get_args(file)
      args = {}
      until (line = file.gets) =~ /^$/
        m = line.match(/^\|\s*`(\w+)`\s*\|\s+.+?\s+\|\s+(.+?)\s+\|/)
        args[m[1].to_sym] = case m[2]
                            when '空' then ''
                            when '-' then nil
                            else get_default m[2]
                            end
      end
      args
    end

    def add_to_func_list(name, file)
      return if non_arg_check(name, skip_to_args(file))
      skip_to_table_head file
      @func_list[name.to_sym] = get_args file
    end

    def gen
      File.open File.join(File.dirname(__FILE__), 'API.md') do |f|
        skip_head f

        loop do
          name = skip_to_next_api f
          return @func_list unless name
          add_to_func_list name, f
        end
      end
    end
  end
end
