class AddColumnToMode < ActiveRecord::Migration[5.0]
  def change
    add_column :modes, :image_json, :text
  end
end
