# A copy of Rails time helpers. With this file we can support the `travel_to`
# helper for Rails versions prior 4.1.
# File origin: https://github.com/rails/rails/blob/52ce6ece8c8f74064bb64e0a0b1ddd83092718e1/activesupport/lib/active_support/testing/time_helpers.rb
module ActiveSupport
  module Testing
    class SimpleStubs # :nodoc:
      Stub = Struct.new(:object, :method_name, :original_method)

      def initialize
        @stubs = {}
      end

      def stub_object(object, method_name, return_value)
        key = [object.object_id, method_name]

        if stub = @stubs[key]
          unstub_object(stub)
        end

        new_name = "__simple_stub__#{method_name}"

        @stubs[key] = Stub.new(object, method_name, new_name)

        object.singleton_class.send :alias_method, new_name, method_name
        object.define_singleton_method(method_name) { return_value }
      end

      def unstub_all!
        @stubs.each_value do |stub|
          unstub_object(stub)
        end
        @stubs = {}
      end

      private

        def unstub_object(stub)
          singleton_class = stub.object.singleton_class
          singleton_class.send :undef_method, stub.method_name
          singleton_class.send :alias_method, stub.method_name, stub.original_method
          singleton_class.send :undef_method, stub.original_method
        end
    end

    # Contains helpers that help you test passage of time.
    module TimeHelpers
      # Changes current time to the time in the future or in the past by a given time difference by
      # stubbing +Time.now+, +Date.today+, and +DateTime.now+.
      #
      #   Time.current     # => Sat, 09 Nov 2013 15:34:49 EST -05:00
      #   travel 1.day
      #   Time.current     # => Sun, 10 Nov 2013 15:34:49 EST -05:00
      #   Date.current     # => Sun, 10 Nov 2013
      #   DateTime.current # => Sun, 10 Nov 2013 15:34:49 -0500
      #
      # This method also accepts a block, which will return the current time back to its original
      # state at the end of the block:
      #
      #   Time.current # => Sat, 09 Nov 2013 15:34:49 EST -05:00
      #   travel 1.day do
      #     User.create.created_at # => Sun, 10 Nov 2013 15:34:49 EST -05:00
      #   end
      #   Time.current # => Sat, 09 Nov 2013 15:34:49 EST -05:00
      def travel(duration, &block)
        travel_to Time.now + duration, &block
      end

      # Changes current time to the given time by stubbing +Time.now+,
      # +Date.today+, and +DateTime.now+ to return the time or date passed into this method.
      #
      #   Time.current     # => Sat, 09 Nov 2013 15:34:49 EST -05:00
      #   travel_to Time.new(2004, 11, 24, 01, 04, 44)
      #   Time.current     # => Wed, 24 Nov 2004 01:04:44 EST -05:00
      #   Date.current     # => Wed, 24 Nov 2004
      #   DateTime.current # => Wed, 24 Nov 2004 01:04:44 -0500
      #
      # Dates are taken as their timestamp at the beginning of the day in the
      # application time zone. <tt>Time.current</tt> returns said timestamp,
      # and <tt>Time.now</tt> its equivalent in the system time zone. Similarly,
      # <tt>Date.current</tt> returns a date equal to the argument, and
      # <tt>Date.today</tt> the date according to <tt>Time.now</tt>, which may
      # be different. (Note that you rarely want to deal with <tt>Time.now</tt>,
      # or <tt>Date.today</tt>, in order to honor the application time zone
      # please always use <tt>Time.current</tt> and <tt>Date.current</tt>.)
      #
      # Note that the usec for the time passed will be set to 0 to prevent rounding
      # errors with external services, like MySQL (which will round instead of floor,
      # leading to off-by-one-second errors).
      #
      # This method also accepts a block, which will return the current time back to its original
      # state at the end of the block:
      #
      #   Time.current # => Sat, 09 Nov 2013 15:34:49 EST -05:00
      #   travel_to Time.new(2004, 11, 24, 01, 04, 44) do
      #     Time.current # => Wed, 24 Nov 2004 01:04:44 EST -05:00
      #   end
      #   Time.current # => Sat, 09 Nov 2013 15:34:49 EST -05:00
      def travel_to(date_or_time)
        if date_or_time.is_a?(Date) && !date_or_time.is_a?(DateTime)
          now = date_or_time.midnight.to_time
        else
          now = date_or_time.to_time.change(usec: 0)
        end

        simple_stubs.stub_object(Time, :now, now)
        simple_stubs.stub_object(Date, :today, now.to_date)
        simple_stubs.stub_object(DateTime, :now, now.to_datetime)

        if block_given?
          begin
            yield
          ensure
            travel_back
          end
        end
      end

      # Returns the current time back to its original state, by removing the stubs added by
      # `travel` and `travel_to`.
      #
      #   Time.current # => Sat, 09 Nov 2013 15:34:49 EST -05:00
      #   travel_to Time.new(2004, 11, 24, 01, 04, 44)
      #   Time.current # => Wed, 24 Nov 2004 01:04:44 EST -05:00
      #   travel_back
      #   Time.current # => Sat, 09 Nov 2013 15:34:49 EST -05:00
      def travel_back
        simple_stubs.unstub_all!
      end

      private

        def simple_stubs
          @simple_stubs ||= SimpleStubs.new
        end
    end
  end
end
