class CreateSigns < ActiveRecord::Migration[5.0]
  def change
    create_table :signs do |t|
      t.string :name
      t.integer :active
      t.integer :vartype
      t.string :unit
      t.float :exchange_rate
      t.integer :priority
      t.integer :input_module
      t.integer :output_moduel
      t.integer :input_period
      t.integer :output_period
      t.integer :access_level
      t.string :description
      t.belongs_to :project, foreign_key: true

      t.timestamps
    end
  end
end
