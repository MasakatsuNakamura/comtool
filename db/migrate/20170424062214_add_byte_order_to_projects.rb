class AddByteOrderToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :byte_order, :integer
  end
end
