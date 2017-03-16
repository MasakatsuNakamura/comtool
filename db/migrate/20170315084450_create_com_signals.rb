class CreateComSignals < ActiveRecord::Migration[5.0]
  def change
    create_table :com_signals do |t|
      t.string :name
      t.belongs_to :message, foreign_key: true
      t.string :unit
      t.string :description
      t.integer :layout
      t.integer :bit_offset
      t.integer :bit_size
      t.belongs_to :sign, foreign_key: true

      t.timestamps
    end
  end
end
