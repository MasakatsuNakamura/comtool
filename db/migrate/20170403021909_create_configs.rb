class CreateConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :configs do |t|
      t.string :item
      t.string :value
      t.string :description
      t.belongs_to :project, foreign_key: true
      t.belongs_to :sign, foreign_key: true
      t.belongs_to :message, foreign_key: true

      t.timestamps
    end

  end
end
