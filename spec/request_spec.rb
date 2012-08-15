require 'spec_helper'

describe MaZMQ::Request do
  context "under EM" do
    context 'when it is not binded' do
      it "should be in 'unavailable' state" do
        EM.run do
          @request = MaZMQ::Reply.new
          @request.state.should == :unavailable
          EM.stop
        end
      end
    end

    context 'when requesting from a listening Reply' do
      it "should send a response" do
        EM.run do
          @reply = MaZMQ::Reply.new
          @request = MaZMQ::Request.new

          @reply.bind :tcp, '127.0.0.1', 5235
          @request.connect :tcp, '127.0.0.1', 5235

          @request.send_string("request").should == :sending
          @reply.on_read { |msg|
            @reply.send_string("response")
          }
          @request.on_read { |msg|
            msg.should == "response"

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

          @request.state.should == :idle
          @request.send_string("request")
          @request.state.should == :sending

          @reply.on_read { |msg|
            @reply.send_string("response")
          }
          @request.on_read { |msg|
            @request.state.should == :idle

            @reply.close
            @request.close
            EM.stop
          }
        end
      end

      context ".send_string" do
        it "should return false when trying to send before receiving a response" do
          EM.run do
            @reply = MaZMQ::Reply.new
            @request = MaZMQ::Request.new

            @reply.bind :tcp, '127.0.0.1', 5235
            @request.connect :tcp, '127.0.0.1', 5235

            @request.send_string("request").should == :sending
            @request.send_string("request").should == false

            @reply.on_read { |msg|
              @reply.send_string("response")
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
  end

  context "not under EM" do
    before(:each) do
      @reply = MaZMQ::Reply.new
      @request = MaZMQ::Request.new
    end

    context 'when it is not connected to a Reply' do
      it "should be in 'unavailable' state" do
        @request.state.should == :unavailable
      end
    end

    context 'when requesting to a listening Reply' do
      before do
        @reply.bind :tcp, '127.0.0.1', 5235
        @request.connect :tcp, '127.0.0.1', 5235
      end

      it "should receive a response" do
        @request.send_string("request").should == :sending; sleep 1

        @reply.recv_string

        @reply.send_string "response"; sleep 1

        @request.recv_string.should == "response"
      end

      it "should change its state" do
        @request.state.should == :idle

        @request.send_string("request"); sleep 1
        @request.state.should == :sending

        @reply.recv_string

        @reply.send_string "response"; sleep 1

        @request.recv_string
        @request.state.should == :idle
      end
    end

    after(:each) do
      @reply.close
      @request.close
      sleep 1
    end
  end
end
