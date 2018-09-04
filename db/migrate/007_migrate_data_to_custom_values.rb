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

    TicketTime.where("time_begin_custom_value_id IS NULL OR time_end_custom_value_id IS NULL").each do |record|

      if (record.time_begin_custom_value_id.nil? && !record.time_begin.nil?)

        time_begin_cv = CustomValue.find_or_create_by(customized_type: :Issue, customized_id: record.issue_id, custom_field: time_begin_cf, value: record.time_begin.strftime("%H:%M"))

        time_begin_cv.save

        record.time_begin_custom_value_id = time_begin_cv.id
      end

      if (record.time_end_custom_value_id.nil? && !record.time_end.nil?)

        time_end_cv = CustomValue.find_or_create_by(customized_type: :Issue, customized_id: record.issue_id, custom_field: time_end_cf, value: record.time_end.strftime("%H:%M"))

        time_end_cv.save

        record.time_end_custom_value_id = time_end_cv.id
      end

      record.save if !record.time_begin_custom_value_id.nil? || !record.time_end_custom_value_id.nil?
    end
  end

  def def down 
    TicketTime.update_all(time_begin_custom_value_id: nil, time_end_custom_value_id: nil)
  end
end
