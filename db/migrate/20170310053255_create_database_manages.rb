class CreateDatabaseManages < ActiveRecord::Migration[5.0]
  def change
    create_table :database_manages do |t|
      t.string :backup_file_path
      t.date :backup_date
      t.belongs_to :project, foreign_key: true

      t.timestamps
    end
  end
end
