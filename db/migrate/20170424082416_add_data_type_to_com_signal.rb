class AddDataTypeToComSignal < ActiveRecord::Migration[5.0]
  def change
    add_column :com_signals, :data_type, :integer
  end
end
