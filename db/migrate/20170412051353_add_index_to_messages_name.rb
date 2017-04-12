class AddIndexToMessagesName < ActiveRecord::Migration[5.0]
  def change
    add_index :messages, [:project_id, :name], unique: true
  end
end
