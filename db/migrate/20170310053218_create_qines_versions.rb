class CreateQinesVersions < ActiveRecord::Migration[5.0]
  def change
    create_table :qines_versions do |t|
      t.string :qines_version_number, :unique => true
      t.string :name

      t.timestamps
    end
  end
end
