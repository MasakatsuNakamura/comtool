class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.string :name
      t.integer :canid
      t.integer :txrx
      t.integer :baudrate
      t.belongs_to :project, foreign_key: true

      t.timestamps
    end
  end
end
