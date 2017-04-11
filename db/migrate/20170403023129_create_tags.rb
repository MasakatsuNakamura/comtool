class CreateTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tags do |t|
      t.string :name
      t.string :description
      t.belongs_to :config, foreign_key: true

      t.timestamps
    end
  end
end
