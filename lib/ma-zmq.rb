require 'eventmachine'
require 'em-zeromq'

require 'ma-zmq/round_robin'
require 'ma-zmq/socket_pool'
require 'ma-zmq/channel'

module MaZMQ
  @@context = nil
  def self.context
    @@context ||= ZMQ::Context.new
    @@context
  end

  class Server
    @@n = 1
    class << self
      def run
        EM.run do
          #context = EM::ZeroMQ::Context.new(1)
          #context = ZMQ::Context.new
          @@round_robin = MaZMQ::RoundRobin.new([3340, 3341])
          EM::add_periodic_timer(1) do
            push(@@n)
            @@n += 1
          end
        end
      end

      def push(n)
        @@round_robin.send_with(n.to_s)
      end
    end
  end
end
