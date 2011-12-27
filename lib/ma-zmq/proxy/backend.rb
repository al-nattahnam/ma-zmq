module MaZMQ
  class Proxy
    module Backend
      def initialize(use_em=true)
        @sockets = []

        @use_em = use_em
        @timeout = nil # TODO individual timeouts for different sockets

        @on_timeout_lambda = lambda {}
        @on_read_lambda = lambda {|m|}
      end

      def connect(protocol, address, port)
        # validate as in SocketHandler
        request = MaZMQ::Request.new(@use_em)
        request.connect(protocol, address, port)
        if @use_em
          request.timeout(@timeout)
          request.on_read { |msg|
            @on_read_lambda.call(msg)
          }
          request.on_timeout {
            @on_timeout_lambda.call
          }
        end

        #request.identity = "lb-#{@@id}"
        #@@id += 1
        @sockets << request
      end

      def timeout(secs)
        @timeout = secs
        @sockets.each do |s|
          s.timeout @timeout
        end
      end

      def on_timeout(&block)  
        return false if not @use_em
        @on_timeout_lambda = block
        @sockets.each do |socket|
          socket.on_timeout {
            @on_timeout_lambda.call
          }
        end
      end

      def on_read(&block)
        return false if not @use_em
        @on_read_lambda = block
        @sockets.each do |socket|
          socket.on_read { |msg|
            @on_read_lambda.call(msg)
          }
        end
      end
    end
  end
end
