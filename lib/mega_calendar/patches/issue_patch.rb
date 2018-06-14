module MegaCalendar
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods
        def hidden_attributes_names(user=nil)
          return (self.send :workflow_rule_by_attribute).reject {|attr, rule| rule != 'hidden'}.keys
        end
        def hidden_attribute?(name, user=nil)
          return self.hidden_attributes_names(user).include?(name.to_s)
        end
        def read_only_attribute?(name, user=nil)
          return self.read_only_attributes_names(user).include?(name.to_s)
        end
        def core_field_enabled?(name)
          return self.tracker.core_fields.include? name.to_s
        end
      end
    end
  end
end
