class RemoveUselessRecordsFromTicketTimes < ActiveRecord::Migration
  def change
    TicketTime.delete(TicketTime.where.not(issue_id: Issue.all.pluck(:id)))
  end
end
