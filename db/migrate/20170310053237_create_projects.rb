class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.belongs_to :communication_protocol, foreign_key: true
      t.belongs_to :qines_version, foreign_key: true

      t.timestamps
    end
  end
end
