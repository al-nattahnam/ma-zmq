require 'eventmachine'
#require 'em-zeromq'
require 'ffi-rzmq'

require 'ma-zmq/round_robin'
require 'ma-zmq/socket_pool'
require 'ma-zmq/channel'

require 'ma-zmq/socket'
require 'ma-zmq/request'

module MaZMQ
  @@context = nil
  def self.context
    # Como MaZMQ estaria funcionando siempre en EM, el proceso en el cual corre seria siempre unico, y por esa razon (repasando http://zguide.zeromq.org/page:all#Getting-the-Context-Right), usamos un unico Contexto en toda la aplicacion. Y el usuario no tiene que instanciar uno.
    @@context ||= ZMQ::Context.new
    @@context
  end

  class Server
    @@n = 1
    class << self
      def run
        EM.run do
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
