class ChangeColumnToComSignal < ActiveRecord::Migration[5.0]
  def change
    remove_index :com_signals, ["message_id", "name"]
  end
end
