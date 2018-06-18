module MegaCalendar
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          # unloadable # Send unloadable so it will not be unloaded in development

          def clear_disabled_fields_with_plugin

            if tracker
              (tracker.disabled_core_fields - Tracker::EXTRA_CORE_FIELDS).each do |attribute|
                send "#{attribute}=", nil
              end
              self.done_ratio ||= 0
            end
          end

          def attributes_with_plugin=(new_attributes)
            assign_attributes new_attributes.dup.delete_if { |k,_| Tracker::EXTRA_CORE_FIELDS.include?(k) }
          end

          alias_method_chain :clear_disabled_fields, :plugin
          alias_method_chain :attributes=, :plugin
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
