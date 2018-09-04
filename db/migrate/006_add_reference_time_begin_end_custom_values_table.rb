class AddReferenceTimeBeginEndCustomValuesTable < ActiveRecord::Migration
  def change

    add_column :ticket_times, :time_begin_custom_value_id, :integer
    add_column :ticket_times, :time_end_custom_value_id, :integer

    add_foreign_key :ticket_times, :custom_values, column: :time_begin_custom_value_id, on_delete: :nullify
    add_foreign_key :ticket_times, :custom_values, column: :time_end_custom_value_id, on_delete: :nullify
  end
end
