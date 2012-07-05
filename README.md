# Stillwater

A simple connection pool, that allows connections to different servers (or anything else)

## Installation

Add this line to your application's Gemfile:

    gem 'stillwater'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stillwater

## Usage

    pool = Stillwater::ConnectionPool.new
    %q{ host1.com host2.com }.each do |host|
      pool.add { MyConnectionClass.new(host) }
    end

    # Basic connection handling
    pool.with_connection do |connection|
      # Do some stuff with your connection
    end

    # Retry connections
    # This will retry your code with a new connection and mark the tried
    # connection as bad. The bad connection will be put back in the pool
    # at the default period of 5 minutes.
    pool.retry_connection_from(ServerConnectionFailed) do |connection|
      # Do some stuff with your connection
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

* Trae Robrock (@trobrock)
* Julio Santos (@julio)
