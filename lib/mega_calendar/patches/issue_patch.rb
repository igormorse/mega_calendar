module MegaCalendar
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          has_one(:ticket_times, dependent: :delete)
        end
      end
    end
  end
end
