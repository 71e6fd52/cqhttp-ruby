module CQHTTP
  class Service
    attr_reader :info, :events

    def initialize(socket)
      @socket = socket
      @events = []
    end

    def run
      loop do
        socket = @socket.accept
        catch(:close) do
          version = socket.gets.match(%r{^DASSMEP/([0-9.])+})
          error(socket, 100) if first.nil?
          error(socket, 101) unless %w[1.0].include? version[0]
          accept socket, version[0]
        end
        socket.close
      end
    end

    def accept(socket, ver)
      error(socket, 210) unless %w[1.0].include? ver
      request = socket.gets.chomp
      format = socket.gets.chomp
      empty = socket.gets.chomp
      error(socket, 102, message: 'need empty line') unless empty == ''
      data = socket.read
      info = get_info(format, data)
      check_info(socket, info)
      go(socket, request, info, ver)
    end

    def go(socket, request, info, ver)
      begin
        send(request.shift.downcase, socket, info, ver)
      rescue NoMethodError
        error(socket, 300)
      end
    end

    def sync(socket, info, _ver)
    end

    def send(socket, info, _ver)
    end

    def event(socket, info, _ver)
    end

    def get_info(format, data)
      case format
      when 'json' then JSON.parse data
      else 'error'
      end
    end

    def check_info(socket, info)
      return if info.is_a? Hash
      error(socket, 211) if info == 'error'
      error(socket, 299, type: 'Unknow', body: info.class)
    end

    def error(socket, no, info = {})
      info[:errno] = no
      info[:type] ||= no
      info[:body] ||= no
      info[:message] ||= no
      socket.puts "DASSMEP/1.0 #{no}"
      socket.puts 'json'
      socket.puts JSON.pretty_generate info
      throw(:close, "error #{no}")
    end
  end
end
