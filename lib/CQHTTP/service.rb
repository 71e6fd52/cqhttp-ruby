module CQHTTP
  # TODO
  class Service
    attr_reader :json

    def initialize(hostname: '0.0.0.0', port: 9455)
      @server = TCPServer.new(hostname, port)
      @event_method = []
    end

    def bind(func)
      @event_method << func
    end

    def run
      loop do
        socket = @server.accept

        head socket

        socket.print "HTTP/1.1 204\r\nContent-Type: application/json\r\n\r\n"
        data = socket.gets
        @json = JSON.parse data

        @event_method.each { |func| func.call self }

        socket.close
      end
    end

    private

    def head(socket)
      puts 'head' if $VERBOSE
      while (line = socket.gets) != "\r\n"
        print '  ' if $VERBOSE
        puts line if $VERBOSE
      end
      puts 'end' if $VERBOSE
    end
  end
end
