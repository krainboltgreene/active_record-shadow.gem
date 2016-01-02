module ActiveRecord
  module Shadow
    class Member
      def self.shadow(klass)
        @shadow_class = klass
      end

      def self.related(key, klass)
        @relateds = relateds.merge(key => klass)
      end

      def self.static(key)
        @statics = Set[*statics, key]
      end

      def self.computed(key)
        @computeds = Set[*computeds, key]
      end

      def self.ignore(key)
        @ignores = Set[*ignores, key]
      end

      def self.relateds
        @relateds || Hash.new
      end

      def self.statics
        @statics || Set.new
      end

      def self.computeds
        @computeds || Set.new
      end

      def self.ignores
        @ignores || Set.new
      end
    end
  end
end
