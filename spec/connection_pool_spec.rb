require 'spec_helper'

class TestConnection
  attr_accessor :name
  def initialize(name)
    @name = name
  end
end

class TestException < StandardError ; end

module Stillwater
  describe ConnectionPool do
    subject { ConnectionPool.new }

    describe "#add" do
      it "should add an available connection" do
        subject.add { TestConnection.new("one") }

        subject.available_count.should == 1
      end
    end

    context "with a connection" do
      before(:each) do
        subject.add { TestConnection.new("one") }
      end

      describe "#checkout" do
        it "should return a connection" do
          conn = subject.checkout

          conn.should be_instance_of(TestConnection)
          subject.available_count.should == 0
          subject.in_use_count.should == 1
        end

        it "should not be able to check out inactive connections" do
          conn = subject.checkout
          subject.deactivate conn

          lambda { subject.checkout }.should raise_error(ConnectionNotAvailable)
        end
      end

      describe "#checkin" do
        it "should return the connection to the pool" do
          conn = subject.checkout
          subject.available_count.should == 0
          subject.in_use_count.should == 1

          subject.checkin(conn)
          subject.available_count.should == 1
          subject.in_use_count.should == 0
        end
      end

      describe "#with_connection" do
        it "should run some code with a connection" do
          result = subject.with_connection do |connection|
            subject.available_count.should == 0
            connection.name.should == "one"

            "bob"
          end

          result.should == "bob"
          subject.available_count.should == 1
        end
      end

      describe "#retry_connection_from" do
        before(:each) do
          subject.add { TestConnection.new("two") }
          subject.add { TestConnection.new("three") }
        end

        it "should retry a connection when receiving specific exception type" do
          client_obj = mock("ClientObject")
          client_obj.stubs(:do_something).
            raises(TestException).then.
            raises(TestException).then.
            returns("client result")

          result = subject.retry_connection_from(TestException) do |conn|
            client_obj.do_something
          end

          subject.available_count.should == 1
          subject.inactive_count.should == 2
          result.should == "client result"
        end

        it "should respect the retry limit" do
          subject.retry_count = 1

          lambda {
            subject.retry_connection_from(TestException) do |conn|
              raise TestException
            end
          }.should raise_error(TestException)

          subject.available_count.should == 2
          subject.inactive_count.should == 1
        end

        it "should fail if all connections get deactivated" do
          lambda {
            subject.retry_connection_from(TestException) do |conn|
              raise TestException
            end
          }.should raise_error(ConnectionNotAvailable)
        end
      end

      describe "#deactivate" do
        before(:each) do
          subject.add { TestConnection.new("two") }
          subject.add { TestConnection.new("three") }
        end

        it "should remove a deactivated connection from the pool" do
          subject.available_count.should == 3
          subject.inactive_count.should == 0

          subject.with_connection do |connection|
            subject.deactivate connection
          end

          subject.available_count.should == 2
          subject.inactive_count.should == 1
        end
      end

      describe "#reactivate" do
        before(:each) do
          subject.add { TestConnection.new("two") }
          subject.add { TestConnection.new("three") }
        end

        it "should be able to reactivate inactive connections" do
          subject.available_count.should == 3
          subject.inactive_count.should == 0

          conn1 = subject.checkout
          conn2 = subject.checkout

          subject.deactivate conn1
          subject.deactivate conn2

          subject.available_count.should == 1
          subject.inactive_count.should == 2

          subject.reactivate_all

          subject.available_count.should == 3
          subject.inactive_count.should == 0
        end

        it "should auto reactivate" do
          subject.reactivate_timeout = 1

          conn1 = subject.checkout
          conn2 = subject.checkout

          subject.deactivate conn1
          subject.deactivate conn2

          sleep 2

          subject.available_count.should == 3
          subject.inactive_count.should == 0
        end
      end
    end
  end
end
