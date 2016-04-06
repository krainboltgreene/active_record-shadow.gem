module ActiveRecord
  module Shadow
    class Member
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

      def initialize(object)
        @object = object
        @bridge = @object.dup

        copy_record
        define_relateds
        define_statics
        define_computeds
      end

      def object
        @object
      end

      def bridge
        @bridge
      end

      def copy_record
        # AR dups don't have an id
        bridge.id = object.id

        # AR dups don't have timestamps
        bridge.created_at = object.created_at
        bridge.updated_at = object.updated_at
      end
      private :copy_record

      def define_relateds
        self.class.relateds.each do |(relation, shadow_klass)|

          # Make sure the bridge has the same relationships as the object
          bridge.public_send("#{relation}=", object.public_send(relation))

          # Define a relationship setter method that forwards to bridge
          define_singleton_method("#{relation}=") do |value|
            bridge.public_send("#{relation}=", value)
          end

          # Define the getter on this instance for wrapping
          define_singleton_method(relation) do
            if has_related?(relation) && same_related?(relation)
              instance_variable_get("@#{relation}")
            else
              instance_variable_set("@#{relation}", shadow_klass.new(bridge.public_send(relation)))
            end
          end
        end
      end
      private :define_relateds

      def define_statics
        self.class.statics.each do |static|
          # Define the static getter
          define_singleton_method(static) do
            bridge.public_send(static)
          end

          # Define the static setter
          define_singleton_method("#{static}=") do |value|
            bridge.public_send("#{static}=", value)
          end
        end
      end
      private :define_statics

      def define_computeds
        self.class.computeds.each do |computed|
          # Define the computed getter
          define_singleton_method(computed) do
            bridge.public_send(computed)
          end
        end
      end
      private :define_computeds

      def has_related?(relation)
        instance_variable_get("@#{relation}")
      end
      private :has_related?

      def same_related?(relation)
        bridge.public_send(relation) == instance_variable_get("@#{relation}").bridge
      end
      private :same_related?
    end
  end
end
