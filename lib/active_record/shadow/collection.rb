module ActiveRecord
  module Shadow
    class Collection
      def self.filter(key, klass)
        @filters = filters.merge(key => klass)
      end

      def self.filters
        @filters ||= Hash.new
      end
    end
  end
end
