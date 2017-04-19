class ChangeNameToComSignalAddNocase < ActiveRecord::Migration[5.0]
  # 変更内容
  def up
    change_column :com_signals, :name, :string, unique: true, collation: 'NOCASE'
  end

  # 変更前の状態
  def down
    change_column :com_signals, :name, :string, unique: true
  end
end
