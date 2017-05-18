class CreateModes < ActiveRecord::Migration[5.0]
  def change
    create_table :modes do |t|
      t.string :title
      t.text :param
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
