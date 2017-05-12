class AddIndexToComSignal < ActiveRecord::Migration[5.0]
  def change
    add_index :com_signals, ["project_id", "name"], unique: true
  end
end
