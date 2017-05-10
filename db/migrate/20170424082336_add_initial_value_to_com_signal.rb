class AddInitialValueToComSignal < ActiveRecord::Migration[5.0]
  def change
    add_column :com_signals, :initial_value, :string
  end
end
