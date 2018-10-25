class MigrateDataToCustomValues < ActiveRecord::Migration
  def up

    time_begin_cf = Setting.try(:plugin_mega_calendar)[:time_begin_custom_field].to_i rescue nil
    time_end_cf = Setting.try(:plugin_mega_calendar)[:time_end_custom_field].to_i rescue nil

    if (time_begin_cf.nil? || time_end_cf.nil?)
      raise "Configure your Time Begin and Time End Custom Fields to Run this Migration!"
    end

    puts "*****\n****\n**** \n\tIF ERROR: Configure Time Begin Custom Field in Mega Calendar Plugin Settings!! \n****\n****\n*****"
    time_begin_cf = CustomField.find(time_begin_cf)
    puts "*****\n****\n**** \n\tIF ERROR: Configure Time Begin Custom Field in Mega Calendar Plugin Settings!! ****\n****\n*****"
    time_end_cf = CustomField.find(time_end_cf)

    TicketTime.where("time_begin_custom_value_id IS NULL OR time_end_custom_value_id IS NULL").each do |ticket_time|

      if (ticket_time.time_begin_custom_value_id.nil? && !ticket_time.time_begin.nil?)

        time_begin_cv = CustomValue.find_or_create_by(customized_type: :Issue, customized_id: ticket_time.issue_id, custom_field: time_begin_cf, value: ticket_time.time_begin.strftime("%H:%M"))

        time_begin_cv.save

        ticket_time.time_begin_custom_value_id = time_begin_cv.id
      end

      if (ticket_time.time_end_custom_value_id.nil? && !ticket_time.time_end.nil?)

        time_end_cv = CustomValue.find_or_create_by(customized_type: :Issue, customized_id: ticket_time.issue_id, custom_field: time_end_cf, value: ticket_time.time_end.strftime("%H:%M"))

        time_end_cv.save

        ticket_time.time_end_custom_value_id = time_end_cv.id
      end

      ticket_time.save if (ticket_time.time_begin_custom_value_id.present? || ticket_time.time_end_custom_value_id.present?)
    end
  end

  def def down
    
    tt = TicketTime.where("time_begin_custom_value_id IS NOT NULL AND time_end_custom_value_id IS NOT NULL").first
    
    time_begin_cf = tt.time_begin_custom_value.custom_field
    time_end_cf = tt.time_end_custom_value.custom_field

    TicketTime.update_all(time_begin_custom_value_id: nil, time_end_custom_value_id: nil)

    CustomValue.where("custom_field_id = #{time_begin_cf.id} OR custom_field_id = #{time_end_cf.id}").delete_all
  end
end
