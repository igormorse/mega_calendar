module MegaCalendar
  module Patches
    module TrackerPatch
      def self.included(base) # :nodoc
        # base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          after_initialize :add_extended_default_core_fields

        end
      end

      module ClassMethods; end

      module InstanceMethods
      
        # Defines Constant inside Class with a Value
        def def_const_if_not_defined(const, value)
          self.class.const_set(const, value) unless self.class.const_defined?(const)
        end

        # Declare new Variables inside Class
        def extended_fields_bits=(value)
          @@extended_fields_bits = value
        end
        def extended_fields_bits
          @@extended_fields_bits||=0
        end

        # Remove internal Constant and creates another one with extended values.
        def redef_const_without_warning

          # Creates Constant EXTRA_CORE_FIELDS so we can deduce the original Core Field inside Application.
          def_const_if_not_defined(:EXTRA_CORE_FIELDS, %w(time_begin time_end).freeze)

          # Save the Temporary Core Fields
          tmp_core_fields_undisablable = self.class.const_get(:CORE_FIELDS_UNDISABLABLE)
          tmp_core_fields = self.class.const_get(:CORE_FIELDS)
          tmp_extra_core_fields = self.class.const_get(:EXTRA_CORE_FIELDS)

          tmp_extended_core_fields = tmp_core_fields + tmp_extra_core_fields

          # Remove the Old Core Fields
          self.class.send(:remove_const, :CORE_FIELDS) if self.class.const_defined?(:CORE_FIELDS)

          # Creates a new one with the new Fields
          self.class.const_set(:CORE_FIELDS, tmp_extended_core_fields.freeze)

          # Remove the Old Core Fields
          self.class.send(:remove_const, :CORE_FIELDS_ALL) if self.class.const_defined?(:CORE_FIELDS_ALL)

          # Creates a new one with the new Fields
          self.class.const_set(:CORE_FIELDS_ALL, (tmp_core_fields_undisablable + tmp_extended_core_fields).freeze)
        end

        def add_extended_default_core_fields
          return if self.extended_fields_bits.present? && self.extended_fields_bits > 0

          # Redefines the Core Field Constant
          redef_const_without_warning

          bits = 0
          self.class.const_get(:CORE_FIELDS).each_with_index do |field, i|
            unless Setting.default_tracker_core_fields.include?(field)
              bits |= 2 ** i
            end
          end
          self.extended_fields_bits = bits
        end
      
      end
    end
  end
end
