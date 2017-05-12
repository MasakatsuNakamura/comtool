class CreateCommunicationProtocols < ActiveRecord::Migration[5.0]
  def change
    create_table :communication_protocols do |t|
      t.string :protocol_number, :unique => true
      t.string :name

      t.timestamps
    end
  end
end
