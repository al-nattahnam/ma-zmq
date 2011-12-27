require 'rubygems'
require 'ma-zmq'
require 'benchmark'
#require 'ruby-prof'

requests = 10000
concurrency = 5
per_fork = requests / concurrency

@@sent = 0
@@tries = 0
@@read = 0

concurrency.times {
  fork do
    puts Benchmark.realtime {
    #result = RubyProf.profile {
      EM.run do
        req = MaZMQ::Proxy.new
        req.connect :tcp, '127.0.0.1', 3340
        req.connect :tcp, '127.0.0.1', 3341
        req.connect :tcp, '127.0.0.1', 3342
        req.connect :tcp, '127.0.0.1', 3343
        req.connect :tcp, '127.0.0.1', 3343

        #req.connect :tcp, '127.0.0.1', 3344
        #req.connect :tcp, '127.0.0.1', 3345
        #req.connect :tcp, '127.0.0.1', 3346
        #req.connect :tcp, '127.0.0.1', 3347
        req.timeout(0.5)
        req.on_read { |m|
          @@read += 1
        }
        req.on_timeout {
          puts 'timeout!'
        }
        EM.add_periodic_timer(0.000001) do
          @@tries += 1
          if @@sent < per_fork
            if req.send_string('test')
              @@sent += 1
            end
          else
            if @@read >= per_fork
              EM.stop
            end
          end
        end
      end
    #}
    }
    #printer = RubyProf::FlatPrinter.new(result)
    #printer.print(STDOUT, 0)
  puts @@read
  puts "Tries: #{@@tries}"
  end
}
