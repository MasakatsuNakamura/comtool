class DestroyTables < ActiveRecord::Migration[5.0]
  def change
    drop_table :qines_versions
    drop_table :communication_protocols
  end
end
