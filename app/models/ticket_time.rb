class TicketTime < ActiveRecord::Base
  unloadable
  belongs_to(:issue)
  belongs_to(:custom_value, foreign_key: :time_begin_custom_value_id)
  belongs_to(:custom_value, foreign_key: :time_end_custom_value_id)
  attr_accessible :time_begin
  attr_accessible :time_end
  attr_accessible :issue_id
  attr_accessible :time_begin_custom_value_id
  attr_accessible :time_end_custom_value_id
end
