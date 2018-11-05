require_dependency 'issues_controller'
module MegaCalendar
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.class_eval do
          # Insert overrides here, for example:
          def create_with_plugin
            create_without_plugin
            if !@issue.id.blank?

              time_begin_cf = Setting.try(:plugin_mega_calendar)[:time_begin_custom_field] rescue nil
              time_end_cf = Setting.try(:plugin_mega_calendar)[:time_end_custom_field] rescue nil

              if !time_begin_cf.nil? && !time_end_cf.nil? && (!params[:issue][:start_date].blank? || !@issue.start_date.blank?) && (params[:issue][:custom_field_values].present? && (params[:issue][:custom_field_values].key?(time_begin_cf) || params[:issue][:custom_field_values].key?(time_end_cf)))

                start_date = params[:issue][:start_date].blank? ? @issue.start_date : params[:issue][:start_date]
                
                due_date = params[:issue][:due_date].blank? ? start_date : params[:issue][:due_date] if params[:issue][:due_date].blank?

                timeBeginNotExists = !params[:issue][:custom_field_values].key?(time_begin_cf) || params[:issue][:custom_field_values][time_begin_cf].blank?
                timeEndNotExists = !params[:issue][:custom_field_values].key?(time_end_cf) || params[:issue][:custom_field_values][time_end_cf].blank?

                if (!timeBeginNotExists || !timeEndNotExists)

                  tbegin = (timeBeginNotExists) ? (Setting.try(:plugin_mega_calendar)[:default_min_time] rescue '00:00') : params[:issue][:custom_field_values][time_begin_cf]
                  tend = (timeEndNotExists) ? (Setting.try(:plugin_mega_calendar)[:default_max_time] rescue '23:00') : params[:issue][:custom_field_values][time_end_cf]

                  time_begin = start_date.to_s + ' ' + tbegin
                  time_end = due_date.to_s + ' ' + tend

                  time_fields_cv = @issue.custom_values.where(:custom_field_id => [time_begin_cf.to_i, time_end_cf.to_i])

                  time_begin_cv_id = time_fields_cv[0].id rescue nil
                  time_end_cv_id = time_fields_cv[1].id rescue nil

                  TicketTime.create({:issue_id => @issue.id, :time_begin => time_begin, :time_end => time_end, :time_begin_custom_value_id => time_begin_cv_id, :time_end_custom_value_id => time_end_cv_id}) rescue nil
                end
              end
            end
          end
          def update_with_plugin
            update_without_plugin
            if !@issue.id.blank?

              time_begin_cf = Setting.try(:plugin_mega_calendar)[:time_begin_custom_field] rescue nil
              time_end_cf = Setting.try(:plugin_mega_calendar)[:time_end_custom_field] rescue nil

              if !time_begin_cf.nil? && !time_end_cf.nil? && (!params[:issue][:start_date].blank? || !@issue.start_date.blank?) && (params[:issue][:custom_field_values].present? && (params[:issue][:custom_field_values].key?(time_begin_cf) || params[:issue][:custom_field_values].key?(time_end_cf)))

                start_date = params[:issue][:start_date].blank? ? @issue.start_date : params[:issue][:start_date]
                
                due_date = params[:issue][:due_date].blank? ? start_date : params[:issue][:due_date] if params[:issue][:due_date].blank?

                timeBeginNotExists = !params[:issue][:custom_field_values].key?(time_begin_cf) || params[:issue][:custom_field_values][time_begin_cf].blank?
                timeEndNotExists = !params[:issue][:custom_field_values].key?(time_end_cf) || params[:issue][:custom_field_values][time_end_cf].blank?

                if (!timeBeginNotExists || !timeEndNotExists)
                  tbegin = (timeBeginNotExists) ? (Setting.try(:plugin_mega_calendar)[:default_min_time] rescue '00:00') : params[:issue][:custom_field_values][time_begin_cf]
                  tend = (timeEndNotExists) ? (Setting.try(:plugin_mega_calendar)[:default_max_time] rescue '23:00') : params[:issue][:custom_field_values][time_end_cf]
                
                  time_begin = start_date.to_s + ' ' + tbegin
                  time_end = due_date.to_s + ' ' + tend
                else
                  time_begin = nil
                  time_end = nil
                end

                time_fields_cv = @issue.custom_values.where(:custom_field_id => [time_begin_cf.to_i, time_end_cf.to_i])

                time_begin_cv_id = time_fields_cv[0].id rescue nil
                time_end_cv_id = time_fields_cv[1].id rescue nil

                tt = TicketTime.where({:issue_id => @issue.id}).first rescue nil
                            
                tt = TicketTime.new({:issue_id => @issue.id}) if tt.blank?

                tt.time_begin = time_begin
                tt.time_end = time_end
                tt.time_begin_custom_value_id = time_begin_cv_id
                tt.time_end_custom_value_id = time_end_cv_id
                tt.save
              end
            end
          end
          alias_method_chain :update, :plugin
          alias_method_chain :create, :plugin # This tells Redmine to allow me to extend show by letting me call it via "show_without_plugin" above.
          # I can outright override it by just calling it "def show", at which case the original controller's method will be overridden instead of extended.
        end
      end
    end
  end
end
