module Inch
  module Codebase
    class Objects
      include Enumerable
      extend Forwardable

      def_delegators :@list, :each, :empty?, :size

      # @param objects [Array<CodeObject::Proxy::Base>]
      # @return [Array<CodeObject::Proxy::Base>]
      def self.sort_by_priority(objects)
        objects.sort_by do |o|
          [o.priority, o.score, o.fullname.size]
        end.reverse
      end

      def initialize(objects)
        list = objects.map do |o|
          proxy = CodeObject::Proxy.for(o)
          proxy.object_lookup = self
          proxy
        end
        @list = list
        # the @list has to be set for the priority sorting
        # since the priority needs the object_lookup, which
        # in turn depends on @list - it's a crazy world
        @list = self.class.sort_by_priority(@list)
      end

      # Returns all parsed objects as code object proxies
      #
      # @see CodeObject::Proxy.for
      # @return [Array<CodeObject::Proxy::Base>]
      def all
        @list
      end

      # Returns the object with the given +fullname+
      #
      # @example
      #
      #   find("Foo#bar")
      #   # => returns the code object proxy for Foo#bar
      #
      # @param fullname [String] partial fullname/name of an object
      # @return [CodeObject::Proxy::Base]
      def find(fullname)
        all.detect { |o| o.fullname == fullname }
      end

      # Returns all objects where the +fullname+ starts_with the given
      # +partial_name+
      #
      # @example
      #
      #   find("Foo#")
      #   # => returns the code object proxies for all instance methods of Foo
      #
      # @param partial_name [String] partial name of an object
      # @return [Array<CodeObject::Proxy::Base>]
      def starting_with(partial_name)
        all.select { |o| o.fullname.start_with?(partial_name) }
      end

      # Filters the list based on the settings in +options+
      #
      # @return [void]
      def filter!(options)
        @list = ObjectsFilter.new(all, options).objects
      end
    end
  end
end
