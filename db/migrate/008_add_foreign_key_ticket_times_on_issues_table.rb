class AddForeignKeyTicketTimesOnIssuesTable < ActiveRecord::Migration
  def change
    add_foreign_key :ticket_times, :issues, on_delete: :cascade
  end
end
