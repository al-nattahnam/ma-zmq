require 'eventmachine'
require 'em-zeromq'
require 'rzmq_compat'

require 'ma-zmq/round_robin'
require 'ma-zmq/socket_pool'
require 'ma-zmq/channel'

module MaZMQ
  class Server
    @@n = 1
    class << self
      def run
        EM.run do
          context = EM::ZeroMQ::Context.new(1)
          @@round_robin = MaZMQ::RoundRobin.new(context, [3200, 3201])
          EM::add_periodic_timer(0.2) do
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
