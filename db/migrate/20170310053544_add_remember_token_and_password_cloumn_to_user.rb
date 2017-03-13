class AddRememberTokenAndPasswordCloumnToUser < ActiveRecord::Migration[5.0]
  def change
    # 追加
    add_column :users, :remember_token, :string
    add_column :users, :password, :string
  end
end
