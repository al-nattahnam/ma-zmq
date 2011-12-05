require 'socket_pool'

module MaZMQ
  class RoundRobin
    include EM::Deferrable

    # Aprovechar el tiempo de timeout para seguir mandando a los restantes

    def initialize(context, ports=[])
      # [] rr.connect('tcp://127.0.0.1')
      # only REQ / REP pattern

      @current_message = nil
      @socket_pool = MaZMQ::SocketPool.new(context, ports)

      @response = nil
    end

    def send_with(msg)
      @current_message = msg
      self.send_string
      self.add_callback
    end

    def send_string
      puts "rr: send #{@current_message}"
      @socket_pool.send_string(@current_message)
      if state == :sending
        succeed
      end
    end

    def recv_string
      puts "rr: recv"
      message = @socket_pool.recv_string
      if state == :idle
        @socket_pool.rotate!
        succeed
        @response = @socket_pool.message
        puts "rr: recvd #{@response}"
        @current_message = nil
      elsif state == :timeout
        puts 'rr: timeout!'
        @socket_pool.rotate!(true)
        self.fail
      end
    end

    def add_callback
      callback {
        recv_string
        callback {
          puts '[ready]'
        }
        errback {
          puts '[fail]'
          send_with @current_message
        }
      }
    end

    def state
      @socket_pool.state
    end
  end
end
