class AddDataFrameToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :data_frame, :integer, null: false, default: 0
  end
end
