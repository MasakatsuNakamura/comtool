class ChangeDataTypeToComSignal < ActiveRecord::Migration[5.0]
  def change
    change_column :com_signals, :data_type, :integer, null: false
    change_column :com_signals, :data_type, :integer, default: 0
  end
end
