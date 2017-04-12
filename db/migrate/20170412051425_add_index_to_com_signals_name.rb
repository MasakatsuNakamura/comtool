class AddIndexToComSignalsName < ActiveRecord::Migration[5.0]
  def change
    add_index :com_signals, [:message_id, :name], unique: true
  end
end
