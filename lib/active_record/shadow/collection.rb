module ActiveRecord
  module Shadow
    class Collection
      # include Enumerable
      # Define methods for each public instance method on the bridge, forwarding to the bridge

      def self.filter(key, shadow_klass)
        @filters = filters.merge(key => shadow_klass)
      end

      def self.shadow(klass)
        @shadows = klass
      end

      def self.filters
        @filters ||= Hash.new
      end

      def self.shadows
        @shadows
      end

      def initialize(object, shadows = self.class.shadows)
        @object = object
        @bridge = @object.dup
        @shadows = shadows

        define_methods
        define_filters
      end

      def each(&block)
        all.each(&block)
      end

      # TODO: This is going to become a lot more complicated
      # def all
      #   @all ||= bridge.all.map do |item|
      #     shadows.new(item)
      #   end
      # end

      def object
        @object
      end

      def bridge
        @bridge
      end

      def shadows
        @shadows
      end

      def define_methods
        @bridge.public_instance_methods.each do |instance_method|
          define_singleton_method(instance_method) do
            @bridge.public_send(meth)
          end
        end
      end
      private :define_methods

      def define_filters
        self.class.filters.each do |(name, shadow_klass)|
          # Define the getter on this instance for wrapping the collection in shadows
          define_singleton_method(name) do
            # Either serve the cache or bust the cache
            if has_filter?(name) && same_filter?(name)
              instance_variable_get("@#{name}")
            else
              instance_variable_set("@#{name}", self.class.new(object.public_send(name), shadow_klass))
            end
          end
        end
      end
      private :define_filters

      def has_filter?(name)
        instance_variable_defined?("@#{name}")
      end
      private :has_filter?

      # TODO: This is going to get a lot more complex
      def same_filter?(name)
        bridge.public_send(name) == instance_variable_get("@#{name}").bridge
      end
      private :same_filter?

      def has_default?
        instance_variable_defined?("@default")
      end
      private :has_default?

      # TODO: This is going to get a lot more complex
      def same_default?
        bridge == instance_variable_get("@default")
      end
      private :same_default?
    end
  end
end
