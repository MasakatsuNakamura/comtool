class ChangeByteOrderToProject < ActiveRecord::Migration[5.0]
  def change
    change_column :projects, :byte_order, :integer, null: false
    change_column :projects, :byte_order, :integer, default: 0
  end
end
