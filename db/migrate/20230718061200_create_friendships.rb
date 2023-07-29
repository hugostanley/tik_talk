class CreateFriendships < ActiveRecord::Migration[7.0]
  def change
    create_table :friendships do |t|
      t.references :recipient, null: false, foreign_key: { to_table: 'users' }
      t.references :requestor, null: false, foreign_key: { to_table: 'users' }
      t.string :status

      t.timestamps
    end
  end
end
