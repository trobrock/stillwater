module Stillwater
  class ConnectionNotAvailable < StandardError ; end

  class ConnectionPool
    attr_accessor :reactivate_timeout, :retry_count

    def initialize
      @pool = []
      @reactivate_timeout = 5 * 60 # 5 minutes
      @retry_count = 3
      @polling = false
    end

    def add(&builder)
      @pool << connection_info_from(builder)
    end

    def reactivate_timeout=(seconds)
      @reactivate_timeout = seconds
      start_polling
    end

    def with_connection(&block)
      conn = checkout
      result = yield conn
      checkin conn

      result
    end

    def retry_connection_from(exception_class, &block)
      count = 0
      begin
        conn  = checkout
        yield conn
      rescue exception_class
        raise if count >= @retry_count
        deactivate conn
        count += 1
        retry
      ensure
        checkin conn
      end
    end

    def checkout
      reactivate_all if poll_timeout_exceeded?
      connection_info = available.respond_to?(:sample) ? available.sample : available.choice
      raise ConnectionNotAvailable if connection_info.nil?
      connection_info[:state] = :in_use

      connection_info[:connection]
    end

    def checkin(conn)
      connection_info = in_use.detect { |info| info[:connection] == conn }
      connection_info[:state] = :available unless connection_info.nil?

      true
    end

    def deactivate(conn)
      connection_info = @pool.detect { |info| info[:connection] == conn }
      connection_info[:connection] = nil
      connection_info[:state] = :inactive

      start_polling
      true
    end

    def reactivate_all
      inactive.each do |info|
        info[:connection] = info[:builder].call
        info[:state] = :available
      end

      true
    end

    def available_count
      available.size
    end

    def inactive_count
      inactive.size
    end

    def in_use_count
      in_use.size
    end

    private

    def poll_timeout_exceeded?
      return false unless @polling
      now = Time.now
      if (now - @last_poll_time) >= @reactivate_timeout
        @last_poll_time = now
        true
      end
    end

    def start_polling
      @polling = true
      @last_poll_time = Time.now
    end

    def available
      find_by_state :available
    end

    def in_use
      find_by_state :in_use
    end

    def inactive
      find_by_state :inactive
    end

    def find_by_state(state)
      @pool.select { |info| info[:state] == state }
    end

    def connection_info_from(builder)
      { :builder => builder, :state => :available, :connection => builder.call }
    end
  end
end
