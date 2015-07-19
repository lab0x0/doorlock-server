class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :openid
      t.string :name
      t.string :type, null: false, default: 'Users::Member'

      t.timestamps null: false
    end
  end
end
