class AddIndexToUsersOpenid < ActiveRecord::Migration
  def change
  	add_index :users, :openid, unique: true
  end
end
