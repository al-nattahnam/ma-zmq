require 'rubygems'
require 'ma-zmq'
require 'benchmark'

requests = 10000
concurrency = 10
per_fork = requests / concurrency

@@sent = 0
@@read = 0

concurrency.times {
fork do
puts Benchmark.realtime {
EM.run do
  req = MaZMQ::LoadBalancer.new
  req.connect :tcp, '127.0.0.1', 3340
  req.connect :tcp, '127.0.0.1', 3341
  req.connect :tcp, '127.0.0.1', 3342
  req.connect :tcp, '127.0.0.1', 3343
  req.timeout(0.5)
  req.on_read {|m| @@read += 1}
  req.on_timeout {
    puts 'timeout!'
  }
  EM.add_periodic_timer(0.000001) do
    if @@sent.to_f % 1000 == 0
      puts "n: #{@@sent}"
    end
    if req.send_string('test')
      @@sent += 1
    end
    if @@read.to_f % 1000 == 0
      puts "R: #{@@read}"
    end
    if @@read >= per_fork
      EM.stop
    end
  end
end
}
end
}
#puts @@read
