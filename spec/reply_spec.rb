require 'spec_helper'

describe MaZMQ::Reply do
  context "under EM" do
    context 'when it is not binded' do
      it "should be in 'unavailable' state" do
        EM.run do
          @reply = MaZMQ::Reply.new
          @reply.state.should == :unavailable
          EM.stop
        end
      end
    end

    context 'when receiving from a Request' do
      it "should send a response" do
        EM.run do
          @reply = MaZMQ::Reply.new
          @request = MaZMQ::Request.new

          @reply.bind :tcp, '127.0.0.1', 5235
          @request.connect :tcp, '127.0.0.1', 5235

          @request.send_string("request")
          @reply.on_read { |msg|
            msg.should == "request"
            @reply.send_string("response").should == true
          }
          @request.on_read { |msg|
            @reply.close
            @request.close
            EM.stop
          }
        end
      end

      it "should change its state" do
        EM.run do
          @reply = MaZMQ::Reply.new
          @request = MaZMQ::Request.new

          @reply.bind :tcp, '127.0.0.1', 5235
          @request.connect :tcp, '127.0.0.1', 5235

          @reply.state.should == :idle
          @request.send_string("request")

          @reply.on_read { |msg|
            @reply.state.should == :reply
            @reply.send_string("response")
            @reply.state.should == :idle
          }
          @request.on_read { |msg|
            @reply.close
            @request.close
            EM.stop
          }
        end
      end
    end
  end

  context "not under EM" do
    before(:each) do
      @reply = MaZMQ::Reply.new
      @request = MaZMQ::Request.new
    end

    context 'when it is not binded' do
      it "should be in 'unavailable' state" do
        @reply.state.should == :unavailable
      end
    end

    context 'when receiving from a Request' do
      before do
        @reply.bind :tcp, '127.0.0.1', 5235
        @request.connect :tcp, '127.0.0.1', 5235
      end

      it "should send a response" do
        @request.send_string("request"); sleep 1

        @reply.recv_string.should == "request"

        @reply.send_string("response").should == true; sleep 1

        @request.recv_string
      end
      
      it "should change its state" do
        @reply.state.should == :idle
        
        @request.send_string("request"); sleep 1
        
        @reply.recv_string
        @reply.state.should == :reply
        @reply.send_string "response"; sleep 1
        @reply.state.should == :idle

        @request.recv_string
      end
    end

    after(:each) do
      @reply.close
      @request.close
      sleep 1
    end
  end
end
